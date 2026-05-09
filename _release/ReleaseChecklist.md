# 提出前チェックリスト(建築士単語帳)

詳細は `/Users/kazuo/00_system/templates/appstore_release/15_release_checklist.md` を参照。本ファイルは ArchitectWords 固有の確認ポイントだけ。

## 0. 必ず最初に差し替えるもの(本番ビルド前に必須)

- [ ] `Info.plist` の `GADApplicationIdentifier` を、AdMob 管理画面で本アプリ用に発行した `~` 区切りのアプリ ID に差し替え
  - 現状: `ca-app-pub-3940256099942544~1458002511`(Google 公式テスト ID)
- [ ] `BannerView.swift` の `AdsConfig.productionBannerAdUnitID` を、本アプリ用バナーユニット `/` 区切り ID に差し替え
  - 現状: プレースホルダ `ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ`
- [ ] App Store Connect で `com.bashio.ArchitectWords.removeads` を Non-Consumable / 280 円 / Ready to Submit で作成
- [ ] AppIcon に 1024×1024 PNG(Alpha 無し)を配置(`Assets.xcassets/AppIcon.appiconset/`)

## 1. AdMob

- [ ] AdMob 管理画面で本アプリを「アプリを追加」 → Bundle ID `com.bashio.ArchitectWords` で登録
- [ ] アプリ ID(`~`)とバナー広告ユニット ID(`/`)を取得
- [ ] DEBUG ビルドではテスト ID が使われる(`#if DEBUG`)
- [ ] NPA=1 が `BannerView.nonPersonalizedRequest()` で毎リクエスト付与
- [ ] 設定画面に `.withBanner()` を呼んでいない(広告非表示)

## 2. StoreKit

- [ ] Product ID 一致: `PurchaseProductID.removeAds` / `ArchitectWords.storekit` / App Store Connect IAP の 3 箇所すべて `com.bashio.ArchitectWords.removeads`
- [ ] シミュレータの StoreKit Configuration が `ArchitectWords.storekit`(共有スキームで自動セット済み)
- [ ] Sandbox 実機購入テスト
- [ ] 「購入を復元」が動く
- [ ] 価格は `product.displayPrice` から取得

## 3. Privacy / Support URL(必ず 200 を確認してから提出)

```sh
echo "/ArchitectWords/             -> $(curl -s -o /dev/null -w '%{http_code}' https://kazuokunbasio.github.io/ArchitectWords/)"
echo "/ArchitectWords/privacy.html -> $(curl -s -o /dev/null -w '%{http_code}' https://kazuokunbasio.github.io/ArchitectWords/privacy.html)"
```

両方 200 が必須。`docs/` で Pages を有効化したか必ず確認(`/` ではなく `/docs`)。

- [ ] Pages が有効になっている: `gh api repos/kazuokunbasio/ArchitectWords/pages` で `source.path == "/docs"`
- [ ] Privacy URL が 200
- [ ] Support URL が 200

## 4. Info.plist

- [ ] `GADApplicationIdentifier` は `~` 区切りの本番アプリ ID
- [ ] `SKAdNetworkItems` 49 件
- [ ] `NSUserTrackingUsageDescription` が**含まれていない**(grep で確認)
- [ ] `ITSAppUsesNonExemptEncryption = false`(輸出申告省略)

## 5. App Store Connect

### App Information
- [ ] Privacy Policy URL を入力
- [ ] Support URL を入力
- [ ] Primary Category: Education
- [ ] Age Rating: 4+ で回答

### Pricing and Availability
- [ ] Free
- [ ] 配信国: 日本(or 他国も)

### App Privacy
- [ ] Identifiers > Device ID, Used for Third-Party Advertising, Tracking = No
- [ ] Usage Data > Product Interaction, Used for Third-Party Advertising, Tracking = No
- [ ] その他は Not Collected

### Version 1.0
- [ ] Description / Keywords / Support URL をメタデータファイルからコピペ
- [ ] What's New(初版なので「初版リリース」)
- [ ] Build を選択
- [ ] Copyright = `© 2026 kazuokunbasio`
- [ ] スクリーンショット 5 枚以上

### App Review Information
- [ ] Sign-in required = **No**
- [ ] Notes は `_release/ReviewNotes.md` をコピペ
- [ ] Contact: kinniku.kin.gin@gmail.com

## 6. アイコン

- [ ] `Assets.xcassets/AppIcon.appiconset/` に 1024×1024 PNG(`Alpha = no`)
- [ ] sips で確認:
  ```sh
  sips -g hasAlpha -g pixelWidth -g pixelHeight \
    ArchitectWords/Assets.xcassets/AppIcon.appiconset/<icon>.png
  ```

## 7. ビルド / Archive

- [ ] Xcode で Generic iOS Device を選択
- [ ] Product → Archive
- [ ] Build Number は前回 +1
- [ ] Validate App → Distribute App → Upload to App Store Connect
- [ ] TestFlight で Processing 完了 → 内部テスター(自分)で実機確認

## 8. TestFlight

- [ ] 起動クラッシュなし(Info.plist の AdMob App ID が正しい証拠)
- [ ] 全 4 タブ動作: ホーム / 一覧 / 追加 / 設定
- [ ] Home / 一覧 / 追加 タブにバナー、設定タブには出ない
- [ ] 設定 → 広告を削除 → ¥280 表示 → タップで Sandbox 購入 → バナー消滅
- [ ] アプリ削除 → 再インストール → 購入を復元で広告消滅状態に戻る
- [ ] 単語追加 → 一覧に出る → 編集 / 削除可能
- [ ] 検索・フィルタが動く
- [ ] 機内モードでもクラッシュせず動作する

## 9. 提出ボタン前

- [ ] App 提出時に IAP も同梱選択
- [ ] Export Compliance: Exempt
- [ ] Advertising Identifier: Yes(AdMob 利用)、Tracking = No
- [ ] Submit for Review

## 10. 公開後

- [ ] Resolution Center を毎日確認
- [ ] App Store ページが想定通り表示されているか
- [ ] AdMob 管理画面で fill rate / 収益が記録されているか(初日は 0 でも可)
