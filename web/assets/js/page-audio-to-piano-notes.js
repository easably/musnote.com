/**
 * Home page — audio to piano notes: file → POST /v1/notes → light keys → play by start time.
 * API: window.MUSNOTE_NOTES_API, else http://127.0.0.1:8095
 */
(function () {
  const panel = document.getElementById('notes-panel');
  const input = document.getElementById('audio-file');
  const btnGo = document.getElementById('btn-transcribe');
  const btnPlay = document.getElementById('btn-play');
  const status = document.getElementById('notes-status');
  const svg = document.getElementById('notes-kb');
  if (!panel || !input || !btnGo || !btnPlay || !status || !svg || typeof MN === 'undefined') return;

  const API = (window.MUSNOTE_NOTES_API || 'http://127.0.0.1:8095').replace(/\/$/, '');
  const MAX_BYTES = 15 * 1024 * 1024;
  const msg = (key) => panel.dataset[key] || '';

  let notes = [];
  let kb = null;
  let playTok = 0;

  function setStatus(text, kind) {
    if (!text) {
      status.hidden = true;
      status.textContent = '';
      status.className = 'notes-status';
      return;
    }
    status.hidden = false;
    status.textContent = text;
    status.className = 'notes-status' + (kind ? ' ' + kind : '');
  }

  function whiteStartFor(midi) {
    let m = midi;
    while (MN.isBlack(m)) m--;
    return m;
  }

  function whitesToCover(lo, hi) {
    let m = whiteStartFor(lo);
    let whites = 0;
    while (m <= hi) {
      if (!MN.isBlack(m)) whites++;
      m++;
    }
    return Math.max(whites, 8);
  }

  function buildKeyboard(list) {
    let lo = 48;
    let hi = 72;
    if (list.length) {
      lo = Math.min(...list.map((n) => n.midi));
      hi = Math.max(...list.map((n) => n.midi));
      lo = Math.max(21, lo - 2);
      hi = Math.min(108, hi + 2);
    }
    const start = whiteStartFor(lo);
    const whites = Math.min(24, whitesToCover(start, hi));
    kb = MN.keyboard(svg, { start, whites, H: 150, labels: true });
  }

  function paintKeys(list) {
    if (!kb) return;
    kb.clear();
    const seen = new Set();
    list.forEach((n) => {
      const k = kb.keys[n.midi];
      if (!k || seen.has(n.midi)) return;
      seen.add(n.midi);
      k.rect.classList.add('hl-r');
    });
  }

  function showNotes(list) {
    notes = list.slice().sort((a, b) => a.start - b.start || a.midi - b.midi);
    buildKeyboard(notes);
    paintKeys(notes);
    btnPlay.disabled = !notes.length;
  }

  function playTimeline() {
    if (!notes.length) return;
    const tok = ++playTok;
    const t0 = notes[0].start;
    const groups = new Map();
    notes.forEach((n) => {
      const key = String(n.start);
      if (!groups.has(key)) groups.set(key, []);
      groups.get(key).push(n);
    });
    const starts = [...groups.keys()]
      .map(Number)
      .sort((a, b) => a - b);

    starts.forEach((s) => {
      const delay = Math.max(0, (s - t0) * 1000);
      setTimeout(() => {
        if (tok !== playTok) return;
        const chunk = groups.get(String(s));
        paintKeys(chunk);
        MN.play(
          chunk.map((n) => n.midi),
          { arp: false }
        );
      }, delay);
    });

    const last = starts[starts.length - 1];
    const endMs = Math.max(0, (last - t0) * 1000) + 900;
    setTimeout(() => {
      if (tok !== playTok) return;
      paintKeys(notes);
    }, endMs);
  }

  async function transcribe(file) {
    if (!file) return;
    if (file.size > MAX_BYTES) {
      setStatus(msg('msgBig'), 'bad');
      return;
    }
    setStatus(msg('msgBusy'));
    btnGo.disabled = true;
    btnPlay.disabled = true;
    playTok++;

    const form = new FormData();
    form.append('file', file, file.name || 'audio.wav');

    let res;
    try {
      res = await fetch(API + '/v1/notes', { method: 'POST', body: form });
    } catch (_) {
      setStatus(msg('msgOffline'), 'bad');
      btnGo.disabled = false;
      return;
    }

    let data = null;
    try {
      data = await res.json();
    } catch (_) {}

    btnGo.disabled = false;
    if (!res.ok) {
      setStatus(msg('msgFail'), 'bad');
      showNotes([]);
      return;
    }
    const found = Array.isArray(data && data.notes) ? data.notes : [];
    if (!found.length) {
      setStatus(msg('msgEmpty'), 'bad');
      showNotes([]);
      return;
    }
    setStatus('');
    showNotes(found);
  }

  buildKeyboard([]);
  btnGo.addEventListener('click', () => {
    const file = input.files && input.files[0];
    if (!file) {
      setStatus(msg('msgEmpty'), 'bad');
      return;
    }
    transcribe(file);
  });
  input.addEventListener('change', () => {
    if (input.files && input.files[0]) setStatus('');
  });
  btnPlay.addEventListener('click', playTimeline);
})();
