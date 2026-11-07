#!/usr/bin/env node
// =====================================================================
//  guard.mjs — guardie statiche sulla sorgente di S1
//
//  Controlla che i programmi Triad del corpus di S1 restino dentro il
//  *sottoinsieme certificato* del seed: il contratto del seed
//  (seed/dev/certified-subset.txt) dice cosa il seed esegue, cosa
//  rifiuta e cosa esegue in modo divergente; le regole (rules.mjs)
//  vietano nella sorgente di S1 i costrutti che il seed non porta.
//
//  Uso:
//    node tools/selfhost-guard/guard.mjs                 # corpus di S1
//    node tools/selfhost-guard/guard.mjs file.td ...     # file specifici
//    node tools/selfhost-guard/guard.mjs --list          # le regole
//
//  Exit: 0 = nessun errore; 1 = almeno un errore; 2 = ambiente non
//  valido (contratto o corpus mancanti).
//
//  I file che NON sono nel manifesto (selfhost/certified.txt) sono
//  "fuori contratto": le violazioni sono segnalate come avvisi e non
//  falliscono il gate — ma non sono silenziate (il gate differenziale
//  seed<->JS li copre solo se sono nel corpus certificato).
// =====================================================================
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { parseContract, contractInt, hasDivergence } from './contract.mjs';
import { scanSource } from './scan.mjs';
import { parseTriad, analyzeProgram } from './analysis.mjs';
import { RULES } from './rules.mjs';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(HERE, '..', '..');

const CONTRACT_PATH = path.join(ROOT, 'seed', 'dev', 'certified-subset.txt');
const MANIFEST_PATH = path.join(ROOT, 'seed', 'dev', 'certified-corpus.txt');
const CORPUS_DIR = path.join(ROOT, 'selfhost');

/** Legge il manifesto del corpus certificato (un percorso per riga). */
export function readManifest(file) {
  if (!fs.existsSync(file)) return [];
  return fs
    .readFileSync(file, 'utf8')
    .split('\n')
    .map((l) => l.trim())
    .filter((l) => l && !l.startsWith('#'));
}

/**
 * Controlla un file: restituisce l'elenco delle violazioni
 * [{rule, level, line, msg, file}].
 */
export function checkFile(file, contract, opts = {}) {
  const src = fs.readFileSync(file, 'utf8');
  const rel = path.relative(ROOT, file);
  const findings = [];
  const scan = scanSource(src);

  for (const e of scan.errors) {
    findings.push({ rule: 'G-P01', level: 'error', line: e.line, msg: e.msg, file: rel });
  }

  let ast = null;
  let analysis = null;
  try {
    ast = parseTriad(src);
    analysis = analyzeProgram(ast);
  } catch (e) {
    findings.push({
      rule: 'G-P01',
      level: 'error',
      line: null,
      msg: `il programma non e' un Triad-Core valido (riferimento JS): ${e.message}`,
      file: rel,
    });
  }

  const ctx = {
    file,
    rel,
    src,
    scan,
    ast,
    analysis,
    contract,
    envelope: {
      sourceMaxBytes: contractInt(contract, 'envelope', 'source.max_bytes', 0),
      heapMaxBytes: contractInt(contract, 'envelope', 'heap.max_bytes', 0),
      listMaxItems: contractInt(contract, 'envelope', 'list.max_items', 0),
      functionMaxParams: contractInt(contract, 'envelope', 'function.max_params', 0),
    },
  };

  for (const rule of RULES) {
    // la regola e' attiva solo se la divergenza e' ancora nel contratto
    if (rule.divergence && !hasDivergence(contract, rule.divergence)) continue;
    let out = [];
    try {
      out = rule.check(ctx) || [];
    } catch (e) {
      findings.push({
        rule: rule.id,
        level: 'error',
        line: null,
        msg: `la regola e' fallita: ${e.message}`,
        file: rel,
      });
      continue;
    }
    for (const f of out) {
      findings.push({
        rule: rule.id,
        level: f.level || rule.level || 'error',
        line: f.line ?? null,
        msg: f.msg,
        file: rel,
      });
    }
  }
  return findings;
}

function main(argv) {
  const args = argv.slice(2);
  if (args.includes('--list')) {
    for (const r of RULES) {
      console.log(`${r.id}\t${r.divergence ?? '-'}\t${r.title}`);
    }
    return 0;
  }
  if (!fs.existsSync(CONTRACT_PATH)) {
    console.error(`contratto del seed non trovato: ${path.relative(ROOT, CONTRACT_PATH)}`);
    return 2;
  }
  const contract = parseContract(fs.readFileSync(CONTRACT_PATH, 'utf8'));

  const explicit = args.filter((a) => !a.startsWith('-'));
  const certified = new Set(readManifest(MANIFEST_PATH).map((p) => path.resolve(ROOT, p)));

  let files = [];
  if (explicit.length) {
    files = explicit.map((f) => path.resolve(process.cwd(), f));
  } else {
    // il corpus certificato (manifesto) + i file .td di selfhost/ che non
    // sono nel manifesto: quelli sono "fuori contratto" e le loro
    // violazioni sono avvisi, non errori.
    const inManifest = new Set([...certified].map((c) => path.resolve(c)));
    const others = fs
      .readdirSync(CORPUS_DIR)
      .filter((f) => f.endsWith('.td'))
      .sort()
      .map((f) => path.join(CORPUS_DIR, f))
      .filter((f) => !inManifest.has(path.resolve(f)));
    files = [...certified].sort().concat(others);
  }

  let errors = 0;
  let warns = 0;
  for (const file of files) {
    if (!fs.existsSync(file)) {
      console.error(`file non trovato: ${file}`);
      return 2;
    }
    const isCertified = explicit.length ? true : certified.has(path.resolve(file));
    const findings = checkFile(file, contract);
    const rel = path.relative(ROOT, file);
    // i file fuori contratto sono "storici": le violazioni si segnalano
    // come avvisi (non falliscono il gate) ma non sono silenziate
    const shown = findings.map((f) => (isCertified ? f : { ...f, level: 'warn' }));
    if (!shown.length) {
      console.log(`OK   ${rel}${isCertified ? '' : '  (fuori contratto)'}`);
      continue;
    }
    for (const f of shown) {
      if (f.level === 'error') errors++; else warns++;
      const where = f.line ? `${rel}:${f.line}` : rel;
      const tag = isCertified ? '' : ' [fuori contratto]';
      console.log(`${f.level === 'error' ? 'ERR ' : 'WARN'} ${where} [${f.rule}]${tag} ${f.msg}`);
    }
  }

  const nFiles = files.length;
  console.log(`\n${nFiles} file, ${errors} errori, ${warns} avvisi`);
  if (!explicit.length) {
    const missing = [...certified].filter((c) => !files.includes(c));
    if (missing.length) {
      console.log('manifesto: file dichiarati certificati ma assenti: ' +
        missing.map((m) => path.relative(ROOT, m)).join(', '));
      return 2;
    }
  }
  return errors ? 1 : 0;
}

if (process.argv[1] && path.resolve(process.argv[1]) === path.resolve(fileURLToPath(import.meta.url))) {
  process.exit(main(process.argv));
}
