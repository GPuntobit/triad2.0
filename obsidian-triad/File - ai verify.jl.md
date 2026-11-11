# `ai/verify.jl`

Source file: [`ai/verify.jl`](../ai/verify.jl) · [project folder `ai/`](../ai/)

## Role in the project

Checks Triad solutions by comparing the exit code and the observed output against the expected values; missing solutions are counted as skips. Graphify reported 6 nodes for the file and listed the definitions `parse_opts()`, `run_solution()`, `task_dirs()` and `main()`.

## Verified calls

```text
main()
├── parse_opts()
├── task_dirs()
└── run_solution()
```

- [`main()`](../ai/verify.jl#L48) parses the arguments, locates the task directories and compares the results.
- [`parse_opts()`](../ai/verify.jl#L16), [`run_solution()`](../ai/verify.jl#L37) and [`task_dirs()`](../ai/verify.jl#L45) are the callees Graphify returned.
- The file imports `Triad` ([`ai/verify.jl`](../ai/verify.jl#L14)); Graphify did not expose a matching import/export edge in the dedicated query.

## Links

- [[Grafo Graphify|Graphify graph]]
- [`ai/` folder](../ai/)
