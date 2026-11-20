/* node scripts/check-notes-export.js */
const assert = require('assert');
const ex = require('../web/assets/js/notes-export.js');

function parseMidi(bytes) {
  assert.strictEqual(Buffer.from(bytes.slice(0, 4)).toString(), 'MThd');
  const format = (bytes[8] << 8) | bytes[9];
  const tracks = (bytes[10] << 8) | bytes[11];
  const div = (bytes[12] << 8) | bytes[13];
  assert.strictEqual(format, 0);
  assert.strictEqual(tracks, 1);
  assert.strictEqual(div, 480);
  let i = 14;
  assert.strictEqual(Buffer.from(bytes.slice(i, i + 4)).toString(), 'MTrk');
  i += 8;
  const events = [];
  let tick = 0;
  while (i < bytes.length) {
    let v = 0;
    let b;
    do {
      b = bytes[i++];
      v = (v << 7) | (b & 0x7f);
    } while (b & 0x80);
    tick += v;
    const status = bytes[i++];
    if (status === 0xff) {
      const type = bytes[i++];
      let len = 0;
      do {
        b = bytes[i++];
        len = (len << 7) | (b & 0x7f);
      } while (b & 0x80);
      const data = bytes.slice(i, i + len);
      i += len;
      events.push({ tick, meta: type, data });
      if (type === 0x2f) break;
    } else if ((status & 0xf0) === 0xc0 || (status & 0xf0) === 0xd0) {
      events.push({ tick, status, d1: bytes[i++] });
    } else {
      events.push({ tick, status, d1: bytes[i++], d2: bytes[i++] });
    }
  }
  return events;
}

const notes = [
  { midi: 60, start: 0, end: 0.5, velocity: 1 },
  { midi: 64, start: 1, end: 1.25, velocity: 0.5 },
];
const events = parseMidi(ex.encodeMidi(notes));
const ons = events.filter((e) => e.status === 0x90);
const offs = events.filter((e) => e.status === 0x80);
assert.strictEqual(ons.length, notes.length);
assert.strictEqual(offs.length, notes.length);
assert.deepStrictEqual(ons.map((e) => e.d1), [60, 64]);
assert.deepStrictEqual(ons.map((e) => e.tick), [0, 960]);
assert.strictEqual(ons[0].d2, 127);
assert.strictEqual(ons[1].d2, 64);
assert.strictEqual(offs[0].tick, 480);
assert.ok(events.some((e) => e.meta === 0x51));
assert.ok(events.some((e) => e.status === 0xc0 && e.d1 === 0));
assert.strictEqual(events[events.length - 1].meta, 0x2f);
assert.strictEqual(ex.midiVelocity(0), 1);

const quiet = ex.encodeMidi([{ midi: 60, start: 0, end: 0, velocity: 0 }]);
const quietOn = parseMidi(quiet).find((e) => e.status === 0x90);
assert.strictEqual(quietOn.d2, 1);
assert.ok(parseMidi(quiet).find((e) => e.status === 0x80).tick >= 1);

const text = ex.notesText([
  { midi: 60, start: 0, end: 0.2 },
  { midi: 64, start: 0.02, end: 0.2 },
  { midi: 67, start: 1.0, end: 1.2 },
], { octave: false, solfege: false });
assert.strictEqual(text, '[C E]\nG');

const oct = ex.notesText([
  { midi: 60, start: 0, end: 0.2 },
  { midi: 64, start: 0.02, end: 0.2 },
  { midi: 67, start: 1.0, end: 1.2 },
], { octave: true, solfege: false });
assert.strictEqual(oct, '[C4 E4]\nG4');

const ru = ex.notesText([
  { midi: 60, start: 0, end: 0.2 },
  { midi: 64, start: 0.01, end: 0.2 },
  { midi: 67, start: 1.0, end: 1.2 },
], { octave: false, solfege: true, lang: 'ru' });
assert.strictEqual(ru, '[До Ми]\nСоль');

const half = ex.scheduleSlice([
  { midi: 60, start: 0, end: 1, velocity: 1 },
], 0, 0.5);
assert.strictEqual(half.length, 1);
assert.strictEqual(half[0].delay, 0);
assert.ok(Math.abs(half[0].duration - 2) < 1e-9);

const later = ex.scheduleSlice([
  { midi: 60, start: 1, end: 1.2, velocity: 1 },
], 0, 1);
assert.strictEqual(later.length, 0);

const mid = ex.scheduleSlice([
  { midi: 60, start: 0.1, end: 0.3, velocity: 1 },
], 0.2, 1);
assert.strictEqual(mid.length, 1);
assert.strictEqual(mid[0].delay, 0);
assert.ok(Math.abs(mid[0].duration - 0.1) < 1e-9);

assert.strictEqual(ex.downloadName('Песня.mp3', 'mid'), 'Песня-musnote.mid');
assert.ok(ex.SOLFEGE_LANGS.has('ru') && ex.SOLFEGE_LANGS.has('pl'));
assert.ok(!ex.SOLFEGE_LANGS.has('en') && !ex.SOLFEGE_LANGS.has('de') && !ex.SOLFEGE_LANGS.has('ja'));

console.log('notes-export ok');
