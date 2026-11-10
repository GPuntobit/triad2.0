#!/bin/sh
# Schema v1: every entity kind, byte-exact canonical roundtrip, invalid input,
# idempotent legacy S0 migration and explicit preservation of input polarity.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf -- "$TMP"' EXIT
SCHEMA="$ROOT/cognitive/native/schema_v1.sh"
cat > "$TMP/v1" <<'EOF'
v1|fact|fact_a|family|book_01|asserted_conditional|1|book_01|none|event_a|none|parent,mario,luca
v1|rule_candidate|rule_a|family|none|experimental|1|none|fact_a|event_b|none|chain
v1|evidence|evidence_a|family|review_01|reviewed_positive|1|review_01|fact_a|event_c|none|positive,mario,luca
v1|proof_node|proof_a|family|book_01|demonstrated_conditional|1|book_01|fact_a|event_d|none|witness_luca
v1|proof_edge|proof_edge_a|family|book_01|demonstrated_conditional|1|book_01|proof_a|event_e|none|from_proof_a
v1|revocation|revoke_a|family|review_01|revoked|2|none|evidence_a|event_f|none|explicit_revoke
v1|activation_pulse|pulse_a|family|none|active|3|none|fact_a|event_g|none|fuel_6
v1|source|source_a|family|none|declared|1|none|none|event_h|none|book_01
v1|definition|def_a|family|book_01|declared|1|none|none|event_i|none|parent_definition
v1|revision|revision_a|family|none|created|1|none|fact_a|event_j|1794300000|baseline
v1|experiment|experiment_a|family|none|proposed|1|none|rule_a|event_k|none|candidate_holdout
EOF
sh "$SCHEMA" --validate "$TMP/v1" > "$TMP/canonical"
cmp "$TMP/v1" "$TMP/canonical"
# Run the canonical bytes through the native parser a second time.
sh "$SCHEMA" --validate "$TMP/canonical" > "$TMP/again"
cmp "$TMP/v1" "$TMP/again"
bad() {
    if sh "$SCHEMA" --validate "$1" > "$TMP/bad.out" 2> "$TMP/bad.err"; then
        echo "TRID schema: invalid record accepted: $1" >&2
        exit 1
    fi
    [ ! -s "$TMP/bad.out" ]
}
sed '1s/^v1|/v2|/' "$TMP/v1" > "$TMP/bad-version"; bad "$TMP/bad-version"
sed '1s/|1|book_01|/|0|book_01|/' "$TMP/v1" > "$TMP/bad-revision"; bad "$TMP/bad-revision"
sed '1s/|fact|/|invalid_kind|/' "$TMP/v1" > "$TMP/bad-kind"; bad "$TMP/bad-kind"
sed '6s/|revoked|/|active|/' "$TMP/v1" > "$TMP/bad-revoke"; bad "$TMP/bad-revoke"
sed '7s/|active|/|revoked|/' "$TMP/v1" > "$TMP/bad-pulse"; bad "$TMP/bad-pulse"
sed '1s/|parent,mario,luca$/|parent,mario,luca|extra/' "$TMP/v1" > "$TMP/bad-arity"; bad "$TMP/bad-arity"
cat "$TMP/v1" > "$TMP/duplicate-id"
head -n 1 "$TMP/v1" >> "$TMP/duplicate-id"
bad "$TMP/duplicate-id"
printf 'println(:injected)\n' > "$TMP/injected"
bad "$TMP/injected"
# Non-lossy fixture bridge for the historical S0 pipe-file domain.
sh "$SCHEMA" --import-s0 "$ROOT/cognitive/native/fixture.txt" > "$TMP/imported"
sh "$SCHEMA" --validate "$TMP/imported" > "$TMP/import-checked"
cmp "$TMP/imported" "$TMP/import-checked"
sh "$SCHEMA" --import-s0 "$ROOT/cognitive/native/fixture.txt" > "$TMP/imported-twice"
cmp "$TMP/imported" "$TMP/imported-twice"
awk -F'|' '{ print $12 }' "$TMP/imported" | tr ',' '|' > "$TMP/reconstructed-legacy"
cmp "$ROOT/cognitive/native/fixture.txt" "$TMP/reconstructed-legacy"
grep -q '|evidence|legacy_.*|reviewed_negative|' "$TMP/imported"
grep -q '|revision|legacy_.*|approved_conditional|' "$TMP/imported"
grep -q '|fact|legacy_.*|asserted_conditional|' "$TMP/imported"
printf 'TRID-010 versioned native schema and S0 fixture roundtrip: PASS\n'
