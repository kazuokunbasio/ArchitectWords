import SwiftUI
import SwiftData

struct WordListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Word.createdAt, order: .reverse)]) private var allWords: [Word]

    @State private var searchText: String = ""
    @State private var categoryFilter: WordCategory? = nil
    @State private var onlyFavorite: Bool = false
    @State private var onlyWeak: Bool = false

    private var filtered: [Word] {
        allWords.filter { word in
            if onlyFavorite && !word.isFavorite { return false }
            if onlyWeak && !word.isWeak { return false }
            if let c = categoryFilter, word.categoryEnum != c { return false }
            if searchText.isEmpty { return true }
            let q = searchText.lowercased()
            return word.term.lowercased().contains(q)
                || word.reading.lowercased().contains(q)
                || word.meaning.lowercased().contains(q)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar
                List {
                    ForEach(filtered) { word in
                        NavigationLink {
                            WordEditView(word: word)
                        } label: {
                            row(word)
                        }
                    }
                    .onDelete(perform: deleteUserAdded)
                }
                .listStyle(.plain)
                .overlay {
                    if filtered.isEmpty {
                        ContentUnavailableView("該当する単語がありません",
                                               systemImage: "magnifyingglass",
                                               description: Text("検索条件を変えるか、追加タブから単語を追加してください。"))
                    }
                }
            }
            .navigationTitle("単語一覧")
            .searchable(text: $searchText, prompt: "単語・読み・意味で検索")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        StudyView(filter: .search(searchText, categoryFilter, onlyFavorite, onlyWeak))
                    } label: {
                        Image(systemName: "play.fill")
                    }
                    .disabled(filtered.isEmpty)
                }
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(label: "すべて", isOn: categoryFilter == nil && !onlyFavorite && !onlyWeak) {
                    categoryFilter = nil; onlyFavorite = false; onlyWeak = false
                }
                FilterChip(label: "★ お気に入り", isOn: onlyFavorite, tint: .yellow) {
                    onlyFavorite.toggle()
                }
                FilterChip(label: "苦手", isOn: onlyWeak, tint: .orange) {
                    onlyWeak.toggle()
                }
                Divider().frame(height: 24)
                ForEach(WordCategory.allCases) { c in
                    FilterChip(label: c.rawValue, isOn: categoryFilter == c) {
                        categoryFilter = (categoryFilter == c) ? nil : c
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    private func row(_ word: Word) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text(word.term)
                    .font(.body.weight(.semibold))
                if word.isFavorite {
                    Image(systemName: "star.fill").font(.caption2).foregroundStyle(.yellow)
                }
                if word.isWeak {
                    Image(systemName: "exclamationmark.triangle.fill").font(.caption2).foregroundStyle(.orange)
                }
                if word.isMemorized {
                    Image(systemName: "checkmark.circle.fill").font(.caption2).foregroundStyle(.green)
                }
                Spacer()
                Text(word.categoryEnum.rawValue).font(.caption).foregroundStyle(.secondary)
            }
            Text(word.meaning)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }

    /// 削除はユーザー追加分のみ。シード由来は触れさせない。
    private func deleteUserAdded(at offsets: IndexSet) {
        for i in offsets {
            let word = filtered[i]
            guard word.isUserAdded else { continue }
            modelContext.delete(word)
        }
        try? modelContext.save()
    }
}

private struct FilterChip: View {
    let label: String
    let isOn: Bool
    var tint: Color = .accentColor
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    isOn
                    ? tint.opacity(0.18)
                    : Color(uiColor: .secondarySystemGroupedBackground)
                )
                .foregroundStyle(isOn ? tint : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
