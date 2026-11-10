# TRID-012 — unified, source-backed S0/S1 projection (research profile)

This is a bounded **opt-in** bridge layered on TRID-010 schema v1 and the
TRID-011 deterministic event ledger. S0 and S1 original sources are
read-only: the bridge does not modify the historical S0 journal, S0 memory,
or S1 graph. All record parsing, metadata transformation, and derived
status computation are native Triad-Core functions. POSIX/Linux scripts
only check safe input syntax, stage strings, invoke Triad, and publish
validated bytes through the TRID-011 ledger.

## Source imports and provenance

1. The original S0 fixture, via schema_v1.sh --import-s0, produces
   legacy_N records with exact comma-joined original pipe fields in payload.
   The importer preserves explicit edge sources, human approvals,
   positive/negative reviews, definitions, and revocation events.
2. The independently verified S0 memory projection, via
   schema_v1.sh --import-s0-memory, produces s0memory_N rule_candidate and
   proof_node records. The original rule/claim bytes remain recoverable
   from payload. Provenance references use source1, source2 and definition
   dependency labels. The old suspended_dependency rule status is mapped
   to suspended while remaining explicit in payload.
3. The restricted S1 graph_06.facts syntax, via schema_s1.sh, produces
   s1graph_N evidence, rule_candidate, revocation and fact records.
   S1 evidence sources remain src_*; association links are stored as
   declared facts in a separate s1_association domain. Comment lines
   are ignored, while source fact order and atom values are preserved.
   Association links are **not** converted into proven conclusions or
   observed activation pulses.

All generated events have a stable identity only for an *unchanged*
snapshot input and row order. Changing the input before reimport can
reassign _N identities. Reimporting the same snapshot into the same
journal is intentionally rejected as a duplicate, not interpreted as a
second independent observation. Versioned cross-snapshot reconciliation
and import from Python JSONL are future milestones (TRID-013/014).

## Commands

    # First, obtain a verified S0 memory snapshot under its native state lock.
    TRID_STATE_DIR="$HOME/trid-s0" sh cognitive/native/run.sh cognitive/native/fixture.txt

    # Build canonical data only; do not mutate source state.
    sh cognitive/native/unify_v1.sh --build \
      cognitive/native/fixture.txt \
      "$HOME/trid-s0/.current/memory.txt" \
      cognitive/native/graph_06.facts > combined.v1

    # Publish that deterministic batch as a complete TRID-011 ledger revision.
    TRID_EVENT_STATE_DIR="$HOME/trid-events" sh cognitive/native/unify_v1.sh --ingest \
      cognitive/native/fixture.txt \
      "$HOME/trid-s0/.current/memory.txt" \
      cognitive/native/graph_06.facts

    TRID_EVENT_STATE_DIR="$HOME/trid-events" sh cognitive/native/journal_v1.sh --replay > replayed.v1
    sh cognitive/native/unify_v1.sh --project replayed.v1 > projection.view

The --build command validates the entire combined ordered stream before
producing any stdout. --ingest additionally validates and atomically
appends to the TRID-011 journal. --project consumes canonical v1 events
and produces deterministic, line-oriented read-only views:

    lane|effective_state|v1|kind|id|domain|source|recorded_state|revision|assumptions|dependencies|origin|timestamp|payload

Lanes are evidence, proofs, hypotheses, revocations, activation_network,
activation, and metadata. No event is deleted, reordered, or promoted.
For example, a recorded demonstrated_conditional proof_node with a
revoked dependency appears in the proofs lane with effective_state
suspended; the recorded state remains demonstrated_conditional in the
event fields. A retained alternative source path is unaffected.
Refuted rules remain refuted rather than being masked by revocations.

The native projection checks revocations within a bounded provenance
family. legacy_s0 and s0_memory share the s0 family; s1_graph and
s1_association share the s1 family. A revocation in one family cannot
accidentally suspend a same-named source in the other family. S1
associations are never proof. Explicit activation_pulse events remain
in the activation lane even when a supporting evidence source is
revoked: **activation is salience, never truth or accepted proof**.

## Limitations / nonclaims

- Import is restricted to S0 pipe fixtures and verifier memory plus the
  original S1 0.6 fact grammar. It is not free-text interpretation, an
  arbitrary Prolog parser, or an incremental distributed proof DAG.
- The schema retains source labels, not independently authenticated
  source reliability. Rule acceptance/proof checking remains in the
  respective native S0/S1 engines, not repeated by this projection.
- A reader must select one immutable S0 revision (and capture a stable S1
  graph file) before building the combined snapshot. The bridge does
  not atomically snapshot two independent state stores.
- Entire import/output remains bounded by the 12,000-byte v1 payload
  budget and the finite native seed heap. No unlimited memory claim.
- Historic events are immutable-by-convention, **not cryptographically
  signed or protected against an administrator rewriting all digests**.
- No automatic knowledge consolidation, human-independent approval,
  continuous scheduler, or true native writefile is introduced.

Tests: sh cognitive/native/tests/run_unify_v1.sh and the five-suite
same-SHA GitHub cognitive baseline, including TRID-011 replay tests.
