#!/bin/sh
# TRID-071: S0/S1 independent execution, atomic filesystem and archive replay.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
W=$(mktemp -d)
trap 'rm -rf -- "$W"' EXIT
export TRID_STATE_DIR="$W/s0" TRID_GRAPH_STATE_DIR="$W/s1" TRID_EVENT_STATE_DIR="$W/events"
S0="$ROOT/cognitive/native/run.sh"
S1="$ROOT/cognitive/native/run_06.sh"
J="$ROOT/cognitive/native/journal_v1.sh"
U="$ROOT/cognitive/native/unify_v1.sh"
sh "$S0" "$ROOT/cognitive/native/fixture.txt" > "$W/s0.first" 2> "$W/s0.err"
sh "$S1" > "$W/s1.first" 2> "$W/s1.err"
cmp "$ROOT/cognitive/native/tests/expected_06.out" "$W/s1.first"
cp "$TRID_STATE_DIR/.current/hypotheses.log" "$W/s0.journal"
cp "$TRID_STATE_DIR/.current/memory.txt" "$W/s0.memory"
cp "$TRID_GRAPH_STATE_DIR/graph.facts" "$W/s1.graph"
sh "$U" --reconcile "$ROOT/cognitive/native/fixture.txt" \
  "$TRID_STATE_DIR/.current/memory.txt" "$TRID_GRAPH_STATE_DIR/graph.facts" > "$W/ingest.out" 2> "$W/ingest.err"
sh "$J" --replay > "$W/first.events"
sh "$J" --verify > "$W/verified.out" 2> "$W/verified.err"
[ ! -s "$W/verified.out" ]
sh "$U" --project-current "$W/first.events" > "$W/projection"
grep -q '^proofs|' "$W/projection"
grep -q '^activation_network|' "$W/projection"
ptr=$(readlink "$TRID_EVENT_STATE_DIR/.current")
# Byte-exact restart and idempotence of the multi-source importer.
sh "$S0" "$ROOT/cognitive/native/fixture.txt" > "$W/s0.second" 2> "$W/s0.second.err"
sh "$S1" > "$W/s1.second" 2> "$W/s1.second.err"
cmp "$W/s0.journal" "$TRID_STATE_DIR/.current/hypotheses.log"
cmp "$W/s0.memory" "$TRID_STATE_DIR/.current/memory.txt"
cmp "$W/s1.graph" "$TRID_GRAPH_STATE_DIR/graph.facts"
cmp "$W/s1.first" "$W/s1.second"
sh "$U" --reconcile "$ROOT/cognitive/native/fixture.txt" \
  "$TRID_STATE_DIR/.current/memory.txt" "$TRID_GRAPH_STATE_DIR/graph.facts" > "$W/noop.out" 2> "$W/noop.err"
grep -q 'no changes' "$W/noop.err"
[ "$ptr" = "$(readlink "$TRID_EVENT_STATE_DIR/.current")" ]
# Fail-closed concurrent state access for each of the three stores.
(
 exec 8>> "$TRID_STATE_DIR/.mutex"; flock -n 8
 if sh "$S0" "$ROOT/cognitive/native/fixture.txt" > "$W/lock.s0.out" 2> "$W/lock.s0.err"; then
   echo 'TRID-071 S0 lock bypass' >&2; exit 1
 fi
 grep -q 'state lock' "$W/lock.s0.err"; flock -u 8
)
(
 exec 8>> "$TRID_GRAPH_STATE_DIR/.mutex"; flock -n 8
 if sh "$S1" > "$W/lock.s1.out" 2> "$W/lock.s1.err"; then
   echo 'TRID-071 S1 lock bypass' >&2; exit 1
 fi
 grep -q 'state locked' "$W/lock.s1.err"; flock -u 8
)
(
 exec 8>> "$TRID_EVENT_STATE_DIR/.mutex"; flock -n 8
 if sh "$J" --verify > "$W/lock.j.out" 2> "$W/lock.j.err"; then
   echo 'TRID-071 ledger lock bypass' >&2; exit 1
 fi
 grep -q 'state locked' "$W/lock.j.err"; flock -u 8
)
# S1 SIGKILL at two deterministic points must not leave a stale lock or
# publish partial output; graph facts remain byte-exact after restart.
for point in after_lock before_output; do
 if TRID_TEST_GRAPH_CRASH_AT="$point" sh "$S1" > "$W/kill.$point.out" 2> "$W/kill.$point.err"; then
   echo "TRID-071 S1 crash $point succeeded unexpectedly" >&2; exit 1
 fi
 [ ! -s "$W/kill.$point.out" ]
 cmp "$W/s1.graph" "$TRID_GRAPH_STATE_DIR/graph.facts"
 sh "$S1" > "$W/restart.$point.out" 2> "$W/restart.$point.err"
 cmp "$W/s1.first" "$W/restart.$point.out"
done
# Valid S0 revocation: pre-pointer SIGKILL preserves both old files,
# then successful restart suspends ONLY the dependent conditional proof.
cp "$ROOT/cognitive/native/fixture.txt" "$W/revoked.fixture"
printf 'revoke|book_02\n' >> "$W/revoked.fixture"
s0_ptr=$(readlink "$TRID_STATE_DIR/.current")
if TRID_TEST_CRASH_AT=before_pointer sh "$S0" "$W/revoked.fixture" \
   > "$W/s0.kill.out" 2> "$W/s0.kill.err"; then
 echo 'TRID-071 S0 SIGKILL unexpectedly succeeded' >&2; exit 1
fi
[ "$s0_ptr" = "$(readlink "$TRID_STATE_DIR/.current")" ]
cmp "$W/s0.journal" "$TRID_STATE_DIR/.current/hypotheses.log"
cmp "$W/s0.memory" "$TRID_STATE_DIR/.current/memory.txt"
sh "$S0" --recover > "$W/s0.recovered" 2> "$W/s0.recovered.err"
sh "$S0" "$W/revoked.fixture" > "$W/revoked.out" 2> "$W/revoked.err"
grep -q '^claim|grandparent|mario|antonio|.*|suspended$' "$TRID_STATE_DIR/.current/memory.txt"
grep -q '^claim|grandparent|sara|nina|.*|demonstrated_conditional$' "$TRID_STATE_DIR/.current/memory.txt"
sh "$U" --reconcile "$W/revoked.fixture" "$TRID_STATE_DIR/.current/memory.txt" \
 "$TRID_GRAPH_STATE_DIR/graph.facts" > "$W/new.ingest" 2> "$W/new.ingest.err"
sh "$J" --replay > "$W/revoked.events"
[ "$(wc -l < "$W/revoked.events")" -gt "$(wc -l < "$W/first.events")" ]
sh "$U" --project-current "$W/revoked.events" > "$W/revoked.projection"
grep -q '^proofs|suspended|' "$W/revoked.projection"
# Restore an already existing complete journal archive in another directory.
mkdir "$W/archive"
cp -a "$TRID_EVENT_STATE_DIR/." "$W/archive/"
TRID_EVENT_STATE_DIR="$W/archive" sh "$J" --recover > "$W/archive.out" 2> "$W/archive.err"
TRID_EVENT_STATE_DIR="$W/archive" sh "$J" --replay > "$W/archive.events"
cmp "$W/revoked.events" "$W/archive.events"
# Incompatible v2 and malicious S1 data fail, without changing a commit pointer.
printf 'v2|fact|bad|family|none|declared|1|none|none|unsafe|none|wrong_version\n' > "$W/v2"
before=$(readlink "$TRID_EVENT_STATE_DIR/.current")
if sh "$J" --append "$W/v2" > "$W/v2.out" 2> "$W/v2.err"; then
 echo 'TRID-071 accepted incompatible version' >&2; exit 1
fi
[ ! -s "$W/v2.out" ]
[ "$before" = "$(readlink "$TRID_EVENT_STATE_DIR/.current")" ]
printf 'println(:evil)\n' >> "$TRID_GRAPH_STATE_DIR/graph.facts"
if sh "$S1" > "$W/injected.out" 2> "$W/injected.err"; then
 echo 'TRID-071 executed source as code' >&2; exit 1
fi
[ ! -s "$W/injected.out" ]
grep -q 'invalid graph record' "$W/injected.err"
[ "$before" = "$(readlink "$TRID_EVENT_STATE_DIR/.current")" ]
# A graph symlink and an aliased state path are not acceptable inputs.
mkdir "$W/s1-symlink-graph"
ln -s "$W/s1.graph" "$W/s1-symlink-graph/graph.facts"
if TRID_GRAPH_STATE_DIR="$W/s1-symlink-graph" sh "$S1" > "$W/symlink-graph.out" 2> "$W/symlink-graph.err"; then
  echo 'TRID-071: accepted symlink graph input' >&2; exit 1
fi
grep -q 'invalid graph path' "$W/symlink-graph.err"
ln -s "$W/s1-symlink-graph" "$W/state-alias"
if TRID_GRAPH_STATE_DIR="$W/state-alias" sh "$S1" > "$W/state-alias.out" 2> "$W/state-alias.err"; then
  echo 'TRID-071: accepted symlink state directory' >&2; exit 1
fi
grep -q 'unsafe state symlink' "$W/state-alias.err"
# Rebuild the old S0 polynomial chain with native Triad after changing the
# first proof witness. This bypasses a mere checksum mismatch but MUST fail
# independent proof-grounding; no new state publication is permitted.
export TRID_STATE_DIR="$W/forged"
mkdir "$TRID_STATE_DIR"
cp -a "$W/s0/.revisions" "$TRID_STATE_DIR/"
cp -a "$W/s0/.current" "$TRID_STATE_DIR/"
: > "$TRID_STATE_DIR/.current/hypotheses.log"
n=1; prev=0; changed=0
while IFS= read -r row; do
  item=${row#*|}
  item=${item#*|}
  item=${item%|*}
  case "$item" in
    proof\|*)
      if [ "$changed" -eq 0 ]; then
        item=$(printf '%s\n' "$item" | sed 's/|luca|/|false_witness|/')
        printf '%s\n' "$item" | grep -q '|false_witness|' || { echo 'TRID-071 missing witness fixture' >&2; exit 1; }
        changed=1
      fi ;;
  esac
  body="$n|$prev|$item"
  { cat "$ROOT/cognitive/native/common.triad"; printf 'println(checksum("%s"))\n' "$body"; } > "$W/checksum.triad"
  digest=$("$ROOT/bin/triad" "$W/checksum.triad")
  printf '%s|%s\n' "$body" "$digest" >> "$TRID_STATE_DIR/.current/hypotheses.log"
  prev=$digest
  n=$((n + 1))
done < "$W/s0.journal"
[ "$changed" -eq 1 ]
(cd "$TRID_STATE_DIR/.current"; sha256sum hypotheses.log memory.txt > checksums.sha256)
forged_ptr=$(readlink "$TRID_STATE_DIR/.current")
if sh "$S0" "$ROOT/cognitive/native/fixture.txt" > "$W/witness.out" 2> "$W/witness.err"; then
  echo 'TRID-071 accepted falsified witness with recomputed checksums' >&2; exit 1
fi
grep -q 'false ground proof' "$W/witness.err"
[ "$forged_ptr" = "$(readlink "$TRID_STATE_DIR/.current")" ]
printf 'TRID-071 S0/S1 filesystems, restart, SIGKILL, replay, forged witness: PASS\n'
