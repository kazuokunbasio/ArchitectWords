# 次回別資格アプリへの差し替え箇所一覧

ArchitectWords を雛形にして別の資格勉強アプリ(例: 「電工単語帳」「行政書士単語帳」「TOEIC 単語帳」など)を作る場合、機械的に差し替えれば動くポイントを集約。

## A. プロジェクト識別子(不可逆)

| 場所 | ArchitectWords の値 | 新規アプリで変える値の例 |
|---|---|---|
| Xcode プロジェクト名 | `ArchitectWords` | `ElectricianWords` |
| `project.pbxproj` 内 全箇所 | `ArchitectWords` | 同上(検索置換) |
| Bundle ID | `com.bashio.ArchitectWords` | `com.bashio.ElectricianWords` |
| Display Name(`INFOPLIST_KEY_CFBundleDisplayName`) | 建築士単語帳 | 電工単語帳 |
| プロジェクトフォルダ | `~/Documents/建築士単語帳/ArchitectWords/` | `~/Documents/電工単語帳/ElectricianWords/` |
| `MARKETING_VERSION` | 1.0 | 1.0(初版) |
| `CURRENT_PROJECT_VERSION` | 1 | 1(初版) |

## B. AdMob

| 場所 | ArchitectWords の値 | 新規アプリで変える値 |
|---|---|---|
| `Info.plist` の `GADApplicationIdentifier` | `ca-app-pub-3940256099942544~1458002511`(Google公式テスト) | AdMob で新アプリ追加 → `~` ID |
| `BannerView.swift` の `productionBannerAdUnitID` | `ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ`(プレースホルダ) | 新アプリ用バナー `/` ID |
| テスト ID | `ca-app-pub-3940256099942544/2934735716` | 変更不要 |

## C. StoreKit / 課金

| 場所 | ArchitectWords の値 | 新規アプリで変える値 |
|---|---|---|
| `PurchaseProductID.removeAds` | `com.bashio.ArchitectWords.removeads` | `com.bashio.<NewApp>.removeads` |
| `<App>.storekit` の `productID` | 同上 | 同上 |
| `<App>.storekit` の `internalID` | UUID 1 | `uuidgen` で新規発行 |
| `<App>.storekit` の `identifier` (top-level) | UUID 2 | 同上 |
| `displayName` / `description`(en/ja) | 広告削除 / Remove Ads | アプリに合わせ修正 |
| App Store Connect の IAP | `com.bashio.ArchitectWords.removeads` を Non-Consumable | コードと一致する Product ID |

## D. データ(資格毎に総入れ替え)

| 場所 | ArchitectWords の値 | 新規アプリで変える値 |
|---|---|---|
| `seed_words.json` | 建築士の単語(30件) | 該当資格の単語 |
| `WordCategory` 列挙 | 計画 / 環境・設備 / 法規 / 構造 / 施工 / その他 | 該当資格の出題分野 |
| `WordCategory.systemImage` | カテゴリ別 SF Symbol | アイコンも変える |

## E. GitHub / Pages

| 場所 | ArchitectWords の値 | 新規アプリで変える値 |
|---|---|---|
| GitHub リポジトリ名 | `ArchitectWords` | `ElectricianWords` |
| Privacy URL | `https://kazuokunbasio.github.io/ArchitectWords/privacy.html` | `https://kazuokunbasio.github.io/<NewApp>/privacy.html` |
| Support URL | `https://kazuokunbasio.github.io/ArchitectWords/` | `https://kazuokunbasio.github.io/<NewApp>/` |
| `docs/index.html` のアプリ名 / 概要 / FAQ | 建築士単語帳 | アプリに合わせ修正 |
| `docs/privacy.html` のアプリ名 / 1. 収集する情報 | 同上 | 同上 |
| アプリ内 `PrivacyPolicyView` のヘッダー / 連絡先 | 同上 | 同上(公開と整合) |
| GitHub Pages の Source path | `/docs` | **`/docs` のまま(必須)** |

## F. App Icon

| 場所 | ArchitectWords の値 | 新規アプリで変える値 |
|---|---|---|
| `Assets.xcassets/AppIcon.appiconset/` | 未配置(1024 PNG を入れる) | 新アプリ用 1024×1024 PNG (Alpha 無し) |

## G. App Store Connect 入力

| フィールド | ArchitectWords の値 | 新規アプリで変える値 |
|---|---|---|
| App Name | 建築士単語帳 | アプリ名(30 字) |
| Subtitle | 一級・二級建築士の重要単語をカードで暗記 | アプリのサブタイトル(30 字) |
| Primary Category | Education | 資格系なら同じく Education |
| Description | 建築士単語帳用 | `_release/AppStoreMetadata.md` を雛形に書き換え |
| Keywords | 建築士,単語帳,暗記,フラッシュカード,試験対策,一級建築士,二級建築士,資格,学習,オフライン | 該当資格名・分野を入れる |
| Screenshots | 建築士単語帳の画面 | 新アプリの画面 |
| Privacy Policy URL / Support URL | 上記 E | 上記 E |
| Copyright | © 2026 kazuokunbasio | 年度更新 |
| App Review Notes | 建築士用 | `_release/ReviewNotes.md` を雛形に英語で書き直し |

## H. ATT / NPA(変更不要)

| 場所 | 値 |
|---|---|
| `NSUserTrackingUsageDescription` | **追加しない**(Info.plist に含めない) |
| `BannerView.swift` の `npa: "1"` | 変更不要 |

## I. 連絡先

| 場所 | ArchitectWords の値 | 新規アプリで変える値 |
|---|---|---|
| `docs/*.html` / `PrivacyPolicyView` / `SettingsView` のメール | `kinniku.kin.gin@gmail.com` | 必要に応じ別アドレス |

## J. 共有スキーム

| 場所 | ArchitectWords の値 | 新規アプリで変える値 |
|---|---|---|
| `<App>.xcscheme` の `BlueprintIdentifier` | `84B4DC9C2FAD636E0078373A`(target UUID 流用可) | 新規プロジェクトでは Xcode 自動生成 UUID を貼る |
| `BuildableName` | `ArchitectWords.app` | `<NewApp>.app` |
| `BlueprintName` / `ReferencedContainer` | `ArchitectWords` / `container:ArchitectWords.xcodeproj` | `<NewApp>` / `container:<NewApp>.xcodeproj` |
| `<StoreKitConfigurationFileReference identifier>` | `../../ArchitectWords.storekit` | `../../<NewApp>.storekit` |

## K. .gitignore / README

| 場所 | 変更要否 |
|---|---|
| `.gitignore` | そのまま流用可 |
| `README.md` | アプリ概要 / Bundle ID / 主要 ID 一覧を書き直す |

## L. 機械的なリネーム手順(目安)

新規プロジェクトを `ArchitectWords` から派生させる場合:

```sh
# 1. プロジェクトをコピー
cp -R ~/Documents/建築士単語帳/ArchitectWords ~/Documents/電工単語帳/ElectricianWords

# 2. ファイル名のリネーム
cd ~/Documents/電工単語帳/ElectricianWords
mv ArchitectWords.xcodeproj ElectricianWords.xcodeproj
mv ArchitectWords.storekit ElectricianWords.storekit
mv ArchitectWords ElectricianWords  # source folder
mv ElectricianWords.xcodeproj/xcshareddata/xcschemes/ArchitectWords.xcscheme \
   ElectricianWords.xcodeproj/xcshareddata/xcschemes/ElectricianWords.xcscheme

# 3. 中身の文字列置換(Display Name 以外)
LC_ALL=C find . -type f \( -name "*.swift" -o -name "*.plist" -o -name "*.pbxproj" -o -name "*.xcscheme" -o -name "*.storekit" -o -name "*.html" -o -name "*.md" -o -name "*.json" \) -print0 \
  | xargs -0 sed -i '' 's/ArchitectWords/ElectricianWords/g'
LC_ALL=C find . -type f \( -name "*.pbxproj" -o -name "*.swift" -o -name "*.storekit" \) -print0 \
  | xargs -0 sed -i '' 's/com\.bashio\.ArchitectWords/com.bashio.ElectricianWords/g'

# 4. Display Name と日本語名は別途手動で書き換え

# 5. .storekit の UUID を再発行
uuidgen   # 2 個発行して中の identifier / internalID を置換

# 6. SwiftData モデルのスキーマ互換性問題を避けるため、もし可能ならビルド後初回起動でデータをリセット
```

## M. 提出までのざっくり工数感

ArchitectWords の構成踏襲なら、新規アプリでの追加作業は:

- 単語データ作成(資格固有): 1〜数日
- カテゴリ enum の差し替え: 30 分
- AppIcon 作成: 1 時間
- 全文字列置換と差し替え: 1 時間
- AdMob / App Store Connect 設定: 1 時間
- Archive / Upload / TestFlight 確認: 半日
- 提出: 1 時間

**合計: 単語データを除けば 1 日強で App Store 提出に到達可能。**
