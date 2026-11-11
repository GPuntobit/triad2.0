#!/bin/sh
# Source transport only: lexer, types, CFG and IR lowering are native Triad.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
[ "$#" -eq 2 ] || { echo 'usage: sh selfhost/toolchain/lower-triad-s2-4.sh SOURCE.triad OUTPUT.tir' >&2; exit 2; }
src=$1
dest=$2
[ -f "$src" ] && [ -r "$src" ] || { echo 'S2.4: unreadable source' >&2; exit 2; }
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
export LC_ALL=C
size=$(wc -c < "$src")
[ "$size" -gt 0 ] && [ "$size" -le 8000 ] || { echo 'S2.4: source size invalid' >&2; exit 2; }
# The compiler input is a literal, not executable source. Never permit quotes,
# backslashes, control characters or arbitrary code in this transport stage.
tr -cd 'a-z0-9_ =+!()\n-' < "$src" > "$TMP/allowed"
cmp -s "$src" "$TMP/allowed" || { echo 'S2.4: source contains disallowed characters' >&2; exit 2; }
{
    cat "$ROOT/selfhost/toolchain/elf64_exit.triad"
    cat "$ROOT/selfhost/toolchain/assembler_s2_1.triad"
    cat "$ROOT/selfhost/toolchain/frontend_s2_3.triad"
    cat "$ROOT/selfhost/toolchain/frontend_s2_4.triad"
    printf '\nmv_source = "'
    cat "$src"
    printf '"\nmv_ir = source_to_ir24(mv_source)\nprintln(mv_ir)\n'
} > "$TMP/source_to_ir.triad"
if ! "$ROOT/bin/triad" "$TMP/source_to_ir.triad" > "$TMP/result"; then
    echo 'S2.4: native typed frontend rejected source' >&2
    exit 1
fi
[ -s "$TMP/result" ] && [ "$(wc -c < "$TMP/result")" -le 12000 ] || {
    echo 'S2.4: generated IR outside budget' >&2
    exit 1
}
tr -cd 'a-z0-9_ \n' < "$TMP/result" > "$TMP/clean"
cmp -s "$TMP/result" "$TMP/clean" || { echo 'S2.4: non-IR output' >&2; exit 1; }
IFS= read -r header < "$TMP/result"
[ "$header" = 'start' ] || { echo 'S2.4: unexpected IR header' >&2; exit 1; }
mv "$TMP/result" "$dest"
