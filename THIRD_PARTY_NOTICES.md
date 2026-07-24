# Third-party notices

Original MASQ Mobile integration code and documentation are licensed under GPL-3.0-only, with
copyright held by their respective contributors. MASQ Mobile also contains adapted MASQ Node
source under GPL-3.0-only. Existing upstream and third-party copyrights remain unchanged. See
`LICENSE`, `masq-node-mobile/LICENSE` and `MODIFICATIONS.md`.

MASQ Node uses a vendored `web3` 0.11.0 source copy under the MIT licence, patched with an iOS
CFStream socket connector. Its upstream notice is retained in
`masq-node-mobile/vendor/web3-0.11.0/LICENSE`.

React Native, WebKit integrations, CocoaPods, Cargo and npm dependencies retain their respective
licences. Exact resolved versions and integrity hashes are recorded in
`masq-mobile/package-lock.json`, `masq-mobile/ios/Podfile.lock` and the Cargo lockfiles under
`masq-node-mobile/`.

The browser-protection rules and cosmetic selectors in this repository are authored for MASQ
Mobile. The app does not bundle EasyList, uBlock rules or another external filter list and does not
download a remote filter list at runtime. It contains no YouTube or Google source code or licensed
Google filter list; no permission or endorsement by Google or YouTube is implied.

Applicable upstream licence files are retained with the corresponding source. Downstream builders
and distributors remain responsible for reviewing the complete dependency inventory and including
any additional notices required by their distribution channel.
