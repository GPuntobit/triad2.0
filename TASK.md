# Task Triad 2.0

## Obiettivo
Completare Triad 2.0 come linguaggio autonomo e riconosciuto con standard proprio, conformance suite, estensione `.triad`, tooling editor, bootstrap senza linguaggi ospiti e self-hosting.

## Stato attuale
- **Seed S0 (Windows):** 8237 byte, hash `76FC146BA7E070522A5445B5CC0810997E035CBC3135911F62B9C6E6B3CB255F`
  - Supporto: interi, variabili, funzioni (forma breve e blocco), ricorsione, Bool, operatori, if/else, while, let, begin, lambda, chiusure, stringhe base, nothing, simboli, liste complete (costruzione, stampa, push!, get)
  - Conformance: 29/30 casi Windows, 33/33 Core Julia
- **S1 (Interprete Triad in Triad-Core):** Ambiente inline funzionante con liste, primitive base complete
- **S2-S4:** Non iniziati

---

# Backlog: errori e verifiche

Questo file raccoglie i problemi confermati e le verifiche ancora da fare sul progetto.
Una verifica aperta **non** implica che il codice sia errato: registrare un bug solo dopo
averlo riprodotto, indicando il comando o i passaggi, il risultato atteso e quello ottenuto.

## Mappa del progetto

La mappa Graphify interrogabile più recente descrive il commit `d75e31a` (indice del
24 ottobre 2026): 677 nodi, 1.546 relazioni e 26 comunità. L'indice include le guardie
di sicurezza per AST malformati; le modifiche locali successive vanno verificate
direttamente.

- `syntax.jl`: lexer, parser Pratt e costruzione degli alberi `Node`; tra i nodi mappati:
  `parse_toplevel`, `parse_stmt`, `parse_function`, `parse_list`, `parse_args`, `parse_for`
  e `skipnl!` (guardia dei limiti sui separatori finali).
- `triad.jl`: runtime ed esecuzione; Graphify individua, tra gli altri, `run_source`,
  `load_file!`, `define_function`, `define_struct`, `solve_opts`, `reload!`, `run_solve`
  (verifica del numero di argomenti) e `solve_goal`.
- `test/runtests.jl` e `conformance/`: test dell'implementazione e casi di conformità.
  `test/oracles/oracle_tests.jl` contiene test oracle opzionali.
- `.github/workflows/ci.yml`, `seed/` e `seed/dev/`: verifiche CI, seed Windows/Linux
  e relativi generatori.
- `bin/`: launcher e packaging standalone (`bin/build_standalone.jl`).
- `editors/`: integrazioni per gli editor; `ai/`: strumenti e benchmark.
- `SPEC.md`, `SPEC-CORE.md`, `BOOTSTRAP.md`, `STATUS.md`, `README.md` e
  `TUTORIAL.md`: standard, profilo Core, piano di bootstrap, stato e documentazione.

Graphify descrive relazioni e simboli indicizzati; non certifica la correttezza semantica,
la copertura dei test o l'assenza di bug. Le verifiche seguenti vanno quindi confermate
eseguendo codice e test e confrontandoli con la specifica.

## Priorità di completamento

1. **P0 — Parser e specifica:** chiudere la verifica di `syntax.jl` rispetto a `SPEC.md`,
   quindi mappare i requisiti normativi ai test e coprire le lacune reali.
2. **P0 — Rilascio multipiattaforma:** verificare la lane CI Windows e l'esecuzione del
   seed PE, inclusi decodifica, casi conformi e hash.
3. **P1 — Distribuibilità e integrità:** verificare packaging standalone, riproducibilità
   dei file generati e protezione degli artefatti versionati.
4. **P1 — Documentazione:** confrontare esempi, stato dichiarato e comandi con
   implementazione e conformità.
5. **P2 — Ecosistema:** controllare integrazioni editor e strumenti AI.

**Diagnosi Graphify:** `lex` è chiamato da `parse_toplevel` e `string_node`, ed è collegato
a `interpolation_end`, `isidstart` e `syntax_error`; `parse_expr` è chiamato dai parser di
istruzioni, liste/comprehension, regole, solve e blocchi. `graphify_tests_for` non ha
restituito test per `lex`, `parse_expr` o `skipnl!` (nessun collegamento nel grafo per i
test dell'audit AST); per `run_solve` e `solve_opts` restituisce solo `test/runtests.jl`
e `test/oracles/oracle_tests.jl` (match per nome, non per contenuto). È una lacuna dei
collegamenti del grafo, non prova dell'assenza di test. L'indice aggiornato è sul commit
`d75e31a`. `raw()` (syntax.jl L310) non è risolvibile come `raw!`; i chiamanti di `next!`
comprendono `expect_ident!`, `expect_kw!`, `expect_op!`, `parse_args`, `parse_expr`,
`parse_for` e `parse_function`.

## Problemi e modifiche recenti (dal `5e8ca470` al `d75e31a`)

- [x] **Guardie per AST malformati (commit `e201a3e`)** — Aggiunte regressioni in
  `test/runtests.jl` per `skipnl!` al limite del vettore di token, per `run_solve` con
  zero argomenti, per `solve_opts` senza opzioni e per un'opzione priva del valore.
  I casi malformati restituiscono errori Triad `:syntax` senza eccezioni host; suite
  Julia: 281/281 test superati.
- [x] **Seed Windows: espressioni in funzioni a blocco** — Il parser del seed separava
  il percorso delle espressioni autonome da quello che salva i registri dell'identificatore;
  un letterale nel corpo (ad es. `20`) corrompeva lo stack della chiamata. Corretto il
  percorso e aggiunta la conformità `funzioni_io`, che verifica `!io`, output nel corpo
  e valore dell'ultima espressione. Verificati anche `test_short_func.td` nella forma
  Triad `f1() = 10` e il corpo a blocco; entrambi terminano con exit `0`.
- [x] **Seed Windows: artefatti rigenerati e allineati** — `gen_seed.js` genera
  25.088 byte; `seed.exe` è stato decodificato da `seed.hex`, SHA-256
  `76FC146BA7E070522A5445B5CC0810997E035CBC3135911F62B9C6E6B3CB255F`.
- [ ] **Seed Windows: `string()` non copre Bool e Symbol** — Il generatore attuale
  gestisce stringhe e interi, ma manda al percorso di errore `string(false)`,
  `string(true)` e `string(:simbolo)`. Implementare e verificare questi casi di
  conformità nel seed PE se sono richiesti dalla specifica.
- [x] **Seed Windows: caso Core `stringhe`** — Dopo la rigenerazione e la decodifica
  del PE da 25.088 byte, `stringhe/program.td` termina con exit code `0` e produce
  esattamente `stringhe/expected.out` (`ciao Triad`, `5`, `42`). Dei 28 casi del job CI
  Windows, 27 passano localmente; `if_else` termina con exit `1` e richiede verifica
  separata (anche il PE precedente non superava questo caso).
- [x] **Seed Windows: crash su liste e stringhe dopo la generazione** — Con il generatore
  locale, `test_list.td` e anche un caso di stringhe terminavano con
  `STATUS_ILLEGAL_INSTRUCTION`; l'Application Error indicava RVA `0x2ce6`. L'area dei nomi
  import PE iniziava a RVA `0x2cde` e sovrascriveva il codice macchina cresciuto fino a
  quell'indirizzo. Spostati i nomi import a RVA `0x5000`; il seed generato stampa ora
  `[1, 2, 3]` e il caso `stringhe` con exit code `0`. Aggiunto il caso di regressione
  `liste_base` alla conformance Core e al job CI Windows. La verifica locale successiva
  passa tutti i casi elencati tranne `if_else` (exit `1`, problema preesistente); il nuovo
  hash del seed è registrato nella CI.
- [x] **Seed Windows: il probe `get(lst, 1)` non veniva dispatchato** — Il generatore
  conteneva il parser del primitivo `get` ma `pf_call` non lo riconosceva; il seed usciva
  con codice `1` senza output. Aggiunto il dispatch e corretto il recupero degli argomenti
  e il controllo dei limiti, con indice zero-based come richiesto dal probe. Il seed stampa
  `20` per `test_get.td`; il probe è incluso nel job CI Windows. `get` resta un'estensione
  del seed, non una primitiva normativa Triad-Core (`xs[i]` è l'accesso standard 1-based).
- [x] **Seed Windows: `push!` non veniva dispatchato** — Il corpo del builtin era già
  presente ma non raggiungibile da `pf_call`; inoltre l'identificatore del seed non
  consumava il suffisso `!`. Aggiunto il dispatch di `push!`, parsing del suffisso finale,
  append mutabile con limite di 64 elementi e ritorno della lista. `test_push.td` stampa
  `[10, 20]`; aggiunto il caso Core `liste_push` e registrato nella CI Windows. Il seed
  supporta qui liste di interi; indexing standard, `length` e iterazione restano assenti.
  La matrice seed locale passa 29/30 casi (resta `if_else`, exit `1`); i 33 casi Core
  passano con il runtime Julia.
- [x] **Self-host seed smoke test: `selfhost/main.td` stampa una lista** — Riprodotto il
  problema: la versione precedente terminava con exit code `1` e stdout vuoto perché
  `env_lookup` usava `get` nel corpo di una funzione e `return`, non supportati dal seed in
  quel contesto. Sostituito il programma con una prova compatibile di `push!` che deve
  stampare `[10, 20]`, e aggiunta una verifica dedicata alla CI Windows. Questo verifica
  la lista nel seed, non il completamento dell'interprete self-hosted: `get` e `return`
  nelle funzioni restano da implementare. Graphify non include ancora `selfhost/` nel
  grafo indicizzato.

## Problema confermato

- [x] **Workflow CI: nome del passo YAML con `:`** — Corretto in
  `.github/workflows/ci.yml` racchiudendo il valore `name` tra virgolette. Il parser YAML
  interpretava i due punti come sintassi della mappa. `git diff --check` è passato;
  la validazione con un parser YAML locale non era disponibile.
- [x] **Interpolazione di stringhe: delimitazione e posizioni** — Corretto in `syntax.jl`.
  Il parser chiudeva `$()` alla prima parentesi `)` anche quando era dentro una stringa
  dell'espressione interpolata, e non aggiornava righe/colonne per diagnostica e istruzioni
  successive. Aggiunti test di regressione per parentesi in stringhe interpolate, espressioni
  multilinea e posizioni degli errori.
- [x] **Range con spazi non conformi** — Corretto in `syntax.jl`: `a: b` veniva accettato
  nonostante la grammatica normativa richieda il range `a:b` senza spazi. Aggiunto un test
  che richiede un errore di sintassi per `1: 2`.
- [x] **`!` interno agli identificatori** — Corretto in `syntax.jl`: `foo!bar` veniva
  tokenizzato come un unico identificatore e produceva un errore `:undef` in valutazione,
  invece di essere rifiutato dal parser. Ora `!` è ammesso solo come suffisso finale;
  aggiunto test di regressione.
- [x] **A capo dentro commenti multilinea** — Corretto in `syntax.jl`: i newline in
  `#= ... =#` aggiornano riga/colonna ma non venivano conservati come separatori, quindi
  `x = 1 #= commento\n=# y = 2` falliva con errore di sintassi. Ora il lexer emette il
  separatore mantenendo gli a capo dentro le parentesi ignorati dal parser; aggiunti test
  per entrambi i casi.
- [x] **Campi duplicati nelle `struct`** — Corretto in `triad.jl`: una definizione con nomi
  di campo duplicati arrivava al costruttore, che restituiva un errore host. La definizione
  ora restituisce subito `Err(:type)` con il nome del campo; aggiunto test di regressione.
- [x] **Budget delle query logiche annidate** — Corretto in `triad.jl`: i passi delle
  sotto-query `not(...)` non erano sommati al limite della query chiamante. Ora il contatore
  è condiviso; test di regressione sui limiti 5/6. Verificati anche i confini di `depth`
  con test espliciti e il caso ricorsivo esistente.
- [x] **Traccia delle sotto-query `not(...)`** — Corretto in `triad.jl`: la query interna
  non riceveva il collector della traccia e i suoi eventi `:call`/`:exit`/`:fail` mancavano.
  Aggiunti test per sotto-query riuscite e fallite.
- [x] **Launcher Windows** — `triad.cmd` poteva selezionare il falso eseguibile di Julia
  in `WindowsApps`, lasciando il comando bloccato; l'espansione ritardata poteva inoltre
  alterare argomenti contenenti `!`. Ora salta l'alias, preserva gli argomenti e propaga
  il codice d'uscita dopo l'esecuzione. Verificati rilevamento automatico, `-v` e inoltro
  di `bang!arg`.

## Verifiche da eseguire

### Parser e semantica

- [ ] **[P0, IN CORSO] Lexer, parser e AST** — Verificare token, precedenza e associatività
  degli operatori, delimitatori annidati, stringhe, commenti, errori di sintassi e posizioni
  degli errori. Aggiunti test AST per assegnamento e operatori associativi, lambda e ternario
  destri, precedenza logica/unaria/postfissa, continuazione a capo, regole con virgola
  iniziale e identificatori Unicode/`!`. Corretto anche il `!` interno, vietato dalla
  grammatica e il newline perso nei commenti multilinea; suite a 275/275. L'audit completo
  contro la specifica rimane aperto.
- [x] **Valutazione e scope** — Verificati assegnamento locale senza alterare i globali,
  cattura e mutazione di variabili nelle closure, e visibilità locale del binding del ciclo.
  Aggiunti test di regressione in `test/runtests.jl`; suite (251 test) e conformità Core
  passano.
- [x] **Funzioni e dispatch** — Verificati metodi più specifici, ambiguità, fallback builtin,
  mismatch di tipo e sostituzione di una firma ridefinita. Aggiunto test per la sostituzione;
  suite (252 test) e conformità già eseguita passano.
- [x] **Tipi e strutture** — Verificati campi tipizzati e non tipizzati, conversione
  Int→Float, tipi mancanti, accesso a campi inesistenti, firme e vincoli dei valori. Corretto
  anche il caso dei campi duplicati; suite (253 test) e conformità completa passano.
- [x] **Chiusure e funzioni di ordine superiore** — Verificati cattura di parametri e mutazione
  di variabili catturate da funzioni annidate; la suite copre anche `map`, `filter` e `reduce`.
- [x] **Programmazione logica** — Verificati fatti, regole, unificazione/occurs-check,
  backtracking, query e opzioni di limite/profondità/passi; corretto il budget aggregato
  delle sotto-query. Suite (259 test) e conformità Core passano.
- [x] **Codice come dato e macro** — Verificati quasiquote/unquote annidati, valutazione
  del codice generato, argomenti di macro come AST, espansione e `gensym`; probe con
  unquote in liste annidate restituisce il risultato atteso.
- [x] **Errori, contratti ed effetti** — Verificati conversione delle eccezioni host,
  propagazione/intercettazione in `try`, dati degli `Err`, `requires`/`ensures`, purezza dei
  contratti e controllo dinamico di `io`/`state`; test dedicati e suite passano.
- [x] **Budget e tracce** — Verificati esaurimento e annidamento dei budget, confini di
  `depth`, trace di funzioni, risoluzione e sotto-query negated. Corretto il conteggio dei
  passi e la propagazione della traccia; suite (261 test) e conformità completa passano.

### Test e conformità

- [x] **Suite completa** — `julia --startup-file=no test/runtests.jl` passa (275 test,
  inclusi i test che coprono le guardie per AST malformati aggiunti in `e201a3e`);
  `julia --startup-file=no conformance/run.jl` passa tutti i casi.
- [x] **Profilo Triad-Core** — `julia --startup-file=no conformance/run.jl --cases
  conformance/core/cases` passa tutti i casi.
- [ ] **Copertura dei requisiti** — Collegare ogni requisito normativo di `SPEC.md` e
  `SPEC-CORE.md` a uno o più test; creare casi minimi per i requisiti non coperti.
- [x] **Oracle opzionali** — La suite ora individua Julia, SWI-Prolog e SBCL dal `PATH`
  (con override `TRIAD_ORACLE_*`); in Debian tutti i confronti passano: SWI-Prolog 2/2,
  SBCL 1/1 e Julia 1/1. Gli errori di esecuzione dei processi oracle non vengono più
  convertiti silenziosamente in output vuoto.

### CLI, piattaforme e distribuzione

- [x] **CLI e caricamento file** — Verificati opzioni, valutazione, codici di uscita,
  `ARGS`, shebang, risoluzione file, errori e REPL nei test dell'implementazione e nella
  conformità.
- [x] **Launcher POSIX** — In Debian verificati sintassi shell, risoluzione symlink,
  percorsi e argomenti con spazi, `!` negli argomenti, ricerca via `PATH`, override
  `TRIAD_JULIA`, `--build`, CLI reale e shebang. Corretto il fallback WSL che selezionava
  `julia.exe` Windows e falliva passando percorsi Linux; ora il launcher richiede Julia
  nativa Linux e rifiuta esplicitamente un override `.exe`.
- [x] **Launcher Windows** — Verificati ricerca PATH contro l'alias `WindowsApps`, override
  `TRIAD_JULIA`, modalità `-v` e inoltro di argomenti contenenti `!` attraverso
  `bin/triad.cmd`.
- [x] **Riproducibilità degli artefatti seed** — I generatori Linux e Windows ricreano
  esattamente i rispettivi dump esadecimali; i byte decodificati coincidono con i file
  PE/ELF versionati.
- [x] **Esecuzione seed Linux (E0)** — In Debian x86_64 eseguito il seed ELF: stampa
  `Triad seed Linux OK` ed esce con successo; hash ELF verificato.
- [x] **Probe portabili** — `_probe.jl`, `_probe2.jl`, `_probe3.jl`, `_qc.jl` e
  `_smoke.jl` eseguiti con Julia nativa su Debian; tutti completano correttamente.
- [ ] **Esecuzione seed Windows** — Restano da eseguire i casi CI nativi; Defender ha
  quarantinato il PE rigenerato in `%TEMP%` durante la prova locale.
- [x] **Ambito di `continue-on-error` nella CI Windows** — Verificato in
  `.github/workflows/ci.yml`: l'opzione tollera solo il fallimento di `Add-MpPreference`;
  decodifica, casi del seed e verifica hash restano bloccanti.
- [ ] **Esecuzione della lane seed Windows** — Verificare che decodifica, casi e hash
  funzionino anche quando l'esclusione antivirus facoltativa non è disponibile. Defender
  ha quarantinato il PE non escluso nella prova locale; resta da verificare la lane hosted
  senza presumere che l'esclusione riesca.
- [x] **CI multipiattaforma** — Verificate le lane definite in
  `.github/workflows/ci.yml` su Windows e Linux. Su Windows locale la suite passa
  275/275 test e la conformità Full/Core passa. In Debian 13 su WSL, conformità Full/Core e
  suite Julia passano (275/275); il seed Linux decodificato in un file temporaneo si avvia
  e restituisce l'output atteso, e l'hash del dump coincide. La
  [run GitHub Actions #21](https://github.com/GPuntobit/triad2.0/actions/runs/39983981561)
  (`5e8ca470`, 2026-10-23) è riuscita su tutte le quattro job: conformance Ubuntu/Windows
  e seed Linux/Windows.
  Non è necessario registrare WSL come runner self-hosted.
- [ ] **Packaging standalone** — Provare `bin/build_standalone.jl` in un ambiente pulito e
  verificare dipendenze, layout e avvio senza Julia. Prova isolata Windows (Julia 1.13.1):
  PackageCompiler 2.4.5 si installa nel depot temporaneo, poi la build termina con
  `TypeError` su `c_driver_program` (`nothing` dove è richiesto `String`); nessun eseguibile
  viene prodotto. Mancano inoltre `Project.toml` e `src/Triad.jl`, necessari al layout
  atteso dal builder. README aggiornato per dichiarare il prototipo non disponibile;
  rendere la build funzionante e provarne l'avvio resta aperto.

### Editor, strumenti e documentazione

- [ ] **Integrazioni editor** — Verificare grammatica, evidenziazione e riconoscimento
  dell'estensione canonica `.triad` e dell'alias `.td` in `editors/`.
- [ ] **Strumenti AI** — Verificare opzioni CLI, dipendenze, error handling e riproducibilità
  di `ai/jev_audit.mjs` e `ai/verify.jl`, senza includere output generati nel repository.
- [ ] **Documentazione coerente** — Confrontare esempi e comandi in `README.md`,
  `TUTORIAL.md`, `SPEC.md`, `SPEC-CORE.md`, `BOOTSTRAP.md` e `STATUS.md` con il
  comportamento effettivo e con i test. Tutti i file `examples/*.td` e `*.triad` sono
  stati eseguiti con Julia; verificati anche i comandi CLI `--version`, `-E` e `--help`.
  Corretto nel tutorial il testo sui fallback distinti dei launcher POSIX/Windows. Il README
  dichiara il limite del packaging; la revisione completa di tutorial, specifica e stato del
  bootstrap resta da fare.
- [x] **Repository e artefatti** — Verificati `.gitignore` (binari standalone/cache ignorati)
  e `.gitattributes` (seed binari e dump esadecimali non normalizzati come testo). I
  generatori riproducono entrambi i dump: Windows SHA-256
  `445CB428EFF44B39C2103DF776E6D9A1D1B5BDD8904C2C93D661950321C4ED60`, Linux
  `AD4C9F08176D9964D5BE17D44C72230184434025980447395E7A3250F63CA5EA`; i byte decodificati
  coincidono con PE/ELF versionati. Il PE Windows è stato aggiornato intenzionalmente
  insieme al generatore e al relativo controllo hash CI.

## Come registrare un nuovo bug

Per ogni problema riprodotto, aggiungere una voce con:

1. area e file coinvolti;
2. comando o passaggi minimi per riprodurlo;
3. risultato attuale e risultato atteso (riferimento alla specifica, se applicabile);
4. test aggiunto o aggiornato che impedisce la regressione.

---

# Task S1 (Interprete Triad in Triad-Core)

### S1.3: Sistema di valori taggati
**Descrizione:** Implementare encoding/decoding per distinguere Int, Bool, String, Nothing, List in S1.

**Dettagli:**
- Usare encoding del seed (Int: shifted/tagged, Bool: 1/5, String: heap object, List: heap object)
- Implementare funzioni per check tipo (is_int, is_bool, is_string, is_list)
- Implementare funzioni per encoding/decoding (int_value, bool_value, etc.)
- Testare con valori misti in ambiente

**Output:** S1 può distinguere e manipolare correttamente tutti i tipi Triad-Core

---

### S1.4: Parser/tokenizer inline
**Descrizione:** Leggere sorgente, tokenizzare e riconoscere numeri, identificatori, operatori in S1.

**Dettagli:**
- Leggere stringa sorgente (input hardcoded o da file)
- Tokenizzare: numeri, identificatori, operatori (+, -, *, ==, <, >), delimiteri (, (, ), ;, newline)
- Riconoscere keyword (if, else, while, function, let, begin, end)
- Memorizzare token in lista per parsing

**Output:** S1 può tokenizzare un programma Triad-Core

---

### S1.5: Eval espressioni base
**Descrizione:** Valutare Int, Bool, String con ambiente inline in S1.

**Dettagli:**
- Implementare eval per interi (aritmetica base)
- Implementare eval per Bool (operatori logici)
- Implementare eval per String (concatenazione, string())
- Usare ambiente inline per lookup variabili
- Testare con espressioni complesse

**Output:** S1 può valutare espressioni base con ambiente

---

### S1.8: Variabili con let
**Descrizione:** Estendere ambiente per supportare binding locali con scope in S1.

**Dettagli:**
- Implementare let con scope locale (shadowing)
- Gestire ambiente come stack di frame
- Supportare nested let con scope corretto
- Testare con scope multipli

**Output:** S1 supporta variabili con let e scope locale

---

### S1.11: Parser completo
**Descrizione:** Supportare if/else, while, function e tutti i costrutti Triad-Core in S1.

**Dettagli:**
- Implementare parsing di if/else
- Implementare parsing di while
- Implementare parsing di function (forma breve e blocco)
- Implementare parsing di let/begin
- Generare AST o struttura intermedia inline

**Output:** S1 può parsare tutti i costrutti Triad-Core

---

### S1.12: Eval programmi completi
**Descrizione:** Valutare statement sequenziali con ambiente in S1.

**Dettagli:**
- Implementare eval di statement sequenziali
- Gestire ambiente persistente tra statement
- Supportare esecuzione completa di programmi
- Testare con programmi con più statement

**Output:** S1 può eseguire programmi completi Triad-Core

---

### S1.13: Funzioni e chiamate
**Descrizione:** Definire funzioni, parametri, return e invocazione in S1.

**Dettagli:**
- Implementare definizione funzioni
- Implementare chiamata funzioni con parametri
- Gestire return esplicito e implicito
- Supportare funzioni ricorsive base

**Output:** S1 supporta definizione e chiamata funzioni

---

### S1.14: Chiusure e ricorsione
**Descrizione:** Supportare funzioni che catturano ambiente in S1.

**Dettagli:**
- Implementare cattura ambiente nelle chiusure
- Supportare ricorsione completa
- Gestire scope corretto in chiusure
- Testare con lambda e higher-order functions

**Output:** S1 supporta chiusure e ricorsione completa

---

### S1.15: Test conformance
**Descrizione:** Eseguire S1 su tutti i casi Core e verificare output.

**Dettagli:**
- Eseguire S1 su tutti i 33 casi Core
- Verificare output atteso per ogni caso
- Fix bug in S1 se necessario
- Documentare casi passati/falliti

**Output:** S1 passa la conformance suite Core completa

---

## Task Bootstrap (S2-S4)

### S2: Compilatore nativo
**Descrizione:** Progettare architettura per compilare Triad a machine code.

**Dettagli:**
- Progettare IR intermedio per Triad
- Implementare codegen x86-64
- Generare PE/ELF eseguibili
- Testare su Windows e Linux

**Output:** Compilatore nativo S2 che genera machine code

---

### S3: Self-hosting
**Descrizione:** Implementare compilatore Triad scritto in Triad.

**Dettagli:**
- Riscrivere S2 in Triad
- Compilare S2 con S2 (bootstrap)
- Verificare fixed point
- Testare self-hosting completo

**Output:** Compilatore self-hosted S3

---

### S4: Runtime completo
**Descrizione:** Implementare REPL, CLI, tooling, parità Linux.

**Dettagli:**
- Implementare REPL interattivo
- Implementare CLI per esecuzione file
- Aggiungere tooling per sviluppo
- Portare seed Linux ELF
- Verificare parità conformance Linux/Windows

**Output:** Runtime completo S4 con parità Linux/Windows

---

## Priorità

1. S1.3 (valori taggati) - fondamento per S1
2. S1.4 (parser/tokenizer) - necessario per eseguire programmi
3. S1.5 (eval base) - base per interprete
4. S1.8 (variabili con let) - scope e binding
5. S1.11 (parser completo) - tutti i costrutti
6. S1.12 (eval programmi) - esecuzione completa
7. S1.13 (funzioni) - potenza linguaggio
8. S1.14 (chiusure) - completezza funzionale
9. S1.15 (test conformance) - verifica S1
10. S2-S4 (bootstrap) - fase finale

## Note

- S1 deve essere implementato inline (senza funzioni helper) a causa delle limitazioni del seed
- Le liste nel seed supportano solo interi - usare convenzioni per altri tipi
- L'ambiente S1 usa interi come chiavi (1="x", 2="y", ecc.)
- Tutte le task S1 devono essere testate su Windows con il seed attuale
