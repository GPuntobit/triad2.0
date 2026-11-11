#!/usr/bin/env bash
# TRID-071/074: produce a local CachyOS evidence bundle on the actual machine.
# Refuse Ubuntu/Arch containers masquerading as CachyOS.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
cd "$ROOT"
[[ $(uname -s) == Linux && $(uname -m) == x86_64 ]] ||
  { echo 'TRID CachyOS: Linux x86_64 required' >&2; exit 2; }
[[ -r /etc/os-release ]] || { echo 'TRID CachyOS: no /etc/os-release' >&2; exit 2; }
grep -Eiq '^ID="?cachyos"?$' /etc/os-release ||
  { echo 'TRID CachyOS: not running on CachyOS; do not certify' >&2; exit 2; }
for cmd in git xxd flock sha256sum timeout cmp mktemp awk sed grep sync; do
  command -v "$cmd" >/dev/null || { echo "TRID CachyOS: missing $cmd" >&2; exit 2; }
done
[[ -z $(git status --porcelain) ]] ||
  { echo 'TRID CachyOS: dirty working tree; use a clean checkout' >&2; exit 2; }
SHA=$(git rev-parse HEAD)
if [[ -n ${TRID_EXPECTED_SHA:-} && $SHA != "$TRID_EXPECTED_SHA" ]]; then
  echo "TRID CachyOS: SHA mismatch actual=$SHA expected=$TRID_EXPECTED_SHA" >&2
  exit 2
fi
EVIDENCE=$(mktemp -d "${TMPDIR:-/tmp}/trid-cachyos-cert.XXXXXXXX")
{
  printf 'platform=cachyos\nsha=%s\n' "$SHA"
  printf 'utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf 'kernel=%s\n' "$(uname -r)"
  printf 'arch=%s\n' "$(uname -m)"
  grep -E '^((ID|VERSION_ID|BUILD_ID|PRETTY_NAME)=)' /etc/os-release || true
  printf 'git_clean=true\n'
} > "$EVIDENCE/platform.txt"
xxd -r -p seed/linux-x86_64/seed.hex seed/linux-x86_64/seed
chmod +x seed/linux-x86_64/seed
ulimit -v 2097152
suites=(
  cognitive/tests/run.sh
  cognitive/native/tests/run.sh
  cognitive/native/tests/run_05.sh
  cognitive/native/tests/run_06.sh
  cognitive/native/tests/run_epistemic_070.sh
  cognitive/native/tests/run_integration_071.sh
  verify.sh
)
count=0
for suite in "${suites[@]}"; do
  count=$((count+1))
  printf 'RUN %s SHA=%s\n' "$suite" "$SHA" | tee -a "$EVIDENCE/results.txt"
  start=$(date +%s)
  if timeout -k 10s 1200s sh "$suite" > "$EVIDENCE/run-$count.log" 2>&1; then
    printf 'PASS %s duration_seconds=%s exit=0\n' "$suite" "$(( $(date +%s) - start ))" |
      tee -a "$EVIDENCE/results.txt"
  else
    rc=$?
    printf 'FAIL %s duration_seconds=%s exit=%s\n' "$suite" "$(( $(date +%s) - start ))" "$rc" |
      tee -a "$EVIDENCE/results.txt" >&2
    printf 'evidence_directory=%s\n' "$EVIDENCE" >&2
    exit "$rc"
  fi
done
(cd "$EVIDENCE" && sha256sum platform.txt results.txt run-*.log > evidence.sha256)
printf 'TRID CachyOS local suites PASS sha=%s evidence_directory=%s\n' "$SHA" "$EVIDENCE"
printf 'NOTE: this is a local, unauthenticated test report, not cryptographic attestation.\n'
