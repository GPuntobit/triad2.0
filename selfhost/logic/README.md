# S1 logic engine

Run a logic program on the native machine-code seed:

```sh
./bin/triad --logic program.triad
# after ./install.sh:
triad --logic program.triad
# or read a program from stdin:
triad --logic - < program.triad
```

```triad
fact parent(:alice, :bob)
fact parent(:bob, :dave)
rule grandparent(?x, ?z) :- parent(?x, ?y), parent(?y, ?z)
println([s.z for s in solve grandparent(:alice, ?z)])
# [:dave]
```

The engine is Triad-Core source, not a JavaScript implementation. The shell
wrapper only transports input bytes into a temporary Core program using POSIX
`od` and `printf`; S1 performs tokenization, parsing, unification, resolution,
solution projection and rendering. Input is never evaluated by the shell.
The regular `triad FILE` path still runs Core directly. `--logic` explicitly
selects this first S1 profile; it is not a claim of complete Triad-Full support.

## Implemented (SPEC.md §6)

- Facts and rules, ordered clauses, conjunction, disjunction and negation as
  failure. Resolution uses an explicit choice stack and an undo trail rather
  than recursive calls to the solver.
- Fresh rule variables on every invocation, repeated-variable constraints,
  independent anonymous variables, iterative unification and occurs-check.
- Symbols, integers, simple ASCII strings, composite terms, lists and list-tail
  patterns. Bare names capture current values when clauses/queries execute;
  `$(expr)` embeds a calculated value.
- `solve` as a value, query variables in appearance order, field access and
  solution comprehensions. Comprehension variables do not leak into the outer
  environment. Calling a predicate in a value position returns a Bool.
- Integer `+`, `-`, `*`, `%` in `is`; numeric ordering, scalar equality and
  inequality; `limit`, `depth`, `steps` with non-negative integer literals.
- `Err(:budget)`, `Err(:instantiation)`, `Err(:undef)`, `Err(:type)` and
  `Err(:arith)` values for the corresponding supported goal failures.

## Explicit limits of this stage

This profile is not the complete Full evaluator. User-defined Boolean function
calls as goals, structs, `trace`, escaped/Unicode strings, arbitrary Core
statements/functions inside a logic input, and expression-valued query options
are not implemented. Syntax outside the profile is rejected, not sent to a host
runtime. Error values currently carry their kind, not Full diagnostic payloads.

Source input is limited to 4094 bytes. Internal vectors hold at most 4096 values,
compound arity at most 64, and allocations use the seed's finite 8 MiB bump heap.
A capacity/heap limit can be reached before the default one-million-step search
budget; this stage is not suitable for unbounded production queries. The `depth`
option cuts deeper branches; `steps` ends search with `Err(:budget)`.

Free variables render as `?name#id`. The engine does not yet provide a general
Full API for moving an unbound variable between separately executed queries.
Negation and choice points undo bindings; successful solutions are reified before
backtracking. Parser/term traversal still uses recursion bounded by the finite
source/heap; predicate resolution itself is iterative.

## Verification

```sh
sh conformance/logic/run.sh
TRIAD_SEED="$PWD/conformance/logic/reference.sh" sh conformance/logic/run.sh
node --test tests/logic-launcher.test.mjs
sh verify.sh
```

`reference.sh` is a development oracle for the same S1 source. It is never a
fallback in the runtime path. The dedicated suite freezes the logic profile's
supported behavior without changing the existing Full suite's goldens.
