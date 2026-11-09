# TRID-Core 0.2: experimental hypothesis laboratory

This is a **bounded S1 demonstration**, not a learning agent.

## Inputs and candidate rule

`examples/laboratory.triad` supplies `edge(domain, kind, from, to, source)`
facts from two independent domains and `observation(domain, kind, from, to,
polarity, review_source)` facts. The generic **pre-programmed** schema
`propose` composes two edges within the same domain and relation kind.
Each proposed edge preserves the witness and both originating source IDs.

`support` joins a proposal to an *explicit* positive observation, while
`challenge` joins it to an *explicit* negative observation. This models
positive and negative evidence without conflating an absent observation with
negative evidence. A proposal may have both support and challenge; neither
deletes the other.

The demo intentionally includes a disputed dependency claim. The negative
observation is a fixture for a contradiction, not an externally established
truth about dependency semantics. Neither `support` nor `challenge` should
be treated as a proof that the entire relation schema is universally valid or
invalid.

## Run and compare

```sh
./bin/triad --logic cognitive/examples/laboratory.triad
sh cognitive/tests/run_02.sh
```

The first three output lines show proposals and positive reviews in the family
domain. The next three show a proposed dependency and explicit negative
review. The last two are empty, demonstrating that absent evidence is *not*
converted into an opposite observation.

## What is NOT implemented

- Automatic invention/search of general relation schemas (the two-hop schema
  is written by a programmer).
- Scores, generalization tests, learned weights, proof of the schema's truth.
- Persisting a mutable laboratory between runs; the fixture files are versioned
  in Git but the runtime does not save new hypotheses.
- Promotion/rollback, event-driven propagation, independent reading of books,
  dialogue or spontaneous questions.
- Continuous agent behavior; the example exits after its queries.

The profile has bounded memory and a 65,535-byte input limit. The project must
stay within actual S1 syntax until larger runtime features are verified.

## Next engineering gate

Implement a source-to-source candidate generator that enumerates several
*bounded* permitted logical schemas (with deduplication); keep candidate
creation separate from positive/negative testing and persist the records. Only
then begin autonomous strategy selection or proof-graph construction.
