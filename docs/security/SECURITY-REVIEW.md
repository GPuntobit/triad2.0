# Security review

**Date:** 2026-10-28
**Scope:** Security findings reported and reviewed during this session.
**Method:** Focused static review of the affected call paths. No malicious payload was executed.

## Findings

| # | Severity | File | Lines | Finding | Confidence | Status |
|---|----------|------|-------|---------|------------|--------|
| 1 | 🟠 HIGH | `.github/ecc/scripts/lib/utils.js` | 491 | Windows package-manager detection starts `where` by name. A project-controlled `where.exe` may be selected from the current directory and run with the operator's permissions. | 8/10 | Fixed (2026-10-30): resolved through an absolute `…\System32\where.exe` path. Hardened again (2026-10-30): `%SystemRoot%` is no longer trusted blindly — it must match exactly `<drive>:\windows` after normalization, otherwise a fixed `C:\WINDOWS\System32` fallback is used (UNC/relative/traversal/nested paths rejected) |
| 2 | 🟠 HIGH | `.github/skills/continuous-learning-v2/hooks/observe.sh` | 106-109, 169, 212-218, 262, 268-269, 316-329, 495-498 | Inline Python invocations import `json` while the checkout can remain on the module search path. A repository `json.py` can run during normal hook event parsing, before skip checks. | 9/10 | Fixed (2026-10-30): all inline `-c` parsers run in isolated mode (`-I`, implies `-E -s`) in observe.sh, scripts/detect-project.sh, agents/start-observer.sh; verified with a shadowing `json.py` PoC |
| 3 | 🟠 HIGH | `ai/jev_audit.mjs` | 74-128, 330 | The audit could follow a tracked symlink while reading file content, exposing an outside file in dry-run output or an API request. | 8/10 | Fixed: symlink protections + regression test (`ai/jev_audit.test.mjs`) |
| 4 | 🟡 MEDIUM | `conformance/run.mjs` | 101-171, 194 | Golden regeneration could follow a symlink and overwrite a file outside the case directory. | 9/10 | Fixed: symlink protections + regression tests (`conformance/run.test.mjs`) |

## Recommended remediation

1. Resolve the Windows `where.exe` executable through a trusted absolute path under the Windows system directory; do not rely on executable-name lookup from the inherited working directory.
2. Run every inline Python parser in isolated mode, or otherwise ensure the checkout and Python environment variables cannot shadow standard-library modules.
3. Keep the symlink protections for audit reads and golden writes. Their regression tests cover direct file symlinks, symlinked parent directories, all three golden outputs, and regular golden generation.

## Verification notes

- The audit and golden-write regression tests passed in the working tree.
- The Core conformance suite passed.
- Findings 1 and 2 were confirmed by focused review and remain open in the current source.
- The working-tree fixes for findings 3 and 4 are deliberately not included in this documentation-only commit.

---

## Findings (2026-11-02 pass)

**Method:** secret-pattern sweep of the tracked tree and of all 832 commits, review of the
credential-handling tooling. Complements the Codacy backlog triage
(`SECURITY-BACKLOG-TRIAGE.md`) and the code-quality triage (`TRIAGE-SEVERITY.md`).

| # | Severity | File | Lines | Finding | Confidence | Status |
|---|----------|------|-------|---------|------------|--------|
| 5 | 🔴 CRITICAL | `.git-credentials` | 2 | A live GitHub PAT (classic `ghp_…` format) was stored in plaintext inside the repository working tree (repository root, in a directory that is routinely archived, synced and scanned). The file was never tracked and the token never entered any commit (verified over all 832 commits), so the exposure is limited to the working tree and its copies. | 9/10 | Fixed (2026-11-02): the token was removed from the file and the placeholder restored. **The token must be rotated on GitHub** — it has to be considered potentially exposed. |
| 6 | 🟠 HIGH | `tools/git-push-with-token.ps1` | 37-57 | The script embedded the PAT in the origin remote URL (`git remote set-url origin https://<token>@github.com/…`). The token was therefore written into `.git/config` for the duration of the push (persisting if the process died before the `finally` restore), could surface in git error output, and the URL form also leaked the token as the HTTP username. | 9/10 | Fixed (2026-11-02): the remote URL is never rewritten; authentication goes through a throwaway `credential.helper` shell helper (`username=x-access-token`, `password=<token>` from the process environment only) that is discarded right after the push. `git add -A` now excludes `.git-credentials` explicitly. |
| 7 | 🟡 MEDIUM | `.git-credentials.example` | 4-16 | The template instructed copying the credential file into the repository root and configuring `credential.helper store --file=.git-credentials` (repo-local store): it made finding 5 the documented workflow. | 9/10 | Fixed (2026-11-02): the template now points to the standard store location outside the repository (`%USERPROFILE%\.git-credentials` / `~/.git-credentials`), the correct store format (`https://<username>:<token>@github.com`), and recommends the `GITHUB_TOKEN` environment variable (no token on disk) plus fine-grained, minimal-scope PATs. |

## Recommended remediation (2026-11-02)

1. **Rotate the PAT removed from `.git-credentials`** (finding 5). Even though it never
   reached git history, it lived in plaintext in a working directory; treat it as exposed.
2. Prefer `GITHUB_TOKEN` in the environment for `tools/git-push-with-token.ps1`; if a file is
   used, keep it outside the repository.
3. Never put credentials in git remote URLs: anything of the form `https://<token>@host/…`
   lands in `.git/config` and in error output.

## Verification notes (2026-11-02)

- Secret sweep: no `ghp_/gho_/ghu_/ghs_/github_pat_` pattern remains in the working tree or in
  any of the 832 commits (`git rev-list --all` + `git grep`; the working tree is now enforced by
  `tests/security/no_live_tokens.test.py`, which also fails — regression-verified — when a token
  is reintroduced).
- The push script was syntax-checked (`PSParser`) and the one-shot `credential.helper` path was
  verified live against `github.com`: the helper is invoked, no credential-bearing URL is built.
- `tests/security/run.sh` checks 2, 2b, 3, 6 and the new 7 pass; check 1
  (`windows_where_path.test.js`) remains Linux-only as documented above.
- The Triad-Core conformance suite still passes (`node cli/triad-cli.mjs test conformance` →
  `conformance: OK`).
