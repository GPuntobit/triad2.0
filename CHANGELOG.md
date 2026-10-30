# Changelog — standard Triad
Regulatory changes also update `VERSION`, the specification (`SPEC.md`) and, if it changes
behavior, the goldens of `conformance/`.

## 0.8.0-beta.7 — 2026-10-31: security hardening, CI integrity & repository cleanup

### Added
- Repository structure reorganization released across three passes: probes moved
  from the root to `probes/`; long-form docs gathered in `docs/` and versioned
  release notes in `docs/releases/`; webcmd Graphify plugin moved to
  `tools/webcmd-graphify/`; `scripts/` split by purpose (`scripts/docs/` build
  helpers, `scripts/seed-runner/` Windows seed wrappers, `scripts/experiments/`
  one-off dev scripts); tutorial translations consolidated in `tutorial/`
  (`docs/TUTORIAL-RU.md` → `tutorial/TUTORIAL.ru.md`). CI, install.sh, build
  scripts, workflows and README references updated accordingly.
- Repaired tooling regressions found during the moves: `download_chart.py`
  indentation/typos plus asset download counts and default repo; `build-epub.cjs`
  and `build-libro.mjs` `continue` typo and variable mismatches.
- `tests/security/` — repeatable security verification suite (`run.sh`, 5 checks):
  Windows command detection cannot execute a project-controlled `where.exe`;
  Python parser isolation against `json.py`/`sitecustomize.py`/`PYTHONPATH`/user
  site-packages shadowing; every workflow action pinned to a full commit SHA;
  relocated build scripts and tutorial links resolve from their new directories;
  download-chart script runs from its new location and writes valid SVG output.
- `.github/workflows/codeql.yml` + `.github/codeql-config.yml` — CodeQL scanning
  for C#, JavaScript/TypeScript and Python; the C# job builds on
  `windows-2022` with `autobuild` so the WinForms CLI analyzer resolves call
  targets and expression types (fixes "Incomplete database" scanner findings).
- `cli/windows-gui/TriadDesktop.csproj` — SDK-style project file mirroring the
  assembly set of `build.ps1`, enabling autobuild/manual-build scans.
- `wiki/` — 10-page English wiki generated from the project documentation
  (Home, Getting Started, Language Guide, Syntax Reference, Error Handling &
  Advanced Features, Logic Programming, Code-as-Data & Macros, Project Status,
  Repository Architecture, Contributing Guide).
- Triad-generated website page: `tools/site-gen/generate_site_core.td` emits
  `docs/pages/generated.html` using only Triad-Core constructs (verified against
  the reference interpreter); online playground bundle restored via
  `scripts/docs/sync-playground.cjs`.
- Site webpages rewritten in Triad: `docs/web/*.td` (index, examples, getting-started,
  tour, api-reference, community, contributing, download, repl) generate the whole
  GitHub Pages site with `tools/site-gen/build-site.td`.
- `.github/config.yml` — versioned CodeRabbit configuration (chill profile,
  path filters excluding generated artifacts).
- Release notes: `docs/releases/RELEASE_NOTES_v0.8.0-beta.7.md`.

### Security
- **HIGH** — `%SystemRoot%` is no longer trusted by default in
  `.github/ecc/scripts/lib/utils.js`: the system directory is validated as an
  absolute `<drive>:\windows` path after normalization; UNC, relative, traversal
  or attacker-controlled values are rejected with a fixed fallback to
  `C:\WINDOWS\System32`, so the invoked `where.exe` always lives in a trusted
  system directory.
- **MEDIUM** — `git` is resolved to a trusted absolute executable before
  `subprocess.run` in `scripts/docs/download_chart.py`: hardcoded canonical paths
  first, then `shutil.which` results accepted only if absolute, a real file after
  `realpath`, executable and outside the repository; argument-list invocation,
  `shell=False`, repository cwd and the unavailable-git fallback preserved.
- ReDoS hardening: `_is_safe_tag_line()` linear-time pre-validation of tag lines
  in `download_chart.py` before regex processing, with worst-case regression tests.
- Incomplete multi-character sanitization fixed in
  `.github/skills/continuous-learning-v2/scripts/instinct-cli.py`: escape
  substitutions iterate to a fixpoint so nested fragments (`<scr<script>ipt>`)
  cannot reconstruct a `<script>` tag.
- All GitHub Actions pinned to full immutable commit SHAs (checkout@v7,
  setup-node@v7, configure-pages@v6, upload-pages-artifact@v5, deploy-pages@v5,
  codeql-action@v3, setup-dotnet@v4), verified against the GitHub API.

### Changed
- Root and folders cleanup (third pass, see below) completed and released.
- All Linux CI jobs pinned to `ubuntu-24.04` ahead of the `ubuntu-latest`
  migration to Ubuntu 26 (actions/runner-images#14748).
- `download-chart.yml`: removed deprecated `setup-python@v5` (stdlib-only
  script) and stale Node-20 warnings; checkout bumped to v7.
- `install.sh`: usage extraction window fixed after the Termux section shifted
  the header; final self-check now probes `$ROOT/probes/test_simple.td`.
- README: Termux (Android) section documenting the Node.js fallback path.

### Fixed
- `obsidian-triad/github-wiki/` removed from the index: an empty leftover
  gitlink broke CI submodule sync ("No url found for submodule path … in
  .gitmodules"), failing every workflow at `actions/checkout`.
- `scripts/docs/build-libro.mjs` crashed writing to a non-existent
  `docs/libro/`; now creates the output directory.
- Removed two empty files accidentally committed in the root (`Developer`,
  `install-triad-ext.bat`).

## 0.8.0-beta.6 — 2026-10-30: repository structure reorganization & tooling fixes

- Probe `.td` moved from the root to `probes/` (`test_simple.td`, `test_let.td`,
  `test_get.td`, `test_td.txt`); paths updated in `.github/workflows/ci.yml`
  and `install.sh`.
- Long-form documentation gathered in `docs/`: `MANUALE.md`, `PREFazione.md`,
  `TUTORIAL-RU.md`; versioned release notes in `docs/releases/`. Paths updated
  in the build scripts.
- webcmd Graphify plugin moved from `.webcmd/` to `tools/webcmd-graphify/`.
- Removed two empty files accidentally committed in the root: `Developer` and
  `install-triad-ext.bat` (no active reference in the repository).
- `scripts/` split by purpose: build helpers in `scripts/docs/`
  (`build-libro.mjs`, `build-epub.cjs`, `build-docx.cjs`, `frontespizio.mjs`,
  `download_chart.py`), Windows seed wrappers in `scripts/seed-runner/`,
  one-off dev experiments in `scripts/experiments/`. Internal paths of the
  build scripts and the `download-chart.yml` workflow updated accordingly.
- Tutorial translations consolidated in `tutorial/` (moved
  `docs/TUTORIAL-RU.md` → `tutorial/TUTORIAL.ru.md`, alongside the existing
  `TUTORIAL.md`, `TUTORIAL.it.md`, `TUTORIAL.zh.md`); links in README, manual,
  site pages and build scripts updated.
- PR descriptions moved out of the root into a dedicated worklog folder:
  `PULL_REQUEST.md` → `docs/worklog/PULL_REQUEST-current.md` (active draft),
  `docs/PULL_REQUEST.md` → `docs/worklog/PULL_REQUEST-pr30.md` (archived).
- Push helper relocated to the tools area: `scripts/git-push-with-token.ps1`
  → `tools/git-push-with-token.ps1`.
- `obsidian-triad/github-wiki/` removed from the index: it was an empty
  leftover directory that broke CI submodule sync ("No url found for submodule
  path 'obsidian-triad/github-wiki' in .gitmodules").
- CI runner stability: all Linux jobs pinned from `ubuntu-latest` to the
  explicit image `ubuntu-24.04` (`ci.yml`, `download-chart.yml`, `pages.yml`,
  `static.yml`) ahead of the `ubuntu-latest` → Ubuntu 26 migration scheduled
  for 2026-10-19 (actions/runner-images#14748), keeping toolchain-dependent
  steps stable (`xxd` install, ELF seed execution, Node conformance runner).
  `node-version: '20'` kept as-is: setup-node downloads the runtime itself,
  so it is unaffected by the runner-image change.
- `README.md` "Project Structure": stale `docs/TUTORIAL-RU.md` entry replaced
  with the `tutorial/` translations line; added `tests/security/`,
  `docs/worklog/`, `scripts/*` subfolders; documented contract paths unchanged
  (`bin/`, `seed/<platform>/`, `conformance/`, `selfhost/`, `examples/`,
  `probes/`, `cli/`, `editors/`, `VERSION`, `LICENSE`, `install.sh`).


## 0.8.0-beta.3 — 2026-10-29
**Triad 2.0 – Beta 3.** Pre-release of the Triad 2.0 series: includes *all*
updates from v0.2.0 to today (also contained in v0.3.0, superseded).
### CLI (`cli/`)
- **`run` command**: `triad-cli run <file> [-- args]` runs a `.triad`/`.td` program
  with the seed in machine code; on Linux/macOS use the reference interpreter
  `seed/dev/triad_core.cjs` as long as the ELF seed remains E0 (forceable with `-n/--native`).
  Exit code propagated, file/parse errors handled with exit 1.
- **`ext`** commands for the VS Code extension:
  - `ext check`: valid `package.json`, tmLanguage grammar and language-configuration
    (all JSON checked); reports name, version, languages ​​and extensions.
  - `ext package`: package the `.vsix` with global `vsce` or `npx --yes @vscode/vsce`;
    supports `-o/--out`.
- **Modularity**: new modules `cli/lib/commands/run.mjs` and `cli/lib/commands/ext.mjs`;
  `status` and updated help, README CLI extended with "Run" sections ed
  "VS Code Extension".
### Tooling editor
- VS Code `editors/vscode` extension (Triad v0.2.0, `triad` languages, extensions
  `.triad`/`.td`) checked and packaged by CLI (`ext check` / `ext package`).
### Compliance and standards
- New Core `gcd` case (Euclid, recursion and `%`); the Core suite has 37 cases.
- Golden versioned: `conformance/**/expected.out` and `expected.code` tracked;
  the runner accepts `expected.golden` as a backup.
- `conformance/run.mjs` uses the `seed/dev/triad_core.cjs` interpreter on Linux/macOS
  (seed ELF still E0) and fails with `golden missing` instead of comparing with
  stdout empty.
- Julia removed from repository (`triad.jl`, `syntax.jl`, `test/`,
  `bin/build_standalone.jl`); the CI uses only Node and the seed.
### Maintenance and dependencies
- Updated `esbuild` dependency to 0.28.1 (PR #21, dependabot).
- `*.vsix` added to `.gitignore` as a generated artifact.
- Added `LICENSE` MIT; seed binaries included in the repository
  (`seed/windows-x86_64/seed.exe`, `seed/linux-x86_64/seed`).
### Documentation
- Release Notes `RELEASE_NOTES_v0.8.0-beta.3.md`; PR description in `PULL_REQUEST.md`.
## 0.3.0 — 2026-10-29
### CLI (`cli/`)
- **`run` command**: `triad-cli run <file> [-- args]` runs a `.triad`/`.td` program
  with the seed in machine code; on Linux/macOS use the reference interpreter
  `seed/dev/triad_core.cjs` as long as the ELF seed remains E0 (forceable with `-n/--native`).
  Exit code propagated, file/parse errors handled with exit 1.
- **`ext`** commands for the VS Code extension:
  - `ext check`: valid `package.json`, tmLanguage grammar and language-configuration
    (all JSON checked); reports name, version, languages ​​and extensions.
  - `ext package`: package the `.vsix` with global `vsce` or `npx --yes @vscode/vsce`;
    supports `-o/--out`.
- **Modularity**: new modules `cli/lib/commands/run.mjs` and `cli/lib/commands/ext.mjs`;
  `status` and updated help, README CLI extended with "Run" sections ed
  "VS Code Extension".
- **Maintenance**: `esbuild` dependency updated to 0.28.1 (PR #21); `*.vsix` added
  to `.gitignore` as the generated artifact.
### Documentation
- Added Pull Request description in `PULL_REQUEST.md`.
## Not released — 2026-10-26
- **Conformance**: new Core `gcd` case (Euclid, recursion and `%`); the Core suite has 37 cases.
- **Golden versioned**: `.gitignore` no longer excludes `conformance/**/expected.out` and
  `expected.code`; the runner accepts `expected.golden` as a backup.
- **Runner**: `conformance/run.mjs` uses the `seed/dev/triad_core.cjs` interpreter on Linux/macOS
  (the ELF seed is still E0) and fails with `golden missing` instead of comparing to one
  empty stdout; removed the golden `gcd` written in the runner code.
- **Julia removed**: `triad.jl`, `syntax.jl`, `test/` and `bin/build_standalone.jl` no longer do
  part of the repository; the CI uses only Node and the seed.
## Not released — 2026-10-22
- **Open source**: added `LICENSE` MIT; seed binaries included in the repository
  (`seed/windows-x86_64/seed.exe`, `seed/linux-x86_64/seed`) and lockfiles
  (`Manifest.toml`, `Cargo.lock`); Updated `.gitignore` and `.gitattributes`.
## 0.2.0 — 2026-10-20
- **Standard Triad v0.2.0**: `SPEC.md` becomes an independent regulatory document
  from implementation (status, regulations, compliance profiles and versioning in §16).
- **Conformance executable**: Added `conformance/` with 12 golden cases (stdout + exit code)
  and a development runner based on stage0; the suite is part of the standard.
- **AI benchmark** (development tool): `ai/` with system prompt, 5 Triad-Core tasks and
  `ai/verify.jl` to generate code with an LLM and verify it against goldens.
- **Seed Linux E0**: first static x86-64 ELF, syscall only (`write`/`exit`), which prints
  `Triad seed Linux OK`; dump `seed/linux-x86_64/seed.hex`, generator `seed/dev/gen_seed_linux.js`
  and CI Linux jobs.
- **Canonical extension**: `.triad`; `.td` remains supported as a historical alias.
- **Independence**: Bootstrap plan without guest languages ​​in `BOOTSTRAP.md`.
- **Tooling editor**: syntax grammars for VS Code and Vim/Neovim (`editors/`) and
  preparing the Linguist entry for recognition on GitHub
  (`editors/linguist/`).
- **Seed M1**: first Triad executable in machine code (1024 byte x86-64 Windows PE,
  `seed/windows-x86_64/`): print `Triad seed OK`, exit 0, no compiler.
- **Seed M2**: Real I/O without runtime — reads the file from the first command line argument
  and writes the bytes to stdout in 4 KiB blocks; exit 0/1/2, path in quotes, PE from
  2560 bytes.
- **Triad-Core**: new profile standard [`SPEC-CORE.md`](SPEC-CORE.md) (subset
  regulatory for self-hosted bootstrap) and `conformance/core/` suite with 29 shared cases
  with Triad-Full.
- **Seed M3b1/M3b2a**: the seed in machine code **interprets** Triad-Core: `println` of
  integer expressions with `+ - *`, parentheses, unary `-`, comments (M3b1) and then variables
  globals with assignments and lookups by name (M3b2a). 8704 byte PE, no runtime; cases
  Core suite `integers` and `variables` checked byte by byte.
- **Seed M3b2b1**: the seed interprets **short form functions with parameters**: definition
  `f(x, y) = expr`, call, dynamic environments with shadowing/truncation, composition of
  functions; Core case `simple_functions` checked byte by byte. 8704 byte PE,code
  1998 bytes, no runtime.
- **Seed M3b2b2**: added **comparisons** (`== != < <= > >=` → `0/1`), **short ternary**
  `c ? a : b` (the unchosen branch is scanned without evaluating it) and then **recursion with
  base case** (`factorial`, `fib`); Core `recursion` case checked byte by byte.
  Code 2611 bytes.
- **Seed M3b2b3a**: **tagged** values (`Int = n<<1`, `Bool false = 1`, `Bool true = 3`):
  comparisons produce Bool and `println` prints `true`/`false`; arithmetic and comparisons
  they untag/re-tag. Core case `compares` checked byte by byte; code 2892 bytes.
- **Seed M3b2b3b**: added `%` (signed remainder), `^` (right-bound, precedence above
the unary) and `true`/`false` literals; Core case `operators` checked byte by byte e
  semantics compared to stage0 (`-2^2=-4`, `2*3^2=18`, `2^3^2=512`). Code 3112 bytes.
- **Seed M3b2b3c**: Added **`if`/`else`/`end`** blocks with branch selection, execution
  block recursion and depth scanning for `else`/`end` (nesting); Core case
  `if_else` checked byte by byte. Code 3706 bytes.
- **Seed M3b2b3d**: added **`while`/`end`** with condition reevaluated every round and
  depth scan that also counts nested `while`s; the assignment now **updates**
  the most recent variable (`env_assign`) instead of appending an entry per iteration. Case
  Core `while_loop` checked byte by byte. Code 4002 bytes.
- **Seed M3b2b3e**: 2-bit tag (`Int=n<<2`, `false=1`, `true=5`, closure=`ptr|2`) and
  **one-parameter lambda** `x -> expr`, with 128-byte records in a dedicated heap
  (256 KiB of `VirtualAlloc`), also callable from variable/passed as argument; case
  Core `lambda` checked byte by byte. Dynamic scoping (no room capture).
  Code 4415 bytes.
- **Seed M3b2b3q**: Checked and covered concatenated concatenation `a * b * c` with `length`; new Core case `multi_strings` (no code changes, hash unchanged).
- **Seed M3b2b3p**: symbols `:name` (string object with name, print without `:`) and new green Core case `symboli_base` (code 6866 bytes).
- **Seed M3b2b3o**: string concatenation with `*` (heap allocation and copying of the two buffers, preserving the parser cursor), new green Core `concat_strings` case. IAT area moved to RVA `0x2C00` for grown code (6680 bytes); `string()` remains to be done.
- **Seed M3b2b3n**: added `nothing` value (static object type 4, prints `nothing`); new green Core `nothing_base` case (code 6451 bytes). Concatenation `*` and `string()` attempted but postponed (unstable); the seed remains on strings base + `nothing`.
- **Seed M3b2b3m**: strings as heap objects (`[type=1][len][byte…]`, value `ptr|3`), parsing literals, printing via `WriteFile`, builtin `length`; IAT area moved to RVA `0x2A00` to make room for code; new green `base_strings` Core case (code 6269 bytes).`n- **Seed M3b2b3l**: added `begin … end` (executed with stop mask) and **CI GitHub Actions** (`.github/workflows/ci.yml`: Full/Core conformance on Ubuntu and Windows, seed cases on Windows, hash check); new green `begin_block` Core case (code 5891 bytes).`n- **Seed M3b2b3k**: **capture-by-value closures** of the last frame binding (parameter or local), re-added to the call above the marker; Core closure cases and green closures; scan_end also counts nested unction/let (code 5743 bytes).
- **Seed M3b2b3j**: **lexical frames** in calls (markers in the environment; local assignments without touching globals) and **let name = expr … end** with local binding; green Core scope case (code 5584 bytes).
- **Seed M3b2b3i**: body of block functions on **multiple instructions** (assignments and expressions) with value of the last expression; expressions like statement and lock value at the end of the source; new case Core unctions_green block (code 5303 byte).
- **Seed M3b2b3h**: added the unction block form f(x, …) <expression> end (body to an expression, end identified by scan_end); the case Core unctions passes byte by byte (code 5097 bytes).
- **Seed M3b2b3g**: added !, &&/|| (bitwise on Bool tags) and +=; the Core Rithmetic case passes byte by byte (code 4763 bytes).
- **Seed M3b2b3f (attempt, unstable)**: added capture fields to closing record; the
  binding to the call was found to be unreliable and has been removed. The seed remains at the state
  stable lambda (code 4570 bytes); the `closure` case only passes on stage0. Capture
  sent back to AST/bytecode or captured frames.
- **Seed dev tooling**: PE development generator in `seed/dev/gen_seed.js` with README;
  the dump remains the source, reproducibility is verified by the hash
  `C7915C02…0BF75FAC` and the generator is not used by the S0→S4 chain.
- First draft of the **Triad-Core** subset required by the seed in machine code.
## 0.1.0 — initial
- Kernel S-expression `legacy/triad_sexpr_v1.jl` (historical).