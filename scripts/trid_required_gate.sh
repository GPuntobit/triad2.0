#!/bin/sh
# TRID-074 fail-closed merge policy for five independent check results.
set -eu
[ "$#" -eq 5 ] || { echo 'TRID gate: requires exactly five results' >&2; exit 2; }
n=0
for status in "$@"; do
  n=$((n + 1))
  printf 'TRID gate job_%s=%s\n' "$n" "$status" >&2
  [ "$status" = success ] || {
    echo "TRID gate: job $n did not succeed" >&2
    exit 1
  }
done
printf 'TRID gate: all five independent jobs succeeded\n'
