#!/bin/sh
# Linux/POSIX byte partitioner for Triad-Core native semantics.
# No rules, epistemic promotions, identities, or revisions are inferred here.
# Each bounded Triad call validates its own records; adjacent-ID and source
# revocation checks are carried across partitions through native Triad.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
SCHEMA="$ROOT/cognitive/native/schema_v1.sh"
MODE=$1
FILE=$2
OTHER=${3:-}
export LC_ALL=C TRID_SCHEMA_WINDOW=1
TMP=$(mktemp -d)
trap 'rm -rf -- "$TMP"' EXIT
die() { echo "TRID stream: $*" >&2; exit 1; }
safe_input() {
    [ -f "$1" ] && [ ! -L "$1" ] && [ -r "$1" ] ||
        die 'unsafe input path (regular file required)'
    if grep '[^a-z0-9_|,.:=-]' "$1" > /dev/null; then
        die 'unsafe input byte'
    fi
    if grep -q '^$' "$1"; then die 'empty record line'; fi
    if [ -s "$1" ]; then
        last=$(tail -c 1 "$1" | od -An -tu1 | tr -d ' \n')
        [ "$last" = 10 ] || die 'truncated final record'
    fi
}
safe_input "$FILE"
[ -z "$OTHER" ] || safe_input "$OTHER"
if [ "$MODE" != --delta ] && [ ! -s "$FILE" ]; then
    die 'empty input'
fi
# GNU split -C preserves complete lines (record never exceeds 5000 bytes).
# A too-large row will be rejected by the original native field validator.
partition() {
    mkdir "$2"
    [ -s "$1" ] || return 0
    split -C "$3" -d -a 6 "$1" "$2/row."
}
native_chunks() {
    input=$1; action=$2; output=$3
    part="$TMP/native.$4"
    partition "$input" "$part" 5000
    : > "$output"
    for piece in "$part"/row.*; do
        [ -f "$piece" ] || continue
        sh "$SCHEMA" "$action" "$piece" >> "$output"
    done
}
# This indexes by the literal identity field only. The native pair gate
# performs the actual revision/kind/domain/identity-consistency decisions.
check_pairs() {
    input=$1
    action=$2
    LC_ALL=C sort -s -t '|' -k3,3 "$input" > "$TMP/sorted"
    rm -rf -- "$TMP/pairs"
    mkdir "$TMP/pairs"
    if ! awk -F '|' -v out="$TMP/pairs/pair." '
        NR > 1 && $3 == previous_id {
            pair=previous_line "\n" $0 "\n"
            if (length(pair) > 5000) exit 2
            if (size + length(pair) > 5000) { bucket++; size=0 }
            filename=out sprintf("%06d",bucket)
            printf "%s",pair >> filename
            size+=length(pair)
        }
        { previous_id=$3; previous_line=$0 }
    ' "$TMP/sorted"; then
        die 'identity pair exceeds bounded native window'
    fi
    for pair in "$TMP/pairs"/pair.*; do
        [ -f "$pair" ] || continue
        sh "$SCHEMA" "$action" "$pair" > "$TMP/pairs.out"
        [ ! -s "$TMP/pairs.out" ] || die 'unexpected native pair output'
    done
}
validate_history() {
    input=$1; ordered=$2; name=$3
    [ -s "$input" ] || return 0
    native_chunks "$input" --validate "$TMP/canon.$name" "validate.$name"
    cmp -s "$input" "$TMP/canon.$name" || die 'noncanonical native record window'
    if [ "$ordered" = 1 ]; then
        check_pairs "$input" --pairs-ordered
    else
        check_pairs "$input" --pairs-unique
    fi
}
case "$MODE" in
    --validate)
        validate_history "$FILE" 0 input
        cat "$FILE" ;;
    --validate-ledger)
        validate_history "$FILE" 1 input
        cat "$FILE" ;;
    --identity)
        validate_history "$FILE" 1 input
        native_chunks "$FILE" --identity "$TMP/keys" "identity"
        [ "$(wc -l < "$TMP/keys")" -eq "$(wc -l < "$FILE")" ] ||
            die 'native identity count mismatch'
        LC_ALL=C sort "$TMP/keys" | uniq -d > "$TMP/ambiguous"
        [ ! -s "$TMP/ambiguous" ] || die 'duplicate native identity in snapshot'
        cat "$TMP/keys" ;;
    --delta)
        [ -n "$OTHER" ] && [ -s "$OTHER" ] || die 'empty delta candidate'
        validate_history "$FILE" 1 history
        validate_history "$OTHER" 1 candidates
        # Prior position-based imports cannot be silently reconciled.
        partition "$FILE" "$TMP/old-managed" 5000
        for piece in "$TMP/old-managed"/row.*; do
            [ -f "$piece" ] || continue
            sh "$SCHEMA" --validate-managed "$piece" > "$TMP/managed.out"
            [ ! -s "$TMP/managed.out" ] || die 'unexpected native managed output'
        done
        # Stable sort + last-row index materialize ONLY the latest old row
        # for each literal ID. Native Triad has already certified monotonicity.
        if [ -s "$FILE" ]; then
            LC_ALL=C sort -s -t '|' -k3,3 "$FILE" |
            awk -F '|' '
              NR>1 && $3 != lastid {print lastrow}
              {lastid=$3;lastrow=$0}
              END {if(NR) print lastrow}
            ' > "$TMP/latest"
        else
            : > "$TMP/latest"
        fi
        : > "$TMP/batch.old"
        : > "$TMP/batch.new"
        : > "$TMP/result"
        size=0
        flush_delta() {
            [ -s "$TMP/batch.new" ] || return 0
            sh "$SCHEMA" --delta "$TMP/batch.old" "$TMP/batch.new" >> "$TMP/result"
            : > "$TMP/batch.old"
            : > "$TMP/batch.new"
            size=0
        }
        while IFS= read -r row || [ -n "$row" ]; do
            id=$(printf '%s\n' "$row" | cut -d '|' -f3)
            previous=$(awk -F '|' -v wanted="$id" '$3 == wanted {print; exit}' "$TMP/latest")
            needed=$(($(printf '%s' "$row" | wc -c) + $(printf '%s' "$previous" | wc -c) + 2))
            [ "$needed" -le 4500 ] || die 'single identity comparison exceeds native window'
            if [ $((size + needed)) -gt 4500 ]; then flush_delta; fi
            printf '%s\n' "$row" >> "$TMP/batch.new"
            if [ -n "$previous" ]; then printf '%s\n' "$previous" >> "$TMP/batch.old"; fi
            size=$((size + needed))
        done < "$OTHER"
        flush_delta
        if [ -s "$TMP/result" ]; then
            cat "$FILE" "$TMP/result" > "$TMP/proposed"
            validate_history "$TMP/proposed" 1 proposed
        fi
        cat "$TMP/result" ;;
    --project|--project-current)
        validate_history "$FILE" 1 projected
        input="$FILE"
        if [ "$MODE" = --project-current ]; then
            # Last per-id position selection is byte indexing, not inference.
            awk -F '|' '{ print $3 "|" NR "|" $0 }' "$FILE" |
              LC_ALL=C sort -s -t '|' -k1,1 -k2,2n |
              awk -F '|' '
                NR>1 && $1 != id {print previous}
                {id=$1;previous=$0}
                END {if(NR) print previous}
              ' |
              LC_ALL=C sort -t '|' -k2,2n | cut -d '|' -f3- > "$TMP/current"
            input="$TMP/current"
        fi
        # Revocation routing is just an input-kind byte index. Native
        # projection_status decides whether each dependency is suspended.
        awk -F '|' '$2 == "revocation" {print}' "$FILE" > "$TMP/revocations"
        partition "$input" "$TMP/records" 3200
        partition "$TMP/revocations" "$TMP/revs" 3200
        : > "$TMP/projection"
        for rec in "$TMP/records"/row.*; do
            [ -f "$rec" ] || continue
            sh "$SCHEMA" --project-start "$rec" > "$TMP/status"
            for rev in "$TMP/revs"/row.*; do
                [ -f "$rev" ] || continue
                sh "$SCHEMA" --project-fold "$rec" "$rev" "$TMP/status" > "$TMP/updated"
                mv "$TMP/updated" "$TMP/status"
            done
            sh "$SCHEMA" --project-finish "$rec" "$TMP/status" >> "$TMP/projection"
        done
        cat "$TMP/projection" ;;
    *) die "unsupported streaming mode $MODE" ;;
esac
