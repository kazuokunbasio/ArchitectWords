import SwiftUI

/// 免責。書き方の正本は ~/AppBusiness/03_共通仕様/11_免責の書き方.md。
///
/// 5つの柱(公式ではない / 出どころ / 保証しない / 限界 / 責任)を必ず全部書く。
/// どれか1つでも黙ると、読む側が誤解できる余地が残る。
/// 資格の本なので、実施機関の正式名称を挙げて「関係がありません」と名指しで書く。
struct DisclaimerView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerBlock

                    section(title: "1. 公式のアプリではありません", body: """
                    本アプリは個人が作った学習用の単語帳で、一級・二級建築士試験を実施する公益財団法人建築技術教育普及センター、国土交通省、その他の官公庁・団体・出版社とは一切関係がありません。
                    これらの団体が本アプリを監修・承認・推薦している事実はありません。
                    """)

                    section(title: "2. 収録した言葉の出どころ", body: """
                    収録している用語・読み・意味・解説は、建築の分野で一般に使われている言葉を開発者が自分で書き起こしたものです。
                    試験問題そのもの、市販の単語帳・参考書の文章を写したものではありません。
                    """)

                    section(title: "3. 正しさと合否は保証できません", body: """
                    内容には誤り・古い記述・説明の不足が含まれている可能性があります。
                    建築基準法をはじめとする法令や各種基準は改正されます。改正後の内容が本アプリに反映されているとは限りません。
                    本アプリを使ったことで試験に合格することを保証するものではありません。
                    """)

                    section(title: "4. これで判断しないでください", body: """
                    設計・施工・申請など実務上の判断や、試験本番の答えを本アプリだけで決めないでください。
                    法令の正本は e-Gov 法令検索(https://elaws.e-gov.go.jp/)です。
                    試験の範囲・出題形式・受験資格は、実施機関が公表する最新の受験要項に従ってください。
                    """)

                    section(title: "5. 責任について", body: """
                    本アプリの利用によって生じた損害について、開発者は責任を負いません。
                    誤りにお気づきの場合は、設定画面のお問い合わせ先までご連絡ください。確認のうえ修正します。
                    """)
                }
                .padding(20)
            }
            .navigationTitle("免責事項")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("建築士単語帳 免責事項")
                .font(.title2.bold())
            Text("お使いになる前に、次の5つをご確認ください。")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    private func section(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            Text(body)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
