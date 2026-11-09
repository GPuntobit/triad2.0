#!/bin/sh
# S2.2: native Triad IR lowering + ELF code generation + real kernel execution.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

# Each expected assembly is a separate reviewed source of truth: the
# lowering stage must not silently bypass its typed IR contract.
for name in loop conditional call zero; do
    sh "$ROOT/selfhost/toolchain/lower-ir.sh" "$ROOT/selfhost/toolchain/tests/ir/$name.tir" "$TMP/$name.s2asm"
    if ! cmp -s "$ROOT/selfhost/toolchain/tests/ir/$name.expected.s2asm" "$TMP/$name.s2asm"; then
        echo "S2.2: lowering mismatch for $name" >&2
        diff -u "$ROOT/selfhost/toolchain/tests/ir/$name.expected.s2asm" "$TMP/$name.s2asm" >&2 || true
        exit 1
    fi
    sh "$ROOT/selfhost/toolchain/compile-ir.sh" "$ROOT/selfhost/toolchain/tests/ir/$name.tir" "$TMP/$name"
    set +e
    "$TMP/$name"
    code=$?
    set -e
    expected=0
    case "$name" in
        loop) expected=0 ;;
        conditional) expected=5 ;;
        call) expected=17 ;;
        zero) expected=1 ;;
    esac
    [ "$code" -eq "$expected" ] || { echo "S2.2: $name exited $code, expected $expected" >&2; exit 1; }
done
# Determinism: identical ELF regardless of output path or prior execution.
sh "$ROOT/selfhost/toolchain/compile-ir.sh" "$ROOT/selfhost/toolchain/tests/ir/loop.tir" "$TMP/again"
cmp "$TMP/loop" "$TMP/again"

# Exercise new x86 instruction encodings and stack balancing in real ELF.
sh "$ROOT/selfhost/toolchain/assemble.sh" "$ROOT/selfhost/toolchain/tests/fixtures/stack_s2_2.s2asm" "$TMP/stack"
xxd -p -s 120 -c 8192 "$TMP/stack" > "$TMP/stack.hex"
cmp "$ROOT/selfhost/toolchain/tests/golden/stack_s2_2.code.hex" "$TMP/stack.hex"
"$TMP/stack"

# Native Triad independently reconstructs 64 real S0 ELF header bytes and
# the actual first seven native S0 instruction bytes from auditable fields.
cat "$ROOT/selfhost/toolchain/elf64_exit.triad" "$ROOT/selfhost/toolchain/s0_fragments_s2_2.triad" > "$TMP/seed_fragment.triad"
printf '\nprintln(s0_elf_header_hex())\nprintln(s0_first_opcode_hex())\n' >> "$TMP/seed_fragment.triad"
"$ROOT/bin/triad" "$TMP/seed_fragment.triad" > "$TMP/generated_fragments"
sed -n '1p' "$TMP/generated_fragments" > "$TMP/header.hex"
sed -n '2p' "$TMP/generated_fragments" > "$TMP/prologue.hex"
[ "$(wc -l < "$TMP/generated_fragments")" -eq 2 ]
cmp "$ROOT/selfhost/toolchain/tests/golden/s0-header-64.hex" "$TMP/header.hex"
cmp "$ROOT/selfhost/toolchain/tests/golden/s0-prologue-7.hex" "$TMP/prologue.hex"
xxd -r -p "$ROOT/seed/linux-x86_64/seed.hex" "$TMP/real-seed"
dd if="$TMP/real-seed" of="$TMP/real-header" bs=1 count=64 2>/dev/null
dd if="$TMP/real-seed" of="$TMP/real-prologue" bs=1 skip=120 count=7 2>/dev/null
xxd -p -c 64 "$TMP/real-header" > "$TMP/real-header.hex"
xxd -p -c 7 "$TMP/real-prologue" > "$TMP/real-prologue.hex"
cmp "$TMP/real-header.hex" "$TMP/header.hex"
cmp "$TMP/real-prologue.hex" "$TMP/prologue.hex"

# Fail-closed tests must never create a binary or valid assembly file.
for invalid in     'start
i32_const 1'     'start
i32_const 65536
exit'     'start
br_zero missing
exit'     'start
label wrong
jump missing
exit'     'start
i32_unknown
exit'     'start
start
exit'     'start
i32_const 12 13
exit'     'start
i32_const 1
exit
println(1)'; do
    printf '%s\n' "$invalid" > "$TMP/bad.tir"
    if sh "$ROOT/selfhost/toolchain/compile-ir.sh" "$TMP/bad.tir" "$TMP/bad.elf" > "$TMP/error" 2>&1; then
        echo "S2.2: accepted invalid IR: $invalid" >&2
        exit 1
    fi
    [ ! -e "$TMP/bad.elf" ]
done

echo 'Triad native S2.2 IR and audited S0 fragments: PASS'
