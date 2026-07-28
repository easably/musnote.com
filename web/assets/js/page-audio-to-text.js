(function () {
  const statusEl = document.getElementById('status');
  const resultEl = document.getElementById('result');
  const transcriptEl = document.getElementById('transcript');
  const segmentsEl = document.getElementById('segments');
  const linkSlow = document.getElementById('link-slow');

  function setStatus(kind, message) {
    statusEl.className = `tool-status is-visible ${kind}`;
    statusEl.textContent = message;
  }

  function clearStatus() {
    statusEl.className = 'tool-status';
    statusEl.textContent = '';
  }

  function formatTime(sec) {
    if (sec == null || Number.isNaN(Number(sec))) return '—';
    const s = Math.max(0, Number(sec));
    const m = Math.floor(s / 60);
    const r = (s % 60).toFixed(1).padStart(4, '0');
    return `${m}:${r}`;
  }

  function showResult(data) {
    resultEl.hidden = false;
    transcriptEl.textContent = data.text || '(empty transcript)';
    segmentsEl.innerHTML = '';
    (data.segments || []).forEach((seg) => {
      const li = document.createElement('li');
      const start = seg.start ?? seg.from ?? 0;
      const end = seg.end ?? seg.to ?? '';
      const text = seg.text || seg.transcript || '';
      li.innerHTML = `<time>${formatTime(start)}${end !== '' ? '–' + formatTime(end) : ''}</time> ${text}`;
      segmentsEl.appendChild(li);
    });
    const q = encodeURIComponent((data.text || '').slice(0, 500));
    linkSlow.href = `/tools/slow-pronunciation?text=${q}`;
  }

  async function run(payload) {
    setStatus('info', 'Transcribing… this can take up to a few minutes for longer clips.');
    resultEl.hidden = true;
    document.getElementById('btn-file').disabled = true;
    document.getElementById('btn-url').disabled = true;
    try {
      const data = await (window.MusnoteVoiceCloud || window.MusnoteApi).speechToText(payload);
      setStatus('ok', `Done${data.language ? ` · detected language: ${data.language}` : ''}${data.duration ? ` · ${Number(data.duration).toFixed(1)}s` : ''}`);
      showResult(data);
    } catch (err) {
      setStatus('error', err.message || String(err));
    } finally {
      document.getElementById('btn-file').disabled = false;
      document.getElementById('btn-url').disabled = false;
    }
  }

  document.getElementById('btn-file').addEventListener('click', () => {
    const file = document.getElementById('audio-file').files?.[0];
    if (!file) {
      setStatus('error', 'Choose an audio file first.');
      return;
    }
    run({ file });
  });

  document.getElementById('btn-url').addEventListener('click', () => {
    const url = document.getElementById('audio-url').value.trim();
    if (!url) {
      setStatus('error', 'Paste an audio or page URL first.');
      return;
    }
    run({ url });
  });

  document.getElementById('btn-copy').addEventListener('click', async () => {
    try {
      await navigator.clipboard.writeText(transcriptEl.textContent || '');
      setStatus('ok', 'Transcript copied.');
    } catch (_) {
      setStatus('error', 'Could not copy — select the text manually.');
    }
  });
})();
