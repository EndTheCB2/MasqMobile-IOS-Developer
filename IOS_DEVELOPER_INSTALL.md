# Install MASQ Mobile on an iPhone

This guide builds and signs the app locally for a physical iPhone. It does not install a shared
IPA and it does not publish anything to the App Store.

## 1. Understand the build

- This is experimental, unaudited, consume-only software.
- Only the embedded **MASQ Private** browser uses MASQ.
- Safari and other apps are not routed through MASQ.
- **Browse without MASQ** deliberately exposes the public IP address of the device's current
  connection or separately active VPN.
- Use a separate wallet with only funds appropriate for testing. Never share recovery words,
  private keys or unredacted diagnostics.

## 2. Prerequisites

You need:

- a Mac with Xcode 16.1 or later;
- Xcode command-line tools (`xcode-select --install` if they are not installed);
- an iPhone running iOS 17 or later;
- an Apple account added under **Xcode → Settings → Accounts**;
- Node.js 22.11 or later;
- `rustup`, with Rust 1.77.2 available;
- a user-managed Ruby 3.1 installation, Bundler 2.4.22 and CocoaPods;
- ripgrep (`rg`), used by the privacy and public-build guards; and
- a USB cable for the first pairing. Wireless debugging can be used after pairing.

A free Apple account can be used for personal development signing. A paid Apple Developer
membership provides broader provisioning and distribution options, but it does not make one signed
development build universally installable on other people's devices.

Check the main tools:

```bash
xcodebuild -version
node --version
rustup --version
ruby --version
bundle --version
rg --version
```

If your Mac still selects Apple's system Ruby, use a Ruby version manager or a current Homebrew
Ruby. Install the locked Bundler version in that Ruby environment:

```bash
gem install bundler -v 2.4.22
```

Install ripgrep through your preferred package manager. With Homebrew:

```bash
brew install ripgrep
```

## 3. Download and prepare the source

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
cd ..
```

Do not move `masq-mobile` away from its sibling `masq-node-mobile` directory. The native build uses
the adapted Node source through that relative layout.

If Xcode cannot locate Node or Rust, run `command -v node`, create
`masq-mobile/ios/.xcode.env.local`, and set the result locally. The `PATH` line makes a standard
rustup installation visible when Xcode was opened from Finder:

```bash
export PATH="$HOME/.cargo/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
export NODE_BINARY="/absolute/path/reported-by-command-v-node"
```

That file is intentionally ignored and must never be committed.

## 4. Prepare the iPhone

1. Connect and unlock the iPhone.
2. Confirm **Trust This Computer** on the iPhone if asked.
3. In Xcode, open **Window → Devices and Simulators** and wait until the device is available.
4. On the iPhone, open **Settings → Privacy & Security → Developer Mode**.
5. Enable Developer Mode, allow the restart, unlock the phone and confirm the final prompt.

Keep the phone unlocked during the first build and installation.

## 5. Configure local signing

Open the CocoaPods workspace, not the `.xcodeproj` file:

```bash
open ios/MasqMobile.xcworkspace
```

Then in Xcode:

1. Select the blue `MasqMobile` project.
2. Select the `MasqMobile` application target.
3. Open **Signing & Capabilities**.
4. Leave **Automatically manage signing** enabled.
5. Choose your own Development Team.
6. Replace `org.masqmobile.community.development` with a unique reverse-DNS identifier such as
   `com.yourname.masqmobile.dev`.

Do not commit your Team ID, signing identity or personal bundle identifier. If Xcode reports that
the identifier is unavailable, choose a different globally unique value.

## 6. Build and run from Xcode

Start Metro in a terminal and leave it running:

```bash
cd MasqMobile-IOS-Developer/masq-mobile
npm start
```

In Xcode:

1. Choose the connected iPhone as the run destination.
2. Select the `MasqMobile` scheme.
3. Press **Run** or use `⌘R`.
4. Wait for Xcode to compile the React Native app and the embedded Rust/MASQ core.

The first native build can take several minutes.

If iOS blocks the first launch, open **Settings → General → VPN & Device Management**, select the
developer certificate for your Apple account and trust it. The exact wording can vary by iOS
version and account type.

## 7. Optional self-contained command-line installation

The public helper creates a signed Release development build, installs it and launches it. This
build includes its JavaScript bundle, so Metro is not required after installation. It deliberately
compiles out the private YouTube-specific filter and contains no NFT access gate.

List paired devices:

```bash
xcrun devicectl list devices
```

Then run:

```bash
cd MasqMobile-IOS-Developer/masq-mobile

MASQ_IOS_DEVICE_ID='<device-id>' \
APPLE_DEVELOPMENT_TEAM='<10-character-team-id>' \
MASQ_BUNDLE_IDENTIFIER='com.yourname.masqmobile.dev' \
./scripts/install-ios-development.sh
```

The default node finder is `https://dev2.api.masq.ai`. To use another reviewed HTTPS service, add:

```bash
MASQ_NODE_FINDER_URL='https://nodes.example.org'
```

All identifiers are read from the local environment; the script does not write them to the
repository.

## 8. First-use checks

1. Open the app and import a test wallet.
2. Verify the selected Base network and RPC.
3. Choose **Connect to MASQ** and wait for route readiness.
4. Open **MASQ Private** and load an HTTPS site.
5. If you check an IP address, do it inside the MASQ Private browser. Safari and **Browse without
   MASQ** will still show the phone's ordinary public IP.

The default node finder is a MASQ development endpoint and can be unavailable. The app retries
entry-node discovery, but it cannot create reachable peers when the service or network has none.

## Troubleshooting

### “The native MASQ core is missing from this build”

- Confirm that you opened `MasqMobile.xcworkspace`.
- Run `bundle _2.4.22_ exec pod install --deployment` again from `masq-mobile/ios`.
- Confirm Rust 1.77.2 and `aarch64-apple-ios` are installed.
- In Xcode, use **Product → Clean Build Folder**, then build again.
- Inspect the Xcode build log for the `Build embedded MASQ core` phase. Do not bypass a failed Rust
  build; the private browser must remain blocked without the core.

### CocoaPods or JavaScript dependency errors

Run from `masq-mobile`:

```bash
npm ci
bundle _2.4.22_ install
cd ios
bundle _2.4.22_ exec pod install --deployment
```

Use the committed lockfiles. Avoid updating Pods or npm packages merely to fix a local setup issue.

### Xcode cannot find Node or Rust

- Set `NODE_BINARY` in the ignored `ios/.xcode.env.local` file as described above.
- Confirm `rustup run 1.77.2 cargo --version` works in Terminal.
- If Xcode was already open when tools were installed, quit and reopen Xcode.

### Signing or provisioning fails

- Confirm the Apple account is signed in under Xcode Settings.
- Choose the correct Team and a unique bundle identifier.
- Keep the iPhone unlocked and connected.
- Resolve any agreement or device-registration prompt shown by Xcode.
- Development provisioning expires. Rebuild and reinstall with the same source when iOS reports
  that the app is no longer available.

### Metro reports that it cannot reach the device

- Keep `npm start` running for a Debug build.
- Allow local-network access if macOS or iOS asks.
- Put the Mac and iPhone on the same network, or use the self-contained Release helper instead.

### Entry nodes cannot be found

- Check that the phone has normal internet access.
- Retry after changing between Wi-Fi and mobile data.
- Verify the RPC and selected chain.
- The development node-finder and public MASQ peers are independent services; their availability
  is not controlled by this repository.

## Sharing this project

Share the repository URL and this guide. Do not share your local build directory, signed `.app`,
IPA, provisioning profile, certificate, Team ID, device ID, wallet database or `.xcode.env.local`.
Every tester should clone the source and sign their own development build.

If you need a build that installs without Developer Mode, use an authorized TestFlight or App
Store distribution workflow instead of trying to reuse a personal development build.
