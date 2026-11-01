#!/bin/sh
# Verifiche di sicurezza suggerite dallo scanner (Codacy/CodeQL).
# Uso: sh tests/security/run.sh   (dal root del repository)
set -e
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

echo "== 1. Windows command detection: nessun where.exe controllato dal repo =="
node --test tests/security/windows_where_path.test.js

echo "== 2. Isolamento Python: json.py/sitecustomize/PYTHONPATH/user-site non influenzano i parser =="
python3 tests/security/python_isolation.test.py

echo "== 2b. Git path hijack: repository-controlled git never invoked =="
python3 tests/security/git_path_hijack.test.py

echo "== 3. Workflow: ogni action pinnata a commit SHA completo e immutabile =="
python3 tests/security/workflows_pinned.test.py

echo "== 4. Script spostati: link tutorial e percorsi build risolvono dalle nuove cartelle =="
for f in docs/tutorial/TUTORIAL.md docs/MANUALE.md docs/PREFazione.md scripts/docs/build-libro.mjs \
         scripts/docs/build-epub.cjs scripts/docs/download_chart.py docs/triad-logo.webp; do
  [ -e "$f" ] || { echo "MISSING $f"; exit 1; }
done
grep -q "scripts/docs/download_chart.py" .github/workflows/download-chart.yml
grep -q "docs/tutorial/TUTORIAL.md" README.md
echo "PASS: relocated paths resolve"

echo "== 5. Download chart: lo script eseguibile scrive l'output atteso =="
TMP_OUT="$(mktemp -d)/chart.svg"
python3 scripts/docs/download_chart.py --out "$TMP_OUT" >/dev/null
head -c 4 "$TMP_OUT" | grep -q "<svg" || { echo "output non-SVG"; exit 1; }
echo "PASS: download_chart writes valid SVG to --out"

echo "== 6. Sanitization incompleta: payload innestati/entità non riassemblano markup =="
node --test tests/security/incomplete_sanitization.test.mjs

echo "ALL SECURITY VERIFICATIONS PASSED"
