import { execa } from 'execa';
import path from 'path';
import { fileURLToPath } from 'url';
import fs from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const PROJECT_ROOT = path.join(__dirname, '..', '..');

/**
 * Trova il seed in codice macchina (nessuna dipendenza da Julia)
 */
export function findSeed() {
  const isWindows = process.platform === 'win32';
  const candidates = [];
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


export function findJulia() {
  // 1. Variabile d'ambiente TRIAD_JULIA
  if (process.env.TRIAD_JULIA) {
    if (fs.existsSync(process.env.TRIAD_JULIA)) {
      return process.env.TRIAD_JULIA;
    }
  }

  // 2. Cerca nel PATH (evitando WindowsApps su Windows)
  const juliaCandidates = [];

  if (process.platform === 'win32') {
    // Posizioni standard Windows
    const localAppData = process.env.LOCALAPPDATA || path.join(process.env.USERPROFILE, 'AppData', 'Local');
    const programFiles = process.env.PROGRAMFILES || 'C:\\Program Files';

    juliaCandidates.push(
      path.join(localAppData, 'Programs', 'Julia-1.13.1', 'bin', 'julia.exe'),
      path.join(localAppData, 'Programs', 'Julia-1.12.0', 'bin', 'julia.exe'),
      path.join(localAppData, 'Programs', 'Julia-1.11.0', 'bin', 'julia.exe'),
      path.join(localAppData, 'Programs', 'Julia-1.10.0', 'bin', 'julia.exe'),
      path.join(localAppData, 'juliaup', 'bin', 'julia.exe'),
      path.join(programFiles, 'Julia', 'bin', 'julia.exe'),
      'C:\\Julia\\bin\\julia.exe'
    );
  } else {
    // POSIX: cerca nel PATH e posizioni standard
    juliaCandidates.push(
      '/usr/local/bin/julia',
      '/usr/bin/julia',
      path.join(process.env.HOME || '', '.juliaup', 'bin', 'julia')
    );
  }

  for (const candidate of juliaCandidates) {
    if (fs.existsSync(candidate)) {
      return candidate;
    }
  }

  // Fallback: prova solo 'julia' nel PATH
  return 'julia';
}

/**
 * Esegue uno script Julia con opzioni standard
 */
export async function runJulia(scriptPath, args = [], options = {}) {
  const julia = findJulia();
  const defaultOptions = {
    cwd: PROJECT_ROOT,
    env: { ...process.env },
    ...options
  };

  const fullArgs = [
    '--startup-file=no',
    scriptPath,
    ...args
  ];

  try {
    const result = await execa(julia, fullArgs, defaultOptions);
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
 * Esegue uno script Node.js
 */
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
