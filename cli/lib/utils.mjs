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
// Repository root: TRIAD_HOME, then going back from the module, from the executable
// (triad-cli.exe standalone) and from the current folder.
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
 * Find seed in machine code (no dependencies on Julia).
 * TRIAD_SEED takes precedence (also used by CI), consistent with
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
 * True if the current seed is a stub (e.g. Linux E0: ELF of a few hundred
 * of bytes which only prints "Triad seed Linux OK"). Under 4 KB it cannot
 * be the full Triad-Core interpreter (E2): JS fallback is needed.
 */
export function seedIsStub(seedPath = findSeed()) {
  if (!seedPath) return true;
  try {
    const st = fs.statSync(seedPath);
    if (st.isFile() && st.size < 4096) return true;
    // Probe runtime: if the seed responds to a .td file with valid output it is real.
    return false;
  } catch {
    return true;
  }
}
/**
 * Seeds in machine code
 */
export async function runSeed(args = [], options = {}) {
  const seed = findSeed();
  if (!seed) {
    return { success: false, stdout: '', stderr: 'seed not found', exitCode: 1 };
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
 * Gets the absolute path to a file in the project
 */
export function projectPath(...segments) {
  return path.join(PROJECT_ROOT, ...segments);
}
/**
 * Check if a file exists
 */
export function fileExists(filePath) {
  return fs.existsSync(filePath);
}
/**
 * Reads a file
 */
export function readFile(filePath, encoding = 'utf-8') {
  return fs.readFileSync(filePath, encoding);
}
/**
 * Writes a file
 */
export function writeFile(filePath, content) {
  fs.writeFileSync(filePath, content, 'utf-8');
}