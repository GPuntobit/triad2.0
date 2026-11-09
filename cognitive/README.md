# TRID-Core 0.1 — isolated cognitive proof of concept

TRID is an experimental cognitive layer **on top of Triad 2.0**, not a
modification of the language standard or the native seed. The first milestone
uses the existing native S1 `--logic` profile and does not require an LLM.

## What works in this milestone

- Store symbolic, domain-qualified directed edges with explicit source IDs.
- Derive **candidate** length-two relational connections, using a reusable
  logical composition rule (not a hard-coded family/grandparent predicate).
- Inspect the intermediate witness and both provenance IDs of each deduction.
- Keep domains and relation kinds separate to avoid accidental cross-domain joins.
- Check a no-result case and compare deterministic output with a golden file.

### Run

From the repository root (after the existing native seed is installed/built):

```sh
./bin/triad --logic cognitive/examples/discovery.triad
sh cognitive/tests/run.sh
```

The six lines of output are specified in `tests/expected.out`.

### Semantics and limits

A successful query demonstrates a **deduction from explicitly supplied facts
and a programmed two-hop inference schema**, not autonomous invention of the
inference schema. The resulting `candidate` is not independently verified
knowledge. Identifying a lexical name for it, proving general validity,
generating new candidate rules, confidence evaluation, and belief revision are
**not implemented**.

Source labels are immutable references within this fixture, not an actual
document ingestion system. There is **no persistent knowledge store**, learning
across sessions, automatic file reading, spontaneous dialogue, asynchronous
agent, or cognitive sandbox in this milestone. A restart reloads the fixture.

Existing S1 limits remain in force (input at most 65,535 bytes, bounded vectors
and heap); consult `selfhost/logic/README.md` for the authoritative limits.
The test makes no changes to S0, S1, `SPEC.md`, or existing golden files.

## Next milestones (proposed)

1. Persist facts, source locations, derived edges, and epistemic state without
   interpreting absence of evidence as a false proposition.
2. Implement a *separate* experimental hypothesis store with deduplication,
   revision history, and counterexample checks.
3. Search candidate logical programs and score held-out positive and negative
   examples; explicitly distinguish proofs from inductive hypotheses.
4. Introduce controlled-language ingestion and concept-to-term definitions.
5. Trigger bounded incremental propagation on new information and produce
   human-readable proof/explanation graphs.

## Architectural decisions

The project currently records 20 agreed decisions: 1–12 D; 13 A
(definitions); 14–17 D; 18 A (logical argument comparison); 19 A
(source-first reliability); 20 A (logical deduction discovery). These are
**requirements**, not claims that this proof of concept implements all of them.

## TRID-Core 0.2 experimental lab (branch feature/trid-core-0.2)

The additional example `cognitive/examples/laboratory.triad` derives candidate
composed edges and joins them to separately supplied positive and negative
observations, preserving review source identifiers. No negative evidence is
inferred from missing observations. This does not yet invent the generic rule
schema or persist runtime-discovered hypotheses.

```sh
sh cognitive/tests/run_02.sh
```

For its scope and explicit limitations, see
[cognitive/laboratory/README.md](laboratory/README.md). The 0.1 example and its
golden test are retained unchanged.
