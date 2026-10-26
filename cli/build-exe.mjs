// Costruisce triad-cli come eseguibile standalone (Node.js Single Executable Application).
// Uso: node build-exe.mjs [percorso-node]   (default: il node corrente)
// Output: dist/triad-cli(.exe). Il binario Node usato come base determina la piattaforma
// (es. node.exe di Windows per costruire triad-cli.exe da Linux).
import { execFileSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const dist = path.join(here, 'dist');
const base = path.resolve(process.argv[2] || process.execPath);
const isExe = base.toLowerCase().endsWith('.exe');
const out = path.join(dist, isExe ? 'triad-cli.exe' : 'triad-cli');
const bin = name => path.join(here, 'node_modules', '.bin', name);

fs.mkdirSync(dist, { recursive: true });
execFileSync(bin('esbuild'), ['triad-cli.mjs', '--bundle', '--platform=node', '--format=cjs',
  '--log-level=error', '--outfile=dist/triad-cli.cjs'], { cwd: here, stdio: 'inherit' });
fs.writeFileSync(path.join(dist, 'sea-config.json'), JSON.stringify({
  main: 'triad-cli.cjs', output: 'sea-prep.blob', disableExperimentalSEAWarning: true
}));
execFileSync(process.execPath, ['--experimental-sea-config', 'sea-config.json'], { cwd: dist, stdio: 'inherit' });
fs.copyFileSync(base, out);
fs.chmodSync(out, 0o755);
execFileSync(bin('postject'), [out, 'NODE_SEA_BLOB', path.join(dist, 'sea-prep.blob'),
  '--sentinel-fuse', 'NODE_SEA_FUSE_fce680ab2cc467b6e072b8b5df1996b2'], { stdio: 'inherit' });
console.log('==> ' + out);
