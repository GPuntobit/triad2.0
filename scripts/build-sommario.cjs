const fs = require('fs');
const path = require('path');

const root = 'c:\\Users\\xbos\\Documents\\progetti\\triad2.0';

function extractHeadings(md, maxLevel) {
  const lines = md.split(/\r?\n/);
  const out = [];
  let inFence = false;
  for (const line of lines) {
    if (/^```/.test(line.trim())) { inFence = !inFence; continue; }
    if (inFence) continue;
    const m = line.match(/^(#{1,6})\s+(.+)$/);
    if (!m || m[1].length > maxLevel) continue;
    const text = m[2].trim();
    if (/[.](triad|td)\b/.test(text)) continue;
    if (/^[a-zàèéìòù]/.test(text)) continue;
    out.push({ level: m[1].length, text });
  }
  return out;
}

const manuale = fs.readFileSync(path.join(root, 'MANUALE.md'), 'utf8');
const tutorial = fs.readFileSync(path.join(root, 'TUTORIAL.md'), 'utf8');

const manHeadings = extractHeadings(manuale, 2);
const tutHeadings = extractHeadings(tutorial, 2);

let md = '# Sommario — Il libro di Triad\n\n';
md += '> Elenco dei capitoli e delle sezioni principali del libro (Manuale + Tutorial).\n';
md += '> Per l\'indice dettagliato con link interni, vedi la pagina "Indice" nel PDF/HTML.\n\n';

md += '## Manuale di Triad 2.0\n\n';
for (const h of manHeadings) {
  const indent = '  '.repeat(h.level - 1);
  md += `${indent}- ${h.text}\n`;
}
md += '\n';

md += '## Tutorial di Triad 2.0\n\n';
for (const h of tutHeadings) {
  const indent = '  '.repeat(h.level - 1);
  md += `${indent}- ${h.text}\n`;
}
md += '\n';

fs.writeFileSync(path.join(root, 'SOMMARIO.md'), md, 'utf8');
console.log('scritto SOMMARIO.md');
console.log('manuale headings:', manHeadings.length, 'tutorial headings:', tutHeadings.length);