# MusNote design system (Grammarly-inspired)

**Goal:** calm product UI that does not read as “generic AI landing.”  
**Reference energy:** Grammarly — soft mint, spacious type, clear one-job sections.

## Tokens

File: `web/assets/css/design-tokens.css`

| Token family | Role |
|---|---|
| `--mn-green-*` | Brand emerald (not purple) |
| `--mn-ink` / `--mn-muted` | Text hierarchy |
| `--mn-font-display` | Source Serif 4 — hero & section titles |
| `--mn-font-sans` | Outfit — UI / body |
| `--mn-radius-*` / `--mn-shadow-*` | Soft, restrained |

## Layout rules (product)

1. First viewport: **MusNote** plus the chord hub — one headline, one sentence, three cards (patterns, hops, clock). The button opens a chord page.
2. Piano stays an **ear helper** inside voice tools. It is not a chord-menu item and not the first screen.
3. Prefer pathway rows / tool links over decorative card grids.
4. Motion: short rise + soft pulse only; respect `prefers-reduced-motion`.

## Homepage story

1. Chord hub: patterns, hops, clock
2. Footnote to the pattern trainer
3. Voice tools stay one menu item away (`/tools/`)

## CSS layout

| File | Role |
|------|------|
| `design-tokens.css` | Tokens |
| `site-chrome.css` | Shared shell |
| `home-landing.css` | Home sections |
| `home.css` / `main.css` | Barrels |
| `tools.css` | Tool UI |

See also `plans/web-folder-map.md`.
