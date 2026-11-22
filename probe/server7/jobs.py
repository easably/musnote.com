"""One job at a time. The queue lives on disk so a restart can see it.

Audio is deleted as soon as a job finishes. The note list stays for a day.
"""

from __future__ import annotations

import json
import logging
import os
import threading
import time
import uuid
from datetime import datetime, timedelta, timezone
from pathlib import Path

from stems import STEM_IDS

log = logging.getLogger(__name__)

JOB_ROOT = Path(os.environ.get("JOB_ROOT", "/var/lib/musnote-jobs"))
RESULT_TTL = timedelta(hours=24)
MAX_ACTIVE = 8
RESTART_ERROR = "The server restarted while this file was being read. Upload it again."
STAGE_IDS = (
    "received",
    "audio",
    "separate",
    *(f"notes:{stem_id}" for stem_id in STEM_IDS),
    "done",
)

gpu_lock = threading.Lock()
_file_lock = threading.Lock()
_stop = threading.Event()


class QueueFull(Exception):
    """Eight songs are already waiting or running."""


class JobFailed(Exception):
    """A job ended with a known code. The message is English, for the log."""

    def __init__(self, message: str, code: str) -> None:
        super().__init__(message)
        self.code = code


def now() -> str:
    return datetime.now(timezone.utc).isoformat()


def jobs_dir() -> Path:
    path = JOB_ROOT / "jobs"
    path.mkdir(parents=True, exist_ok=True)
    return path


def audio_dir() -> Path:
    path = JOB_ROOT / "audio"
    path.mkdir(parents=True, exist_ok=True)
    return path


def _path(job_id: str) -> Path:
    return jobs_dir() / f"{job_id}.json"


def _read(job_id: str) -> dict | None:
    path = _path(job_id)
    if not path.is_file():
        return None
    return json.loads(path.read_text())


def _write(job: dict) -> None:
    path = _path(job["id"])
    tmp = path.with_suffix(".json.tmp")
    tmp.write_text(json.dumps(job))
    tmp.replace(path)


def _blank_stages() -> list[dict]:
    return [{"id": stage_id, "started": None, "ended": None} for stage_id in STAGE_IDS]


def create(suffix: str, data: bytes) -> str:
    job_id = uuid.uuid4().hex
    audio = audio_dir() / f"{job_id}{suffix}"
    stamp = now()
    stages = _blank_stages()
    stages[0]["started"] = stamp
    stages[0]["ended"] = stamp
    job = {
        "id": job_id,
        "state": "queued",
        "stage": "received",
        "error": None,
        "error_code": None,
        "created": stamp,
        "audio": str(audio),
        "stages": stages,
        "stems": None,
    }
    audio.write_bytes(data)
    with _file_lock:
        active = sum(1 for item in _all() if item["state"] in ("queued", "running"))
        if active >= MAX_ACTIVE:
            audio.unlink(missing_ok=True)
            raise QueueFull()
        _write(job)
    return job_id


def _close_open(job: dict, stamp: str) -> None:
    for stage in job["stages"]:
        if stage["started"] and not stage["ended"]:
            stage["ended"] = stamp


def mark_stage(job_id: str, stage_id: str) -> None:
    stamp = now()
    with _file_lock:
        job = _read(job_id)
        if job is None or job["state"] in ("done", "error"):
            return
        _close_open(job, stamp)
        for stage in job["stages"]:
            if stage["id"] == stage_id and not stage["started"]:
                stage["started"] = stamp
        job["state"] = "running"
        job["stage"] = stage_id
        _write(job)


def finish(job_id: str, stems: list[dict]) -> None:
    stamp = now()
    with _file_lock:
        job = _read(job_id)
        if job is None:
            return
        _close_open(job, stamp)
        done = job["stages"][-1]
        if not done["started"]:
            done["started"] = stamp
        done["ended"] = stamp
        job["state"] = "done"
        job["stage"] = "done"
        job["stems"] = stems
        job["error"] = None
        job["error_code"] = None
        _write(job)
    _delete_audio(job_id)


def fail(job_id: str, message: str, code: str) -> None:
    stamp = now()
    with _file_lock:
        job = _read(job_id)
        if job is None or job["state"] in ("done", "error"):
            return
        _close_open(job, stamp)
        job["state"] = "error"
        job["error"] = message
        job["error_code"] = code
        _write(job)
    _delete_audio(job_id)


def _delete_audio(job_id: str) -> None:
    with _file_lock:
        job = _read(job_id)
        if job is None:
            return
        audio = job.get("audio")
        if audio:
            Path(audio).unlink(missing_ok=True)
            job["audio"] = None
            _write(job)


def public_view(job_id: str) -> dict | None:
    with _file_lock:
        _expire_unlocked()
        job = _read(job_id)
        if job is None:
            return None
        ahead = _ahead(job)
        return {
            "id": job["id"],
            "state": job["state"],
            "stage": job["stage"],
            "queue_position": ahead,
            "error": job["error"],
            "error_code": job.get("error_code"),
            "stages": job["stages"],
            "stems": job["stems"],
        }


def _ahead(job: dict) -> int:
    if job["state"] != "queued":
        return 0
    count = 0
    for other in _all():
        if other["id"] == job["id"]:
            continue
        if other["state"] == "running":
            count += 1
        elif other["state"] == "queued" and other["created"] < job["created"]:
            count += 1
    return count


def _all() -> list[dict]:
    jobs = []
    for path in jobs_dir().glob("*.json"):
        try:
            jobs.append(json.loads(path.read_text()))
        except json.JSONDecodeError:
            continue
    jobs.sort(key=lambda item: item.get("created") or "")
    return jobs


def recover() -> None:
    """A half-run job cannot be trusted. A job still waiting can continue."""
    with _file_lock:
        for job in _all():
            if job["state"] == "running":
                _close_open(job, now())
                job["state"] = "error"
                job["error"] = RESTART_ERROR
                job["error_code"] = "restarted"
                audio = job.get("audio")
                if audio:
                    Path(audio).unlink(missing_ok=True)
                    job["audio"] = None
                _write(job)
            elif job["state"] == "queued":
                audio = job.get("audio")
                if not audio or not Path(audio).is_file():
                    job["state"] = "error"
                    job["error"] = RESTART_ERROR
                    job["error_code"] = "restarted"
                    job["audio"] = None
                    _write(job)
        _sweep_orphan_audio()


def _sweep_orphan_audio() -> None:
    known = set()
    for job in _all():
        audio = job.get("audio")
        if audio:
            known.add(Path(audio).name)
    for path in audio_dir().iterdir():
        if path.is_file() and path.name not in known:
            path.unlink(missing_ok=True)


def _expire_unlocked() -> None:
    cutoff = datetime.now(timezone.utc) - RESULT_TTL
    for job in _all():
        if job["state"] not in ("done", "error"):
            continue
        created = datetime.fromisoformat(job["created"])
        if created < cutoff:
            _path(job["id"]).unlink(missing_ok=True)


def expire() -> None:
    with _file_lock:
        _expire_unlocked()


def next_queued() -> dict | None:
    with _file_lock:
        for job in _all():
            if job["state"] == "queued":
                return job
    return None


def worker(run_file) -> None:
    while not _stop.is_set():
        expire()
        job = next_queued()
        if job is None:
            time.sleep(0.4)
            continue
        audio = job.get("audio")
        if not audio or not Path(audio).is_file():
            fail(job["id"], RESTART_ERROR, "restarted")
            continue
        try:
            with gpu_lock:
                stems = run_file(Path(audio), lambda stage: mark_stage(job["id"], stage))
            finish(job["id"], stems)
        except JobFailed as exc:
            fail(job["id"], str(exc), exc.code)
        except Exception:
            log.exception("job failed")
            fail(job["id"], "Could not separate this audio", "unreadable")


def start(run_file) -> None:
    recover()
    thread = threading.Thread(target=worker, args=(run_file,), daemon=True)
    thread.start()
