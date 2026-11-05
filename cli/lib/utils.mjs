import { execa } from 'execa';
import path from 'path';
import { fileURLToPath } from 'url';
import fs from 'fs';
function moduleDir() {
  try { return path.dirname(fileURLToPath(import.meta.url)); } catch { return null; }
}
function isProjectRoot(dir) {
  return fs.existsSync(path.join(dir, 'conformance', 'run.sh')) && fs.existsSync(path.join(dir, 'seed'));
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

// Nota (N18, decisione "CLI e toolchain senza Node"): la logica di
// stub/fallback (`seedIsStub`, `runSeed`) è uscita con `run.mjs` — la CLI
// Node di sviluppo non esegue più programmi Triad; il percorso utente
// (run/test/status) vive in `bin/triad-cli` (shell POSIX, pura delega).

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
