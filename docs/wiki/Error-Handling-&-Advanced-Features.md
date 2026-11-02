# Error Handling & Advanced Features

[⬅ Home](Home.md)

Triad's central promise: **failure is information, not catastrophe.** This page covers errors-as-data, contracts, budgets, traces and effects (manual §11–§15).

## Errors are values (manual §11)

An error is a normal value of type `Err`. It flows through calls, gets stored in lists, gets returned from functions — like any other datum. Nothing unwinds implicitly.

```triad
# [Full] producing and propagating (§11.2)
safe_div(a, b) {
    if b == 0 { Err(:domain, "division by zero") }
    else { a / b }
}
```

In **Core** today the same idea exists in reduced form: errors are tagged lists (§11.4) that you inspect and forward manually. The category taxonomy (`:type`, `:domain`, `:budget`, `:not_found`, …) is defined in §11.3.

Why this matters: no hidden control flow. Every failure path is visible in the types and in the data your program passes around; testing failures means comparing values, not catching exceptions.

## Contracts (manual §12)

`requires` / `ensures` clauses attach to functions. A violated clause becomes an `Err` value **carrying the failing clause itself** — so callers can see *which* condition broke, not just that something did.

```triad
sqrt(x) requires x >= 0 ensures result * result <= x { … }
```

Contracts are checked at call boundaries; they are documentation, test, and runtime guard expressed once.

## Budgets (manual §13)

Evaluation is bounded on demand:

```triad
with budget(steps = 100) { runaway_search() }   # → Err(:budget) when exhausted
```

A runaway recursion or infinite loop consumes its budget and yields an error value instead of hanging the process. Budgets compose: nested scopes get their own allowance.

## Traces (manual §14)

`with trace { … }` collects execution events as a first-class value you can store, filter, and count. The event vocabulary follows Byrd ports (call, exit, fail, redo — glossary in §14). Example from the manual: counting failures of a search without printing anything.

## Declared effects (manual §15)

Functions are pure unless their signature declares capabilities:

```triad
ask(prompt)!io { read_line(prompt) }     # I/O must be declared
counter(n)!state { … }                   # stateful mutation must be declared
```

The runtime checks declarations against actual operations: an undeclared effect is an error value, not a silent escape. This keeps referential transparency available wherever it isn't explicitly traded away.

## `try` / `catch` [Full] (manual §5.6)

For ergonomics, `try { … } catch e { … }` exists as *syntactic sugar over value inspection* — it does not introduce exception control flow beyond what errors-as-values already provide.

## See also

- [Syntax Reference](Syntax-Reference.md) — grammar positions of these constructs
- [Logic Programming](Logic-Programming.md) — where `Err(:budget)` meets backtracking
- [`SPEC.md`](../../SPEC.md) §errors/contracts/budgets/traces/effects — normative text
