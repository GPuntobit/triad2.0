# 01 — Portare la GUI Windows alla CLI POSIX (bin/triad-cli)

Type: task
Status: open

## Contesto

La GUI Windows (`cli/windows-gui/TriadDesktop.cs`, .NET WinForms) è stata costruita sulla
CLI Node pre-beta.9: i pulsanti invocano `triad-cli status`, `triad-cli test run`,
`triad-cli test conformance`, `triad-cli ai verify`.

Con N18 (E3) la CLI Node è stata ridotta ai soli comandi di sviluppo (`seed`, `ai`, `ext`);
i comandi utente (`run`, `test`, `status`) sono passati alla CLI POSIX `bin/triad-cli`.
Di conseguenza:

- `status` e `test` non esistono più nella CLI Node → i pulsanti «Stato», «Test unitari» e
  «Conformance» della GUI falliscono;
- `IsProjectRoot` cerca ancora `conformance/run.mjs`, file rimosso in N17 (ora il percorso
  è `conformance/run.sh`): la GUI non riconosce più la root del repository;
- il binario `TriadDesktop.exe` non è ricostruibile su Linux (serve .NET SDK + WinForms) e
  per questo **non è stato pubblicato** in `v0.8.0-beta.9` (vedi le release notes).

## Task

1. Portare la GUI alla CLI POSIX: invocare `bin/triad-cli.cmd` (Windows) con gli stessi
   argomenti (`status`, `test conformance`, `test probes`, `test all`) invece della CLI Node.
2. Correggere `IsProjectRoot` sul layout corrente (`VERSION` + `conformance/run.sh` + `seed`).
3. Ricostruire `cli/dist/TriadDesktop.exe` su Windows (`cli/windows-gui/build.ps1`) e ricaricarlo
   come asset della release successiva.
4. Aggiornare `tests/desktop.sh` (regressione isolata) per coprire il percorso GUI.

## Riferimenti

- Release notes: `docs/releases/RELEASE_NOTES_v0.8.0-beta.9.md` (sezione «Known issues»).
- N18/E3: `CHANGELOG.md` § «toolchain Linux senza Node — install → run».
- Launcher POSIX già esistente: `bin/triad-desktop`.
