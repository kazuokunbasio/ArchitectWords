import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            HomeView()
                .withBanner()
                .tabItem { Label("ホーム", systemImage: "house") }

            WordListView()
                .withBanner()
                .tabItem { Label("一覧", systemImage: "list.bullet") }

            WordEditEntryView()
                .withBanner()
                .tabItem { Label("追加", systemImage: "plus.circle") }

            SettingsView()
                .tabItem { Label("設定", systemImage: "gearshape") }
        }
        .task {
            WordSeeder.seedIfNeeded(modelContext: modelContext)
        }
    }
}

/// 「追加」タブから飛ぶ単語編集の入口。新規追加モードで `WordEditView` を開く。
struct WordEditEntryView: View {
    var body: some View {
        NavigationStack {
            WordEditView(word: nil)
        }
    }
}
