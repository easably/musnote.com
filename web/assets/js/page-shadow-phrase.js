(function () {
  const phraseEl = document.getElementById('phrase');
  const speedEl = document.getElementById('speed');
  const speedVal = document.getElementById('speed-val');
  const player = document.getElementById('player');
  const statusEl = document.getElementById('status');
  const liveNote = document.getElementById('live-note');
  const liveHz = document.getElementById('live-hz');
  let objectUrl = null;
  let monitor = null;

  const params = new URLSearchParams(location.search);
  if (params.get('text')) phraseEl.value = params.get('text');

  function setStatus(kind, message) {
    statusEl.className = `tool-status is-visible ${kind}`;
    statusEl.textContent = message;
  }

  speedEl.addEventListener('input', () => {
    speedVal.textContent = `${Number(speedEl.value).toFixed(2)}×`;
  });

  document.getElementById('btn-model').addEventListener('click', async () => {
    const text = phraseEl.value.trim();
    if (!text) {
      setStatus('error', 'Enter a phrase to shadow.');
      return;
    }
    const btn = document.getElementById('btn-model');
    btn.disabled = true;
    setStatus('info', 'Generating model audio…');
    try {
      if (objectUrl) URL.revokeObjectURL(objectUrl);
      const result = await (window.MusnoteVoiceCloud || window.MusnoteApi).synthesizeSpeech({
        text,
        language: document.getElementById('language').value,
        voice: 'female',
        speed: Number(speedEl.value),
      });
      objectUrl = result.objectUrl;
      player.src = objectUrl;
      player.style.display = 'block';
      await player.play().catch(() => {});
      setStatus('ok', 'Model ready — start the mic and speak along.');
    } catch (err) {
      setStatus('error', err.message || String(err));
    } finally {
      btn.disabled = false;
    }
  });

  document.getElementById('btn-mic-start').addEventListener('click', async () => {
    try {
      monitor = new MusnotePitch.LivePitchMonitor(({ note, freq }) => {
        if (!note) {
          liveNote.textContent = '…';
          liveHz.textContent = '—';
          return;
        }
        liveNote.textContent = note.label;
        liveHz.textContent = Math.round(freq);
      });
      await monitor.start();
      document.getElementById('btn-mic-start').disabled = true;
      document.getElementById('btn-mic-stop').disabled = false;
      setStatus('info', 'Mic on — shadow the model phrase.');
    } catch (err) {
      setStatus('error', err.message || 'Microphone permission denied.');
    }
  });

  document.getElementById('btn-mic-stop').addEventListener('click', () => {
    if (monitor) monitor.stop();
    monitor = null;
    document.getElementById('btn-mic-start').disabled = false;
    document.getElementById('btn-mic-stop').disabled = true;
    setStatus('ok', 'Mic stopped.');
  });
})();
