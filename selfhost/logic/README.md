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

This profile is not the complete Full evaluator. Escaped/Unicode strings and arbitrary Core
statements/functions inside a logic input, and expression-valued query options
are not implemented. Syntax outside the profile is rejected, not sent to a host
runtime. Error values currently carry their kind, not Full diagnostic payloads.

Source input uses compact 64-byte pages and is limited to 65535 bytes. Internal vectors hold at most 4096 values,
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

## Extensions after the initial engine

- `solve ... trace` returns `.result` and `.trace`; events expose `.port`,
  `.goal`, `.depth`, with call/exit/redo/fail/depth ports. Comprehensions
  may filter events: `[e.goal for e in t.trace if e.port == :call]`.
- `struct Point` with newline-separated fields, optionally `x :: Int`,
  supports construction, field access and logic patterns. Built-in field
  types and nested struct types are checked at construction.
- Boolean functions can be declared as `even(x) = x % 2 == 0` or with
  `function even(x)` / optional `return` / one Boolean goal / `end`.
  They use the method table; calls from goals must return Bool.

This is still not a complete Full evaluator. Arbitrary function statements,
control-flow bodies and return type annotations remain unsupported; typed
method dispatch and scalar expression returns are now supported. General Full semantics and diagnostic
payloads remain separate work. Finite S0 heap/vector limits still apply.

## Sessione desktop

La sessione desktop parte in `auto`: rileva fact/rule/solve/struct nel
codice, ignorando commenti e stringhe, e seleziona S1 oppure Core per ogni
file. `:logic` forza S1 e `:core` forza Core; `:auto` ripristina la scelta
automatica. Inserisci il percorso del file senza virgolette. `:core` torna al profilo Core;
`:quit` chiude la sessione. Il profilo rimane selezionato anche dopo un errore.
Per aprire direttamente un file logico: `bin/triad-desktop --logic FILE`.
La selezione del profilo non abilita un REPL e non amplia la sintassi S1.

La selezione è lessicale, non una prova di conformità Full. Un uso ambiguo
di una parola chiave come nome di funzione può richiedere `:core`. Il file
viene eseguito una sola volta: non si passa a un altro runtime dopo un errore.
L'automatismo riguarda il desktop; `triad FILE` mantiene il percorso Core e
`triad --logic FILE` seleziona S1 esplicitamente da terminale.

## Typed methods and Float data

`area(n::Int) = :intero` and `area(n::Number) = :numero` are supported.
Methods are selected by the subtype partial order, independent of declaration
order: Int/Float <: Number <: Any; same-signature redefinition replaces the
old method. No applicable method returns Err(:method), multiple maximal
methods Err(:ambiguous). Expression bodies can return scalar values; goal
functions must return Bool. Parameter bindings are restored after a call.

Decimal Float literals support struct data and dispatch; Int fields passed to
a Float field convert as required by SPEC.md §4. This is not a full IEEE-754
numeric evaluator: Float arithmetic, exponents, return annotations and arbitrary
statement bodies remain unsupported. The existing source/heap limits remain.
The desktop detector recognizes `::` outside comments/strings as S1 syntax.
