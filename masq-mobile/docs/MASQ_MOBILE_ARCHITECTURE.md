# MASQ Mobile iOS architecture

## Foundation

The embedded runtime builds on MASQ Node 1.0.0 plus the source adaptations retained in this
repository.

Relevant upstream behavior:

- `consume-only` is an existing neighborhood mode.
- Consume-only mode starts no exit `ProxyClient` and performs no automatic router port mapping.
- The TLS listener accepts HTTP `CONNECT` and passes tunneled traffic through ProxyServer, Hopper
  and Neighborhood.
- A usable connection requires `OverallConnectionStage::RouteFound`; one reachable neighbor alone
  is not a complete private exit route.

The desktop bootstrap binds privileged ports before dropping privileges. That design is unsuitable
inside an iOS application sandbox.

## Mobile proxy adaptation

`--mobile-proxy-port PORT` provides an unprivileged embedded path:

1. It is valid only with `--neighborhood-mode consume-only`.
2. Ports 80 and 443 are not bound.
3. A random high-numbered port is bound only to `127.0.0.1`.
4. The discriminator reports logical reception port 443 internally so existing TLS/CONNECT logic
   continues to work.
5. No root process, background daemon or public listener is required.
6. The embedded Actix runtime reports start, pause, shutdown and route state to the mobile wrapper
   in the same process.

Pausing closes browser routing while allowing the mesh to stay warm. Explicit Direct mode first
blocks WebKit routing, stops the actor system and joins its thread without calling
`process::exit`, allowing a later clean restart in the same app process.

## Traffic flow

```text
MASQ Private WKWebView
  -> WKWebsiteDataStore proxy configuration
  -> HTTP CONNECT to 127.0.0.1:<random high port>
  -> HttpRequestDiscriminator (logical reception port 443)
  -> ProxyServer
  -> Hopper / Neighborhood route
  -> MASQ relay nodes
  -> selected exit
  -> HTTPS destination
```

```text
Explicit Direct WKWebView
  -> separate WKWebsiteDataStore
  -> ordinary iPhone networking
  -> HTTPS destination
```

A MASQ proxy setting without a route is rejected. `failoverAllowed` is false, so losing the route
produces an error instead of an invisible direct connection. Direct browsing is a separately
confirmed user action, never a recovery fallback.

## WebKit isolation

- Minimum iOS version is 17 because the app uses
  `WKWebsiteDataStore.proxyConfigurations`.
- The native bridge owns separate non-persistent stores for MASQ and Direct sessions.
- The patched React Native WebView target is strongly linked to the exact selected store.
- The MASQ store is never configured for direct networking.
- The Direct store can have an empty proxy configuration only in exact `direct` state.
- Both stores use an unreachable localhost sink in `blocked` state.
- Closing the browser or backgrounding the app selects `blocked`.
- Local file access, mixed content, popup windows, shared cookies, link previews and production
  WebView debugging are disabled.

No Packet Tunnel Provider, Network Extension entitlement or system VPN target is included.
Consequently, Safari and other apps remain outside the MASQ route.

## Native bridge and Rust core

Xcode invokes `scripts/build-rust-ios.sh` for the selected architecture. The script builds the
`masq-mobile-core` static library, which depends on adapted crates in the sibling
`masq-node-mobile` tree. The app force-loads the library so the Objective-C++ bridge can resolve
the required FFI surface.

A native-link contract test checks that the build phase, patch and symbols remain present. At
runtime, missing symbols produce a blocked state and an actionable error instead of enabling
direct browsing.

The bridge:

- imports and removes device-bound wallet material;
- starts, pauses and stops the embedded actor system;
- configures the browser routing state;
- exposes route status and redacted diagnostics;
- checks connectivity and applies route preferences; and
- monitors iOS network-path and app-lifecycle changes.

## Wallet and persistence

- React state clears the imported secret after it crosses the native boundary.
- The private key is not placed in operating-system process arguments.
- Temporary Rust copies are zeroized.
- Wallet material is stored using
  `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`.
- Node data is written to an app-private directory excluded from backups.
- Profile settings can be reset independently from the saved wallet.
- Only an explicit wallet removal or full reset deletes the Keychain item.

## Route preferences

Route length is passed to Node through `--min-hops`. Exit-country preference is sent to the
Neighborhood actor through its typed exit-location message and reapplied when a neighbor becomes
available. The UI offers only countries learned from the current neighborhood and supports strict
or fallback selection.

## Browser protection

iOS request interception applies a small, locally authored rule set for known advertising and
tracking resources. Web content scripts provide cross-site-cookie controls, cosmetic consent
hiding and an optional rejection path for recognized dialogs.

The app does not download a filter list or report URLs, matches or block counts. Protection is
best effort and independent from MASQ routing. The public compiler configuration excludes the
private YouTube-specific experiment.

## Explicitly out of scope

- serving, routing or exit traffic for other MASQ users;
- public listeners and UPnP/PCP/NAT-PMP;
- HTTP sites and local, private or link-local browser destinations;
- automatic or remembered fallback from MASQ to Direct;
- device-wide or per-app routing without a separately entitled Packet Tunnel extension;
- hardcoded wallet secrets, private RPC credentials or personal signing data; and
- a universally installable development IPA.

## Verification

The test layers cover:

- configuration, URL, wallet and HTTP CONNECT parsing;
- React Native rendering and connection lifecycle behavior;
- WebKit store isolation and native-link contracts;
- consume-only validation and mobile port behavior;
- compilation and smoke testing of the complete Node engine; and
- source privacy checks for local paths, credentials and Apple signing data.

CI installs locked JavaScript, Ruby, CocoaPods and Rust dependencies, runs these checks and builds
an unsigned generic iPhone Release target. Real-device route validation remains necessary because
entry nodes, RPC services, MASQ peers and Apple provisioning are external systems.
