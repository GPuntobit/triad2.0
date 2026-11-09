# TRID-Core 0.6 — persistent S1 graph with bounded recursive proofs

This is a native Triad **S1 logic experiment**, using the machine-code S0
seed to run S1 through `bin/triad --logic`. Python, Node.js, and external
LLMs are **not** used in the cognitive inference path.

## Run

```sh
sh cognitive/native/tests/run_06.sh
TRID_GRAPH_STATE_DIR="$HOME/trid-graph" sh cognitive/native/run_06.sh
```

The script initializes `$TRID_GRAPH_STATE_DIR/graph.facts` on first run and
retains it across subsequent runs. This is **durable source data**, not a
mutable database written directly from S1: current S1 has no general
write-to-disk API. The POSIX wrapper performs restricted record validation and
concatenates facts with the Triad logic program; **all graph reasoning runs in
Triad S1**.

The wrapper accepts only `fact evidence`, `fact association`, `fact revoked`
and `fact rule_state` records with constrained ASCII atoms, not arbitrary
Triad code. Rejecting invalid records is necessary because the S1 input is
compiled from text. Changes and revocations to `graph.facts` remain across
restart. This is not an append-only tamper-evident audit journal.

## Reasoning, epistemology and bounded pulse behavior

- `proof_path` is recursive over labelled `evidence` edges, carrying ordered
  source labels and a visited-node list to avoid simple graph cycles.
- `uses_revoked` identifies explicit revocations anywhere in each proof path.
  `retained_path` and `suspended_path` classify **proof paths**, not the
  objective truth of a conclusion. Where two routes support the same result,
  revoking one source suspends that route without deleting the other.
- `active_node` propagates along `association` edges through a **finite
  fuel budget**, here `:h6`, and tracks visited nodes. Graph cycles do not
  create an infinite unbounded pulse.
- Activation is *salience*, **not truth, reliability, proof, or acceptance**.
  The rule state `experimental` remains separate from both derivation and
  activation.
- The example has a five-edge path and an alternate three-edge path to the
  same node, one explicitly revoked source and a cycle in the activation
  network.

## Explicit limits

- "Arbitrary dependencies" means arbitrary **finite topology and path
  length within a configured S1 query budget**, not unrestricted execution,
  infinite proof depth or a general proof DAG with arbitrary rules.
- Recursive S1 resolution on large/cyclic graphs is expensive and subject to
  strict S1 heap/step limits. The fuel list is finite and fixed in the demo.
- A "retained" proof is one for which **no explicit revocation is known**;
  this does not prove the source is trustworthy. Rule schemas remain
  prewritten rather than learned.
- The persisted graph does not yet include timestamps, versions, append-only
  history, per-event signed provenance or automatic reconciliation with the
  older S0 journal.
- No continuous scheduler, weighted pulses, autonomous goals, natural-language
  learning or arbitrary metacognitive planning.
- The previous 0.4 S0 journal workflow remains a separate, unresolved gate;
  this feature does not replace it.

Further work should add verified source-to-file persistence of the proof graph,
a committed revision/event schema, negative evidence and independent proof
checking for recursive witnesses, then weighted activation and scheduling.
