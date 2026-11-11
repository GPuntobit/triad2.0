#!/bin/sh
# Native Triad S2.5 IR validation and lowering, POSIX transport only.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
[ "$#" -eq 2 ] || { echo 'usage: sh selfhost/toolchain/lower-ir-s2-5.sh INPUT.tir OUTPUT.s2asm' >&2; exit 2; }
src=$1
dest=$2
[ -f "$src" ] && [ -r "$src" ] || { echo 'S2.5 IR: unreadable file' >&2; exit 2; }
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
export LC_ALL=C
size=$(wc -c < "$src")
[ "$size" -gt 0 ] && [ "$size" -le 12000 ] || { echo 'S2.5 IR: invalid size' >&2; exit 2; }
tr -cd 'a-z0-9_ \n' < "$src" > "$TMP/allowed"
cmp -s "$src" "$TMP/allowed" || { echo 'S2.5 IR: unsafe bytes' >&2; exit 2; }
{
    cat "$ROOT/selfhost/toolchain/elf64_exit.triad"
    cat "$ROOT/selfhost/toolchain/assembler_s2_1.triad"
    cat "$ROOT/selfhost/toolchain/ir_s2_2.triad"
    cat "$ROOT/selfhost/toolchain/ir_stream_s2_5.triad"
    printf '\nsource = "'
    cat "$src"
    printf '"\nresult = lower_ir_stream25(source)\nprintln(result)\n'
} > "$TMP/runner.triad"
if ! "$ROOT/bin/triad" "$TMP/runner.triad" > "$TMP/asm"; then
    echo 'S2.5 IR: native lowerer rejected input' >&2; exit 1
fi
[ -s "$TMP/asm" ] && [ "$(wc -c < "$TMP/asm")" -le 12000 ] || { echo 'S2.5 IR: invalid output size' >&2; exit 1; }
tr -cd 'a-z0-9_ \n' < "$TMP/asm" > "$TMP/clean"
cmp -s "$TMP/asm" "$TMP/clean" || { echo 'S2.5 IR: malformed output' >&2; exit 1; }
mv "$TMP/asm" "$dest"
