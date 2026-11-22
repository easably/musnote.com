"""Official song check. Not part of deploy.

Lewis Capaldi, "Someone You Loved", 3:05, voice plus piano and the rest
of the band. Two local copies of the same recording:

- .tmp/Lewis Capaldi - Someone You Loved.mp3
- .tmp/Lewis Capaldi - Someone You Loved.m4a

The recording is commercial, so the files stay in .tmp/ and are not in git.
CI keeps the public-domain scale in test_live_notes.py.

This posts the whole file. The service still returns one mixed note list.
Run it only when the API is reachable:

    NOTES_API_URL=http://127.0.0.1:18095 python3 -m pytest api/tests/test_someone_you_loved.py -q
"""

from __future__ import annotations

import os
from pathlib import Path

import pytest

from test_live_notes import _post_audio

ROOT = Path(__file__).resolve().parents[2]
SONG = [
    ROOT / ".tmp" / "Lewis Capaldi - Someone You Loved.mp3",
    ROOT / ".tmp" / "Lewis Capaldi - Someone You Loved.m4a",
]

pytestmark = pytest.mark.skipif(
    not os.environ.get("NOTES_API_URL"),
    reason="NOTES_API_URL is not set",
)


@pytest.mark.parametrize("audio", SONG, ids=["mp3", "m4a"])
def test_someone_you_loved_returns_one_mixed_note_list(audio: Path) -> None:
    if not audio.is_file():
        pytest.skip(f"local song file is missing: {audio.name}")

    base = os.environ["NOTES_API_URL"].rstrip("/")
    data = _post_audio(base + "/v1/piano-notes", audio)

    notes = data["notes"]
    assert data["clipped"] is False
    assert len(notes) > 50
    for note in notes:
        assert isinstance(note["midi"], int)
        assert isinstance(note["name"], str) and note["name"]
        assert note["end"] >= note["start"] >= 0
