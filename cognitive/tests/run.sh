#!/bin/sh
# Integration check against the native S1 logic profile.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
ACTUAL=$(mktemp)
trap 'rm -f "$ACTUAL"' EXIT HUP INT TERM
"$ROOT/bin/triad" --logic "$ROOT/cognitive/examples/discovery.triad" > "$ACTUAL"
if ! cmp -s "$ROOT/cognitive/tests/expected.out" "$ACTUAL"; then
    echo "TRID-Core 0.1 discovery output differs from expected.out" >&2
    diff -u "$ROOT/cognitive/tests/expected.out" "$ACTUAL" >&2 || true
    exit 1
fi
echo "TRID-Core 0.1 discovery: PASS"
