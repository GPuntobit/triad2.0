#!/bin/sh
# POSIX transport; S2.4 assembler parses and lays out instructions in Triad.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
[ "$#" -eq 2 ] || { echo 'usage: sh selfhost/toolchain/assemble-s2-4.sh INPUT.s2asm OUTPUT_ELF' >&2; exit 2; }
src=$1
dest=$2
[ -f "$src" ] && [ -r "$src" ] || { echo 'S2.4 assembly: unreadable source' >&2; exit 2; }
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
export LC_ALL=C
size=$(wc -c < "$src")
[ "$size" -gt 0 ] && [ "$size" -le 12000 ] || { echo 'S2.4 assembly: invalid size' >&2; exit 2; }
tr -cd 'a-z0-9_ \n' < "$src" > "$TMP/allowed"
cmp -s "$src" "$TMP/allowed" || { echo 'S2.4 assembly: invalid characters' >&2; exit 2; }
{
    cat "$ROOT/selfhost/toolchain/elf64_exit.triad"
    cat "$ROOT/selfhost/toolchain/assembler_s2_1.triad"
    cat "$ROOT/selfhost/toolchain/assembler_stream_s2_4.triad"
    printf '\nsource_asm = "'
    cat "$src"
    printf '"\nimage = assemble_stream24(source_asm)\nprintln(image)\n'
} > "$TMP/assemble.triad"
if ! "$ROOT/bin/triad" "$TMP/assemble.triad" > "$TMP/code.hex"; then
    echo 'S2.4 assembly: native Triad rejected source' >&2
    exit 1
fi
tr -d '\n' < "$TMP/code.hex" > "$TMP/no-newline"
tr -cd '0123456789abcdef' < "$TMP/no-newline" > "$TMP/hex-only"
cmp -s "$TMP/no-newline" "$TMP/hex-only" || { echo 'S2.4 assembly: non-hex output' >&2; exit 1; }
digits=$(wc -c < "$TMP/no-newline")
[ "$digits" -ge 242 ] && [ "$digits" -le 8432 ] && [ $((digits % 2)) -eq 0 ] || {
    echo 'S2.4 assembly: invalid ELF hex length' >&2; exit 1;
}
xxd -r -p "$TMP/no-newline" "$TMP/program"
[ "$(wc -c < "$TMP/program")" -eq $((digits / 2)) ] || {
    echo 'S2.4 assembly: decode mismatch' >&2; exit 1;
}
chmod 755 "$TMP/program"
mv "$TMP/program" "$dest"
