"""Probe only: one upload, every stem back, each with its own notes.

Runs on server7. It does not replace POST /v1/piano-notes on server8.
Demucs weights are not cleared for the product; this process stays on the probe host.
"""

from __future__ import annotations

import logging
import os
import shutil
import subprocess
import tempfile
from pathlib import Path

from fastapi import FastAPI, File, HTTPException, UploadFile

from notes import notes_from_audio
from stems import NOTE_STEM_IDS, STEM_IDS, is_quiet, parse_mean_volume_db, stem_payload

log = logging.getLogger(__name__)

MAX_BYTES = 100 * 1024 * 1024
AUDIO_SUFFIXES = {".wav", ".mp3", ".m4a", ".ogg", ".flac", ".webm", ".aac"}

DEMUCS_BIN = os.environ.get(
    "DEMUCS_BIN",
    "/home/admin2/musnote-separate/venv/bin/demucs",
)

app = FastAPI(title="MusNote stem probe")


def mean_volume_db(path: str) -> float | None:
    proc = subprocess.run(
        ["ffmpeg", "-hide_banner", "-i", path, "-af", "volumedetect", "-f", "null", "-"],
        capture_output=True,
        text=True,
        check=False,
    )
    return parse_mean_volume_db(proc.stderr)


def separate(audio_path: str, out_dir: str) -> Path:
    proc = subprocess.run(
        [DEMUCS_BIN, "-n", "htdemucs_6s", "-o", out_dir, audio_path],
        capture_output=True,
        text=True,
        check=False,
    )
    if proc.returncode != 0:
        log.error("demucs failed: %s", proc.stderr[-2000:])
        raise RuntimeError("demucs failed")
    stems = list(Path(out_dir).glob("htdemucs_6s/*"))
    if len(stems) != 1:
        raise RuntimeError("demucs did not write one song folder")
    return stems[0]


@app.get("/health")
def health():
    return {"ok": True}


@app.post("/v1/separated-notes")
async def separated_notes(file: UploadFile = File(...)):
    suffix = Path(file.filename or "").suffix.lower()
    if suffix not in AUDIO_SUFFIXES:
        raise HTTPException(400, "Upload wav, mp3, m4a, ogg, flac, webm, or aac")
    data = await file.read()
    if not data:
        raise HTTPException(400, "Empty file")
    if len(data) > MAX_BYTES:
        raise HTTPException(413, "File is larger than 100 MB")

    work = tempfile.mkdtemp(prefix="musnote-separate-")
    src = Path(work) / f"upload{suffix}"
    try:
        src.write_bytes(data)
        song_dir = separate(str(src), str(Path(work) / "out"))
        stems = []
        for stem_id in STEM_IDS:
            wav = song_dir / f"{stem_id}.wav"
            if not wav.is_file():
                raise RuntimeError(f"missing stem {stem_id}")
            mean_db = mean_volume_db(str(wav))
            notes: list[dict] = []
            if stem_id in NOTE_STEM_IDS and not is_quiet(mean_db):
                notes = notes_from_audio(str(wav))
            stems.append(stem_payload(stem_id, mean_db, notes))
    except HTTPException:
        raise
    except Exception as exc:
        log.exception("separation failed")
        raise HTTPException(422, "Could not separate this audio") from exc
    finally:
        shutil.rmtree(work, ignore_errors=True)

    return {"stems": stems}
