# Triad 2.0 – Beta 3 (v0.8.0-beta.3) — 2026-10-29

Pre-release della serie **Triad 2.0**. Questa release include **tutti gli aggiornamenti**
dalla v0.2.0 a oggi (gli stessi della v0.3.0, che resta nel changelog ma è superata da
questa beta).

## ✨ Novità principali

### CLI: `triad-cli run`
- `triad-cli run <file> [-- args]` esegue un programma `.triad` / `.td`.
- Usa il seed in codice macchina; su Linux/macOS, finché il seed ELF resta E0,
  fa fallback all'interprete di riferimento `seed/dev/triad_core.cjs`
  (forzabile con `-n/--native`), come il runner di conformità.
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
- Estensione VS Code verificata (`triad` v0.2.0, `.triad`/`.td`) e pacchetizzabile da CLI.

## 📚 Conformità e standard (inclusi dalla v0.2.0)
- Nuovo caso Core `gcd` (Euclide, ricorsione e `%`); la suite Core ha 37 casi.
- Golden versionati: `conformance/**/expected.out` e `expected.code` tracciati;
  il runner accetta `expected.golden` come copia di riserva.
- `conformance/run.mjs` usa l'interprete `seed/dev/triad_core.cjs` su
  Linux/macOS e fallisce con `golden mancante` invece di confrontare con stdout vuoto.
- Julia rimossa dal repository (`triad.jl`, `syntax.jl`, `test/`,
  `bin/build_standalone.jl`); la CI usa solo Node e il seed.

## 📦 Manutenzione e dipendenze
- `esbuild` aggiornata a 0.28.1 (PR #21, dependabot).
- `*.vsix` aggiunto a `.gitignore` (artefatto generato dal packaging).
- `LICENSE` MIT aggiunta; binari del seed Windows/Linux inclusi nel repository.

## 📄 Documentazione
- `CHANGELOG.md` con la sezione 0.8.0-beta.3; descrizione PR in `PULL_REQUEST.md`.

## Upgrade
Nessuna modifica normativa al linguaggio rispetto alla v0.3.0: basta aggiornare
il repository e rieseguire la suite:
```bash
node conformance/run.mjs          # suite di conformità
node cli/triad-cli.mjs status     # stato CLI e comandi disponibili
node cli/triad-cli.mjs ext check  # verifica estensione VS Code
```

## Note per i pre-rilasci beta
Questa è una beta di Triad 2.0: comportamento e API della CLI possono cambiare
nelle prossime beta prima della 2.0 stabile. Il seed nativo è ancora E0 su
Linux/macOS (fallback JS attivo).
