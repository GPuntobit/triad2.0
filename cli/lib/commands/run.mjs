import path from 'path';
import { runSeed, findSeed, seedIsStub, projectPath, fileExists, runNode } from '../utils.mjs';
import chalk from 'chalk';
/**
 * Resolves the path to a Triad program: file existing in the cwd,
 * otherwise going back from the project root.
 */
function resolveProgram(file) {
  if (fileExists(path.resolve(file))) return path.resolve(file);
  const inRoot = projectPath(file);
  if (fileExists(inRoot)) return inRoot;
  return null;
}
/**
 * Run a .triad/.td program seeded in machine code.
 * On platforms where the seed is still a stub (Linux E0) use the interpreter
 * Reference JS seed/dev/triad_core.cjs, as does conformance/run.mjs.
 * Arguments after `--` are passed to the Triad program.
 */
export async function runProgram(file, programArgs = [], options = {}) {
  const prog = resolveProgram(file);
  if (!prog) {
    console.error(chalk.red(`X File not found: ${file}`));
    return false;
  }
  let result;
  const seed = findSeed();
  const jsInterp = projectPath('seed', 'dev', 'triad_core.cjs');
// Use the native seed only if it exists and is not a stub (Linux E0). Consistent
  // with bin/triad and conformance/run.mjs: on Windows the seed.exe is complete,
  // on Linux the E0 stub (<4KB) is recognized and the JS reference is used.
  const useNative = seed && !seedIsStub(seed);
  if (!options.native && !useNative && fileExists(jsInterp)) {
    // Seed stub or absent: Reference JS runtime
    result = await runNode(jsInterp, [prog, ...programArgs]);
  } else if (useNative) {
    result = await runSeed([prog, ...programArgs]);
  } else if (seed) {
    result = await runSeed([prog, ...programArgs]);
  } else {
    console.error(chalk.red('X Seed not found. Generate it with: triad-cli seed generate <windows|linux>'));
    return false;
  }
if (result.stdout) process.stdout.write(result.stdout.endsWith('\n') ? result.stdout : result.stdout + '\n');
  if (result.stderr) process.stderr.write(result.stderr);
if (options.verbose && !result.success) {
    console.error(chalk.gray(` exit code: ${result.exitCode}`));
  }
if (!result.success) {
    console.error(chalk.red(`X Program terminated with exit code ${result.exitCode}`));
    return false;
  }
  return true;
}
export async function handleRun(file, programArgs, options) {
  try {
    return await runProgram(file, programArgs || [], options);
  } catch (error) {
    console.error(chalk.red(`Error during execution: ${error.message}`));
    return false;
  }
}