# Post release — v0.8.0-beta.8 (da copiare e incollare)

> ⚠️ Da fare prima di pubblicare: `CHANGELOG.md` e `README.md` non contengono ancora la sezione beta.8 (VERSION è 0.8.0-beta.8). Aggiungerla per mantenere i file allineati, come richiesto dalle regole del progetto.

## Versione per GitHub Release (titolo + corpo, Markdown)

**Titolo:**
```
Triad 2.0 — v0.8.0-beta.8: merge resolution, security fixes & website restoration
```

**Corpo:**
```markdown
🎉 **Triad 2.0 v0.8.0-beta.8** is out (2026-10-31)!

> Triad 2.0 is a programming language that bootstraps itself: the compiler is
> written in Triad and compiled by its own previous version — no host language
> required (S0→S4 bootstrap). This release consolidates the Termux support work
> and hardens CI/security tooling.

This release resolves the merge between `main` and `termux-with-triad-7086e`,
fixes two security alerts (CodeQL + Bandit), restores the website assets that
were accidentally removed, and cleans up the repository. All tests pass:
conformance **37/37 Core**, security suite **PASS**.

### 🔒 Security
- Fixed CodeQL `js/incomplete-multi-character-sanitization`: `build-libro.mjs`
  now uses a Node-safe `stripTags` + `escapeHtml` instead of `DOMParser`.
- Fixed Bandit B603 in `download_chart.py`: static command list with
  `executable=git_bin`.
- Disabled conflicting CodeQL default setup — the advanced workflow now runs cleanly.

### 🛠️ Fixed
- Resolved merge conflicts between `main` and `termux-with-triad-7086e` (termux changes preferred).
- Restored homepage assets `docs/assets/css/style.css` and `docs/assets/js/learning-curve.js`.
- Deduplicated code in `detect-project.sh` (global-bucket and SHA-256 helpers extracted).

### ✅ Quality
- Working tree clean; full test suite green (conformance 37/37, security PASS).

### 📦 Downloads
| Asset | Platform | SHA-256 |
|---|---|---|
| `triad-seed-windows-x86_64.zip` (10 KB) | Windows x86-64 runtime | `930c8011ce306f3bc4a904fe696e3d3a9d8889512a9a1a74ab5f19912f49cd03` |
| `triad-seed-linux-x86_64.tar.gz` (454 B) | Linux x86-64 runtime (ELF E0) | `9f58b55bd19fec5823cd1b8ae08ccd77c750e3dc0aa56d8886d9d0c322b3fd09` |
| `triad-source.zip` (500 KB) | Any OS + Node.js ≥ 20 | `f331d4bf43eca3f19e91f2edae7e326b2ed68ba5f53768de13a17d4e381c86a4` |
| `triad-source.tar.gz` (423 KB) | Any OS + Node.js ≥ 20 | `19e02ad53778a431c7a9665c9081c89770c1e4962cb00f3a4c86cecb896b83c9` |

**Full Changelog**: https://github.com/GPuntobit/triad2.0/compare/v0.8.0-beta.7...v0.8.0-beta.8
```

## Versione breve per social (X / Mastodon / LinkedIn)

```
🚀 Triad 2.0 v0.8.0-beta.8 released!

Merge resolution main↔termux, 2 security fixes (CodeQL + Bandit),
website assets restored, repo cleanup. Conformance 37/37 Core ✅

A language that bootstraps itself — no host language required.

📦 github.com/GPuntobit/triad2.0/releases/tag/v0.8.0-beta.8

#Triad #PLT #programminglanguages #opensource
```
