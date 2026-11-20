/* Chord chart: pick a name, see the keys, play. */
const GROUPS = [
  { type: 'maj', roots: ['C', 'D', 'E', 'F', 'G', 'A', 'B'] },
  { type: 'min', roots: ['C', 'D', 'E', 'F', 'G', 'A', 'B'] },
  { type: 'dom7', roots: ['C', 'D', 'E', 'F', 'G', 'A', 'B'] },
];

const kb = MN.keyboard(document.getElementById('kb'), {
  whites: 14,
  onKey: m => MN.play([m], { arp: false }),
});
let current = null;

function show(root, type, sound) {
  current = { root, type };
  const c = MN.chord(root, type);
  document.querySelectorAll('.cbtn').forEach(b => b.classList.toggle('on', b.dataset.root === root && b.dataset.type === type));
  document.getElementById('name').textContent = c.name;
  document.getElementById('notes').innerHTML = c.notes.map(n => `<span class="note-chip ${n.role}">${MN.noteLabel(n)}</span>`).join('');
  kb.show(c.notes, { fingers: true });
  if (sound) MN.play(c.notes.map(n => n.midi));
}

GROUPS.forEach(group => {
  const box = document.querySelector(`[data-chart="${group.type}"]`);
  group.roots.forEach(root => {
    const c = MN.chord(root, group.type);
    const b = document.createElement('button');
    b.className = 'cbtn';
    b.textContent = c.name;
    b.dataset.root = root;
    b.dataset.type = group.type;
    b.addEventListener('click', () => show(root, group.type, true));
    box.appendChild(b);
  });
});

document.getElementById('btnPlay').onclick = () => {
  if (!current) return;
  MN.play(MN.chord(current.root, current.type).notes.map(n => n.midi));
};
document.addEventListener('notation', () => { kb.relabel(); if (current) show(current.root, current.type, false); });
show('C', 'maj', false);
