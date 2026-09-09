#!/bin/sh
# 建築士単語帳(ArchitectWords) — アーカイブから App Store Connect への投稿まで。
#
#   sh release.sh archive   アーカイブを作る
#   sh release.sh export    ipa を書き出す
#   sh release.sh upload    App Store Connect へ投稿する
#   sh release.sh all       上を順に全部
#
# 審査提出はしない。投稿までで止まる。審査提出は依頼者に確認してから別途行う。
# 手本は ~/Developer/app-sushi/release.sh。

set -eu

ROOT="$HOME/Documents/建築士単語帳/ArchitectWords"
ARCHIVE="$ROOT/build/ArchitectWords.xcarchive"
EXPORT_DIR="$ROOT/build/export"
IPA="$EXPORT_DIR/ArchitectWords.ipa"

TEAM_ID="89JWWGRJ34"
PROFILE="ArchitectWords AppStore"
SIGN_SHA1="C84C569D8D0D0651226209FF58E39B91F7E16DC9"
API_KEY="Q22VK9HYVG"
API_ISSUER="248e62bb-71dc-402d-9712-02b876f0db5e"

# 署名は専用のビルドキーチェーンを使う。login キーチェーンの鍵は codesign から
# 使うたびに GUI の許可ダイアログが出て、非対話のビルドが止まる。
KEYCHAIN="$HOME/Library/Keychains/harvestmvp-build.keychain-db"
KEYCHAIN_PW="harvestmvp_build_keychain_2026"

unlock_keychain() {
  security unlock-keychain -p "$KEYCHAIN_PW" "$KEYCHAIN"
}

do_archive() {
  echo "アーカイブを作ります"
  unlock_keychain
  cd "$ROOT"
  xcodebuild \
    -project ArchitectWords.xcodeproj \
    -scheme ArchitectWords \
    -configuration Release \
    -destination "generic/platform=iOS" \
    -archivePath "$ARCHIVE" \
    archive \
    CODE_SIGN_STYLE=Manual \
    CODE_SIGN_IDENTITY="$SIGN_SHA1" \
    PROVISIONING_PROFILE_SPECIFIER="$PROFILE" \
    DEVELOPMENT_TEAM="$TEAM_ID" \
    OTHER_CODE_SIGN_FLAGS="--keychain $KEYCHAIN"
}

do_export() {
  echo "ipa を書き出します"
  unlock_keychain
  rm -rf "$EXPORT_DIR"
  xcodebuild -exportArchive \
    -archivePath "$ARCHIVE" \
    -exportPath "$EXPORT_DIR" \
    -exportOptionsPlist "$ROOT/ExportOptions.plist" \
    -allowProvisioningUpdates
  ls -la "$EXPORT_DIR"
}

do_upload() {
  echo "App Store Connect へ投稿します"
  xcrun altool --upload-app \
    -f "$IPA" \
    -t ios \
    --apiKey "$API_KEY" \
    --apiIssuer "$API_ISSUER"
}

case "${1:-all}" in
  archive) do_archive ;;
  export)  do_export ;;
  upload)  do_upload ;;
  all)     do_archive; do_export; do_upload ;;
  *)       echo "使い方: sh release.sh [archive|export|upload|all]"; exit 1 ;;
esac
