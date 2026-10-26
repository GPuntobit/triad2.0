# Conformance suite — il contratto eseguibile di Triad

Questa directory è la **specifica eseguibile** usata per verificare qualunque
implementazione di Triad: il seed in codice macchina, l'implementazione in
Triad-Core e il futuro compilatore nativo.

## Formato di un caso

```
cases/<nome>/
  program.td      # programma Triad, eseguito come script
  args.txt        # opzionale: un argomento per riga (ARGS)
  expected.out    # stdout atteso (byte esatti, fine riga LF)
  expected.code   # exit code atteso
```

Regole:

- il caso passa se stdout è **byte per byte** uguale a `expected.out` e l'exit
  code è quello atteso;
- stderr non è confrontato (i messaggi d'errore sono diagnostici);
- niente input interattivo, niente stdin: la suite deve essere deterministica;
- i golden sono dati statici committati: **non richiedono Julia** per essere
  verificati.

## Profili

- **Triad-Full** — `cases/` (12 casi): tutto il linguaggio di `SPEC.md`.
- **Triad-Core** — `core/cases/` (33 casi): solo il sottoinsieme normativo di
  [`SPEC-CORE.md`](../SPEC-CORE.md), condiviso con Triad-Full; i primitivi di bootstrap non
  sono coperti da questa suite.

## Runner

- Definitivo (dalla milestone M4): `triad --conformance DIR`, implementato in
  Triad, eseguito dall'implementazione sotto test.
- Temporaneo (fase 0): `run.mjs`, runner Node che usa il seed in codice macchina:

```sh
node conformance/run.mjs --update   # rigenera expected.*
node conformance/run.mjs            # verifica (profilo Full)

# profilo Core
node conformance/run.mjs --cases conformance/core/cases
node conformance/run.mjs --cases conformance/core/cases --update
```

`run.jl` è uno strumento di sviluppo: da M3 in poi la suite deve poter girare
senza Julia né altri linguaggi.

## Casi attuali (`cases/`, profilo Full)

| Caso | Copre |
|---|---|
| `assaggio` | struct, dispatch, logica, macro, contratti |
| `famiglia` | fatti/regole, ricorsione, liste Prolog, negazione per fallimento |
| `macro` | codice come dato, quote/eval, macro, gensym |
| `tour` | tutti i paradigmi in un programma unico |
| `hello_shebang` | shebang, ARGS, effetti dichiarati |
| `valori` | valori, aritmetica, stringhe, liste, comprehension |
| `liste_base` | costruzione e stampa seed di liste di interi |
| `liste_push` | `push!` su liste di interi |
| `dispatch` | struct, operatori-funzione, dispatch, errori come dati |
| `prolog` | regole ricorsive, liste stile Prolog, `solve` |
| `destruttura` | `(a, b) = ...`, `for (k, v) in ...`, errore di arità |
| `garanzie_core` | contratti, budget, tracce, effetti |
| `macro_eval` | quote, sexpr, parse/unparse, macro |
| `errore` | errore non gestito: stdout vuoto, exit code 1 |

I golden sono stati generati dallo stage0 il 2026-10-20 e sono congelati: da qui in poi sono loro il contratto.
