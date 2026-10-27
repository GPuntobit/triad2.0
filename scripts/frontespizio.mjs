// Frontespizio A4 (SVG) de "Il libro di Triad", con il logo incorporato. Uso:
//   node scripts/frontespizio.mjs > docs/libro/frontespizio.svg
// Il PDF si ottiene stampando l'SVG (es. Chrome headless, pagina A4 senza margini).
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const logo = readFileSync(join(root, 'docs', 'triad-logo.webp')).toString('base64');
const version = readFileSync(join(root, 'VERSION'), 'utf8').trim();
const year = new Date().getFullYear();

const C = { bg: '#050507', bg2: '#0d0a0f', frame: '#7d5157', accent: '#d0405a', text: '#f5f5f4', muted: '#a8a29e', dim: '#6b6460' };
const serif = "'Liberation Serif', 'Times New Roman', 'DejaVu Serif', Georgia, serif";
const sans = "'Liberation Sans', 'Helvetica Neue', Arial, 'DejaVu Sans', sans-serif";
const mono = "'JetBrains Mono', 'DejaVu Sans Mono', Consolas, monospace";
const esc = s => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

const parts = ['Fondamenti', 'Triad-Core', 'Triad-Full', 'Dentro il progetto'];
const partsText = parts.map((p, i) => `<tspan fill="${C.accent}">${['I', 'II', 'III', 'IV'][i]}</tspan> ${esc(p)}`)
  .join(`<tspan fill="${C.dim}">  ·  </tspan>`);

process.stdout.write(`<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="210mm" height="297mm" viewBox="0 0 210 297">
  <title>Il libro di Triad — frontespizio</title>
  <defs>
    <radialGradient id="glow" cx="50%" cy="34%" r="65%">
      <stop offset="0" stop-color="${C.bg2}"/>
      <stop offset="1" stop-color="${C.bg}"/>
    </radialGradient>
    <radialGradient id="fade" cx="50%" cy="50%" r="50%">
      <stop offset="0.72" stop-color="#fff"/>
      <stop offset="1" stop-color="#000"/>
    </radialGradient>
    <mask id="logoMask" maskContentUnits="userSpaceOnUse">
      <rect x="45" y="40" width="120" height="120" fill="url(#fade)"/>
    </mask>
  </defs>
  <rect width="210" height="297" fill="url(#glow)"/>
  <rect x="10" y="10" width="190" height="277" fill="none" stroke="${C.frame}" stroke-width="0.6"/>
  <rect x="12.5" y="12.5" width="185" height="272" fill="none" stroke="${C.frame}" stroke-width="0.25" opacity="0.6"/>

  <text x="105" y="30" text-anchor="middle" font-family="${sans}" font-size="4.2" letter-spacing="1.6" fill="${C.muted}">GPUNTOBIT</text>

  <image mask="url(#logoMask)" x="45" y="40" width="120" height="120" xlink:href="data:image/webp;base64,${logo}"/>

  <text x="105" y="184" text-anchor="middle" font-family="${serif}" font-size="15" fill="${C.text}">Il libro di <tspan font-style="italic">Triad</tspan></text>
  <line x1="80" y1="192" x2="130" y2="192" stroke="${C.accent}" stroke-width="0.6"/>
  <text x="105" y="202" text-anchor="middle" font-family="${serif}" font-style="italic" font-size="6" fill="${C.muted}">Imparare il linguaggio e il codice del progetto triad2.0,</text>
  <text x="105" y="210" text-anchor="middle" font-family="${serif}" font-style="italic" font-size="6" fill="${C.muted}">dai primi programmi al seed in codice macchina</text>

  <text x="105" y="226" text-anchor="middle" font-family="${sans}" font-size="3.6" letter-spacing="0.4" fill="${C.muted}">${partsText}</text>

  <text x="105" y="244" text-anchor="middle" font-family="${mono}" font-size="3.3" fill="${C.dim}">fattoriale(n) = n &lt; 2 ? 1 : n * fattoriale(n - 1)</text>

  <line x1="30" y1="258" x2="180" y2="258" stroke="${C.frame}" stroke-width="0.25"/>
  <text x="105" y="266" text-anchor="middle" font-family="${sans}" font-size="3.8" letter-spacing="0.6" fill="${C.text}">Prima edizione · Standard del linguaggio ${esc(version)} · ${year}</text>
  <text x="105" y="273" text-anchor="middle" font-family="${mono}" font-size="3.2" fill="${C.muted}">github.com/GPuntobit/triad2.0</text>
</svg>
`);
