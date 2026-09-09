import SwiftUI
import SwiftData
import StoreKit

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var words: [Word]
    @Query private var seedMetas: [SeedMeta]

    @ObservedObject private var purchaseManager = PurchaseManager.shared
    @State private var showPrivacy = false
    @State private var showDisclaimer = false
    @State private var showResetConfirm = false
    @State private var showSeedReplaceConfirm = false

    var body: some View {
        NavigationStack {
            List {
                Section("購入") {
                    purchaseRow

                    Button {
                        Task { await purchaseManager.restore() }
                    } label: {
                        Label("購入を復元", systemImage: "arrow.clockwise")
                            .foregroundStyle(.primary)
                    }
                }

                Section("単語データ") {
                    LabeledContent("登録単語数", value: "\(words.count) 単語")
                    LabeledContent("ユーザー追加", value: "\(words.filter { $0.isUserAdded }.count) 単語")
                    LabeledContent("シード版", value: "v\(seedMetas.first?.seedVersion ?? 0)")
                    Button(role: .destructive) {
                        showSeedReplaceConfirm = true
                    } label: {
                        Label("シード単語を再投入", systemImage: "arrow.triangle.2.circlepath")
                    }
                    Button(role: .destructive) {
                        showResetConfirm = true
                    } label: {
                        Label("すべてのデータをリセット", systemImage: "trash")
                    }
                }

                Section("情報") {
                    Button {
                        showDisclaimer = true
                    } label: {
                        Label("免責事項", systemImage: "exclamationmark.bubble")
                            .foregroundStyle(.primary)
                    }
                    Button {
                        showPrivacy = true
                    } label: {
                        Label("プライバシーポリシー", systemImage: "hand.raised.fill")
                            .foregroundStyle(.primary)
                    }
                    // 版はここに直書きしない。書くと版を上げるたびに古いままになる。
                    LabeledContent("バージョン", value: Self.appVersion)
                }

                Section("お問い合わせ") {
                    Link(destination: URL(string: "mailto:kinniku.kin.gin@gmail.com")!) {
                        Label("kinniku.kin.gin@gmail.com", systemImage: "envelope")
                            .foregroundStyle(.primary)
                    }
                }
            }
            .navigationTitle("設定")
            .alert(
                "エラー",
                isPresented: Binding(
                    get: { purchaseManager.actionErrorMessage != nil },
                    set: { if !$0 { purchaseManager.actionErrorMessage = nil } }
                ),
                presenting: purchaseManager.actionErrorMessage
            ) { _ in
                Button("OK", role: .cancel) {}
            } message: { message in
                Text(message)
            }
            .alert("シード単語を再投入しますか?", isPresented: $showSeedReplaceConfirm) {
                Button("キャンセル", role: .cancel) {}
                Button("再投入", role: .destructive) { replaceSeed() }
            } message: {
                Text("既存のシード単語(初期収録)を一旦削除して入れ直します。あなたが追加した単語と暗記状態は保持されます。")
            }
            .alert("すべてリセットしますか?", isPresented: $showResetConfirm) {
                Button("キャンセル", role: .cancel) {}
                Button("リセット", role: .destructive) { resetAll() }
            } message: {
                Text("登録単語・進捗・お気に入りなどすべての保存データを削除します。")
            }
            .sheet(isPresented: $showPrivacy) {
                PrivacyPolicyView()
            }
            .sheet(isPresented: $showDisclaimer) {
                DisclaimerView()
            }
            .task {
                if purchaseManager.products.isEmpty {
                    await purchaseManager.bootstrap()
                }
            }
        }
    }

    /// Info.plist から取る。手で書くと版を上げたときに必ず食い違う。
    private static var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
        return v
    }

    @ViewBuilder
    private var purchaseRow: some View {
        if purchaseManager.hasRemovedAds {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green).font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    Text("広告削除済み").font(.body)
                    Text("ありがとうございます").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
            }
        } else if let product = purchaseManager.removeAdsProduct {
            Button {
                Task { await purchaseManager.purchaseRemoveAds() }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "rectangle.slash")
                        .foregroundStyle(.primary).font(.title3)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("広告を削除").font(.body).foregroundStyle(.primary)
                        Text("バナーと全画面の広告を永久に非表示").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    if purchaseManager.isPurchasing {
                        ProgressView()
                    } else {
                        Text(product.displayPrice).font(.callout.weight(.semibold))
                    }
                }
            }
            .disabled(purchaseManager.isPurchasing)
        } else {
            HStack(spacing: 12) {
                Image(systemName: "rectangle.slash")
                    .foregroundStyle(.primary).font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    Text("広告を削除").font(.body)
                    Text(purchaseManager.isLoadingProducts ? "価格を取得中…" : "価格を取得できませんでした")
                        .font(.caption).foregroundStyle(.secondary).lineLimit(2)
                }
                Spacer()
                if purchaseManager.isLoadingProducts {
                    ProgressView()
                } else {
                    Button("再読み込み") {
                        Task { await purchaseManager.reloadProducts() }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        }
    }

    private func replaceSeed() {
        // SeedMeta の seedVersion を 0 に下げて、Seeder に再投入を強制する。
        if let meta = seedMetas.first {
            meta.seedVersion = 0
        }
        try? modelContext.save()
        WordSeeder.seedIfNeeded(modelContext: modelContext)
    }

    private func resetAll() {
        for w in words { modelContext.delete(w) }
        for m in seedMetas { modelContext.delete(m) }
        try? modelContext.save()
        // 直後にシードを入れ直して、空の状態にしない。
        WordSeeder.seedIfNeeded(modelContext: modelContext)
    }
}
