# Triad v0.3.0 — 2026-10-29
Release focused on the CLI and tooling of the VS Code extension, with all the
updates from the latest release (v0.2.0) included.
## ✨ New
### CLI: `triad-cli run`
- `triad-cli run <file> [-- args]` runs a `.triad` / `.td` program.
- Use seed in machine code; on Linux/macOS, as long as the ELF seed remains E0,
  falls back to the `seed/dev/triad_core.cjs` reference interpreter
  (forceable with `-n/--native`), as the conformance runner does.
- Exit code propagated; non-existent file or parse errors handled with exit 1.
### CLI: VS Code extension tooling (`ext`)
- `triad-cli ext check`: validate `package.json`, tmLanguage grammar and
  language-configuration of the `editors/vscode` extension; reports name,
  declared version, languages and extensions.
- `triad-cli ext package`: package the `.vsix` using global `vsce` if
  present, otherwise `npx --yes @vscode/vsce`; supports `-o/--out`.
## 🔧 Improvements
- Separate CLI modules: `cli/lib/commands/run.mjs` and `cli/lib/commands/ext.mjs`.
- CLI `status`, help and README updated with new commands.
- `*.vsix` added to `.gitignore` (packaging generated artifact).
## 📦 Maintenance and dependencies
- updated `esbuild` to 0.28.1 (PR #21, dependabot).
## 📚 Compliance and standards (since v0.2.0)
- New Core `gcd` case (Euclid, recursion and `%`); the Core suite has 37 cases.
- Golden versioned: `conformance/**/expected.out` and `expected.code` are now
  routes; the runner accepts `expected.golden` as a backup.
- `conformance/run.mjs` uses the `seed/dev/triad_core.cjs` interpreter on
  Linux/macOS and fails with `golden missing` instead of comparing with empty stdout.
- Julia removed from repository (`triad.jl`, `syntax.jl`, `test/`,
  `bin/build_standalone.jl`); the CI uses only Node and the seed.
- Added `LICENSE` MIT; including seed binaries for Windows and Linux.
## 📄 Documentation
- Description of the Pull Request in `PULL_REQUEST.md`.
- "Run" and "VS Code Extension" sections in the README CLI.
## Quick commands
```bash
node cli/triad-cli.mjs status          # stato degli stage e comandi disponibili
node cli/triad-cli.mjs run prog.triad  # esegue un programma Triad
node cli/triad-cli.mjs ext check       # valida l'estensione VS Code
node cli/triad-cli.mjs ext package     # genera il .vsix
```

Full changelog: [CHANGELOG.md](../../CHANGELOG.md)