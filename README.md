# Musnote

Learn piano notes and music notation for beginners — website + Flutter vocal pitch monitor.

## Repository layout

| Path | Purpose |
|------|---------|
| `web/` | Static multilingual marketing / learning site (EN, RU, DE) |
| `vocal_note_monitor/` | Flutter app: real-time vocal pitch graph and tuner |
| `plans/` | Product / architecture notes |

## Website deploy (Cloudflare Pages)

Static files from `web/` deploy via GitHub Actions → Cloudflare Pages.

**Secret (only one):** `CLOUDFLARE_API_TOKEN`  
**Variables:** `CLOUDFLARE_ACCOUNT_ID`, optional `CLOUDFLARE_PAGES_PROJECT` (default `musnote`)

See [DEPLOYMENT.md](./DEPLOYMENT.md).

Local preview:

```bash
python3 -m http.server -d web 8080
```

## Flutter app

```bash
cd vocal_note_monitor
flutter pub get
flutter run
```

See [vocal_note_monitor/README.md](./vocal_note_monitor/README.md) and chord/harmony ideas in [plans/flutter-chord-harmony.md](./plans/flutter-chord-harmony.md).

---

**Learn Piano Notes Easy - Musnote: Beginner Music Notation Made Simple**

Musnote solves the two biggest problems when learning piano notes for beginners. Learn to read music notation easily with our innovative approach designed for complete beginners learning piano from scratch.

**Problem #1: Fixed Piano Keyboard - No More Confusion**

Most piano learning apps shift the keyboard left and right, making it impossible for beginners to understand where to place their hands on a real piano. Musnote keeps the piano keyboard in a **fixed position** - the keys never move.

**Problem #2: Simple Progression - Start with Note Names First**

- **Step 1:** Learn basic piano notes by letter names (A, B, C, D, E, F, G)
- **Step 2:** Master note recognition on the staff for beginners
- **Step 3:** Only then introduce scales and chords (A major, A minor, etc.)
