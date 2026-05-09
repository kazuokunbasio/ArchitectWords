import Foundation
import SwiftData

/// `seed_words.json` を初回起動時(または `seedVersion` 更新時)に SwiftData へ投入するヘルパー。
@MainActor
enum WordSeeder {
    /// JSON のレコード形。`Word` モデルへ写像する。
    private struct SeedRecord: Decodable {
        let term: String
        let reading: String?
        let meaning: String
        let detail: String?
        let category: String
        let importance: Int?
    }

    /// メインスレッドから一度呼ぶ。版番号が同じなら何もしない。
    static func seedIfNeeded(modelContext: ModelContext) {
        let metaFetch = FetchDescriptor<SeedMeta>()
        let metas = (try? modelContext.fetch(metaFetch)) ?? []

        if let meta = metas.first, meta.seedVersion >= SeedConstants.currentVersion {
            return
        }

        guard let url = Bundle.main.url(forResource: "seed_words", withExtension: "json") else {
            assertionFailure("seed_words.json not found in bundle")
            return
        }
        guard let data = try? Data(contentsOf: url) else { return }

        let decoder = JSONDecoder()
        guard let records = try? decoder.decode([SeedRecord].self, from: data) else {
            assertionFailure("seed_words.json failed to decode")
            return
        }

        // 既存のシード由来単語(isUserAdded == false)を一旦削除して入れ直す。
        // ユーザー追加分(isUserAdded == true)は保持する。
        let allFetch = FetchDescriptor<Word>(predicate: #Predicate { !$0.isUserAdded })
        let existingSeed = (try? modelContext.fetch(allFetch)) ?? []
        for w in existingSeed { modelContext.delete(w) }

        for r in records {
            let category = WordCategory(rawValue: r.category) ?? .other
            let word = Word(
                term: r.term,
                reading: r.reading ?? "",
                meaning: r.meaning,
                detail: r.detail ?? "",
                category: category,
                importance: r.importance ?? 2,
                isUserAdded: false
            )
            modelContext.insert(word)
        }

        if let meta = metas.first {
            meta.seedVersion = SeedConstants.currentVersion
            meta.seededAt = .now
        } else {
            modelContext.insert(SeedMeta(seedVersion: SeedConstants.currentVersion))
        }

        try? modelContext.save()
    }
}
