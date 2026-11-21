import json, math, os, sys
W, H, FR, BASE = 400, 160, 60, 180
def rgb(h, a=1): h=h.lstrip('#'); return [int(h[i:i+2],16)/255 for i in (0,2,4)]+[a]

def token_tree():
    path = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'tokens', 'musnote.tokens.json'))
    return json.load(open(path))

TREE = token_tree()
def get(*keys):
    node = TREE
    for key in keys:
        node = node[key]
    return node['$value']

def duration_ms(value):
    text = str(value).strip()
    if text.endswith('ms'): return float(text[:-2])
    if text.endswith('s'): return float(text[:-1]) * 1000
    raise SystemExit('bad duration ' + text)

OP = int(round(duration_ms(get('animation', 'loading', 'cycle')) / 1000 * FR))
def F(n): return int(round(n * OP / BASE))

def token_colors():
    return dict(
        green=get('mn', 'green', '500'), ghost=get('mn', 'green', '200'), ink=get('mn', 'ink'),
        r=get('c', 'r'), t=get('c', 't'), f=get('c', 'f'),
        rs=get('c', 'r-soft'), ts=get('c', 't-soft'), fs=get('c', 'f-soft'),
        line=get('mn', 'key-line'), black=get('mn', 'key-black'), white=get('mn', 'key-white'))

C = token_colors()
LIN = {"i": {"x": [1], "y": [1]}, "o": {"x": [0], "y": [0]}}
def ease(ix, iy, ox, oy): return {"i": {"x": [ix], "y": [iy]}, "o": {"x": [ox], "y": [oy]}}
static = lambda v: {"a": 0, "k": v}
def anim(kfs):  # kfs: list of (t, value, easing or None)
    out = []
    for t, v, e in kfs:
        k = {"t": t, "s": v if isinstance(v, list) else [v]}
        if e: k.update(e)
        out.append(k)
    return {"a": 1, "k": out}
def tr(p=(0, 0), s=(100, 100), o=100):
    return {"ty": "tr", "p": static(list(p)), "a": static([0, 0]), "s": static(list(s)), "r": static(0), "o": static(o), "sk": static(0), "sa": static(0)}
def layer(ind, name, shapes, ks=None, ip=0, op=OP):
    return {"ddd": 0, "ind": ind, "ty": 4, "nm": name, "sr": 1,
            "ks": ks or {"o": static(100), "r": static(0), "p": static([0, 0, 0]), "a": static([0, 0, 0]), "s": static([100, 100, 100])},
            "ao": 0, "shapes": shapes, "ip": ip, "op": op, "st": 0, "bm": 0}
def group(name, items): return {"ty": "gr", "nm": name, "it": items + [tr()]}
fill = lambda c, o=100: {"ty": "fl", "c": static(rgb(c)), "o": static(o), "r": 1}
def stroke(c, w, o=100): return {"ty": "st", "c": static(rgb(c)), "o": static(o), "w": static(w), "lc": 2, "lj": 2, "ml": 4}
rect = lambda cx, cy, w, h, r: {"ty": "rc", "p": static([cx, cy]), "s": static([w, h]), "r": static(r), "d": 1}

# ---- wave (shape morph, seamless loop) ----
X0, X1, Y, AMP, LAMBDA = 20, 290, 52, 20, 135
N = 32
def wave_path(phase, amp):
    xs = [X0 + (X1 - X0) * i / (N - 1) for i in range(N)]
    dx = (X1 - X0) / (N - 1)
    v, ii, oo = [], [], []
    for x in xs:
        u = (x - X0) / (X1 - X0)
        env = math.sin(math.pi * u) ** 1.2 if 0 < u < 1 else 0
        denv = 0
        if 0 < u < 1:
            denv = 1.2 * math.sin(math.pi * u) ** 0.2 * math.cos(math.pi * u) * math.pi / (X1 - X0)
        k = 2 * math.pi / LAMBDA
        s = math.sin(k * x - phase)
        y = Y - amp * env * s
        dy = -amp * (denv * s + env * k * math.cos(k * x - phase))
        v.append([round(x, 2), round(y, 2)])
        h = dx / 3
        ii.append([round(-h, 2), round(-dy * h, 2)]); oo.append([round(h, 2), round(dy * h, 2)])
    return {"i": ii, "o": oo, "v": v, "c": False}
def wave_layer(ind, color, width, amp, phase0, opacity):
    steps = 24  # keyframes per loop: wave moves 2 wavelengths per loop
    kfs = [(round(OP * j / steps, 3), [wave_path(phase0 + 4 * math.pi * j / steps, amp)], LIN if j < steps else None) for j in range(steps + 1)]
    sh = {"ty": "sh", "ks": anim(kfs)}
    return layer(ind, f"wave-{ind}", [group("wave", [sh, stroke(color, width, opacity)])])

# ---- keyboard ----
KX, KY, KW, KH, NW = 20, 112, 36, 44, 10
BLACK_AFTER = [0, 1, 3, 4, 5, 7, 8]  # white index that has a black key to its right (C D F G A C D)
TARGETS = {5: ('r', 'rs'), 7: ('t', 'ts'), 9: ('f', 'fs')}  # A C E — A minor: root, third, fifth
LAND = {5: F(46), 7: F(106), 9: F(166)}  # landing frame for each key, authored on a 180-frame loop
def white_key(i):
    cx, cy = KX + i * KW + KW / 2, KY + KH / 2
    items = [rect(cx, cy, KW - 2, KH, 5)]
    if i in TARGETS:
        _, soft = TARGETS[i]; lf = LAND[i] % OP
        col = {"ty": "fl", "o": static(100), "r": 1, "c": anim([
            (0, rgb(C['white']), LIN), (max(0, lf - F(1)), rgb(C['white']), ease(.4, 1, .6, 0)),
            (lf + F(2), rgb(C[soft]), ease(.4, 1, .6, 0)), (min(OP - 1, lf + F(34)), rgb(C['white']), LIN), (OP, rgb(C['white']), None)])}
        if lf + F(34) >= OP:  # flash wraps around the loop end
            col["c"] = anim([(0, rgb(C[soft]), ease(.4, 1, .6, 0)), (lf + F(34) - OP, rgb(C['white']), LIN),
                             (lf - F(1), rgb(C['white']), ease(.4, 1, .6, 0)), (lf + F(2) if lf + F(2) < OP else OP, rgb(C[soft]), None)])
        items += [col, stroke(C['line'], 1.2)]
    else:
        items += [fill(C['white']), stroke(C['line'], 1.2)]
    return group(f"white-{i}", items)
blacks = [group(f"black-{i}", [rect(KX + (i + 1) * KW, KY + 13, 22, 26, 3.5), fill(C['black'])]) for i in BLACK_AFTER]
keys_layer = layer(20, "keys", blacks + [white_key(i) for i in range(NW)])

# ---- falling notes ----
def note_layer(ind, key, role, start):
    tx = KX + key * KW + KW / 2
    land = LAND[key]
    sx, sy = X1 - 6, Y - 4
    p = anim([
        (start, [sx, sy, 0], ease(.45, 1, .55, 0)),
        (start + F(14), [sx + (tx - sx) * .25, sy - 22, 0], ease(.7, 1, .35, 0)),   # pops up off the crest
        (land, [tx, KY + KH - 12, 0], LIN),                                          # gravity fall onto the key
        (land + F(14), [tx, KY + KH - 12, 0], None)])
    s = anim([(start, [0, 0, 100], ease(.3, 1.4, .6, 0)), (start + F(12), [100, 100, 100], LIN),
              (land - F(2), [100, 100, 100], ease(.3, 1, .7, 0)), (land + F(2), [125, 80, 100], ease(.3, 1, .7, 0)),
              (land + F(14), [0, 0, 100], None)])
    o = anim([(start, 0, LIN), (start + F(6), 100, LIN), (land + F(6), 100, LIN), (land + F(14), 0, None)])
    ks = {"o": o, "r": static(0), "p": p, "a": static([0, 0, 0]), "s": s}
    note = group("note", [{"ty": "el", "p": static([0, 0]), "s": static([18, 18]), "d": 1}, fill(C[role]),
                          {"ty": "st", "c": static(rgb(C['white'])), "o": static(100), "w": static(3), "lc": 2, "lj": 2}])
    return layer(ind, f"note-{role}", [note], ks, ip=start, op=land + F(15))

layers = [note_layer(1, 5, 'r', F(6)), note_layer(2, 7, 't', F(66)), note_layer(3, 9, 'f', F(126)), keys_layer,
          wave_layer(30, C['green'], 5, AMP, 0, 100), wave_layer(31, C['ghost'], 4, AMP * .7, math.pi * .6, 100)]
doc = {"v": "5.7.4", "fr": FR, "ip": 0, "op": OP, "w": W, "h": H, "nm": "musnote-loading-wave-to-notes", "ddd": 0, "assets": [], "layers": layers,
       "meta": {"g": "musnote / generated by scripts in design/loading-animation/lottie", "d": "Wave turns into three notes that land on A–C–E. Loop length is animation.loading.cycle, 60 fps. Colours from design tokens."}}
payload = json.dumps(doc, separators=(',', ':'))
root = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..'))
out = os.path.join(root, 'web', 'assets', 'anim', 'musnote-loading.json')
os.makedirs(os.path.dirname(out), exist_ok=True)
open(out, 'w').write(payload)
print('ok', len(payload))
