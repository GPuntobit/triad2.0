#!/bin/sh
# S2.5: source bytes only; AST, types and ABI lowering run in native Triad.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
[ "$#" -eq 2 ] || { echo 'usage: sh selfhost/toolchain/lower-triad-s2-5.sh INPUT.triad OUTPUT.tir' >&2; exit 2; }
src=$1
dest=$2
[ -f "$src" ] && [ -r "$src" ] || { echo 'S2.5: unreadable source' >&2; exit 2; }
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
export LC_ALL=C
size=$(wc -c < "$src")
[ "$size" -gt 0 ] && [ "$size" -le 8000 ] || { echo 'S2.5: source exceeds bounds' >&2; exit 2; }
tr -cd 'a-z0-9_ =+!(),\n-' < "$src" > "$TMP/allowed"
cmp -s "$src" "$TMP/allowed" || { echo 'S2.5: unsafe source bytes' >&2; exit 2; }
{
    cat "$ROOT/selfhost/toolchain/elf64_exit.triad"
    cat "$ROOT/selfhost/toolchain/assembler_s2_1.triad"
    cat "$ROOT/selfhost/toolchain/frontend_s2_3.triad"
    cat "$ROOT/selfhost/toolchain/frontend_s2_4.triad"
    cat "$ROOT/selfhost/toolchain/frontend_s2_5.triad"
    printf '\nsource = "'
    cat "$src"
    printf '"\nresult = source_to_ir25(source)\nprintln(result)\n'
} > "$TMP/frontend.triad"
if ! "$ROOT/bin/triad" "$TMP/frontend.triad" > "$TMP/ir"; then
    echo 'S2.5: Triad AST/type frontend rejected input' >&2
    exit 1
fi
[ -s "$TMP/ir" ] && [ "$(wc -c < "$TMP/ir")" -le 12000 ] || { echo 'S2.5: IR size invalid' >&2; exit 1; }
tr -cd 'a-z0-9_ \n' < "$TMP/ir" > "$TMP/clean"
cmp -s "$TMP/ir" "$TMP/clean" || { echo 'S2.5: non-IR output' >&2; exit 1; }
IFS= read -r first < "$TMP/ir"
[ "$first" = start ] || { echo 'S2.5: invalid IR entry' >&2; exit 1; }
mv "$TMP/ir" "$dest"
