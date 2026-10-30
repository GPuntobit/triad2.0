# Triad-Core — bootstrap subset (standard 0.2.0)
**Status:** Regulatory, part of the Triad 0.2.0 standard (profile §16.1 of `SPEC.md`).
Defines the subset of Triad that the machine code seed (S0) must be able to execute e
where the complete self-hosted implementation (S1) is written. Each Triad-Core program,
**excluding bootstrap primitives** from §8, it is also a valid Triad program and must
behave the same way in a Triad-Full implementation.
## 1. Purpose and criteria
Triad-Core is chosen for two properties:
1. **implementable in handwritten machine code** (the S0 seed): few shapes, few types,
   no macros, no logical resolution, no dispatch;
2. **expressive enough** to write the interpreter of all Triad in Triad-Core
   (S1): dynamic values, lists, strings, closures, and recursion, plus I/O and
   access to the characters needed to read/analyze the Triad source.
Rule: everything in Triad-Full is syntactic sugar or convenience (Prolog, macro, `quote`,
struct, dispatch, contracts, budget, tracks, effects, destructuring, `for`, `try`) **not**
it is part of Core: S1 implements it in Core and exposes it to Full programs.
## 2. Vocabulary
Included:
| element | shape |
|---|---|
| identifier | letter or `_`, then letters/digits/`_`; final `!` allowed |
| integer | `42`, `1_000` (sign handled by unary operator) |
| boolean | `true`, `false` |
| nothing | `nothing` |
| string | `"..."` escaped `\n \t \" \\`; **no** interpolation `$` |
| symbol | `:` + name or operator (`:alice`, `:+`) |
| comment | `#` to end of line; `#= ... =#` |
| separator | newline or `;` |
| operators | `+ - * % ^ == != < <= > >= && \|\| ! = += -= *= -> ?:` |
Excluded: `Float` literals, `?x` logical variables, characters (Triad has none),
macro `@name`, the shebang is still ignored by the seed.
## 3. Types and values
| type | values ​​|
|---|---|
| `Int` | 64-bit signed integers, wrapped arithmetic (two's complement) |
| `Bool` | `true`, `false` |
| `String` | immutable UTF-8 byte sequence |
| `Symbol` | `:name`; two symbols are equal if they have the same name |
| `List` | mutable heterogeneous list, indices of 1 |
| `Function` | named function, lambda or closure |
| `Nothing` | `nothing` |
There are no `Float`, user struct, `Term`, `Solution`, `Err` as language values:
S1 represents these concepts with Core types (e.g. a struct as a tagged list, an error
as a list `[Err, kind, msg]`). `readfile`/`strbyte`/`strsub` (§8) are bootstrap primitives,
not types.
## 4. Syntax
```ebnf
program  = { sep } { stmt sep { sep } } ;
stmt     = funcdef | "return" [ expr ] | "break" | "continue" | expr ;
funcdef  = "function" NAME "(" [ NAME { "," NAME } ] ")" block "end"
         | NAME "(" [ NAME { "," NAME } ] ")" "=" expr ;
expr     = assegnamento ;
assegnamento = NAME ( "=" | "+=" | "-=" | "*=" ) expr | ternario ;
ternario = or_expr [ "?" expr ":" expr ] ;
or_expr  = and_expr { "||" and_expr } ;
and_expr = cmp_expr { "&&" cmp_expr } ;
cmp_expr = sum_expr { ( "==" | "!=" | "<" | "<=" | ">" | ">=" ) sum_expr } ;
sum_expr = mul_expr { ( "+" | "-" ) mul_expr } ;
mul_expr = pow_expr { ( "*" | "%" ) pow_expr } ;
pow_expr = unary { "^" unary } ;                    (* destra *)
unary    = ( "-" | "!" ) unary | postfix ;
postfix  = primary { "(" args ")" | "[" expr "]" } ;
primary  = INT | STRING | SYMBOL | "true" | "false" | "nothing" | NAME
         | "(" expr ")"
         | "[" [ expr { "," expr } ] "]"
         | "(" NAME { "," NAME } ")" "->" expr
         | "if" expr block { "elseif" expr block } [ "else" block ] "end"
         | "while" expr block "end"
         | "let" [ NAME "=" expr { "," NAME "=" expr } ] block "end"
         | "begin" block "end"
         | "function" "(" [ NAME { "," NAME } ] ")" block "end" ;
block    = { stmt sep { sep } } ;                   (* fino a end/else/elseif *)
```

`elseif` is included; `for`, `elif`, destructuring, `try`, `with`, `solve`, `quote`,
`struct`, `macro` are not.
## 5. Semantics
- Everything is an expression; a block is worth the value of the last statement (`nothing` if empty).
- **Lexical Scope:** `function`, lambda, `let` and `while` introduce environments; a name is
  visible in the environment in which it is tied and in the internal ones. Inside a function
  the assignment binds in the local frame (or in an internal closure); cycles at the top level
  they update the globals.
- **Closures:** a lambda captures the environment in which it is created; the captured variables are
  shared (visible mutations).
- **Recursion:** the named functions are visible in their body (direct recursion).
- **Conditions:** `Bool` only; no truthiness. `&&`/`||` short circuit.
- **Equality:** numbers, strings and symbols by value; element-by-element lists;
  identity functions.
- **Indexes:** from 1; out of range is an execution error (§9).
- **Arithmetic:** `+ - * % ^` to `Int` with 64-bit wrap; `%` is remainder with dividend sign
  (like `rem` in Julia). `/` does not exist in Core (S1 implements rational division of
  Triad-Full).
- **Return values:** `return e` ends the function; without expression returns
  `nothing`.
- **`break`/`continue`** act on the innermost `while`.
- **Formatting of `println`/`print`:** concatenate arguments without separators;
  `Int` decimal, `Bool` `true`/`false`, `String` as-is, `Symbol` without `:` level
  top-level, `List` as `[a, b]` with symbols as `:a`, `Nothing` as `nothing`.
## 6. Expressions and instructions included
- simple assignment and `+= -= *=` (the left side is evaluated only once);
- `if`/`elseif`/`else`, `while`, `let`, `begin`, ternary;
- named `function`, short form `f(x) = e`, lambda `x -> e`, `function (x) … end`;
- call, list indexing, `return`, `break`, `continue`;
- comments and separators.
## 7. Language primitives (also visible at Triad-Full)
| category | primitives |
|---|---|
| arithmetic | `+ - * % ^`, unary `-` |
| comparison | `== != < <= > >=` |
| logic | `&& \|\| !` |
| lists | `length`, `push!`, indexing `xs[i]`, `[a, b]` |
| strings | `*` (concatenation), `length` |
| conversions | `Int("42")`, `string(x)`, `Symbol("name")` |
| I/O | `print`, `println` |
| introspection | `typeof` (type name like `Symbol`) |
`ARGS` is also available as a list of strings (the script arguments). They aren't there
`map`, `filter`, `reduce`, `sum`, `sort`, `div`, `mod`: S1 implements these in Core.
## 8. Bootstrap primitives (for self-hosted deployment only)
These are used by S1 to read and analyze the Triad source; They are **not** part of the
Triad-Full language and do not appear in `SPEC.md` §13:
| primitive | semantics |
|---|---|
| `readfile(path)` | returns the contents of the file as `String`; execution error if not readable |
| `strlen(s)` | number of bytes of string |
| `strbyte(s, i)` | bytes (`Int`, 0–255) at position 1-based |
| `strsub(s, a, b)` | substring from bytes `a` to `b` inclusive (1-based) |
| `exit(n)` | terminate the process with code `n` |
The seed must still provide `readfile` to load S1 itself; `strlen`/`strbyte`/`strsub`
they are only required when S1 needs to analyze source.
## 9. Errors
Core has no `try`/`catch` nor `Err` values: an execution error (undefined variable,
wrong type, index out of range, division by zero, file not readable) **ends on
process with exit code 1** and a diagnostic message on stderr. S1, written in Core, uses
explicit values (`[Err, kind, msg]` lists) to propagate errors of Full programs without
rely on seed exceptions.
## 10. Command line interface
Triad-Core uses the same interface as §14 of `SPEC.md`, limited to:
```
triad FILE [ARG...]     # esegue FILE come script, ARGS = [ARG...]
triad -                 # legge lo script da stdin
```

Exit: `0` success, `1` error, `2` invalid use. The REPL is not part of Core - it provides it
S1 for Triad-Full.
## 11. Compliance
- Cases in `conformance/core/cases/` use **only** the subset of §2–§7 (so they run
  both on Triad-Core and on Triad-Full) and are normative for both profiles.
- The primitives in §8 are verified by seed tests (cannot run on Triad-Full).
- A Core implementation is conformant if it passes `conformance/core/` and produces the expected output
  byte by byte with the same exit codes.
## 12. Notes for implementation in machine code (informative)
- Recommended representation: 64-bit tagged word; `Int` immediate, other values
  pointers to objects with headers (type, size).
- Environments: chain of frames with name→value association; or lists of associations.
- Lists: dynamic vector with capacity; strings: (pointer, length) immutable.
- Allocator: bump arena; no GC in the first version (bootstrap programs are
  short), then mark-sweep.
- Functions: object with pointer to the AST and captured environment; recursive evaluation with
  explicit stack to not depend on the system stack.
- The seed S0 must implement the **lexer** and the **parser** of Core, not those of Full: it is S1
  to implement the complete parser.