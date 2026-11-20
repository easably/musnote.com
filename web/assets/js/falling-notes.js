/* Falling notes: bars drop onto piano keys.
 * rangeForMidis, keyLayout and barsAtTime do not touch the page.
 * The same numbers are in vocal_note_monitor/lib/models/falling_notes.dart.
 * Keep both copies in step, including the three width ratios below.
 */
const FallingNotes = (() => {
  const LETTERS = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
  const BLACK = new Set([1, 3, 6, 8, 10]);
  const NS = 'http://www.w3.org/2000/svg';

  /* Widths are fractions of one white key. A black key sits in the crack. */
  const BLACK_KEY_WIDTH = 0.6;
  const WHITE_BAR_WIDTH = 0.72;
  const BLACK_BAR_WIDTH = 0.48;

  function isBlack(midi) {
    return BLACK.has(((midi % 12) + 12) % 12);
  }

  function letterForMidi(midi) {
    return LETTERS[((midi % 12) + 12) % 12];
  }

  /* First white key, and how many white keys to draw. */
  function rangeForMidis(midis, opts = {}) {
    const pad = opts.pad == null ? 2 : opts.pad;
    const minWhites = opts.minWhites == null ? 8 : opts.minWhites;
    const maxWhites = opts.maxWhites == null ? 24 : opts.maxWhites;
    const lowest = opts.lowest == null ? 21 : opts.lowest;
    const highest = opts.highest == null ? 108 : opts.highest;
    let lo = 48;
    let hi = 72;
    const list = midis || [];
    if (list.length) {
      lo = Math.min.apply(null, list);
      hi = Math.max.apply(null, list);
      lo = Math.max(lowest, lo - pad);
      hi = Math.min(highest, hi + pad);
      if (hi < lo) hi = lo;
    }
    let start = lo;
    while (isBlack(start) && start > 0) start--;
    let whites = 0;
    let midi = start;
    while (midi <= hi && whites < maxWhites) {
      if (!isBlack(midi)) whites++;
      midi++;
    }
    while (whites < minWhites && midi < 128) {
      if (!isBlack(midi)) whites++;
      midi++;
    }
    return { start, whites };
  }

  /* Center of each key, measured in white-key widths from the left. */
  function keyLayout(start, whites) {
    const keys = [];
    let whiteIndex = 0;
    let midi = start;
    while (whiteIndex < whites) {
      if (isBlack(midi)) {
        keys.push({ midi, black: true, centerWhites: whiteIndex, widthWhites: BLACK_KEY_WIDTH });
      } else {
        keys.push({ midi, black: false, centerWhites: whiteIndex + 0.5, widthWhites: 1 });
        whiteIndex++;
      }
      midi++;
    }
    return keys;
  }

  /* Bars visible above the keys at this moment. y grows downward; the bottom of the lane is now. */
  function barsAtTime(notes, time, opts) {
    const lookAhead = opts.lookAhead;
    const laneHeight = opts.laneHeight;
    const whiteKeyWidth = opts.whiteKeyWidth;
    const pixelsPerSecond = laneHeight / lookAhead;
    const byMidi = {};
    (opts.keys || []).forEach((key) => { byMidi[key.midi] = key; });
    const out = [];
    (notes || []).forEach((note) => {
      if (note.end <= time) return;
      if (note.start >= time + lookAhead) return;
      const key = byMidi[note.midi];
      if (!key) return;
      const bottom = laneHeight - (note.start - time) * pixelsPerSecond;
      const top = laneHeight - (note.end - time) * pixelsPerSecond;
      const y = Math.max(0, top);
      const y1 = Math.min(laneHeight, bottom);
      const height = y1 - y;
      if (height < 0.5) return;
      const width = (key.black ? BLACK_BAR_WIDTH : WHITE_BAR_WIDTH) * whiteKeyWidth;
      out.push({
        midi: note.midi,
        x: key.centerWhites * whiteKeyWidth - width / 2,
        y,
        width,
        height,
        label: letterForMidi(note.midi),
        active: note.start <= time && time < note.end,
        black: key.black,
      });
    });
    return out;
  }

  function el(tag, attrs, parent) {
    const node = document.createElementNS(NS, tag);
    Object.keys(attrs).forEach((name) => node.setAttribute(name, attrs[name]));
    if (parent) parent.appendChild(node);
    return node;
  }

  /* Draws the lane above an existing keyboard svg from MN.keyboard. */
  function mount(keyboardSvg, opts = {}) {
    const lookAhead = opts.lookAhead == null ? 4 : opts.lookAhead;
    const laneHeight = opts.laneHeight == null ? 220 : opts.laneHeight;
    const lane = document.createElementNS(NS, 'svg');
    lane.setAttribute('class', 'falling-notes');
    lane.setAttribute('aria-hidden', 'true');
    keyboardSvg.before(lane);

    let keys = [];
    let notes = [];
    let time = 0;
    let whiteKeyWidth = 44;

    function draw() {
      lane.replaceChildren();
      if (!notes.length || !keys.length) {
        lane.hidden = true;
        return;
      }
      lane.hidden = false;
      const width = whiteKeyWidth * keys.filter((key) => !key.black).length;
      lane.setAttribute('viewBox', '0 0 ' + width + ' ' + laneHeight);
      el('line', {
        x1: 0, x2: width, y1: laneHeight - 1, y2: laneHeight - 1,
        class: 'hit',
      }, lane);
      barsAtTime(notes, time, { lookAhead, laneHeight, whiteKeyWidth, keys }).forEach((bar) => {
        let y = bar.y;
        let height = bar.height;
        if (height < 4) {
          y = Math.max(0, y - (4 - height));
          height = Math.min(laneHeight - y, 4);
        }
        el('rect', {
          x: bar.x,
          y,
          width: bar.width,
          height,
          rx: Math.min(4, bar.width / 2),
          class: bar.active ? 'bar on' : 'bar',
        }, lane);
        if (height >= 16) {
          const text = el('text', {
            x: bar.x + bar.width / 2,
            y: y + height / 2 + 4,
            class: 'bar-label',
          }, lane);
          text.textContent = bar.label;
        }
      });
    }

    return {
      setLayout(start, whites, nextWhiteKeyWidth) {
        keys = keyLayout(start, whites);
        whiteKeyWidth = nextWhiteKeyWidth || 44;
        draw();
      },
      setNotes(list) {
        notes = list || [];
        draw();
      },
      setTime(next) {
        time = next || 0;
        draw();
      },
    };
  }

  return { isBlack, letterForMidi, rangeForMidis, keyLayout, barsAtTime, mount };
})();

if (typeof module !== 'undefined' && module.exports) module.exports = FallingNotes;
if (typeof window !== 'undefined') window.FallingNotes = FallingNotes;
