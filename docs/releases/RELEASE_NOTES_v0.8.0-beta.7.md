# Triad 2.0 — v0.8.0-beta.7 (2026-10-31)

**Security hardening, CI integrity & repository cleanup.** Full change list in
[CHANGELOG.md](../../CHANGELOG.md). Highlights below.

## What's changed

### Security (all findings from CodeQL/Codacy closed)
- **HIGH** — `where.exe` resolution no longer trusts `%SystemRoot%`: validated as
  an absolute `<drive>:\windows` path, with rejection of UNC/relative/traversal
  values and a fixed fallback to `C:\WINDOWS\System32`. A project-controlled
  `where.exe` can never be executed (regression test included).
- **MEDIUM** — `git` is resolved to a trusted absolute executable before
  `subprocess.run` in the download-chart script: canonical system paths first;
  `shutil.which` results accepted only if absolute, real (post-`realpath`),
  executable and outside the repository. Argument-list invocation, `shell=False`,
  repo cwd and the unavailable-git fallback preserved.
- **ReDoS guard** — linear-time `_is_safe_tag_line()` pre-validation of git tag
  lines before regex processing, with worst-case regression tests.
- **Sanitization fix** — escape substitutions in the learning-v2 CLI iterate to a
  fixpoint, so nested fragments (`<scr<script>ipt>`) cannot reconstruct a
  `<script>` tag.
- **Actions pinned** — every GitHub Action reference uses a full immutable commit
  SHA (checkout@v7, setup-node@v7, configure-pages@v6, upload-pages-artifact@v5,
  deploy-pages@v5, codeql-action@v3, setup-dotnet@v4), verified against the API.
- **Runner stability** — all Linux jobs pinned to `ubuntu-24.04` ahead of the
  `ubuntu-latest` → Ubuntu 26 migration (actions/runner-images#14748).

### Added
- `tests/security/` — repeatable verification suite (`bash tests/security/run.sh`,
  5 checks covering everything above plus relocated-path integrity).
- `.github/workflows/codeql.yml` + `.github/codeql-config.yml` — C#/JS/Python
  scanning; the C# job builds on `windows-2022` (autobuild) so call targets and
  expression types resolve. New `cli/windows-gui/TriadDesktop.csproj` enables it.
- `wiki/` — 10-page English project wiki (Home, Getting Started, Language Guide,
  Syntax Reference, Error Handling & Advanced Features, Logic Programming,
  Code-as-Data & Macros, Project Status, Repository Architecture, Contributing).
- Website generated **with Triad itself**: `tools/site-gen/generate_site_core.td`
  emits `docs/pages/generated.html` using only Triad-Core constructs; playground
  bundle rebuilt; Termux install path documented in README.
- `.github/config.yml` — versioned CodeRabbit configuration.

### Fixed
- Broken CI: removed the empty leftover `obsidian-triad/github-wiki/` gitlink that
  failed submodule sync ("No url found for submodule path … in .gitmodules").
- `build-libro.mjs` crashed writing to a non-existent `docs/libro/`; output dir is
  now created automatically.
- Two empty files accidentally committed in the root were deleted (`Developer`,
  `install-triad-ext.bat`).

### Repository structure (three-pass cleanup, released here)
- Probes → `probes/`; long-form docs → `docs/`; release notes → `docs/releases/`;
  PR drafts → `docs/worklog/`; webcmd plugin → `tools/webcmd-graphify/`; push
  helper → `tools/`; `scripts/` split into `docs/`, `seed-runner/`,
  `experiments/`; tutorial translations consolidated in `tutorial/`.
- Contract paths unchanged: `bin/`, `seed/<platform>/`, `conformance/`, `selfhost/`,
  `examples/`, `probes/`, `cli/`, `editors/`, `VERSION`, `LICENSE`, `install.sh`.

## Downloads

| Asset | Platform | SHA-256 |
|---|---|---|
| `triad-seed-windows-x86_64.zip` (10 KB) | Windows x86-64 runtime | `930c8011ce306f3bc4a904fe696e3d3a9d8889512a9a1a74ab5f19912f49cd03` |
| `triad-seed-linux-x86_64.tar.gz` (454 B) | Linux x86-64 runtime (ELF E0) | `9f58b55bd19fec5823cd1b8ae08ccd77c750e3dc0aa56d8886d9d0c322b3fd09` |
| `triad-source.zip` (7.6 MB) | Any OS + Node.js ≥ 20 | `73e40bd543f0a82de23f930a4243938e5d60f1f059e850e073f86aea8db10602` |
| `triad-source.tar.gz` | Any OS + Node.js ≥ 20 | `93eec488042138ba000534065b4c8aabe723fb318c6adc3353a23eeba2c5eb7b` |

Inner binaries (verified identical to the repository files):
`seed/windows-x86_64/seed.exe` — `f2352418485383038952748e5e2767662ba5cca724c7f4195b672e254fa6b7ce`;
`seed/linux-x86_64/seed` — `6d504451e1d8a39c6e139a8a120bfaf03373131894292be12f0039eb8a7797f9`.

Reference interpreter used by the conformance runner and the Termux/Node fallback:
`seed/dev/triad_core.cjs` — SHA-256
`5e04a91b7e98f382eb3cda44f14157025dab21b0fef9d00af83c0e8bb84d02f5`.

### Install (recommended)
```sh
# Linux/macOS (also works on Termux via the Node.js fallback)
git clone https://github.com/GPuntobit/triad2.0.git && cd triad2.0
sh install.sh            # installs bin/triad launcher + PATH hint
triad demo.td            # prints 42
node conformance/run.mjs # conformance: OK
```

### Verify downloads manually
```sh
unzip -p triad-seed-windows-x86_64.zip seed/windows-x86_64/seed.exe | sha256sum
tar -xzOf triad-seed-linux-x86_64.tar.gz seed/linux-x86_64/seed | sha256sum
```
Compare against the table above (PowerShell: `Get-FileHash -Algorithm SHA256`).

## Also in this release (consolidated)
- English project wiki (`wiki/`, 10 pages) and repository folder reorganization
  (probes → `probes/`, docs → `docs/` + `docs/releases/` + `docs/worklog/`,
  scripts split by purpose, tutorial translations consolidated in `tutorial/`).
- Website generated with Triad itself (`tools/site-gen/`) and GitHub Pages
  updated to the Triad-generated site; CodeRabbit configuration versioned
  (`.github/config.yml`).
- Fixed broken CI submodule sync (orphan gitlink `obsidian-triad/github-wiki`)
  and the `build-libro.mjs` output-directory crash.
- `examples/benvenuto.triad` repaired: it now runs end-to-end with the
  reference interpreter (`triad examples/benvenuto.triad` →
  `Benvenuto in Triad`). The remaining `.td` showcase files use Triad-Full
  constructs (facts/rules/solve, contracts, macros) that are spec'd but not yet
  runnable until the self-hosted runtime lands — labeled as such on the site.

## Compliance status at this release
- Triad-Core: 37/37 executable conformance cases pass with the reference
  interpreter; 33 Core cases run on the Windows PE seed in CI.
- Triad-Full: specified (SPEC 0.2.0); golden cases present, runtime pending the
  self-hosted bootstrap (BOOTSTRAP.md roadmap).

**Full Changelog**: https://github.com/GPuntobit/triad2.0/compare/v0.8.0-beta.6...v0.8.0-beta.7
