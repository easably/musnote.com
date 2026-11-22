"""Turn an upload into one 44.1 kHz stereo wav.

Keep this file the same in the notes API and the stem probe.
"""

from __future__ import annotations

import subprocess
from pathlib import Path

ALLOWED_SUFFIXES = {
    ".mp3",
    ".m4a",
    ".aac",
    ".wav",
    ".flac",
    ".ogg",
    ".oga",
    ".opus",
    ".webm",
    ".wma",
    ".aif",
    ".aiff",
    ".amr",
    ".3ga",
    ".caf",
    ".mp4",
    ".m4v",
    ".mov",
    ".mkv",
    ".avi",
    ".3gp",
    ".wmv",
}

NO_AUDIO = "This file has no audio."

# Content decides the demuxer, not the extension. Only ordinary media files,
# and only from disk: a playlist named .mp4 must not open http or other files.
_GUARD = [
    "-protocol_whitelist",
    "file",
    "-format_whitelist",
    "mov,mp4,m4a,3gp,matroska,webm,mp3,wav,flac,ogg,aac,asf,aiff,amr,amrnb,amrwb,caf,avi",
]


class NoAudio(Exception):
    """The file opened, and it has no audio track."""


class Unreadable(Exception):
    """ffprobe or ffmpeg could not read the file."""


def to_wav(src: Path, dest: Path) -> None:
    """Write a 44.1 kHz stereo wav. Demucs and Basic Pitch both read that."""
    try:
        probe = subprocess.run(
            [
                "ffprobe",
                "-v",
                "error",
                *_GUARD,
                "-select_streams",
                "a:0",
                "-show_entries",
                "stream=codec_type",
                "-of",
                "csv=p=0",
                str(src),
            ],
            capture_output=True,
            text=True,
            timeout=30,
            check=False,
        )
    except subprocess.TimeoutExpired as exc:
        raise Unreadable("ffprobe timed out") from exc
    if probe.returncode != 0:
        raise Unreadable(probe.stderr[-500:])
    if probe.stdout.strip() != "audio":
        raise NoAudio(NO_AUDIO)
    try:
        conv = subprocess.run(
            [
                "ffmpeg",
                "-y",
                "-hide_banner",
                *_GUARD,
                "-i",
                str(src),
                "-vn",
                "-ar",
                "44100",
                "-ac",
                "2",
                "-c:a",
                "pcm_s16le",
                str(dest),
            ],
            capture_output=True,
            text=True,
            timeout=120,
            check=False,
        )
    except subprocess.TimeoutExpired as exc:
        raise Unreadable("ffmpeg timed out") from exc
    if conv.returncode != 0 or not dest.is_file() or dest.stat().st_size == 0:
        raise Unreadable(conv.stderr[-500:])
