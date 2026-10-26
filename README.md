# Triad 2.0 — linguaggio di programmazione

**Triad** è un linguaggio di programmazione autonomo: sintassi a blocchi e tipi dichiarati,
multiple dispatch, programmazione logica integrata, codice come dato. La sua definizione è
una specifica normativa indipendente dall'implementazione ([SPEC.md](SPEC.md), standard
0.2.0) con una suite di conformità eseguibile ([conformance/](conformance/README.md)).

Sintassi e semantica sono definite da Triad, non da altri linguaggi. Le influenze sono
documentate come note informative (Appendice A di SPEC.md):

| influenza | idea ripresa |
|---|---|
| Julia | `function … end`, `struct`, tipi con `::`, multiple dispatch, operatori-funzione, `if`/`for`/`while`/`let` |
| Prolog | `fact`, `rule`, unificazione con occurs-check, backtracking, `solve` (variabili logiche `?x`) |
| Lisp | codice come dato (`Node`), `:( … )`/`quote` con `$`, macro |

Sono parte del linguaggio, non di una libreria: errori come dati (`Err`), contratti
(`requires`/`ensures`), budget (`with budget`), tracce (`with trace`), effetti dichiarati
(`!io`, `!state`).

## Standard e riconoscimento

- **Specifica:** [SPEC.md](SPEC.md) — normativa, versione in [`VERSION`](VERSION); storia in
  [CHANGELOG.md](CHANGELOG.md).
- **Conformità:** [conformance/](conformance/README.md) — golden che ogni implementazione
  deve passare.
- **AI:** [ai/](ai/README.md) — benchmark per generazione di codice Triad da LLM, con
  prompt di sistema e verificatore automatico.
- **Implementazione:** oggi `triad.jl` + `syntax.jl` su Julia, transitoria per il bootstrap;
  il piano per un Triad senza linguaggi ospiti è in [BOOTSTRAP.md](BOOTSTRAP.md).
- **Editor:** [editors/](editors/README.md) — VS Code, Vim/Neovim e voce Linguist per GitHub.
- **Estensione:** `.triad` (canonica), `.td` (alias storico).

## Avvio

L'interfaccia a riga di comando è definita da SPEC.md §14. L'implementazione di riferimento
(oggi su Julia, transitoria) offre un launcher che trova il runtime da solo.

### 1. Launcher (consigliato)

Aggiungi `bin/` al `PATH`, poi usa `triad` come qualsiasi comando:

```sh
triad                           # REPL
triad file.triad arg1 arg2      # esegue un file ed esce
triad -l file.triad             # carica un file e apre il REPL
triad -i file.triad             # esegue un file e poi apre il REPL
triad --tree file.triad         # stampa l'albero uniforme (S-expression)
triad -E '1 + 2'                # valuta e stampa il valore
triad --help                    # tutte le opzioni
```

L'estensione `.triad` è canonica; `.td` è accettata come alias storico.

Il launcher cerca in ordine:
1. `bin/triad-native` — eseguibile standalone (se compilato)
2. Variabile d'ambiente `TRIAD_JULIA`
3. `julia` nel `PATH`
4. Posizioni standard di Julia per Linux/macOS

Su Windows usare `triad.cmd` (funziona analogamente). Su WSL il launcher POSIX richiede
Julia per Linux; non usa il `julia.exe` installato in Windows, perché i percorsi e i file
passati dal filesystem Linux non sono compatibili con quel runtime.

### 2. File .triad eseguibili direttamente (shebang)

I file `.triad` (o `.td`) possono essere resi eseguibili come script autonomi:

```sh
# Prima riga del file programma.triad:
#!/usr/bin/env triad

println("ciao dal file .triad!")
fact parent(:alice, :bob)
result = solve parent(:alice, ?x)
println(result)
```

```sh
chmod +x programma.triad
./programma.triad arg1 arg2     # ARGS == ["arg1", "arg2"]
```

Lo shebang `#!` viene rimosso automaticamente prima del parsing.

### 3. Packaging standalone (non ancora disponibile)

`bin/build_standalone.jl` e `triad --build` sono prototipi, non una procedura di
distribuzione funzionante. In una prova pulita su Windows con Julia 1.13.1, il builder ha
installato PackageCompiler 2.4.5 in un ambiente temporaneo ma si è fermato con un errore di
tipo sull'argomento `c_driver_program`; non è stato prodotto alcun eseguibile. Inoltre il
repository non ha ancora il layout di pacchetto `Project.toml`/`src/Triad.jl` richiesto dal
builder e lo script di precompilazione presuppone `using Triad`. Il packaging resta quindi
da completare e verificare prima di poter usare `bin/triad-native`.

Per usare Triad oggi, serve Julia installato: usare il launcher `triad`/`triad.cmd` oppure
`julia --startup-file=no triad.jl ...`. Un eventuale eseguibile creato in futuro potrà
includere il runtime Julia senza richiedere un'installazione separata di Julia; non sarà
però un'implementazione indipendente da Julia. La strada per un Triad senza linguaggi
ospiti è in [BOOTSTRAP.md](BOOTSTRAP.md).

### 4. CLI di sviluppo (triad-cli)

Per le operazioni di sviluppo è disponibile una CLI unificata che wrappa i vari tool:

```sh
cd cli
npm install
node triad-cli.mjs status          # stato del progetto
node triad-cli.mjs seed generate windows  # genera seed
node triad-cli.mjs ai verify        # verifica soluzioni AI
node triad-cli.mjs build standalone # compila eseguibile
node triad-cli.mjs test conformance # esegue conformance
```

Vedi [cli/README.md](cli/README.md) per la documentazione completa della CLI di sviluppo.

### Fallback diretto

Se preferisci invocare Julia esplicitamente:

```sh
julia --startup-file=no triad.jl [opzioni]
```

## Esempio veloce (`examples/assaggio.td`)

```julia
struct Point
    x::Float
    y::Float
end

function dist(a::Point, b::Point)::Float
    requires a.x != b.x || a.y != b.y
    sqrt((a.x - b.x)^2 + (a.y - b.y)^2)
end

fact parent(:alice, :bob)
fact parent(:bob, :dave)
rule grandparent(?x, ?z) :- parent(?x, ?y), parent(?y, ?z)

result = solve grandparent(:alice, ?who) limit 5
println("nipoti: ", result)     # [{who = :dave}]
println("primo: ", result[1].who) # :dave
```

## Test

```sh
# test dell'implementazione di riferimento
julia --startup-file=no test/runtests.jl

# confronto opzionale con interpreti esterni (solo sviluppo)
julia --startup-file=no test/oracles/oracle_tests.jl
```

## Conformità e indipendenza

La specifica eseguibile è `conformance/`: casi golden con stdout ed exit code attesi,
verificabili da qualunque implementazione (seed in codice macchina, implementazione in
Triad-Core, compilatore nativo). Vedi [BOOTSTRAP.md](BOOTSTRAP.md) per il piano che porta
Triad a non dipendere da Julia né da altri linguaggi ospiti.

```sh
julia --startup-file=no conformance/run.jl           # verifica (strumento di sviluppo)
julia --startup-file=no conformance/run.jl --update  # rigenera i golden (solo stage0)
```

## Struttura del progetto

```
triad.jl                    implementazione di riferimento (kernel e interprete)
syntax.jl                   lessico e parser Pratt (albero Node)
bin/triad                   launcher POSIX (sh)
bin/triad.cmd               launcher Windows (cmd)
bin/build_standalone.jl     packaging standalone (PackageCompiler)
test/runtests.jl            test dell'implementazione di riferimento
test/oracles/oracle_tests.jl confronto opzionale, solo sviluppo, con interpreti esterni
conformance/                suite golden: contratto eseguibile delle implementazioni
ai/                         benchmark di generazione LLM + verificatore (strumento di sviluppo)
seed/                       seed S0 in codice macchina (PE Windows + ELF Linux E0)
seed/linux-x86_64/          primo ELF Linux (E0): syscall write/exit, "Triad seed Linux OK"
editors/                    VS Code, Vim/Neovim e voce Linguist
examples/*.triad, *.td      esempi Triad (.triad canonica, .td alias storico)
BOOTSTRAP.md                piano di indipendenza da Julia e da ogni altro linguaggio
SPEC.md                     standard Triad: specifica normativa (0.2.0)
SPEC-CORE.md                profilo Triad-Core (normativo, per il bootstrap self-hosted)
STATUS.md                   stato di avanzamento e roadmap del bootstrap
VERSION / CHANGELOG.md      versione e storia dello standard
TUTORIAL.md                 tutorial completo d'uso
LICENSE                     licenza MIT (open source)
docs/                       note e documenti di supporto
```

## Requisiti

- **Standard Triad:** nessuna dipendenza; è definito da questo repository (`SPEC.md` +
  `conformance/`).
- **Implementazione di riferimento:** Julia ≥ 1.6 (testato con 1.13.1), zero pacchetti
  esterni; è transitoria e sarà sostituita dall'implementazione self-hosted
  ([BOOTSTRAP.md](BOOTSTRAP.md)).
- **Test oracle:** opzionali e solo per lo sviluppo (SWI-Prolog, SBCL); non servono per
  usare Triad né per la conformità.

## Licenza

Distribuito sotto licenza **MIT** — vedi [`LICENSE`](LICENSE).

---

Scritto e mantenuto da **Kilo** — agente software engineer per il progetto Triad 2.0.