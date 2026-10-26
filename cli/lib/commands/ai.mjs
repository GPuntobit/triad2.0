import { runJulia, projectPath, fileExists } from '../utils.mjs';
import fs from 'fs';
import path from 'path';

/**
 * Verifica le soluzioni AI
 */
export async function verifyAISolutions(options = {}) {
  const verifyScript = projectPath('ai', 'verify.jl');
  const tasksDir = options.tasks || projectPath('ai', 'tasks');

  if (!fileExists(verifyScript)) {
    throw new Error(`Script verify.jl non trovato: ${verifyScript}`);
  }

  console.log('==> Verifica soluzioni AI...');
  console.log(`    Script: ${verifyScript}`);
  console.log(`    Tasks: ${tasksDir}`);

  const args = [];
  if (options.tasks) {
    args.push('--tasks', options.tasks);
  }
  if (options.verbose) {
    args.push('--verbose');
  }

  const result = await runJulia(verifyScript, args);

  if (!result.success) {
    console.error('✗ Verifica fallita');
    if (result.stderr) {
      console.error(result.stderr);
    }
    return false;
  }

  console.log('✓ Verifica completata');
  if (result.stdout) {
    console.log(result.stdout);
  }

  return true;
}

/**
 * Handler comando ai verify
 */
export async function handleAIVerify(options) {
  try {
    return await verifyAISolutions(options);
  } catch (error) {
    console.error(`Errore durante la verifica: ${error.message}`);
    return false;
  }
}
