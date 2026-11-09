#!/bin/sh
# First-party security checks; no Node.js runtime or script-generated HTML.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
cd "$ROOT"

echo "== Native source and website: no JavaScript"
sh scripts/no-js.sh

echo "== Python isolation for retained development utilities"
python3 tests/security/python_isolation.test.py

echo "== Git executable path hijack resistance"
python3 tests/security/git_path_hijack.test.py

echo "== Workflow actions pinned to immutable SHAs"
python3 tests/security/workflows_pinned.test.py

echo "== No live tokens in repository"
python3 tests/security/no_live_tokens.test.py

echo "== GitHub Actions workflow YAML syntax"
python3 tests/security/workflows_yaml.test.py

echo "== Static HTML and download chart generation"
for file in docs/index.html docs/pages/getting-started.html docs/pages/spec.html \
  docs/tutorial/TUTORIAL.md docs/MANUALE.md \
  scripts/docs/download_chart.py docs/triad-logo.webp; do
  [ -f "$file" ] || { echo "MISSING: $file" >&2; exit 1; }
done
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
python3 scripts/docs/download_chart.py --out "$tmp/chart.svg" >/dev/null
head -c 4 "$tmp/chart.svg" | grep -q '<svg'
echo "SECURITY: PASS"
