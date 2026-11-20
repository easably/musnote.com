# Web folder map (MusNote static site)

## CSS

| File | Purpose |
|------|---------|
| `assets/css/design-tokens.css` | Colors, type, space — design system tokens |
| `assets/css/site-chrome.css` | Shared shell: reset, header, buttons, footer |
| `assets/css/home-landing.css` | Home-only sections (hero, pathway, tools strip) |
| `assets/css/home.css` | Barrel: tokens + chrome + home + responsive |
| `assets/css/main.css` | Barrel for non-home pages: tokens + chrome |
| `assets/css/tools.css` | Tool page panels / forms / status |
| `assets/css/responsive.css` | Breakpoints for chrome + home |
| `assets/css/chords.css` | Chord hub and the four chord pages |
| `assets/css/piano.css` / `chord-tutorial.css` | Legacy piano page. Old chord lesson now redirects. |

## JS

| File | Purpose |
|------|---------|
| `assets/js/site-chrome.js` | Mobile nav + smooth anchors (prefer this) |
| `assets/js/main.js` | Same as `site-chrome.js` (legacy filename) |
| `assets/js/musnote-voice-api.js` | STT/TTS client → FreeDubbing (`MusnoteVoiceCloud`) |
| `assets/js/live-pitch-helpers.js` | Mic pitch + buffer range + pitched playback |
| `assets/js/page-*.js` | One script per tool page |
| `assets/js/language.js` | EN/RU/DE path switcher + `data-translate` |
| `assets/js/chords-shared.js` plus `chords-patterns.js`, `chords-hops.js`, `chords-clock.js`, `chords-chart.js` | Chord pages |
| `assets/js/piano.js` | Ear-helper piano |

## Pages

| Path | Job |
|------|-----|
| `/` | Chord hub (three cards). Voice is a menu item, not the first screen. |
| `/chords/patterns/` | Two tabs: CFG / iDEA theory, then the pattern trainer (`#trainer`) |
| `/chords/hops/` | Build a chord as hops 4+3 and 3+4 |
| `/chords/clock/` | One triangle, twelve chords |
| `/chords/chart/` | Chord chart: name, keys, play. Old `/chord-tutorial` opens this. |
| `/tools/` | Voice tool hub |
| `/tools/audio-to-text` | Song/speech → transcript |
| `/tools/slow-pronunciation` | Text → slow TTS |
| `/tools/find-my-octave` | Range + transpose preview |
| `/tools/shadow-phrase` | Language shadowing + live pitch |
| `/piano` | Ear helper, linked from voice tools, not from the chord menu |

## Intentional leftovers / ask product

1. **RU/DE homes** are the same chord hub as English. Voice tool pages are still English-only.
2. **Chord pages** are the front of the site (see `plans/chord-site-pages.md`). `/piano` stays the ear helper.
3. **No HTML includes** — nav duplicated in each HTML; next step could be a tiny build/partials step if duplication hurts.
