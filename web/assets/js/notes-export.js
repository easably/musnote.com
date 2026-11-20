/* MIDI, letter-note text, and the player lookahead. No UI. */
(function (root, factory) {
  const api = factory();
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else root.MusnoteExport = api;
})(typeof globalThis !== 'undefined' ? globalThis : this, function () {
  const LETTERS = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
  const SOLFEGE = {
    ru: ['До', 'До#', 'Ре', 'Ре#', 'Ми', 'Фа', 'Фа#', 'Соль', 'Соль#', 'Ля', 'Ля#', 'Си'],
    es: ['Do', 'Do#', 'Re', 'Re#', 'Mi', 'Fa', 'Fa#', 'Sol', 'Sol#', 'La', 'La#', 'Si'],
    pt: ['Dó', 'Dó#', 'Ré', 'Ré#', 'Mi', 'Fá', 'Fá#', 'Sol', 'Sol#', 'Lá', 'Lá#', 'Si'],
    pl: ['Do', 'Do#', 'Re', 'Re#', 'Mi', 'Fa', 'Fa#', 'Sol', 'Sol#', 'La', 'La#', 'Si'],
  };
  const SOLFEGE_LANGS = new Set(['ru', 'es', 'pt', 'pl']);
  const TPQ = 480;
  const TICKS_PER_SEC = 960;

  function pitchName(midi, opts) {
    const pc = ((midi % 12) + 12) % 12;
    const useSolfege = opts && opts.solfege && SOLFEGE[opts.lang];
    const name = useSolfege ? SOLFEGE[opts.lang][pc] : LETTERS[pc];
    if (opts && opts.octave) return name + (Math.floor(midi / 12) - 1);
    return name;
  }

  function phrases(notes) {
    const list = notes.slice().sort((a, b) => a.start - b.start || a.midi - b.midi);
    const out = [];
    let phrase = [];
    let phraseEnd = -Infinity;
    list.forEach((n) => {
      if (phrase.length && n.start - phraseEnd > 0.6) {
        out.push(phrase);
        phrase = [];
        phraseEnd = -Infinity;
      }
      phrase.push(n);
      phraseEnd = Math.max(phraseEnd, n.end);
    });
    if (phrase.length) out.push(phrase);
    return out;
  }

  function tokens(phrase) {
    const groups = [];
    phrase.forEach((n) => {
      const g = groups[groups.length - 1];
      if (!g || n.start - g[0].start > 0.04) groups.push([n]);
      else g.push(n);
    });
    return groups;
  }

  function notesText(notes, opts) {
    return phrases(notes).map((phrase) => tokens(phrase).map((group) => {
      const names = group.slice().sort((a, b) => a.midi - b.midi).map((n) => pitchName(n.midi, opts));
      return names.length > 1 ? '[' + names.join(' ') + ']' : names[0];
    }).join(' ')).join('\n');
  }

  function writeVarLen(n) {
    const bytes = [n & 0x7f];
    n >>= 7;
    while (n > 0) {
      bytes.unshift((n & 0x7f) | 0x80);
      n >>= 7;
    }
    return bytes;
  }

  function midiVelocity(v) {
    const x = v == null || Number.isNaN(Number(v)) ? 0.8 : Number(v);
    let vel = Math.round(Math.max(0, Math.min(1, x)) * 127);
    if (vel < 1) vel = 1;
    if (vel > 127) vel = 127;
    return vel;
  }

  function encodeMidi(notes) {
    const events = [];
    notes.forEach((n) => {
      const on = Math.max(0, Math.round(Number(n.start) * TICKS_PER_SEC));
      let off = Math.max(0, Math.round(Number(n.end) * TICKS_PER_SEC));
      if (off <= on) off = on + 1;
      const midi = Math.max(0, Math.min(127, n.midi | 0));
      const vel = midiVelocity(n.velocity);
      events.push({ t: on, order: 1, bytes: [0x90, midi, vel] });
      events.push({ t: off, order: 0, bytes: [0x80, midi, 0] });
    });
    events.sort((a, b) => a.t - b.t || a.order - b.order);

    const track = [0x00, 0xff, 0x51, 0x03, 0x07, 0xa1, 0x20, 0x00, 0xc0, 0x00];
    let last = 0;
    events.forEach((e) => {
      writeVarLen(e.t - last).forEach((b) => track.push(b));
      e.bytes.forEach((b) => track.push(b));
      last = e.t;
    });
    track.push(0x00, 0xff, 0x2f, 0x00);

    const len = track.length;
    const bytes = [
      0x4d, 0x54, 0x68, 0x64,
      0x00, 0x00, 0x00, 0x06,
      0x00, 0x00,
      0x00, 0x01,
      (TPQ >> 8) & 0xff, TPQ & 0xff,
      0x4d, 0x54, 0x72, 0x6b,
      (len >> 24) & 0xff, (len >> 16) & 0xff, (len >> 8) & 0xff, len & 0xff,
    ];
    track.forEach((b) => bytes.push(b));
    return Uint8Array.from(bytes);
  }

  function volumeFor(v) {
    const x = v == null || Number.isNaN(Number(v)) ? 0.7 : Number(v);
    return 0.02 + Math.max(0, Math.min(1, x)) * 0.12;
  }

  /* Notes that should be armed in the next ~200 ms of wall-clock time. */
  function scheduleSlice(notes, recNow, speed, lookaheadWall) {
    const wall = lookaheadWall == null ? 0.2 : lookaheadWall;
    const rate = speed > 0 ? speed : 1;
    const horizon = recNow + wall * rate;
    const out = [];
    notes.forEach((n) => {
      if (!(n.end > recNow + 0.0005)) return;
      if (n.start > horizon) return;
      const startAt = Math.max(n.start, recNow);
      out.push({
        note: n,
        delay: (startAt - recNow) / rate,
        duration: Math.max(0.02, (n.end - startAt) / rate),
        volume: volumeFor(n.velocity),
      });
    });
    return out;
  }

  function downloadName(filename, ext) {
    const base = String(filename || 'audio').split(/[/\\]/).pop().replace(/\.[^.]+$/, '') || 'audio';
    return base + '-musnote.' + ext;
  }

  return {
    LETTERS,
    SOLFEGE,
    SOLFEGE_LANGS,
    pitchName,
    phrases,
    notesText,
    encodeMidi,
    midiVelocity,
    scheduleSlice,
    downloadName,
  };
});
