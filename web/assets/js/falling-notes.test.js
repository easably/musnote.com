const assert = require('assert');
const FallingNotes = require('./falling-notes.js');

const range = FallingNotes.rangeForMidis([61, 72]);
assert.strictEqual(range.start % 12 === 1 || range.start % 12 === 3 || range.start % 12 === 6 || range.start % 12 === 8 || range.start % 12 === 10, false);
assert.ok(range.start <= 61);
assert.ok(range.whites >= 8 && range.whites <= 24);
const whites = FallingNotes.keyLayout(range.start, range.whites).filter((key) => !key.black);
assert.ok(whites[whites.length - 1].midi >= 72);

const keys = FallingNotes.keyLayout(60, 2);
assert.deepStrictEqual(keys.map((key) => [key.midi, key.centerWhites]), [
  [60, 0.5],
  [61, 1],
  [62, 1.5],
]);

const layout = { lookAhead: 4, laneHeight: 200, whiteKeyWidth: 40, keys: FallingNotes.keyLayout(60, 1) };
const bars = FallingNotes.barsAtTime([{ midi: 60, start: 1, end: 2 }], 0, layout);
assert.strictEqual(bars.length, 1);
assert.strictEqual(bars[0].label, 'C');
assert.strictEqual(bars[0].active, false);
assert.ok(Math.abs(bars[0].y - 100) < 0.001);
assert.ok(Math.abs(bars[0].height - 50) < 0.001);
assert.ok(Math.abs(bars[0].x - 5.6) < 0.001);

const held = FallingNotes.barsAtTime([{ midi: 60, start: 1, end: 2 }], 1.5, layout);
assert.strictEqual(held[0].active, true);
assert.ok(Math.abs(held[0].y - 175) < 0.001);
assert.ok(Math.abs(held[0].height - 25) < 0.001);

const gone = FallingNotes.barsAtTime([{ midi: 60, start: 0, end: 1 }], 1, layout);
assert.strictEqual(gone.length, 0);

console.log('falling-notes ok');
