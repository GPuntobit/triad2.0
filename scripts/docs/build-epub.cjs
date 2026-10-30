const fs = require('fs');
const path = require('path');
const marked = require('marked');
const Epub = require('epub-gen');
const root = path.join(__dirname, '..', '..');
const outDir = path.join(root, 'docs', 'libro');
fs.mkdirSync(outDir, { recursive: true });
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
// Remove internal indexes
function stripIndex(md, heading, endMarker) {
  const start = md.indexOf(heading);
  if (start === -1) return md;
  const end = md.indexOf(endMarker, start);
  if (end === -1) return md;
  return md.slice(0, start) + md.slice(end);
}
const manualClean = stripIndex(manual, '### Index', '\n<a id="part-1">');
const tutorialClean = stripIndex(tutorial, '## Index', '\n<a id="part-1">');
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
let summaryHtml = '<p>Complete list of all chapters and sections.</p>';
summaryHtml += '<h2>Triad 2.0 Handbook</h2><ul>';
for (const h of manH) summaryHtml += '<li>' + h.text + '</li>';
summaryHtml += '</ul>';
summaryHtml += '<h2>Triad 2.0 Tutorial</h2><ul>';
for (const h of tutH) summaryHtml += '<li>' + h.text + '</li>';
summaryHtml += '</ul>';
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
const contents = [
  {
    title: 'Preface',
    data: rewriteRepositoryLinks(marked.parse(stripFirstH1(preface)))
  },
  {
    title: 'Summary',
    data: summaryHtml
  },
  {
    title: 'Triad Manual 2.0',
    data: rewriteRepositoryLinks(marked.parse(stripFirstH1(manualClean)))
  },
  {
    title: 'Triad 2.0 Tutorial',
    data: rewriteRepositoryLinks(marked.parse(stripFirstH1(tutorialClean)))
  },
  {
    title: 'Back cover',
    data: `<div style="background:#0d0a0f;color:#f5f5f4;padding:1em;">
      <h1>The Book of Triad</h1>
      <p>Triad 2.0 is an autonomous programming language, defined by a specific regulation independent of any implementation.</p>
      <p>The project is released under the MIT license. SPEC.md (standard 0.2.0), SPEC-CORE.md, conformance/ with verifiable golden.</p>
      <p>The goal is an autonomous and recognized language: own standard, conformance executable, .triad extension, tooling editor, bootstrap without guest languages and self-hosting.</p>
    </div>`
  }
];
const options = {
  title: 'The Book of Triad',
  author: 'GPuntobit',
  publisher: 'GPuntobit',
  description: 'The Triad book — learning the language and code of the triad2.0 project',
  cover: fs.existsSync(path.join(outDir, 'frontespizio.png')) ? path.join(outDir, 'frontespizio.png') : undefined,
  content: contents,
  css: css,
  tocTitle: 'Index',
  version: 3,
  lang: 'it'
};
const epub = new Epub(options, path.join(outDir, 'The-book-of-Triad.epub'));
epub.promise.then(() => {
  console.log('written book.epub');
}).catch(err => {
  console.error('epub error:', err);
});
