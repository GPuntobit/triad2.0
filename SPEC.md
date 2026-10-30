# Standard Triad — language specification (version 0.2.0, draft)
**Document status:** regulatory draft. Defines the language Triad — lexicon,
grammar, types, semantics, execution model, errors, contracts, effects, logic,
introspection and command line interface — **regardless of any
implementation**.
**Normativity:** Sections §1–§14 and §16 are normative. §15 and Appendix A are
informative. An implementation is **compliant** if it meets the requirements of §16 and passes the
conformance suite in `conformance/`.
**Triad in brief.** Triad is a language in itself, with block syntax and declared types,
multiple dispatch, integrated logic programming (`fact`, `rule`, `solve`), code as
data (uniform tree, dimensions, macros) and, as part of the language and not of a library:
errors such as data, contracts, budgets, tracks and declared effects.
**File extension:** `.triad` is the canonical extension; `.td` is accepted as an alias
historical. The extension can be omitted on the command line.
```triad
struct Point
    x::Float
    y::Float
end

function dist(a::Point, b::Point)::Float
    requires a.x != b.x || a.y != b.y
    sqrt((a.x - b.x)^2 + (a.y - b.y)^2)
end

fact parent(:alice, :bob)
fact parent(:bob, :dave)

rule grandparent(?x, ?z) :- parent(?x, ?y), parent(?y, ?z)

macro unless(c, body)
    :(if !$c; $body; end)
end

result = solve grandparent(:alice, ?who) limit 5     # [{who = :dave}]
```

`solve` returns a normal value, i.e. a list of solutions. You can switch to one
function, filter, index (`result[1].who`) or use for dispatch, without printing
nothing.
**Reference implementation (transitional, informational):** `triad.jl` and `syntax.jl`,
today written in Julia for bootstrapping; they are not part of the definition of the language e
they will be replaced by the self-hosted implementation (see `BOOTSTRAP.md`). The specification
executable is `conformance/`.
---
## 1. Vocabulary
| element | shape | examples |
|---|---|---|
| identifier | letter or `_`, then letters, digits, `_`; Final `!` allowed if not followed by `=` | `x`, `push!`, `age` |
| logical variable | `?` **attached** to a name | `?x`, `?who` |
| anonymous variable | `?_`: each occurrence is a new variable | `parent(?x, ?_)` |
| symbol | `:` followed by a name or an operator, if it is not attached to a previous value (`:-` remains the `:-` of the rules) | `:alice`, `:+`, `:<=` |
| numbers | `Int` (`42`, `1_000`) and `Float` (`3.14`, `1e-9`) | |
| strings | `"..."` escaped `\n \t \" \\ \$` and interpolated `$x`, `$(expr)` | `"x = $x"` |
| comments | `#` to end of line; `#= ... =#` on multiple lines | |
| separators | newline or `;` | |
| macros | `@name(...)` | `@unless(c, e)` |
**Keywords:** `function struct macro end if elseif else for in while let begin return
break continue fact rule solve quote try catch with requires ensures true false nothing isa is`.
They are contextual (after `solve`) `limit depth steps trace`.
**Colon rules** (the classic `:` problem):
- `1:n` and `xs[2:end]`: a `:` attached to a value and without spaces is a range;
- `f(:a)`, `x = :a`: a `:` not preceded by a value and followed by a name is a symbol;
- `:( ... )`: is quoted code;
- `c ? a : b`: a `:` surrounded by spaces is the ternary separator.
`?` also has two uses: `?x` (attached) is a logical variable, while `? ` with a space after it
it is the ternary.
**Newlines** end a statement, except inside `( )`, `[ ]`, and `:( )`, and except
immediately after a binary operator or a `rule` comma.
## 2. Syntax (EBNF)
```ebnf
program    = { sep } { stmt sep { sep } } ;
sep        = NEWLINE | ";" ;
block      = { sep } { stmt sep { sep } } ;          (* fino alla parola chiave di chiusura *)

stmt       = funcdef | structdef | macrodef | fact | rule
           | "requires" expr | "ensures" expr
           | "return" [ expr ] | "break" | "continue"
           | "(" NAME { "," NAME } ")" "=" expr        (* destrutturazione *)
           | expr ;                                   (* include l'assegnamento *)

funcdef    = "function" fname "(" [ params ] ")" [ "::" TYPE ] [ "!" EFFECT { "," EFFECT } ]
             block "end"
           | NAME "(" [ params ] ")" "=" expr ;       (* forma breve: sq(x) = x * x *)
fname      = NAME | "+" | "-" | "*" | "/" | "%" | "^" | "==" | "<" | "<=" | ">" | ">=" ;
params     = param { "," param } ;
param      = NAME [ "::" TYPE ] | "(" NAME { "," NAME } ")" ;
structdef  = "struct" NAME sep { NAME [ "::" TYPE ] sep } "end" ;
macrodef   = "macro" NAME "(" [ NAME { "," NAME } ] ")" block "end" ;

fact       = "fact" term ;
rule       = "rule" term [ ":-" goal { "," goal } ] ;
(* the comma can also be at the beginning of the line, when the body goes to a new line *)
expr       = (* Pratt: precedences from lowest to highest *)
  1  a = b   a += b   a -= b   a *= b                 (destra)
  2  x -> e   (a, b) -> e   c ? a : b                 (destra)
  3  ||
  4  &&
  5  ==  !=  <  <=  >  >=  in  isa  is
  6  a:b                                               (range, senza spazi)
  7  +  -
  8  *  /  %
  9  -x  !x  +x  $x                                    (unari)
 10  ^                                                 (destra)
 11  e::T                                              (asserzione di tipo)
 12  f(args)  xs[i]  a.campo                           (postfissi, senza spazio prima di ( e [)

primary    = NUMBER | STRING | SYMBOL | LVAR | NAME | "true" | "false" | "nothing"
           | "(" expr ")" | "(" expr "," ... ")"       (* tupla: parametri di lambda *)
           | "[" [ expr { "," expr } [ "|" expr ] ] "]"
           | "[" expr "for" NAME "in" expr [ "if" expr ] "]"
           | ":(" expr ")" | "quote" block "end"
           | "@" NAME "(" args ")"
           | "if" expr block { "elseif" expr block } [ "else" block ] "end"
           | "while" expr block "end"
           | "for" NAME "in" expr block "end"
           | "for" "(" NAME { "," NAME } ")" "in" expr block "end"   (* destrutturazione *)
           | "let" [ NAME "=" expr { "," NAME "=" expr } ] block "end"
           | "begin" block "end"
           | "try" block [ "catch" [ NAME ] block ] "end"
           | "with" modifier { "," modifier } block "end"
           | "solve" goal { "limit" expr | "depth" expr | "steps" expr | "trace" }
           | "function" "(" params ")" block "end" ;   (* anonima *)
modifier   = "budget" "(" "steps" "=" expr ")" | "trace" ;
```

Everything is an expression with a value: `if`, `let`, `try`, `with`, `solve` and the blocks
they return the value of the last executed statement (`nothing` if there is none).
## 3. The uniform tree
The parser produces only one node type, `Node(head, args)`. It is the same tree as the kernel
executes, which `:( ... )` returns as a value and which `--tree` prints as an S-expression:
```
$ julia triad.jl --tree examples/assaggio.td
(rule (call grandparent ?x ?z) (call parent ?x ?y) (call parent ?y ?z))
(assign result (solve (call grandparent (sym alice) ?who) (tuple (assign limit 5))))
```

| syntax | node |
|---|---|
| `f(a, b)`, `a + b` | `(call f a b)`, `(call + a b)`: the operators are calls |
| `a && b`, `a \|\| b` | `(and a b)`, `(or a b)`: short circuit |
| `x = e` | `(assign x e)` |
| `:alice` | `(sym alice)`; a bare name `x` is the Symbol `x` (variable reference) |
| `?x` | the logical variable itself (leaf) |
| `a.x`, `xs[i]` | `(dot a x)`, `(index xs i)` |
| `[a, b]`, `[h \| t]` | `(list a b)`, `(cons (list h) t)` |
| `[e for x in xs if c]` | `(comprehension e x xs c)` |
| `x -> is | `(lambda (tuple x) e)` |
| `x::T` | `(typed x T)` |
| `"to $x"` | `(string "a " x)` |
| `if c a else b end`, `c ? a : b` | `(if c (block a) (block b))` |
| `while`, `for`, `let`, `begin` | `(while c body)`, `(for x iter body)`, `(let (tuple binds…) body)`, `(block …)` |
| `function f(a::T)::R !io ... end` | `(function f (tuple (typed a T)) R (tuple io) body)` |
| `struct P; x::Float; end` | `(struct P (tuple (typed x Float)))` |
| `macro m(a) ... end`, `@m(e)` | `(macro m (tuple a) body)`, `(macrocall m e)` |
| `:(e)`, `quote … end`, `$e` | `(almost e)`, `(almost (block …))`, `(unquote e)` |
| `fact t`, `rule h :- g1, g2` | `(fact t)`, `(rule h g1 g2)` |
| `solve g limit 5 trace` | `(solve g (tuple (assign limit 5) (assign trace true)))` |
| `try b catch and h end` | `(try b and h)` |
| `with budget(steps = N), trace … end` | `(with (tuple (call budget (assign steps N)) trace) body)` |
| `requires c`, `ensures c`, `return e` | `(requires c)`, `(ensures c)`, `(return e)` |
The quoted code is a value of type `Expr`: `c.head` and `c.args` inspect it,
`Expr(:call, :f, 1)` constructs it, `eval(c)` executes it, `parse(s)` and `unparse(c)` convert
between text and tree, `sexpr(c)` gives the view to S-expression.
## 4. Values ​​and types
| type | values ​​|
|---|---|
| `Int`, `Float` (subtypes of `Number`) | `42`, `3.5` |
| `Bool` | `true`, `false` |
| `String` | `"text"` |
| `Symbol` | `:alice` (also the atom of logic) |
| `Nothing` | `nothing` |
| `List` | `[1, :a, "x"]`: heterogeneous list, indices of 1 |
| `Function` | lambda, generic functions, builtins |
| `Expr` | quoted code |
| `Term`, `LVar` | logical terms and variables (`f(?x)`, `?x`) |
| `Solution` | `{who = :dave}`: `s.who`, `s[:who]`, `vars(s)` |
| `Err` | error as given (§8) |
| `Type` | the types themselves are values: `typeof(3) == Int` |
| struct user | `Point(3.0, 4.0)` |
- **Hierarchy:** `Int <: Number`, `Float <: Number`, and each type is a subtype of `Any`.
- **Struct:** are immutable and the constructor is positional (`Point(3, 4)`). The builder
  check typed fields; an `Int` passed to a `Float` field is converted to `Float`.
  A non-convertible type value produces `Err(:type)`.
- **Conversions:** `Int(x)`, `Float(x)`, `String(x)`, `Symbol(x)`. The name of the type used as
  convert function; the name of a struct used as a construct function.
- **Assertion:** `e::T` returns `e` if it is of type `T`, otherwise it produces `Err(:type)`.
- **Declarer constraint:** `x::T = e` (and a `x::T` parameter) *fixes* the type of that name
  in the environment where it is born: subsequent assignments are controlled and
converted against `T` (`y::Float = 1.0; y = 2` → `2.0`; `x::Int = 1; x = 0.5` → `Err(:type)`).
  A new declaration `x::U = ...` on the same name replaces the constraint, a non-name
  declared with type remains free (`s = "a"; s = 3` is fine), and a binding in an environment
  interior (`let x = 2.5`) does not inherit the constraint of the exterior.
- **Conditions:** `if`, `while`, `&&`, `||`, `!` and filters only accept `Bool`. It doesn't exist
  a concept of "truthy", and a non-boolean condition gives `Err(:type)`.
- **`print` and `show`:** `println(:a)` prints `a`; inside a list or in a `repr` the symbol
  it prints as `:a`.
## 5. Functions and multiple dispatch
```julia
area(n::Number) = :number
area(n::Int)    = :int            # more specific: wins for Ints
area(p::Point)  = :point
function +(a::Point, b::Point)    # gli operatori si estendono come funzioni
    Point(a.x + b.x, a.y + b.y)
end
```

- A generic function is a collection of methods. Redefine the same signature replaces the
  previous method.
- **Method selection:** among the applicable methods (same arity, each argument subtype
  of the parameter) the most specific wins. A method A is more specific than B if each its
  parameter is subtype of the corresponding parameter of B and the signatures differ.
  - If no method is applicable you get `Err(:method)`. If the name is also a builtin,
    for example `+` on numbers, the builtin is used.
  - More maximal methods give `Err(:ambiguous)`.
- **Return type:** `::R` is checked on exit, with Int→Float conversion. If the
  value does not conform you get `Err(:type)`.
- **First-class values:** functions and operators are values ​​(`reduce(+, xs)`,
`map(sq, xs)`), lambdas (`x -> x + 1`) are closures.
- **Local functions:** a `function` defined inside another function is a local closure,
  without dispatch.
- **Lexical Scope:** each `function`, lambda, `let`, `for`, `while` and comprehension
  introduces an environment. A name is visible in the environment in which it is linked and in those
  internal, not external ones. Inside a function, an assignment binds the name
  in the local environment (or in an internal closure), never in globals; cycles at the top level
  they can update globals.
- **`return`, `break`, `continue`:** `return ends the function returning the value of
  `e` (`nothing` without expression); `break` exits the innermost `for`/`while`; `continue`
  jumps to the next step of the innermost loop.
## 6. Logic
### 6.1 Facts, rules, terms
```julia
fact parent(:tom, :bob)
rule ancestor(?a, ?d) :- parent(?a, ?d)
rule ancestor(?a, ?d) :- parent(?a, ?x), ancestor(?x, ?d)
```

Within a term:
- `:atom` is a symbol; `?x` is a logical variable; numbers, strings and lists are themselves.
- `f(t1, t2)` is a composite term. `?x + 1` is also a term (`+(?x, 1)`) and does not come
  evaluated.
- **a bare name is a value from the current environment**, read at the time it is executed
  `fact`, `rule` or `solve`: `chi = :bob; solve parent(chi, ?c)`.
- `$(expr)` explicitly inserts a calculated value: `fact age(:bob, $(2026 - 1975))`.
- `[a, b]` and `[?h | ?t]` are lists and patterns on lists.
- The name of a struct with arguments, such as `Point(?x, ?y)`, unifies with instances of that
  struct (pattern matching).
Variables in a clause are renamed each time they are used (standardization aside).
Unification does the **occurs-check**: `solve ?x = f(?x)` has no solutions.
### 6.2 Goals
| goals | meaning |
|---|---|
| `p(t…)` | knowledge base predicate, solved with SLD and backtracking, clauses in order |
| `g1 && g2`, `(g1, g2)` | conjunction; in `rules` also with `,` |
| `g1 \|\| g2` | disjunction |
| `!g`, `not(g)` | denial for failure |
| `not(b)` | *out* of a goal `not/1` is a function: negate a `Bool` (`not(true) == false`) |
| `a = b` | unification |
| `?y is expr` | evaluates `expr` (variables must be bound) and unifies with `?y` |
| `a < b`, `==`, `!=`, `<=`, `>`, `>=` | comparison between values, evaluated |
| `f(t…)` with `f` function Triad | calls the function with the evaluated arguments; must return `Bool` |
| `true`, `false` | success, failure |
A predicate without clauses with that arity, which is not even a function, gives
`Err(:undef, "unknown predicate: p/2")`. An unbound variable within an expression gives
`Err(:instantiation)`.
### 6.3 `solve` is a value
```julia
sols = solve ancestor(:tom, ?d) limit 10 depth 50 steps 100_000
[s.d for s in sols]                 # comprehension sulle soluzioni
```

- `solve g` returns a list (`List`) of `Solution`. Each solution links the variables
  of the query **not anonymous**, in the order in which they appear. The variables left free
  `?x#n` remain.
- Options:
  - `limit n`: at most `n` solutions;
  - `depth d`: branches deeper than `d` are cut (i.e. fail);
  - `steps s`: at most `s` resolution steps, otherwise `Err(:budget)`; the default is
    1 000 000;
  - `trace`: see §11.
- **Predicate in an expression:** Call a predicate where a value is expected
  returns `Bool`, i.e. it says whether the goal is provable:
  `if grandparent(:alice, :dave) … end`, `filter(p -> !parent(p, ?_), people)`.
- The engine is iterative, with an explicit stack and a trail link store. Don't use it
implementation recursion, so infinite recursion, even left, ends in
  `Err(:budget)` and not on a stack overflow.
## 7. Macros and code as given
```julia
macro swap(a, b)
    t = gensym(:tmp)
    quote
        $t = $a
        $a = $b
        $b = $t
    end
end
@swap(x, y)
```

- `:(e)` and `quote … end` return code (`Expr`). Inside, `$x` and `$(e)` insert the
  **value** of an expression: if it is a code it is nested, if it is a number, a list or something else
  it becomes a constant, if it is a Symbol it becomes an identifier.
- A macro receives arguments **as code**, not evaluated, and returns code, which is
  then executed in place of the `@name(...)` call in the caller's scope.
- Expansion is pure (§12) and is not hygienic: `gensym()` is used for temporary names.
- `eval(c)` executes code in global scope.
## 8. Errors as data
An error is an `Err` value with three fields:
- `kind::Symbol`: the category on which dispatch can be performed;
- `msg::String`;
- `data`: any value, often an `Info(...)` record with details.
| construct | effect |
|---|---|
| `err(:kind, "msg"[, data])` | constructs an `Err` without raising it |
| `throw(e)`, `error("msg")` | raise (`error` produces `Err(:error, …)`) |
| `try b catch and h end` | if `b` raises, `e` is related to `Err` and `h` | is evaluated
| `try b end` | **the error becomes the value** of the expression |
| `iserr(x)` | checks if `x` is an `Err` |
All language and implementation failures (integer division by zero,
`sqrt(-1.0)`, indices out of range…), arrive as `Err` and never as fatal failures:
| kind | when |
|---|---|
| `:syntax` | parse error; `data` contains `line`, `col` and `incomplete` (used by the REPL) |
| `:undef` | undefined name, function, macro or predicate |
| `:type` | wrong type (fields, return, `::`, conditions not `Bool`) |
| `:method` | no applicable method; `data.types` contains the types of the arguments |
| `:ambiguous` | multiple equally specific methods |
| `:field`, `:bounds`, `:domain` | non-existent field, index out of range, mathematical error |
| `:instantiation` | unbound logical variable where a | value is needed
| `:contract` | `requires`/`ensures` violated (§9) |
| `:budget` | steps exhausted (§10) |
| `:effect` | undeclared effect (§12) |
| `:host` | any other interpreter errors |
An unhandled error at the top level interrupts the program. The message displays the line
of the statement (`line 12: …`) and the exit code is 1.
## 9. Contracts
```julia
function safe_div(a::Number, b::Number)::Float
    requires b != 0
    ensures abs(result * b - a) < 1e-9
    a / b
end
```

- `requires c` is checked where it appears: by convention at the beginning of
  body.
- `ensures c` is recorded and checked at function exit, with `result` bound to
  return value, after checking the return type.
- A violation produces `Err(:contract, "requires violated in safe_div: b != 0", Info(fn, clause, cond[, result]))`.
  `cond` contains the condition code: it is data, it can be inspected.
- The conditions are **pure**: an effect inside a contract gives `Err(:effect)`.
- At the top level `requires c` works like an assertion.
## 10. Budget
```julia
r = with budget(steps = 10_000)
    calcolo_che_potrebbe_non_finire()
end
iserr(r) && r.kind == :budget
```

- A **step** is a call, loop iteration, or resolution step.
- `with budget(steps = N) … end` limits the body steps. If the budget runs out,
  **the value of the `with` is `Err(:budget)`**: the program does not crash and does not
  interrupted.
- Budgets are nested: the tightest applies. A `with` converts only the depletion to a value
  of **own** budget, while that of an external budget continues to propagate.
- `solve … steps N` is the specific budget of a query.
## 11. Tracks
The trace of a calculation is a **value**, not printed output:
```julia
t = with trace
    fib(3)
end
t.result                         # 2
t.trace                          # [Event(port = :call, fn = :fib, args = [3], depth = 0), …]

t = solve path(:a, :c) trace
t.trace                          # Event(port = :call | :redo | :exit | :fail | :depth, goal, depth)
```

- `with trace … end` returns `Traced(result, trace)` with the `:call` and `:exit` events of
  any generic function called in the body.
- `solve … trace` returns `Traced(result, trace)`, where `result` is the list of
  solutions and events are the gates of the Byrd box model (`call`, `exit`, `redo`,
  `fail`) plus `depth`, when a branch is cut by `depth`.
- Events are records: they are filtered and counted like any other value
  (`[e.args for e in t.trace if e.port == :call]`).
## 12. Effects
The functions are **pure by default**. The effects are declared in the signature:
```julia
function saluta(nome::String) !io
    println("ciao, ", nome)
end
function impara(x) !state
    fact visto($x)
end
```

| effect | operations |
|---|---|
| `I` | `println`, `print` |
| `state` | `fact`/`rule` executed inside a function (modifies the knowledge base) |
- **Dynamic control.** A function executes only with the effects it declares, and only
  if the caller allows them. If a pure function calls `println`, or calls a function
  `!io`, you get `Err(:effect)`. `data` contains `fn`, `caller` and `missing`.
- The top level allows all effects.
- Lambdas inherit the effects of the context in which they are executed.
- Macros and contracts are pure.
- Reading the knowledge base (`solve`, calling a predicate) is pure.
- Local data mutation (`push!` on a list, assignment to local variables) is not a
  effect: only changes values reachable from the local environment.
## 13. Builtin
| scope | functions |
|---|---|
| arithmetic and comparison | `+ - * / ^ % == != < <= > >= !`, `abs sqrt floor ceil round exp log sin cos div mod min max`; `*` concatenate strings |
| lists | `length is empty first last rest reverse sort sum push! pop! append! vcat collect`, `a:b`, `x in xs` |
| higher order | `map filter reduce any all count` |
| strings and output | `string repr println print` |
| types | `typeof`, `isa`, `Int Float String Symbol` |
| errors | `err iserr throw error` |
| code | `eval parse unparse sexpr Expr gensym` |
| logic | `vars(sol)` |
## 14. Command line interface
A compliant implementation exposes a `triad` command with this interface. The shape is
legislation; additional options are permitted, as long as they are compatible.
```
triad                            # REPL
triad FILE [ARG...]              # esegue FILE; ARGS == [ARG...]
triad -l FILE                    # carica FILE e apre il REPL
triad -i FILE                    # esegue FILE e poi apre il REPL
triad -e CODE                    # esegue CODE
triad -E CODE                    # esegue CODE e stampa il valore
triad --tree FILE                # stampa l'albero uniforme come S-expression
triad -q                         # REPL senza banner
triad -h, --help
triad -v, --version
triad -                          # legge lo script da stdin
```

- The actions are performed in the given order; then the script.
- The `.triad` (canonical) or `.td` (historical) extension can be omitted.
- A `.triad`/`.td` file can have shebang `#!/usr/bin/env triad`; the first line `#!...` is
  ignored before parsing.
- The program sees the arguments in `ARGS`, list of strings, without the program name.
- Exit codes: `0` success, `1` unhandled error, `2` invalid use. Not an error
  managed is printed to stderr.
**REPL.** Without scripting, the implementation opens a REPL with this behavior:
```
triad> ?- ancestor(:tom, ?d)
?d = :bob ;
?d = :liz.
triad> mother(?m, ?c)                # a goal on a KB predicate is already a query
?m = :pat,
?c = :jim.
triad> parent(:jim, ?x)
false.
```

- The lines are Triad code; blocks remain open until closed by `end`.
- `?- goal` (the trailing `.` is optional) runs a query with the `solve` options:
  `limit`, `depth`, `steps`, `trace`.
- A statement that is a goal on a knowledge base predicate is treated as a query.
- After each solution: `;`, `n` or space for the next one, `a` for all the remaining ones,
  enter or `.` to stop. `false.` means no other solution. If stdin is not a
  terminal the solutions are all printed.
- Commands: `:load FILE...` (`:l`), `:reload` (`:r`, `make`), `:listing [name|name/arity]`
  (`:ls`), `:tree CODE`, `:reset`, `:help` (`:h`), `:quit` (`:q`, `halt`, Ctrl-D).
- Ctrl-C stops the calculation in progress; an unhandled error is printed and the REPL continues.
The conformance suite covers the non-interactive part of the interface (scripts, arguments,
exit code); the REPL is covered by implementation testing.
## 15. Reference implementation status (informational)
This section is not regulatory.
- The current reference implementation (`triad.jl`, `syntax.jl`) is written in Julia and is
  transitional: used for bootstrapping and will be replaced by the self-hosted implementation
  (`BOOTSTRAP.md`).
- Not yet implemented in the reference: named arguments (except `budget(steps = …)`),
  mutable structs, user abstract types, parametric types, bracketless macros, quotas
  nested at multiple levels, cut.
- Effects control is dynamic; a static control is foreseen.
- The old S-expression kernel is preserved in `legacy/triad_sexpr_v1.jl`.
## 16. Compliance and versioning
### 16.1 Compliance Profiles
- **Triad-Core** — subset required to perform bootstrapping and deployments
  self-hosted: values, functions and closures, flow control, lists, strings, I/O and
  bootstrap primitives. It is normatively defined in `SPEC-CORE.md`; shared cases
  with Triad-Full they are in `conformance/core/`.
- **Triad-Full** — all language described in this document, including logic (§6),
  macros (§7), contracts (§9), budgets (§10), tracks (§11), effects (§12).
### 16.2 Verification
An implementation conforms to a profile if:
1. pass the cases of `conformance/`, producing exactly `expected.out` for each and
   `expected.code` (format in `conformance/README.md`);
2. implement the command line interface of §14 for the part covered by the suite;
3. for Triad-Full all cases pass; for Triad-Core, the declared subset.
The compliance suite is part of the standard: its goldens are normative and versioned
together with the specification. An implementation cannot declare itself compliant without running it.
### 16.3 Versioning
- The standard version is `MAJOR.MINOR.PATCH` (current `0.2.0`, in `VERSION`).
- `MAJOR` changes for incompatible changes; `MINOR` for compatible extensions e
  clarifications; `PATCH` for non-normative or implementation fixes.
- Each regulatory change updates `CHANGELOG.md`, `VERSION` and, if the behavior changes,
  the goldens of conformity.
## Appendix A — Claimed Influences (Informative)
Triad was born from ideas of **Julia**, **Prolog** and **Lisp**, but is not a dialect of any of
three: the definition of the language is this specification. Similarities are informative notes.
| from | idea resumed |
|---|---|
| Julia | `function ... end` blocks, `::` types, `struct`, multiple dispatch, function-operators, `if`/`for`/`while`/`let` |
| Prolog | `fact`/`rule` as constructs, unification with occurs-check, backtracking, `solve`, `?x` variables |
| Lisp | code as given, uniform tree, `:( ... )`/`quote` with `$`, macro |
Triad's own, not borrowed: errors such as data, contracts, budgets, tracks and
effects declared as part of the language, and the integration of the three models into one
block syntax.