"""What one separated recording looks like in the probe response.

A stem is one instrument (or the voice) after Demucs. drums are kept in the
list so the caller can see them, but they are not turned into piano notes.
"""

from __future__ import annotations

import re

# Mean volume at or below this is "nothing to show".
QUIET_MEAN_DB = -45.0
MAX_NOTES = 4000
STEM_IDS = ("vocals", "piano", "guitar", "bass", "other", "drums")
NOTE_STEM_IDS = ("vocals", "piano", "guitar", "bass", "other")


def parse_mean_volume_db(ffmpeg_log: str) -> float | None:
    match = re.search(r"mean_volume:\s*(-?\d+(?:\.\d+)?)\s*dB", ffmpeg_log)
    if not match:
        return None
    return float(match.group(1))


def is_quiet(mean_db: float | None) -> bool:
    return mean_db is not None and mean_db <= QUIET_MEAN_DB


def stem_payload(stem_id: str, mean_db: float | None, notes: list[dict]) -> dict:
    quiet = is_quiet(mean_db)
    if stem_id == "drums" or quiet:
        notes = []
    clipped = len(notes) > MAX_NOTES
    return {
        "id": stem_id,
        "loudness_db": mean_db,
        "empty": quiet,
        "clipped": clipped,
        "notes": notes[:MAX_NOTES],
    }
