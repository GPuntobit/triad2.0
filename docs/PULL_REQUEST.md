# feat(cli): command `run` and tooling VS Code extension (`ext check`/`ext package`)
## Summary
Extends the VS Code Triad CLI with two new capabilities, integrating support for the editor extension into `editors/vscode` and allowing direct execution of Triad programs from the command line.
**Branch:** `qwen-code-72490772-b8ec-4db4-9e8b-1a4ff6d961a8`
**Commit:** `30578bd` — 5 files changed, +263 lines
## Changes
### New commands
#### `triad-cli run <file> [-- args]` (`cli/lib/commands/run.mjs`, new)
- Run a `.triad`/`.td` program with the seed in machine code.
- Documented fallback: as long as the native seed is a stub (E0), on Linux/macOS use the reference JS interpreter `seed/dev/triad_core.cjs`, exactly as `conformance/run.mjs` does.
- `-n/--native` flag to force native seed; arguments after `--` are passed to the program.
- Exit code fixed: `1` on non-existent file or parse error, `0` on successful execution.
#### `triad-cli ext check` and `triad-cli ext package [-o FILE]` (`cli/lib/commands/ext.mjs`, new)
- **check**: valid `package.json`, `tmLanguage.xml` grammar and `language-configuration.json`; all JSON is parsed and verified; reports name, version, languages ​​and declared extensions.
- **package**: Package the `.vsix` using global `vsce` if available, otherwise `npx --yes @vscode/vsce`.
### Files touched
| Files | Change |
|---|---|
| `cli/lib/commands/run.mjs` | New — Triad program execution |
| `cli/lib/commands/ext.mjs` | New — VS Code extension validation and packaging |
| `cli/triad-cli.mjs` | Register `run` and `ext check\|package`; updated help and output of `status` |
| `cli/README.md` | Documented the "Run" and "VS Code Extension" + module architecture sections |
| `.gitignore` | Added `*.vsix` (packaging generated artifact) |
## Manual tests performed
- `node --check` on all modules → OK
- `triad-cli ext check` → `V Valid VS Code Extension — triad v0.2.0, triad: .triad,.td`
- `triad-cli ext package` → generated `editors/vscode/triad-0.2.0.vsix` (6 files, 4 KB) via `npx vsce`; artifact removed after verification
- `triad-cli run test_simple.td` → print `test`, exit 0
- `triad-cli run test_let.td` → print `15`
- Error handling: non-existent file and parse error return exit 1 with readable message
- `triad-cli status` lists new commands
- `Conformance` suite unchanged and still green
## Notes for reviewers
- The fallback to the JS interpreter is explicitly tied to the stub state of the seed (E0); when the native seed is complete, `-n/--native` becomes the root path without structural changes.
- No changes to existing commands (`build`, `test`, `status`).
## Checklist
- [x] CLI help and `status` updated
- [x] README updated
- [x] Build artifacts ignored (`.gitignore`)
- [x] Manual tests documented above