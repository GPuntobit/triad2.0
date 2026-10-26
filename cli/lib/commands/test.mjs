import { runJulia, projectPath, fileExists } from '../utils.mjs';

/**
 * Esegue i test unitari
 */
export async function runTests(options = {}) {
  const testScript = projectPath('test', 'runtests.jl');

  if (!fileExists(testScript)) {
    console.warn(`⚠ Script runtests.jl non trovato: ${testScript}`);
    console.warn('  I test unitari potrebbero non essere ancora implementati in questo progetto.');
    console.warn('  Verifica che la directory test/ esistae contenga runtests.jl');
    return false;
  }

  console.log('==> Esecuzione test unitari...');
  console.log(`    Script: ${testScript}`);

  const result = await runJulia(testScript, []);

  if (!result.success) {
    console.error('✗ Test falliti');
    if (result.stderr) {
      console.error(result.stderr);
    }
    return false;
  }

  console.log('✓ Test completati con successo');
  if (result.stdout) {
    console.log(result.stdout);
  }

  return true;
}

/**
 * Esegue la conformance suite
 */
export async function runConformance(options = {}) {
  const conformanceScript = projectPath('conformance', 'run.jl');

  if (!fileExists(conformanceScript)) {
    throw new Error(`Script conformance/run.jl non trovato: ${conformanceScript}`);
  }

  console.log('==> Esecuzione conformance suite...');
  console.log(`    Script: ${conformanceScript}`);

  const args = [];
  if (options.update) {
    args.push('--update');
    console.log('    Modalità: update (rigenera golden)');
  }
  if (options.cases) {
    args.push('--cases', options.cases);
    console.log(`    Cases: ${options.cases}`);
  }

  const result = await runJulia(conformanceScript, args);

  if (!result.success) {
    console.error('✗ Conformance fallita');
    if (result.stderr) {
      console.error(result.stderr);
    }
    return false;
  }

  console.log('✓ Conformance completata con successo');
  if (result.stdout) {
    console.log(result.stdout);
  }

  return true;
}

/**
 * Handler comando test run
 */
export async function handleTestRun(options) {
  try {
    return await runTests(options);
  } catch (error) {
    console.error(`Errore durante l'esecuzione dei test: ${error.message}`);
    return false;
  }
}

/**
 * Handler comando test conformance
 */
export async function handleTestConformance(options) {
  try {
    return await runConformance(options);
  } catch (error) {
    console.error(`Errore durante la conformance: ${error.message}`);
    return false;
  }
}
