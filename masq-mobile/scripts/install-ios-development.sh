#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKSPACE="$ROOT_DIR/ios/MasqMobile.xcworkspace"
SCHEME="MasqMobile"
CONFIGURATION="Release"
DEVICE_ID="${MASQ_IOS_DEVICE_ID:-}"
TEAM_ID="${APPLE_DEVELOPMENT_TEAM:-}"
BUNDLE_IDENTIFIER="${MASQ_BUNDLE_IDENTIFIER:-}"
DERIVED_DATA="${MASQ_IOS_DERIVED_DATA:-$ROOT_DIR/native/build/ios-development}"

# Reuse the strict local input validation without running the App Store archive
# entry point.
source "$ROOT_DIR/scripts/archive-ios-app-store.sh"
# archive-ios-app-store.sh intentionally has no node-finder default. Restore the
# public developer default after loading its validation helpers.
NODE_FINDER_URL="${MASQ_NODE_FINDER_URL:-https://dev2.api.masq.ai}"

main() {
  [ -d "$WORKSPACE" ] || fail "Run bundle exec pod install in ios/ before installing."
  [ -n "$DEVICE_ID" ] || fail "Set MASQ_IOS_DEVICE_ID to the connected iPhone identifier."
  [ -n "$TEAM_ID" ] || fail "Set APPLE_DEVELOPMENT_TEAM to your 10-character Apple Team ID."
  [[ "$TEAM_ID" =~ ^[A-Z0-9]{10}$ ]] || fail "APPLE_DEVELOPMENT_TEAM is not a valid Team ID."
  [[ "$BUNDLE_IDENTIFIER" =~ ^[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$ ]] || \
    fail "Set MASQ_BUNDLE_IDENTIFIER to a unique bundle ID registered to your team."
  validate_node_finder_url "$NODE_FINDER_URL" || \
    fail "Set MASQ_NODE_FINDER_URL to an approved HTTPS endpoint."

  "$ROOT_DIR/scripts/verify-ios-webview-patch.sh"
  "$ROOT_DIR/scripts/verify-source-privacy.sh"
  mkdir -p "$DERIVED_DATA"

  xcodebuild \
    -workspace "$WORKSPACE" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination "id=$DEVICE_ID" \
    -derivedDataPath "$DERIVED_DATA" \
    -allowProvisioningUpdates \
    -allowProvisioningDeviceRegistration \
    DEVELOPMENT_TEAM="$TEAM_ID" \
    CODE_SIGN_STYLE=Automatic \
    PRODUCT_BUNDLE_IDENTIFIER="$BUNDLE_IDENTIFIER" \
    MASQ_NODE_FINDER_URL="$NODE_FINDER_URL" \
    'GCC_PREPROCESSOR_DEFINITIONS=$(inherited) MASQ_PRIVATE_YOUTUBE_AD_BLOCKER=0' \
    build

  local app_path="$DERIVED_DATA/Build/Products/$CONFIGURATION-iphoneos/MasqMobile.app"
  local executable="$app_path/MasqMobile"
  local built_bundle_identifier
  [ -x "$executable" ] || fail "The signed MasqMobile.app was not produced."

  built_bundle_identifier="$(
    /usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app_path/Info.plist"
  )"
  [ "$built_bundle_identifier" = "$BUNDLE_IDENTIFIER" ] || \
    fail "The built bundle identifier does not match the requested identifier."
  if rg -a -q -F "$HOME/" "$app_path"; then
    fail "The development app contains a path from this local user account."
  fi
  if rg -a -q '__masqPrivateYouTubeFilter' "$executable"; then
    fail "The public development binary unexpectedly contains the private YouTube filter."
  fi
  if rg -a -q 'E_ACCESS_PASS|checkAccessPass|NFT access' "$app_path"; then
    fail "The development app unexpectedly contains NFT access-gate code."
  fi

  xcrun devicectl device install app --device "$DEVICE_ID" "$app_path"
  xcrun devicectl device process launch --device "$DEVICE_ID" "$BUNDLE_IDENTIFIER"

  echo "Installed and launched the public iOS development build."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
