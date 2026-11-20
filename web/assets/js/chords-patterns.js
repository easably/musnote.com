/* Patterns page: two tabs. Theory is CFG / iDEA. Trainer is the “which pattern?” quiz. */
const COPY = {
  en: {
    majMood: 'major — bright sound',
    minMood: 'minor — darker sound',
    pname: { www: 'All white', wbw: 'Black in the middle', bwb: 'White in the middle', bbb: 'Special pattern', wbb: 'Special pattern', bww: 'Special pattern', wwb: 'Special pattern', bbw: 'Special pattern' },
    caps: { maj: ['all white', 'black in the middle', '= iDEA, one semitone down'], min: ['black in the middle', 'all white', '= CFG, one semitone up'] },
    skel: (skel) => `Skip one letter: <b>${skel}</b>`,
    changed: (dots, list) => `Pattern ${dots}: ${list}`,
    same: (dots) => `Pattern ${dots}: leave every key white`,
    becomes: (from, to) => `<b>${from}</b> becomes <b>${to}</b>`,
    toMin: '⇄ To minor',
    toMaj: '⇄ To major',
    ok: 'Right. ',
    bad: 'Not quite. ',
    family: (name, dots) => `${name} is in the B family. Just remember ${dots}.`,
    trio: (name, kind, group, dots) => `${name}: ${kind} in ${group} → ${dots}`,
    down: (name, L, dots) => `${name} is ${L} from iDEA, moved down onto a black key → ${dots}`,
    up: (name, L, dots) => `${name} is ${L}m from CFG, moved up onto a black key → ${dots}`,
    major: 'major',
    minor: 'minor',
  },
  ru: {
    majMood: 'мажор — светлое звучание',
    minMood: 'минор — грустное звучание',
    pname: { www: 'Все белые', wbw: 'Чёрная в середине', bwb: 'Белая в середине', bbb: 'Особый узор', wbb: 'Особый узор', bww: 'Особый узор', wwb: 'Особый узор', bbw: 'Особый узор' },
    caps: { maj: ['все белые', 'чёрная в середине', '= iDEA на полутон ниже'], min: ['чёрная в середине', 'все белые', '= CFG на полутон выше'] },
    skel: (skel) => `Скелет через одну букву: <b>${skel}</b>`,
    changed: (dots, list) => `Узор ${dots}: ${list}`,
    same: (dots) => `Узор ${dots}: ничего не меняем, только белые`,
    becomes: (from, to) => `<b>${from}</b> становится <b>${to}</b>`,
    toMin: '⇄ В минор',
    toMaj: '⇄ В мажор',
    ok: 'Верно. ',
    bad: 'Не совсем. ',
    family: (name, dots) => `${name} — из семьи B, его узор ${dots} просто запомни.`,
    trio: (name, kind, group, dots) => `${name}: ${kind} из тройки ${group} → ${dots}`,
    down: (name, L, dots) => `${name} — это ${L} из iDEA, опущенный на чёрную клавишу → ${dots}`,
    up: (name, L, dots) => `${name} — это ${L}m из CFG, поднятый на чёрную клавишу → ${dots}`,
    major: 'мажор',
    minor: 'минор',
  },
  de: {
    majMood: 'Dur — heller Klang',
    minMood: 'Moll — dunklerer Klang',
    pname: { www: 'Alles weiß', wbw: 'Schwarz in der Mitte', bwb: 'Weiß in der Mitte', bbb: 'Besonderes Muster', wbb: 'Besonderes Muster', bww: 'Besonderes Muster', wwb: 'Besonderes Muster', bbw: 'Besonderes Muster' },
    caps: { maj: ['alles weiß', 'schwarz in der Mitte', '= iDEA, einen Halbton tiefer'], min: ['schwarz in der Mitte', 'alles weiß', '= CFG, einen Halbton höher'] },
    skel: (skel) => `Einen Buchstaben überspringen: <b>${skel}</b>`,
    changed: (dots, list) => `Muster ${dots}: ${list}`,
    same: (dots) => `Muster ${dots}: alles bleibt weiß`,
    becomes: (from, to) => `<b>${from}</b> wird <b>${to}</b>`,
    toMin: '⇄ Zu Moll',
    toMaj: '⇄ Zu Dur',
    ok: 'Richtig. ',
    bad: 'Noch nicht. ',
    family: (name, dots) => `${name} gehört zur B-Familie. Merk dir ${dots}.`,
    trio: (name, kind, group, dots) => `${name}: ${kind} aus ${group} → ${dots}`,
    down: (name, L, dots) => `${name} ist ${L} aus iDEA, eine schwarze Taste tiefer → ${dots}`,
    up: (name, L, dots) => `${name} ist ${L}m aus CFG, eine schwarze Taste höher → ${dots}`,
    major: 'Dur',
    minor: 'Moll',
  },
};
const T = COPY[MN.LANG] || COPY.en;

const GRID = {
  maj: [
    { col: 'cfg', p: 'www', roots: ['C', 'F', 'G'] },
    { col: 'dea', p: 'wbw', roots: ['D', 'E', 'A'] },
    { col: 'shift', p: 'bwb', roots: ['Db', 'Eb', 'Ab'] },
    { col: 'odd', roots: ['B', 'Bb', 'F#'] },
  ],
  min: [
    { col: 'cfg', p: 'wbw', roots: ['C', 'F', 'G'] },
    { col: 'dea', p: 'www', roots: ['D', 'E', 'A'] },
    { col: 'shift', p: 'bwb', roots: ['C#', 'F#', 'G#'] },
    { col: 'odd', roots: ['B', 'Bb', 'Eb'] },
  ],
};
const cls = p => (['www', 'wbw', 'bwb'].includes(p) ? p : 'odd');

const sheet = document.getElementById('sheet');
const cross = document.getElementById('cross');
const allBtns = [];
function cbtn(root, type) {
  const c = MN.chord(root, type);
  const b = document.createElement('button');
  b.className = 'cbtn';
  b.textContent = c.name;
  b.dataset.root = root;
  b.dataset.type = type;
  b.addEventListener('click', () => select(root, type, true));
  allBtns.push(b);
  return b;
}
['maj', 'min'].forEach((type, ri) => {
  GRID[type].forEach((g, ci) => {
    const cell = document.createElement('div');
    if (g.col === 'odd') {
      cell.className = 'cell odd';
      g.roots.forEach(r => {
        const row = document.createElement('div');
        row.className = 'odd-row';
        row.appendChild(cbtn(r, type));
        row.insertAdjacentHTML('beforeend', MN.dots(MN.chord(r, type).pattern));
        cell.appendChild(row);
      });
    } else {
      cell.className = 'cell p-' + g.p;
      cell.dataset.p = g.p;
      cell.insertAdjacentHTML('beforeend', MN.dots(g.p, true));
      const chips = document.createElement('div');
      chips.className = 'chips';
      g.roots.forEach(r => chips.appendChild(cbtn(r, type)));
      cell.appendChild(chips);
      cell.insertAdjacentHTML('beforeend', `<div class="cap">${T.caps[type][ci]}</div>`);
    }
    if (ci < 2) {
      cell.style.gridColumn = ci + 1;
      cell.style.gridRow = ri + 1;
      cross.appendChild(cell);
    } else {
      cell.style.gridColumn = ci + 2;
      cell.style.gridRow = ri + 2;
      sheet.appendChild(cell);
    }
  });
});
document.querySelectorAll('.cell[data-p]').forEach(cell => {
  cell.addEventListener('mouseenter', () => document.querySelectorAll('.cell').forEach(c => {
    c.classList.toggle('glow', c.dataset.p === cell.dataset.p);
    c.classList.toggle('dim', c.dataset.p !== cell.dataset.p);
  }));
  cell.addEventListener('mouseleave', () => document.querySelectorAll('.cell').forEach(c => c.classList.remove('glow', 'dim')));
});

const kb = MN.keyboard(document.getElementById('kb'), { whites: 14 });
let cur = { root: 'C', type: 'maj' };
function select(root, type, sound) {
  cur = { root, type };
  const c = MN.chord(root, type);
  allBtns.forEach(b => b.classList.toggle('on', b.dataset.root === root && b.dataset.type === type));
  document.getElementById('stName').textContent = c.name;
  document.getElementById('stType').textContent = type === 'maj' ? T.majMood : T.minMood;
  document.getElementById('stDots').innerHTML = MN.dots(c.pattern, true);
  document.getElementById('stPname').textContent = T.pname[c.pattern] || T.pname.bbb;
  const changed = c.notes.filter(n => n.acc !== 0);
  const skel = c.skeleton.map(MN.letterLabel).join(' · ');
  const step2 = changed.length
    ? T.changed(MN.dots(c.pattern), changed.map(n => T.becomes(MN.letterLabel(n.letter), MN.noteLabel(n))).join(', '))
    : T.same(MN.dots(c.pattern));
  document.getElementById('stExplain').innerHTML =
    `<li><span class="num">1</span><span>${T.skel(skel)}</span></li>
     <li><span class="num">2</span><span>${step2}</span></li>`;
  document.getElementById('stNotes').innerHTML = c.notes.map(n => `<span class="note-chip ${n.role}">${MN.noteLabel(n)}</span>`).join('');
  document.getElementById('btnFlip').textContent = type === 'maj' ? T.toMin : T.toMaj;
  kb.show(c.notes, { fingers: true });
  const li = MN.LET.indexOf(root[0]);
  document.getElementById('alpha').innerHTML = [...MN.LET, ...MN.LET].slice(li, li + 7)
    .map((L, i) => `<span class="${i % 2 === 0 && i <= 4 ? 'on' : ''}">${MN.letterLabel(L)}</span>`).join('');
  if (sound) MN.play(c.notes.map(n => n.midi));
}
document.getElementById('btnPlay').onclick = () => MN.play(MN.chord(cur.root, cur.type).notes.map(n => n.midi));
document.getElementById('btnFlip').onclick = () => {
  const pc = MN.chord(cur.root, cur.type).notes[0].midi % 12;
  const t = cur.type === 'maj' ? 'min' : 'maj';
  select(MN.rootFor(pc, t), t, true);
};
select('C', 'maj', false);

const POOL = [];
['C', 'Db', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B'].forEach(r => POOL.push([r, 'maj']));
['C', 'C#', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'G#', 'A', 'Bb', 'B'].forEach(r => POOL.push([r, 'min']));
const qkb = MN.keyboard(document.getElementById('qkb'), { whites: 14, W: 36, H: 130 });
let q, answered = false, streak = 0, best = 0;
function why(root, type) {
  const c = MN.chord(root, type);
  const L = root[0];
  const acc = root.slice(1);
  const kind = type === 'maj' ? T.major : T.minor;
  const dots = MN.dots(c.pattern);
  if (L === 'B' || (root === 'Eb' && type === 'min') || (root === 'F#' && type === 'maj')) return T.family(c.name, dots);
  if (!acc) return T.trio(c.name, kind, 'CFG'.includes(L) ? 'CFG' : 'iDEA', dots);
  return acc === 'b' ? T.down(c.name, L, dots) : T.up(c.name, L, dots);
}
function nextQ() {
  let n;
  do { n = POOL[Math.floor(Math.random() * POOL.length)]; } while (q && n[0] === q[0] && n[1] === q[1]);
  q = n;
  answered = false;
  document.getElementById('qChord').textContent = MN.chord(q[0], q[1]).name;
  document.querySelectorAll('.q-opt').forEach(b => b.classList.remove('right', 'wrong'));
  const fb = document.getElementById('qFb');
  fb.textContent = '';
  fb.className = 'fb';
  qkb.clear();
}
document.getElementById('qOpts').addEventListener('click', e => {
  const b = e.target.closest('.q-opt');
  if (!b || answered) return;
  answered = true;
  const c = MN.chord(q[0], q[1]);
  const right = cls(c.pattern);
  const ok = b.dataset.p === right;
  document.querySelector(`.q-opt[data-p="${right}"]`).classList.add('right');
  if (!ok) b.classList.add('wrong');
  streak = ok ? streak + 1 : 0;
  best = Math.max(best, streak);
  document.getElementById('streak').textContent = streak;
  document.getElementById('best').textContent = best;
  const fb = document.getElementById('qFb');
  fb.className = 'fb ' + (ok ? 'ok' : 'bad');
  fb.innerHTML = (ok ? T.ok : T.bad) + why(q[0], q[1]);
  qkb.show(c.notes);
  MN.play(c.notes.map(n => n.midi));
  const asked = q;
  if (ok) setTimeout(() => { if (answered && q === asked) nextQ(); }, 2200);
});
document.getElementById('qNext').onclick = nextQ;
nextQ();

document.addEventListener('notation', () => { kb.relabel(); qkb.redraw(); select(cur.root, cur.type, false); });

/* Theory is the default tab. #trainer (the hub footnote) opens the quiz tab. */
function showPatternTab(name) {
  document.querySelectorAll('[data-pattern-panel]').forEach(panel => {
    panel.hidden = panel.dataset.patternPanel !== name;
  });
  document.querySelectorAll('.pattern-tab').forEach(button => {
    const on = button.dataset.patternTab === name;
    button.classList.toggle('on', on);
    button.setAttribute('aria-selected', on ? 'true' : 'false');
  });
  if (location.hash === '#trainer' && name !== 'trainer') history.replaceState(null, '', location.pathname + location.search);
  if (name === 'trainer' && location.hash !== '#trainer') history.replaceState(null, '', '#trainer');
  window.scrollTo(0, 0);
}
document.querySelector('.pattern-tabs')?.addEventListener('click', event => {
  const button = event.target.closest('.pattern-tab');
  if (!button) return;
  showPatternTab(button.dataset.patternTab);
});
window.addEventListener('hashchange', () => showPatternTab(location.hash === '#trainer' ? 'trainer' : 'theory'));
showPatternTab(location.hash === '#trainer' ? 'trainer' : 'theory');
