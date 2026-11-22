# One image. Python 3.10 so Basic Pitch stays on TFLite, same as api/.
# Demucs and PyTorch CUDA 12.8 live here too: the host split them only
# because Ubuntu's Python is 3.12, and Basic Pitch does not install there.
FROM python:3.10-slim-bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends ffmpeg libsndfile1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir \
        torch==2.11.0+cu128 torchaudio==2.11.0+cu128 \
        --extra-index-url https://download.pytorch.org/whl/cu128 \
    && pip install --no-cache-dir -r requirements.txt demucs==4.1.0 \
    && pip install --no-cache-dir \
        torch==2.11.0+cu128 torchaudio==2.11.0+cu128 \
        --extra-index-url https://download.pytorch.org/whl/cu128 \
    && python -c "import torch; assert 'cu128' in torch.__version__, torch.__version__"

COPY app.py audio_in.py jobs.py notes.py stems.py ./

ENV DEMUCS_BIN=demucs \
    TORCH_HOME=/var/cache/torch

EXPOSE 8096
CMD ["python", "-m", "uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8096"]
