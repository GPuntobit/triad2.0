# feat(cli): comanda `run` e tooling estensione VS Code (`ext check`/`ext package`)

## Riepilogo

Estende la CLI di VS Code Triad con due nuove capacità, integrando il supporto per l'estensione editor in `editors/vscode` e consentendo l'esecuzione diretta di programmi Triad dalla riga di comando.

**Branch:** `qwen-code-72490772-b8ec-4db4-9e8b-1a4ff6d961a8`
**Commit:** `30578bd` — 5 file modificati, +263 righe

## Modifiche

### Nuovi comandi

#### `triad-cli run <file> [-- args]` (`cli/lib/commands/run.mjs`, nuovo)
- Esegue un programma `.triad`/`.td` con il seed in codice macchina.
- Fallback documentato: finché il seed nativo è uno stub (E0), su Linux/macOS usa l'interprete JS di riferimento `seed/dev/triad_core.cjs`, esattamente come fa `conformance/run.mjs`.
- Flag `-n/--native` per forzare il seed nativo; gli argomenti dopo `--` vengono passati al programma.
- Exit code corretti: `1` su file inesistente o errore di parse, `0` a esecuzione riuscita.

#### `triad-cli ext check` e `triad-cli ext package [-o FILE]` (`cli/lib/commands/ext.mjs`, nuovo)
- **check**: valida `package.json`, la grammatica `tmLanguage.xml` e `language-configuration.json`; tutti i JSON vengono parsati e verificati; riporta nome, versione, linguaggi ed estensioni dichiarate.
- **package**: pacchettizza il `.vsix` usando `vsce` globale se disponibile, altrimenti `npx --yes @vscode/vsce`.

### File toccati

| File | Cambio |
|---|---|
| `cli/lib/commands/run.mjs` | Nuovo — esecuzione programmi Triad |
| `cli/lib/commands/ext.mjs` | Nuovo — validazione e packaging estensione VS Code |
| `cli/triad-cli.mjs` | Registrati `run` ed `ext check\|package`; aggiornati help e output di `status` |
| `cli/README.md` | Documentate le sezioni "Run" ed "Estensione VS Code" + architettura moduli |
| `.gitignore` | Aggiunto `*.vsix` (artefatto generato dal packaging) |

## Test manuali eseguiti

- `node --check` su tutti i moduli → OK
- `triad-cli ext check` → `V Estensione VS Code valida — triad v0.2.0, triad: .triad,.td`
- `triad-cli ext package` → generato `editors/vscode/triad-0.2.0.vsix` (6 file, 4 KB) via `npx vsce`; artefatto rimosso dopo la verifica
- `triad-cli run test_simple.td` → stampa `test`, exit 0
- `triad-cli run test_let.td` → stampa `15`
- Error handling: file inesistente e parse error restituiscono exit 1 con messaggio leggibile
- `triad-cli status` elenca i nuovi comandi
- Suite `conformance` invariata e ancora verde

## Note per i reviewer

- Il fallback all'interprete JS è esplicitamente legato allo stato stub del seed (E0); quando il seed nativo sarà completo, `-n/--native` diventa il percorso principale senza modifiche strutturali.
- Nessun cambiamento ai comandi esistenti (`build`, `test`, `status`).

## Checklist

- [x] Help CLI e `status` aggiornati
- [x] README aggiornato
- [x] Artefatti build ignorati (`.gitignore`)
- [x] Test manuali documentati sopra
