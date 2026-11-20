/* Hop page: build a chord by counting every key. */
const COPY = {
  en: { frame: n => `frame ${n}`, same: ' · the same for major and minor' },
  ru: { frame: n => `рамка ${n}`, same: ' · одинаковая у мажора и минора' },
  de: { frame: n => `Rahmen ${n}`, same: ' · gleich bei Dur und Moll' },
};
const T = COPY[MN.LANG] || COPY.en;
const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

const svg = document.getElementById('kb');
const TOP = 100, H = 180, W = 48;
const kb = MN.keyboard(svg, { W, H, top: TOP, bottom: 70, whites: 14, onKey: m => { setRoot(m); animate(); } });
const arcsG = MN.el('g', {}, svg);
const countsG = MN.el('g', {}, svg);
const frameG = MN.el('g', { class: 'frame' }, svg);
const ROLEC = { t: 'var(--c-t)', f: 'var(--c-f)', s: 'var(--c-s)' };

let rootMidi = 60, type = 'maj', tok = 0;
function current() {
  const max = MN.TYPES[type].iv.at(-1)[1];
  let base = rootMidi;
  if (base + max > 83) base -= 12;
  return MN.chord(MN.rootFor(base % 12, type), type, base);
}
function setRoot(m) { rootMidi = m; }

function arc(from, to, role, animateIt) {
  const x1 = kb.keys[from].cx, x2 = kb.keys[to].cx, gap = to - from;
  const y = TOP - 30, h = 26 + gap * 9;
  MN.el('path', { d: `M${x1} ${y} C${x1} ${y - h}, ${x2} ${y - h}, ${x2} ${y}`, class: 'arc' + (animateIt ? ' draw' : ''), stroke: ROLEC[role] }, arcsG);
  const g = MN.el('g', { class: 'arc-label', transform: `translate(${(x1 + x2) / 2},${y - h * 0.75})` }, arcsG);
  MN.el('circle', { r: 15, fill: ROLEC[role] }, g);
  MN.el('text', { y: 6 }, g).textContent = gap;
  MN.el('circle', { cx: x2, cy: y, r: 4, fill: ROLEC[role] }, arcsG);
}
function frame(c) {
  frameG.innerHTML = '';
  const a = kb.keys[c.notes[0].midi], b = kb.keys[c.notes[2].midi];
  const y = TOP + H + 14;
  MN.el('path', { d: `M${a.cx} ${y - 8} V${y} H${b.cx} V${y - 8}` }, frameG);
  const n = c.notes[2].semi;
  const same = (type === 'maj' || type === 'min') ? T.same : '';
  MN.el('text', a.cx < 340 ? { x: Math.max(4, a.cx - 10), y: y + 22, 'text-anchor': 'start' } : { x: b.cx + 10, y: y + 22, 'text-anchor': 'end' }, frameG)
    .textContent = T.frame(n) + same;
}
function readout(c) {
  document.getElementById('name').textContent = c.name;
  const gaps = c.notes.slice(1).map((n, i) => n.semi - c.notes[i].semi);
  document.getElementById('formula').innerHTML = gaps.map((g, i) => `<span style="color:${ROLEC[c.notes[i + 1].role]}">${g}</span>`).join(' + ');
  document.getElementById('notes').innerHTML = c.notes.map(n => `<span class="note-chip ${n.role}">${MN.noteLabel(n)}</span>`).join('');
}
function render() {
  tok++;
  const c = current();
  readout(c);
  arcsG.innerHTML = '';
  countsG.innerHTML = '';
  kb.show(c.notes, { fingers: true });
  for (let i = 1; i < c.notes.length; i++) arc(c.notes[i - 1].midi, c.notes[i].midi, c.notes[i].role, false);
  frame(c);
}
async function animate() {
  if (reduceMotion) {
    render();
    MN.play(current().notes.map(n => n.midi), { arp: false });
    return;
  }
  const my = ++tok;
  const c = current();
  readout(c);
  arcsG.innerHTML = '';
  countsG.innerHTML = '';
  frameG.innerHTML = '';
  let shown = [c.notes[0]];
  kb.show(shown);
  MN.tick(c.notes[0].midi);
  await MN.sleep(450);
  for (let i = 1; i < c.notes.length; i++) {
    countsG.innerHTML = '';
    const from = c.notes[i - 1].midi, to = c.notes[i].midi;
    for (let k = 1; k <= to - from; k++) {
      if (my !== tok) return;
      const key = kb.keys[from + k];
      kb.show(shown);
      if (k < to - from) key.rect.classList.add('step');
      const g = MN.el('g', { class: 'count', transform: `translate(${key.cx},${TOP - 12})` }, countsG);
      MN.el('circle', { r: 10 }, g);
      MN.el('text', { y: 4 }, g).textContent = k;
      MN.tick(from + k);
      await MN.sleep(320);
    }
    if (my !== tok) return;
    shown = c.notes.slice(0, i + 1);
    kb.show(shown);
    arc(from, to, c.notes[i].role, true);
    await MN.sleep(420);
  }
  if (my !== tok) return;
  countsG.innerHTML = '';
  kb.show(c.notes, { fingers: true });
  frame(c);
  MN.play(c.notes.map(n => n.midi), { arp: false });
}

document.getElementById('types').addEventListener('click', e => {
  const b = e.target.closest('.type');
  if (!b) return;
  type = b.dataset.t;
  document.querySelectorAll('.type').forEach(x => x.classList.toggle('on', x === b));
  animate();
});
document.getElementById('btnAnim').onclick = animate;
document.getElementById('btnPlay').onclick = () => MN.play(current().notes.map(n => n.midi));
document.getElementById('btnFlip').onclick = () => {
  if (type !== 'maj' && type !== 'min') type = 'maj';
  const next = type === 'maj' ? 'min' : 'maj';
  render();
  const marker = kb.gM.querySelector('[data-role="t"]');
  const oldC = current();
  type = next;
  document.querySelectorAll('.type').forEach(x => x.classList.toggle('on', x.dataset.t === type));
  const newC = current();
  if (marker && newC.notes[0].midi === oldC.notes[0].midi && !reduceMotion) {
    const k0 = kb.keys[oldC.notes[1].midi], k1 = kb.keys[newC.notes[1].midi];
    marker.removeAttribute('transform');
    marker.style.transform = `translate(${k0.cx}px, ${kb.markerY(k0)}px)`;
    marker.getBoundingClientRect();
    marker.classList.add('slide');
    marker.style.transform = `translate(${k1.cx}px, ${kb.markerY(k1)}px)`;
    const myTok = tok;
    setTimeout(() => { if (tok !== myTok) return; render(); MN.play(newC.notes.map(n => n.midi), { arp: false }); }, 520);
  } else {
    render();
    MN.play(newC.notes.map(n => n.midi), { arp: false });
  }
};
document.addEventListener('notation', () => { kb.relabel(); render(); });
render();
