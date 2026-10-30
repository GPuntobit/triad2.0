# Triad 2.0 Handbook

> The complete manual of the language: vocabulary, values, flow control, functions, dispatch,
> logic, code as data, errors, contracts, budgets, tracks, effects, exercises and reference.

Triad is a self-contained programming language: block syntax and declared, multiple types
dispatch, integrated logic programming and code as data, in a single syntax. His
definition is a specific regulation independent of any implementation
([`SPEC.md`](SPEC.md), standard `0.2.0`), accompanied by an executable specification
([`SPEC-CORE.md`](SPEC-CORE.md)) and a conformance suite with verifiable goldens
([`conformance/`](conformance/README.md)).

This manual teaches the language as it is defined by the standard. It is not a summary of
specification: it is a study path, with explanations, examples and exercises. You can read it from the beginning
at the end without any other material: every concept needed to understand a chapter is explained first or
in that chapter, and the external references are optional further information. It is not a collection of pages
to be consulted at random: it is a book, and the order of the chapters builds the mental model of
language one piece at a time.

---

## How to read this manual

### Who is it addressed to?

You know how to program, in any language: you know what a variable, a function, a loop, a
recursion. This manual does not explain programming in general, **Triad** explains.

The manual doesn't assume you've read anything else: every concept is explained where it matters. I
project regulatory documents — `SPEC.md`, `SPEC-CORE.md` — and the compliance suite in
`conformance/` are the texts and tests that you can go back to for further information or to check a
extreme case, but they are not prerequisites: they are the reference for those who want to verify, not the manual
of those who want to learn. For this reason the text always distinguishes what is a rule of language from what is
which is behavior of a particular implementation.

### Two profiles, one language

The standard defines two compliance profiles, and it is useful to know how to distinguish them before starting:

| profile | what does it contain | where | is defined
|---|---|---|
| **Triad-Core** | values, functions, closures, flow control, lists, strings, I/O | [`SPEC-CORE.md`](SPEC-CORE.md) |
| **Triad-Full** | everything: declared types, dispatch, logic, macros, contracts, budgets, tracks, effects | [`SPEC.md`](SPEC.md) |

Triad-Core is a **subset** of Triad-Full: every Core program is also a Full program
valid and must behave in the same way. The manual presents the two profiles **on the same level**,
by logical construction: each chapter introduces a construct and says in which profile it exists. Not
because Full is "further ahead", but because they are two sides of the same specification.

The Core profile is not a simplified version for educational convenience: it is the chosen subset
why a bootstrap interpreter, written in a few thousand lines, can run it, and why it
same language can describe itself. Full adds constructs that require a more engine
rich — multiple dispatch, unification, macro expansion — but it doesn't change the meaning of
the ones Core already has. Learning Core, therefore, is not time spent on a different language.

Where the difference matters, you find two markers:

- **[Core]** — the construct exists in the bootstrap subset;
- **[Full]** — the construct exists only in the full standard.

A profile marker describes what the standard defines, not what each program does
installed already knows how to run. For this reason the manual distinguishes three levels: the normative rule
(what the construct should mean), availability in the Core or Full profile and the status
of the implementations present in the repository. A Full example can be corrected according to the
standard and, at the same time, not yet be executable by the current runtime. When a
example reports **Output (golden Full)**, the result is an expected value preserved by the suite,
not a check just performed by a complete Full interpreter.

To study a construct without confusing these levels, ask yourself in order: what form
do you accept grammar? What values ​​does it read and produce? What effects or errors can it generate? in which one
Is profile defined? which implementation and which conformance case verify this? This one
sequence allows you to move from code to semantics and then to proofs, instead of dealing
the output of a single runtime as the language definition.

### Notation conventions

| notation | means |
|---|---|
| `monospace` | Triad code or a literal value |
| **Output:** | the exact output produced by the program |
| **[Core]** / **[Full]** | the profile in which the construct exists |
| `SPEC §n` | the corresponding regulatory section |

Code blocks are marked with their executable level:

| fence | means |
|---|---|
| ```` ```triad ```` | program **executable today** with the reference interpreter |
| ```` ```triad-full ```` | program **standard specification**: defined and normative, but not yet executable by the current runtime |

### How to run the examples

Examples marked `triad` are run with the JavaScript reference interpreter:

```sh
node seed/dev/triad_core.cjs program.triad
```

The program receives arguments in `ARGS` (list of strings, without the program name) and lo
shebang `#!` in first line is ignored by the parser.

```triad
#!/usr/bin/env triad
# greeting.triad
println("hello, " * "Triad")
println(6 * 7)
```

```sh
node seed/dev/triad_core.cjs greeting.triad one two
```

**Output:**

```text
Hi, Triad
42
```

The example shows three things that are true throughout the book. The shebang is just a convenience of the systems
operations: the parser skips it, so the program actually starts from the second line. `println`
It doesn't put separators between arguments, so the comma and space you see in the output are
characters written in the program, not automatic formatting. Finally `6 * 7` is calculated
before printing: The arguments of a call are expressions, not text. Past topics
from the command line (`one`, `two`) do not become variables with those names: they all end up in the list
`ARGS`, as explained in chapter 20.

### Index

**Part I — Language**

1. [Lexicon](#chap-1) · 2. [Values and types](#chap-2) · 3. [Variables and assignment](#chap-3) ·
4. [Operators and precedence](#ch-4) · 5. [Flow control](#ch-5) ·
6. [Functions](#cap-6) · 7. [Types and multiple dispatch](#cap-7) ·
8. [Lambdas, closures and scopes](#cap-8) · 9. [Lists](#cap-9) ·
10. [Strings, symbols and conversions](#cap-10) · 11. [Errors as data](#cap-11) ·
12. [Contracts](#cap-12) · 13. [Budget](#cap-13) · 14. [Tracks](#cap-14) ·
15. [Declared Effects](#chap-15) · 16. [Logic](#chap-16) ·
17. [Code as given](#cap-17) · 18. [Macro](#cap-18) ·
19. [Builtin](#cap-19) · 20. [Command line and REPL](#cap-20) ·
21. [Bootstrap primitives](#ch-21) · 22. [Idiomatic style and patterns](#ch-22)

**Part II — Exercises** · [23. Guided exercises](#cap-23) · [24. Exercises on Triad-Full](#cap-24)

**Part III — Reference** · [25. Grammar](#cap-25) · [26. Quick tabs](#cap-26) ·
[27. Error table](#cap-27) · [28. Glossary](#cap-28) ·
[29. What's going on today](#cap-29)

**Appendices** · [A. Declared influences](#app-a) · [B. Where to watch](#app-b)

---

<a id="part-1"></a>

# Part I — Language

The first part builds the language layer by layer: first the building blocks (lexicon and values),
then the expressions and flow control, then the functions and calculation models that Triad
adds — dispatch, closures, logic, code as data — and finally the tools with which a
program communicates with the outside (errors, contracts, budget, tracks, effects). Every chapter yes
relies on precedents; the examples are short on purpose, because the point is not to admire a program
but understand one rule.

<a id="cap-1"></a>

## 1. Vocabulary

### 1.1 Identifiers

An identifier begins with a letter or `_`, followed by letters, digits, or `_`. A final `!` is
allowed if not followed by `=`. **[Core]**

```triad
x = 1
sum_2 = 2
_ = 3
valid_name = 4
```

`push!`, `sort!` and similar are legitimate names: the final `!` convention is for functions that
they change their topic (chap. 9).

The `!` does not change the meaning of the name and is not an operator: it is a signal to the reader. The parser
accepts it only as the last character, and only if the following character is not `=`; otherwise
a confrontation would begin. This is the first of the conventions that Triad inherits from Julia: the name
declares a contract, but the programmer must respect it.

In Triad-Full identifiers also allow non-ASCII letters. **[Full]**

```triad-full
age = 42
```

### 1.2 Numbers

Integers are written with decimal places; `_` works as a separator. The sign is an operator
unary, not part of the literal. **[Core]**

The distinction is more important than it seems: `-5` is the application of the `-` operator to
literal `5`, not a negative number written in a special way. That's why there isn't one
"negative syntax" to remember: the parentheses and precedence levels from chapter 4 already explain
what happens in an expression like `-x * y`.

```triad
println(42)
println(1_000_000)
println(-5)
```

**Output:**

```text
42
1000000
-5
```

`Float` exists only in Triad-Full. **[Full]**

```triad-full
println(3.14)
println(1e-9)
```

### 1.3 Strings

A string is an **immutable** sequence of UTF-8 bytes, enclosed in double quotes. Escapes are `\n`,
`\t`, `\"`, `\\`. **[Core]**

```triad
println("hello\n")
println("tab:\t|")
println("quotes: \"")
println("backslash: \\")
```

**Output:**

```text
hello

tab: |
quotes: "
backslash:\
```

In Core **there is no interpolation**: `"x = $x"` literally prints `x = $x`. In Full exists, and
you write `$x` for a simple expression and `$(expr)` for a complex one. **[Full]**

```triad-full
x = 42
println("x = $x")
println("x + 1 = $(x + 1)")
```

### 1.4 Symbols

A symbol is `:` followed by a name or operator: `:alice`, `:+`. Two symbols are equal if
they have the same name. In Triad-Full the symbol is also the atom of logic (chap. 16). **[Core]**

A symbol serves to give a stable name to a thing — a category, a key, an atom — without the
flexibility and the cost of a string. The difference compared to a string is not just one of convenience:
`:alice` is an identity, `"alice"` is a sequence of bytes; two symbols with the same name are lo
same value wherever they appear, while two strings must be compared character by character. It is
this property that makes the symbols suitable for record keys (chap. 2), list tags and
to the atoms of facts (chap. 16).

```triad
println(:alice)
println(:+)
println(:ok == Symbol("ok"))
```

**Output:**

```text
alice
+
true
```

### 1.5 Comments

`#` comments to end of line. `#= … =#` comments on multiple lines; the standard describes this shape
but **doesn't** dictate that block comments are nested, and the reference interpreter closes at
first `=#`: Don't rely on nesting. **[Core]**

```triad
#= comment
   on multiple lines =#
x = 1_000 # line comment
println(x)
```

**Output:**

```text
1000
```

### 1.6 Separators and line endings

A statement ends with a newline or `;`. Newlines **close** a statement, except inside
`( )`, `[ ]`, and `:( )`, and except immediately following a binary operator or a `rule` comma.

```triad
println(1); println(2)
```

A practical consequence: **in Triad-Core each newline closes the statement**. Core's grammar
does not have a line continuation rule: an expression split across multiple lines is not a
valid program. Write **one statement per line** and use `;` to separate two statements.

```triad
total = 1 + 2 + 3
println(total);
println("second statement")
```

**Output:**

```text
6
second education
```

The rule has a consequence on formatting: when you want to break a long expression, the
parentheses are not enough in Core. The reference interpreter ends the statement at the first line break too
inside a call, so `println(1 +` and `2)` on different lines is not a valid program today.
For the code intended for the current runtime only one rule applies: one statement per line, and `;` only
when two instructions must be on the same line.

> **In Triad-Full** the rule is more permissive: `SPEC §1` states that a newline **doesn't** close
> the statement inside `( )`, `[ ]` and `:( )`, nor immediately after a binary operator. The interpreter of
> current reference does not yet implement this exception, so even in Full the form
> safe remains one instruction per line.

### 1.7 The rule of the colon and the question mark

`:` has three meanings and `?` has two. The specification explicitly calls them “the classical problem
of `:`» — is the first point where Triad deviates from the syntax you know.

| writing | meaning |
|---|---|
| `1:n`, `xs[2:end]` | `:` attached to a value and without spaces → **range** |
| `f(:a)`, `x = :a` | `:` not preceded by a value and followed by a name → **symbol** |
| `:( … )` | → **listed code** |
| `c ? a : b` | `:` surrounded by spaces → **ternary separator** |

| writing | meaning |
|---|---|
| `?x` | `?` attached → **logical variable** |
| `? ` | `?` with space after → **ternary** |

Hence the rule of thumb: when `:` is ambiguous, **add or remove spaces**. `xs[2:end]` is a range;
`c ? a : b` is a ternary because the two spaces surround it.

The two tables look like a list of special cases, but they stem from a single idea: a character
adhering to the previous token belongs to that token, a separate one belongs to the syntax.
This is why in Triad spacing is not a question of style: it is information that the parser reads. If
write `xs[2: end]` or `a ? b:c`, changing the spaces does not change the appearance of the program: you change
what the parser recognizes, and most of the time you get a syntax error. The advice is
always write the spaces that make the meaning explicit.

### 1.8 Keywords

The standard defines **29 keywords**:

```
function struct macro end if elseif else for in while let begin return
break continue fact rule solve quote try catch with requires ensures
true false nothing is
```

And **4 contextual words**, valid only after `solve`:

```
limit depth steps trace
```

`true`, `false` and `nothing` are values, not structural words.

Keywords are reserved because the parser must recognize them before knowing what they are
doing: if `if` could also be a variable name, reading a line would depend on the
context in an unpredictable way. `true`, `false` and `nothing` are exceptions only in appearance: they are
values that the language predefines, not syntactic forms. The four contextual words show
the same principle in reverse: `limit`, `depth`, `steps` and `trace` are very normal names as long as
they do not follow `solve`, and only there do they have a special meaning. This distinction reduces the number of
reserved words and allows you to use natural names in the rest of the program.

### 1.9 Advanced identifiers and conventions

In Triad-Core identifiers are limited to ASCII: letters, digits, and `_`. In Triad-Full yes
they also allow non-ASCII letters (accented, Greek, Cyrillic): `age`, `π`, `Δx` are names
valid. **[Full]**

```triad-full
age = 42
π = 3.14159
Δx = 0.001
println(age + π)
```

The trailing `!` convention (`push!`, `sort!`) indicates functions that **mutate** their argument.
It is the only special character allowed inside an identifier: the grammar accepts letters, digits,
`_` and the final `!`, and nothing more. In particular the `?` is **not** part of the name, because in Triad
introduces a logical variable or ternary: `valid?` is not a valid identifier. For a
predicate uses a normal name and lets the `Bool` type of the result tell what it is —
`empty`, `is_valid`. **[Core]**

```triad
function push!(xs, v)
    # mutates xs and returns it
    xs
end

function empty(xs)
    length(xs) == 0
end
```

The body of `push!` is intentionally empty here: the example is about names, not implementation. The
True mutation of lists, with `push!` and with assignment to an element, is in chapter 9.

Identifiers that match a keyword are not allowed: `function`, `end`,
`if` cannot be used as variable or function names. **[Core]**

### 1.10 Escape and advanced strings

The standard sets four escapes in strings: `\n`, `\t`, `\"`, `\\`; in Triad-Full it is added
`\$`, because the `$` introduces interpolation and must be neutralized when it must remain a character
normal. The extended forms `\r`, `\0`, `\u{…}` and `\x{…}` that appear in the following fragment are not
listed in `SPEC §1`: treat them as extensions of a single implementation, not as guarantees of
language. A portable program uses documented escapes. **[Full]**

```triad-full
println("a\r\nb") # carriage return CRLF
println("unicode: \u{1F600}") # emoji
println("hex: \x{41}") # 'A'
```

A string is a sequence of UTF-8 bytes and strings are **immutable**: any operation of
concatenation creates a new string, as shown in the example below. Length is measured in
bytes and not in characters, a detail that matters as soon as you leave the Latin alphabet (chap. 10). **[Core]**

```triad
a = "hello"
b = a * "world"
println(a) # "hello" — unchanged
println(b) # "hello world"
```

**Output:**

```text
hello
hello world
```

### 1.11 Vocabulary exercises

1. Write a program that prints your name and age on two lines, using `\n` and
   string concatenation.
2. Define an identifier with a leading `_` and one with a trailing `!`; print them.
3. Try writing `x = 1_000_000` and verify that the output is `1000000`.
4. (Full) Write a string with interpolation `$x` and `$(x + 1)`.
5. (Full) Define the symbol `:ok` and compare it to `Symbol("ok")`.

---

<a id="cap-2"></a>

## 2. Values and types

### 2.1 The types

A Triad value always belongs to a type, and the type can always be observed: the table lists the
types of the standard, with the name that `typeof` returns and the profile in which they exist.

| type | values ​​| `typeof(v)` |
|---|---|---|
| `Int` | 64-bit signed integers, wrapped arithmetic | `Int` |
| `Float` | floating point numbers **[Full]** | `Float` |
| `Bool` | `true`, `false` | `Bool` |
| `String` | immutable UTF-8 byte sequence | `String` |
| `Symbol` | `:name` | `Symbol` |
| `List` | mutable heterogeneous list, indices of 1 | `List` |
| `Function` | named function, lambda, builtin | `Function` |
| `Nothing` | `nothing` | `Nothing` |
| `Expr` | quoted code **[Full]** | `Expr` |
| `Term`, `LVar` | logical terms and variables **[Full]** | — |
| `Solution` | `{who = :dave}` **[Full]** | — |
| `Err` | error as given **[Full]** | — |
| `Type` | the types themselves are **[Full]** | values — |
| struct user | `Point(3.0, 4.0)` **[Full]** | `Point` |

The Core type set is **closed and small**: `Int`, `Bool`, `String`, `Symbol`, `List`, `Function`,
`Nothing`. In Core there are no `Float`, `Term`, `Solution`, `Err` as language values: a
error is a list tagged `[:Err, kind, msg]` (ch. 11) and a struct is `[:Point, x, y]`. The set
closed is not an arbitrary limitation: a bootstrap interpreter must be able to represent every
value with few structures, and the Full concepts that are missing — error, struct, solution — yes
they reconstruct by convention on lists and symbols.

`typeof` returns the **type name as symbol**. Profile detail matters: in Core the
result is a `Symbol`, so `typeof(1) == :Int` is the natural comparison; in Triad-Full the types are
values of type `Type`, so `typeof(3) == Int` compares directly to the type. The press is there
same (`Int`), but the operation you write is different — which is why the table above has a
column `typeof(v)` with the name and not the type.

It's helpful to separate three ideas that may seem like the same thing in syntax. The **value** is the
concrete data, for example `5` or `"hello"`; the **dynamic type** describes the category of the value
that the program is manipulating; a **declared constraint** instead restricts which values it can
take on a name or parameter. In Core the type is observed with `typeof`, but it is not declared
variable like `x::Int`. In Full the types also enter signatures, structs and dispatch.
A conversion like `Float(3)` constructs a compatible value; an assertion like `x::Int`
checks a value already obtained. They are different operations: converting can change the value,
assert is not a request for conversion.

Another important distinction is between **nominal** type and structural form. In Full one
`struct Point` declares a type identity, so a `Point` value does not become another type
just because it has similar fields. In Core, where there are no structs, the same information is
conventional: a list like `[:Point, 3, 4]` carries the `:Point` tag and fields in positions
agreed by the program. The tag makes it possible to recognize the record, but does not add itself
field controls, immutability or dispatch.

```triad
xs = [1, :a, "s"]
println(typeof(1), " ", typeof("s"), " ", typeof(:a), " ", typeof(xs))
println(typeof(nothing), " ", typeof(true), " ", typeof(x -> x))
```

**Output:**

```text
Int String Symbol List
Nothing Bool Function
```

### 2.2 Type hierarchy

`Int <: Number`, `Float <: Number`, and each type is a subtype of `Any`. `Any` is the supertype used
in signatures when a parameter accepts anything. **[Full]**

The hierarchy exists for dispatch (ch. 7): a method declared on `Number` also accepts the
`Int`, because `Int` is a subtype of `Number`. In Core the hierarchy cannot be observed, because not
there is multiple dispatch, but the reason remains that the types have names and are not just labels of
convenient: the relationship between the names is what allows you to write a method once and apply it to
a family of values.

```triad-full
function accept_any(x::Any)
    "whatever: " * string(x)
end
```

### 2.3 Struct

A `struct` is an immutable record with typed fields and positional constructor. The
constructor checks fields; an `Int` passed to a `Float` field is converted, a value is not
convertible produces `Err(:type)`. **[Full]**

```triad-full
struct Point
    x::Float
    y::Float
end

p = Point(3, 4)
println(p.x, " ", p.y)
println(typeof(p) == Point)
println(p isa Point)
```

**Output (golden Full):**

```text
3.0 4.0
true
true
```

In Core the same concept is represented with a **tagged list**: `[:Point, x, y]`, with the
type symbol in first position. This is how the `selfhost/` interpreters represent the
struct Full. The difference between the Full and Core records is not just one of writing: the struct has
a type identity and immutable fields, the Core record is a list, so it can be mutated and
no one stops you from building one with the wrong tag. The tag makes the data recognizable, not
makes it safe: the checks that a struct does on its own, in Core must be done by the program.

```triad
point(x, y) = [:Point, x, y]
px(p) = p[2]
py(p) = p[3]
println(dot(1, 2), " ", px(dot(1, 2)))
```

**Output:**

```text
[:Point, 1, 2] 1
```
### 2.4 Conversions

`Int(x)`, `Float(x)`, `String(x)`, `Symbol(x)`. The name of the type used as the convert function; the
name of a struct used as a **construct** function. **[Full]**

The conversion is an explicit operation: Triad does not transform types itself, except at points
specified in the specification — an `Int` passed to a struct's `Float` field, or the value of
return checked with `::R`. Elsewhere you ask for the conversion, and this makes it readable
point at which the type changes. `string(x)`, which you see in the table in chapter 10, is a special case:
it is defined for each value and is used to construct text, which is why it is the way in Core programs
normal to convert a number to string.

```triad-full
println(Int("42") + 1)
println(Float(3))
println(Symbol("hello"))
println(String(42))
```

`Int(s)` and `Symbol(s)` also exist in Core, but only for strings and symbols. **[Core]**

```triad
println(Int("41") + 1)
println(Symbol("bob"))
```

**Output:**

```text
42
bob
```

### 2.5 Type assertion

`e::T` returns `e` if it is of type `T`, otherwise it produces `Err(:type)`. **[Full]**

```triad-full
x = 3
println(x::Int)
println(iserr(x::String))
```

### 2.6 The constraint of the declared

`x::T = e` — and a parameter `x::T` — **fixes** the type of that name in the environment in which it originates. The
Subsequent assignments are checked and converted against `T`. A new statement
`x::U = …` replaces the constraint; an undeclared name with type remains free; a binding in
an internal environment (`let x = 2.5`) does not inherit the external constraint. **[Full]**

```triad-full
x::Int = 5
x = 6 # good
x = 5.5 # Err(:type)

y::Float = 1.0
y = 2 # 2.0: Int -> Float conversion

s = "a"
s = 3 # fine: s is not declared with a type
```

The constraint applies to the environment in which the name was born, not forever: it is a local annotation, not
a global statement. This allows you to introduce types into an already written Core program
without rewriting the structure, and explains why `let x = 2.5` inside a function is not an error
even when out `x` was bound to `Int`. The check happens at every assignment, so the
cost is an extra check for each write; in return, a value of the wrong type does not enter
never in the name, and the error arrives where the type was promised, not much later.

### 2.7 Conditions accept only `Bool`

There is no concept of "implicit truth": a value does not become true or false by convention.
`if 1` is an error, not `true`. This applies to `if`,
`while`, `&&`, `||`, `!`, the ternary and the comprehension filters. **[Core]**

```triad
println(1 < 2 && 2 < 3)
x = 3
println(x > 2 ? "large" : "small")
```

**Output:**

```text
true
big
```

The choice is deliberate. In a language with dynamic types and errors as values, the only one
what a condition must do is produce `true` or `false`; admit "true" values for
convention (`0`, `""`, `[]`) would make the meaning of a program ambiguous and shift
the error away from its cause. With the strict rule, `if xs` is an immediate error and says that there
a comparison is needed — for example `if length(xs) > 0`. The same goes for `&&` and `||`: both
operands that are evaluated must be `Bool`, even if the short circuit spares one.

### 2.8 How to print a value

`print` and `println` concatenate arguments **without separators**; `println` adds a newline.

| value | how it is printed |
|---|---|
| `Int` | decimal |
| `Bool` | `true` / `false` |
| `String` | as it is |
| `Nothing` | `nothing` |
| `Symbol` | **without** `:` if passed directly, **with** `:` inside a list |
| `List` | `[a, b]`; strings inside do not have quotes |
| `Function` | `#lambda(x)` |

```triad
xs = [1, :a, "s", true, nothing, [2, 3]]
println(xs)
println(:alice)
print("without ", "return")
println()
```

**Output:**

```text
[1, :a, s, true, nothing, [2, 3]]
alice
without a leader
```

The difference between a symbol printed alone and inside a list is not a whim: outside one
list the symbol is the only content of the output, inside a list you need a way to distinguish it from
a string with the same text. This is why `println(:a)` prints `a` while lists use `:a`, and
for this reason the table should be read as «how a value appears when it is printed», not as «how it is
made the value". Strings inside a list do not have quotes for the same reason: the
print is meant to be readable, not to be read back by the parser.

Equality compares numbers, strings and symbols **by value**, lists **element by
element** (also nested), functions **per identity**. **[Core]**

```triad
println([1, [2, [3]]] == [1, [2, [3]]])
println("ab" == "a" * "b", " ", :a == :a, " ", 1 == 2)
```

**Output:**

```text
true
true true false
```

---

<a id="cap-3"></a>

## 3. Variables and assignment

`name = expr` binds or updates a name. The assignment **is an expression** and is the value
assigned. `+=`, `-=`, `*=` update an existing variable and evaluate the left side a
only once. Using a name that was never assigned is an execution error. **[Core]**

The `=` sign does not read "write to memory": it binds a name to a value. When the name doesn't exist
it creates it, when it exists it replaces the bond. Triad does not distinguish the two cases with keywords
different and does not have a word to declare a variable: `let` introduces a scope, it does not declare a
type. This simplicity has a price that should be known immediately: a poorly written name doesn't work
reported as you write, but only when that line is executed.

```triad
x = 42
y = x + 8
x = x + 1
z = (x + y) * 2
println(x, " ", y, " ", z)
n = 10
n += 5
n -= 3
n *= 2
println(n)
```

**Output:**

```text
43 50 186
24
```
There are no declarations: variables are dynamic. The **visibility** rules can be seen in the
chapter 8.

Why would an assignment have a value? Because in Triad everything that can appear in
a program is an expression, and assignment is no exception: so `x = 42` can fit inside a
`if`, a `let`, or a function argument without special syntax. The value is the one assigned,
not a successful `Bool` like in other languages; that's why you won't write `if x = 5` expecting it
a check, because `5` is not a `Bool` and the condition fails with a type error.

`+=`, `-=` and `*=` are also expressions and take the updated value. They are not shapes
declarative and do not introduce a new name: they update a link that must already exist. In return
they evaluate the left side only once, a detail that with a simple name is not noticed but which
counts when the target is a list element (`xs[i] += 1`, chap. 9): so the index is not
calculated twice.

Read the example distinguishing the **name** from the value: after `x = 42`, `x` is a bond
of the current environment; `y = x + 8` reads that binding and stores the result `50` in a binding
different; `x = x + 1` first calculates `43` and then replaces the value associated with `x`. As a result
`y` remains `50`: it is not an automatic alias of the expression that produced it. The assignment
returns the new value, so it can appear inside an expression, but that doesn't mean that
each assignment is global: function, lambda and `let` define distinct scope rules.

Finally, renaming is not the same as mutating an object. With `x = 43` the bond of changes
`x`; with `xs[1] = 43` changes an element of the list to which `xs` refers. If a middle name
points to the same list, it will see the mutation; a local reassignment of `xs`, however, does not change
automatically the link of the other name. This difference becomes essential when one
function shares a list with the caller.

---

<a id="cap-4"></a>

## 4. Operators and precedence

The parser is a **Pratt** with twelve levels. «Pratt» means that each operator has a number of
precedence and the parser, reading from the left, knows when to stop and return control to the
lowest level: it is a compact way of describing the tree without writing a rule for each
combination of operators. From lowest to highest precedence:

| level | operators | associativity |
|---|---|---|
| 1 | `=` `+=` `-=` `*=` | right |
| 2 | `x -> e`, `(a, b) -> e`, `c ? a : b` | right |
| 3 | `\|\|` | left, short circuit |
| 4 | `&&` | left, short circuit |
| 5 | `==` `!=` `<` `<=` `>` `>=` `in` `isa` `is` | left |
| 6 | `a:b` | range, no spaces |
| 7 | `+` `-` | left |
| 8 | `*` `/` `%` | left |
| 9 | `-x` `!x` `+x` `$x` | prefixes |
| 10 | `^` | **right** |
| 11 | `e::T` | assertion of type |
| 12 | `f(args)` `xs[i]` `a.field` | postfixes, with no space before `(` and `[` |

Levels 6, 8 (division), 9 (`$x`), 11 (`::`), and some comparison operators exist only in
Triad-Full. In Triad-Core the levels actually used are **ten**, because the range is missing
division, `$x`, `::` and the operators `in`, `isa`, `is`; once those are removed, the table becomes compact but the
relationship between the operators who remain is the same. The number twelve, which the glossary reports, is
therefore the Full profile count: is not in contradiction with the ten levels of Core, it is the
account for a larger profile. **[Core]**

Precedence decides **how the parser groups** the operators, not what computation occurs for
first in every possible program. For example, `2 + 3 * 4` is read as `2 + (3 * 4)`: the
multiplication belongs to a stronger level than addition. The parentheses do not change the rule
of language; they make a programmer's choice explicit and help the reader.
Associativity instead solves the parity of precedence: `2 ^ 3 ^ 2` is `2 ^ (3 ^ 2)`, while the
chain subtractions cluster on the left. When the precedence is unfamiliar, write the
brackets is a form of executable documentation.

Grouping should not be confused with evaluation. `&&` and `||` are short-circuit operators:
the second operand is evaluated only if the first does not already determine the result. This allows
to put a control on the right that depends on a valid value on the left, for example before
verify that an index is within bounds and then read the list. In Core every condition must
still produce a `Bool`; an integer or a list are not implicitly converted to
true/false.

### 4.1 Integer arithmetic

Core's arithmetic is entirely integer and these four rules should be read as a single model,
not as isolated curiosities: the `Int` type is a 64-bit block, operations treat it as such,
and the division is left at Full because it requires another type of number.

- `+ - * ^` to `Int` with **64-bit wrap** (two's complement);
- `%` is the **signed remainder of the dividend**, like Julia's `rem`: `-7 % 3 == -1`;
- `^` with negative exponent is an error; `%` for zero is an error;
- **`/` does not exist in Core**: the division is Triad-Full.

```triad
println(2 + 3 * 4, " ", (2 + 3) * 4, " ", 2 ^ 3 ^ 2)
println(7 % 3, " ", -7 % 3, " ", 10 % 4)
println(9223372036854775807 + 1)
```

**Output:**

```text
14 20 512
1 -1 2
-9223372036854775808
```

Note `2^3^2 == 512`: the exponent is right associative, as in mathematics.

The wrap is not a flaw to work around: `Int` is a 64-bit integer and the arithmetic is that of
two's complement, so exceeding the maximum brings you back to the minimum. If your calculation can grow
beyond 64 bits, in Full you can switch to `Float` (with its precision limits); in Core you must
design the calculation to stay within bounds, for example by checking values before
multiply.

`%` follows the dividend sign because it is the remainder of integer division truncated towards zero, not
the mathematical form, which would always be non-negative: `-7 % 3` is `-1` and not `2`. The distinction
counts in algorithms that use the remainder to alternate indices or to normalize negative values.

Finally `/`: in Core it does not exist because the exact division of two integers does not have a type to live in
without the floating point numbers. In Full `/` produces a `Float` and `div` does integer division; if
you work in Core, the entire division is written by hand, as in the example in chapter 11.4.

### 4.2 Logic and comparisons

`&&` and `||` short circuit. Comparisons **do not** chain: `1 < 2 < 3` is an error (yes
compare `Bool < Int`); write `1 < 2 && 2 < 3`. **[Core]**

```triad
println(!false, " ", true && false, " ", false || true)
println(1 < 2 && 2 < 3)
```

**Output:**

```text
true false true
true
```

---

<a id="cap-5"></a>

## 5. Flow control

In Triad **everything is an expression**: `if`, `while`, `let`, `begin` have a value, that
of the last executed statement (`nothing` if there is none).

The exceptions are `return`, `break` and `continue`: they don't produce a value, they stop the flow.
Assignment, on the other hand, is an expression (chap. 3), and this uniformity is what makes it possible
write `v = if condition … end` without special syntax: a block is an expression like lo
it is a sum.

This rule unifies two uses that often have separate syntaxes in other languages: choose a
branch and calculate a result. In `v = if condition ... end`, the complete expression produces the
value of the last expression of the chosen branch; the code of the unchosen branches is not executed.
Instructions that produce output or mutate a list can fit in the same block as
an expression that evaluates to a value: the result of the block is the last expression, not one
automatic combination of all intermediate results.

The conditions are intentionally restrictive: `if`, `while`, ternary, `&&` and `||` ask
a `Bool` value. You do not use an "implicit truth" rule that interprets `0`, empty strings, or lists
empty like fakes. This makes type errors visible close to the decision that has them
provoked, instead of transforming them into unexpected branches.

### 5.1 `if` / `elseif` / `else` **[Core]**

```triad
function rank(x)
    if x < 0
        "negative"
    elseif x == 0
        "zero"
    else
        "positive"
    end
end
println(rank(-3), " ", rank(0), " ", rank(7))
v = if 2 > 1 :yes else :no end
println(v)
```

**Output:**

```text
negative zero positive
yes
```

In the example `classify` returns the last expression of the chosen branch, so it is not needed
no `return`. `v = if 2 > 1 :yes else :no end` shows the same thing without function: the block is
a value and `v` receives `:si`. The branch that doesn't win isn't executed at all, it isn't evaluated
and then discarded: if it contained a print or mutation, you wouldn't see it.
The ternary `c ? a : b` is the short form of `if` and has the same precedence as `->`. **[Core]**

### 5.2 `while`, `break`, `continue` **[Core]**

`break` and `continue` act on the **innermost** loop.

```triad
i = 0
sum_odd = 0
while i < 10
    i += 1
    if i % 2 == 0
        continue
    end
    sum_odd += i
end
println(odd_sum)
while true
    break
end
println(:end)
```

**Output:**

```text
25
end
```

The first loop adds only the odd ones: `continue` skips the rest of the body, so the addition doesn't
happens for evens, and the `i` counter has already been incremented before the jump. If the increase
had it been at the bottom of the body, `continue` would have skipped it and the loop would have been infinite:
It's the classic `continue` trap in manual counter loops, and why it's convenient
increase immediately, before any possible early exit.

`break` and `continue` act on the **innermost** loop; there is no etiquette for dating two
loops in one go, so in that case you use a state variable.

In Core **there is no `for`**: you iterate with a counter and `while`. In Full `for` exists (ch. 5.6).

### 5.3 `let` and `begin` **[Core]**

`let` introduces a new scope with local bindings. `begin … end` groups statements into one
expression, but it is not "without consequences" on the scope: the reference interpreter updates a name
already bound outside the block, while a **new** name assigned inside `begin` is not visible
out. The specification does not list `begin` among the constructs that introduce environments and no cases of
conformity sets the point: for new names it is prudent to treat the block as a boundary.

```triad
x = 1
let x = 10
    let x = 20
        println(x)
    end
    println(x)
end
println(x)
r = begin
    a = 2
    at * 21
end
println(r)
```

**Output:**

```text
20
10
1
42
```

The example shows three distinct bindings for `x`: the external one, the one introduced by the first `let` and
the one introduced by the second. Each `let` creates a new environment, and a name is looked up first
in the innermost environment; for this reason the three prints give `20`, `10`, `1` and none of the three
bindings touches the others. `begin`, however, is just a grouping: the example assigns `a = 2` e
uses `a * 21` in the same block, so it doesn't depend on what remains visible after. The rule from
keep in mind is that the block is not used to release new names: if a value must be used
out, assign it to a name that already exists before `begin` or return it as a value
of the expression. In practice `let` is used when you want to isolate a name or reuse an already taken name
without altering the external bond; `begin` is used to group statements into a single expression.

### 5.4 `for` and ranges **[Full]**

`for` iterates over a list, range, or result of `solve`. `a:b` produces the range from `a` to `b`
included.

```triad-full
s = 0
for i in 1:10
    s += i
end
println(s)

xs = [1, 2, 3]
println(xs[end])
println(xs[2:end])
```

**Output (golden Full):**

```text
55
3
[2, 3]
```

`end` is a special name that takes the position of the last element and can be used inside le
square brackets of an index: `xs[end]` is the last element, `xs[2:end]` is the tail from the second
element onwards. The range `a:b` is inclusive at both ends, so `1:10` contains ten
values; it is a form of Triad-Full, and in Core it is achieved with a loop. Destructuring in the `for`
is covered in chapter 24.

### 5.5 Comprehensions **[Full]**

The comprehension `[e for x in xs]` constructs a list; with `if` it adds a filter.

```triad-full
println([x^2 for x in 1:4])
println([x^2 for x in 1:4 if x > 2])
```

**Output (golden Full):**

```text
[1, 4, 9, 16]
[9, 16]
```

The comprehension is sugar for a loop that accumulates into a list: for each `x` of `1:4` evaluates
`x^2` and adds the result, without an explicit counter. The `if x > 2` filter works
on the element, not on the index: `9` and `16` remain because `3` and `4` exceed the threshold. In Core
`[e for x in xs]` does not exist and the handwritten functions in the chapter do the same job
22.1; in Full, comprehension is often the most readable form, as long as the expression remains short.

### 5.6 `try` / `catch` **[Full]**

In Full the error is a **value**, so `try` has two forms: with `catch` the managed branch produces the
expression value; without `catch`, the error **becomes** the value of the expression.

```triad-full
e = try div(1, 0) end
println(iserr(e), " ", e.kind)

r = try div(1, 0) catch err; 0 end
println(r)
```

**Output (golden Full):**

```text
true domain
0
```

The two forms are not interchangeable. `try and end` doesn't handle the error: it makes it the value
of the expression, so you can check it with `iserr` and decide later. `try and catch err; h end` instead
retrieve: bind `err` to the error and evaluate `h`, whose value becomes the result. In the first case
`e` is an `Err`, in the second `r` is `0`. Choosing between the two is a design decision: the first
form keeps the error in the normal flow, the second confines it to a precise point. It's the reason why
to which Chapter 11 insists that “error as given” does not mean “the program continues from
only": without a `try` to observe it, the error reaches the upper level and the program terminates.

---

<a id="cap-6"></a>

## 6. Functions

### 6.1 Three forms of definition **[Core]**

A named function is defined in two ways — short form and block form — and the third form is
an anonymous function tied to a name. The difference is only syntactic: the function you get is the
itself. The short form is used when the body is a single expression; the form `function … end`
when the body has multiple statements or a `return` that exits before the end; the lambda assigned to a
name is useful when the function value arises inside an expression.

```triad
# short form: the body is an expression
square(x) = x * x

# block form: the value is that of the last expression
function compute(n)
    m = n + 1
    m * 2
end

# anonymous function assigned a name
multiply = function (a, b)
    a * b
end

println(square(4), " ", calculate(3), " ", multiply(6, 7))
```

**Output:**

```text
16 8 42
```

`square` and `calculate` are named functions, `multiply` is a function-type value bound to a
name: from the point of view of the call there is no difference. Choose the shape that makes it most readable
the body, not the one that seems most modern; the short form with only one expression makes it obvious
that there are no hidden effects between the lines.

### 6.2 `return`, recursion, arity

`return e` exits the function immediately; `return` alone returns `nothing`. A named function
it's visible in your body, so direct recursion works. The number of arguments must
coincide with the parameters. **[Core]**

```triad
function size(n)
    if n > 100
        return :large
    end
    :small
end
factorial(n) = n < 2 ? 1 : n * factorial(n - 1)
fib(n) = n < 2 ? n : fib(n - 1) + fib(n - 2)
gcd(a, b) = b == 0 ? a : gcd(b, a % b)
println(size(500), " ", size(5))
println(factorial(10), " ", fib(15), " ", gcd(48, 18))
```
**Output:**

```text
big small
3628800 610 6
```

A call can be read as a precise sequence: the arguments are evaluated, the
context of the function, you associate the values with the parameters and execute the body. The body ends
in one of two ways: reaches the end and returns the last expression, or executes `return`,
which immediately interrupts the body and returns the indicated value. `return` without
expression returns `nothing`. A recursion is a new call with its own set of
local parameters; the base case prevents you from continuing to create endless calls.

Arity is also part of the signature in Core: `sum(1, 2)` is not interchangeable with `sum(1)`.
Triad-Full adds types to signatures and allows multiple methods with the same name; this doesn't change
the notion of calling, but adds a method selection step before executing the body.

One last practical note: deep recursion consumes call space, so per depth
large, a `while` with an explicit state is better (chap. 22.6). The base case is not a formality:
without it the recursive call doesn't stop and the program doesn't arrive at a result.

### 6.3 Higher-order functions

Functions are first-class values: they pass, they return, they compose. In Core
`map`, `filter` and `reduce` **do not exist**: they are written by hand (chap. 22.1). In Full they are builtins.
**[Core]**

```triad
function apply_all(f, xs)
    out = []
    i = 1
    while i <= length(xs)
        push!(out, f(xs[i]))
        i += 1
    end
    out
end
println(apply_all(x -> x * x, [1, 2, 3]))
```

**Output:**

```text
[1, 4, 9]
```

In Full, `reduce(+, xs)` and `map(sq, xs)` work because the **operators are also functions**.

The point of `apply_all` isn't function specific: it's that `f` is a parameter like the others, and
`x -> x * x` is a value constructed at call time. This is the difference between writing
ten almost equal cycles and write a cycle only once; in Core `map` and `filter` do not exist
because the bootstrap language needs to stay small, not because the idea is foreign to Triad. Le
functions of chapter 22.1 are the practical answer: write them once and use them again.

### 6.4 The `!io` effect annotation

A function that prints must declare `!io` in the signature. Core **accepts the annotation and the
ignore**: writing it makes the code ready for Full. **[Core]**

```triad
function show() !io
    println("hello from block")
    20 + 22
end
println(show())
```

**Output:**

```text
hello from block
42
```

The annotation is not decorative. In Triad-Full a function declares the capabilities it uses, and the
runtime checks that the caller allows them (chap. 15); in Core the control does not exist, but
writing `!io` now means not having to rewrite the signature when the program switches to Full.
The word `I` is a permission, not a descriptive label: it says what the function can produce
output, and the caller must be authorized to do so.

---

<a id="cap-7"></a>

## 7. Types and multiple dispatches

A generic function is a collection of methods. Redefine the same signature overrides the method
previous. Among the applicable methods (same arity, each argument subtype of the parameter) wins
the **most specific**. **[Full]**

```triad-full
area(n::Number) = :number
area(n::Int) = :int

println(area(1))
println(area(1.5))
```

**Output (golden Full):**

```text
int
number
```

The example should be read as a search: `area(1)` has an `Int`, which is a subtype of both `Int` and
`Number`; both methods are applicable, but `Int` is more specific and wins. `area(1.5)` has a
`Float`, which is a subtype of `Number` but not of `Int`, so there is only one applicable method left. If
had I only defined `area(n::Number)`, both calls would have used that: dispatch does not
chooses the "best" method, chooses the most specific among those that accept the arguments.
A method A is more specific than B if each of its parameters is a subtype of the corresponding parameter of B
and the signatures differ.

- If no method is applicable: `Err(:method)`.
- If multiple methods are maximal: `Err(:ambiguous)`.
- If the name is also a builtin (for example `+` on numbers), the builtin is used.

Dispatch can be modeled as a two-step search. First we eliminate the methods with
incorrect arity or with at least one argument that does not satisfy the declared type; then they compare
those remaining according to the subtype relationship, parameter by parameter. One method is more
specific only if it is no longer general in any position and is general in at least one. So it's not enough
choose the most recently added method. If two incomparable signatures remain, the call is
ambiguous and produces `Err(:ambiguous)` instead of depending on the order of the files or the order of
registration. This behavior allows you to add specialized methods without rewriting
the generic function, while keeping explicit the cases that do not have a univocal answer.

Operators are extended as functions, redefining them:

```triad-full
struct Point
    x::Float
    y::Float
end

function +(a::Point, b::Point)
    Point(a.x + b.x, a.y + b.y)
end

p = Point(1, 2) + Point(3, 4)
println(p.x, " ", p.y)
```

**Output (golden Full):**

```text
4.0 6.0
```

### 7.1 The return type

`::R` is checked on exit, with the `Int -> Float` conversion. If the value does not comply:
`Err(:type)`. **[Full]**

```triad-full
function half(n::Number)::Float
    n / 2
end
println(half(3))
```

**Output (golden Full):**

```text
1.5
```

The control occurs at the exit because only then does the value exist; the `Int -> Float` conversion
allows you to write `n / 2` without worrying about the literal type of the result. If the value is not
convertible, you get an `Err(:type)` and not an exception: a violated signature promise also enters
in the error stream as given.

### 7.2 Local functions
A `function` defined inside another function is a **local closure**, without dispatch. **[Full]**

```triad-full
function external(x)
    function internal(y)
        y * 2
    end
    internal(x) + 1
end
println(external(5))
```

---

<a id="cap-8"></a>

## 8. Lambdas, closures and scopes

### 8.1 Lambda **[Core]**

A lambda is an unnamed function: `x -> x * 2` is a value, not a definition. The shape
`(a, b) -> …` declares multiple parameters, and the body is an expression or a block. Lambdas yes
pass as arguments and return as results, and that's how an order function
above (chap. 6.3) describes an operation without carrying it out immediately.
```triad
double = x -> x * 2
sum = (a, b) -> a + b
apply = f -> f(3)
println(double(5), " ", sum(1, 2), " ", apply(x -> x * x))
```

**Output:**

```text
10 3 9
```

A lambda with a multi-statement body is written with `begin … end` or with `function (…) … end`. Le
parameterless lambdas (`() -> …`) are **not** supported: use `function () … end`.

### 8.2 Closures

A lambda captures the environment in which it is created. According to `SPEC-CORE §5` the captured variables are
**shared**: mutations are visible. **[Core]**

```triad
function add(n)
    x -> x + n
end
f = add(10)
g = add(100)
println(f(5), " ", g(5))

function counter()
    v = 0
    x -> begin
        v += x
        v
    end
end
acc = counter()
acc(5)
println(acc(10))
```

**Output:**

```text
15 105
15
```

> **Caution.** The Windows seed captures **by value** and covers only the last binding of the frame: a
> accumulator as `counter` may not work on seed. The JS interpreter and specification use the
> shared model.

A closure doesn't keep a snapshot of just the text of the lambda: it keeps access to the bindings
that his body can read. In the first example the function returned by `add(10)` maintains the
value `n = 10` even after the call to `add` has finished; `add(100)` creates a closure
distinct. In the counter, however, the variable `v` is a shared link: each call updates
the same state and the next one observes it. It's why a closure can represent
a small object with private status. It is also the reason why the specific behavior of the
seed Windows should be verified separately from the reference interpreter.

The difference between shared capture and value capture is not theoretical: with the shared model
two closures created from the same frame see the same state, with the pattern for value each has
his copy. When you design a stateful object, know which model you're using, because that's it
which decides whether two counters are independent or not.

### 8.3 The rules of scope

The rules follow a single principle: the scope is **lexical**, i.e. it matters where the code is written,
not where it is called from. From that principle derive the five rules that follow; read them in
order helps predict what actually changes an assignment.

1. `function`, lambda, `let`, `while`, `for` and comprehensions introduce **environments**; a name is
   visible in the environment in which it is linked and in the internal ones (lexical scope), never in those
   external.
2. **Within a named function** the assignment binds in the local frame: a function **not
   edit globals**.
3. **Inside a lambda** assigning to a name already bound outside updates that binding.
4. **At top level** loops can update globals.
5. `let x = …` creates a new `x`: assigning `x` inside the `let` does not affect the outer `x`.

```triad
x = 1
function f()
    x = 2
    x
end
println(f(), " ", x)
c = 0
function increment()
    c += 1
end
increment()
println(c)
```

**Output:**

```text
2 1
0
```

To get a result out of a function, return it — or use a list, which is mutable.

The example shows the most important case: `f` returns `2` and the global `x` remains `1`, because
assignment within a named function creates a local binding. `increment` increments a
local binding `c` that is born and dies in the call, and the global `c` remains `0`. It's not an oversight
language: it is what makes the behavior of a function independent of the global state.
When you need shared state, there are two ways — a mutable list passed as
topic (chap. 9) or a closure (chap. 8.2) — and in both cases the sharing is visible
in the signature or definition.

---

<a id="cap-9"></a>

## 9. Lists

A list is heterogeneous, nestable and **mutable**. The indices start from **1**. **[Core]**
A list is written in square brackets, `[1, 2, 3]`; the order of the elements is significant and i
values can be of different types. Mutability is the property that distinguishes the list from a
record: the list grows and changes, and multiple names can observe the same list. It's the structure
supports almost all Core code, from records to queues, from environments to parsers.

```triad
xs = [1, 2, 3]
println(xs[1], " ", length(xs))
push!(xs, 4)
xs[1] += 100
println(xs)
alias = xs
push!(aka, 5)
println(xs)
```

**Output:**

```text
1 3
[101, 2, 3, 4]
[101, 2, 3, 4, 5]
```

`push!` **mutates** the list and returns it. The lists are references: two names can indicate the
same list, as seen above.

The fact that `push!` returns the list, and not `nothing`, is a convenient choice: it allows you to
chain the addition with another operation, but it also makes it possible to write `xs = push!(xs, 4)`,
which is redundant but harmless. Assignment to an element (`xs[1] += 100`) also works with
compound operators: the left side is evaluated only once, so the index is not
calculated twice.

A list is a mutable object; a variable contains a reference to that object. If `ys =
xs`, the two names allow you to reach the same list: `push!(ys, value)` and `xs[i] = value`
are also observable by reading `xs`. If you instead write `ys = [1, 2]`, you have replaced only the
bond `ys`; `xs` continues to refer to the previous list. This distinction explains why
assigning a list does not automatically create a copy of it and because list arguments can
be used to share state between functions.

The 1-based convention is consistent with examples and specifies: to visit `n` elements, the counter
starts from 1 and the typical condition is `i <= length(xs)`. In one loop, update the counter
after reading the item avoid skipping the first item; increase it in each iteration
ensures that the condition will sooner or later become false. On the Windows seed the auxiliary function
experimental `get(xs, i)` is different and 0-based: it should not be used as if it were the standard semantics
of the lists.

The choice to start from 1 is not an aesthetic detail: it makes access consistent with the positions
human and range-based, and allows `length(xs)` to be used as the last valid index. The price is that a
index calculated with 0 in mind must be corrected; the typical error is `xs[0]`, which does not return a
value but produces an error. An out-of-range index is `nothing`: in Core the program
ends, in Full comes an `Err(:bounds)` to handle. For this reason, when the index is calculated, it is
good practice to check it first with `1 <= i && i <= length(xs)`.

The sum of the elements with an explicit loop:

```triad
xs = [101, 2, 3, 4, 5]
total = 0
i = 1
while i <= length(xs)
    tot += xs[i]
    i += 1
end
println(tot)
```

**Output:**

```text
115
```

The loop shows the canonical form of traversal in Core: counter from 1, condition
`i <= length(xs)`, reading `xs[i]`. `length` is recalculated every iteration, so if the
loop body changes list border moves; mutating the list as you traverse it is
possible, but it must be done with awareness. Adding elements lengthens the list and loops through them
will visit; in Full, where `pop!` and `append!` exist, removing items as the index grows does
skip the next ones.
In Full there are also `reverse`, `sort`, `sum`, `first`, `last`, `rest`, `pop!`, `append!`, `vcat`,
`collect` and the `x in xs` operator. None of these names exist in Core: if you need them, write them to
hand with `while` and `push!`, as in chapter 22.1. It's not a loss: handwritten algorithms
they show what they do and how much they cost, and in a bootstrap this transparency is worth more than
brevity.

---

<a id="cap-10"></a>

## 10. Strings, symbols and conversions

The strings in Triad are immutable values and the operations are few, deliberately explicit: yes
concatenate with `*`, measure the length in bytes, convert with clearly named functions. The
table collects the operations available in Core; where Full behaves differently you can find it
indicated below, with why.

| operation | meaning |
|---|---|
| `a * b` | string concatenation |
| `length(s)` | number of **bytes** UTF-8 (`length("é") == 2`) |
| `string(x)` | textual representation of any value (`string(:a) == "a"`, `string([1, 2]) == "[1, 2]"`) |
| `Int(s)` | string to integer (`Int("42") == 42`) |
| `Symbol(s)` | from string to symbol (`Symbol("hello") == :hello`) |
| `typeof(x)` | in Core, the type name as symbol (chap. 2.1) |

```triad
name = "Triad"
greeting = "hello " * name
println(greeting, " (", length(greeting), " byte)")
println("response: " * string(40 + 2))
println(Int("41") + 1, " ", Symbol("bob"), " ", string(true))
```

**Output:**

```text
hello Triad (10 bytes)
answer: 42
42 bob true
```

The first thing to note is that `length(greeting)` is equal to `10`: "hello Triad" has ten characters and ten
byte, because the Latin alphabet takes up one byte per character. With `"é"` the account changes
(`length("é") == 2`), and with an emoji it changes again: the length is a property of the encoding
UTF-8, not text as you see it. It's the reason why in Triad you don't index a string like
a list: `s[1]` would return a byte, not a character, and would be a silent trap. For
working on individual bytes requires bootstrap primitives (chap. 21).

Concatenation with `*` does not change `salute`: it creates a new string, and the old one remains
available to anyone who is using it. This immutability makes strings safe to pass to
functions, but it also means that each `*` allocates a new string: in a loop along the cost
grows with the string, not with the number of turns.

`string(x)` and `Symbol(s)` must be kept distinct: `string` transforms a value into text, `Symbol`
transforms text into an identity. `string(42)` produces the string `"42"`; `Symbol("42")` produces a
symbol, which is a completely different value. `Int("42")` does the reverse: it is one
conversion, not an evaluation, so the text must be an integer written in decimal. What
what happens with a non-numeric text is not fixed by the standard: the reference interpreter
returns `0`, but this is something you should check before counting on it.

In Full the strings additionally have interpolation (chap. 1.3) and `repr`, which produces a
representation designed to be reread; in Core `string` is the only port from value to text,
and there is no interpolation.

---

<a id="cap-11"></a>

## 11. Errors as data

This is one of the main ideas of Triad: **error is a value**, not an exception
 interrupts the program.

### 11.1 The `Err` form

An error is an `Err` value with three fields:

- `kind::Symbol` — the category, on which dispatch can be done;
- `msg::String` — the message;
- `data` — any value, often an `Info(...)` record with details.

**[Full]**

The three fields separate three different questions: *what* happened (`kind`), *how to tell it* (`msg`) and
*what information is needed to react* (`data`). Keeping them separate is what allows you to write
code that decides based on the category without analyzing the message text, which it is meant for
a person and not for a program.

```triad-full
e = err(:my, "oops", 42)
println(e.kind, " ", e.msg)
println(iserr(e))
```

### 11.2 Produce and propagate

The table summarizes the constructs that create, propagate, or observe an error: read it from above in
low is also the order in which an error passes through a program, from the point at which it arises to the point at
where someone decides what to do with it.

| construct | effect |
|---|---|
| `err(:kind, "msg"[, data])` | constructs an `Err` **without** raising it |
| `throw(e)`, `error("msg")` | raise (`error` produces `Err(:error, …)`) |
| `try b catch and h end` | if `b` raises, `e` is related to `Err` and `h` | is evaluated
| `try b end` | **the error becomes the value** of the expression |
| `iserr(x)` | checks if `x` is an `Err` |

All the failures of the language — integer division by zero, `sqrt(-1.0)`, out-of-range indices,
no applicable methods — come as `Err` and **never** as fatal failures. **[Full]**

```triad-full
e = try div(1, 0) end
println(e.kind)
println(iserr(e))

r = try div(10, 2) catch err; 0 end
println(r)
```

**Output (golden Full):**

```text
domain
true
5
```

It is useful to distinguish three moments: **produce**, **propagate** and **manage** an error. `err(...)`
builds a piece of data and doesn't interrupt anything; a failing operation produces an `Err` according to the
specific; `try` establishes the point at which that value is observed or retrieved. In Full,
`try expression end` returns the error as a value, while `try ... catch name ... end`
allows the recovery branch to examine the category, message or details. If the error
is not handled, goes to the top level and becomes a failed exit code: "error
as given" does not mean that the program continues automatically after any operation.

The data type allows you to write different policies for different categories. For example, a
`:bounds` error can be presented as invalid input, while `:method` can indicate that
an implementation is missing. Separating the stable category (`kind`) from the readable text (`msg`) avoids
having to analyze diagnostic strings to decide how to react.

### 11.3 Error categories

The category is the stable part of the error: it is a symbol, the program can compare it and make
dispatch on it. The table lists the categories that the standard defines; the messages you see
printed instead of the implementation and may change.

| kind | when |
|---|---|
| `:syntax` | parse error; `data` contains `line`, `col` and `incomplete` |
| `:undef` | undefined name, function, macro or predicate |
| `:type` | wrong type (fields, return, `::`, conditions not `Bool`) |
| `:method` | no applicable method; `data.types` contains the types of the arguments |
| `:ambiguous` | multiple equally specific methods |
| `:field`, `:bounds`, `:domain` | non-existent field, index out of range, mathematical error |
| `:instantiation` | unbound logical variable where a | value is needed
| `:contract` | `requires`/`ensures` violated (chap. 12) |
| `:budget` | steps exhausted (ch. 13) |
| `:effect` | undeclared effect (chap. 15) |
| `:host` | any other interpreter errors |

An error not handled at the top level interrupts the program: the message reports the line
of the statement (`line 12: …`) and the exit code is `1`.

### 11.4 In Core: Errors like tagged lists

Core has no `try`/`catch` nor the `Err` type: an error **terminates the process** with exit code `1` and a
diagnostic message on stderr. But the "error as given" pattern can already be written, and is
exactly so that S1 will implement Full. The convention is `[:Err, kind, msg]`. **[Core]**

```triad
err(kind, msg) = [:Err, kind, msg]
is_err(v) = typeof(v) == :List && length(v) == 3 && v[1] == :Err

function div_integer(a, b)
    if b == 0
        return err(:domain, "division by zero")
    end
    q = 0
    while a >= b
        a -= b
        q += 1
    end
    q
end

r = integer_div(7, 0)
if is_err(r)
    println("error ", r[2], ": ", r[3])
end
println(integer_div(17, 5))
```

**Output:**

```text
domain error: division by zero
3
```

Note that `&&` shorts: `v[1]` is only evaluated if `v` is a list of 3 elements.

The reason for a tagged list is simple: in Core there is no `Err` type, but there are lists and
symbols, and a list with the tag in the first position can represent any record. `is_err` is
so a convention, not a type guarantee: anyone can construct a list `[:Err, ...]` with
wrong fields, and whoever receives it must check what he needs. It's the same deal that he
interpreters in `selfhost/` use for structs (ch. 2.3). The important part is not the container,
is the idea: a failure is a value that travels like the others, and whoever receives it can choose whether
manage it, transform it or return it.

---

<a id="cap-12"></a>

## 12. Contracts

A contract is a precondition (`requires`) or a postcondition (`ensures`) declared in the body
of a function. **[Full]**

A contract is not a comment: it is an executed condition, and a violation of it is a mistake as
given. It serves to make explicit what a function expects from those who call it and what it promises
to those who receive it, without entrusting the pact to the good will of those who read it. It does not demonstrate that the
property holds for every possible input — it controls it for the executions that occur — but
turns a silent violation into an `Err` reporting which clause failed.

```triad-full
function safe_div(a::Number, b::Number)::Float
    requires b != 0
    ensures abs(result * b - a) < 1e-9
    a/b
end
```

- `requires c` is checked **where it appears**: by convention at the beginning of the body.
- `ensures c` is recorded and checked at function exit, with `result` bound to
  return value, **after** checking the return type.
- A violation produces
  `Err(:contract, "requires violated in safe_div: b != 0", Info(fn, clause, cond[, result]))`.
  `cond` contains the **code** of the condition: it is data, it can be inspected.
- The conditions are **pure**: an effect inside a contract gives `Err(:effect)`.
- At the top level `requires c` works like an assertion.
- `ensures` only makes sense inside a `function`: use `result`, which exists only when the function
  is going to return a value. Outside a function there is no result to refer to.

```triad-full
println(safe_div(6, 3))

e = try safe_div(1, 0) end
println(e.kind)
println(e.data.clause)
println(e.data.fn)
```

**Output (golden Full):**

```text
2.0
contract
requires
safe_div
```

In the example `safe_div(6, 3)` produces `2.0`: the `Float` return type converts the result and
exposes it as a promise kept. `safe_div(1, 0)` never gets to divide: the precondition comes
checked at the beginning, the error is already a value and the program continues. The error message
carries with it `clause = requires` and `fn = safe_div`, so the caller can distinguish a violation
of entry from a promise of exit not kept without reading the text.

The checking sequence is significant: the body evaluates the clauses in the order in which
appear; preconditions are checked at the point where they are declared, while the
postconditions are preserved until the function completes. The final value comes
first subjected to the return constraint and then exposed as a `result` to the `ensures` clauses.
A contract error includes which clause failed and the code that represents it, so who
calls can distinguish an entry violation from a broken exit promise. I
contracts control an observable invariant, but do not mathematically prove that it holds for every
possible input: they are evaluated for the executions that occur.

---

<a id="cap-13"></a>

## 13. Budget

A **budget** limits how many steps the program can consume. A step is a call, an iteration
of loop or a resolution step. When the budget runs out, **the value of the `with` is
`Err(:budget)`**: The program does not crash or terminate. **[Full]**

```triad-full
r = with budget(steps = 10_000)
    while true end
end
println(r.kind)
```

**Output (golden Full):**

```text
budget
```

Budgets nest and the tightest applies. A `with` converts **only** the exhaustion of to a value
own budget, while that of an external budget continues to propagate. `solve … steps N` is the
query-specific budget.

Budget measures **work**, not time: two runs of the same program with the same
budgets consume the same steps, so the result is reproducible. A timeout based
on the watch it would not be and would make the tests unstable. This is why the limit is part of the
language and not the environment: a program can decide what to do when it runs out, e.g
that decision is also code.

The logic engine uses an explicit stack: infinite recursion, even left, ends in
`Err(:budget)` is **not** in a stack overflow.

The limit is part of the calculation result because the program can choose how to treat it:
show a diagnosis, reduce the problem or return a partial result only if your
logic allows it. Don't confuse `limit n`, which limits the number of solutions returned,
`depth d`, which cuts branches beyond a depth, and `steps s`, which limits the overall work.
A query that has explored the intended space without finding solutions returns an empty list;
a query stopped by exhaustion of steps instead reports `Err(:budget)`.

---

<a id="cap-14"></a>

## 14. Tracks

The trace of a calculation is a **value**, not printed output. **[Full]**

```triad-full
fib(n::Int) = n < 2 ? n : fib(n - 1) + fib(n - 2)

t = with trace
    fib(3)
end
println(t.result)
println(length(t.trace))
```

**Output (golden Full):**

```text
2
10
```

`fib(3)` makes 5 calls (`fib(3)`, `fib(2)`, `fib(1)`, `fib(0)`, `fib(1)`): trace records
**two events for each call**, `:call` and `:exit`, so 10 events. For `fib(5)` that's 15 calls
and 30 events — is the value expected from the `garanzie_core` conformance case.

`with trace … end` returns `Traced(result, trace)` with the `:call` and `:exit` events of each
generic function called in the body. `solve … trace` returns `Traced(result, trace)` where
`result` is the list of solutions and events are the gates of the Byrd box model
(`call`, `exit`, `redo`, `fail`) plus `depth`, when a branch is cut by `depth`.

Events are records: they are filtered and counted like any other value.

Collecting a trace is not free: each event is an allocated value, and on large calculations the
trace can weigh more than the result. Ask it when you need it, not by default.

A trace adds a time dimension to debug data: two runs can have it
same result but follow different paths, for example if a query had to try and
discard alternatives. Instead of writing logs inside each function, the caller encloses the
calculation in `with trace` or ask `trace` to `solve`; the result and events come
returned together. This keeps the application result and diagnostics separate, and allows
to analyze the trace with the same tools used for lists and records.

### Glossary of trace events (Byrd gates)

When using `solve … trace`, each search step produces an event that logs **at what
reference** (which goal, which clause, which logical variables) is being worked on. Four o'clock
Byrd box model doors are:

| door | when it occurs | meaning |
|---|---|---|
| `:call` | you enter a goal | start of candidate clause evaluation |
| `:exit` | unification **successful** | the goal is demonstrated: it is the "success" of the research |
| `:redo` | backtracking | we go back to look for another solution |
| `:fail` | no applicable clause | the goal **fails**: no solution for that branch |

Important Notes:

- **"success" and "fail" are not generic outcomes**: they are the `:exit` and `:fail` ports of the trace,
  refer to the current goal/clause. The failure of a goal is not an exception: it occurs
  as **empty solution list** in the `result` of `Traced(result, trace)`.
- **`depth`** appears as an additional event when a branch is cut from the depth limit
  (`solve … depth N`), signaling that the search was aborted before an `:exit`/`:fail`.
- Events are **ordinary records**: they are filtered (`[e for e in t.trace if e.port == :fail]`),
  they are counted (`length`), they are inspected (`e.args`, `e.depth`) like any other Triad value.
- The reference of each event is the **current goal and the logical variables** (`?x`, `?y`, …)
  involved in that passage: by reading the trace one reconstructs *which* alternative it was
  tried and *why* it failed.

```triad-full
# Count search failures
t = solve path(:a, :c) trace
fails = [e for e in t.trace if e.port == :fail]
println(length(fails))
```
```triad-full
fib(n::Int) = n < 2 ? n : fib(n - 1) + fib(n - 2)
t = with trace
    fib(3)
end
println([e.args for e in t.trace if e.port == :call])
```

**Output (golden Full):**

```text
[[3], [2], [1], [0], [1]]
```

---

<a id="cap-15"></a>

## 15. Declared effects

The functions are **pure by default**. The effects are declared in the signature, after i
parameters. **[Full]**

“Pure by default” is a security choice: if you forget a statement, the
function cannot do more than expected, and the error comes when the effect is attempted. In this
sense an effect is a **capability**, not a descriptive annotation: `!io` says that the function has the
permission to print, and the dynamic check checks permission at run time.

```triad-full
function hello(name::String) !io
    println("hello, ", name)
end

function learn(x) !state
    fact seen($x)
end
```

| effect | operations |
|---|---|
| `I` | `println`, `print` |
| `state` | `fact`/`rule` executed inside a function (modifies the knowledge base) |

The control is **dynamic**. A function executes only with the effects it declares, and only
if the caller allows them. If a pure function calls `println`, or calls an `!io` function, yes
get `Err(:effect)`; `data` contains `fn`, `caller` and `missing`.

Purity by default means that a function can calculate and return values
without changing the external state or producing I/O; it doesn't mean the runtime parses
statically every possible path before execution. Dynamic control observes the effects while
occur and compares them with the active context. Local mutations and list mutations are not
classified as effects declared in this specification: `!state` refers to the modification
of the knowledge base via `fact` and `rule`, not to any assignment.

- The top level allows all effects.
- Lambdas inherit the effects of the context in which they are executed.
- Macros and contracts are pure.
- Reading the knowledge base (`solve`, calling a predicate) is pure.
- Local data mutation (`push!` on a list, assignment to local variables) is **not** a
  effect: only changes values reachable from the local environment.

```triad-full
noisy function()
    println("I make noise")
end

function quiet()
    noisy()
end

e = try quiet() end
println(e.kind)
```

**Output (golden Full):**

```text
effect
```

`noisy` does not declare `!io`, so its `println` is a disallowed effect; `quiet` there
calls from a pure context and gets the same error. `data` contains `fn` (who tried
the effect), `caller` (from where) and `missing` (which effect was missing): these are the three pieces of information
They are used to correct the signature. The control is dynamic, so a branch that doesn't execute doesn't
produces effect errors, and there is no static analysis that warns you first: the statement is a
as long as the runtime checks as the code runs.

---

<a id="cap-16"></a>

## 16. Logic

Triad integrates logic programming **into block syntax**: the facts and the rules are
top-level constructs, not an embedded language. **[Full]**

Facts and rules form the **knowledge base**, which the program builds as it runs. A fact
asserts that a relationship is valid; a rule says that it is valid provided that other things are valid.
`solve` asks a question at the base and returns the answers as values: there is no interpreter
separate to invoke, because the logic is within the same syntax and the same engine as the rest
of language.

### 16.1 Facts, Rules, Terms

```triad-full
fact parent(:tom, :bob)
fact parent(:bob, :jim)

rule ancestor(?a, ?d) :- parent(?a, ?d)
rule ancestor(?a, ?d) :- parent(?a, ?x), ancestor(?x, ?d)
```

Within a term:
- `:atom` is a symbol; `?x` is a logical variable; numbers, strings and lists are themselves;
- `f(t1, t2)` is a composite term. `?x + 1` is also a term (`+(?x, 1)`) and **is not
  rated**;
- a **bare name** is a value from the current environment, read at the time `fact` is executed,
  `rule` or `solve`: `chi = :bob; solve parent(chi, ?c)`;
- `$(expr)` explicitly inserts a calculated value: `fact age(:bob, $(2026 - 1975))`;
- `[a, b]` and `[?h | ?t]` are lists and forms that unify with lists;
- the name of a struct with arguments, such as `Point(?x, ?y)`, unifies with instances of that struct.

Variables in a clause are **renamed with each use** (standardization aside).
Unification does the **occurs-check**: `solve ?x = f(?x)` has no solutions.

To read a query you need to distinguish **terms** from normal calculated values. A symbol
as `:alice` is a constant term; `?who` is a logical variable that searches for a value; a shape
like `parent(:alice, ?who)` describes a goal to be proved. Logical variables are not variables
local Triads assigned with `=`: the engine searches for associations that make the goal compatible with
facts and rules. In particular, `?x + 1` within a term does not compute itself; the `is` operator
explicitly expresses the request to evaluate an expression using already bound variables.

Unification progressively builds a set of associations. If they compare
`parent(:alice, ?who)` and `parent(:alice, :bob)`, the corresponding arguments are the same and the
engine can bind `?who` to `:bob`; if an argument is different, that attempt fails. When more
clauses can satisfy a goal, backtracking back to the choice point and testing the clause
next. Each solution is a snapshot of the variables required by the query; a list
empty means "no proof found", not an execution error. The `limit` limits,
`depth` and `steps` control how many solutions or search steps are allowed.

### 16.2 The goals

A goal is the description of what you want to be true: the engine looks for bonds for the variables that
they make it demonstrable. The table collects the forms that a goal can take; the first two are
the most important ones, because `p(t…)` is the only way to query the knowledge base and the conjunction
it's the only way to ask for more things at once.

| goals | meaning |
|---|---|
| `p(t…)` | knowledge base predicate, solved with SLD and backtracking, clauses in order |
| `g1 && g2`, `(g1, g2)` | conjunction; in `rules` also with `,` |
| `g1 \|\| g2` | disjunction |
| `!g`, `not(g)` | denial for failure |
| `not(b)` *out* of a goal | is a function: negate a `Bool` (`not(true) == false`) |
| `a = b` | unification |
| `?y is expr` | evaluates `expr` (variables must be bound) and unifies with `?y` |
| `a < b`, `==`, `!=`, `<=`, `>`, `>=` | comparison between values, evaluated |
| `f(t…)` with `f` function Triad | calls the function with the evaluated arguments; must return `Bool` |
| `true`, `false` | success, failure |

A predicate without clauses with that arity, which is not even a function, gives
`Err(:undef, "unknown predicate: p/2")`. An unbound variable within an expression gives
`Err(:instantiation)`.

### 16.3 `solve` is a value

`solve` **returns a list** of `Solution`. It doesn't print anything: it's a value like any other.

```triad-full
fact parent(:alice, :bob)
fact parent(:alice, :carol)
fact parent(:bob, :dave)

rule grandparent(?x, ?z) :- parent(?x, ?y), parent(?y, ?z)

sols = solve grandparent(:alice, ?who) limit 5
println(sols)
println(sols[1].who)
println(length(sols))
```

**Output (golden Full):**

```text
[{who = :dave}]
dave
1
```

Each solution binds the **non-anonymous** query variables, in the order they appear. Le
variables left free remain `?x#n`. `vars(sol)` returns bound names.
`Solution` is a record with the query names: `sols[1].who` reads the binding, and `vars(sol)` lists the
names. The result of `solve` is a normal list, so you can filter, sort or count the
solutions with the tools of the rest of the language: the logic does not produce a special format,
produces values.

`solve` options:
- `limit n` — at most `n` solutions;
- `depth d` — branches deeper than `d` are cut (fail);
- `steps s` — at most `s` resolution steps, otherwise `Err(:budget)`; the default value
  is `1 000 000`;
- `trace` — see chap. 14.

The options are not equivalent: `limit` stop the search when you have enough solutions, `depth`
cuts branches that are too deep and considers them failed, `steps` limits the overall work and reports
exhaustion with `Err(:budget)`. Distinguishing them matters because only the last one is a mistake: the other two
produce a partial but legitimate result.

### 16.4 A predicate used as a function

Calling a predicate where a value is expected returns a `Bool`: tells if the goal is
demonstrable.

```triad-full
if grandparent(:alice, :dave)
    println("alice is dave's grandmother")
end
```

### 16.5 Examples

Route with cost:

```triad-full
fact edge(:a, :b, 2)
fact edge(:b, :c, 3)
rule path(?x, ?y, ?c) :- edge(?x, ?y, ?c)
rule path(?x, ?y, ?c) :- edge(?x, ?z, ?c1), path(?z, ?y, ?c2), ?c is ?c1 + ?c2
println((solve path(:a, :c, ?cost))[1].cost)
```

**Output (golden Full):**

```text
5
```

The cost accumulates by composition: `path(:a, :c, ?cost)` proves the goal by combining the fact
`edge(:a, :b, 2)` to the recursive rule; the second step finds `edge(:b, :c, 3)` and `?c is ?c1 + ?c2`
calculate `2 + 3`. `is` is necessary because `?c1 + ?c2` inside a term would remain a non-term
evaluated; `is` is the point where the logic asks the evaluator to do arithmetic.

Prolog style append:

```triad-full
rule app([], ?l, ?l)
rule app([?h | ?t], ?l, [?h | ?r]) :- app(?t, ?l, ?r)
println((solve app([1, 2], [3], ?r))[1].r)
println(length(solve app(?a, ?b, [1, 2, 3])))
```

**Output (golden Full):**

```text
[1, 2, 3]
4
```

`app([1, 2], [3], ?r)` unifies the linked list and returns `[1, 2, 3]`. The second query does not
fixes the result but asks for all pairs of lists which, concatenated, give `[1, 2, 3]`: they are
four, because the first piece can be the empty list, `[1]`, `[1, 2]` or `[1, 2, 3]`. The number
it's not an error: it's the engine that enumerates the alternatives, and `limit` is there to stop it when
you are not interested in all of them.

Denial for failure:

```triad-full
fact parent(:tom, :bob)
people = [:tom, :bob]
leaves = filter(p -> !parent(p, ?_), people)
println(leaves)
```

**Output (golden Full):**

```text
[:bob]
```

`!parent(p, ?_)` is negation by failure: `p` passes the filter only if the goal `parent(p, ?_)`
it is not demonstrable. `:tom` has a child, so it doesn't pass; `:bob` has none, so it passes. The
anonymous variable `?_` is the one that does not appear in the result: each occurrence is a variable
new, so you don't have to invent a name for a variable you don't care about.

---

<a id="cap-17"></a>

## 17. Code as given

The parser produces **only one node type**, `Node(head, args)`. It is the same tree as the kernel
executes, which `:( … )` returns as a value and which `triad --tree` prints as an S-expression.
**[Full]**

The idea behind it is radical: the program is not a sequence of commands but the evaluator
interpret by hand, it is a **given**. The parser produces the tree, the evaluator executes the tree, the
macros receive tree pieces and return others. Since there is only one type of node, chi
writes code that manipulates the program does not have to know ten different representations: it knows
`Node(head, args)` and that's it.

The table shows how shapes you've already encountered become knots: read it like a dictionary
between the syntax you write and the data the program can inspect.

| syntax | node |
|---|---|
| `f(a, b)`, `a + b` | `(call f a b)`, `(call + a b)` |
| `a && b`, `a \|\| b` | `(and a b)`, `(or a b)` |
| `x = e` | `(assign x e)` |
| `:alice` | `(sym alice)` |
| `a.x`, `xs[i]` | `(dot a x)`, `(index xs i)` |
| `[a, b]`, `[h \| t]` | `(list a b)`, `(cons (list h) t)` |
| `[e for x in xs if c]` | `(comprehension e x xs c)` |
| `x -> is | `(lambda (tuple x) e)` |
| `x::T` | `(typed x T)` |
| `"to $x"` | `(string "a " x)` |
| `if c a else b end`, `c ? a : b` | `(if c (block a) (block b))` |
| `while`, `for`, `let`, `begin` | `(while c body)`, `(for x iter body)`, `(let (tuple …) body)`, `(block …)` |
| `function f(a::T)::R !io … end` | `(function f (tuple (typed a T)) R (tuple io) body)` |
| `struct P; x::Float; end` | `(struct P (tuple (typed x Float)))` |
| `macro m(a) … end`, `@m(e)` | `(macro m (tuple a) body)`, `(macrocall m e)` |
| `:(e)`, `quote … end`, `$e` | `(almost e)`, `(almost (block …))`, `(unquote e)` |
| `fact t`, `rule h :- g1, g2` | `(fact t)`, `(rule h g1 g2)` |
| `solve g limit 5 trace` | `(solve g (tuple (assign limit 5) (assign trace true)))` |
| `try b catch and h end` | `(try b and h)` |
| `with budget(steps = N), trace … end` | `(with (tuple (call budget (assign steps N)) trace) body)` |

### 17.1 Odds, unquotes, eval

```triad-full
c = :(a.x + f(b, 2))
println(c.head)
println(sexpr(c))

n = 7
square = :($n * $n)
println(eval(square))
```

**Output (golden Full):**

```text
call
(call + (dot a x) (call f b 2))
49
```

Inside a quote, `$x` and `$(e)` insert the **value** of an expression: if it is code it is
nested, if it is a number or a list it becomes a constant, if it is a Symbol it becomes an identifier.
`eval(c)` executes code **in global scope**. The other builtins in the "code" group are `parse`,
`unparse`, `sexpr`, `Expr` and `gensym`.

Quoting and evaluating are opposite but not interchangeable operations. The parser normally transforms
the source in a tree and the evaluator executes that tree; `:(...)` stops the process al
boundary between the two phases and returns the tree as an `Expr` value. `eval(expr)` delivers it by
new to the evaluator, in global scope. The unquote `$x` inside a quote inserts the value
calculated of `x` in the new tree: if it is an `Expr`, insert code; if it is a number, create a node
constant. `sexpr` is for inspecting the structure and does not run the program.

The example shows the complete journey: `:(a.x + f(b, 2))` returns an `Expr` without executing it,
`c.head` is `call` and `sexpr` writes it in linear form. `:($n * $n)` with `n = 7` does not create a
function: create a tree that already contains the constant `7`, and `eval` executes it. The difference between
`eval` and a normal call is the scope: `eval` starts from the global scope, so it doesn't see the
local variables of the person invoking it. This is why `eval` is used to build complete code,
not to read context values.

---

<a id="cap-18"></a>

## 18. Macros

A macro takes arguments **as code**, not evaluated, and returns code, which is then
executed in place of the `@name(...)` call in the caller's scope. **[Full]**

The difference compared to a function is not only technical: a function receives already calculated values,
therefore he cannot decide whether to evaluate a topic once, twice or never. A macro receives the
source form, and this is its only real reason for being: it is used when behavior
depends on the code, not on the value of the arguments.

```triad-full
macro unless(c, body)
    :(if !$c; $body; end)
end

macro swap(a, b)
    t = gensym(:tmp)
    odds
        $t = $a
        $a = $b
        $b = $t
    end
end

x = 1
y = 2
@swap(x, y)
println(x, " ", y)
```

**Output (golden Full):**

```text
2 1
```

The expansion is **pure** (§15) and **unhygienic**: `gensym()` is used for temporary names.

This distinction is important for the effects. A function normally receives values already
calculated; a macro receives the source shape and can then decide whether to insert it once, multiple times
times or not insert it. Triad macros are unhygienic: a temporary name introduced by
macro can collide with a caller name. `gensym` creates a cool symbol for temps,
but it does not automatically make every free reference safe. For this reason it is advisable to limit the
macro to small transformations and inspect the expanded tree before attributing to the result
unexpected behavior.

### 18.1 Code generating code

```triad-full
function poly(coeffs)
    acc = :(0)
    i = 0
    for c in coeffs
        acc = :($acc + $c * x ^ $i)
        i += 1
    end
    acc
end

p = poly([1, 2, 3])
x = 2
println(eval(p))
```

**Output (golden Full):**

```text
17
```

`poly` builds a tree on each spin: `:(0)` is the starting point, and each coefficient grafts
the previous tree with `$acc`, the constant `$c` and the exponent `$i`. The `for` here works on values
normal; only quote and unquote build code. With `[1, 2, 3]` the final tree represents
`1 + 2 * x + 3 * x^2`, and with `x = 2` the value is `1 + 4 + 12 = 17`. `eval(p)` searches for `x` in scope
global: if `x` had been local to a function, the tree would not have seen it.

---

<a id="cap-19"></a>

## 19. Builtin

A **builtin** is a function that the language provides without you defining it. Some are
real primitives (arithmetic), others are conveniences built on top of the nucleus (functions
of higher order in Full). The table lists Triad-Full's builtins, grouped by scope;
below you will find the part that also exists in Core.

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

Two details that the table hides. First, **operators are functions**: in Full `+` is a name
like the others, so `reduce(+, xs)` works and you can add methods to an operator (ch. 7).
Second, builtins and user functions are not separate worlds: in Full you can add methods to a
name that is also a builtin, like `+` on `Point`, and the builtin remains the choice for values that do not
they have a more specific method.

**Core's subset** is smaller: `+ - * % ^`, comparisons, `&& || !`, `length`, `push!`,
`[a, b]` construction and `xs[i]` indexing, `*` on strings, `Int`, `string`, `Symbol`,
`print`, `println`, `typeof` (`SPEC-CORE §7`). The reduction is by design: a bootstrap interpreter
it must be able to run itself, and any extra builtin is code that bootstrap must provide. For
this in Core `map`, `filter`, `reduce`, `sum`, `sort`, `div` and `mod` **do not exist**: they are written
by hand (chap. 22.1).

---

<a id="cap-20"></a>

## 20. Command line and REPL

A Triad program doesn't just live inside a file: the standard also defines how it is invoked
the interpreter. The `triad` interface is normative (`SPEC §14`), that is, it is part of the language
how much the syntax; if two implementations read the arguments differently, the programs do not
they are portable.

```
triad # REPL
triad FILE [ARG...] # execute FILE; ARGS == [ARG...]
triad -l FILE # loads FILE and opens the REPL
triad -i FILE # execute FILE and then open the REPL
triad -e CODE # execute CODE
triad -E CODE # execute CODE and print the value
triad --tree FILE # print uniform tree as S-expression
triad -q # REPL without banner
triad -h, --help
triad -v, --version
triad - # read script from stdin
```

The options cover three different needs. `-e` and `-E` are used to test a fragment from the terminal,
with the difference that the second also prints the value; `-l` and `-i` combine a file and session
interactive, depending on whether the file is loaded or executed; `--tree` shows the uniform tree
from Chapter 17, useful when you want to see how the parser has grouped the code. The final dash
reads script from stdin, so Triad can fit in a pipeline.

- The `.triad`/`.td` extension can be omitted; the shebang `#!` is ignored.
- The program sees the arguments in `ARGS`, list of strings, without the program name.
- Exit codes: `0` success, `1` unhandled error (to stderr), `2` invalid use.

This interface is normative, but not all implementations cover it: Windows seed today
executes a file and that's it, without REPL or options (chap. 29). To run the examples in this manual
just the form `triad FILE`, or the `node seed/dev/triad_core.cjs` shown at the beginning.

### 20.1 The REPL

The REPL is an interactive session: you write an expression, see the value, and the definitions remain
active between one command and another. It is useful for exploration, for proving a logical goal or for understanding
because an expression gives a certain result, without creating a file every time.

The REPL is Prolog style:

```
triad > 1 + 2
3
triad> ?- ancestor(:tom, ?d)
?d = :bob ;
?d = :liz.
triad> parent(:jim, ?x)
false.
```
The answers show the two modes of the REPL: `1 + 2` is a normal Triad expression and prints the value;
`?- ancestor(...)` is a query and prints the solutions one by one, with `;` to ask for the next one
and `.` to stop. `false.` is not an error: it means there is no other solution.

- Blocks remain open until closed by `end`.
- `?- goal` (the trailing `.` is optional) executes a query with the `solve` options: `limit`,
  `depth`, `steps`, `trace`.
- A statement that is a goal on a knowledge base predicate is treated as a query.
- After each solution: `;`, `n` or space for the next one, `a` for all the remaining ones, enter or `.`
  to stop. `false.` means no other solution.
- Commands: `:load FILE…` (`:l`), `:reload` (`:r`), `:listing [name]` (`:ls`), `:tree CODE`,
  `:reset`, `:help` (`:h`), `:quit` (`:q`, `halt`, Ctrl-D).
- Ctrl-C stops the calculation in progress; an unhandled error is printed and the REPL continues.

---

<a id="cap-21"></a>

## 21. Bootstrap primitives

Five primitives are used by S1 to read and analyze the Triad source. **They are not part of
Triad-Full** (`SPEC-CORE §8`): Use them only in bootstrap code.

They are primitives and not functions because they are **under** the language: they are used by a written interpreter
in Triad to read your source as a sequence of bytes. This is why they are not part of
Triad-Full: An application program should not depend on them, and the code that uses them is not
portable outside the bootstrap. Their presence in the Core profile explains why a string is one
sequence of bytes and not a sequence of characters (chap. 10).

| primitive | semantics |
|---|---|
| `readfile(path)` | file contents as `String`; error if not readable |
| `strlen(s)` | number of bytes |
| `strbyte(s, i)` | bytes (`Int` 0–255) at position `i`, from 1 |
| `strsub(s, a, b)` | substring from bytes `a` to `b` inclusive, 1 |
| `exit(n)` | terminate the process with code `n` |
The five primitives are deliberately minimal: none knows the characters, none knows the
syntax. `strbyte` returns an `Int` between 0 and 255 and `strsub` works on byte ranges
inclusive, therefore a program that analyzes the source must make the comparison with the codes itself
characters that interest him.

```triad
s = "abc 123 xyz"
digits = 0
i = 1
while i <= strlen(s)
    b = strbyte(s, i)
    if b >= 48 && b <= 57
        digits += 1
    end
    i += 1
end
println(digits)
end = 1
while end <= strlen(s) && strbyte(s, end) != 32
    end += 1
end
println(strsub(s, 1, end - 1))
```

**Output:**

```text
3
abc
```

The first loop counts the digits by comparing the byte to `48` and `57`, which are the ASCII codes of `0` and
`9`: This is how a lexical analyzer distinguishes a number from a name without having functions
on strings (chap. 23, exercise 6). The second loop searches for the first space and then stops
`strsub(s, 1, end - 1)` extracts the bytes from position 1 to the last before the space: `abc`. Note
the order of the condition in the `while`: first it checks to be inside the string, then it reads
the byte; reversing them would produce an out-of-range access.

A program can read itself with `readfile(ARGS[1])`: it is the first step of an interpreter
self-hosted.

---

<a id="cap-22"></a>

## 22. Style and idiomatic patterns

This chapter does not introduce new constructs: it shows how to combine those from previous chapters
in cases that always occur — transform a list, represent a record, hold a state
shared, construct a string. They are patterns, not rules of language, and you will recognize them in the
project code.

### 22.1 Higher-order functions written in Core

In Core there are no `map`/`filter`/`reduce`: they are written once, with `while` and lambda, and then
they use everywhere.

The difference compared to the Full versions is not only in the name: here the loop is explicit, so you see
the index, the end condition, and the point at which the item is added. If one day one of
these functions gives an unexpected result, the defect is visible in three lines.

```triad
function map(f, xs)
    out = []
    i = 1
    while i <= length(xs)
        push!(out, f(xs[i]))
        i += 1
    end
    out
end

function filter(p, xs)
    out = []
    i = 1
    while i <= length(xs)
        if p(xs[i])
            push!(out, xs[i])
        end
        i += 1
    end
    out
end

function reduce(f, acc, xs)
    i = 1
    while i <= length(xs)
        acc = f(acc, xs[i])
        i += 1
    end
    acc
end

xs = [1, 2, 3, 4, 5, 6]
println(map(x -> x * x, xs))
println(filter(x -> x % 2 == 0, xs))
println(reduce((a, b) -> a + b, 0, xs))
```

**Output:**

```text
[1, 4, 9, 16, 25, 36]
[2, 4, 6]
21
```

`map` and `filter` return new lists, `reduce` returns a value; in all three cases
the received function is a normal parameter, so the behavior can be changed without touching
the cycle. Note that `reduce` accumulates in `acc` and does not mutate `xs`: the input list remains the same.

### 22.2 Records as tagged lists

In Core there is no `struct`: a record is a list with a symbol as a tag in the first position. The
convention is important because without struct there is no nominal type: the meaning of the record
it lies entirely in the tag and field order, which the program must respect itself.

```triad
point(x, y) = [:Point, x, y]
px(p) = p[2]
py(p) = p[3]
sum_points(a, b) = point(px(a) + px(b), py(a) + py(b))
p = sum_points(point(1, 2), point(10, 20))
println(p, " ", p[1] == :Point)
```

**Output:**

```text
[:Point, 11, 22] true
```

The example is built to show the deal: `dot` is the constructor, `px`/`py` are the accessories
and no function touches the elements by hand except them. If one day you change the order of the fields,
you only change the manufacturer and accessories; those who use `px` and `py` don't notice this. It's the same
principle of encapsulation of a struct, obtained with conventions instead of the type.

### 22.3 Environment as a list of associations

This is the structure used by user agents in `selfhost/`: a flat list `[name1, value1, name2,
value2, …]`.

```triad
function env_get(env, name)
    i = 1
    while i < length(env)
        if env[i] == name
            return env[i + 1]
        end
        i += 2
    end
    nothing
end

function env_set(env, name, value)
    i = 1
    while i < length(env)
        if env[i] == name
            env[i + 1] = value
            return env
        end
        i += 2
    end
    push!(env, name)
    push!(env, value)
end

env = []
env_set(env, :x, 10)
env_set(env, :y, 20)
env_set(env, :x, 11)
println(env, " ", env_get(env, :x), " ", env_get(env, :z))
```

**Output:**

```text
[:x, 11, :y, 20] 11 nothing
```

It's a flat list to avoid paying a level of nesting: the pairs are side by side and `env[i+1]`
reads the value of the name in position `i`. The cost is that each search is linear and that the two
functions must advance two by two; the advantage is that the structure is a normal list, therefore
it is printed and inspected without conversions. It's the same pattern an interpreter uses for the environment
of names.

### 22.4 Shared mutable state

Since a named function cannot reassign a global, the shared state is held in one
mutable list or in a closure.

```triad
status = [0]
function tick()
    status[1] += 1
end
tick()
tick()
println(state[1])
```

**Output:**

```text
2
```

`tick` does not reassign `status`: it mutates the list element that `status` indicates. It's the difference of
chapter 3 between changing a link and changing an object, and here is what allows a function
appointed to update an external state without violating rule 8.3 on local assignment. The
list acts as a container: the `state` link remains the same, the content changes. If the state must
have more fields, you make the list longer (or use a tagged record as in 22.2).

### 22.5 Constructing strings

Two functions that always return: repeating a string and joining a list with a separator. In Core
there is no function that joins a list with a separator, so the separator must be inserted manually,
and position is everything: it must be placed in front of every element except the first. Remember that every `*` creates
a new string (chap. 10).

```triad
function repeat(s, n)
out = ""
    while n > 0
        out = out * s
        n -= 1
    end
    out
end

function join(xs, sep)
    out = ""
    i = 1
    while i <= length(xs)
        if i > 1
            out = out * sep
        end
        out = out * string(xs[i])
        i += 1
    end
    out
end

println(repeat("ab", 3))
println(join([1, 2, 3], ", "))
```

**Output:**

```text
ababab
1, 2, 3
```

`join` puts the separator before every element except the first one: this is why the `i > 1` check
comes first of the two concatenations. If I put it after the element, the last concatenation
would leave the separator at the end of the string.

### 22.6 Style rules

- Small functions with clear names; explicit base case in every recursion; for great depths
  prefer `while`.
- Loops with explicit counters (`i = 1 … while i <= length(xs)`).
- Don't use `fact`, `rule`, `solve`, `struct` and other Full keywords as names: code
  must also remain valid in Triad-Full.
- Write `!io` on functions that print: Core ignores it, Full requires it.
- Don't break an expression across multiple lines: the reference interpreter closes the statement at each
  newlines also inside the brackets (chap. 1.6). One instruction per line.

These rules are not personal tastes: each avoids a concrete problem — a name that collides with
Full, an undeclared effect, a reading ambiguity, a broken line that the runtime rejects.

---

<a id="part-2"></a>

# Part II — Exercises

Each exercise has a verified solution. Try it first, then open the "Solution" box.

The exercises in the first series are Triad-Core programs and are performed with the interpreter of
reference; those of the second use Full constructs, therefore they have expected results but they are not
executable today. In both cases the solution is not the only right program: it is a program that
it works, and it is useful to compare it with yours to understand which of the two is clearer.

<a id="cap-23"></a>
## 23. Guided exercises (Triad-Core)

### Exercise 1 — Power and sums

Without using `^`, write `power(b, e)` recursive and `sum_up(n)` (sum `1 + … + n`) with `while`.
Prints `power(3, 13)`, `power(2, 10)` and `sum_up(100)`.

<details>
<summary>Solution</summary>

```triad
power(b, e) = e == 0 ? 1 : b * power(b, e - 1)

function sum_up(n)
    s = 0
    i = 1
    while i <= n
        s += i
        i += 1
    end
    s
end

println(power(3, 13), " ", power(2, 10), " ", sum_up(100))
```

**Output:**

```text
1594323 1024 5050
```

</details>

### Exercise 2 — Prime numbers

Prints the list of prime numbers less than 30.

<details>
<summary>Solution</summary>

```triad
function first(n)
    if n < 2
        return false
    end
    d = 2
    while d * d <= n
        if n % d == 0
            return false
        end
        d += 1
    end
    true
end

prime = []
n = 2
while n < 30
    if first(n)
        push!(first, n)
    end
    n += 1
end
println(firsts)
```

**Output:**

```text
[2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
```

</details>

### Exercise 3 — Reverse a list

Write `reverse(xs)` which returns a new list with the elements in reverse order.

<details>
<summary>Solution</summary>

```triad
function invert(xs)
    out = []
    i = length(xs)
    while i >= 1
        push!(out, xs[i])
        i -= 1
    end
    out
end

println(reverse([1, :two, "three"]))
```

**Output:**

```text
[three, :two, 1]
```

</details>

### Exercise 4 — Insertion sorting

Order `[5, 2, 9, 1, 7]` on site.

<details>
<summary>Solution</summary>

```triad
function sort!(xs)
    i = 2
    while i <= length(xs)
        k = xs[i]
        j = i - 1
        while j >= 1 && xs[j] > k
            xs[j + 1] = xs[j]
            j -= 1
        end
        xs[j + 1] = k
        i += 1
    end
    xs
end

println(sort!([5, 2, 9, 1, 7]))
```

**Output:**

```text
[1, 2, 5, 7, 9]
```
The final `!` in the name signals, by convention, a function that changes its argument.

</details>

### Exercise 5 — Word counter

Count the words (separated by spaces) of `"the Triad language"` using `strbyte`.

<details>
<summary>Solution</summary>

```triad
function word_count(s)
    n = 0
    inside = false
    i = 1
    while i <= strlen(s)
        space = strbyte(s, i) == 32
        if !space && !inside
            n += 1
        end
        inside = !space
        i += 1
    end
    n
end

println(count_words("the Triad language "))
```

**Output:**

```text
3
```

</details>

### Exercise 6 — A mini-lexical analyzer

Transforms `"12+x*3"` into a list of `[type, text]` tokens, with types `:num`, `:id`, `:op`. It's the first
step of an interpreter.

<details>
<summary>Solution</summary>

```triad
digit(b) = b >= 48 && b <= 57
letter(b) = (b >= 97 && b <= 122) || (b >= 65 && b <= 90) || b == 95

function tokenize(s)
    toks = []
    i = 1
    while i <= strlen(s)
        b = strbyte(s, i)
        if digit(b)
            j = i
            while j <= strlen(s) && digit(strbyte(s, j))
                j += 1
            end
            push!(toks, [:num, strsub(s, i, j - 1)])
            i = j
        elseif letter(b)
            j = i
            while j <= strlen(s) && (letter(strbyte(s, j)) || digit(strbyte(s, j)))
                j += 1
            end
            push!(toks, [:id, strsub(s, i, j - 1)])
            i = j
        else
            push!(toks, [:op, strsub(s, i, i)])
            i += 1
        end
    end
    toks
end

println(tokenize("12+x*3"))
```

**Output:**

```text
[[:num, 12], [:op, +], [:id, x], [:op, *], [:num, 3]]
```

</details>

### Exercise 7 — Evaluating an expression

Using the tokens from Exercise 6, write a recursive drop-down evaluator for `+` and `*` with
precedence, where the variables come from a list of associations. Tip: Hold your ground
current in a list `pos = [1]`, so functions can update it.

<details>
<summary>Solution</summary>

```triad
digit(b) = b >= 48 && b <= 57
letter(b) = (b >= 97 && b <= 122) || b == 95

function tokenize(s)
    toks = []
    i = 1
    while i <= strlen(s)
        b = strbyte(s, i)
        if digit(b)
            j = i
            while j <= strlen(s) && digit(strbyte(s, j))
                j += 1
            end
            push!(toks, [:num, strsub(s, i, j - 1)])
            i = j
        elseif letter(b)
            j = i
            while j <= strlen(s) && letter(strbyte(s, j))
                j += 1
            end
            push!(toks, [:id, strsub(s, i, j - 1)])
            i = j
        else
            push!(toks, [:op, strsub(s, i, i)])
            i += 1
        end
    end
    toks
end

function search(env, name)
    i = 1
    while i < length(env)
        if env[i] == name
            return env[i + 1]
        end
        i += 2
    end
    0
end

function primary(toks, pos, env)
    t = toks[pos[1]]
    pos[1] += 1
    if t[1] == :num
        Int(t[2])
    else
        search(env, t[2])
    end
end

function product(toks, pos, env)
    v = primary(toks, pos, env)
    while pos[1] <= length(toks) && toks[pos[1][2] == "*"
        pos[1] += 1
        v = v * primary(toks, pos, env)
    end
    v
end

function sum(toks, pos, env)
    v = product(toks, pos, env)
    while pos[1] <= length(toks) && toks[pos[1]][2] == "+"
        pos[1] += 1
        v = v + product(toks, pos, env)
    end
    v
end

evaluate(s, env) = sum(tokenize(s), [1], env)
println(evaluate("12+x*3", ["x", 10]))
println(evaluate("2*3+4*5", []))
```

**Output:**

```text
42
26
```

</details>

### Exercise 8 — A dictionary environment

Extend exercise 7 (the evaluator with environment) by removing a name, and write
`environment_from_list` which constructs an environment from `[name, value]` pairs. Check with `env_get` ed
`env_set` from chapter 22.3.

<details>
<summary>Solution</summary>

```triad
function env_get(env, name)
    i = 1
    while i < length(env)
        if env[i] == name
            return env[i + 1]
        end
        i += 2
    end
nothing
end

function env_set(env, name, value)
    i = 1
    while i < length(env)
        if env[i] == name
            env[i + 1] = value
            return env
        end
        i += 2
    end
    push!(env, name)
    push!(env, value)
end

function env_remove(env, name)
    out = []
    i = 1
    while i < length(env)
        if env[i] == name
            i += 2
        else
            push!(out, env[i])
            push!(out, env[i + 1])
            i += 2
        end
    end
    out
end

function environment_from_list(pairs)
    env = []
    i = 1
    while i < length(pairs)
        env_set(env, pairs[i], pairs[i + 1])
        i += 2
    end
    env
end

env = environment_from_list([:x, 10, :y, 20])
println(env, " ", env_get(env, :x))
env = env_remove(env, :x)
println(env, " ", env_get(env, :x))
```

**Output:**

```text
[:x, 10, :y, 20] 10
[:y, 20] nothing
```

</details>

<a id="cap-24"></a>

## 24. Exercises on Triad-Full

These exercises use the constructs of the full standard. They are defined by the specification and have
expected results in `conformance/cases/`, but are **not yet executable** by the current runtime.

Studying them is still useful: the solutions are normative code, and seeing them next to the Core exercises
shows that Full constructs are nested in the same syntax, not in a separate language.
The reported output is an expected value held by the suite, not a test performed today.

### Exercise 9 — Dispatch on struct

Define `struct Vec2` with two `Float` fields and three `area` methods: one for `Vec2`, one for `Number`
and one for `Any`. Verify that the most specific method wins.

<details>
<summary>Solution</summary>

```triad-full
struct Vec2
    x::Float
    y::Float
end

area(v::Vec2) = v.x * v.y
area(n::Number) = n * n
area(x::Any) = 0

println(area(Old2(3, 4)))
println(area(5))
println(area("hello"))
```

**Output (golden Full):**

```text
12.0
25
0
```

</details>

### Exercise 10 — A knowledge base
Write facts and rules for `parent` and `sister`, and use `solve` to find the sisters of `:bob` and
`:alice`'s grandchildren.

<details>
<summary>Solution</summary>

```triad-full
fact parent(:alice, :bob)
fact parent(:alice, :carol)
fact parent(:bob, :dave)
fact parent(:carol, :erin)

rule grandparent(?x, ?z) :- parent(?x, ?y), parent(?y, ?z)

rule sister(?a, ?b) :- parent(?p, ?a), parent(?p, ?b), ?a != ?b

println([s.b for s in solve sister(:bob, ?b)])
println([s.z for s in solve grandparent(:alice, ?z)])
```

**Output (golden Full):**

```text
[:carol]
[:dave, :erin]
```

</details>

### Exercise 11 — Contracts in practice

Write `divide(a, b)` with `requires b != 0` and `ensures abs(result * b - a) < 1e-9`, and use `try` to
distinguish the case of breached contract from the case of success.

<details>
<summary>Solution</summary>

```triad-full
function divide(a::Number, b::Number)::Float
    requires b != 0
    ensures abs(result * b - a) < 1e-9
    a/b
end

r = try divide(1, 0) end
if iserr(r)
    println("contract: ", r.data.clause)
else
    println("value: ", r)
end
```

**Output (golden Full):**

```text
contract: requires
```

</details>

### Exercise 12 — A macro that measures

Write the macro `@measure(label, expr)` that evaluates the expression and prints the label and value,
returning the value.

<details>
<summary>Solution</summary>

```triad-full
macro measure(label, e)
    :(begin
        r = $e
        println($label, " -> ", r)
        r
    end)
end

total = @measure("sum", 1 + 2 + 3)
println(total)
```

**Output (golden Full):**

```text
sum -> 6
6
```

</details>

---

<a id="part-3"></a>

# Part III — Reference

This part is designed for consultation, after reading the first: it contains the grammar,
the quick tabs, the error table, the glossary and the real status of the implementations. Not
it is new material: if a point doesn't add up, the reference to the chapter in Part I takes you back to
explanation. Please note that the reference sections describe the **standard**; the state of
what is executable today is collected in the last chapter.

<a id="cap-25"></a>

## 25. Grammar

Grammar is the most compact form in which a specification says what a valid program is. Yes
reads like a recipe: `=` means «is made of», `{ … }` means «zero or more», `[ … ]`
«optional». The following two grammars do not describe two languages: the first is the subset
Core, the second is Full, and the productions that Core shares appear in Full with the same form.

### 25.1 Triad-Core (EBNF regulation)

```
program = { sep } { stmt sep { sep } };
sep = NEWLINE | ";" ;
stmt = funcdef | "return" [ expr ] | "break" | "continue" | expr ;
funcdef = "function" NAME "(" [ NAME { "," NAME } ] ")" block "end"
         | NAME "(" [ NAME { "," NAME } ] ")" "=" expr ;
expr = assignment ;
assignment = NAME ( "=" | "+=" | "-=" | "*=" ) expr | ternary ;
ternary = or_expr [ "?" expr ":" expr ] ;
or_expr = and_expr { "||" and_expr } ;
and_expr = cmp_expr { "&&" cmp_expr } ;
cmp_expr = sum_expr { ( "==" | "!=" | "<" | "<=" | ">" | ">=" ) sum_expr } ;
sum_expr = mul_expr { ( "+" | "-" ) mul_expr } ;
mul_expr = pow_expr { ( "*" | "%" ) pow_expr } ;
pow_expr = unary { "^" unary } ;                    (*right*)
unary = ( "-" | "!" ) unary | postfix ;
postfix = primary { "(" args ")" | "[" expr "]" } ;
primary = INT | STRING | SYMBOL | "true" | "false" | "nothing" | NAME
         | "(" expr ")"
         | "[" [ expr { "," expr } ] "]"
         | "(" NAME { "," NAME } ")" "->" expr
         | "if" expr block { "elseif" expr block } [ "else" block ] "end"
         | "while" expr block "end"
         | "let" [ NAME "=" expr { "," NAME "=" expr } ] block "end"
         | "begin" block "end"
| "function" "(" [ NAME { "," NAME } ] ")" block "end" ;
block = { stmt sep { sep } } ;                   (* to end/else/elseif *)
```

The Core grammar is deliberately small: no `for`, no ranges, no types in signatures. Not
however, it describes every detail that the execution accepts: the assignment to an element (`xs[i] = e`,
`xs[i] += e`), which the examples in chapter 9 use to mutate lists, does not appear in production
`assignment`. It is a shortcoming of the text of the specification, not of the language: the interpreter of
reference supports it, and code using it is portable between Core implementations.

### 25.2 Triad-Full (EBNF regulation)

```
program = { sep } { stmt sep { sep } };
sep = NEWLINE | ";" ;
block = { sep } { stmt sep { sep } };

stmt = funcdef | structdef | macrodef | facts | rule
           | "requires" expr | "ensures" expr
           | "return" [ expr ] | "break" | "continue"
           | "(" NAME { "," NAME } ")" "=" expr
           | expr ;

funcdef = "function" fname "(" [ params ] ")" [ "::" TYPE ] [ "!" EFFECT { "," EFFECT } ]
             block "end"
           | NAME "(" [ params ] ")" "=" expr ;
fname = NAME | "+" | "-" | "*" | "/" | "%" | "^" | "==" | "<" | "<=" | ">" | ">=" ;
params = param { "," param } ;
param = NAME [ "::" TYPE ] | "(" NAME { "," NAME } ")" ;
structdef = "struct" NAME sep { NAME [ "::" TYPE ] sep } "end" ;
macrodef = "macro" NAME "(" [ NAME { "," NAME } ] ")" block "end" ;

fact = "fact" term ;
rule = "rule" term [ ":-" goal { "," goal } ] ;

expr = (*Pratt: precedence from lowest to highest *)
  1 a = b a += b a -= b a *= b (right)
  2 x -> e (a, b) -> e c ? a : b (right)
  3 ||
  4 &&
  5 == != < <= > >= in isa is
  6 a:b (range, no spaces)
  7 + -
  8 * / %
  9 -x !x +x $x (unary)
10^ (right)
 11 e::T (type assertion)
 12 f(args) xs[i] a.field (postfixes, no space before ( and [)

primary = NUMBER | STRING | SYMBOL | LVAR | NAME | "true" | "false" | "nothing"
           | "(" expr ")" | "(" expr "," ... ")" (* tuple: lambda parameters *)
           | "[" [ expr { "," expr } [ "|" expr ] ] "]"
           | "[" expr "for" NAME "in" expr [ "if" expr ] "]"
           | ":(" expr ")" | "quotes" block "end"
           | "@"NAME"("args")"
           | "if" expr block { "elseif" expr block } [ "else" block ] "end"
           | "while" expr block "end"
           | "for" NAME "in" expr block "end"
           | "for" "(" NAME { "," NAME } ")" "in" expr block "end"
           | "let" [ NAME "=" expr { "," NAME "=" expr } ] block "end"
           | "begin" block "end"
           | "try" block [ "catch" [ NAME ] block ] "end"
           | "with" modifier { "," modifier } block "end"
           | "solve" goal { "limit" expr | "depth" expr | "steps" expr | "trace" }
           | "function" "(" params ")" block "end" ;
modifier = "budget" "(" "steps" "=" expr ")" | "trace" ;
```

The Full grammar lists the precedence levels in the numbered form that the parser uses: it is the
same table as chapter 4, and the `primary` production tells which shapes can underlie
an expression. The `stmt` and `block` productions instead tell what a block can contain, e
so where `fact`, `rule`, `requires` and `ensures` are allowed.

---

<a id="cap-26"></a>

## 26. Quick Tabs

Quick cards do not replace chapters: they serve to remember the exact form of a construct
when you already know what you want to write. They are divided by problem type — a value, a control of
flow, a function — and each line refers, when necessary, to the chapter that explains the choice.

### 26.1 Values

| do you want | write |
|---|---|
| an integer | `42`, `1_000` |
| a float **[Full]** | `3.14`, `1e-9` |
| a boolean | `true`, `false` |
| the void | `nothing` |
| a string | `"text"` |
| a symbol | `:alice` |
| a list | `[1, 2, 3]` |
| a lambda | `x -> x + 1` |
| a function | `function (x) x end` |
| a Core record | `[:Point, 1, 2]` |
| a struct **[Full]** | `Point(3, 4)` |
| code as given **[Full]** | `:(a + b)`, `quote … end` |

### 26.2 Flow control

| do you want | write |
|---|---|
| a condition | `if c … elseif d … else … end` |
| a short condition | `c ? a : b` |
| a cycle | `while c … end` **[Core]** · `for x in xs … end` **[Full]** |
| exit the loop | `break` |
| skip to the next step | `continue` |
| exit the function | `return is |
| a new scope | `let x = 1 … end` |
| a scopeless block | `begin … end` |
| a constructed list **[Full]** | `[x * x for x in xs]` |
| catch an error **[Full]** | `try b catch and h end` |

### 26.3 Functions

| do you want | write |
|---|---|
| a function | `f(x) = x + 1` |
| a multi-education body | `function f(x) … end` |
| a **[Full]** return type | `function f(x)::Float … end` |
| a **[Full]** effect | `function f(x) !io … end` |
| a predicate in a goal **[Full]** | `function evena(n) n % 2 == 0 end` |
| a **[Full]** precondition | `requires cond` |
| a **[Full]** postcondition | `ensures cond` |

---

<a id="cap-27"></a>

## 27. Error table

The table collects the messages that the reference interpreter prints today in Triad-Core, with the
typical cause. The messages are from the implementation, not the standard: the error category is
regulations (chap. 11.3), the text does not, so do not write programs that depend on these strings.

### 27.1 In Core

Core has no `try`/`catch` or `Err` values: an error **terminates the process** with exit code `1` and a
diagnostic message on stderr. The one already printed on stdout remains.

| message | cause |
|---|---|
| `parse error: unexpected token …` / `parse error: expected …` | non-Core syntax (`1.5`, `/`, `() -> …`, `end` missing) |
| `error: undefined variable NAME` | name never assigned, or function called before being defined |
| `error: not a function` | a value that is not a function is called (`x = 5; x(1)`) |
| `error: arity mismatch` | number of arguments other than parameters |
| `error: index out of range` | `xs[i]` with `i < 1` or `i > length(xs)` |
| `error: + type error` (and similar) | operands of wrong type (`1 + "a"`) |
| `error: if cond` / `while cond` / `ternary cond` / `&& expects bool` | non `Bool` condition |
| `error: div by zero` / `negative exponent` | `x % 0`, `2 ^ -1` |
| `error: unknown function NAME` | reserved builtin used in an unsupported way |
| `cannot read file: …` | file non-existent or unreadable |
| `usage: triad FILE [ARG...]` (exit 2) | no files passed |

### 27.2 In Triad-Full

The same failures arrive as `Err` with a `kind` (ch. 11.3), instead of terminating the
process. An unhandled error at the top level prints `line N: …` and exits with code `1`.
---

<a id="cap-28"></a>

## 28. Glossary

The glossary collects the terms that the manual uses with a precise meaning and that occur in
different chapters. The definitions are short on purpose: the reference to the chapter is useful when the word
alone is not enough.

| term | meaning |
|---|---|
| **Uniform tree** | the only node type produced by the parser, `Node(head, args)`; it's also what the kernel does |
| **Environment** | the set of links between names and values ​​visible at a point in the program |
| **Backtracking** | the logic engine goes back to the bonds and tries the next clause |
| **Budget** | limit of executable steps; exhausted produces `Err(:budget)` |
| **Clause** | a knowledge base `fact` or `rule` |
| **Closing** | function that captures the environment in which it was created |
| **Dispatch** | choice of method based on the **types** of the arguments |
| **Effect** | declared capability of a function: `i`, `state` |
| **Err** | the error as given: `kind`, `msg`, `data` |
| **Goal** | a question to the knowledge base: predicate, conjunction, disjunction, unification |
| **Knowledge base** | the set of facts and rules |
| **Macros** | a function that receives and returns code |
| **Occurs-check** | the rule that prevents `?x` from merging with a term containing `?x` |
| **Door (Byrd)** | one of the four events `:call`, `:exit`, `:redo`, `:fail` that describe a logical search step (chap. 14) |
| **Precedence** | the order in which the operators are grouped (12 levels in Full, 10 in Core) |
| **Profile** | a regulatory subset of the standard: Core or Full |
| **Lexical Scope** | a name is visible where it was linked and on the inside, never on the outside |
| **Solution** | a `Solution`: the bonds produced by a solved goal |
| **Standardization aside** | the variables of a clause are renamed each time | is used
| **Term** | a logical data: constant, logical variable or composite form, not evaluated until needed |
| **Track** | the `Traced(result, trace)` value returned by `with trace` or `solve … trace` |
| **Unification** | logical equality: two terms become identical by linking the variables |
| **First class values** | functions and operators that can be used like any other value |

---

<a id="cap-29"></a>

## 29. What's going on today

This section is not part of the language: it is the status of the implementations, useful for orientation
before writing code. It serves to answer a question that a manual risks leaving
implicit: what you just read is **defined** by the standard, but what can you **execute**
today? The two things do not coincide, and confusing them leads to two opposite errors: believing that an example
Full doesn't work because it's wrong, or believing that a Core program works on every runtime.

| profile | status |
|---|---|
| **Triad-Core** | **executable**: JavaScript reference interpreter `seed/dev/triad_core.cjs` (37/37 Core cases) and, in part, the Windows seed `seed/windows-x86_64/seed.exe` |
| **Triad-Full** | **not executable**: struct, dispatch, logic, macro, contracts, budget, traces, effects, destructuring, `for`, `try`, `Float` are specific; in Full conformance only `error` |

The Full profile is not "almost ready": it is fully defined in the standard, and its examples have
expected results preserved by the suite, but none of the repository runtimes run it today. When
in the book you see `**Output (golden Full):**`, therefore, you read an expected value, not a verification just
done. On the Core side the situation is different: the JavaScript interpreter passes the entire suite,
while the Windows seed covers only a part of the cases — in particular the lists remain partial.

Even staying in Core, "executable" does not mean "identical everywhere": there are two runtimes, and not
they cover the same subset. The table lists the differences that matter to code writers
intended to run on both; reading it before choosing a construct avoids discovering the
problem only when the program arrives on the seed.

Known differences between the two Core runtimes:

| functionality | JS interpreter | seed Windows |
|---|---|---|
| `return`, `break`, `continue` | yes | not listed in the seed README |
| lambda | more parameters | **only one parameter** |
| closures | shared | **by value**, only the last binding of the frame |
| `string(x)` | all types | only `Int` and `String` |
| lists | heterogeneous, `xs[i]`, `length`, `push!` | only integers; construction, press, `push!` |
| `get(xs, i)` | does not exist | **non-standard** auxiliary function, indices **from 0** |
| `ARGS`, bootstrap primitives | yes | not listed in the seed README |
| error messages | on stderr | exit code only |

The most important lines are the first three. A `return` or a `break` that the JS interpreter executes can
not be supported by the seed; a lambda with two parameters works on one and not the other; one
closure that updates a shared state behaves differently. They are differences of
implementation, not standard: the correct semantics are those of the JS interpreter and the
specification, and the seed is the most limited runtime. If a program needs to run on both, choose the
common subset and don't rely on what a single column declares.

Rule of thumb: **write code that respects `SPEC-CORE` and test it with the JS interpreter**; if he must
also turn on the seed, narrow down to the features listed in the right column and check it out
on Windows.

Two known limitations that the reader should be aware of before writing code:

- **each newline closes the statement**, even inside `( )`, `[ ]` and in the arguments of a call.
  The exception provided by `SPEC §1` for Triad-Full (wrapped inside parentheses, or immediately after a
binary operator) is not implemented in the reference interpreter. Write an instruction for
  row;
- **Windows seed does not implement standard `xs[i]` indexing**: the function is there
  non-standard auxiliary `get(xs, i)`, with indices **from 0**.

To these two limits a platform detail must be added: the Linux seed is at the E0 stage and prints
just a test message, so to run programs on Linux today you use the interpreter
JavaScript (`node seed/dev/triad_core.cjs`). The Windows seed is the most machine code runtime
complete, but it's not the only way to run Triad.

What to do with it, in practice: to study and write code use the JS interpreter; to check the
portability to the bootstrap test on the seed; for Full examples read and compare with the golden ones,
knowing that no runtime executes them yet. The manual doesn't promise what the repository doesn't know
do, and this section exists to make the boundary explicit.

---

<a id="app-a"></a>

# Appendix A — Claimed influences

Triad was born from ideas of Julia, Prolog and Lisp, but **is not a dialect of any of the three**: the
definition of the language is the specification.

Knowing the influences is not curiosity: if you come from one of these languages, knowing what Triad
has resumed and what has changed helps you not to import bad habits. The table is not a
list of relatives, is a warning: the similarities are of idea, not of behavior.

| from | idea resumed |
|---|---|
| Julia | `function … end` blocks, `struct`, types with `::`, multiple dispatch, function-operators, `if`/`for`/`while`/`let` |
| Prolog | `fact`/`rule` as constructs, unification with occurs-check, backtracking, `solve`, `?x` logical variables |
| Lisp | code as given, uniform tree, `:( … )`/`quote` with `$`, macro |

**Own by Triad**, not borrowed: errors such as data, contracts, budgets, tracks and effects
declared as part of the language, and integrating the three patterns into a block syntax.

---

<a id="app-b"></a>

# Appendix B — Where to look

This appendix lists where to learn more. These are **optional** materials: the manual is
self-sufficient, and these references are useful to those who want to trace the regulatory source, check a
corner case or see project code. The study path by chapters and the visit to
code are a complement, not a prerequisite.

| do you want | read |
|---|---|
| the complete regulatory definition | [`SPEC.md`](SPEC.md) |
| the bootstrap subset | [`SPEC-CORE.md`](SPEC-CORE.md) |
| the study path by chapters and the project code | [`TUTORIAL.md`](tutorial/TUTORIAL.md) |
| the complete examples with output | `examples/` |
| the executable contract, with the golden | [`conformance/`](conformance/README.md) |
| the state of the bootstrap | [`STATUS.md`](STATUS.md) · [`BOOTSTRAP.md`](BOOTSTRAP.md) |
| the work plan | [`plan.md`](plan.md) · [`TASK.md`](TASK.md) |
| tools for editors | [`editors/`](editors/README.md) |
| the license | [`LICENSE`](LICENSE) — MIT |

---

*Manual written for the Triad `0.2.0` standard. The regulatory sections are in [`SPEC.md`](SPEC.md) and
[`SPEC-CORE.md`](SPEC-CORE.md); in case of divergence, the specification prevails.*