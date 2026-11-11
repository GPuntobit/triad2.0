# TRID-Core 0.4 — Independent Ground Proofs & Cognitive Memory Projection

## Scope and trust boundary

This is a **Python 3 standard-library development/reference tool**, not native Triad/S1 or a complete theorem prover. `proof_04.py` does not import `discover_03.py`; it independently recomputes candidate outcomes and checks witnesses against the labelled input facts.

The proof kernel recognizes the same finite four rule shapes as 0.3: chain, reverse chain, common source, and common target. It checks variable substitutions, both actual source-labelled edges, non-reflexive conclusions, example metrics, predicted conclusions, journal hash-chain integrity, and supplied positive/negative examples. **It does not establish that the sources or premises are true.** Hash chains detect partial corruption, not malicious replacement of a whole journal.

## Epistemic states

- `experimental`: candidate rule without an approved, matching definition.
- `refuted`: candidate entails an explicitly negative example, or the supplied training/test examples are contradictory.
- `consolidated_conditional`: a **human-approved** rule matching an explicit formal definition, with error-free labelled train and held-out examples.
- `demonstrated_conditional`: a ground conclusion follows from the accepted *conditional* rule and recorded facts; their external truth remains unverified.
- `suspended` and `suspended_dependency`: conclusions/rules whose source or definition was explicitly revoked.

The original `hypotheses.jsonl` experimental journal remains untouched and append-only. `memory.json` is an atomically replaced **derived view** of permitted conditional rules, witnesses and source dependencies. A revoked source causes affected individual proof paths to be suspended while unaffected paths remain visible.

## Run

```sh
sh cognitive/tests/run_04.sh
```

The script executes the independent 0.4 unit tests, invokes the 0.3 generator into a temporary directory, checks its journal, projects approved conditional knowledge, and checks that revocation suspends dependent conclusions.

For your persistent local lab, after producing a journal using `discover_03.py`:

```sh
python3 cognitive/tools/proof_04.py \
  --fixture cognitive/fixtures/discovery_03.json \
  --journal "$HOME/trid-lab/hypotheses.jsonl" \
  --definitions cognitive/fixtures/definitions_04.json \
  --memory "$HOME/trid-lab/memory.json" \
  --approve family_grandparent_chain \
  --approve family_sibling_common_source
```

**Important:** `--approve` is an explicit human/policy decision, not an automatic conclusion of scientific validity. The reference identifiers in `definitions_04.json` are illustrative, not independently vetted citations. Without explicit approval no rule is promoted. To suspend affected inferences, re-run with `--revoke-source book_02`.

## Current limitations

- Independent verification is limited to the same bounded two-edge rule language used by 0.3, not arbitrary proofs, recursive rules or a general Datalog kernel.
- Source references and formally named definitions are supplied, not discovered in unrestricted books.
- Dependency invalidation covers a single inference step, not an arbitrary recursive dependency graph.
- The derived snapshot is atomic but there is no multi-process consistency transaction spanning experimental journal, fixture and consolidated memory.
- Rules can be promoted **conditionally** only; there is no proof of real-world truth.
- Persistence and verification are written in transitional Python 3, not yet self-hosted Triad. Native S1 compatibility must be tested independently.
