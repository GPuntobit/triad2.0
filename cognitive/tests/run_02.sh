#!/bin/sh
# TRID-Core 0.2: isolated experiment, no changes to seed or S1.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
ACTUAL=$(mktemp)
ERROR=$(mktemp)
trap 'rm -f "$ACTUAL" "$ERROR"' EXIT HUP INT TERM

if ! "$ROOT/bin/triad" --logic "$ROOT/cognitive/examples/laboratory.triad" > "$ACTUAL" 2> "$ERROR"; then
    echo "TRID-Core 0.2: S1 failed while executing laboratory.triad" >&2
    cat "$ERROR" >&2
    exit 1
fi
if ! cmp -s "$ROOT/cognitive/tests/expected_02.out" "$ACTUAL"; then
    echo "TRID-Core 0.2: output differs from expected_02.out" >&2
    diff -u "$ROOT/cognitive/tests/expected_02.out" "$ACTUAL" >&2 || true
    exit 1
fi
echo "TRID-Core 0.2 laboratory: PASS"
