import { readFileSync, writeFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { marked } from 'marked';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const outDir = join(root, 'docs', 'libro');

const manuale = readFileSync(join(root, 'MANUALE.md'), 'utf8');
const tutorial = readFileSync(join(root, 'TUTORIAL.md'), 'utf8');

marked.setOptions({ gfm: true, breaks: false });

function slugify(s) {
  return String(s).toLowerCase()
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '') || 'section';
}

function addHeadingIds(html, prefix, toc) {
  const used = new Set();
  let firstH1 = true;
  return html.replace(/<h([1-6])>([\s\S]*?)<\/h\1>/g, (m, level, text) => {
    const plain = text.replace(/<[^>]+>/g, '').trim();
    if (level === '1' && firstH1) { firstH1 = false; return m; }
    const base = prefix + '-' + slugify(plain);
    let slug = base;
    let n = 1;
    while (used.has(slug)) { slug = base + '-' + n++; }
    used.add(slug);
    toc.push({ level: +level, text: plain, slug });
    return '<h' + level + ' id="' + slug + '">' + text + '</h' + level + '>';
  });
}

const manualeToc = [];
const tutorialToc = [];
const manualeHtml = addHeadingIds(marked.parse(manuale), 'man', manualeToc);
const tutorialHtml = addHeadingIds(marked.parse(tutorial), 'tut', tutorialToc);

function buildToc(groups) {
  let html = '<h1>Indice</h1>\n';
  for (const g of groups) {
    html += '<h2>' + g.label + '</h2>\n<ul class="toc-list">\n';
    for (const e of g.entries) {
      html += '<li class="toc-l' + e.level + '"><a href="#' + e.slug + '">' + e.text + '</a></li>\n';
    }
    html += '</ul>\n';
  }
  return html;
}

const tocHtml = buildToc([
  { label: 'Manuale di Triad 2.0', entries: manualeToc },
  { label: 'Tutorial di Triad 2.0', entries: tutorialToc }
]);

const html = `<!DOCTYPE html>
<html lang="it">
<head>
<meta charset="utf-8">
<title>Il libro di Triad</title>
<style>
  @page { size: A4; margin: 20mm 18mm; }
  html, body { font-family: 'Liberation Serif', 'Times New Roman', 'DejaVu Serif', Georgia, serif; font-size: 11pt; line-height: 1.5; color: #1a1a1a; }
  h1, h2, h3, h4 { font-family: 'Liberation Sans', 'Helvetica Neue', Arial, sans-serif; color: #0d0a0f; page-break-after: avoid; }
  h1 { font-size: 20pt; margin-top: 24pt; border-bottom: 1pt solid #7d5157; padding-bottom: 4pt; }
  h2 { font-size: 15pt; margin-top: 18pt; }
  h3 { font-size: 12.5pt; margin-top: 14pt; }
  p { margin: 6pt 0; text-align: justify; }
  a { color: #d0405a; text-decoration: none; }
  code { font-family: 'JetBrains Mono', 'DejaVu Sans Mono', Consolas, monospace; font-size: 9.5pt; background: #f3f1f4; padding: 1pt 3pt; border-radius: 2pt; }
  pre { background: #0d0a0f; color: #f5f5f4; padding: 10pt; border-radius: 4pt; overflow-x: auto; page-break-inside: avoid; }
  pre code { background: none; color: inherit; padding: 0; font-size: 9pt; }
  table { border-collapse: collapse; width: 100%; margin: 8pt 0; page-break-inside: avoid; }
  th, td { border: 0.5pt solid #b8b0aa; padding: 4pt 6pt; font-size: 9.5pt; }
  th { background: #ece8e4; font-weight: bold; }
  img { max-width: 100%; }
  blockquote { border-left: 2pt solid #7d5157; margin: 8pt 0; padding: 4pt 10pt; color: #444; font-style: italic; }
  hr { border: none; border-top: 0.5pt solid #7d5157; margin: 12pt 0; }
  .cover { page-break-after: always; text-align: center; }
  .cover img { width: 100%; height: auto; }
  .toc { page-break-after: always; }
  .toc-list { list-style: none; padding-left: 0; }
  .toc-list li { margin: 2pt 0; font-size: 10pt; }
  .toc-list .toc-l1 { font-weight: bold; margin-top: 8pt; }
  .toc-list .toc-l2 { padding-left: 14pt; }
  .toc-list .toc-l3 { padding-left: 28pt; font-size: 9pt; }
  .part { page-break-before: always; }
  ul, ol { margin: 6pt 0 6pt 18pt; }
  li { margin: 2pt 0; }
</style>
</head>
<body>
  <div class="cover"><img src="frontespizio.png" alt="Frontespizio — Il libro di Triad" /></div>
  <div class="toc">${tocHtml}</div>
  <div class="part">
    ${manualeHtml}
  </div>
  <div class="part">
    ${tutorialHtml}
  </div>
</body>
</html>`;

writeFileSync(join(outDir, 'libro.html'), html, 'utf8');
console.log('scritto', join(outDir, 'libro.html'));