# MusNote — Voice performance for career & languages

**Domain:** musnote.com  
**Locked:** 2026-07-28

## Positioning line

> Voice performance for career & languages

Not karaoke entertainment. Not a generic music-learning platform.  
A **live voice mirror**: hear/see yourself while practicing — then improve intonation, speaking confidence, and (later) career delivery.

## Priority order (product + SEO)

1. **Languages / intonation / “accent”** — honestly: **intonation & rhythm first**, not full phoneme accent reduction in v1  
2. **Career / public speaking / confidence** — second wave of messaging and features

## What we sell vs what we don’t

| Sell | Don’t sell (yet / ever as core) |
|------|----------------------------------|
| See your pitch contour while speaking or repeating | Party karaoke / hit songs |
| Shadow a model phrase (language “karaoke”) | “AI removes your accent” as a hard claim |
| Match intonation of a native / teacher line | Generic “learn piano notes” as brand hero |
| Build voice confidence for interviews & talks | Entertainment singer identity |

## Language karaoke (working name)

**Idea:** karaoke *format* for language learners — not entertainment karaoke.

Flow:

1. **TTS / native audio** — generate or play a target phrase  
2. **User speaks / sings-along the phrase** (shadowing)  
3. **Pitch contour compare** — user vs reference (MusNote’s existing pitch stack)  
4. **STT / ASR** — optional text score: did they say the words?  
5. Feedback: intonation closeness + (optional) word accuracy  

This is the bridge between current Vocal Note Monitor tech and language/career outcomes.

### Honest capability ladder

1. **Now:** live pitch / note / cents → control & confidence  
2. **Next:** reference audio + contour overlay → intonation / shadowing (“language karaoke”)  
3. **Later:** ASR scoring + curated phrase banks → measurable practice  
4. **Later+:** phoneme / accent depth only if we add specialized audio models  

## Personas (entry order)

1. **Language learner** — wants to sound clearer, match native melody of English (or other) phrases  
2. **Career speaker** — interviews, presentations, “I sound unsure”  
3. **Voice trainee** — exercises / controlled singing as *training*, not stage karaoke  

## Semantic core (B first, then career)

### P0 — Languages / intonation

- English intonation practice  
- shadowing pronunciation  
- speak like a native intonation  
- pronunciation with pitch feedback  
- language speaking practice app  
- reduce accent English *(SEO OK; product claim = intonation/rhythm)*  
- repeat after me English  

**RU:** интонация английского, shadowing, произношение по образцу, убрать акцент (интонация), повтори за диктором  

**DE:** Intonation üben Englisch, Aussprache Schattenlesen, Akzent Intonation  

### P1 — Career / confidence (second)

- voice confidence  
- public speaking voice training  
- presentation voice practice  
- interview speaking practice  
- speak with confidence app  

### P2 — Tech bridge (true to current app)

- live voice pitch monitor  
- see your pitch while speaking  
- vocal exercise pitch feedback  

### Exclude from core

karaoke (entertainment), party, song quiz, play-along hits  

## App Store sketch (draft)

- **Name direction:** MusNote Voice / MusNote Speak (TBD)  
- **Subtitle ideas:** `Intonation practice, live` / `Shadow speech with pitch`  
- **Keywords seed:** voice,speaking,intonation,pronunciation,accent,shadowing,pitch,confidence,speech,training,english,monitor  

## Public beta on the site

**2026-11-20:** landing pages `/app/`, `/ru/app/`, `/de/app/` explain the iOS pitch mirror and hold the public TestFlight CTA.  
Paste the public link once into `web/assets/js/musnote-app-install.js` → `testflightUrl`. Until then the button stays “beta soon” and points people to `/tools/`.  
Hub `/tools/` links to the app page. Full store listing is not required for public TestFlight testing.

## Site implication

**2026-11-20:** the first screen is the chord hub (`plans/chord-site-pages.md`). Voice tools stay in the menu at `/tools/`. `/piano` stays a pitch helper inside that voice section, not a chord-menu item. Mobile app story lives at `/app/`.

## Site tools (shipped)

Public pages under `/tools/` calling FreeDubbing (`https://api.freedubbing.com`):

| Path | Job |
|------|-----|
| `/tools/` | Hub |
| `/tools/audio-to-text` | STT — song/speech → transcript |
| `/tools/slow-pronunciation` | TTS with speed — clear slow model |
| `/tools/find-my-octave` | Mic range + transpose preview |
| `/tools/shadow-phrase` | Language karaoke — model + live pitch |

Override API base in the browser: `window.MUSNOTE_API_BASE`.
