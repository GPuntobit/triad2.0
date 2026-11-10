#!/bin/sh
# TRID-012 opt-in S0/S1 bridge. Source states never modified.
# POSIX shell stages native Triad imported/projection bytes only.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
MODE=${1:-}
case "$MODE" in
  --build|--ingest|--reconcile)
    [ "$#" -eq 4 ] || { echo 'usage: unify_v1.sh --build|--ingest|--reconcile FIXTURE MEMORY GRAPH' >&2; exit 2; } ;;
  --project|--project-current)
    [ "$#" -eq 2 ] || { echo 'usage: unify_v1.sh --project|--project-current REPLAYED_V1_FILE' >&2; exit 2; } ;;
  *) echo 'usage: unify_v1.sh --build|--ingest|--reconcile FIXTURE MEMORY GRAPH | --project|--project-current V1_FILE' >&2; exit 2 ;;
esac
umask 077
TMP=$(mktemp -d)
trap 'rm -rf -- "$TMP"' EXIT
if [ "$MODE" = --project ] || [ "$MODE" = --project-current ]; then
  sh "$ROOT/cognitive/native/schema_v1.sh" "$MODE" "$2" > "$TMP/projection"
  cat "$TMP/projection"
  exit 0
fi
# These are separate source domains with disjoint stable ID prefixes.
# Importing data does not certify real-world source authenticity.
sh "$ROOT/cognitive/native/schema_v1.sh" --import-s0 "$2" > "$TMP/s0.v1"
sh "$ROOT/cognitive/native/schema_v1.sh" --import-s0-memory "$3" > "$TMP/memory.v1"
sh "$ROOT/cognitive/native/schema_s1.sh" "$4" > "$TMP/s1.v1"
cat "$TMP/s0.v1" "$TMP/memory.v1" "$TMP/s1.v1" > "$TMP/combined.v1"
sh "$ROOT/cognitive/native/schema_v1.sh" --validate-ledger "$TMP/combined.v1" > "$TMP/canonical.v1"
cmp -s "$TMP/combined.v1" "$TMP/canonical.v1" ||
  { echo 'TRID unified: noncanonical imported event batch' >&2; exit 1; }
if [ "$MODE" = --build ]; then
  cat "$TMP/canonical.v1"
elif [ "$MODE" = --reconcile ]; then
  # The ledger keeps its flock while calculating the delta; no TOCTOU window
  # between read/reconciliation and atomic commit.
  sh "$ROOT/cognitive/native/journal_v1.sh" --reconcile "$TMP/canonical.v1"
else
  sh "$ROOT/cognitive/native/journal_v1.sh" --append "$TMP/canonical.v1"
fi
