const fs = require('fs');
const path = require('path');
const marked = require('marked');
const Epub = require('epub-gen');

const root = path.join(__dirname, '..');
const outDir = path.join(root, 'docs', 'libro');

const preface = fs.readFileSync(path.join(root, 'PREFazione.md'), 'utf8');
const manuale = fs.readFileSync(path.join(root, 'MANUALE.md'), 'utf8');
const tutorial = fs.readFileSync(path.join(root, 'TUTORIAL.md'), 'utf8');

marked.setOptions({ gfm: true, breaks: false });

function rewriteRepositoryLinks(html) {
  return html.replace(/href="([^"]+)"/g, (match, target) => {
    if (/^(?:https?:|mailto:|#)/.test(target)) return match;
    const path = target.replace(/^\.\//, '');
    const kind = path.endsWith('/') ? 'tree' : 'blob';
    return `href="https://github.com/GPuntobit/triad2.0/${kind}/main/${path}"`;
  });
}

function stripFirstH1(md) {
  const lines = md.split(/\r?\n/);
  let inFence = false;
  const index = lines.findIndex((line) => {
    if (/^```/.test(line.trim())) { inFence = !inFence; return false; }
    return !inFence && /^#\s+/.test(line);
  });
  if (index !== -1) lines.splice(index, 1);
  return lines.join('\n');
}

// Rimuovi indici interni
function stripIndice(md, heading, endMarker) {
  const start = md.indexOf(heading);
  if (start === -1) return md;
  const end = md.indexOf(endMarker, start);
  if (end === -1) return md;
  return md.slice(0, start) + md.slice(end);
}
const manualeClean = stripIndice(manuale, '### Indice', '\n<a id="parte-1">');
const tutorialClean = stripIndice(tutorial, '## Indice', '\n<a id="parte-1">');

function extractHeadings(md, maxLevel) {
  const lines = md.split(/\r?\n/);
  const out = [];
  let inFence = false;
  let firstH1 = true;
  for (const line of lines) {
    if (/^```/.test(line.trim())) { inFence = !inFence; continue; }
    if (inFence) continue;
    const m = line.match(/^(#{1,6})\s+(.+)$/);
    if (!m || m[1].length > maxLevel) continue;
    if (m[1].length === 1 && firstH1) { firstH1 = false; continue; }
    const text = m[2].trim();
    if (/[.](triad|td)\b/.test(text)) continue;
    if (/^[a-z]/.test(text)) continue;
    out.push({ level: m[1].length, text });
  }
  return out;
}
const manH = extractHeadings(manualeClean, 3);
const tutH = extractHeadings(tutorialClean, 3);
let sommarioHtml = '<p>Elenco completo di tutti i capitoli e le sezioni.</p>';
sommarioHtml += '<h2>Manuale di Triad 2.0</h2><ul>';
for (const h of manH) sommarioHtml += '<li>' + h.text + '</li>';
sommarioHtml += '</ul>';
sommarioHtml += '<h2>Tutorial di Triad 2.0</h2><ul>';
for (const h of tutH) sommarioHtml += '<li>' + h.text + '</li>';
sommarioHtml += '</ul>';

const css = `
body { font-family: serif; font-size: 1em; line-height: 1.6; color: #1a1a1a; }
h1, h2, h3 { font-family: sans-serif; color: #0d0a0f; page-break-before: always; }
h1 { font-size: 1.6em; border-bottom: 1px solid #7d5157; padding-bottom: 0.3em; }
h2 { font-size: 1.3em; }
h3 { font-size: 1.1em; }
p { text-align: justify; margin: 0.6em 0; }
code { font-family: monospace; font-size: 0.9em; background: #f3f1f4; padding: 0.1em 0.3em; }
pre { background: #f3f1f4; color: #1a1a1a; padding: 0.8em; border: 1px solid #ccc; border-radius: 4px; overflow-x: auto; }
pre code { background: none; color: inherit; }
table { border-collapse: collapse; width: 100%; margin: 0.8em 0; }
th, td { border: 0.5pt solid #b8b0aa; padding: 0.3em 0.5em; }
th { background: #ece8e4; font-weight: bold; }
blockquote { border-left: 2pt solid #7d5157; margin: 0.8em 0; padding: 0.3em 0.8em; font-style: italic; }
`;

const content = [
  {
    title: 'Prefazione',
    data: rewriteRepositoryLinks(marked.parse(stripFirstH1(preface)))
  },
  {
    title: 'Sommario',
    data: sommarioHtml
  },
  {
    title: 'Manuale di Triad 2.0',
    data: rewriteRepositoryLinks(marked.parse(stripFirstH1(manualeClean)))
  },
  {
    title: 'Tutorial di Triad 2.0',
    data: rewriteRepositoryLinks(marked.parse(stripFirstH1(tutorialClean)))
  },
  {
    title: 'Quarta di copertina',
    data: `<div style="background:#0d0a0f;color:#f5f5f4;padding:1em;">
      <h1>Il libro di Triad</h1>
      <p>Triad 2.0 è un linguaggio di programmazione autonomo, definito da una specifica normativa indipendente da qualsiasi implementazione.</p>
      <p>Il progetto è rilasciato sotto licenza MIT. SPEC.md (standard 0.2.0), SPEC-CORE.md, conformance/ con golden verificabili.</p>
      <p>L'obiettivo è un linguaggio autonomo e riconosciuto: standard proprio, conformance eseguibile, estensione .triad, tooling editor, bootstrap senza linguaggi ospiti e self-hosting.</p>
    </div>`
  }
];

const options = {
  title: 'Il libro di Triad',
  author: 'GPuntobit',
  publisher: 'GPuntobit',
  description: 'Il libro di Triad — imparare il linguaggio e il codice del progetto triad2.0',
  cover: path.join(outDir, 'frontespizio.png'),
  content: content,
  css: css,
  tocTitle: 'Indice',
  version: 3,
  lang: 'it'
};

const epub = new Epub(options, path.join(outDir, 'Il-libro-di-Triad.epub'));
epub.promise.then(() => {
  console.log('scritto libro.epub');
}).catch(err => {
  console.error('errore epub:', err);
});