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

1. First viewport: **MusNote** brand + one headline + one sentence + CTA + one visual (pitch contour).
2. Piano is **ear helper**, never hero.
3. Prefer pathway rows / tool links over decorative card grids.
4. Motion: short rise + soft pulse only; respect `prefers-reduced-motion`.

## Homepage story

1. Hear / match phrase (languages / intonation)
2. How practice works (3 steps)
3. Tools strip
4. Explicit demotion of piano
5. Languages → career closing

## CSS layout

| File | Role |
|------|------|
| `design-tokens.css` | Tokens |
| `site-chrome.css` | Shared shell |
| `home-landing.css` | Home sections |
| `home.css` / `main.css` | Barrels |
| `tools.css` | Tool UI |

See also `plans/web-folder-map.md`.
