# Modification notice

This repository contains changes to MASQ Node and new iOS integration work. The mobile adaptation
was developed during 2026 and differs from the upstream MASQ Node 1.0.0 codebase in these principal
areas:

- embedded, consume-only runtime lifecycle for an iOS application;
- mobile-safe discovery, route selection, proxying and status reporting;
- configurable hop count and exit-location preferences;
- wallet import and device-bound iOS persistence;
- settlement, receipt-session and database migration support required by the embedded runtime;
- React Native user interface and a native WebKit bridge with explicit `blocked`, `masq` and
  `direct` routing states;
- separate non-persistent WebKit stores and no automatic direct fallback;
- local ad/tracker, cross-site-cookie and cookie-consent protection without a downloaded filter
  list or browsing telemetry; and
- iOS build scripts, source-integration tests, diagnostics and fail-closed controls.

The public build compiles YouTube-specific filtering out. Generic protection deliberately avoids
broad `googlevideo` blocking because those hosts also deliver requested media.

The complete modified source used by the embedded runtime is present in `masq-node-mobile/`. The
original MASQ copyright and GPL-3.0-only notices are preserved. This file is a summary, not a
substitute for the source diff and individual notices.
