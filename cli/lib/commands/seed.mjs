import { runNode, projectPath, fileExists } from '../utils.mjs';
import crypto from 'crypto';

/**
 * Genera seed Windows
 */
export async function generateWindowsSeed(options = {}) {
  const genSeedPath = projectPath('seed', 'dev', 'gen_seed.js');
  const outputHex = options.output || projectPath('seed', 'windows-x86_64', 'seed.hex');

  if (!fileExists(genSeedPath)) {
    throw new Error(`Generatore seed non trovato: ${genSeedPath}`);
  }

  console.log('==> Generazione seed Windows...');
  console.log(`    Script: ${genSeedPath}`);
  console.log(`    Output: ${outputHex}`);

  const result = await runNode(genSeedPath, [outputHex]);

  if (!result.success) {
    console.error('✗ Generazione fallita');
    console.error(result.stderr);
    return false;
  }

  console.log('✓ Seed generato con successo');

  // Calcola hash del file generato
  if (fileExists(outputHex)) {
    const hash = crypto.createHash('sha256');
    const data = await import('fs').then(fs => fs.readFileSync(outputHex));
    hash.update(data);
    const sha256 = hash.digest('hex').toUpperCase();
    console.log(`    SHA-256: ${sha256}`);
  }

  return true;
}

/**
 * Genera seed Linux
 */
export async function generateLinuxSeed(options = {}) {
  const genSeedPath = projectPath('seed', 'dev', 'gen_seed_linux.js');
  const outputHex = options.output || projectPath('seed', 'linux-x86_64', 'seed.hex');

  if (!fileExists(genSeedPath)) {
    throw new Error(`Generatore seed Linux non trovato: ${genSeedPath}`);
  }

  console.log('==> Generazione seed Linux...');
  console.log(`    Script: ${genSeedPath}`);
  console.log(`    Output: ${outputHex}`);

  const result = await runNode(genSeedPath, [outputHex]);

  if (!result.success) {
    console.error('✗ Generazione fallita');
    console.error(result.stderr);
    return false;
  }

  console.log('✓ Seed generato con successo');

  // Calcola hash del file generato
  if (fileExists(outputHex)) {
    const hash = crypto.createHash('sha256');
    const data = await import('fs').then(fs => fs.readFileSync(outputHex));
    hash.update(data);
    const sha256 = hash.digest('hex').toUpperCase();
    console.log(`    SHA-256: ${sha256}`);
  }

  return true;
}

/**
 * Handler comando seed generate
 */
export async function handleSeedGenerate(platform, options) {
  if (!platform) {
    console.error('Errore: specifica la piattaforma (windows|linux)');
    return false;
  }

  try {
    if (platform === 'windows') {
      return await generateWindowsSeed(options);
    } else if (platform === 'linux') {
      return await generateLinuxSeed(options);
    } else {
      console.error(`Piattaforma non supportata: ${platform}`);
      console.error('Piattaforme supportate: windows, linux');
      return false;
    }
  } catch (error) {
    console.error(`Errore durante la generazione: ${error.message}`);
    return false;
  }
}
