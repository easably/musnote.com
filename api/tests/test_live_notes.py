"""Live check against the deployed API.

The clip is a public-domain C major scale, up and then down, about 10 seconds.
Source: https://commons.wikimedia.org/wiki/File:C_major.ogg
Author: Aidan Hanrath, 2006, released into the public domain.
Wikimedia also publishes the MP3 transcode we store in fixtures/.

Set NOTES_API_URL. Port 8095 is only open on server8 itself, so the usual
way in is an SSH tunnel: scripts/integration-notes-api.sh.
"""

from __future__ import annotations

import json
import os
import urllib.request
from pathlib import Path

import pytest

# What the recording plays, and what the server returned for this file.
SCALE = [
    "C4", "D4", "E4", "F4", "G4", "A4", "B4", "C5",
    "B4", "A4", "G4", "F4", "E4", "D4", "C4",
]
FIXTURE = Path(__file__).parent / "fixtures" / "c-major-scale.mp3"

pytestmark = pytest.mark.skipif(
    not os.environ.get("NOTES_API_URL"),
    reason="NOTES_API_URL is not set",
)


def _post_audio(url: str, audio: Path) -> dict:
    content_type = {
        ".mp3": "audio/mpeg",
        ".m4a": "audio/mp4",
    }.get(audio.suffix.lower(), "application/octet-stream")
    boundary = "musnote-live-test"
    body = (
        f"--{boundary}\r\n"
        f'Content-Disposition: form-data; name="file"; filename="{audio.name}"\r\n'
        f"Content-Type: {content_type}\r\n\r\n"
    ).encode() + audio.read_bytes() + f"\r\n--{boundary}--\r\n".encode()
    request = urllib.request.Request(
        url,
        data=body,
        headers={"Content-Type": f"multipart/form-data; boundary={boundary}"},
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=180) as response:
        return json.loads(response.read())


def test_c_major_scale_comes_back_as_piano_notes() -> None:
    base = os.environ["NOTES_API_URL"].rstrip("/")
    health = urllib.request.urlopen(base + "/health", timeout=10)
    assert health.status == 200

    data = _post_audio(base + "/v1/piano-notes", FIXTURE)

    assert data["clipped"] is False
    assert [note["name"] for note in data["notes"]] == SCALE
