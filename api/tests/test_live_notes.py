"""Live check against the deployed API.

A generated C-major tone (do, mi, sol) is posted to /v1/piano-notes.
The server must answer with C4, E4, G4.

Set NOTES_API_URL. Port 8095 is only open on server8 itself, so the usual
way in is an SSH tunnel: scripts/integration-notes-api.sh.
"""

from __future__ import annotations

import json
import math
import os
import struct
import urllib.request
import wave
from pathlib import Path

import pytest

# MIDI numbers for the three tones the fixture plays.
C4, E4, G4 = 60, 64, 67

pytestmark = pytest.mark.skipif(
    not os.environ.get("NOTES_API_URL"),
    reason="NOTES_API_URL is not set",
)


def _c_major_wav(path: Path) -> None:
    sample_rate = 22050
    freqs = (261.63, 329.63, 392.00)
    with wave.open(str(path), "w") as handle:
        handle.setnchannels(1)
        handle.setsampwidth(2)
        handle.setframerate(sample_rate)
        frames = bytearray()
        for freq in freqs:
            total = int(sample_rate * 1.2)
            for i in range(total):
                edge = min(1.0, i / (sample_rate * 0.02), (total - i) / (sample_rate * 0.05))
                sample = int(0.6 * edge * math.sin(2 * math.pi * freq * i / sample_rate) * 32767)
                frames += struct.pack("<h", sample)
            frames += b"\x00\x00" * int(sample_rate * 0.15)
        handle.writeframes(frames)


def _post_wav(url: str, wav: Path) -> dict:
    boundary = "musnote-live-test"
    body = (
        f"--{boundary}\r\n"
        f'Content-Disposition: form-data; name="file"; filename="{wav.name}"\r\n'
        f"Content-Type: audio/wav\r\n\r\n"
    ).encode() + wav.read_bytes() + f"\r\n--{boundary}--\r\n".encode()
    request = urllib.request.Request(
        url,
        data=body,
        headers={"Content-Type": f"multipart/form-data; boundary={boundary}"},
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=180) as response:
        return json.loads(response.read())


def test_c_major_comes_back_as_piano_notes(tmp_path: Path) -> None:
    base = os.environ["NOTES_API_URL"].rstrip("/")
    health = urllib.request.urlopen(base + "/health", timeout=10)
    assert health.status == 200

    wav = tmp_path / "c-major.wav"
    _c_major_wav(wav)
    data = _post_wav(base + "/v1/piano-notes", wav)

    assert data["clipped"] is False
    assert [note["midi"] for note in data["notes"]] == [C4, E4, G4]
    assert [note["name"] for note in data["notes"]] == ["C4", "E4", "G4"]
