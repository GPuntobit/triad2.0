#!/usr/bin/env node
// sync-playground-core.mjs — rigenera docs/pages/triad-core.js dal seed/dev/triad_core.cjs.
//
// Perche esiste: il playground del sito (docs/pages/playground.html) carica
// <script src="triad-core.js">, un bundle browser dell'interprete di riferimento.
// Il file generato non e in git (artefatto), quindi questo script va eseguito
// prima di pubblicare GitHub Pages (npm run site / workflow pages).
//
// Uso:  node scripts/docs/sync-playground-core.mjs [--check]
//       --check: non scrive; esce 1 se il file pubblicato manca o e obsoleto.
import { readFileSync, writeFileSync, existsSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..', '..');
const SRC = path.join(ROOT, 'seed', 'dev', 'triad_core.cjs');
const OUT = path.join(ROOT, 'docs', 'pages', 'triad-core.js');
const checkOnly = process.argv.includes('--check');

const core = readFileSync(SRC, 'utf8');
if (!core.includes('window.TriadCore')) {
  console.error('ERRORE: triad_core.cjs non espone window.TriadCore (branch browser mancante).');
  process.exit(2);
}

const banner = [
  '// triad-core.js — bundle BROWSER dell interprete di riferimento Triad-Core.',
  '// GENERATO da scripts/docs/sync-playground-core.mjs a partire da seed/dev/triad_core.cjs.',
  '// NON modificare a mano: modificare il sorgente e rigenerare (npm run site).',
  `// Generato: ${new Date().toISOString()}`,
  '',
].join('\n');

// In ambiente statico non c'e require(): il guard typeof require === 'function'
// dentro al core fa gia cadere sullo shim fs; nessun'altra trasformazione serve.
const out = banner + core;

if (checkOnly) {
  if (!existsSync(OUT)) {
    console.error('CHECK FAIL: docs/pages/triad-core.js assente. Eseguire: node scripts/docs/sync-playground-core.mjs');
    process.exit(1);
  }
  const cur = readFileSync(OUT, 'utf8');
  // confronta solo il corpo (ignora la riga "Generato:")
  const strip = s => s.split('\n').filter(l => !l.startsWith('// Generato:')).join('\n');
  if (strip(cur) !== strip(out)) {
    console.error('CHECK FAIL: docs/pages/triad-core.js e obsoleto rispetto a seed/dev/triad_core.cjs.');
    process.exit(1);
  }
  console.log('CHECK OK: triad-core.js sincronizzato con triad_core.cjs');
  process.exit(0);
}

writeFileSync(OUT, out, 'utf8');
console.log(`Scritto ${path.relative(ROOT, OUT)} (${out.length} bytes, da ${path.relative(ROOT, SRC)})`);
