#!/bin/sh
# POSIX filesystem transport only. All cognitive decisions in Triad-Core.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
FIXTURE=${1:-"$ROOT/cognitive/native/fixture.txt"}
STATE=${TRID_STATE_DIR:-"$HOME/.local/state/trid-native"}
umask 077
mkdir -p "$STATE"
STATE=$(CDPATH= cd -- "$STATE" && pwd)
if ! mkdir "$STATE/.lock" 2>/dev/null; then
    echo 'TRID: another session is running (or stale lock)' >&2
    exit 1
fi
TMP="$STATE/.lock"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
[ -r "$FIXTURE" ] || { echo 'TRID: fixture cannot be read' >&2; exit 1; }
JOURNAL="$STATE/hypotheses.log"
MEMORY="$STATE/memory.txt"
[ -e "$JOURNAL" ] || : > "$JOURNAL"
cat "$ROOT/cognitive/native/common.triad" "$ROOT/cognitive/native/discover.triad" > "$TMP/discover.triad"
cat "$ROOT/cognitive/native/common.triad" "$ROOT/cognitive/native/verify.triad" > "$TMP/verify.triad"
cp "$FIXTURE" "$TMP/fixture.txt"
cp "$JOURNAL" "$TMP/journal.log"
echo "TRID native: discovery stage" >&2
( cd "$TMP"; "$ROOT/bin/triad" "$TMP/discover.triad" > "$TMP/events.log" )
cat "$TMP/journal.log" "$TMP/events.log" > "$TMP/new-journal.log"
cp "$TMP/new-journal.log" "$TMP/journal.log"
echo "TRID native: independent verification stage" >&2
( cd "$TMP"; "$ROOT/bin/triad" "$TMP/verify.triad" > "$TMP/new-memory.txt" )
mv "$TMP/new-journal.log" "$JOURNAL"
mv "$TMP/new-memory.txt" "$MEMORY"
printf 'TRID native: memory updated; %s total events\n' "$(wc -l < "$JOURNAL" | tr -d ' ')"
