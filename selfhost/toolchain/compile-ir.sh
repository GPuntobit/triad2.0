#!/bin/sh
# Two native Triad stages: IR -> S2.1 assembler -> Linux x86-64 ELF.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
[ "$#" -eq 2 ] || { echo 'usage: sh selfhost/toolchain/compile-ir.sh SOURCE.tir OUTPUT_ELF' >&2; exit 2; }
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
sh "$ROOT/selfhost/toolchain/lower-ir.sh" "$1" "$TMP/lowered.s2asm"
sh "$ROOT/selfhost/toolchain/assemble.sh" "$TMP/lowered.s2asm" "$2"
