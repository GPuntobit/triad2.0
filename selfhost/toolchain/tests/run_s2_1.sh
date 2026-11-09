#!/bin/sh
# Tests MUST execute native-generated ELF on Linux; no compiler/JS used.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

for name in forward backward rip_data call; do
    sh "$ROOT/selfhost/toolchain/assemble.sh" "$ROOT/selfhost/toolchain/tests/fixtures/$name.s2asm" "$TMP/$name"
    xxd -p -s 120 -c 8192 "$TMP/$name" > "$TMP/$name.code.hex"
    if ! cmp -s "$ROOT/selfhost/toolchain/tests/golden/$name.code.hex" "$TMP/$name.code.hex"; then
        echo "S2.1: code bytes differ in $name" >&2
        diff -u "$ROOT/selfhost/toolchain/tests/golden/$name.code.hex" "$TMP/$name.code.hex" >&2 || true
        exit 1
    fi
done
# Forward jump skips a wrong exit status.
set +e
"$TMP/forward"
rc=$?
set -e
[ "$rc" -eq 42 ] || { echo "forward: expected 42, got $rc" >&2; exit 1; }
# Backward conditional jump loops three times and exits 0.
"$TMP/backward"
# RIP-relative LEA points to a trailing data byte and Linux write prints A.
"$TMP/rip_data" > "$TMP/output"
printf A > "$TMP/expected"
cmp "$TMP/expected" "$TMP/output"
# CALL rel32 jumps to the body, RET returns, exit status 17.
set +e
"$TMP/call"
rc=$?
set -e
[ "$rc" -eq 17 ] || { echo "call: expected 17, got $rc" >&2; exit 1; }

# Reassembly is deterministic, independent of working directory and previous runs.
sh "$ROOT/selfhost/toolchain/assemble.sh" "$ROOT/selfhost/toolchain/tests/fixtures/forward.s2asm" "$TMP/again"
cmp "$TMP/forward" "$TMP/again"

# Negative tests: fail closed without creating an executable.
for entry in 'jmp missing' 'label x
label x
mov_edi 42
mov_eax 60
syscall' 'mov_edi 65536
mov_eax 60
syscall' 'nop 1' 'byte 256'; do
    printf '%s\n' "$entry" > "$TMP/bad.s2asm"
    if sh "$ROOT/selfhost/toolchain/assemble.sh" "$TMP/bad.s2asm" "$TMP/bad" > "$TMP/error.out" 2>&1; then
        echo "S2.1: invalid assembly unexpectedly accepted: $entry" >&2
        exit 1
    fi
    [ ! -e "$TMP/bad" ]
done
printf 'mov_edi 1\nprintln(1)\n' > "$TMP/injected.s2asm"
if sh "$ROOT/selfhost/toolchain/assemble.sh" "$TMP/injected.s2asm" "$TMP/injected" > "$TMP/error.out" 2>&1; then
    echo 'S2.1: unsafe input unexpectedly accepted' >&2
    exit 1
fi
[ ! -e "$TMP/injected" ]
echo 'Triad native S2.1 assembler (labels, branches, RIP data, call/ret): PASS'
