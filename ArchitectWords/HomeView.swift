import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allWords: [Word]

    private var totalCount: Int { allWords.count }
    private var memorizedCount: Int { allWords.filter { $0.isMemorized }.count }
    private var weakCount: Int { allWords.filter { $0.isWeak }.count }
    private var favoriteCount: Int { allWords.filter { $0.isFavorite }.count }

    private var progressRatio: Double {
        guard totalCount > 0 else { return 0 }
        return Double(memorizedCount) / Double(totalCount)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    progressCard
                    quickActionRow
                    categoryGrid
                }
                .padding()
            }
            .navigationTitle("建築士単語帳")
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("学習進捗")
                    .font(.headline)
                Spacer()
                Text("\(memorizedCount) / \(totalCount)")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: progressRatio)
                .tint(.accentColor)
            HStack(spacing: 16) {
                statBadge(icon: "star.fill", title: "お気に入り", value: favoriteCount, color: .yellow)
                statBadge(icon: "exclamationmark.triangle.fill", title: "苦手", value: weakCount, color: .orange)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func statBadge(icon: String, title: String, value: Int, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundStyle(color)
            VStack(alignment: .leading, spacing: 0) {
                Text(title).font(.caption).foregroundStyle(.secondary)
                Text("\(value) 単語").font(.callout.weight(.medium))
            }
            Spacer()
        }
        .padding(10)
        .background(Color(uiColor: .tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var quickActionRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("今日の復習")
                .font(.headline)
            HStack(spacing: 10) {
                NavigationLink {
                    StudyView(filter: .weak)
                } label: {
                    actionTile(icon: "exclamationmark.triangle.fill", title: "苦手単語", subtitle: "\(weakCount) 件", tint: .orange)
                }
                NavigationLink {
                    StudyView(filter: .favorite)
                } label: {
                    actionTile(icon: "star.fill", title: "お気に入り", subtitle: "\(favoriteCount) 件", tint: .yellow)
                }
            }
            NavigationLink {
                StudyView(filter: .all)
            } label: {
                actionTile(icon: "play.fill", title: "全単語をシャッフル学習", subtitle: "\(totalCount) 件", tint: .accentColor)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func actionTile(icon: String, title: String, subtitle: String, tint: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundStyle(tint)
            VStack(alignment: .leading, spacing: 0) {
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(.primary)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var categoryGrid: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("カテゴリ別")
                .font(.headline)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(WordCategory.allCases) { cat in
                    NavigationLink {
                        StudyView(filter: .category(cat))
                    } label: {
                        categoryTile(cat)
                    }
                }
            }
        }
    }

    private func categoryTile(_ cat: WordCategory) -> some View {
        let count = allWords.filter { $0.categoryEnum == cat }.count
        return HStack(spacing: 10) {
            Image(systemName: cat.systemImage).foregroundStyle(.accent)
            VStack(alignment: .leading, spacing: 2) {
                Text(cat.rawValue).font(.subheadline.weight(.semibold)).foregroundStyle(.primary)
                Text("\(count) 単語").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
