/**
 * Home and song-to-notes: file → POST /v1/piano-notes → keys, player, MIDI, text.
 * Override: window.MUSNOTE_NOTES_API.
 * Empty state is the large drop zone. After notes arrive it collapses to a file row.
 * #notes-kb stays in the result block; falling-notes.js draws its lane above that svg.
 */
(function () {
  const panel = document.getElementById('notes-panel');
  const input = document.getElementById('audio-file');
  const btnPlay = document.getElementById('btn-play');
  const btnStop = document.getElementById('btn-stop');
  const seek = document.getElementById('notes-seek');
  const speedEl = document.getElementById('notes-speed');
  const timeEl = document.getElementById('notes-time');
  const status = document.getElementById('notes-status');
  const summary = document.getElementById('notes-summary');
  const clippedEl = document.getElementById('notes-clipped');
  const busy = document.getElementById('notes-busy');
  const svg = document.getElementById('notes-kb');
  const btnMidi = document.getElementById('btn-midi');
  const btnSheet = document.getElementById('btn-sheet');
  const btnTxt = document.getElementById('btn-txt');
  const btnCopy = document.getElementById('btn-copy');
  const btnPick = document.getElementById('btn-pick');
  const btnAnother = document.getElementById('btn-another');
  const fileNameEl = document.getElementById('notes-file-name');
  const fileSizeEl = document.getElementById('notes-file-size');
  const menu = document.getElementById('notes-menu');
  const downloadMenuBtn = document.getElementById('btn-download-menu');
  const btnMidiMenu = document.getElementById('btn-midi-menu');
  const drop = document.getElementById('notes-drop');
  if (!panel || !input || !btnPlay || !btnStop || !seek || !status || !svg) return;
  if (typeof MN === 'undefined' || typeof MusnoteExport === 'undefined' || typeof FallingNotes === 'undefined') return;

  const host = location.hostname;
  const local = host === 'localhost' || host === '127.0.0.1';
  const API = (
    window.MUSNOTE_NOTES_API ||
    (local ? 'http://127.0.0.1:8095' : 'https://api.musnote.com')
  ).replace(/\/$/, '');
  const MAX_BYTES = 100 * 1024 * 1024;
  const SUFFIXES = new Set(['.wav', '.mp3', '.m4a', '.ogg', '.flac', '.webm', '.aac']);
  const msg = (key) => panel.dataset[key] || '';
  const warn = document.getElementById('notes-track-warn');
  const solo = document.getElementById('track-solo');

  function selectedTrack() {
    const picked = panel.querySelector('input[name="track-intent"]:checked');
    return picked ? picked.value : 'whole';
  }

  function paintTrack() {
    const one = !!(solo && solo.checked);
    if (warn) warn.textContent = one ? msg('warnSolo') : msg('warnMix');
    panel.dataset.trackIntent = selectedTrack();
  }

  let notes = [];
  let kb = null;
  let roll = null;
  let duration = 0;
  let playing = false;
  let speed = 1;
  let position = 0;
  let originAudio = 0;
  let originPos = 0;
  let gen = 0;
  let timer = 0;
  let seeking = false;
  let fileName = 'audio';
  const voices = [];
  let sheet;
  let copiedTimer = 0;
  /* dragenter also fires when the pointer moves onto a child of the zone. */
  let dragDepth = 0;

  /* empty: drop zone. drag: file is over the zone. loading: reading notes. result: player and download. */
  function showPanelState(name) {
    panel.dataset.state = name;
  }

  function formatBytes(bytes) {
    const lang = document.documentElement.lang || 'en';
    const mb = bytes / (1024 * 1024);
    if (mb >= 0.1) {
      const n = mb.toLocaleString(lang, { maximumFractionDigits: 1 });
      return n + ' ' + (msg('msgMb') || 'MB');
    }
    const n = Math.max(1, Math.round(bytes / 1024)).toLocaleString(lang);
    return n + ' ' + (msg('msgKb') || 'KB');
  }

  function showFile(file) {
    if (fileNameEl) fileNameEl.textContent = file.name || '';
    if (fileSizeEl) fileSizeEl.textContent = formatBytes(file.size || 0);
  }

  function closeMenu() {
    if (!menu || !downloadMenuBtn) return;
    menu.hidden = true;
    downloadMenuBtn.setAttribute('aria-expanded', 'false');
  }

  function toggleMenu() {
    if (!menu || !downloadMenuBtn || downloadMenuBtn.disabled) return;
    const open = menu.hidden;
    menu.hidden = !open;
    downloadMenuBtn.setAttribute('aria-expanded', open ? 'true' : 'false');
  }

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

  function formatClock(sec) {
    const whole = Math.max(0, Math.round(Number(sec) || 0));
    const m = Math.floor(whole / 60);
    const s = whole % 60;
    return m + ':' + String(s).padStart(2, '0');
  }

  function pitchLabel(midi) {
    return MusnoteExport.pitchName(midi, { octave: true, solfege: false });
  }

  function buildKeyboard(list) {
    const range = FallingNotes.rangeForMidis(list.map((n) => n.midi));
    kb = MN.keyboard(svg, { start: range.start, whites: range.whites, H: 150, labels: true });
    if (!roll) roll = FallingNotes.mount(svg, { lookAhead: 4, laneHeight: 220 });
    roll.setLayout(range.start, range.whites, kb.W);
    roll.setNotes(notes);
    roll.setTime(position);
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
    if (roll) roll.setTime(position);
  }

  function paintAt(t) {
    if (!kb) return;
    kb.clear();
    const seen = new Set();
    notes.forEach((n) => {
      if (n.start <= t && t < n.end) {
        const k = kb.keys[n.midi];
        if (!k || seen.has(n.midi)) return;
        seen.add(n.midi);
        k.rect.classList.add('hl-r');
      }
    });
    if (roll) roll.setTime(t);
  }

  function setBusy(on) {
    if (busy) busy.hidden = !on;
  }

  function setControls(on) {
    btnPlay.disabled = !on;
    btnStop.disabled = !on;
    seek.disabled = !on;
    if (speedEl) speedEl.disabled = !on;
    if (btnMidi) btnMidi.disabled = !on;
    if (btnMidiMenu) btnMidiMenu.disabled = !on;
    if (btnSheet) btnSheet.disabled = !on;
    if (btnTxt) btnTxt.disabled = !on;
    if (btnCopy) btnCopy.disabled = !on;
    if (downloadMenuBtn) downloadMenuBtn.disabled = !on;
    if (!on) closeMenu();
  }

  function renderTime() {
    const pos = seeking
      ? Number(seek.value) / 1000
      : Math.min(duration, Math.max(0, playing ? recNow() : position));
    if (timeEl) timeEl.textContent = formatClock(pos) + ' / ' + formatClock(duration);
    if (!seeking) seek.value = String(Math.round(pos * 1000));
    btnPlay.textContent = playing ? (msg('msgPause') || 'Pause') : (msg('msgPlay') || btnPlay.textContent);
    btnPlay.setAttribute('aria-pressed', playing ? 'true' : 'false');
  }

  function noteUnit(n) {
    const lang = document.documentElement.lang || 'en';
    let category = 'other';
    try {
      category = new Intl.PluralRules(lang).select(n);
    } catch (_) {}
    const key = 'msgNote' + category.charAt(0).toUpperCase() + category.slice(1);
    return msg(key) || msg('msgNoteOther') || '';
  }

  function showSummary(isClipped) {
    if (!notes.length) {
      if (summary) summary.hidden = true;
      if (clippedEl) clippedEl.hidden = true;
      return;
    }
    const lo = pitchLabel(Math.min(...notes.map((n) => n.midi)));
    const hi = pitchLabel(Math.max(...notes.map((n) => n.midi)));
    const template = msg('msgFound') || 'Found {n} {unit} · {time} · {lo} to {hi}';
    const map = {
      n: String(notes.length),
      unit: noteUnit(notes.length),
      time: formatClock(duration),
      lo,
      hi,
    };
    const text = template.replace(/\{(n|unit|time|lo|hi)\}/g, (_, key) => map[key]);
    if (summary) {
      summary.hidden = false;
      summary.textContent = text;
    }
    if (clippedEl) {
      clippedEl.hidden = !isClipped;
      clippedEl.textContent = isClipped ? msg('msgClipped') : '';
    }
  }

  function stopVoices() {
    while (voices.length) {
      const v = voices.pop();
      if (v && v.stop) v.stop();
    }
  }

  function recNow() {
    if (!playing) return position;
    return originPos + Math.max(0, (MN.now() - originAudio) * speed);
  }

  function arm() {
    const now = recNow();
    MusnoteExport.scheduleSlice(notes, now, speed).forEach((item) => {
      const n = item.note;
      if (n._gen === gen) return;
      n._gen = gen;
      voices.push(MN.note(n.midi, {
        when: MN.now() + item.delay,
        duration: item.duration,
        volume: item.volume,
      }));
    });
  }

  function haltAt(pos, paintAll) {
    if (playing) position = Math.min(duration, Math.max(0, recNow()));
    playing = false;
    if (timer) clearInterval(timer);
    timer = 0;
    stopVoices();
    gen += 1;
    position = pos;
    if (paintAll) paintKeys(notes);
    else paintAt(position);
    renderTime();
  }

  function playFrom(pos) {
    stopVoices();
    gen += 1;
    notes.forEach((n) => { n._gen = 0; });
    position = Math.min(duration, Math.max(0, pos));
    playing = true;
    originAudio = MN.now() + 0.03;
    originPos = position;
    if (timer) clearInterval(timer);
    timer = setInterval(tick, 50);
    tick();
    renderTime();
  }

  function tick() {
    if (!playing) return;
    const now = recNow();
    if (now >= duration) {
      haltAt(0, true);
      return;
    }
    arm();
    paintAt(now);
    renderTime();
  }

  function togglePlay() {
    if (!notes.length) return;
    if (playing) haltAt(recNow(), false);
    else playFrom(position >= duration ? 0 : position);
  }

  function showNotes(list, isClipped) {
    haltAt(0, false);
    notes = list.map((n) => ({
      midi: Number(n.midi),
      start: Number(n.start) || 0,
      end: Math.max(Number(n.end) || 0, (Number(n.start) || 0) + 0.02),
      velocity: n.velocity == null ? 0.7 : Number(n.velocity),
    })).sort((a, b) => a.start - b.start || a.midi - b.midi);
    duration = notes.reduce((m, n) => Math.max(m, n.end), 0);
    seek.max = String(Math.max(0, Math.round(duration * 1000)));
    seek.value = '0';
    position = 0;
    buildKeyboard(notes);
    paintKeys(notes);
    setControls(!!notes.length);
    showSummary(!!isClipped);
    renderTime();
    if (sheet && !sheet.hidden) renderSheet();
  }

  function suffixOf(name) {
    const dot = String(name || '').lastIndexOf('.');
    return dot >= 0 ? name.slice(dot).toLowerCase() : '';
  }

  function accept(file) {
    if (!file) return;
    if (!SUFFIXES.has(suffixOf(file.name))) {
      setStatus(msg('msgBadType'), 'bad');
      return;
    }
    if (file.size > MAX_BYTES) {
      setStatus(msg('msgBig'), 'bad');
      return;
    }
    fileName = file.name || 'audio';
    showFile(file);
    transcribe(file);
  }

  async function transcribe(file) {
    setStatus('');
    showPanelState('loading');
    setBusy(true);
    setControls(false);
    haltAt(0, false);

    const form = new FormData();
    form.append('file', file, file.name || 'audio.wav');

    let res;
    try {
      res = await fetch(API + '/v1/piano-notes', { method: 'POST', body: form });
    } catch (_) {
      setBusy(false);
      showPanelState(notes.length ? 'result' : 'empty');
      setStatus(msg('msgOffline'), 'bad');
      setControls(!!notes.length);
      return;
    }

    let data = null;
    try {
      data = await res.json();
    } catch (_) {}

    setBusy(false);
    if (!res.ok) {
      showPanelState(notes.length ? 'result' : 'empty');
      setStatus(msg('msgFail'), 'bad');
      setControls(!!notes.length);
      return;
    }
    const found = Array.isArray(data && data.notes) ? data.notes : [];
    if (!found.length) {
      showPanelState('empty');
      setStatus(msg('msgFail'), 'bad');
      showNotes([], false);
      return;
    }
    showPanelState('result');
    setStatus('');
    showNotes(found, !!(data && data.clipped));
  }

  function downloadMidi() {
    if (!notes.length) return;
    saveBlob(MusnoteExport.encodeMidi(notes), MusnoteExport.downloadName(fileName, 'mid'), 'audio/midi');
    closeMenu();
  }

  function saveBlob(bytes, name, type) {
    const blob = new Blob([bytes], { type });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = name;
    document.body.appendChild(a);
    a.click();
    a.remove();
    setTimeout(() => URL.revokeObjectURL(url), 1000);
  }

  function textOpts() {
    if (!sheet) return { octave: false, solfege: MusnoteExport.SOLFEGE_LANGS.has(MN.LANG), lang: MN.LANG };
    const octave = sheet.querySelector('#sheet-octave');
    const solfege = sheet.querySelector('input[name="sheet-names"]:checked');
    return {
      octave: !!(octave && octave.checked),
      solfege: !!(solfege && solfege.value === 'solfege'),
      lang: MN.LANG,
    };
  }

  function currentText() {
    return MusnoteExport.notesText(notes, textOpts());
  }

  function legendHtml() {
    if (!notes.length) return '';
    const lo = Math.min(...notes.map((n) => n.midi));
    const hi = Math.max(...notes.map((n) => n.midi));
    const start = lo - (lo % 12);
    let end = hi + ((12 - (hi % 12)) % 12);
    if (end === start) end = start + 12;
    let html = '<div class="sheet-kb" aria-hidden="true">';
    for (let m = start; m <= end; m++) {
      const black = MN.isBlack(m);
      const label = m % 12 === 0 ? 'C' + (Math.floor(m / 12) - 1) : '';
      html += '<i class="' + (black ? 'b' : 'w') + '">' + (label ? '<b>' + label + '</b>' : '') + '</i>';
    }
    html += '</div>';
    return html;
  }

  function renderSheet() {
    if (!sheet) return;
    const body = sheet.querySelector('.notes-sheet-body');
    if (!body) return;
    const when = new Date().toLocaleDateString(document.documentElement.lang || 'en');
    const lines = currentText().split('\n').map((line) => '<p class="sheet-line">' + escapeHtml(line) + '</p>').join('');
    body.innerHTML =
      '<h2>' + escapeHtml(fileName) + '</h2>' +
      '<p class="sheet-meta">' + escapeHtml(when) + ' · musnote.com</p>' +
      legendHtml() +
      lines;
  }

  function escapeHtml(s) {
    return String(s).replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
  }

  function ensureSheet() {
    if (sheet) return;
    const solfegeDefault = MusnoteExport.SOLFEGE_LANGS.has(MN.LANG);
    sheet = document.createElement('section');
    sheet.className = 'notes-sheet wrap';
    sheet.hidden = true;
    sheet.innerHTML =
      '<div class="notes-sheet-tools">' +
      '<label><input type="checkbox" id="sheet-octave"> ' + escapeHtml(msg('msgSheetOctave')) + '</label>' +
      '<label><input type="radio" name="sheet-names" value="letters"' + (solfegeDefault ? '' : ' checked') + '> ' + escapeHtml(msg('msgSheetLetters')) + '</label>' +
      '<label><input type="radio" name="sheet-names" value="solfege"' + (solfegeDefault ? ' checked' : '') + '> ' + escapeHtml(msg('msgSheetSolfege')) + '</label>' +
      '<button type="button" class="btn primary" id="btn-print">' + escapeHtml(msg('msgPrint')) + '</button>' +
      '</div>' +
      '<article class="notes-sheet-body"></article>';
    document.body.appendChild(sheet);
    sheet.addEventListener('change', renderSheet);
    sheet.querySelector('#btn-print').addEventListener('click', () => {
      document.body.classList.add('printing-notes');
      window.print();
    });
  }

  window.addEventListener('afterprint', () => {
    document.body.classList.remove('printing-notes');
  });

  buildKeyboard([]);
  paintTrack();
  showPanelState('empty');
  setControls(false);
  renderTime();
  if (btnPick) btnPick.addEventListener('click', () => input.click());
  if (btnAnother) btnAnother.addEventListener('click', () => input.click());
  if (downloadMenuBtn) downloadMenuBtn.addEventListener('click', (event) => {
    event.stopPropagation();
    toggleMenu();
  });
  document.addEventListener('click', (event) => {
    if (!menu || menu.hidden) return;
    if (menu.contains(event.target) || (downloadMenuBtn && downloadMenuBtn.contains(event.target))) return;
    closeMenu();
  });
  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') closeMenu();
  });
  panel.addEventListener('change', (event) => {
    const target = event.target;
    if (!target) return;
    if (target.name === 'track-intent' || target.id === 'track-solo') paintTrack();
  });
  input.addEventListener('change', () => {
    const file = input.files && input.files[0];
    input.value = '';
    if (file) accept(file);
  });
  function fileDrag(event) {
    const types = event.dataTransfer && event.dataTransfer.types;
    return !!(types && [...types].includes('Files'));
  }
  document.addEventListener('dragover', (event) => {
    if (!fileDrag(event)) return;
    event.preventDefault();
  });
  document.addEventListener('drop', (event) => {
    if (!fileDrag(event)) return;
    event.preventDefault();
    dragDepth = 0;
    if (panel.dataset.state === 'drag') showPanelState('empty');
    if (!panel.contains(event.target)) return;
    const file = event.dataTransfer.files && event.dataTransfer.files[0];
    if (file) accept(file);
  });
  const dragHost = drop || panel;
  dragHost.addEventListener('dragenter', (event) => {
    if (!fileDrag(event)) return;
    dragDepth += 1;
    if (panel.dataset.state === 'empty' || panel.dataset.state === 'drag') showPanelState('drag');
  });
  dragHost.addEventListener('dragleave', (event) => {
    if (!fileDrag(event)) return;
    dragDepth = Math.max(0, dragDepth - 1);
    if (dragDepth === 0 && panel.dataset.state === 'drag') showPanelState('empty');
  });
  btnPlay.addEventListener('click', togglePlay);
  btnStop.addEventListener('click', () => {
    if (!notes.length) return;
    haltAt(0, true);
  });
  let seekCommitAt = 0;
  function commitSeek() {
    const nowMs = Date.now();
    if (nowMs - seekCommitAt < 40) return;
    seekCommitAt = nowMs;
    const pos = Number(seek.value) / 1000;
    seeking = false;
    if (playing) playFrom(pos);
    else {
      position = pos;
      paintAt(pos);
      renderTime();
    }
  }
  seek.addEventListener('pointerdown', () => { seeking = true; });
  seek.addEventListener('input', () => {
    seeking = true;
    const pos = Number(seek.value) / 1000;
    if (!playing) position = pos;
    paintAt(pos);
    renderTime();
  });
  seek.addEventListener('change', commitSeek);
  seek.addEventListener('pointerup', commitSeek);
  if (speedEl) {
    speedEl.addEventListener('change', () => {
      const pos = playing ? recNow() : position;
      speed = Number(speedEl.value) || 1;
      if (playing) playFrom(pos);
    });
  }
  if (btnMidi) btnMidi.addEventListener('click', downloadMidi);
  if (btnMidiMenu) btnMidiMenu.addEventListener('click', downloadMidi);
  if (btnTxt) {
    btnTxt.addEventListener('click', () => {
      if (!notes.length) return;
      saveBlob(currentText(), MusnoteExport.downloadName(fileName, 'txt'), 'text/plain');
      closeMenu();
    });
  }
  if (btnCopy) {
    btnCopy.addEventListener('click', async () => {
      if (!notes.length) return;
      try {
        await navigator.clipboard.writeText(currentText());
        closeMenu();
        setStatus(msg('msgCopied'));
        clearTimeout(copiedTimer);
        copiedTimer = setTimeout(() => {
          if (status.textContent === msg('msgCopied')) setStatus('');
        }, 1500);
      } catch (_) {
        setStatus(msg('msgFail'), 'bad');
      }
    });
  }
  if (btnSheet) {
    btnSheet.addEventListener('click', () => {
      if (!notes.length) return;
      ensureSheet();
      sheet.hidden = false;
      renderSheet();
      sheet.scrollIntoView({ behavior: 'smooth', block: 'start' });
      closeMenu();
    });
  }
  document.addEventListener('keydown', (event) => {
    if (event.code !== 'Space') return;
    const tag = event.target && event.target.tagName;
    if (tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT' || tag === 'BUTTON' || tag === 'A') return;
    if (event.target && event.target.isContentEditable) return;
    if (!notes.length) return;
    event.preventDefault();
    togglePlay();
  });
})();
