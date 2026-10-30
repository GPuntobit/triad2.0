# `triad.jl`
Source file: [`triad.jl`](../triad.jl) · [project folder](../)
## Role in the project
Main runtime of the Triad language. Graphify reported 124 symbols for this file; Those visible in queries include types `TVar`, `Term`, `Cons`, `Node`, `Rec`, `Err`, `Solution`, environments (`Env`), and functions for execution and loading.
## Verified calls
The indexed load path is:
```text
load_file!()
├── find_source()
├── run_source()
└── report()
```

- [`load_file!()`](../triad.jl#L1725) resolves the path with [`find_source()`](../triad.jl#L1716), sends the source to [`run_source()`](../triad.jl#L1656) and reports errors with [`report()`](../triad.jl#L1707).
- `reload!()` is defined next to load functions ([`triad.jl`](../triad.jl#L1739)).
## Links
- [[Grafo Graphify|Graphify graph]]
- [Project root](../)