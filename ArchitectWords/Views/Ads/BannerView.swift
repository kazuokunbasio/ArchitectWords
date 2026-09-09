import SwiftUI
import GoogleMobileAds
import UIKit

enum AdsConfig {
    /// 本番のバナー広告ユニット ID。AdMob 管理画面で発行 (`/` 区切り) したもの。
    /// Info.plist の GADApplicationIdentifier(`~` 区切り)とは別物なので混同しない。
    static let productionBannerAdUnitID = "ca-app-pub-2165259899292420/3900651940"

    /// Google 公式テスト用バナー ID。シミュレータ / DEBUG ビルドで利用。
    /// https://developers.google.com/admob/ios/test-ads
    static let testBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"

    static var bannerAdUnitID: String {
        #if DEBUG
        return testBannerAdUnitID
        #else
        return productionBannerAdUnitID
        #endif
    }

    /// アンカー型アダプティブのサイズ。幅が 0 以下のときは端末幅で代用する。
    static func adaptiveSize(for width: CGFloat) -> GADAdSize {
        let w = width > 0 ? width : UIScreen.main.bounds.width
        return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(w)
    }

    /// その幅のときのバナーの高さ。SwiftUI 側の枠取りに使う。
    static func adaptiveHeight(for width: CGFloat) -> CGFloat {
        adaptiveSize(for: width).size.height
    }
}

@MainActor
enum AdsBootstrap {
    private static var didStart = false

    static func startIfNeeded() {
        guard !didStart else { return }
        didStart = true

        #if DEBUG
        // 実機でテスト広告を強制したいときはデバイス ID を追記する。
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = []
        #endif

        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
}

struct BannerView: UIViewRepresentable {
    let adUnitID: String
    /// バナーを置く場所の横幅。アンカー型アダプティブの高さがこれで決まる。
    let width: CGFloat

    init(adUnitID: String = AdsConfig.bannerAdUnitID, width: CGFloat) {
        self.adUnitID = adUnitID
        self.width = width
    }

    func makeUIView(context: Context) -> GADBannerView {
        // 固定 320x50 ではなくアンカー型アダプティブを使う。
        // 端末の幅いっぱいに出るぶん埋まりやすく、単価も上がる。Google が薦めているのもこちら。
        let banner = GADBannerView(adSize: AdsConfig.adaptiveSize(for: width))
        banner.adUnitID = adUnitID
        banner.rootViewController = Self.topViewController()
        banner.load(Self.nonPersonalizedRequest())
        return banner
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {}

    /// ATT を使わない方針のため、毎リクエストで Non-Personalized Ads (NPA) を明示する。
    private static func nonPersonalizedRequest() -> GADRequest {
        let extras = GADExtras()
        extras.additionalParameters = ["npa": "1"]
        let request = GADRequest()
        request.register(extras)
        return request
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

/// `@AppStorage("adsRemoved")` を尊重し、購入後は自動で消えるバナーコンテナ。
/// 高さは幅から決まる(アンカー型アダプティブ)ので、ここでは固定値を書かない。
struct AdBannerContainer: View {
    @AppStorage("adsRemoved") private var adsRemoved: Bool = false

    var body: some View {
        if !adsRemoved {
            GeometryReader { geo in
                BannerView(width: geo.size.width)
                    .frame(width: geo.size.width,
                           height: AdsConfig.adaptiveHeight(for: geo.size.width))
            }
            .frame(height: AdsConfig.adaptiveHeight(for: UIScreen.main.bounds.width))
        }
    }
}

/// タブのコンテンツ領域内・最下部にバナーを配置するラッパー。
/// 設定タブ等、広告を出したくない画面では呼ばない。
struct BannerHostingView<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            AdBannerContainer()
        }
    }
}

extension View {
    func withBanner() -> some View {
        BannerHostingView { self }
    }
}
