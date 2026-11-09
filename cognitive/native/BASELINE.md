# TRID cognitive baseline — certification record

**Reference main:** `9c08fd3c5ff7084d18fa012a51bda850a0b14ee1` (9 November 2026).  
**Scope:** TRID-001 baseline CI, TRID-002 documentation correction, TRID-003 pre-commit checks.  
**Environment:** GitHub Actions Ubuntu 24.04, Linux x86-64. CachyOS requires a separate local check.

The [historical S0 green run](https://github.com/GPuntobit/triad2.0/actions/runs/42621287537)
tested `9d7c241f50b0376c7aeac737e5b0f08d65509bab`, not reference main.
The [combined baseline workflow](../../.github/workflows/trid-baseline.yml)
records one SHA, exit codes, durations and logs for all five suites below.

| Suite | Required evidence on candidate SHA |
|---|---|
| `sh cognitive/tests/run.sh` | S1 0.1 byte-exact golden |
| `sh cognitive/native/tests/run.sh` | S0 journal/verifier and transport fault injection |
| `sh cognitive/native/tests/run_05.sh` | S1 0.5 byte-exact golden |
| `sh cognitive/native/tests/run_06.sh` | S1 0.6 replay, proof revocations and golden |
| `sh verify.sh` | Language seed and conformance |

**Certification state:** pending review of the candidate commit's CI run URL and
CachyOS results; a previous branch's green status is not transferable.

**Not covered:** a crash between publication of `hypotheses.log` and `memory.txt`.
That is TRID-005 (transactional state, deterministic recovery, backup and lock policy),
not a claim of this stabilization change. No new Python or external cognitive runtime.
