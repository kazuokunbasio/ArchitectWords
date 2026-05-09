import Foundation
import SwiftData

/// 初回起動時のシード投入が完了したことを記録する 1 行モデル。
/// 「ユーザーが追加した単語」と「シード単語」を SwiftData 内で混ざらせず、
/// シードを再投入しない / 古いシードを差し替えるための version を持つ。
@Model
final class SeedMeta {
    /// シード版番号。`SeedConstants.currentVersion` と比較して再投入するか判定。
    var seedVersion: Int
    var seededAt: Date

    init(seedVersion: Int, seededAt: Date = .now) {
        self.seedVersion = seedVersion
        self.seededAt = seededAt
    }
}

enum SeedConstants {
    /// シード単語を新規追加 / 改訂したらこの値を上げる。
    /// v2: 法規分野を 7 -> 88 件に増補。
    /// v3: 構造 / 施工 / 計画 / 環境・設備 を増補し合計 285 件に。
    /// v4: GPT 補完(動線分類・荷重分類・単体規定 / 集団規定など)を統合し合計 699 件
    ///     (計画 105 / 環境・設備 144 / 法規 225 / 構造 133 / 施工 92)。
    ///     原典の引き写しは行わず、すべてオリジナル定義文を採用。
    static let currentVersion: Int = 4
}
