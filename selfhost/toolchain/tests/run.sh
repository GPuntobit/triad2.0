#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
# Require native Triad output to equal independently recorded bytes.
sh "$ROOT/selfhost/toolchain/build-elf-exit.sh" 42 "$TMP/exit42"
xxd -p -c 256 "$TMP/exit42" > "$TMP/actual.hex"
if ! cmp -s "$ROOT/selfhost/toolchain/tests/exit42.expected.hex" "$TMP/actual.hex"; then
    echo 'native ELF output differs from independently reviewed golden' >&2
    diff -u "$ROOT/selfhost/toolchain/tests/exit42.expected.hex" "$TMP/actual.hex" >&2 || true
    exit 1
fi
[ "$(wc -c < "$TMP/exit42")" -eq 132 ]
# Independent Linux kernel validates the executable's header and payload.
set +e
"$TMP/exit42"
rc="$?"
set -e
[ "$rc" -eq 42 ] || { echo "expected exit 42, got $rc" >&2; exit 1; }
sh "$ROOT/selfhost/toolchain/build-elf-exit.sh" 0 "$TMP/exit0"
"$TMP/exit0"
sh "$ROOT/selfhost/toolchain/build-elf-exit.sh" 255 "$TMP/exit255"
set +e
"$TMP/exit255"
rc="$?"
set -e
[ "$rc" -eq 255 ] || { echo "expected exit 255, got $rc" >&2; exit 1; }
if sh "$ROOT/selfhost/toolchain/build-elf-exit.sh" 256 "$TMP/invalid" > "$TMP/error" 2>&1; then
    echo 'invalid status was accepted' >&2
    exit 1
fi
[ ! -e "$TMP/invalid" ]
echo 'Triad native S2.0 ELF emitter: PASS'
