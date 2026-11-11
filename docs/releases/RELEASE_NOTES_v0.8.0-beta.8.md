# Triad 2.0 — v0.8.0-beta.8 (2026-10-31)

**Merge resolution, security fixes, website restoration & repository cleanup.**
Full change list in [CHANGELOG.md](../../CHANGELOG.md). Highlights below.

## What's changed

### Fixed
- Resolved merge conflicts between `main` and `termux-with-triad-7086e` (prefer termux changes).
- Fixed `build-libro.mjs` crash: replaced `DOMParser` (unavailable in Node.js) with
  a Node-safe `stripTags` + `escapeHtml` to satisfy CodeQL incomplete-sanitization.
- Fixed Bandit B603 in `download_chart.py`: static command list with `executable=git_bin`.
- Restored website assets removed by main: `docs/assets/css/style.css` and
  `docs/assets/js/learning-curve.js` (CSS/JS for the homepage).
- Removed duplicated code in `detect-project.sh` (global-bucket and sha256 hash snippets
  extracted into helper functions).

### Security
- CodeQL `js/incomplete-multi-character-sanitization` alert fixed (char-by-char tag
  stripping + HTML escaping in TOC).
- Disabled conflicting CodeQL default setup; advanced workflow now runs cleanly.

### Repository
- Cleaned working tree; all tests pass (conformance 37/37, security PASS).

## Downloads

| Asset | Platform | SHA-256 |
|---|---|---|
| `triad-seed-windows-x86_64.zip` (10 KB) | Windows x86-64 runtime | `930c8011ce306f3bc4a904fe696e3d3a9d8889512a9a1a74ab5f19912f49cd03` |
| `triad-seed-linux-x86_64.tar.gz` (454 B) | Linux x86-64 runtime (ELF E0) | `9f58b55bd19fec5823cd1b8ae08ccd77c750e3dc0aa56d8886d9d0c322b3fd09` |
| `triad-source.zip` (500 KB) | Any OS + Node.js ≥ 20 | `f331d4bf43eca3f19e91f2edae7e326b2ed68ba5f53768de13a17d4e381c86a4` |
| `triad-source.tar.gz` (423 KB) | Any OS + Node.js ≥ 20 | `19e02ad53778a431c7a9665c9081c89770c1e4962cb00f3a4c86cecb896b83c9` |

**Full Changelog**: https://github.com/GPuntobit/triad2.0/compare/v0.8.0-beta.7...v0.8.0-beta.8
