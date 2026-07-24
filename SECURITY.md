# Security policy

MASQ Mobile is experimental, consume-only software and has not completed an independent mobile
security audit. Do not treat a development build as production wallet software. Keep an offline
backup of the recovery phrase and use a separate wallet with only funds appropriate for testing.

## Report a vulnerability

Do not open a public issue containing a vulnerability, wallet secret, node key, IP address, device
identifier or sensitive diagnostic. Use GitHub's private vulnerability reporting feature for this
repository. Include the affected commit, iOS and Xcode versions, a minimal reproduction and
redacted logs. Never include a real recovery phrase or private key.

Only the latest commit on the default branch receives fixes. A locally signed build is supported
only to the extent that its source commit and local build settings are known.

## Security boundaries

- **MASQ Private** is HTTPS-only and fail-closed. A missing core, proxy or private exit route blocks
  the page; it never silently selects direct networking.
- **Browse without MASQ** is a separate explicit action. It stops the active MASQ connection and
  warns that websites see the public IP address of the current connection or VPN.
- The two browser modes use separate non-persistent WebKit stores. Closing or backgrounding the
  browser returns native browser routing to `blocked`.
- This iOS target routes only its embedded browser. It has no Packet Tunnel Network Extension and
  does not protect Safari, other apps or all device traffic.
- The wallet secret is stored in an unlocked-only, device-bound Keychain item. The wallet address,
  profile and preferences remain in app-private storage.
- Browser protection is best effort. It cannot recognize every advertisement, tracker or consent
  dialog and can occasionally make a site less functional.
- Apple teams, bundle identifiers, certificates, provisioning profiles, device identifiers, local
  paths, wallet databases, logs and built artifacts must remain outside source control.
