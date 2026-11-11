#!/bin/sh
# TRID-015: historical revision queries, effective revocations, provenance,
# stable diffs, tamper rejection, and no mutation of the current ledger.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
WORK=$(mktemp -d)
trap 'rm -rf -- "$WORK"' EXIT
export TRID_EVENT_STATE_DIR="$WORK/state"
JOURNAL="$ROOT/cognitive/native/journal_v1.sh"
HISTORY="$ROOT/cognitive/native/history_v1.sh"

cat > "$WORK/batch1.v1" <<'EOF'
v1|source|source_a|family|none|declared|1|none|none|event_a|none|book_a
v1|fact|fact_a|family|source_a|asserted_conditional|1|source_a|none|event_b|none|parent,mario,luca
v1|fact|fact_b|family|source_b|asserted_conditional|1|source_b|none|event_c|none|parent,sara,leo
EOF
sh "$JOURNAL" --append "$WORK/batch1.v1"
first=$(readlink "$TRID_EVENT_STATE_DIR/.current")
[ "$first" = '.revisions/r00000001' ]
sh "$HISTORY" --as-of r00000001 > "$WORK/first.view"
[ "$(wc -l < "$WORK/first.view")" -eq 3 ]
grep -Fq 'evidence|asserted_conditional|v1|fact|fact_a|family|source_a|' "$WORK/first.view"
grep -Fq 'evidence|asserted_conditional|v1|fact|fact_b|family|source_b|' "$WORK/first.view"
# As-of is byte-exact and the same revision has no diff.
sh "$HISTORY" --as-of r00000001 > "$WORK/first.repeat"
cmp "$WORK/first.view" "$WORK/first.repeat"
sh "$HISTORY" --diff r00000001 r00000001 > "$WORK/noop.diff"
[ ! -s "$WORK/noop.diff" ]

cat > "$WORK/batch2.v1" <<'EOF'
v1|revocation|revoke_a|family|source_a|revoked|1|none|fact_a|event_d|none|explicit_revocation
EOF
sh "$JOURNAL" --append "$WORK/batch2.v1"
second=$(readlink "$TRID_EVENT_STATE_DIR/.current")
[ "$second" = '.revisions/r00000002' ]
sh "$HISTORY" --as-of r00000001 > "$WORK/unchanged.view"
cmp "$WORK/first.view" "$WORK/unchanged.view"
sh "$HISTORY" --as-of r00000002 > "$WORK/second.view"
grep -Fq 'evidence|suspended|v1|fact|fact_a|family|source_a|' "$WORK/second.view"
grep -Fq 'evidence|asserted_conditional|v1|fact|fact_b|family|source_b|' "$WORK/second.view"
grep -Fq 'revocations|revoked|v1|revocation|revoke_a|' "$WORK/second.view"
sh "$HISTORY" --diff r00000001 r00000002 > "$WORK/revoked.diff"
grep -Fq -- '-evidence|asserted_conditional|v1|fact|fact_a|' "$WORK/revoked.diff"
grep -Fq -- '+evidence|suspended|v1|fact|fact_a|' "$WORK/revoked.diff"

# An explicit new revision may change provenance without changing a truth score.
cat > "$WORK/batch3.v1" <<'EOF'
v1|fact|fact_b|family|source_c|asserted_conditional|2|source_c|none|event_e|none|parent,sara,leo
EOF
sh "$JOURNAL" --append "$WORK/batch3.v1"
third=$(readlink "$TRID_EVENT_STATE_DIR/.current")
[ "$third" = '.revisions/r00000003' ]
sh "$HISTORY" --as-of r00000003 > "$WORK/third.view"
grep -Fq 'evidence|asserted_conditional|v1|fact|fact_b|family|source_c|' "$WORK/third.view"
sh "$HISTORY" --diff r00000002 r00000003 > "$WORK/provenance.diff"
grep -Fq -- '-evidence|asserted_conditional|v1|fact|fact_b|family|source_b|' "$WORK/provenance.diff"
grep -Fq -- '+evidence|asserted_conditional|v1|fact|fact_b|family|source_c|' "$WORK/provenance.diff"
sh "$HISTORY" --diff r00000002 r00000003 > "$WORK/provenance.repeat"
cmp "$WORK/provenance.diff" "$WORK/provenance.repeat"
[ "$third" = "$(readlink "$TRID_EVENT_STATE_DIR/.current")" ]

# Rejected/unsupported revisions never emit partial data.
for invalid in r00000000 r00000004 r0000000x ../r00000001; do
  if sh "$HISTORY" --as-of "$invalid" > "$WORK/invalid.out" 2> "$WORK/invalid.err"; then
    echo "TRID-015 accepted historical revision $invalid" >&2
    exit 1
  fi
  [ ! -s "$WORK/invalid.out" ]
done
[ "$third" = "$(readlink "$TRID_EVENT_STATE_DIR/.current")" ]
if sh "$HISTORY" --diff r00000001 r00000004 > "$WORK/invalid-diff.out" 2> "$WORK/invalid-diff.err"; then
  echo 'TRID-015 accepted an invalid diff endpoint' >&2; exit 1
fi
[ ! -s "$WORK/invalid-diff.out" ]

# The archived snapshot must retain its SHA and be a verified prefix of HEAD.
cp "$TRID_EVENT_STATE_DIR/.revisions/r00000001/events.log" "$WORK/archive.good"
cp "$TRID_EVENT_STATE_DIR/.revisions/r00000001/checksums.sha256" "$WORK/archive.checksums"
sed '1s/|source|/|fact|/' "$WORK/archive.good" > "$TRID_EVENT_STATE_DIR/.revisions/r00000001/events.log"
if sh "$HISTORY" --as-of r00000001 > "$WORK/tampered.out" 2> "$WORK/tampered.err"; then
  echo 'TRID-015 accepted tampered archive' >&2; exit 1
fi
[ ! -s "$WORK/tampered.out" ]
grep -q 'historical checksum mismatch' "$WORK/tampered.err"
(cd "$TRID_EVENT_STATE_DIR/.revisions/r00000001" && sha256sum events.log > checksums.sha256)
if sh "$HISTORY" --as-of r00000001 > "$WORK/rehashed.out" 2> "$WORK/rehashed.err"; then
  echo 'TRID-015 accepted a rewritten archive checksum' >&2; exit 1
fi
[ ! -s "$WORK/rehashed.out" ]
grep -q 'not a committed prefix' "$WORK/rehashed.err"
cp "$WORK/archive.good" "$TRID_EVENT_STATE_DIR/.revisions/r00000001/events.log"
cp "$WORK/archive.checksums" "$TRID_EVENT_STATE_DIR/.revisions/r00000001/checksums.sha256"

# Read queries honor the ledger's existing single-writer lock.
(
  exec 8>> "$TRID_EVENT_STATE_DIR/.mutex"
  flock -n 8
  if sh "$HISTORY" --as-of r00000001 > "$WORK/locked.out" 2> "$WORK/locked.err"; then
    echo 'TRID-015 query bypassed active ledger lock' >&2; exit 1
  fi
  [ ! -s "$WORK/locked.out" ]
  grep -q 'state locked' "$WORK/locked.err"
  flock -u 8
)
sh "$JOURNAL" --verify > "$WORK/verified.out" 2> "$WORK/verified.err"
grep -q 'verified 5 events' "$WORK/verified.err"
[ "$third" = "$(readlink "$TRID_EVENT_STATE_DIR/.current")" ]
echo 'TRID-015 historical as-of, deterministic diff and provenance: PASS'
