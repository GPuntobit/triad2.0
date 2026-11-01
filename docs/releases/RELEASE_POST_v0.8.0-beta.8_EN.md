# Release post — v0.8.0-beta.8 (English, copy & paste)

## GitHub Release

**Title:**

```
Triad 2.0 — v0.8.0-beta.8: A Cleaner, Safer Step Toward Self-Hosting
```

**Body:**

```markdown
Triad 2.0 is a programming language that bootstraps itself: the compiler is
written in Triad and compiled by its own previous version — no host language
required. Every release brings it one step closer to full self-hosting, and
v0.8.0-beta.8 is no exception.

This release began as a consolidation task. Two long-running branches — `main`
and the Termux support branch — had drifted apart, and bringing them back
together surfaced more issues than expected. What follows is the story of what
we found and fixed along the way.

**Merging two futures.** The merge between `main` and the Termux branch was
resolved with a clear rule: where the two disagreed, the Termux work won,
because it carried the newer platform support. But resolving conflicts is only
half the job — after the merge, the homepage was silently broken. Key assets
(`style.css` and `learning-curve.js`) had been dropped somewhere along the way,
so we restored them and verified the site renders exactly as intended again.

**Closing the security gaps.** Our scanners flagged two real problems, and we
fixed both properly rather than suppressing them. The site builder
(`build-libro.mjs`) relied on `DOMParser`, which doesn't exist in Node.js —
ironic for a build script — so we replaced it with an explicit, character-by-character
sanitization plus HTML escaping that satisfies CodeQL's incomplete-sanitization
check. The download-chart tool was invoking `git` in a way Bandit flagged
(B603); it now uses a static command list with a validated executable path. We
also disabled the conflicting CodeQL default setup so the advanced workflow runs
cleanly from now on.

**Small hygiene, big payoff.** We extracted duplicated logic in
`detect-project.sh` into shared helper functions, cleaned the working tree, and
ran everything: conformance suite **37/37 Core**, security suite **PASS**. No
regressions, no known alerts.

If you want to try Triad today, the source seed works on any OS with Node.js ≥ 20,
and prebuilt runtime seeds are available for Linux and Windows.

### Downloads

| Asset | Platform | SHA-256 |
|---|---|---|
| `triad-seed-windows-x86_64.zip` (10 KB) | Windows x86-64 runtime | `930c8011ce306f3bc4a904fe696e3d3a9d8889512a9a1a74ab5f19912f49cd03` |
| `triad-seed-linux-x86_64.tar.gz` (454 B) | Linux x86-64 runtime (ELF E0) | `9f58b55bd19fec5823cd1b8ae08ccd77c750e3dc0aa56d8886d9d0c322b3fd09` |
| `triad-source.zip` (500 KB) | Any OS + Node.js ≥ 20 | `f331d4bf43eca3f19e91f2edae7e326b2ed68ba5f53768de13a17d4e381c86a4` |
| `triad-source.tar.gz` (423 KB) | Any OS + Node.js ≥ 20 | `19e02ad53778a431c7a9665c9081c89770c1e4962cb00f3a4c86cecb896b83c9` |

**Full Changelog**: https://github.com/GPuntobit/triad2.0/compare/v0.8.0-beta.7...v0.8.0-beta.8
```

## Short version for social media (X / Mastodon / LinkedIn)

```
🚀 Triad 2.0 v0.8.0-beta.8 is out!

A language that bootstraps itself — no host language required.

This release merged our Termux branch into main, restored the broken homepage
assets, closed two security alerts (CodeQL + Bandit), and finished green:
conformance 37/37 Core ✅

📦 github.com/GPuntobit/triad2.0/releases/tag/v0.8.0-beta.8

#Triad #PLT #programminglanguages #opensource
```
