/* MusNote chord design prototypes — shared helpers
 * keyboard renderer, chord speller (correct ♯/♭ spelling), tiny synth, notation toggle */
const MN = (() => {
  const NS = 'http://www.w3.org/2000/svg';
  const BLACK = new Set([1, 3, 6, 8, 10]);
  const isBlack = m => BLACK.has(((m % 12) + 12) % 12);
  const LET = 'CDEFGAB';
  const LPC = { C: 0, D: 2, E: 4, F: 5, G: 7, A: 9, B: 11 };
  const PREFIX_RE = (window.MusnoteLocale && window.MusnoteLocale.PREFIX_RE)
    || /^\/(ru|de|pl|es|pt|ja|ko|zh-tw|zh-cn|vi)(?=\/|$)/;
  const LANG = (() => {
    const m = location.pathname.match(PREFIX_RE);
    if (m) return m[1];
    const html = (document.documentElement.lang || 'en').toLowerCase();
    if (html.startsWith('zh-tw') || html === 'zh-hant') return 'zh-tw';
    if (html.startsWith('zh')) return 'zh-cn';
    return html.slice(0, 2);
  })();
  const SOLF_RU = { C: 'До', D: 'Ре', E: 'Ми', F: 'Фа', G: 'Соль', A: 'Ля', B: 'Си' };
  const SOLF_DO = { C: 'Do', D: 'Re', E: 'Mi', F: 'Fa', G: 'Sol', A: 'La', B: 'Si' };
  const SOLF = LANG === 'ru' ? SOLF_RU : SOLF_DO;
  const ACC = { '-2': '𝄫', '-1': '♭', '0': '', '1': '♯', '2': '𝄪' };
  const ROLES = ['r', 't', 'f', 's'];
  const TYPE_LABELS = {
    en: { maj: 'Major', min: 'Minor', dom7: 'Seventh', dim: 'Diminished', aug: 'Augmented' },
    ru: { maj: 'Мажор', min: 'Минор', dom7: 'Септаккорд', dim: 'Уменьшённый', aug: 'Увеличенный' },
    de: { maj: 'Dur', min: 'Moll', dom7: 'Septakkord', dim: 'Vermindert', aug: 'Übermäßig' },
  };
  const TL = TYPE_LABELS[LANG] || TYPE_LABELS.en;
  const TYPES = {
    maj:  { suffix: '',    label: TL.maj,  iv: [[0, 0], [2, 4], [4, 7]] },
    min:  { suffix: 'm',   label: TL.min,  iv: [[0, 0], [2, 3], [4, 7]] },
    dom7: { suffix: '7',   label: TL.dom7, iv: [[0, 0], [2, 4], [4, 7], [6, 10]] },
    dim:  { suffix: 'dim', label: TL.dim,  iv: [[0, 0], [2, 3], [4, 6]] },
    aug:  { suffix: '+',   label: TL.aug,  iv: [[0, 0], [2, 4], [4, 8]] },
  };
  // conventional root spellings per pitch class
  const ROOTS_MAJ = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B'];
  const ROOTS_MIN = ['C', 'C#', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'G#', 'A', 'Bb', 'B'];
  const rootFor = (pc, type) => ((type === 'min' || type === 'dim') ? ROOTS_MIN : ROOTS_MAJ)[((pc % 12) + 12) % 12];

  let notation = 'abc';

  function el(tag, attrs = {}, parent) {
    const e = document.createElementNS(NS, tag);
    for (const k in attrs) e.setAttribute(k, attrs[k]);
    if (parent) parent.appendChild(e);
    return e;
  }
  function parseRoot(n) {
    const L = n[0];
    let a = 0;
    for (const c of n.slice(1)) { if (c === '#' || c === '♯') a++; if (c === 'b' || c === '♭') a--; }
    return { L, a, pc: (LPC[L] + a + 12) % 12 };
  }
  const pretty = n => n[0] + n.slice(1).replace(/#/g, '♯').replace(/b/g, '♭');

  function chord(root, type = 'maj', baseMidi) {
    const r = parseRoot(root);
    const li = LET.indexOf(r.L);
    const base = baseMidi ?? 60 + r.pc;
    const notes = TYPES[type].iv.map(([s, semi], i) => {
      const L = LET[(li + s) % 7];
      const pc = (r.pc + semi) % 12;
      let d = (((pc - LPC[L]) % 12) + 12) % 12;
      if (d > 6) d -= 12;
      return { letter: L, acc: d, name: L + ACC[d], midi: base + semi, semi, role: ROLES[i], black: isBlack(base + semi) };
    });
    return {
      root, type,
      name: pretty(root) + TYPES[type].suffix,
      notes,
      skeleton: notes.map(n => n.letter),
      pattern: notes.slice(0, 3).map(n => (n.black ? 'b' : 'w')).join(''),
    };
  }
  const noteLabel = n => (notation === 'solf' ? SOLF[n.letter] + ACC[n.acc] : n.name);
  const letterLabel = L => (notation === 'solf' ? SOLF[L] : L);
  const dots = (p, lg) => `<span class="dots${lg ? ' lg' : ''}">${[...p].map(c => `<i class="${c}"></i>`).join('')}</span>`;

  /* ---------- keyboard ---------- */
  function keyboard(svg, { start = 60, whites = 14, W = 44, H = 170, top = 0, bottom = 0, labels = true, onKey } = {}) {
    svg.innerHTML = '';
    const BW = Math.round(W * 0.6), BH = Math.round(H * 0.62);
    svg.setAttribute('viewBox', `0 0 ${whites * W} ${top + H + bottom}`);
    svg.classList.add('kb');
    const gW = el('g', {}, svg), gB = el('g', {}, svg), gM = el('g', { class: 'markers' }, svg);
    const keys = {};
    const nameEls = [];
    let x = 0, m = start, c = 0;
    while (c < whites) {
      if (isBlack(m)) keys[m] = { midi: m, black: true, cx: x };
      else {
        const r = el('rect', { x: x + 1, y: top, width: W - 2, height: H, rx: 6, class: 'key key-w' }, gW);
        keys[m] = { midi: m, black: false, cx: x + W / 2, rect: r };
        if (labels) {
          const t = el('text', { x: x + W / 2, y: top + H - 12, class: 'key-name' }, gW);
          nameEls.push([t, LET[[0, 2, 4, 5, 7, 9, 11].indexOf(m % 12)]]);
        }
        x += W; c++;
      }
      m++;
    }
    Object.values(keys).filter(k => k.black).forEach(k => {
      k.rect = el('rect', { x: k.cx - BW / 2, y: top, width: BW, height: BH, rx: 4, class: 'key key-b' }, gB);
    });
    Object.values(keys).forEach(k => {
      if (onKey) { k.rect.style.cursor = 'pointer'; k.rect.addEventListener('click', () => onKey(k.midi)); }
    });
    const kb = {
      svg, keys, W, H, BW, BH, top, gM, last: [], opts: {},
      relabel() { nameEls.forEach(([t, L]) => (t.textContent = letterLabel(L))); },
      markerY(k) { return top + (k.black ? BH - 22 : H - 46); },
      clear() {
        Object.values(keys).forEach(k => k.rect.classList.remove('hl-r', 'hl-t', 'hl-f', 'hl-s', 'step'));
        gM.innerHTML = '';
      },
      show(notes, opts = {}) {
        this.clear(); this.last = notes; this.opts = opts;
        const FING = ['1', '3', '5', '5'];
        notes.forEach((n, i) => {
          const k = keys[n.midi]; if (!k) return;
          k.rect.classList.add('hl-' + n.role);
          const g = el('g', { class: 'marker m-' + n.role, 'data-role': n.role, transform: `translate(${k.cx},${this.markerY(k)})` }, gM);
          el('circle', { r: k.black ? 14 : 17 }, g);
          const label = noteLabel(n);
          const t = el('text', { y: 5, 'font-size': label.length > 3 ? 9.5 : label.length > 2 ? 11 : 13 }, g);
          t.textContent = label;
          if (opts.fingers && notes.length === 3) {
            const f = el('text', { y: k.black ? 31 : -25, class: 'finger' }, g);
            f.textContent = ['1', '3', '5'][i];
          }
        });
      },
      redraw() { this.relabel(); if (this.last.length) this.show(this.last, this.opts); },
    };
    kb.relabel();
    return kb;
  }

  /* ---------- synth ---------- */
  let AC;
  function ctx() {
    AC = AC || new (window.AudioContext || window.webkitAudioContext)();
    if (AC.state === 'suspended') AC.resume();
    return AC;
  }
  function voice(m, t, d, vol = 0.14) {
    const a = ctx();
    const f = 440 * Math.pow(2, (m - 69) / 12);
    const o = a.createOscillator(), o2 = a.createOscillator(), g = a.createGain(), g2 = a.createGain();
    o.type = 'triangle'; o2.type = 'sine';
    o.frequency.value = f; o2.frequency.value = f * 2;
    g2.gain.value = 0.3;
    o2.connect(g2).connect(g); o.connect(g); g.connect(a.destination);
    g.gain.setValueAtTime(0, t);
    g.gain.linearRampToValueAtTime(vol, t + 0.012);
    g.gain.exponentialRampToValueAtTime(0.0008, t + d);
    o.start(t); o2.start(t); o.stop(t + d + 0.05); o2.stop(t + d + 0.05);
    let stopped = false;
    return {
      stop() {
        if (stopped) return;
        stopped = true;
        try {
          const now = a.currentTime;
          g.gain.cancelScheduledValues(now);
          if (now < t) {
            g.gain.setValueAtTime(0, now);
            o.stop(t);
            o2.stop(t);
            return;
          }
          const level = Math.max(g.gain.value, 0.0008);
          g.gain.setValueAtTime(level, now);
          g.gain.exponentialRampToValueAtTime(0.0008, now + 0.02);
          o.stop(now + 0.03);
          o2.stop(now + 0.03);
        } catch (e) { /* already stopped */ }
      },
    };
  }
  function note(m, { when, duration = 1.6, volume = 0.1 } = {}) {
    const t = when == null ? ctx().currentTime + 0.03 : when;
    return voice(m, t, Math.max(0.02, duration), volume);
  }
  function now() { return ctx().currentTime; }
  function play(midis, { arp = true, gap = 0.16 } = {}) {
    try {
      const t = ctx().currentTime + 0.03;
      if (arp) {
        midis.forEach((m, i) => voice(m, t + i * gap, 0.9));
        midis.forEach(m => voice(m, t + midis.length * gap + 0.08, 1.8, 0.1));
      } else midis.forEach(m => voice(m, t, 1.6, 0.1));
    } catch (e) { /* audio not available */ }
  }
  function tick(m) { try { voice(m, ctx().currentTime + 0.01, 0.22, 0.05); } catch (e) {} }

  /* ---------- notation toggle in top bar ---------- */
  document.addEventListener('DOMContentLoaded', () => {
    const seg = document.getElementById('notation');
    if (seg) seg.addEventListener('click', e => {
      const b = e.target.closest('button'); if (!b) return;
      notation = b.dataset.v;
      seg.querySelectorAll('button').forEach(x => x.classList.toggle('on', x === b));
      document.dispatchEvent(new CustomEvent('notation'));
    });
    const page = document.body.dataset.page;
    document.querySelectorAll('.variants a').forEach(a => a.classList.toggle('on', a.dataset.page === page));
    const langSel = document.getElementById('language-selector');
    if (langSel) {
      const live = (window.MusnoteLocale && window.MusnoteLocale.LIVE) || {
        en: 1, ru: 1, de: 1, pl: 1, es: 1, pt: 1,
        ja: 1, ko: 1, 'zh-tw': 1, 'zh-cn': 1, vi: 1
      };
      [...langSel.options].forEach((opt) => {
        if (!live[opt.value]) opt.hidden = true;
      });
      langSel.value = live[LANG] ? LANG : 'en';
      langSel.addEventListener('change', () => {
        const language = langSel.value;
        if (window.MusnoteLocale && window.MusnoteLocale.remember) {
          window.MusnoteLocale.remember(language);
        }
        if (window.MusnoteLocale && window.MusnoteLocale.hrefFor) {
          location.href = window.MusnoteLocale.hrefFor(
            language,
            location.pathname,
            location.search,
            location.hash
          );
          return;
        }
        let path = location.pathname.replace(PREFIX_RE, '') || '/';
        if (!path.startsWith('/')) path = '/' + path;
        if (language !== 'en') path = '/' + language + (path === '/' ? '/' : path);
        location.href = path;
      });
    }
  });

  const sleep = ms => new Promise(r => setTimeout(r, ms));

  return { el, isBlack, chord, rootFor, pretty, noteLabel, letterLabel, dots, keyboard, play, note, now, tick, sleep, TYPES, SOLF, LET, ACC, LANG,
    get notation() { return notation; } };
})();
