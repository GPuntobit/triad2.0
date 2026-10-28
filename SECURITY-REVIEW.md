# Security review

**Date:** 2026-10-28
**Scope:** Security findings reported and reviewed during this session.
**Method:** Focused static review of the affected call paths. No malicious payload was executed.

## Findings

| # | Severity | File | Lines | Finding | Confidence | Status |
|---|----------|------|-------|---------|------------|--------|
| 1 | 🟠 HIGH | `.github/ecc/scripts/lib/utils.js` | 491 | Windows package-manager detection starts `where` by name. A project-controlled `where.exe` may be selected from the current directory and run with the operator's permissions. | 8/10 | Open |
| 2 | 🟠 HIGH | `.github/skills/continuous-learning-v2/hooks/observe.sh` | 106-109, 169, 212-218, 262, 268-269, 316-329, 495-498 | Inline Python invocations import `json` while the checkout can remain on the module search path. A repository `json.py` can run during normal hook event parsing, before skip checks. | 9/10 | Open |
| 3 | 🟠 HIGH | `ai/jev_audit.mjs` | 74-128, 330 | The audit could follow a tracked symlink while reading file content, exposing an outside file in dry-run output or an API request. | 8/10 | Fix and regression test present in the working tree; not included in this report-only commit |
| 4 | 🟡 MEDIUM | `conformance/run.mjs` | 101-171, 194 | Golden regeneration could follow a symlink and overwrite a file outside the case directory. | 9/10 | Fix and regression tests present in the working tree; not included in this report-only commit |

## Recommended remediation

1. Resolve the Windows `where.exe` executable through a trusted absolute path under the Windows system directory; do not rely on executable-name lookup from the inherited working directory.
2. Run every inline Python parser in isolated mode, or otherwise ensure the checkout and Python environment variables cannot shadow standard-library modules.
3. Keep the symlink protections for audit reads and golden writes. Their regression tests cover direct file symlinks, symlinked parent directories, all three golden outputs, and regular golden generation.

## Verification notes

- The audit and golden-write regression tests passed in the working tree.
- The Core conformance suite passed.
- Findings 1 and 2 were confirmed by focused review and remain open in the current source.
- The working-tree fixes for findings 3 and 4 are deliberately not included in this documentation-only commit.
