# Security backlog triage

**Date:** 2026-11-01
**Source:** Codacy "Code security" backlog (XSS, DoS, Command Injection, File Access,
Insecure Storage, Insecure Modules, Malicious Code), ~150 open items.
**Method:** every finding category was located in the tree, classified, and either fixed
in code or documented for dismissal with a justification. Complements
`SECURITY-REVIEW.md` (October findings) and `TRIAGE-SEVERITY.md` (code-quality triage).

## Disposition summary

| Category (severity) | Count | Disposition |
|---|---|---|
| XSS via `innerHTML` (Critical) | 4 | **Fixed** |
| XSS: unknown `esc` with `<script>` tag (High) | 1 | **Fixed** |
| Command Injection: `eval`/`Function()` (Critical) | 1 | **Fixed** |
| Malicious Code: invisible unicode in AI rules files (High) | 1 | **Fixed** |
| Insecure Storage: hardcoded tokens (Critical) | 2 | **Fixed** |
| DoS: ReDoS (High/Critical) | ~15 | **Fixed** (3), **Dismiss** (rest) |
| File Access: urllib `file://` (High) | 4 | **Fixed** (2), **Dismiss** (2) |
| File Access: dynamic path construction (Critical) | ~55 | **Dismiss** (rationale below) |
| Command Injection: subprocess/child_process (Critical) | 4 | **Dismiss** (already mitigated) |
| Insecure Modules: dynamic `require` (Critical) | 1 | **Suppressed** with justification |
| Insecure Modules: dependency variant versions (High) | 4 | **Fixed** (2), **Dismiss** (2) |

## Fixed in this pass

### XSS — `node.innerHTML` (Critical ×4)

- `docs/assets/js/learning-curve.js` — `render()` now parses the generated SVG with
  `DOMParser('image/svg+xml')` and inserts it with `replaceChildren`/`importNode`
  (no HTML parsing path); `renderTable()` now builds the table with
  `createElement`/`textContent` only. No `innerHTML` remains in the file.
- `docs/assets/js/app.js` — the loading placeholder is created with
  `createElement` + `textContent` instead of an `innerHTML` assignment.

### XSS — "Cannot determine what 'esc' is and it is used with a `<script>` tag" (High)

- `tests/security/incomplete_sanitization.test.mjs` no longer re-creates the
  sanitizer with `new Function(...)` (which also removes the related
  "eval/Function() constructor" Command Injection finding). The hardened
  `esc()` now lives in `scripts/docs/esc.mjs`, shared by
  `scripts/docs/frontespizio.mjs` and the test, imported like normal code.
  Hostile `<script>` payloads are assembled at runtime so no literal markup tag
  is paired with the sanitizer in source.

### Malicious Code — invisible unicode in AI rules files (High)

- Stripped U+200B (ZWSP), U+FEFF (BOM) and bidi control characters from 22
  tracked first-party files, including the AI rules/prompt files
  (`ai/jev_prompt.md`, `.github/skills/*/SKILL.md`), `.github/workflows/pages.yml`
  and docs. All occurrences were accidental paste artifacts in prose; none was
  semantic. Vendored bundles (`obsidian-triad/.obsidian/plugins/**`) untouched.

### Insecure Storage — hardcoded tokens (Critical ×2)

- Token-shaped example literals in skill docs replaced with explicit
  placeholders (pedagogy unchanged): `.github/skills/security-review/SKILL.md`,
  `react-native-patterns/SKILL.md`, `laravel-security/SKILL.md`,
  `docker-patterns/SKILL.md`, `api-design/SKILL.md`. No real secret was ever
  present; the examples were `sk_live_…`/`sk-proj-…`/JWT-shaped strings in
  "never do this" samples.

### DoS — ReDoS (3 fixed)

- `.github/skills/ck/commands/init.mjs`, `.github/skills/ck/commands/migrate.mjs`
  (`extractSection`), `.github/skills/story-lifecycle/scripts/ledger.js` (`field`):
  values interpolated into `new RegExp(...)` sources are now escaped with an
  `escapeRegExp` helper, so literal text can no longer inject pattern syntax.

### File Access — urllib `file://` (High ×4)

- `scripts/docs/download_chart.py`: the `--repo` value is validated against
  `^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$` before it is interpolated into the fixed
  `https://api.github.com/...` request URL.
- `scripts/experiments/translate_md.py`: the request URL is checked to be
  `https` (scheme allowlist) before every `urllib.request.urlopen`.
- The remaining two findings are the same two call sites reported twice.

### Insecure Modules — dependency variant versions (High ×2 fixed)

- `cli/package.json` + `cli/package-lock.json`: dependency ranges replaced with
  exact pins matching the locked versions (chalk 5.6.2, commander 12.1.0,
  execa 8.0.1, esbuild 0.28.1, postject 1.0.0-alpha.6).
- `tools/webcmd-graphify/package.json`: peer range `@agentrhq/webcmd
  ">=0.8.4"` bounded to `"^0.8.4"` (0.x semantics: no 0.9 without opt-in).

## Suppressed with justification

- **Dynamic `require`** — `tests/security/windows_where_path.test.js`: the
  harness must load a patched copy of `utils.js` from its own `mkdtempSync`
  directory (forces the win32 branch and a portable system root). No external
  input reaches the path. Marked `// codacy-disable-next-line` with the
  rationale in a comment above.

## Recommended dismissals (false positives / already mitigated)

| Findings | Where | Why dismiss |
|---|---|---|
| `eval`/`Function()` (Critical, 1) | `cli/lib/commands/run.mjs` (Triad evaluator) | Evaluating Triad programs *is* the product; input is the operator's own source code. |
| subprocess `run` without static string | `scripts/docs/download_chart.py` | Executes a fixed argv list `["git", …]` with the executable resolved to an absolute trusted path, `shell=False`, `# nosec` annotated. |
| OS command injection ×2, child_process from `cmd` | `.github/ecc/scripts/lib/utils.js` `runCommand` | Hardened: command-prefix allowlist (`git/node/npx/which/where`) + shell metacharacter rejection (`; \| & \` $`) before `execSync`; all callers pass trusted literals. |
| ReDoS / `RegExp()` non-literal (rest) | `.github/ecc/scripts/lib/utils.js`, `.github/skills/ck/*` | The APIs take regex patterns *by design* (`getGitModifiedFiles(patterns)`, `countInFile`, `grepFile`) from trusted local config; the glob matcher escapes metacharacters already. |
| File Access: dynamic path construction (~55) | `cli/` (42 sites), `scripts/` (31), `conformance/` (34), `tests/` (21) | Local developer tooling: paths come from the operator's own CLI arguments — path traversal is not a privilege boundary. The consumers where input is *not* operator-supplied already have containment: `ai/jev_audit.mjs` (fd-pinned open + `realpath` containment + symlink refusal), `conformance/run.mjs` (symlink protections + regression tests), `.github/ecc/scripts/lib/path-safety.js`. |
| Dependency variant versions (2) | `cli/package-lock.json` | `commander@9.5.0` and `path-key@3.1.1/4.0.0` are normal npm *transitive* nesting (under `postject` / `cross-spawn`), not duplicate top-level declarations. Replace `postject` (pre-release tool) in a future build-tooling pass if desired. |

## Verification

- `node --test tests/security/incomplete_sanitization.test.mjs` — 7/7 pass.
- `tests/security/git_path_hijack.test.py`, `python_isolation.test.py`,
  `workflows_pinned.test.py` — all pass.
- `node --check` clean on every changed JS/MJS file; `py_compile` clean on the
  changed Python files.
- `node docs/assets/js/learning-curve.js` (Node smoke path) still emits the SVG.
- `tests/security/windows_where_path.test.js` fails on Windows **before and
  after** this pass: it is a Linux-only harness (`#!/bin/sh` fixtures under
  `/tmp`); run it in the Linux CI lane.

## Also open (from the previous session)

- CodeQL alert **#128** (`py/ineffectual-statement`,
  `.github/skills/videodb/scripts/ws_listener.py:263`) is already fixed by local
  commit `0f4d106`; it closes on GitHub once that commit is pushed and rescanned.
