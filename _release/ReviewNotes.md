# App Review Information(レビュー担当向け)

App Store Connect → アプリ → 該当 Version → **App Review Information** にコピペ。

## Sign-in Required

**No**(ログイン機能なし。Demo Account も不要)

## Notes(英語推奨、レビュー担当の理解が早い)

```
Hello reviewer,

Overview:
- ArchitectWords (建築士単語帳) is a vocabulary flashcard app for Japanese architect license exams (一級建築士 / 二級建築士).
- All vocabulary content is authored by the developer; no third-party copyrighted material is used.
- Fully offline. No login required. All data is stored locally on the device using SwiftData.

Ads:
- The app shows a Google AdMob banner at the bottom of Home / Word List / Add tabs.
- We use Non-Personalized Ads (npa: 1) only. No IDFA-based behavioral targeting.
- We do NOT request App Tracking Transparency permission.
- The Settings tab does not show any ads.

In-App Purchase:
- One Non-Consumable IAP: "Remove Ads" (Product ID: com.bashio.ArchitectWords.removeads, ¥280).
- Settings tab → "広告を削除" to test purchase flow.
- Settings tab → "購入を復元" to test restore.

Test path:
1. Launch the app — Home screen appears with progress card and category grid.
2. Tap any category → study mode opens with flashcards.
3. Tap a card to flip front <-> back.
4. Use the star / triangle / check buttons to mark favorite / weak / memorized.
5. "一覧" tab — search and filter words.
6. "追加" tab — add a custom word, then verify it appears in the list.
7. "設定" tab — verify no ads here. Tap "広告を削除" to test IAP. Tap "購入を復元" to test restore.

Note: All exam-related vocabulary is original content authored by the developer. No content is taken from any official exam materials, textbooks, or copyrighted sources. The app is intended as a personal study aid, not a substitute for official preparation materials.

Contact: kinniku.kin.gin@gmail.com
```

## 攻めポイントの予防対応

### Q. 「試験名を商標として使っているのでは?」

→ App Review Notes に記載済みの通り、本アプリの単語データは開発者が独自に作成したもので、「建築士」は職能の一般名称として使用しています(商標ではない)。試験運営機関の名称は使用していません。

### Q. 「App 内課金画面で価格をハードコードしていない?」

→ コードは `Product.displayPrice` を使用。`SettingsView.swift` の購入セクションで確認可能。

### Q. 「『購入を復元』が動くか?」

→ 設定タブ → 「購入を復元」をタップで `AppStore.sync()` が走る実装。

### Q. 「オフライン動作するか?」

→ 機内モードで全機能(カード学習、追加、検索、フィルタ)が動作することを確認。広告は表示されないだけで挙動に影響なし。

## Resolution Center に届いた問い合わせへの返信テンプレ

`/Users/kazuo/00_system/templates/appstore_release/09_rejection_patterns_and_fixes.md` を参照。
