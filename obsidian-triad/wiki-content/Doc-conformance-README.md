> Copia di [`conformance/README.md`](https://github.com/GPuntobit/triad2.0/blob/main/conformance/README.md) — torna a [Documenti](Documenti) · [Home](Home)

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

- **Triad-Full** — `cases/` (12 casi; oggi passa solo `errore`, il resto di Triad-Full non è implementato): tutto il linguaggio di `SPEC.md`.
- **Triad-Core** — `core/cases/` (37 casi, tutti verdi): solo il sottoinsieme normativo di
  [`SPEC-CORE.md`](https://github.com/GPuntobit/triad2.0/blob/main/SPEC-CORE.md), condiviso con Triad-Full; i primitivi di bootstrap non
  sono coperti da questa suite.

## Runner

- Definitivo (dalla milestone M4): `triad --conformance DIR`, implementato in
  Triad, eseguito dall'implementazione sotto test.
- Temporaneo (fase 0): `run.mjs`, runner Node (nessuna dipendenza da Julia):

```sh
node conformance/run.mjs            # verifica (profilo Core, default)
node conformance/run.mjs --update   # rigenera expected.out/expected.golden/expected.code

# profilo Full
node conformance/run.mjs --cases conformance/cases
node conformance/run.mjs --cases conformance/cases --update
```

Opzioni: `--cases DIR` (default `conformance/core/cases`), `--update`, `--skip a,b`
(default `liste`; la CI passa `--skip liste`, ma oggi `liste` passa anche lui).

Runtime usato, in ordine: `TRIAD_SEED` se impostato; su Linux/macOS l'interprete di
riferimento `seed/dev/triad_core.cjs` (il seed ELF è ancora E0); su Windows
`bin/triad-native.exe`, poi `seed/windows-x86_64/seed.exe`.

Golden: il runner legge `expected.out` e, se manca, `expected.golden` (copia identica).
Se mancano entrambi il caso fallisce con `golden mancante`: di solito il checkout non ha i
file (`git pull`), perché `.gitignore` esclude `*.out` con l'eccezione
`!conformance/**/expected.out`.

`run.jl` (Julia) è stato rimosso: la suite gira senza Julia né altri linguaggi.

## Casi attuali (`cases/`, profilo Full)

| Caso | Copre |
|---|---|
| `assaggio` | struct, dispatch, logica, macro, contratti |
| `famiglia` | fatti/regole, ricorsione, liste Prolog, negazione per fallimento |
| `macro` | codice come dato, quote/eval, macro, gensym |
| `tour` | tutti i paradigmi in un programma unico |
| `hello_shebang` | shebang, ARGS, effetti dichiarati |
| `valori` | valori, aritmetica, stringhe, liste, comprehension |
| `dispatch` | struct, operatori-funzione, dispatch, errori come dati |
| `prolog` | regole ricorsive, liste stile Prolog, `solve` |
| `destruttura` | `(a, b) = ...`, `for (k, v) in ...`, errore di arità |
| `garanzie_core` | contratti, budget, tracce, effetti |
| `macro_eval` | quote, sexpr, parse/unparse, macro |
| `errore` | errore non gestito: stdout vuoto, exit code 1 |

I golden Full sono stati generati dallo stage0 (Julia) il 2026-10-20 e sono congelati: da qui in poi sono loro il contratto.
