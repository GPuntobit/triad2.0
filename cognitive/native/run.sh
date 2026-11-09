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
# S0 cannot reliably assign/pass a readfile result. Transport data as literals.
# Reject every byte that could escape a Triad quoted multiline string.
safe_records() {
    if LC_ALL=C grep '[^a-zA-Z0-9_|]' "$1" >/dev/null; then
        echo "TRID: unsafe input bytes in $1" >&2
        exit 1
    fi
}
# Convert validated pipe-separated records to native Triad List literals.
# Shell performs only serialization; all induction and checking are Triad code.
emit_rows() {
    path="$1"
    variable="$2"
    printf '%s = []\n' "$variable"
    while IFS= read -r line || [ -n "$line" ]; do
        [ -n "$line" ] || continue
        printf 'push!(%s, ["' "$variable"
        printf '%s' "$line" | sed 's/|/", "/g'
        printf '"])\n'
    done < "$path"
}
make_source() {
    safe_records "$FIXTURE"
    safe_records "$2"
    {
        emit_rows "$FIXTURE" trid_data
        emit_rows "$2" trid_history
        cat "$ROOT/cognitive/native/common.triad" "$1"
    } > "$3"
}
make_source "$ROOT/cognitive/native/discover.triad" "$JOURNAL" "$TMP/discover.triad"
echo "TRID native: discovery stage" >&2
if ! ( cd "$TMP"; "$ROOT/bin/triad" "$TMP/discover.triad" > "$TMP/events.log" ); then
    echo "TRID: discovery stdout before failure:" >&2
    cat "$TMP/events.log" >&2
    exit 1
fi
cat "$JOURNAL" "$TMP/events.log" > "$TMP/new-journal.log"
make_source "$ROOT/cognitive/native/verify.triad" "$TMP/new-journal.log" "$TMP/verify.triad"
echo "TRID native: independent verification stage" >&2
( cd "$TMP"; "$ROOT/bin/triad" "$TMP/verify.triad" > "$TMP/new-memory.txt" )
mv "$TMP/new-journal.log" "$JOURNAL"
mv "$TMP/new-memory.txt" "$MEMORY"
printf 'TRID native: memory updated; %s total events\n' "$(wc -l < "$JOURNAL" | tr -d ' ')"
