# refactor(repo): riordino della struttura delle cartelle

Branch: `qwen-code-25b29def-032d-42a2-9df2-e2fd8967086e`
Commit: `0e209d4` + `7bb8dc6` — 57 file toccati (tutti gli spostamenti registrati con `git mv`)

## Riepilogo

Riorganizza il repository senza modificare i percorsi contrattuali (`bin/`, `seed/<piattaforma>/`, `conformance/`, `selfhost/`, `examples/`, `cli/`, `editors/`, `VERSION`, `LICENSE`, `install.sh`). La root viene ripulita dai file sciolti; tutti i riferimenti nei file di build, CI e documentazione sono stati verificati uno a uno prima dello spostamento.

## Spostamenti

| Da | A | Motivo |
|---|---|---|
| `test_get.td`, `test_let.td`, `test_simple.td` | `probes/` | Probe usati da CI e `install.sh`; `bin/test_td.txt` (residuo di debug) li accompagna |
| `MANUALE.md`, `PREFazione.md`, `TUTORIAL-RU.md` | `docs/` | Insieme al sito GitHub Pages che già li referenzia |
| `RELEASE_NOTES_v0.3.0.md`, `RELEASE_NOTES_v0.8.0-beta.3.md` | `docs/releases/` | Note di release storiche |
| `PULL_REQUEST.md` | `docs/PULL_REQUEST.md` | Allineato al riordino (secondo commit) |
| `.webcmd/graphify/` + zip plugin | `tools/webcmd-graphify/` | Nessun tool sparso fuori dalle directory dedicate |
| `Developer`, `install-triad-ext.bat` | *(eliminati)* | File vuoti (0 byte) committati per errore; un `.bat` vuoto andava rimosso, non ricollocato |

## Riferimenti aggiornati

- `.github/workflows/ci.yml`: probe Linux → `probes/…`; probe Windows → `probes\test_get.td` (path relativo alla cwd del runner, richiesto da `Start-Process`)
- `install.sh`: verifica finale su `$ROOT/probes/test_simple.td`; corretto l'estrazione dell'usage (`sed -n '2,17p'` → `'3,18p'`), scalata dalla sezione Termux nel README
- `scripts/build-libro.mjs`, `scripts/build-epub.cjs`: letture da `docs/PREFazione.md` / `docs/MANUALE.md`
- `README.md`: sezione "Project Structure" riscritta sul nuovo assetto + link a `docs/MANUALE.md`
- `plan.md`, `TUTORIAL.md` (tabella file), `CHANGELOG.md` (voce "Non rilasciato — riordino della struttura")

Nota: i file di registrazione storica (`STATUS.md`, `TASK.md`, vecchi `PULL_REQUEST`) conservano i nomi precedenti dei probe perché documentano eventi passati. `obsidian-triad/Grafo Graphify.md` è output generato: va rigenerato con `graphify update .`.

## Fix CI: workflow download-chart (Node.js 20 deprecato)

Il job `chart` mostrava il warning di deprecazione perche' usava
`actions/checkout@v4` e `actions/setup-python@v5`, che vengono forzati su
Node.js 24 con avviso (Node 20 deprecato: github.blog/changelog/2025-09-19).
Adeguati i pin a `checkout@v7` (gia' usato negli altri workflow) e rimosso
`setup-python`: `scripts/download_chart.py` usa solo la libreria standard e
`python3` e' gia' presente su ubuntu-latest. YAML validato; script eseguito
localmente senza dipendenze extra (exit 0, fallback ai tag git se l'API non e'
raggiungibile).

## Verifica post-spostamento

- `node conformance/run.mjs` → `conformance: OK` (37/37)
- `triad probes/test_simple.td` → `test`; seed ELF E0 invariato
- `probes/test_get.td` fallisce con l'interprete JS di riferimento: estensione presente solo nel seed PE, testata nel job Windows (comportamento preesistente)
- `examples/assaggio.td` ha un errore di parse preesistente, non correlato
