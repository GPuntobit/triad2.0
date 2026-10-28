#!/usr/bin/env node
import { Command } from 'commander';
import chalk from 'chalk';
import { handleSeedGenerate } from './lib/commands/seed.mjs';
import { handleAIVerify } from './lib/commands/ai.mjs';
import { handleBuildStandalone } from './lib/commands/build.mjs';
import { handleTestRun, handleTestConformance } from './lib/commands/test.mjs';
import { handleRun } from './lib/commands/run.mjs';
import { handleExtCheck, handleExtPackage } from './lib/commands/ext.mjs';
import { findSeed, projectPath } from './lib/utils.mjs';

const program = new Command();

program
  .name('triad-cli')
  .description('Unified CLI for Triad 2.0 development tools')
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

// Comando build
program
  .command('build')
  .description('Build and packaging commands')
  .addCommand(
    new Command('standalone')
      .description('Build standalone Triad executable')
      .action(async (options) => {
        const success = await handleBuildStandalone(options);
        process.exit(success ? 0 : 1);
      })
  );

// Comando test
program
  .command('test')
  .description('Test and verification commands')
  .addCommand(
    new Command('run')
      .description('Run unit tests')
      .option('-v, --verbose', 'Verbose output')
      .action(async (options) => {
        const success = await handleTestRun(options);
        process.exit(success ? 0 : 1);
      })
  )
  .addCommand(
    new Command('conformance')
      .description('Run conformance suite')
      .option('-u, --update', 'Update golden outputs (development only)')
      .option('-c, --cases <path>', 'Specific cases directory')
      .action(async (options) => {
        const success = await handleTestConformance(options);
        process.exit(success ? 0 : 1);
      })
  );

// Comando run
program
  .command('run')
  .description('Run a Triad program (.triad/.td) with the machine-code seed')
  .argument('<file>', 'Program file (e.g. test_func.triad)')
  .argument('[args...]', 'Arguments passed to the program (after --)')
  .option('-v, --verbose', 'Verbose output on failure')
  .option('-n, --native', 'Force the machine-code seed runtime (skip JS fallback)')
  .allowUnknownOption()
  .action(async (file, args, options) => {
    const success = await handleRun(file, args, options);
    process.exit(success ? 0 : 1);
  });

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

// Comando status
program
  .command('status')
  .description('Show project status and environment info')
  .action(() => {
    console.log(chalk.bold('Triad 2.0 CLI Status'));
    console.log('');
    console.log('Environment:');
    console.log(`  Node.js: ${process.version}`);
    console.log(`  Platform: ${process.platform}`);
    console.log(`  Seed: ${findSeed() || 'non trovato'}`);
    console.log('');
    console.log('Project:');
    console.log(`  Root: ${projectPath()}`);
    console.log('');
    console.log('Available commands:');
    console.log('  triad-cli seed generate <platform>  Generate seed binary');
    console.log('  triad-cli ai verify                  Verify AI solutions');
    console.log('  triad-cli build standalone           Build standalone executable');
    console.log('  triad-cli run <file> [-- args]       Run a Triad program (.triad/.td)');
    console.log('  triad-cli test run                    Run unit tests');
    console.log('  triad-cli test conformance            Run conformance suite');
    console.log('  triad-cli ext check                   Validate VS Code extension');
    console.log('  triad-cli ext package                 Package VS Code extension (.vsix)');
    console.log('  triad-cli status                      Show this status');
  });

// Parse arguments
program.parse(process.argv);

// Show help if no command provided
if (!process.argv.slice(2).length) {
  program.outputHelp();
}
