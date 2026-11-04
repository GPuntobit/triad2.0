#!/usr/bin/env node
// =====================================================================
//  build.mjs — costruisce il sito di Triad a partire dai programmi
//  Triad in tools/site-gen/.
//
//  Ogni generatore (.td) stampa un "bundle" di testo:
//
//      === FILE: docs/pages/spec.html ===
//      <!DOCTYPE html>
//      ...
//
//  Questo driver esegue ogni generatore sui DUE runtime Triad-Core
//  (seed PE nativo e interprete di riferimento JS), pretende stdout
//  identico byte per byte, divide il bundle e scrive i file.
//
//  Uso:
//    node tools/site-gen/build.mjs                    # genera e scrive i file
//    node tools/site-gen/build.mjs --check            # verifica, non scrive
//    node tools/site-gen/build.mjs --dry              # esegue e confronta i
//                                                      #   due runtime, non
//                                                      #   scrive nulla
//    node tools/site-gen/build.mjs --lint             # esegue solo il lint
//    node tools/site-gen/build.mjs site_pages.td     # solo i generatori dati
// =====================================================================
import { spawnSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(HERE, '..', '..');
const MARKER = /^=== FILE: (.+) ===$/;

const args = process.argv.slice(2);
const CHECK_ONLY = args.includes('--check');
const DRY = args.includes('--dry');
const LINT_ONLY = args.includes('--lint');
const selected = args.filter((a) => !a.startsWith('--'));

const SEED_WIN = path.join(ROOT, 'seed', 'windows-x86_64', 'seed.exe');
const SEED_LINUX = path.join(ROOT, 'bin', 'triad-native');
const SEED_LINUX_STUB = path.join(ROOT, 'seed', 'linux-x86_64', 'seed');
const JS_INTERP = path.join(ROOT, 'seed', 'dev', 'triad_core.cjs');

/** Restituisce il percorso del seed nativo utilizzabile, o null. */
function findSeed() {
  const candidates = process.platform === 'win32'
    ? [SEED_WIN, path.join(ROOT, 'bin', 'triad-native.exe')]
    : [SEED_LINUX, SEED_LINUX_STUB];
  for (const c of candidates) {
    // stat diretto senza existsSync: evita il check-then-use (TOCTOU).
    let size;
    try {
      size = fs.statSync(c).size;
    } catch {
      continue; // come l'existsSync: qualsiasi errore = candidato saltato
    }
    if (size < 4096) continue; // stub Linux E0: non è l'interprete completo
    return c;
  }
  return null;
}

function run(command, argv) {
  // encoding 'buffer': il confronto fra i due runtime è fatto sui byte
  // grezzi, non su stringhe già decodificate.
  const res = spawnSync(command, argv, { cwd: ROOT, maxBuffer: 32 * 1024 * 1024 });
  return {
    code: res.status === null ? 1 : res.status,
    out: res.stdout ?? Buffer.alloc(0),
    err: res.stderr ?? Buffer.alloc(0)
  };
}

/** Divide il bundle in file {path, content}. */
function splitBundle(bundle) {
  const files = [];
  let current = null;
  for (const line of bundle.split('\n')) {
    const m = MARKER.exec(line);
    if (m) {
      current = { path: m[1].trim(), lines: [] };
      files.push(current);
      continue;
    }
    if (current) current.lines.push(line);
  }
  // l'ultima riga del bundle è vuota (newline finale): va rimossa
  for (const f of files) {
    if (f.lines.length && f.lines[f.lines.length - 1] === '') f.lines.pop();
  }
  return files;
}

// ---------------------------------------------------------------- lint
function runLint() {
  const res = run(process.execPath, [path.join(HERE, 'lint.mjs')]);
  process.stdout.write(res.out);
  return res.code === 0;
}

// ---------------------------------------------------------------- main
const seed = findSeed();
const haveJs = fs.existsSync(JS_INTERP);

console.log('Triad site generator');
console.log('  seed nativo : ' + (seed ? path.relative(ROOT, seed) : 'NON TROVATO (solo interprete JS)'));
console.log('  interprete  : ' + (haveJs ? path.relative(ROOT, JS_INTERP) : 'NON TROVATO'));
console.log('');

if (LINT_ONLY) {
  process.exit(runLint() ? 0 : 1);
}

const generators = (selected.length
  ? selected.map((s) => (s.endsWith('.td') ? s : s + '.td'))
  : fs.readdirSync(HERE).filter((f) => /^site_.*\.td$/.test(f)).sort()
).map((g) => {
  if (path.isAbsolute(g)) return g;
  const fromCwd = path.resolve(process.cwd(), g);
  if (fs.existsSync(fromCwd)) return fromCwd;
  return path.join(HERE, g);
});

if (!generators.length) {
  console.error('nessun generatore (site_*.td) in tools/site-gen/');
  process.exit(2);
}

const bundleParts = [];
let failed = false;

for (const gen of generators) {
  const abs = path.resolve(gen);
  const rel = path.relative(ROOT, abs);
  const arg = rel && !rel.startsWith('..') ? rel : abs;
  const js = haveJs ? run(process.execPath, [JS_INTERP, arg]) : null;
  const native = seed ? run(seed, [arg]) : null;

  if (js && js.code !== 0) {
    console.error(`ERR  ${rel}: l'interprete JS esce con codice ${js.code}\n${js.err}`);
    failed = true;
    continue;
  }
  if (native && native.code !== 0) {
    console.error(`ERR  ${rel}: il seed nativo esce con codice ${native.code}\n${native.err}`);
    failed = true;
    continue;
  }
  if (native && js && (!native.out.equals(js.out) || native.code !== js.code)) {
    console.error(`ERR  ${rel}: i due runtime non concordano (seed ${native.out.length} byte, JS ${js.out.length} byte)`);
    const a = native.out.toString('utf8').split('\n');
    const b = js.out.toString('utf8').split('\n');
    for (let i = 0; i < Math.max(a.length, b.length); i++) {
      if (a[i] !== b[i]) {
        console.error(`     prima differenza alla riga ${i + 1}:`);
        console.error(`       seed: ${JSON.stringify(a[i])}`);
        console.error(`       js  : ${JSON.stringify(b[i])}`);
        break;
      }
    }
    failed = true;
    continue;
  }
  const note = native ? 'seed + js: output identico byte per byte' : 'solo js (seed non disponibile)';
  console.log(`OK   ${rel}  (${note})`);
  bundleParts.push((js ? js.out : native.out).toString('utf8'));
}

if (failed) {
  console.error('\nbuild fallito: i generatori non girano in modo portabile.');
  process.exit(1);
}

const bundle = bundleParts.join('');
const files = splitBundle(bundle);
if (!files.length) {
  console.error('\nnessun file nel bundle: i generatori devono emettere "=== FILE: <path> ===".');
  process.exit(1);
}

let drift = 0;
let written = 0;
console.log('');
for (const f of files) {
  const target = path.resolve(ROOT, f.path);
  if (!target.startsWith(ROOT + path.sep)) {
    console.error(`ERR  percorso fuori dal repository: ${f.path}`);
    process.exit(1);
  }
  const content = f.lines.join('\n') + '\n';
  // Lettura diretta con gestione ENOENT: niente existsSync prima del read
  // (check-then-use = race condition segnalata da CodeQL).
  let current = null;
  try {
    current = fs.readFileSync(target, 'utf8');
  } catch (e) {
    if (e.code !== 'ENOENT') throw e;
  }
  if (DRY) {
    console.log(`DRY  ${f.path} (${content.length} byte, ${f.lines.length} righe)`);
    continue;
  }
  if (current === content) {
    console.log(`SAME ${f.path}`);
    continue;
  }
  if (CHECK_ONLY) {
    drift++;
    console.log(`DRIFT ${f.path} (il file su disco non coincide con il generato)`);
    continue;
  }
  fs.mkdirSync(path.dirname(target), { recursive: true });
  // Scrittura atomica: temp + rename. Un file (o symlink) comparso o
  // cambiato dopo la lettura viene sostituito, non inseguito.
  const tmp = path.join(path.dirname(target), `.${path.basename(target)}.${process.pid}.tmp`);
  fs.writeFileSync(tmp, content, 'utf8');
  fs.renameSync(tmp, target);
  written++;
  console.log(`WRITE ${f.path} (${content.length} byte)`);
}

console.log('');
if (DRY) {
  console.log(`dry run: ${files.length} file prodotti dai generatori, nulla scritto.`);
} else if (CHECK_ONLY) {
  if (drift) {
    console.error(`check fallito: ${drift} file non coincidono con il generato.`);
    process.exit(1);
  }
  console.log(`check ok: ${files.length} file coincidono con il generato.`);
} else {
  console.log(`generati ${files.length} file (${written} scritti, ${files.length - written} invariati).`);
}
