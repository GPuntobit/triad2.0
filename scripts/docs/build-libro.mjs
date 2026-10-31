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
  // ReDoS-safe heading matcher: linear scan instead of the nested-quantifier
  // regex /<h([1-6])>([\s\S]*?)<\/h\1>/g, which CodeQL flags as polynomial.
  // Semantics preserved: only bare <hN> tags (no attributes) are processed and
  // each match consumes up to its closing </hN>, so nested headings are handled
  // by subsequent iterations exactly like the original global regex did.
  const headings = [];
  const openRe = /<h([1-6])>/g;
  let om;
  while ((om = openRe.exec(html)) !== null) {
    const close = html.indexOf('</h' + om[1] + '>', om.index);
    if (close === -1) continue;
    headings.push({ start: om.index, end: close + om[0].length + om[1].length, level: om[1], textStart: om.index + om[0].length, textEnd: close });
    openRe.lastIndex = close;
  }
  let cursor = 0;
  let out = '';
  for (const h of headings) {
    if (h.start < cursor) continue;
    out += html.slice(cursor, h.start);
    const m = html.slice(h.start, h.end);
    const level = h.level;
    const text = html.slice(h.textStart, h.textEnd);
    const plain = text.replace(/<[^>]+>/g, '').trim();
    if (level === '1' && firstH1) { firstH1 = false; out += m; cursor = h.end; continue; }
    const base = prefix + '-' + slugify(plain);
    let slug = base;
    let n = 1;
    while (used.has(slug)) { slug = base + '-' + n++; }
    used.add(slug);
    toc.push({ level: +level, text: plain, slug });
    out += '<h' + level + ' id="' + slug + '">' + text + '</h' + level + '>';
    cursor = h.end;
  }
  out += html.slice(cursor);
  return out;
}

const preface = readFileSync(join(root, 'docs', 'PREFazione.md'), 'utf8');
const prefaceHtml = rewriteRepositoryLinks(marked.parse(preface));
const manualeRaw = readFileSync(join(root, 'docs', 'MANUALE.md'), 'utf8');
const tutorialRaw = readFileSync(join(root, 'tutorial', 'TUTORIAL.md'), 'utf8');

function stripIndice(md, heading, endMarker) {
  const start = md.indexOf(heading);
  if (start === -1) return md;
  const end = md.indexOf(endMarker, start);
  if (end === -1) return md;
  return md.slice(0, start) + md.slice(end);
}

function namespaceAnchors(md, prefix) {
  return md
    .replace(/id="(cap-\d+|parte-\d+|app-[a-z])"/g, (_, id) => `id="${prefix}-${id}"`)
    .replace(/href="#(cap-\d+|parte-\d+|app-[a-z])"/g, (_, id) => `href="#${prefix}-${id}"`)
    .replace(/\]\(#(cap-\d+|parte-\d+|app-[a-z])\)/g, (_, id) => `](#${prefix}-${id})`);
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

const manuale = namespaceAnchors(
  stripIndice(manualeRaw, '### Indice', '\n<a id="parte-1">'),
  'man'
);
const tutorial = namespaceAnchors(
  stripIndice(tutorialRaw, '## Indice', '\n<a id="parte-1">'),
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

const manualeToc = [];
const tutorialToc = [];
const manualeHtml = rewriteRepositoryLinks(addHeadingIds(marked.parse(manuale), 'man', manualeToc));
const tutorialHtml = rewriteRepositoryLinks(addHeadingIds(marked.parse(tutorial), 'tut', tutorialToc));

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
  allo stesso modo. L'interprete di riferimento JavaScript esegue Triad-Core; il seed S0 Windows
  è un interprete in codice macchina x86-64 distinto e più limitato. Il seed Linux attuale è
  ancora un test di avvio E0, non un interprete. Il piano di bootstrap prevede S1 (un interprete
  Triad scritto in Triad-Core), S2
  (compilatore nativo), S3 (self-hosting) e S4 (parità cross-platform).</p>
  <p>Questo libro è il percorso di studio del linguaggio per come è definito dallo standard. Il
  Manuale e il Tutorial alternano spiegazioni concettuali, semantica tecnica, esempi annotati,
  esercizi e riferimenti alla specifica. Ciascun testo presenta i concetti nel punto in cui servono
  e distingue i costrutti eseguibili oggi da quelli definiti dallo standard ma non ancora supportati.
  Il Tutorial accompagna prima il lettore nei costrutti Core eseguibili oggi, poi
  presenta Triad-Full come standard da studiare e infine mostra come leggere le implementazioni,
  il bootstrap e la suite di conformance nel repository. Le etichette dei blocchi distinguono il
  codice eseguibile dal codice definito dallo standard ma non ancora supportato dal runtime.</p>
  <p>Il progetto è rilasciato sotto licenza MIT. La specifica normativa è in SPEC.md (standard
  0.2.0), il sottoinsieme di bootstrap in SPEC-CORE.md, la suite di conformance in
  conformance/ con golden verificabili. Il repository include anche un benchmark per la generazione
  di codice Triad da LLM (ai/), grammatiche per VS Code e Vim, e un sito con la curva di
  apprendimento. L'obiettivo è un linguaggio autonomo e riconosciuto: standard proprio,
  conformance eseguibile, estensione .triad, tooling editor, bootstrap senza linguaggi ospiti e,
  infine, self-hosting.</p>
  <p>La suite di conformance è il contratto eseguibile del linguaggio. L'interprete di riferimento
  JavaScript passa tutti i 37 casi Core; il seed Windows passa i casi supportati e lascia fuori
  per default il caso <code>liste</code>, che richiede l'indicizzazione standard. Il seed Linux è
  ancora allo stadio E0 e stampa solo un messaggio di avvio. Il profilo Full è definito dallo
  standard, ma il runtime corrente non implementa ancora il linguaggio completo; gli output
  etichettati golden sono risultati attesi conservati nei file della suite. Ogni caso Core dichiara
  output e codice di uscita, così che un'implementazione possa essere confrontata con un contratto
  riproducibile, non con un esempio isolato.</p>
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
  .cover img { max-width: 100%; max-height: 100%; width: auto; height: auto; display: block; margin: auto; }
  .index-page { page-break-after: always; }
  .sommario-list { list-style: none; padding-left: 0; }
  .sommario-list .sl1 { font-weight: bold; margin-top: 8pt; }
  .sommario-list .sl2 { padding-left: 14pt; font-size: 10pt; }
  .sommario-list .sl3 { padding-left: 28pt; font-size: 9pt; }
  .sommario-intro { font-style: italic; color: #555; font-size: 10pt; }
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
  <div class="cover" style="text-align:center"><img src="frontespizio.png" alt="Frontespizio — Il libro di Triad" /></div>
  <div class="preface-page">
    ${prefaceHtml}
  </div>
  <div class="index-page">
    ${tocHtml}
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
copyFileSync(join(root, 'docs', 'triad-logo.webp'), join(outDir, 'triad-logo.webp'));
console.log('scritto', join(outDir, 'libro.html'));
