import { execa } from 'execa';
import path from 'path';
import { fileURLToPath } from 'url';
import fs from 'fs';

function moduleDir() {
  try { return path.dirname(fileURLToPath(import.meta.url)); } catch { return null; }
}

function isProjectRoot(dir) {
  return fs.existsSync(path.join(dir, 'conformance', 'run.mjs')) && fs.existsSync(path.join(dir, 'seed'));
}

// Root del repository: TRIAD_HOME, poi risalendo dal modulo, dall'eseguibile
// (triad-cli.exe standalone) e dalla cartella corrente.
function findProjectRoot() {
  const starts = [process.env.TRIAD_HOME, moduleDir(), path.dirname(process.execPath), process.cwd()];
  for (const start of starts.filter(Boolean)) {
    let dir = path.resolve(start);
    for (;;) {
      if (isProjectRoot(dir)) return dir;
      const parent = path.dirname(dir);
      if (parent === dir) break;
      dir = parent;
    }
  }
  return process.cwd();
}

const PROJECT_ROOT = findProjectRoot();

/**
 * Trova il seed in codice macchina (nessuna dipendenza da Julia).
 * TRIAD_SEED ha la precedenza (usato anche dalla CI), coerentemente con
 * conformance/run.mjs.
 */
export function findSeed() {
  const isWindows = process.platform === 'win32';
  const candidates = [];
  if (process.env.TRIAD_SEED && fs.existsSync(process.env.TRIAD_SEED)) {
    return process.env.TRIAD_SEED;
  }
  if (isWindows) {
    candidates.push(
      path.join(PROJECT_ROOT, 'bin', 'triad-native.exe'),
      path.join(PROJECT_ROOT, 'seed', 'windows-x86_64', 'seed.exe')
    );
  } else {
    candidates.push(
      path.join(PROJECT_ROOT, 'bin', 'triad-native'),
      path.join(PROJECT_ROOT, 'seed', 'linux-x86_64', 'seed')
    );
  }
  for (const c of candidates) {
    if (fs.existsSync(c)) return c;
  }
  return null;
}

/**
 * Vero se il seed corrente è uno stub (es. Linux E0: ELF di poche centinaia
 * di byte che stampa solo "Triad seed Linux OK"). Sotto i 4 KB non può
 * essere l'interprete Triad-Core completo (E2): serve il fallback JS.
 */
export function seedIsStub(seedPath = findSeed()) {
  if (!seedPath) return true;
  try {
    const st = fs.statSync(seedPath);
    if (st.isFile() && st.size < 4096) return true;
    // Probe runtime: se il seed risponde a un file .td con output valido è reale.
    return false;
  } catch {
    return true;
  }
}

/**
 * Esegue il seed in codice macchina
 */
export async function runSeed(args = [], options = {}) {
  const seed = findSeed();
  if (!seed) {
    return { success: false, stdout: '', stderr: 'seed non trovato', exitCode: 1 };
  }
  const defaultOptions = { cwd: PROJECT_ROOT, env: { ...process.env }, ...options };
  try {
    const result = await execa(seed, args, defaultOptions);
    return { success: true, stdout: result.stdout, stderr: result.stderr, exitCode: result.exitCode };
  } catch (error) {
    return { success: false, stdout: error.stdout || '', stderr: error.stderr || '', exitCode: error.exitCode || 1, error };
  }
}


export async function runNode(scriptPath, args = [], options = {}) {
  const defaultOptions = {
    cwd: PROJECT_ROOT,
    env: { ...process.env },
    ...options
  };

  try {
    const result = await execa('node', [scriptPath, ...args], defaultOptions);
    return {
      success: true,
      stdout: result.stdout,
      stderr: result.stderr,
      exitCode: result.exitCode
    };
  } catch (error) {
    return {
      success: false,
      stdout: error.stdout || '',
      stderr: error.stderr || '',
      exitCode: error.exitCode || 1,
      error
    };
  }
}

/**
 * Ottiene il percorso assoluto di un file nel progetto
 */
export function projectPath(...segments) {
  return path.join(PROJECT_ROOT, ...segments);
}

/**
 * Verifica se un file esiste
 */
export function fileExists(filePath) {
  return fs.existsSync(filePath);
}

/**
 * Legge un file
 */
export function readFile(filePath, encoding = 'utf-8') {
  return fs.readFileSync(filePath, encoding);
}

/**
 * Scrive un file
 */
export function writeFile(filePath, content) {
  fs.writeFileSync(filePath, content, 'utf-8');
}
