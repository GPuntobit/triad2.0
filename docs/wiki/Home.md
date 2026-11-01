![Triad Logo](https://raw.githubusercontent.com/GPuntobit/triad2.0/main/docs/triad-logo.webp)

# Triad Wiki

**Triad** is a standalone programming language: block syntax with declared types, multiple dispatch, integrated logic programming, and code-as-data — all in a single syntax. Its definition is a normative specification independent of any implementation ([`SPEC.md`](../../SPEC.md), standard `0.2.0`), accompanied by an executable core specification ([`SPEC-CORE.md`](../../SPEC-CORE.md)) and a conformance suite with verifiable golden cases ([`conformance/`](../../conformance/README.md)).

This wiki is the English entry point to the project documentation. The full manual ([`docs/MANUALE.md`](../MANUALE.md), currently Italian-only) is organized as a book; these pages reorganize it into a browsable reference.

## Quick links

| I want to… | Go to |
|---|---|
| Install and run my first program | [Getting Started](Getting-Started.md) |
| Learn the language from scratch | [Language Guide](Language-Guide.md) → [Tutorial](../tutorial/TUTORIAL.md) |
| Look up a construct (loops, closures, lists…) | [Syntax Reference](Syntax-Reference.md) |
| Understand errors, contracts, budgets, traces, effects | [Error Handling & Advanced Features](Error-Handling-%26-Advanced-Features.md) |
| Use facts, rules and `solve` | [Logic Programming](Logic-Programming.md) |
| Write macros / understand `Node(head, args)` | [Code as Data & Macros](Code-as-Data-%26-Macros.md) |
| Know what runs today vs. what is only specified | [Project Status](Project-Status.md) |
| Read the interpreter, seed and conformance code | [Repository Architecture](Repository-Architecture.md) |
| Contribute | [Contributing Guide](Contributing-Guide.md) |

## The two compliance profiles

The standard defines two profiles, and every example in this wiki declares which one it belongs to:

| Profile | Defined in | Runnable today? |
|---|---|---|
| **Triad-Core** | [`SPEC-CORE.md`](../../SPEC-CORE.md) | **Yes**: JavaScript reference interpreter `seed/dev/triad_core.cjs` (37/37 Core cases) and, partially, the Windows seed `seed/windows-x86_64/seed.exe` (33 Core cases verified in CI) |
| **Triad-Full** | [`SPEC.md`](../../SPEC.md) | **No**: struct, dispatch, logic, macros, contracts, budgets, traces, effects, destructuring, `for`, `try`, `Float` are specified but not yet executed end-to-end by a runtime |

## Project at a glance

- **Repository:** https://github.com/GPuntobit/triad2.0
- **Website:** https://gpuntobit.github.io/triad2.0
- **Standard version:** `0.2.0` (recorded in [`VERSION`](../../VERSION))
- **License:** MIT ([`LICENSE`](../../LICENSE))
- **Security policy:** [`SECURITY.md`](../../SECURITY.md)
- **Bootstrap roadmap (self-hosting):** [`BOOTSTRAP.md`](../../BOOTSTRAP.md)
- **Status & changelog:** [`STATUS.md`](../../STATUS.md), [`CHANGELOG.md`](../../CHANGELOG.md)

*Wiki generated from the project sources on 2026-10-30. To regenerate after doc changes, update these pages manually or ask for a refresh.*
