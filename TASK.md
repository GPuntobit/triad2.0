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

---

# Nuove task generate dall'audit del 2026-10-25

Questa sezione integra il backlog precedente con task emerse dall'esame dei sorgenti e
dalle prove locali. In caso di conflitto con riepiloghi storici più vecchi, fanno fede il
codice, la specifica e i risultati riprodotti qui.

## Evidenze di partenza

- Graphify: indice sul commit `f589f89`, 686 nodi e 1.555 relazioni; copre soprattutto
  `triad.jl`, `syntax.jl`, test e strumenti, ma non modella ancora adeguatamente `selfhost/`.
  I file locali sono quindi stati controllati direttamente.
- Runtime Julia: **281/281 test**, **12/12 casi Full**, **33/33 casi Core** superati.
- Seed Windows: `if_else` stampa `100` ed esce `1`; `liste` esce `1`; `valori` e `stringhe`
  passano. Il seed non è ancora un'implementazione Triad-Core completa.
- CI Windows attualmente incoerente: `selfhost/main.td` stampa `Value: 10`, mentre il job
  richiede `[10, 20]`.
- Moduli S1: `ast.td` non viene parsato dal runtime Full; `eval.td` va in stack overflow;
  `main.td` dipende dall'helper `get` assente nel runtime Full; `env.td`, `heap.td` e
  `interpreter.td` sono prototipi, non componenti di un interprete funzionante.

## P0 — Ripristinare una baseline verificabile

- [ ] **A01 — Allineare lo smoke test self-hosted alla CI**
  - **File:** `selfhost/main.td`, `.github/workflows/ci.yml`.
  - **Lavoro:** decidere se il caso deve verificare l'ambiente oppure `push!`; rendere
    programma e golden coerenti, senza dichiarare che lo smoke test equivale a S1.
  - **Accettazione:** il seed produce esattamente l'output atteso ed esce `0`; il job
    `seed-windows` non contiene più un fallimento deterministico.

- [ ] **A02 — Correggere `if_else` nel seed Windows**
  - **File:** `seed/dev/gen_seed.js`, caso `conformance/core/cases/if_else/`, CI e dump PE.
  - **Lavoro:** diagnosticare la valutazione/scansione dei rami `if`/`elseif`/`else`; il
    risultato osservato è stdout `100` e exit `1`.
  - **Accettazione:** output byte-esatto ed exit `0` per `if_else`, più regressioni per
    rami annidati, `elseif` multipli, condizioni false e assenza di `else`; dump e hash
    rigenerati.

- [ ] **A03 — Eliminare i moduli S1 non validi o ricorsivi**
  - **File:** `selfhost/ast.td`, `selfhost/eval.td`, `selfhost/main.td`.
  - **Lavoro:** rimuovere `type AST = Int`, non presente nella grammatica; eliminare la
    ridefinizione ricorsiva di `string()` e l'uso di `/`, escluso da Core; non usare `get`
    come se fosse una primitiva Full.
  - **Accettazione:** ogni sorgente S1 è valido Triad-Core, non solleva overflow e non
    richiede estensioni del seed non normative; eventuali file obsoleti sono rimossi.

- [ ] **A04 — Introdurre un runner unico per il seed**
  - **File:** nuovo runner di sviluppo, `.github/workflows/ci.yml`, `conformance/`.
  - **Lavoro:** sostituire la lista manuale di 30 casi con discovery delle directory,
    confronto binario di stdout e verifica di exit code, `args.txt` e stderr dove previsto.
    Separare i casi Core condivisi dai test specifici dei primitivi di bootstrap.
  - **Accettazione:** tutti i casi presenti vengono eseguiti automaticamente; un caso nuovo
    non richiede modifiche alla CI; aggiunta o modifica di un golden errato fa fallire il job.

- [ ] **A05 — Aggiungere casi negativi e limiti alla conformance Core**
  - **File:** `conformance/core/cases/`, `SPEC-CORE.md` §9–§10, runner seed.
  - **Lavoro:** coprire indici fuori range, tipi errati, variabili indefinite, modulo per
    zero, file illeggibile, CLI non valida e diagnostica su stderr; aggiungere overflow,
    valore zero e limiti di conversione dove la specifica li definisce.
  - **Accettazione:** stdout, stderr normalizzato se necessario ed exit code sono verificati;
    i casi passano sul runtime Full quando applicabile e sul seed dopo il completamento S0.

- [ ] **A06 — Rendere la CI obbligatoria prima di nuove milestone**
  - **File:** `.github/workflows/ci.yml`, `STATUS.md`.
  - **Lavoro:** eseguire la lane sul commit corrente dopo A01–A04 e registrare run, commit e
    risultati effettivi; non basarsi sulle run storiche citate nei documenti.
  - **Accettazione:** conformance, test Julia, seed Windows e seed Linux sono tutti verdi;
    ogni eccezione antivirus resta limitata al solo passo facoltativo già previsto.

## P0/P1 — Completare S0 come interprete Triad-Core

- [ ] **S0.1 — Definire e testare un modello uniforme dei valori**
  - **File:** `seed/dev/gen_seed.js`, `SPEC-CORE.md` §3 e §5.
  - **Lavoro:** distinguere String e Symbol oggi rappresentati dallo stesso oggetto; rendere
    `==`, `!=`, `typeof`, `string()` e stampa coerenti per Int, Bool, String, Symbol, List,
    Function e Nothing; gestire esplicitamente zero e interi con segno.
  - **Accettazione:** liste eterogenee e annidate stampano correttamente; conversioni e
    confronti misti non crashano; simboli e stringhe con lo stesso testo restano tipi diversi.

- [ ] **S0.2 — Completare liste e indicizzazione normativa**
  - **File:** `seed/dev/gen_seed.js`, casi `liste` e nuovi casi Core.
  - **Lavoro:** implementare `xs[i]` 1-based in lettura e assegnamento, `length`, `push!`
    su valori misti, uguaglianza strutturale e capacità dinamica; mantenere `get` solo come
    estensione interna oppure ritirarlo dai sorgenti destinati alla conformance.
  - **Accettazione:** il caso `liste` e i nuovi casi di mutazione, annidamento, lista vuota,
    limiti e crescita oltre 64 elementi passano senza corruzione della memoria.

- [ ] **S0.3 — Implementare stringhe e primitivi di bootstrap**
  - **File:** `seed/dev/gen_seed.js`, test specifici del seed.
  - **Lavoro:** aggiungere escape `\n \t \" \\`, `length`, `readfile`, `strlen`, `strbyte`,
    `strsub` e `exit`; rispettare indici e byte UTF-8 definiti da `SPEC-CORE.md`.
  - **Accettazione:** test byte-esatti per stringhe vuote, escape, UTF-8 multibyte, substring
    ai limiti, errori di I/O e contenuto riletto; nessuna dipendenza da Julia o Node a runtime.

- [ ] **S0.4 — Completare controllo di flusso, scope e chiusure**
  - **File:** `seed/dev/gen_seed.js`, casi Core.
  - **Lavoro:** implementare `return` esplicito, `break`, `continue`, `-=`, `*=`, lambda a
    zero/più parametri e `let` multiplo; sostituire la cattura singola/per valore con frame
    lessicali condivisi come richiesto dalla specifica.
  - **Accettazione:** regressioni per ritorno annidato, cicli annidati, shadowing, closure
    mutabili con più binding, ricorsione e chiamate higher-order passano sul seed.

- [ ] **S0.5 — Completare CLI, `ARGS` e diagnostica**
  - **File:** `seed/dev/gen_seed.js`, `SPEC-CORE.md` §8–§10.
  - **Lavoro:** supportare argomenti multipli e quoted, `ARGS`, script da stdin con `-`,
    `print` a più argomenti, stderr ed exit `0/1/2`; evitare che ogni errore termini senza
    messaggio diagnostico.
  - **Accettazione:** casi Windows con spazi nei path/argomenti, stdin, uso non valido, file
    mancante ed errori runtime producono stream ed exit code attesi.

- [ ] **S0.6 — Rendere memoria e parser del seed robusti**
  - **File:** `seed/dev/gen_seed.js`, test negativi e fuzz di sviluppo.
  - **Lavoro:** controllare limiti di sorgente, heap, frame, funzioni e liste; gestire arena
    esaurita e ricorsione; rifiutare token/keyword parziali, commenti annidati e input
    malformati senza leggere oltre i buffer.
  - **Accettazione:** nessun crash o `STATUS_ILLEGAL_INSTRUCTION` nei casi di limite; errori
    deterministici con exit `1`; layout PE, relocazioni e riproducibilità restano verificati.

- [ ] **S0.7 — Chiudere formalmente la milestone M3**
  - **Dipendenze:** A01–A06 e S0.1–S0.6.
  - **Accettazione:** tutti i casi Core positivi e negativi e tutti i test dei primitivi di
    bootstrap passano sul PE decodificato dal solo `seed.hex`; `STATUS.md`, `BOOTSTRAP.md`,
    `seed/README.md`, `TUTORIAL.md`, dump ed hash riportano lo stesso stato.

## P1 — Costruire S1 come implementazione realmente self-hosted

- [ ] **S1.0 — Definire architettura, formato e entrypoint unico**
  - **File:** `selfhost/`, `BOOTSTRAP.md`.
  - **Lavoro:** consolidare i prototipi in una pipeline `lexer → parser/AST → evaluator →
    runtime/CLI`; definire encoding di valori, nodi, ambienti ed errori usando solo tipi Core.
    Stabilire come comporre i moduli senza un `include` non previsto dal seed.
  - **Accettazione:** un entrypoint versionato carica ed esegue un programma minimo tramite
    seed; ogni modulo ha un contratto e un test; niente stub presentati come funzionalità.

- [ ] **S1.1 — Implementare lexer e parser Triad-Full in Core**
  - **Dipendenze:** S0.3, S0.7, S1.0.
  - **Lavoro:** tokenizzare tutto il lessico di `SPEC.md`, costruire AST con posizioni,
    precedenze, blocchi, tipi, termini logici, quote e macro; rappresentare errori come dati.
  - **Accettazione:** test AST differenziali contro `syntax.jl` per l'intera grammatica;
    input malformati producono `Err(:syntax)` con riga/colonna senza terminare il seed.

- [ ] **S1.2 — Implementare evaluator, ambienti e funzioni**
  - **Dipendenze:** S0.4, S1.1.
  - **Lavoro:** valutare letterali, operatori, assegnamenti, indici, blocchi, scope, closure,
    `return`/`break`/`continue`; implementare funzioni generiche, builtin e chiamate.
  - **Accettazione:** S1 esegue sopra S0 tutti i casi Core e i test di valutazione Full senza
    delegare parsing o valutazione al runtime Julia.

- [ ] **S1.3 — Implementare tipi, struct e multiple dispatch**
  - **Dipendenze:** S1.2.
  - **Lavoro:** rappresentare gerarchia, vincoli dichiarati, conversioni, struct immutabili,
    selezione del metodo, fallback builtin ed errori di ambiguità.
  - **Accettazione:** passano `dispatch`, `assaggio` e regressioni equivalenti a quelle di
    `test/runtests.jl`, inclusi Int→Float, ridefinizione e firme ambigue.

- [ ] **S1.4 — Implementare il motore logico**
  - **Dipendenze:** S1.2.
  - **Lavoro:** fatti/regole, termini, unificazione con occurs-check, trail/backtracking,
    negazione, `is`, query, soluzioni, limit/depth/steps e motore iterativo.
  - **Accettazione:** passano `famiglia`, `prolog`, query ricorsive e test di budget/traccia;
    nessuna ricorsione logica infinita causa overflow dell'host o del seed.

- [ ] **S1.5 — Implementare macro, errori, contratti, effetti, budget e tracce**
  - **Dipendenze:** S1.2–S1.4.
  - **Lavoro:** coprire quasiquote/unquote, `Expr`, `eval`, `gensym`, `try`/`throw`, `Err`,
    `requires`/`ensures`, `with`, eventi e controllo dinamico di `io`/`state`.
  - **Accettazione:** passano `macro`, `macro_eval`, `errore`, `garanzie_core`, `tour` e i
    test semantici corrispondenti; gli effetti e i budget annidati conservano il loro scope.

- [ ] **S1.6 — Implementare CLI e REPL self-hosted**
  - **Dipendenze:** S1.2–S1.5, S0.5.
  - **Lavoro:** riprodurre `SPEC.md` §14: opzioni ordinate, `ARGS`, stdin, shebang, query
    interattive, comandi REPL, diagnostica ed exit code.
  - **Accettazione:** la stessa matrice CLI/REPL del runtime Julia passa su S1 sopra S0;
    file `.triad` e `.td` sono equivalenti.

- [ ] **S1.7 — Chiudere M4 senza Julia**
  - **Dipendenze:** S1.0–S1.6.
  - **Lavoro:** implementare `triad --conformance DIR` in Triad e usare i golden committati;
    eseguire tutti gli esempi e i 12 casi Full tramite la sola catena `seed.hex + S1`.
  - **Accettazione:** una lane CI esegue la conformità senza installare Julia/Node; il
    risultato è byte-esatto e la documentazione distingue chiaramente stage0 e self-host.

## P2 — Compilazione, portabilità e completamento del prodotto

- [ ] **S2.1 — Specificare IR e ABI del compilatore nativo**
  - **Dipendenze:** S1.7.
  - **Lavoro:** definire rappresentazione dei valori, frame, chiamate, allocazione, runtime,
    layout PE/ELF, eccezioni/controllo e strategia di debug prima del codegen.
  - **Accettazione:** documento normativo/implementativo con test sull'IR e mapping completo
    dei costrutti Triad; nessuna dipendenza da C/Rust/Julia nella catena finale.

- [ ] **S2.2 — Implementare codegen x86-64 e chiudere M5**
  - **Dipendenze:** S2.1.
  - **Lavoro:** compilare S1 in eseguibili nativi Windows/Linux, collegare il runtime e
    aggiungere test differenziali tra S1 interpretato e S1 compilato.
  - **Accettazione:** S1 compilato supera tutta la conformance senza il seed; dump e binari
    riproducibili, con test su entrambe le piattaforme.

- [ ] **S3.1 — Dimostrare il fixed point e chiudere M6**
  - **Dipendenze:** S2.2.
  - **Lavoro:** compilare il compilatore con se stesso per almeno due generazioni e confrontare
    artefatti o hash canonici; rimuovere il seed dal percorso normale di build e uso.
  - **Accettazione:** generazione N e N+1 equivalenti, conformance verde e procedura di
    bootstrap documentata e ripetibile da checkout pulito.

- [ ] **S4.1 — Portare il runtime completo su Linux e chiudere M7**
  - **Dipendenze:** S2.2; non limitarsi all'attuale ELF E0.
  - **Lavoro:** completare syscall/layer OS, file e argomenti, REPL, diagnostica e test
    multipiattaforma; valutare macOS/ARM solo come milestone successiva esplicita.
  - **Accettazione:** stessa conformance Full/Core, stessi esempi e stessa CLI verdi su Windows
    e Linux senza Julia; nessun caso saltato silenziosamente.

## Qualità trasversale e riconoscimento

- [ ] **Q01 — Creare una matrice requisito → implementazione → test**
  - **File:** `SPEC.md`, `SPEC-CORE.md`, `test/`, `conformance/`.
  - **Lavoro:** assegnare un ID ai requisiti normativi e collegarli a test positivi/negativi;
    completare l'audit del parser e segnalare esplicitamente ciò che è informativo o non
    implementato.
  - **Accettazione:** ogni requisito ha almeno una verifica o una lacuna aperta motivata; la
    matrice è controllata in CI per evitare riferimenti a test inesistenti.

- [ ] **Q02 — Riallineare tutta la documentazione allo stato misurato**
  - **File:** `TASK.md`, `STATUS.md`, `BOOTSTRAP.md`, `README.md`, `TUTORIAL.md`, `seed/`, `ai/`.
  - **Lavoro:** correggere conteggi, hash, dimensioni, claim S0/S1 e roadmap contraddittori;
    sistemare anche il blocco di codice del tutorial intorno a §19.5.5/§20 e la dicitura
    «S0 completato»; archiviare gli handoff storici senza usarli come stato corrente.
  - **Accettazione:** un controllo automatico ricava conteggi/hash dai file e nessun documento
    attivo dichiara complete funzionali smentite dai test.

- [ ] **Q03 — Rendere gli strumenti AI riproducibili e aggiornati**
  - **File:** `ai/jev_audit.mjs`, `ai/verify.jl`, prompt e task.
  - **Lavoro:** sostituire i risultati hardcoded 243/29/25 con dati generati o parametri
    espliciti; correggere i ruoli che chiamano Core il runtime Full; testare dry-run, errori
    API, path assenti e codici di uscita; mantenere gli output generati fuori da Git.
  - **Accettazione:** test locali senza rete coprono successo e fallimento; nessun fatto
    obsoleto viene inviato come ground truth; i benchmark misurano il profilo dichiarato.

- [ ] **Q04 — Completare o ritirare il packaging standalone Julia**
  - **File:** `bin/build_standalone.jl`, launcher e documentazione.
  - **Lavoro:** creare il layout `Project.toml`/`src/Triad.jl` se si mantiene PackageCompiler,
    correggere `c_driver_program`, precompilazione e `--build`; altrimenti rimuovere il
    percorso non supportato senza confonderlo con S2 self-hosted.
  - **Accettazione:** da ambiente pulito l'eseguibile si avvia senza Julia installato e passa
    una suite CLI; oppure ogni riferimento al packaging è rimosso e il comando non promette
    una build inesistente.

- [ ] **Q05 — Validare e pubblicare il tooling editor**
  - **File:** `editors/`, esempi e grammatica.
  - **Lavoro:** testare automaticamente token TextMate/Vim su tutti i costrutti e su
    `.triad`/`.td`; verificare package VSIX e installazione; preparare la PR Linguist senza
    appropriarsi dell'estensione `.td` di LLVM TableGen.
  - **Accettazione:** test delle grammatiche verdi, pacchetto installabile, istruzioni
    riprodotte e stato delle pubblicazioni esterne registrato separatamente dal codice.

- [ ] **Q06 — Ripulire e proteggere il repository**
  - **File:** `.gitignore`, `.gitattributes`, `.vs/`, probe e `test_*.td` nella root, `out.txt`.
  - **Lavoro:** spostare i probe utili in test strutturati, eliminare artefatti IDE e output
    vuoti dal versionamento, ignorare `.vs/` e altre directory locali; preservare i dump seed
    come fonti e controllarne gli hash.
  - **Accettazione:** checkout pulito senza cache personali; nessuna regressione persa durante
    lo spostamento; CI verifica che binari e report generati non vengano reinseriti in Git.

## Ordine di esecuzione consigliato

1. **A01–A06:** prima una CI affidabile sullo stato reale.
2. **S0.1–S0.7:** completare il contratto Core prima di ampliare S1.
3. **S1.0–S1.7:** un unico interprete self-hosted verificato end-to-end.
4. **S2.1–S4.1:** compilazione, fixed point e parità Linux.
5. **Q01–Q06:** attività trasversali, anticipate quando sbloccano verifiche o rilasci.
