#!/bin/sh
# POSIX transport for a durable graph; ALL cognitive rules run in native S1.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
STATE=${TRID_GRAPH_STATE_DIR:-"$HOME/.local/state/trid-graph"}
umask 077
mkdir -p "$STATE"
STATE=$(CDPATH= cd -- "$STATE" && pwd)
if ! mkdir "$STATE/.lock" 2>/dev/null; then
    echo 'TRID 0.6: state locked' >&2
    exit 1
fi
LOCK="$STATE/.lock"
trap 'rm -f "$LOCK/rejected" "$LOCK/proofs.triad" "$LOCK/pulses.triad" "$LOCK/proofs.out" "$LOCK/pulses.out"; rmdir "$LOCK"' EXIT HUP INT TERM
GRAPH="$STATE/graph.facts"
[ -e "$GRAPH" ] || cp "$ROOT/cognitive/native/graph_06.facts" "$GRAPH"
[ -f "$GRAPH" ] && [ -r "$GRAPH" ] || { echo 'TRID 0.6: invalid graph path' >&2; exit 1; }
# Restrict the durable file to three named fact predicates. No arbitrary Triad
# program is accepted as data, and nothing in the input is evaluated by sh.
# Whitespace, quoting, separators and comments use strictly controlled syntax.
export LC_ALL=C
if grep -v -E '^(#[- a-zA-Z0-9.,]+|fact evidence\(:[a-z][a-z0-9_]*, :[a-z][a-z0-9_]*, :[a-z][a-z0-9_]*\)|fact association\(:[a-z][a-z0-9_]*, :[a-z][a-z0-9_]*\)|fact revoked\(:[a-z][a-z0-9_]*\)|fact rule_state\(:[a-z][a-z0-9_]*, :(experimental|refuted|consolidated_conditional)\)|)$' "$GRAPH" > "$LOCK/rejected"; then
    if [ -s "$LOCK/rejected" ]; then
        echo 'TRID 0.6: invalid graph record (accepted facts only)' >&2
        cat "$LOCK/rejected" >&2
        exit 1
    fi
fi
SIZE=$(wc -c < "$GRAPH")
if [ "$SIZE" -gt 16000 ]; then
    echo 'TRID 0.6: graph exceeds fixed size budget' >&2
    exit 1
fi
# S1 uses a finite bump heap. Isolate repeated recursive proof queries from
# propagation, so inference and salience cannot consume each other's budget.
cat "$GRAPH" "$ROOT/cognitive/native/s1_graph_06.triad" "$ROOT/cognitive/native/queries_proof_06.triad" > "$LOCK/proofs.triad"
cat "$GRAPH" "$ROOT/cognitive/native/s1_graph_06.triad" "$ROOT/cognitive/native/queries_pulse_06.triad" > "$LOCK/pulses.triad"
"$ROOT/bin/triad" --logic "$LOCK/proofs.triad" > "$LOCK/proofs.out"
"$ROOT/bin/triad" --logic "$LOCK/pulses.triad" > "$LOCK/pulses.out"
cat "$LOCK/proofs.out" "$LOCK/pulses.out"
