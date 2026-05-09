import Foundation
import SwiftData

@Model
final class Word {
    /// 表面に出る単語。例: 「免震構造」
    var term: String
    /// ふりがな / 読み。例: 「めんしんこうぞう」
    var reading: String
    /// 短い意味(裏面の最初に出る一行)
    var meaning: String
    /// 詳細解説(裏面の本文)
    var detail: String
    /// `WordCategory.rawValue` を保持。enum 直書きは Predicate で扱いにくいので String で持つ。
    var category: String
    /// 1〜3。3 が最重要。デフォルト 2。
    var importance: Int
    /// ユーザー操作: 暗記済みフラグ
    var isMemorized: Bool
    /// ユーザー操作: お気に入りフラグ
    var isFavorite: Bool
    /// ユーザー操作: 苦手フラグ(間違えた / 自信ない を後で復習する用)
    var isWeak: Bool
    /// シード由来 (false) かユーザー追加 (true) か。`true` のものだけユーザーが削除可能。
    var isUserAdded: Bool
    /// 作成日時。並び替え / 「新着」表示の基準。
    var createdAt: Date

    init(
        term: String,
        reading: String = "",
        meaning: String,
        detail: String = "",
        category: WordCategory,
        importance: Int = 2,
        isMemorized: Bool = false,
        isFavorite: Bool = false,
        isWeak: Bool = false,
        isUserAdded: Bool = true,
        createdAt: Date = .now
    ) {
        self.term = term
        self.reading = reading
        self.meaning = meaning
        self.detail = detail
        self.category = category.rawValue
        self.importance = max(1, min(3, importance))
        self.isMemorized = isMemorized
        self.isFavorite = isFavorite
        self.isWeak = isWeak
        self.isUserAdded = isUserAdded
        self.createdAt = createdAt
    }

    var categoryEnum: WordCategory {
        WordCategory(rawValue: category) ?? .other
    }
}
