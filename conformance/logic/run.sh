#!/bin/sh
set -u
root=$(CDPATH= cd "$(dirname "$0")/../.." && pwd) || exit 2
tmp=$(mktemp -d /tmp/triad-logic-tests.XXXXXXXX) || exit 2
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
bad=0; total=0
for case_dir in "$root"/conformance/logic/cases/*; do
    total=$((total + 1))
    sh "$root/scripts/run-logic.sh" "$case_dir/program.triad" > "$tmp/out" 2> "$tmp/err"
    rc=$?
    if [ "$rc" = "$(cat "$case_dir/expected.code")" ] && cmp -s "$tmp/out" "$case_dir/expected.out"; then
        echo "PASS  logic/$(basename "$case_dir")"
    else
        echo "FAIL  logic/$(basename "$case_dir") (exit $rc)"
        diff -u "$case_dir/expected.out" "$tmp/out" || true
        cat "$tmp/err"
        bad=$((bad + 1))
    fi
done
echo "logic: $total cases, $bad failed"
[ "$bad" = 0 ]
