import { runNode, projectPath, fileExists } from '../utils.mjs';

/**
 * Esegue la conformance suite (via seed, senza Julia)
 */
export async function runConformance(options = {}) {
  const runner = projectPath('conformance', 'run.mjs');

  if (!fileExists(runner)) {
    throw new Error(`Runner conformance/run.mjs non trovato: ${runner}`);
  }

  console.log('==> Esecuzione conformance suite...');
  console.log(`    Runner: ${runner}`);

  const args = [];
  const cases = options.cases || projectPath('conformance', 'core', 'cases');
  args.push('--cases', cases);
  if (options.update) {
    args.push('--update');
    console.log("    Modalita': update (rigenera golden)");
  }
  if (options.skip) args.push('--skip', options.skip);
  else args.push('--skip', 'liste');
  console.log(`    Cases: ${cases}`);

  const result = await runNode(runner, args);

  if (!result.success) {
    console.error('X Conformance fallita');
    if (result.stderr) console.error(result.stderr);
    return false;
  }
  console.log('V Conformance completata con successo');
  if (result.stdout) console.log(result.stdout);
  return true;
}

/**
 * Esegue i test unitari (sostituiti dalla conformance Core via seed)
 */
export async function runTests(options = {}) {
  console.log('==> Test unitari: usare la conformance Core (seed) al posto di test/runtests.jl');
  return await runConformance({ ...options, cases: options.cases || projectPath('conformance', 'core', 'cases'), skip: 'liste' });
}

export async function handleTestRun(options) {
  try { return await runTests(options); }
  catch (error) { console.error(`Errore durante i test: ${error.message}`); return false; }
}

export async function handleTestConformance(options) {
  try { return await runConformance(options); }
  catch (error) { console.error(`Errore durante la conformance: ${error.message}`); return false; }
}

