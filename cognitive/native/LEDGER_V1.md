# TRID-011 — append-only research event ledger, deterministic native replay

The record format is TRID-010 schema v1, preserved byte-for-byte:

    v1|kind|id|domain|source|state|revision|assumptions|dependencies|origin|timestamp|payload

The Linux transport script journal_v1.sh stores records in an unkeyed SHA-256
hash chain. A physical journal line has the form:

    sequence|previous_sha256|event_sha256|<canonical v1 record>

The event digest is SHA-256 of the UTF-8 bytes of
sequence + "|" + predecessor + "|" + record + newline. The first predecessor
is 64 zeroes; sequence starts at 1 and is contiguous. All individual events,
the complete history, type stability and strictly increasing per-ID revisions
are validated before a new revision can become visible. Native Triad-Core
schema_emit_ledger performs the typed identity and revision checks. Shell
computes byte hashes and safely moves immutable-by-convention files; it does
not reason over the cognitive contents.

## Usage

    TRID_EVENT_STATE_DIR="$HOME/trid-events" sh cognitive/native/journal_v1.sh --append events.v1
    TRID_EVENT_STATE_DIR="$HOME/trid-events" sh cognitive/native/journal_v1.sh --verify
    TRID_EVENT_STATE_DIR="$HOME/trid-events" sh cognitive/native/journal_v1.sh --replay > events-replayed.v1
    TRID_EVENT_STATE_DIR="$HOME/trid-events" sh cognitive/native/journal_v1.sh --recover

Append accepts one or more newline-terminated canonical v1 events in a
regular file. Repeated (id,revision) pairs, decreasing revisions, type or
domain drift and any existing history corruption fail **before** publication.
Replay reconstructs exactly the original concatenated stream in append
order; it never reorders facts by kind or timestamp. An empty journal replays
as an empty stream. A command never prints partially validated data to stdout.

## Durability model and limits

The journal is a **logically append-only** stream implemented as retained
immutable generation snapshots (copy-on-append, not OS O_APPEND). Each
generation lives at:

    .revisions/r00000001/events.log
    .revisions/r00000001/checksums.sha256
    .current -> .revisions/r00000001

The single .current pointer is switched using same-filesystem atomic rename
under a permanent flock. A killed writer before the pointer switch leaves the
old generation readable; after switching it leaves the new one readable.
A recovery operation cleans abandoned working directories but never
automatically rewinds a corrupt current pointer. Unreferenced revision
snapshots are retained for audit. The lock avoids concurrent appends, but
other tools should not read/modify the backing generation without the lock.

SHA-256 checksums and the predecessor chain detect accidental corruption,
truncated histories (unless a trusted administrator also rewrites the
checksum manifest) and changes where only the outer checksum is recomputed.
They are **not a cryptographic signature, remote trust anchor, immutable
storage policy, or protection against an attacker who can rewrite both
events and hashes**. Separate backups and suitable permissions remain needed.

The current research seed and schema transport bound the entire v1 payload
stream to 12,000 bytes and the chain to at most 1,000 events. This is not an
unbounded event database; the actual byte budget is typically reached first.
No external clocks, random IDs, full S1 graph import, automatic approval
or semantic truth promotion are performed. Integration with S0 and S1
projections is TRID-012, not a claim of this ledger alone.

## Verification

Run:

    sh cognitive/native/tests/run_ledger_v1.sh
    sh cognitive/native/tests/run.sh

The tests inject SIGKILL at after_stage, before_pointer and after_pointer,
verify exact replay after restart, reject duplicate/nonmonotone updates,
check a preserved prefix, competing locks, hash tampering and truncation.
The same-SHA TRID cognitive baseline runs these tests alongside native
S0 and S1 conformance.
