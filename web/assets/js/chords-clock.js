/* Clock page: one shape, twelve chords. */
const COPY = {
  en: {
    sub: { maj: 'major — triangle 4·3·5', min: 'minor — triangle 3·4·5', dom7: 'seventh — quadrilateral 4·3·3·2' },
    tour: '▶ Turn around the circle of fifths',
    stop: '■ Stop',
  },
  ru: {
    sub: { maj: 'мажор — треугольник 4·3·5', min: 'минор — треугольник 3·4·5', dom7: 'септаккорд — четырёхугольник 4·3·3·2' },
    tour: '▶ Покрутить по кругу квинт',
    stop: '■ Стоп',
  },
  de: {
    sub: { maj: 'Dur — Dreieck 4·3·5', min: 'Moll — Dreieck 3·4·5', dom7: 'Septakkord — Viereck 4·3·3·2' },
    tour: '▶ Quintenzirkel drehen',
    stop: '■ Stopp',
  },
};
const T = COPY[MN.LANG] || COPY.en;
const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

const svg = document.getElementById('clock');
const CX = 220, CY = 220, R = 148, RA = R + 34;
const PC_NAMES = [['C', 0], ['C', 1], ['D', 0], ['E', -1], ['E', 0], ['F', 0], ['F', 1], ['G', 0], ['A', -1], ['A', 0], ['B', -1], ['B', 0]];
const ROLE = ['r', 't', 'f', 's'];
const RC = { r: 'var(--c-r)', t: 'var(--c-t)', f: 'var(--c-f)', s: 'var(--c-s)' };
const SHAPES = { maj: [0, 4, 7, 7], min: [0, 3, 7, 7], dom7: [0, 4, 7, 10] };
const ang = h => ((-90 + h * 30) * Math.PI) / 180;
const pos = (h, r) => [CX + r * Math.cos(ang(h)), CY + r * Math.sin(ang(h))];

const ticks = MN.el('g', { class: 'ticks' }, svg);
for (let i = 0; i < 12; i++) {
  const [x1, y1] = pos(i + .5, R - 30), [x2, y2] = pos(i + .5, R + 30);
  MN.el('line', { x1, y1, x2, y2 }, ticks);
}
const arcsG = MN.el('g', {}, svg);
const poly = MN.el('polygon', { class: 'poly' }, svg);
const nodesG = MN.el('g', {}, svg);
const ringsG = MN.el('g', {}, svg);
const centerName = MN.el('text', { x: CX, y: CY + 10, class: 'center-name' }, svg);
const centerSub = MN.el('text', { x: CX, y: CY + 36, class: 'center-sub' }, svg);
const rings = ROLE.map(r => MN.el('circle', { class: 'ring', r: 29, stroke: RC[r] }, ringsG));

const nodeTexts = [];
PC_NAMES.forEach(([L, a], i) => {
  const [x, y] = pos(i, R);
  const g = MN.el('g', { class: 'node ' + (a ? 'b' : 'w'), transform: `translate(${x},${y})` }, nodesG);
  MN.el('circle', { r: 22 }, g);
  const t = MN.el('text', { y: 5 }, g);
  nodeTexts.push([t, L, a]);
  g.addEventListener('click', () => setRoot(i));
});
function relabelNodes() {
  nodeTexts.forEach(([t, L, a]) => {
    const s = MN.letterLabel(L) + MN.ACC[a];
    t.textContent = s;
    t.setAttribute('font-size', s.length > 3 ? 10 : s.length > 2 ? 12 : 15);
  });
}

let type = 'maj', rootT = 0, rootH = 0, offs = [...SHAPES.maj], offsT = [...SHAPES.maj], running = false;
const pcNow = () => ((rootT % 12) + 12) % 12;

function arcPath(a, b) {
  const [x1, y1] = pos(a, RA), [x2, y2] = pos(b, RA);
  return `M${x1} ${y1} A${RA} ${RA} 0 ${b - a > 6 ? 1 : 0} 1 ${x2} ${y2}`;
}
function draw() {
  const pts = offs.map(o => pos(rootH + o, R));
  poly.setAttribute('points', pts.map(p => p.join(',')).join(' '));
  poly.style.stroke = type === 'min' ? 'var(--c-t)' : 'var(--mn-ink)';
  pts.forEach(([x, y], i) => { rings[i].setAttribute('cx', x); rings[i].setAttribute('cy', y); });
  rings[3].style.opacity = Math.min(1, Math.max(0, (offs[3] - offs[2]) / 2));
  arcsG.innerHTML = '';
  for (let i = 0; i < 4; i++) {
    const a = offs[i], b = i < 3 ? offs[i + 1] : offs[0] + 12;
    const tLen = (i < 3 ? offsT[i + 1] : offsT[0] + 12) - offsT[i];
    if (b - a < 0.15 || tLen === 0) continue;
    const col = ['var(--c-t)', 'var(--c-f)', 'var(--c-s)', '#b3c3bc'][i];
    MN.el('path', { d: arcPath(rootH + a + .25, rootH + b - .25), class: 'oarc', stroke: col }, arcsG);
    const [lx, ly] = pos(rootH + (a + b) / 2, RA + 18);
    const label = MN.el('text', { x: lx, y: ly + 6, class: 'olabel', fill: col }, arcsG);
    label.textContent = tLen;
  }
}
function loop() {
  let moving = false;
  const step = (cur, tgt) => {
    if (reduceMotion) return tgt;
    const n = cur + (tgt - cur) * 0.16;
    if (Math.abs(tgt - n) > 0.002) { moving = true; return n; }
    return tgt;
  };
  rootH = step(rootH, rootT);
  offs = offs.map((o, i) => step(o, offsT[i]));
  draw();
  if (moving) requestAnimationFrame(loop); else running = false;
}
const kick = () => { if (!running) { running = true; requestAnimationFrame(loop); } };

const kb = MN.keyboard(document.getElementById('kb'), { whites: 14, W: 50, H: 170 });
function update(sound = true) {
  const c = MN.chord(MN.rootFor(pcNow(), type), type);
  centerName.textContent = c.name;
  centerSub.textContent = MN.TYPES[type].label;
  document.getElementById('name').textContent = c.name;
  document.getElementById('sub').textContent = T.sub[type];
  document.getElementById('dots').innerHTML = MN.dots(c.pattern, true);
  document.getElementById('notes').innerHTML = c.notes.map(n => `<span class="note-chip ${n.role}">${MN.noteLabel(n)}</span>`).join('');
  kb.show(c.notes, { fingers: true });
  if (sound) MN.play(c.notes.map(n => n.midi), { arp: false });
}
function setRoot(pc, sound = true) {
  const d = ((((pc - pcNow()) % 12) + 18) % 12) - 6;
  rootT += d;
  kick();
  update(sound);
}
function setType(t) {
  type = t;
  offsT = [...SHAPES[t]];
  document.querySelectorAll('#types button').forEach(b => b.classList.toggle('on', b.dataset.t === t));
  kick();
  update();
}
document.getElementById('types').addEventListener('click', e => { const b = e.target.closest('button'); if (b) setType(b.dataset.t); });
document.getElementById('cw').onclick = () => setRoot(pcNow() + 1);
document.getElementById('ccw').onclick = () => setRoot(pcNow() + 11);
document.getElementById('play').onclick = () => MN.play(MN.chord(MN.rootFor(pcNow(), type), type).notes.map(n => n.midi));
document.addEventListener('keydown', e => {
  if (e.target.closest('input, select, textarea')) return;
  if (e.key === 'ArrowRight') { setRoot(pcNow() + 1); e.preventDefault(); }
  if (e.key === 'ArrowLeft') { setRoot(pcNow() + 11); e.preventDefault(); }
});
let tourTimer = null;
const tourBtn = document.getElementById('tour');
tourBtn.textContent = T.tour;
tourBtn.onclick = () => {
  if (tourTimer) { clearInterval(tourTimer); tourTimer = null; tourBtn.textContent = T.tour; return; }
  tourBtn.textContent = T.stop;
  let n = 0;
  tourTimer = setInterval(() => {
    setRoot(pcNow() + 7);
    if (++n >= 12) { clearInterval(tourTimer); tourTimer = null; tourBtn.textContent = T.tour; }
  }, 1300);
};
document.addEventListener('notation', () => { relabelNodes(); kb.relabel(); update(false); });
relabelNodes();
draw();
update(false);
