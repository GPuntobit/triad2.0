# Triad and S0 bootstrap status

## Audit runtime: output JS troncato su pipe — 2026-11-08

Checkpoint: branch `checkpoint/runtime-audit-2026-11-08`, base main
`d76821f` (dopo l'integrazione di #77). Core 40/40, probe 39/39,
desktop e sicurezza erano verdi; sito e differenziale fallivano in modo
intermittente perché `process.exit()` terminava il riferimento JS prima
dello svuotamento di stdout su pipe (riprodotto con lettore lento).

`seed/dev/triad_core.cjs` ora restituisce il codice di uscita al CLI,
che imposta process.exitCode e lascia svuotare gli stream. `exit(n)`
interrompe la valutazione con un segnale interno intercettato al confine
del programma. Lo stesso vale per errori e caricamento Node --require.
Riferimenti: SPEC-CORE §§5,7 (stdout deterministico), §§8–10 (exit e CLI).
Nessun dump o generatore macchina modificato.

Aggiunti 5 test Node (prima: 4 FAIL/1 PASS; dopo: 5 PASS): output lungo,
exit esplicito, errore runtime, entry point preloaded e codici/diagnostiche
CLI. Nuovo caso Core output_pipe con golden deterministico: 41/41.
Test Node collegati alla CI; corretto npm test della CLI che invocava
un comando rimosso. Il file tools/webcmd-graphify/tests.js è un comando
plugin e non una suite di test: la peer dependency non installata non
è stata classificata come bug del runtime.

Validazione: Core 41/41, probe 39/39, verify.sh, CLI installata, limiti
seed (7 casi), desktop, 27 self-test guardie, guardie corpus (0 errori),
differenziale (6 file, 0 differenze), sito (13 file identici), sicurezza,
test audit AI e test Node PASS. Restano i limiti già dichiarati dai bad_*;
questo audit non dimostra conformità a tutte le funzionalità Triad-Full.


## Checkpoint e suite complete senza esclusioni — 2026-11-08

Checkpoint remoto del codice iniziale non funzionante: branch
`checkpoint/core-probes-failing-2026-11-08`, commit
`6c38d383a13c85ce90f4107f1f5d70f601f3cf84` (hash CI obsoleti,
quattro probe negativi obsoleti e D23 non risolta). I fix precedenti
sono ora integrati in main `488f05e`: Core 40/40 e probe 39/39 passano.

Rimossa l'ultima esclusione `liste`: conformance/gate.sh delega
direttamente all'oracle e propaga il suo exit code. Aggiornati
verify.sh, nome dello step CI, AGENTS.md e documentazione del runner
e del seed. Nessun golden, dump o generatore modificato: i probe
negativi restano test dei limiti attesi, non feature dichiarate implementate.
Riferimento normativo: SPEC-CORE.md §11 (tutti i casi Core obbligatori).

Verifiche PASS: Core 40/40, probe 39/39, verify.sh, CLI installata
triad-cli test all, suite security, git diff --check. Controllo negativo:
un errore temporaneo nel golden di liste fa fallire gate, verify.sh e
triad-cli test all; il golden è poi ripristinato byte per byte.
Il difetto dei precedenti gate che tolleravano una regressione di liste
è chiuso. Restano i limiti del runtime registrati nei probe bad_*:
la richiesta corrente copre le suite complete, non la loro implementazione.


## D23 risolta: ternario con simbolo reinserito nel gate — 2026-11-08

`seed/dev/core.js`, scanner `pt_colon`: un `:` seguito dall'inizio di un
identificatore (`A-Z`, `a-z`, `_`) appartiene a un simbolo e non decrementa
la profondità dei ternari. Restano accettati i separatori compatti già
verificati dai probe (`:7`). Riferimenti: SPEC.md §1, SPEC-CORE.md §§2,4–6.

Rimossa l'esclusione `ternario_simbolo` da conformance/gate.sh e D23 dal
contratto; il self-test verifica che G-D23 sia disattivata. Esteso il caso
con entrambi i rami, maiuscole/underscore, annidamento e short circuit: le
tre righe originali del golden restano invariate, le nuove derivano dal JS.
Rigenerati i due dump e le decodifiche ELF/PE (incluso seed_decoded.exe);
aggiornati hash CI e README. Cambio semantico deliberato, con diff dei
dump tracciato, secondo ADR 0001; nessuna esecuzione del PE (ADR 0002).

Verifiche PASS: conformance **40/40**, probe **39/39**, verify.sh, 27
self-test guardie, guardie sul corpus (0 errori; 11 avvisi fuori contratto),
differenziale (6 file, 0 differenze), limiti/errori seed (7 casi), rebuild
PE/ELF + cmp, suite security. Il vecchio skip `liste` resta conservativo,
ma il suo caso passa sul dump attuale; gli altri limiti non sono certificati
come risolti da questa modifica. Le note D23 precedenti sono storiche.


## Correzione gate probe dopo `ff222c2` — 2026-11-08

I quattro probe `bad_chiamata_nested_int`, `bad_chiamata_ultima_espressione`,
`bad_if_valore_funzione`, `bad_lista_indice` verificavano il rifiuto di programmi
validi (SPEC-CORE §§4–7). Sui dump attuali coincidono con il riferimento JS:
stdout rispettivamente `11\n`, `4\n`, `55\n5\n`, `1\n3\n`, exit 0.
Rinominati `ok_*`, con nuovi sidecar derivati dal riferimento: il runner
verifica stdout byte-esatto ed exit code senza eccezioni nuove. Nessun
golden preesistente, dump o generatore modificato. Aggiornata la matrice
in tests/probes/README.md. Il fallimento dei quattro probe registrato nella
nota hash precedente è risolto; D23 resta un gap noto. Le guardie conservative
del corpus certificato restano in attesa di una verifica più ampia.
Verifica: `verify.sh` e CLI installata `triad-cli test all` PASS (exit 0);
`probes: 39 probe, OK`, gate Core PASS con il solo fallimento noto D23.


## Correzione CI hash seed — 2026-11-08

Il commit `ff222c2` ha aggiornato i dump PE/ELF senza aggiornare gli hash in CI.
Il controllo ora usa SHA-256 dei dump committati (ELF `23a84dd3…`, PE `57f631e4…`)
e `sha256sum --check`, che identifica il file in caso di mismatch. Nessun dump,
generatore o golden modificato; nessuna modifica normativa a SPEC.md/SPEC-CORE.md.

Verifiche: hash PE/ELF PASS; rebuild dei due dump + `cmp` PASS;
`check_seed.sh` PASS (7 casi); gate Core PASS (39/40, D23 ancora escluso).
`verify.sh` FAIL: quattro probe negativi accettati dal seed corrente
(`bad_chiamata_nested_int`, `bad_chiamata_ultima_espressione`,
`bad_if_valore_funzione`, `bad_lista_indice`). Restano da riallineare al contratto
nel lavoro sul seed; nessun golden riscritto. L'anti-drift dei dump attuali passa:
le note storiche sul suo fallimento si riferiscono ai dump precedenti a `ff222c2`.


## Ternario con simbolo: nuova divergenza `D23` del seed — 2026-11-08 (ter)

Il seed implementa il ternario con uno scanner byte-per-byte che cerca il separatore `:`
contando solo parentesi tonde, quadre e graffe. Quando il ramo *then* è un **simbolo**
(`:nome`), il `:` del simbolo è a profondità zero e viene scambiato per il separatore: il
programma viene **rifiutato** (exit 1, diagnostica generica `seed: error`) quando la
condizione è falsa. Il ramo *true* funziona per caso (il seed parsa il ramo *then* dalla
posizione subito dopo `?`), quindi il difetto si manifesta solo sul ramo non scelto.

`SPEC.md` §1 stabilisce la regola dei due punti: «`c ? a : b`: a `:` **surrounded by
spaces** is the ternary separator». Il **riferimento JS** (`seed/dev/triad_core.cjs`,
autorità semantica) è conforme: byte-exatto sui 39 casi Core già congelati.

Conseguenze (tutte in questa sessione):

- **divergenza `D23 = noisy`** nel contratto del seed (`seed/dev/certified-subset.txt`) +
  riga in `seed/README.md`;
- **guardia statica `G-D23`** (`tools/selfhost-guard/rules.mjs`) con fixture e voce nel
  self-test: nei sorgenti di S1 il ternario con simbolo nel ramo *then* è vietato (il
  costrutto è *rumoroso*: exit 1). La regola si spegne da sola quando `D23` sparisce dal
  contratto;
- **caso di conformance `ternario_simbolo`** (`conformance/core/cases/ternario_simbolo/`)
  con il golden del riferimento JS: **2° gap noto** della suite Core, escluso in modo
  esplicito e rumoroso da `conformance/gate.sh` → **38/40** verdi sul seed (40/40 sul
  riferimento JS). Nessun golden è stato riscritto per mascherare il difetto;
- **`conformance/gate.sh`** corretto: la KNOWN_GAP accettava un solo nome e con due gap
  avrebbe fallito il gate (filtro `grep -v -x -F -f` su elenco + motivo per gap).

**Resta rosso** (fuori scope, noto): il **fix del codice macchina** del ternario
(`seed/dev/core.js`, routine `pt_scan`/`pt_colon`) è rinviato a una sessione separata —
toccerebbe il ciclo di rebuild dei dump (`seed.hex` + PE/ELF + hash CI), oggi bloccato dal
known issue anti-drift (vedi `TASK.md` → handoff «2026-11-07 22:40 (ter)»). Ticket:
`.scratch/seed-linux-nativo/issues/11-ternario-simbolo-seed.md` (aperto).

Gate eseguiti: `sh verify.sh` → OK (conformance 38/40 con i due gap noti `liste` e
`ternario_simbolo`, probe 39/39); `node tools/selfhost-guard/test.mjs` → OK (27 test);
`node tools/selfhost-guard/guard.mjs` → 0 errori; `node tools/selfhost-guard/differential.mjs`
→ 0 differenze.

## Contratto dei limiti del seed allineato all'arena N20 — 2026-11-08 (bis)

Il gate `sh seed/linux-x86_64/check_seed.sh` era **rotto** dalla ri-proporzionamento
dell'arena (N20): i casi 6-7 verificavano ancora il vecchio envelope pre-N20 (sorgente
≤ `0xEFFF`, rifiuto da `0xF000`), mentre il seed committato riserva **1 MiB** di sorgente
(maschera di stop a `+0x100000`) → `FAIL: 0xF000: exit 0 (atteso 1)`.

Allineati al **contratto macchina-leggibile** (`seed/dev/certified-subset.txt`:
`source.max_bytes = 1048576`):

- `seed/linux-x86_64/check_seed.sh`: `0xFFFFF` ammessa (exit 0, stdout byte-esatto),
  `0x100000` rifiutata (exit 1, stdout vuoto, diagnostica su stderr) — **7 casi verdi**;
- `.github/workflows/ci.yml`: gate hash anti-tampering riallineato ai dump committati
  (ELF `971f61d5…`, PE `9f96c413…`; prima riportava gli hash pre-N20 → passo rosso);
- `seed/windows-x86_64/seed.exe` + `seed_decoded.exe`: rigenerati dal `seed.hex` committato
  (erano la decodifica pre-N20: ADR 0001 richiede la decodifica esatta). Parità PE↔ELF
  ripristinata sull'envelope (verificata con Wine: stessi exit code e stesso stdout sui
  casi `0xFFFFF`/`0x100000`/file assente/path vuoto/nessun argomento);
- documentazione allineata: `seed/README.md`, `seed/linux-x86_64/README.md`,
  `seed/windows-x86_64/README.md`, il mirror Obsidian in-repo
  (`obsidian-triad/wiki-content/`), `docs/libro/_dati_dal_codice.md`. Il mirror gemello
  `obsidian-triad/github-wiki/` sta nel **submodulo** del wiki (repo separato): va
  aggiornato lì, out-of-band.

Gate eseguiti: `sh verify.sh` → OK (conformance 38/39 con il solo gap noto `liste`, probe
39/39); `check_seed.sh` → OK (7 casi); `tools/selfhost-guard/{guard,test,differential}.mjs` →
OK (0 differenze); `tools/site-gen/build.mjs --check` → OK.

**Resta rosso** (fuori scope, noto): il passo CI «Reproducible dump (anti-drift)» — il
generatore a HEAD (`ceaf202`, WIP N03/N04) non rigenera i dump committati: chiude col ciclo
di rebuild (vedi `TASK.md` → handoff «2026-11-07 22:40 (ter)»).

## Guardie statiche e gate differenziale sul corpus certificato — 2026-11-08

La decisione [12] della mappa M6 (`.scratch/self-hosting-m6/issues/12-guardie-statiche-sorgente-s1.md`)
fissa *come* si presidia il sottoinsieme certificato del seed:

- **contratto del seed** — `seed/dev/certified-subset.txt` (envelope, primitivi §8
  disponibili, divergenze D1–D22 con la classe `silent`/`noisy`), leggibile in
  `seed/README.md` («Contratto del seed»);
- **corpus certificato** — `seed/dev/certified-corpus.txt`: i programmi che il seed deve
  poter eseguire (front-end di S1, smoke, i quattro generatori attivi di `tools/site-gen/`);
  gli altri `.td` sono *fuori contratto* (le violazioni sono avvisi, non errori);
- **guardie statiche** — `tools/selfhost-guard/` (CLI `guard.mjs`, regole `G-D01`…`G-D22`
  + envelope `G-E01`–`G-E03`): riusano l'AST del riferimento JS, ogni regola è legata a una
  divergenza e **si spegne da sola** quando la divergenza sparisce dal contratto; self-test
  con un fixture per regola (`node tools/selfhost-guard/test.mjs`);
- **gate differenziale** — `tools/selfhost-guard/differential.mjs`: per ogni programma del
  corpus certificato, seed e riferimento JS devono dare lo **stesso stdout byte per byte** e
  lo **stesso exit code**; è il presidio delle divergenze che una regola statica non può
  decidere (dipendono dai tipi a runtime, es. `string(true)` → il seed stampa `1`).

CI (job `conformance-core`): tre passi nuovi — guardie statiche, self-test, differenziale.
Il guard e il differenziale sono strumenti di sviluppo (Node), fuori dalla catena S0→S4:
`verify.sh` resta senza Node.

Correzioni alle misure precedenti (ticket 01), misurate oggi: `println` **è** ammesso in
posizione finale (D9); il seed **risolve** i riferimenti in avanti fra funzioni (D18 rifiuta
solo la chiamata a livello di file che precede la definizione); il problema di scope dei
blocchi riguarda `if`/`while` (non `let`/`begin`) e ha due casi — il nome *nuovo* è una
divergenza vera fra i runtime, il nome *già legatto* è identico nei due runtime (decisione
normativa pending, famiglia N08); le keyword cieche del seed contano **solo dentro un corpo
di blocco** (D22).

## Release 0.8.0-beta.9 — 2026-11-07

Pubblicata la release `v0.8.0-beta.9` (tag `v0.8.0-beta.9`, commit `f30a0a2`):
https://github.com/GPuntobit/triad2.0/releases/tag/v0.8.0-beta.9 — seed Linux nativo,
toolchain senza Node, desktop launcher. `VERSION` = `0.8.0-beta.9`; note di rilascio in
`docs/releases/RELEASE_NOTES_v0.8.0-beta.9.md` (EN) e `.it.md` (IT).

Asset pubblicati (SHA-256):
- `seed.exe` — PE Windows x86-64, 25088 byte, `631f401ffe42f5f748bb92ab80c2886a7d68f9e00b09bd8dfde2de0c671fe219`
- `seed-linux-x86_64` — ELF Linux x86-64 statico, 8499 byte, `c8c82bc9c77c69e603e07ab7287065076e04c8139a57ae3ee454a472cee2a0ce`
- `triad-cli` — CLI dev standalone Linux (Node SEA), 119 MB, `337c5188ee5cfef7d50256f5b03ab510b47dedf15aac6aa14256e1bf2ebe9cb2`
- `triad-cli.exe` — CLI dev standalone Windows (Node SEA), 83 MB, `d7ab6e05a538a7f1ffd571014c91c7f5029e6b21855e9db0843e15acabb06d5e`

**Non** pubblicato `TriadDesktop.exe`: la GUI Windows punta ancora alla CLI Node pre-N18
(`status` / `test`) e il suo probing della root cerca `conformance/run.mjs`, rimosso in N17 →
ticket `.scratch/desktop-gui-windows/issues/01-gui-windows-alla-cli-posix.md`.

Validazione al tag: `sh verify.sh` → OK (gate 38/39 con il gap noto `liste` escluso in
modo esplicito, probe 39/39), `sh tests/desktop.sh` → PASS, `sh tests/security/run.sh` →
PASS (8 check), CI GitHub Actions → **verde** (5 job: conformance-core, security, site-gen,
seed-linux, linux-toolchain).

Correzioni incluse nella release (la CI era rotta dal 2026-11-06 e non avviava alcun job):
- `ci.yml` aveva uno scalare non quotato con `": "` → YAML non valido; nome dello step
  quotato + regressione `tests/security/workflows_yaml.test.py`.
- i golden dei probe e del golden S1 erano esclusi da git → versionati (23 probe su 39
  fallivano con «golden mancante» in un checkout pulito).
- il seed aveva un codegen rotto per `xs[i]` (SIGSEGV in scrittura, parse error in
  lettura): revert allo stato documentato; i gate hash PE/ELF della CI tornano coerenti.

Nota di build: il binario standalone SEA è costruito su base **Node 22.23.4** (Linux e
Windows); con Node 26 l'iniezione del blob tramite `postject@1.0.0-alpha.6` produce un
binario che va in segfault al primo avvio.

## Desktop launcher — 2026-11-07

Double-click follow-up: install.sh now registers shared-mime-info globs for
`.triad`/`.td`, refreshes the MIME database and selects triad.desktop via xdg-mime.
Previously MimeType in the desktop entry alone did not recognize these extensions.
The isolated desktop regression also checks real xdg-mime type/default queries.

`install.sh --desktop` now routes the menu and associated files through
`bin/triad-desktop`, a POSIX session that prompts for a program and keeps output
and failures visible until `:quit` or EOF. Previously a menu launch passed no file
to the seed, which printed usage and exited 2 immediately. Reinstall to refresh
existing desktop entries. `bin/triad` still delegates directly to the seed.
The full REPL required by SPEC.md §14 remains pending; this session runs files.
Regression gate: `sh tests/desktop.sh`; seed gate: `sh verify.sh`.

Validation: desktop integration PASS. On an untouched checkout of `83ca5ed`,
conformance already fails `liste` (38/39 PASS), and probes fail 24/39, mostly
missing ignored `*.expected.out` goldens. This patch restores the installer smoke
golden (`test_simple.expected.out`, literal `test\n`, with a .gitignore exception);
probes then fail 23/39. No other seed/golden behavior is changed. Those baseline
failures remain open; conformance goldens were not rewritten to hide them.

Updated after the 2026-11-05 closure of N18 (E3: Linux toolchain without Node — **main task
complete**); previous: N17 closure (E2b ELF seed + Node-free harness), 2026-11-02 closure of
problem-table rows 2–6 and backlog A03/A04.
**Main task promoted 2026-11-03:** native Linux seed without Wine (TASK.md → «Task
principale (2026-11-03)», N15–N18); it takes precedence over N03 and the mechanical
sub-tasks. Decision map (wayfinder): `.scratch/seed-linux-nativo/map.md` (closed, the way
is clear). Next decision map (wayfinder, 2026-11-05): `.scratch/self-hosting-m6/map.md` —
self-hosting M6 (native compiler + fixed point, seed retired).

## Goal

Triad as a standalone, recognized language: its own standard, conformance, `.triad` extension, editor tooling, bootstrap without host languages and self-hosting.

## What is ready

- **Standard**: `SPEC.md` (v0.2.0), `SPEC-CORE.md`, `VERSION`, `CHANGELOG.md`.
- **Conformance**: POSIX harness `conformance/run.sh` (no Node, no Julia — 2026-11-05,
  N17: replaced `conformance/run.mjs`/`run.test.mjs` in one shot, ticket 08); Triad-Core
  39/39 green **byte-exact** on the native ELF seed (`seed/linux-x86_64/seed`, no Wine).
  Triad-Full: 12 cases, today only `errore` passes (outside the gate, ticket 08 Q3).
  Golden `expected.out`/`expected.code` sidecar versioned; a missing golden fails the
  case with `golden mancante`. See `conformance/README.md`.
- **Canonical extension**: `.triad` (`.td` historical alias), VS Code/Vim grammars and Linguist entry prepared.
- **Repository layout** (2026-11-01): documentation consolidated under `docs/` (`tutorial/`, `wiki/`,
  `security/`), probe programs in `tests/probes/`, legacy Jekyll scaffold in `tools/site-jekyll/`;
  contractual paths unchanged (see CHANGELOG, "Not released — 2026-11-01").
- **Site generated by Triad** (2026-11-01): the static site of `docs/` is rebuilt from Triad
  programs in `tools/site-gen/` (`site_pages.td`, `site_pages2.td`, `site_playground.td`,
  `site_style.td`); the driver `build.mjs` runs every generator on the seed PE **and** on the JS
  reference interpreter and requires byte-identical stdout, and `lint.mjs` blocks the constructs
  the seed cannot execute. 13 generated files (12 pages + stylesheet), 214 internal links, none
  broken; CI job `site-gen` (Ubuntu + Windows). The certified subset and the measured seed limits
  are in `tests/probes/README.md`.
- **Seed S0** (Windows PE, no runtime/compiler): Triad-Core interpreter with
  support for integers, variables, functions (short form and multi-statement `function ... end`),
  recursion, Bool, operators (`% ^ ! && || +=`), `if`/`elseif`/`else`, `while`, `let`, `begin`,
  lambda, closures with capture by value, basic strings + concatenation + `string()`,
  `nothing`, symbols and construction/printing of integer lists.
- **S1 source-code front end** (2026-11-02): `selfhost/source.td` — a new
  scanner + root-scan + recursive-descent algorithm derived from the
  machine-code seed (not from the removed Julia code), covering the whole
  machine-code domain and printing the AST pre-order; byte-identical stdout on
  the seed PE and the JS reference (`node tests/probes/run_probes.mjs
  selfhost/source.td` → `[same]`), golden in `selfhost/source.expected.out`.
  Newly measured seed limits are certified in `tests/probes/` (list-literal
  heap 528 B/evaluation, dynamic scoping, max 4 parameters, multi-line list
  literals) and documented in `tests/probes/README.md`.
- **Book** `docs/libro/`: *Il libro di Triad* in three texts — **Fondamenta** (`docs/FONDAMENTA.it.md`,
  programming from zero for readers who have never programmed), Manuale, Tutorial — built from the
  Italian sources by `scripts/docs/build-libro.mjs` / `build-epub.cjs`; PDF generated by
  `scripts/docs/build-pdf.mjs` (Chrome/Edge headless printing: the calibre PDF writer corrupts
  composite glyphs, turning accented characters into tofu). EPUB/MOBI/DOCX regenerated alongside.
  Every concluded chapter ends with an **Esercizi** section of at least 10 exercises (the
  pre-existing exercise chapters were topped up to the same minimum; the guided-exercise chapters
  gained a supplementary list).
  Print geometry is KDP-compliant and uniform on every page: 19.05mm (0.75") margins on all
  four sides, identical layout on recto and verso (text block and page numbers in the same
  position everywhere), full-bleed cover centered on the page, 424 pages; `build-pdf.mjs`
  checks the PDF against the KDP margin table at build time and fails (exit 3) if the
  gutter/outer margins are insufficient.
- **Launcher/CLI**: the default runtime for `.triad` is the machine-code seed (`bin/triad`, `bin/triad.cmd`, `cli/lib/utils.mjs`); the Julia implementation (`triad.jl`, `syntax.jl`, `test/`, `bin/build_standalone.jl`) has been removed.
- **CI**: `.github/workflows/ci.yml` — **solo runner Linux nativi** (decisione 04, ticket
  `.scratch/seed-linux-nativo/issues/04-parita-suite-ci.md`): gambe Windows rimosse il
  2026-11-05 (job `seed-windows` eliminato, matrice `site-gen` ridotta a Ubuntu; il commit
  `fc320f4` lo dichiarava nel messaggio ma non lo implementava nel diff). Job:
  `conformance-core` (Ubuntu, `--skip liste`), `site-gen` (Ubuntu), `seed-linux` (ELF E1 +
  `check_e1.sh` + hash PE **ed** ELF + anti-drift dump of **both** artifacts:
  `gen_seed.js`/`gen_seed_linux.js` + `cmp`), `linux-toolchain`, `security`. Lato PE: gate
  hash di `seed.hex` + golden congelati (ADR 0002: il PE non viene mai rieseguito dal gate).

## What is missing

| area | status |
|---|---|
| `stringhe` (`string()`) | implemented (Int/String); Bool/Symbol/Nothing not implemented |
| `liste` | Core case passes with the runner; on the seed PE: construction/printing and `push!` of integer lists, standard indexing, `length` and iteration not supported |
| `valori` (lists/symbols/strings together) | partial; integer lists only, no operations or mixed values |
| `controllo` (`elseif`) | implemented |
| `continue` | Core per `SPEC-CORE.md`, ma **assente dal seed PE**: il programma termina con codice 1 alla prima `continue` (misurato, 2026-11-01); l'interprete JS la esegue. Il libro usa la forma equivalente con `break` + condizione capovolta, verificata identica sui due runtime |
| `-=`, `*=` | Core per `SPEC-CORE.md`, ma **assenti dal seed PE** (codice 1); funzionano sull'interprete JS. Solo `+=` è supportato dal seed |
| `while`-espressione (`x = while … end`) | Core per `SPEC-CORE.md` §4, ma il seed PE la rifiuta (codice 1); l'interprete JS la esegue |
| condizione `while` non-`Bool` | `SPEC.md` prevede `Err(:type)`; il seed PE salta silenziosamente il corpo (exit 0), l'interprete JS segnala `error: while cond` — comportamenti divergenti entrambi da verificare |
| scope del corpo `while` | `SPEC.md` §5 prevede un ambiente per `while`; il seed PE lascia uscire le variabili assegnate nel corpo, l'interprete JS le confina (errore di variabile indefinita) — il caso `while_annidati` usa solo assegnamenti su nomi preesistenti per restare neutro |
| S1 (Triad in Triad-Core) | in progress in `selfhost/` (smoke test in CI, not yet conformance) |
| Triad-Full | 11/12 cases not implemented (only `errore` passes) |
| CLI seed | file execution only; REPL and SPEC section 14 options to do |
| S2-S3 (native compiler, self-hosting) | not started |
| S4 / M7 (parity, Linux ELF) | **✅ MAIN TASK (2026-11-03) COMPLETE (2026-11-05)**: E1 file runner (N15); E2a `os_*` codegen core, PE byte-identical (N16); E2b ELF **E2** 8499 byte = full Triad-Core interpreter, **byte-exact parity** on conformance 39/39 + probes 39/39 + S1 golden, native Linux **without Wine** + Node-free harness (N17); E3 toolchain without Node (N18): `./install.sh` (pure-`printf` seed decode, absolute-path wrappers, byte-exact smoke test that fails the install on mismatch) → `bin/triad` exec-always-seed (stub/`--jsref`/JS/triad-native logic removed) + POSIX `bin/triad-cli` (`run`/`test`/`status`, no Node), `cli/triad-cli.mjs` thinned to dev commands (`seed`/`ai`/`ext`), CI `seed-linux` native + `linux-toolchain` without Node, tutorials (it/en/ja/zh/ru) updated to the post-decision-04 CI. Windows keeps the PE unchanged. |

## Main task (2026-11-03): native Linux seed — no Wine — ✅ COMPLETE (2026-11-05)

Per the maintainer's decision, Triad must not become a Windows-only emulator: Windows users
keep the PE, Linux users must install **nothing beyond the GitHub repo**. The Linux port was
therefore the main task (TASK.md N15–N18: E1 file runner → E2a platform-independent `os_*`
codegen core → E2b ELF emitter with PE parity → E3 native toolchain/CI), preceding N03.
All four slices are closed (2026-11-05): the native ELF seed interprets Triad-Core with
byte-exact PE parity and the whole user path (`./install.sh` → `triad program.td`) is
Node-free. Next in line: N03 (`xs[i]` 1-based and the `liste` gap) in a single PE/ELF rebuild
+ CI hash cycle. Normative frame unchanged: `SPEC-CORE.md` is the reference, the ELF behaves
identically to the PE (known limits included), `BOOTSTRAP.md` §4/§5/§6/§9 (M7 parity + Linux port).

## Verification commands

```sh
sh verify.sh                       # gate unico: conformance/run.sh + tests/probes/run_probes.sh
sh conformance/run.sh              # Core, 39 casi, byte-exatti sull'ELF nativo
sh tests/probes/run_probes.sh      # 39 probe (ok_*/test_* + bad_* + selfhost golden)
sh seed/linux-x86_64/check_seed.sh # errori/limiti del seed (7 casi)
node tools/selfhost-guard/guard.mjs        # guardie statiche sul corpus certificato
node tools/selfhost-guard/test.mjs         # self-test delle guardie (un fixture per regola)
node tools/selfhost-guard/differential.mjs  # gate differenziale seed <-> riferimento JS
```

Triad-Full (`conformance/cases`) resta fuori dal gate (ticket 08 Q3); da eseguire con la
dev CLI dove serve. Windows, seed (PE invariato, non rieseguito dal gate — ADR 0002):

```powershell
certutil -decodehex -f seed/windows-x86_64/seed.hex seed/windows-x86_64/seed.exe
.\seed\windows-x86_64\seed.exe conformance\core\cases\closure\program.td
```

## External recognition (requires the maintainer)

- `LICENSE` added (MIT, 2026-10-22);
- PR to GitHub Linguist with `editors/linguist/languages.yml`;
- publishing the VS Code / Open VSX and Vim extensions;
- possible registration of the language/standard.

## Final verification (round 31; previous baseline)

- Seed S0 Windows: PE 25088 bytes, hash `445CB428EFF44B39C2103DF776E6D9A1D1B5BDD8904C2C93D661950321C4ED60`, reproducible dump.
- Stage0: **Triad-Core 31/31**, **Triad-Full 12/12**.
- Seed Windows: new `funzioni_io` regression verified with byte-exact stdout; 27/28 cases listed in the CI job pass locally. `if_else` ends with exit `1` (even with the previous PE); hosted CI verification is still needed.
- CI: seed hash updated; Ubuntu/Windows matrix for conformance and Windows job for the seed.

### Core cases not yet covered by the seed

- `liste`: the seed covers construction, printing and `push!` of integer lists; standard
  indexing, `length`, iteration and mixed values remain to be implemented.
- `valori`: partial support; mixed values and full string handling are missing.

### Distance from the goal

The goal **is not complete**:
- S0 is a machine-code interpreter, but **S1 (Triad in Triad-Core) has not started**, so there is no self-hosting yet;
- S2-S3 (native compiler in Triad, fixed point) not started;
- S4/M7 (conformance parity, Linux ELF port) **done 2026-11-05** (TASK.md N15–N18): E1 file runner, E2a `os_*` codegen core (PE byte-identical), E2b ELF E2 = full Triad-Core interpreter with byte-exact PE parity (conformance 39/39 + probes 39/39 + S1 golden), E3 toolchain without Node (`install.sh` → `bin/triad`/`bin/triad-cli`, byte-exact smoke test, CI native + `linux-toolchain` without Node);
- external recognition: MIT LICENSE chosen; Linguist PR and extension publishing require the maintainer.

## Seed Windows verification (round 32)

- Fixed the crash caused by overlap of PE import names with machine code:
  the generator placed the names at RVA `0x2cde`, inside code that had grown beyond
  that offset. Now the names start at RVA `0x5000`.
- Added `liste_base`: construction and printing of `[1, 2, 3]`; the seed exits with code `0`.
  Indexing, `push!`, `length`, iteration and lists with non-integer elements remain unsupported.
- The local Windows seed job passes 28/29 cases including the new regression; `if_else` remains
  the only known failure (exit `1`). The Julia suite of the new conformance passes.
- PE regenerated: 25,088 bytes; SHA-256 of the dump: `1B88C89A9D3EACD0D05594BC2CECFAA3A4B56A0B76553F904CB96339F4B3CE65`.

## `get` probe seed Windows (round 33)

- The generator already contained the body of `get`, but the call dispatcher did not
  recognize the name; moreover the body read arguments from the stack in the wrong order.
- Added dispatch and fixed 0-based access with checks on list type, index type
  and bounds. `test_get.td` now prints `20` and exits with code `0`; the probe is verified
  also in the Windows CI job.
- `get(xs, i)` is an extra helper of the seed and not a primitive defined by Triad-Core.
  Standard indexing `xs[i]` remains 1-based and is not yet implemented by the seed.
- Reproducible HEX dump: SHA-256 `EF8EB3D7DB47B55E2C455B8D79A45351EC80F1BBA01CA8918951FF1F15D7A802`.

## `push!` probe seed Windows (round 34)

- Connected the `push!` builtin to the dispatcher, added the `!` suffix to identifier parsing
  and fixed append: the mutated list is returned, with a seed limit of
  64 elements.
- `test_push.td` and the new Core case `liste_push` print `[10, 20]`; both exit with
  code `0`. `liste_push` is included in the Windows CI.
- The seed implementation remains limited to integer lists; Core indexing, `length`,
  iteration and printing of mixed values are not implemented.
- The local Windows seed matrix passes 29/30 cases; `if_else` is the only case still failing
  (exit `1`). All 33 Core cases pass on the seed.
- PE: 25,088 bytes; SHA-256 of the dump: `76FC146BA7E070522A5445B5CC0810997E035CBC3135911F62B9C6E6B3CB255F`.

## Seed Windows: Triad-Core conditionals (A02)

- Fixed dispatch of `if`/`elseif`/`else`: `elseif` conditions are evaluated
  in order, nested branches are delimited correctly and only the first
  selected branch is executed.
- Added Core cases `if_elseif`, `if_nested` and `if_no_else`; the seed passes these and
  `if_else` with byte-exact output and exit `0`. The Core conformance Julia passes all
  cases.
- PE regenerated: 25,088 bytes, code 8315 bytes; SHA-256 of `seed.hex`:
  `9987105DCD56F42A1AD73451821A281E6F24374ED6CE83993BB8CA56F5EC4822`.

## Seed Windows: fix `string()` Int conversion (A03)

- Fixed bug in `pbs_int` (Int to string conversion): r10 was used in the loop
  to write digits BEFORE being initialized, causing an access violation (0xC0000005).
- Moved initialization of r10 (`lea r10, [rbp-8]`) BEFORE the loop to ensure
  it always points to the valid stack buffer.
- Tested: `string(42)`, `string(0)`, `string(-5)`, `string("ciao")` work correctly.
- Conformance `stringhe` passes with correct output: `ciao Triad\n5\n42`.
- Bool/Symbol/Nothing remain unimplemented (they crashed before too; now they return fail).

## Closure of open problems rows 2–6 + A03/A04 (2026-11-02)

Verified locally on **both** runtimes: the PE seed executed under wine and the JS
reference interpreter (`seed/dev/triad_core.cjs`).

- **`get(xs, i)` normative** (row 2): added to `SPEC-CORE.md` §8 as a bootstrap
  primitive with **0-based** index, explicitly distinct from `xs[i]` (§7, 1-based);
  Core conformance cases stay on §2–§7 (§11).
- **Multi-line list literals** (row 3): the JS lexer now treats newlines as trivia
  inside `[ ... ]`; `tests/probes/bad_lista_multiriga.td` flipped to
  `ok_lista_multiriga.td`. Trailing comma remains an error on both runtimes.
- **Attached ternary colon `? 5 :7`** (row 4): both `selfhost/source.td` (root_pos
  `td > 0` branch + `parse_expr` colon check) and the JS parser (`parseTernary`
  SYM → `COLON` + rest) now reinterpret the SYM token like the scannerless machine
  code. New probe `ok_ternario_colon_attacco.td` (7/8 identical on PE and JS) and
  new test-source chunk c8 in `source.td` (nested ternary with two attached colons);
  golden `selfhost/source.expected.out` regenerated and verified on both runtimes.
- **Operator symbols `:+`** (row 5): the `selfhost/source.td` scanner accepts an
  operator-character run after `:` (`is_opc`) — superset of the machine-code domain.
  `bad_simbolo_operatore.td` documents that the seed still rejects `:+`.
- **CI wiring** (row 6) + **A04**: `seed-windows` now runs `conformance/run.mjs`
  (directory discovery + byte-exact goldens + exit codes; the hardcoded list of 35
  cases is gone, `gcd` and `valori` are covered), `tests/probes/run_probes.mjs
  --strict` (ok_*/test_* must match seed vs JS and their optional golden) and
  `run_probes.mjs selfhost/source.td` (S1 front-end golden). New `security` job runs
  `tests/security/run.sh`; `conformance-core` checks that every `selfhost/*.td`
  executes on the reference interpreter.
- **A03**: `selfhost/ast.td` no longer uses `type AST = Int` (outside the grammar);
  `selfhost/program.td` rewritten on the flat integer-token model (the nested model
  was inconsistent) and now prints `42\n7\n` on both runtimes; `get` legitimized as
  a §8 bootstrap primitive.
- **`SPEC-CORE.md` §2 strings**: raw newlines inside string literals are explicitly
  **allowed** (both runtimes accept them; the S1 scanner already did).

New measured divergences logged as table rows 14–15 and probes:
`bad_identificatore_maiuscolo.td` (seed start class `[a-z_]` rejects `Ab = 0`) and
`bad_separatore_newline.td` (the scannerless seed continues the expression across a
newline after an operator; the statement-separator semantics need a normative
decision first).

Sub-tasks derived from these notes are collected in `TASK.md` → «Sotto-task dalle
note di sessione (2026-11-02)» (N01–N10), with the mapping to the problem-table
rows and the suggested order (N09 wine harness → N01+N03+N04+N05 in a single PE
rebuild → N10 human action → N02/N08 after the normative decisions → N06+N07).

**N09 closed (2026-11-02):** `scripts/seed-runner/seed-wine.sh` runs the PE seed
on Linux via wine with a hash-invalidated cache of the decoded PE
(`~/.cache/triad2.0/seed-wine`); one command (`seed-wine.sh --check`) repeats the
Core conformance, the strict probes and the S1 front-end golden on the native PE.
Verified from a clean cache: conformance OK, 17 strict probes with 0 differences,
golden confirmed; cache hit/invalidation verified. Documented in `seed/README.md`
and `tests/probes/README.md`; CI unchanged.

**N01 closed (2026-11-02):** uppercase-initial identifiers and symbols now work
on the PE seed. The defect was not in `parse_ident` (already case-folding) but in
two case-sensitive first-byte tests: `stmt_assign` (statement dispatch) and
`sym_scan` (dead `A-Z` branch shadowed by `jb('sym_digit')`). Both now fold case
like `parse_ident`. Probe flipped to `ok_identificatore_maiuscolo.td` (covers
`Ab` and `:Ab`); keywords stay lowercase-only (`IF` is an identifier).
New PE 25,088 bytes, SHA-256 of `seed.hex`:
`4235A70790BAA6784DC3D944616705B37E76ED2263CE73210BCC20E53639B8F7` (CI hash updated).

**Bug discovered and fixed by the same rebuild:** `gen_seed.js` no longer
reproduced the committed `seed.hex` (1,705-byte drift): the CodeQL commit `649709a`
(2026-10-31) fixed `testRcx` → `testRcx()` in `pf_call` (the closure cap check
was corrupted) but the artifacts were never regenerated — the committed PE
contained the bug. Reproducibility restored; all ±3-byte shifts traced to the
3-byte `test rcx,rcx` insertion.

Gate (`scripts/seed-runner/seed-wine.sh --check`) after the rebuild: conformance
Core OK, 18 strict probes with 0 differences, S1 golden confirmed.

Verification run (2026-11-02, Linux + wine):

- `node conformance/run.mjs` (JS): OK; `TRIAD_SEED=wine-seed node conformance/run.mjs` (PE): OK (37/38, `liste` skipped as known S0.2 gap);
- `node tests/probes/run_probes.mjs --strict`: 17 probes, 0 differences; full run: 37 probes, differences only in the 18 documented `bad_*` (0 violations);
- `node tests/probes/run_probes.mjs selfhost/source.td`: seed == JS == golden;
- every `selfhost/*.td` exits 0 on the JS interpreter; `tools/site-gen` lint + `build.mjs --check` OK;
- `sh tests/security/run.sh`: ALL SECURITY VERIFICATIONS PASSED; `node --test conformance/run.test.mjs`: 2/2.

**N17 closed (2026-11-05):** E2b delivered — the native ELF seed is now a **complete
Triad-Core interpreter** (8,499 bytes, `seed/linux-x86_64/seed`, static ELF64 without
libc) running the same machine-code domain as the PE. Single generator entry
`seed/dev/gen_seed.js <windows|linux|all>` with shared `core` + `backend_pe`/`backend_elf`
(tickets 02 Q8 / 03 Q6: `os_*` via Linux syscalls `openat`/`read`/`write`/`exit`/`mmap`
-adjacent arena, no libc); dumps reproducible (`gen_seed.js` + `cmp`), PE hash
`4235A707…B8F7` unchanged. **Parity byte-exact**: `conformance/core` 39/39 (the historical
`liste` skip is *registered*, not skipped: seed exits 1 with empty stdout, identical on PE
and ELF), probes 39/39 with frozen `<file>.expected.out`/`.expected.code` sidecars, S1
golden `selfhost/source.expected.out`. Node-free harness replaced the Node runners **in one
shot** (ticket 08 Q4): `conformance/run.sh`, `tests/probes/run_probes.sh`, `verify.sh`,
`seed/linux-x86_64/check_seed.sh` (7 cases); `gen_seed_linux.js` absorbed into
`gen_seed.js`, `check_e1.sh` renamed `check_seed.sh`, spurious `windows` file removed.
CI re-pointed (decision 04): `seed-windows` gone, `site-gen` matrix Ubuntu-only, PE hash
gate moved into `seed-linux`, anti-drift `gen_seed.js && cmp` for both dumps; the gates
lost with the Windows legs (probes `ok_*`/`test_*`, `selfhost/source.td` golden, `get`
probe, `selfhost/main.td` smoke) are wired back on the native ELF. Verification
(2026-11-05, Linux native): `sh verify.sh` OK (conformance 39 casi OK + probes 39 OK),
`check_seed.sh` OK. Remaining for the main task: **N18** (E3 toolchain without Node +
tutorial update to the post-decision-04 CI).

**N18 closed (2026-11-05):** E3 delivered — the Linux toolchain is **Node-free end to end**
and the 2026-11-03 main task is complete. `bin/triad` now execs the seed unconditionally
(the 4 KB stub threshold, `--jsref`, the JS branch and the `bin/triad-native` branch are
removed); `bin/triad-cli` is a pure POSIX CLI delegating `run`/`test`/`status` to the seed
and the sh harnesses; `cli/triad-cli.mjs` keeps only the dev commands (`seed generate`,
`ai verify`, `ext check|package`), with `run.mjs`/`test.mjs`/`build.mjs` and the
`seedIsStub`/`runSeed` fallback logic deleted. `install.sh` (ticket 07) decodes `seed.hex`
with a single pure-`printf` octal decoder (no xxd/python3/od), verifies the decode against
the committed binary (anti-drift `cmp` + warning), installs `triad`/`triad-cli` as
absolute-path wrappers (no symlinks, `--no-symlink` removed) and performs a **byte-exact
smoke test** (`test_simple.td` vs `test_simple.expected.out`) that **fails the install**
(exit non-zero, verified also with a tampered golden); outside Linux x86-64 the install is
partial (launchers + PATH) with an explicit warning, exit 0. CI: `linux-toolchain` runs
without `setup-node` (launcher + install + negative smoke + `triad-cli test all`);
`seed-linux` stays pinned to `ubuntu-24.04` (deviation from the acceptance wording
`ubuntu-latest`, noted in ticket 09). Docs updated: `README.md` (deduplicated, new
Startup/Testing/Requirements/Termux), `cli/README.md` (two-level toolchain), `AGENTS.md`
rule 3 (`sh verify.sh`), `PROJECT_PROMPT.md`, `seed/README.md`, `seed/linux-x86_64/README.md`,
`BOOTSTRAP.md` §5/§10 and the tutorials (it/en/ja/zh/ru) rewritten to the post-decision-04
CI (no more `seed-windows`/`$cases`/`conformance/run.mjs` references). Verification
(2026-11-05): `sh verify.sh` OK (conformance 39 + probes 39), `check_seed.sh` OK (7 casi),
`install.sh` + smoke + negative smoke OK, `node cli/triad-cli.mjs ai verify` 5/5,
`tools/site-gen` lint + `--check` OK, `tests/security/run.sh` ALL PASSED. Known consequence:
`bin/triad-cli.cmd` (Windows) unchanged but `run`/`test`/`status` left the Node CLI (ticket
09). Next: **N03** (`xs[i]` 1-based + gap `liste`) in a single PE/ELF rebuild + CI hash cycle.
