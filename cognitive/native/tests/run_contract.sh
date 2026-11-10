#!/bin/sh
# Permanent S1 CLI boundary micro-tests (no JavaScript/Python runtime).
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
# The oversized source must fail BEFORE construction of the S1 heap.
dd if=/dev/zero bs=65536 count=1 2>/dev/null | tr '\000' 'a' > "$TMP/oversized.triad"
[ "$(wc -c < "$TMP/oversized.triad" | tr -d ' ')" = 65536 ]
if "$ROOT/bin/triad" --logic "$TMP/oversized.triad" > "$TMP/large.out" 2> "$TMP/large.err"; then
    echo 'TRID contract: oversized S1 source accepted' >&2
    exit 1
fi
grep -q 'source limit is 65535 bytes' "$TMP/large.err"
[ ! -s "$TMP/large.out" ]
# The S1 entry point has exactly one source argument; reject missing/extra.
printf 'fact sample(:a)\n' > "$TMP/small.triad"
if "$ROOT/bin/triad" --logic > "$TMP/missing.out" 2> "$TMP/missing.err"; then
    echo 'TRID contract: missing S1 source accepted' >&2
    exit 1
fi
grep -q 'usage: triad --logic' "$TMP/missing.err"
if "$ROOT/bin/triad" --logic "$TMP/small.triad" "$TMP/small.triad" > "$TMP/extra.out" 2> "$TMP/extra.err"; then
    echo 'TRID contract: extra S1 source accepted' >&2
    exit 1
fi
grep -q 'usage: triad --logic' "$TMP/extra.err"
printf 'TRID S0/S1 CLI contract: PASS\n'
