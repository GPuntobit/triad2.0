#!/bin/sh
# TRID-012: deterministic source-backed S0/S1 bridge and epistemic projection.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
WORK=$(mktemp -d)
trap 'rm -rf -- "$WORK"' EXIT
export TRID_EVENT_STATE_DIR="$WORK/events"
UNIFY="$ROOT/cognitive/native/unify_v1.sh"
JOURNAL="$ROOT/cognitive/native/journal_v1.sh"
cat > "$WORK/s0.fixture" <<'EOF'
edge|family|parent|mario|luca|book_01
edge|family|parent|luca|antonio|book_02
revoke|book_02
EOF
cat > "$WORK/s0.memory" <<'EOF'
rule|grandparent|chain|consolidated_conditional|6|definition_gp_01
claim|grandparent|mario|antonio|chain|luca|book_01|book_02|definition_gp_01|demonstrated_conditional
EOF
cat > "$WORK/s1.facts" <<'EOF'
# A strictly labelled bounded graph.
fact evidence(:trid, :alpha, :src_a)
fact evidence(:alpha, :beta, :src_b)
fact revoked(:src_b)
fact association(:trid, :alpha)
fact rule_state(:path_generalization, :experimental)
EOF
sh "$UNIFY" --build "$WORK/s0.fixture" "$WORK/s0.memory" "$WORK/s1.facts" > "$WORK/batch.v1"
sh "$UNIFY" --build "$WORK/s0.fixture" "$WORK/s0.memory" "$WORK/s1.facts" > "$WORK/batch-again.v1"
cmp "$WORK/batch.v1" "$WORK/batch-again.v1"
[ "$(wc -l < "$WORK/batch.v1")" -eq 10 ]
sh "$ROOT/cognitive/native/schema_v1.sh" --validate-ledger "$WORK/batch.v1" > "$WORK/native.v1"
cmp "$WORK/batch.v1" "$WORK/native.v1"
# Full source-backed pipeline into TRID-011's immutable event revisions.
sh "$UNIFY" --ingest "$WORK/s0.fixture" "$WORK/s0.memory" "$WORK/s1.facts"
sh "$JOURNAL" --replay > "$WORK/replayed.v1"
cmp "$WORK/batch.v1" "$WORK/replayed.v1"
before=$(readlink "$TRID_EVENT_STATE_DIR/.current")
if sh "$UNIFY" --ingest "$WORK/s0.fixture" "$WORK/s0.memory" "$WORK/s1.facts" > "$WORK/dup.out" 2> "$WORK/dup.err"; then
    echo 'TRID-012: accepted repeated import with duplicate v1 revisions' >&2; exit 1
fi
[ "$before" = "$(readlink "$TRID_EVENT_STATE_DIR/.current")" ]
# Explicitly supplied pulse belongs to activation, never to the proof lane.
cat > "$WORK/pulse.v1" <<'EOF'
v1|activation_pulse|pulse_a|s1_graph|none|active|1|none|none|pulse_query|none|activated_alpha
EOF
sh "$JOURNAL" --append "$WORK/pulse.v1"
sh "$JOURNAL" --replay > "$WORK/full.v1"
sh "$UNIFY" --project "$WORK/full.v1" > "$WORK/view"
sh "$UNIFY" --project "$WORK/full.v1" > "$WORK/view-again"
cmp "$WORK/view" "$WORK/view-again"
[ "$(wc -l < "$WORK/view")" -eq 11 ]
# Revoking book_02 changes source-backed claim status, not event bytes.
grep -q '^proofs|suspended|v1|proof_node|s0memory_2|s0_memory|book_01|demonstrated_conditional|' "$WORK/view"
grep -q '^evidence|suspended|v1|fact|legacy_2|legacy_s0|book_02|asserted_conditional|' "$WORK/view"
grep -q '^evidence|asserted_conditional|v1|fact|legacy_1|legacy_s0|book_01|' "$WORK/view"
# S1 revocation affects only src_b. Source src_a stays retained.
grep -q '^evidence|suspended|v1|evidence|s1graph_2|s1_graph|src_b|' "$WORK/view"
grep -q '^evidence|asserted_conditional|v1|evidence|s1graph_1|s1_graph|src_a|' "$WORK/view"
grep -q '^activation_network|declared|v1|fact|s1graph_4|s1_association|' "$WORK/view"
grep -q '^activation|active|v1|activation_pulse|pulse_a|' "$WORK/view"
[ "$(grep -c '^activation|' "$WORK/view")" -eq 1 ]
[ "$(grep -c '^revocations|' "$WORK/view")" -eq 2 ]
# Opaque original S0 memory/fixture row contents are preserved exactly.
head -n 3 "$WORK/batch.v1" | cut -d '|' -f12 | tr ',' '|' > "$WORK/s0.roundtrip"
cmp "$WORK/s0.fixture" "$WORK/s0.roundtrip"
sed -n '4,5p' "$WORK/batch.v1" | cut -d '|' -f12 | tr ',' '|' > "$WORK/memory.roundtrip"
cmp "$WORK/s0.memory" "$WORK/memory.roundtrip"
# Reject source injection, do not mutate the active event pointer.
printf 'println(:unsafe)\n' >> "$WORK/s1.facts"
if sh "$UNIFY" --ingest "$WORK/s0.fixture" "$WORK/s0.memory" "$WORK/s1.facts" > "$WORK/bad.out" 2> "$WORK/bad.err"; then
  echo 'TRID-012: unsafe S1 code accepted as data' >&2; exit 1
fi
[ ! -s "$WORK/bad.out" ]
grep -q 'rejected invalid or executable graph' "$WORK/bad.err"
[ "$(readlink "$TRID_EVENT_STATE_DIR/.current")" != "$before" ]
sh "$JOURNAL" --replay > "$WORK/still-valid.v1"
cmp "$WORK/full.v1" "$WORK/still-valid.v1"
# Activation cannot be silently promoted to demonstration of truth.
sed 's/|active|1|/|demonstrated_conditional|1|/' "$WORK/pulse.v1" > "$WORK/invalid-pulse.v1"
if sh "$UNIFY" --project "$WORK/invalid-pulse.v1" > "$WORK/invalid-view.out" 2> "$WORK/invalid-view.err"; then
  echo 'TRID-012: pulse promoted into proof state' >&2; exit 1
fi
[ ! -s "$WORK/invalid-view.out" ]
printf 'TRID-012 S0/S1 native source-backed unified projection: PASS\n'
