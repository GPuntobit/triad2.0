#!/bin/sh
# Real fixed-point CFG verifier, executed by Triad itself before codegen.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
[ "$#" -eq 1 ] || { echo 'usage: sh selfhost/toolchain/verify-cfg-s2-6.sh INPUT.tir' >&2; exit 2; }
src=$1
[ -f "$src" ] && [ -r "$src" ] || { echo 'S2.6 CFG: unreadable IR' >&2; exit 2; }
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
export LC_ALL=C
size=$(wc -c < "$src")
[ "$size" -gt 0 ] && [ "$size" -le 12000 ] || { echo 'S2.6 CFG: IR exceeds bounds' >&2; exit 2; }
tr -cd 'a-z0-9_ \n' < "$src" > "$TMP/allowed"
cmp -s "$src" "$TMP/allowed" || { echo 'S2.6 CFG: unsafe input' >&2; exit 2; }
{
    cat "$ROOT/selfhost/toolchain/elf64_exit.triad"
    cat "$ROOT/selfhost/toolchain/assembler_s2_1.triad"
    cat "$ROOT/selfhost/toolchain/cfg_s2_5.triad"
    cat "$ROOT/selfhost/toolchain/ir_stream_s2_4.triad"
    cat "$ROOT/selfhost/toolchain/cfg_s2_6.triad"
    printf '\nir_input = "'
    cat "$src"
    printf '"\nverified = cfg26_verify(ir_input)\nif !verified\n    exit(1)\nend\nprintln("S2.6 CFG: PASS")\n'
} > "$TMP/check.triad"
if ! "$ROOT/bin/triad" "$TMP/check.triad" > "$TMP/result"; then
    echo 'S2.6 CFG: native fixed-point verification failed' >&2
    head -c 2000 "$TMP/result" >&2
    exit 1
fi
grep -qx 'S2.6 CFG: PASS' "$TMP/result" || { echo 'S2.6 CFG: unexpected verifier output' >&2; head -c 2000 "$TMP/result" >&2; exit 1; }
cat "$TMP/result"
