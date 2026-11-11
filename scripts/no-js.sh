#!/bin/sh
# Triad 2.0 — tracked-tree JavaScript exclusion gate.
# Keeps the Triad source tree free of JavaScript/TypeScript sources,
# inline browser scripts, Node launchers and npm package manifests.
# This does not rewrite Git history or inspect external GitHub Actions.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
LC_ALL=C
export LC_ALL
git ls-files > "$TMP/files"
grep -E -i '\.(js|jsx|mjs|cjs|ts|tsx|mts|cts)$' "$TMP/files" > "$TMP/code" || true
grep -E '(^|/)(package(-lock)?\.json|npm-shrinkwrap\.json|yarn\.lock|pnpm-lock\.yaml)$' "$TMP/files" > "$TMP/packages" || true
grep -E -i '\.(html|htm|svg)$' "$TMP/files" > "$TMP/web" || true
# Only inspect first-party executable markup, not Markdown descriptions
# or CSS. An SVG containing a script is executable, so include SVG.
: > "$TMP/embedded"
while IFS= read -r file; do
  [ -f "$file" ] || continue
  if grep -Ein '<script([[:space:]>])|\bon(click|load|submit|change|input|error|keydown|keyup|mouseover)[[:space:]]*=|javascript:' "$file" >/dev/null; then
    echo "$file" >> "$TMP/embedded"
  fi
done < "$TMP/web"
# Bundle archives may embed JS source despite using a non-JS extension.
grep -E -i '\.(zip|tgz|tar|gz)$' "$TMP/files" > "$TMP/archives" || true
# The build/release entrypoints cannot invoke a JS runtime.
: > "$TMP/runtime"
for file in verify.sh install.sh bin/triad bin/triad-cli .github/workflows/*.yml .github/workflows/*.yaml; do
  [ -f "$file" ] || continue
  if grep -vE '^[[:space:]]*#' "$file" | grep -Ein '(^|[[:space:];|])((node|nodejs|npm|npx|bun|deno)[[:space:]]|corepack[[:space:]])|actions/setup-node' >/dev/null; then
    echo "$file" >> "$TMP/runtime"
  fi
done
status=0
for category in code packages embedded archives runtime; do
  if [ -s "$TMP/$category" ]; then
    printf 'no-js: forbidden %s files or references:\n' "$category" >&2
    cat "$TMP/$category" >&2
    status=1
  fi
done
if [ "$status" -eq 0 ]; then
  echo "no-js: PASS (no tracked JS/TS source, npm manifests, inline scripts or Node entrypoints)"
fi
exit "$status"
