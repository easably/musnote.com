"""One stem in, the same note list the site already understands.

The fields match api/app/notes.py. This file stays here because the probe
runs on server7, and api/ deploys only to server8.
"""

from __future__ import annotations

import threading
from typing import Any

NAMES = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
_model: Any = None
_lock = threading.Lock()


def note_name(midi: int) -> str:
    return NAMES[midi % 12] + str(midi // 12 - 1)


def _model_instance():
    global _model
    if _model is None:
        from basic_pitch import ICASSP_2022_MODEL_PATH
        from basic_pitch.inference import Model

        _model = Model(ICASSP_2022_MODEL_PATH)
    return _model


def notes_from_audio(path: str) -> list[dict]:
    from basic_pitch.inference import predict

    with _lock:
        _model_output, _midi, events = predict(path, _model_instance())

    notes = []
    for start, end, midi, amplitude, _bends in events:
        midi_i = int(midi)
        notes.append(
            {
                "midi": midi_i,
                "name": note_name(midi_i),
                "start": round(float(start), 3),
                "end": round(float(end), 3),
                "velocity": round(float(amplitude), 3),
            }
        )
    notes.sort(key=lambda note: (note["start"], note["midi"]))
    return notes
