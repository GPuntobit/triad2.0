# Code as Data & Macros

[⬅ Home](Home.md) · profile: **[Full]** (specified; awaiting the self-hosted runtime)

## One node type (manual §17)

The parser produces exactly one kind of value: `Node(head, args)`. The kernel evaluates these nodes; quoted code *is* these nodes. There is no separate "AST type" hidden from the programmer and no parallel representation between syntax and data — homoiconicity is the whole point.

```triad
let q = :(1 + 2)     # quote: a data value describing the expression
eval(q)              # => 3
```

Quote / unquote / eval are described in §17.1: `` :(...) `` builds a node value, unquote splices runtime values into it, `eval` runs a node. Because code is data, metaprogramming needs no special privileges beyond ordinary list processing.

## Macros (manual §18)

A macro is a function **on code**: it receives node values and returns a node value that replaces the call site (§18.1, "code that generates code"). Lisp-style hygiene concerns and expansion semantics are defined normatively in [`SPEC.md`](../SPEC.md).

Practical consequences:

- New syntactic forms don't require touching the parser.
- Debugging metaprograms means inspecting ordinary values (`Node(head, args)` lists), which you can print, compare and test.
- The Tutorial's Full exercise 12 ("a macro that measures") wraps a body with timing instrumentation purely through node rewriting.

## Why this matters for bootstrap

The self-hosting compiler ([`BOOTSTRAP.md`](../BOOTSTRAP.md)) relies on this property: if the language can represent its own syntax as native data, the compiler written in Triad manipulates the same node values the runtime evaluates. Code-as-data is not a gimmick here; it's the load-bearing wall of the roadmap.

## Conformance status

Macro and quote/eval cases are Triad-Full golden expectations today ([`conformance/`](../conformance/README.md)); Core programs run without them.

## See also

- [Language Guide](Language-Guide.md) — design principles
- [Repository Architecture](Repository-Architecture.md) — where parsing/evaluation live in the reference interpreter
