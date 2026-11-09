#!/bin/sh
# POSIX input/output transport only; parsing, symbols and codegen are Triad.
# Usage: sh selfhost/toolchain/assemble.sh SOURCE.s2asm OUTPUT
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
if [ "$#" -ne 2 ]; then
    echo 'usage: sh selfhost/toolchain/assemble.sh SOURCE.s2asm OUTPUT' >&2
    exit 2
fi
input=$1
output=$2
[ -f "$input" ] && [ -r "$input" ] || {
    echo 'assembler: input file is not readable' >&2
    exit 2
}
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
# Prevent any input from escaping the Triad multiline string literal.
# This is NOT an assembler parser: no opcodes or labels are decoded by shell.
export LC_ALL=C
size=$(wc -c < "$input")
[ "$size" -gt 0 ] && [ "$size" -le 12000 ] || {
    echo 'assembler: source must contain 1..12000 bytes' >&2
    exit 2
}
tr -cd 'a-z0-9_ \n' < "$input" > "$TMP/allowed"
if ! cmp -s "$input" "$TMP/allowed"; then
    echo 'assembler: only lowercase ASCII, digits, underscore, spaces and LF permitted' >&2
    exit 2
fi
{
    cat "$ROOT/selfhost/toolchain/elf64_exit.triad"
    cat "$ROOT/selfhost/toolchain/assembler_s2_1.triad"
    printf '\nasm_source = "'
    cat "$input"
    printf '"\nimage = assemble_text(asm_source)\nprintln(image)\n'
} > "$TMP/run.triad"
if ! "$ROOT/bin/triad" "$TMP/run.triad" > "$TMP/code.hex"; then
    echo 'assembler: native Triad rejected this program' >&2
    exit 1
fi
# Reject output contamination, malformed hex or excessive image length.
tr -d '\n' < "$TMP/code.hex" > "$TMP/no_newline.hex"
tr -cd '0123456789abcdef' < "$TMP/no_newline.hex" > "$TMP/hex_only"
if ! cmp -s "$TMP/no_newline.hex" "$TMP/hex_only"; then
    echo 'assembler: Triad produced non-hex output' >&2
    exit 1
fi
digits=$(wc -c < "$TMP/no_newline.hex")
[ "$digits" -ge 242 ] && [ "$digits" -le 8432 ] && [ $((digits % 2)) -eq 0 ] || {
    echo 'assembler: native output length invalid' >&2
    exit 1
}
xxd -r -p "$TMP/no_newline.hex" "$TMP/program"
bytes=$(wc -c < "$TMP/program")
[ "$bytes" -eq $((digits / 2)) ] || {
    echo 'assembler: hex decoding mismatch' >&2
    exit 1
}
chmod 755 "$TMP/program"
mv "$TMP/program" "$output"
