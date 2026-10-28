import path from 'path';
import { runSeed, findSeed, seedIsStub, projectPath, fileExists, runNode } from '../utils.mjs';
import chalk from 'chalk';

/**
 * Risolve il percorso di un programma Triad: file esistente nel cwd,
 * altrimenti risalendo dalla root del progetto.
 */
function resolveProgram(file) {
  if (fileExists(path.resolve(file))) return path.resolve(file);
  const inRoot = projectPath(file);
  if (fileExists(inRoot)) return inRoot;
  return null;
}

/**
 * Esegue un programma .triad/.td con il seed in codice macchina.
 * Su piattaforme dove il seed e' ancora uno stub (Linux E0) usa l'interprete
 * JS di riferimento seed/dev/triad_core.cjs, come fa conformance/run.mjs.
 * Argomenti dopo `--` vengono passati al programma Triad.
 */
export async function runProgram(file, programArgs = [], options = {}) {
  const prog = resolveProgram(file);
  if (!prog) {
    console.error(chalk.red(`X File non trovato: ${file}`));
    return false;
  }

  let result;
  const seed = findSeed();
  const jsInterp = projectPath('seed', 'dev', 'triad_core.cjs');

  // Usa il seed nativo solo se esiste e non è uno stub (Linux E0). Coerente
  // con bin/triad e conformance/run.mjs: su Windows il seed.exe è completo,
  // su Linux lo stub E0 (<4KB) viene riconosciuto e si usa il JS reference.
  const useNative = seed && !seedIsStub(seed);
  if (!options.native && !useNative && fileExists(jsInterp)) {
    // Seed stub o assente: runtime JS di riferimento
    result = await runNode(jsInterp, [prog, ...programArgs]);
  } else if (useNative) {
    result = await runSeed([prog, ...programArgs]);
  } else if (seed) {
    result = await runSeed([prog, ...programArgs]);
  } else {
    console.error(chalk.red('X Seed non trovato. Generarlo con: triad-cli seed generate <windows|linux>'));
    return false;
  }

  if (result.stdout) process.stdout.write(result.stdout.endsWith('\n') ? result.stdout : result.stdout + '\n');
  if (result.stderr) process.stderr.write(result.stderr);

  if (options.verbose && !result.success) {
    console.error(chalk.gray(`  exit code: ${result.exitCode}`));
  }

  if (!result.success) {
    console.error(chalk.red(`X Programma terminato con exit code ${result.exitCode}`));
    return false;
  }
  return true;
}

export async function handleRun(file, programArgs, options) {
  try {
    return await runProgram(file, programArgs || [], options);
  } catch (error) {
    console.error(chalk.red(`Errore durante l'esecuzione: ${error.message}`));
    return false;
  }
}
