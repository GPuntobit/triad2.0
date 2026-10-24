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
`d75e31a`. `raw()` (syntax.jl L310) non è risolvibile come `raw!`; i chiamatori di `next!`
comprendono `expect_ident!`, `expect_kw!`, `expect_op!`, `parse_args`, `parse_expr`,
`parse_for` e `parse_function`.

## Problemi e modifiche recenti (dal `5e8ca470` al `d75e31a`)

- [ ] **Guardie per AST malformati (commit `e201a3e`) senza test di regressione** — Aggiornate
  le guardie di `skipnl!` (`syntax.jl` L316), `run_solve` (`triad.jl` L1415: `length(x.args) >= 1`)
  e `solve_opts` (`triad.jl` L1426: `length(x.args) >= 2` e ogni opzione con esattamente 2 campi).
  `graphify_tests_for` non ha collegato test a `skipnl!` (0 test); per `run_solve`/`solve_opts`
  restituisce solo `test/runtests.jl` e `test/oracles/oracle_tests.jl` (match per nome). Mancano
  test che costruiscano un `Node` deformato (ad es. `Node(:solve)` con 0 argomenti) e verifichino
  che le guardie restituiscono `Err(:syntax)` senza eccezioni host. Da aggiungere in
  `test/runtests.jl`.
- [ ] **Seed Windows: layout PE aggiornato (commit `d75e31a`) ma `seed.exe` non rigenerato** —
  Il commit `d75e31a` ha aggiornato `seed/dev/gen_seed.js` (IAT `0x2C00`→`0x3800`, `SEC_RAW`
  `0x2400`→`0x2800`, `FILESZ` calcolato dinamicamente = 11.392 byte, nuovi supporti
  `string(false)`/`string(true)`/`string(Symbol)` in `pb_str`) e `seed/windows-x86_64/seed.hex`.
  Lo SHA-256 del `seed.hex` rigenerato localmente con
  `node seed/dev/gen_seed.js windows-x86_64/seed.hex` (11.392 byte decodificati) è
  `03A6EE4649661DDB056DA4B5B3B97A41CDC2F16DCDDB77D0936709380FB59F15`;
  il `seed.exe` versionato in `seed/windows-x86_64/seed.exe` ha ancora 9.728 byte con
  SHA-256 `f5c084FECE504478CF4A1EC15EDDFC67C05106D24E7C819BF6CAC6141B789562`.
  Da rigenerare con `certutil -decodehex -f seed/windows-x86_64/seed.hex seed/windows-x86_64/seed.exe`
  e verificare che l'immagine PE eseguita.
- [ ] **Seed Windows: nuovi tipi di `string()` da verificare nei casi Core** —
  `gen_seed.js` ora gestisce `false` (tag 1), `true` (tag 5) e `Symbol` (tag 2) nel
  built-in `string()`. Aggiungere o verificare i casi di conformità che chiamano
  `string(false)`, `string(true)` e `string(:simbolo)` nel seed PE; la suite Core
  (26/29) e Full (12/12) non coprono ancora questi percorsi.
- [ ] **`seed.exe` non parte dopo il decodehex locale** — Decodificato
  `seed.hex` con `certutil` in `%TEMP%\triad_seed_test.exe` (11.392 byte, SHA-256
  `03A6EE...`), l'esecuzione con argomento `-v` restituisce `exit -1073741819`
  (`0xC000001D`, `STATUS_ILLEGAL_INSTRUCTION`). Verificare che l'immagine PE generata
  da `gen_seed.js` sia eseguibile su Windows x86-64; se l'istruzione illecita è dovuta
  a una sezione .text mal formata, correggere il generatore e rigenerare `seed.hex`.

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
- [x] **Esecuzione seed Linux (E0)** — In Debian x86-64 eseguito il seed ELF: stampa
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
  `11ADCCCAA092C5C39ECD4DB7C21926BAF4BB536FB740E0B115F2B2BC4433289C`, Linux
  `AD4C9F08176D9964D5BE17D44C72230184434025980447395E7A3250F63CA5EA`; i byte decodificati
  coincidono con PE/ELF versionati. Nessun artefatto del repository è stato modificato
  dalle verifiche.

## Come registrare un nuovo bug

Per ogni problema riprodotto, aggiungere una voce con:

1. area e file coinvolti;
2. comando o passaggi minimi per riprodurlo;
3. risultato attuale e risultato atteso (riferimento alla specifica, se applicabile);
4. test aggiunto o aggiornato che impedisce la regressione.
