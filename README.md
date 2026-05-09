# 建築士単語帳 (ArchitectWords)

建築士試験に必要な重要単語を、表裏カード形式で覚えるための学習アプリ。

## 技術スタック

- Swift 5 / SwiftUI
- SwiftData(端末内永続化)
- StoreKit 2(非消耗型「広告削除」課金)
- Google AdMob (Banner、NPA=1 固定、ATT 不使用)
- iPhone 専用、iOS 17 以降
- ログイン不要、サーバなし、オフライン動作

## ディレクトリ構成

```
ArchitectWords/
├── ArchitectWords.xcodeproj/
│   └── xcshareddata/xcschemes/ArchitectWords.xcscheme  StoreKit Configuration を埋め込んだ共有スキーム
├── ArchitectWords/                                      アプリソース (synchronized group)
│   ├── ArchitectWordsApp.swift                          @main
│   ├── ContentView.swift                                TabView ルート
│   ├── HomeView / StudyView / WordListView / WordEditView / SettingsView / PrivacyPolicyView
│   ├── Models/
│   │   ├── Word.swift           SwiftData @Model
│   │   ├── WordCategory.swift   出題分野 enum
│   │   └── SeedMeta.swift       シード版番号管理
│   ├── Data/
│   │   ├── seed_words.json      初期単語データ
│   │   └── WordSeeder.swift     初回起動時にシード投入
│   └── Views/
│       ├── Ads/BannerView.swift          AdMob (NPA=1)
│       └── Purchase/PurchaseManager.swift StoreKit 2
├── Info.plist                                  GADApplicationIdentifier / SKAdNetworkItems
├── ArchitectWords.storekit                     ローカル StoreKit Configuration
├── docs/                                        GitHub Pages 配信
│   ├── index.html
│   └── privacy.html
└── _release/
    ├── AppStoreMetadata.md
    ├── ReviewNotes.md
    ├── ReleaseChecklist.md
    └── SwapListForNextApp.md
```

## セットアップ

```sh
git clone https://github.com/kazuokunbasio/ArchitectWords.git
cd ArchitectWords
open ArchitectWords.xcodeproj
```

Xcode で `Cmd+R` を押すと、共有スキームに `ArchitectWords.storekit` が紐付いているのでローカル StoreKit テストが可能。

## 主要 ID 一覧

| 項目 | 値 |
|---|---|
| Bundle Identifier | `com.bashio.ArchitectWords` |
| Display Name | 建築士単語帳 |
| App Store Category | Education |
| IAP Product ID(広告削除) | `com.bashio.ArchitectWords.removeads` |
| AdMob App ID(Info.plist) | `ca-app-pub-2165259899292420~2745306775` |
| AdMob Banner Unit ID(コード) | `ca-app-pub-2165259899292420/3900651940` |
| 収録単語数(初期シード v4) | **699 件**(計画 105 / 環境・設備 144 / 法規 225 / 構造 133 / 施工 92) |
| 動作要件 | iPhone, iOS 17 以降 |

## リリース手順

`_release/ReleaseChecklist.md` を上から順に潰す。詳細手順は
`/Users/kazuo/00_system/templates/appstore_release/` 配下のドキュメント参照。

## ライセンス

未定(個人開発)。
