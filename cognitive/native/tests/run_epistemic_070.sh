#!/bin/sh
# TRID-070: epistemic invariants for a bounded native v1 projection.
# Golden is the actual native Triad projection, NOT an expected free-text belief.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf -- "$TMP"' EXIT
SCHEMA="$ROOT/cognitive/native/schema_v1.sh"
JOURNAL="$ROOT/cognitive/native/journal_v1.sh"
UNIFY="$ROOT/cognitive/native/unify_v1.sh"
cat > "$TMP/cases.v1" <<'EOF'
v1|fact|fact_a|s0_memory|src_a|asserted_conditional|1|src_a|none|event_a|none|family_relation
v1|proof_node|path_a|s0_memory|src_a|demonstrated_conditional|1|src_a|src_a|event_b|none|witness_a
v1|proof_node|path_b|s0_memory|src_b|demonstrated_conditional|1|src_b|src_b|event_c|none|witness_b
v1|proof_node|correlated_a|s0_memory|src_c|demonstrated_conditional|1|src_c|src_c|event_d|none|witness_common
v1|proof_node|correlated_b|s0_memory|src_c|demonstrated_conditional|1|src_c|src_c|event_e|none|witness_common
v1|activation_pulse|pulse_a|s0_memory|none|active|1|none|path_a|event_f|none|fuel_2
v1|rule_candidate|candidate_a|s0_memory|none|experimental|1|none|none|event_g|none|unapproved_rule
v1|fact|fact_s1|s1_graph|src_a|asserted_conditional|1|src_a|none|event_h|none|s1_relation
v1|evidence|missing_a|s0_memory|src_missing|unknown|1|src_missing|none|event_k|none|source_not_observed
v1|revocation|revoke_a|s0_memory|src_a|revoked|1|none|none|event_i|none|revoked_source
v1|revocation|revoke_c|s0_memory|src_c|revoked|1|none|none|event_j|none|duplicate_source
EOF
# pulse != proof, missing != false, one of two paths revoked, and a same-name
# source in another context is not inadvertently suspended.
sh "$SCHEMA" --project "$TMP/cases.v1" > "$TMP/view"
cmp "$ROOT/cognitive/native/tests/golden_epistemic_070.view" "$TMP/view"
[ "$(grep -c '^activation|' "$TMP/view")" -eq 1 ]
[ "$(grep -c '^proofs|demonstrated_conditional' "$TMP/view")" -eq 1 ]
[ "$(grep -c '^proofs|suspended|' "$TMP/view")" -eq 3 ]
[ "$(grep -c '^evidence|unknown|' "$TMP/view")" -eq 1 ]
! grep -q '^evidence|refuted|.*missing_a' "$TMP/view"
# Both correlated supports use src_c; they must BOTH suspend on one revocation.
[ "$(grep -c '^proofs|suspended|.*|correlated_[ab]|' "$TMP/view")" -eq 2 ] ||
  { echo 'TRID-070: duplicated correlated source bypassed revocation' >&2; exit 1; }
# Stated, experimental rule may not be promoted by an activation pulse.
grep -q '^hypotheses|experimental|' "$TMP/view"
grep -q '^activation|active|' "$TMP/view"
# Revocations never delete the original event history.
export TRID_EVENT_STATE_DIR="$TMP/events"
sh "$JOURNAL" --append "$TMP/cases.v1" > "$TMP/append.out" 2> "$TMP/append.err"
sh "$JOURNAL" --replay > "$TMP/replayed"
cmp "$TMP/cases.v1" "$TMP/replayed"
sh "$JOURNAL" --verify > "$TMP/verified.out" 2> "$TMP/verified.err"
[ ! -s "$TMP/verified.out" ]
# Idempotent reconcile; no-op does not generate a new revision.
cat > "$TMP/s0.fixture" <<'EOF'
edge|family|parent|mario|luca|book_01
target|family|grandparent|parent
EOF
cat > "$TMP/s0.memory" <<'EOF'
rule|grandparent|chain|experimental|0|definition_gp_01
EOF
cat > "$TMP/s1.graph" <<'EOF'
fact rule_state(:path_generalization, :experimental)
EOF
export TRID_EVENT_STATE_DIR="$TMP/reconcile-events"
sh "$UNIFY" --reconcile "$TMP/s0.fixture" "$TMP/s0.memory" "$TMP/s1.graph" > "$TMP/first.out" 2> "$TMP/first.err"
pointer=$(readlink "$TRID_EVENT_STATE_DIR/.current")
sh "$UNIFY" --reconcile "$TMP/s0.fixture" "$TMP/s0.memory" "$TMP/s1.graph" > "$TMP/again.out" 2> "$TMP/again.err"
[ "$pointer" = "$(readlink "$TRID_EVENT_STATE_DIR/.current")" ]
grep -q 'no changes' "$TMP/again.err"
# A changed experimental candidate is not an approval event.
sed 's/|experimental|/|consolidated_conditional|/' "$TMP/s0.memory" > "$TMP/unapproved"
if sh "$UNIFY" --reconcile "$TMP/s0.fixture" "$TMP/unapproved" "$TMP/s1.graph" > "$TMP/rejected.out" 2> "$TMP/rejected.err"; then
  echo 'TRID-070: promotion without approval succeeded' >&2
  exit 1
fi
[ ! -s "$TMP/rejected.out" ]
[ "$pointer" = "$(readlink "$TRID_EVENT_STATE_DIR/.current")" ]
sh "$JOURNAL" --verify > "$TMP/reverified.out" 2> "$TMP/reverified.err"
# Missing input records do not imply negative evidence/revocation.
printf 'target|family|grandparent|parent\n' > "$TMP/less.fixture"
sh "$UNIFY" --reconcile "$TMP/less.fixture" "$TMP/s0.memory" "$TMP/s1.graph" > "$TMP/missing.out" 2> "$TMP/missing.err"
[ "$pointer" = "$(readlink "$TRID_EVENT_STATE_DIR/.current")" ]
printf 'TRID-070 epistemic golden, missing, revocation, duplicate, promotion: PASS\n'
