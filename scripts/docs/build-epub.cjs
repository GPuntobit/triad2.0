const fs = require('fs');
const path = require('path');
const marked = require('marked');
const Epub = require('epub-gen');

const root = path.join(__dirname, '..', '..');
const outDir = path.join(root, 'docs', 'libro');

const preface = fs.readFileSync(path.join(root, 'docs', 'PREFazione.md'), 'utf8');
const manual = fs.readFileSync(path.join(root, 'docs', 'MANUALE.md'), 'utf8');
const tutorial = fs.readFileSync(path.join(root, 'tutorial', 'TUTORIAL.md'), 'utf8');

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

// Remove the internal tables of contents
function stripIndex(md, headings, endMarker) {
  const candidates = Array.isArray(headings) ? headings : [headings];
  let start = -1;
  for (const h of candidates) {
    const at = md.indexOf(h);
    if (at !== -1 && (start === -1 || at < start)) start = at;
  }
  if (start === -1) return md;
  const end = md.indexOf(endMarker, start);
  if (end === -1) return md;
  return md.slice(0, start) + md.slice(end);
}
const manualClean = stripIndex(manual, ['### Index', '### Indice'], '\n<a id="parte-1">');
const tutorialClean = stripIndex(tutorial, ['## Index', '## Indice'], '\n<a id="parte-1">');

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
const manH = extractHeadings(manualClean, 3);
const tutH = extractHeadings(tutorialClean, 3);
let sommarioHtml = '<p>Complete list of all chapters and sections.</p>';
sommarioHtml += '<h2>The Triad 2.0 Handbook</h2><ul>';
for (const h of manH) sommarioHtml += '<li>' + h.text + '</li>';
sommarioHtml += '</ul>';
sommarioHtml += '<h2>The Triad 2.0 Tutorial</h2><ul>';
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
    title: 'Preface',
    data: rewriteRepositoryLinks(marked.parse(stripFirstH1(preface)))
  },
  {
    title: 'Contents',
    data: sommarioHtml
  },
  {
    title: 'The Triad 2.0 Handbook',
    data: rewriteRepositoryLinks(marked.parse(stripFirstH1(manualClean)))
  },
  {
    title: 'The Triad 2.0 Tutorial',
    data: rewriteRepositoryLinks(marked.parse(stripFirstH1(tutorialClean)))
  },
  {
    title: 'Back cover',
    data: `<div style="background:#0d0a0f;color:#f5f5f4;padding:1em;">
      <h1>The Book of Triad</h1>
      <p>Triad 2.0 is a standalone programming language, defined by a normative specification independent of any implementation.</p>
      <p>The project is released under the MIT license. SPEC.md (standard 0.2.0), SPEC-CORE.md, conformance/ with verifiable goldens.</p>
      <p>The goal is a standalone and recognised language: its own standard, executable conformance, the .triad extension, editor tooling, bootstrap without host languages and, finally, self-hosting.</p>
    </div>`
  }
];

const options = {
  title: 'The Book of Triad',
  author: 'GPuntobit',
  publisher: 'GPuntobit',
  description: 'The Book of Triad — learn the language and the code of the triad2.0 project',
  cover: path.join(outDir, 'frontespizio.png'),
  content: content,
  css: css,
  tocTitle: 'Index',
  version: 3,
  lang: 'en'
};

const epub = new Epub(options, path.join(outDir, 'The-Book-of-Triad.epub'));
epub.promise.then(() => {
  console.log('wrote The-Book-of-Triad.epub');
}).catch(err => {
  console.error('epub error:', err);
});