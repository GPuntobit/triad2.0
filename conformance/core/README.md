# Profilo Triad-Core

Casi di conformità per il sottoinsieme **Triad-Core** (normativo in
[`../../SPEC-CORE.md`](../../SPEC-CORE.md), profilo §16.1 di [`../../SPEC.md`](../../SPEC.md)).

I programmi qui usano solo costrutti e primitive presenti **sia** in Triad-Core **sia** in
Triad-Full: gli stessi golden devono passare su entrambi i profili. I primitivi di bootstrap
(`readfile`, `strlen`, `strbyte`, `strsub`, `exit`) non compaiono qui perché non fanno parte
di Triad-Full: saranno coperti dai test del seed.

## Esecuzione

```sh
node conformance/run.mjs --cases conformance/core/cases          # verifica
node conformance/run.mjs --cases conformance/core/cases --update # golden
```

## Casi

| caso | copre |
|---|---|
| `interi` | interi, precedenza, parentesi, unario: coperto dal seed (M3b1) |
| `variabili` | variabili globali, assegnamenti, lookup: coperto dal seed (M3b2a) |
| `funzioni_semplici` | funzioni in forma breve con parametri e chiamate: coperto dal seed (M3b2b1) |
| `ricorsione` | confronti, ternario e ricorsione con caso base (`fattoriale`, `fib`): coperto dal seed (M3b2b2) |
| `confronti` | Bool stampabili (`true`/`false`) dal seed (M3b2b3a) |
| `operatori` | `%`, `^` destra-associata, letterali `true`/`false` (M3b2b3b) |
| `if_else` | blocchi `if`/`else`/`end` e annidamento (M3b2b3c) |
| `while_loop` | `while`/`end`, aggiornamento variabili (M3b2b3d) |
| `lambda` | lambda a un parametro, anche come argomento (M3b2b3e) |
| `closure` | cattura del parametro — coperto dal seed (M3b2b3k) |
| `valori` | Int, Bool, String, Symbol, List, Nothing |
| `aritmetica` | precedenza, `%`, `^`, unari, confronti, logica, `+=` — coperto dal seed (M3b2b3g) |
| `controllo` | `while`, `if`/`elseif`/`else`, `let`, `begin` |
| `funzioni` | funzioni nominali, forma breve, ricorsione, ternario — coperto dal seed (M3b2b3h) |
| `funzioni_blocco` | funzione con corpo multi-istruzione e valore dell'ultima espressione — coperto dal seed (M3b2b3i) |
| `begin_block` | blocco `begin … end` — coperto dal seed (M3b2b3l) |
| `liste` | indici 1-based, `length`, `push!`, iterazione con `while` |
| `stringhe_base` | stringhe letterali, stampa, `length` — coperto dal seed (M3b2b3m) |
| `nothing_base` | valore `nothing` e stampa — coperto dal seed (M3b2b3n) |
| `stringhe_concat` | concatenazione `*` e `length` — coperto dal seed (M3b2b3o) |
| `simboli_base` | simboli `:nome` e stampa — coperto dal seed (M3b2b3p) |
| `stringhe_multi` | concatenazione concatenata e `length` — coperto dal seed |
| `stringhe` | concatenazione `*`, `length`, `string` |
| `chiusure` | lambda che catturano variabili, più chiusure indipendenti |
| `chiusure_local` | chiusura che cattura un locale del corpo funzione — coperto dal seed |
| `let_annidato` | `let` annidati con shadowing — coperto dal seed |
| `let_chiusura` | lambda dentro `let` con lookup dinamico — coperto dal seed |
| `chiusura_in_if` | lambda dentro `if` — coperto dal seed |
| `scope` | locale vs globale, shadowing con `let` — coperto dal seed (M3b2b3j) |

I golden sono generati dallo stage0 e congelati; ogni implementazione Core (seed compreso)
deve riprodurli byte per byte con gli stessi exit code.
