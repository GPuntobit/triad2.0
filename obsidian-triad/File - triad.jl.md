# `triad.jl`

File sorgente: [`triad.jl`](../triad.jl) · [cartella del progetto](../)

## Ruolo nel progetto

Runtime principale del linguaggio Triad. Graphify ha riportato 124 simboli per questo file; tra quelli visibili nelle query figurano i tipi `TVar`, `Term`, `Cons`, `Node`, `Rec`, `Err`, `Solution`, gli ambienti (`Env`) e le funzioni per esecuzione e caricamento.

## Chiamate verificate

Il percorso di caricamento indicizzato è:

```text
load_file!()
├── find_source()
├── run_source()
└── report()
```

- [`load_file!()`](../triad.jl#L1725) risolve il percorso con [`find_source()`](../triad.jl#L1716), invia il sorgente a [`run_source()`](../triad.jl#L1656) e segnala gli errori tramite [`report()`](../triad.jl#L1707).
- `reload!()` è definita accanto alle funzioni di caricamento ([`triad.jl`](../triad.jl#L1739)).

## Collegamenti

- [[Grafo Graphify]]
- [Radice del progetto](../)
