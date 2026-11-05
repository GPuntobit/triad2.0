import { runSh, projectPath, fileExists } from '../utils.mjs';

/**
 * Esegue la conformance suite via l'harness POSIX `conformance/run.sh`
 * (senza Node: decisione "Harness di verifica senza Node", ticket
 * .scratch/seed-linux-nativo/issues/08, Q4 transizione in un colpo solo
 * + Q9 interfaccia). Suite cablata: 39 casi `conformance/core/cases`,
 * nessun flag `--cases`/`--skip`; solo `--update` (Q6).
 */
export async function runConformance(options = {}) {
  const runner = projectPath('conformance', 'run.sh');

  if (!fileExists(runner)) {
    throw new Error(`Runner conformance/run.sh non trovato: ${runner}`);
  }

  console.log('==> Esecuzione conformance suite...');
  console.log(`    Runner: ${runner}`);

  const args = [];
  if (options.update) {
    args.push('--update');
    console.log("    Modalita': update (rigenera golden)");
  }

  const result = await runSh(runner, args);

  if (result.stdout) console.log(result.stdout);
  if (!result.success) {
    console.error('X Conformance fallita');
    if (result.stderr) console.error(result.stderr);
    return false;
  }
  console.log('V Conformance completata con successo');
  return true;
}

/**
 * Esegue i test unitari (sostituiti dalla conformance Core via seed)
 */
export async function runTests(options = {}) {
  console.log('==> Test unitari: usare la conformance Core (seed) al posto di test/runtests.jl');
  return await runConformance(options);
}

export async function handleTestRun(options) {
  try { return await runTests(options); }
  catch (error) { console.error(`Errore durante i test: ${error.message}`); return false; }
}

export async function handleTestConformance(options) {
  try { return await runConformance(options); }
  catch (error) { console.error(`Errore durante la conformance: ${error.message}`); return false; }
}
