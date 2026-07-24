# MASQ Mobile Privacy Policy

Effective: 24 July 2026

MASQ Mobile is an independent, open-source, consume-only iOS client. It is not an official release
of the MASQ Project. This repository distributes source for people who build and sign their own
development copy. Public project support is available through the repository's issue tracker.

This document describes the source as published here. A downstream builder who modifies or
distributes the app is responsible for describing their own build and data practices.

## Summary

The app has no maintainer-operated account, advertising SDK, analytics SDK or cross-app tracking.
It does not sell personal data. It stores the wallet secret and network profile on the iPhone.
Using MASQ sends necessary data to a blockchain RPC, a node-finder, MASQ peers and the websites the
user chooses to visit. Free-text browser searches are sent to Timpi Search. Explicit direct
browsing instead uses the device's normal internet connection. Those independent services may
process or retain network data under their own policies.

## Data stored on the iPhone

- The recovery phrase or private key is stored in a device-bound Keychain item available only
  while the iPhone is unlocked. The `ThisDeviceOnly` setting prevents that Keychain item from
  migrating to another device through a backup.
- The public wallet address, selected chain, RPC URL, entry-node cache, hop preference,
  exit-country preference and app state are kept in app-private storage.
- The MASQ and Direct browsers use separate non-persistent WebKit data stores. Cookies, cache and
  page history are not written to persistent website storage, but data can remain in memory until
  the web-content process exits. The app clears temporary website data when it prepares a new
  session or changes protection settings.
- Browser-protection choices are stored locally. The bundled advertising/tracker,
  cross-site-cookie, cookie-banner and optional-cookie-rejection rules do not download an external
  filter list and do not synchronize browsing history.
- The app does not intentionally put wallet secrets in diagnostics. A user decides whether to
  share the redacted diagnostic report.

**Remove wallet from this device** deletes the saved wallet secret. Network settings can be
removed separately, and **Reset everything** removes both. iOS Keychain items can survive app
deletion, and reinstalling an app with the same bundle identifier may regain access to them. Use
**Remove wallet from this device** or **Reset everything** before uninstalling when the wallet
secret must be removed. Funds remain on the blockchain and can be recovered only with the user's
own recovery phrase or private key.

## Data sent when the app is used

### Blockchain RPC

The selected RPC receives the device's public IP address, public wallet address, chain queries and
transaction-related JSON-RPC requests. It does not need the recovery phrase or private key.

The source defaults to the public Nodies Base Mainnet endpoint and the PublicNode Base Sepolia
endpoint, with public fallbacks. These are independent services whose availability, privacy and
retention practices are controlled by their operators. A user-selected RPC is governed by its own
operator.

### Entry-node discovery

The node-finder receives the public IP address, requested MASQ chain and public network/suburb. It
returns candidate public node descriptors. Development builds default to
`https://dev2.api.masq.ai`, a development endpoint on the MASQ domain. It is not operated by this
repository's maintainer. Its availability and retention practices are controlled by its operator.
Do not use this development build if that dependency is unacceptable.

### MASQ peers and destination sites

MASQ entry, relay and exit nodes process the routing metadata required for a route. Different
nodes can observe different portions of a connection. The destination site receives the exit
node's IP address and normal web requests, including data the user submits. This project does not
control independent nodes or destination sites and cannot promise that they retain no data.

In **MASQ Private**, the embedded browser is fail-closed. If the local proxy or private exit route
is unavailable, the page is blocked instead of loading through the device's direct connection.
The app routes only this embedded browser; it does not claim to protect Safari or other apps.

### Direct browsing

**Browse without MASQ** is a separate action that requires explicit confirmation for each session.
It stops an active MASQ connection before using ordinary device networking. MASQ hops and
exit-country preferences do not apply. Destination sites receive the public IP address used by
the current mobile, Wi-Fi, VPN or relay connection. The internet provider and DNS resolver can
observe the network metadata normally available to them. HTTPS encrypts contents in transit but
does not hide IP addresses or all destination metadata.

The selected browser routing mode is not persisted. Closing the browser or backgrounding the app
returns native browser routing to `blocked`. Local protection rules can still filter recognized
resources in Direct mode, but they do not provide MASQ routing or hide the public IP address.

### Timpi Search

When browser input is not recognized as a public web address, the app opens the public Timpi
Search website with that input as the query. In MASQ Private, Timpi sees the exit node's IP
address. In Direct, Timpi sees the public IP address of the current connection or VPN. MASQ Mobile
does not use Timpi's private data API and does not separately log, synchronize or send the query
to the repository maintainer.

Timpi is an independent service. Its current privacy terms and retention practices are controlled
by Timpi: [Timpi privacy policy](https://timpi.io/wp-content/uploads/2025/07/Timpi-International-Ltd-Privacy-Policy.pdf).

### Browser protection

Browser protection runs on the iPhone. The public build can block a limited set of known
advertising and tracking requests, strip cookies from cross-site requests and hide recognized
cookie-consent banners. It does not contact a filter-list service or report visited URLs, matches,
block counts or page contents to the maintainer. Destination sites still receive unblocked
requests and may detect that resources were filtered.

Cookie-banner hiding is cosmetic and does not by itself accept or reject consent. A separate
**Reject optional cookies** preference is disabled by default. It recognizes only supported
dialogs and deliberately follows a reject path; it never chooses **Accept**. An unrecognized
full-page consent gate remains visible because hiding it could leave the page unusable.

Protection is best effort. It cannot recognize every advertisement, tracker or consent dialog and
can occasionally break a page. The public build compiles YouTube-specific filtering out and does
not broadly block `googlevideo` media hosts.

## Sharing and disclosure

The app does not transmit data to the repository maintainer unless a user deliberately opens an
external support channel or shares diagnostics. Information posted to a public GitHub issue is
public. Never post recovery words, private keys, IP addresses, device identifiers, exact browsing
history or unredacted logs.

Data can otherwise be processed by the RPC operator, node-finder operator, MASQ peers, destination
sites, Timpi and infrastructure providers described above.

## Security and limitations

The app uses iOS secure storage, encrypted MASQ transport and isolated temporary browser sessions.
Direct browsing deliberately does not provide MASQ anonymity. No software or decentralized
network can guarantee complete anonymity or security. Keep a separate offline recovery backup and
use only funds appropriate for experimental software until the project completes an independent
security review.

## Children and web content

The app can access unrestricted web content and is not designed for children. This source
distribution has no App Store age rating. Builders and distributors must follow applicable local
age, content and distribution rules.

## Changes and contact

Policy changes are recorded in this repository. Project and privacy questions can be opened
through [GitHub Issues](https://github.com/EndTheCB2/MasqMobile-IOS-Developer/issues). Do not
include secrets or sensitive personal data in a public issue.
