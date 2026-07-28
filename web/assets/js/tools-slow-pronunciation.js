(function () {
  const phraseEl = document.getElementById('phrase');
  const speedEl = document.getElementById('speed');
  const speedVal = document.getElementById('speed-val');
  const player = document.getElementById('player');
  const statusEl = document.getElementById('status');
  const linkShadow = document.getElementById('link-shadow');
  let objectUrl = null;

  const params = new URLSearchParams(location.search);
  if (params.get('text')) {
    phraseEl.value = params.get('text');
  }

  function setStatus(kind, message) {
    statusEl.className = `tool-status is-visible ${kind}`;
    statusEl.textContent = message;
  }

  function syncShadowLink() {
    const q = encodeURIComponent(phraseEl.value.trim().slice(0, 500));
    linkShadow.href = `/tools/shadow-phrase?text=${q}`;
  }

  speedEl.addEventListener('input', () => {
    speedVal.textContent = `${Number(speedEl.value).toFixed(2)}×`;
  });
  phraseEl.addEventListener('input', syncShadowLink);
  syncShadowLink();

  document.getElementById('btn-speak').addEventListener('click', async () => {
    const text = phraseEl.value.trim();
    if (!text) {
      setStatus('error', 'Enter a phrase to pronounce.');
      return;
    }
    const btn = document.getElementById('btn-speak');
    btn.disabled = true;
    setStatus('info', 'Generating speech…');
    try {
      if (objectUrl) URL.revokeObjectURL(objectUrl);
      const result = await MusnoteApi.synthesizeSpeech({
        text,
        language: document.getElementById('language').value,
        voice: document.getElementById('voice').value,
        speed: Number(speedEl.value),
      });
      objectUrl = result.objectUrl;
      player.src = objectUrl;
      player.style.display = 'block';
      await player.play().catch(() => {});
      setStatus('ok', 'Ready — listen, then shadow the phrase.');
      syncShadowLink();
    } catch (err) {
      setStatus('error', err.message || String(err));
    } finally {
      btn.disabled = false;
    }
  });
})();
