import SwiftUI
import SwiftData

/// 学習画面で使うフィルタ。Home / WordList から渡されて、表示対象を絞る。
enum StudyFilter: Equatable {
    case all
    case weak
    case favorite
    case category(WordCategory)
    case search(String, WordCategory?, Bool, Bool) // text, category, onlyFavorite, onlyWeak

    var title: String {
        switch self {
        case .all: return "全単語"
        case .weak: return "苦手単語"
        case .favorite: return "お気に入り"
        case .category(let c): return c.rawValue
        case .search: return "検索結果"
        }
    }
}

struct StudyView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allWords: [Word]
    @State private var index: Int = 0
    @State private var isFlipped: Bool = false
    @State private var shuffledIDs: [PersistentIdentifier] = []

    let filter: StudyFilter

    init(filter: StudyFilter) {
        self.filter = filter
    }

    private var filtered: [Word] {
        let base: [Word]
        switch filter {
        case .all:
            base = allWords
        case .weak:
            base = allWords.filter { $0.isWeak }
        case .favorite:
            base = allWords.filter { $0.isFavorite }
        case .category(let c):
            base = allWords.filter { $0.categoryEnum == c }
        case .search(let text, let category, let onlyFavorite, let onlyWeak):
            base = allWords.filter { word in
                if onlyFavorite && !word.isFavorite { return false }
                if onlyWeak && !word.isWeak { return false }
                if let c = category, word.categoryEnum != c { return false }
                if text.isEmpty { return true }
                let q = text.lowercased()
                return word.term.lowercased().contains(q)
                    || word.reading.lowercased().contains(q)
                    || word.meaning.lowercased().contains(q)
            }
        }
        // 順序固定: Home から開いた直後にシャッフルし、shuffledIDs にキャッシュ。
        if shuffledIDs.isEmpty {
            return base
        }
        let map = Dictionary(uniqueKeysWithValues: base.map { ($0.persistentModelID, $0) })
        return shuffledIDs.compactMap { map[$0] }
    }

    private var current: Word? {
        guard !filtered.isEmpty else { return nil }
        return filtered[min(index, filtered.count - 1)]
    }

    var body: some View {
        VStack(spacing: 0) {
            if filtered.isEmpty {
                emptyView
            } else if let word = current {
                cardArea(word: word)
                actionBar(word: word)
            }
        }
        .navigationTitle(filter.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    shuffle()
                } label: {
                    Image(systemName: "shuffle")
                }
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .onAppear { if shuffledIDs.isEmpty { shuffle() } }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("対象の単語がありません")
                .font(.headline)
            Text("「追加」タブから新しい単語を登録できます。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func cardArea(word: Word) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("\(min(index + 1, filtered.count)) / \(filtered.count)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                Spacer()
                Label(word.categoryEnum.rawValue, systemImage: word.categoryEnum.systemImage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            Button {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                    isFlipped.toggle()
                }
            } label: {
                cardBody(word: word)
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func cardBody(word: Word) -> some View {
        ZStack {
            // 表
            cardFace(content: {
                VStack(spacing: 10) {
                    if !word.reading.isEmpty {
                        Text(word.reading)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(word.term)
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                    Text("タップで意味を表示")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 8)
                }
                .padding()
            })
            .opacity(isFlipped ? 0 : 1)
            .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))

            // 裏
            cardFace(content: {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(word.term)
                            .font(.title3.weight(.semibold))
                        Divider()
                        Text(word.meaning)
                            .font(.body)
                        if !word.detail.isEmpty {
                            Text(word.detail)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
            })
            .opacity(isFlipped ? 1 : 0)
            .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 360)
    }

    private func cardFace<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }

    private func actionBar(word: Word) -> some View {
        HStack(spacing: 8) {
            iconToggle(systemName: word.isFavorite ? "star.fill" : "star",
                       tint: .yellow,
                       isOn: word.isFavorite) {
                word.isFavorite.toggle()
                try? modelContext.save()
            }
            iconToggle(systemName: word.isWeak ? "exclamationmark.triangle.fill" : "exclamationmark.triangle",
                       tint: .orange,
                       isOn: word.isWeak) {
                word.isWeak.toggle()
                try? modelContext.save()
            }
            iconToggle(systemName: word.isMemorized ? "checkmark.circle.fill" : "checkmark.circle",
                       tint: .green,
                       isOn: word.isMemorized) {
                word.isMemorized.toggle()
                if word.isMemorized { word.isWeak = false }
                try? modelContext.save()
            }
            Spacer()
            Button {
                advance(by: -1)
            } label: {
                Image(systemName: "chevron.left").frame(width: 44, height: 44)
            }
            .buttonStyle(.bordered)
            Button {
                advance(by: 1)
            } label: {
                Image(systemName: "chevron.right").frame(width: 44, height: 44)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func iconToggle(systemName: String, tint: Color, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .frame(width: 44, height: 44)
                .foregroundStyle(isOn ? tint : .secondary)
        }
        .buttonStyle(.bordered)
    }

    private func advance(by delta: Int) {
        guard !filtered.isEmpty else { return }
        let next = (index + delta + filtered.count) % filtered.count
        withAnimation(.easeInOut(duration: 0.15)) {
            isFlipped = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            index = next
        }
    }

    private func shuffle() {
        let base: [Word]
        switch filter {
        case .all: base = allWords
        case .weak: base = allWords.filter { $0.isWeak }
        case .favorite: base = allWords.filter { $0.isFavorite }
        case .category(let c): base = allWords.filter { $0.categoryEnum == c }
        case .search: base = filtered
        }
        shuffledIDs = base.shuffled().map { $0.persistentModelID }
        index = 0
        isFlipped = false
    }
}
