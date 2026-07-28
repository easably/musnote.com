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
| `assets/css/piano.css` / `chord-tutorial.css` | Legacy interactive pages |

## JS

| File | Purpose |
|------|---------|
| `assets/js/site-chrome.js` | Mobile nav + smooth anchors (prefer this) |
| `assets/js/main.js` | Same as `site-chrome.js` (legacy filename) |
| `assets/js/musnote-voice-api.js` | STT/TTS client → FreeDubbing (`MusnoteVoiceCloud`) |
| `assets/js/live-pitch-helpers.js` | Mic pitch + buffer range + pitched playback |
| `assets/js/page-*.js` | One script per tool page |
| `assets/js/language.js` | EN/RU/DE path switcher + `data-translate` |
| `assets/js/piano.js` / `chord-tutorial.js` | Ear-helper instruments |

## Pages

| Path | Job |
|------|-----|
| `/` | Voice positioning landing |
| `/tools/` | Tool hub |
| `/tools/audio-to-text` | Song/speech → transcript |
| `/tools/slow-pronunciation` | Text → slow TTS |
| `/tools/find-my-octave` | Range + transpose preview |
| `/tools/shadow-phrase` | Language shadowing + live pitch |
| `/piano` | Ear helper (secondary) |

## Intentional leftovers / ask product

1. **RU/DE home** (`/ru/`, `/de/`) still old “music learning” copy — translate landing next?
2. **Chord tutorial** still in repo but off primary nav — keep, hide, or fold into ear helper?
3. **No HTML includes** — nav duplicated in each HTML; next step could be a tiny build/partials step if duplication hurts.
