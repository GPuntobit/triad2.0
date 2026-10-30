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

## Secondo passaggio: cartelle piu' ordinate

- `scripts/` divisa per scopo: `scripts/docs/` (build libro/EPUB/DOCX, frontespizio, grafico download), `scripts/seed-runner/` (12 wrapper .bat del seed Windows), `scripts/experiments/` (script one-off di traduzione/debug + liste md temporanee). Corretti i percorsi interni (`root` da `__dirname/../..`) e i riferimenti in `.github/workflows/download-chart.yml`, README, plan.md, CHANGELOG.
- Traduzioni del tutorial accentrate in `tutorial/`: `docs/TUTORIAL-RU.md` → `tutorial/TUTORIAL.ru.md` accanto a `TUTORIAL.md`, `TUTORIAL.it.md`, `TUTORIAL.zh.md`; aggiornati i link in README, MANUALE e tabelle file.
- Verifiche: `python3 scripts/docs/download_chart.py` esegue con exit 0 (fallback tag git); build script puntano ai percorsi corretti; suite conformita' invariata.

## Sicurezza: validazione del SystemRoot in `commandExists()`

Il finding #1 di SECURITY-REVIEW.md era stato chiuso risolvendo `where.exe`
percorso assoluto, ma il valore veniva preso da `%SystemRoot%` senza verifica:
un aggressore che controlla l'ambiente poteva reindirizzare l'esecuzione verso
un `where.exe` controllato dal repository (path relativo o annidato). Ora la
risoluzione passa da `getWindowsSystemDir()`: %SystemRoot% e' accettato solo se,
dopo normalizzazione, corrisponde esattamente a `<drive>:\windows` (case-insensitive);
qualsiasi altro valore — UNC, percorso relativo, traversal, sottocartelle come
`C:\Program Files\Windows`, valori non-stringa, vuoto/non impostato — viene
rifiutato con fallback fisso su `C:\WINDOWS\System32`. Nota di trasparenza: Node
non espone GetSystemDirectoryW, quindi la validazione dell'shape e' il segnale di
fiducia disponibile piu' forte; le installazioni Windows custom fuori schema sono
rigettate di proposito (commandExists e' solo un probe di feature). Testato con
harness locale su 17 casi (accettazione/rifiuto/fallback, nessun throw).

## Hardening CI: azioni pinnate a SHA completi

Tutte le GitHub Actions nei 4 workflow (`ci.yml`, `download-chart.yml`,
`pages.yml`, `static.yml`) sono ora referenziate con commit SHA a 40
caratteri invece che per tag, come richiesto dal scanner di sicurezza
("action not pinned to a full length commit SHA"). Il tag aggiornato resta
come commento per la manutenzione. SHA risolti via API GitHub al momento del
commit: checkout@3d3c42e (v7), setup-node@949feb2 (v7), configure-pages@45bfe01
(v6), upload-pages-artifact@fc324d3 (v5), deploy-pages@368f825 (v5). Questo
rende immutabile il codice delle azioni usate in CI (anti tag-flipping /
supply-chain attack); per gli aggiornamenti futuri ricreare i pin da un tag
nuovo (o usare Dependabot `package-ecosystem: "github-actions"`).

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
