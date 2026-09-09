import Foundation
import GoogleMobileAds
import UIKit

/// 全画面広告(インタースティシャル)の読み込みと表示。
///
/// 出してよいのは学習を一区切りつけた瞬間だけ。カードをめくっている最中には出さない。
/// 呼び出しは `StudyView` の1か所に限る。増やすときはここのコメントも直すこと。
///
/// 頻度の上限はコードで持つ。AdMob 管理画面側の設定は消えることがあるが、コードは消えない。
@MainActor
final class InterstitialAds: NSObject {
    static let shared = InterstitialAds()

    /// 本番の全画面広告ユニット ID(`/` 区切り)。
    /// Info.plist の GADApplicationIdentifier(`~` 区切り)とは別物なので混同しない。
    private static let productionAdUnitID = "ca-app-pub-2165259899292420/5296611552"

    /// Google 公式テスト用インタースティシャル ID。シミュレータ / DEBUG ビルドで使う。
    /// https://developers.google.com/admob/ios/test-ads
    private static let testAdUnitID = "ca-app-pub-3940256099942544/4411468910"

    private static var adUnitID: String {
        #if DEBUG
        return testAdUnitID
        #else
        return productionAdUnitID
        #endif
    }

    /// 前に出してから最低これだけ空ける。
    private static let minInterval: TimeInterval = 180
    /// 1回の起動で出す上限。
    private static let maxPerSession = 2

    private var loaded: GADInterstitialAd?
    private var isLoading = false
    private var lastShownAt: Date?
    private var shownThisSession = 0

    private override init() { super.init() }

    /// 「広告を削除」を買った人には何もしない。バナーと同じ `adsRemoved` を見る。
    private var adsRemoved: Bool {
        UserDefaults.standard.bool(forKey: "adsRemoved")
    }

    /// 次の1本を先に読み込んでおく。表示の瞬間に読み始めると間に合わない。
    /// 起動時には呼ばない。学習が始まって、区切りが近づいてから呼ぶ。
    func preload() {
        guard !adsRemoved, loaded == nil, !isLoading else { return }
        isLoading = true
        let request = GADRequest()
        let extras = GADExtras()
        // ATT を使わない方針なので、毎リクエストで非パーソナライズを明示する。
        extras.additionalParameters = ["npa": "1"]
        request.register(extras)

        GADInterstitialAd.load(withAdUnitID: Self.adUnitID, request: request) { [weak self] ad, error in
            guard let self else { return }
            Task { @MainActor in
                self.isLoading = false
                if let error {
                    print("[ads] interstitial load failed: \(error.localizedDescription)")
                    self.loaded = nil
                    return
                }
                ad?.fullScreenContentDelegate = self
                self.loaded = ad
            }
        }
    }

    /// 読み込み済みで、上限に達していなければ出す。
    /// 出せなかった1本は捨てずに持ち続け、次の機会に回す。
    func show() {
        guard !adsRemoved else { return }
        guard shownThisSession < Self.maxPerSession else { return }
        if let last = lastShownAt, Date().timeIntervalSince(last) < Self.minInterval { return }
        guard let ad = loaded else {
            preload() // 次の機会に間に合わせる
            return
        }
        guard let root = Self.topViewController() else { return }
        // 画面遷移の最中に出そうとすると iOS に断られる。
        // 呼び出し側で遷移が終わるのを待ってから呼ぶこと。
        guard root.presentedViewController == nil else { return }
        ad.present(fromRootViewController: root)
    }

    private static func topViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })?
            .windows
            .first(where: \.isKeyWindow)?
            .rootViewController
    }
}

extension InterstitialAds: GADFullScreenContentDelegate {
    /// 実際に画面が開いたときだけ数える。断られた分は数えない。
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        loaded = nil
        lastShownAt = Date()
        shownThisSession += 1
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        loaded = nil
        preload()
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("[ads] interstitial present failed: \(error.localizedDescription)")
        // 出せなかっただけなので、次の機会に読み直す。
        loaded = nil
        preload()
    }
}
