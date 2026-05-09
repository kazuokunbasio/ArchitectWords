import Foundation
import Combine
import StoreKit

enum PurchaseProductID {
    static let removeAds = "com.bashio.ArchitectWords.removeads"
}

/// `@AppStorage("adsRemoved")` と連携する StoreKit 2 ベースの課金マネージャ。
/// 起動時に `bootstrap()` を呼び、UI からは `purchaseRemoveAds()` / `restore()` / `reloadProducts()` を叩く。
@MainActor
final class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoadingProducts: Bool = false
    @Published private(set) var isPurchasing: Bool = false

    /// 商品取得失敗時の inline 表示用
    @Published private(set) var productLoadError: String?
    /// 購入 / 復元中の一過性エラー (alert 表示)
    @Published var actionErrorMessage: String?

    private var transactionListener: Task<Void, Never>?

    var removeAdsProduct: Product? {
        products.first { $0.id == PurchaseProductID.removeAds }
    }

    var removeAdsPriceText: String? {
        removeAdsProduct?.displayPrice
    }

    var hasRemovedAds: Bool {
        purchasedProductIDs.contains(PurchaseProductID.removeAds)
    }

    private init() {
        transactionListener = startTransactionListener()
    }

    deinit { transactionListener?.cancel() }

    func bootstrap() async {
        await loadProducts()
        await refreshEntitlements()
    }

    func loadProducts() async {
        isLoadingProducts = true
        productLoadError = nil
        defer { isLoadingProducts = false }
        do {
            let fetched = try await Product.products(for: [PurchaseProductID.removeAds])
            if fetched.isEmpty {
                products = []
                productLoadError = "商品情報を取得できませんでした。Edit Scheme → Run → Options → StoreKit Configuration に ArchitectWords.storekit を設定してください。実機では App Store Connect で商品が「Ready to Submit」になっているか確認してください。"
            } else {
                products = fetched
            }
        } catch {
            products = []
            productLoadError = "商品情報の取得に失敗しました: \(error.localizedDescription)"
        }
    }

    func reloadProducts() async { await loadProducts() }

    func purchaseRemoveAds() async {
        guard let product = removeAdsProduct else {
            actionErrorMessage = "商品情報が読み込めていません。「再読み込み」を実行してください。"
            return
        }
        await purchase(product)
    }

    func purchase(_ product: Product) async {
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await refreshEntitlements()
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            actionErrorMessage = "購入に失敗しました: \(error.localizedDescription)"
        }
    }

    func restore() async {
        do {
            try await AppStore.sync()
        } catch {
            actionErrorMessage = "購入の復元に失敗しました: \(error.localizedDescription)"
        }
        await refreshEntitlements()
    }

    func refreshEntitlements() async {
        var ids: Set<String> = []
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.revocationDate == nil && !transaction.isUpgraded {
                ids.insert(transaction.productID)
            }
        }
        purchasedProductIDs = ids
        UserDefaults.standard.set(hasRemovedAds, forKey: "adsRemoved")
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error): throw error
        case .verified(let value): return value
        }
    }

    nonisolated private func startTransactionListener() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await update in Transaction.updates {
                if case .verified(let transaction) = update {
                    await transaction.finish()
                }
                await self?.refreshEntitlements()
            }
        }
    }
}
