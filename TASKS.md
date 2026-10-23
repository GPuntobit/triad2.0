# Backlog: errori e verifiche

Questo file raccoglie i problemi confermati e le verifiche ancora da fare sul progetto.
Una verifica aperta **non** implica che il codice sia errato: registrare un bug solo dopo
averlo riprodotto, indicando il comando o i passaggi, il risultato atteso e quello ottenuto.

## Mappa del progetto

La mappa Graphify interrogabile più recente descrive il commit `98e3fdb` (indice del
22 ottobre 2026): 650 nodi, 1.497 relazioni e 21 comunità. Il repository locale è avanzato
al commit `31bd7fd` con modifiche non ancora indicizzate; usare il grafo per orientare
l'indagine e verificare sempre i risultati sul codice attuale.

- `syntax.jl`: lexer, parser Pratt e costruzione degli alberi `Node`; tra i nodi mappati:
  `parse_toplevel`, `parse_stmt`, `parse_function`, `parse_list`, `parse_args` e `parse_for`.
- `triad.jl`: runtime ed esecuzione; Graphify individua, tra gli altri, `run_source`,
  `load_file!`, `define_function`, `define_struct`, `solve_opts` e `reload!`.
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

**Attività iniziale svolta:** Graphify mappa `parse_expr` (`syntax.jl`) come snodo centrale,
con chiamanti che includono parser di istruzioni, liste/comprehension, regole, solve, blocchi
e interpolazione. `graphify_tests_for` non ha restituito test collegati a `parse_expr` o
`syntax.jl`; tuttavia il repository contiene il testset parser in `test/runtests.jl`, quindi
questo risultato indica copertura incompleta delle relazioni del grafo, non assenza dei test.
La query Graphify è sullo snapshot `98e3fdb`, non sul codice locale corrente.

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
  iniziale e identificatori Unicode/`!`; suite a 272/272. L'audit completo contro la
  specifica rimane aperto.
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

- [x] **Suite completa** — `julia --startup-file=no test/runtests.jl` passa (272 test);
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
- [ ] **CI multipiattaforma** — Eseguire o controllare tutte le lane definite in
  `.github/workflows/ci.yml` su Windows e Linux; verificare che le istruzioni Julia e i
  comandi usati localmente coincidano con quelli CI. In Debian passano la suite completa
  (261 test), la conformità Full e Triad-Core; restano da verificare le lane Windows
  nell'ambiente CI.
- [ ] **Packaging standalone** — Provare `bin/build_standalone.jl` in un ambiente pulito e
  verificare dipendenze, layout e avvio senza Julia. Il README segnala che il packaging
  attuale richiede ancora di completare il layout `Project.toml`/`src`: confermare lo
  stato e aggiornare la documentazione in base al risultato.

### Editor, strumenti e documentazione

- [ ] **Integrazioni editor** — Verificare grammatica, evidenziazione e riconoscimento
  dell'estensione canonica `.triad` e dell'alias `.td` in `editors/`.
- [ ] **Strumenti AI** — Verificare opzioni CLI, dipendenze, error handling e riproducibilità
  di `ai/jev_audit.mjs` e `ai/verify.jl`, senza includere output generati nel repository.
- [ ] **Documentazione coerente** — Confrontare esempi e comandi in `README.md`,
  `TUTORIAL.md`, `SPEC.md`, `SPEC-CORE.md`, `BOOTSTRAP.md` e `STATUS.md` con il
  comportamento effettivo e con i test.
- [ ] **Repository e artefatti** — Controllare `.gitignore`, `.gitattributes`, hash dei
  seed e file generati per assicurare che test e build non modifichino accidentalmente
  golden o artefatti versionati.

## Come registrare un nuovo bug

Per ogni problema riprodotto, aggiungere una voce con:

1. area e file coinvolti;
2. comando o passaggi minimi per riprodurlo;
3. risultato attuale e risultato atteso (riferimento alla specifica, se applicabile);
4. test aggiunto o aggiornato che impedisce la regressione.
