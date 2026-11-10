#!/bin/sh
# TRID-011 event ledger: Linux transport only; native Triad validates semantics.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
MODE=${1:-}
INPUT=${2:-}
case "$MODE" in
  --append|--reconcile) [ "$#" -eq 2 ] || { echo 'usage: journal_v1.sh --append|--reconcile FILE' >&2; exit 2; };;
  --verify|--replay|--recover)
    [ "$#" -eq 1 ] || { echo 'usage: journal_v1.sh --verify|--replay|--recover' >&2; exit 2; };;
  *) echo 'usage: journal_v1.sh --append|--reconcile FILE | --verify | --replay | --recover' >&2; exit 2 ;;
esac
STATE=${TRID_EVENT_STATE_DIR:-"$HOME/.local/state/trid-events"}
umask 077
[ ! -L "$STATE" ] || { echo 'TRID ledger: unsafe state symlink' >&2; exit 1; }
mkdir -p "$STATE"
STATE=$(CDPATH= cd -- "$STATE" && pwd)
[ ! -L "$STATE/.mutex" ] || { echo 'TRID ledger: unsafe lock symlink' >&2; exit 1; }
exec 9>> "$STATE/.mutex"
if ! flock -n 9; then echo 'TRID ledger: state locked' >&2; exit 1; fi
TMP=$(mktemp -d "$STATE/.work.XXXXXXXX")
trap 'rm -rf -- "$TMP"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
export LC_ALL=C
die() { echo "TRID ledger: $*" >&2; exit 1; }
id_ok() { printf '%s\n' "$1" | grep -Eq '^r[0-9]{8}$'; }
hash_ok() { printf '%s\n' "$1" | grep -Eq '^[a-f0-9]{64}$'; }
ZERO=0000000000000000000000000000000000000000000000000000000000000000
[ ! -L "$STATE/.revisions" ] || die 'unsafe revisions directory symlink'
mkdir -p "$STATE/.revisions"
ACTIVE=""
if [ -L "$STATE/.current" ]; then
  tgt=$(readlink "$STATE/.current")
  case "$tgt" in .revisions/*) ACTIVE=${tgt##*/} ;; *) die 'unsafe current pointer' ;; esac
  id_ok "$ACTIVE" || die 'invalid revision id'
  [ "$tgt" = ".revisions/$ACTIVE" ] || die 'invalid pointer target'
elif [ -e "$STATE/.current" ]; then
  die 'current pointer is not a symlink'
fi
SOURCE=""
if [ -n "$ACTIVE" ]; then
  DIR="$STATE/.revisions/$ACTIVE"
  [ -d "$DIR" ] && [ ! -L "$DIR" ] || die 'missing committed directory'
  [ -f "$DIR/events.log" ] && [ ! -L "$DIR/events.log" ] || die 'invalid events file'
  [ -f "$DIR/checksums.sha256" ] && [ ! -L "$DIR/checksums.sha256" ] || die 'invalid checksum file'
  expected=$(cd "$DIR" && sha256sum events.log)
  recorded=$(cat "$DIR/checksums.sha256")
  [ "$expected" = "$recorded" ] || die 'committed checksum mismatch'
  SOURCE="$DIR/events.log"
fi
# Reconstruct the logical stream and verify sequence, predecessors, and digests.
: > "$TMP/rows.v1"
n=0
last=$ZERO
if [ -n "$SOURCE" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in *'|'*'|'*'|'*) ;; *) die 'malformed chain record' ;; esac
    seq=${line%%|*}
    rest=${line#*|}
    before=${rest%%|*}
    rest=${rest#*|}
    digest=${rest%%|*}
    record=${rest#*|}
    n=$((n + 1))
    [ "$seq" = "$n" ] || die 'event sequence gap'
    [ "$before" = "$last" ] || die 'predecessor hash mismatch'
    hash_ok "$digest" || die 'invalid event SHA-256 format'
    actual=$(printf '%s\n' "$seq|$before|$record" | sha256sum | cut -d ' ' -f1)
    [ "$actual" = "$digest" ] || die 'event SHA-256 mismatch'
    printf '%s\n' "$record" >> "$TMP/rows.v1"
    last=$digest
  done < "$SOURCE"
  if [ -s "$SOURCE" ]; then
    endbyte=$(tail -c 1 "$SOURCE" | od -An -tu1 | tr -d ' \n')
    [ "$endbyte" = 10 ] || die 'incomplete trailing event'
  fi
fi
if [ -s "$TMP/rows.v1" ]; then
    if ! sh "$ROOT/cognitive/native/schema_v1.sh" --validate-ledger "$TMP/rows.v1" > "$TMP/checked.v1"; then
    die 'native replay schema validation failed'
  fi
  cmp -s "$TMP/rows.v1" "$TMP/checked.v1" || die 'noncanonical committed events'
fi
case "$MODE" in
  --verify) printf 'TRID ledger: verified %s events\n' "$n" >&2; exit 0 ;;
  --replay) cat "$TMP/rows.v1"; exit 0 ;;
  --recover)
    # Keep orphan committed-generation candidates for forensic inspection.
    find "$STATE" -mindepth 1 -maxdepth 1 -type d -name '.work.*' \
      ! -path "$TMP" -exec rm -rf -- {} +
    printf 'TRID ledger: recovered %s events\n' "$n" >&2
    exit 0 ;;
esac
[ -f "$INPUT" ] && [ -r "$INPUT" ] && [ ! -L "$INPUT" ] || die 'invalid append file'
[ -s "$INPUT" ] || die 'empty append batch'
if [ "$MODE" = --reconcile ]; then
  # Under the SAME journal flock, compute a native-checked delta from the
  # current verified history. No read/commit race can lose a concurrent edit.
  sh "$ROOT/cognitive/native/normalize_v1.sh" "$INPUT" > "$TMP/stable.v1"
  if ! sh "$ROOT/cognitive/native/schema_v1.sh" --delta "$TMP/rows.v1" "$TMP/stable.v1" > "$TMP/delta.v1"; then
    die 'native incremental reconciliation rejected snapshot'
  fi
  if [ ! -s "$TMP/delta.v1" ]; then
    printf 'TRID ledger: no changes; revision pointer unchanged\n' >&2
    exit 0
  fi
  INPUT="$TMP/delta.v1"
fi
cat "$TMP/rows.v1" "$INPUT" > "$TMP/complete.v1"
if ! sh "$ROOT/cognitive/native/schema_v1.sh" --validate-ledger "$TMP/complete.v1" > "$TMP/canonical.v1"; then
  die 'native validation rejected proposed history'
fi
cmp -s "$TMP/complete.v1" "$TMP/canonical.v1" || die 'noncanonical proposed history'
# Every old byte is retained: new revision differs only by an appended suffix.
mkdir "$TMP/stage"
if [ -n "$SOURCE" ]; then cp "$SOURCE" "$TMP/stage/events.log"; else : > "$TMP/stage/events.log"; fi
while IFS= read -r record || [ -n "$record" ]; do
  n=$((n + 1))
  [ "$n" -le 1000 ] || die 'bounded event count exceeded'
  digest=$(printf '%s\n' "$n|$last|$record" | sha256sum | cut -d ' ' -f1)
  printf '%s|%s|%s|%s\n' "$n" "$last" "$digest" "$record" >> "$TMP/stage/events.log"
  last=$digest
done < "$INPUT"
(cd "$TMP/stage" && sha256sum events.log > checksums.sha256)
sync -f "$TMP/stage/events.log" "$TMP/stage/checksums.sha256"
sync -f "$TMP/stage"
if [ "${TRID_TEST_LEDGER_CRASH_AT:-}" = after_stage ]; then kill -KILL "$$"; fi
next=1
if [ -n "$ACTIVE" ]; then
  decimal=$(printf '%s\n' "$ACTIVE" | sed 's/^r0*//')
  [ -n "$decimal" ] || decimal=0
  next=$((decimal + 1))
fi
while :; do
  [ "$next" -le 99999999 ] || die 'revision counter exhausted'
  candidate=$(printf 'r%08d' "$next")
  [ ! -e "$STATE/.revisions/$candidate" ] && [ ! -L "$STATE/.revisions/$candidate" ] && break
  next=$((next + 1))
done
mv "$TMP/stage" "$STATE/.revisions/$candidate"
sync -f "$STATE/.revisions"
if [ "${TRID_TEST_LEDGER_CRASH_AT:-}" = before_pointer ]; then kill -KILL "$$"; fi
ln -s ".revisions/$candidate" "$TMP/new-current"
mv -Tf "$TMP/new-current" "$STATE/.current"
sync -f "$STATE"
if [ "${TRID_TEST_LEDGER_CRASH_AT:-}" = after_pointer ]; then kill -KILL "$$"; fi
printf 'TRID ledger: committed %s events as %s\n' "$n" "$candidate" >&2
