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
git switch feature/trid-native-core
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
4. State updates are protected by one lock and staged in temporary files, but
   the journal and memory file are **not a single transactional filesystem
   commit**. Keep backups and do not use it for critical data.
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

## Real GitHub Actions status — native migration is NOT yet complete

The `TRID Native Core` workflow has executed on Ubuntu 24.04 using the
machine-code seed. The stand-alone `s1_discovery.triad` sample **passed**
the native S1 smoke check. The larger native S0
`common.triad + discover.triad + verify.triad` implementation
**still fails** with `seed: error` during discovery, and the end-to-end
persistent-laboratory regression has **not passed**. The branch and PR must
remain draft.

The sources were adjusted for actual seed gaps (no function `return`,
no reliable native string `==`, no usable `ARGS`), and a static seed
guard pass is not a substitute for a real execution test. The current
S0 implementation contains temporary diagnostic output; it is **not ready
for persistent production data**. Do not treat it as a drop-in replacement
for the Python reference tool until a native regression is green.

The S1 sample is a verified native deduction **from a manually declared
logical schema**; it is not autonomous rule synthesis. Existing Python
0.3/0.4 tools remain retained for preservation and baseline comparison.
