#!/bin/sh
# Test persistence/restarts, independent proof revocation and finite pulses.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
export TRID_GRAPH_STATE_DIR="$TMP/graph"
sh "$ROOT/cognitive/native/run_06.sh" > "$TMP/first"
[ -s "$TRID_GRAPH_STATE_DIR/graph.facts" ]
cp "$TRID_GRAPH_STATE_DIR/graph.facts" "$TMP/graph-before"
sh "$ROOT/cognitive/native/run_06.sh" > "$TMP/second"
cmp "$TMP/first" "$TMP/second"
cmp "$TRID_GRAPH_STATE_DIR/graph.facts" "$TMP/graph-before"
# Mutation is explicit; a new source revocation survives a restart.
printf 'fact revoked(:src_g)\n' >> "$TRID_GRAPH_STATE_DIR/graph.facts"
sh "$ROOT/cognitive/native/run_06.sh" > "$TMP/after-revoke"
grep -q 'src_g' "$TRID_GRAPH_STATE_DIR/graph.facts"
# Reject attempted program injection; preserve the durable graph untouched.
printf 'println(:injected)\n' >> "$TRID_GRAPH_STATE_DIR/graph.facts"
if sh "$ROOT/cognitive/native/run_06.sh" > "$TMP/unsafe.out" 2> "$TMP/unsafe.err"; then
    echo 'TRID 0.6: accepted malicious graph record' >&2
    exit 1
fi
grep -q 'invalid graph record' "$TMP/unsafe.err"
echo 'TRID-Core 0.6 native persistence and bounded logic: PASS'
