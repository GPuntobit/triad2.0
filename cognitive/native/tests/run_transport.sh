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
        esac
        ;;
    */verify.triad)
        case "$TRID_MOCK_MODE" in
            bad_memory) printf 'rule|grandparent|chain|experimental|0|\nDIAG-memory\n'; exit 0 ;;
            empty_memory) exit 0 ;;
            verification_failure) printf 'partial stdout\n'; exit 8 ;;
        esac
        printf 'rule|grandparent|chain|experimental|0|\n'
        ;;
    *) exit 9 ;;
esac
EOF
chmod +x "$TMP/mock/bin/triad"
printf 'target|family|grandparent|parent\n' > "$TMP/fixture"
export TRID_STATE_DIR="$TMP/state"
sh "$TMP/mock/cognitive/native/run.sh" "$TMP/fixture" > "$TMP/initial.out" 2>&1
cp "$TRID_STATE_DIR/hypotheses.log" "$TMP/journal-before"
cp "$TRID_STATE_DIR/memory.txt" "$TMP/memory-before"
for mode in discovery_failure bad_event verification_failure bad_memory empty_memory; do
    if TRID_MOCK_MODE="$mode" sh "$TMP/mock/cognitive/native/run.sh" "$TMP/fixture" > "$TMP/$mode.out" 2>&1; then
        echo "TRID transport: accepted fault $mode" >&2
        exit 1
    fi
    cmp "$TMP/journal-before" "$TRID_STATE_DIR/hypotheses.log"
    cmp "$TMP/memory-before" "$TRID_STATE_DIR/memory.txt"
    case "$mode" in
        bad_event) grep -q 'discovery emitted invalid event' "$TMP/$mode.out" ;;
        bad_memory|empty_memory) grep -q 'verifier emitted invalid memory' "$TMP/$mode.out" ;;
        discovery_failure) grep -q 'discovery stdout before failure' "$TMP/$mode.out" ;;
        verification_failure) grep -q 'verifier failed' "$TMP/$mode.out" ;;
    esac
done
printf 'println(:injected)\n' > "$TMP/unsafe-fixture"
if sh "$TMP/mock/cognitive/native/run.sh" "$TMP/unsafe-fixture" > "$TMP/unsafe.out" 2>&1; then
    echo 'TRID transport: accepted an invalid fixture' >&2
    exit 1
fi
cmp "$TMP/journal-before" "$TRID_STATE_DIR/hypotheses.log"
cmp "$TMP/memory-before" "$TRID_STATE_DIR/memory.txt"
export TRID_STATE_DIR="$TMP/fresh-state"
if TRID_MOCK_MODE=bad_event sh "$TMP/mock/cognitive/native/run.sh" "$TMP/fixture" > "$TMP/fresh.out" 2>&1; then
    echo 'TRID transport: accepted a bad first-boot event' >&2
    exit 1
fi
[ ! -e "$TRID_STATE_DIR/hypotheses.log" ]
[ ! -e "$TRID_STATE_DIR/memory.txt" ]
printf 'TRID transport fault-injection: PASS\n'
