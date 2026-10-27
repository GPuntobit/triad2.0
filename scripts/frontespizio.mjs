// Frontespizio 6x9 (SVG) de "Il libro di Triad", con il logo incorporato. Uso:
//   node scripts/frontespizio.mjs > docs/libro/frontespizio.svg
// Il PDF si ottiene stampando l'SVG (es. Chrome headless, pagina 6x9 senza margini).
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import sharp from 'sharp';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const logo = (await sharp(join(root, 'docs', 'triad-logo.webp')).png().toBuffer()).toString('base64');
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
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="152.4mm" height="228.6mm" viewBox="0 0 152.4 228.6">
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
    <radialGradient id="logoGlow" cx="50%" cy="50%" r="50%">
      <stop offset="0" stop-color="${C.accent}" stop-opacity="0.35"/>
      <stop offset="1" stop-color="${C.accent}" stop-opacity="0"/>
    </radialGradient>
    <mask id="logoMask" maskContentUnits="userSpaceOnUse">
      <rect x="36.2" y="24" width="80" height="80" fill="url(#fade)"/>
    </mask>
  </defs>
  <rect width="152.4" height="228.6" fill="url(#glow)"/>
  <rect x="8" y="8" width="136.4" height="212.6" fill="none" stroke="${C.frame}" stroke-width="0.6"/>
  <rect x="10" y="10" width="132.4" height="208.6" fill="none" stroke="${C.frame}" stroke-width="0.25" opacity="0.6"/>

  <circle cx="76.2" cy="64" r="46" fill="url(#logoGlow)"/>

  <text x="76.2" y="16" text-anchor="middle" font-family="${sans}" font-size="3.5" letter-spacing="1.6" fill="${C.muted}">GPUNTOBIT</text>

  <image mask="url(#logoMask)" x="36.2" y="24" width="80" height="80" xlink:href="data:image/png;base64,${logo}"/>

  <text x="76.2" y="118" text-anchor="middle" font-family="${serif}" font-size="14" fill="${C.text}">Il libro di <tspan font-style="italic">Triad</tspan></text>
  <line x1="56.2" y1="126" x2="96.2" y2="126" stroke="${C.accent}" stroke-width="0.7"/>
  <text x="76.2" y="134" text-anchor="middle" font-family="${serif}" font-style="italic" font-size="5.5" fill="${C.muted}">Imparare il linguaggio e il codice del progetto triad2.0,</text>
  <text x="76.2" y="141" text-anchor="middle" font-family="${serif}" font-style="italic" font-size="5.5" fill="${C.muted}">dai primi programmi al seed in codice macchina</text>

  <text x="76.2" y="155" text-anchor="middle" font-family="${sans}" font-size="3.2" letter-spacing="0.4" fill="${C.muted}">${partsText}</text>

  <text x="76.2" y="170" text-anchor="middle" font-family="${mono}" font-size="3" fill="${C.dim}">fattoriale(n) = n &lt; 2 ? 1 : n * fattoriale(n - 1)</text>

  <line x1="20" y1="182" x2="132.4" y2="182" stroke="${C.frame}" stroke-width="0.25"/>
  <text x="76.2" y="190" text-anchor="middle" font-family="${sans}" font-size="3.4" letter-spacing="0.6" fill="${C.text}">Prima edizione · Standard del linguaggio ${esc(version)} · ${year}</text>
  <text x="76.2" y="196" text-anchor="middle" font-family="${mono}" font-size="2.8" fill="${C.muted}">github.com/GPuntobit/triad2.0</text>
</svg>
`);
