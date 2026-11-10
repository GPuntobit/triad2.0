#!/bin/sh
# POSIX byte transport only; validation, semantics and migration run in Triad.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
[ "$#" -eq 2 ] || { echo 'usage: schema_v1.sh --validate|--validate-ledger|--import-s0|--import-s0-memory|--project FILE' >&2; exit 2; }
MODE=$1
FILE=$2
case "$MODE" in --validate|--validate-ledger|--import-s0|--import-s0-memory|--project) ;; *) echo 'TRID schema: unknown mode' >&2; exit 2 ;; esac
[ -f "$FILE" ] && [ -r "$FILE" ] || { echo 'TRID schema: input not readable' >&2; exit 2; }
[ ! -L "$FILE" ] || { echo 'TRID schema: symlink input forbidden' >&2; exit 2; }
export LC_ALL=C
SIZE=$(wc -c < "$FILE")
[ "$SIZE" -le 12000 ] && [ "$SIZE" -gt 0 ] ||
    { echo 'TRID schema: input size limit 1..12000 bytes' >&2; exit 2; }
if grep '[^a-z0-9_|,.:=-]' "$FILE" >/dev/null; then
    echo 'TRID schema: rejected unsafe input bytes' >&2
    exit 2
fi
if grep -q '^$' "$FILE"; then
    echo 'TRID schema: empty rows are forbidden' >&2
    exit 2
fi
# Line-oriented serialization only; never eval, source, or run input as shell.
emit_rows() {
    printf 'schema_rows = []\n'
    while IFS= read -r line || [ -n "$line" ]; do
        printf 'push!(schema_rows, ["'
        printf '%s' "$line" | sed 's/|/", "/g'
        printf '"])\n'
    done < "$FILE"
}
TMP=$(mktemp -d)
trap 'rm -rf -- "$TMP"' EXIT
{
    emit_rows
    cat "$ROOT/cognitive/native/common.triad"
    cat "$ROOT/cognitive/native/schema_v1.triad"
    case "$MODE" in
        --validate) printf 'schema_emit(schema_rows)\n' ;;
        --validate-ledger) printf 'schema_emit_ledger(schema_rows)\n' ;;
        --import-s0) printf 'schema_import_s0(schema_rows)\n' ;;
        --import-s0-memory)
            cat "$ROOT/cognitive/native/schema_import_memory.triad"
            printf 'schema_import_s0_memory(schema_rows)\n' ;;
        --project)
            cat "$ROOT/cognitive/native/schema_project.triad"
            printf 'schema_project(schema_rows)\n' ;;
    esac
} > "$TMP/schema.triad"
if ! "$ROOT/bin/triad" "$TMP/schema.triad" > "$TMP/validated.out" 2> "$TMP/diagnostics.err"; then
    echo 'TRID schema: native validation failed (no records published)' >&2
    cat "$TMP/diagnostics.err" >&2
    exit 1
fi
cat "$TMP/validated.out"
