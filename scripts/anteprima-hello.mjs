/* eslint-disable */
/* global process */


// Anteprima animata (SVG/SMIL, in loop) di un programma Triad-Core digitato carattere per carattere.
// L'output mostrato è quello reale dell'interprete JS. Uso:
//   node scripts/anteprima-battitura.mjs > docs/assets/img/anteprima-codice.svg
import { readFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const program = join(root, 'scripts', 'anteprima-hello.td');
const code = readFileSync(program, 'utf8').replace(/\r/g, '').trimEnd().split('\n');
const output = execFileSync(process.execPath, [join(root, 'seed/dev/triad_core.cjs'), program], { encoding: 'utf8' })
  .replace(/\r/g, '').trimEnd().split('\n');
const command = '$ node seed/dev/triad_core.cjs anteprima-hello.td';

const C = { bg: '#0b1220', bar: '#111827', border: '#263248', text: '#e5e7eb', muted: '#94a3b8',
  kw: '#c084fc', fn: '#60a5fa', str: '#34d399', cm: '#64748b', num: '#fbbf24', out: '#e5e7eb', prompt: '#34d399' };
const FS = 15, CW = 9, LH = 23, PAD = 24, BAR = 38;
const CHAR = 0.035, EOL = 0.25, START = 0.8, OUT_STEP = 0.35, HOLD = 4;

const esc = s => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
const KW = new Set(['function', 'end', 'if', 'elseif', 'else', 'while', 'return', 'let', 'begin', 'break', 'continue', 'true', 'false', 'nothing']);
function highlight(line) {
  const re = /(#.*$)|("(?:[^"\\]|\\.)*")|(\b\d+\b)|([A-Za-z_][A-Za-z0-9_!]*)(?=\()|([A-Za-z_][A-Za-z0-9_]*)|(->|[-+*<>=?:!]+)/g;
  let out = '', last = 0, m;
  while ((m = re.exec(line))) {
    out += esc(line.slice(last, m.index));
    const [t] = m;
    const color = m[1] ? C.cm : m[2] ? C.str : m[3] ? C.num : m[4] ? (KW.has(t) ? C.kw : C.fn)
      : m[5] ? (KW.has(t) ? C.kw : null) : C.muted;
    out += color ? `<tspan fill="${color}">${esc(t)}</tspan>` : esc(t);
    last = m.index + t.length;
  }
  return out + esc(line.slice(last));
}

// Timeline: righe di codice, poi il comando, poi l'output una riga alla volta.
let t = START;
const typed = [];
const codeTop = BAR + PAD + FS;
code.forEach((line, i) => {
  typed.push({ text: line, html: highlight(line), x: PAD, y: codeTop + i * LH, start: t });
  t += line.length * CHAR + EOL;
});
const sepY = codeTop + code.length * LH - FS + 10;
const cmdY = sepY + 18 + FS;
typed.push({ text: command, html: `<tspan fill="${C.prompt}">$</tspan>${esc(command.slice(1))}`, x: PAD, y: cmdY, start: t + 0.3 });
t = typed.at(-1).start + command.length * CHAR * 0.6 + 0.5;
const outs = output.map((line, i) => ({ line, y: cmdY + (i + 1) * LH, at: t + i * OUT_STEP }));
const D = +(outs.at(-1).at + HOLD).toFixed(2);

const W = PAD * 2 + CW * Math.max(...code.map(l => l.length), command.length) + CW;
const H = cmdY + output.length * LH + PAD;
const kt = s => (s / D).toFixed(5);
const anim = (attr, frames) => {
  const ts = frames.map(f => kt(f[0])), vs = frames.map(f => f[1]);
  return `<animate attributeName="${attr}" dur="${D}s" repeatCount="indefinite" calcMode="discrete" keyTimes="${ts.join(';')}" values="${vs.join(';')}"/>`;
};
const RESET = D - 0.25;

let defs = '', body = '';
const cursor = [[0, `${PAD}`]], cursorY = [[0, `${codeTop - FS + 3}`]];
typed.forEach((l, i) => {
  const step = i === typed.length - 1 ? CHAR * 0.6 : CHAR;
  const frames = [[0, 0], [l.start, 0]];
  for (let k = 1; k <= l.text.length; k++) frames.push([l.start + k * step, k * CW]);
  frames.push([RESET, 0]);
  const indent = l.text.length - l.text.trimStart().length;
  if (l.text.trim()) {
    defs += `<clipPath id="l${i}"><rect x="${l.x}" y="${l.y - FS}" height="${LH}" width="0">${anim('width', frames)}</rect></clipPath>`;
    body += `<text x="${l.x + indent * CW}" y="${l.y}" textLength="${(l.text.length - indent) * CW}" lengthAdjust="spacingAndGlyphs" clip-path="url(#l${i})">${l.html.replace(/^ +/, '')}</text>`;
  }
  cursorY.push([l.start, l.y - FS + 3]);
  frames.slice(1, -1).forEach(([ft, w]) => cursor.push([ft, l.x + w]));
});
outs.forEach(o => {
  body += `<text x="${PAD}" y="${o.y}" fill="${C.out}" opacity="0">${esc(o.line)}${anim('opacity', [[0, 0], [o.at, 1], [RESET, 0]])}</text>`;
});
const endY = outs.at(-1).y + LH - FS + 3;
cursorY.push([outs[0].at, endY], [RESET, codeTop - FS + 3]);
cursor.push([outs[0].at, PAD], [RESET, PAD]);
cursor.sort((a, b) => a[0] - b[0]); cursorY.sort((a, b) => a[0] - b[0]);
const uniq = fr => fr.filter((f, i) => i === 0 || f[0] > fr[i - 1][0]);

process.stdout.write(`<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}" role="img" aria-label="Anteprima: un programma Triad-Core digitato carattere per carattere e il suo output">
<title>Triad-Core: anteprima di battitura del codice</title>
<defs>${defs}</defs>
<rect x="0.5" y="0.5" width="${W - 1}" height="${H - 1}" rx="14" fill="${C.bg}" stroke="${C.border}"/>
<path d="M0.5 ${BAR} V14.5 a14 14 0 0 1 14 -14 H${W - 14.5} a14 14 0 0 1 14 14 V${BAR} Z" fill="${C.bar}" stroke="${C.border}"/>
<circle cx="22" cy="${BAR / 2}" r="6" fill="#f87171"/><circle cx="42" cy="${BAR / 2}" r="6" fill="#fbbf24"/><circle cx="62" cy="${BAR / 2}" r="6" fill="#34d399"/>
<text x="${W / 2}" y="${BAR / 2 + 5}" text-anchor="middle" fill="${C.muted}" font-family="ui-sans-serif, system-ui, sans-serif" font-size="13">anteprima.td — Triad-Core</text>
<line x1="${PAD}" x2="${W - PAD}" y1="${sepY}" y2="${sepY}" stroke="${C.border}" stroke-dasharray="4 4"/>
<g font-family="'JetBrains Mono', 'DejaVu Sans Mono', Consolas, Menlo, monospace" font-size="${FS}" fill="${C.text}" style="font-variant-ligatures:none;font-feature-settings:'liga' 0,'calt' 0">
${body}
</g>
<rect width="${CW}" height="${FS + 2}" fill="${C.fn}" opacity="0.85" x="${PAD}" y="${codeTop - FS + 3}">${anim('x', uniq(cursor))}${anim('y', uniq(cursorY))}<animate attributeName="fill-opacity" values="1;0;1" dur="1s" repeatCount="indefinite"/></rect>
</svg>
`);
