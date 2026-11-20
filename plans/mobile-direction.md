# Mobile direction — MusNote (1–2 quarters)

**Locked architecture:** keep the current repo split — Flutter app = live voice mirror; site on Cloudflare Pages; heavy audio→notes in `api/`. Do not move transcription onto Cloudflare Workers or replace the Flutter pitch stack with a server round-trip.

**App today:** `vocal_note_monitor` — live pitch graph, tuner, record/play, settings. Chord/harmony screens under Ideas are preview-only.

**Bundle ID:** `com.musnote.vocalNoteMonitor`  
**Publish script:** `scripts/ios-testflight.sh` (see also `plans/ios-publish.md`)

---

## Product layers (do not collapse)

| Layer | Job | Where it runs |
|-------|-----|----------------|
| A. Live voice | Pitch contour, cents, practice mirror | **On-device** (Flutter, already) |
| B. Language karaoke | Shadow phrase: pitch + optional STT score | On-device pitch + **SpeechAnalyzer** (iOS); web can keep FreeDubbing |
| C. Audio → piano notes | File → note list on keyboard | **Server `api/`** (Basic Pitch); optional later Core ML on iOS |
| D. Music meta | Key, BPM, structure, loudness | **Music Understanding** (new iOS) when useful — not a substitute for C |

---

## Quarter priorities

### Q1 — Ship the mirror + TestFlight loop

1. Stabilize iOS signing/team (`DEVELOPMENT_TEAM=C52BX6VAT9` in Flutter xcconfigs).
2. Create App Store Connect app card once (manual; API key cannot CREATE) → run `scripts/ios-testflight.sh` → TestFlight.
3. App Store card: name/subtitle aligned with *Voice performance for career & languages* (`plans/voice-performance-positioning.md`).
4. Do **not** block TestFlight on chord Ideas or audio→notes.

**Done when:** testers install a signed build; mic permission and live pitch work on a physical iPhone.

### Q2 — Language karaoke (mobile) + notes as a bridge

1. **Shadow phrase in app:** play/reference contour + live user contour (reuse pitch service).
2. On-device STT via SpeechAnalyzer for “did they say the words?” — server STT only as fallback / web parity.
3. Optional button: send a recording to `api/` for **audio → piano notes** (same contract as the site). Keep Basic Pitch on the server as source of truth.
4. Evaluate Music Understanding only for helper UX (key / BPM next to practice) — never market it as “song to sheet music.”

**Done when:** one end-to-end shadowing flow works offline for pitch; notes conversion works online via existing API.

---

## On-device vs server (decision rule)

| Need | Choice |
|------|--------|
| Realtime pitch / tuner | On-device only |
| Speech → text for practice score | Prefer on-device SpeechAnalyzer; server OK for web |
| File → piano notes (SEO promise) | Server `api/` now; on-device Basic Pitch later as offline bonus |
| Multi-instrument / sheet PDF | Server only (and avoid NC-licensed weights in product) |
| Key / BPM / song structure | On-device Music Understanding if targeting recent iOS |

---

## Explicit non-goals (this window)

- Replacing Flutter with a native rewrite
- Entertainment karaoke / hit-song play-along as core
- Claiming “AI removes your accent” as a hard product promise
- Shipping MuScriptor weights in a commercial build (CC BY-NC)

---

## Related docs

- `plans/ios-publish.md` — Bundle ID / TestFlight checklist  
- `plans/voice-performance-positioning.md` — positioning & SEO ladder  
- `plans/audio-to-piano-notes.md` — server notes API  
- `plans/flutter-chord-harmony.md` — Ideas previews (not core)  
- `docs/transcription-models.md` — model / license table  
