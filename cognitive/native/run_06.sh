#!/bin/sh
# POSIX transport for a durable graph; ALL cognitive rules run in native S1.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
STATE=${TRID_GRAPH_STATE_DIR:-"$HOME/.local/state/trid-graph"}
umask 077
[ ! -L "$STATE" ] || { echo 'TRID 0.6: unsafe state symlink' >&2; exit 1; }
mkdir -p "$STATE"
STATE=$(CDPATH= cd -- "$STATE" && pwd)
[ ! -L "$STATE/.mutex" ] || { echo 'TRID 0.6: unsafe lock symlink' >&2; exit 1; }
# Keep one permanent flock inode. The kernel releases the lock on SIGKILL.
# Never unlink it: that would allow concurrent writers to lock distinct inodes.
exec 9>> "$STATE/.mutex"
if ! flock -n 9; then
    echo 'TRID 0.6: state locked' >&2
    exit 1
fi
# Only the holder of the mutex removes orphaned private working directories.
find "$STATE" -mindepth 1 -maxdepth 1 -type d -name '.work.*' \
  -exec rm -rf -- {} +
WORK=$(mktemp -d "$STATE/.work.XXXXXXXX")
trap 'rm -rf -- "$WORK"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
if [ "${TRID_TEST_GRAPH_CRASH_AT:-}" = after_lock ]; then
    kill -KILL "$$"
fi
GRAPH="$STATE/graph.facts"
[ -e "$GRAPH" ] || cp "$ROOT/cognitive/native/graph_06.facts" "$GRAPH"
[ -f "$GRAPH" ] && [ ! -L "$GRAPH" ] && [ -r "$GRAPH" ] ||
    { echo 'TRID 0.6: invalid graph path' >&2; exit 1; }
# Restrict the durable file to three named fact predicates. No arbitrary Triad
# program is accepted as data, and nothing in the input is evaluated by sh.
# Whitespace, quoting, separators and comments use strictly controlled syntax.
export LC_ALL=C
if grep -v -E '^(#[- a-zA-Z0-9.,]+|fact evidence\(:[a-z][a-z0-9_]*, :[a-z][a-z0-9_]*, :[a-z][a-z0-9_]*\)|fact association\(:[a-z][a-z0-9_]*, :[a-z][a-z0-9_]*\)|fact revoked\(:[a-z][a-z0-9_]*\)|fact rule_state\(:[a-z][a-z0-9_]*, :(experimental|refuted|consolidated_conditional)\)|)$' "$GRAPH" > "$WORK/rejected"; then
    if [ -s "$WORK/rejected" ]; then
        echo 'TRID 0.6: invalid graph record (accepted facts only)' >&2
        cat "$WORK/rejected" >&2
        exit 1
    fi
fi
SIZE=$(wc -c < "$GRAPH")
if [ "$SIZE" -gt 16000 ]; then
    echo 'TRID 0.6: graph exceeds fixed size budget' >&2
    exit 1
fi
# S1's bump heap is finite and is not reclaimed between heavy recursive
# `solve` queries. Execute EACH proof/pulse query in its own native S1 process
# with the same durable fact store, collecting output in fixed order.
: > "$WORK/query.out"
n=0
for queries in "$ROOT/cognitive/native/queries_proof_06.triad" "$ROOT/cognitive/native/queries_pulse_06.triad"; do
    while IFS= read -r line || [ -n "$line" ]; do
        case "$line" in
            println\(*)
                n=$((n + 1))
                cat "$GRAPH" "$ROOT/cognitive/native/s1_graph_06.triad" > "$WORK/query.triad"
                printf '%s\n' "$line" >> "$WORK/query.triad"
                if ! "$ROOT/bin/triad" --logic "$WORK/query.triad" >> "$WORK/query.out"; then
                    echo "TRID 0.6: native S1 query $n failed" >&2
                    exit 1
                fi
                ;;
        esac
    done < "$queries"
done
if [ "${TRID_TEST_GRAPH_CRASH_AT:-}" = before_output ]; then
    kill -KILL "$"
fi
cat "$WORK/query.out"
