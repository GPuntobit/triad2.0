# Language Guide

[⬅ Home](Home.md) · [Syntax Reference ➡](Syntax-Reference.md)

This page distills the manual ([`docs/MANUALE.md`](../docs/MANUALE.md), Italian) into an English overview. For the normative text use [`SPEC-CORE.md`](../SPEC-CORE.md) and [`SPEC.md`](../SPEC.md); for exercises and solutions use the [Tutorial](../tutorial/TUTORIAL.md).

## Design principles

1. **Code is data.** The parser produces exactly one node type, `Node(head, args)`, which is both what the kernel evaluates and what `:( … )` quotes into a value. There is no parallel representation between "syntax" and "data".
2. **Errors are values.** Failures produce `Err(…)` values that propagate like any other data instead of unwinding the stack. Contracts violations become `Err` values carrying the failing clause.
3. **Bounded execution by default.** Computations can carry step budgets (`with budget(steps = N)`); runaway recursion returns `Err(:budget)` rather than hanging.
4. **Pure functions, declared effects.** Functions are pure unless their signature declares effect capabilities (`!io`, `!state`), checked at runtime.
5. **One syntax, three paradigms.** Imperative-ish blocks, multiple dispatch, and logic programming (`fact` / `rule` / `solve`) share the same grammar and evaluation model.

## Lexicon (Core)

- **Identifiers:** letters, digits, `_`; leading letter. Conventional names documented in the manual §1.9.
- **Numbers:** integers (`Int`) today; `Float` is Full-only.
- **Strings:** double quotes with escapes (§1.10); **symbols**: `:name`.
- **Comments:** `# line` and `#= block =#`.
- **Keywords:** listed in manual §1.8; the colon/question-mark rule (§1.7) governs call vs. predicate naming.

## Values and types

Core types: `Int`, `Bool`, `String`, `Symbol`, `List`, `Function`, `Err`, `Nil`. Full adds declared types, `struct`, `Float`, and the type hierarchy (manual §2). Every example in the docs declares its profile: **[Core]** runs today; **[Full]** is specified but not yet executed end-to-end.

## Variables and assignment

```triad
let x = 10        # binding
set x = x + 1     # mutation of an existing binding
```

`let` introduces a scope-local binding; `begin … end` blocks give explicit scoping (manual §3, §5.3).

## Control flow

```triad
if x > 0 { print("positive") } elseif x == 0 { print("zero") } else { print("negative") }   # [Core]

while i < 10 { set i = i + 1 }          # break / continue supported  [Core]

for i in 1..10 { print(i) }             # ranges                        [Full]
[x * 2 for x in xs if x > 0]            # comprehensions                [Full]
try { risky() } catch e { e }           #                               [Full]
```

## Functions

Three definition forms (manual §6.1):

```triad
f(x) = x * x                    # short form: body is an expression
g(x) { let y = x + 1            # block form: value is the last expression
       y * y }
h = \(x) -> x + 1               # anonymous function bound to a name
```

- `return`, recursion, arity rules: §6.2. Higher-order functions: §6.3.
- Effect annotation `!io` marks impure functions: §6.4.
- Closures capture their defining environment; scope rules in §8.

## Lists and strings

Lists are immutable linked structures in Core, built with `[1, 2, 3]`, `cons`, `head`, `tail`; idiomatic patterns (association-list environments, tagged-list records, string building) are collected in manual §22. String/symbol conversions: §10.

## Multiple dispatch (Full)

Methods specialize on the runtime types of **all** arguments (§7). Declared return types and local functions: §7.1–7.2.

## Logic programming (Full)

Top-level `fact`, `rule` and `solve` with unification (occurs-check) and backtracking — see [Logic Programming](Logic-Programming.md).

## Errors as data (Core subset, Full shape)

See [Error Handling & Advanced Features](Error-Handling-%26-Advanced-Features.md).

## Builtin functions and bootstrap primitives

The builtin table is manual §19; the bootstrap primitives (§21) are what the self-hosting compiler will eventually consume. Idiomatic style rules: §22.6.

## Exercises

Guided Core exercises (powers, primes, insertion sort, word counter, mini lexer/expression evaluator, dictionary environment) and Full exercises (dispatch on structs, knowledge base, contracts, a measuring macro) live in the Tutorial parts II–III and manual §23–24.
