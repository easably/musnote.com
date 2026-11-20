# Mobile app: public beta on the site

**Locked with:** [voice-performance-positioning.md](voice-performance-positioning.md)  
**Date:** 2026-11-20

## What shipped on the website

| Path | Role |
|------|------|
| `/app/` | EN landing: brand + one promise + TestFlight CTA |
| `/ru/app/`, `/de/app/` | Same story in RU / DE |
| `/tools/` | Promo strip + nav/footer link to `/app/` |
| `web/assets/js/musnote-app-install.js` | **Only** place to paste the public TestFlight URL |

## Public test link (when App Store listing is not live yet)

1. Build / upload IPA (Xcode Archive or `flutter build ipa`) → App Store Connect.
2. Create the app record if needed (Bundle ID `com.musnote.vocalNoteMonitor`) — see [ios-publish.md](ios-publish.md).
3. TestFlight → External Testing → enable **Public Link**.
4. Copy `https://testflight.apple.com/join/…` into `musnote-app-install.js` → `testflightUrl: '…'`.
5. Deploy the site. The green button becomes **Join iOS public beta**.

Until step 4, the pages already explain the product and send people to browser tools.

## Not this beta

- Song → full sheet music / heavy Basic Pitch server pipeline (website `api/`).
- Android open testing (slot in `playUrl` later).
- Claiming “AI removes your accent.”
