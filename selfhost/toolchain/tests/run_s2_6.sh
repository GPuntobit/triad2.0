#!/bin/sh
# S2.6 native Triad source -> typed AST -> per-function CFG fixed point
# -> i32 IR -> assembly -> executable Linux x86-64 ELF.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

for name in chain nested triple shadow nested_sub; do
    echo "S2.6 CASE: $name" >&2
    src="$ROOT/selfhost/toolchain/tests/frontend26/$name.triad"
    sh "$ROOT/selfhost/toolchain/lower-triad-s2-6.sh" "$src" "$TMP/$name.tir"
    expected_ir="$ROOT/selfhost/toolchain/tests/frontend26/$name.expected.tir"
    if [ -f "$expected_ir" ] && ! cmp -s "$expected_ir" "$TMP/$name.tir"; then
        diff -u "$expected_ir" "$TMP/$name.tir" >&2 || true
        echo "S2.6: unexpected typed IR for $name" >&2
        exit 1
    fi
    sh "$ROOT/selfhost/toolchain/verify-cfg-s2-6.sh" "$TMP/$name.tir" > "$TMP/cfg.out"
    grep -qx 'S2.6 CFG: PASS' "$TMP/cfg.out"
    sh "$ROOT/selfhost/toolchain/compile-triad-s2-6.sh" "$src" "$TMP/$name.elf"
    set +e
    "$TMP/$name.elf" > "$TMP/elf.stdout" 2> "$TMP/elf.stderr"
    elf_status=$?
    "$ROOT/bin/triad" "$src" > "$TMP/seed.stdout" 2> "$TMP/seed.stderr"
    seed_status=$?
    set -e
    case "$name" in
        chain) expected=9 ;;
        nested) expected=9 ;;
        triple) expected=5 ;;
        shadow) expected=12 ;;
        nested_sub) expected=11 ;;
    esac
    if [ "$elf_status" -ne "$expected" ] || [ "$seed_status" -ne "$expected" ]; then
        echo "S2.6: $name generated=$elf_status interpreted=$seed_status expected=$expected" >&2
        cat "$TMP/elf.stderr" "$TMP/seed.stderr" >&2
        exit 1
    fi
    cmp "$TMP/elf.stdout" "$TMP/seed.stdout"
done

# Recompilation must be byte-for-byte deterministic.
sh "$ROOT/selfhost/toolchain/compile-triad-s2-6.sh" "$ROOT/selfhost/toolchain/tests/frontend26/chain.triad" "$TMP/chain.rebuilt"
cmp "$TMP/chain.elf" "$TMP/chain.rebuilt"

# The compiler must reject unproven input and declarations outside contract.
for invalid in \
'function first(x)
    x
end
function second(y)
    value = missing(y)
    value
end
a = second(2)
exit(a)' \
'function first(x)
    result = unknown + x
    result
end
function second(y)
    y
end
a = second(2)
exit(a)' \
'function one(x)
    result = one(x)
    result
end
function two(y)
    y
end
a = one(2)
exit(a)' \
'function one(x)
    x
end
function one(y)
    y
end
a = one(2)
exit(a)' \
'function one(x)
    x
end
function two(y)
    result = three(y)
    result
end
function three(z)
    z
end
a = two(2)
exit(a)' \
'function first(x)
    x
end
function second(y)
    result = first(y)
    result
end
a = second(true)
exit(a)' \
'function first(x)
    x
end
function second(y)
    result = first(y)
    result
end
a = second(2)
exit(3)' \
'function first(x)
    x
end
function second(y)
    result = first(y)
    result
end
a = second(2)
exit(a)
a = 3' \
'function first(x)
    x
end
function second(y)
    y
end
a = 1 + (2 * 3)
b = second(a)
exit(b)' \
'function first(x)
    x
end
function second(y)
    y
end
a = second(2, 3)
exit(a)'; do
    printf '%s\n' "$invalid" > "$TMP/invalid.triad"
    if sh "$ROOT/selfhost/toolchain/compile-triad-s2-6.sh" "$TMP/invalid.triad" "$TMP/invalid.elf" > "$TMP/reject.out" 2>&1; then
        echo "S2.6: accepted unsupported or unsafe source: $invalid" >&2
        exit 1
    fi
    [ ! -e "$TMP/invalid.elf" ]
done

# Independent CFG proof must reject a read not assigned in that function;
# the main frame having the same offset does NOT initialize callee locals.
cat > "$TMP/unsafe.tir" <<'EOF'
start
i32_frame 32
i32_const 2
i32_call first
i32_store 0
i32_load 0
exit
label first
i32_enter 40
i32_store 0
i32_load 4
i32_result
i32_leave 40
return
label second
i32_enter 40
i32_store 0
i32_load 0
i32_result
i32_leave 40
return
EOF
if sh "$ROOT/selfhost/toolchain/verify-cfg-s2-6.sh" "$TMP/unsafe.tir" > "$TMP/cfg.out" 2>&1; then
    echo 'S2.6: CFG accepted uninitialized function-local slot' >&2
    exit 1
fi
echo 'Triad native S2.6 multi-function AST, lexical slots and CFG: PASS'
