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

The wrapper uses a permanent `flock` mutex at
`$TRID_GRAPH_STATE_DIR/.mutex`; a SIGKILL releases its kernel lock.
Each execution builds output in a private work directory and publishes stdout
only after all queries finish. Unsafe state-directory symlinks, symlinked
`graph.facts` (including dangling links), malformed records and oversized
graphs are rejected. This is a **single graph file**, not an atomic
multi-store snapshot with S0 and the event ledger.

The wrapper executes each recursive proof/activation query in a separate S1 process to reset the seed's finite bump-heap budget; it concatenates the outputs in a deterministic order. Byte-exact golden files cover retained and suspended alternative proofs, activated nodes, and the changed status after revoking a second source.

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
- This 0.6 `graph.facts` file itself has no timestamps, versioned commits,
  signed provenance or automatic reconciliation with S0. Newer **opt-in**
  [TRID-011/012/013](README.md) event-ledger and source-backed reconciliation
  tools add a separate, versioned history. They do not magically make
  `graph.facts` transactional or authenticate source truth.
- No continuous scheduler, weighted pulses, autonomous goals, natural-language
  learning or arbitrary metacognitive planning.
- S0 and S1 gates are independent. Both passed on
  `main` SHA `7ff41abad93d2c646617d7d620c3bdda1c920a1a` in
  [TRID Required](https://github.com/GPuntobit/triad2.0/actions/runs/43021172705).
  For another candidate SHA, the checks must be rerun.
- `TRID_TEST_GRAPH_CRASH_AT=after_lock|before_output` intentionally sends
  **actual SIGKILL** to the S1 runner. The regression checks Linux exit 137,
  empty partial stdout, exact graph bytes and a successful restart. This is
  not a physical power-failure test.

**Existing additional checks:** run
`sh cognitive/native/tests/run_integration_071.sh` and
`sh cognitive/native/tests/run_epistemic_070.sh` for independent
restart/recovery and epistemic checks, respectively. Their
[scope and limitations](QA_070_071_074.md) are documented separately.

**Still open beyond 0.6:** native proof persistence and general
write-to-disk I/O, explicit negative-evidence semantics for general recursive
rules, verification of arbitrarily generated proofs, source reliability,
weighted activation and scheduling. These are separate milestones, not
features of the bounded 0.6 demonstration.
