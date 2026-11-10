#!/bin/sh
# TRID-011: native canonical event replay, append-only prefix, SHA chain,
# idempotent verification, bad revisions, concurrency and SIGKILL recovery.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
TEMP=$(mktemp -d)
trap 'rm -rf -- "$TEMP"' EXIT
export TRID_EVENT_STATE_DIR="$TEMP/ledger"
RUN="$ROOT/cognitive/native/journal_v1.sh"
cat > "$TEMP/initial.v1" <<'EOF'
v1|fact|fact_a|family|book_01|asserted_conditional|1|book_01|none|event_a|none|parent,mario,luca
v1|revocation|revoke_a|family|book_02|revoked|1|none|fact_a|event_b|none|explicit_revoke
EOF
sh "$RUN" --verify > "$TEMP/verified.out" 2> "$TEMP/verified.err"
[ ! -s "$TEMP/verified.out" ]
sh "$RUN" --append "$TEMP/initial.v1"
sh "$RUN" --verify > "$TEMP/verify.out" 2> "$TEMP/verify.err"
grep -q 'verified 2 events' "$TEMP/verify.err"
sh "$RUN" --replay > "$TEMP/replayed.v1"
cmp "$TEMP/initial.v1" "$TEMP/replayed.v1"
saved=$(readlink "$TRID_EVENT_STATE_DIR/.current")
cp "$TRID_EVENT_STATE_DIR/.current/events.log" "$TEMP/initial-chain"
# Repeating the same batch is never silently accepted as a second event.
if sh "$RUN" --append "$TEMP/initial.v1" > "$TEMP/invalid.out" 2> "$TEMP/invalid.err"; then
  echo 'TRID-011: accepted duplicated event identity/revision' >&2; exit 1
fi
[ ! -s "$TEMP/invalid.out" ]
[ "$saved" = "$(readlink "$TRID_EVENT_STATE_DIR/.current")" ]
cat > "$TEMP/update.v1" <<'EOF'
v1|fact|fact_a|family|book_01|suspended|2|book_01|none|event_c|none|parent,mario,luca
EOF
sh "$RUN" --append "$TEMP/update.v1"
sh "$RUN" --replay > "$TEMP/all.v1"
cat "$TEMP/initial.v1" "$TEMP/update.v1" > "$TEMP/expected.v1"
cmp "$TEMP/all.v1" "$TEMP/expected.v1"
head -n 2 "$TRID_EVENT_STATE_DIR/.current/events.log" > "$TEMP/prefix"
cmp "$TEMP/prefix" "$TEMP/initial-chain"
# Reject reordered/non-monotone revisions without publication.
cat > "$TEMP/backwards.v1" <<'EOF'
v1|fact|fact_a|family|book_01|asserted_conditional|1|book_01|none|event_d|none|old
EOF
before=$(readlink "$TRID_EVENT_STATE_DIR/.current")
if sh "$RUN" --append "$TEMP/backwards.v1" > "$TEMP/backwards.out" 2> "$TEMP/backwards.err"; then
  echo 'TRID-011: accepted backward revision' >&2; exit 1
fi
[ "$before" = "$(readlink "$TRID_EVENT_STATE_DIR/.current")" ]
# Lock must not permit two concurrent appenders or verifiers.
(
  exec 8>> "$TRID_EVENT_STATE_DIR/.mutex"
  flock -n 8
  if sh "$RUN" --verify > "$TEMP/locked.out" 2> "$TEMP/locked.err"; then
    echo 'TRID-011: competing lock was accepted' >&2; exit 1
  fi
  grep -q 'state locked' "$TEMP/locked.err"
  flock -u 8
)
cat > "$TEMP/late.v1" <<'EOF'
v1|experiment|experiment_a|family|none|proposed|1|none|none|event_e|none|bounded_test
EOF
for point in after_stage before_pointer; do
  if TRID_TEST_LEDGER_CRASH_AT="$point" sh "$RUN" --append "$TEMP/late.v1" > "$TEMP/$point.out" 2>&1; then
    echo "TRID-011: injected crash $point succeeded" >&2; exit 1
  fi
  sh "$RUN" --recover > "$TEMP/$point.recover.out" 2> "$TEMP/$point.recover.err"
  [ "$before" = "$(readlink "$TRID_EVENT_STATE_DIR/.current")" ]
  sh "$RUN" --replay > "$TEMP/$point.v1"
  cmp "$TEMP/expected.v1" "$TEMP/$point.v1"
done
if TRID_TEST_LEDGER_CRASH_AT=after_pointer sh "$RUN" --append "$TEMP/late.v1" > "$TEMP/post.out" 2>&1; then
  echo 'TRID-011: post-pointer SIGKILL unexpectedly returned success' >&2; exit 1
fi
sh "$RUN" --recover > "$TEMP/recovery.out" 2> "$TEMP/recovery.err"
cat "$TEMP/expected.v1" "$TEMP/late.v1" > "$TEMP/after.v1"
sh "$RUN" --replay > "$TEMP/after-replay.v1"
cmp "$TEMP/after.v1" "$TEMP/after-replay.v1"
# Recomputed manifest must NOT bypass the per-event predecessor/digest check.
current="$TRID_EVENT_STATE_DIR/.current"
cp "$current/events.log" "$TEMP/untouched-chain"
cp "$current/checksums.sha256" "$TEMP/untouched-manifest"
sed '2s/|revocation|/|experiment|/' "$TEMP/untouched-chain" > "$current/events.log"
(cd "$current" && sha256sum events.log > checksums.sha256)
if sh "$RUN" --verify > "$TEMP/tamper.out" 2> "$TEMP/tamper.err"; then
  echo 'TRID-011: digest-chain tampering accepted' >&2; exit 1
fi
grep -q 'event SHA-256 mismatch' "$TEMP/tamper.err"
cp "$TEMP/untouched-chain" "$current/events.log"
cp "$TEMP/untouched-manifest" "$current/checksums.sha256"
# Sequence truncation (first event remains) is rejected by manifest mismatch.
sed '$d' "$TEMP/untouched-chain" > "$current/events.log"
if sh "$RUN" --verify > "$TEMP/truncate.out" 2> "$TEMP/truncate.err"; then
  echo 'TRID-011: truncated log accepted' >&2; exit 1
fi
grep -q 'checksum mismatch' "$TEMP/truncate.err"
cp "$TEMP/untouched-chain" "$current/events.log"
# Unsafe current pointers never fall back to an older version automatically.
ln -s .revisions/../../invalid "$TEMP/bad-pointer"
mv -Tf "$TEMP/bad-pointer" "$TRID_EVENT_STATE_DIR/.current"
if sh "$RUN" --recover > "$TEMP/unsafe.out" 2> "$TEMP/unsafe.err"; then
  echo 'TRID-011: unsafe pointer accepted' >&2; exit 1
fi
grep -q 'invalid revision id' "$TEMP/unsafe.err"
ln -s "$before" "$TEMP/good-pointer"
mv -Tf "$TEMP/good-pointer" "$TRID_EVENT_STATE_DIR/.current"
sh "$RUN" --verify > "$TEMP/final.out" 2> "$TEMP/final.err"
grep -q 'verified 3 events' "$TEMP/final.err"
echo 'TRID-011 append-only SHA chain and deterministic replay: PASS'
