# MASQ Mobile iOS application

This directory contains the React Native interface, iOS native bridge and mobile Rust wrapper for
the consume-only MASQ developer preview.

## Product behavior

- **MASQ Private** opens only after the embedded core has a peer and a real HTTP `CONNECT`
  preflight succeeds through a private exit route.
- **Browse without MASQ** is a separate, explicitly confirmed browser mode. It first stops the
  MASQ connection and then uses normal iPhone networking.
- A MASQ failure never selects Direct automatically.
- Browser routing returns to `blocked` when the browser closes or the app enters the background.
- The app starts Node only in `consume-only` mode. It does not serve routing or exit traffic.
- iOS whole-device and per-app routing are unsupported because this target contains no Packet
  Tunnel Network Extension.

## Main features

- Base Mainnet and Base Sepolia profiles.
- Import from a 12-word recovery phrase or a private key.
- Device-bound, unlocked-only Keychain persistence.
- Public RPC health and chain checks with bounded fallback.
- Automatic discovery, reachability testing, retry and caching of two entry nodes.
- Single-flight connection control and cancellation.
- Configurable route length from one to six hops.
- Optional exit-country selection from the currently known MASQ neighborhood.
- MASQ and Base ETH balance checks with low-funds and gas guidance.
- Embedded Rust/MASQ Node runtime without a daemon or root privileges.
- Separate non-persistent WebKit stores for MASQ and Direct sessions.
- HTTPS-only navigation that blocks localhost, private and link-local destinations.
- Timpi Search for browser text that is not recognized as a public URL.
- Local ad/tracker, cross-site-cookie and cookie-consent protection.
- Privacy-safe diagnostics and actionable error categories.

## Traffic paths

```text
MASQ Private WebView
  -> local HTTP CONNECT proxy on 127.0.0.1
  -> embedded consume-only MASQ Node
  -> MASQ entry and relay nodes
  -> selected MASQ exit
  -> HTTPS destination

Explicit Direct WebView
  -> ordinary iPhone networking
  -> HTTPS destination
```

WebKit uses three native states:

- `blocked` — both stores point to an unreachable local sink;
- `masq` — only the dedicated MASQ store uses the local proxy; and
- `direct` — only the dedicated Direct store can use ordinary networking.

The MASQ store is never configured for direct networking. `failoverAllowed` remains disabled.

## Directory relationships

The native wrapper at `native/masq-mobile-core` depends on adapted crates in the sibling
`../masq-node-mobile` tree at the repository root. Keep both top-level directories in place.

The iOS Xcode build phase runs `scripts/build-rust-ios.sh`, produces a static Rust library for the
selected device architecture and force-loads it into the app. The Objective-C++ bridge blocks
private browsing when required native symbols are missing.

## Requirements

- macOS and Xcode 16.1 or later;
- Node.js 22.11 or later;
- Rust toolchain 1.77.2 plus the `aarch64-apple-ios` target;
- a user-managed Ruby 3.1 installation, Bundler 2.4.22 and CocoaPods 1.17.0;
- ripgrep (`rg`) for privacy and public-build guards; and
- an iOS 17+ iPhone for real MASQ route testing.

## Install dependencies

```bash
npm ci
rustup toolchain install 1.77.2 --profile minimal
rustup target add --toolchain 1.77.2 aarch64-apple-ios
gem install bundler -v 2.4.22
bundle _2.4.22_ install

cd ios
bundle _2.4.22_ exec pod install --deployment
cd ..
```

Always open `ios/MasqMobile.xcworkspace`, not the `.xcodeproj`.

## Run a Debug build

```bash
npm start
```

Choose a local Development Team and unique bundle identifier in Xcode, select the connected iPhone
and press **Run**. Metro must remain available to a Debug build.

The repository default, `org.masqmobile.community.development`, is only a placeholder. Signing
teams and personal bundle identifiers must remain local.

See the repository-level `IOS_DEVELOPER_INSTALL.md` for the complete device, Developer Mode,
signing and troubleshooting procedure.

## Install a self-contained development build

After the dependencies and Pods are installed:

```bash
MASQ_IOS_DEVICE_ID='<device-id>' \
APPLE_DEVELOPMENT_TEAM='<10-character-team-id>' \
MASQ_BUNDLE_IDENTIFIER='com.yourname.masqmobile.dev' \
./scripts/install-ios-development.sh
```

The script builds a signed Release development app, verifies source and binary boundaries,
installs it with `devicectl` and launches it. It defaults to the MASQ development node finder. The
YouTube-specific experiment is compiled out, and an NFT access gate is rejected if detected.

## Configuration

Debug builds default to `https://dev2.api.masq.ai` for entry-node discovery. Release archive
automation requires the builder to provide a reviewed HTTPS node-finder URL. The developer
installer uses the development endpoint unless `MASQ_NODE_FINDER_URL` is supplied locally.

The app defaults to public Nodies and PublicNode RPC endpoints. Users can change the RPC under
advanced network settings; URLs with embedded credentials are rejected.

Do not commit:

- Apple Team IDs, signing identities, profiles or certificates;
- device identifiers or personal bundle identifiers;
- `.xcode.env.local`, local paths or environment files;
- recovery phrases, private keys, wallet databases or logs; or
- Pods, `node_modules`, Rust targets, Derived Data, apps, archives or IPAs.

## Browser protection

Protection preferences are local and separately controllable. The app can:

- block a limited authored set of known advertising/tracking requests;
- strip cookies from cross-site requests;
- hide recognized cookie-consent overlays; and
- optionally follow a supported **Configure → Reject all** consent flow.

Hiding a banner is cosmetic and is not itself a consent decision. Unrecognized full-page gates
remain visible. The rules are best effort and can occasionally break a page.

No external filter list, URL history, matching event or block count is downloaded or sent to the
maintainer. The public build excludes YouTube-specific filtering and avoids broad media-host
blocking.

## Verification

```bash
npm run typecheck
npm run lint
npm run test:ci:linux
npm run test:ci:ios
npm run test:core
npm run test:engine
npm run verify:privacy
```

- `test:ci:linux` checks shared TypeScript and UI behavior.
- `test:ci:ios` checks the Xcode bridge, Rust build phase, WebKit patch and public build guards.
- `test:core` checks the fail-closed Rust wrapper.
- `test:engine` compiles and smoke-tests the adapted MASQ Node integration.
- `verify:privacy` rejects personal paths, Apple signing data and private-key blocks.

An unsigned device build can be checked with:

```bash
xcodebuild \
  -workspace ios/MasqMobile.xcworkspace \
  -scheme MasqMobile \
  -configuration Release \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  CODE_SIGNING_ALLOWED=NO \
  MASQ_NODE_FINDER_URL=https://ci.invalid.example \
  ARCHS=arm64 \
  ONLY_ACTIVE_ARCH=YES \
  build
```

## Security boundaries

- Private traffic is blocked if the native core, peer, proxy or exit route is unavailable.
- Private navigation supports HTTPS only.
- The embedded browser does not protect Safari or other apps.
- Direct mode offers browser protection controls but no MASQ anonymity.
- Non-persistent WebKit stores reduce durable browser state; temporary data may remain in process
  memory until the web-content process exits.
- Wallet secrets leave React state after import and temporary Rust copies are zeroized.
- No software or decentralized network can guarantee complete anonymity.
