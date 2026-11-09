#!/bin/sh
# Native S2.4: multi-variable Triad-Core subset, typed definite assignment,
# stack-slot assembler and differential semantics against direct seed S0.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
for name in multi loop join compare nested eight else_false copy; do
    src="$ROOT/selfhost/toolchain/tests/frontend24/$name.triad"
    sh "$ROOT/selfhost/toolchain/lower-triad-s2-4.sh" "$src" "$TMP/$name.tir"
    golden="$ROOT/selfhost/toolchain/tests/frontend24/$name.expected.tir"
    if [ -f "$golden" ] && ! cmp -s "$golden" "$TMP/$name.tir"; then
        echo "S2.4: IR golden mismatch for $name" >&2
        diff -u "$golden" "$TMP/$name.tir" >&2 || true
        exit 1
    fi
    sh "$ROOT/selfhost/toolchain/compile-triad-s2-4.sh" "$src" "$TMP/$name.elf"
    set +e
    "$TMP/$name.elf" > "$TMP/$name.compiled.out" 2> "$TMP/$name.compiled.err"
    compiled_status=$?
    "$ROOT/bin/triad" "$src" > "$TMP/$name.interpreted.out" 2> "$TMP/$name.interpreted.err"
    native_status=$?
    set -e
    case "$name" in
        multi) expected=15 ;;
        loop) expected=12 ;;
        join) expected=7 ;;
        compare) expected=0 ;;
        nested) expected=4 ;;
        eight) expected=36 ;;
        else_false) expected=11 ;;
        copy) expected=9 ;;
    esac
    if [ "$compiled_status" -ne "$expected" ] || [ "$native_status" -ne "$expected" ]; then
        echo "S2.4: $name compiled=$compiled_status interpreted=$native_status expected=$expected" >&2
        cat "$TMP/$name.interpreted.err" >&2
        exit 1
    fi
    cmp "$TMP/$name.compiled.out" "$TMP/$name.interpreted.out"
done
sh "$ROOT/selfhost/toolchain/compile-triad-s2-4.sh" "$ROOT/selfhost/toolchain/tests/frontend24/multi.triad" "$TMP/rebuilt"
cmp "$TMP/multi.elf" "$TMP/rebuilt"

# Validate each machine opcode against an independent reviewed golden.
sh "$ROOT/selfhost/toolchain/assemble.sh" "$ROOT/selfhost/toolchain/tests/fixtures/stack_s2_4.s2asm" "$TMP/stack"
xxd -p -s 120 -c 8192 "$TMP/stack" > "$TMP/stack.code.hex"
cmp "$ROOT/selfhost/toolchain/tests/golden/stack_s2_4.code.hex" "$TMP/stack.code.hex"
set +e
"$TMP/stack"
stack_status=$?
set -e
[ "$stack_status" -eq 7 ] || { echo "S2.4: stack assembly exit $stack_status" >&2; exit 1; }

# Structured control-flow/definite-assignment negative cases. An assignment
# inside an if without else or a while is not definitely available afterward.
for bad in 'a = b
exit(a)' 'a = 1
if a == 1
    result = 7
end
exit(result)' 'a = 1
while a != 0
    tmp = 2
    a -= 1
end
exit(tmp)' 'a = 1
if a == 1
    tmp = 7
else
    a = 3
end
exit(tmp)' 'a = 1
if a == 1
    y = 5
else
    z = y
end
exit(a)' 'a = 1
while b != 0
    a -= 1
end
exit(a)' 'a = 1
b = 0
if a > b
    a = 2
end
exit(a)' 'a = 1
b = true
exit(b)' 'a = 1
b = a * 3
exit(b)' 'a = 1
exit(2)' 'a = 1
exit(a)
a = 2' 'a = 1
if a == 1
    a = 2
exit(a)' 'a = 1
end
exit(a)' 'a = 1
b = 2
c = 3
d = 4
e = 5
f = 6
g = 7
h = 8
i = 9
exit(i)' 'a = 65536
exit(a)' 'a = 1
println(a)
exit(a)'; do
    printf '%s\n' "$bad" > "$TMP/bad.triad"
    if sh "$ROOT/selfhost/toolchain/compile-triad-s2-4.sh" "$TMP/bad.triad" "$TMP/bad.elf" > "$TMP/bad.log" 2>&1; then
        echo "S2.4: invalid source unexpectedly compiled: $bad" >&2
        exit 1
    fi
    [ ! -e "$TMP/bad.elf" ]
done

# Reject malformed stack IR and out-of-frame offsets independently of source.
for bad in 'start
i32_load 0
exit' 'start
i32_frame 16
i32_const 1
i32_store 0
exit' 'start
i32_frame 32
i32_const 1
i32_store 29
exit' 'start
i32_frame 32
i32_const 1
i32_store 32
exit' 'start
i32_frame 32
i32_frame 32
i32_const 1
exit'; do
    printf '%s\n' "$bad" > "$TMP/bad.tir"
    if sh "$ROOT/selfhost/toolchain/compile-ir.sh" "$TMP/bad.tir" "$TMP/bad-from-ir" > "$TMP/ir.log" 2>&1; then
        echo "S2.4: invalid typed IR unexpectedly assembled: $bad" >&2
        exit 1
    fi
    [ ! -e "$TMP/bad-from-ir" ]
done
echo 'Triad native S2.4 multi-variable stack and structured CFG: PASS'
