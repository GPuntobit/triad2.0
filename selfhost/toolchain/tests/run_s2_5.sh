#!/bin/sh
# Native S2.5 AST -> typed CFG fixed-point -> IR -> ELF64, Linux x86-64.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

for name in add sub inc twice immediates constant_left; do
    echo "S2.5 SOURCE: $name" >&2
    src="$ROOT/selfhost/toolchain/tests/frontend25/$name.triad"
    sh "$ROOT/selfhost/toolchain/lower-triad-s2-5.sh" "$src" "$TMP/$name.tir"
    golden="$ROOT/selfhost/toolchain/tests/frontend25/$name.expected.tir"
    if [ -f "$golden" ]; then
        if ! cmp -s "$golden" "$TMP/$name.tir"; then
            echo "S2.5: typed AST to IR golden mismatch: $name" >&2
            diff -u "$golden" "$TMP/$name.tir" >&2 || true
            exit 1
        fi
    fi
    sh "$ROOT/selfhost/toolchain/verify-cfg-s2-5.sh" "$TMP/$name.tir" > "$TMP/verified"
    grep -qx 'S2.5 CFG: PASS' "$TMP/verified"
    sh "$ROOT/selfhost/toolchain/compile-triad-s2-5.sh" "$src" "$TMP/$name.elf"
    set +e
    "$TMP/$name.elf" > "$TMP/compiled.out" 2> "$TMP/compiled.err"
    native_exit=$?
    "$ROOT/bin/triad" "$src" > "$TMP/interpreted.out" 2> "$TMP/interpreted.err"
    source_exit=$?
    set -e
    case "$name" in
        add) expected=12 ;;
        sub) expected=7 ;;
        inc) expected=7 ;;
        twice) expected=13 ;;
        immediates) expected=8 ;;
        constant_left) expected=7 ;;
    esac
    if [ "$native_exit" -ne "$expected" ] || [ "$source_exit" -ne "$expected" ]; then
        echo "S2.5: $name ELF=$native_exit seed=$source_exit expected=$expected" >&2
        cat "$TMP/interpreted.err" >&2
        cat "$TMP/compiled.err" >&2
        exit 1
    fi
    cmp "$TMP/interpreted.out" "$TMP/compiled.out"
done

# Exact opcode fixture for 2nd SysV argument and EAX return, then execute it.
sh "$ROOT/selfhost/toolchain/assemble-s2-4.sh" "$ROOT/selfhost/toolchain/tests/fixtures/abi_s2_5.s2asm" "$TMP/abi"
xxd -p -s 120 -c 8192 "$TMP/abi" > "$TMP/abi.hex"
cmp "$ROOT/selfhost/toolchain/tests/golden/abi_s2_5.code.hex" "$TMP/abi.hex"
set +e
"$TMP/abi"
code=$?
set -e
[ "$code" -eq 12 ] || { echo "S2.5: ABI opcode test returned $code" >&2; exit 1; }

# Fixed-point CFG proofs over both forward join and actual loop backedge.
for name in loop branch; do
    sh "$ROOT/selfhost/toolchain/verify-cfg-s2-5.sh" "$ROOT/selfhost/toolchain/tests/cfg25/$name.valid.tir" > "$TMP/cfg.out"
    grep -qx 'S2.5 CFG: PASS' "$TMP/cfg.out"
    if sh "$ROOT/selfhost/toolchain/verify-cfg-s2-5.sh" "$ROOT/selfhost/toolchain/tests/cfg25/$name.invalid.tir" > "$TMP/cfg.out" 2>&1; then
        echo "S2.5: invalid $name CFG escaped definite-assignment check" >&2
        exit 1
    fi
done

# Fail closed on untyped ASTs, mismatched function arity and parameter scope.
for invalid in 'function f(a)
return a
end
x = f(1, 2)
exit(x)' 'function f(a, a)
return a
end
x = f(1, 2)
exit(x)' 'function f(a)
result = unknown + a
return result
end
x = f(1)
exit(x)' 'function f(a)
return b
end
x = f(1)
exit(x)' 'function f(a)
result = f(a)
return result
end
x = f(1)
exit(x)' 'function f(a)
return a
end
x = unknown
y = f(x)
exit(y)' 'function f(a)
return a
end
x = f(true)
exit(x)' 'function f(a)
return a
end
x = 3 * 5
y = f(x)
exit(y)' 'function f(a)
return a
end
x = nope(3)
exit(x)' 'function f(a)
return a
end
x = f(1)
exit(1)' 'function f(a)
return a
end
x = f(1)
exit(x)
x = 2' 'function f(a)
return a
end
x = f(1)
print(x)
exit(x)'; do
    printf '%s\n' "$invalid" > "$TMP/invalid.triad"
    if sh "$ROOT/selfhost/toolchain/compile-triad-s2-5.sh" "$TMP/invalid.triad" "$TMP/invalid.elf" > "$TMP/err" 2>&1; then
        echo "S2.5: invalid function source compiled: $invalid" >&2
        exit 1
    fi
    [ ! -e "$TMP/invalid.elf" ]
done

# Invalid function frame/ABI IR must be rejected before any executable.
for invalid in 'start
i32_frame 32
i32_const 1
i32_call f
exit
label f
i32_enter 32
i32_store 0
i32_load 0
i32_result
i32_leave 40
return' 'start
i32_frame 32
i32_const 1
i32_call f
exit
label f
i32_enter 40
i32_store 0
i32_load 0
i32_result
return'; do
    printf '%s\n' "$invalid" > "$TMP/invalid.tir"
    if sh "$ROOT/selfhost/toolchain/lower-ir-s2-5.sh" "$TMP/invalid.tir" "$TMP/invalid.s2asm" > "$TMP/err" 2>&1; then
        echo 'S2.5: unsafe ABI frame accepted' >&2
        exit 1
    fi
    [ ! -e "$TMP/invalid.s2asm" ]
done

sh "$ROOT/selfhost/toolchain/compile-triad-s2-5.sh" "$ROOT/selfhost/toolchain/tests/frontend25/add.triad" "$TMP/add-again"
cmp "$TMP/add.elf" "$TMP/add-again"
echo 'Triad native S2.5 typed AST, CFG fixed point, function ABI: PASS'
