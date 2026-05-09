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
    static let currentVersion: Int = 1
}
