#!/bin/sh
# TRID 0.4 integration: 0.3 synthesis -> independent verifier -> memory.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
python3 -m unittest discover -s "$ROOT/cognitive/tests" -p test_04.py
python3 "$ROOT/cognitive/tools/discover_03.py" \
  --fixture "$ROOT/cognitive/fixtures/discovery_03.json" \
  --store "$TMP/experiments.jsonl" \
  --generated-dir "$TMP/generated" > "$TMP/discover.json"
python3 "$ROOT/cognitive/tools/proof_04.py" \
  --fixture "$ROOT/cognitive/fixtures/discovery_03.json" \
  --journal "$TMP/experiments.jsonl" \
  --definitions "$ROOT/cognitive/fixtures/definitions_04.json" \
  --memory "$TMP/memory.json" \
  --approve family_grandparent_chain \
  --approve family_sibling_common_source > "$TMP/report.json"
python3 - "$TMP/memory.json" <<'PY'
import json, sys
v = json.load(open(sys.argv[1]))
states = {rule['id']: rule['state'] for rule in v['rules']}
assert states['family_grandparent_chain'] == 'consolidated_conditional', states
assert states['family_sibling_common_source'] == 'consolidated_conditional', states
assert any(rule['state'] == 'refuted' for rule in v['rules'])
assert any(claim['claim'] == ['family','grandparent','mario','antonio'] for claim in v['claims'])
assert all(claim['state'] == 'demonstrated_conditional' for claim in v['claims'])
PY
python3 "$ROOT/cognitive/tools/proof_04.py" \
  --fixture "$ROOT/cognitive/fixtures/discovery_03.json" \
  --journal "$TMP/experiments.jsonl" \
  --definitions "$ROOT/cognitive/fixtures/definitions_04.json" \
  --memory "$TMP/revoked.json" \
  --approve family_grandparent_chain \
  --approve family_sibling_common_source \
  --revoke-source book_02 > "$TMP/revoked_report.json"
python3 - "$TMP/revoked.json" <<'PY'
import json, sys
v = json.load(open(sys.argv[1]))
assert any(c['state'] == 'suspended' and 'book_02' in c['retracted_sources'] for c in v['claims'])
assert any(c['state'] == 'demonstrated_conditional' for c in v['claims'])
PY
echo 'TRID-Core 0.4 independent proof + dependency projection: PASS'
