#!/bin/sh
# TRID 0.3 reference generator + persistent laboratory.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
python3 -m unittest discover -s "$ROOT/cognitive/tests" -p test_03.py
python3 "$ROOT/cognitive/tools/discover_03.py" \
  --fixture "$ROOT/cognitive/fixtures/discovery_03.json" \
  --store "$TMP/hypotheses.jsonl" --generated-dir "$TMP/generated" > "$TMP/report.json"
COUNT1=$(wc -l < "$TMP/hypotheses.jsonl")
python3 "$ROOT/cognitive/tools/discover_03.py" \
  --fixture "$ROOT/cognitive/fixtures/discovery_03.json" \
  --store "$TMP/hypotheses.jsonl" --generated-dir "$TMP/generated" > "$TMP/report_again.json"
COUNT2=$(wc -l < "$TMP/hypotheses.jsonl")
if [ "$COUNT1" -ne "$COUNT2" ] || ! cmp -s "$TMP/report.json" "$TMP/report_again.json"; then
  echo "TRID-Core 0.3: non-idempotent result" >&2
  exit 1
fi
[ -s "$TMP/generated/family_grandparent.triad" ]
[ -s "$TMP/generated/family_sibling.triad" ]
echo "TRID-Core 0.3 reference generator and append-only journal: PASS"
if [ "${TRID_RUN_NATIVE:-0}" = 1 ]; then
  "$ROOT/bin/triad" --logic "$TMP/generated/family_grandparent.triad" > "$TMP/grandparent.out"
  "$ROOT/bin/triad" --logic "$TMP/generated/family_sibling.triad" > "$TMP/sibling.out"
  grep -q ':nina' "$TMP/grandparent.out"
  grep -q ':antonella' "$TMP/sibling.out"
  echo "TRID-Core 0.3 generated S1 programs: PASS"
fi
