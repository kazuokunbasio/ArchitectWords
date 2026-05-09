import Foundation

/// 建築士試験の出題分野。
/// 文字列リテラル(rawValue)が SwiftData の `Word.category` として保存される。
/// 順序は CaseIterable で TabBar / Picker の表示順に直結するので慎重に変えること。
enum WordCategory: String, CaseIterable, Identifiable, Codable {
    case planning = "計画"
    case environment = "環境・設備"
    case law = "法規"
    case structure = "構造"
    case construction = "施工"
    case other = "その他"

    var id: String { rawValue }

    /// SF Symbols のアイコン。Home / WordList のアクセント用。
    var systemImage: String {
        switch self {
        case .planning: return "ruler"
        case .environment: return "leaf"
        case .law: return "books.vertical"
        case .structure: return "building.columns"
        case .construction: return "hammer"
        case .other: return "doc.text"
        }
    }
}
