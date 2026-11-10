# TRID Native Core — 0.1–0.4 migration experiment

**Language:** Triad-Core only (executed on the existing native S0 machine-code
seed). **Cognitive runtime dependencies:** no Python, Node.js, LLM, or
external logical inference engine. The POSIX `run.sh` launcher only concatenates
Triad sources, creates a locked state directory, redirects stdout to files and
publishes a verified journal/memory snapshot.

This is a **bounded native implementation of the 0.1–0.4 experiments**, not
the full 20-decision autonomous AI system. Historical Python prototypes remain
unchanged on their parent branch while native parity is being validated.

## Files

- `common.triad`: file reading, pipe-delimited record parsing, input
  validation, deterministic checksum-chain journal, deduplication.
- `discover.triad`: enumerates four structural two-edge Horn-rule candidates,
  selects by training score, checks held-out positive/negative evidence, emits
  candidate evaluations and grounded proof witnesses.
- `verify.triad`: **separate Triad-native verifier**, recomputes rule metrics
  and training selection without importing/distributing discovery functions,
  checks each proof from original labelled edges and creates a conditional
  cognitive-memory projection.
- `fixture.txt`: illustrative facts, explicitly labelled observations,
  conditional formal definitions and human approvals.
- `run.sh`: POSIX-only filesystem transport, state persistence and serialization.
- `tests/run.sh`: regression of inferred relations, restart idempotence,
  source revocation and journal tampering.

## Run (native S0, Linux)

```sh
sh cognitive/native/tests/run.sh
# user-specific persistent state directory, no root access:
sh cognitive/native/run.sh
cat "$HOME/.local/state/trid-native/memory.txt"
```

You can choose where to store the state and which fixture to load:

```sh
TRID_STATE_DIR="$HOME/my-trid-lab" sh cognitive/native/run.sh \
  cognitive/native/fixture.txt
```

The state directory contains `hypotheses.log` (history) and
`memory.txt` (derived view). Do not commit personal lab files.

## Model / epistemology

- `evaluation`: for a target predicate, each of the four structural shapes
  receives train/test TP, FP, FN and a deterministic ranking score.
- `proof`: source-labelled **ground path** is conditionally established by
  the independent verifier.
- Rules have **experimental** or **refuted** status. Their records are not
  deleted when contradicted.
- A rule can be projected into `consolidated_conditional` only if its selected
  training candidate has no known explicit counterexamples, positive train
  and held-out results, no missed positive labelled examples, one matching
  provided definition and an explicit `approve` record.
- Only accepted rule instances are `demonstrated_conditional`: validity is
  **relative to the supplied premise facts and formal rule**. This does not
  establish real-world truth or independent reliability of the input sources.
- A `revoke|source_name` record suspends individual proof paths that depend
  on that source (including definition source) without destroying the log.

## Intentionally limited / differences from the Python reference

1. No general induction of arbitrary or recursive logic: the four two-edge
   rule templates are predefined; the winning structure is learned from
   supervised examples. Names and definitions of target relations are supplied.
2. **Persistence uses text records via POSIX stdout redirection**, because the
   current S0 seed implements `readfile` but does **not** provide a native
   `writefile` primitive. All cognitive decisions remain in native Triad.
3. The native journal uses a **small deterministic polynomial checksum**, NOT
   SHA-256. It detects incidental corruption, **not adversarial tampering**.
   The existing 0.3 Python journal uses SHA-256 and is not binary compatible.
4. TRID-005 publishes a checked pair of journal and memory files via one
   atomic revision pointer on local Linux filesystems, using a permanent
   `flock` lock and SHA-256 accidental-corruption checks. This is **not**
   adversary-resistant authenticity or universal power-loss durability.
5. Input files must contain ASCII atoms (`[a-z][a-z0-9_]*`) and use
   `|`-delimited records; changing pre-existing evidence after a run causes a
   verification failure rather than automatic truth-maintenance. Append-only
   `revoke` records are supported. The persistent journal is not currently
   importable from the Python JSONL version.
6. S0 imposes finite memory/list limits and a 1 MiB `readfile` bound; the
   demonstration is intentionally small. It doesn't ingest free-form books,
   initiate dialogue, manage long-term curiosity, prove source truth, perform
   multi-level defeasible reasoning or implement all 20 decisions.
7. **Native runtime validation is required before claiming parity**. Run the
   conformance and native regression test on the user's Linux environment or
   GitHub Actions. No host Python is needed for this native smoke test.

## Design note

There is no modification to S0, S1, `SPEC.md` or their conformance files.
Once the experimental features pass native tests, improving the S0/S1 I/O
interface and the type-safe representation of proof DAGs should be handled
as separately reviewed language/runtime milestones.

## CI status and verification boundary

The historical S0 verifier failure was addressed in merged PR #99.
A [green TRID Native Core run](https://github.com/GPuntobit/triad2.0/actions/runs/42621287537)
exists on an **older commit**: it must not be cited as proof that current `main`
passes. The new [combined baseline workflow](../../.github/workflows/trid-baseline.yml)
runs all five required suites on one checkout and records its SHA.

The launcher rejects unexpected discovery stdout and malformed verifier
projections before publishing them. A native verifier debug print has been
removed. Fault injection checks that failures before publication preserve
the pre-existing journal and memory bytes.

**TRID-005:** the journal and projection are stored together in complete
revision directories, with a single atomic `.current` pointer. The old
top-level filenames are compatibility symlinks. Take the state lock for
consistent pair reads across concurrent commits. See
[STATE_STORE.md](STATE_STORE.md) for backup, restore, legacy migration and
the remaining power-loss/filesystem limitations.

The example S1 proofs remain conditional on manually supplied premises;
there is no autonomous rule synthesis or free-text understanding.

## Optional TRID-011 / TRID-012 event store and source-backed unified view

The [versioned event ledger](LEDGER_V1.md) and [S0/S1 unified
projection](UNIFIED_V1.md) are opt-in research paths, not changes to the
historical S0 memory format or S1 resolver. The ledger retains SHA-256-chained
events in immutable-by-convention revisions with deterministic native replay.
The projection imports S0 fixture and independently verified S0 memory records
alongside the restricted S1 graph grammar, preserving source metadata and
separating activation/association data from evidence and proofs. Neither tool
automatically approves an experimental rule or establishes source reliability.

## TRID-013: opt-in stable-ID incremental reconciliation

The [incremental v1 contract](INCREMENTAL_V1.md) adds native natural-key
identities, locked no-op/delta imports and latest-revision projection to the
TRID-011/012 research tools. It **does not** promote experimental rules or
suspended proofs into demonstrated knowledge. Use a separate event-state
directory rather than silently mixing legacy positional import IDs.

## Streaming ledger storage (TRID-011/013 enhancement)

The former 12 KB global ledger limit and 24 KB total delta-input limit
no longer apply. Each call to the native Triad seed validates a finite
record window; integrity across windows is checked by native per-ID
revision and provenance rules. Source input adapters and the native seed
still have **separate** bounds, while disk/CPU use grows with retained
copy-on-append revisions. See [LEDGER_V1.md](LEDGER_V1.md) and
[INCREMENTAL_V1.md](INCREMENTAL_V1.md) for exact boundaries and tests.
