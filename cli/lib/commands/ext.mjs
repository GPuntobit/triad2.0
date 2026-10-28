import { execa } from 'execa';
import path from 'path';
import fs from 'fs';
import chalk from 'chalk';
import { projectPath } from '../utils.mjs';

const VSCODE_DIR = projectPath('editors', 'vscode');

/**
 * Verifica che la cartella editors/vscode sia una struttura valida per vsce:
 * package.json con contributes.languages/grammars, grammar e language-configuration.
 */
export function checkExtension(dir = VSCODE_DIR) {
  const pkgPath = path.join(dir, 'package.json');
  if (!fs.existsSync(pkgPath)) return { ok: false, message: `manca package.json in ${dir}` };

  let pkg;
  try {
    pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf8'));
  } catch (e) {
    return { ok: false, message: `package.json non valido JSON: ${e.message}` };
  }

  const langs = (pkg.contributes && pkg.contributes.languages) || [];
  const grammars = (pkg.contributes && pkg.contributes.grammars) || [];
  if (!langs.length) return { ok: false, message: 'nessun linguaggio dichiarato in contributes.languages' };

  const errors = [];
  for (const g of grammars) {
    const gp = path.join(dir, g.path.replace(/^\.\//, ''));
    if (!fs.existsSync(gp)) { errors.push(`grammar mancante: ${g.path}`); continue; }
    try { JSON.parse(fs.readFileSync(gp, 'utf8')); }
    catch (e) { errors.push(`grammar non valido JSON: ${g.path} - ${e.message}`); }
  }
  for (const l of langs) {
    if (!l.configuration) continue;
    const cp = path.join(dir, l.configuration.replace(/^\.\//, ''));
    if (!fs.existsSync(cp)) { errors.push(`language-configuration mancante: ${l.configuration}`); continue; }
    try { JSON.parse(fs.readFileSync(cp, 'utf8')); }
    catch (e) { errors.push(`language-configuration non valido JSON: ${l.configuration} - ${e.message}`); }
  }
  if (errors.length) return { ok: false, message: errors.join('; ') };

  return {
    ok: true,
    info: {
      name: pkg.name,
      version: pkg.version,
      languages: langs.map((l) => `${l.id}: ${(l.extensions || []).join(',')}`),
      grammars: grammars.length,
    },
  };
}

async function findVsce() {
  try {
    await execa('vsce', ['--version'], { stdio: 'ignore' });
    return { command: 'vsce', prefix: [] };
  } catch {
    /* vsce non installato globalmente: usa npx */
  }
  return { command: 'npx', prefix: ['--yes', '@vscode/vsce'] };
}

/**
 * Pacchettizza l'estensione VS Code in un .vsix (vsce package).
 */
export async function packageExtension(options = {}) {
  console.log(chalk.bold('Pacchetto estensione VS Code (Triad)'));
  console.log(`  Cartella: ${VSCODE_DIR}`);

  const check = checkExtension();
  if (!check.ok) {
    console.error(chalk.red(`X Struttura estensione non valida: ${check.message}`));
    return false;
  }
  console.log(`  Linguaggi: ${check.info.languages.join(', ')}`);
  console.log(`  Grammatiche: ${check.info.grammars}`);

  const vsce = await findVsce();
  const args = [...vsce.prefix, 'package', '--allow-missing-repository'];
  if (options.out) args.push('--out', options.out);

  console.log(`==> ${vsce.command} ${args.join(' ')}`);
  try {
    const result = await execa(vsce.command, args, { cwd: VSCODE_DIR });
    if (result.stdout) console.log(result.stdout);
    const match = /(\S+\.vsix)/.exec(result.stdout || '');
    console.log(chalk.green('V Estensione pacchettizzata') + (match ? `: ${path.join(VSCODE_DIR, match[1])}` : ''));
    console.log('  Installazione: code --install-extension <file>.vsix');
    return true;
  } catch (error) {
    if (error.stdout) console.error(error.stdout);
    console.error(chalk.red('X vsce package fallita.'));
    console.error(chalk.gray('  Prova a installare vsce: npm install -g @vscode/vsce'));
    if (error.stderr) console.error(error.stderr);
    return false;
  }
}

export async function handleExtCheck() {
  const check = checkExtension();
  if (!check.ok) {
    console.error(chalk.red(`X Estensione non valida: ${check.message}`));
    return false;
  }
  console.log(chalk.green('V Estensione VS Code valida'));
  console.log(`  Nome: ${check.info.name} v${check.info.version}`);
  console.log(`  Linguaggi: ${check.info.languages.join(', ')}`);
  console.log(`  Grammatiche: ${check.info.grammars}`);
  return true;
}

export async function handleExtPackage(options) {
  try {
    return await packageExtension(options);
  } catch (error) {
    console.error(chalk.red(`Errore durante il pacchetto: ${error.message}`));
    return false;
  }
}
