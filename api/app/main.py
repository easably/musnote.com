"""Audio file in, piano notes out. The static site only calls this."""

from __future__ import annotations

import os
import tempfile
from pathlib import Path

from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware

from app.notes import transcribe

MAX_BYTES = 15 * 1024 * 1024
MAX_NOTES = 4000
ALLOWED = {".wav", ".mp3", ".m4a", ".ogg", ".flac", ".webm", ".aac"}

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


@app.post("/v1/notes")
async def notes(file: UploadFile = File(...)):
    suffix = Path(file.filename or "").suffix.lower()
    if suffix not in ALLOWED:
        raise HTTPException(400, "Upload wav, mp3, m4a, ogg, flac, webm, or aac")

    data = await file.read()
    if not data:
        raise HTTPException(400, "Empty file")
    if len(data) > MAX_BYTES:
        raise HTTPException(413, "File is larger than 15 MB")

    tmp = tempfile.NamedTemporaryFile(delete=False, suffix=suffix)
    try:
        tmp.write(data)
        tmp.close()
        found = transcribe(tmp.name)
    except Exception as exc:
        raise HTTPException(422, "Could not read notes from this audio") from exc
    finally:
        os.unlink(tmp.name)

    clipped = len(found) > MAX_NOTES
    return {"notes": found[:MAX_NOTES], "clipped": clipped}
