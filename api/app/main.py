"""Audio file in, piano notes out. The static site only calls this."""

from __future__ import annotations

import logging
import os
import tempfile
from pathlib import Path

from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware

from app.notes import notes_from_recording

log = logging.getLogger(__name__)

MAX_BYTES = 100 * 1024 * 1024
MAX_NOTES = 4000
AUDIO_SUFFIXES = {".wav", ".mp3", ".m4a", ".ogg", ".flac", ".webm", ".aac"}

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


@app.post("/v1/piano-notes")
async def piano_notes(file: UploadFile = File(...)):
    suffix = Path(file.filename or "").suffix.lower()
    if suffix not in AUDIO_SUFFIXES:
        raise HTTPException(400, "Upload wav, mp3, m4a, ogg, flac, webm, or aac")

    data = await file.read()
    if not data:
        raise HTTPException(400, "Empty file")
    if len(data) > MAX_BYTES:
        raise HTTPException(413, "File is larger than 100 MB")

    tmp = tempfile.NamedTemporaryFile(delete=False, suffix=suffix)
    try:
        tmp.write(data)
        tmp.close()
        found = notes_from_recording(tmp.name)
    except Exception as exc:
        log.exception("transcription failed")
        raise HTTPException(422, "Could not read notes from this audio") from exc
    finally:
        os.unlink(tmp.name)

    clipped = len(found) > MAX_NOTES
    return {"notes": found[:MAX_NOTES], "clipped": clipped}
