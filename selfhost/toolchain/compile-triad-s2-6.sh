#!/bin/sh
# Typed native Triad frontend -> CFG check -> native IR -> S2.1 ELF64.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
[ "$#" -eq 2 ] || { echo 'usage: sh selfhost/toolchain/compile-triad-s2-6.sh SOURCE.triad OUTPUT_ELF' >&2; exit 2; }
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
sh "$ROOT/selfhost/toolchain/lower-triad-s2-6.sh" "$1" "$TMP/program.tir"
sh "$ROOT/selfhost/toolchain/verify-cfg-s2-6.sh" "$TMP/program.tir"
sh "$ROOT/selfhost/toolchain/lower-ir-s2-6.sh" "$TMP/program.tir" "$TMP/program.s2asm"
sh "$ROOT/selfhost/toolchain/assemble-s2-4.sh" "$TMP/program.s2asm" "$2"
