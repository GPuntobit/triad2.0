# `ai/verify.jl`

File sorgente: [`ai/verify.jl`](../ai/verify.jl) · [cartella `ai/`](../ai/)

## Ruolo nel progetto

Verifica le soluzioni Triad confrontando codice d’uscita e output osservato con i valori attesi; le soluzioni mancanti vengono conteggiate come skip. Graphify ha riportato 6 nodi per il file e ha elencato le definizioni `parse_opts()`, `run_solution()`, `task_dirs()` e `main()`.

## Chiamate verificate

```text
main()
├── parse_opts()
├── task_dirs()
└── run_solution()
```

- [`main()`](../ai/verify.jl#L48) interpreta gli argomenti, trova le directory dei task e confronta i risultati.
- [`parse_opts()`](../ai/verify.jl#L16), [`run_solution()`](../ai/verify.jl#L37) e [`task_dirs()`](../ai/verify.jl#L45) sono i callee restituiti da Graphify.
- Il file importa `Triad` ([`ai/verify.jl`](../ai/verify.jl#L14)); Graphify non ha esposto un arco import/export corrispondente nella query dedicata.

## Collegamenti

- [[Grafo Graphify]]
- [Cartella `ai/`](../ai/)
