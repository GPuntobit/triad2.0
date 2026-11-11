#!/bin/sh
# POSIX byte transport: the lexer, block parser and IR lowerer run in TRIAD.
# Usage: sh selfhost/toolchain/lower-triad.sh INPUT.triad OUTPUT.tir
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
[ "$#" -eq 2 ] || { echo 'usage: sh selfhost/toolchain/lower-triad.sh INPUT.triad OUTPUT.tir' >&2; exit 2; }
source_file=$1
output=$2
[ -f "$source_file" ] && [ -r "$source_file" ] || { echo 'S2.3: unreadable source file' >&2; exit 2; }
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
export LC_ALL=C
size=$(wc -c < "$source_file")
[ "$size" -gt 0 ] && [ "$size" -le 8000 ] || { echo 'S2.3: source outside 1..8000-byte limit' >&2; exit 2; }
# No arbitrary Triad source is executed during compilation. Only a safely
# quoted subset source literal may enter the frontend process.
tr -cd 'a-z0-9_ =+!()\n-' < "$source_file" > "$TMP/clean"
cmp -s "$source_file" "$TMP/clean" || { echo 'S2.3: disallowed source character' >&2; exit 2; }
{
    cat "$ROOT/selfhost/toolchain/elf64_exit.triad"
    cat "$ROOT/selfhost/toolchain/assembler_s2_1.triad"
    cat "$ROOT/selfhost/toolchain/frontend_s2_3.triad"
    printf '\ntriad_input = "'
    cat "$source_file"
    printf '"\nresult = source_to_ir(triad_input)\nprintln(result)\n'
} > "$TMP/frontend.triad"
if ! "$ROOT/bin/triad" "$TMP/frontend.triad" > "$TMP/ir.out"; then
    echo 'S2.3: native frontend rejected source' >&2
    exit 1
fi
[ -s "$TMP/ir.out" ] && [ "$(wc -c < "$TMP/ir.out")" -le 12000 ] || {
    echo 'S2.3: empty or oversized IR' >&2; exit 1;
}
tr -cd 'a-z0-9_ \n' < "$TMP/ir.out" > "$TMP/ir-clean"
cmp -s "$TMP/ir.out" "$TMP/ir-clean" || { echo 'S2.3: malformed IR output' >&2; exit 1; }
# Fail closed: diagnostic output cannot be mistaken for valid IR.
IFS= read -r first < "$TMP/ir.out"
[ "$first" = 'start' ] || { echo 'S2.3: invalid IR header' >&2; exit 1; }
mv "$TMP/ir.out" "$output"
