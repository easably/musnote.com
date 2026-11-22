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
from fastapi.concurrency import run_in_threadpool
from fastapi.responses import JSONResponse

import audio_in
import jobs
from notes import notes_from_audio
from stems import NOTE_STEM_IDS, STEM_IDS, is_quiet, parse_mean_volume_db, stem_payload

log = logging.getLogger(__name__)

MAX_BYTES = 100 * 1024 * 1024

DEMUCS_BIN = os.environ.get(
    "DEMUCS_BIN",
    "/home/admin2/musnote-separate/venv/bin/demucs",
)

app = FastAPI(title="MusNote stem probe")


@app.on_event("startup")
def _start_queue() -> None:
    jobs.start(run_job)


def mean_volume_db(path: str) -> float | None:
    proc = subprocess.run(
        ["ffmpeg", "-hide_banner", "-i", path, "-af", "volumedetect", "-f", "null", "-"],
        capture_output=True,
        text=True,
        check=False,
    )
    return parse_mean_volume_db(proc.stderr)


def build_stems(src: Path, on_stage=None) -> list[dict]:
    """Separate one file and read notes. on_stage is how a queued job reports progress."""

    def stage(name: str) -> None:
        if on_stage is not None:
            on_stage(name)

    work = tempfile.mkdtemp(prefix="musnote-job-")
    try:
        stage("audio")
        wav = Path(work) / "input.wav"
        audio_in.to_wav(src, wav)
        stage("separate")
        song_dir = separate(str(wav), work)
        stems = []
        for stem_id in STEM_IDS:
            stage(f"notes:{stem_id}")
            wav = song_dir / f"{stem_id}.wav"
            if not wav.is_file():
                raise RuntimeError(f"missing stem {stem_id}")
            mean_db = mean_volume_db(str(wav))
            notes: list[dict] = []
            if stem_id in NOTE_STEM_IDS and not is_quiet(mean_db):
                notes = notes_from_audio(str(wav))
            stems.append(stem_payload(stem_id, mean_db, notes))
        return stems
    finally:
        shutil.rmtree(work, ignore_errors=True)


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


def run_job(src: Path, on_stage) -> list[dict]:
    """Queue entry. A missing audio track is its own error, not a generic failure."""
    try:
        return build_stems(src, on_stage)
    except audio_in.NoAudio as exc:
        raise jobs.JobFailed("This file has no audio.", "no_audio") from exc
    except audio_in.Unreadable as exc:
        raise jobs.JobFailed("Could not read this file.", "unreadable") from exc


def separate_blocking(suffix: str, data: bytes) -> list[dict]:
    """Disk and the GPU lock stay off the request loop, so status polls still answer."""
    work = tempfile.mkdtemp(prefix="musnote-separate-")
    src = Path(work) / f"upload{suffix}"
    try:
        src.write_bytes(data)
        with jobs.gpu_lock:
            return build_stems(src)
    finally:
        shutil.rmtree(work, ignore_errors=True)


@app.post("/v1/separated-notes")
async def separated_notes(file: UploadFile = File(...)):
    suffix = Path(file.filename or "").suffix.lower()
    if suffix not in audio_in.ALLOWED_SUFFIXES:
        raise HTTPException(400, "Upload an audio or video file")
    data = await file.read()
    if not data:
        raise HTTPException(400, "Empty file")
    if len(data) > MAX_BYTES:
        raise HTTPException(413, "File is larger than 100 MB")

    try:
        stems = await run_in_threadpool(separate_blocking, suffix, data)
    except audio_in.NoAudio as exc:
        raise HTTPException(400, audio_in.NO_AUDIO) from exc
    except audio_in.Unreadable as exc:
        raise HTTPException(422, "Could not read this file.") from exc
    except Exception as exc:
        log.exception("separation failed")
        raise HTTPException(422, "Could not separate this audio") from exc

    return {"stems": stems}


def _reject(status: int, code: str, message: str) -> JSONResponse:
    return JSONResponse({"error": message, "error_code": code}, status_code=status)


@app.post("/v1/jobs", status_code=202)
async def create_job(file: UploadFile = File(...)):
    data = await file.read()
    suffix = Path(file.filename or "").suffix.lower()
    if suffix not in audio_in.ALLOWED_SUFFIXES:
        return _reject(400, "bad_type", "Upload an audio or video file")
    if not data:
        return _reject(400, "empty", "Empty file")
    if len(data) > MAX_BYTES:
        return _reject(413, "too_large", "File is larger than 100 MB")
    try:
        job_id = await run_in_threadpool(jobs.create, suffix, data)
    except jobs.QueueFull:
        return _reject(429, "queue_full", "The queue is full. Try again in a few minutes.")
    return {"id": job_id}


@app.get("/v1/jobs/{job_id}")
def job_status(job_id: str):
    view = jobs.public_view(job_id)
    if view is None:
        return _reject(404, "not_found", "No such job")
    return view
