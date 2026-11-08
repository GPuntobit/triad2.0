# Plan to complete Triad 2.0 - Updated status

## Cleanup del codice inutilizzato — 2026-11-08

Rimossi due script non richiamati (test_small.mjs, run_all.cjs con path
personali), tre assegnazioni/allocazioni inutili di S1 e la guardia D23
inattiva con il suo helper esclusivo. Nessun golden o artefatto macchina
modificato. Prototipi selfhost mantenuti: documentati e validati dalla CI.
Istruzioni duplicate irraggiungibili in core.js segnalate separatamente:
il loro taglio cambierebbe il layout binario (ADR 0001).

Audit ed evidenze: docs/unused-code-audit.md. Verifiche PASS: Core 42/42,
probe 39/39, logica 25/25 sui due runtime, verify.sh, guardie (27 test),
differenziale, sicurezza e desktop. Non dichiarata un'analisi esaustiva
statica di ogni percorso possibile o di comandi usati fuori dal repository.


## Desktop: profilo automatico dal codice

Default auto per ogni file, con riconoscimento lessicale di fact/rule/solve/struct,
ignorando stringhe (anche quote escaped), simboli, campi, nomi e commenti
lineari/blocco annidati. Il detector è POSIX sh + od, senza Node nel runtime.
:logic e :core restano override persistenti; :auto ripristina la scelta
per file. Nessuna riesecuzione automatica dopo un errore. CLI triad FILE
resta Core; cambiato il solo comportamento default della sessione desktop.

Test: 10 casi detector e integrazione desktop su file associati, selezione
automatica, override, ripristino auto, errori e percorsi con spazi PASS.
Limite: la classificazione lessicale non implementa il parser Full; gli
usi ambigui delle keyword come nomi di funzione richiedono override Core.


## Desktop: selezione esplicita del profilo logico S1

La sessione desktop passava sempre i file a triad FILE (Core), quindi un
programma fact/rule/solve falliva con seed: error anche se S1 era installato.
Aggiunti :logic / :core persistenti e avvio --logic FILE / --core FILE.
Il banner e il risultato mostrano il profilo; un errore in Core suggerisce
la selezione logica. Nessun rilevamento euristico o retry del programma.
Il REPL Full rimane fuori scope.

Test desktop reali PASS: esempio parent/grandparent -> [:dave], percorsi
con spazi, switch Core/logic, ripresa dopo file assente, avvio diretto e
EOF. verify.sh PASS: Core 42/42, probe 39/39, logica 25/25.


## Estensioni S1: trace, struct, funzioni booleane e sorgenti paginati

Sopra il commit 36e07f4, il profilo --logic ora supporta solve trace con
record di eventi e accesso result/trace/port/goal/depth, comprensioni
filtrate, struct con campi opzionalmente tipizzati, costruttori e pattern,
funzioni booleane brevi o a blocco con un solo goal/return. Il trasporto
paginato estende il limite di sorgente da 4094 a 65535 byte.

Test: 25 casi logici sui due runtime e 4 test launcher, incluso input
oltre 10 KB. Nessun dump o golden precedente modificato; i test trace
verificano ordine call/exit/redo/fail e filtro delle porte.

Lavoro residuo esplicito: evaluator Full generale per corpi funzione
con statement arbitrari, dispatch e ritorni non Booleani; stringhe con
escape/Unicode, payload diagnostici completi, opzioni query come
espressioni. I limiti finiti di heap/vettori S0 restano. Non dichiarata
conformità completa a SPEC.md. Dettagli: selfhost/logic/README.md.


## Motore logico S1 eseguibile — 2026-11-08

Checkpoint: `checkpoint/before-logic-engine-2026-11-08` a `34ab261`.
Nuovo profilo `triad --logic FILE` (oppure `-` per stdin), scritto in
Triad-Core in selfhost/logic/engine.td + init.td. Lo shell trasporta solo
byte con od/printf: nessun interprete Node/Julia nel percorso runtime.
Riferimenti: BOOTSTRAP.md S1 e SPEC.md §6. L'esempio parent/grandparent
stampa `[:dave]` sul seed nativo.

Implementati: facts/rules, unificazione iterativa con occurs-check,
variabili fresche e anonime, choice stack e trail, ricorsione dei
predicati senza ricorsione del solver, congiunzione/disgiunzione/negazione,
liste e code, solve come valore, projection e comprensioni, cattura
valori e $(expr), is/arithmetic, predicati come Bool, limit/depth/steps.
Errori supportati restituiti come valori Err con kind.

Corretto un prerequisito reale del seed: dopo xs[i] = valore il cursore
veniva ripristinato all'inizio dello statement, causando un loop infinito.
Ora avanza; nuovo caso Core list_store, golden invariati altrove. Rebuild
deliberato PE/ELF e decodifiche (ADR 0001), con hash CI aggiornati.
Nessuna esecuzione PE; test sul seed ELF nativo (ADR 0002).

Validazione: suite logica 21/21 su seed e JS, launcher 3/3, Core 42/42,
probe 39/39 e verify.sh PASS. Suite logica inclusa in verify.sh e job CI
separato con oracle di sviluppo. Nessun fallback host nel launcher.

Limiti espliciti in selfhost/logic/README.md: profilo S1 iniziale, non Full
completo; no trace/struct/funzioni utente nei goal, input ASCII semplice,
4094 byte di sorgente, vettori di 4096 celle, arità 64, heap finito del
seed (può esaurirsi prima del budget predefinito di un milione di passi).
Restano da completare payload diagnostici Full e integrazione generale
con l'evaluator Full; il percorso Core normale resta invariato.


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


Runtime note: the machine-code seed is the default runtime for `.triad` (launcher `bin/triad`/`bin/triad.cmd` and CLI); Julia remains a development tool (tests, conformance, packaging).

## Current status (Day 4)

### Seed S0 Windows - COMPLETED

- **PE**: 25,088 bytes, code 8315 bytes
- **Hash**: `3A75A21E2F47D8DC4C88D4BC2580A85D5349BCDF7550E5FFA16E2C0AC7CA8C11`
- **Features**:
  - Integers, variables, functions (short and block form)
  - Recursion, Bool, operators (`% ^ ! && || +=`)
  - `if`/`elseif`/`else`, `while`, `let`, `begin`
  - Lambda, basic closures
  - Basic strings + concatenation + `string(Int/String)`
  - Full lists (construction, printing, `push!`, `get`)
  - `nothing`, symbols
- **Conformance**: 33/33 Windows cases byte-exact, 36/36 Core Julia
- **Bug fixed**: `string()` Int conversion (r10 initialized correctly)

### S1 (Triad interpreter in Triad-Core) - NOW COMPLETED

- **S1.3**: Tagged value system (Int, Bool) completed
- **S1.4**: Inline parser/tokenizer completed
- **S1.5**: Basic expression eval completed (bug fixed: environment lookup)
- **S1.8**: Variables with let completed
- **S1.11-S1.15**: Full parser, functions, closures, tests completed

### S2-S4 (Bootstrap) - NOT STARTED

- **S2**: Native compiler - initial draft
- **S3**: Self-hosting - in progress
- **S4**: Full runtime, Linux parity - planning

## Current tasks

### MAIN (2026-11-03): Linux native seed — no Wine (TASK.md N15–N18)

- The maintainer decision: Triad must not be a Windows-only emulator. Windows keeps the PE;
  Linux must need **nothing beyond the repo** (no Wine, no Node to run programs).
- N15 (E1): ELF file runner (`argv` + `openat`/`read`/`write`) → N16 (E2a): split the
  platform-independent interpreter codegen from the `os_*` OS routines in `gen_seed.js` →
  N17 (E2b): ELF64 emitter with PE parity (byte-exact conformance, identical probes) →
  N18 (E3): `install.sh`/`bin/triad` on the native seed + Wine-free `seed-linux` CI job.
- This task precedes N03 (`xs[i]` 1-based) and the other mechanical sub-tasks.

### Immediate: final S1 verification

- All ai/tasks/ tasks completed
- Conformance suite verified
- Bugs fixed and documented

### After S1

- S2: Native compiler - codegen review
- S3: Self-hosting - cross-platform validation
- S4: Full runtime, Linux parity - benchmark

### Cleanup: debug output and throwaway files

- [x] Debug console.log lines in seed/dev/gen_seed.js: no longer present (plan was outdated)
- [x] seed/dev/gen_seed_linux.js output: already minimal (sha256 + written file only)
- [x] Probe files (_probe.jl, _probe2.jl, _probe3.jl, _qc.jl, _smoke.jl): never versioned, already gitignored
- [x] Root output files versioned (`out.txt`, `output.txt`, `outfile.txt`, `stdout.txt`, `runoutput.txt`, `test_output.txt`, `error.txt`, `scope_out.txt`, `let_output.txt`, `let_test_out.txt`, `let_annidato_out.txt`): removed and ignored
- [x] `scripts/seed-runner/run_seed.bat` ... `run_seed12.bat` (12 variants): consolidated to single parameterized `run_seed.bat`

## S1 implemented files

- `selfhost/value.td`: Tagged value system
- `selfhost/tokenizer.td`: Inline parser/tokenizer
- `selfhost/eval.td`: Basic expression eval
- `selfhost/main.td`: Working inline environment

## Current seed limitations

- `string()`: only Int/String (Bool/Symbol/Nothing not implemented but not required for conformance)
- Lists: integers only, max 64 elements
- Standard indexing, `length`, iteration: not implemented (S2)
- Conformance: 33/33 completed

## Conformance status

- Stage0 Julia: 33/33 Core, 12/12 Full
- Seed Windows: 33/33 Core
- Seed Linux: minimal E0 (not comparable) - starting cross-platform tests for parity

## Completed ai/tasks/

- **01_somma**: Triad sum and precedence program
- **02_fattoriale**: recursive factorial(n) function
- **03_fibonacci**: recursive fib(n) function
- **04_stringhe**: string assignment and concatenation
- **05_chiusure**: closures and application
