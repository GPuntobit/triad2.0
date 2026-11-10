#!/bin/sh
# Regression for the historical 12KB journal / 24KB delta / 1000 event caps.
# Native epistemic checks must hold across different finite seed windows.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
WORK=$(mktemp -d)
trap 'rm -rf -- "$WORK"' EXIT
export TRID_EVENT_STATE_DIR="$WORK/state"
SCHEMA="$ROOT/cognitive/native/schema_v1.sh"
NORM="$ROOT/cognitive/native/normalize_v1.sh"
JOURNAL="$ROOT/cognitive/native/journal_v1.sh"
UNIFY="$ROOT/cognitive/native/unify_v1.sh"
awk 'BEGIN {
    for (i=1;i<=150;i++) {
        src=(i<=6 ? "book_02" : "book_03")
        printf "v1|fact|legacy_%d|legacy_s0|%s|asserted_conditional|1|%s|none|legacy_s0_fixture|none|edge,family,parent,u%04d,v%04d,%s\n",i,src,src,i,i,src
    }
    print "v1|evidence|legacy_151|legacy_s0|review_01|reviewed_negative|1|review_01|none|legacy_s0_fixture|none|review,grandparent,train,negative,antonio,mario,review_01"
    print "v1|revocation|legacy_152|legacy_s0|book_02|revoked|1|none|none|legacy_s0_fixture|none|revoke,book_02"
}' > "$WORK/first.v1"
[ "$(wc -c < "$WORK/first.v1")" -gt 12000 ] ||
    { echo 'TRID stream: input fixture did not exceed historical ceiling' >&2; exit 1; }
sh "$NORM" "$WORK/first.v1" > "$WORK/first.stable"
[ "$(wc -c < "$WORK/first.stable")" -gt 12000 ]
sh "$JOURNAL" --reconcile "$WORK/first.v1"
sh "$JOURNAL" --verify > "$WORK/verify.out" 2> "$WORK/verify.err"
sh "$JOURNAL" --replay > "$WORK/replay"
cmp "$WORK/first.stable" "$WORK/replay"
[ "$(wc -l < "$WORK/replay")" -eq 152 ]
first_ptr=$(readlink "$TRID_EVENT_STATE_DIR/.current")
cp "$TRID_EVENT_STATE_DIR/.current/events.log" "$WORK/prefix"
sh "$JOURNAL" --reconcile "$WORK/first.v1" > "$WORK/noop.out" 2> "$WORK/noop.err"
[ "$first_ptr" = "$(readlink "$TRID_EVENT_STATE_DIR/.current")" ]
grep -q 'no changes' "$WORK/noop.err"
[ ! -s "$WORK/noop.out" ]
# One source review changes polarity. Native logical key stays the same;
# old and new candidate together exceed 24,000 bytes by a wide margin.
sed 's/reviewed_negative|1|/reviewed_positive|1|/;s/train,negative,antonio/train,positive,antonio/' \
  "$WORK/first.v1" > "$WORK/second.v1"
[ $(( $(wc -c < "$WORK/replay") + $(wc -c < "$WORK/second.v1") )) -gt 24000 ]
sh "$JOURNAL" --reconcile "$WORK/second.v1"
second_ptr=$(readlink "$TRID_EVENT_STATE_DIR/.current")
[ "$first_ptr" != "$second_ptr" ]
head -n 152 "$TRID_EVENT_STATE_DIR/.current/events.log" > "$WORK/second.prefix"
cmp "$WORK/prefix" "$WORK/second.prefix"
sh "$JOURNAL" --replay > "$WORK/replay2"
[ "$(wc -l < "$WORK/replay2")" -eq 153 ]
id=$(grep 'review,grandparent,train,negative' "$WORK/replay" | cut -d '|' -f3)
grep -F "|$id|" "$WORK/replay2" | grep -q '|reviewed_positive|2|'
# A later revocation still suspends older dependency paths when projected
# across multiple input chunks. Other, independent source paths stay valid.
sh "$UNIFY" --project-current "$WORK/replay2" > "$WORK/current"
[ "$(wc -l < "$WORK/current")" -eq 152 ]
grep -q '^evidence|suspended|v1|fact|' "$WORK/current"
grep -q '^evidence|asserted_conditional|v1|fact|' "$WORK/current"
grep -q '^evidence|reviewed_positive|v1|evidence|' "$WORK/current"
sh "$UNIFY" --project "$WORK/replay2" > "$WORK/historical"
[ "$(wc -l < "$WORK/historical")" -eq 153 ]
# Native adjacent-ID revision gate rejects duplicate revisions separated by
# more than one window; the caller must publish NO partially validated stdout.
sed 's/|reviewed_positive|2|/|reviewed_positive|1|/' "$WORK/replay2" > "$WORK/rollback.v1"
if sh "$SCHEMA" --validate-ledger "$WORK/rollback.v1" > "$WORK/invalid.out" 2> "$WORK/invalid.err"; then
    echo 'TRID stream: accepted cross-window revision rollback' >&2; exit 1
fi
[ ! -s "$WORK/invalid.out" ]
# Crash before the one pointer rename leaves entire previous history intact.
cat "$WORK/second.v1" > "$WORK/third.v1"
printf 'v1|experiment|manual_new|audit|none|proposed|1|none|none|new_test|none|bounded_change\n' >> "$WORK/third.v1"
if TRID_TEST_LEDGER_CRASH_AT=before_pointer sh "$JOURNAL" --reconcile "$WORK/third.v1" > "$WORK/crash.out" 2> "$WORK/crash.err"; then
    echo 'TRID stream: injected SIGKILL unexpectedly succeeded' >&2; exit 1
fi
# The new explicit experiment has unsupported import origin; reconcile MUST
# fail before the crash point (the previous revision is unchanged either way).
[ "$second_ptr" = "$(readlink "$TRID_EVENT_STATE_DIR/.current")" ]
sh "$JOURNAL" --recover > "$WORK/recovered.out" 2> "$WORK/recovered.err"
sh "$JOURNAL" --replay > "$WORK/recovered.v1"
cmp "$WORK/replay2" "$WORK/recovered.v1"
# More than 1,000 additional canonical explicit events in one append.
awk 'BEGIN {
    for (i=1;i<=1005;i++)
        printf "v1|experiment|experiment_%05d|audit|none|proposed|1|none|none|operator_record|none|test_%05d\n",i,i
}' > "$WORK/many.v1"
[ "$(wc -c < "$WORK/many.v1")" -gt 24000 ]
sh "$JOURNAL" --append "$WORK/many.v1"
sh "$JOURNAL" --verify > "$WORK/large.verify" 2> "$WORK/large.err"
grep -q 'verified 1158 events' "$WORK/large.err"
sh "$JOURNAL" --replay > "$WORK/full-replay"
[ "$(wc -l < "$WORK/full-replay")" -eq 1158 ]
head -n 153 "$WORK/full-replay" > "$WORK/old-events"
cmp "$WORK/replay2" "$WORK/old-events"
echo 'TRID streaming native ledger >12KB, delta >24KB, >1000 events: PASS'
