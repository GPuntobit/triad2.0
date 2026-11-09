#!/bin/sh
# POSIX input transport only; all IR parsing and lowering is native Triad.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
[ "$#" -eq 2 ] || { echo 'usage: sh selfhost/toolchain/lower-ir.sh SOURCE.tir OUTPUT.s2asm' >&2; exit 2; }
source_path=$1
output_path=$2
[ -f "$source_path" ] && [ -r "$source_path" ] || { echo 'IR: input file unreadable' >&2; exit 2; }
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
export LC_ALL=C
size=$(wc -c < "$source_path")
[ "$size" -gt 0 ] && [ "$size" -le 12000 ] || { echo 'IR: source size invalid' >&2; exit 2; }
# Identical safe literal transport policy to S2.1 (no quotes or escapes).
tr -cd 'a-z0-9_ \n' < "$source_path" > "$TMP/allowed"
cmp -s "$source_path" "$TMP/allowed" || { echo 'IR: invalid source characters' >&2; exit 2; }
{
    cat "$ROOT/selfhost/toolchain/elf64_exit.triad"
    cat "$ROOT/selfhost/toolchain/assembler_s2_1.triad"
    cat "$ROOT/selfhost/toolchain/ir_s2_2.triad"
    printf '\nir_input = "'
    cat "$source_path"
    printf '"\nlowered = lower_ir(ir_input)\nprintln(lowered)\n'
} > "$TMP/lower.triad"
if ! "$ROOT/bin/triad" "$TMP/lower.triad" > "$TMP/asm.out"; then
    echo 'IR: native Triad rejected the input' >&2
    exit 1
fi
[ -s "$TMP/asm.out" ] && [ "$(wc -c < "$TMP/asm.out")" -le 12000 ] || {
    echo 'IR: generated assembly size invalid' >&2; exit 1;
}
tr -cd 'a-z0-9_ \n' < "$TMP/asm.out" > "$TMP/clean"
cmp -s "$TMP/asm.out" "$TMP/clean" || { echo 'IR: non-assembly output' >&2; exit 1; }
mv "$TMP/asm.out" "$output_path"
