#!/bin/sh
# TRID-005 deterministic crash/backup tests. Mock seed tests transport only;
# the separate native suite exercises the actual Triad reasoning.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
WORK=$(mktemp -d)
trap 'rm -rf -- "$WORK"' EXIT
mkdir -p "$WORK/mock/cognitive/native" "$WORK/mock/bin"
cp "$ROOT/cognitive/native/run.sh" "$ROOT/cognitive/native/state_store.sh" \
   "$ROOT/cognitive/native/common.triad" "$ROOT/cognitive/native/discover.triad" \
   "$ROOT/cognitive/native/verify.triad" "$WORK/mock/cognitive/native/"
cat > "$WORK/mock/bin/triad" <<'EOF'
#!/bin/sh
case "$1" in
  */discover.triad) exit 0 ;;
  */verify.triad)
    val=0
    [ -z "$TRID_MOCK_VALUE" ] || val=$TRID_MOCK_VALUE
    printf 'rule|grandparent|chain|experimental|%s|\n' "$val" ;;
  *) exit 9 ;;
esac
EOF
chmod +x "$WORK/mock/bin/triad"
printf 'target|family|grandparent|parent\n' > "$WORK/fixture"
RUN="$WORK/mock/cognitive/native/run.sh"
export TRID_STATE_DIR="$WORK/state"
sh "$RUN" "$WORK/fixture" > "$WORK/initial.out"
J="$TRID_STATE_DIR/hypotheses.log"
M="$TRID_STATE_DIR/memory.txt"
[ -L "$J" ] && [ -L "$M" ]
[ "$(readlink "$TRID_STATE_DIR/.current")" = '.revisions/r00000001' ]
grep -q 'experimental|0|' "$M"
cp "$M" "$WORK/initial-memory"
cp "$J" "$WORK/initial-journal"
sh "$RUN" --backup > "$WORK/backup.out"
grep -q 'backup r00000001' "$WORK/backup.out"
# Concurrent writer fails under a live lock.
(
  exec 8>> "$TRID_STATE_DIR/.mutex"
  flock -n 8
  if sh "$RUN" "$WORK/fixture" > "$WORK/locked.out" 2>&1; then
    echo 'TRID store: concurrent writer succeeded' >&2; exit 1
  fi
  grep -q 'state lock' "$WORK/locked.out"
  flock -u 8
)
# Interrupted before pointer switch => original journal/memory preserved.
for point in after_stage before_pointer; do
  if TRID_TEST_CRASH_AT="$point" TRID_MOCK_VALUE=1 sh "$RUN" "$WORK/fixture" \
      > "$WORK/$point.out" 2>&1; then
    echo "TRID store: SIGKILL injection $point returned success" >&2; exit 1
  fi
  sh "$RUN" --recover > "$WORK/$point.recover"
  cmp "$WORK/initial-journal" "$J"
  cmp "$WORK/initial-memory" "$M"
  [ "$(readlink "$TRID_STATE_DIR/.current")" = '.revisions/r00000001' ]
done
# After pointer commit, new pair is visible despite a killed writer.
if TRID_TEST_CRASH_AT=after_pointer TRID_MOCK_VALUE=2 sh "$RUN" "$WORK/fixture" \
    > "$WORK/after_pointer.out" 2>&1; then
  echo 'TRID store: post-pointer SIGKILL returned success' >&2; exit 1
fi
sh "$RUN" --recover > "$WORK/recover-after-pointer"
grep -q 'experimental|2|' "$M"
[ -L "$J" ] && [ -L "$M" ]
# Backup restore makes new committed revision without overwriting old.
sh "$RUN" --restore r00000001 > "$WORK/restored.out"
cmp "$WORK/initial-journal" "$J"
cmp "$WORK/initial-memory" "$M"
[ "$(readlink "$TRID_STATE_DIR/.current")" != '.revisions/r00000001' ]
# Corruption fails closed; explicit verified backup restoration is allowed.
printf 'tamper\n' >> "$M"
if sh "$RUN" "$WORK/fixture" > "$WORK/tamper.out" 2>&1; then
  echo 'TRID store: accepted modified revision' >&2; exit 1
fi
grep -q 'integrity checksum mismatch' "$WORK/tamper.out"
if sh "$RUN" --recover > "$WORK/corrupt.out" 2>&1; then
  echo 'TRID store: silently rolled back a corrupt revision' >&2; exit 1
fi
grep -q 'integrity checksum mismatch' "$WORK/corrupt.out"
sh "$RUN" --restore r00000001 > "$WORK/repair.out"
cmp "$WORK/initial-memory" "$M"
# Explicit archival migration preserves both original legacy files.
export TRID_STATE_DIR="$WORK/legacy"
mkdir -p "$TRID_STATE_DIR"
cp "$WORK/initial-journal" "$TRID_STATE_DIR/hypotheses.log"
cp "$WORK/initial-memory" "$TRID_STATE_DIR/memory.txt"
if sh "$RUN" "$WORK/fixture" > "$WORK/legacy-reject.out" 2>&1; then
  echo 'TRID store: migrated implicitly' >&2; exit 1
fi
grep -q 'legacy state detected' "$WORK/legacy-reject.out"
sh "$RUN" --migrate > "$WORK/migrate.out"
[ -L "$TRID_STATE_DIR/hypotheses.log" ] && [ -L "$TRID_STATE_DIR/memory.txt" ]
cmp "$WORK/initial-journal" "$TRID_STATE_DIR/.legacy/hypotheses.log"
cmp "$WORK/initial-memory" "$TRID_STATE_DIR/.legacy/memory.txt"
sh "$RUN" --recover > "$WORK/legacy.recover"
# Interrupt legacy migration before publication; recover must preserve the old
# regular files and allow an explicit retry without removing .legacy manually.
for point in after_stage before_pointer; do
  export TRID_STATE_DIR="$WORK/migrate-$point"
  mkdir -p "$TRID_STATE_DIR"
  cp "$WORK/initial-journal" "$TRID_STATE_DIR/hypotheses.log"
  cp "$WORK/initial-memory" "$TRID_STATE_DIR/memory.txt"
  if TRID_TEST_CRASH_AT="$point" sh "$RUN" --migrate > "$WORK/migrate-$point.crash" 2>&1; then
    echo "TRID store: migrate SIGKILL $point unexpectedly succeeded" >&2; exit 1
  fi
  [ ! -L "$TRID_STATE_DIR/.current" ]
  cmp "$WORK/initial-journal" "$TRID_STATE_DIR/hypotheses.log"
  cmp "$WORK/initial-memory" "$TRID_STATE_DIR/memory.txt"
  sh "$RUN" --recover > "$WORK/migrate-$point.recovery" 2>&1
  sh "$RUN" --migrate > "$WORK/migrate-$point.retry"
  [ -L "$TRID_STATE_DIR/hypotheses.log" ] && [ -L "$TRID_STATE_DIR/memory.txt" ]
  cmp "$WORK/initial-journal" "$TRID_STATE_DIR/.legacy/hypotheses.log"
  cmp "$WORK/initial-memory" "$TRID_STATE_DIR/.legacy/memory.txt"
done
# SIGKILL just AFTER publication: --recover finishes both compatibility links.
export TRID_STATE_DIR="$WORK/migrate-after-pointer"
mkdir -p "$TRID_STATE_DIR"
cp "$WORK/initial-journal" "$TRID_STATE_DIR/hypotheses.log"
cp "$WORK/initial-memory" "$TRID_STATE_DIR/memory.txt"
if TRID_TEST_CRASH_AT=after_pointer sh "$RUN" --migrate > "$WORK/migrate-after-pointer.crash" 2>&1; then
  echo 'TRID store: post-pointer migrate SIGKILL unexpectedly succeeded' >&2; exit 1
fi
[ -L "$TRID_STATE_DIR/.current" ]
sh "$RUN" --recover > "$WORK/migrate-after-pointer.recovered"
[ -L "$TRID_STATE_DIR/hypotheses.log" ] && [ -L "$TRID_STATE_DIR/memory.txt" ]
cmp "$WORK/initial-journal" "$TRID_STATE_DIR/.legacy/hypotheses.log"
cmp "$WORK/initial-memory" "$TRID_STATE_DIR/.legacy/memory.txt"
printf 'TRID-005 atomic state, crash recovery, backup/restore: PASS\n'
