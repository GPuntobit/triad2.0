# Contributing Guide

[⬅ Home](Home.md) · policies: [`SECURITY.md`](../../SECURITY.md), license MIT ([`LICENSE`](../../LICENSE))

## Ground rules

1. **The spec is law.** Behavior changes go through [`SPEC.md`](../../SPEC.md) / [`SPEC-CORE.md`](../../SPEC-CORE.md) first; implementations follow. A language is the contract between its possible interpreters, not one interpreter's quirks.
2. **Conformance gates everything.** Before opening a PR:

   ```bash
   node conformance/run.mjs        # must print: conformance: OK
   triad probes/test_simple.td     # must print: test
   bash tests/security/run.sh      # ALL PASSED (5/5)
   ```

3. **New features need golden cases.** Add expected stdout + exit code under `conformance/cases/`; mark clearly whether the case is Core (executable today) or Full (golden expectation pending the self-hosted runtime).
4. **Keep profiles honest.** Docs and examples must declare `[Core]` vs `[Full]`; never present a golden Full output as something the current runtime executes.

## Workflow

- Branch from `main`, keep history reviewable (rebase feature branches; merge commits acceptable for syncing).
- All GitHub Actions stay pinned to full commit SHAs; runners pinned explicitly (`ubuntu-24.04`) — update pins via Dependabot (`github-actions` ecosystem), never move back to tags or floating labels.
- Security-sensitive code (path resolution, subprocess invocation, regex over user input) follows the established patterns: trusted absolute paths, argument-list invocation with `shell=False`, linear-time pre-validation before regex matching. The `tests/security/` suite encodes these as regressions.
- Documentation: English is the default for new docs; translations live in `tutorial/` and should be flagged for sync when the English source changes.

## Reporting vulnerabilities

Use the process in [`SECURITY.md`](../../SECURITY.md) (private disclosure). Include reproduction steps and the affected runtime path (seed vs. fallback).

## Good first contributions

- Run the Tutorial exercises (manual §23–24) and report where instructions drift.
- Add Core conformance cases for edge behaviors you find under-tested.
- Port examples to Termux and verify the Node fallback story.
- Proofread the wiki pages against the manual; flag divergences.

## Contact & links

- Repo: https://github.com/GPuntobit/triad2.0
- Site: https://gpuntobit.github.io/triad2.0
- Status/roadmap discussions: open an issue referencing [`STATUS.md`](../../STATUS.md) / [`TASK.md`](../../TASK.md).
