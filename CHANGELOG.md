# Changelog — standard Triad

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


## Non rilasciato — 2026-11-08 (ter): ternario con simbolo — divergenza `D23` del seed

### Added
- **Casi di conformance `ternario_simbolo`** (`conformance/core/cases/ternario_simbolo/`):
  il ternario il cui ramo *then* è un **simbolo**. Il golden (`intero` / `numero` / `numero`,
  exit 0) è quello del **riferimento JS** (`seed/dev/triad_core.cjs`, autorità semantica,
  byte-exatto sui 39 casi già congelati); nessun golden è stato riscritto per mascherare il
  difetto. Il caso contiene anche il controllo del ramo *else* (`? 1 : :numero`), che il
  seed esegue senza problemi.
- **Divergenza `D23 = noisy`** nel contratto del seed (`seed/dev/certified-subset.txt`) e
  riga nella tabella delle divergenze di `seed/README.md`: il seed prende il `:` di un
  simbolo come separatore del ternario e **rifiuta** il programma (exit 1).
- **Guardia statica `G-D23`** (`tools/selfhost-guard/rules.mjs`) + fixture
  `d23_ternario_simbolo.td` + voce nel self-test: nei sorgenti di S1 (che girano sul seed)
  il ternario con un simbolo a profondità zero nel ramo *then* è **vietato**. Come tutte le
  regole, si spegne da sola quando `D23` sparisce dal contratto.

### Fixed
- **`conformance/gate.sh`** — la KNOWN_GAP accettava **un solo** nome (`grep -v -x -F
  "$KNOWN_GAP"`): con due gap noti il filtro non ne avrebbe escluso nessuno e il gate
  sarebbe fallito. Ora i gap sono un elenco (uno per riga) e il filtro usa
  `grep -v -x -F -f`, con il motivo di ogni gap stampato nel riepilogo.

### Known (non risolto qui)
- Il **fix del codice macchina** del ternario (`seed/dev/core.js`, routine
  `pt_scan`/`pt_colon`) è rinviato a una sessione separata: tocca il ciclo di rebuild dei
  dump (`seed.hex` + PE/ELF + hash CI), oggi bloccato dal known issue anti-drift (vedi
  `TASK.md` → handoff «2026-11-07 22:40 (ter)»). Finché il fix non c'è, il caso
  `ternario_simbolo` è il **2° gap noto** della suite Core: `conformance/gate.sh` lo
  esclude in modo esplicito e rumoroso (**38/40** verdi sul seed, 40/40 sul riferimento JS).
- Ticket: `.scratch/seed-linux-nativo/issues/11-ternario-simbolo-seed.md` (aperto).

## Non rilasciato — 2026-11-08 (bis): contratto dei limiti del seed allineato all'arena N20

### Fixed
- **`seed/linux-x86_64/check_seed.sh`** — i casi 6 e 7 verificavano ancora l'envelope
  pre-N20 (sorgente ≤ `0xEFFF` ammessa, `0xF000` rifiutata): il gate falliva con
  `FAIL: 0xF000: exit 0 (atteso 1)`, perché l'arena N20 riserva **1 MiB** di sorgente
  (maschera di stop a `+0x100000`). Ora i casi verificano `0xFFFFF` ammessa (exit 0,
  stdout byte-esatto) e `0x100000` rifiutata (exit 1, stdout vuoto, diagnostica su stderr).
- **`.github/workflows/ci.yml`** — il gate hash anti-tampering riportava gli hash dei dump
  **pre-N20**: allineati ai dump committati (ELF `971f61d5…`, PE `9f96c413…`).
- **`seed/windows-x86_64/seed.exe` e `seed_decoded.exe`** — erano la decodifica del dump
  **pre-N20**, non quella del `seed.hex` committato (ADR 0001: i due file devono essere la
  decodifica esatta del dump canonico): rigenerati dal `seed.hex` committato. La parità
  PE↔ELF sull'envelope è ripristinata (prima il PE rifiutava già una sorgente da 64 KiB,
  l'ELF no).
- **Documentazione** allineata all'envelope N20: `seed/README.md`,
  `seed/linux-x86_64/README.md` (tabella dei comportamenti, limiti, numeri e hash),
  `seed/windows-x86_64/README.md` (memory map, numeri e hash), il mirror Obsidian in-repo
  (`obsidian-triad/wiki-content/Doc-seed-windows-README.md`) e
  `docs/libro/_dati_dal_codice.md` (§3 «Limiti strutturali del seed»).
  Il mirror gemello `obsidian-triad/github-wiki/Doc-seed-windows-README.md` sta nel
  **submodulo** del wiki (repo separato): va aggiornato lì, out-of-band.

### Known (non risolto qui)
- Il passo CI «Reproducible dump (anti-drift)» resta **rosso**: il generatore a HEAD
  (`ceaf202`, WIP N03/N04) non rigenera i dump committati. È il known issue del ciclo di
  rebuild (vedi `TASK.md` → handoff «2026-11-07 22:40 (ter)»): chiudere il ciclo prima di
  rigenerare PE/ELF + hash.

## Non rilasciato — 2026-11-08: guardie statiche e gate differenziale sul corpus certificato

Decisione [12] della mappa self-hosting M6 (`.scratch/self-hosting-m6/issues/12-guardie-statiche-sorgente-s1.md`):
*come* si presidia il sottoinsieme certificato del seed.

### Added
- **Contratto del seed** — `seed/dev/certified-subset.txt` (macchina-leggibile: envelope,
  primitivi §8 disponibili, divergenze D1–D22 con la classe `silent`/`noisy`) e la sezione
  «Contratto del seed» in `seed/README.md` (la versione leggibile, con la tabella delle
  divergenze e l'elenco di ciò che è *fuori contratto*).
- **Corpus certificato** — `seed/dev/certified-corpus.txt`: i programmi che il seed deve
  poter eseguire (front-end di S1, smoke, i quattro generatori attivi di `tools/site-gen/`).
- **Guardie statiche sulla sorgente di S1** — `tools/selfhost-guard/`: CLI `guard.mjs`,
  regole `G-D01`…`G-D22` (una per divergenza) più le regole d'envelope `G-E01`–`G-E03`,
  analisi degli ambienti sull'AST del riferimento JS (`analysis.mjs`), scanner grezzo del
  sorgente (`scan.mjs`), lettore del contratto (`contract.mjs`), self-test con un fixture per
  regola (`test.mjs`, `fixtures/`).
- **Gate differenziale seed ↔ riferimento JS** — `tools/selfhost-guard/differential.mjs`: per
  ogni programma del corpus certificato, seed e riferimento JS devono dare lo **stesso stdout
  byte per byte** e lo **stesso exit code**.
- **CI** (job `conformance-core`): tre passi nuovi — guardie statiche, self-test, gate
  differenziale.

### Changed
- Il lint di `tools/site-gen/lint.mjs` **resta dov'è** (presidia un altro contratto: il
  sottoinsieme portabile per il browser) e non viene duplicato: le regole nuove sono *del
  seed* e consumano il suo contratto.
- Ogni regola è **legata a una divergenza**: quando il seed viene corretto e la divergenza
  sparisce da `certified-subset.txt`, la regola si spegne da sola.

### Fixed (misure corrette)
- `println` **è** ammesso in posizione finale (D9): la regola iniziale era troppo larga.
- Il seed **risolve** i riferimenti in avanti *fra funzioni* (D18 rifiuta solo la chiamata a
  livello di file che precede la definizione).
- Lo scope dei corpi di blocco riguarda `if`/`while` (`let`/`begin` lo fanno già) e ha due
  casi: il nome *nuovo* è una divergenza vera fra i runtime, il nome *già legato* è identico
  nei due runtime (decisione normativa pending, famiglia N08).
- Le keyword cieche del seed contano **solo dentro un corpo di blocco** (D22).

## 0.8.0-beta.9 — 2026-11-07: seed Linux nativo, toolchain senza Node, desktop launcher

Riepilogo della release: da `v0.8.0-beta.8` (2026-10-31) a `v0.8.0-beta.9` (2026-11-07).
Dettaglio completo nelle sezioni datate qui sotto, in `docs/releases/RELEASE_NOTES_v0.8.0-beta.9.md`.

### Added
- **Seed Linux nativo (N17, E2b)** — `seed/linux-x86_64/seed`: interprete Triad-Core completo
  in ELF statico senza libc (8499 byte), con parità **byte-esatta** rispetto al PE Windows
  (interi, variabili, funzioni, ricorsione, Bool, operatori, `if`/`elseif`/`else`, `while`,
  `let`, `begin`, lambda/closure, stringhe, `nothing`, simboli, liste). Nessun Wine, nessun
  runtime esterno: su Linux il linguaggio si esegue **nativamente**.
- **Toolchain Linux senza Node (N18, E3)** — `install.sh` (decoder hex **sh-puro** con
  `printf` ed escape ottali, anti-drift `cmp` del binario decodificato, launcher come
  wrapper a percorso assoluto, smoke test byte-exatto), `bin/triad` che esegue **sempre il
  seed**, CLI POSIX `bin/triad-cli` (`run` / `test` / `status`).
- **Harness di verifica senza Node** — `conformance/run.sh`, `tests/probes/run_probes.sh`,
  `verify.sh` (entry point unico) e `seed/linux-x86_64/check_seed.sh`.
- **Launcher desktop** — `bin/triad-desktop` (sessione POSIX che mantiene output ed errori
  visibili fino a `:quit`/EOF) e registrazione dei MIME `.triad`/`.td` in `install.sh --desktop`
  (double-click → programma predefinito).
- **Front-end S1** — `selfhost/source.td`: nuovo scanner + root-scan + discesa ricorsiva
  derivati dal codice macchina del seed; stampa l'AST in pre-ordine (golden byte-identico
  su seed PE e interprete JS di riferimento).
- **Sito generato da sorgenti Triad** — `tools/site-gen/` (generatori `.td` + driver
  `build.mjs` + `lint.mjs`): le pagine di `docs/` sono emesse dal linguaggio stesso.
- **Libro: *Fondamenta*** — `docs/FONDAMENTA.it.md` (programmazione da zero) e ~900 esercizi
  aggiunti ai capitoli conclusi; PDF 424 pagine, geometria KDP conforme.
- **Governance del repository** — `GLOSSARY.md`, ADR `docs/adr/0001` (immutabilità del dump
  PE) e `0002` (verifica di parità senza rieseguire il PE), issue tracker locale in
  `.scratch/<sforzo>/`.

### Changed
- **CI solo Linux nativo (decisione 04)** — eliminate le gambe Windows del workflow; il lato
  PE resta garantito dal gate hash di `seed.hex` + golden congelati (ADR 0002). Job:
  `conformance-core`, `site-gen`, `seed-linux` (con anti-drift dei dump PE **ed** ELF),
  `linux-toolchain` (senza `setup-node`), `security`.
- **Gate di conformità con gap noti espliciti** — `conformance/gate.sh` (nuovo): esegue
  l'oracle `conformance/run.sh` e tollera **solo** i fallimenti già documentati (`liste`,
  gap N03), stampandoli sempre; ogni altro fallimento fa fallire il gate. `verify.sh` e
  `triad-cli test conformance` usano il gate; l'oracle puro resta raggiungibile con
  `triad-cli test conformance --strict` (o `sh conformance/run.sh`). Nessun golden è
  stato riscritto per mascherare il gap.
- **CI ripristinata** — `.github/workflows/ci.yml` aveva uno scalare non quotato contenente
  `": "` (`- name: Verify (harness senza Node: ...)`): YAML non valido, GitHub non avviava
  alcun job («this run likely failed because of a workflow file issue») dal 2026-11-06.
  Nome dello step quotato + nuova regressione `tests/security/workflows_yaml.test.py`
  (check 8 di `tests/security/run.sh`): ogni workflow deve essere YAML valido.
- **Golden dei probe e del front-end S1 versionati** — `tests/probes/*.expected.out` e
  `selfhost/*.expected.out` erano esclusi da git (`*.out` senza eccezioni): in un checkout
  pulito il harness dei probe falliva con «golden mancante» su 23 probe su 39. Ora sono
  versionati (eccezioni in `.gitignore`), come i golden di `conformance/` e `ai/`.
- **Generatore del seed** — `seed/dev/gen_seed.js` con unico entry point
  `gen_seed.js <windows|linux|all>`: core del codegen condiviso + backend `backend_pe` /
  `backend_elf`; il confine `os_*` isola le chiamate di sistema (N16). Il dump PE resta
  byte-identico.
- **Riferimento JS** — `seed/dev/triad_core.cjs` allineato al seed (`get(xs, i)` 0-based,
  newline ammessi nei letterali di lista, ternario con `:` attaccato).

### Fixed
- **Seed: rimosso il codegen rotto dell'indicizzazione `xs[i]`** — il tentativo del
  2026-11-06 leggeva il campo tipo della lista nel registro che teneva il puntatore
  (`mov rdx, [rdx]`): la lettura falliva con parse error e la scrittura `xs[i] = v`
  terminava con **SIGSEGV**. Il codegen torna allo stato documentato (il gap N03 resta
  aperto: `xs[i]` 1-based non e' implementato nel seed) e i dump PE/ELF tornano coincidere
  con i gate hash della CI (PE `4235a707…`, ELF `0e121db8…`); il binario PE committato non
  cambia (`631f401f…`).

### Security
- **Credential-storage hardening** — il PAT GitHub in chiaro presente nella working tree è
  stato rimosso e il template riportato alla cronologia; `tools/git-push-with-token.ps1`
  non mette più il token nell'URL del remote ma in una `credential.helper` temporanea
  alimentata dall'ambiente; nuovo test di regressione
  `tests/security/no_live_tokens.test.py` (nessun token vivo nel repository né nelle URL).

### Known issues
- Il caso di conformance **`liste`** fallisce sul seed (38/39 verdi): il gap storico è
  registrato nell'harness (exit 1 + stdout vuoto) e il gate `conformance/gate.sh` lo esclude
  **in modo esplicito e rumoroso** (l'eccezione è elencata nel gate e in questo CHANGELOG).
  I probe sono **39/39** verdi. Nessun golden è stato riscritto per mascherare il gap.

## Merge `origin/main` — 2026-11-07

Il ramo `fix/desktop-cli-session` è stato riallineato a `origin/main` (merge `45c7d7d`).
Conflitti risolti: config Codacy (`.codacy/codacy.config.json`,
`.codacy/codacy.config.baseline.json`) prese da `origin/main` (config remota
`GPuntobit/triad2.0`); `bin/triad-desktop` tenuta nella versione del ramo (sessione POSIX con
`:quit`, exit code preservato, mode `755`); istruzioni Codacy allineate a
`repository: triad2.0`. Nessuna modifica alla semantica del linguaggio né ai goldens.

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
Regulatory changes also update `VERSION`, the specification (`SPEC.md`) and, if it changes
behavior, the goldens of `conformance/`.

## 2026-11-05: toolchain Linux senza Node — install → run (N18, E3)

### Added
- `bin/triad-cli` — CLI **POSIX senza Node** a pura delega: `run <file> [-- args]` →
  `bin/triad`; `test conformance [--update]|probes|all` → `conformance/run.sh` /
  `tests/probes/run_probes.sh` / `verify.sh`; `status` deterministico (root, `uname -s -m`,
  seed, stato del PATH). Exit code = comando delegato; exit 2 = errori d'uso.
- `install.sh` riscritto secondo il contratto zero-install (ticket 07): decoder hex
  **sh-puro `printf`** con escape ottali (nessun `xxd`/`python3`/`od`), verifica anti-drift
  della decodifica col binario committato (`cmp` + avviso), launcher installati come
  **wrapper a percorso assoluto** (niente symlink), **smoke test byte-exatto**
  (`test_simple.td` vs `test_simple.expected.out`) che fa fallire l'installazione su
  mismatch; fuori Linux x86-64 installazione parziale con avviso, exit 0.

### Changed
- `bin/triad`: **exec-sempre-il-seed** — escono la soglia stub 4 KB, la flag `--jsref`, il
  ramo JS e il ramo `bin/triad-native` (nessun artefatto opzionale devia il runtime);
  `TRIAD_SEED` resta l'unico override; seed mancante/non eseguibile → errore chiaro, exit 1.
- `cli/triad-cli.mjs` (CLI Node di sviluppo): ai soli comandi dev `seed generate`,
  `ai verify`, `ext check|package` (nome invariato).
- `.github/workflows/ci.yml`: job `linux-toolchain` senza `setup-node` (launcher + install +
  smoke negativo + `triad-cli test all`); documentazione tutorial (it/en/ja/zh/ru),
  `README.md`, `cli/README.md`, `AGENTS.md`, `PROJECT_PROMPT.md`, `seed/README.md`,
  `seed/linux-x86_64/README.md`, `BOOTSTRAP.md` §5/§10 allineati alla CI post-decisione 04.

### Removed
- `cli/lib/commands/run.mjs`, `test.mjs`, `build.mjs` e la logica di stub/fallback
  (`seedIsStub`, `runSeed`, `runSh`, `findSeed`) da `cli/lib/utils.mjs`; comandi
  `run`/`test`/`status`/`build standalone` dalla CLI Node (coperti dalla CLI sh).
- `install.sh`: opzione `--no-symlink` (opzione sconosciuta → exit 2) e i rami decoder
  `xxd`/`python3`/`od`+`awk`.

## 2026-11-05: seed Linux E2b — interprete Triad-Core nativo + harness senza Node (N17)

### Added
- `seed/linux-x86_64/seed` (ELF64 statico **E2**, 8499 byte, senza libc): interprete
  Triad-Core completo — stessa macchina del PE (interi, variabili, funzioni short e
  `function … end`, ricorsione, Bool, operatori, `if`/`elseif`/`else`, `while`, `let`,
  `begin`, lambda/closures, stringhe base + `string()`, `nothing`, simboli, liste con
  costruzione/stampa/`push!`/`get`). Parità **byte-exatta** col PE: `conformance/core`
  39/39, probe 39/39, golden S1 `selfhost/source.expected.out`; il gap storico `liste`
  è registrato nell'harness (exit 1 + stdout vuoto, identico su PE ed ELF), non skippato.
- Harness di verifica **senza Node** (ticket 08, sostituzione in un colpo solo):
  `conformance/run.sh`, `tests/probes/run_probes.sh`, `verify.sh` (entry point unico) e
  `seed/linux-x86_64/check_seed.sh` (7 casi errori/limiti); golden sidecar
  `<file>.expected.out`/`<file>.expected.code` congelati da PE committati per tutti i
  probe e per i casi selfhost.

### Changed
- `seed/dev/gen_seed.js`: entry unico `gen_seed.js <windows|linux|all>` — core del codegen
  condiviso + moduli `backend_pe`/`backend_elf` (decisioni 02 Q8 / 03 Q6); `os_*` su ELF
  via syscall Linux (`openat`/`read`/`write`/`exit`), niente libc. Dump PE/ELF
  riproducibili; hash PE `4235A707…B8F7` invariato. `gen_seed_linux.js` assorbito.
- `.github/workflows/ci.yml`: ripuntata ai nuovi entry point sh; le gate perse dalle
  gambe Windows (probe `ok_*`/`test_*`, golden `selfhost/source.td`, probe `get`, smoke
  `selfhost/main.td`) riagganciate al job `seed-linux` sull'ELF nativo; delega di
  `triad-cli test conformance` a `run.sh`.
- `cli/lib/commands/test.mjs`, `cli/lib/utils.mjs`, `bin/triad`: delega all'harness sh.

### Removed
- `conformance/run.mjs`, `conformance/run.test.mjs`, `tests/probes/run_probes.mjs`
  (sostituiti dagli entry point sh); `seed/linux-x86_64/check_e1.sh` (rinominato
  `check_seed.sh`); file spurio `windows`.

## 2026-11-05: CI senza gambe Windows (decisione 04)

### Changed
- `.github/workflows/ci.yml`: rimosse le **gambe Windows** come da decisione 04 (ticket
  `.scratch/seed-linux-nativo/issues/04-parita-suite-ci.md`, *Parità: suite di
  riferimento, CI e politica delle divergenze*): job `seed-windows` eliminato e matrice
  `site-gen` ridotta a `ubuntu-24.04` — la verifica gira solo su Linux nativo, senza
  runner Windows. Il lato PE resta garantito dal gate hash di `seed.hex` (spostato nel
  job `seed-linux`, anti-tampering) + golden congelati (ADR 0002: il PE non viene mai
  rieseguito dal gate). Nota storica: il commit `fc320f4` dichiara questa rimozione nel
  messaggio ma non la implementa nel diff. Le gate che giravano sul PE (probe
  `ok_*`/`test_*`, golden `selfhost/source.td`, probe `get`, smoke `selfhost/main.td`)
  rientreranno sull'ELF nativo alla parità N17.

## 2026-11-05: confine `os_*` nel generatore del seed (N16)

### Changed
- `seed/dev/gen_seed.js`: rifattorizzazione **solo strutturale** — il codegen dell'interprete
  (*core del codegen*, piattaforma-indipendente) è separato dalle chiamate di sistema
  Windows, isolate nelle routine `os_*` (`os_arg`/`os_open`/`os_read`/`os_write`/`os_exit`/
  `os_alloc`) in emissione inline a *piazzamenti ordinati* (contratto `os_*`, ticket 03
  della mappa `seed-linux-nativo`). Il PE rigenerato resta **byte-identico** (hash
  `seed.hex` invariato `4235A707…B8F7`); conformance Core e probe invariate.
- `.github/workflows/ci.yml`: anti-drift del dump PE (`gen_seed.js` + `cmp`) accanto a
  quello ELF — chiude la lacuna del drift `649709a` (ADR 0001) anche lato Windows.
- `seed/dev/README.md`: descrizione della nuova struttura del generatore; hash di
  `seed.hex` corretto (era obsoleto: `3A75A21E…`).

## 2026-11-05: seed Linux E1 — runner di un file `.td` (N15)

### Added
- `seed/linux-x86_64/check_e1.sh` — 7 casi di accettazione POSIX shell (echo
  byte-exatto, file vuoto, usage exit 2, path vuoto exit 2, file inesistente exit 1,
  sorgente 0xEFFF ammesso, sorgente 0xF000 exit 1) con confronti `cmp`; eseguito dalla
  CI `seed-linux`.

### Changed
- `seed/dev/gen_seed_linux.js` + `seed/linux-x86_64/seed.hex`/`seed`: il seed ELF passa da
  E0 (messaggio fisso) a **E1** — `_start` con argc/argv e syscall `openat`/`read`/`write`/
  `exit`; legge il sorgente da `argv[1]` e lo riscrive su stdout (echo). Exit code pari al
  PE (contratto `os_*`): 2 = usage, 1 = open/read fail o sorgente ≥ `0xF000`; diagnostica
  su stderr solo sull'ELF (il PE resta muto). 557 byte, sotto la soglia stub di 4 KB.
- `.github/workflows/ci.yml`: job `seed-linux` ora esegue `check_e1.sh`, verifica hash
  del dump e anti-drift (`gen_seed_linux.js` + `cmp`).
- `install.sh`: smoke test agnostico alla fase del seed (esecuzione di `test_simple.td`
  con exit 0, non più stringa `Triad seed Linux OK`).
- `seed/linux-x86_64/README.md`, `seed/README.md`, `seed/dev/README.md`: comportamento,
  numeri, hash e limiti noti di E1.

## 2026-11-02: chiusura righe 2–6 dei problemi aperti, A03/A04

### Changed
- `SPEC-CORE.md`: §8 aggiunge `get(xs, i)` (primitiva di bootstrap, indice
  **0-based**) con nota che la distingue da `xs[i]` (§7, 1-based) e che i casi di
  `conformance/core/` non la usano; §2 chiarisce che una stringa **può contenere
  newline grezzi** (decisione normativa: entrambi i runtime li accettano).
- `seed/dev/triad_core.cjs`: dentro `[ ... ]` i newline sono trivia (come nel codice
  macchina), quindi i letterali di lista vanno a capo; in `parseTernary` un token
  SYM in posizione di colon viene reinterpretato come `:` + resto (`a ? b :c`).
- `selfhost/source.td`: lo scanner accetta i simboli operatore (`:+`) e i parser
  reinterpretano il colon attaccato al ramo del ternario; nuovo chunk c8 nel
  sorgente di test (ternario annidato con colon attaccati), golden rigenerato.
- `selfhost/ast.td`: rimosso `type AST = Int` (fuori grammatica); `make_call` usa il
  pattern assegna-e-restituisci. `selfhost/program.td`: riscritto sul modello piatto
  di token interi (prima: modello annidato incoerente, errore a runtime).
- `.github/workflows/ci.yml`: job `security` (`tests/security/run.sh`); il job
  `seed-windows` usa `conformance/run.mjs` (scoperta directory + golden) al posto
  della lista hardcodata di 35 casi, più `run_probes.mjs --strict` e
  `run_probes.mjs selfhost/source.td` (golden del front-end S1);
  `conformance-core` verifica che ogni `selfhost/*.td` sia eseguibile.
- `tests/probes/run_probes.mjs`: override `TRIAD_SEED`, confronto con golden
  opzionale (`<file>.expected.out`), exit code non-zero se un `ok_*`/`test_*`
  differisce (i `bad_*` documentano divergenze e non falliscono).

### Added
- `tests/probes/ok_lista_multiriga.td` (ribaltato da `bad_`),
  `ok_ternario_colon_attacco.td`, `bad_simbolo_operatore.td`,
  `bad_identificatore_maiuscolo.td`, `bad_separatore_newline.td` — con le righe
  corrispondenti in `tests/probes/README.md`.

## 2026-11-02: nuovo algoritmo per il codice sorgente (front-end S1)

### Added
- `selfhost/source.td` — nuovo algoritmo per il codice sorgente, derivato dal
  codice macchina del seed (`seed/dev/gen_seed.js`) e non dalla vecchia
  implementazione Julia: scanner a token con cursore esplicito
  (`next_tok(srcs, pos, campo)`), root-scan dell'espressione corrente con le
  regole del codice macchina (radice = operatore di precedenza minima,
  ultima delle catene left-assoc, `?`/`->` right-assoc; parentesi/ternario/
  virgole come in `scan_end`/`pt_scan`) e discesa ricorsiva che stampa l'AST
  in pre-ordine con la profondita' come prefisso. Copre l'intero dominio del
  codice macchina: `println`, `break`, `=`/`+=`/`-=`/`*=` , funzione breve e a
  blocco con parametri ed effetti `!io`, `let`, `begin`, `if`/`elseif`/`else`,
  `while`, lambda `x -> expr`, chiamate, liste, stringhe con escape, simboli,
  letterali `true`/`false`/`nothing`, ternario, tutti gli operatori e i due
  commenti `#` / `#= =#`. Esegui**to** e verificato identico byte per byte su
  seed PE in codice macchina e sull'interprete JS di riferimento
  (`node tests/probes/run_probes.mjs selfhost/source.td` → `[same]`); golden
  in `selfhost/source.expected.out`.
- `tests/probes/bad_lista_alloc.td`, `bad_lista_multiriga.td`,
  `bad_scope_dinamico.td`, `bad_parametri_5.td` — quattro nuovi limiti del
  seed misurati e certificati: ~60 valutazioni di letterali di lista per
  esecuzione (528 byte fissi per valutazione in un heap di 64 KB; ~150 fanno
  terminare il processo per access violation), letterali di lista su piu'
  righe (accettati dal seed, `parse error` sul JS), scope DINAMICO dei nomi
  nelle funzioni (il callee vede i locali del chiamante; il JS e' lessicale),
  massimo 4 parametri per funzione.

### Changed
- `seed/dev/triad_core.cjs` — aggiunto il builtin `get(xs, i)` (indice 0-based
  su lista, con gli stessi controlli del primitivo `pf_builtin_get` del codice
  macchina): il riferimento JS allineato al seed rimuove la divergenza misurata
  da `tests/probes/test_get.td` (ora `[same]`). Conformance Core invariata.
- `tests/probes/README.md` — tabella aggiornata con le misure vere di
  `get`/`length`/`xs[i]` (la vecchia tabella li dava invertiti) e con i quattro
  nuovi limiti.

## 2026-11-02: credential-storage hardening (security)

### Security
- `.git-credentials` (working tree) — a live GitHub PAT stored in plaintext in the repository
  root has been removed and the placeholder restored; the token never entered git history
  (verified over all 832 commits) but must be rotated (see `docs/security/SECURITY-REVIEW.md`
  findings #5–#7).
- `tools/git-push-with-token.ps1` — the PAT is no longer embedded in the origin remote URL
  (it used to land in `.git/config` and in git error output). Authentication now uses a
  throwaway `credential.helper` that reads the token from the process environment only;
  `git add -A` explicitly excludes `.git-credentials`.
- `.git-credentials.example` — the template now points to the standard git credential store
  outside the repository (`%USERPROFILE%\.git-credentials` / `~/.git-credentials`) and
  recommends the `GITHUB_TOKEN` environment variable and fine-grained, minimal-scope PATs.
- `tests/security/no_live_tokens.test.py` — new regression test (registered in
  `tests/security/run.sh` as check 7): no live GitHub token in the working tree (text and
  binaries), no token in git URLs/remotes in the push tooling, `.gitignore` covers
  `.git-credentials`, and the template keeps the credential store out of the repository.

## 2026-11-02: per-chapter exercises in the book

### Added
- `docs/FONDAMENTA.it.md`, `docs/MANUALE.it.md`, `docs/tutorial/TUTORIAL.it.md` — every
  concluded chapter now ends with an **Esercizi** section with at least 10 exercises
  (~900 new exercises overall). The exercises are grounded in the chapter content and respect
  the Core/Full labelling: Core exercises are runnable on the reference interpreter (and, where
  the book says so, on the seed), Full exercises are marked **[Full]** and are study material
  until the runtime implements the standard. The pre-existing exercise material was kept and
  topped up to the same minimum (Fondamenta 8 and 14 already had 10 and 12 exercises; Manuale
  1.11 grew from 5 to 12 items, Manuale 23 and 24 and Tutorial 17 gained supplementary lists).
- `docs/libro/Il-libro-di-triad.pdf` (424 pages, was 378), `libro.html`, `Il-libro-di-Triad.epub`,
  `libro.docx` regenerated from the updated sources; KDP margin check passes (gutter 19.05mm,
  minimum 19.05mm for 401–500 pages).

## 2026-11-01: the site rebuilt from Triad sources

### Added
- `tools/site-gen/site_pages.td`, `tools/site-gen/site_playground.td`,
  `tools/site-gen/site_style.td` — the site generators: Triad programs that emit the static
  site of `docs/` (documentation pages, playground page, stylesheet) as a text bundle of
  `=== FILE: <path> ===` markers.
- `tools/site-gen/build.mjs` — the driver: it runs every generator on the machine-code seed
  **and** on the JavaScript reference interpreter, requires byte-identical stdout from the two,
  splits the bundle and writes the files. `--check` verifies that the published files match
  the generated ones, `--dry` runs everything without writing.
- `tools/site-gen/lint.mjs` — lint of the Triad sources: it blocks the constructs the seed
  cannot execute (`return` inside a block function, `print`, multi-argument `println`, string
  escapes, multi-binding `let`, `readfile`, a literal containing `if` inside a block, a call
  as last expression of a body, `+=` on strings).
- `tests/probes/` — the portability matrix: every probe is executed on the two runtimes and
  compared byte for byte. `tests/probes/README.md` documents the certified Triad-Core subset
  and the measured limits of the seed (they are limits of the seed, not of the specification:
  `SPEC-CORE.md` §2–§7 allows all of them).
- Generated pages: `docs/pages/getting-started.html`, `language-tour.html`, `spec.html`,
  `tutorial.html`, `conformance.html`, `bootstrap.html`, `editors.html`, `status.html`,
  `playground.html`, `apprendimento.html`, `ai.html`, `license.html`, plus the stylesheet
  `docs/assets/css/triad-generated.css` (documentation layout, playground, tables, code
  cards). The pages that `docs/index.html` and `docs/assets/js/app.js` linked but that did not
  exist are now generated by Triad: the site has no broken internal link.
- CI job `site-gen` (Ubuntu and Windows): it lints the generators and checks that the
  published files match the generated ones. On Windows the check also compares the two
  runtimes, byte for byte.

### Changed
- `docs/index.html` and `docs/assets/js/app.js` link pages that did not exist: the pages
  listed above are now generated by Triad and published with the site.
- `tools/site-gen/README.md` — documentation of the generator: bundle protocol, commands,
  certified subset, the three practical consequences for anyone writing a generator.

### Fixed
- The site generators now compare the two runtimes on **raw bytes** (`Buffer.equals` in
  `tools/site-gen/build.mjs`), not on decoded strings.
- `docs/assets/js/learning-curve.js`: 38 corrupted sequences (UTF-8 bytes mapped through CP437)
  are repaired — `–` (en dash), `·` (middle dot), `Σ` (sigma), `—` (em dash). The learning curve
  chart no longer shows wrong characters.
- `docs/assets/js/app.js`: the navigation has a `License` entry and no longer duplicates `Home`
  (the brand already links to the home page); `markSidebar()` marks the current page in the
  documentation sidebar, which is generated by Triad and therefore cannot carry the `active`
  class itself; the footer link to the book points to `libro/libro.html`, the file that exists.
- `docs/assets/css/triad-generated.css` (generated by Triad): the navigation links are compacted
  above 1100px, so all thirteen entries fit without horizontal scrolling.
- The generated pages no longer state that the tutorial has four parts (it has five, with
  chapters 44-49 as the reference), no longer point at a non-existent `recursion` conformance
  case (it is `ricorsione`), no longer show the wrong `export PATH` line for `install.sh`, and
  mark the logic and code-as-data sections as Triad-Full.

### Known limits of the seed (measured, not regressions)
The site generators stay inside a narrow subset because the seed in machine code is still
partial: no `print`, no multi-argument `println`, no `return` in a block function, no escape
inside a string, no `let` with more than one binding, no `readfile`, no list indexing, no
forward reference, and a literal containing the substring `if` inside a block breaks the
block nesting counter. The reference interpreter implements the whole Triad-Core, so a
divergence between the two runtimes is a defect of the program, not of the seed.

## 2026-11-01: libro — Fondamenta per principianti, PDF rigenerato

### Added
- `docs/FONDAMENTA.it.md` — nuova parte del *Libro di Triad*, "Fondamenta: programmare da zero
  con Triad", per chi non ha mai programmato: programma/interprete, terminale, valori e tipi,
  variabili, espressioni, stringhe, `if`/`while`, liste, funzioni, ricorsione, errori e debug,
  pensare da programmatore (scomporre un problema), esercizi con soluzioni, glossario dei
  termini informatici, domande da neofita, percorsi di lettura, Appendice A (installazione
  guidata passo passo con tabella dei guasti) e Appendice B (scheda rapida della sintassi
  Core). Tutti gli esempi sono Triad-Core e sono stati verificati uno per uno con
  `node seed/dev/triad_core.cjs` (34 esempi completi, output identici a quelli riportati;
  1 con output abbreviato verificato per prefisso/suffisso).
  Include il capitolo 15 "Una domanda che capita spesso: cosa sono «success» e «fail»?":
  spiega task e verifica automatica del benchmark `ai/` (PASS/FAIL rispetto all'output atteso,
  metriche `pass@1`/`pass@k`, «il primo che riesce conta»), i codici di uscita e l'esito dei
  goal nella programmazione logica (`:call`/`:redo`/`:exit`/`:fail` di `solve … trace`); la
  stessa risposta è riassunta nelle FAQ del Tutorial (`docs/tutorial/TUTORIAL.it.md` cap. 49,
  con versione inglese in `TUTORIAL.md`).
- `docs/PREFazione.it.md` — prefazione italiana del volume (aggiornata ai tre testi e al lettore
  principiante); `docs/PREFazione.md` resta la fonte inglese, allineata.
- `scripts/docs/build-pdf.mjs` — generazione del PDF del libro con il motore di stampa di
  Chrome/Edge (headless, puppeteer-core): formato e margini dalle regole `@page` di
  `libro.html`, numeri di pagina da footer template, segnalibri PDF dai titoli.

### Changed
- `scripts/docs/build-libro.mjs`, `scripts/docs/build-epub.cjs`: il libro italiano si costruisce
  dalle fonti italiane (`PREFazione.it.md`, `FONDAMENTA.it.md`, `MANUALE.it.md`,
  `docs/tutorial/TUTORIAL.it.md`); indice e sommario ricevono il gruppo "Fondamenta";
  quarta di copertina menziona la parte per principianti.
- `docs/MANUALE.it.md`, `docs/MANUALE.md`: "A chi è indirizzato" rimanda alle Fondamenta per
  chi non ha mai programmato.
- Artefatti di `docs/libro/` rigenerati: `libro.html`, `Il-libro-di-Triad.epub`,
  `Il-libro-di-Triad.mobi`, `libro.docx`, `Il-libro-di-triad.docx`, `Il-libro-di-triad.doc`
  (Word 97, generato con LibreOffice) e `Il-libro-di-triad.pdf` (273 pagine, formato
  152,4×228,6 mm, 295 segnalibri, numeri di pagina).

### Fixed
- `Il-libro-di-triad.pdf`: generato con il motore di stampa di Chrome invece di
  `ebook-convert` (calibre), il cui writer PDF (9.17) corrompe i glifi composti durante il
  subsetting dei font: tutte le lettere accentate (è, à, ù, …) e gli em-dash risultavano
  riquadri vuoti (tofu) in ogni viewer. Il bug affliggeva anche i PDF generati in precedenza.
- Indice del libro e documento Word: le voci di titolo con apostrofi comparivano con
  l'entità letterale `&#39;` (doppio escape `&amp;#39;` generato da `escapeHtml` su testi già
  entità di `marked`). `build-libro.mjs` decodifica ora le entità di base nei titoli prima
  del TOC (slug più leggibili); `build-docx.cjs` normalizza `&#39;` nell'input di html-to-docx,
  che non decodifica quell'entità numerica.
- Verifica PDF ↔ DOC (confronto automatico del testo estratto, entrambe le direzioni):
  il documento Word contiene tutto il contenuto del PDF. La verifica ha però scoperto e
  corretto due difetti del PDF, che perdeva contenuto rispetto alle fonti:
  - le righe di codice più lunghe della colonna venivano **tagliate** (`overflow-x` in
    stampa): il CSS di `build-libro.mjs`/`build-epub.cjs` usa ora `white-space: pre-wrap`;
  - i blocchi `<details>` (le soluzioni degli esercizi, 19 nel Manuale/Tutorial) erano
    **collassati e non stampati** da Chrome: `build-pdf.mjs` li apre tutti prima della stampa.
  Restano come differenze volute le intestazioni di tabella ripetute a fine pagina nel PDF
  (comportamento di stampa) e i puntini elenco aggiunti dal Word nella conversione in testo.

## 2026-11-01: folder reorganization

### Changed
- Repository tree tidied without touching the contractual paths (`SPEC*.md`, `BOOTSTRAP.md`,
  `conformance/`, `ai/`, `bin/`, `cli/`, `editors/`, `seed/`, `selfhost/`, `VERSION`, `install.sh`):
  - `probes/` → `tests/probes/` (probe programs next to `tests/security/`);
  - `tutorial/` → `docs/tutorial/` and `wiki/` → `docs/wiki/`: all long-form documentation now
    lives under `docs/`;
  - `SECURITY-REVIEW.md`, `SECURITY-BACKLOG-TRIAGE.md`, `TRIAGE-SEVERITY.md` → `docs/security/`
    (`SECURITY.md` stays at the root, GitHub convention);
  - `PULL_REQUEST.md` → `docs/worklog/PULL_REQUEST-current.md`; the previous draft is archived as
    `docs/worklog/PULL_REQUEST-reorg-struttura.md`;
  - legacy Jekyll scaffold (`_config.yml`, `index.md`, `_includes/`, `assets/`) →
    `tools/site-jekyll/` (the Pages site is deployed as the static `docs/` artifact);
  - `served.svg` / `served_raw.svg` (drafts of the typing-preview animation) → `docs/assets/img/`;
    stray `server.err` log removed.
- References updated in `.github/workflows/ci.yml`, `install.sh`, `scripts/docs/build-libro.mjs`,
  `scripts/docs/build-epub.cjs`, `tests/security/run.sh`, `README.md`, `docs/MANUALE*.md`,
  `.codacy.yml`, `.stylelintignore`; relative links in `docs/wiki/` rewritten and verified
  (90/90 resolve).

## 0.8.0-beta.7 — 2026-10-31: security hardening, CI integrity & repository cleanup

### Added
- Repository structure reorganization released across three passes: probes moved
  from the root to `probes/`; long-form docs gathered in `docs/` and versioned
  release notes in `docs/releases/`; webcmd Graphify plugin moved to
  `tools/webcmd-graphify/`; `scripts/` split by purpose (`scripts/docs/` build
  helpers, `scripts/seed-runner/` Windows seed wrappers, `scripts/experiments/`
  one-off dev scripts); tutorial translations consolidated in `tutorial/`
  (`docs/TUTORIAL-RU.md` → `tutorial/TUTORIAL.ru.md`). CI, install.sh, build
  scripts, workflows and README references updated accordingly.
- Repaired tooling regressions found during the moves: `download_chart.py`
  indentation/typos plus asset download counts and default repo; `build-epub.cjs`
  and `build-libro.mjs` `continue` typo and variable mismatches.
- `tests/security/` — repeatable security verification suite (`run.sh`, 5 checks):
  Windows command detection cannot execute a project-controlled `where.exe`;
  Python parser isolation against `json.py`/`sitecustomize.py`/`PYTHONPATH`/user
  site-packages shadowing; every workflow action pinned to a full commit SHA;
  relocated build scripts and tutorial links resolve from their new directories;
  download-chart script runs from its new location and writes valid SVG output.
- `.github/workflows/codeql.yml` + `.github/codeql-config.yml` — CodeQL scanning
  for C#, JavaScript/TypeScript and Python; the C# job builds on
  `windows-2022` with `autobuild` so the WinForms CLI analyzer resolves call
  targets and expression types (fixes "Incomplete database" scanner findings).
- `cli/windows-gui/TriadDesktop.csproj` — SDK-style project file mirroring the
  assembly set of `build.ps1`, enabling autobuild/manual-build scans.
- `wiki/` — 10-page English wiki generated from the project documentation
  (Home, Getting Started, Language Guide, Syntax Reference, Error Handling &
  Advanced Features, Logic Programming, Code-as-Data & Macros, Project Status,
  Repository Architecture, Contributing Guide).
- Triad-generated website page: `tools/site-gen/generate_site_core.td` emits
  `docs/pages/generated.html` using only Triad-Core constructs (verified against
  the reference interpreter); online playground bundle restored via
  `scripts/docs/sync-playground.cjs`.
- Site webpages rewritten in Triad: `docs/web/*.td` (index, examples, getting-started,
  tour, api-reference, community, contributing, download, repl) generate the whole
  GitHub Pages site with `tools/site-gen/build-site.td`.
- `.github/config.yml` — versioned CodeRabbit configuration (chill profile,
  path filters excluding generated artifacts).
- Release notes: `docs/releases/RELEASE_NOTES_v0.8.0-beta.7.md`.

### Security
- **HIGH** — `%SystemRoot%` is no longer trusted by default in
  `.github/ecc/scripts/lib/utils.js`: the system directory is validated as an
  absolute `<drive>:\windows` path after normalization; UNC, relative, traversal
  or attacker-controlled values are rejected with a fixed fallback to
  `C:\WINDOWS\System32`, so the invoked `where.exe` always lives in a trusted
  system directory.
- **MEDIUM** — `git` is resolved to a trusted absolute executable before
  `subprocess.run` in `scripts/docs/download_chart.py`: hardcoded canonical paths
  first, then `shutil.which` results accepted only if absolute, a real file after
  `realpath`, executable and outside the repository; argument-list invocation,
  `shell=False`, repository cwd and the unavailable-git fallback preserved.
- ReDoS hardening: `_is_safe_tag_line()` linear-time pre-validation of tag lines
  in `download_chart.py` before regex processing, with worst-case regression tests.
- Incomplete multi-character sanitization fixed in
  `.github/skills/continuous-learning-v2/scripts/instinct-cli.py`: escape
  substitutions iterate to a fixpoint so nested fragments (`<scr<script>ipt>`)
  cannot reconstruct a `<script>` tag.
- All GitHub Actions pinned to full immutable commit SHAs (checkout@v7,
  setup-node@v7, configure-pages@v6, upload-pages-artifact@v5, deploy-pages@v5,
  codeql-action@v3, setup-dotnet@v4), verified against the GitHub API.

### Changed
- Root and folders cleanup (third pass, see below) completed and released.
- All Linux CI jobs pinned to `ubuntu-24.04` ahead of the `ubuntu-latest`
  migration to Ubuntu 26 (actions/runner-images#14748).
- `download-chart.yml`: removed deprecated `setup-python@v5` (stdlib-only
  script) and stale Node-20 warnings; checkout bumped to v7.
- `install.sh`: usage extraction window fixed after the Termux section shifted
  the header; final self-check now probes `$ROOT/probes/test_simple.td`.
- README: Termux (Android) section documenting the Node.js fallback path.

### Fixed
- `obsidian-triad/github-wiki/` removed from the index: an empty leftover
  gitlink broke CI submodule sync ("No url found for submodule path … in
  .gitmodules"), failing every workflow at `actions/checkout`.
- `scripts/docs/build-libro.mjs` crashed writing to a non-existent
  `docs/libro/`; now creates the output directory.
- Removed two empty files accidentally committed in the root (`Developer`,
  `install-triad-ext.bat`).

## 0.8.0-beta.6 — 2026-10-30: repository structure reorganization & tooling fixes

- Probe `.td` moved from the root to `probes/` (`test_simple.td`, `test_let.td`,
  `test_get.td`, `test_td.txt`); paths updated in `.github/workflows/ci.yml`
  and `install.sh`.
- Long-form documentation gathered in `docs/`: `MANUALE.md`, `PREFazione.md`,
  `TUTORIAL-RU.md`; versioned release notes in `docs/releases/`. Paths updated
  in the build scripts.
- webcmd Graphify plugin moved from `.webcmd/` to `tools/webcmd-graphify/`.
- Removed two empty files accidentally committed in the root: `Developer` and
  `install-triad-ext.bat` (no active reference in the repository).
- `scripts/` split by purpose: build helpers in `scripts/docs/`
  (`build-libro.mjs`, `build-epub.cjs`, `build-docx.cjs`, `frontespizio.mjs`,
  `download_chart.py`), Windows seed wrappers in `scripts/seed-runner/`,
  one-off dev experiments in `scripts/experiments/`. Internal paths of the
  build scripts and the `download-chart.yml` workflow updated accordingly.
- Tutorial translations consolidated in `tutorial/` (moved
  `docs/TUTORIAL-RU.md` → `tutorial/TUTORIAL.ru.md`, alongside the existing
  `TUTORIAL.md`, `TUTORIAL.it.md`, `TUTORIAL.zh.md`); links in README, manual,
  site pages and build scripts updated.
- PR descriptions moved out of the root into a dedicated worklog folder:
  `PULL_REQUEST.md` → `docs/worklog/PULL_REQUEST-current.md` (active draft),
  `docs/PULL_REQUEST.md` → `docs/worklog/PULL_REQUEST-pr30.md` (archived).
- Push helper relocated to the tools area: `scripts/git-push-with-token.ps1`
  → `tools/git-push-with-token.ps1`.
- `obsidian-triad/github-wiki/` removed from the index: it was an empty
  leftover directory that broke CI submodule sync ("No url found for submodule
  path 'obsidian-triad/github-wiki' in .gitmodules").
- CI runner stability: all Linux jobs pinned from `ubuntu-latest` to the
  explicit image `ubuntu-24.04` (`ci.yml`, `download-chart.yml`, `pages.yml`,
  `static.yml`) ahead of the `ubuntu-latest` → Ubuntu 26 migration scheduled
  for 2026-10-19 (actions/runner-images#14748), keeping toolchain-dependent
  steps stable (`xxd` install, ELF seed execution, Node conformance runner).
  `node-version: '20'` kept as-is: setup-node downloads the runtime itself,
  so it is unaffected by the runner-image change.
- `README.md` "Project Structure": stale `docs/TUTORIAL-RU.md` entry replaced
  with the `tutorial/` translations line; added `tests/security/`,
  `docs/worklog/`, `scripts/*` subfolders; documented contract paths unchanged
  (`bin/`, `seed/<platform>/`, `conformance/`, `selfhost/`, `examples/`,
  `probes/`, `cli/`, `editors/`, `VERSION`, `LICENSE`, `install.sh`).

- `seed/dev/triad_core.cjs`: added direct execution support for `.td`/`.triad` files via Node module system (`require.extensions`), enabling `node --require ./seed/dev/triad_core.cjs nome-file.td [arg...]`; program arguments are normalized into `ARGS`. The simpler launcher form `triad nomefile.td` / `triad nome-file.triad` remains supported.

## 0.8.0-beta.3 — 2026-10-29
**Triad 2.0 – Beta 3.** Pre-release of the Triad 2.0 series: includes *all*
updates from v0.2.0 to today (also contained in v0.3.0, superseded).
### CLI (`cli/`)
- **`run` command**: `triad-cli run <file> [-- args]` runs a `.triad`/`.td` program
  with the seed in machine code; on Linux/macOS use the reference interpreter
  `seed/dev/triad_core.cjs` as long as the ELF seed remains E0 (forceable with `-n/--native`).
  Exit code propagated, file/parse errors handled with exit 1.
- **`ext`** commands for the VS Code extension:
  - `ext check`: valid `package.json`, tmLanguage grammar and language-configuration
    (all JSON checked); reports name, version, languages and extensions.
  - `ext package`: package the `.vsix` with global `vsce` or `npx --yes @vscode/vsce`;
    supports `-o/--out`.
- **Modularity**: new modules `cli/lib/commands/run.mjs` and `cli/lib/commands/ext.mjs`;
  `status` and updated help, README CLI extended with "Run" sections ed
  "VS Code Extension".
### Tooling editor
- VS Code `editors/vscode` extension (Triad v0.2.0, `triad` languages, extensions
  `.triad`/`.td`) checked and packaged by CLI (`ext check` / `ext package`).
### Compliance and standards
- New Core `gcd` case (Euclid, recursion and `%`); the Core suite has 37 cases.
- Golden versioned: `conformance/**/expected.out` and `expected.code` tracked;
  the runner accepts `expected.golden` as a backup.
- `conformance/run.mjs` uses the `seed/dev/triad_core.cjs` interpreter on Linux/macOS
  (seed ELF still E0) and fails with `golden missing` instead of comparing with
  stdout empty.
- Julia removed from repository (`triad.jl`, `syntax.jl`, `test/`,
  `bin/build_standalone.jl`); the CI uses only Node and the seed.
### Maintenance and dependencies
- Updated `esbuild` dependency to 0.28.1 (PR #21, dependabot).
- `*.vsix` added to `.gitignore` as a generated artifact.
- Added `LICENSE` MIT; seed binaries included in the repository
  (`seed/windows-x86_64/seed.exe`, `seed/linux-x86_64/seed`).
### Documentation
- Release Notes `RELEASE_NOTES_v0.8.0-beta.3.md`; PR description in `PULL_REQUEST.md`.
## 0.3.0 — 2026-10-29
### CLI (`cli/`)
- **`run` command**: `triad-cli run <file> [-- args]` runs a `.triad`/`.td` program
  with the seed in machine code; on Linux/macOS use the reference interpreter
  `seed/dev/triad_core.cjs` as long as the ELF seed remains E0 (forceable with `-n/--native`).
  Exit code propagated, file/parse errors handled with exit 1.
- **`ext`** commands for the VS Code extension:
  - `ext check`: valid `package.json`, tmLanguage grammar and language-configuration
    (all JSON checked); reports name, version, languages and extensions.
  - `ext package`: package the `.vsix` with global `vsce` or `npx --yes @vscode/vsce`;
    supports `-o/--out`.
- **Modularity**: new modules `cli/lib/commands/run.mjs` and `cli/lib/commands/ext.mjs`;
  `status` and updated help, README CLI extended with "Run" sections ed
  "VS Code Extension".
- **Maintenance**: `esbuild` dependency updated to 0.28.1 (PR #21); `*.vsix` added
  to `.gitignore` as the generated artifact.
### Documentation
- Added Pull Request description in `PULL_REQUEST.md`.
## 2026-10-26
- **Conformance**: new Core `gcd` case (Euclid, recursion and `%`); the Core suite has 37 cases.
- **Golden versioned**: `.gitignore` no longer excludes `conformance/**/expected.out` and
  `expected.code`; the runner accepts `expected.golden` as a backup.
- **Runner**: `conformance/run.mjs` uses the `seed/dev/triad_core.cjs` interpreter on Linux/macOS
  (the ELF seed is still E0) and fails with `golden missing` instead of comparing to one
  empty stdout; removed the golden `gcd` written in the runner code.
- **Julia removed**: `triad.jl`, `syntax.jl`, `test/` and `bin/build_standalone.jl` no longer do
  part of the repository; the CI uses only Node and the seed.
## 2026-10-22
- **Open source**: added `LICENSE` MIT; seed binaries included in the repository
  (`seed/windows-x86_64/seed.exe`, `seed/linux-x86_64/seed`) and lockfiles
  (`Manifest.toml`, `Cargo.lock`); Updated `.gitignore` and `.gitattributes`.
## 0.2.0 — 2026-10-20
- **Standard Triad v0.2.0**: `SPEC.md` becomes an independent regulatory document
  from implementation (status, regulations, compliance profiles and versioning in §16).
- **Conformance executable**: Added `conformance/` with 12 golden cases (stdout + exit code)
  and a development runner based on stage0; the suite is part of the standard.
- **AI benchmark** (development tool): `ai/` with system prompt, 5 Triad-Core tasks and
  `ai/verify.jl` to generate code with an LLM and verify it against goldens.
- **Seed Linux E0**: first static x86-64 ELF, syscall only (`write`/`exit`), which prints
  `Triad seed Linux OK`; dump `seed/linux-x86_64/seed.hex`, generator `seed/dev/gen_seed_linux.js`
  and CI Linux jobs.
- **Canonical extension**: `.triad`; `.td` remains supported as a historical alias.
- **Independence**: Bootstrap plan without guest languages in `BOOTSTRAP.md`.
- **Tooling editor**: syntax grammars for VS Code and Vim/Neovim (`editors/`) and
  preparing the Linguist entry for recognition on GitHub
  (`editors/linguist/`).
- **Seed M1**: first Triad executable in machine code (1024 byte x86-64 Windows PE,
  `seed/windows-x86_64/`): print `Triad seed OK`, exit 0, no compiler.
- **Seed M2**: Real I/O without runtime — reads the file from the first command line argument
  and writes the bytes to stdout in 4 KiB blocks; exit 0/1/2, path in quotes, PE from
  2560 bytes.
- **Triad-Core**: new profile standard [`SPEC-CORE.md`](SPEC-CORE.md) (subset
  regulatory for self-hosted bootstrap) and `conformance/core/` suite with 29 shared cases
  with Triad-Full.
- **Seed M3b1/M3b2a**: the seed in machine code **interprets** Triad-Core: `println` of
  integer expressions with `+ - *`, parentheses, unary `-`, comments (M3b1) and then variables
  globals with assignments and lookups by name (M3b2a). 8704 byte PE, no runtime; cases
  Core suite `integers` and `variables` checked byte by byte.
- **Seed M3b2b1**: the seed interprets **short form functions with parameters**: definition
  `f(x, y) = expr`, call, dynamic environments with shadowing/truncation, composition of
  functions; Core case `simple_functions` checked byte by byte. 8704 byte PE,code
  1998 bytes, no runtime.
- **Seed M3b2b2**: added **comparisons** (`== != < <= > >=` → `0/1`), **short ternary**
  `c ? a : b` (the unchosen branch is scanned without evaluating it) and then **recursion with
  base case** (`factorial`, `fib`); Core `recursion` case checked byte by byte.
  Code 2611 bytes.
- **Seed M3b2b3a**: **tagged** values (`Int = n<<1`, `Bool false = 1`, `Bool true = 3`):
  comparisons produce Bool and `println` prints `true`/`false`; arithmetic and comparisons
  they untag/re-tag. Core case `compares` checked byte by byte; code 2892 bytes.
- **Seed M3b2b3b**: added `%` (signed remainder), `^` (right-bound, precedence above
the unary) and `true`/`false` literals; Core case `operators` checked byte by byte e
  semantics compared to stage0 (`-2^2=-4`, `2*3^2=18`, `2^3^2=512`). Code 3112 bytes.
- **Seed M3b2b3c**: Added **`if`/`else`/`end`** blocks with branch selection, execution
  block recursion and depth scanning for `else`/`end` (nesting); Core case
  `if_else` checked byte by byte. Code 3706 bytes.
- **Seed M3b2b3d**: added **`while`/`end`** with condition reevaluated every round and
  depth scan that also counts nested `while`s; the assignment now **updates**
  the most recent variable (`env_assign`) instead of appending an entry per iteration. Case
  Core `while_loop` checked byte by byte. Code 4002 bytes.
- **Seed M3b2b3e**: 2-bit tag (`Int=n<<2`, `false=1`, `true=5`, closure=`ptr|2`) and
  **one-parameter lambda** `x -> expr`, with 128-byte records in a dedicated heap
  (256 KiB of `VirtualAlloc`), also callable from variable/passed as argument; case
  Core `lambda` checked byte by byte. Dynamic scoping (no room capture).
  Code 4415 bytes.
- **Seed M3b2b3q**: Checked and covered concatenated concatenation `a * b * c` with `length`; new Core case `multi_strings` (no code changes, hash unchanged).
- **Seed M3b2b3p**: symbols `:name` (string object with name, print without `:`) and new green Core case `symboli_base` (code 6866 bytes).
- **Seed M3b2b3o**: string concatenation with `*` (heap allocation and copying of the two buffers, preserving the parser cursor), new green Core `concat_strings` case. IAT area moved to RVA `0x2C00` for grown code (6680 bytes); `string()` remains to be done.
- **Seed M3b2b3n**: added `nothing` value (static object type 4, prints `nothing`); new green Core `nothing_base` case (code 6451 bytes). Concatenation `*` and `string()` attempted but postponed (unstable); the seed remains on strings base + `nothing`.
- **Seed M3b2b3m**: strings as heap objects (`[type=1][len][byte…]`, value `ptr|3`), parsing literals, printing via `WriteFile`, builtin `length`; IAT area moved to RVA `0x2A00` to make room for code; new green `base_strings` Core case (code 6269 bytes).`n- **Seed M3b2b3l**: added `begin … end` (executed with stop mask) and **CI GitHub Actions** (`.github/workflows/ci.yml`: Full/Core conformance on Ubuntu and Windows, seed cases on Windows, hash check); new green `begin_block` Core case (code 5891 bytes).`n- **Seed M3b2b3k**: **capture-by-value closures** of the last frame binding (parameter or local), re-added to the call above the marker; Core closure cases and green closures; scan_end also counts nested unction/let (code 5743 bytes).
- **Seed M3b2b3j**: **lexical frames** in calls (markers in the environment; local assignments without touching globals) and **let name = expr … end** with local binding; green Core scope case (code 5584 bytes).
- **Seed M3b2b3i**: body of block functions on **multiple instructions** (assignments and expressions) with value of the last expression; expressions like statement and lock value at the end of the source; new case Core unctions_green block (code 5303 byte).
- **Seed M3b2b3h**: added the unction block form f(x, …) <expression> end (body to an expression, end identified by scan_end); the case Core unctions passes byte by byte (code 5097 bytes).
- **Seed M3b2b3g**: added !, &&/|| (bitwise on Bool tags) and +=; the Core Rithmetic case passes byte by byte (code 4763 bytes).
- **Seed M3b2b3f (attempt, unstable)**: added capture fields to closing record; the
  binding to the call was found to be unreliable and has been removed. The seed remains at the state
  stable lambda (code 4570 bytes); the `closure` case only passes on stage0. Capture
  sent back to AST/bytecode or captured frames.
- **Seed dev tooling**: PE development generator in `seed/dev/gen_seed.js` with README;
  the dump remains the source, reproducibility is verified by the hash
  `C7915C02…0BF75FAC` and the generator is not used by the S0→S4 chain.
- First draft of the **Triad-Core** subset required by the seed in machine code.
## 0.1.0 — initial
- Kernel S-expression `legacy/triad_sexpr_v1.jl` (historical).