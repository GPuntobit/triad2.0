# Logic Programming

[⬅ Home](Home.md) · profile: **[Full]** (specified in [`SPEC.md`](../../SPEC.md); not yet executed end-to-end by a runtime — see [Project Status](Project-Status.md))

Triad integrates logic programming as **top-level constructs**, not an embedded DSL or a foreign query engine. Facts, rules and queries share the grammar, the value model and the error discipline of the rest of the language.

## Facts, rules, terms (manual §16.1)

```triad
fact parent(tom, bob).
fact parent(bob, ann).

rule ancestor(X, Y) :- parent(X, Y).
rule ancestor(X, Z) :- parent(X, Y), ancestor(Y, Z).
```

Terms are variables (`X`, uppercase), atoms/symbols, compound structures and lists. A `fact` asserts ground data into the program's knowledge base; a `rule` is a clause with a head and a body of goals.

## Goals (manual §16.2)

Goals are predicates called in rule bodies or in queries: conjunctions (`A, B`), calls with partially bound arguments, and recursion. Resolution proceeds by **unification with occurs-check** and **backtracking** over matching clauses.

## `solve` returns values (manual §16.3)

The key design decision: querying does not print, throw, or escape. It produces data:

```triad
let answers = solve ancestor(tom, W)
# answers → list of bindings/values for W
```

Empty result = empty list. Multiple solutions = multiple elements. Failure of a subgoal is just failure — it drives backtracking, nothing else. Because results are values, you can filter, map, count, and store them like any list.

## Predicates as functions (manual §16.4)

A predicate name used in a functional position yields truth-value behavior compatible with the boolean rules (§2.7): conditions accept only `Bool`, so predicate calls that answer yes/no fit directly into `if`.

## Worked examples (manual §16.5)

The manual develops family trees, reachability graphs and small knowledge bases; the Tutorial Part III adds exercise 10 ("a knowledge base") with a full solution.

## Interaction with budgets and traces

Because logic execution is evaluation like any other, `with budget(steps = N)` bounds searches (exhausted budget → `Err(:budget)` instead of non-termination), and `with trace` exposes Byrd-port events (call / exit / fail / redo) as data — e.g. counting how many times a search failed without printing anything. This is where "errors are values" and declarative search meet: a runaway proof becomes an inspectable datum.

## Conformance status

Logic cases belong to Triad-Full conformance ([`conformance/`](../../conformance/README.md)); they are currently golden expectations, executable once the self-hosted runtime lands ([`BOOTSTRAP.md`](../../BOOTSTRAP.md)).

## See also

- [Error Handling & Advanced Features](Error-Handling-%26-Advanced-Features.md) — budgets/traces around searches
- [Syntax Reference](Syntax-Reference.md) — clause syntax positions
