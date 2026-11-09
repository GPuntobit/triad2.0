#!/bin/sh
# S2.4 streaming IR to S2.1 assembly. All parsing and validation are Triad.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
[ "$#" -eq 2 ] || { echo 'usage: sh selfhost/toolchain/lower-ir-s2-4.sh INPUT.tir OUTPUT.s2asm' >&2; exit 2; }
src=$1
dest=$2
[ -f "$src" ] && [ -r "$src" ] || { echo 'S2.4 IR: unreadable input' >&2; exit 2; }
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
export LC_ALL=C
size=$(wc -c < "$src")
[ "$size" -gt 0 ] && [ "$size" -le 12000 ] || { echo 'S2.4 IR: invalid length' >&2; exit 2; }
tr -cd 'a-z0-9_ \n' < "$src" > "$TMP/allowed"
cmp -s "$src" "$TMP/allowed" || { echo 'S2.4 IR: rejected input bytes' >&2; exit 2; }
{
    cat "$ROOT/selfhost/toolchain/elf64_exit.triad"
    cat "$ROOT/selfhost/toolchain/assembler_s2_1.triad"
    cat "$ROOT/selfhost/toolchain/ir_s2_2.triad"
    cat "$ROOT/selfhost/toolchain/ir_stream_s2_4.triad"
    printf '\nsource_ir = "'
    cat "$src"
    printf '"\nresult_asm = lower_ir_stream24(source_ir)\nprintln(result_asm)\n'
} > "$TMP/lower.triad"
if ! "$ROOT/bin/triad" "$TMP/lower.triad" > "$TMP/asm.out"; then
    echo 'S2.4 IR: native Triad rejected input' >&2
    exit 1
fi
[ -s "$TMP/asm.out" ] && [ "$(wc -c < "$TMP/asm.out")" -le 12000 ] || {
    echo 'S2.4 IR: output exceeds budget' >&2; exit 1;
}
tr -cd 'a-z0-9_ \n' < "$TMP/asm.out" > "$TMP/clean"
cmp -s "$TMP/asm.out" "$TMP/clean" || { echo 'S2.4 IR: output is not assembly' >&2; exit 1; }
mv "$TMP/asm.out" "$dest"
