# Syntax Reference

[⬅ Home](Home.md) · [⬅ Language Guide](Language-Guide.md)

Quick lookup tables distilled from the manual ([`docs/MANUALE.md`](../docs/MANUALE.md), §25–§27) and the normative grammars in [`SPEC-CORE.md`](../SPEC-CORE.md) (EBNF, Core) and [`SPEC.md`](../SPEC.md) (EBNF, Full). The parser is a Pratt parser with twelve precedence levels.

## Operators and precedence (manual §4)

| Level | Operators | Note |
|---|---|---|
| Highest | `.field`, call `f(x)`, indexing | postfix |
| | unary `-`, `not` | prefix |
| | `*`, `/`, `%` | integer arithmetic in Core (§4.1) |
| | `+`, `-` | |
| | `..` | ranges **[Full]** |
| | comparisons `<`, `<=`, `>`, `>=`, `==`, `!=` | conditions accept only `Bool` (§2.7) |
| | `and`, `or` | short-circuit logic (§4.2) |
| Lowest | assignment forms (`let`, `set`) | statement-level |

## Control flow (manual §5)

```triad
if cond { … } elseif cond2 { … } else { … }   # [Core]
while cond { … break … continue … }            # [Core]
let x = expr in body                           # [Core]
begin … end                                    # explicit block/scope [Core]
for i in 1..n { … }                            # [Full]
[expr for x in xs if guard]                    # comprehension [Full]
try { expr } catch err { handler }             # [Full]
```

## Functions and lambdas (manual §6, §8)

```triad
f(x) = expr                       # short form
f(x) { e1; e2; last }             # block form — value is the last expression
g = \(x, y) -> x + y              # lambda literal
h(x)!io { print(x); x }           # declared effect capability
```

- Last-expression semantics everywhere: blocks, function bodies, `let` bodies.
- Recursion is direct by name; arity is checked at call time (§6.2).
- Closures capture bindings, not values of mutable cells (§8.2); scope rules §8.3.

## Data literals

```triad
42                 # Int
true / false       # Bool
"hi\n"             # String with escapes (§1.10)
:symbol            # Symbol
[]  [1, 2, 3]      # List (immutable; cons/head/tail builtins)
:(1 + 2)           # quoted code node — Code as Data [Full] (§17)
```

## Logic constructs [Full] (manual §16)

```triad
fact parent(tom, bob).
rule ancestor(X, Y) :- parent(X, Y).
rule ancestor(X, Z) :- parent(X, Y), ancestor(Y, Z).
solve ancestor(bob, W)          # returns a list of solutions as data
```

Unification uses occurs-check; resolution backtracks over rules. `solve` is a **value**, not an exception channel (§16.3).

## Contracts, budgets, traces [Full] (manual §12–§14)

```triad
requires x >= 0                  # precondition clause
ensures result >= 0              # postcondition clause
with budget(steps = 1000) { … }  # bounded evaluation → Err(:budget)
with trace { … }                 # trace events as first-class values
```

Violation of a clause produces an `Err` carrying the failing clause — never a crash.

## Errors (manual §11, §27)

**Full shape:** `Err(category, payload)` — categories table in §11.3 (e.g. `:type`, `:domain`, `:budget`, `:not_found`).
**Core today:** errors surface as tagged lists (§11.4); the error-message table is manual §27.1 (Core) and §27.2 (Full).

## CLI & REPL (manual §20)

```bash
triad file.td        # run a script (shebang: #!/usr/bin/env triad)
triad repl           # interactive REPL (§20.1)
triad --help         # usage
node seed/dev/triad_core.cjs file.td   # reference interpreter directly
```

## Style rules (manual §22.6)

Prefer last-expression blocks over explicit `return`; use symbols for tags; association lists before hash-like structures in Core; keep effects declared (`!io`, `!state`) narrow.
