#!/bin/sh
# Strict S1 fact-string transport. Native Triad parses the graph predicates.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
[ "$#" -eq 1 ] || { echo 'usage: schema_s1.sh GRAPH.facts' >&2; exit 2; }
GRAPH=$1
[ -f "$GRAPH" ] && [ -r "$GRAPH" ] && [ ! -L "$GRAPH" ] ||
  { echo 'TRID S1 import: input must be a regular readable file' >&2; exit 2; }
export LC_ALL=C
size=$(wc -c < "$GRAPH")
[ "$size" -gt 0 ] && [ "$size" -le 16000 ] ||
  { echo 'TRID S1 import: graph exceeds bounded input limit' >&2; exit 2; }
TMP=$(mktemp -d)
trap 'rm -rf -- "$TMP"' EXIT
# Match only the exact S1 source grammar already recognized by run_06.sh.
if grep -v -E '^(#[ a-zA-Z0-9.,:_-]+|fact evidence\(:[a-z][a-z0-9_]*, :[a-z][a-z0-9_]*, :[a-z][a-z0-9_]*\)|fact association\(:[a-z][a-z0-9_]*, :[a-z][a-z0-9_]*\)|fact revoked\(:[a-z][a-z0-9_]*\)|fact rule_state\(:[a-z][a-z0-9_]*, :(experimental|refuted|consolidated_conditional)\)|)$' "$GRAPH" > "$TMP/rejected"; then
  if [ -s "$TMP/rejected" ]; then
    echo 'TRID S1 import: rejected invalid or executable graph line' >&2
    exit 2
  fi
fi
{
  printf 'graph_lines = []\n'
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      'fact '*)
        printf 'push!(graph_lines, "'
        printf '%s' "$line"
        printf '")\n' ;;
    esac
  done < "$GRAPH"
  cat "$ROOT/cognitive/native/common.triad"
  cat "$ROOT/cognitive/native/schema_v1.triad"
  cat "$ROOT/cognitive/native/schema_import_s1.triad"
  printf 'schema_import_s1(graph_lines)\n'
} > "$TMP/import.triad"
if ! "$ROOT/bin/triad" "$TMP/import.triad" > "$TMP/validated.out" 2> "$TMP/errors"; then
  echo 'TRID S1 import: native source validation failed' >&2
  cat "$TMP/errors" >&2
  exit 1
fi
[ -s "$TMP/validated.out" ] ||
  { echo 'TRID S1 import: empty graph data' >&2; exit 1; }
cat "$TMP/validated.out"
