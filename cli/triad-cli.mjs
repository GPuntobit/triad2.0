#!/usr/bin/env node
import { Command } from 'commander';
import { handleSeedGenerate } from './lib/commands/seed.mjs';
import { handleAIVerify } from './lib/commands/ai.mjs';
import { handleExtCheck, handleExtPackage } from './lib/commands/ext.mjs';

const program = new Command();

program
  .name('triad-cli')
  .description('CLI Node di sviluppo per Triad 2.0 (solo comandi dev: seed, ai, ext). Il percorso utente (run/test/status) vive nella CLI POSIX bin/triad-cli, senza Node.')
  .version('1.0.0');

// Comando seed
program
  .command('seed')
  .description('Seed generation commands')
  .addCommand(
    new Command('generate')
      .description('Generate seed binary (Windows or Linux)')
      .argument('<platform>', 'Platform: windows or linux')
      .option('-o, --output <path>', 'Output hex file path')
      .action(async (platform, options) => {
        const success = await handleSeedGenerate(platform, options);
        process.exit(success ? 0 : 1);
      })
  );

// Comando ai
program
  .command('ai')
  .description('AI benchmark and verification commands')
  .addCommand(
    new Command('verify')
      .description('Verify AI-generated solutions against golden tests')
      .option('-t, --tasks <dir>', 'Tasks directory')
      .option('-v, --verbose', 'Verbose output')
      .action(async (options) => {
        const success = await handleAIVerify(options);
        process.exit(success ? 0 : 1);
      })
  );

// Comando ext (estensione VS Code)
program
  .command('ext')
  .description('VS Code extension commands (editors/vscode)')
  .addCommand(
    new Command('check')
      .description('Validate the extension structure (package.json, grammar, language-configuration)')
      .action(async () => {
        const success = await handleExtCheck();
        process.exit(success ? 0 : 1);
      })
  )
  .addCommand(
    new Command('package')
      .description('Package the extension into a .vsix with vsce')
      .option('-o, --out <path>', 'Output .vsix path')
      .action(async (options) => {
        const success = await handleExtPackage(options);
        process.exit(success ? 0 : 1);
      })
  );

// Parse arguments
program.parse(process.argv);

// Show help if no command provided
if (!process.argv.slice(2).length) {
  program.outputHelp();
}
