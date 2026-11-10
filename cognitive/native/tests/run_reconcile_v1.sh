#!/bin/sh
# TRID-013: stable semantic IDs, no-op, ordered revisions, source revocation,
# no automatic proof promotion and crash-atomic incremental ingestion.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
WORK=$(mktemp -d)
trap 'rm -rf -- "$WORK"' EXIT
export TRID_EVENT_STATE_DIR="$WORK/events"
UNIFY="$ROOT/cognitive/native/unify_v1.sh"
JOURNAL="$ROOT/cognitive/native/journal_v1.sh"
NORMALIZE="$ROOT/cognitive/native/normalize_v1.sh"
cat > "$WORK/first.fixture" <<'EOF'
edge|family|parent|mario|luca|book_01
edge|family|parent|luca|antonio|book_02
review|grandparent|train|negative|antonio|mario|review_01
EOF
cat > "$WORK/first.memory" <<'EOF'
rule|grandparent|chain|experimental|0|definition_gp_01
claim|grandparent|mario|antonio|chain|luca|book_01|book_02|definition_gp_01|demonstrated_conditional
claim|grandparent|sara|nina|chain|leo|book_03|book_04|definition_gp_01|suspended
EOF
cat > "$WORK/first.graph" <<'EOF'
fact evidence(:trid, :alpha, :src_a)
fact association(:trid, :alpha)
fact rule_state(:path_generalization, :experimental)
EOF
sh "$UNIFY" --build "$WORK/first.fixture" "$WORK/first.memory" "$WORK/first.graph" > "$WORK/first.import.v1"
sh "$NORMALIZE" "$WORK/first.import.v1" > "$WORK/first.stable.v1"
[ "$(wc -l < "$WORK/first.stable.v1")" -eq 9 ]
if grep -v -E '^v1[|][a-z_]+[|]k[a-f0-9]{40}[|]' "$WORK/first.stable.v1" > "$WORK/bad-stable"; then
  if [ -s "$WORK/bad-stable" ]; then
    echo 'TRID-013: normalized ID is not a stable 160-bit digest' >&2; exit 1
  fi
fi
sh "$UNIFY" --reconcile "$WORK/first.fixture" "$WORK/first.memory" "$WORK/first.graph"
sh "$JOURNAL" --replay > "$WORK/first.replay"
cmp "$WORK/first.stable.v1" "$WORK/first.replay"
first_ptr=$(readlink "$TRID_EVENT_STATE_DIR/.current")
cp "$TRID_EVENT_STATE_DIR/.current/events.log" "$WORK/first.chain"
# Identical snapshots are true no-ops: no extra event or revision.
sh "$UNIFY" --reconcile "$WORK/first.fixture" "$WORK/first.memory" "$WORK/first.graph" > "$WORK/repeated.out" 2> "$WORK/repeated.err"
[ "$first_ptr" = "$(readlink "$TRID_EVENT_STATE_DIR/.current")" ]
grep -q 'no changes' "$WORK/repeated.err"
[ ! -s "$WORK/repeated.out" ]
# Reordering source input, changing polarity by a reviewer, updating a rule,
# and adding a source/revocation must not renumber the unchanged entities.
cat > "$WORK/second.fixture" <<'EOF'
review|grandparent|train|positive|antonio|mario|review_01
edge|family|parent|mario|luca|book_01
edge|family|parent|sara|leo|book_03
revoke|book_02
edge|family|parent|luca|antonio|book_02
EOF
cat > "$WORK/second.memory" <<'EOF'
claim|grandparent|sara|nina|chain|leo|book_03|book_04|definition_gp_01|suspended
rule|grandparent|chain|refuted|0|definition_gp_01
claim|grandparent|mario|antonio|chain|luca|book_01|book_02|definition_gp_01|demonstrated_conditional
EOF
cat > "$WORK/second.graph" <<'EOF'
fact rule_state(:path_generalization, :refuted)
fact association(:trid, :alpha)
fact evidence(:trid, :alpha, :src_a)
EOF
sh "$UNIFY" --build "$WORK/second.fixture" "$WORK/second.memory" "$WORK/second.graph" > "$WORK/second.import.v1"
sh "$NORMALIZE" "$WORK/second.import.v1" > "$WORK/second.stable.v1"
id_first=$(grep '|edge,family,parent,mario,luca,book_01$' "$WORK/first.stable.v1" | cut -d '|' -f3)
id_second=$(grep '|edge,family,parent,mario,luca,book_01$' "$WORK/second.stable.v1" | cut -d '|' -f3)
[ -n "$id_first" ] && [ "$id_first" = "$id_second" ] ||
  { echo 'TRID-013: inserted rows shifted a stable identity' >&2; exit 1; }
review_first=$(grep '|review,grandparent,train,negative,antonio,mario,review_01$' "$WORK/first.stable.v1" | cut -d '|' -f3)
review_second=$(grep '|review,grandparent,train,positive,antonio,mario,review_01$' "$WORK/second.stable.v1" | cut -d '|' -f3)
[ "$review_first" = "$review_second" ] ||
  { echo 'TRID-013: reviewer polarity change lost its identity' >&2; exit 1; }
sh "$UNIFY" --reconcile "$WORK/second.fixture" "$WORK/second.memory" "$WORK/second.graph"
new_ptr=$(readlink "$TRID_EVENT_STATE_DIR/.current")
[ "$first_ptr" != "$new_ptr" ]
head -n 9 "$TRID_EVENT_STATE_DIR/.current/events.log" > "$WORK/prior.prefix"
cmp "$WORK/first.chain" "$WORK/prior.prefix"
sh "$JOURNAL" --replay > "$WORK/replayed"
# 9 initial plus two new source records and three revised records.
[ "$(wc -l < "$WORK/replayed")" -eq 14 ]
[ "$(cut -d '|' -f3 "$WORK/replayed" | sort -u | wc -l)" -eq 11 ]
grep -F "|$review_first|" "$WORK/replayed" | grep -q '|2|'
sh "$UNIFY" --project-current "$WORK/replayed" > "$WORK/view"
[ "$(wc -l < "$WORK/view")" -eq 11 ]
grep -q '^hypotheses|refuted|v1|rule_candidate|' "$WORK/view"
# Old demonstration recorded, but effective state is suspended by book_02.
grep -q '^proofs|suspended|v1|proof_node|' "$WORK/view"
grep -q '^revocations|revoked|v1|revocation|' "$WORK/view"
grep -q '^evidence|reviewed_positive|v1|evidence|' "$WORK/view"
# Historical rows are available by --project despite current-view folding.
sh "$UNIFY" --project "$WORK/replayed" > "$WORK/history-view"
[ "$(wc -l < "$WORK/history-view")" -eq 14 ]
sh "$UNIFY" --reconcile "$WORK/second.fixture" "$WORK/second.memory" "$WORK/second.graph" > "$WORK/again.out" 2> "$WORK/again.err"
[ "$new_ptr" = "$(readlink "$TRID_EVENT_STATE_DIR/.current")" ]
# Reject any automatic promotion of an already refuted rule.
sed 's/|refuted|0|/|consolidated_conditional|6|/' "$WORK/second.memory" > "$WORK/promoted.memory"
if sh "$UNIFY" --reconcile "$WORK/second.fixture" "$WORK/promoted.memory" "$WORK/second.graph" > "$WORK/promote.out" 2> "$WORK/promote.err"; then
  echo 'TRID-013: silently promoted a refuted rule to verified' >&2; exit 1
fi
[ "$new_ptr" = "$(readlink "$TRID_EVENT_STATE_DIR/.current")" ]
[ ! -s "$WORK/promote.out" ]
# Nor can a suspended conditional proof be promoted by a changed snapshot.
sed 's/|suspended$/|demonstrated_conditional/' "$WORK/second.memory" > "$WORK/promote-proof.memory"
if sh "$UNIFY" --reconcile "$WORK/second.fixture" "$WORK/promote-proof.memory" "$WORK/second.graph" > "$WORK/promote-proof.out" 2> "$WORK/promote-proof.err"; then
  echo 'TRID-013: silently promoted a suspended proof' >&2; exit 1
fi
[ "$new_ptr" = "$(readlink "$TRID_EVENT_STATE_DIR/.current")" ]
# Duplicate natural keys within one snapshot are invalid even when row IDs differ.
cat "$WORK/second.fixture" > "$WORK/ambiguous.fixture"
printf 'review|grandparent|test|negative|antonio|mario|review_01\n' >> "$WORK/ambiguous.fixture"
if sh "$UNIFY" --reconcile "$WORK/ambiguous.fixture" "$WORK/second.memory" "$WORK/second.graph" > "$WORK/ambiguous.out" 2> "$WORK/ambiguous.err"; then
  echo 'TRID-013: duplicated reviewer ID accepted' >&2; exit 1
fi
[ "$new_ptr" = "$(readlink "$TRID_EVENT_STATE_DIR/.current")" ]
# Deleting an observation from input does NOT infer a revocation.
grep -v '^edge|family|parent|mario|luca|book_01$' "$WORK/second.fixture" > "$WORK/missing.fixture"
sh "$UNIFY" --reconcile "$WORK/missing.fixture" "$WORK/second.memory" "$WORK/second.graph" > "$WORK/missing.out" 2> "$WORK/missing.err"
[ "$new_ptr" = "$(readlink "$TRID_EVENT_STATE_DIR/.current")" ]
# New input after failed/no-op imports: simulate interruption before pointer.
cat "$WORK/second.fixture" > "$WORK/third.fixture"
printf 'edge|family|parent|nina|tom|book_09\n' >> "$WORK/third.fixture"
if TRID_TEST_LEDGER_CRASH_AT=before_pointer sh "$UNIFY" --reconcile "$WORK/third.fixture" "$WORK/second.memory" "$WORK/second.graph" > "$WORK/crash.out" 2> "$WORK/crash.err"; then
  echo 'TRID-013: before-pointer SIGKILL succeeded' >&2; exit 1
fi
sh "$JOURNAL" --recover > "$WORK/recover.out" 2> "$WORK/recover.err"
[ "$new_ptr" = "$(readlink "$TRID_EVENT_STATE_DIR/.current")" ]
sh "$JOURNAL" --replay > "$WORK/after-crash"
cmp "$WORK/replayed" "$WORK/after-crash"
sh "$UNIFY" --reconcile "$WORK/third.fixture" "$WORK/second.memory" "$WORK/second.graph"
sh "$JOURNAL" --replay > "$WORK/final"
[ "$(wc -l < "$WORK/final")" -eq 15 ]
# Unsafe mixing with pre-TRID-013 positional ledger cannot be auto-migrated.
export TRID_EVENT_STATE_DIR="$WORK/positional"
sh "$JOURNAL" --append "$WORK/first.import.v1"
if sh "$UNIFY" --reconcile "$WORK/first.fixture" "$WORK/first.memory" "$WORK/first.graph" > "$WORK/legacy.out" 2> "$WORK/legacy.err"; then
  echo 'TRID-013: accepted implicit rewrite of positional history' >&2; exit 1
fi
grep -q 'native' "$WORK/legacy.err"
# Integration against native S0 independently verified output and the full
# restricted S1 0.6 graph, rather than solely the small synthetic fixtures.
export TRID_STATE_DIR="$WORK/full-s0"
sh "$ROOT/cognitive/native/run.sh" "$ROOT/cognitive/native/fixture.txt" > "$WORK/full-s0.out"
export TRID_EVENT_STATE_DIR="$WORK/full-v1"
sh "$UNIFY" --build "$ROOT/cognitive/native/fixture.txt" \
  "$TRID_STATE_DIR/.current/memory.txt" \
  "$ROOT/cognitive/native/graph_06.facts" > "$WORK/full-raw"
printf 'TRID-013 full fixture raw_bytes=%s\n' "$(wc -c < "$WORK/full-raw" | tr -d ' ')" >&2
TRID_DIAG_SIZE=1 sh "$NORMALIZE" "$WORK/full-raw" > "$WORK/full-stable"
sh "$UNIFY" --reconcile "$ROOT/cognitive/native/fixture.txt" \
  "$TRID_STATE_DIR/.current/memory.txt" "$ROOT/cognitive/native/graph_06.facts"
sh "$JOURNAL" --replay > "$WORK/full-replayed"
cmp "$WORK/full-stable" "$WORK/full-replayed"
# A complete, unchanged native S0 + S1 snapshot must be idempotent too.
full_pointer=$(readlink "$TRID_EVENT_STATE_DIR/.current")
sh "$UNIFY" --reconcile "$ROOT/cognitive/native/fixture.txt" \
  "$TRID_STATE_DIR/.current/memory.txt" "$ROOT/cognitive/native/graph_06.facts" > "$WORK/full-noop.out" 2> "$WORK/full-noop.err"
[ "$full_pointer" = "$(readlink "$TRID_EVENT_STATE_DIR/.current")" ]
grep -q 'no changes' "$WORK/full-noop.err"
sh "$UNIFY" --project-current "$WORK/full-replayed" > "$WORK/full-current"
[ "$(wc -l < "$WORK/full-current")" -eq "$(wc -l < "$WORK/full-replayed")" ]
echo 'TRID-013 stable IDs, monotone incremental replay and no auto-promotion: PASS'
