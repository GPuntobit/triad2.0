#!/bin/sh
# TRID-005 Linux filesystem transport, not cognitive reasoning.
# Requires flock, sha256sum, GNU mv -T, sync -f.
store_die() { echo "TRID state: $*" >&2; exit 1; }
store_id_ok() { printf '%s\n' "$1" | LC_ALL=C grep -Eq '^r[0-9]{8}$'; }
store_check() (
  cd "$1" || exit 1
  for f in hypotheses.log memory.txt checksums.sha256; do
    [ -f "$f" ] && [ ! -L "$f" ] || exit 1
  done
  [ "$(wc -l < checksums.sha256)" -eq 2 ] || exit 1
  sha256sum --status -c checksums.sha256
)
store_dirs() {
  for d in "$STATE/.revisions" "$STATE/.backups"; do
    [ ! -L "$d" ] || store_die "unsafe directory symlink"
    mkdir -p "$d"
  done
}
store_active() {
  ACTIVE_ID=""
  ACTIVE_DIR=""
  if [ -L "$STATE/.current" ]; then
    tgt=$(readlink "$STATE/.current")
    case "$tgt" in .revisions/*) ACTIVE_ID=$(basename "$tgt");; *) store_die "unsafe current target";; esac
    store_id_ok "$ACTIVE_ID" || store_die "invalid revision identifier"
    [ "$tgt" = ".revisions/$ACTIVE_ID" ] || store_die "invalid revision target"
    ACTIVE_DIR="$STATE/.revisions/$ACTIVE_ID"
    if [ "${STORE_IGNORE_CHECK:-0}" != 1 ]; then
      store_check "$ACTIVE_DIR" || store_die "integrity checksum mismatch in $ACTIVE_ID"
    fi
  elif [ -e "$STATE/.current" ]; then
    store_die "invalid current pointer"
  fi
}
store_links() {
  [ -n "$ACTIVE_ID" ] || return 0
  for f in hypotheses.log memory.txt; do
    p="$STATE/$f"
    if [ -L "$p" ]; then
      [ "$(readlink "$p")" = ".current/$f" ] || store_die "unsafe view symlink $f"
    elif [ -e "$p" ]; then
      [ -d "$STATE/.legacy" ] && [ ! -L "$STATE/.legacy" ] ||
        store_die "legacy file requires explicit --migrate"
      [ -f "$p" ] && [ ! -L "$p" ] || store_die "invalid legacy file"
      cmp -s "$p" "$ACTIVE_DIR/$f" || store_die "legacy file differs from active revision"
      [ ! -e "$STATE/.legacy/$f" ] || store_die "legacy archive collision"
      mv "$p" "$STATE/.legacy/$f"
      ln -s ".current/$f" "$p"
    else
      ln -s ".current/$f" "$p"
    fi
  done
}
store_open() {
  store_dirs
  store_active
  if [ -n "$ACTIVE_ID" ]; then
    store_links
  elif [ -e "$STATE/hypotheses.log" ] || [ -L "$STATE/hypotheses.log" ] ||
       [ -e "$STATE/memory.txt" ] || [ -L "$STATE/memory.txt" ]; then
    store_die "legacy state detected; run --migrate"
  fi
}
store_next() {
  n=1
  if [ -n "$ACTIVE_ID" ]; then n=$(expr "$(echo "$ACTIVE_ID" | sed 's/^r0*//')" + 1); fi
  while :; do
    [ "$n" -le 99999999 ] || store_die "revision counter exhausted"
    NEXT_ID=$(printf 'r%08d' "$n")
    if [ ! -e "$STATE/.revisions/$NEXT_ID" ] &&
       [ ! -L "$STATE/.revisions/$NEXT_ID" ]; then break; fi
    n=$((n + 1))
  done
}
store_crash() {
  # SIGKILL injection only for deterministic regression tests.
  if [ "${TRID_TEST_CRASH_AT:-}" = "$1" ]; then kill -KILL "$$"; fi
}
store_commit() {
  [ -f "$1" ] && [ ! -L "$1" ] || store_die "invalid journal candidate"
  [ -f "$2" ] && [ ! -L "$2" ] || store_die "invalid memory candidate"
  store_next
  stage="$TMP/complete"
  mkdir "$stage"
  cp "$1" "$stage/hypotheses.log"
  cp "$2" "$stage/memory.txt"
  (cd "$stage"; sha256sum hypotheses.log memory.txt > checksums.sha256)
  store_check "$stage" || store_die "staging integrity check failed"
  sync -f "$stage/hypotheses.log" "$stage/memory.txt" "$stage/checksums.sha256"
  sync -f "$stage"
  store_crash after_stage
  mv "$stage" "$STATE/.revisions/$NEXT_ID"
  sync -f "$STATE/.revisions"
  store_crash before_pointer
  ln -s ".revisions/$NEXT_ID" "$TMP/new-pointer"
  # Atomic same-filesystem rename of one pointer, never two separately.
  mv -Tf "$TMP/new-pointer" "$STATE/.current"
  sync -f "$STATE"
  store_crash after_pointer
  store_active
  store_links
}
store_recover() {
  store_open
  # Only remove orphan stages, never committed or uncommitted revisions.
  find "$STATE" -mindepth 1 -maxdepth 1 -type d -name '.work.*' \
      ! -path "$TMP" -exec rm -rf -- {} +
  printf 'TRID state: recovered %s\n' "$ACTIVE_ID"
}
store_backup() {
  store_open
  [ -n "$ACTIVE_ID" ] || store_die "no committed revision"
  backup="$STATE/.backups/$ACTIVE_ID"
  if [ -e "$backup" ] || [ -L "$backup" ]; then
    store_check "$backup" || store_die "backup checksum mismatch"
    cmp -s "$backup/hypotheses.log" "$ACTIVE_DIR/hypotheses.log" ||
      store_die "backup differs from current journal"
    cmp -s "$backup/memory.txt" "$ACTIVE_DIR/memory.txt" ||
      store_die "backup differs from current memory"
  else
    mkdir "$TMP/backup"
    cp "$ACTIVE_DIR/hypotheses.log" "$ACTIVE_DIR/memory.txt" \
       "$ACTIVE_DIR/checksums.sha256" "$TMP/backup/"
    store_check "$TMP/backup" || store_die "backup integrity failed"
    sync -f "$TMP/backup/hypotheses.log" "$TMP/backup/memory.txt" "$TMP/backup/checksums.sha256"
    sync -f "$TMP/backup"
    mv "$TMP/backup" "$backup"
    sync -f "$STATE/.backups"
  fi
  printf 'TRID state: backup %s\n' "$ACTIVE_ID"
}
store_restore() {
  # Explicit restore is allowed after current-file corruption; the selected
  # backup must still pass SHA-256 and the current pointer must be well formed.
  STORE_IGNORE_CHECK=1
  store_dirs
  store_active
  STORE_IGNORE_CHECK=0
  req="$1"
  store_id_ok "$req" || store_die "invalid backup identifier"
  backup="$STATE/.backups/$req"
  store_check "$backup" || store_die "missing/corrupt backup"
  store_commit "$backup/hypotheses.log" "$backup/memory.txt"
  printf 'TRID state: restored %s as %s\n' "$req" "$ACTIVE_ID"
}
store_migrate() {
  store_dirs
  store_active
  [ -z "$ACTIVE_ID" ] || store_die "already migrated"
  for f in hypotheses.log memory.txt; do
    [ -f "$STATE/$f" ] && [ ! -L "$STATE/$f" ] ||
      store_die "migration needs two legacy regular files"
  done
  [ ! -e "$STATE/.legacy" ] && [ ! -L "$STATE/.legacy" ] ||
    store_die "legacy archive already exists"
  mkdir "$STATE/.legacy"
  store_commit "$STATE/hypotheses.log" "$STATE/memory.txt"
  printf 'TRID state: migrated into %s\n' "$ACTIVE_ID"
}
