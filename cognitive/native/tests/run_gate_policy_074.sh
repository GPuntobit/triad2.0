#!/bin/sh
# TRID-074 regression: failed, cancelled or skipped checks never count as green.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
GATE="$ROOT/scripts/trid_required_gate.sh"
sh "$GATE" success success success success success > /dev/null
for state in failure cancelled skipped timed_out neutral ''; do
  for slot in 1 2 3 4 5; do
    set -- success success success success success
    case "$slot" in
      1) set -- "$state" "$2" "$3" "$4" "$5" ;;
      2) set -- "$1" "$state" "$3" "$4" "$5" ;;
      3) set -- "$1" "$2" "$state" "$4" "$5" ;;
      4) set -- "$1" "$2" "$3" "$state" "$5" ;;
      5) set -- "$1" "$2" "$3" "$4" "$state" ;;
    esac
    if sh "$GATE" "$@" >/dev/null 2>&1; then
      echo "TRID-074 gate accepted slot=$slot result=$state" >&2
      exit 1
    fi
  done
done
if sh "$GATE" success success success success >/dev/null 2>&1; then
  echo 'TRID-074 gate accepted missing job result' >&2
  exit 1
fi
echo 'TRID-074 all-checks-required fail-closed policy: PASS'
