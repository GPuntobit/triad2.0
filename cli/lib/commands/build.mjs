import { runJulia, projectPath, fileExists, findJulia } from '../utils.mjs';

/**
 * Compila l'eseguibile standalone
 */
export async function buildStandalone(options = {}) {
  const buildScript = projectPath('bin', 'build_standalone.jl');

  if (!fileExists(buildScript)) {
    throw new Error(`Script build_standalone.jl non trovato: ${buildScript}`);
  }

  // Verifica Julia
  const juliaPath = findJulia();
  console.log('==> Compilazione eseguibile standalone...');
  console.log(`    Julia: ${juliaPath}`);
  console.log(`    Script: ${buildScript}`);

  const result = await runJulia(buildScript, []);

  if (!result.success) {
    console.error('✗ Build fallita');
    if (result.stderr) {
      console.error(result.stderr);
    }
    return false;
  }

  console.log('✓ Build completata con successo');
  if (result.stdout) {
    console.log(result.stdout);
  }

  // Verifica output
  const isWindows = process.platform === 'win32';
  const appName = isWindows ? 'triad-native.exe' : 'triad-native';
  const appPath = projectPath('bin', appName);

  if (fileExists(appPath)) {
    console.log(`    Eseguibile creato: ${appPath}`);
  } else {
    console.warn('⚠ Eseguibile non trovato dopo la build');
  }

  return true;
}

/**
 * Handler comando build standalone
 */
export async function handleBuildStandalone(options) {
  try {
    return await buildStandalone(options);
  } catch (error) {
    console.error(`Errore durante la build: ${error.message}`);
    return false;
  }
}
