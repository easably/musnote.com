# SEO core — US English (musnote.com)

Голос и «audio to text» больше не лицо сайта. Актуальная схема: [audio-to-piano-notes.md](audio-to-piano-notes.md). Ниже — разбор от 2026-11-20, до этого выбора.

Locked: 2026-11-20  
Market: United States, English  
Sources: Search Console (`sc-domain:musnote.com`, last 90 days, country = USA) + Google autocomplete (`hl=en`, `gl=us`).

## What Search Console already shows

USA, 90 days: **13 queries, 0 clicks**. None of them is a head term we should build the site around.

| Query (USA) | Impressions | Avg position | Use? |
|---|---:|---:|---|
| speech meter | 48 | 80.6 | No — wrong product |
| spoken notes | 19 | 67.7 | No — brand-adjacent noise |
| noten erkennen / notenerkennung… | 8 | ~70–96 | No — German, not this market |
| song to text | 1 | 73 | Yes — keep, audio-to-text |
| english phrasing and tone checker | 1 | 9 | Yes — keep, shadow / intonation |
| voice type online | 1 | 100 | Weak — octave / voice type |

Worldwide the only on-intent crumbs are `slow pronunciation translator`, `sound to text`, `vocal to text`, `octave finder`, `my octave`. The core below is the **target** list, not a list of queries we already rank for.

## Rules for this core

1. Phrase is a **basic** US search (autocomplete shows it as a head or the first modifier: free, online, converter, test).
2. An existing page already does that job.
3. Skip heads whose US meaning is a different product: iPhone dictation, Google Docs voice typing, medical job shadowing, “how to pronounce gyro”, wedding “repeat after me”, karaoke.

Piano stays a helper cluster. Brand line stays voice for languages.

## P0 — pages that can win a basic phrase

### 1. Audio → text — `/tools/audio-to-text`

People want a file or a song turned into words, in the browser, free.

| Phrase | Role |
|---|---|
| audio to text | Head |
| audio to text converter | Head modifier |
| transcribe audio to text | Head |
| transcribe audio to text free | Modifier |
| song to text | Head (lyrics) |
| song to text converter | Modifier |
| speech to text | Mention only — US autocomplete is iPhone / Android / Google Docs, not a website |
| voice to text | Same — phone dictation, do not make it the title |

Title / H1 direction: **Audio to text** (song or speech).  
Do not title the page “Speech to text”.

### 2. Hear it slowly — `/tools/slow-pronunciation`

This is the cleanest English match. Autocomplete already has “slow pronunciation website” and “slow pronunciation in american english”. Search Console has already shown `slow pronunciation translator`.

| Phrase | Role |
|---|---|
| slow pronunciation | Head |
| slow pronunciation in english | Modifier |
| slow pronunciation in american english | Modifier |
| english pronunciation | Supporting head (broader, harder) |
| english pronunciation practice | Supporting |
| pronunciation practice | Supporting |
| text to speech | Mention only — huge head, mostly “read this aloud”, not our fight |

Title / H1 direction: **Slow pronunciation**.  
“How to pronounce [word]” is a dictionary query (gyro, nguyen, gnocchi). Do not chase single words.

### 3. Range — `/tools/find-my-octave`

Autocomplete is almost the page itself.

| Phrase | Role |
|---|---|
| vocal range test | Head |
| find my vocal range | Head |
| vocal range finder | Modifier |
| singing range test | Modifier |
| voice octave finder | Closest to the tool name |
| octave finder | Already seen in Search Console; keep |

Title / H1 direction: **Find my vocal range** (octave).  
“Pitch detector” is real, but US suggestions drift to trumpet / mp3 / voice changer. Use it in body copy, not as the page title.

## P1 — real US phrases, weaker fit

### 4. Say it back — `/tools/shadow-phrase`

| Phrase | Role |
|---|---|
| english intonation | Head we can own |
| english intonation practice | Modifier |
| english pronunciation practice | Shared with slow-pronunciation; this page is the “say it” step |
| english phrasing and tone checker | Already one US impression at position 9 |

Do **not** target the bare word `shadowing`. In the US it means shadowing a doctor.  
Do **not** target `repeat after me` (camp songs, wedding vows).

Title / H1 direction: **English intonation practice**.

### 5. Piano helper — `/piano` and `/chord-tutorial`

Real US heads, and too big for a side tool. Keep them so the pages are not invisible. Do not let them become the homepage.

| Phrase | Page |
|---|---|
| piano notes | `/piano` |
| piano notes for beginners | `/piano` |
| learn piano notes | `/piano` |
| online piano | `/piano` — supporting, very competitive |
| virtual piano | `/piano` — supporting |
| piano chords | `/chord-tutorial` |

## Not in this core

| Phrase | Why |
|---|---|
| public speaking practice | Real US search. No page yet. Add only when a career page exists. |
| accent reduction | Mostly “classes near me” / coach. We do not claim accent removal. |
| karaoke, song quiz | Entertainment. Out of positioning. |
| noten schreiben, ноты онлайн | Germany / Russia. Separate core if we do those markets. |

## One line per page

| URL | One target phrase |
|---|---|
| `/tools/audio-to-text` | audio to text |
| `/tools/slow-pronunciation` | slow pronunciation |
| `/tools/find-my-octave` | find my vocal range |
| `/tools/shadow-phrase` | english intonation practice |
| `/tools/` | voice tools (hub, not a head term) |
| `/piano` | piano notes for beginners |
| `/` | MusNote — hear your voice, match the phrase (brand; no head-term fight) |
