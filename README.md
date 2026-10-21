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

- **Specifica:** [SPEC.md](SPEC.md) — normativa, versione in [`STATUS.md                    stato di avanzamento e roadmap del bootstrap`nVERSION`](STATUS.md                    stato di avanzamento e roadmap del bootstrap`nVERSION); storia in
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
4. Posizioni standard di Julia (Linux/macOS/Windows)

Su Windows usare `triad.cmd` (funziona analogamente).

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

### 3. Imballaggio standalone (implementazione attuale)

L'implementazione di riferimento può essere impacchettata con PackageCompiler in un
eseguibile che non richiede Julia installato:

```sh
triad --build                   # crea bin/triad-native
bin/triad-native file.triad     # esegue senza Julia
```

Questo è un imballaggio, **non** l'indipendenza da Julia: il runtime resta Julia. La strada
per un Triad senza linguaggi ospiti è in [BOOTSTRAP.md](BOOTSTRAP.md); il packaging attuale
va inoltre completato (layout di pacchetto `Project.toml`/`src`).

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
seed/                       seed S0 in codice macchina (M3b2b3p: PE x86-64, simboli)
editors/                    VS Code, Vim/Neovim e voce Linguist
examples/*.triad, *.td      esempi Triad (.triad canonica, .td alias storico)
BOOTSTRAP.md                piano di indipendenza da Julia e da ogni altro linguaggio
SPEC.md                     standard Triad: specifica normativa (0.2.0)
SPEC-CORE.md                profilo Triad-Core (normativo, per il bootstrap self-hosted)
STATUS.md                   stato di avanzamento e roadmap del bootstrap
VERSION / CHANGELOG.md      versione e storia dello standard
TUTORIAL.md                 tutorial completo d'uso
```

## Requisiti

- **Standard Triad:** nessuna dipendenza; è definito da questo repository (`SPEC.md` +
  `conformance/`).
- **Implementazione di riferimento:** Julia ≥ 1.6 (testato con 1.13.1), zero pacchetti
  esterni; è transitoria e sarà sostituita dall'implementazione self-hosted
  ([BOOTSTRAP.md](BOOTSTRAP.md)).
- **Test oracle:** opzionali e solo per lo sviluppo (SWI-Prolog, SBCL); non servono per
  usare Triad né per la conformità.

---

Scritto e mantenuto da **Kilo** — agente software engineer per il progetto Triad 2.0.