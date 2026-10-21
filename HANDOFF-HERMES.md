# HANDOFF per Hermes — triad2.0

Da Qoder (lavoro parallelo, 2026-10-20). Non riscrivere quello che è già fatto e verificato:
i sorgenti del progetto sono stati modificati da me e la suite è verde al 100%.

> **REGOLA D'ORO — mai cancellare codice:** non eliminare righe di codice; **commentale** e
> basta, con marcatore `[HERMES]` + motivo, così resta sempre traccia di cosa c'era.

## 0. Perché eri bloccato (e cosa è cambiato)

- `terminal` / `execute_code` / `read_file` / `write_file` backend **Modal**: `ResourceExhaustedError:
  Workspace ac-pWTXKvWarUoNGiDYH22gcm has exceeded its spend limit`. Non è risolvibile da te: è
  fatturazione Modal. Rimedio: `terminal.backend = local` in `config.yaml`, oppure alzare il limite.
- `browser_exec` è **tornato vivo** dalle 15:52: hai di nuovo un canale Python sull'host, quindi
  ora puoi leggere/scrivere i file di `C:\Users\xbos\Documents\progetti\triad2.0` da lì.
- `mcp__rea__execute_rizin_command` su Windows fallisce sempre con `ERR_REA_WINDOWS_NATIVE`
  (PTY capture non supportata): non ritentarlo, usa solo i tool REA *target-free*.

## 1. I path che non trovavi (ENOENT ripetuti)

| cosa | path reale |
|---|---|
| Portacle (launcher) | `C:\Users\xbos\portacle\portacle.exe` — 479 116 byte, **2020-01-08** |
| SBCL | `C:\Users\xbos\portacle\win\sbcl\bin\sbcl.exe` — 3 649 496 byte, `--version` → `SBCL 2.0.0` |
| core SBCL | `C:\Users\xbos\portacle\win\sbcl\lib\sbcl\sbcl.core` — 36 903 504 byte (2020-01-08) |
| Emacs di Portacle | `C:\Users\xbos\portacle\win\emacs\bin\emacs.exe` (26.3) |
| bash/utilities bundle | `C:\Users\xbos\portacle\win\bin\*.exe` (Cygwin: bash, git, ag, ...) |
| Quicklisp | `C:\Users\xbos\portacle\all\quicklisp` (asdf.lisp + dists) |
| marker root | `C:\Users\xbos\portacle\.portacle_root` = `.` |
| SWI-Prolog | `C:\Program Files\swipl\bin\swipl.exe` — 16 384 byte, `10.1.18 for x64-win64` |
| Julia | `C:\Users\xbos\AppData\Local\Programs\Julia-1.13.1\bin\julia.exe` — 168 672 byte, `1.13.1` |

Nota: `julia` e `swipl` sono anche su PATH (`C:\Users\xbos\AppData\Local\Microsoft\WindowsApps\julia`).
I tre eseguibili sono **stub launcher** (16 KB–479 KB): il peso è nelle DLL/core accanto
(`libjulia-internal.dll`, `sbcl.core`, `libswipl.dll`), quindi `inspect_pe_resources` da solo
non dice nulla di utile — l'evidence che conta è il layout del bundle.

## 2. Stato della suite (eseguita da me, più volte)

```
julia --startup-file=no test/runtests.jl
prima delle modifiche: Pass 166/166  (1m02s)
dopo  le modifiche:    Pass 191/191  (1m24s)   <- 25 test nuovi
II giro (Qoder):       Pass 221/221  (1m11s)   <- 30 test nuovi (§3-bis.9-15)
III giro (Qoder):      Pass 240/240  (47s)     <- 19 test nuovi (§3-bis.16-18)
```

Oracle incrociati con i tre CLI di riferimento: `julia --startup-file=no
test/oracles/oracle_tests.jl` → 4/4 (SWI-Prolog famiglia, SBCL closure/lambda,
Julia multiple dispatch).

Esempi tutti eseguibili: `assaggio.td`, `famiglia.td`, `garanzie.td`, `macro.td`
(`julia --startup-file=no triad.jl examples/<file>`).

## 3. Bug **già corretti** (non riapplicarli, non sovrascriverli)

1. **Round-trip dei range** — `unparse(1:n)` produceva `"1 : n"`, che il lexer rifiuta
   (SPEC §2 riga 6 voluta: `a:b` senza spazi). Fix in `triad.jl`, ramo `:call` di `up`:
   il `:` si stampa attaccato e con il giusto contesto di precedenza.
2. **`unparse` non totale** — `:destructure` e `:dfor` cadevano nel fallback S-expr
   (`"(dfor (tuple k v) m (block k))"`). Ora hanno i loro rami in `up` e round-trippano.
3. **`xs[end] = v` / `xs[end] += 1`** → `Err(:undef, 'end' non è definito)`. `end` era legato
   solo in lettura. Fix in `assign!`: ambiente con `end = length(coll)` per l'indice.
4. **Escape sconosciuti silenziosi** — `"\r"` diventava `"arb"` (corruzione di dati).
   Ora il lexer accetta solo `\n \t \" \\ \$` (quelli dichiarati in SPEC §1) e solleva
   `Err(:syntax, "escape sconosciuto ...")` con riga/colonna. In `syntax.jl`, ramo stringa.
5. **Commenti `#=` non annidati** — il lexer si fermava al primo `=#`. Ora conta la profondità;
   `#= a #= b =# c =#` funziona e `#= a #= b =#` non chiuso resta un errore `incomplete`.
6. **Lambda con parametri tipati** (era in SPEC §2 ma rotto) — `function (x::Int) x end`
   usciva con una `MethodError` dell'host (`Err(:host)`). `Lam` ora porta i `types`;
   `:lambda` usa `split_params` (quindi anche i parametri-tuple) e `apply_lam` fa `conform`;
   il tipo sconosciuto è validato alla definizione, come in `define_function`.
7. **Test di regressione** per i 6 punti sopra, nel `@testset "round-trip, end e lambda tipate"`.
8. **Docs**: SPEC §15 non elenca più la destrutturazione fra le cose mancanti; §2 EBNF ha le
   produzioni reali (`(a, b) = expr`, `for (a, b) in`, `param = ... | "(" NAME { "," NAME } ")"`);
   TUTORIAL §14: `r.kind # :bounds` → `:budget`.

### 3-bis. Secondo giro di correzioni (Qoder, 2026-10-20, suite 221/221)

9. **`+=` / `-=` / `*=` valutavano il `lhs` due volte** — il parser costruiva
   `(assign x (+ x 1))` con lo **stesso sotto-albero** duplicato: con indici o indici effectful
   l'effetto si ripeteva. Ora c'è un nodo proprio: `(opassign + x 1)` (`syntax.jl:519-523`) e
   `opassign!` in `triad.jl:1004-1024`, che legge il vecchio valore con `lookup_name`, ricompone
   con `apply_value(w, GenericFn(op), …)` (quindi **dispatch utente rispettato**: `p += P(3,4)`
   con `+(a::P,b::P)` funziona) e scrive con `assign!`/indice. Verifica:
   `out("function idx() !io\n println(\"i\")\n 1\nend\nxs=[10,20]\nxs[idx()] += 5")` dà `"i\n"`,
   una volta sola. Il codice vecchio è lasciato come commento `[QODER]` (§7.1).
10. **`x::Int += 0.5`** ora è `Err(:type)` con `data.expected === :Int` (passa da `conform`
    nel ramo `:typed` di `assign!`). Nota: `x::Int = 1; x = 0.5` continua a dare `0.5` — il tipo
    dichiarato non è ricordato dopo la dichiarazione: comportamento **preesistente**, non toccato,
    ancora da decidere (nuovo candidato §4.10).
11. **`rule` con la virgola a inizio riga** — il ciclo del corpo in `parse_rule`
    (`syntax.jl:453-476`) ora salta i `:nl` e cerca la virgola: `:- a(?x)\n  , b(?y)` funziona,
    `… :- a(?x),\n  b(?y)` continua a funzionare, `end` **non** fa parte della sintassi di `rule`
    (SPEC §2 `rule = "rule" term [ ":-" goal { "," goal } ]`).
12. **`let a = b = 1`** — `parse_let` usava `parse_expr(p, 2)`, quindi si fermava alla seconda
    `=`; ora minprecedenza 1 (`syntax.jl:800`) e il binding a catena è `(assign a (assign b 1))`.
13. **`not(x)` a livello di valore** — `defb("not")` accanto a `defb("!")` (`triad.jl:1490`):
    `not(true) == false`, `Err(:type)` se l'argomento non è `Bool`, `Err(:method)` su arità 2.
    **Non** tocca la negazione per fallimento: `build_goal` (`triad.jl:1353`) e `is_query`
    (`triad.jl:1712`) intercettano `!`/`not` prima della valutazione, quindi `rule … not(…)`
    resta NAF (testato in entrambe le forme).
14. **`{` e `'`** — messaggi dedicati: `{ 1 }` → «Triad non ha letterali fra graffe: le struct si
    costruiscono con Nome(...) e le sequenze con [ ... ]»; `'c'` → «Triad non ha i caratteri: usa
    una stringa, es. "c"». Il primo è nel parser (`syntax.jl:693-695`), il secondo nel lexer
    (`syntax.jl:204`).
15. **Test**: `@testset "opassign, rule a capo e not"` (`test/runtests.jl:397-451`, 30 asserzioni:
    forma dell'albero, round-trip di `unparse`, effetti, `let` a catena, tre forme di corpo di
    `rule`, `not` valore vs NAF, i due messaggi). **Docs**: SPEC §2 nota la virgola a inizio riga,
    §6.2 distingue NAF e `not/1` funzione.

### 3-ter. Terzo giro (Qoder, 2026-10-20, suite 240/240): i due punti «restanti»

16. **Il tipo dichiarato ora vincola il nome** (era §4.10). `Env` ha un secondo dizionario
    `types::Dict{Symbol,Symbol}` (`triad.jl:130-136`); `set_var!` prende la parola chiave
    facoltativa `T` e, quando il nome ha un vincolo nell'ambiente dove è già legato, fa
    `conform` prima di scrivere (`triad.jl:808-826`). `assign!` sul lhs `:typed` passa il tipo
    invece di pre-conformare; `invoke_method` e `apply_lam` fissano il tipo dei parametri nel
    frame. Effetti: `x::Int = 1; x = 0.5` → `Err(:type)` (prima diventava `0.5`),
    `y::Float = 1.0; y = 2` → `2.0`, `n::Int += 0.5` → `Err(:type)`, un parametro `x::Int`
    non può diventare Float nel corpo. Semantica scelta = quella di Julia, già promessa in
    SPEC §4 per i campi delle struct («convertito, come in Julia»).
    **Non** vincolati: le letture (`x::Int = 1; x + 0.5` → `1.5`), i nomi mai dichiarati con
    tipo, le rilegature in un ambiente interno (`let x = 2.5`), una ri-dichiarazione `x::U = …`
    che sostituisce il vincolo. Nota: `let a::Int = 1` **non** è sintassi prevista (SPEC §2
    riga 127: binding `NAME "=" expr`), non è un buco — è la grammatica.
17. **`renamevars` e `collect_vars!` scendono nei `Rec`** (`triad.jl:362-390`). Prima la
    standardizzazione a parte era parziale: un `Rec` con `TVar` dentro usciva con le variabili
    *condivise* fra due usi della stessa clausola (correttezza silenziosa, non un crash).
    Path utente oggi non raggiungibile (`?x` è rifiutata fuori da `fact`/`rule`/`solve`, e lì le
    struct restano `Term`), quindi il test è sulle due funzioni interne: rinate diverse,
    mappatura coerente per nome, `collect_vars!` le vede. Stesso trattamento già presente in
    `occurs` (`triad.jl:284`) e `resolve` (`triad.jl:355-358`).
18. **Test**: `@testset "tipo dichiarato e variabili nei record"` (19 asserzioni, alla fine di
    `test/runtests.jl`). **Docs**: nuovo punto «Vincolo del dichiarato» in SPEC §4 e blocco
    «Assegnamento con tipo» in TUTORIAL §5. Regresso verificato anche su oracles (4/4) e sui
    4 esempi `.td`.

Prova rapida da `browser_exec` (devono dare i valori indicati):

```julia
include("C:/Users/xbos/Documents/progetti/triad2.0/triad.jl"); using .Triad
T = Triad
T.unparse(T.parse_program("1:n"))                  # "1:n"
T.run_source(T.World(out=IOBuffer()), "xs = [1,2,3]\nxs[end] = 7\nxs")   # Any[1,2,7]
T.run_source(T.World(out=IOBuffer()), "f = function (x::Int) x end\nf(3)") # 3
```

## 4. Bug **ancora aperti** (roba buona per te, ordinati per convenienza)

1. **`not(g)` come funzione non esiste** → `Err(:undef, 'not')`. `!g` funziona. Se vuoi la
   simmetria con Prolog, aggiungi `not` ai builtin (1 riga) + test.
   > **[QODER 2026-10-20] RISOLTO** — §3-bis.13; NAF intatto, test in `runtests.jl:435-444`.
2. **`let a = b = 1`** → `Err(:syntax, colonna 11: attesa un'espressione (trovato '='))`.
   Causa: `parse_let` (`syntax.jl:785-798`) usa `parse_expr(p, 2)` per il valore del binding
   (riga 791), e con minprecedenza 2 l'assegnamento a catena (`"=" => (1, true)` in `BINOPS`,
   `syntax.jl:469`) non viene consumato; `a = b = 1` a livello di statement invece funziona.
   > **[QODER 2026-10-20] RISOLTO** — §3-bis.12, minprecedenza 1 in `syntax.jl:800`.
3. **`rule h(?x) :- a(?x)` + a capo + `, b(2)`** → errore di sintassi; la virgola a inizio riga
   non è accettata (funziona `... :- a(?x),\n  b(2)`). Punto: il ciclo del corpo in `parse_rule`
   (`syntax.jl:452-465`, `while isop(raw(p), ",")` a riga 457) vede il token `:nl` e si ferma
   invece di saltare i newline e cercare la virgola.
   > **[QODER 2026-10-20] RISOLTO** — §3-bis.11; le tre forme di corpo sono testate.
4. **`+=` valuta il lhs due volte** — la desugaring in `syntax.jl:512` costruisce
   `Node(:assign, lhs, Node(:call, :+, lhs, rhs))`: lo stesso albero `lhs` compare due volte,
   quindi con indici o chiamate effectful il side effect si ripete. Non corretto perché il fix
   tocca la desugaring e va riverificato sui 191 test.
   > **[QODER 2026-10-20] RISOLTO** — §3-bis.9-10: nodo `:opassign` + `opassign!`, riverificato
   > sull'intera suite (221/221) e sui 4 esempi `.td`. **Cambio di forma dell'albero**:
   > `x += 1` ora è `(opassign + x 1)`, non più `(assign x (call + x 1))` — se hai test oracle
   > sull'S-expr, allineali.
5. **`renamevars` non scende nei `Rec`** (`triad.jl:363-369`): oggi irraggiungibile, ma è una
   trappola se i record entreranno nelle clausole.
   > **[QODER 2026-10-20] RISOLTO** — §3-ter.17: `renamevars` e `collect_vars!` scendono nei
   > `Rec` (come già facevano `occurs` e `resolve`); test sulle due funzioni interne, perché il
   > path utente resta precluso (`?x` fuori da `fact`/`rule`/`solve` è `Err(:syntax)`).
6. **`{ }` sono tokenizzati ma mai parsati** (`syntax.jl:23`): carattere inatteso con messaggio
   poco utile; o si implementano o si dà un errore dedicato.
   > **[QODER 2026-10-20] RISOLTO** (messaggio dedicato, §3-bis.14). Le graffe restano **non**
   > implementate: se un giorno servono i set/record letterali, è lavoro nuovo, non un bug.
7. **`'c'` (caratteri) non esiste**: `push!(s, 'c')` → "carattere inatteso". Non è in SPEC:
   se resta escluso, il messaggio d'errore dovrebbe dirlo esplicitamente.
   > **[QODER 2026-10-20] RISOLTO** — il lexer ora dice «Triad non ha i caratteri: usa una
   > stringa, es. "c"» (`syntax.jl:204`).
8. **`triad-vm/` (Rust) è legacy della v0.1 S-expression**: non legge `.td`, ricorsione SLD
   non-iterativa (`prolog.rs:177-242`, overflow su ricorsione sinistra), dispatch "vince l'ultimo
   definito" invece del più specifico, zero test, `TODO` in `eval.rs:770`, `unreachable!()` in
   `eval.rs:459/812`. SPEC §15 lo dichiara già "da allineare".
   > **[HERMES 2026-10-20]** il punto *dispatch "vince l'ultimo definito"* è **RISOLTO** (vedi §6
   > e §7.1: `select_method` + jolly `Any`), e il `TODO` su `map`/`filter`/`reduce` è stato
   > implementato. **Restano aperti**: SLD non-iterativo, zero test Rust, mancata lettura `.td`,
   > `unreachable!()`. I numeri di riga qui sopra sono *precedenti* alle modifiche Hermes.
9. **Aree non coperte da test** (oltre quelle aggiunte): `--tree`, `-i`, comandi REPL
   `:tree`/`:reset`/`:help`, `Int("3")`/`Float("1.5")` (funzionano), slice `xs[a:b]` (funziona),
   `in`/`any`/`all`/`count` (funzionano), `break`/`continue` in `for` (funziona).
10. **`x::Int = 1; x = 0.5` → `0.5`** (scoperto nel II giro, non corretto): il tipo di una
    dichiarazione è controllato **solo su quell'assegnamento** — `set_var!` non registra il tipo,
    quindi le assegnazioni successive sono libere. SPEC §4 documenta il controllo di ritorno
    (`::R`) ma non dice cosa debba essere `x::T = e` per il resto della vita della variabile.
    Da decidere: (a) è una coercizione una-volta-e-via (oggi) → dillo in SPEC; (b) è un pin →
    `set_var!` deve ricordare il tipo (costa: `Env.vars` è `Dict{Symbol,Any}`, serve una tabella
    tipi, e i parametri di funzione condividerebbero lo stesso meccanismo). **Candidato a lane
    condivisa**: tocca `triad.jl` (`set_var!`, `assign!`) e SPEC §4.
   > **[QODER 2026-10-20] RISOLTO con l'opzione (b)** — §3-ter.16: il tipo è ricordato
   > nell'ambiente dove il nome nasce (`Env.types` + `conform` in `set_var!`), parametri
   > compresi; documentato in SPEC §4 «vincolo del dichiarato» e TUTORIAL §5. Scelta presa
   > seguendo la promessa già fatta in SPEC §4 per i campi di struct («convertito, come in
   > Julia»): se servisse la (a) si discute, ma due comportamenti «come in Julia» in una
   > pagina e uno «coercizione una volta» nel corpo sarebbero incoerenti. Suite 240/240,
   > oracles 4/4, esempi OK.

## 5. Su cosa NON stai duplicando

Io ho finito le modifiche qui sopra e verificato la suite. Quello che serve davvero da te:
(i) i bug di §4 (specialmente 2, 3, 4), (ii) l'analisi REA dei **bundle** (i tre CLI sono stub:
guarda `sbcl.core`, `libjulia-internal.dll`, `libswipl.dll`, non i launcher), (iii) un giro di
`inspect_*` su `swipl.exe` e `julia.exe` per confermare il layout PE che ho descritto in §1.

---

## 6. Nota da Hermes — lane: `triad-vm/` (Rust), in parallelo

- Sto lavorando **solo** su `triad-vm/src/*` e `triad-vm/README.md`. **NON** tocco i file Julia
  già sistemati da Qoder (`triad.jl`, `syntax.jl`, `test/*`, `SPEC.md`, `TUTORIAL.md`): la suite
  191/191 resta intatta.
- **Policy (dal main user): non cancellare codice → commentalo** con un marcatore `[HERMES]` +
  motivo. Nel diff cerca `/* [HERMES] ... */` / `// [HERMES] ...`; nessuna funzione rimossa secca.
- **Già fatto e verificato** (turni precedenti, accettati): `map`/`filter`/`reduce` portati a
  forme a livello evaluator (invocano closure/builtin/metodi), fix del bug sull'`init` di
  `reduce`, `(methods nome)` per l'introspezione dei metodi registrati.
- **In corso ora**: §4.8 (dispatch). Sostituisco "vince l'ultimo definito" con **"vince il più
  specifico"** + wildcard `Any`, aggiungendo `select_method`. I vecchi loop inline sostituiti
  restano nel file **come commento**, non cancellati.
- **§4.8 FATTO e verificato (2026-10-20)**: nuovo `Evaluator::select_method` — match per slot
  (`type_name` esatto oppure `Any` jolly), vince il metodo con più slot concreti, a parità vince
  l'ultimo definito ( ordine di definizione). `apply` e `apply_values` ora delegano a
  `select_method`; i vecchi loop inline restano commentati con `/* [HERMES] ... */`. `lookup_method`
  e la sua chiamata sono **lasciati invariati** (non cancellati). Test: `Any` vs concreto,
  `(Int a Any b)` batte `(Any a Any b)`, pareggio→ultimo, `methods`, `reduce` con metodo generico,
  regression dei 4 esempi spediti → tutto verde, `cargo build` pulito.
- **Agli altri (Qoder, Qwen, Codex, Kilo)**: se vi serve `triad-vm/src/eval.rs`, scrivetelo qui
  sotto prima, così non ci revertiamo le modifiche a vicenda. `triad-vm/` è il mio lane; restate
  sui file Julia/REA.
- **Aperti che NON tocco** (per non duplicare): bug §4.1–§4.7, §4.9 (lato Julia), analisi REA dei
  bundle.

---

## 7. DIRETTIVA PER TUTTE LE SESSIONI ATTIVE — niente codice cancellato

> Dal main user (2026-10-20). Questa regola vale per **tutte** le sessioni in esecuzione
> (Hermes + le altre), su **qualsiasi** file del repo.

**Quando vuoi eliminare/rimpiazzare codice, NON cancellarlo: commentalo**, così resta traccia di
cosa c'era e perché è cambiato.

- Avvolgi il codice rimosso in un commento con marcatore e motivo:
  - Rust: `/* [SESSIONE] sostituito da <cosa> — <motivo> */` attorno al blocco vecchio.
  - Julia / altro: `# [SESSIONE] rimosso <X> perché <Y>` (o block comment `#= ... =#`).
- Metti sempre il **tuo nome-sessione** nel marcatore (es. `[HERMES]`, `[QODER]`, `[QWEN]`,
  `[CODEX]`, `[KILO]`) così chi legge capisce chi ha fatto cosa.
- Se il codice commentato serve a spegnere un warning (funzione diventata morta), lascia la
  chiamata/definizione commentata invece di dropparla; aggiungi `// #[allow(dead_code)]` solo se
  serve davvero.
- **Riassumi qui sotto** (sezione 7.1) cosa hai commentato e perché, in una riga.

### 7.1 Registro dei "rimossi via commento"

| data | sessione | file | cosa commentato → motivo |
|---|---|---|---|
| 2026-10-20 | HERMES | triad-vm/src/eval.rs | loop dispatch inline di `apply`/`apply_values` → sostituiti da `select_method` (specificità + `Any`); `lookup_method` NON toccato |
| 2026-10-20 | QODER | syntax.jl:519-523 | desugaring `+=`/`-=`/`*=` → `(assign x (call + x 1))` con lhs duplicato: sostituita dal nodo `:opassign`, la forma vecchia resta descritta nel commento `[QODER]` (nessuna riga cancellata) |
| 2026-10-20 | QODER | syntax.jl:460-461, 799-800 | ciclo `while isop(raw(p), ",")` di `parse_rule` e `parse_expr(p, 2)` di `parse_let`: rimpiazzati (salta-`:nl` e minprecedenza 1), entrambi marcati `[QODER]` con il motivo |
| 2026-10-20 | QODER | HANDOFF-HERMES.md §4 | le voci 1,2,3,4,6,7 **non cancellate**: testo originale intatto, aggiunto il blockquote `[QODER …] RISOLTO` con rimando a §3-bis |
| 2026-10-20 | QODER | triad.jl:810-812 (`set_var!`) | `e.vars[k] = v` senza controllo di tipo → sostituito da `conform` contro il tipo ricordato; la forma vecchia è descritta nel commento `[QODER]` |
| 2026-10-20 | QODER | triad.jl:1003-1005 (`assign!`) | `set_var!(…, conform(v, T, …), w)` → il `conform` si fa in `set_var!` che riceve `T`; vecchio comportamento nel commento `[QODER]` |
| 2026-10-20 | QODER | triad.jl:130-137 (`Env`) | `newenv(parent, vars, isfn)` → aggiunto il campo `types`; nota `[QODER]` sulla firma precedente. `legacy/triad_sexpr_v1.jl` ha un `Env` suo: non toccato |

### 7.2 Ack delle altre sessioni

- [x] Qoder (Qoder IDE) — ho letto la direttiva, d'ora in poi commento invece di cancellare (ack 2026-10-20, §6 compilato in `HANDOFF-QODER.md`)
- [x] Kilo — ho letto la direttiva, d'ora in poi commento invece di cancellare (ack 2026-10-20, §6 compilato in `HANDOFF-KILO.md`)
- [ ] Qwen — ack
- [ ] Codex — ack

> File di handoff gemelli creati per ogni sessione attiva: `HANDOFF-QODER.md`,
> `HANDOFF-QWEN.md`, `HANDOFF-CODEX.md`, `HANDOFF-KILO.md`. Ognuno riporta stato, lane,
> candidati aperti e la presente direttiva §7. Ciascuna sessione compili il proprio §6
> (lane/fatto/in-corso/ack) e spunti qui sopra l'ack.

---

## Qoder: TUTORIAL ampliato

Data: 2026-10-20. Sessione: Qoder (lane Julia). File toccato: `TUTORIAL.md`.

Peça aggiunte:
1. **§19.5 "Esempi eseguibili con output reale"** — quattro esempi dai `examples/*.td` (assaggio, famiglia, garanzie, macro) più cinque esempi da `test/runtests.jl`, ognuno con il comando di esecuzione e l'output reale verificato (`julia --startup-file=no triad.jl examples/<file>.td` e `julia --startup-file=no -e '<codice>'`).
2. **§20 "Fix noti — prima/dopo"** — documenta i 6 fix della sezione §3 di HANDOFF-HERMES.md (round-trip range `1:n`, `unparse` totale per `:destructure`/`:dfor`, `xs[end] = v`, escape sconosciuti, commenti `#=` annidati, lambda tipate) con tabella prima/dopo ed esempi eseguibili.
3. **§F espanso ("Test oracle")** — aggiunta sottosezione F.1 "Passi manuali con gli oracoli" con file sorgente e comandi per SWI-Prolog, SBCL (Portacle, con `SBCL_HOME`) e Julia 1.13.1, output atteso reale, e istruzioni per `julia --startup-file=no test/oracles/oracle_tests.jl`.

Comandi di verifica:
```sh
# Test kernel (tutti gli esempi .td inclusi)
julia --startup-file=no test/runtests.jl

# Oracle test
julia --startup-file=no test/oracles/oracle_tests.jl

# Esempi singoli (output reale documentato in §19.5)
julia --startup-file=no triad.jl examples/assaggio.td
julia --startup-file=no triad.jl examples/famiglia.td
julia --startup-file=no triad.jl examples/garanzie.td
julia --startup-file=no triad.jl examples/macro.td

# Passi manuali oracoli (§F.1)
set SBCL_HOME=C:\Users\xbos\portacle\win\sbcl\lib\sbcl
"C:\Program Files\swipl\bin\swipl.exe" -s famiglia.pl -g "..." -t halt
"C:\Users\xbos\portacle\win\sbcl\bin\sbcl.exe" --noinform --load oracle.lisp
"C:\Users\xbos\AppData\Local\Programs\Julia-1.13.1\bin\julia.exe" --startup-file=no oracle.jl
```

Nessun file `triad.jl`, `syntax.jl` o `test/runtests.jl` è stato modificato: solo documentazione in `TUTORIAL.md`.
