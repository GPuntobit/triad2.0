#!/usr/bin/env node
// tests/probes/run_probes.mjs — esegue i probe .td sui due runtime Triad-Core
// (seed PE nativo, interprete di riferimento JS) e confronta stdout ed exit
// code. Serve a caratterizzare il sottoinsieme supportato prima di scrivere
// il generatore del sito (tools/site-gen).
//
// Uso: node tests/probes/run_probes.mjs [--strict] [file.td ...]
//
// Regole (usate anche dalla CI):
//   - i file ok_* e test_* devono dare risultati IDENTICI sui due runtime e,
//     se esiste <file>.expected.out, identici anche al golden;
//   - i file bad_* documentano divergenze note: il confronto viene mostrato
//     ma non fa fallire il programma;
//   - exit code 1 se una regola violata, 2 se il seed non e' trovato.
//
// Il seed si puo' sostituire con TRIAD_SEED (utile su Linux via wine:
//   TRIAD_SEED=/path/wrapper node tests/probes/run_probes.mjs ...).
import { spawnSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '..', '..');
const seed = process.env.TRIAD_SEED || path.join(root, 'seed', 'windows-x86_64', 'seed.exe');
const jsInterp = path.join(root, 'seed', 'dev', 'triad_core.cjs');

function run(command, prefix, file) {
  const args = [...prefix, file];
  const res = spawnSync(command, args, { encoding: 'utf8', cwd: root });
  return {
    code: res.status === null ? 1 : res.status,
    out: (res.stdout || '').replace(/\r\n/g, '\n'),
    err: (res.stderr || '').replace(/\r\n/g, '\n')
  };
}

const argv = process.argv.slice(2);
const strictOnly = argv.includes('--strict');
const args = argv.filter((a) => a !== '--strict');
const files = args.length
  ? args.map((a) => path.resolve(root, a))
  : fs.readdirSync(here)
      .filter((f) => f.endsWith('.td'))
      .filter((f) => !strictOnly || !f.startsWith('bad_'))
      .sort()
      .map((f) => path.join(here, f));

if (!fs.existsSync(seed)) {
  console.error('seed non trovato: ' + seed);
  process.exit(2);
}

let diffs = 0;
let failures = 0;
for (const file of files) {
  const rel = path.relative(root, file);
  const base = path.basename(file);
  const strict = !base.startsWith('bad_');
  const s = run(seed, [], rel);
  const j = run(process.execPath, [jsInterp], rel);
  const same = s.code === j.code && s.out === j.out;
  if (!same) diffs++;
  const show = (t) => JSON.stringify(t.out).slice(0, 120);
  console.log(
    `${base.padEnd(28)} seed: exit=${s.code} ${show(s)}  |  js: exit=${j.code} ${show(j)}  [${same ? 'same' : 'DIFF'}]`
  );
  if (!same && s.err) console.log('   seed stderr: ' + s.err.trim());
  if (!same && j.err) console.log('   js stderr:   ' + j.err.trim());

  // Golden opzionale: <file senza .td>.expected.out
  const goldenPath = file.replace(/\.td$/, '.expected.out');
  if (fs.existsSync(goldenPath)) {
    const golden = fs.readFileSync(goldenPath, 'utf8').replace(/\r\n/g, '\n');
    for (const [who, r] of [['seed', s], ['js', j]]) {
      if (r.out !== golden) {
        console.log(`   golden DIVERSO (${who}): ${goldenPath}`);
        if (strict) failures++;
      }
    }
  }
  if (strict && !same) failures++;
}
console.log(`\n${files.length} probe, ${diffs} differenze seed/js` +
  (failures ? `, ${failures} violazioni (ok_*/test_* o golden)` : ''));
process.exit(failures ? 1 : 0);
