#!/bin/sh
# Simulate crashes and invalid stdout at the POSIX transport boundary.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP/mock/cognitive/native" "$TMP/mock/bin"
cp "$ROOT/cognitive/native/run.sh" "$ROOT/cognitive/native/common.triad" \
   "$ROOT/cognitive/native/discover.triad" "$ROOT/cognitive/native/verify.triad" \
   "$ROOT/cognitive/native/state_store.sh" "$TMP/mock/cognitive/native/"
cat > "$TMP/mock/bin/triad" <<'EOF'
#!/bin/sh
case "$1" in
    */discover.triad)
        case "$TRID_MOCK_MODE" in
            bad_event) printf 'DIAG-discovery\n'; exit 0 ;;
            discovery_failure) printf 'partial stdout\n'; exit 7 ;;
            discovery_syntax_error) printf 'mock Triad syntax error in discovery\n' >&2; exit 2 ;;
        esac
        ;;
    */verify.triad)
        case "$TRID_MOCK_MODE" in
            bad_memory) printf 'rule|grandparent|chain|experimental|0|\nDIAG-memory\n'; exit 0 ;;
            extra_memory) printf 'rule|grandparent|chain|experimental|0|\nTRACE|unexpected\n'; exit 0 ;;
            empty_memory) exit 0 ;;
            verification_failure) printf 'partial stdout\n'; exit 8 ;;
            verification_syntax_error) printf 'mock Triad syntax error in verifier\n' >&2; exit 2 ;;
        esac
        printf 'rule|grandparent|chain|experimental|0|\n'
        ;;
    *) exit 9 ;;
esac
EOF
chmod +x "$TMP/mock/bin/triad"
printf 'target|family|grandparent|parent\n' > "$TMP/fixture"
export TRID_STATE_DIR="$TMP/state"
sh "$TMP/mock/cognitive/native/run.sh" "$TMP/fixture" > "$TMP/initial.stdout" 2> "$TMP/initial.stderr"
[ ! -s "$TMP/initial.stdout" ] || { echo 'TRID-003 S0 success wrote diagnostics on stdout' >&2; exit 1; }
grep -q 'TRID native: memory updated' "$TMP/initial.stderr"
cp "$TRID_STATE_DIR/hypotheses.log" "$TMP/journal-before"
cp "$TRID_STATE_DIR/memory.txt" "$TMP/memory-before"
before_pointer=$(readlink "$TRID_STATE_DIR/.current")
before_revisions=$(find "$TRID_STATE_DIR/.revisions" -mindepth 1 -maxdepth 1 -type d | wc -l)
for mode in discovery_failure discovery_syntax_error bad_event verification_failure verification_syntax_error bad_memory extra_memory empty_memory; do
    if TRID_MOCK_MODE="$mode" sh "$TMP/mock/cognitive/native/run.sh" "$TMP/fixture" > "$TMP/$mode.stdout" 2> "$TMP/$mode.stderr"; then
        echo "TRID transport: accepted fault $mode" >&2
        exit 1
    fi
    [ ! -s "$TMP/$mode.stdout" ] || { echo "TRID-003 leaked stdout after fault $mode" >&2; exit 1; }
    cmp "$TMP/journal-before" "$TRID_STATE_DIR/hypotheses.log"
    cmp "$TMP/memory-before" "$TRID_STATE_DIR/memory.txt"
    [ "$before_pointer" = "$(readlink "$TRID_STATE_DIR/.current")" ] ||
        { echo "TRID-003 changed commit pointer under fault $mode" >&2; exit 1; }
    [ "$before_revisions" -eq "$(find "$TRID_STATE_DIR/.revisions" -mindepth 1 -maxdepth 1 -type d | wc -l)" ] ||
        { echo "TRID-003 published a revision under fault $mode" >&2; exit 1; }
    case "$mode" in
        bad_event) grep -q 'discovery emitted invalid event' "$TMP/$mode.stderr" ;;
        bad_memory|extra_memory|empty_memory) grep -q 'verifier emitted invalid memory' "$TMP/$mode.stderr" ;;
        discovery_failure) grep -q 'discovery stdout before failure' "$TMP/$mode.stderr" ;;
        verification_failure) grep -q 'verifier failed' "$TMP/$mode.stderr" ;;
        discovery_syntax_error) grep -q 'syntax error in discovery' "$TMP/$mode.stderr" ;;
        verification_syntax_error) grep -q 'syntax error in verifier' "$TMP/$mode.stderr" ;;
    esac
done
printf 'println(:injected)\n' > "$TMP/unsafe-fixture"
if sh "$TMP/mock/cognitive/native/run.sh" "$TMP/unsafe-fixture" > "$TMP/unsafe.stdout" 2> "$TMP/unsafe.stderr"; then
    echo 'TRID transport: accepted an invalid fixture' >&2
    exit 1
fi
[ ! -s "$TMP/unsafe.stdout" ]
cmp "$TMP/journal-before" "$TRID_STATE_DIR/hypotheses.log"
cmp "$TMP/memory-before" "$TRID_STATE_DIR/memory.txt"
[ "$before_pointer" = "$(readlink "$TRID_STATE_DIR/.current")" ]
export TRID_STATE_DIR="$TMP/fresh-state"
if TRID_MOCK_MODE=bad_event sh "$TMP/mock/cognitive/native/run.sh" "$TMP/fixture" > "$TMP/fresh.stdout" 2> "$TMP/fresh.stderr"; then
    echo 'TRID transport: accepted a bad first-boot event' >&2
    exit 1
fi
[ ! -s "$TMP/fresh.stdout" ]
[ ! -e "$TRID_STATE_DIR/hypotheses.log" ]
[ ! -e "$TRID_STATE_DIR/memory.txt" ]
[ ! -e "$TRID_STATE_DIR/.current" ]
printf 'TRID transport fault-injection, syntax errors, clean stdout, no partial commits: PASS\n'
