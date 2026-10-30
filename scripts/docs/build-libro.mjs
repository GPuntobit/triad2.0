import { copyFileSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { marked } from 'marked';
const root = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
const outDir = join(root, 'docs', 'libro');
mkdirSync(outDir, { recursive: true });
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
const preface = readFileSync(join(root, 'docs', 'PREFazione.md'), 'utf8');
const prefaceHtml = rewriteRepositoryLinks(marked.parse(preface));
const manualRaw = readFileSync(join(root, 'docs', 'MANUALE.md'), 'utf8');
const tutorialRaw = readFileSync(join(root, 'tutorial', 'TUTORIAL.md'), 'utf8');
function stripIndex(md, heading, endMarker) {
  const start = md.indexOf(heading);
  if (start === -1) return md;
  const end = md.indexOf(endMarker, start);
  if (end === -1) return md;
  return md.slice(0, start) + md.slice(end);
}
function namespaceAnchors(md, prefix) {
  return md
    .replace(/id="(cap-\d+|part-\d+|parte-\d+|app-[a-z])"/g, (_, id) => `id="${prefix}-${id}"`)
    .replace(/href="#(cap-\d+|part-\d+|parte-\d+|app-[a-z])"/g, (_, id) => `href="#${prefix}-${id}"`)
    .replace(/\]\(#(cap-\d+|part-\d+|parte-\d+|app-[a-z])\)/g, (_, id) => `](#${prefix}-${id})`);
}
function rewriteRepositoryLinks(html) {
  const withLocalLogo = html.replace(
    'src="https://raw.githubusercontent.com/GPuntobit/triad2.0/main/docs/triad-logo.webp"',
    'src="triad-logo.webp"'
  );
  return withLocalLogo.replace(/href="([^"]+)"/g, (match, target) => {
    if (/^(?:https?:|mailto:|#)/.test(target)) return match;
    const path = target.replace(/^\.\//, '');
    const kind = path.endsWith('/') ? 'tree' : 'blob';
    return `href="https://github.com/GPuntobit/triad2.0/${kind}/main/${path}"`;
  });
}
const manual = namespaceAnchors(
  stripIndex(manualRaw, '### Index', '\n<a id="part-1">'),
  'man'
);
const tutorial = namespaceAnchors(
  stripIndex(tutorialRaw, '## Index', '\n<a id="part-1">'),
  'tut'
);
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
const manualToc = [];
const tutorialToc = [];
const manualHtml = rewriteRepositoryLinks(addHeadingIds(marked.parse(manual), 'man', manualToc));
const tutorialHtml = rewriteRepositoryLinks(addHeadingIds(marked.parse(tutorial), 'tut', tutorialToc));
function buildToc(groups) {
  let html = '<h1>Index</h1>\n';
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
  { label: 'Triad 2.0 Manual', entries: manualToc },
  { label: 'Triad 2.0 tutorial', entries: tutorialToc }
]);
const backCoverHtml = `<div class="backcover">
  <h1>The Book of Triad</h1>
  <p>Triad 2.0 is an autonomous programming language, defined by a specific regulation
  independent of any implementation. It is not a dialect of Julia, Prolog or Lisp, despite having
  taken from each of them fundamental ideas: <code>function … end</code> blocks and types with
  <code>::</code> from Julia, unification with occurs-check, backtracking and <code>solve</code> with
  <code>?x</code> logical variables from Prolog, code as data and macros from Lisp. What is proper
  of Triad, and not borrowed, is the integration of the three models — imperative, logical,
  metaprogramming — in a single block syntax, accompanied by errors as data
  (<code>Err</code>), contracts (<code>requires</code>/<code>ensures</code>), budget
  (<code>with budget</code>), traces (<code>with trace</code>) and declared effects
  (<code>!io</code>, <code>!state</code>) as part of the language and not a library.</p>
  <p>The language comes in two conformance profiles. Triad-Core is the subset of
  bootstrap: values, functions, closures, flow control, lists, strings, I/O. Triad-Full is
  the complete standard: declared types, multiple dispatch, integrated logic, macros, contracts,
  budget, tracks, effects. Every Core program is also a valid Full program and must behave
  the same way. The JavaScript reference interpreter runs Triad-Core; the S0 Windows seed
  is a distinct and more limited x86-64 machine code interpreter. The current Linux seed is
  still an E0 boot test, not an interpreter. The bootstrap plan involves S1 (an interpreter
  Triad written in Triad-Core), S2
  (native compiler), S3 (self-hosting), and S4 (cross-platform parity).</p>
  <p>This book is the study path of the language as it is defined by the standard. The
  Manual and Tutorial alternate conceptual explanations, technical semantics, annotated examples,
exercises and references to the specification. Each text presents concepts where they are needed
  and distinguishes constructs executable today from those defined by the standard but not yet supported.
  The Tutorial first accompanies the reader in the Core constructs executable today, then
  presents Triad-Full as a standard to study and finally shows how to read the implementations,
  the bootstrap and conformance suite in the repository. Block labels distinguish the
  code executable from code defined by the standard but not yet supported by the runtime.</p>
  <p>The project is released under the MIT license. The specific regulation is in SPEC.md (standard
  0.2.0), the bootstrap subset in SPEC-CORE.md, the conformance suite in
  conformance/ with verifiable golden. The repository also includes a benchmark for the build
  of Triad code from LLM (ai/), grammars for VS Code and Vim, and a site with the
  learning. The goal is an autonomous and recognized language: own standard,
  conformance executable, .triad extension, tooling editor, bootstrap without guest languages and,
  finally, self-hosting.</p>
  <p>The conformance suite is the executable contract of the language. The reference interpreter
  JavaScript passes all 37 Core cases; the Windows seed passes supported cases and leaves out
  by default the <code>liste</code> case, which requires standard indexing. The Linux seed is
  still at the E0 stage and only prints a startup message. The Full profile is defined by
  standard, but the current runtime does not yet implement the complete language; the outputs
  labeled golden are expected results stored in the suite files. Each Core case states
  output and exit code, so that an implementation can be compared to a contract
  reproducible, not with an isolated example.</p>
  <p>Editor tools include grammars for VS Code and Vim/Neovim and an entry for
GitHub Linguist, so that the <code>.triad</code> (canonical) and <code>.td</code> (historical alias) files
  are recognized everywhere. The project website exposes the learning curve, the graphs of the
  steps and an animated demo of typing a Triad-Core program executed by the interpreter. The
  repository is organized to be explored: progressive examples in <code>examples/</code>,
  guided tasks in <code>ai/tasks/</code>, LLM benchmarks in <code>ai/</code>. Every change is
  accompanied by tests and updates to STATUS.md, BOOTSTRAP.md and CHANGELOG.md.</p>
  <p>This book is written for the 0.2.0 standard. In case of discrepancy between manual and specification,
  specification prevails: SPEC.md and SPEC-CORE.md are the source of normative truth, and this volume
  is the study path, with explanations, examples and exercises.</p>
</div>`;
const html = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>The Book of Triad</title>
<style>
  @page { size: 152.4mm 228.6mm; margin: 15mm 12mm; @bottom-center { content: counter(page); font-size: 9pt; color: #666; } }
  @page :first { margin: 0; }
  html, body { font-family: 'Liberation Serif', 'Times New Roman', 'DejaVu Serif', Georgia, serif; font-size: 10.5pt; line-height: 1.6; color: #1a1a1a; }
  h1, h2, h3, h4 { font-family: 'Liberation Sans', 'Helvetica Neue', Arial, sans-serif; color: #0d0a0f; page-break-after: avoid; margin-top: 18pt; margin-bottom: 6pt; }
  h1 { font-size: 18pt; margin-top: 24pt; border-bottom: 1.2pt solid #7d5157; padding-bottom: 4pt; }
  h2 { font-size: 13.5pt; margin-top: 16pt; color: #2a1a1f; }
  h3 { font-size: 11.5pt; margin-top: 12pt; color: #3a2a2f; }
  p { margin: 6pt 0 8pt 0; text-align: justify; orphans: 3; widows: 3; text-indent: 0; }
  p + p { text-indent: 1.2em; margin-top: 0; }
  a { color: #d0405a; text-decoration: none; }
  code { font-family: 'JetBrains Mono', 'DejaVu Sans Mono', Consolas, monospace; font-size: 9pt; background: #f3f1f4; padding: 1pt 3pt; border-radius: 2pt; }
  pre { background: #f3f1f4; color: #1a1a1a; padding: 10pt 12pt; border-radius: 4pt; overflow-x: auto; margin: 8pt 0; border-left: 3pt solid #d0405a; }
  pre code { background: none; color: inherit; padding: 0; font-size: 8.5pt; line-height: 1.4; }
  table { border-collapse: collapse; width: 100%; margin: 10pt 0; font-size: 9.5pt; }
  th, td { border: 0.5pt solid #b8b0aa; padding: 4pt 6pt; }
  th { background: #ece8e4; font-weight: bold; }
  tr:nth-child(even) td { background: #f7f5f3; }
  img { max-width: 100%; }
  blockquote { border-left: 2pt solid #7d5157; margin: 8pt 0; padding: 4pt 10pt; color: #444; font-style: italic; background: #f9f7f5; }
  hr { border: none; border-top: 0.5pt solid #7d5157; margin: 14pt 0; }
.cover { page-break-after: always; display: flex; align-items: center; justify-content: center; margin: 0; padding: 0; text-align: center; }
  .cover img { max-width: 100%; max-height: 100%; width: auto; height: car; display: block; margin: auto; }
  .index-page { page-break-after: always; }
  .summary-list { list-style: none; padding-left: 0; }
  .summary-list .sl1 { font-weight: bold; margin-top: 8pt; }
  .summary-list .sl2 { padding-left: 14pt; font-size: 10pt; }
  .summary-list .sl3 { padding-left: 28pt; font-size: 9pt; }
  .summary-intro { font-style: italic; color: #555; font-size: 10pt; }
  .preface-page { page-break-after: always; }
  .backcover-page { page-break-before: always; }
  .backcover { background: #0d0a0f; color: #f5f5f4; padding: 24pt 18pt; min-height: 100%; }
  .backcover h1 { color: #f5f5f4; border-color: #7d5157; }
  .backcover p { text-align: justify; font-size: 10.5pt; line-height: 1.6; }
  .backcover code { background: #1a1520; color: #f5f5f4; }
  .toc { page-break-after: always; }
  .toc-list { list-style: none; padding-left: 0; }
  .toc-list li { margin: 2pt 0; font-size: 10pt; }
  .toc-list .toc-l1 { font-weight: bold; margin-top: 8pt; }
  .toc-list .toc-l2 { padding-left: 14pt; }
  .toc-list .toc-l3 { padding-left: 28pt; font-size: 9pt; }
  .part { page-break-before: always; }
  ul, ol { margin: 6pt 0 8pt 18pt; }
  li { margin: 3pt 0; }
  strong { color: #0d0a0f; }
</style>
</head>
<body>
  <div class="cover" style="text-align:center"><img src="frontespizio.png" alt="Frontespizio — The book of Triad" /></div>
  <div class="preface-page">
    ${prefaceHtml}
  </div>
  <div class="index-page">
    ${tocHtml}
  </div>
  <div class="part">
    ${manualHtml}
  </div>
  <div class="part">
    ${tutorialHtml}
  </div>
  <div class="backcover-page">
    ${backCoverHtml}
  </div>
</body>
</html>`;
writeFileSync(join(outDir, 'book.html'), html, 'utf8');
copyFileSync(join(root, 'docs', 'triad-logo.webp'), join(outDir, 'triad-logo.webp'));
console.log('written', join(outDir, 'book.html'));
