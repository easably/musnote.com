#!/usr/bin/env node
/**
 * Build CSS and Dart from design/tokens/musnote.tokens.json.
 * No dependencies. `--check` exits 1 when a generated file is stale.
 */
const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');
const jsonPath = path.join(root, 'design/tokens/musnote.tokens.json');
const cssPath = path.join(root, 'web/assets/css/design-tokens.css');
const dartPath = path.join(root, 'vocal_note_monitor/lib/theme/musnote_tokens.g.dart');

function isToken(node) {
  return node && typeof node === 'object' && typeof node.$type === 'string' && '$value' in node;
}

function walk(node, parts, out) {
  if (isToken(node)) {
    const flutter = node.$extensions ? node.$extensions.flutter : undefined;
    out.push({ parts, type: node.$type, value: node.$value, flutter });
    return;
  }
  for (const key of Object.keys(node)) {
    if (key.startsWith('$')) continue;
    walk(node[key], parts.concat(key), out);
  }
}

function cssName(parts) {
  return '--' + parts.join('-');
}

function camel(parts) {
  const bits = parts.join('-').split('-').filter(Boolean);
  return bits[0] + bits.slice(1).map((b) => b.charAt(0).toUpperCase() + b.slice(1)).join('');
}

function dartName(parts) {
  if (parts[0] === 'mn') return camel(parts.slice(1));
  if (parts[0] === 'c') return 'role' + camel(parts.slice(1)).replace(/^./, (c) => c.toUpperCase());
  return camel(parts);
}

function cssValue(token) {
  const v = token.value;
  if (token.type === 'color' || token.type === 'dimension' || token.type === 'duration' || token.type === 'number') {
    return String(v);
  }
  if (token.type === 'fontFamily') {
    return v.map((name) => (name.includes(' ') || /[^a-z-]/i.test(name) ? '"' + name + '"' : name)).join(', ');
  }
  if (token.type === 'cubicBezier') {
    return 'cubic-bezier(' + v.join(', ') + ')';
  }
  if (token.type === 'shadow') {
    return [v.offsetX, v.offsetY, v.blur, v.spread, v.color].filter((p) => p != null && p !== '0px' || p === v.offsetX || p === v.offsetY).filter((p, i, arr) => {
      if (p === '0px' && v.spread === '0px' && p === v.spread) return false;
      return p != null;
    }).join(' ');
  }
  throw new Error('Unknown token type ' + token.type);
}

function shadowCss(v) {
  const parts = [v.offsetX, v.offsetY, v.blur];
  if (v.spread && v.spread !== '0px') parts.push(v.spread);
  parts.push(v.color);
  return parts.join(' ');
}

function hexColor(value) {
  const m = String(value).trim().match(/^#([0-9a-fA-F]{6})$/);
  if (!m) throw new Error('Expected #rrggbb, got ' + value);
  return 'Color(0xFF' + m[1].toUpperCase() + ')';
}

function dartString(value) {
  return "'" + String(value).replace(/'/g, "\\'") + "'";
}

const genericFonts = new Set([
  'sans-serif', 'serif', 'monospace', 'cursive', 'fantasy',
  'system-ui', 'ui-sans-serif', 'ui-serif', 'ui-monospace',
]);

function dartColor(value) {
  const hex = String(value).trim().match(/^#([0-9a-fA-F]{6})$/);
  if (hex) return 'Color(0xFF' + hex[1].toUpperCase() + ')';
  const rgba = String(value).trim().match(/^rgba\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*([0-9.]+)\s*\)$/);
  if (!rgba) throw new Error('Expected a color, got ' + value);
  const bytes = [Math.round(parseFloat(rgba[4]) * 255), Number(rgba[1]), Number(rgba[2]), Number(rgba[3])];
  return 'Color(0x' + bytes.map((n) => n.toString(16).padStart(2, '0')).join('').toUpperCase() + ')';
}

function pxNum(value) {
  return String(parseFloat(value));
}

function shadowList(v) {
  const spread = v.spread && v.spread !== '0px' ? ', spreadRadius: ' + pxNum(v.spread) : '';
  return '[\n    BoxShadow(color: ' + dartColor(v.color) + ', offset: Offset(' + pxNum(v.offsetX) + ', ' + pxNum(v.offsetY) + '), blurRadius: ' + pxNum(v.blur) + spread + '),\n  ]';
}

function dartRows(token) {
  if (token.flutter === false) return [];
  if (token.flutter && typeof token.flutter === 'object') {
    const base = dartName(token.parts);
    const rows = [];
    if ('min' in token.flutter) rows.push(['double', base + 'Min', String(token.flutter.min)]);
    if ('max' in token.flutter) rows.push(['double', base + 'Max', String(token.flutter.max)]);
    if (rows.length) return rows;
  }
  if (token.type === 'fontFamily') {
    const names = token.value.filter((name) => !genericFonts.has(String(name).toLowerCase()));
    const base = dartName(token.parts);
    return [
      ['String', base, dartString(names[0])],
      ['List<String>', base + 'Fallback', '[' + names.slice(1).map(dartString).join(', ') + ']'],
    ];
  }
  if (token.type === 'shadow') return [['List<BoxShadow>', dartName(token.parts), shadowList(token.value)]];
  if (token.type === 'color') return [['Color', dartName(token.parts), hexColor(token.value)]];
  if (token.type === 'duration') {
    return [['Duration', dartName(token.parts), 'Duration(milliseconds: ' + parseFloat(token.value) + ')']];
  }
  if (token.type === 'cubicBezier') return [['Cubic', dartName(token.parts), 'Cubic(' + token.value.join(', ') + ')']];
  if (token.type === 'number' || (token.type === 'dimension' && /^\d+(\.\d+)?(px|rem)$/.test(String(token.value)))) {
    const n = token.type === 'number'
      ? token.value
      : (String(token.value).endsWith('rem') ? parseFloat(token.value) * 16 : parseFloat(token.value));
    return [['double', dartName(token.parts), String(n)]];
  }
  throw new Error('No Flutter form for ' + token.parts.join('.'));
}

function renderCss(tokens) {
  const lines = [
    '/*',
    ' * Сгенерировано из design/tokens/musnote.tokens.json. Не править руками.',
    ' * node scripts/build-tokens.js',
    ' */',
    ':root {',
  ];
  for (const token of tokens) {
    const value = token.type === 'shadow' ? shadowCss(token.value) : cssValue(token);
    lines.push('  ' + cssName(token.parts) + ': ' + value + ';');
  }
  lines.push('}');
  lines.push('');
  lines.push('@media (prefers-reduced-motion: reduce) {');
  lines.push('  :root {');
  lines.push('    --mn-dur: 1ms;');
  lines.push('  }');
  lines.push('}');
  lines.push('');
  return lines.join('\n');
}

function renderDart(tokens) {
  const lines = [
    '// Сгенерировано из design/tokens/musnote.tokens.json. Не править руками.',
    '// node scripts/build-tokens.js',
    "import 'package:flutter/material.dart';",
    '',
    'abstract final class MusnoteTokens {',
  ];
  for (const token of tokens) {
    for (const [type, name, expr] of dartRows(token)) {
      lines.push('  static const ' + type + ' ' + name + ' = ' + expr + ';');
    }
  }
  lines.push('}');
  lines.push('');
  return lines.join('\n');
}

const tree = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));
const tokens = [];
walk(tree, [], tokens);
const css = renderCss(tokens);
const dart = renderDart(tokens);
const check = process.argv.includes('--check');

if (check) {
  const cssNow = fs.existsSync(cssPath) ? fs.readFileSync(cssPath, 'utf8') : '';
  const dartNow = fs.existsSync(dartPath) ? fs.readFileSync(dartPath, 'utf8') : '';
  if (cssNow !== css || dartNow !== dart) {
    console.error('tokens out of date: run node scripts/build-tokens.js');
    process.exit(1);
  }
  console.log('tokens ok');
} else {
  fs.writeFileSync(cssPath, css);
  fs.writeFileSync(dartPath, dart);
  console.log('wrote', path.relative(root, cssPath));
  console.log('wrote', path.relative(root, dartPath));
}
