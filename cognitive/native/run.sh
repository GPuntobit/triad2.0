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
# An absent journal must not be created before successful verification.
ORIGINAL_JOURNAL="$JOURNAL"
if [ ! -e "$JOURNAL" ]; then
    ORIGINAL_JOURNAL="$TMP/empty-journal.log"
    : > "$ORIGINAL_JOURNAL"
fi
# S0 cannot reliably assign/pass a readfile result. Transport data as literals.
# Reject every byte that could escape a Triad quoted multiline string.
# Allowed: letters, digits, '_', '|' (field separator) and '-' (negative metric).
safe_records() {
    if LC_ALL=C grep '[^a-zA-Z0-9_|.-]' "$1" >/dev/null; then
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
        emit_rows "$FIXTURE" data
        case "$1" in
            */verify.triad) emit_rows "$2" history ;;
            *) emit_rows "$2" journal ;;
        esac
        cat "$ROOT/cognitive/native/common.triad" "$1"
    } > "$3"
}
# Transport validation, not inference: native Triad still verifies the journal
# checksum, rule selection, witnesses and epistemic status independently.
validate_events() {
    if ! LC_ALL=C awk -F '[|]' '
        function atom(x) { return x ~ /^[a-z][a-z0-9_]*$/ }
        function number(x) { return x ~ /^[0-9]+$/ }
        function integer(x) { return x ~ /^-?[0-9]+$/ }
        function shape(x) { return x=="chain" || x=="reverse_chain" || x=="common_source" || x=="common_target" }
        {
            if (!number($1) || !number($2) || !number($NF)) exit 1
            if ($3 == "evaluation" && NF == 15) {
                if (!atom($4) || !shape($5) || ($6!="experimental" && $6!="refuted")) exit 1
                for (i=7;i<=13;i++) if (!integer($i)) exit 1
                if ($14!="yes" && $14!="no") exit 1
            } else if ($3=="proof" && NF==11) {
                if (!atom($4) || !shape($5)) exit 1
                for (i=6;i<=10;i++) if (!atom($i)) exit 1
            } else exit 1
        }
    ' "$1"; then
        echo 'TRID: discovery emitted invalid event/diagnostic output' >&2
        exit 1
    fi
}
validate_memory() {
    if ! LC_ALL=C awk -F '[|]' '
        function atom(x) { return x ~ /^[a-z][a-z0-9_]*$/ }
        function integer(x) { return x ~ /^-?[0-9]+$/ }
        function shape(x) { return x=="chain" || x=="reverse_chain" || x=="common_source" || x=="common_target" }
        {
            if ($1=="rule" && NF==6) {
                if (!atom($2) || !shape($3) || !integer($5)) exit 1
                if ($4!="experimental" && $4!="refuted" && $4!="consolidated_conditional" && $4!="suspended_dependency") exit 1
                if ($6!="" && !atom($6)) exit 1
            } else if ($1=="claim" && NF==10) {
                if (!atom($2) || !atom($3) || !atom($4) || !shape($5)) exit 1
                for (i=6;i<=9;i++) if (!atom($i)) exit 1
                if ($10!="demonstrated_conditional" && $10!="suspended") exit 1
            } else exit 1
        }
        END { if (NR==0) exit 1 }
    ' "$1"; then
        echo 'TRID: verifier emitted invalid memory/diagnostic output' >&2
        exit 1
    fi
}

make_source "$ROOT/cognitive/native/discover.triad" "$ORIGINAL_JOURNAL" "$TMP/discover.triad"
echo "TRID native: discovery stage" >&2
if ! ( cd "$TMP"; "$ROOT/bin/triad" "$TMP/discover.triad" > "$TMP/events.log" ); then
    echo "TRID: discovery stdout before failure:" >&2
    cat "$TMP/events.log" >&2
    exit 1
fi
validate_events "$TMP/events.log"
cat "$ORIGINAL_JOURNAL" "$TMP/events.log" > "$TMP/new-journal.log"
make_source "$ROOT/cognitive/native/verify.triad" "$TMP/new-journal.log" "$TMP/verify.triad"
echo "TRID native: independent verification stage" >&2
if ! ( cd "$TMP"; "$ROOT/bin/triad" "$TMP/verify.triad" > "$TMP/new-memory.txt" ); then
    echo "TRID: verifier failed; last diagnostic/output lines:" >&2
    tail -n 40 "$TMP/new-memory.txt" >&2
    exit 1
fi
validate_memory "$TMP/new-memory.txt"
mv "$TMP/new-journal.log" "$JOURNAL"
mv "$TMP/new-memory.txt" "$MEMORY"
printf 'TRID native: memory updated; %s total events\n' "$(wc -l < "$JOURNAL" | tr -d ' ')"
