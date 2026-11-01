# Project Status

[⬅ Home](Home.md) · source of truth: [`STATUS.md`](../../STATUS.md), [`CHANGELOG.md`](../../CHANGELOG.md), [`VERSION`](../../VERSION) (standard `0.2.0`)

## What runs today

| Capability | Status |
|---|---|
| **Triad-Core** language profile | ✅ Executable: JS reference interpreter `seed/dev/triad_core.cjs` passes **37/37** Core conformance cases; the Windows x86-64 seed (`seed/windows-x86_64/seed.exe`) verifies 33 Core cases in CI; Linux x86-64 ELF seed available |
| **Termux / ARM64 / macOS** | ✅ Via Node.js fallback (Core only) — see [Getting Started](Getting-Started.md) |
| **Triad-Full** constructs (struct, dispatch, logic, macros, contracts, budgets, traces, effects, destructuring, `for`, `try`, `Float`) | 📝 Specified normatively ([`SPEC.md`](../../SPEC.md)); Full conformance currently has golden expectations only — 1/12 chapters (errors) fully runnable end-to-end |
| Self-hosted compiler/runtime | 🚧 Roadmap documented in [`BOOTSTRAP.md`](../../BOOTSTRAP.md); no ARM64 native seed yet |

## Release line

Recent releases: v0.3.0 and v0.8.0-beta series up to beta.6+ (notes under [`docs/releases/`](../releases/)). The changelog is [`CHANGELOG.md`](../../CHANGELOG.md).

## Repository health

- **CI:** GitHub Actions workflows pinned runner images (`ubuntu-24.04`, ahead of the 2026-10-19 `ubuntu-latest` → Ubuntu 26 migration) with all actions pinned to full commit SHAs.
- **Security:** reviewed and hardened — trusted-path resolution for `where.exe` (no reliance on `%SystemRoot%`), git resolved to a trusted absolute executable before `subprocess.run`, Python inline parsers isolated (`-I -S`), ReDoS-safe tag-line validation. Details: [`SECURITY.md`](../../SECURITY.md), [`SECURITY-REVIEW.md`](../security/SECURITY-REVIEW.md), regression suite `tests/security/run.sh`.
- **Conformance:** `node conformance/run.mjs` → `conformance: OK` on every merged PR.

## Known honest limitations

1. Full-profile examples in docs are **golden outputs** frozen from earlier prototype implementations — they define expected behavior but aren't executed by today's runtime.
2. The machine-code seed S0 is closed-format binary tooling; the readable reference implementation is the JS interpreter.
3. Performance work (benchmarks) targets the post-bootstrap runtime.

## See also

- [Repository Architecture](Repository-Architecture.md) — where each piece lives
- [Contributing Guide](Contributing-Guide.md) — how changes get validated
