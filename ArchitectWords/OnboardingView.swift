import SwiftUI

/// 初回起動時のみ表示する操作ヒント。
/// `@AppStorage("onboardingShown")` が false の間だけ ContentView から sheet で出る。
struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("onboardingShown") private var onboardingShown: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    feature(icon: "rectangle.on.rectangle.angled.fill",
                            title: "カードをタップして反転",
                            body: "表で「単語」、タップで裏返して「意味」と「詳細解説」を確認できます。")
                    feature(icon: "star.fill", tint: .yellow,
                            title: "お気に入り / 苦手 / 暗記済み",
                            body: "学習画面の下部ボタンでワンタップ仕分け。フィルタで絞り込んで効率的に復習できます。")
                    feature(icon: "magnifyingglass",
                            title: "検索とカテゴリ絞り込み",
                            body: "「一覧」タブで単語・読み・意味から検索。計画 / 環境・設備 / 法規 / 構造 / 施工 のカテゴリ別に並び替えも可能。")
                    feature(icon: "plus.circle.fill", tint: .green,
                            title: "自分の単語を追加",
                            body: "「追加」タブから独自の単語をいつでも登録できます。あとで編集・削除も自由です。")
                    feature(icon: "rectangle.slash",
                            title: "広告について",
                            body: "本アプリは無料運営のためバナー広告を表示します。「設定 → 広告を削除」のアプリ内購入で永久に非表示にできます。")
                }
                .padding(24)
            }

            VStack(spacing: 0) {
                Divider()
                Button {
                    onboardingShown = true
                    dismiss()
                } label: {
                    Text("はじめる")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .background(.thinMaterial)
        }
        .interactiveDismissDisabled(true)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("ようこそ")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text("建築士単語帳へ")
                .font(.largeTitle.bold())
            Text("一級・二級建築士試験の重要単語を、表裏カードでサクサク覚えるアプリです。")
                .font(.callout)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
    }

    private func feature(icon: String, tint: Color = .accentColor, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(tint)
                .frame(width: 32, alignment: .center)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(body).font(.subheadline).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
