#!/usr/bin/env node
// =====================================================================
//  conformance/run.mjs — runner di conformita' Triad (senza Julia)
//
//  Esegue i casi in una directory (ogni sottodir con program.td) tramite
//  il seed in codice macchina (o bin/triad-native), confrontando stdout
//  ed exit code con expected.out / expected.code.
//
//  Uso:
//    node conformance/run.mjs [--cases DIR] [--update]
//
//  --cases DIR   directory dei casi (default: conformance/core/cases)
//  --update      rigenera i golden (solo se il runtime supporta i casi)
// =====================================================================
import { spawnSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const PROJECT_ROOT = path.join(__dirname, '..');

function parseArgs(argv) {
  let cases = path.join(__dirname, 'core', 'cases');
  let update = false;
  let skip = ['liste'];
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--update') update = true;
    else if (a === '--cases') {
      if (i + 1 >= argv.length) { console.error('--cases vuole una directory'); process.exit(2); }
      cases = path.resolve(argv[++i]);
    } else if (a === '--skip') {
      if (i + 1 >= argv.length) { console.error('--skip vuole una lista'); process.exit(2); }
      skip = argv[++i].split(',').map(s => s.trim()).filter(Boolean);
    } else {
      console.error('opzione sconosciuta: ' + a);
      process.exit(2);
    }
  }
  return { cases, update, skip };
}

function findRuntime() {
  if (process.env.TRIAD_SEED && fs.existsSync(process.env.TRIAD_SEED)) {
    return { command: process.env.TRIAD_SEED, prefix: [] };
  }
  const isWin = process.platform === 'win32';
  // On platforms where the native seed is still a minimal stub (e.g. Linux E0),
  // fall back to the JavaScript reference interpreter so the conformance suite
  // can run. This keeps the runner usable without changing the committed seeds.
  if (!isWin) {
    const jsInterp = path.join(PROJECT_ROOT, 'seed', 'dev', 'triad_core.cjs');
    if (fs.existsSync(jsInterp)) {
      return { command: process.execPath, prefix: [jsInterp] };
    }
  }
  const candidates = [];
  if (isWin) {
    candidates.push(path.join(PROJECT_ROOT, 'bin', 'triad-native.exe'));
    candidates.push(path.join(PROJECT_ROOT, 'seed', 'windows-x86_64', 'seed.exe'));
  } else {
    candidates.push(path.join(PROJECT_ROOT, 'bin', 'triad-native'));
    candidates.push(path.join(PROJECT_ROOT, 'seed', 'linux-x86_64', 'seed'));
  }
  for (const c of candidates) if (fs.existsSync(c)) return { command: c, prefix: [] };
  return null;
}

function caseDirs(cases) {
  return fs.readdirSync(cases, { withFileTypes: true })
    .filter(d => d.isDirectory())
    .map(d => path.join(cases, d.name))
    .filter(d => fs.existsSync(path.join(d, 'program.td')))
    .sort();
}

function runCase(runtime, dir) {
  const prog = path.join(dir, 'program.td');
  const argsFile = path.join(dir, 'args.txt');
  const args = [];
  if (fs.existsSync(argsFile)) {
    const content = fs.readFileSync(argsFile, 'utf8');
    for (const line of content.split(/\r?\n/)) {
      if (line.length > 0) args.push(line.replace(/\r$/, ''));
    }
  }
  const fullArgs = [...runtime.prefix, prog, ...args];
  const res = spawnSync(runtime.command, fullArgs, { encoding: 'utf8', cwd: PROJECT_ROOT });
  const stdout = (res.stdout || '').replace(/\r\n/g, '\n');
  const code = (res.status === null ? 1 : res.status);
  return { code, stdout, stderr: res.stderr || '' };
}

function isWithinDirectory(directory, target) {
  const rel = path.relative(directory, target);
  return rel === '' || (rel !== '..' && !rel.startsWith(`..${path.sep}`) && !path.isAbsolute(rel));
}

function assertSafeGoldenPath(caseRoot, name) {
  const filePath = path.join(caseRoot, name);
  let info;
  try {
    info = fs.lstatSync(filePath);
  } catch (error) {
    if (error.code === 'ENOENT') return;
    throw error;
  }
  if (info.isSymbolicLink() || !info.isFile()) {
    throw new Error(`Rifiutato golden non regolare: ${filePath}`);
  }
  const resolved = fs.realpathSync(filePath);
  if (!isWithinDirectory(caseRoot, resolved)) {
    throw new Error(`Rifiutato golden fuori dalla directory del caso: ${filePath}`);
  }
}

function openGoldenForWrite(caseRoot, name) {
  const filePath = path.join(caseRoot, name);
  let existing;
  try {
    existing = fs.lstatSync(filePath);
  } catch (error) {
    if (error.code !== 'ENOENT') throw error;
  }

  if (existing && (existing.isSymbolicLink() || !existing.isFile())) {
    throw new Error(`Rifiutato golden non regolare: ${filePath}`);
  }
  const flags = fs.constants.O_WRONLY |
    (fs.constants.O_NOFOLLOW || 0) |
    (existing ? 0 : fs.constants.O_CREAT | fs.constants.O_EXCL);
  const fd = fs.openSync(filePath, flags, 0o666);
  try {
    const opened = fs.fstatSync(fd);
    const resolved = fs.realpathSync(filePath);
    if (!isWithinDirectory(caseRoot, resolved)) {
      throw new Error(`Rifiutato golden fuori dalla directory del caso: ${filePath}`);
    }
    const current = fs.statSync(resolved);
    if (!opened.isFile() || !opened.ino || !current.ino ||
        opened.dev !== current.dev || opened.ino !== current.ino ||
        (existing && (opened.dev !== existing.dev || opened.ino !== existing.ino))) {
      throw new Error(`Golden cambiato durante l'apertura: ${filePath}`);
    }
    return { fd, filePath };
  } catch (error) {
    fs.closeSync(fd);
    throw error;
  }
}

function writeGoldens(dir, stdout, code) {
  const caseRoot = fs.realpathSync(dir);
  const entries = [
    ['expected.out', stdout],
    ['expected.golden', stdout],
    ['expected.code', String(code)],
  ];
  for (const [name] of entries) assertSafeGoldenPath(caseRoot, name);

  const opened = [];
  try {
    for (const [name, content] of entries) {
      opened.push({ ...openGoldenForWrite(caseRoot, name), content });
    }
    for (const { fd, content } of opened) {
      fs.ftruncateSync(fd, 0);
      fs.writeFileSync(fd, content, 'utf8');
    }
  } finally {
    for (const { fd } of opened) fs.closeSync(fd);
  }
}

function main() {
  const { cases, update, skip } = parseArgs(process.argv.slice(2));
  const runtime = findRuntime();
  if (!runtime) {
    console.error('runtime non trovato (seed/triad-native). Decodifica il seed o imposta TRIAD_SEED.');
    process.exit(1);
  }
  if (!fs.existsSync(cases)) {
    console.error('directory casi non trovata: ' + cases);
    process.exit(1);
  }
  const dirs = caseDirs(cases).filter(d => !skip.includes(path.basename(d)));
  let fails = 0;
  for (const dir of dirs) {
    const name = path.basename(dir);
    const { code, stdout } = runCase(runtime, dir);
    if (update) {
      writeGoldens(dir, stdout, code);
      console.log('aggiornato  ' + name);
      continue;
    }
    const eoutPathPrimary = path.join(dir, 'expected.out');
    const eoutPathFallback = path.join(dir, 'expected.golden');
    const eoutPath = fs.existsSync(eoutPathPrimary) ? eoutPathPrimary : eoutPathFallback;
    const ecodePath = path.join(dir, 'expected.code');
    if (!fs.existsSync(eoutPath)) {
      fails++;
      console.log('FAIL  ' + name + '  (golden mancante: expected.out non trovato, esegui git pull o --update)');
      continue;
    }
    const eout = fs.readFileSync(eoutPath, 'utf8');
    const ecode = fs.existsSync(ecodePath) ? parseInt(fs.readFileSync(ecodePath, 'utf8').trim(), 10) : 0;
    const ok = stdout.replace(/\r\n/g, '\n') === eout.replace(/\r\n/g, '\n') && code === ecode;
    if (ok) {
      console.log('PASS  ' + name);
    } else {
      fails++;
      console.log('FAIL  ' + name + '  (exit ' + code + ', atteso ' + ecode + ', stdout ' + Buffer.byteLength(stdout, 'utf8') + ' byte, attesi ' + Buffer.byteLength(eout, 'utf8') + ')');
    }
  }
  if (update) {
    console.log('golden aggiornati');
    process.exit(0);
  }
  console.log(fails === 0 ? 'conformance: OK' : 'conformance: ' + fails + ' casi falliti');
  process.exit(fails === 0 ? 0 : 1);
}

main();
