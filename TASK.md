# Task Triad 2.0

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


## Handoff — 2026-11-08 03:30: ternario con simbolo — divergenza `D23` del seed (1 e 2 della lista)

### Stato attuale e obiettivo della sessione

Obiettivo della sessione precedente: capire perché il seed risponde `seed: error` a un
programma Triad-Full (`struct Point` con campi `Float`, `area(n::Int)`/`area(n::Number)`).
Diagnosi: **non è un bug** — il seed implementa solo Triad-Core (`struct`, `::`, `Float`,
`Number` e il multiple dispatch non sono in `SPEC-CORE.md` §1–§4); l'output Full corrispondente
è congelato in `conformance/cases/dispatch/expected.out`.

Durante la costruzione dell'equivalente Core è emerso un **difetto vero del seed**: il
ternario con un **simbolo nel ramo *then*** viene rifiutato (exit 1). Decisione del
maintainer: eseguire in questa sessione i punti **(1)** e **(2)** (ticket + caso di
conformance + divergenza `D23` nel contratto) e rinviare **(3)** (fix del codice macchina) a
una sessione nuova.

### Cosa è stato fatto

1. **Difetto misurato**: `f(n) = n == 1 ? :intero : :numero` → il seed stampa `intero` e poi
   esce con 1 (`seed: error`); il riferimento JS (`seed/dev/triad_core.cjs`, autorità
   semantica) stampa `intero` / `numero` ed esce con 0. Causa: in `seed/dev/core.js` lo
   scanner del ternario (`pt_scan`/`pt_colon`) sceglie come separatore **qualunque** `:` a
   profondità zero → prende il `:` del simbolo. Sul ramo *true* il bug è mascherato (il ramo
   viene parsato da subito dopo `?`); sul ramo *false* il seed parsa `intero : :numero` →
   variabile inesistente → errore. Non conforme a `SPEC.md` §1 («a `:` **surrounded by
   spaces** is the ternary separator»).
2. **Ticket** `.scratch/seed-linux-nativo/issues/11-ternario-simbolo-seed.md` (aperto) con
   fatti, risposte Q1–Q4, piano di chiusura e cosa fare quando il fix entra; pointer in
   `.scratch/seed-linux-nativo/map.md` (sezione «Open (dopo la destinazione)»).
3. **Divergenza `D23 = noisy`** in `seed/dev/certified-subset.txt` + riga nella tabella delle
   divergenze di `seed/README.md` (e nella lista «fuori contratto»).
4. **Guardia statica `G-D23`** in `tools/selfhost-guard/rules.mjs` (helper
   `hasTopLevelSymbol`: simbolo a profondità zero nel ramo *then`), fixture
   `tools/selfhost-guard/fixtures/d23_ternario_simbolo.td`, voce nel self-test: nei sorgenti di
   S1 (che girano sul seed) il costrutto è **vietato**; la regola si spegne da sola quando
   `D23` sparisce dal contratto.
5. **Caso di conformance `ternario_simbolo`** (`conformance/core/cases/ternario_simbolo/`):
   `program.td` (ternario con simbolo nel ramo *then* + controllo sul ramo *else*),
   `expected.out` = `intero` / `numero` / `numero`, `expected.code` = `0`, `expected.golden`
   legacy. Golden generato con il **riferimento JS** (verificato byte-exatto sui 39 casi già
   congelati: 39/39 con `cmp` su stdout + exit code).
6. **`conformance/gate.sh` corretto**: la `KNOWN_GAP` accettava **un solo** nome
   (`grep -v -x -F "$KNOWN_GAP"`) → con due gap il gate sarebbe fallito. Ora: elenco di gap,
   filtro `grep -v -x -F -f`, motivo per gap stampato nel riepilogo. Il caso entra nella
   `KNOWN_GAP` (2° gap noto), **nessun golden riscritto per mascherarlo**.
7. **Documentazione allineata**: `AGENTS.md` (§2 tabella + regola operativa 3: 40 casi, gap
   noti plurali), `conformance/core/README.md` (tabella casi, conteggio, esecuzione),
   `conformance/README.md`, `conformance/run.sh` (commento), `cli/README.md`,
   `seed/README.md` (D23), `docs/libro/_dati_dal_codice.md` (§8), `STATUS.md`,
   `CHANGELOG.md`.

### Cosa manca

- **Il fix del codice macchina** (punto 3 del piano, sessione nuova): `seed/dev/core.js`,
  routine `pt_scan`/`pt_colon`. Ipotesi: ignorare un `:` seguito da un identificatore
  (inizio di simbolo); in alternativa esigere il `:` circondato da spazi (`SPEC.md` §1),
  badando attenzione alla coerenza con `SPEC-CORE.md` (dove il `:` è solo prefisso di
  simbolo). Il fix implica il **ciclo di rebuild dei dump** (`seed.hex` + PE/ELF + hash CI),
  oggi bloccato dal known issue anti-drift («2026-11-07 22:40 (ter)» in questo file): chiudere
  prima il ciclo N03/N04.
- **Alla chiusura del fix**: togliere `D23` dal contratto (la guardia `G-D23` si spegne da
  sola), togliere `ternario_simbolo` dalla `KNOWN_GAP` del gate → 39/40 verdi con un solo gap
  noto (`liste`), rigenerare i dump e gli hash CI, aggiornare i conteggi nella documentazione.
- **Conteggi obsoleti nel book/tutorial**: `docs/tutorial/TUTORIAL{,.it,.ja}.md` dicono ancora
  «39/39 casi Core» (più il mirror Obsidian in `obsidian-triad/github-wiki/`, submodule
  separato, out-of-band): passaggio di sincronizzazione da fare, non fatto in questa sessione.
- Il resto del ciclo di rebuild (N03/N04 → N23 → N24) resta invariato.

### File toccati

| File | Modifica |
|---|---|
| `.scratch/seed-linux-nativo/issues/11-ternario-simbolo-seed.md` | **nuovo**: ticket del difetto (aperto) |
| `.scratch/seed-linux-nativo/map.md` | sezione «Open (dopo la destinazione)» con il ticket 11 |
| `seed/dev/certified-subset.txt` | `D23 = noisy` |
| `seed/README.md` | riga D23 nella tabella delle divergenze + lista «fuori contratto» |
| `tools/selfhost-guard/rules.mjs` | helper `hasTopLevelSymbol` + regola `G-D23` |
| `tools/selfhost-guard/fixtures/d23_ternario_simbolo.td` | **nuovo**: fixture della regola |
| `tools/selfhost-guard/test.mjs` | caso `d23_ternario_simbolo.td → G-D23` |
| `conformance/core/cases/ternario_simbolo/{program.td,expected.out,expected.code,expected.golden}` | **nuovo**: caso di conformance (golden del riferimento JS) |
| `conformance/gate.sh` | KNOWN_GAP multi-gap (+ filtro corretto, + motivo per gap) |
| `conformance/core/README.md`, `conformance/README.md`, `conformance/run.sh`, `cli/README.md` | conteggi 39 → 40, casi noti, entry point correnti |
| `AGENTS.md` | §2 (38/40, due gap noti) + regola operativa 3 (gap noti plurali) |
| `STATUS.md`, `CHANGELOG.md`, `docs/libro/_dati_dal_codice.md` | stato e conteggi |
| `TASK.md` | questo handoff |

Nessun file di lessico/parser/valutazione è stato modificato: **i byte del seed non cambiano**
(niente rebuild dei dump in questa sessione).

### Decisioni prese

1. **Il difetto è del seed, non della specifica**: `SPEC.md` §1 distingue il `:` del
   simbolo dal separatore del ternario; il riferimento JS è conforme e byte-exatto sui 39
   casi Core → il golden del nuovo caso viene dal riferimento JS (autorità semantica).
2. **Il caso di conformance entra nella suite Core anche se il seed lo rifiuta**: è il
   precedente del gap `liste` (N03) — il golden dice la verità, il gate lo esclude in modo
   esplicito e rumoroso. Nessun golden è stato riscritto per mascherare il difetto.
3. **Il gap noto è dichiarato in due punti**: nel contratto del seed (`D23 = noisy`, da cui
   dipende la guardia `G-D23`) e nella `KNOWN_GAP` del gate (da cui dipende il conteggio
   «38/40 verdi»). Il test del guard («ogni divergenza del contratto è presidiata») impedisce
   di dimenticare la guardia.
4. **Il fix del codice macchina è rinviato**: tocca i dump e gli hash CI, e il ciclo di
   rebuild è bloccato dal known issue anti-drift → sessione separata (fix + rebuild + hash +
   rimozione di `D23`/`KNOWN_GAP` + conteggi).
5. **Nessun probe `bad_*` per il difetto**: quei probe esigono stdout vuoto, il seed emette
   invece `intero` prima di fallire → il caso di conformance è lo strumento adatto.

### Test di conformance eseguiti ed esito

| comando | esito |
|---|---|
| `sh conformance/run.sh` | **FAIL** (atteso): 38 PASS + 2 gap noti (`liste`, `ternario_simbolo`) su 40 |
| `sh conformance/gate.sh` | **PASS** (exit 0): 38/40 verdi, 2 gap noti esclusi rumorosamente |
| `sh verify.sh` | **PASS** (exit 0): conformance gate + 39/39 probe |
| `node tools/selfhost-guard/test.mjs` | **PASS**: 27 test, 0 falliti (nuova regola `G-D23` + fixture) |
| `node tools/selfhost-guard/guard.mjs` | **PASS**: 0 errori sul corpus (17 file, 11 avvisi preesistenti) |
| `node tools/selfhost-guard/differential.mjs` | **PASS**: 0 differenze seed↔JS sul corpus certificato |
| riferimento JS sui 39 casi Core (cmp stdout + exit) | **PASS**: 39/39 byte-esatti |

### Prossimi passi concordati e problemi aperti

1. **(sessione nuova)** fixare `pt_scan`/`pt_colon` in `seed/dev/core.js`; chiudere prima il
   ciclo N03/N04; rigenerare `seed.hex` + PE/ELF + hash CI; togliere `D23` e
   `ternario_simbolo` (guardia e gate si spengono da sole); riallineare i conteggi.
2. Sincronizzare i conteggi «39/39» del book/tutorial (4 lingue) e il mirror Obsidian
   (submodule, out-of-band).
3. Restano rossi i known issue già noti: il passo CI «Reproducible dump (anti-drift)» e il
   resto del ciclo di rebuild (N03/N04 → N23 → N24).

### Comando di ripresa

```
Ripresa sessione: leggi la sezione "Handoff — 2026-11-08 03:30" in TASK.md e continua da lì
```

## Handoff — 2026-11-08 02:40: contratto dei limiti del seed allineato all'arena N20

### Stato attuale e obiettivo della sessione

Obiettivo: **fixare il gate rotto** `sh seed/linux-x86_64/check_seed.sh ./seed/linux-x86_64/seed`
(FAIL: `0xF000: exit 0 (atteso 1)`) e riallineare gli artefatti/documenti che ne dipendono.
Sessione **breve e mirata**: nessuna modifica a lessico, parser, tipi o semantica del
linguaggio → nessun golden di conformance toccato.

### Cosa è stato fatto

1. **Diagnosi**: il fallimento non è un bug del seed ma un **contratto di test obsoleto**.
   La ri-proporzionamento dell'arena (N20, `9d22de3`) ha portato il buffer sorgente da 64 KiB
   a **1 MiB** (maschera di stop a `+0x100000`); il contratto macchina-leggibile
   (`seed/dev/certified-subset.txt`: `source.max_bytes = 1048576`) e il seed committato
   (CI-gated) sono coerenti fra loro, ma `check_seed.sh` verificava ancora l'envelope
   pre-N20 (`0xEFFF` ammesso, `0xF000` rifiutato). Le specifiche (`SPEC.md`,
   `SPEC-CORE.md`) **non** fissano un limite di dimensione della sorgente: la scelta
   dell'envelope è del progetto e il suo riferimento è il contratto del seed.
2. **`seed/linux-x86_64/check_seed.sh`** — casi 6-7 riscritti sull'envelope corrente:
   sorgente `0xFFFFF` (1 048 575 byte) **ammessa** (exit 0, stdout byte-esatto) e
   sorgente `0x100000` **rifiutata** (exit 1, stdout vuoto, diagnostica su stderr);
   intestazione aggiornata.
3. **`.github/workflows/ci.yml`** — il gate hash anti-tampering riportava gli hash dei dump
   **pre-N20** (passo CI rosso): allineato ai dump committati (ELF `971f61d5…`,
   PE `9f96c413…`).
4. **`seed/windows-x86_64/seed.exe` + `seed_decoded.exe`** — erano la decodifica del dump
   pre-N20, **non** quella del `seed.hex` committato (ADR 0001: devono essere la decodifica
   esatta): rigenerati dal dump canonico. La parità PE↔ELF sull'envelope è ripristinata
   (verificata con Wine: stessi exit code e stesso stdout sui casi `0xFFFFF` / `0x100000` /
   file assente / path vuoto / nessun argomento; il PE resta muto su stderr per contratto).
5. **Documentazione** allineata all'envelope N20: `seed/README.md`,
   `seed/linux-x86_64/README.md` (tabella dei comportamenti, exit code, limiti, numeri e
   hash), `seed/windows-x86_64/README.md` (memory map, numeri, hash), il mirror Obsidian
   in-repo (`obsidian-triad/wiki-content/Doc-seed-windows-README.md`) e
   `docs/libro/_dati_dal_codice.md` (§3 «Limiti strutturali del seed»).
   Il mirror gemello `obsidian-triad/github-wiki/Doc-seed-windows-README.md` sta nel
   **submodulo** del wiki (repo separato): va aggiornato lì, out-of-band.
   La diagnostica ELF per sorgente troppo grande resta `seed: read error` (etichetta
   `read_fail` condivisa col fallimento di lettura: limite noto del seed) → il README è
   stato allineato al comportamento reale invece del testo promesso.

### Cosa manca (fuori scope di questa sessione)

- **Il passo CI «Reproducible dump (anti-drift)» resta rosso**: il generatore a HEAD
  (`ceaf202`, WIP N03/N04) **non** rigenera i dump committati (verificato: il generatore a
  `9d22de3` li riproduce byte per byte, quello a HEAD no). È il known issue del ciclo di
  rebuild: chiudere il ciclo N03/N04 (chiamata come statement) **prima** di rigenerare
  PE/ELF + hash, altrimenti si ripubblicano dump non conformi.
- Il resto del ciclo di rebuild (N03/N04 → N23 → N24) è invariato: vedi l'handoff
  «2026-11-07 22:40 (ter)».

### File toccati

| File | Modifica |
|---|---|
| `seed/linux-x86_64/check_seed.sh` | casi 6-7 + intestazione sull'envelope N20 (1 MiB) |
| `.github/workflows/ci.yml` | gate hash: hash dei dump committati (ELF/PE) |
| `seed/windows-x86_64/seed.exe`, `seed_decoded.exe` | rigenerati dal `seed.hex` committato (decodifica esatta, ADR 0001) |
| `seed/linux-x86_64/README.md`, `seed/windows-x86_64/README.md`, `seed/README.md` | limiti, memory map, numeri e hash aggiornati |
| `obsidian-triad/wiki-content/Doc-seed-windows-README.md` | mirror del README PE aggiornato (il gemello nel submodulo `github-wiki` resta da aggiornare nel repo del wiki) |
| `docs/libro/_dati_dal_codice.md` | §3 «Limiti strutturali del seed»: valori N20 e citazioni `seed/dev/core.js` |
| `seed/dev/backend_elf.js` | solo commento: la soglia è `0x100000`, non `0xF000` |
| `CHANGELOG.md`, `STATUS.md` | voce di correzione + stato corrente |
| `TASK.md` | questo handoff |

Nessun golden (`conformance/`, `tests/probes/`) è stato toccato; nessun file di
lessico/parser/valutazione è stato modificato.

### Decisioni prese

1. **Il contratto di test si adatta al seed, non il viceversa**: l'envelope N20 è
   deliberato (N20, `9d22de3`, contratto `certified-subset.txt`), le specifiche non fissano
   limiti di dimensione della sorgente → il gate era il relitto obsoleto.
2. **Nessun cambio ai byte del seed**: la diagnostica dedicata «file too large» implicherebbe
   una nuova etichetta di uscita (PE + ELF) e dunque un nuovo hash CI + diff tracciata
   (ADR 0001) per un vantaggio solo cosmetico: si è preferito allineare la documentazione
   al comportamento reale (`seed: read error`).
3. **Riparazione degli artefatti PE**: rigenerare `seed.exe`/`seed_decoded.exe` dal dump
   canonico è un atto di riallineamento (non un cambio semantico): il gate hash CI resta
   sulla `.hex` e non cambia.

### Test di conformance eseguiti ed esito

- `sh seed/linux-x86_64/check_seed.sh ./seed/linux-x86_64/seed` → **OK (7 casi)** (prima:
  `FAIL: 0xF000: exit 0 (atteso 1)`).
- `sh verify.sh` → **OK**: conformance 38/39 (unico FAIL il gap noto `liste`, escluso da
  `conformance/gate.sh`), probe 39/39.
- `node tools/selfhost-guard/guard.mjs` → OK (17 file, 0 errori, 11 avvisi);
  `node tools/selfhost-guard/test.mjs` → OK (26 test, 0 falliti);
  `node tools/selfhost-guard/differential.mjs` → OK (6 file, 0 differenze).
- `node tools/site-gen/build.mjs --check` → OK (13 file coincidono con il generato).
- PE↔ELF (Wine): `0xFFFFF` → `42` exit 0 su entrambi; `0x100000` → exit 1 su entrambi;
  file assente → exit 1; path vuoto/nessun argomento → exit 2 (PE muto, ELF con
  diagnostica).

### Prossimi passi concordati e problemi aperti

1. **Ciclo di rebuild N03/N04** (prioritario): chiamata come statement → poi rigenerare
   PE/ELF (`node seed/dev/gen_seed.js all`), aggiornare gli hash in `.github/workflows/ci.yml`
   e i documenti (`seed/README.md`, `seed/dev/README.md`, i due README dei seed, ADR 0001:
   diff tracciato) → chiude il passo anti-drift.
2. **N23**: `conformance/gate.sh` → `KNOWN_GAP` vuoto (il caso `liste` chiude con la
   chiamata-statement).
3. **N24**: allineare `BOOTSTRAP.md` §10, «Current status» di `TASK.md`, `STATUS.md`,
   `CHANGELOG.md` (affermazioni ottimistiche su `elseif` e liste «complete»).
4. N21/N06 rinviati (primitivi §8, stringhe).

### Comando di ripresa

```sh
cd /home/votlazam/Documenti/progetti/triad2.0 && git status --short && sh seed/linux-x86_64/check_seed.sh ./seed/linux-x86_64/seed && sh verify.sh && node seed/dev/gen_seed.js all && git diff --stat
```

```
Ripresa sessione: leggi la sezione "Handoff — 2026-11-08 02:40: contratto dei limiti del seed allineato all'arena N20" in TASK.md e continua da lì
```

## Handoff — 2026-11-07 22:40 (ter): N03/N04 nel seed — indicizzazione `xs[i]` (WIP, **non committato**)

### Stato attuale e obiettivo della sessione

Ripresa dall'handoff «2026-11-08 (bis)»: obiettivo = **ciclo di rebuild del seed**
(N20 già committato in `9d22de3`; N03, N04 in lavorazione; N21/N06 rinviati) e quindi
**N23** (gate 39/39) e **N24** (allineamento documenti).

Il working tree contiene **un solo file modificato**: `seed/dev/core.js` (+134 righe, WIP
**non committato**). I dump committati (PE/ELF) **non** sono stati rigenerati → il check
anti-drift della CI (`gen_seed.js` + `cmp`) **fallisce** finché il ciclo non è chiuso.
Sugli artefatti **committati** `sh verify.sh` resta verde (conformance 38/39 con il gap
noto `liste`, probe 39/39).

### Cosa è stato fatto

1. **Diagnosi del WIP lasciato dalla sessione precedente** (il diff non committato conteneva
   `parse_postfix`/`index_apply`): il generatore non compilava (`movRcxRax` non definito) e,
   una volta completato, produceva codice errato. Bug trovati e corretti:
   - `cmpEdxImm32` usava l'opcode `0x83` (forma imm8) **con** un immediato a 32 bit: 4 byte
     in più nel flusso → **segfault**;
   - **convenzione di chiamata**: dentro una routine gli operandi spinti dal chiamante
     stanno *sotto* l'indirizzo di ritorno (`[rsp+8]`, `[rsp+16]`, …): il WIP assumeva
     `[rsp]` → leggeva l'indirizzo di ritorno come se fosse il valore;
   - **etichetta dei valori**: `and $3` *prima* dello shift distruggeva `n<<2` (n diventava
     0) → l'indice risultava sempre fuori range; ora il tag si controlla senza distruggere
     il valore (`test dl,3`, opcode `F6 C2 ib` — non `84 D2`, che è `test dl,dl`) e poi si
     applica `sar rdx,2`;
   - `mov r10,rax` era codificato con i bit REX sbagliati (`4C 89 C2` = `mov rdx,r8`).
2. **N03 — indicizzazione `xs[i]` (1-based)**: `parse_postfix` (`primary { "[" expr "]" }`),
   `index_apply` (lettura) e `index_store` (scrittura `xs[i] = v`), con i controlli di
   `SPEC-CORE.md` §5/§7/§9 (indice `Int`, `1 ≤ n ≤ length`, tipo lista, errore di esecuzione
   con exit 1 fuori range).
3. **N04 — `-=` e `*=`**: `st_sub_check` / `st_mul_check` (simmetriche a `st_add_check`),
   con wrap-around a 64 bit come `+=`.
4. Helper di codegen aggiunti: `movRcxRax`, `movR10Rax`, `movR10MemRax`, `movR9MemRax`,
   `movR11MemRax`, `cmpR10Imm32`, `cmpR11Imm32`, `movMemRaxR10`, `movRaxMemRsp8/16`,
   `movR10MemRsp8`, `movR11MemRsp16/24`, `addRspImm16`, `testDlImm`.

### Scoperta cruciale (blocca N23)

Il caso `liste` **non** si chiude solo con l'indicizzazione: usa `push!(xs, 4)` come
**statement**. Il seed non supporta le chiamate come statement: in `stmt_assign` un nome
seguito da `(` finisce in `st_func` (definizione di funzione) e, senza `=`, il seed va in
`fail` (exit 1). Servono quindi **due** capability: (a) `xs[i]`, (b) **chiamata come
statement**.

### Test di conformance eseguiti ed esito

- `node seed/dev/gen_seed.js linux /tmp/seed_test.hex` → compila ✓ (ELF 9245 byte in `/tmp`).
- `/tmp/seed_test` su programma di prova: `xs[1]` → `1` ✓, `xs[3]` → `3` ✓,
  `length(xs)` → `3` ✓ (stessi valori del riferimento JS `seed/dev/triad_core.cjs`);
  `push!(xs, 4)` → `seed: error` (exit 1) ✗ → è la chiamata-statement mancante.
- `sh verify.sh` (artefatti **committati**) → **OK**: conformance 38/39 (unico FAIL `liste`,
  gap noto N03), probe 39/39.
- Nessun golden riscritto; nessun caso di conformance aggiunto.

### Cosa manca (ordine consigliato)

1. **Chiamata come statement** nel seed: in `st_func`, dopo la lista parametri, se il
   carattere successivo non è `=` → è una chiamata → ri-parsare lo statement come
   espressione (riposizionare `rsi` all'inizio dello statement, `parse_expr`,
   `blockStoreRax`, `popRsi`). Attenzione: un argomento di chiamata può **non** essere un
   identificatore (`f(g(1))`): la lista parametri va controllata *prima* (primo carattere
   non alfabetico → è una chiamata), altrimenti `parse_ident` va in `fail`. Poi N03 chiude
   il caso `liste` → N23.
2. **Rigenerare i dump** PE + ELF (`node seed/dev/gen_seed.js all`) e aggiornare gli hash in
   `.github/workflows/ci.yml`, `seed/README.md`, `seed/dev/README.md`,
   `seed/windows-x86_64/README.md`, `seed/linux-x86_64/README.md` (ADR 0001: diff tracciato).
3. **Contratto e guardie**: togliere `D13` da `seed/dev/certified-subset.txt` (l'indicizzazione
   esiste) → la regola `G-D13` in `tools/selfhost-guard/rules.mjs` si spegne da sola, ma vanno
   rimossi il fixture `tools/selfhost-guard/fixtures/d13_indicizzazione.td` e il caso in
   `tools/selfhost-guard/test.mjs` (il test «il contratto spegne la regola» usa D13: va
   spostato su un'altra divergenza, es. D14). Se `xs[i] += v` resta non supportato → **nuova
   divergenza D23 (noisy)** con la regola corrispondente (AST `indexassign` con op ≠ `=`).
4. **Probe**: `tests/probes/bad_lista_indice.td` (che registra oggi l'assenza
   dell'indicizzazione) va ribaltato in `ok_*` con i golden sidecar; aggiungere un probe per
   l'errore fuori range (exit 1) e per `xs[i] = v`; aggiornare la matrice dei limiti in
   `tests/probes/README.md`.
5. **N23**: `conformance/gate.sh` → `KNOWN_GAP` vuoto e correggere il commento (dice che
   `length(xs)` manca: **funziona già**); `conformance/README.md` (righe 47 e 55).
6. **N24**: `BOOTSTRAP.md` §10, `STATUS.md`, «Current status» di questo file, `CHANGELOG.md`
   — togliere le affermazioni ottimistiche su `elseif` e liste «complete».
7. **N21/N06** (rinviati): §8 (`readfile`, `strlen`, `strbyte`, `strsub`) e stringhe
   (escape, `==`, `+=`).

### File toccati

| File | Modifica |
|---|---|
| `seed/dev/core.js` | N03 (postfix: lettura e scrittura `xs[i]`), N04 (`-=`, `*=`), helper di codegen, correzione di `cmpEdxImm32` (WIP **non committato**) |
| `TASK.md` | questo handoff |

### Decisioni prese

1. **Convenzione di chiamata**: gli operandi passati sullo stack stanno sotto l'indirizzo di
   ritorno → letture con `mov r??,[rsp+8+N]` (`movRaxMemRsp8`, `movR11MemRsp16`, …).
2. **Tag dei valori**: si controlla senza distruggere il valore (`test dl,3` + `sar`), non
   con `and $3` + `sar`.
3. **Nessun nuovo caso in `conformance/core/cases/`**: il conteggio «39» è cablato in ~15
   documenti (guide incluse, più versioni linguistiche); la copertura dell'indicizzazione
   resta il caso `liste` già presente, e le capability nuove (scrittura, fuori range) vanno
   nei **probe** (`tests/probes/`), che è il luogo previsto per i limiti del runtime.
   Da rivalutare in una sessione dedicata se si preferisce un 40° caso.

### Problemi aperti / noti

- Il seed rigenerato **non** è ancora conforme: senza la chiamata-statement il caso `liste`
  resta FAIL → il gate resta 38/39.
- Il WIP non committato rende **rotto il check anti-drift** della CI (dump rigenerato ≠ dump
  committato): chiudere il ciclo (punto 1–2) prima di committare.
- `xs[i] += v` (assegnazione composta a indice) non è previsto: va dichiarato come
  divergenza (D23) o implementato.

### Comando di ripresa

```sh
cd /home/votlazam/Documenti/progetti/triad2.0 && git status --short && node seed/dev/gen_seed.js linux /tmp/seed_test.hex && xxd -r -p /tmp/seed_test.hex /tmp/seed_test && chmod +x /tmp/seed_test && printf 'xs = [1, 2, 3]\nprintln(xs[1])\n' > /tmp/t.td && /tmp/seed_test /tmp/t.td
```

```
Ripresa sessione: leggi la sezione "Handoff — 2026-11-07 22:40 (ter)" in TASK.md e continua da lì
```

## Handoff — 2026-11-08 (bis): budget di sessione, tetto R2.5M + handoff entro R3.0M

Sessione breve, **solo documentazione** (nessuna modifica a lessico, parser, tipi, valutazione
o I/O → regola operativa 3 non attivata, nessun golden toccato).

**Cosa è stato fatto** — `AGENTS.md`, regola operativa 8 riscritta:

- il consumo di token di una sessione **non deve mai superare R2.5M** (tetto rigido, non soglia
  di avviso: prima valeva R2.7M con «2.5M da considerare già raggiunta»);
- al raggiungimento (o all'avvicinarsi) di R2.5M l'AI **si ferma immediatamente**;
- il **riepilogo di handoff deve essere completato e consegnato entro R3.0M**: superare R3.0M
  senza handoff scritto in `TASK.md` è una violazione della regola, al pari di superare R2.5M;
- aggiunto l'**ordine di arresto** in 4 passi: stop → chiusura coerente del passo in corso →
  scrittura dell'handoff in `TASK.md` → risposta finale con il comando di ripresa.

**Cosa manca** — invariato rispetto all'handoff precedente: ciclo di rebuild del seed
(N20 + N21 + N03 + N04 + N06), poi N23 (gate 39/39) e N24 (allineamento documenti);
decisioni normative pending: N02 (newline), N08 (scope dei nomi), D21 (`while` non-`Bool`);
ticket M6 aperti: 02–11.

**File toccati** — `AGENTS.md` (regola 8), `TASK.md` (questa sezione).

**Test di conformance** — non applicabili (nessuna modifica di linguaggio/runtime): PASS non
applicabile.

**Comando di ripresa**

```sh
cd /home/votlazam/Documenti/progetti/triad2.0 && git status --short && node tools/selfhost-guard/guard.mjs && node tools/selfhost-guard/test.mjs && node tools/selfhost-guard/differential.mjs && sed -n '1,40p' TASK.md
```

```
Ripresa sessione: leggi la sezione "Handoff — 2026-11-08 (bis): budget di sessione, tetto R2.5M + handoff entro R3.0M" in TASK.md e continua da lì
```

## Handoff — 2026-11-08 (ticket 12 risolto: guardie statiche + gate differenziale)

### Stato attuale e obiettivo della sessione

Sessione dedicata alla **decisione [12 — Guardie statiche per la sorgente di S1]**
(skill `grilling`) della mappa self-hosting M6: *quali* regole presidiano le divergenze
del seed, *dove* stanno, *come* falliscono, e quale è il criterio di «non presidabile».
La sessione non è solo decisionale: la decisione è **implementata e verificata** (guardie,
contratto del seed, gate differenziale, self-test, CI).

Punto di partenza: `HEAD` = `889282f` (dopo la release `v0.8.0-beta.9`), working tree
pulito. Il ticket 01 (fork architetturale) era risolto; il ticket 12 era l'ultimo
prerequisito della slice **N22**.

### Cosa è stato fatto

1. **Ticket [12 — Guardie statiche per la sorgente di S1](.scratch/self-hosting-m6/issues/12-guardie-statiche-sorgente-s1.md)
   → `Status: resolved`** (file modificato): le quattro domande (Q1–Q4) sono risposte con
   **misure**, non deduzioni, e la risposta è implementata.
2. **Misure seed↔JS** (seed ELF nativo vs riferimento JS, programmi in `/tmp`): D1 (scope
   dinamico: 7 vs 100), D2 (cattura per valore: 1 vs 2), D3 (escape), D4 (`==` fra stringhe),
   D15 (`string(true)` → `1` vs `true`), D19 (newline: 3 vs errore di parse), D20 (nome
   creato in `if`/`while`: 5 vs «undefined variable»), D21 (`while` non-Bool: salta vs errore),
   D9 (chiamata in posizione finale), D18. **Correzioni alle misure precedenti** (ticket 01):
   - **D9**: `println` **è** ammesso in posizione finale (solo gli altri builtin e le
     funzioni utente no);
   - **D18**: il seed **risolve** i riferimenti in avanti *fra funzioni*; rifiuta solo la
     chiamata **a livello di file** che precede la definizione;
   - **D20**: il problema è dei **corpi di blocco in generale** (`if`/`while` non creano un
     ambiente; `let`/`begin` sì) e ha **due** casi: il nome *nuovo* è una divergenza vera fra
     i runtime, il nome *già legato* è identico nei due runtime (resta una decisione
     normativa pending, famiglia N08);
   - **D22**: le keyword cieche contano **solo dentro un corpo di blocco**; il caso peggiore
     è un identificatore che **inizia** con una keyword.
3. **Contratto del seed** — `seed/dev/certified-subset.txt` (fatti macchina-leggibili:
   envelope, primitivi §8 disponibili, elenco delle divergenze con la classe `silent`/`noisy`)
   + `seed/dev/certified-corpus.txt` (i programmi che il seed deve eseguire) + la sezione
   «Contratto del seed» in `seed/README.md` (la versione leggibile, con la tabella D1–D22).
4. **Il controllore** — `tools/selfhost-guard/`: `guard.mjs` (CLI), `rules.mjs` (una regola
   per divergenza: `G-D01`…`G-D22`, più le regole d'envelope `G-E01`–`G-E03`),
   `analysis.mjs` (albero degli ambienti sull'AST), `scan.mjs` (scanner grezzo: escape,
   keyword cieche, fine riga, corpi dei blocchi), `contract.mjs`, `differential.mjs`
   (gate seed↔JS), `test.mjs` (self-test), `fixtures/` (un fixture per regola + `pulito.td`),
   `README.md`. Il guard **riusa l'AST del riferimento JS** (`seed/dev/triad_core.cjs`): nessun
   secondo parser.
5. **Gate differenziale** — `differential.mjs`: per ogni programma del corpus certificato,
   seed e riferimento JS devono dare lo **stesso stdout byte per byte** e lo **stesso exit
   code**. Copre il corpus certificato completo (front-end di S1, smoke, i quattro generatori
   attivi del sito): **0 differenze**.
6. **CI** (`.github/workflows/ci.yml`, job `conformance-core`): tre passi nuovi — guardie
   statiche, self-test delle guardie, gate differenziale.
7. **Documenti**: `GLOSSARY.md` (+ *Corpus certificato*, *Contratto del seed*, *Gate
   differenziale*), `TASK.md` (N22 chiusa, ordine aggiornato, questo handoff),
   `.scratch/self-hosting-m6/map.md` (decisione [12] in «Decisions so far»).

### Cosa manca

- **Ciclo di rebuild del seed** (N20 + N21 + N03 + N04 + N06): ri-proporzionamento dell'arena
  (buffer sorgente 1 MiB, heap 8 MiB), primitivi §8 (`readfile`, `strlen`, `strbyte`,
  `strsub`), `xs[i]` 1-based (sblocca il caso `liste`), `-=`/`*=`, escape/`==`/`+=` su
  stringhe — **un solo ciclo** PE/ELF + hash CI + diff tracciato (ADR 0001).
- **N23**: gate a 39/39 (`KNOWN_GAP` vuoto in `conformance/gate.sh`) e correzione del
  commento di `gate.sh` su `length(xs)` (funziona già).
- **N24**: allineare `BOOTSTRAP.md` §10, «Current status» di `TASK.md` e `STATUS.md` alla
  ricognizione misurata (restano ottimistici).
- **Decisioni normative pending**: **N02** (newline: quando continua l'espressione — la
  regola `G-D19` è già scritta sul minimo comune delle due letture), **N08** (scope: lessicale
  vs dinamico; include il caso D20 «nome già legato»).
- **Mappa M6**: ticket `02` (architettura di S1), `03` (GC/memoria), `04`–`11` ancora aperti.
  Il prossimo ticket per numero, dopo il 12 risolto, è **02**.
- **Fuori dal bootstrap**: GUI Windows, traduzione EN del libro, `Q01–Q06`.

### File toccati in questa sessione

| File | Modifica |
|---|---|
| `.scratch/self-hosting-m6/issues/12-guardie-statiche-sorgente-s1.md` | `Status: open` → `resolved`; sezione «Answer» con Q1–Q4, tabella delle regole, misure, limiti noti |
| `.scratch/self-hosting-m6/map.md` | decisione [12] in «Decisions so far» |
| `seed/dev/certified-subset.txt` | **nuovo**: contratto del seed (envelope, §8 disponibili, divergenze e classe) |
| `seed/dev/certified-corpus.txt` | **nuovo**: corpus certificato (S1 + generatori del sito) |
| `seed/README.md` | nuova sezione «Contratto del seed» (tabella D1–D22, fuori contratto) |
| `tools/selfhost-guard/guard.mjs` | **nuovo**: CLI del controllore |
| `tools/selfhost-guard/rules.mjs` | **nuovo**: le regole (una per divergenza + envelope) |
| `tools/selfhost-guard/analysis.mjs` | **nuovo**: analisi degli ambienti sull'AST del riferimento JS |
| `tools/selfhost-guard/scan.mjs` | **nuovo**: scanner grezzo (escape, keyword cieche, corpi dei blocchi) |
| `tools/selfhost-guard/contract.mjs` | **nuovo**: lettore del contratto |
| `tools/selfhost-guard/differential.mjs` | **nuovo**: gate differenziale seed↔JS |
| `tools/selfhost-guard/test.mjs` | **nuovo**: self-test (un fixture per regola) |
| `tools/selfhost-guard/fixtures/*.td` | **nuovi**: 24 fixture (uno per regola + `pulito.td`) |
| `tools/selfhost-guard/README.md` | **nuovo**: contratto del controllore |
| `.github/workflows/ci.yml` | job `conformance-core`: tre passi nuovi (guardie, self-test, differenziale) |
| `GLOSSARY.md` | + *Corpus certificato*, *Contratto del seed*, *Gate differenziale* |
| `TASK.md` | N22 chiusa, ordine aggiornato, questo handoff |

Nessuna modifica a **codice del seed, lessico, parser, tipi, valutazione o I/O** del
linguaggio: la regola operativa 3 (conformance) non è stata attivata per il linguaggio; i
golden esistenti non sono stati toccati.

### Decisioni prese (con riferimento agli ADR)

1. **Le guardie stanno in un controllore dedicato** (`tools/selfhost-guard/`), che riusa
   l'AST del riferimento JS; il lint di `tools/site-gen/lint.mjs` **resta dov'è** (presidia
   un altro contratto: il sottoinsieme portabile per il browser) e non viene duplicato.
2. **Il contratto del seed guida le regole**: ogni regola è legata a una divergenza ed è
   attiva solo se la divergenza è ancora in `seed/dev/certified-subset.txt` → quando il
   seed viene corretto, la regola si spegne da sola.
3. **Criterio di precisione**: le regole statiche decidono solo ciò che si vede nell'AST;
   le divergenze che dipendono dai tipi a runtime (D15) **non** hanno una regola statica
   aggressiva ma il **gate differenziale**.
4. **Criterio di «non presidabile»**: decidibile dall'AST **e** regola che la presidia
   **e** fixture sintetico che la fa scattare; altrimenti il presidio è il differenziale e,
   se il differenziale trova una differenza, la risposta è la **chirurgia nel seed**.
5. **Corpus certificato dichiarato** (`seed/dev/certified-corpus.txt`); i file fuori
   manifesto sono *fuori contratto*: le violazioni sono avvisi, non errori (e non sono
   silenziate).
6. **Nessun nuovo ADR**: le decisioni stanno nei ticket della mappa M6 (il posto previsto,
   `docs/agents/issue-tracker.md`); il rebuild del seed resta sotto ADR 0001 (byte del PE) e
   ADR 0002 (parità senza PE).

### Test di conformance eseguiti ed esito

- `sh verify.sh` → **OK**: gate conformance **38/39** (l'unico FAIL è `liste`, gap noto
  **N03**, escluso in modo esplicito e rumoroso da `conformance/gate.sh`) + probe **39/39
  PASS** + golden S1.
- `node tools/selfhost-guard/test.mjs` → **26 test, 0 falliti** (un fixture per regola, il
  corpus pulito, la disattivazione per contratto, la copertura delle divergenze).
- `node tools/selfhost-guard/guard.mjs` → **17 file, 0 errori, 11 avvisi** (gli avvisi sono
  tutti su file *fuori contratto*).
- `node tools/selfhost-guard/differential.mjs` → **6 file, 0 differenze** (corpus certificato:
  seed e riferimento JS, stesso stdout byte per byte e stesso exit code).
- Nessun golden riscritto; nessun caso di conformance aggiunto (nessuna modifica al
  comportamento del linguaggio).

### Prossimi passi concordati

1. **Ciclo di rebuild unico** N20 + N21 + N03 + N04 + N06 → PE + ELF + hash CI + diff
   tracciato; poi N23 (gate 39/39) e N24 (allineamento dei documenti).
2. **Decisioni normative** N02 (newline) e N08 (scope, incluso il caso D20 «nome già
   legato»): le regole `G-D19`/`G-D20` vanno riesaminate dopo.
3. Poi i ticket M6 `02` (architettura di S1) e `03` (GC/memoria).

### Problemi aperti / noti

- **N03**: il caso `liste` resta FAIL → il gate è 38/39.
- L'**envelope** del seed non ospita S1 (sorgente > 64 KiB, heap 64 KiB) → N20 è bloccante
  per ogni lavoro su S1.
- `readfile` **assente**: S1 non può ancora leggere il programma da interpretare.
- **D20 «nome già legato»**: i due runtime coincidono e la lettera di `SPEC-CORE.md` §5 è
  ambigua (la lettura stretta renderebbe impossibile scrivere un ciclo) → decisione
  normativa pending (N08).
- Le guardie sono **sintattiche**: non provano i tipi (D15 resta al differenziale).
- `examples/` non è nel corpus certificato (i programmi di esempio girano sul riferimento
  JS; sul seed solo se sono nel manifesto).
- `TASK.md` «Current status» e `BOOTSTRAP.md` §10 restano **ottimistici** (N24).
- `TriadDesktop.exe` non pubblicato; N10 (rotazione del PAT esposto) resta **azione umana**.

### Comando di ripresa

```sh
cd /home/votlazam/Documenti/progetti/triad2.0 && git status --short && node tools/selfhost-guard/guard.mjs && node tools/selfhost-guard/test.mjs && node tools/selfhost-guard/differential.mjs && sed -n '1,40p' TASK.md
```

Prossimo lavoro: **ciclo di rebuild del seed** (N20 + N21 + N03 + N04 + N06), poi N23/N24.

```
Ripresa sessione: leggi la sezione "Handoff — 2026-11-08" in TASK.md e continua da lì
```

## Handoff — 2026-11-07 17:40 (soglia di budget R2.7M raggiunta)

### Stato attuale e obiettivo della sessione

Sessione dedicata alla **decisione architetturale [01] della mappa self-hosting M6**
(skill `grilling`): «il seed va forkato con un livello AST/bytecode?». Obiettivo:
riconoscere i **gap reali** del seed (misurati, non dedotti), decidere il **pavimento
(contratto)** del seed per la catena S0→S4 e tradurre la decisione in slice di esecuzione
numerate (`TASK.md` N20–N24). Sessione chiusa per raggiungimento della soglia di budget
(R2.7M): nessuna modifica a codice del seed, solo documentazione, ticket e glossario.

Punto di partenza: `HEAD` = `1612c44` (release `v0.8.0-beta.9`, dati di pubblicazione),
con la release pubblicata e la CI verde. La sezione «Ciclo di rebuild del seed per S1 —
N20–N24» in questo file è **già committata** (in `1612c44`); il lavoro di questa sessione è
il **corpo decisionale** che la precede.

### Cosa è stato fatto

1. **Ticket [01 — Fork architetturale del seed](.scratch/self-hosting-m6/issues/01-fork-architetturale-seed.md)
   → `Status: resolved`** (file modificato, non ancora committato):
   - **ricognizione misurata** sul seed ELF nativo: tabella **D1–D22** (divergenze semantiche
     rispetto a `SPEC-CORE.md`), sezione **F** (funzionalità mancanti: N03–N07), sezione **R**
     (limiti di risorsa), sezione **E** (envelope dell'arena: sorgente 64 KiB, heap 64 KiB senza
     `free`, liste 64 elementi, funzioni 64 B/record → max 4 parametri);
   - **risposta alla grilling Q1–Q6**: nessun fork AST/bytecode (la motivazione di
     `BOOTSTRAP.md` §10 è *misurata* obsoleta: `elseif` esiste, le liste sono parziali, il
     vero ostacolo è lo **scope dinamico**); il seed resta **interprete diretto** e diventa
     **veicolo di transizione per S1**, non implementazione Core conforme; **pavimento** =
     §8 completi (`readfile` incluso) + divergenze toccate dalla sorgente di S1 + `liste` verde
     (39/39); **fuori contratto** il resto (`typeof`, `Int()`, `Symbol()`, `:+`, forward ref…);
     costruzioni *rumorose* → **vietate** nella sorgente di S1 (guardie statiche), divergenze
     *silenziose* → **guardie dedicate**; **riferimento JS** (`seed/dev/triad_core.cjs`) =
     autorità semantica di sviluppo, **seed** = gate di esecuzione; **arena da
     ri-proporzionare** (buffer sorgente 64 KiB → **1 MiB**, heap 64 KiB → **8 MiB**, liste a 64
     elementi invariate); criterio di riapertura del fork = **costo misurato**, non principio;
   - **correzione documentale**: `length(xs)` **funziona già** (misurato `length([1,2,3])` → `3`)
     → il commento di `conformance/gate.sh` che lo dichiarava mancante è sbagliato.
2. **`.scratch/self-hosting-m6/map.md`** (modificato): decisione [01] inserita in
   «Decisions so far»; il seed post-decisione è **veicolo di transizione**; envelope
   ri-proporzionato e **sottoinsieme certificato** in `seed/README.md` +
   `seed/dev/certified-subset.txt`; slice N20–N24 referenziate (mai duplicate).
3. **`GLOSSARY.md`** (modificato): due termini canonici nuovi — *Sottoinsieme certificato*,
   *Divergenza silenziosa*.
4. **Nuovo ticket [12 — Guardie statiche per la sorgente di S1](.scratch/self-hosting-m6/issues/12-guardie-statiche-sorgente-s1.md)**
   (file **nuovo, non versionato**): 4 decisioni aperte — quale regola presidia quale
   divergenza silenziosa (e con quale precisione), dove stanno le guardie (lint esistente
   `tools/site-gen/lint.mjs` vs controllore dedicato alla sorgente S1), **criterio di
   «non presidabile»** (⇒ chirurgia nel seed) e ruolo del riferimento JS nella CI
   (confronto seed↔JS come gate?).
5. **`AGENTS.md`** (modificato): soglia di budget di sessione aggiornata a **R2.7M** (era
   1.5–2M) e formato del riepilogo di handoff esplicitato su «cosa è stato fatto / cosa manca».

### Cosa manca

**Esecuzione (slice già definite in questo file, ordine in «Ordine» 2026-11-07):**

- **N20** — ri-proporzionamento dell'arena (buffer sorgente 1 MiB, heap 8 MiB): senza questo
  l'envelope attuale **non ospita S1**.
- **N21** — primitivi §8 nel seed (`readfile`, `strlen`, `strbyte`, `strsub`): `readfile` non è
  un extra, è il modo in cui S1 legge il programma da interpretare.
- **N03** — `xs[i]` 1-based (sblocca il caso `liste`, **unico FAIL** del gate: 38/39).
- **N04** — `-=` / `*=`. **N05** — funzioni con > 4 parametri.
  → tutti e quattro in **un solo ciclo di rebuild PE/ELF + hash CI** (ADR 0001: diff tracciato).
- **N22** — contratto del seed (`seed/README.md` + `seed/dev/certified-subset.txt`) e guardie
  statiche sulla sorgente di S1 → **dipende dalla decisione del ticket 12**.
- **N23** — gate a **39/39** (`KNOWN_GAP` vuoto in `conformance/gate.sh`).
- **N24** — allineamento dei documenti (`BOOTSTRAP.md` §10, «Current status» di questo file,
  `STATUS.md`) alla **ricognizione misurata** (via le affermazioni ottimistiche su `elseif` e
  liste «complete»).

**Decisioni normative ancora da prendere (regola operativa 1: non inventare semantica):**

- **N02** — newline: quando continua l'espressione e quando separa gli statement (D19).
- **N08** — scope dei nomi: lessicale (`SPEC-CORE.md` §5) o dinamico (comportamento del seed)
  (D1); una delle due implementazioni va allineata.
- **D21** — condizione `while` non-`Bool`: il seed **salta il corpo** (divergenza silenziosa);
  il caso negativo di conformance resta sospeso in attesa della decisione.

**Mappa M6 (ticket ancora aperti):** `02-architettura-s1`, `03-gc-memoria`,
`04-linguaggio-sorgente-s2`, `05-forma-artefatti`, `06-architettura-codegen-compilatore`,
`07-certificazione-pe`, `08-certificazione-punto-fisso-ci`, `09-toolchain-alla-destinazione`,
`10-ricerca-punto-fisso-root`, `11-ricerca-gc-bootstrap`, `12-guardie-statiche-sorgente-s1`.

**Fuori dal bootstrap (trasversali, da non confondere con la catena S0→S4):** GUI Windows
(`TriadDesktop.exe` non pubblicata: ticket `.scratch/desktop-gui-windows/issues/01`),
traduzione EN del libro, `Q01–Q06` (matrice requisiti→test, allineamento documenti, tool AI,
packaging Julia, editor, pulizia repo).

### File toccati in questa sessione

| File | Modifica |
|---|---|
| `.scratch/self-hosting-m6/issues/01-fork-architetturale-seed.md` | `Status: open` → `resolved`; aggiunte sezioni Fatti (D1–D22, F, R, E), metodo di misura, risposta Q1–Q6 |
| `.scratch/self-hosting-m6/map.md` | decisione [01] in «Decisions so far»; seed = veicolo di transizione; slice N20–N24 |
| `.scratch/self-hosting-m6/issues/12-guardie-statiche-sorgente-s1.md` | **nuovo** ticket (grilling) sulle guardie statiche della sorgente di S1 |
| `GLOSSARY.md` | + *Sottoinsieme certificato*, + *Divergenza silenziosa* |
| `TASK.md` | questa sezione di handoff |
| `AGENTS.md` | soglia di budget R2.7M + formato del riepilogo (cosa fatto / cosa manca) |

Nessuna modifica a codice (seed, parser, evaluator, harness, CI): la regola operativa 3
(conformance) non è stata attivata perché non c'è stata alcuna modifica a lessico, parser,
tipi, valutazione o I/O.

### Decisioni prese (con riferimento agli ADR)

1. **Nessun fork AST/bytecode del seed** — criterio di riapertura: costo **misurato**
   (giorni di codice macchina × regressioni sui 38 casi verdi) vs nucleo AST/bytecode.
2. **Il seed è veicolo di transizione per S1**, non implementazione Core conforme; il suo
   *pavimento* è §8 + divergenze toccate da S1 + `liste` verde (39/39).
3. **Guardie statiche sulla sorgente di S1** invece di chirurgia nel seed per le costruzioni
   *rumorose*; regole dedicate per le *silenziose*; chirurgia solo se «non presidabile».
4. **Riferimento JS = autorità semantica**; **seed = gate di esecuzione**.
5. **Arena ri-proporzionata** (1 MiB / 8 MiB): modifica di costanti e offset, **nessun impatto
   sul layout del PE** → cambia i byte del codice macchina → hash CI + diff tracciato
   (**ADR 0001**, `docs/adr/0001-immutabilita-pe-riproducibilita-dump.md`); parità PE/ELF
   verificata senza il PE (**ADR 0002**, `docs/adr/0002-verifica-parita-senza-pe.md`).
6. **Nessun nuovo ADR** in questa sessione: le decisioni stanno nei ticket della mappa M6
   (che è il posto previsto per le decisioni, `docs/agents/issue-tracker.md`).

### Test di conformance eseguiti ed esito

- `sh verify.sh` → **OK**: gate conformance **38/39** (l'unico FAIL è `liste`, gap noto **N03**,
  escluso in modo esplicito e rumoroso da `conformance/gate.sh`) + probe **39/39 PASS**.
- Nessun nuovo caso di conformance in questa sessione (sessione decisionale: nessuna modifica
  al comportamento → nessun golden da aggiungere, **nessun golden riscritto**).
- Working tree: modifiche solo a documenti/ticket (nessun codice) → nessuna regressione
  possibile sul seed.

### Prossimi passi concordati

1. **Risolvere il ticket 12** (grilling) → Q: regole per divergenza, sede delle guardie,
   criterio di «non presidabile», ruolo del confronto seed↔JS in CI.
2. **Ciclo di rebuild unico** N20 + N21 + N03 + N04 + N05 → PE + ELF + hash CI + diff
   tracciato; poi N23 (gate 39/39) e N22 (contratto + guardie).
3. **N24**: allineare `BOOTSTRAP.md` §10, «Current status» e `STATUS.md` alla misura.
4. Solo dopo: ticket M6 `02` (architettura di S1) e `03` (GC/memoria).

### Problemi aperti / noti

- **N03**: caso `liste` ancora FAIL → il gate è 38/39, non 39/39.
- L'**envelope** del seed non ospita S1 (sorgente > 64 KiB, heap 64 KiB) → N20 è bloccante
  per ogni lavoro su S1.
- `readfile` **assente** nel seed: S1 non può ancora leggere il programma da interpretare.
- Divergenze **silenziose** ancora non presidiate: D1 (scope dinamico), D2 (cattura per valore),
  D3 (escape), D4 (`==` su stringhe), D19 (newline), D20 (scope del corpo `while`),
  D21 (`while` non-`Bool`).
- `TASK.md` «Current status» è **ottimistico e superato** dalla misura (N24).
- `TriadDesktop.exe` non pubblicato (GUI Windows legata alla CLI Node pre-N18).
- N10 (rotazione del PAT esposto) resta **azione umana** fuori dal repo.

### Comando di ripresa

```sh
cd /home/votlazam/Documenti/progetti/triad2.0 && git status --short && git diff --stat && sed -n '1,120p' TASK.md && cat .scratch/self-hosting-m6/issues/12-guardie-statiche-sorgente-s1.md
```

Prossimo lavoro: **ticket 12** (grilling sulle guardie statiche) → poi ciclo di rebuild
N20+N21+N03+N04+N05.

```
Ripresa sessione: leggi la sezione "Handoff — 2026-11-07 17:40" in TASK.md e continua da lì
```

## Release 0.8.0-beta.9 — 2026-11-07 (branch `release/v0.8.0-beta.9`, PR #72 + PR #73)

Preparazione e pubblicazione della release `v0.8.0-beta.9` (da `v0.8.0-beta.8`, 123 commit
intermedi). Tag `v0.8.0-beta.9` sul commit di merge `f30a0a2` (`main`).
Release: https://github.com/GPuntobit/triad2.0/releases/tag/v0.8.0-beta.9

### File toccati
- `VERSION` → `0.8.0-beta.9`.
- `CHANGELOG.md`: nuova sezione di rilascio in testa; le sezioni «Not released — …» sono
  state rinominate in sezioni datate (tutto ciò che precede è ora rilasciato).
- `AGENTS.md`, `PROJECT_PROMPT.md`, `docs/wiki/Project-Status.md`: riferimenti di versione.
- `docs/releases/RELEASE_NOTES_v0.8.0-beta.9.md` (EN, corpo della GitHub Release) e
  `RELEASE_NOTES_v0.8.0-beta.9.it.md` (IT).
- `docs/releases/RELEASE_POST_v0.8.0-beta.9.md` / `_EN.md` (post social, da copiare).
- `.codacy/codacy.config.json` e `.codacy/codacy.config.baseline.json`: nuovi file di
  release aggiunti alla lista `exclude`.
- `STATUS.md`: sezione di rilascio in testa.
- `.scratch/desktop-gui-windows/issues/01-gui-windows-alla-cli-posix.md`: ticket di follow-up
  per la GUI Windows (non pubblicata in questa release).

### Decisioni
1. **Versione `0.8.0-beta.9`** — semver pre-release, stesso canale delle beta precedenti.
2. **Asset pubblicati**: `seed.exe`, `seed-linux-x86_64`, `triad-cli` (Linux ELF),
   `triad-cli.exe` (Windows). Le release precedenti non pubblicavano il seed ELF: con N17
   il runtime Linux è il percorso primario, quindi l'asset è essenziale.
3. **`TriadDesktop.exe` non pubblicato** — la GUI Windows è stata scritta per la CLI Node
   pre-N18 (`status` / `test`, rimossi) e il suo probing della root cerca
   `conformance/run.mjs` (rimosso in N17); non è ricostruibile su Linux (serve .NET SDK
   WinForms). Rischio di pubblicare un binario notamente rotto → escluso, con ticket.
4. **SEA su base Node 22.23.4** — con Node 26 il blob iniettato con
   `postject@1.0.0-alpha.6` (ultima versione disponibile) produce un eseguibile che va in
   segfault all'avvio; la base 22.23.4 (Linux e Windows) funziona ed è smoke-testata
   (`triad-cli --help` nativo, `wine triad-cli.exe --help`).
5. **Nessun golden riscritto** — il caso `liste` resta il FAIL noto (38/39), registrato
   dall'harness e escluso dalla CI.

### Validazione
- `sh verify.sh` → **OK** (gate: 38/39 con il gap noto `liste` escluso esplicitamente,
  probe 39/39).
- `sh tests/probes/run_probes.sh` → **39/39 PASS**.
- `sh tests/desktop.sh` → **PASS**.
- `sh tests/security/run.sh` → **PASS** (8 check).
- Checkout pulito (clone): `verify.sh`, `check_seed.sh`, gate hash PE/ELF, anti-drift dei
  dump, `install.sh` (prefix temporaneo), `triad-cli test all`, `site-gen` lint + check,
  security → tutti verdi.
- CI GitHub Actions sul branch → **verde** (5 job).

### Correzioni fatte durante la release (la CI era rotta e non partiva)
1. **`ci.yml` non valido** — `- name: Verify (harness senza Node: ...)` era uno scalare
   plain non quotato con `": "` → YAML non valido, GitHub non avviava alcun job dal
   2026-11-06. Nome quotato + regressione `tests/security/workflows_yaml.test.py` (check 8).
2. **Golden dei probe e S1 non versionati** — `*.out` era ignorato senza eccezioni: in un
   checkout pulito 23 probe su 39 fallivano con «golden mancante». Ora versionati.
3. **Seed: codegen rotto di `xs[i]`** — il tentativo del 2026-11-06 leggeva il campo tipo
   della lista nel registro del puntatore: lettura → parse error, scrittura → SIGSEGV.
   Revert allo stato documentato (gap N03 aperto); i gate hash PE (`4235a707…`) ed ELF
   (`0e121db8…`) tornano coerenti con i dump committati.
4. **Gate con gap noti** — `conformance/gate.sh`: esegue l'oracle e tollera **solo** i
   fallimenti documentati (`liste`), stampandoli; `verify.sh` e `triad-cli test
   conformance` lo usano, l'oracle puro resta con `--strict`.

### Prossimi passi
- Portare e ricostruire la GUI Windows (ticket `.scratch/desktop-gui-windows/issues/01`).
- Prossima milestone: self-hosting M6 (mappa `.scratch/self-hosting-m6/map.md`).

## Merge `origin/main` — 2026-11-07 (branch `fix/desktop-cli-session`)

Merge commit `45c7d7d` (base `83ca5ed`). Three conflicts resolved:

- `.codacy/codacy.config.json`, `.codacy/codacy.config.baseline.json` → **versione di
  `origin/main`** (`source: remote`, provider `gh`, org `GPuntobit`, repo `triad2.0`).
  La versione del ramo era `source: auto` (config "auto" rigenerata senza remoto); quella di
  `main` è la config remota effettiva e include i linguaggi presenti nel repo (`Lua`, `Swift`,
  `XML`). Il contenuto è identico a quello rigenerato localmente da `codacy-cli`, salvo i
  timestamp `createdAt`/`updatedAt`.
- `bin/triad-desktop` → **versione del ramo** (sessione POSIX che chiede il percorso del
  programma, preserva l'exit code e `:quit`/EOF). La versione di `main` è il launcher
  pre-sessione: usciva subito con exit 2 quando lanciato senza file. Modalità file: `755`.
- `.github/instructions/codacy.instructions.md` → `repository: triad2.0` (allineato a `main`
  e al `repositoryName` della baseline Codacy; il ramo puntava a `triad2.0.wiki`, che è il
  repo wiki, non quello analizzato).

Le modifiche locali non committate (rigenerazione `codacy-cli` con path assoluti della macchina,
`.codacy/generated/*`) sono state scartate: sono artefatti machine-specific e sovrascriverebbero
i file con path Windows già versionati.

Validazione post-merge: `sh verify.sh` → 38/39 PASS, l'unico FAIL è `liste` (gap **N03**,
`xs[i]` 1-based non ancora implementato nel seed), preesistente su `17796ce`; `sh tests/desktop.sh`
→ PASS.

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
## Objective
Complete Triad 2.0 as a standalone and recognized language with its own standard, conformance suite, `.triad` extension, tooling editor, bootstrap without guest languages and self-hosting.
## Current status
- **Seed S0 (Windows):** 8315 bytes, hash `9987105DCD56F42A1AD73451821A281E6F24374ED6CE83993BB8CA56F5EC4822`
  - Support: integers, variables, functions (short form and block), recursion, Bool, operators, if/elseif/else, while, let, begin, lambda, closures, base strings, nothing, symbols, complete lists (build, print, push!, get)
  - Conformance: 33/33 Windows byte-exact cases, 36/36 Core Julia
- **S1 (Triad Interpreter in Triad-Core):** Inline environment working with lists, complete basic primitives
- **Seed S0 (Linux):** ELF **E2** (8499 byte: interprete Triad-Core completo, stessa
  macchina del PE, parità **byte-exatta** su conformance 39/39 + probe 39/39 + golden S1)
  — **N15–N18 tutte chiuse il 2026-11-05**: E1 runner, E2a confine `os_*` (PE byte-identico),
  E2b interprete + harness senza Node, E3 toolchain senza Node (`install.sh` →
  `bin/triad`/`bin/triad-cli`, smoke byte-exatto). **Task principale (2026-11-03) completa**;
  prossima in ordine: **N03** (`xs[i]` 1-based + gap `liste`) in un ciclo unico di rebuild
  PE/ELF + hash CI.
- **S2-S4:** mappa decisionale wayfinder `.scratch/self-hosting-m6/map.md` (tracciata
  2026-11-05; destinazione M6: punto fisso del compilatore nativo + seed ritirato);
  esecuzione da schedulare qui dopo le decisioni. Prima: porta Linux N15–N18.

## Task da fare (2026-11-05, post-N16)

Checklist operativa dalle note di chiusura di N16 e dalle decisioni wayfinder ancora da
attuare; il dettaglio resta nelle slice N17–N18 e nei ticket di
`.scratch/seed-linux-nativo/` (mai duplicati qui).

- [x] **Revisione CI secondo decisione 04** (dentro N17) — ✅ **fatto 2026-11-05**: job
  `seed-windows` rimosso e matrice `site-gen` ridotta a Ubuntu (solo Linux nativo);
  lato PE resta il gate hash di `seed.hex` (spostato nel job `seed-linux`) + golden
  congelati (ADR 0002); anti-drift `gen_seed.js && cmp` già presente. Promemoria storico:
  il commit `fc320f4` dichiara la rimozione ma non la implementa nel diff — implementata
  qui. Conseguenze noti (gate PE non più eseguite, tutorial da aggiornare): raccolte
  come voci dedicate qui sotto.
- [x] **N17 — E2b** (slice sotto) — ✅ **fatto 2026-11-05**: entry unico
  `gen_seed.js <windows|linux|all>` + moduli `core`/`backend_pe`/`backend_elf`
  (decisione 02 Q8); backend ELF con `os_*` via syscall Linux (`openat`, contratto 03 Q6);
  parità **byte-exatta** col PE su `conformance/core` (39 casi), probe `ok_*`/`test_*` e
  golden `selfhost/source.expected.out` (esito dettagliato nella slice N17).
- [x] **Harness di verifica senza Node, sostituzione in un colpo solo** (dentro N17,
  decisione 08) — ✅ **fatto 2026-11-05**: `conformance/run.sh` +
  `tests/probes/run_probes.sh` + `verify.sh` al posto di `run.mjs`/`run_probes.mjs`/
  `run.test.mjs` (assieme a loro: `gen_seed_linux.js` assorbito in `gen_seed.js`,
  `check_e1.sh` → `check_seed.sh`); 39 casi senza `--skip liste`; golden sidecar
  committati (`*.expected.out`/`*.expected.code`); CI ripuntata, inclusa la delega di
  `triad-cli test conformance` a `run.sh`.
- [x] **N18 — E3** (slice sotto) — ✅ **fatto 2026-11-05**: `bin/triad` senza logica di
  stub (soglia 4 KB, `--jsref`, ramo JS e ramo `bin/triad-native` escono), `bin/triad-cli`
  POSIX a pura delega (`run`/`test`/`status`), `install.sh` con decoder `printf` puro,
  wrapper a percorso assoluto e smoke test byte-exatto (mismatch → exit non-zero; verificato
  anche con golden alterato); `cli/triad-cli.mjs` ai soli comandi dev; CI `seed-linux`
  sull'ELF nativo senza Wine e `linux-toolchain` senza Node (decisioni 07/09).
- [x] **Ripristino sull'ELF delle gate perse dalle gambe Windows** (dentro N17) —
  ✅ **fatto 2026-11-05**: probe `ok_*`/`test_*`, golden `selfhost/source.td`, probe
  `get` e smoke `selfhost/main.td` riagganciate al job `seed-linux` (step `sh verify.sh` →
  `run_probes.sh` coi sidecar) sulla parità **byte-exatta** dell'ELF.
- [x] **Rimozione dello skip storico `liste`** (decisione 04 Q1) — ✅ **fatto 2026-11-05**:
  il gate `conformance/core` copre i **39 casi** con `sh conformance/run.sh`, senza
  `--skip`: il gap `liste` è **registrato** nell'harness (esito del seed congelato come
  `exit 1 + stdout vuoto`, identico su PE ed ELF), non skippato.
- [x] **Aggiornamento tutorial alla CI post-decisione 04** (dentro N18, documentazione
  stato piattaforme) — ✅ **fatto 2026-11-05**: `docs/tutorial/*` (it/en/ja/zh/ru)
  riscritti secondo la CI attuale (gate hash PE in `seed-linux`, suite sull'ELF nativo,
  nessun riferimento a `seed-windows`/`$cases`/`conformance/run.mjs`), incluse le tabelle
  dei job CI, la CLI a due livelli e il capitolo del seed Linux (E0 → E2).
- [x] **Revisione delle modifiche pendenti preesistenti** in `GLOSSARY.md`/`STATUS.md`/
  `TASK.md` (nel working tree prima della sessione N16) — ✅ **risolta col commit
  `7350412`** (modifiche incorporate, nessun scarto).
- [x] **Chiusura N17: note di stato + commit** (azione immediata, prima di N18):
  — ✅ **fatto 2026-11-05**: `STATUS.md` (riga S4/M7, comandi di verifica, distanza
  dall'obiettivo, nota di chiusura N17) e `CHANGELOG.md` (voce «seed Linux E2b + harness
  senza Node») aggiornati; commenti di chiusura ai ticket 04/08 in
  `.scratch/seed-linux-nativo/issues/`; commit del working tree N17 (ELF E2 da 8499 byte,
  harness sh + golden sidecar, CI ripuntata, `gen_seed_linux.js`/`check_e1.sh` assorbiti,
  file `windows` spurio rimosso).
---
# Task principale (2026-11-03): seed Linux nativo — senza Wine (N15–N18)

Decisione del maintainer (2026-11-03), **prima di riprendere N03**: Triad non deve diventare
«un emulatore solo Windows». L'utente Windows resta libero di usare il PE; l'utente Linux
**non deve installare nulla oltre la repo di GitHub** (niente Wine, niente Node per eseguire
i programmi): il seed deve girare **nativo** come ELF64. La porta Linux è quindi la task
principale e precede N03 e tutte le altre sotto-task meccaniche.

Riferimenti normativi: `BOOTSTRAP.md` §4 (chiamate di SO isolate in 4–5 routine `os_*`),
§5 (riga «Linux x86-64 (ELF)»: E0 ✅, E1/E2/E3 dopo), §6 (M7 = parità + porta Linux), §9
(rischio «Seed too tied to Windows»), §7 (il JS reference resta fuori dalla catena S0→S4,
strumento di sviluppo). Il dominio del linguaggio non cambia: `SPEC-CORE.md` resta normativo
e vale il vincolo Triad-Core ⊂ Triad-Full (regola operativa 4). Nessuna semantica inventata
(regola operativa 1): l'ELF deve comportarsi **identico al PE**, limiti noti compresi.

Mappa decisionale (wayfinder): `.scratch/seed-linux-nativo/map.md`, ticket in
`.scratch/seed-linux-nativo/issues/` (decisioni aperte: byte del PE, architettura codegen,
contratto `os_*`, parità/CI, installazione zero-install). Le slice N15–N18 qui sotto
restano il piano d'esecuzione: la mappa decide, le slice costruiscono.

Obiettivo finale: `seed/linux-x86_64/seed` (ELF64 statico, senza libc né dynamic linker)
che esegue gli stessi programmi Triad-Core del PE con stdout byte-identico; da un checkout
pulito su Linux, `./install.sh` + `bin/triad program.td` funziona con zero dipendenze esterne.

### N15 — E1: runner ELF di un file `.td` (argv + I/O nativo) — ✅ chiusa (2026-11-05)
- **Files:** `seed/dev/gen_seed_linux.js`, `seed/linux-x86_64/seed.hex` + `seed` +
  `check_e1.sh`, `seed/linux-x86_64/README.md`.
- **Work:** estendere `_start` con argc/argv e syscall `openat`/`read`/`write`/`exit`:
  il seed legge il sorgente indicato in `argv[1]` in un buffer (E1: caricamento + echo,
  errore su file mancante; l'interprete arriva in N17). ELF statico senza libc, come E0.
- **Acceptance:** `./seed file.td` legge il file; senza argomenti o con file inesistente →
  exit ≠ 0 con messaggio su stderr; dump riproducibile da `gen_seed_linux.js`; verificato
  nativamente su Linux x86-64 (CachyOS/CI).

### N16 — E2a: nucleo di codegen piattaforma-indipendente (routine `os_*`) — ✅ chiusa (2026-11-05)
- **Files:** `seed/dev/gen_seed.js` (rifattorizzazione interna), PE + `seed.hex`, hash in
  `.github/workflows/ci.yml`.
- **Work:** separare in `gen_seed.js` il codegen dell'interprete dalle chiamate di sistema
  Windows, isolando queste ultime nelle routine `os_*` — confine completo col sistema
  operativo, lista e firme nel contratto
  `.scratch/seed-linux-nativo/issues/03-contratto-os-star.md`, emissione inline
  (decisione `.scratch/seed-linux-nativo/issues/02-architettura-codegen.md`). Solo
  struttura: il PE rigenerato deve restare **byte-identico**
  a quello versionato — politica vincolante (a), decisione
  `.scratch/seed-linux-nativo/issues/01-byte-pe.md`: ogni diff nei byte è un bug o un
  cambio di layout da decidere nell'architettura del codegen; eccezioni solo per cambi
  semantici deliberati (ciclo N03–N05) con nuovo hash in CI e diff tracciata.
- **Acceptance:** `cmp` fra PE rigenerato e versionato; conformance Core e probe invariati;
  nessuna modifica semantica (refactoring del solo generatore).
- **Esito (2026-11-05):** `gen_seed.js` riorganizzato in emettitore neutro + *core del codegen*
  (memoria condivisa, confine `os_*`, corpo) + *backend PE* (emissioni `os_*` inline a
  piazzamenti ordinati, costanti di sistema, builder): il corpo non vede più nulla di
  Windows (nessuna `callIat`/costante fuori dal backend). PE rigenerato **byte-identico**
  (`cmp` + hash `seed.hex` invariato `4235A707…B8F7`), conformance Core e probe invariate;
  anti-drift del dump PE (`gen_seed.js` + `cmp`) aggiunto alla CI. Note: (i) il contratto 03
  non nomina dove vive l'acquisizione dell'handle stdout (`GetStdHandle` → r12): sanata
  dentro la forma PE di `os_arg` (commento in `gen_seed.js` + commento a ticket 03);
  (ii) la revisione della CI prevista da decisione 04 (rimozione gambe Windows + harness
  senza Node) resta a **N17** — il commit `fc320f4` la dichiara nel messaggio ma non la
  implementa nel diff.

### N17 — E2b: emettitore ELF64 e parità col PE (il cuore della task)
- **Files:** `seed/dev/gen_seed.js` (entry unico `<windows|linux|all>` + core condiviso +
  backend ELF con `os_*` via syscall Linux — decisione
  `.scratch/seed-linux-nativo/issues/02-architettura-codegen.md`),
  `seed/linux-x86_64/*`, `conformance/run.mjs` e `tests/probes/run_probes.mjs` (terzo
  runtime via `TRIAD_SEED`; sostituiti in un colpo solo dagli entry point POSIX
  `conformance/run.sh`/`tests/probes/run_probes.sh`/`verify.sh` — decisione
  `.scratch/seed-linux-nativo/issues/08-harness-verifica-senza-node.md`),
  `.github/workflows/ci.yml`.
- **Work:** implementare sull'ELF lo stesso dominio machine-code del PE — interi, variabili,
  funzioni short e `function … end`, ricorsione, Bool, operatori, `if`/`elseif`/`else`,
  `while`, `let`, `begin`, lambda/closures, stringhe base + `string()`, `nothing`, simboli,
  liste (costruzione, stampa, `push!`, `get`) — usando solo le routine `os_*`, niente libc.
- **Acceptance:** tutti i casi `conformance/core/` verdi sul PE risultano verdi **byte-exatti**
  sull'ELF nativo senza Wine (stessi `expected.out`/`expected.code`); probe `ok_*`/`test_*`
  identici su PE, ELF e JS; i limiti noti del PE restano limiti documentati (nessuna nuova
  semantica); dump riproducibile dai generatori.
- **Esito (2026-11-05):** E2b verificato — conformance **39/39 byte-exatta** sull'ELF
  nativo (gap `liste` registrato come `exit 1 + stdout vuoto`, assenza identica misurata
  su PE ed ELF), probe **39/39** con sidecar `<file>.expected.out`/`.expected.code`
  congelati da PE (ticket 08 Q10), `verify.sh` + `check_seed.sh` (7 casi) verdi, dump
  PE/ELF riproducibili da `gen_seed.js <windows|linux>` + `cmp` (hash PE `4235A707…`
  invariato). Harness senza Node sostituito in un colpo solo (ticket 08 Q4) e CI
  ripuntata; gate perse dalle gambe Windows riagganciate al job `seed-linux`. Restano
  commit + note di stato (voce dedicata nella checklist qui sopra).

### N18 — E3: toolchain Linux senza Wine (install → run)
- **Files:** `install.sh`, `bin/triad`, `cli/lib/utils.mjs` (soglia stub 4 KB e fallback JS
  automatico), `.github/workflows/ci.yml` (job `seed-linux` nativo), `seed/README.md`,
  `seed/linux-x86_64/README.md`, `STATUS.md`, `BOOTSTRAP.md` §5/§10.
- **Work:** il launcher `bin/triad` su Linux usa il seed ELF nativo (durante la transizione
  il fallback JS diventa solo esplicito con `--jsref`, non più automatico; **a chiusura di
  N18 la logica di stub — soglia 4 KB, flag `--jsref`, ramo JS — esce da `bin/triad`**,
  decisione *Installazione e launcher: il contratto zero-install*); la CLI diventa shell
  POSIX: `bin/triad-cli` con `run`/`test`/`status` a pura delega, `cli/triad-cli.mjs`
  ristretto ai soli comandi dev (`seed`/`ai`/`ext`), ramo `bin/triad-native` fuori dal
  launcher (decisione *CLI e toolchain senza Node*); job CI `seed-linux` su
  `ubuntu-latest` che esegue
  conformance + probe sull'ELF nativo **senza Wine** (Wine resta solo nel job di parità PE,
  opzionale); aggiornare la documentazione dello stato piattaforme.
- **Acceptance:** su Linux: `git clone` → `./install.sh` → `triad program.td` funziona con
  zero dipendenze oltre alla repo (percorso garantito: la catena con `install.sh`);
  installazione con smoke test byte-exatto (`test_simple.td` + golden sidecar) che **fallisce
  con exit non-zero** su mismatch; launcher installato come wrapper a percorso assoluto,
  senza logica di stub; `triad-cli` in shell POSIX installato e funzionante senza Node
  (`status`, `test` → harness); CI `seed-linux` verde senza Wine; l'utente Windows
  continua a usare il PE invariato; `linux-toolchain` copre launcher + install.
- **Esito (2026-11-05):** N18 verificata e chiusa — `install.sh` decodifica `seed.hex` con
  un solo decoder sh-puro `printf` (nessun `xxd`/`python3`/`od`; 8499 byte in ~0,2 s),
  confronta la decodifica col binario committato (anti-drift `cmp` + avviso) e installa
  `triad`/`triad-cli` come wrapper a percorso assoluto; smoke test byte-exatto su
  `test_simple.expected.out` con `cmp`, che **fa fallire l'installazione** su mismatch
  (verificato anche negativamente); fuori Linux x86-64 installazione parziale con avviso,
  exit 0. `bin/triad` exec-sempre-il-seed; `bin/triad-cli` sh (`run`/`test`/`status`,
  `status` deterministico); `cli/triad-cli.mjs` ai soli comandi dev con
  `run.mjs`/`test.mjs`/`build.mjs` e `seedIsStub`/`runSeed` eliminati. CI: `linux-toolchain`
  senza `setup-node` con smoke negativo esplicito; `seed-linux` resta su runner pinnato
  `ubuntu-24.04` (deviazione minore dall'acceptance `ubuntu-latest`, nota a ticket 09).
  Tutorial (it/en/ja/zh/ru) + `README.md`/`cli/README.md`/`AGENTS.md`/`PROJECT_PROMPT.md`/
  `seed/*README*`/`BOOTSTRAP.md` §5/§10 aggiornati. Gate verdi: `sh verify.sh` (conformance
  39 + probe 39), `check_seed.sh` (7 casi), `ai verify` 5/5, site-gen lint + `--check`,
  `tests/security/run.sh` ALL PASSED.

### N19 — (secondario, non bloccante) Esperienza di sviluppo / IDE
- **Files:** `editors/` (grammar VS Code/Vim già presenti), eventualmente un Language Server.
- **Work:** se con «ide» si intendeva un ambiente di sviluppo (diagnostica, autocomplete,
  run/Debug da editor): estendere `editors/` con un LSP minimo (diagnostica di parse + run
  del seed) oppure pubblicare l'estensione VS Code già preparata. Fuori dalla catena
  S0→S4 (regola operativa 2), non tocca il bootstrap.
- **Dipendenze:** decisione di scope del maintainer PRIMA del codice (come N02/N08).
  Ruling 2026-11-05: **fuori dalla mappa** `.scratch/seed-linux-nativo` (oltre la sua
  destinazione zero-dep; ticket chiuso fuori scope — vedi *Out of scope* in
  `.scratch/seed-linux-nativo/map.md`). Forma e perimetro (LSP minimo vs solo estensione,
  debug/autocomplete, accettazione) si decidono in uno sforzo proprio, quando deciso.
- **Acceptance:** da definire alla decisione; finché non è decisa non blocca N15–N18.

### Ciclo di rebuild del seed per S1 — N20–N24 (decisione della mappa, 2026-11-07)

Decisione: `.scratch/self-hosting-m6/issues/01-fork-architetturale-seed.md` (ticket risolto) —
il seed resta interprete diretto (nessun fork AST/bytecode) ed è **veicolo di transizione
per S1**; pavimento = §8 + le divergenze che la sorgente di S1 tocca + `liste` verde.
Ricognizione misurata dei gap e dell'envelope: **ticket 01** (Fatti). N19 è già occupato
(«Esperienza di sviluppo / IDE»): le slice nuove partono da N20.

### N20 — Ri-proporzionamento dell'arena del seed
- **Files:** `seed/dev/core.js` (costanti e offset), PE/ELF + `seed.hex`, hash in
  `.github/workflows/ci.yml`.
- **Work:** buffer sorgente 64 KiB → **1 MiB**; heap 64 KiB → **8 MiB** (bump, senza GC: il
  GC è di S1, vedi ticket `03-gc-memoria`); `os_read` con `max` = dimensione del buffer
  (errore oltre); **le liste restano a 64 elementi** (chunking = problema di S1, N07 resta
  fuori ciclo). L'arena è allocata a runtime: nessun impatto sul layout del PE, cambiano i
  byte del codice macchina (hash CI + diff tracciato, ADR 0001).
- **Acceptance:** un programma > 64 KiB gira ed esce 0 (oggi: `seed: read error`); la
  sorgente di S1 completa sta nell'arena con margente ×2; conformance invariata.

### N21 — Primitivi §8 nel seed (`readfile`, `strlen`, `strbyte`, `strsub`)
- **Files:** `seed/dev/core.js` (dispatch dei builtin), `tests/probes/`,
  `seed/linux-x86_64/check_seed.sh`.
- **Work:** implementare i §8 mancanti (`get` ed `exit` ci sono). `readfile` non è un
  extra: è il modo in cui S1 legge il programma da interpretare (`SPEC-CORE.md` §8).
- **Acceptance:** un probe per ciascun primitivo, confrontato byte-per-byte con il
  riferimento JS; `readfile` restituisce il contenuto del file senza alterazioni.

### N22 — Contratto del seed + guardie statiche sulla sorgente di S1
- **Files:** `seed/README.md` (contratto), `seed/dev/certified-subset.txt` (contratto
  macchina-leggibile), `seed/dev/certified-corpus.txt` (corpus certificato),
  `tools/selfhost-guard/` (il controllore: `guard.mjs`, `rules.mjs`, `analysis.mjs`,
  `scan.mjs`, `contract.mjs`, `differential.mjs`, `test.mjs`, `fixtures/`), CI.
- **Work:** ✅ **guardie fatte 2026-11-08** (decisione del ticket
  `.scratch/self-hosting-m6/issues/12-guardie-statiche-sorgente-s1.md`, risolto):
  contratto del seed scritto (fatti: envelope, primitivi §8, divergenze e classe) e
  guardie implementate in un **controllore dedicato** che riusa l'AST del riferimento JS
  (nessun secondo parser) e consuma il contratto: ogni regola è legata a una divergenza e
  si spegne da sola quando la divergenza sparisce dal contratto. Le divergenze non
  decidibili staticamente (tipi a runtime) sono presidiate dal **gate differenziale**
  seed↔JS (`differential.mjs`, per programma del corpus certificato): se il differenziale
  trova una differenza, la risposta è la **chirurgia nel seed**. Il lint di
  `tools/site-gen/lint.mjs` **resta dov'è** (presidia un altro contratto: il sottoinsieme
  portabile per il browser) e non viene duplicato.
- **Acceptance:** ✅ il corpus certificato (`selfhost/source.td`, `selfhost/main.td`, i
  quattro generatori attivi di `tools/site-gen/`) passa le guardie e il differenziale
  (0 differenze); ogni violazione è segnalata con un messaggio che nomina la regola
  (`G-Dxx`) e il costrutto; il self-test (`tools/selfhost-guard/test.mjs`) ha un fixture
  per ogni regola e verifica che ogni divergenza del contratto sia presidiata.

### N23 — Gate a 39/39 e chiusura del gap `liste`
- **Files:** `conformance/gate.sh` (`KNOWN_GAP` svuotato), `conformance/core/cases/liste`,
  CI.
- **Work:** N03 (`xs[i]` 1-based) rende verde il caso `liste` → il gate non ha più gap
  noti; correggere il commento di `gate.sh` che dice che il seed non implementa
  `length(xs)` (**funziona**: misurato `length([1,2,3])` → `3`).
- **Acceptance:** `sh verify.sh` → conformance **39/39**, gate senza gap noti.

### N24 — Allineamento dei documenti alla ricognizione misurata dei gap
- **Files:** `BOOTSTRAP.md` §10, `TASK.md` «Current status», `STATUS.md`.
- **Work:** sostituire gli elenchi ottimistici (che dichiarano `elseif` e liste «complete»)
  con la ricognizione misurata del ticket 01; aggiornare lo stato del seed e l'inventario
  dei gap con la loro destinazione (nel seed / fuori contratto / vietati in S1).
- **Acceptance:** nessun documento afferma più che `elseif` sia mancante né che le liste
  siano «complete»; l'envelope del seed (1 MiB / 8 MiB / 64 elementi) è dichiarato.

### Ordine (aggiornato 2026-11-08)
1. ~~**N15 → N16 → N17 → N18**~~ (task principale: seed Linux nativo, senza Wine) — ✅
2. **N20 + N21 + N03 + N04 + N06** in un ciclo unico di rebuild PE/ELF + hash CI
   (contenuto del ciclo fissato dalla decisione del ticket 01) — ora verificabile
   nativamente anche su Linux →
3. ~~**N22** (contratto del seed + guardie statiche)~~ — ✅ **fatto 2026-11-08**
   (decisione del ticket 12: `tools/selfhost-guard/`, contratto in
   `seed/dev/certified-subset.txt`, corpus in `seed/dev/certified-corpus.txt`) →
4. **N23** (gate a 39/39) →
5. **N02** e **N08** dopo le decisioni normative; **N05**/**N07** quando decisi; **N19** (se
   deciso).
---
# Backlog: errors and checks
This file collects confirmed problems and checks still to be done on the project.
An open check does **not** imply that the code is bad: file a bug only afterwards
have reproduced it, indicating the command or steps, the expected result and the one obtained.
## Project map
The most recent queryable Graphify map describes commit `d75e31a` (index of
October 24, 2026): 677 nodes, 1,546 relationships and 26 communities. The index includes guards
safety for malformed ASTs; subsequent local changes must be verified
directly.
- `syntax.jl`: lexer, Pratt parser and `Node` tree construction; between the mapped nodes:
  `parse_toplevel`, `parse_stmt`, `parse_function`, `parse_list`, `parse_args`, `parse_for`
  and `skipnl!` (guarding limits on trailing separators).
- `triad.jl`: runtime and execution; Graphify locates, among others, `run_source`,
  `load_file!`, `define_function`, `define_struct`, `solve_opts`, `reload!`, `run_solve`
  (checking the number of arguments) and `solve_goal`.
- `test/runtests.jl` and `conformance/`: implementation tests and conformance cases.
  `test/oracles/oracle_tests.jl` contains optional oracle tests.
- `.github/workflows/ci.yml`, `seed/` and `seed/dev/`: CI checks, Windows/Linux seeds
  and related generators.
- `bin/`: standalone launcher and packaging (`bin/build_standalone.jl`).
- `editors/`: editor integrations; `ai/`: tools and benchmarks.
- `SPEC.md`, `SPEC-CORE.md`, `BOOTSTRAP.md`, `STATUS.md`, `README.md` and
  `TUTORIAL.md`: standards, Core profile, bootstrap plan, status and documentation.
Graphify describes indexed relationships and symbols; does not certify semantic correctness,
test coverage or absence of bugs. The following checks must therefore be confirmed
running code and tests and comparing them to the specification.
## Completion priority
1. **P0 — Parser and specification:** close the check of `syntax.jl` against `SPEC.md`,
   then map regulatory requirements to testing and cover real gaps.
2. **P0 — Cross-platform release:** verify Windows CI lane and execution
   PE seed, including decoding, conformal cases, and hashing.
3. **P1 — Distribubility and integrity:** verify standalone packaging, reproducibility
   of generated files and protection of versioned artifacts.
4. **P1 — Documentation:** compare examples, declared state, and commands with
   implementation and compliance.
5. **P2 — Ecosystem:** Check editor integrations and AI tools.
**Graphify diagnosis:** `lex` is called from `parse_toplevel` and `string_node`, and is linked
to `interpolation_end`, `isidstart` and `syntax_error`; `parse_expr` is called by parsers
instructions, lists/comprehension, rules, solve and blocks. `graphify_tests_for` does not have
returned test for `lex`, `parse_expr` or `skipnl!` (no links in graph for i
AST audit test); for `run_solve` and `solve_opts` returns only `test/runtests.jl`
and `test/oracles/oracle_tests.jl` (match by name, not by content). It's a shortcoming of the
graph connections, not evidence of the absence of testing. The updated index is on commit
`d75e31a`. `raw()` (syntax.jl L310) is not resolvable like `raw!`; the callers of `next!`
include `expect_ident!`, `expect_kw!`, `expect_op!`, `parse_args`, `parse_expr`,
`parse_for` and `parse_function`.
## Recent issues and changes (from `5e8ca470` to `d75e31a`)
- [x] **Guards for malformed ASTs (commit `e201a3e`)** — Added regressions in
  `test/runtests.jl` for `skipnl!` at the token vector boundary, for `run_solve` with
  zero arguments, for `solve_opts` with no options, and for an option with no value.
  Malformed cases return Triad `:syntax` errors with no host exceptions; suites
  Julia: 281/281 tests passed.
- [x] **Seed Windows: Expressions in Block Functions** — The seed parser separated
  the path of the autonomous expressions from the one that saves the identifier registers;
  a literal in the body (e.g. `20`) corrupted the call stack. Corrected the
  path and added `io_functions` conformance, which checks `!io`, output in the body
and value of the last expression. Also check `test_short_func.td` in the form
  Triad `f1() = 10` and the block body; both end with exit `0`.
- [x] **Seed Windows: regenerated and aligned artifacts** — `gen_seed.js` generates
  25,088 bytes; `seed.exe` was decoded from `seed.hex`, SHA-256
  `76FC146BA7E070522A5445B5CC0810997E035CBC3135911F62B9C6E6B3CB255F`.
- [ ] **Seed Windows: `string()` does not cover Bool and Symbol** — The current generator
  handles strings and integers, but sends the `string(false)` error path,
  `string(true)` and `string(:symbol)`. Implement and test these cases
  compliance in the seed PE if they are required by the specification.
- [x] **Seed Windows: Core case `strings`** — After regeneration and decoding
of the 25,088 byte PE, `stringe/program.td` ends with exit code `0` and produces
  exactly `strings/expected.out` (`hi Triad`, `5`, `42`). Of the 28 cases of the CI job
  Windows, 27 pass locally; `if_else` ends with exit `1` and requires verification
  separate (even the previous EP did not overcome this case).
- [x] **Seed Windows: crash on lists and strings after generation** — With the generator
  local, `test_list.td` and also a case of strings ended with
  `STATUS_ILLEGAL_INSTRUCTION`; the Application Error indicated RVA `0x2ce6`. The name area
  import PE started at RVA `0x2cde` and overwrote the machine code grown to
  that address. Moved import names to RVA `0x5000`; the generated seed prints now
`[1, 2, 3]` and the `strings` case with exit code `0`. Added regression case
  `liste_base` to the conformance Core and the Windows CI job. The subsequent local verification
  passes all cases listed except `if_else` (exit `1`, pre-existing problem); the new
  hash of the seed is recorded in the CI.
- [x] **Seed Windows: probe `get(lst, 1)` was not dispatched** — The generator
  contained the `get` primitive parser but `pf_call` didn't recognize it; the seed came out
  with code `1` without output. Added dispatch and fixed argument retrieval
  and bounds checking, with zero-based index as required by the probe. The seed prints
  `20` for `test_get.td`; the probe is included in the Windows CI job. `get` remains an extension
of the seed, not a Triad-Core normative primitive (`xs[i]` is the standard 1-based access).
- [x] **Seed Windows: `push!` was not dispatched** — The builtin body was already
  present but not reachable from `pf_call`; also the seed identifier does not
  consumed the suffix `!`. Added `push!` dispatch, final suffix parsing,
  mutable append with 64 element limit and list return. `test_push.td` prints
  `[10, 20]`; added Core case `liste_push` and registered in Windows CI. The seed
  supports integer lists here; standard indexing, `length` and iteration remain absent.
  The local seed array passes 29/30 cases (remains `if_else`, exit `1`); the 33 Core cases
  they pass with the Julia runtime.
- [x] **Self-host seed smoke test: `selfhost/main.td` prints a list** — Reproduced on
  problem: previous version ended with exit code `1` and stdout empty because
  `env_lookup` used `get` in a function body and `return`, not supported by the seed in
  that context. Replaced the program with a compatible test of `push!` which must
  print `[10, 20]`, and added a check dedicated to the Windows CI. This checks out
  the list in the seed, not the completion of the self-hosted interpreter: `get` and `return`
  in the functions remain to be implemented. Graphify does not yet include `selfhost/` in
  indexed graph.
## Problem confirmed
- [x] **CI Workflow: YAML step name with `:`** — Fixed to
  `.github/workflows/ci.yml` by enclosing the `name` value in quotation marks. The YAML parser
  interpreted the colon as map syntax. `git diff --check` passed;
  validation with a local YAML parser was not available.
- [x] **String interpolation: delimiting and positions** — Fixed in `syntax.jl`.
  The parser closed `$()` at the first `)` parenthesis even when it was inside a string
  of the interpolated expression, and did not update rows/columns for diagnostics and instructions
  subsequent ones. Added regression tests for parentheses in interpolated string, expressions
  multiline and error locations.
- [x] **Range with non-compliant spaces** — Fixed in `syntax.jl`: `a:b` was accepted
although the normative grammar requires the range `a:b` without spaces. Added a test
  which requires a syntax error for `1:2`.
- [x] **`!` internal to identifiers** — Fixed in `syntax.jl`: `foo!bar` was
  tokenized as a unique identifier and produced a `:undef` error in evaluation,
  instead of being rejected by the parser. Now `!` is only allowed as a final suffix;
  added regression test.
- [x] **Return inside multiline comments** — Fixed in `syntax.jl`: newlines in
  `#= ... =#` update row/column but were not kept as separators, so
  `x = 1 #= comment\n=# y = 2` failed with syntax error. Now the lexer outputs the
  separator keeping newlines inside parentheses ignored by the parser; added tests
for both cases.
- [x] **Duplicate fields in `struct`** — Fixed in `triad.jl`: a definition with names
  of duplicate fields reached the constructor, which returned a host error. The definition
  now immediately returns `Err(:type)` with the field name; added regression test.
- [x] **Nested logical query budget** — Fixed in `triad.jl`: query steps
  subqueries `not(...)` were not added to the limit of the calling query. Now the counter
  it is shared; regression test on limits 5/6. Also checked the boundaries of `depth`
  with explicit tests and the existing recursive case.
- [x] **Trace `not(...)` subqueries** — Fixed in `triad.jl`: the inner query
  was not receiving the trace collector and its `:call`/`:exit`/`:fail` events were missing.
Added tests for successful and failed subqueries.
- [x] **Launcher Windows** — `triad.cmd` could select the fake Julia executable
  in `WindowsApps`, leaving the command locked; delayed expansion could also
  alter arguments containing `!`. Now skip alias, preserve arguments and propagate
  the exit code after execution. Checked autodetection, `-v` and forwarding
  of `bang!arg`.
## Checks to be performed
### Parsers and semantics
- [ ] **[P0, IN PROGRESS] Lexers, parsers and AST** — Check token, precedence and associativity
  operators, nested delimiters, strings, comments, syntax errors, and locations
  of errors. Added AST tests for assignment and associative, lambda and ternary operators
  right-handed, logical/unary/postfix precedence, newline continuation, comma rules
  initial and Unicode/`!` identifiers. Also corrected the internal `!`, prohibited by the
  grammar and newlines lost in multiline comments; suite at 275/275. The full audit
  against the specification remains open.
- [x] **Evaluation and scope** — Check local assignment without affecting globals,
  capture and mutation of variables in closures, and local visibility of loop binding.
Added regression tests in `test/runtests.jl`; suite (251 tests) and Core compliance
  they pass.
- [x] **Functions and dispatch** — Checked more specific methods, ambiguity, builtin fallback,
  type mismatch and replacement of a redefined signature. Added test for replacement;
  suite (252 tests) and compliance already performed pass.
- [x] **Types and structures** — Checked typed and untyped fields, conversion
  Int→Float, missing types, accessing non-existent fields, signatures and value constraints. Correct
  also the case of duplicate fields; suite (253 tests) and full compliance pass.
- [x] **Closures and higher-order functions** — Parameter capture and mutation checked
  of variables captured by nested functions; the suite also covers `map`, `filter` and `reduce`.
- [x] **Logic programming** — Check facts, rules, unification/occurs-check,
  backtracking, query, and limit/depth/step options; corrected the aggregate budget
  of the sub-queries. Suite (259 tests) and Core compliance pass.
- [x] **Code as data and macro** — Check nested quasiquote/unquote, evaluation
  of the generated code, macro arguments such as AST, expansion, and `gensym`; probe with
  unquote in nested lists returns the expected result.
- [x] **Errors, contracts and effects** — Host exception conversion verified,
  propagation/interception in `try`, `Err` data, `requires`/`ensures`, purity of
  contracts and dynamic control of `io`/`state`; Dedicated tests and suites pass.
- [x] **Budgets and Tracks** — Checked budget exhaustion and nesting, boundaries of
  `depth`, function trace, resolution and negated subqueries. Corrected count of
  steps and trace propagation; suite (261 tests) and full compliance pass.
### Testing and compliance
- [x] **Full suite** — `julia --startup-file=no test/runtests.jl` passes (275 tests,
  including tests covering guards for malformed ASTs added in `e201a3e`);
  `julia --startup-file=no conformance/run.jl` passes all cases.
- [x] **Triad-Core Profile** — `julia --startup-file=no conformance/run.jl --cases
  conformance/core/cases` passes all cases.
- [ ] **Requirements Coverage** — Link each regulatory requirement from `SPEC.md` and
  `SPEC-CORE.md` to one or more tests; create minimal cases for requirements not covered.
- [x] **Oracle optional** — The suite now locates Julia, SWI-Prolog and SBCL from the `PATH`
  (with override `TRIAD_ORACLE_*`); in Debian all comparisons pass: SWI-Prolog 2/2,
  SBCL 1/1 and Julia 1/1. Oracle process execution errors no longer occur
silently converted to blank output.
### CLI, platforms and distribution
- [x] **CLI and file upload** — Checked options, evaluation, exit codes,
  `ARGS`, shebang, file resolution, errors and REPL in implementation tests and in
  compliance.
- [x] **POSIX Launcher** — In Debian checked shell syntax, symlink resolution,
  paths and arguments with spaces, `!` in arguments, search via `PATH`, override
  `TRIAD_JULIA`, `--build`, real CLI and shebang. Fixed WSL fallback selecting
  `julia.exe` Windows and failed passing Linux paths; now the launcher requires Julia
  native Linux and explicitly rejects a `.exe` override.
- [x] **Windows Launcher** — Check PATH lookup against `WindowsApps` alias, override
  `TRIAD_JULIA`, `-v` mode and forwarding arguments containing `!` through
  `bin/triad.cmd`.
- [x] **Reproducibility of seed artifacts** — Linux and Windows generators recreate
  exactly the respective hex dumps; the decoded bytes match the files
  PE/ELF versioned.
- [x] **Linux seed execution (E0)** — ELF seed executed on Debian x86_64: print
  `Triad seed Linux OK` and exits successfully; ELF hash verified.
- [x] **Portable Probes** — `_probe.jl`, `_probe2.jl`, `_probe3.jl`, `_qc.jl` and
  `_smoke.jl` run with native Julia on Debian; all complete correctly.
- [ ] **Windows seed execution** — Native CI cases remain to be executed; Defender has
  quarantined the regenerated PE in `%TEMP%` during the local test.
- [x] **Scope of `continue-on-error` in Windows CI** — Checked in
`.github/workflows/ci.yml`: option only tolerates failure of `Add-MpPreference`;
  decoding, seed cases and hash verification remain blocking.
- [ ] **Running lane seed Windows** — Verify decoding, cases and hashing
  work even when the optional antivirus exclusion is not available. Defender
  the EP not excluded in the local test got through; it remains to verify the hosted lane
  without assuming that the exclusion will succeed.
- [x] **Cross-platform CI** — Check the lanes defined in
  `.github/workflows/ci.yml` on Windows and Linux. On local Windows the suite passes
  275/275 tests and Full/Core compliance passes. In Debian 13 on WSL, Full/Core compliance and
  Julia suite pass (275/275); the Linux seed decoded into a temporary file boots
and returns the expected output, and the hash of the dump matches. The
  [run GitHub Actions #21](https://github.com/GPuntobit/triad2.0/actions/runs/39983981561)
  (`5e8ca470`, 2026-10-23) succeeded on all four jobs: Ubuntu/Windows conformance
  and Linux/Windows seeds.
  There is no need to register WSL as a self-hosted runner.
- [ ] **Standalone packaging** — Try `bin/build_standalone.jl` in a clean environment and
  check dependencies, layout and startup without Julia. Windows Isolated Trial (Julia 1.13.1):
  PackageCompiler 2.4.5 installs in the temporary depot, then the build ends with
  `TypeError` on `c_driver_program` (`nothing` where `String` is required); no executable
  is produced. Also missing are `Project.toml` and `src/Triad.jl`, which are necessary for the layout
expected by the builder. Updated README to declare prototype unavailable;
  getting the build working and trying to launch it remains open.
### Editors, tools and documentation
- [ ] **EPUB book metadata** — `epub-gen`'s `content.opf.ejs` template does not emit
  `dc:description`, so the `description` option in `scripts/docs/build-epub.cjs` has no
  effect: the book description lives only in the *Quarta di copertina* chapter (verified in
  the generated EPUB). To put it in the metadata, pass `customOpfTemplatePath` with a
  template kept in the repository (and cover the same gap in the MOBI/DOCX builds).
- [ ] **Editor integrations** — Check grammar, highlighting and recognition
  of the canonical `.triad` extension and the `.td` alias in `editors/`.
- [x] **AI Tools** — Checked CLI options, dependencies, error handling and reproducibility
  of `ai/jev_audit.mjs` and `ai/verify.jl`. Cleanup completed: seed-runner batch files consolidated, debug output removed, probe files confirmed untracked.
- [ ] **Consistent documentation** — Compare examples and commands in `README.md`,
  `TUTORIAL.md`, `SPEC.md`, `SPEC-CORE.md`, `BOOTSTRAP.md` and `STATUS.md` with the
  actual behavior and with tests. All `examples/*.td` and `*.triad` files are
  were performed with Julia; also checked the CLI commands `--version`, `-E` and `--help`.
  Corrected text about distinct POSIX/Windows launcher fallbacks in the tutorial. The README
declares the packaging limit; the complete review of tutorial, specification and status of the
  bootstrap remains to be done.
- [x] **Repositories and artifacts** — Checked `.gitignore` (standalone binaries/cache ignored)
  and `.gitattributes` (binary seeds and hex dumps not normalized as text). I
  generators play both dumps: Windows SHA-256
  `445CB428EFF44B39C2103DF776E6D9A1D1B5BDD8904C2C93D661950321C4ED60`, Linux
  `AD4C9F08176D9964D5BE17D44C72230184434025980447395E7A3250F63CA5EA`; the decoded bytes
  coincide with versioned PE/ELF. Windows PE was intentionally updated
  along with the generator and its CI hash checker.
## How to log a new bug
For each issue reproduced, add an entry with:
1. area and files involved;
2. minimal command or steps to play it;
3. current result and expected result (reference to specification, if applicable);
4. Added or updated test that prevents regression.
---
# Task S1 (Triad Interpreter in Triad-Core)
### S1.3: Tagged value system
**Description:** Implement encoding/decoding to distinguish Int, Bool, String, Nothing, List in S1.
**Details:**
- Use seed encoding (Int: shifted/tagged, Bool: 1/5, String: heap object, List: heap object)
- Implement functions for check type (is_int, is_bool, is_string, is_list)
- Implement functions for encoding/decoding (int_value, bool_value, etc.)
- Test with mixed values in the environment
**Output:** S1 can correctly distinguish and manipulate all Triad-Core types
---
### S1.4: Inline parser/tokenizer
**Description:** Read source, tokenize and recognize numbers, identifiers, operators in S1.
**Details:**
- Read source string (hardcoded input or from file)
- Tokenize: numbers, identifiers, operators (+, -, *, ==, <, >), delimiters (, (, ), ;, newline)
- Recognize keywords (if, else, while, function, let, begin, end)
- Store tokens in list for parsing
**Output:** S1 can tokenize a Triad-Core program
---
### S1.5: Eval basic expressions
**Description:** Evaluate Int, Bool, String with inline environment in S1.
**Details:**
- Implement eval for integers (basic arithmetic)
- Implement eval for Bool (logical operators)
- Implement eval for String (concatenation, string())
- Use inline environment for variable lookups
- Test with complex expressions
**Output:** S1 can evaluate basic expressions with environment
---
### S1.8: Variables with let
**Description:** Extend environment to support scoped local bindings in S1.
**Details:**
- Implement let with local scope (shadowing)
- Manage environment like frame stack
- Support nested let with correct scope
- Test with multiple scopes
**Output:** S1 supports variables with let and local scope
---
### S1.11: Full parser
**Description:** Support if/else, while, function and all Triad-Core constructs in S1.
**Details:**
- Implement if/else parsing
- Implement while parsing
- Implement function parsing (short form and block)
- Implement let/begin parsing
- Generate AST or intermediate structure inline
**Output:** S1 can parse all Triad-Core constructs
---
### S1.12: Eval complete programs
**Description:** Evaluate sequential statements with environment in S1.
**Details:**
- Implement eval of sequential statements
- Manage persistent environment between statements
- Support full program execution
- Test with programs with multiple statements
**Output:** S1 can run complete Triad-Core programs
---
### S1.13: Functions and calls
**Description:** Define functions, parameters, returns and invocation in S1.
**Details:**
- Implement function definition
- Implement call functions with parameters
- Handle explicit and implicit returns
- Support basic recursive functions
**Output:** S1 supports defining and calling functions
---
### S1.14: Closures and recursion
**Description:** Support functions that capture environment in S1.
**Details:**
- Implement environment capture in closures
- Support full recursion
- Handle correct scope in closures
- Test with lambda and higher-order functions
**Output:** S1 supports closures and full recursion
---
### S1.15: Conformance test
**Description:** Run S1 on all Core cases and verify output.
**Details:**
- Run S1 on all 33 Core cases
- Check expected output for each case
- Fix bug in S1 if necessary
- Document past/failed cases
**Output:** S1 passes the full Core conformance suite
---
## Bootstrap Tasks (S2-S4)
### S2: Native compiler
**Description:** Design architecture to compile Triad to machine code.
**Details:**
- Design intermediate IR for Triad
- Implement x86-64 codegen
- Generate PE/ELF executables
- Test on Windows and Linux
**Output:** Native S2 compiler that generates machine code
---
### S3: Self-hosting
**Description:** Implement Triad compiler written in Triad.
**Details:**
- Rewrite S2 in Triad
- Compile S2 with S2 (bootstrap)
- Check fixed points
- Test complete self-hosting
**Output:** S3 self-hosted compiler
---
### S4: Runtime complete
**Description:** Implement REPL, CLI, tooling, Linux parity.
**Details:**
- Implement interactive REPL
- Implement CLI for file execution
- Add development tooling
- Bring Linux ELF seed
- Check Linux/Windows conformance parity
**Output:** Full S4 runtime with Linux/Windows parity
---
## Priority
1. S1.3 (tagged values) - foundation for S1
2. S1.4 (parser/tokenizer) - required to run programs
3. S1.5 (eval base) - interpreter base
4. S1.8 (variables with let) - scope and binding
5. S1.11 (full parser) - all constructs
6. S1.12 (eval programs) - complete execution
7. S1.13 (functions) - language power
8. S1.14 (closures) - functional completeness
9. S1.15 (conformance test) - S1 verification
10. S2-S4 (bootstrap) - final stage
## Notes
- S1 must be implemented inline (without helper functions) due to seed limitations
- Lists in the seed only support integers - use conventions for other types
- The S1 environment uses integers as keys (1="x", 2="y", etc.)
- All S1 tasks must be tested on Windows with the current seed
---
# New tasks generated by the 2026-10-25 audit
This section integrates the previous backlog with tasks that emerged from the examination of the sources and
from local evidence. In case of conflict with older historical summaries, the
code, specification, and results reproduced here.
## Initial evidence
- Graphify: index on commit `f589f89`, 686 nodes and 1,555 relations; covers mostly
  `triad.jl`, `syntax.jl`, tests and tools, but still doesn't adequately model `selfhost/`.
  Local files were then checked directly.
- Julia runtime: **281/281 tests**, **12/12 Full cases**, **33/33 Core cases** passed.
- Seed Windows: `if_else` prints `100` and exits `1`; `lists` exits `1`; `values` and `strings`
  they pass. The seed is not yet a full Triad-Core implementation.
- Windows CI currently inconsistent: `selfhost/main.td` prints `Value: 10`, while the job
  requires `[10, 20]`.
- S1 modules: `ast.td` is not parsed by the Full runtime; `eval.td` stack overflows;
  `main.td` depends on the `get` helper absent in the Full runtime; `env.td`, `heap.td` and
`interpreter.td` are prototypes, not components of a working interpreter.
## P0 — Restore a verifiable baseline
- [x] **A01 — Align self-hosted smoke test with CI**
  - **Files:** `selfhost/main.td`, `.github/workflows/ci.yml`.
  - **Work:** the case checks the lookup of the environment; the golden CI has been aligned
    to the actual output `Value: 10\n`, compared byte by byte. The name of the step makes it clear
    that this smoke test is not equivalent to the conformance of S1.
  - **Check:** local Windows seed: exit `0`, exact stdout `Value: 10\n`, empty stderr;
    the CI step checks exit code and expected bytes.
- [x] **A02 — Fix `if_else` in Windows seed**
  - **Files:** `seed/dev/gen_seed.js`, case `conformance/core/cases/if_else/`, CI and PE dump.
  - **Work:** distinguish `elseif` from `else` when scanning, evaluate conditions
    `elseif` in sequence and skip subsequent branches after the first selected branch.
  - **Check:** `if_else`, `if_elseif`, `if_nested` and `if_no_else` pass byte by byte
    on regenerated PE; exit `0`. Conformance Core Julia: All cases pass.
  - **Artifact:** PE 25088 bytes, code 8315 bytes, SHA-256 of `seed.hex`:
    `9987105DCD56F42A1AD73451821A281E6F24374ED6CE83993BB8CA56F5EC4822`.
- [x] **A03 — Delete invalid or recursive S1 modules**
  - **Files:** `selfhost/ast.td`, `selfhost/eval.td`, `selfhost/main.td`.
  - **Work:** remove `type AST = Int`, not present in the grammar; eliminate the
    recursive overriding of `string()` and the use of `/`, excluded from Core; don't use `get`
    as if it were a Full primitive.
  - **Acceptance:** every S1 source is valid Triad-Core, does not raise overflow and does not
    requires non-normative seed extensions; any obsolete files are removed.
  - **Closed 2026-11-02:** `type AST = Int` removed from `selfhost/ast.td` (constants
    now plain assignments; `make_call` uses the assign-then-return pattern so the
    seed accepts it); `selfhost/program.td` rewritten on the flat integer-token
    model (the old nested-token model was inconsistent and failed on its own test
    data) — it now prints `42\n7\n` on PE seed and JS; `string()` overrides and `/`
    were already absent; `get` is now a normative bootstrap primitive in
    `SPEC-CORE.md` §8 (problem row 2). The `conformance-core` CI job checks that
    every `selfhost/*.td` runs on the reference interpreter.
- [x] **A04 — Introduce a unique runner for the seed**
  - **File:** new development runner, `.github/workflows/ci.yml`, `conformance/`.
  - **Work:** replace manual list of 30 cases with directory discovery,
    Binary comparison of stdout and checking exit code, `args.txt` and stderr where applicable.
    Separate shared Core cases from tests specific to bootstrap primitives.
  - **Acceptance:** all present cases are executed automatically; a new case
    does not require changes to the CI; adding or modifying an incorrect golden causes the job to fail.
  - **Closed 2026-11-02:** the `seed-windows` job runs `node conformance/run.mjs
    --cases conformance/core/cases --skip liste` (directory discovery, byte-exact
    `expected.out`/`expected.golden`, `expected.code`, `args.txt`): the hardcoded
    list of 35 cases is gone; `gcd` and `valori` are now covered too. Bootstrap
    probes run via `node tests/probes/run_probes.mjs --strict` (ok_*/test_* must
    match seed vs JS and their optional golden) and `run_probes.mjs
    selfhost/source.td` checks the S1 front-end golden `selfhost/source.expected.out`.
- [ ] **A05 — Add negative cases and limits to Core conformance**
  - **File:** `conformance/core/cases/`, `SPEC-CORE.md` §9–§10, runner seed.
  - **Job:** cover out-of-range indexes, wrong types, undefined variables, module for
    zero, unreadable file, invalid CLI and diagnostics on stderr; add overflow,
    zero value and conversion limits where the specification defines them.
  - **Acceptance:** stdout, stderr normalized if necessary and exit code are checked;
    cases move to the Full runtime when applicable and to the seed after S0 completion.
- [ ] **A06 — Make CI mandatory before new milestones**
  - **File:** `.github/workflows/ci.yml`, `STATUS.md`.
  - **Job:** lane on current commit after A01–A04 and record run, commit and
    actual results; do not rely on historical runs cited in documents.
  - **Acceptance:** conformance, Julia test, Windows seed and Linux seed are all green;
    each antivirus exception remains limited to the optional step already provided.
## P0/P1 — Complete S0 as a Triad-Core interpreter
- [ ] **S0.1 — Define and test a uniform value model**
  - **File:** `seed/dev/gen_seed.js`, `SPEC-CORE.md` §3 and §5.
  - **Work:** distinguish String and Symbol today represented by the same object; make
    `==`, `!=`, `typeof`, `string()` and print consistent for Int, Bool, String, Symbol, List,
    Function and Nothing; explicitly handle zeros and signed integers.
  - **Acceptance:** heterogeneous and nested lists print correctly; conversions e
    mixed comparisons do not crash; symbols and strings with the same text remain different types.
- [ ] **S0.2 — Complete lists and regulatory indexing**
  - **File:** `seed/dev/gen_seed.js`, `list` cases and new Core cases.
  - **Work:** implement `xs[i]` 1-based read and assignment, `length`, `push!`
    on mixed values, structural equality and dynamic capacity; keep `get` just as
    internal extension or withdraw it from the sources intended for compliance.
  - **Acceptance:** the `lists` case and the new cases of mutation, nesting, empty list,
    limits and growth beyond 64 items pass without memory corruption.
- [ ] **S0.3 — Implement bootstrap strings and primitives**
  - **File:** `seed/dev/gen_seed.js`, seed specific tests.
  - **Work:** add escape `\n \t \" \\`, `length`, `readfile`, `strlen`, `strbyte`,
    `strsub` and `exit`; respect UTF-8 indices and bytes defined by `SPEC-CORE.md`.
  - **Acceptance:** byte-exact tests for empty strings, escapes, multibyte UTF-8, substrings
    at limits, I/O errors and reread content; no dependencies on Julia or Node at runtime.
- [ ] **S0.4 — Complete flow control, scopes and closures**
  - **File:** `seed/dev/gen_seed.js`, Core cases.
  - **Work:** implement explicit `return`, `break`, `continue`, `-=`, `*=`, lambda a
    zero/multiple parameters and multiple `let`; replace single/per-value capture with frame
    shared lexicons as required by the specification.
  - **Acceptance:** regressions for nested return, nested loops, shadowing, closure
    mutables with more binding, recursion and higher-order calls pass on the seed.
- [ ] **S0.5 — Complete CLI, `ARGS` and diagnostics**
  - **File:** `seed/dev/gen_seed.js`, `SPEC-CORE.md` §8–§10.
  - **Works:** support multiple and quoted arguments, `ARGS`, script from stdin with `-`,
    multi-argument `print`, stderr and exit `0/1/2`; prevent every error from ending without
    diagnostic message.
  - **Acceptance:** Windows cases with spaces in paths/arguments, stdin, invalid use, file
    missing and runtime errors produce expected streams and exit codes.
- [ ] **S0.6 — Make memory and seed parsers robust**
  - **File:** `seed/dev/gen_seed.js`, negative tests and development fuzz.
  - **Work:** check source, heap, frame, function and list bounds; manage arena
    exhausted and recursion; reject partial tokens/keywords, nested comments, and input
    malformed without reading past the buffers.
  - **Acceptance:** no crash or `STATUS_ILLEGAL_INSTRUCTION` in borderline cases; errors
    deterministic with exit `1`; PE layout, relocations and reproducibility remain verified.
- [ ] **S0.7 — Formally close the M3 milestone**
  - **Dependencies:** A01–A06 and S0.1–S0.6.
  - **Acceptance:** all positive and negative Core cases and all primitive tests
    bootstrap pass on the PE decoded from just `seed.hex`; `STATUS.md`, `BOOTSTRAP.md`,
    `seed/README.md`, `TUTORIAL.md`, dump and hash report the same status.
## P1 — Build S1 as a truly self-hosted deployment
- [ ] **S1.0 — Define architecture, format and unique entrypoint**
  - **Files:** `selfhost/`, `BOOTSTRAP.md`.
  - **Work:** consolidate prototypes into a pipeline `lexer → parser/AST → evaluator →
    runtime/CLI`; define encoding of values, nodes, environments and errors using only Core types.
    Determine how to compose the modules without an `include` not foreseen by the seed.
  - **Acceptance:** a versioned entrypoint loads and runs a minimal program via
    seed; each module has a contract and a test; no stubs presented as features.
- [ ] **S1.1 — Implement Triad-Full lexers and parsers in Core**
  - **Dependencies:** S0.3, S0.7, S1.0.
  - **Work:** tokenize all `SPEC.md` lexicon, build AST with positions,
    precedences, blocks, types, logical terms, quotas and macros; represent errors as data.
  - **Acceptance:** differential AST tests against `syntax.jl` for the entire grammar;
    Malformed input produces `Err(:syntax)` with row/column without terminating the seed.
- [ ] **S1.2 — Implement evaluators, environments and functions**
  - **Dependencies:** S0.4, S1.1.
  - **Work:** evaluate literals, operators, assignments, indexes, blocks, scope, closure,
    `return`/`break`/`continue`; implement generic functions, builtins and calls.
  - **Acceptance:** S1 runs above S0 all Core cases and Full evaluation tests without
    delegate parsing or evaluation to the Julia runtime.
- [ ] **S1.3 — Implement types, structs and multiple dispatch**
  - **Dependencies:** S1.2.
  - **Work:** represent hierarchy, declared constraints, conversions, immutable structs,
    method selection, builtin fallbacks, and ambiguity errors.
  - **Acceptance:** pass `dispatch`, `tasting` and regressions equivalent to those of
    `test/runtests.jl`, including Int→Float, redefinition and ambiguous signatures.
- [ ] **S1.4 — Implement the logic engine**
  - **Dependencies:** S1.2.
  - **Work:** facts/rules, terms, unification with occurs-check, trail/backtracking,
    negation, `is`, queries, solutions, limit/depth/steps and iterative engine.
  - **Acceptance:** pass `family`, `prolog`, recursive queries and budget/trace tests;
    no infinite logical recursion causes host or seed overflow.
- [ ] **S1.5 — Implement macros, errors, contracts, effects, budgets and tracks**
  - **Dependencies:** S1.2–S1.4.
  - **Work:** cover quasiquote/unquote, `Expr`, `eval`, `gensym`, `try`/`throw`, `Err`,
    `requires`/`ensures`, `with`, events and dynamic control of `io`/`state`.
  - **Acceptance:** pass `macro`, `macro_eval`, `error`, `core_guarantees`, `tour` and i
    corresponding semantic tests; Nested effects and budgets retain their scope.
- [ ] **S1.6 — Implement self-hosted CLI and REPL**
  - **Dependencies:** S1.2–S1.5, S0.5.
  - **Jobs:** replay `SPEC.md` §14: sorted options, `ARGS`, stdin, shebang, query
    interactive, REPL commands, diagnostics and exit codes.
  - **Acceptance:** the same CLI/REPL array as the Julia runtime passes to S1 above S0;
    `.triad` and `.td` files are equivalent.
- [ ] **S1.7 — Closing M4 without Julia**
  - **Dependencies:** S1.0–S1.6.
  - **Work:** implement `triad --conformance DIR` in Triad and use committed goldens;
    run all the examples and the 12 Full cases via the `seed.hex + S1` chain alone.
  - **Acceptance:** a CI lane performs compliance without installing Julia/Node; the
    result is byte-exact and the documentation clearly distinguishes stage0 and self-host.
## P2 — Compilation, portability and completion of the product
- [ ] **S2.1 — Specify native compiler IR and ABI**
  - **Dependencies:** S1.7.
  - **Job:** define value representation, frames, calls, allocation, runtime,
    PE/ELF layout, exceptions/checking and debug strategy before codegen.
  - **Acceptance:** Regulatory/implementation document with IR testing and full mapping
    of Triad constructs; no dependency on C/Rust/Julia in the final chain.
- [ ] **S2.2 — Implement x86-64 codegen and close M5**
  - **Dependencies:** S2.1.
  - **Work:** compile S1 into native Windows/Linux executables, link the runtime and
    add differential tests between interpreted S1 and compiled S1.
  - **Acceptance:** Compiled S1 passes all conformance without the seed; dumps and binaries
    playable, with testing on both platforms.
- [ ] **S3.1 — Demonstrate the fixed point and close M6**
  - **Dependencies:** S2.2.
  - **Work:** compile the compiler with itself for at least two generations and compare
    artifacts or canonical hashes; remove the seed from the normal build and use path.
  - **Acceptance:** generation N and N+1 equivalent, green conformance and procedure
    bootstrap documented and repeatable by clean checkout.
- [ ] **S4.1 — Port the full runtime to Linux and close M7**
  - **Dependencies:** S2.2; Don't limit yourself to the current ELF E0.
  - **Work:** Complete syscall/OS layer, files and arguments, REPL, diagnostics and tests
    multiplatform; evaluate macOS/ARM only as an explicit next milestone.
  - **Acceptance:** same Full/Core conformance, same examples and same green CLI on Windows
    and Linux without Julia; no cases silently skipped over.
## Transversal quality and recognition
- [ ] **Q01 — Create a requirement → implementation → test matrix**
  - **Files:** `SPEC.md`, `SPEC-CORE.md`, `test/`, `conformance/`.
  - **Work:** assign an ID to regulatory requirements and link them to positive/negative tests;
    complete the parser audit and explicitly report what is informative or not
    implemented.
  - **Acceptance:** each requirement has at least one verification or a reasoned open gap; the
    matrix is checked in CI to avoid references to non-existent tests.
- [ ] **Q02 — Realign all documentation to measured state**
  - **Files:** `TASK.md`, `STATUS.md`, `BOOTSTRAP.md`, `README.md`, `TUTORIAL.md`, `seed/`, `ai/`.
  - **Work:** fix contradictory counts, hashes, sizes, S0/S1 claims and roadmaps;
    also fix the tutorial code block around §19.5.5/§20 and the wording
    «S0 completed»; archive historical handoffs without using them as current state.
  - **Acceptance:** an automatic check gets counts/hashes from files and no documents
    active declares complete functionalities denied by tests.
- [ ] **Q03 — Make AI tools reproducible and up-to-date**
  - **Files:** `ai/jev_audit.mjs`, `ai/verify.jl`, prompts and tasks.
  - **Work:** replace hardcoded results 243/29/25 with generated data or parameters
    explicit; fix roles calling Core the Full runtime; test dry-run,errors
    API, absent paths and exit codes; keep generated outputs outside of Git.
  - **Acceptance:** local tests without network cover success and failure; no facts
    obsolete is sent as ground truth; benchmarks measure the declared profile.
- [ ] **Q04 — Complete or retire Julia standalone packaging**
  - **File:** `bin/build_standalone.jl`, launcher and documentation.
  - **Work:** create layout `Project.toml`/`src/Triad.jl` if keeping PackageCompiler,
    fix `c_driver_program`, precompilation and `--build`; otherwise remove the
    unsupported path without confusing it with self-hosted S2.
  - **Acceptance:** from a clean environment the executable starts without Julia installed and passes
    a CLI suite; or any reference to packaging is removed and the command is not promising
    a non-existent build.
- [ ] **Q05 — Validate and publish the tooling editor**
  - **File:** `editors/`, examples and grammar.
  - **Work:** Automatically test TextMate/Vim tokens on all constructs and on
    `.triad`/`.td`; verify VSIX package and installation; prepare the PR Linguist without
    appropriate the `.td` extension of LLVM TableGen.
  - **Acceptance:** green grammars test, installable package, instructions
    reproduced and the status of external publications recorded separately from the code.
- [ ] **Q06 — Clean up and secure the repository**
  - **Files:** `.gitignore`, `.gitattributes`, `.vs/`, probe and `test_*.td` in the root, `out.txt`.
  - **Work:** move useful probes into structured tests, eliminate IDE and output artifacts
    empty from versioning, ignore `.vs/` and other local directories; preserve seed dumps
    as sources and check their hashes.
  - **Acceptance:** clean checkout without personal caches; no regression lost during
    displacement; CI ensures that generated binaries and reports are not pushed back into Git.
## Libro — Fondamenta per principianti (2026-11-01)
- [x] **Fondamenta: programmare da zero** (`docs/FONDAMENTA.it.md`): parte del libro per chi non
  ha mai programmato, inclusa nel volume (`build-libro.mjs`, `build-epub.cjs`); esempi Core
  verificati con `seed/dev/triad_core.cjs`; PDF/EPUB/MOBI/DOCX/DOC rigenerati in `docs/libro/`
  (`Il-libro-di-triad.doc` Word 97 via LibreOffice). Comprende: cap. 13 «Pensare da
  programmatore», cap. 17 «Domande da neofita», Appendice A (installazione guidata),
  Appendice B (scheda rapida della sintassi).
- [x] **Pipeline PDF** (`scripts/docs/build-pdf.mjs`): sostituisce `ebook-convert` per il PDF
  (il writer calibre corrompe i glifi composti → tofu sulle accentate).
- [ ] **Rigenerare il libro inglese** (`docs/libro/Il-libro-di-triad.en.*`): la traduzione non
  include ancora le Fondamenta; aggiornare `_translation_progress.json` e ripartire dal nuovo
  testo.
- [ ] **Traduzione delle Fondamenta** in inglese (`docs/FONDAMENTA.md`) per il libro EN e il sito.

## Libro — dati aggiuntivi estratti dal codice per Sessione 1 / mimo (2026-11-01)
- [x] **`docs/libro/_dati_dal_codice.md`**: scheda di dati per la scrittura del libro ottenuta
  **solo da lettura del codice** (`seed/dev/gen_seed.js`, `seed/dev/triad_core.cjs`,
  `selfhost/value.td`, `conformance/run.mjs`) ed esecuzione misurata dei due runtime — nessun
  dato preso da SPEC/MANUALE. Contiene: schema tag dei valori del seed (Int = n<<2, ecc.),
  limiti strutturali (sorgente ≤ 61440 byte, liste ≤ 64 elementi, funzioni ≤ 512, parametri ≤ 64,
  heap ~64 KiB), fatti di lexer, precedenza operatori, matrice built-in e **27 divergenze misurate
  seed ↔ interprete JS** con output ed exit code.
- [x] **`docs/libro/_sonde/`** (27 sonde `.td`): riproducono ogni divergenza; eseguibili con
  `./seed/windows-x86_64/seed.exe <sonda>` e `node seed/dev/triad_core.cjs <sonda>`.
- [x] **Dati nuovi emersi e da presidiare**: il caso `liste` della conformance è **saltato di
  default** (`conformance/run.mjs:34`, `skip = ['liste']`); `get(xs,i)` è 0-based sul seed e
  assente dal JS, `xs[i]` è 1-based sul JS e assente dal seed; `string(true)` → `1` sul seed;
  `1 % 0` → exit 127 (crash) sul seed; letterali interi nel seed limitati a 2^61-1;
  funzione a blocco che termina con `println` restituisce `0` (seed) / `nothing` (JS).

- [x] **Dati portati nel libro e PDF rigenerato (2026-11-01)**: aggiunte 10 «Nota di
  implementazione» in `docs/MANUALE.it.md` (§1.2 numeri/underscore/2^61-1, §1.10 escape,
  §2.7 condizioni non-Bool, §2.8 stampa, §4.1 wrap e `% 0`, §9 indici e `push!`, §10 conversioni,
  §27.1 exit code del seed) e 2 in `docs/FONDAMENTA.it.md` (cap. 6 escape, cap. 9 liste);
  rigenerati `docs/libro/libro.html` e `docs/libro/Il-libro-di-triad.pdf` (305 pagine, note
  verificate estraendo il testo dal PDF). Restano da rigenerare gli altri formati
  (`docx/epub/mobi`) se servono allineati.

## Libro — cap. 8 «Ripetizioni» riscritto con verifica su entrambi i runtime (2026-11-01)
- [x] **Esercizi del cap. 8 divisi per sottogenere** (`docs/FONDAMENTA.it.md`): contatore,
  accumulatore, ricerca/decisione, cicli annidati, sentinella — 10 task con soluzioni, ogni
  esempio eseguito sul seed PE **e** sull'interprete JS con output identico byte per byte.
- [x] **Nuovi casi di conformance** `while_annidati` (break sul ciclo più interno, uscita con
  variabile di stato) e `while_sentinella` (`while true` + `break`), verdi su entrambi i
  runtime; aggiunti alla lista della CI `seed-windows`. Core: 39/39.
- [x] **Gap del seed scoperti scrivendo gli esempi** (tutti già in «Colmare i limiti del
  seed», qui è il riscontro misurato): `continue` → exit 1 sul PE; `-=`/`*=` → exit 1;
  `while` come espressione → exit 1; `voti[i]` non seleziona l'elemento (il libro lo segnala
  con una nota di implementazione e rimanda a TASK.md S0.2); condizione `while` non-`Bool`:
  il PE salta il corpo silenziosamente, il JS reference segnala errore (divergenza da chiudere
  con un caso negativo di conformance).
- [ ] **Caso negativo di conformance per la condizione non-`Bool`** e per lo scope del corpo
  `while`: i due runtime si comportano in modo diverso e nessuno dei due è allineato a
  `SPEC.md` §4/§5. Servono decisioni normative prima di fissare i golden.

## Sito generato da Triad (2026-11-01)
- [x] **Generatore del sito in Triad** (`tools/site-gen/`): `site_pages.td` (8 pagine di
  documentazione), `site_playground.td` (playground), `site_style.td` (foglio di stile);
  `build.mjs` esegue ogni generatore sul seed PE nativo e sull'interprete di riferimento JS e
  pretende stdout identico byte per byte; `lint.mjs` blocca i costrutti che il seed non
  esegue; CI `site-gen` (Ubuntu + Windows) verifica lint e sincronia. Sottoinsieme
  certificato e limiti misurati del seed: `tests/probes/README.md`.
- [x] **Chiarire in `SPEC-CORE.md` §2 se una stringa può contenere un newline grezzo.**
  Deciso il 2026-11-02: **ammesso** — il letterale va a capo e il newline fa parte
  del valore (documentato in §2); entrambi i runtime lo accettano e vietarlo
  richiederebbe casi negativi e un cambiamento dei runtime. Allineare S1 non serve:
  lo scanner di `selfhost/source.td` lo accetta già.
  I due runtime attuali lo accettano (i generatori del sito lo usavano), ma la specifica
  prevede `\n` come escape: è una delle poche cose che il generatore evita dopo la
  verifica. Decidere (spec o divieto esplicito) e allineare S1.
- [ ] **Colmare i limiti del seed** rilevati scrivendo i generatori (tutti consentiti da
  `SPEC-CORE.md` §2–§7, quindi lacune del seed, non della lingua): `print` e `println`
  multi-argomento; `return` nelle funzioni a blocco; chiamata come ultima espressione del
  corpo; escape nelle stringhe; `let` con più binding; `readfile`/`strlen`/`strbyte`/`strsub`;
  indice di lista e `length(lista)`; riferimenti in avanti; letterale con la sottostringa
  `if` dentro un blocco (il contatore di annidamento conta le occorrenze nel testo). Ogni
  limite è un candidato per la prossima tappa «A» del seed, con caso di conformance.
- [x] **Rigenerare le pagine mancanti del sito**: `ai.html`, `apprendimento.html`,
  `license.html` erano linkate dal NAV di `docs/assets/js/app.js` ma non esistevono; ora sono
  generate come le altre (`tools/site-gen/site_pages2.td`). Verificato: 182 link interni del
  sito, nessuno rotto.

## Libro — margini KDP conformi per la stampa (2026-11-01)
- [x] **Gutter KDP nel PDF del libro**: KDP aveva rifiutato l'interno del volume (305 pagine →
  gutter minimo 0.625"/15.875mm per la fascia 301–400, margini esterno/superiore/inferiore
  ≥ 0.25"/6.35mm) perché `scripts/docs/build-libro.mjs` usava `margin: 15mm 12mm` uniformi,
  senza gutter specchiato. Ora `@page` usa margini specchiati (gutter 19.05mm = 0.75"
  all'interno, 10mm all'esterno, 15mm sopra/sotto; `@page :left` sposta il gutter a destra
  nelle pagine pari) — verificato sperimentalmente che Chrome 156 rispetta `:left`/`:right`.
  Rimosso anche l'header/footer template di puppeteer: riservava fascia ai margini e
  duplicava i numeri di pagina (stampando anche "1" sulla copertina). I numeri arrivano ora
  solo dalla margin box CSS `@bottom-center` (nessuno sulla copertina via `@page :first`),
  con `padding-bottom: 4mm` che li tiene a ≥ 6.35mm dal taglio. Volume risultante:
  293 pagine. Misurato sul PDF con PyMuPDF: gutter reale min 20.94mm, esterno 9.79mm,
  sopra 15.67mm, sotto 7.78mm — tutti ≥ i minimi KDP, con slack anche per la fascia
  401–500 pagine (0.75").
- [x] **Verifica margini KDP automatica in `scripts/docs/build-pdf.mjs`**: dopo la generazione
  conta le pagine del PDF e confronta i margini `@page` dell'HTML con la tabella KDP
  (24–150: 0.375", 151–300: 0.5", 301–400: 0.625", 401–500: 0.75", 501–700: 0.875",
  701–828: 1"; esterno/sopra/sotto ≥ 0.25"); esce con codice 3 se non conformi.
  Accetta argomenti opzionali input/output (`node scripts/docs/build-pdf.mjs in.html out.pdf`)
  per rigenerare anche il PDF inglese.
- [x] **DOCX e inglese allineati**: `scripts/docs/build-docx.cjs` con margini laterali simmetrici
  da 19.05mm (1080 twips; html-to-docx non scrive `w:mirrorMargins`, quindi il gutter non puo'
  essere specchiato) e attributi header/footer/gutter espliciti (prima venivano scritti
  `w:header="undefined"`, OOXML invalido). Stesso blocco `@page` aggiornato in
  `docs/libro/Il-libro-di-triad.en.html` e `docs/libro/chunk1.html`. Rigenerati
  `docs/libro/libro.html`, `Il-libro-di-triad.pdf` (293 pagine), `Il-libro-di-triad.en.pdf`,
  `libro.docx`. Da rigenerare via LibreOffice `Il-libro-di-triad.doc` (Word 97) se serve.

## Libro — allineamento uniforme di tutte le pagine (2026-11-01)
- [x] **Margini equi e geometria identica su ogni pagina**: con i margini specchiati il blocco
  del testo e i numeri di pagina si alternavano recto/verso (testo a L12.09/R20.95mm sulle
  pari e L21.08/R11.96mm sulle dispari; numeri che oscillavano di ~9mm tra x=71.81 e x=80.83,
  mai centrati sulla pagina). Ora `@page` ha margini uguali su tutti i lati
  (`margin: 19.05mm`, 0.75") senza `@page :left`: ogni pagina ha la stessa identica
  impaginatura. Verificato sul PDF con PyMuPDF: numeri di pagina centrati a 76.20mm su
  tutte le 282 pagine (varianza 0), margini di contenuto minimi 20.93mm (sin), 19.05mm
  (des), 19.59mm (sup), 20.12mm (inf) — tutti ≥ i minimi KDP (gutter 12.7mm per 282 pagine,
  19.05mm copre anche la fascia 401–500). 0.75" su tutti i lati mantiene il volume conforme
  anche se cresce oltre 400 pagine. Allineati anche `Il-libro-di-triad.en.html`,
  `chunk1.html` e `build-docx.cjs` (1080 twips = 19.05mm su tutti i lati); rigenerati
  `libro.html`, i due PDF e `libro.docx`. Nota: la riflessione Chrome passa da 293 a 282
  pagine con la nuova scatola di testo (contenuto verificato identico: 58.548 parole,
  nessun clipping); la copertina resta a vivo (`@page :first`), unica eccezione voluta.

## Libro — copertina centrata e scala di stampa 1:1 (2026-11-01)
- [x] **Copertina impaginata al centro**: la prima pagina mostrava l'immagine rimpicciolita
  (135.31x202.97mm) e spinta in alto a sinistra con ~17mm di bianco a destra e ~26mm in basso.
  Causa reale NON centratura: Chrome riduceva l'**intero documento** a scala 0.88789
  (misurato: font di corpo a 9.32pt invece di 10.5pt) perché una tabella del Tutorial
  (§15, confronto interprete JS / seed Windows) sforava la colonna (min-content 475px vs
  432px disponibili): i token lunghi (`seed/windows-x86_64/README.md`, hash) non andavano a
  capo. Aggiunto `overflow-wrap: anywhere` a `code` e `th, td` in `build-libro.mjs`,
  `Il-libro-di-triad.en.html`, `chunk1.html` (anche `anywhere` e non `break-word` perche'
  abbassa la min-content). Verificato sul PDF rigenerato: copertina a vivo esatta
  152.40x228.60mm a (0,0) — centrata per costruzione, font 10.5pt/9pt, numeri di pagina
  centrati a 76.20mm su tutte le pagine. Il volume torna a scala reale: **378 pagine**
  (prima 282 "zoomate"; il PDF caricato su KDP con 305 pagine era pure scalato 0.88789).
  Margini KDP: 378 pagine → fascia 301-400 → gutter min 15.875mm, misurati 19.05mm;
  residuo sforo di 1.4mm su p.356 dovuto a spazi finali invisibili di un `pre` (17.65mm,
  comunque oltre il minimo KDP). Rigenerati anche `Il-libro-di-triad.en.pdf` e `libro.docx`.

## Recommended execution order
1. **A01–A06:** First a reliable CI on the real state.
2. **S0.1–S0.7:** Complete the Core contract before expanding S1.
3. **S1.0–S1.7:** a single end-to-end verified self-hosted interpreter.
4. **S2.1–S4.1:** Linux compilation, fixed point and parity.
5. **Q01–Q06:** transversal activities, anticipated when they unlock checks or releases.
# Problemi aperti per complessità (2026-11-02)

Problemi emersi dalla sessione sul front-end S1 (`selfhost/source.td`) e dai
limiti misurati sul seed, **ordinati per complessità crescente** (sforzo di
implementazione + rischio: si passa da azioni minuti a settimane con processo
normativo). Ogni voce riporta l'evidenza (probe) e dove si interviene.

**Scala:** C0 = azione/documento (minuti) · C1 = codice di supporto — JS/tests/CI
(ore) · C2 = generatore del seed + rebuild PE/ELF + hash CI (mezza giornata) ·
C3 = memoria/stringhe del seed in assembly (giornate) · C4 = semantica SPEC +
allineamento runtime + tappa S1 (settimane).

| # | C | Problema | Evidenza | Intervento |
|---|---|---|---|---|
| 1 | C0 | Il PAT rimosso da `.git-credentials` va **ruotato** su GitHub: va considerato esposto | `docs/security/SECURITY-REVIEW.md` #5 | azione umana (GitHub → revoca/rotazione) |
| 2 ✅ | C0 | `get(xs, i)` è nel codice macchina e nel riferimento JS ma **non in `SPEC-CORE.md` §8**: ambiguità reale da chiudere (aggiungerlo a §8 o dichiararlo non standard) | `tests/probes/test_get.td` | chiarimento normativo (una riga in §8 + nota §11) — **fatto 2026-11-02** |
| 3 ✅ | C1 | Letterali di lista su più righe: il parser JS li rifiuta (`parse error: SEP`), il seed li accetta | `tests/probes/bad_lista_multiriga.td` | `seed/dev/triad_core.cjs`: saltare i separatori dentro `[ ... ]` + ribaltare il probe in `ok_` — **fatto 2026-11-02** |
| 4 ✅ | C1 | `a ? b :c` (due punti attaccato al ramo): il lexer di `selfhost/source.td` legge `:c` come simbolo; il codice macchina risolve dal contesto | `selfhost/source.td` (divergenze, header) | reinterpretare il token SYM come `:` nel ramo ternario (parser) — **fatto 2026-11-02** anche nel parser JS |
| 5 ✅ | C1 | Simboli operatore del lessico Core (`:+`) non nel dominio del codice macchina | header `selfhost/source.td` | supersett nello scanner di `selfhost/source.td` (l'esecuzione resta ai punti 7/11) — **scanner fatto 2026-11-02** |
| 6 ✅ | C1 | Verifiche non agganciate alla CI: golden del front-end S1 e suite `tests/security` | `conformance/OK` locale | `.github/workflows/ci.yml`: `run_probes.mjs selfhost/source.td` + diff golden nello smoke `seed-windows`; `tests/security/run.sh` in una lane — **fatto 2026-11-02** |
| 7 | C2 | `-=` e `*=`: previsti dal lessico Core e accettati dal parser S1, il seed valuta solo `+=` | `STATUS.md` (limiti), probe `p6` della sessione | `seed/dev/gen_seed.js`: `st_sub_check`/`st_mul_check` simmetriche a `st_add_check`; rebuild PE/ELF, hash CI, conformance |
| 8 | C2 | Massimo **4 parametri** per funzione nel seed (record da 64 byte, 16 per parametro) | `tests/probes/bad_parametri_5.td` | `gen_seed.js`: allargare gli slot del record (o più record); rebuild + hash CI |
| 9 | C2 | Junk a destra del corpo di funzione breve: il seed ignora il resto riga, il parser S1 produce `ERR` | header `selfhost/source.td` | tracciare i separatori nello scanner S1 (token SEP o contatore riga) e consumare fino a fine riga |
| 10 | C3 | **Heap liste**: 528 byte irrecuperabili per ogni valutazione di letterale (64 KB totali; ~60/run ok, 150 = crash) | `tests/probes/bad_lista_alloc.td` | allocator con riuso o slab in `gen_seed.js`; sblocca AST come dato e vettori di token in S1 |
| 11 | C3 | Stringhe del seed: escape `\n \t \" \` assenti, `==` sempre `false`, `+=` corrompe | `bad_escape_stringa.td`, `bad_confronto_stringa.td`, `bad_stringa_plus_equals.td` | valutatore stringhe in `gen_seed.js` (escape in `pf_string`, confronto per contenuto, concat in `+=`) |
| 12 | C4 | **Scope dei nomi**: il seed è dinamico (il callee vede i locali del chiamante), il JS è lessicale, `SPEC-CORE.md` §4 non decide | `tests/probes/bad_scope_dinamico.td` | 1) decisione normativa in §4; 2) allineamento di un runtime (cambia la semantica dei programmi con omonimi nei frame) |
| 13 | C4 | S1.5 (eval) e AST come dato: richiedono §8 (`strlen`/`strbyte`/`strsub`/`readfile`) nel seed e/o il punto 10 | `BOOTSTRAP.md` S1, `SPEC-CORE.md` §8 | tappa S1 successiva: valutatore in Triad-Core sui token dell'algoritmo attuale |
| 14 | C2 | Identificatori con **iniziale maiuscola** (`Ab = 0`): il seed esce con 1, il JS li accetta; `aB` funziona (solo la classe di start del seed è `[a-z_]`); SPEC-CORE §2 ammette `[A-Za-z]` | `tests/probes/bad_identificatore_maiuscolo.td` | `gen_seed.js`: allargare la classe di start di `parse_ident` a `[A-Za-z_]`; rebuild PE/ELF, hash CI, conformance |
| 15 | C4 | Separatore newline dopo un operatore: il seed prosegue l'espressione (`x = 1` + `-2` = `-1`), il JS separa gli statement; SPEC-CORE §2 elenca il newline come separatore ma non decide la continuazione dopo un operatore | `tests/probes/bad_separatore_newline.td` | decisione normativa su §2/§4 (quando il newline continua l'espressione) + allineamento di un runtime |

### Chiusi il 2026-11-02 (righe 2–6 della tabella, A03, A04)
- **Riga 2 (`get`)**: aggiunta `get(xs, i)` a `SPEC-CORE.md` §8 come primitiva di
  bootstrap a indice **0-based**, con nota che la distingue da `xs[i]` (§7, 1-based)
  e che i casi di `conformance/core/` non la usano (§11). Risolve anche il vincolo
  «non usare `get` come se fosse una primitiva Full» di A03.
- **Riga 3 (liste multi-riga)**: `seed/dev/triad_core.cjs` tratta i newline come
  trivia dentro `[ ... ]` (con contatore di profondità dei bracket); probe ribaltato
  in `ok_lista_multiriga.td`. Il trailing comma resta errore su entrambi i runtime.
  Divergenze residue sui newline: vedi riga 15.
- **Riga 4 (`? :c`)**: reinterpretazione del token SYM come colon in posizione di
  operatore sia in `selfhost/source.td` (root_pos con `td > 0` + colon check in
  `parse_expr`, con avanzamento di un solo byte oltre i trivia) sia nel parser JS
  (splice `COLON` + resto in `parseTernary`). Probe `ok_ternario_colon_attacco.td`
  (7/8 identici su PE e JS) e nuovo chunk c8 nel sorgente di test di `source.td`
  (ternario annidato con due colon attaccati); golden rigenerato e verificato su
  entrambi i runtime.
- **Riga 5 (`:+`)**: scanner di `selfhost/source.td` accetta dopo `:` una corsa di
  caratteri operatore come nome simbolo (`is_opc`), superset del dominio del codice
  macchina. Probe `bad_simbolo_operatore.td` documenta che il seed lo rifiuta ancora.
- **Riga 6 (CI)**: job `security` (`tests/security/run.sh`), step
  `run_probes.mjs --strict` + `run_probes.mjs selfhost/source.td` nel job
  `seed-windows`, step di validità di tutti i `selfhost/*.td` in `conformance-core`.
- **A03/A04**: vedi le note nelle rispettive voci sopra.

Residui di sessioni precedenti (non del front-end, non bloccanti): Critical di
complessità/lint (`docs/security/TRIAGE-SEVERITY.md` rec. 3–5), CodeQL #128 da
chiudere al push del commit `0f4d106`.

## Sotto-task dalle note di sessione (2026-11-02)

Sotto-task derivati dalle note «Note e rinvii» del 2026-11-02 e dalle nuove
divergenze misurate (righe 14–15). Regola di lettura: N01/N03/N04/N05 sono
meccaniche (`gen_seed.js`) e **conviene raggrupparle in un unico ciclo di
rebuild PE/ELF + hash CI**; N02/N08 richiedono invece una decisione normativa
prima del codice (regola operativa 1: non inventare semantica); N09 è
l'abilitatore di tutti i rebuild verificabili senza Windows; N10 è azione umana.
Ogni sotto-task ha verifica locale su PE (wine) **e** interprete JS.
Mappatura con la tabella dei problemi: riga 1 → N10, riga 7 → N04,
riga 8 → N05, riga 10 → N07, riga 11 → N06, riga 12 → N08, riga 14 → N01,
riga 15 → N02; il caso `liste` skippato → N03.

### N01 — ✅ Identificatori con iniziale maiuscola nel seed (riga 14, C2, fatto 2026-11-02)
- **Files:** `seed/dev/gen_seed.js` (`parse_ident`), PE/ELF + `seed.hex`, hash in
  `.github/workflows/ci.yml`, `tests/probes/`.
- **Work:** allargare la classe di START dell'identificatore da `[a-z_]` a
  `[A-Za-z_]` (la classe di continuazione accetta già le maiuscole: `aB` funziona);
  la tabella delle keyword resta solo minuscola (`IF` non è keyword). Rebuild
  PE/ELF, aggiornare i due hash della CI.
- **Acceptance:** probe ribaltato in `ok_identificatore_maiuscolo.td` e identico
  sui due runtime; casi Core e probe `ok_*`/`test_*` verdi sul PE rigenerato;
  dump riproducibili dai generatori.
- **Closed 2026-11-02:** il difetto NON era in `parse_ident` (fa già case-folding)
  ma in due test del primo byte senza folding: `stmt_assign` (dispatch statement:
  `A = 0` diventava expression statement e falliva) e `sym_scan` (`:Ab`: il
  `jb('sym_digit')` sul test `a-z` catturava `A-Z` prima del ramo `A-Z`, codice
  morto). Entrambi ora usano il folding `or 0x20` come `parse_ident`. Verificato
  anche: iniziali maiuscole nei corpi di funzione (come il caso minuscolo),
  keyword solo minuscole (`IF = 5` → identificatore), `:Ab` = Symbol. Nuovo
  PE 25088 byte, SHA-256 `seed.hex`: `4235A70790BAA6784DC3D944616705B37E76ED2263CE73210BCC20E53639B8F7`.
- **Scoperta collegata (bug confermato, risolto dal rebuild):** `gen_seed.js`
  **non** riproduceva `seed.hex` (1705 byte di drift): il commit CodeQL `649709a`
  (2026-10-31) aveva fixato `testRcx` → `testRcx()` in `pf_call` (il cap check
  delle chiusure era corrotto) senza rigenerare gli artefatti. Il PE versionato
  conteneva il bug; il rebuild ripristina il contratto di riproducibilità.
  Riproduzione: `node seed/dev/gen_seed.js /tmp/x.hex && cmp /tmp/x.hex
  seed/windows-x86_64/seed.hex` (le differenze iniziano a `0x22f`, nei
  displacement dei salti che attraversano il punto d'inserzione in `pf_call` a
  `0x1c8b`: tutti gli shift di ±3 byte coerenti con l'inserimento di
  `test rcx,rcx`). Storia verificata byte-per-byte e raccolta in
  `docs/adr/0001-immutabilita-pe-riproducibilita-dump.md`.

### N02 — Newline: decisione normativa e allineamento (riga 15, C4)
- **Files:** `SPEC-CORE.md` §2/§4, `conformance/core/cases/`, poi un runtime.
- **Work:** decidere quando un newline **continua** l'espressione (dopo un
  operatore binario? dentro `()`/`[]`?) e quando **separa** gli statement;
  scrivere la regola in §2/§4; aggiungere casi `newline_continua` e
  `newline_separa`; allineare il runtime non conforme.
- **Dipendenze:** decisione normativa (umana) PRIMA del codice.
- **Acceptance:** casi newline verdi identici su PE e JS;
  `bad_separatore_newline.td` non documenta più una divergenza.

### N03 — `xs[i]` 1-based e sblocco del caso `liste` (C2, sottoinsieme di S0.2)
- **Files:** `seed/dev/gen_seed.js`, `conformance/run.mjs` (skip `liste`), CI.
- **Work:** implementare la lettura `xs[i]` (1-based) e la scrittura `xs[i] = v`
  nel seed (il JS già le ha); verificare `length`/`push!` esistenti; rimuovere
  `skip = ['liste']` dal runner e dai comandi CI.
- **Acceptance:** `conformance/core/cases/liste` verde byte-exatto sul PE senza
  skip; indici fuori intervallo e `0` → exit 1 + stderr (collegato a A05).

### N04 — `-=` e `*=` nel seed (riga 7, C2)
- **Files:** `seed/dev/gen_seed.js` (`st_sub_check`/`st_mul_check` simmetriche a
  `st_add_check`), PE/ELF, hash CI, `tests/probes/`, casi Core.
- **Work:** comporre assegnazione e operazione con wrap-around 64 bit firmato,
  come `+=`; caso di conformance `assegnazioni_composte` su entrambi i runtime.
- **Acceptance:** `-=`/`*=` producono gli stessi valori del JS; nessun caso
  regresso fra i 38 Core.

### N05 — Funzioni con più di 4 parametri (riga 8, C2)
- **Files:** `seed/dev/gen_seed.js` (record funzione da 64 byte, 16 per parametro),
  PE/ELF, hash CI, `tests/probes/`.
- **Work:** allargare gli slot del record (o impiegare più record) fino a 8+
  parametri; verificare ricorsione e chiamate con argomenti misti.
- **Acceptance:** `bad_parametri_5.td` ribaltato in `ok_`; caso con 6–8 parametri
  verificato identico sui due runtime.

### N06 — Stringhe del seed: escape, `==`, `+=` (riga 11, C3)
- **Files:** `seed/dev/gen_seed.js` (`pf_string`, valutatore stringhe), PE/ELF,
  hash CI, `tests/probes/`, `SPEC-CORE.md` §2.
- **Work:** escape `\n \t \" \\` nei letterali; `==`/`!=` per contenuto (oggi
  sempre `false`); `+=` come concatenazione (oggi corrompe); rispettare gli
  indici in byte UTF-8 di §2 (collegato a S0.3).
- **Acceptance:** `bad_escape_stringa.td`, `bad_confronto_stringa.td`,
  `bad_stringa_plus_equals.td` ribaltati; stringhe vuote, escape ai limiti e
  multibyte verificati byte per byte.

### N07 — Heap liste riutilizzabile (riga 10, C3)
- **Files:** `seed/dev/gen_seed.js` (bump allocator → riuso/slab per i valori di
  lista), PE/ELF, hash CI, `tests/probes/`.
- **Work:** riusare la memoria dei letterali di lista quando il valore non è più
  referenziato (oggi 528 byte irrecuperabili per valutazione, ~60/run, ~150 =
  crash); misurare il limite residuo.
- **Acceptance:** `bad_lista_alloc.td` (150 valutazioni) termina con exit 0 senza
  crash; sblocca vettori di token e AST come dato in S1.

### N08 — Scope dei nomi: decisione normativa (riga 12, C4)
- **Files:** `SPEC-CORE.md` §4, poi un runtime fra `seed/dev/gen_seed.js` e
  `seed/dev/triad_core.cjs`, `tests/probes/`.
- **Work:** decidere se lo scope è lessicale (JS, maggioranza dei linguaggi) o
  dinamico (seed: `env_find` vede i locali del chiamante); scrivere la regola in
  §4; allineare il runtime non conforme; documentare l'impatto sui programmi con
  omonimi nei frame.
- **Dipendenze:** decisione normativa (umana) PRIMA del codice.
- **Acceptance:** `bad_scope_dinamico.td` non documenta più una divergenza; i
  programmi con shadowing fra chiamante e chiamato hanno comportamento unico e
  specificato.

### N09 — ✅ Harness di verifica locale del PE via wine (C1, abilitatore, fatto 2026-11-02)
- **Files:** `scripts/seed-runner/seed-wine.sh` (nuovo; path rifinito rispetto a
  `scripts/dev/`: la cartella `scripts/seed-runner/` ospita già il runner Windows
  `run_seed.bat`), `tests/probes/README.md`, `seed/README.md`.
- **Work:** formalizzare la procedura usata in sessione: decodificare
  `seed/windows-x86_64/seed.hex` in un PE temporaneo ed eseguirlo con
  `WINEDEBUG=-all wine`, esportando `TRIAD_SEED` per `conformance/run.mjs` e
  `tests/probes/run_probes.mjs` (che già lo accettano). Un solo comando ripete
  conformance + probes su Linux.
- **Acceptance:** da un checkout pulito, un comando su Linux esegue la
  conformance Core e i probe sul PE nativo senza Windows; la CI resta invariata
  (su Windows il seed gira nativo).
- **Closed 2026-11-02:** `scripts/seed-runner/seed-wine.sh` con tre modalità
  (`FILE.td [ARG...]`, `--check`, `--help`) e cache del PE in
  `~/.cache/triad2.0/seed-wine` invalidata al cambio di SHA-256 di `seed.hex`
  (verificata: cache hit, invalidazione, ripristino del marker). `--check` da
  cache pulita: conformance Core OK (38 casi, `liste` skippata), 17 probe
  `ok_*`/`test_*` con 0 differenze, golden `selfhost/source.expected.out`
  confermato. Documentato in `seed/README.md` e `tests/probes/README.md`.

### N10 — Rotazione del PAT esposto (riga 1, C0, azione umana)
- **Files:** nessuno nel repository; `docs/security/SECURITY-REVIEW.md` #5,
  `tests/security/no_live_tokens.test.py`.
- **Work (manuale):** GitHub → Settings → Developer settings → Personal access
  tokens: revocare il PAT rimosso da `.git-credentials` e generarne uno nuovo;
  riconfigurare le credenziali locali FUORI dal repository (come da
  `.git-credentials.example`).
- **Acceptance:** il vecchio PAT risulta revocato; nessun token nel working tree
  o negli URL di git (`sh tests/security/run.sh` verde).

### Ordine suggerito
> **Aggiornamento 2026-11-03:** la task principale «seed Linux nativo senza Wine»
> (N15–N18, sezione in testa al file) **precede N03**; N03/N04/N05 restano raggruppate
> in un unico ciclo di rebuild PE/ELF + hash CI dopo N15–N17.
1. **N09** (abilitatore, minuti) → 2. **N15–N18** (task principale, vedi sopra) →
  3. **N03+N04+N05** in un unico rebuild + hash CI (N01 chiuso; mezza giornata) →
  4. **N10** (azione umana, indipendente) → 5. **N02** e **N08** dopo le decisioni
  normative → 6. **N06+N07** (C3, giorni).

## Sotto-task dalle note di sessione (2026-11-03)

Sotto-task derivati dalle note di chiusura delle due lavorazioni del 2026-11-03:
(1) libro fuori dal repo (`.gitignore` con `/docs/libro/` + `git rm --cached` dei
3 artefatti tracciati) e (2) fix CodeQL TOCTOU in `tools/site-gen/build.mjs`.
N11 è meccanico (stessa rimediazione già applicata in `build.mjs`); N12 è la
verifica di chiusura dell'alert dopo il push; N13 e N14 richiedono una decisione
(regola operativa 1: non inventare semantica — qui: non committare né rimuovere
senza conferma).

### N11 — Sweep TOCTOU check-then-use negli script CLI/dev (C1, meccanico)
- **Files:** `cli/lib/commands/ai.mjs:39-42`, `cli/lib/utils.mjs:50-52`,
  `scripts/docs/sync-playground-core.mjs:40`, `scripts/docs/build-docx.cjs:30`,
  in subordine `scripts/docs/build-pdf.mjs:36`.
- **Work:** applicare a ogni occorrenza la rimediazione già adottata in
  `tools/site-gen/build.mjs`: niente `existsSync` prima dell'uso — operazione
  diretta con gestione errore (`try { readFileSync/statSync } catch (ENOENT)`).
  Le più chiare: `build-docx.cjs:30` (check → `readFileSync` poche righe dopo),
  `sync-playground-core.mjs:40` (check → `readFileSync` alla riga 44),
  `ai.mjs:39-42` (scelta path con `existsSync` → subito `readFileSync`);
  `utils.mjs:50` ritorna un path già "controllato" poi usato da `seedIsStub`
  (`statSync`) — stesso schema di `findSeed()` corretto in `build.mjs`.
- **Acceptance:** nessuna coppia check-then-use residua (le `existsSync`
  rimaste sono solo decisioni booleane senza uso fs successivo sullo stesso
  path); scansione CodeQL/Codacy senza nuovi alert TOCTOU; comandi verdi:
  `node cli/triad-cli.mjs ai verify`, `node scripts/docs/sync-playground-core.mjs`,
  `node scripts/docs/build-docx.cjs`.

### N12 — Chiusura dell'alert CodeQL su `tools/site-gen/build.mjs` (C1)
- **Files:** `tools/site-gen/build.mjs` (fix già in working tree, non committato),
  `.github/workflows/`, configurazione Codacy/CodeQL.
- **Work:** committare e pushare il fix (read senza `existsSync`, scrittura
  atomica temp+rename, `statSync` diretto in `findSeed`), rilanciare la
  scansione e verificare che l'alert "Potential file system race condition"
  risulti chiuso; chiudere anche il residuo `CodeQL #128` citato sopra se
  ancora aperto.
- **Acceptance:** alert chiuso sul portale della scansione dopo il push;
  `node tools/site-gen/build.mjs --check` (13 file coincidenti) e
  `node cli/triad-cli.mjs test conformance` (37/37) restano verdi.

### N13 — Commit della politica «libro fuori dal repo» (C1, decisione)
- **Files:** `.gitignore` (modificato), index git (staged:
  `D docs/libro/libro.html`, `D docs/libro/The-book-of-Triad.epub`,
  `D docs/libro/triad-logo.webp`), `STATUS.md` (voce «Book `docs/libro/`»).
- **Work:** decidere fra due strade: (a) committare `.gitignore` + le rimozioni
  staged (`docs/libro/` resta solo su disco e nel repo dedicato con il proprio
  `.git`), oppure (b) `git restore --cached docs/libro/...` e restringere il
  `.gitignore` con negazioni `!` per mantenere i 3 artefatti. Verificato il
  2026-11-03: `docs/index.html`, `docs/pages/` e `tools/site-gen/` non
  referenziano `docs/libro/`, quindi la rimozione non tocca il sito generato;
  `scripts/docs/build-libro.mjs` legge le fonti in `docs/*.md` e scrive in
  `docs/libro/` (ignorato da git ma presente su disco): il build resta ok.
- **Acceptance:** `git status` pulito su `docs/libro/`; se (a), `git ls-files
  docs/libro/` è vuoto; `node scripts/docs/build-libro.mjs` rigenera gli
  artefatti senza che git li rilevi; `STATUS.md` aggiornato di conseguenza.

### N14 — Decisione sui capitoli `Libro-*.md` del wiki (C4, decisione umana)
- **Files:** `obsidian-triad/wiki-content/Libro-*.md` (`Libro-00`…`Libro-22`,
  tracciati nel repo), `obsidian-triad/github-wiki/Libro-*.md` (submodule
  `triad2.0.wiki`, gestito a parte).
- **Work:** decidere se i capitoli restano versionati nel repo principale o
  vengono ignorati/rimossi dal tracciamento come il resto del libro. Non sono
  sorgente del build (`scripts/docs/build-libro.mjs` usa `docs/PREFazione.it.md`,
  `docs/FONDAMENTA.it.md`, `docs/MANUALE.it.md`, `docs/tutorial/TUTORIAL.it.md`)
  ma sono il mirror wiki del libro. In caso di rimozione intervenire solo su
  `wiki-content` e aggiungere la regola a `.gitignore`.
- **Acceptance:** decisione documentata in `STATUS.md`; se rimozione, stesse
  verifiche di N13 (`git ls-files` vuoto per i file toccati, build libro
  invariata).

### Ordine suggerito
1. **N12** (chiude l'alert già fixato, commit + push) → 2. **N11** (stessa
  rimediazione, sweep meccanico) → 3. **N13** (decisione + commit della
  politica sul libro) → 4. **N14** (decisione umana, indipendente).
