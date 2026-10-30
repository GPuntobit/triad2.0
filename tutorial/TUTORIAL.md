<p align="center">
  <img src="https://raw.githubusercontent.com/GPuntobit/triad2.0/main/docs/triad-logo.webp" alt="Triad logo" width="160">
</p>

# Triad 2.0 — Tutorial: learning the language and the project code

This tutorial is the guided path with which you learn Triad starting from zero. It does not
assume that you know the language: it assumes only that you know how to program in
some other language. If you can already write loops, functions and lists, you have everything
you need; the rest — Triad's syntax, the behavior of values, the distinction between the
executable subset and the complete standard — is explained here, in the order in which it is
best learned.

The path leads to three results. First, **writing Triad-Core programs that really run**,
that is complete programs, executable today with the reference interpreter. Second,
**knowing Triad-Full**, the complete language defined by the standard, including the parts
that the current runtime does not execute yet. Third, **being able to read the project code**:
the reference interpreter, the machine-code seed, the conformance suite and the development
tools. The tutorial does not refer elsewhere to understand concepts: the specification
(`SPEC.md`, `SPEC-CORE.md`) and the cases in `conformance/` are optional deep dives, not
prerequisites.

## What you learn and how it is organized

The tutorial is a book in five parts, meant to be read in order but autonomous enough to be
consulted separately.

- **Part I — First steps.** What Triad is, how to install and run it, the first program
  explained line by line.
- **Part II — Triad-Core step by step.** The subset executable today, construct by construct:
  lexicon, values, variables, expressions, control flow, functions, closures, lists, strings,
  bootstrap primitives, errors and differences between runtimes. The guided exercises at the
  end of the part serve to fix what you read.
- **Part III — Triad-Full (the complete standard).** Declared types, multiple dispatch,
  struct, `for` and comprehensions, logic with facts and rules, macros, contracts, budgets,
  traces and effects. It is the language defined by the specification: here you study it, but
  the current runtime does not execute it yet.
- **Part IV — The project code.** A guided tour of the repository: the reference interpreter,
  the seed, S1, the conformance cases, the CLI, the benchmark, the contribution flow. It serves
to understand how the language is implemented, not just how it is used.
- **Part V — Reference.** Grammar, quick cards, error messages, glossary, project status and
  FAQ: chapters to consult rather than read in sequence.

**What «executable today» means.** The Triad standard defines two conformance profiles. An
example is *executable today* when it runs, without changes, on an implementation that already
exists in the repository; it is *defined by the standard* when the specification describes it
but no current runtime executes it. The tutorial always distinguishes the two cases, and every
code block declares the profile it belongs to.

| profile | where it is defined | executable today? |
|---|---|---|
| **Triad-Core** | `SPEC-CORE.md` | **yes**: JavaScript reference interpreter `seed/dev/triad_core.cjs` (37/37 Core cases) and, in part, the Windows seed `seed/windows-x86_64/seed.exe` (33 Core cases verified in CI) |
| **Triad-Full** | `SPEC.md` | **no**: struct, dispatch, logic, macros, contracts, budgets, traces, effects, destructuring, `for`, `try`, `Float` are specification; in Full conformance only `errore` passes |

Two clarifications about the context, useful so as not to confuse the book with the project. The
standard version is `0.2.0`, recorded in `VERSION`. Triad does not depend on Julia: that old
implementation has been removed, and the Triad-Full outputs you read in the book are the
**goldens**, that is the expected results produced at the time by that implementation and frozen
in `conformance/cases/`; they have not been reproduced by the current runtime. By contrast,
every example marked **Output:** is a Triad-Core program verified with
`node seed/dev/triad_core.cjs`; Full examples are marked **Output (golden Full):** or
