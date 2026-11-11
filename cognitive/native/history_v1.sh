#!/bin/sh
# TRID-015: historical read-only memory snapshots and deterministic diffs.
# The journal validates event history; native Triad computes effective state.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
MODE=${1:-}
case "$MODE" in
  --as-of)
    [ "$#" -eq 2 ] || { echo 'usage: history_v1.sh --as-of rNNNNNNNN' >&2; exit 2; };;
  --diff)
    [ "$#" -eq 3 ] || { echo 'usage: history_v1.sh --diff rNNNNNNNN rNNNNNNNN' >&2; exit 2; };;
  *)
    echo 'usage: history_v1.sh --as-of rNNNNNNNN | --diff rNNNNNNNN rNNNNNNNN' >&2
    exit 2;;
esac
umask 077
export LC_ALL=C
TMP=$(mktemp -d)
trap 'rm -rf -- "$TMP"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
snapshot() {
  revision=$1
  prefix=$2
  # These commands publish no stdout before full validation succeeds.
  sh "$ROOT/cognitive/native/journal_v1.sh" --replay-revision "$revision" > "$prefix.events"
  if [ -s "$prefix.events" ]; then
    sh "$ROOT/cognitive/native/unify_v1.sh" --project-current "$prefix.events" > "$prefix.view"
  else
    : > "$prefix.view"
  fi
}
if [ "$MODE" = --as-of ]; then
  snapshot "$2" "$TMP/at"
  cat "$TMP/at.view"
  exit 0
fi
snapshot "$2" "$TMP/left"
snapshot "$3" "$TMP/right"
# Diff the native views without asserting worldly truth or deleting history.
# Exit 1 from diff means "different", not a query failure.
if diff -u --label "revision/$2" --label "revision/$3" \
  "$TMP/left.view" "$TMP/right.view" > "$TMP/changes"; then
  :
else
  status=$?
  [ "$status" -eq 1 ] || exit "$status"
fi
cat "$TMP/changes"
