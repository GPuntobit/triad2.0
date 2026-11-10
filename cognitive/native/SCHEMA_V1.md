# TRID-010 — common native cognitive record schema v1

**Status:** bounded, typed research data format and native Triad-Core
validation/serialization. The separately implemented
[TRID-011 ledger](LEDGER_V1.md) and
[TRID-012 S0/S1 projection](UNIFIED_V1.md) use this format. The schema
itself is **not** a transactional database, independently authenticated
proof checker, or autonomous knowledge-consolidation engine.

## Canonical representation

One record per line with exactly 12 nonempty pipe-delimited fields:

    v1|kind|id|domain|source|state|revision|assumptions|dependencies|origin|timestamp|payload

Each record provides:
1. A literal version marker (v1).
2. A kind from the closed set in the table below.
3. A stable identifier within the producer's domain, such as fact_a.
4. A domain identifier.
5. The source ID, or the literal none when none is known.
6. A typed epistemic state, never a floating-point truth probability.
7. A strictly positive decimal revision (up to 12 digits).
8. An assumption/reference ID, or none.
9. A comma-separated dependency ID list or none.
10. An origin event ID.
11. Optional Unix seconds timestamp as nonnegative decimal, or none.
12. An opaque **data-only** payload (never Triad source code).

Valid names are lowercase ASCII [a-z][a-z0-9_]* with at most 64 bytes
for primary fields. Payloads use only lowercase ASCII letters, digits,
underscore, comma, colon, dot, equal and dash, length 1..256.
Dependencies are comma-delimited valid atoms, max 256 bytes. The timestamp
and revision are decimal, with no leading zeroes except timestamp 0.
No quotes, backslashes, newlines embedded in a record, or shell expansion.

A particular (id,revision) pair must be unique within an input file;
one id cannot silently change its kind across revisions. More than one
revision of the same ID is preserved when explicitly supplied, but a
future event log must enforce monotone ordering (TRID-011).

## Entity kinds

| Wire kind | Corresponding TRID entity | Meaning |
|---|---|---|
| fact | Fact | Source-bound asserted fact, not externally proven truth |
| rule_candidate | RuleCandidate | Experimental generalization, not deduced theorem |
| evidence | Evidence | Labelled observation/review including negative evidence |
| proof_node | ProofNode | Conditional inference step, not free-standing truth |
| proof_edge | ProofEdge | Dependency/witness relation |
| revocation | Revocation | Explicit invalidation, retained historically |
| activation_pulse | ActivationPulse | Salience/attention only, **never evidence or belief** |
| source | Source | Provenance for imported or native data |
| definition | Definition | Declared meaning and expected relation |
| revision | Revision | Audit/reviewer actions or revision metadata |
| experiment | Experiment | Isolated test or experimental hypothesis context |

States accepted by the parser are asserted_conditional, experimental,
refuted, suspended, unknown, consolidated_conditional,
demonstrated_conditional, active, proposed, declared, reviewed_positive,
reviewed_negative, approved_conditional, revoked and created.
A revocation record must have state revoked; activation pulses must have
state active. Other kind/state validity rules require a later policy
layer; the schema alone does not authorize promotion in memory.

## Executable schema gates

    sh cognitive/native/schema_v1.sh --validate FILE
    sh cognitive/native/schema_v1.sh --import-s0 cognitive/native/fixture.txt
    sh cognitive/native/tests/run_schema_v1.sh

The POSIX wrapper only rejects hostile bytes and serializes input rows
as safe Triad string literals. Native functions in schema_v1.triad
validate all rows before output and reconstruct the **same 12 fields in
their original order**, byte for byte. An invalid input causes nonzero
exit and *no published normalized records*. No Python/Node/LLM inference
runs on the data.

For the old S0 fixture format, --import-s0 emits deterministic
identifiers legacy_1, legacy_2, etc., in original line order. The entire
original record is preserved losslessly as comma-delimited payload atoms
(source fixture atoms contain no commas). Source labels, explicit
positive/negative reviews, approvals and revocations remain distinguishable.
The importer does not automatically declare any world truth and does not
replace the original data. The mapping is idempotent for the same fixture;
line insertions can renumber legacy_N IDs, so it is **not** a global
cross-import identity service.

A bounded explicit import for the original S1 graph_06.facts grammar and for
verified S0 rule/claim projections is now available through TRID-012.
Python JSONL 0.3/0.4 migration remains a separate task (TRID-014);
no arbitrary S1 code or free text is accepted as an event. The schema parser
still has no native direct-write API; TRID-011 provides separate POSIX/Linux
durable event transport and replay.
