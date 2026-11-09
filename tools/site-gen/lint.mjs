#!/usr/bin/env node
// =====================================================================
//  lint.mjs — controlla che i generatori Triad del sito restino nel
//  sottoinsieme Triad-Core "portabile", cioè quello che il seed PE
//  nativo e l'interprete di riferimento JS eseguono con lo stesso
//  risultato (stdout identico byte per byte, stesso exit code).
//
//  I limiti non sono ipotesi: sono stati misurati con
//  tests/probes/run_probes.mjs (matrice seed vs interprete JS).
//
//  Uso:  node tools/site-gen/lint.mjs [file.td ...]
//  Esci con 1 se c'è almeno un errore.
// =====================================================================
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(HERE, '..', '..');

const BOOTSTRAP_ONLY = new Set(['readfile', 'strlen', 'strbyte', 'strsub', 'ARGS']);

/** Tokenizza il sorgente Triad: stringhe, commenti, identificatori, numeri, punteggiatura. */
function tokenize(src, file) {
  const tokens = [];
  const errors = [];
  let i = 0;
  let line = 1;
  while (i < src.length) {
    const c = src[i];
    if (c === '\n') { line++; i++; continue; }
    if (c === ' ' || c === '\t' || c === '\r' || c === ';') { i++; continue; }
    if (c === '#') {
      if (src.startsWith('#=', i)) {
        const end = src.indexOf('=#', i + 2);
        if (end < 0) { errors.push({ line, msg: 'commento di blocco #= non chiuso' }); break; }
        for (const ch of src.slice(i, end)) if (ch === '\n') line++;
        i = end + 2;
      } else {
        while (i < src.length && src[i] !== '\n') i++;
      }
      continue;
    }
    if (c === '"') {
      const start = line;
      let j = i + 1;
      let value = '';
      let closed = false;
      while (j < src.length) {
        if (src[j] === '\\') {
          value += src[j] + (src[j + 1] ?? '');
          j += 2;
          continue;
        }
        if (src[j] === '"') { closed = true; j++; break; }
        if (src[j] === '\n') line++;   // una stringa può contenere newline
        value += src[j++];
      }
      if (!closed) errors.push({ line: start, msg: 'stringa non chiusa' });
      tokens.push({ type: 'string', value, line: start, raw: src.slice(i, j) });
      i = j;
      continue;
    }
    if (/[0-9]/.test(c)) {
      let j = i;
      while (j < src.length && /[0-9_]/.test(src[j])) j++;
      tokens.push({ type: 'number', value: src.slice(i, j), line });
      i = j;
      continue;
    }
    if (/[A-Za-z_]/.test(c)) {
      let j = i;
      while (j < src.length && /[A-Za-z0-9_]/.test(src[j])) j++;
      if (src[j] === '!' && src[j + 1] !== '=') j++;
      tokens.push({ type: 'ident', value: src.slice(i, j), line });
      i = j;
      continue;
    }
    if (src.startsWith('->', i) || src.startsWith('==', i) || src.startsWith('!=', i) ||
        src.startsWith('<=', i) || src.startsWith('>=', i) || src.startsWith('&&', i) ||
        src.startsWith('||', i) || src.startsWith('+=', i) || src.startsWith('-=', i) ||
        src.startsWith('*=', i)) {
      tokens.push({ type: 'punct', value: src.slice(i, i + 2), line });
      i += 2;
      continue;
    }
    tokens.push({ type: 'punct', value: c, line });
    i++;
  }
  return { tokens, errors };
}

/** Controlla un file .td e restituisce l'elenco dei problemi trovati. */
function lintFile(file) {
  const src = fs.readFileSync(file, 'utf8');
  const rel = path.relative(ROOT, file);
  const out = [];
  const add = (level, line, code, msg) => out.push({ level, line, code, msg, file: rel });

  if (src.includes('\r')) add('error', 1, 'E000', 'fine riga CRLF: il sorgente Triad deve usare LF');
  if (src.charCodeAt(0) === 0xfeff) add('error', 1, 'E001', 'BOM UTF-8: rimuoverlo');

  const { tokens, errors } = tokenize(src, file);
  for (const e of errors) add('error', e.line, 'E002', e.msg);

  // --- letterali: escape e righe multiple ------------------------------
  // Nota: la regola E010 (letterale con "if" dentro un blocco) e' stata
  // rimossa il 2026-11-09: il seed riconosce le parole chiave come token
  // esatti e salta il testo di un letterale quando scandisce la fine di un
  // blocco, quindi un letterale puo' contenere "if" anche dentro un blocco.
  for (const t of tokens) {
    if (t.type === 'string' && /\\[ntr"\\]/.test(t.value)) {
      add('error', t.line, 'E011',
        'escape non interpretato nella stringa: il seed stampa i due caratteri e fallisce su \\". ' +
        'Ogni riga generata deve essere un println separato.');
    }
    if (t.type === 'string' && t.value.includes('\n')) {
      add('error', t.line, 'E012',
        'stringa su più righe: SPEC-CORE.md §2 prevede "\\n" come escape, quindi una riga ' +
        'generata deve stare in una singola println. Spezza il letterale in più println.');
    }
  }

  // --- costrutti vietati ----------------------------------------------
  for (let i = 0; i < tokens.length; i++) {
    const t = tokens[i];
    const next = tokens[i + 1];
    if (t.type === 'ident') {
      if (t.value === 'print' && next && next.type === 'punct' && next.value === '(') {
        add('error', t.line, 'E020', 'print(...) non esiste nel Core: usa println(...)');
      }
      if (t.value === 'return') {
        add('error', t.line, 'E021',
          'return non è supportato dal seed nelle funzioni a blocco: ' +
          'il valore della funzione è l\'ultima espressione del corpo');
      }
      if (BOOTSTRAP_ONLY.has(t.value)) {
        add('error', t.line, 'E022',
          `${t.value} è una primitiva bootstrap (§8 SPEC-CORE): non eseguibile nel browser`);
      }
      if (t.value === 'length' && next && next.type === 'punct' && next.value === '(') {
        const arg = tokens[i + 2];
        if (arg && arg.type === 'ident') {
          add('warn', t.line, 'W021',
            'length(<variabile>): il seed lo supporta sulle stringhe, non sulle liste. ' +
            'Se l\'argomento è una lista, il calcolo fallisce a runtime.');
        }
      }
    }
    if (t.type === 'punct' && t.value === '[' && next && next.type !== 'punct') {
      const after = tokens[i + 2];
      if (after && after.type === 'punct' && after.value === ']') {
        add('warn', t.line, 'W022',
          'indicizzazione di lista non supportata dal seed: il sito non deve indicizzare liste');
      }
    }
    if (t.type === 'punct' && t.value === '=' && next && next.type === 'punct' && next.value === '=') {
      const left = tokens[i - 1];
      const right = tokens[i + 3];
      if (left && left.type === 'string' && right && right.type === 'string') {
        add('error', left.line, 'E023', 'confronto fra stringhe con == non è affidabile sul seed');
      }
    }
  }

  // --- chiamata come ultima espressione di una funzione ---------------
  // Una funzione il cui corpo termina con una chiamata fallisce sul seed:
  // l'ultima espressione deve essere una variabile o un'espressione semplice.
  const fnStack = [];
  for (let i = 0; i < tokens.length; i++) {
    const t = tokens[i];
    if (t.type === 'ident' && t.value === 'function') {
      fnStack.push({ line: t.line, body: [] });
      continue;
    }
    if (t.type === 'ident' && t.value === 'end' && fnStack.length) {
      const fn = fnStack.pop();
      // l'ultima istruzione del corpo è l'ultima riga non vuota prima di 'end'
      let lastLine = null;
      for (const b of fn.body) {
        if (b.tokens.length && b.line < t.line) lastLine = b;
      }
      if (!lastLine) continue;
      const first = lastLine.tokens[0];
      const second = lastLine.tokens[1];
      if (first && first.type === 'ident' && second && second.type === 'punct' && second.value === '(') {
        add('warn', first.line, 'W023',
          `la chiamata "${first.value}" è l'ultima istruzione del corpo: il seed non la supporta. ` +
          'Assegna il risultato a una variabile e restituisci la variabile.');
      }
      continue;
    }
    if (fnStack.length && !(t.type === 'ident' && (t.value === 'end' || t.value === 'function'))) {
      const fn = fnStack[fnStack.length - 1];
      let bucket = fn.body[fn.body.length - 1];
      if (!bucket || bucket.line !== t.line) {
        bucket = { line: t.line, tokens: [] };
        fn.body.push(bucket);
      }
      bucket.tokens.push(t);
    }
  }

  // --- += su stringhe --------------------------------------------------
  for (let i = 0; i < tokens.length; i++) {
    if (tokens[i].type === 'punct' && tokens[i].value === '+=') {
      const rhs = tokens[i + 1];
      if (rhs && rhs.type === 'string') {
        add('warn', tokens[i].line, 'W024',
          '+= su una stringa stampa spazzatura sul seed: usa s = s * "..."');
      }
    }
  }

  // --- let con più binding --------------------------------------------
  for (let i = 0; i < tokens.length; i++) {
    if (tokens[i].type === 'ident' && tokens[i].value === 'let') {
      let j = i + 1;
      while (j < tokens.length && !(tokens[j].type === 'ident' && tokens[j].value === 'end')) {
        if (tokens[j].type === 'punct' && tokens[j].value === ',') {
          add('error', tokens[i].line, 'E030', 'let con più binding: il seed supporta un solo binding per let');
          break;
        }
        j++;
      }
    }
  }

  return out;
}

// ---------------------------------------------------------------- main
//  Per default il lint controlla i generatori attivi (site_*.td). Gli altri
//  file .td della cartella (per es. generate_site_core.td, prima versione
//  del generatore, conservata per i riferimenti storici) si controllano
//  passandoli esplicitamente.
const args = process.argv.slice(2);
const files = args.length
  ? args.map((a) => path.resolve(process.cwd(), a))
  : fs.readdirSync(HERE)
      .filter((f) => /^site_.*\.td$/.test(f))
      .sort()
      .map((f) => path.join(HERE, f));

if (!files.length) {
  console.error('nessun file .td da controllare');
  process.exit(2);
}

let errors = 0;
let warns = 0;
for (const file of files) {
  const problems = lintFile(file);
  const rel = path.relative(ROOT, file);
  if (!problems.length) {
    console.log(`OK   ${rel}`);
    continue;
  }
  for (const p of problems) {
    if (p.level === 'error') errors++; else warns++;
    console.log(`${p.level === 'error' ? 'ERR ' : 'WARN'} ${rel}:${p.line} [${p.code}] ${p.msg}`);
  }
}
console.log(`\n${files.length} file, ${errors} errori, ${warns} avvisi`);
process.exit(errors ? 1 : 0);
