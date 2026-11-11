#!/bin/sh
# S2.3: compiled TRIAD source and directly interpreted source must agree.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
for name in simple loop conditional nested equality; do
    src="$ROOT/selfhost/toolchain/tests/frontend/$name.triad"
    golden="$ROOT/selfhost/toolchain/tests/frontend/$name.expected.tir"
    sh "$ROOT/selfhost/toolchain/lower-triad.sh" "$src" "$TMP/$name.tir"
    if ! cmp -s "$golden" "$TMP/$name.tir"; then
        echo "S2.3: source-to-IR golden mismatch: $name" >&2
        diff -u "$golden" "$TMP/$name.tir" >&2 || true
        exit 1
    fi
    sh "$ROOT/selfhost/toolchain/compile-triad.sh" "$src" "$TMP/$name.elf"
    set +e
    "$TMP/$name.elf" > "$TMP/compiled.out" 2> "$TMP/compiled.err"
    compiled_code=$?
    "$ROOT/bin/triad" "$src" > "$TMP/interpreted.out" 2> "$TMP/interpreted.err"
    interpreted_code=$?
    set -e
    expected=0
    case "$name" in
        simple) expected=5 ;;
        loop) expected=0 ;;
        conditional) expected=9 ;;
        nested) expected=0 ;;
        equality) expected=3 ;;
    esac
    [ "$compiled_code" -eq "$expected" ] || {
        echo "S2.3: $name compiled exit $compiled_code, expected $expected" >&2
        exit 1
    }
    [ "$interpreted_code" -eq "$expected" ] || {
        echo "S2.3: $name S0 exit $interpreted_code, expected $expected" >&2
        cat "$TMP/interpreted.err" >&2
        exit 1
    }
    cmp "$TMP/compiled.out" "$TMP/interpreted.out"
done

# Verify byte-for-byte reproducibility across build invocations.
sh "$ROOT/selfhost/toolchain/compile-triad.sh" "$ROOT/selfhost/toolchain/tests/frontend/simple.triad" "$TMP/rebuilt"
cmp "$TMP/simple.elf" "$TMP/rebuilt"

# Fail closed for undefined variable, malformed blocks, invalid expressions,
# multiple or missing exits, and unknown statements or attempted injection.
for invalid in 'x += 1
exit(x)' 'x = 1
while x != 0
exit(x)' 'x = 1
end
exit(x)' 'x = 1
else
exit(x)' 'x = 1
if x == 1
else
else
end
exit(x)' 'x = 1
if x == 1
x = 2
end' 'x = 1
exit(x)
x = 2' 'x = 1
exit(1)' 'x = 65536
exit(x)' 'x = -1
exit(x)' 'y = 1
exit(y)' 'x = 1
while x > 0
x -= 1
end
exit(x)' 'x = 1
println(x)
exit(x)' 'x = 1
exit(x); println(1)'; do
    printf '%s\n' "$invalid" > "$TMP/bad.triad"
    if sh "$ROOT/selfhost/toolchain/compile-triad.sh" "$TMP/bad.triad" "$TMP/bad.elf" > "$TMP/error.out" 2>&1; then
        echo "S2.3: invalid source accepted: $invalid" >&2
        exit 1
    fi
    [ ! -e "$TMP/bad.elf" ]
done
echo 'Triad native S2.3 source frontend and ELF differential: PASS'
