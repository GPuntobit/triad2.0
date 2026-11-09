#!/bin/sh
# Three native TRIAD stages: Triad-Core subset -> IR -> assembler -> ELF64.
# The shell only stages and transports validated bytes, with no codegen logic.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
[ "$#" -eq 2 ] || { echo 'usage: sh selfhost/toolchain/compile-triad.sh INPUT.triad OUTPUT_ELF' >&2; exit 2; }
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
sh "$ROOT/selfhost/toolchain/lower-triad.sh" "$1" "$TMP/lowered.tir"
sh "$ROOT/selfhost/toolchain/compile-ir.sh" "$TMP/lowered.tir" "$2"
