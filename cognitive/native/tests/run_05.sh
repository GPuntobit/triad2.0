#!/bin/sh
# Native Triad S1 only, no Python or external LLM runtime.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
"$ROOT/bin/triad" --logic "$ROOT/cognitive/native/s1_multilevel_05.triad" > "$TMP/actual"
if ! cmp -s "$ROOT/cognitive/native/tests/expected_05.out" "$TMP/actual"; then
    echo "TRID-Core 0.5: S1 multilevel/pulse golden mismatch" >&2
    diff -u "$ROOT/cognitive/native/tests/expected_05.out" "$TMP/actual" >&2 || true
    exit 1
fi
echo "TRID-Core 0.5 native S1 multilevel pulses: PASS"
