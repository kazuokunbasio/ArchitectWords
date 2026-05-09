import SwiftUI
import SwiftData

/// 一覧画面の並び順。
enum WordSortOrder: String, CaseIterable, Identifiable {
    case createdDesc = "新着順"
    case importanceDesc = "重要度順"
    case readingAsc = "50 音順"
    case categoryAsc = "カテゴリ順"
    var id: String { rawValue }
    var systemImage: String {
        switch self {
        case .createdDesc: return "calendar"
        case .importanceDesc: return "star.fill"
        case .readingAsc: return "textformat"
        case .categoryAsc: return "folder"
        }
    }
}

struct WordListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Word.createdAt, order: .reverse)]) private var allWords: [Word]

    @State private var searchText: String = ""
    @State private var categoryFilter: WordCategory? = nil
    @State private var onlyFavorite: Bool = false
    @State private var onlyWeak: Bool = false
    /// 重要度のしきい値。1 = 全件、2 = ★★以上、3 = ★★★のみ。
    @State private var minImportance: Int = 1
    @State private var sortOrder: WordSortOrder = .createdDesc

    private var filtered: [Word] {
        let base = allWords.filter { word in
            if onlyFavorite && !word.isFavorite { return false }
            if onlyWeak && !word.isWeak { return false }
            if word.importance < minImportance { return false }
            if let c = categoryFilter, word.categoryEnum != c { return false }
            if searchText.isEmpty { return true }
            let q = searchText.lowercased()
            return word.term.lowercased().contains(q)
                || word.reading.lowercased().contains(q)
                || word.meaning.lowercased().contains(q)
        }
        return sorted(base)
    }

    private func sorted(_ words: [Word]) -> [Word] {
        switch sortOrder {
        case .createdDesc:
            return words.sorted { $0.createdAt > $1.createdAt }
        case .importanceDesc:
            // 重要度降順 → 同じ重要度なら作成日降順
            return words.sorted {
                if $0.importance != $1.importance { return $0.importance > $1.importance }
                return $0.createdAt > $1.createdAt
            }
        case .readingAsc:
            return words.sorted {
                let a = $0.reading.isEmpty ? $0.term : $0.reading
                let b = $1.reading.isEmpty ? $1.term : $1.reading
                return a.localizedCompare(b) == .orderedAscending
            }
        case .categoryAsc:
            // 列挙順 (計画 → 環境・設備 → 法規 → 構造 → 施工 → その他)
            let order = Dictionary(uniqueKeysWithValues:
                WordCategory.allCases.enumerated().map { ($1, $0) })
            return words.sorted {
                let oa = order[$0.categoryEnum] ?? Int.max
                let ob = order[$1.categoryEnum] ?? Int.max
                if oa != ob { return oa < ob }
                return $0.term.localizedCompare($1.term) == .orderedAscending
            }
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
            .navigationTitle("単語一覧 \(filtered.count) / \(allWords.count)")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "単語・読み・意味で検索")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Section("並び順") {
                            ForEach(WordSortOrder.allCases) { order in
                                Button {
                                    sortOrder = order
                                } label: {
                                    Label(order.rawValue, systemImage: order.systemImage)
                                    if sortOrder == order {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
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
        VStack(spacing: 6) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(label: "すべて", isOn: categoryFilter == nil && !onlyFavorite && !onlyWeak && minImportance == 1) {
                        categoryFilter = nil; onlyFavorite = false; onlyWeak = false; minImportance = 1
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
                .padding(.top, 8)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    importanceChip(label: "重要度すべて", value: 1)
                    importanceChip(label: "★★ 以上", value: 2)
                    importanceChip(label: "★★★ のみ", value: 3)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    private func importanceChip(label: String, value: Int) -> some View {
        FilterChip(label: label, isOn: minImportance == value, tint: .accentColor) {
            minImportance = value
        }
    }

    private func row(_ word: Word) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text(word.term)
                    .font(.body.weight(.semibold))
                if word.importance == 3 {
                    Text("★★★").font(.caption2).foregroundStyle(.red)
                } else if word.importance == 2 {
                    Text("★★").font(.caption2).foregroundStyle(.orange)
                }
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
