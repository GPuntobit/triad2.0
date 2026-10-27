import { readFileSync, writeFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { marked } from 'marked';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const outDir = join(root, 'docs', 'libro');

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

function buildSommarioHtml() {
  const manH = extractHeadings(manuale, 2);
  const tutH = extractHeadings(tutorial, 2);
  let html = '<h1>Sommario</h1>\n';
  html += '<p class="sommario-intro">Elenco dei capitoli e delle sezioni principali.</p>\n';
  html += '<h2>Manuale di Triad 2.0</h2>\n<ul class="sommario-list">\n';
  for (const h of manH) {
    html += '<li class="sl' + h.level + '">' + h.text + '</li>\n';
  }
  html += '</ul>\n';
  html += '<h2>Tutorial di Triad 2.0</h2>\n<ul class="sommario-list">\n';
  for (const h of tutH) {
    html += '<li class="sl' + h.level + '">' + h.text + '</li>\n';
  }
  html += '</ul>\n';
  return html;
}

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

const manuale = readFileSync(join(root, 'MANUALE.md'), 'utf8');
const tutorial = readFileSync(join(root, 'TUTORIAL.md'), 'utf8');

const sommarioHtml = buildSommarioHtml();

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
  <p>Triad 2.0 è un linguaggio di programmazione autonomo, definito da una specifica normativa
  indipendente da qualsiasi implementazione. Non è un dialetto di Julia, Prolog o Lisp, pur avendo
  preso da ciascuno di essi idee fondamentali: blocchi <code>function … end</code> e tipi con
  <code>::</code> da Julia, unificazione con occurs-check, backtracking e <code>solve</code> con
  variabili logiche <code>?x</code> da Prolog, codice come dato e macro da Lisp. Ciò che è proprio
  di Triad, e non in prestito, è l'integrazione dei tre modelli — imperativo, logico,
  metaprogrammatorio — in una sola sintassi a blocchi, accompagnata da errori come dati
  (<code>Err</code>), contratti (<code>requires</code>/<code>ensures</code>), budget
  (<code>with budget</code>), tracce (<code>with trace</code>) ed effetti dichiarati
  (<code>!io</code>, <code>!state</code>) come parte del linguaggio e non di una libreria.</p>
  <p>Il linguaggio si presenta in due profili di conformità. Triad-Core è il sottoinsieme di
  bootstrap: valori, funzioni, chiusure, controllo di flusso, liste, stringhe, I/O. Triad-Full è
  lo standard completo: tipi dichiarati, multiple dispatch, logica integrata, macro, contratti,
  budget, tracce, effetti. Ogni programma Core è anche un programma Full valido e deve comportarsi
  allo stesso modo. Il runtime di riferimento è il seed S0: un interprete Triad-Core scritto
  direttamente in codice macchina x86-64 (PE su Windows, ELF su Linux), senza alcun linguaggio
  ospite. Il piano di bootstrap prevede S1 (un interprete Triad scritto in Triad-Core), S2
  (compilatore nativo), S3 (self-hosting) e S4 (parità cross-platform).</p>
  <p>Questo libro è il percorso di studio del linguaggio per come è definito dallo standard. La
  prima parte, Fondamenti, introduce il lessico, i valori e i tipi, il controllo di flusso, le
  funzioni, il dispatch, la logica, il codice come dato, gli errori, i contratti, il budget, le
  tracce e gli effetti. La seconda, Triad-Core, copre il sottoinsieme eseguibile oggi dall'interprete
  di riferimento, con tutti i 37 casi di conformance. La terza, Triad-Full, presenta i costrutti
  dello standard completo, oggi studiabili ma non ancora eseguibili dal runtime. La quarta, Dentro
  il progetto, accompagna il lettore nel codice del repository: il seed, la suite di conformance,
  la CLI, gli strumenti per gli editor.</p>
  <p>Il progetto è rilasciato sotto licenza MIT. La specifica normativa è in SPEC.md (standard
  0.2.0), il sottoinsieme di bootstrap in SPEC-CORE.md, la suite di conformance in
  conformance/ con golden verificabili. Il repository include anche un benchmark per la generazione
  di codice Triad da LLM (ai/), grammatiche per VS Code e Vim, e un sito con la curva di
  apprendimento. L'obiettivo è un linguaggio autonomo e riconosciuto: standard proprio,
  conformance eseguibile, estensione .triad, tooling editor, bootstrap senza linguaggi ospiti e,
  infine, self-hosting.</p>
  <p>La suite di conformance è il contratto eseguibile del linguaggio: 37 casi Triad-Core e 12 casi
  Triad-Full, ognuno con golden verificabili byte per byte, inclusi l'exit code. Il runner è scritto
  in Node e non dipende da Julia: il seed Windows passa 33 casi Core sul PE, il seed Linux è in
  fase E0. Ogni caso dichiara il profilo (Core o Full) e un golden mancante fa fallire il caso,
  così che nessuna implementazione possa registrare comportamenti scorretti come attesi. I test del
  progetto (unit e end-to-end) coprono parser, valutatore, unificazione, macro e CLI.</p>
  <p>Gli strumenti per gli editor includono grammatiche per VS Code e Vim/Neovim e una voce per
  GitHub Linguist, così che i file <code>.triad</code> (canonica) e <code>.td</code> (alias storico)
  siano riconosciuti ovunque. Il sito del progetto espone la curva di apprendimento, i grafici delle
  fasi e una demo animata della battitura di un programma Triad-Core eseguito dall'interprete. Il
  repository è organizzato per essere esplorato: esempi progressivi in <code>examples/</code>,
  task guidati in <code>ai/tasks/</code>, benchmark LLM in <code>ai/</code>. Ogni modifica è
  accompagnata da test e da aggiornamenti a STATUS.md, BOOTSTRAP.md e CHANGELOG.md.</p>
  <p>Questo libro è scritto per lo standard 0.2.0. In caso di divergenza tra manuale e specifica,
  prevale la specifica: SPEC.md e SPEC-CORE.md sono la fonte di verità normativa, e questo volume
  ne è il percorso di studio, con spiegazioni, esempi ed esercizi.</p>
</div>`;

const html = `<!DOCTYPE html>
<html lang="it">
<head>
<meta charset="utf-8">
<title>Il libro di Triad</title>
<style>
  @page { size: A4; margin: 20mm 18mm; @bottom-center { content: counter(page); font-size: 9pt; color: #666; } }
  @page :first { margin: 0; }
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
  .cover { page-break-after: always; margin: 0; padding: 0; }
  .cover img { width: 100%; height: 100vh; object-fit: cover; display: block; }
  .backcover-page { page-break-before: always; }
  .backcover { background: #0d0a0f; color: #f5f5f4; padding: 24pt 18pt; min-height: 100%; }
  .backcover h1 { color: #f5f5f4; border-color: #7d5157; }
  .backcover p { text-align: justify; font-size: 10.5pt; line-height: 1.6; }
  .backcover code { background: #1a1520; color: #f5f5f4; }
  .sommario-page { page-break-after: always; }
  .sommario-list { list-style: none; padding-left: 0; }
  .sommario-list .sl1 { font-weight: bold; margin-top: 8pt; }
  .sommario-list .sl2 { padding-left: 14pt; font-size: 10pt; }
  .sommario-intro { font-style: italic; color: #555; font-size: 10pt; }
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
  <div class="sommario-page">
    ${sommarioHtml}
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