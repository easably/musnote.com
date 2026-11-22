"""Audio file in, piano notes out. The static site only calls this."""

from __future__ import annotations

import logging
import shutil
import tempfile
from pathlib import Path

from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.concurrency import run_in_threadpool
from fastapi.middleware.cors import CORSMiddleware

from app.audio_in import ALLOWED_SUFFIXES, NO_AUDIO, NoAudio, Unreadable, to_wav
from app.notes import notes_from_recording

log = logging.getLogger(__name__)

MAX_BYTES = 100 * 1024 * 1024
MAX_NOTES = 4000

app = FastAPI(title="MusNote audio to piano notes")
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://musnote.com",
        "https://www.musnote.com",
        "http://localhost:8080",
        "http://127.0.0.1:8080",
    ],
    allow_methods=["POST", "GET"],
    allow_headers=["*"],
)


@app.get("/health")
def health():
    return {"ok": True}


def _notes_from_upload(suffix: str, data: bytes) -> list[dict]:
    work = tempfile.mkdtemp(prefix="musnote-notes-")
    try:
        src = Path(work) / f"upload{suffix}"
        wav = Path(work) / "audio.wav"
        src.write_bytes(data)
        to_wav(src, wav)
        return notes_from_recording(str(wav))
    finally:
        shutil.rmtree(work, ignore_errors=True)


@app.post("/v1/piano-notes")
async def piano_notes(file: UploadFile = File(...)):
    suffix = Path(file.filename or "").suffix.lower()
    if suffix not in ALLOWED_SUFFIXES:
        raise HTTPException(400, "Upload an audio or video file")

    data = await file.read()
    if not data:
        raise HTTPException(400, "Empty file")
    if len(data) > MAX_BYTES:
        raise HTTPException(413, "File is larger than 100 MB")

    try:
        found = await run_in_threadpool(_notes_from_upload, suffix, data)
    except NoAudio as exc:
        raise HTTPException(400, NO_AUDIO) from exc
    except Unreadable as exc:
        raise HTTPException(422, "Could not read this file.") from exc
    except Exception as exc:
        log.exception("transcription failed")
        raise HTTPException(422, "Could not read notes from this audio") from exc

    clipped = len(found) > MAX_NOTES
    return {"notes": found[:MAX_NOTES], "clipped": clipped}
