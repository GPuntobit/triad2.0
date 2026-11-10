#!/bin/sh
# Native Triad execution regression; no Python, Node or LLM.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
cp "$ROOT/cognitive/native/fixture.txt" "$TMP/fixture.txt"
export TRID_STATE_DIR="$TMP/state"
sh "$ROOT/cognitive/native/run.sh" "$TMP/fixture.txt"
J="$TRID_STATE_DIR/hypotheses.log"
M="$TRID_STATE_DIR/memory.txt"
grep -q '^rule|grandparent|chain|consolidated_conditional|6|definition_gp_01$' "$M"
grep -q '^rule|sibling|common_source|consolidated_conditional|6|definition_sibling_01$' "$M"
grep -q '^claim|grandparent|mario|antonio|chain|luca|book_01|book_02|definition_gp_01|demonstrated_conditional$' "$M"
grep -q '^rule|grandparent|reverse_chain|refuted|' "$M"
cp "$J" "$TMP/journal-before"
sh "$ROOT/cognitive/native/run.sh" "$TMP/fixture.txt"
cmp "$TMP/journal-before" "$J"
printf 'revoke|book_02\n' >> "$TMP/fixture.txt"
sh "$ROOT/cognitive/native/run.sh" "$TMP/fixture.txt"
cmp "$TMP/journal-before" "$J"
grep -q '^claim|grandparent|mario|antonio|chain|luca|book_01|book_02|definition_gp_01|suspended$' "$M"
grep -q '^claim|grandparent|sara|nina|chain|leo|book_03|book_04|definition_gp_01|demonstrated_conditional$' "$M"
sed '1s/^1|/9|/' "$J" > "$TMP/tampered"
cp "$TMP/tampered" "$J"
if sh "$ROOT/cognitive/native/run.sh" "$TMP/fixture.txt" > "$TMP/failed.out" 2>&1; then
    echo 'TRID native: tampered journal unexpectedly accepted' >&2
    exit 1
fi
grep -q 'integrity checksum mismatch' "$TMP/failed.out"
sh "$ROOT/cognitive/native/tests/run_transport.sh"
sh "$ROOT/cognitive/native/tests/run_store.sh"
sh "$ROOT/cognitive/native/tests/run_contract.sh"
sh "$ROOT/cognitive/native/tests/run_schema_v1.sh"
sh "$ROOT/cognitive/native/tests/run_ledger_v1.sh"
if LC_ALL=C grep -E '^(DIAG-|NATIVE |TRID error:|[0-9]+$)' "$M" >/dev/null; then
    echo 'TRID: diagnostics contaminated the committed memory' >&2
    exit 1
fi
printf 'TRID-Core native migration: PASS\n'
