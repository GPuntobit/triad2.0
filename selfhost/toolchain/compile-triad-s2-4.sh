#!/bin/sh
# Three native Triad passes, POSIX only transports validated files and bytes.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
[ "$#" -eq 2 ] || { echo 'usage: sh selfhost/toolchain/compile-triad-s2-4.sh SOURCE.triad OUTPUT_ELF' >&2; exit 2; }
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
sh "$ROOT/selfhost/toolchain/lower-triad-s2-4.sh" "$1" "$TMP/program.tir"
sh "$ROOT/selfhost/toolchain/lower-ir-s2-4.sh" "$TMP/program.tir" "$TMP/program.s2asm"
sh "$ROOT/selfhost/toolchain/assemble-s2-4.sh" "$TMP/program.s2asm" "$2"
