# TRID-Core 0.3 — bounded rule search and persistent experiment journal

## Scope

**This is a development/reference implementation in Python 3's standard
library, not a self-hosted cognitive engine written in Triad.** The existing
Triad S1 `--logic` engine is the intended executor of the `.triad` programs
emitted by the tool. Native S1 has not yet been verified by our execution
workspace; its executable tests must run on a local installation or CI.

The reference tool *does* construct distinct new Horn-rule bodies, rather than
only grounding a single already-written rule. It enumerates four connected,
range-restricted two-edge graph patterns:

- chain: `edge(X,Y), edge(Y,Z)`
- reverse chain: `edge(Y,X), edge(Z,Y)`
- common source: `edge(Y,X), edge(Y,Z)`
- common target: `edge(X,Y), edge(Z,Y)`

All rules are constrained to one domain and one named edge relation; reflexive
`X=Z` pairs are excluded. No arbitrary higher-order program synthesis or
recursive rule learning is claimed. The candidates' **names and target
examples are supplied** as supervision, not autonomously understood from a
book. Search over the set is automated and uses training examples to select a
structure; separate held-out examples only evaluate it afterward.

## Experiment and persistent history

```sh
sh cognitive/tests/run_03.sh
# additionally exercise generated programs in the native Triad S1 runtime:
TRID_RUN_NATIVE=1 sh cognitive/tests/run_03.sh
```

For an enduring local lab, use a directory outside Git (do not commit private
sources or user data):

```sh
python3 cognitive/tools/discover_03.py \
  --fixture cognitive/fixtures/discovery_03.json \
  --store "$HOME/trid-lab/hypotheses.jsonl" \
  --generated-dir "$HOME/trid-lab/generated"
./bin/triad --logic "$HOME/trid-lab/generated/family_grandparent.triad"
```

The local JSON Lines journal is *append only*: every candidate receives an
`evaluation` with its training and held-out metrics, provenance IDs for
observations, proof witnesses (and their source IDs), and one of two rule
statuses: `experimental` or `refuted`. A negative observation must be explicit;
missing data is **unknown**, not false. Rules classified as refuted are retained
with their counterexamples; a later reevaluation appends an event rather than
rewriting history. Identical events are deduplicated, and events carry a
sequence number and SHA-256 predecessor hash. A process lock protects
concurrent writers on Linux; journal contents are checked before append.
Tampering is detected but the journal is *not* cryptographically authenticated
against a malicious actor able to rewrite the entire file. Back up your lab.

For selected non-refuted rules, `conditional_proof` events hold the grounded
conclusion, source witnesses and status `demonstrated`, explicitly scoped as
`assuming_experimental_rule` and epistemic truth `unverified`. The latter
**does not promote a learned rule into a proven fact**. This separates logical
validity relative to assumptions from independent empirical validity.

## Verification and limitations

- Reference test suite: six unit tests cover alternative structural searches,
  held-out checks, explicit counterexamples, unknown/absence, provenance,
  domain isolation, replay/idempotence, corruption detection and atom sanitizing.
- Native S1 integration is optional and needs the installed seed; program
  generation validates the 65,535-byte input limit and uses single-line rules.
- The generator and persistent journal currently run in **Python 3**, an
  explicitly temporary development tool, not an S1 feature. Migration to native
  Triad and runtime file IO will require additional language/runtime work.
- A source ID is a *reference label*, not a source reliability score.
- Scores count training hits and errors; no statistically calibrated confidence
  or guarantee of generalization is implied by a held-out pass.
- This tool does not read arbitrary books, ask unsolicited questions, schedule
  background activity, autonomously name invented concepts, revise global
  belief networks, or merge experimental rules into stable cognitive memory.
- It does not include external source checks or a generic proof checker.

## Next milestone

Add an independently verifiable representation of ground inference proofs,
explicit acceptance policies for learned rules, contradiction dependencies and
an S1-native or fully Triad-backed persistent store. Do not call a rule
`demonstrated` without spelling out which axioms or hypotheses it assumes.
