#!/bin/sh
# TRID-013 deterministic identity normalization (Linux byte transport only).
# Native Triad selects natural keys and rejects ambiguous source snapshots.
# The shell hashes those keys into versioned schema-safe IDs; no inference here.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
[ "$#" -eq 1 ] || { echo 'usage: normalize_v1.sh IMPORTED_SNAPSHOT.v1' >&2; exit 2; }
SOURCE=$1
[ -f "$SOURCE" ] && [ -r "$SOURCE" ] && [ ! -L "$SOURCE" ] ||
    { echo 'TRID identity: expected a readable regular snapshot file' >&2; exit 2; }
export LC_ALL=C
TMP=$(mktemp -d)
trap 'rm -rf -- "$TMP"' EXIT
sh "$ROOT/cognitive/native/schema_v1.sh" --identity "$SOURCE" > "$TMP/keys"
# The keys are selected by native Triad. SHA-256 is only byte identity
# transport; keep one alphabetic prefix plus 40 hex digits (160 bits).
[ "$(wc -l < "$TMP/keys")" -eq "$(wc -l < "$SOURCE")" ] ||
    { echo 'TRID identity: native key count mismatch' >&2; exit 1; }
exec 8< "$TMP/keys"
: > "$TMP/normalized.v1"
while IFS= read -r line || [ -n "$line" ]; do
    if ! IFS= read -r key <&8; then
        echo 'TRID identity: missing native identity key' >&2
        exit 1
    fi
    [ -n "$key" ] || { echo 'TRID identity: empty key' >&2; exit 1; }
    digest=$(printf '%s\n' "$key" | sha256sum | cut -d ' ' -f1 | cut -c1-40)
    id="k$digest"
    printf '%s\n' "$line" |
      awk -F '[|]' -v id="$id" '
        BEGIN { OFS="|" }
        NF == 12 { $3=id; $7="1"; print; next }
        { exit 1 }
      ' >> "$TMP/normalized.v1"
done < "$SOURCE"
# Normalize order, never sort. Check schema and all canonical bytes before
# making a single validated snapshot visible to downstream consumers.
if [ "${TRID_DIAG_SIZE:-0}" = 1 ]; then
  printf 'TRID-013 full fixture normalized_bytes=%s\n' "$(wc -c < "$TMP/normalized.v1" | tr -d ' ')" >&2
fi
sh "$ROOT/cognitive/native/schema_v1.sh" --validate-ledger "$TMP/normalized.v1" > "$TMP/checked.v1"
cmp -s "$TMP/normalized.v1" "$TMP/checked.v1" ||
    { echo 'TRID identity: normalized output is not canonical' >&2; exit 1; }
cat "$TMP/checked.v1"
