# `ai/jev_audit.mjs`

Source file: [`ai/jev_audit.mjs`](../ai/jev_audit.mjs) · [project folder `ai/`](../ai/)

## Role in the project

Audit script for the versioned files: it locates the files, collects contextual facts, builds the state to analyse and produces a report. Graphify reported 20 symbols.

## Verified calls

The function [`sweep()`](../ai/jev_audit.mjs#L281) calls:

- [`trackedFiles()`](../ai/jev_audit.mjs#L67) to obtain the files;
- [`knownFacts()`](../ai/jev_audit.mjs#L142) and [`buildState()`](../ai/jev_audit.mjs#L245) to prepare the context;
- [`callSystemOne()`](../ai/jev_audit.mjs#L261) for the analysis;
- [`writeReport()`](../ai/jev_audit.mjs#L334) for the report.

Graphify also links `sweep()` to the file entry point (call site at L448). The calls above are `calls` edges returned with strict resolution.

## Links

- [[Grafo Graphify|Graphify graph]]
- [`ai/` folder](../ai/)
