#!/bin/sh
# POSIX byte transport only; validation, semantics and migration run in Triad.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
MODE=${1:-}
case "$MODE" in
  --validate|--validate-ledger|--import-s0|--import-s0-memory|--project|--project-current|--identity|--pairs-ordered|--pairs-unique|--validate-managed|--project-start)
    [ "$#" -eq 2 ] || { echo 'usage: schema_v1.sh MODE FILE' >&2; exit 2; }
    FILE=$2 ;;
  --delta|--project-finish)
    [ "$#" -eq 3 ] || { echo 'usage: schema_v1.sh MODE FILE SECOND' >&2; exit 2; }
    FILE=$2; OTHER=$3 ;;
  --project-fold)
    [ "$#" -eq 4 ] || { echo 'usage: schema_v1.sh --project-fold RECORDS REVOCATIONS STATES' >&2; exit 2; }
    FILE=$2; OTHER=$3; THIRD=$4 ;;
  *) echo 'usage: schema_v1.sh --validate|--validate-ledger|--identity|--delta|--import-s0|--import-s0-memory|--project|--project-current FILE [OTHER]' >&2; exit 2 ;;
esac
# The public modes switch to bounded native windows for large files.
# Internal calls from the stream driver set TRID_SCHEMA_WINDOW=1.
if [ "${TRID_SCHEMA_WINDOW:-0}" != 1 ]; then
  case "$MODE" in
    --validate|--validate-ledger|--identity|--delta|--project|--project-current)
      if [ -f "$FILE" ]; then
        first=$(wc -c < "$FILE")
        second=0
        if [ "$MODE" = --delta ] && [ -f "$OTHER" ]; then
          second=$(wc -c < "$OTHER")
        fi
        if [ "$first" -gt 7000 ] || [ "$second" -gt 7000 ] ||
           [ $((first + second)) -gt 7000 ]; then
          exec sh "$ROOT/cognitive/native/schema_v1_stream.sh" "$@"
        fi
      fi ;;
  esac
fi
export LC_ALL=C
# Validate byte transport before injecting any data into native Triad source.
# The old ledger may be empty only on first-time reconciliation.
for path in "$FILE" ${OTHER:+"$OTHER"} ${THIRD:+"$THIRD"}; do
    [ -f "$path" ] && [ -r "$path" ] && [ ! -L "$path" ] ||
      { echo 'TRID schema: input not a readable regular file' >&2; exit 2; }
    size=$(wc -c < "$path")
    [ "$size" -le 12000 ] ||
      { echo 'TRID schema: input exceeds 12000 bytes' >&2; exit 2; }
    if [ "$size" -eq 0 ]; then
      if [ "$MODE" != --delta ] || [ "$path" != "$FILE" ]; then
        echo 'TRID schema: empty input is forbidden' >&2
        exit 2
      fi
    fi
    if grep '[^a-z0-9_|,.:=-]' "$path" >/dev/null; then
      echo 'TRID schema: rejected unsafe input bytes' >&2
      exit 2
    fi
    if grep -q '^$' "$path"; then
      echo 'TRID schema: empty rows are forbidden' >&2
      exit 2
    fi
    if [ "$size" -gt 0 ]; then
      final=$(tail -c 1 "$path" | od -An -tu1 | tr -d ' \n')
      [ "$final" = 10 ] ||
        { echo 'TRID schema: unterminated input row' >&2; exit 2; }
    fi
done
# Per-window size only; no whole-ledger or whole-snapshot byte cap.
# The window driver never asks this process to parse more than 7 KiB.
if [ "${TRID_SCHEMA_WINDOW:-0}" = 1 ]; then
  total=$(( $(wc -c < "$FILE") + $(test -z "${OTHER:-}" || wc -c < "$OTHER") + $(test -z "${THIRD:-}" || wc -c < "$THIRD") ))
  [ "$total" -le 8000 ] ||
    { echo 'TRID schema: native window budget exceeded' >&2; exit 2; }
fi
# Line-oriented serialization only; never eval, source, or run input as shell.
emit_rows() {
    path_in=$1
    variable=$2
    printf '%s = []\n' "$variable"
    while IFS= read -r line || [ -n "$line" ]; do
        printf 'push!(%s, ["' "$variable"
        printf '%s' "$line" | sed 's/|/", "/g'
        printf '"])\n'
    done < "$path_in"
}
TMP=$(mktemp -d)
trap 'rm -rf -- "$TMP"' EXIT
{
    if [ "$MODE" = --delta ]; then
        emit_rows "$FILE" history_rows
        emit_rows "$OTHER" candidate_rows
    else
        emit_rows "$FILE" schema_rows
        if [ "$MODE" = --project-fold ]; then
            emit_rows "$OTHER" revocation_rows
            emit_rows "$THIRD" status_rows
        elif [ "$MODE" = --project-finish ]; then
            emit_rows "$OTHER" status_rows
        fi
    fi
    cat "$ROOT/cognitive/native/common.triad"
    cat "$ROOT/cognitive/native/schema_v1.triad"
    case "$MODE" in
        --validate-managed)
            cat "$ROOT/cognitive/native/schema_identity.triad" "$ROOT/cognitive/native/schema_reconcile.triad"
            printf 'reconcile_check_managed(schema_rows)\n' ;;
        --pairs-ordered|--pairs-unique)
            cat "$ROOT/cognitive/native/schema_identity.triad" "$ROOT/cognitive/native/schema_pairs.triad"
            if [ "$MODE" = --pairs-ordered ]; then
                printf 'schema_pair_gate(schema_rows, true)\n'
            else
                printf 'schema_pair_gate(schema_rows, false)\n'
            fi ;;
        --project-start)
            cat "$ROOT/cognitive/native/schema_project.triad" "$ROOT/cognitive/native/schema_projection_stream.triad"
            printf 'projection_stream_begin(schema_rows)\n' ;;
        --project-fold)
            cat "$ROOT/cognitive/native/schema_project.triad" "$ROOT/cognitive/native/schema_projection_stream.triad"
            printf 'projection_stream_fold(schema_rows, revocation_rows, status_rows)\n' ;;
        --project-finish)
            cat "$ROOT/cognitive/native/schema_project.triad" "$ROOT/cognitive/native/schema_projection_stream.triad"
            printf 'projection_stream_finish(schema_rows, status_rows)\n' ;;
        --validate) printf 'schema_emit(schema_rows)\n' ;;
        --identity)
            cat "$ROOT/cognitive/native/schema_identity.triad"
            printf 'identity_emit_snapshot(schema_rows)\n' ;;
        --delta)
            cat "$ROOT/cognitive/native/schema_identity.triad" "$ROOT/cognitive/native/schema_reconcile.triad"
            printf 'reconcile_delta(history_rows, candidate_rows)\n' ;;
        --validate-ledger) printf 'schema_emit_ledger(schema_rows)\n' ;;
        --import-s0) printf 'schema_import_s0(schema_rows)\n' ;;
        --import-s0-memory)
            cat "$ROOT/cognitive/native/schema_import_memory.triad"
            printf 'schema_import_s0_memory(schema_rows)\n' ;;
        --project)
            cat "$ROOT/cognitive/native/schema_project.triad"
            printf 'schema_project(schema_rows)\n' ;;
        --project-current)
            cat "$ROOT/cognitive/native/schema_project.triad"
            printf 'schema_project_current(schema_rows)\n' ;;
    esac
} > "$TMP/schema.triad"
if ! "$ROOT/bin/triad" "$TMP/schema.triad" > "$TMP/validated.out" 2> "$TMP/diagnostics.err"; then
    echo 'TRID schema: native validation failed (no records published)' >&2
    cat "$TMP/diagnostics.err" >&2
    exit 1
fi
cat "$TMP/validated.out"
