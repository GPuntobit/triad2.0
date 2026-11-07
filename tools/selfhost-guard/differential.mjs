#!/usr/bin/env node
// =====================================================================
//  differential.mjs — gate differenziale seed <-> riferimento JS
//
//  Il riferimento JS (seed/dev/triad_core.cjs) e' l'autorita' semantica
//  di sviluppo; il seed e' il gate di esecuzione.  Questo gate esegue
//  ogni programma del corpus certificato (selfhost/certified.txt) su
//  entrambi i runtime e confronta stdout (byte per byte) e exit code.
//
//  Il gate differenziale e' il presidio delle divergenze che una regola
//  statica NON puo' decidere (dipendono dai tipi a runtime: D15), e il
//  controllo empirico delle regole statiche (se una regola lascia passare
//  un programma divergente, qui si vede).
//
//  Uso:
//    node tools/selfhost-guard/differential.mjs
//    node tools/selfhost-guard/differential.mjs --seed ./seed/linux-x86_64/seed
//
//  Exit: 0 = stdout ed exit code coincidono su ogni file; 1 = una
//  differenza; 2 = ambiente non valido (seed mancante).
// =====================================================================
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(HERE, '..', '..');
const DEFAULT_SEED = path.join(ROOT, 'seed', 'linux-x86_64', 'seed');
const JS_REF = path.join(ROOT, 'seed', 'dev', 'triad_core.cjs');
const MANIFEST = path.join(ROOT, 'seed', 'dev', 'certified-corpus.txt');

function readManifest(file) {
  if (!fs.existsSync(file)) return [];
  return fs
    .readFileSync(file, 'utf8')
    .split('\n')
    .map((l) => l.trim())
    .filter((l) => l && !l.startsWith('#'))
    .map((l) => path.resolve(ROOT, l));
}

function run(cmd, args) {
  const r = spawnSync(cmd, args, { encoding: 'utf8', maxBuffer: 64 * 1024 * 1024 });
  return {
    stdout: r.stdout ?? '',
    stderr: r.stderr ?? '',
    code: r.status === null ? -1 : r.status,
    error: r.error ? String(r.error.message) : null,
  };
}

function main(argv) {
  const args = argv.slice(2);
  let seed = DEFAULT_SEED;
  const i = args.indexOf('--seed');
  if (i >= 0 && args[i + 1]) seed = path.resolve(process.cwd(), args[i + 1]);

  if (!fs.existsSync(seed)) {
    console.error(`seed non trovato: ${seed}\n` +
      'decodifica: xxd -r -p seed/linux-x86_64/seed.hex seed/linux-x86_64/seed');
    return 2;
  }
  if (!fs.existsSync(JS_REF)) {
    console.error(`riferimento JS non trovato: ${JS_REF}`);
    return 2;
  }
  const files = [];
  const fi = args.indexOf('--file');
  if (fi >= 0 && args[fi + 1]) {
    files.push(path.resolve(process.cwd(), args[fi + 1]));
  } else {
    files.push(...readManifest(MANIFEST));
  }
  if (!files.length) {
    console.error('manifesto del corpus certificato vuoto o mancante');
    return 2;
  }

  let diffs = 0;
  for (const file of files) {
    const rel = path.relative(ROOT, file);
    const s = run(seed, [file]);
    const j = run(process.execPath, [JS_REF, file]);
    const same = s.stdout === j.stdout && s.code === j.code;
    if (same) {
      console.log(`same  ${rel}  (exit ${s.code}, ${s.stdout.length} byte)`);
      continue;
    }
    diffs++;
    console.log(`DIFF  ${rel}`);
    console.log(`  seed: exit ${s.code}, ${s.stdout.length} byte di stdout`);
    console.log(`  js  : exit ${j.code}, ${j.stdout.length} byte di stdout`);
    const sl = s.stdout.split('\n');
    const jl = j.stdout.split('\n');
    for (let k = 0; k < Math.max(sl.length, jl.length); k++) {
      if (sl[k] !== jl[k]) {
        console.log(`  riga ${k + 1}:`);
        console.log(`    seed: ${JSON.stringify(sl[k])}`);
        console.log(`    js  : ${JSON.stringify(jl[k])}`);
        break;
      }
    }
    if (s.stderr) console.log(`  seed stderr: ${s.stderr.trim().split('\n')[0]}`);
    if (j.stderr) console.log(`  js   stderr: ${j.stderr.trim().split('\n')[0]}`);
  }

  console.log(`\n${files.length} file, ${diffs} differenze`);
  return diffs ? 1 : 0;
}

process.exit(main(process.argv));
