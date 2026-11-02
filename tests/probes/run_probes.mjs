#!/usr/bin/env node
// tests/probes/run_probes.mjs — esegue i probe .td sui due runtime Triad-Core
// (seed PE nativo su Windows, interprete di riferimento JS) e confronta
// stdout ed exit code. Serve a caratterizzare il sottoinsieme supportato
// prima di scrivere il generatore del sito (tools/site-gen).
//
// Uso: node tests/probes/run_probes.mjs [file.td ...]
import { spawnSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '..', '..');
const seed = path.join(root, 'seed', 'windows-x86_64', 'seed.exe');
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

const args = process.argv.slice(2);
const files = args.length
  ? args.map((a) => path.resolve(root, a))
  : fs.readdirSync(here)
      .filter((f) => f.endsWith('.td'))
      .sort()
      .map((f) => path.join(here, f));

if (!fs.existsSync(seed)) {
  console.error('seed non trovato: ' + seed);
  process.exit(2);
}

let diffs = 0;
for (const file of files) {
  const rel = path.relative(root, file);
  const s = run(seed, [], rel);
  const j = run(process.execPath, [jsInterp], rel);
  const same = s.code === j.code && s.out === j.out;
  if (!same) diffs++;
  const show = (t) => JSON.stringify(t.out).slice(0, 120);
  console.log(
    `${path.basename(file).padEnd(14)} seed: exit=${s.code} ${show(s)}  |  js: exit=${j.code} ${show(j)}  [${same ? 'same' : 'DIFF'}]`
  );
  if (!same && s.err) console.log('   seed stderr: ' + s.err.trim());
  if (!same && j.err) console.log('   js stderr:   ' + j.err.trim());
}
console.log(`\n${files.length} probe, ${diffs} differenze seed/js`);
