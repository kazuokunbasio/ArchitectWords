import SwiftUI
import SwiftData

@main
struct ArchitectWordsApp: App {
    init() {
        AdsBootstrap.startIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task { await PurchaseManager.shared.bootstrap() }
        }
        .modelContainer(for: [Word.self, SeedMeta.self])
    }
}
