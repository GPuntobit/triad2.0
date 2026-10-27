import { readFileSync, writeFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { marked } from 'marked';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const outDir = join(root, 'docs', 'libro');

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

const preface = readFileSync(join(root, 'PREFazione.md'), 'utf8');
const prefaceHtml = marked.parse(preface);
const manualeRaw = readFileSync(join(root, 'MANUALE.md'), 'utf8');
const tutorialRaw = readFileSync(join(root, 'TUTORIAL.md'), 'utf8');

function stripIndice(md, heading, endMarker) {
  const start = md.indexOf(heading);
  if (start === -1) return md;
  const end = md.indexOf(endMarker, start);
  if (end === -1) return md;
  return md.slice(0, start) + md.slice(end);
}

const manuale = stripIndice(manualeRaw, '### Indice', '\n<a id="parte-1">');
const tutorial = stripIndice(tutorialRaw, '## Indice', '\n<a id="parte-1">');

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

const backCoverHtml = `<div class="backcover">
  <h1>Il libro di Triad</h1>
  <p>Triad 2.0 Ã¨ un linguaggio di programmazione autonomo, definito da una specifica normativa
  indipendente da qualsiasi implementazione. Non Ã¨ un dialetto di Julia, Prolog o Lisp, pur avendo
  preso da ciascuno di essi idee fondamentali: blocchi <code>function â€¦ end</code> e tipi con
  <code>::</code> da Julia, unificazione con occurs-check, backtracking e <code>solve</code> con
  variabili logiche <code>?x</code> da Prolog, codice come dato e macro da Lisp. CiÃ² che Ã¨ proprio
  di Triad, e non in prestito, Ã¨ l'integrazione dei tre modelli â€” imperativo, logico,
  metaprogrammatorio â€” in una sola sintassi a blocchi, accompagnata da errori come dati
  (<code>Err</code>), contratti (<code>requires</code>/<code>ensures</code>), budget
  (<code>with budget</code>), tracce (<code>with trace</code>) ed effetti dichiarati
  (<code>!io</code>, <code>!state</code>) come parte del linguaggio e non di una libreria.</p>
  <p>Il linguaggio si presenta in due profili di conformitÃ . Triad-Core Ã¨ il sottoinsieme di
  bootstrap: valori, funzioni, chiusure, controllo di flusso, liste, stringhe, I/O. Triad-Full Ã¨
  lo standard completo: tipi dichiarati, multiple dispatch, logica integrata, macro, contratti,
  budget, tracce, effetti. Ogni programma Core Ã¨ anche un programma Full valido e deve comportarsi
  allo stesso modo. Il runtime di riferimento Ã¨ il seed S0: un interprete Triad-Core scritto
  direttamente in codice macchina x86-64 (PE su Windows, ELF su Linux), senza alcun linguaggio
  ospite. Il piano di bootstrap prevede S1 (un interprete Triad scritto in Triad-Core), S2
  (compilatore nativo), S3 (self-hosting) e S4 (paritÃ  cross-platform).</p>
  <p>Questo libro Ã¨ il percorso di studio del linguaggio per come Ã¨ definito dallo standard. La
  prima parte, Fondamenti, introduce il lessico, i valori e i tipi, il controllo di flusso, le
  funzioni, il dispatch, la logica, il codice come dato, gli errori, i contratti, il budget, le
  tracce e gli effetti. La seconda, Triad-Core, copre il sottoinsieme eseguibile oggi dall'interprete
  di riferimento, con tutti i 37 casi di conformance. La terza, Triad-Full, presenta i costrutti
  dello standard completo, oggi studiabili ma non ancora eseguibili dal runtime. La quarta, Dentro
  il progetto, accompagna il lettore nel codice del repository: il seed, la suite di conformance,
  la CLI, gli strumenti per gli editor.</p>
  <p>Il progetto Ã¨ rilasciato sotto licenza MIT. La specifica normativa Ã¨ in SPEC.md (standard
  0.2.0), il sottoinsieme di bootstrap in SPEC-CORE.md, la suite di conformance in
  conformance/ con golden verificabili. Il repository include anche un benchmark per la generazione
  di codice Triad da LLM (ai/), grammatiche per VS Code e Vim, e un sito con la curva di
  apprendimento. L'obiettivo Ã¨ un linguaggio autonomo e riconosciuto: standard proprio,
  conformance eseguibile, estensione .triad, tooling editor, bootstrap senza linguaggi ospiti e,
  infine, self-hosting.</p>
  <p>La suite di conformance Ã¨ il contratto eseguibile del linguaggio: 37 casi Triad-Core e 12 casi
  Triad-Full, ognuno con golden verificabili byte per byte, inclusi l'exit code. Il runner Ã¨ scritto
  in Node e non dipende da Julia: il seed Windows passa 33 casi Core sul PE, il seed Linux Ã¨ in
  fase E0. Ogni caso dichiara il profilo (Core o Full) e un golden mancante fa fallire il caso,
  cosÃ¬ che nessuna implementazione possa registrare comportamenti scorretti come attesi. I test del
  progetto (unit e end-to-end) coprono parser, valutatore, unificazione, macro e CLI.</p>
  <p>Gli strumenti per gli editor includono grammatiche per VS Code e Vim/Neovim e una voce per
  GitHub Linguist, cosÃ¬ che i file <code>.triad</code> (canonica) e <code>.td</code> (alias storico)
  siano riconosciuti ovunque. Il sito del progetto espone la curva di apprendimento, i grafici delle
  fasi e una demo animata della battitura di un programma Triad-Core eseguito dall'interprete. Il
  repository Ã¨ organizzato per essere esplorato: esempi progressivi in <code>examples/</code>,
  task guidati in <code>ai/tasks/</code>, benchmark LLM in <code>ai/</code>. Ogni modifica Ã¨
  accompagnata da test e da aggiornamenti a STATUS.md, BOOTSTRAP.md e CHANGELOG.md.</p>
  <p>Questo libro Ã¨ scritto per lo standard 0.2.0. In caso di divergenza tra manuale e specifica,
  prevale la specifica: SPEC.md e SPEC-CORE.md sono la fonte di veritÃ  normativa, e questo volume
  ne Ã¨ il percorso di studio, con spiegazioni, esempi ed esercizi.</p>
</div>`;

const html = `<!DOCTYPE html>
<html lang="it">
<head>
<meta charset="utf-8">
<title>Il libro di Triad</title>
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
  pre { background: #0d0a0f; color: #f5f5f4; padding: 10pt 12pt; border-radius: 4pt; overflow-x: auto; page-break-inside: avoid; margin: 8pt 0; border-left: 3pt solid #d0405a; }
  pre code { background: none; color: inherit; padding: 0; font-size: 8.5pt; line-height: 1.4; }
  table { border-collapse: collapse; width: 100%; margin: 10pt 0; page-break-inside: avoid; font-size: 9.5pt; }
  th, td { border: 0.5pt solid #b8b0aa; padding: 4pt 6pt; }
  th { background: #ece8e4; font-weight: bold; }
  tr:nth-child(even) td { background: #f7f5f3; }
  img { max-width: 100%; }
  blockquote { border-left: 2pt solid #7d5157; margin: 8pt 0; padding: 4pt 10pt; color: #444; font-style: italic; background: #f9f7f5; }
  hr { border: none; border-top: 0.5pt solid #7d5157; margin: 14pt 0; }
  .cover { page-break-after: always; margin: 0; padding: 0; }
  .cover img { width: 100%; height: 100vh; object-fit: cover; display: block; }
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
  <div class="cover"><img src="frontespizio.png" alt="Frontespizio — Il libro di Triad" /></div>
  <div class="preface-page">
    ${prefaceHtml}
  </div>
  <div class="part">
    ${manualeHtml}
  </div>
  <div class="part">
    ${tutorialHtml}
  </div>
  <div class="backcover-page">
    ${backCoverHtml}
  </div>
</body>
</html>`;

writeFileSync(join(outDir, 'libro.html'), html, 'utf8');
console.log('scritto', join(outDir, 'libro.html'));
