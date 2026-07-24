# MASQ Mobile for iOS — developer preview

This repository contains an experimental, consume-only MASQ client for iPhone. It embeds an
adapted MASQ Node runtime and can purchase private routes without serving routing or exit traffic
for other peers.

This is an independent community development build, not an official MASQ Project release. It has
not completed an independent mobile security audit. Use a separate wallet with only funds
appropriate for experimental software.

## What this repository provides

- An iOS 17+ React Native app with the native MASQ core compiled into the application.
- Wallet import from a 12-word recovery phrase or private key, stored in device-bound iOS
  Keychain storage.
- Automatic RPC validation, entry-node discovery and bounded retry.
- Configurable route length and optional exit-country preference.
- An embedded **MASQ Private** browser that is fail-closed: a failed route never falls back to the
  phone's direct connection.
- A separate, explicitly confirmed **Browse without MASQ** mode.
- Local browser protection for a limited set of advertising, tracking, cross-site-cookie and
  cookie-consent resources.
- English user interface, source documentation and diagnostics.

## Important routing boundary

Only traffic inside the embedded **MASQ Private** browser is routed through MASQ. This repository
does not contain an iOS Packet Tunnel Network Extension and does not claim to protect Safari,
other apps or all traffic on the iPhone. **Browse without MASQ** deliberately uses the device's
ordinary network, so websites see the public IP address of that connection or any separately
active VPN.

The app is consume-only. It does not open public listening ports or let the phone serve as a relay
or exit node.

## Install on your own iPhone

There is no universal IPA in this repository. Apple development provisioning ties a local build
to the builder's Apple account, signing team, bundle identifier and registered device. Each person
therefore compiles and signs their own copy on a Mac.

Requirements:

- a Mac with Xcode 16.1 or later and its command-line tools;
- an iPhone running iOS 17 or later;
- an Apple account added to Xcode;
- Node.js 22.11 or later, Rust 1.77.2, Ruby 3.1 with Bundler 2.4.22,
  CocoaPods and ripgrep (`rg`); and
- Developer Mode enabled on the iPhone.

Quick start:

```bash
git clone https://github.com/EndTheCB2/MasqMobile-IOS-Developer.git
cd MasqMobile-IOS-Developer/masq-mobile

npm ci
rustup toolchain install 1.77.2 --profile minimal
rustup target add --toolchain 1.77.2 aarch64-apple-ios
gem install bundler -v 2.4.22
bundle _2.4.22_ install

cd ios
bundle _2.4.22_ exec pod install --deployment
open MasqMobile.xcworkspace
```

In Xcode, select the `MasqMobile` target, choose your own Development Team, replace
`org.masqmobile.community.development` with a globally unique bundle identifier, select the
connected iPhone and press **Run**. A Debug build also needs Metro running in a second terminal.
Change to the cloned app directory, regardless of the new terminal's starting directory:

```bash
cd /path/to/MasqMobile-IOS-Developer/masq-mobile
npm start
```

Follow the complete [iPhone developer installation guide](IOS_DEVELOPER_INSTALL.md) for Developer
Mode, trust, signing, the optional command-line installer and troubleshooting.

## Repository layout

- `masq-mobile/` — React Native interface, iOS bridge, native Rust wrapper, tests and build scripts.
- `masq-node-mobile/` — complete adapted MASQ Node source required by the native wrapper.

Keep both directories next to each other. The Rust build intentionally resolves the Node workspace
through their relative locations.

## Verify the source

```bash
cd /path/to/MasqMobile-IOS-Developer/masq-mobile
npm ci
npm run typecheck
npm run lint
npm run test:ci:linux
npm run test:ci:ios
npm run test:core
npm run test:engine
npm run verify:privacy
```

GitHub Actions also compiles an unsigned generic iPhone build. CI proves that the source builds; it
does not produce an installable or signed IPA.

Generated builds, Pods, dependencies, provisioning profiles, certificates, signing identities,
Apple team IDs, device identifiers, local paths, wallet databases, recovery phrases, private keys
and logs are excluded from this repository. See [Security](SECURITY.md) and the
[Privacy Policy](PRIVACY_POLICY.md) before testing.

## Licence and marks

Original mobile integration code and documentation, the mobile Rust core, and the adapted MASQ
Node source are distributed under GPL-3.0-only. Copyright in original additions remains with their
respective contributors; upstream and third-party files retain their notices. See
[LICENSE](LICENSE), [Third-party notices](THIRD_PARTY_NOTICES.md) and the adaptation summary in
[MODIFICATIONS.md](MODIFICATIONS.md).

MASQ names, logos and upstream source remain subject to their respective copyright, licence and
trademark terms. No endorsement by the MASQ Project is implied.
