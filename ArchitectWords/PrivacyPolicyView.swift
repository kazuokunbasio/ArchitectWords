import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerBlock

                    section(title: "1. 収集する情報", body: """
                    本アプリは外部サーバへの個人情報送信を行いません。
                    以下のデータは端末内 (SwiftData) にのみ保存されます。
                    ・登録した単語・読み・意味・解説
                    ・暗記済み・お気に入り・苦手などの学習状態
                    ・カテゴリ・重要度などの分類情報
                    """)

                    section(title: "2. 端末の機能の利用", body: """
                    本アプリは特別な権限を要求しません。通信もアプリ内課金と広告配信に必要なもの以外には行いません。
                    本アプリは App Tracking Transparency (ATT) による広告識別子 (IDFA) の利用許可は要求しません。
                    """)

                    section(title: "3. 解析と広告", body: """
                    本アプリは Google AdMob を利用して、アプリ下部にバナー広告を表示します。また、学習を一区切りつけて画面を離れたときに全画面広告を表示することがあります。
                    AdMob は「非パーソナライズ広告 (Non-Personalized Ads)」モードで動作し、広告識別子 (IDFA) を用いた行動ターゲティングは行いません。配信のために端末の種類・OS バージョン・大まかな位置情報 (IP から推定) などが利用される場合があります。
                    詳細は Google のプライバシーポリシー (https://policies.google.com/privacy) をご確認ください。
                    広告を表示したくない場合は、設定タブの「広告を削除」からアプリ内課金で恒久的に非表示にできます。
                    """)

                    section(title: "4. アプリ内課金について", body: """
                    本アプリ内のすべての課金処理は Apple の StoreKit (App内課金) を通じて行われます。
                    本アプリの開発者はユーザーのクレジットカード情報・Apple ID・その他の決済情報を一切取得しません。本アプリが取得するのは「対象商品が購入済みかどうか」の購入状態のみです。
                    """)

                    section(title: "5. データの削除", body: """
                    設定タブの「すべてのデータをリセット」から、保存されている単語・学習状態をすべて削除できます。
                    アプリをアンインストールした場合も、端末内のデータは消去されます。
                    """)

                    section(title: "6. 子供のプライバシー", body: """
                    本アプリは13歳未満の子供から個人を特定できる情報を意図的に収集することはありません。
                    """)

                    section(title: "7. お問い合わせ", body: """
                    ご質問は開発者までお問い合わせください: kinniku.kin.gin@gmail.com
                    本ポリシーは予告なく変更されることがあります。最新版は本画面でご確認ください。
                    """)

                    Text("最終更新: 2026 年 5 月")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("プライバシーポリシー")
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
            Text("建築士単語帳 プライバシーポリシー")
                .font(.title2.bold())
            Text("ご利用ありがとうございます。本アプリにおける情報の取り扱いについてご説明します。")
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
