// Genera docs/libro/Il-libro-di-triad.pdf da docs/libro/libro.html usando il motore di
// stampa di Chrome/Edge (headless) invece di calibre.
//
// Perché non calibre: il writer PDF di calibre (9.17) corrompe i glifi composti durante
// il subsetting dei font — tutte le lettere accentate dell'italiano (è, à, ù, …) e gli
// em-dash vengono renderizzati come riquadri vuoti (tofu) in ogni viewer, benché il testo
// estratto sia corretto. Il motore di stampa di Chrome (PDFium) incorpora i font
// correttamente e rispetta le regole CSS @page del libro (formato 152.4mm x 228.6mm,
// margini, page-break) e le margin box CSS: il numero di pagina arriva da
// @bottom-center, senza header/footer template di puppeteer (che stamperebbero
// un numero anche sulla copertina).
//
// Uso: node scripts/docs/build-pdf.mjs [input.html] [output.pdf]
// (richiede Chrome o Edge installati; senza argomenti: docs/libro/libro.html)

import { existsSync, mkdirSync, readFileSync } from 'node:fs';
import { join, dirname, resolve } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import puppeteer from 'puppeteer-core';

const root = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
const outDir = join(root, 'docs', 'libro');
const input = process.argv[2] ? resolve(process.argv[2]) : join(outDir, 'libro.html');
const output = process.argv[3] ? resolve(process.argv[3]) : join(outDir, 'Il-libro-di-triad.pdf');
mkdirSync(dirname(output), { recursive: true });

const candidates = [
  process.env.PUPPETEER_EXECUTABLE_PATH,
  process.env.CHROME_PATH,
  'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
  'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe',
  'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe',
  'C:\\Program Files\\Microsoft\\Edge\\Application\\msedge.exe'
].filter(Boolean);

const executablePath = candidates.find((p) => existsSync(p));
if (!executablePath) {
  console.error('nessun browser trovato: imposta PUPPETEER_EXECUTABLE_PATH');
  process.exit(2);
}

// --- verifica margini KDP ------------------------------------------------
// KDP rifiuta l'interno del libro se il gutter (margine interno) e' insufficiente.
// Soglie per numero di pagine (inches): 24-150: 0.375", 151-300: 0.5",
// 301-400: 0.625", 401-500: 0.75", 501-700: 0.875", 701-828: 1".
// I margini esterno/superiore/inferiore devono essere >= 0.25" (6.35mm).
const KDP_OUTER_MM = 6.35;
const kdpGutterMm = (pages) =>
  pages <= 150 ? 9.525 : pages <= 300 ? 12.7 : pages <= 400 ? 15.875 :
  pages <= 500 ? 19.05 : pages <= 700 ? 22.225 : 25.4;

function marginMm(token) {
  const m = /^([\d.]+)(mm|cm|in|pt)?$/.exec(token.trim());
  if (!m) return null;
  const n = parseFloat(m[1]);
  return { mm: n, cm: n * 10, in: n * 25.4, pt: (n * 25.4) / 72 }[m[2] || 'mm'];
}

// Legge lo shorthand `margin:` del blocco @page (base, :left, :right) dal CSS
// dell'input e restituisce {top,right,bottom,left} in mm, oppure null.
function pageMargins(css, pseudo) {
  const block = new RegExp('@page\\s*' + pseudo + '\\s*\\{([^}]*)', 'm').exec(css);
  if (!block) return null;
  const decl = /(?:^|[;{])\s*margin\s*:([^;}]*)/.exec(block[1]);
  if (!decl) return null;
  const vals = decl[1].trim().split(/\s+/).map(marginMm);
  if (!vals.length || vals.some((v) => v === null)) return null;
  const [top, right = top, bottom = top, left = right] = vals;
  return { top, right, bottom, left };
}

function checkKdpMargins(pdf, css) {
  const pages = (Buffer.from(pdf).toString('latin1').match(/\/Type\s*\/Page(?![sA-Za-z])/g) || []).length;
  const base = pageMargins(css, '');
  const right = pageMargins(css, ':right') || base; // pagine dispari (recto)
  const left = pageMargins(css, ':left') || base;   // pagine pari (verso)
  if (!pages || !right || !left) {
    console.warn('verifica margini KDP saltata: conteggio pagine o margini @page non leggibili');
    return;
  }
  // Il gutter e' il margine interno: sinistra nelle pagine dispari, destra nelle pari.
  const gutter = Math.min(right.left, left.right);
  const outer = Math.min(right.right, left.left);
  const vert = Math.min(right.top, right.bottom, left.top, left.bottom);
  const gutterReq = kdpGutterMm(pages);
  const problems = [];
  if (gutter < gutterReq) problems.push(`gutter ${gutter}mm < ${gutterReq}mm (KDP, ${pages} pagine)`);
  if (outer < KDP_OUTER_MM) problems.push(`margine esterno ${outer}mm < ${KDP_OUTER_MM}mm`);
  if (vert < KDP_OUTER_MM) problems.push(`margini sopra/sotto ${vert}mm < ${KDP_OUTER_MM}mm`);
  if (problems.length) {
    console.error('MARGINI KDP INSUFFICIENTI:', problems.join('; '));
    process.exit(3);
  }
  console.log(`margini KDP ok: ${pages} pagine, gutter ${gutter}mm (min ${gutterReq}mm), esterno ${outer}mm, sopra/sotto ${vert}mm`);
}

const browser = await puppeteer.launch({
  executablePath,
  headless: true,
  args: ['--no-sandbox', '--disable-gpu', '--font-render-hinting=none']
});

try {
  const page = await browser.newPage();
  await page.goto(pathToFileURL(input).href, { waitUntil: 'networkidle0', timeout: 300000 });

  // I blocchi <details> (le soluzioni degli esercizi) sono collassati: il motore di
  // stampa non raffigura il contenuto chiuso, quindi li apriamo tutti prima del print.
  await page.evaluate(() => {
    document.querySelectorAll('details').forEach((d) => { d.open = true; });
  });

  const pdfOptions = {
    path: output,
    printBackground: true,
    preferCSSPageSize: true
    // I numeri di pagina arrivano dalla margin box CSS @bottom-center (Chrome la
    // supporta): la copertina non ha numero grazie a @page :first { content: none }.
    // Niente header/footer template di puppeteer: avrebbero stampato "1" sulla copertina
    // e un secondo numero duplicato accanto a quello della margin box.
  };

  let pdf;
  try {
    // Genera anche i segnalibri PDF dai titoli (Chrome >= 117).
    pdf = await page.pdf({ ...pdfOptions, outline: true });
  } catch (err) {
    console.warn('outline non supportato, riprovo senza:', err.message);
    pdf = await page.pdf(pdfOptions);
  }
  console.log('scritto', output);
  checkKdpMargins(pdf, readFileSync(input, 'utf8'));
} finally {
  await browser.close();
}
