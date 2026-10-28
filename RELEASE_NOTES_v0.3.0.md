# Triad v0.3.0 — 2026-10-29

Release incentrata sulla CLI e sul tooling dell'estensione VS Code, con tutti gli
aggiornamenti dall'ultima release (v0.2.0) inclusi.

## ✨ Novità

### CLI: `triad-cli run`
- `triad-cli run <file> [-- args]` esegue un programma `.triad` / `.td`.
- Usa il seed in codice macchina; su Linux/macOS, finché il seed ELF resta E0,
  fa fallback all'interprete di riferimento `seed/dev/triad_core.cjs`
  (forzabile con `-n/--native`), come fa il runner di conformità.
- Exit code propagato; errori di file inesistente o parse gestiti con exit 1.

### CLI: tooling estensione VS Code (`ext`)
- `triad-cli ext check`: valida `package.json`, grammatica tmLanguage e
  language-configuration dell'estensione `editors/vscode`; riporta nome,
  versione, linguaggi ed estensioni dichiarate.
- `triad-cli ext package`: pacchettizza il `.vsix` usando `vsce` globale se
  presente, altrimenti `npx --yes @vscode/vsce`; supporta `-o/--out`.

## 🔧 Miglioramenti
- Moduli CLI separati: `cli/lib/commands/run.mjs` e `cli/lib/commands/ext.mjs`.
- `status`, help e README della CLI aggiornati con i nuovi comandi.
- `*.vsix` aggiunto a `.gitignore` (artefatto generato dal packaging).

## 📦 Manutenzione e dipendenze
- `esbuild` aggiornata a 0.28.1 (PR #21, dependabot).

## 📚 Conformità e standard (dalla v0.2.0)
- Nuovo caso Core `gcd` (Euclide, ricorsione e `%`); la suite Core ha 37 casi.
- Golden versionati: `conformance/**/expected.out` e `expected.code` sono ora
  tracciati; il runner accetta `expected.golden` come copia di riserva.
- `conformance/run.mjs` usa l'interprete `seed/dev/triad_core.cjs` su
  Linux/macOS e fallisce con `golden mancante` invece di confrontare con stdout vuoto.
- Julia rimossa dal repository (`triad.jl`, `syntax.jl`, `test/`,
  `bin/build_standalone.jl`); la CI usa solo Node e il seed.
- Aggiunta `LICENSE` MIT; inclusi i binari del seed per Windows e Linux.

## 📄 Documentazione
- Descrizione della Pull Request in `PULL_REQUEST.md`.
- Sezioni "Run" ed "Estensione VS Code" nel README CLI.

## Comandi rapidi
```bash
node cli/triad-cli.mjs status          # stato degli stage e comandi disponibili
node cli/triad-cli.mjs run prog.triad  # esegue un programma Triad
node cli/triad-cli.mjs ext check       # valida l'estensione VS Code
node cli/triad-cli.mjs ext package     # genera il .vsix
```

Full changelog: [CHANGELOG.md](./CHANGELOG.md)
