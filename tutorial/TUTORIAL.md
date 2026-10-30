<p align="center">
  <img src="https://raw.githubusercontent.com/GPuntobit/triad2.0/main/docs/triad-logo.webp" alt="Triad Logo" width="160">
</p>

# Triad 2.0 — Tutorial: Learn the project language and code

This tutorial is the guided path with which you learn Triad starting from scratch. He doesn't give for
It's assumed that you know the language: it just assumes that you know how to program in
some other language. If you already know how to write loops, functions and lists, you have everything you need;
the rest — the Triad syntax, the behavior of values, the distinction between the
executable subset and the complete standard — it is explained here, in the order in which it is convenient
learn it.

The path leads to three results. First, **write Triad-Core programs that actually run**,
that is, complete programs, executable today with the reference interpreter. Second, **know
Triad-Full**, the complete language defined by the standard, including the parts that runtime
current does not yet execute. Third, **know how to read the project code**: the interpreter of
reference, the machine code seed, the conformance suite, and the development tools.
The tutorial does not take you anywhere else to understand the concepts: the specification (`SPEC.md`, `SPEC-CORE.md`)
and the `conformance/` cases are optional insights, not prerequisites.

## What you learn and how it is organized

The tutorial is a book in five parts, designed to be read in order but enough
autonomous that they can be consulted separately.

- **Part I — First Steps.** What is Triad, how to install and run it, the first
  program explained line by line.
- **Part II — Triad-Core step by step.** The subset executable today, constructed for
  construct: lexicon, values, variables, expressions, flow control, functions, closures,
  lists, strings, bootstrap primitives, errors, and differences between runtimes. The exercises
  guided at the bottom of the part serve to fix what you have read.
- **Part III — Triad-Full (the complete standard).** Declared types, multiple dispatch,
  struct, `for` and comprehension, logic with facts and rules, macros, contracts, budgets, traces
  and effects. It's the language defined by the specification: you study it here, but the actual runtime doesn't
  still does it.
- **Part IV — The project code.** A guided tour of the repository: the interpreter of
  reference, the seed, S1, the compliance cases, the CLI, the benchmark, the contribution flow.
  It helps to understand how the language is implemented, not just how it is used.
- **Part V — Reference.** Grammar, quick tabs, error messages, glossary, status
  of the project and FAQ: chapters to consult, rather than read in succession.

**What does “executable today” mean?** The Triad standard defines two profiles of
compliance. An example is *runnable today* when it runs, unchanged, on
an implementation that already exists in the repository; is *defined by the standard* when the
specification describes it but no current runtime executes it. The tutorial always distinguishes the two
cases, and each block of code declares the profile to which it belongs.

| profile | where | is defined executable today? |
|---|---|---|
| **Triad-Core** | `SPEC-CORE.md` | **yes**: JavaScript reference interpreter `seed/dev/triad_core.cjs` (37/37 Core cases) and, partly, the Windows seed `seed/windows-x86_64/seed.exe` (33 Core cases verified in CI) |
| **Triad-Full** | `SPEC.md` | **no**: struct, dispatch, logic, macro, contracts, budget, traces, effects, destructuring, `for`, `try`, `Float` are specific; in Full conformance only `error` |

Two clarifications on the context, useful to avoid confusing the book with the project. The version
of the standard is `0.2.0`, registered in `VERSION`. Triad does not depend on Julia: that
old implementation has been removed, and the Triad-Full outputs you read in the book are i
**golden**, i.e. the expected results produced at the time by that implementation and frozen
in `conformance/cases/`; they were not played by the current runtime. On the contrary, every
example marked **Output:** is a Triad-Core program verified with
`node seed/dev/triad_core.cjs`; Full examples are marked **Output (golden Full):** or
they report no output.

---

## How to use this tutorial

There isn't just one way to read the book: it depends on what you need. The table below
summarizes the main routes. Those unfamiliar with Triad, however, should start with Part I:
the subsequent chapters take the vocabulary of the language as acquired.

| do you want… | read |
|---|---|
| write Triad programs that run today | [Part I](#part-1) → [Part II](#part-2) (chapters 4–17, with exercises) |
| know the complete language of the standard | [Part III](#part-3) (chapters 18–32) |
| contribute to JS interpreter, seed, S1, CLI or conformance | [Part IV](#part-4) (chapters 33–43) |
| consult grammar, quick sheets, errors, glossary | [Part V](#part-5) (chapters 44–49) |

Some conventions make it easier to follow the examples. Commands are shown for
Linux/macOS (`sh`) and, when they are different, for Windows (`cmd`/PowerShell). The `triad` blocks
they contain Core code, normally executable with the JS interpreter; the specific fragments of the
seed Windows are indicated in the text. `triad-full` blocks show code defined by
standard Full, not yet executable by the current runtime. With **JS interpreter** we mean
`seed/dev/triad_core.cjs`, the Triad-Core reference interpreter used on Linux/macOS and since
compliance runner; **seed** means `seed/windows-x86_64/seed.exe`, the interpreter
Triad-Core in machine code (S0). Where the two behave differently says the
[chapter 15](#chap-15). The sources are written in `.triad` (canonical extension) or `.td` files
(aka historical).

## Index
**[Part I — First steps](#part-1)**
1. [What is Triad](#cap-1)
2. [Install and Run](#ch-2)
3. [The first program](#ch-3)

**[Part II — Triad-Core step by step (run today)](#part-2)**

4. [Lexicon](#chap-4)
5. [Values, types and printing](#chap-5)
6. [Variables and assignment](#chap-6)
7. [Operators and expressions](#chap-7)
8. [Flow Control](#ch-8)
9. [Functions](#chap-9)
10. [Lambdas, closures and scopes](#cap-10)
11. [Lists](#cap-11)
12. [Strings, symbols and conversions](#cap-12)
13. [Bootstrap Primitives](#ch-13)
14. [Execution errors](#ch-14)
15. [JS interpreter and Windows seeds: differences](#cap-15)
16. [Triad-Core Idiomatic Patterns](#cap-16)
17. [Guided exercises](#chap-17)

**[Part III — Triad-Full (the complete standard)](#part-3)**

18. [Lexicon and Full types](#cap-18)
19. [Typed and multiple dispatch functions](#cap-19)
20. [Struct](#cap-20)
21. [Full flow control: `for`, range, comprehension, `try`](#cap-21)
22. [Logic: facts, rules, `solve`](#cap-22)
23. [Deconstruction](#cap-23)
24. [Errors as data](#cap-24)
25. [Contracts](#cap-25)
26. [Budget](#cap-26)
27. [Tracks](#cap-27)
28. [Declared effects](#cap-28)
29. [Code as given, uniform tree and macro](#cap-29)
30. [Builtin Full](#cap-30)
31. [Command line and REPL (SPEC §14)](#cap-31)
32. [Full examples with golden output](#cap-32)

**[Part IV — The project code](#part-4)**

33. [Repository Map](#cap-33)
34. [The JS Reference Interpreter (`seed/dev/triad_core.cjs`)](#cap-34)
35. [The S0 Windows seed and its generator](#cap-35)
36. [The Linux seed (E0)](#cap-36)
37. [Self-hosting: S1 in `selfhost/`](#cap-37)
38. [Conformance: reading, writing and verifying cases](#cap-38)
39. [The `triad-cli` development CLI](#cap-39)
40. [AI Benchmark (`ai/`)](#cap-40)
41. [Editor, launcher and site](#cap-41)
42. [Continuous integration](#cap-42)
43. [Contribution flow](#cap-43)

**[Part V — Reference](#part-5)**

44. [Triad-Core Grammar (EBNF)](#cap-44)
45. [Core and Full Quick Tabs](#cap-45)
46. [Debugging and common problems](#cap-46)
47. [Glossary](#cap-47)
48. [Status, known limits and historical fixes](#cap-48)
49. [FAQ](#cap-49)

---

<a id="part-1"></a>

# Part I — First steps

<a id="cap-1"></a>

## 1. What is Triad

Triad is a self-contained programming language that brings together three paradigms — imperative,
logical and metaprogrammatic — in a single block syntax. The basic idea is that these
paradigms should not be kept in separate languages: a Triad program can define functions and
loops like an imperative language, declare facts and rules like Prolog, and treat code
as a constructible and transformable value as in Lisp, and the three things coexist in the same
files without layers or interfaces.

There are three declared influences, and for each one the book will gradually show what Triad has
resumed:

| influence | idea taken up in Triad |
|---|---|
| Julia | `function … end`, `struct`, types with `::`, multiple dispatch, operators as functions, `if`/`for`/`while`/`let` |
| Prolog | `fact`, `rule`, unification with occurs-check, backtracking, `solve` with `?x` logical variables |
| Lisp | code as given (`Node`), `:( … )`/`quote` with `$`, macro |

To these are added, as part of the language and not of a library: **errors as data**
(`Err`), **contracts** (`requires`/`ensures`), **budget** (`with budget`), **tracks**
(`with trace`) and **declared effects** (`!io`, `!state`).

The distinction between "part of the language" and "library" is not nominal, and it is worth understanding
right away. An error that is a value can be returned, inspected, and composed like any
other data, instead of interrupting the program; a written contract in the signature is visible
to the implementation, which can control it; a declared effect allows the runtime to
verify that a pure function does not print. These are all features that a language can
offer only if it knows them, and for this reason Triad defines them in the standard rather than leaving them to
conventions between programmers.

From Julia comes the backbone of the syntax: `function … end` blocks, types with `::`, struct and
multiple dispatch. From Prolog comes the logic engine: facts, rules, unification with
occurs-check, backtracking and `solve` with logical variables. From Lisp comes the idea that code
be a uniform tree, therefore a value like the others, and the macro machine that on
that idea leans. Keeping the three models together is the truly new part: it doesn't exist
a «Monday language» and a «Tuesday language», there is only one program with only one
semantics of expressions and blocks.

### 1.1 Two profiles: Core and Full
The standard defines two compliance profiles (SPEC §16.1):

- **Triad-Core** ([`SPEC-CORE.md`](SPEC-CORE.md)): integers, Bools, strings, symbols, `nothing`,
  lists, functions, lambdas and closures, `if`/`elseif`/`else`, `while`, `let`, `begin`, ternary,
  `return`/`break`/`continue`, plus some bootstrap primitives. It's small enough to
  be implemented in handwritten machine code and expressive enough to write in
  the interpreter of all Triad.
- **Triad-Full** ([`SPEC.md`](SPEC.md)): All language.

The separation responds to a practical constraint, not a choice of convenience. The first interpreter
of Triad must exist before a Triad compiler exists, so it must be written by hand in code
machine: the smaller the language, the more realistic that task is. At the same time the
subset must be enough to write the complete interpreter in the second phase. Triad-Core is
exactly the point of balance between the two needs, and for this reason it is defined by one
specific to itself.

Every Triad-Core program (excluding bootstrap primitives) is also a Triad-Full program
valid and must behave in the same way. The reverse is not true: a program that uses `struct`,
`for` or `float` is Full, and the Core runtime will not execute it. It is the distinction that you will find in
the whole book: Part II teaches the profile going around today, Part III adds the rest.

### 1.2 The bootstrap chain

Triad doesn't want to depend on any host language, but every language has to start from
something. The bootstrap chain solves the problem in stages: We start with an interpreter
handwritten in machine code, you use it to run an interpreter written in Triad, e
so on up to a compiler that compiles itself. The plan ([`BOOTSTRAP.md`](BOOTSTRAP.md)):

```
S0 seed: Triad-Core interpreter in x86-64 machine code (hex dump in repo)
S1 interpreter of all Triad written in Triad-Core (selfhost/, in progress)
S2 native compiler written in Triad (uninitiated)
S3 self-hosted compiler: S2 compiled by S2 (uninitiated)
S4 Triad complete: REPL, CLI, tooling, parity Linux (not started)
```

The S0 seed is not distributed as an executable but as a hex dump - that's the simplest way
to versioned a binary in a text repository, and materializes with the tool
decoding the operating system ([chapter 2](#chap-2)). Stages S1–S4 are the direction of
project, not what you need to read this book: to follow the tutorial all you need is the S0 seed
or the JS interpreter.

The tools in Node.js (`seed/dev/*.js`, `conformance/run.mjs`, `cli/`) are **
development**: they help generate and verify, but are not part of the S0→S4 chain. Part IV
of the book presents them one by one, explaining what they do and why they are external to the bootstrap.

---

<a id="cap-2"></a>

## 2. Install and run

«Installing» Triad here doesn't mean installing a package: it means having the repository and
one of the two available runtimes. There is no compiler to add to the system yet, either
a language package manager. The chapter therefore answers two concrete questions: how
you execute a file and which runtime is best to start from.

The recommended choice for beginners is the **JS interpreter**: it starts with Node.js, it does not require
to decode binaries and is what conformance cases are checked against. The seed
Windows is interesting when you want to see the language run without guest runtimes; his
limits are listed in [chapter 15](#chap-15). To follow the book you can only use the interpreter
JS, and move to the seed when a chapter requires it.

### 2.1 Requirements

- **Node.js ≥ 18** (CI uses Node 20) for the JS interpreter, conformance runner and CLI.
- On Windows, nothing else for the seed: `seed.exe` is obtained by decoding `seed.hex` with
  `certutil`.
- Git to clone the repository: `git clone https://github.com/GPuntobit/triad2.0.git`.

The requirements are few on purpose: Triad doesn't want dependencies on other languages to run the
programs, and the development toolbox's only dependency is Node.js. If you have Node.js, you already have
everything you need to run the examples in Part II.

### 2.2 Running a file

A Triad program is a text file that the runtime reads, parses, and executes. The table
shows how to start it on the two platforms and how to pass it the script from stdin:

| platform | command |
|---|---|
| Linux / macOS | `node seed/dev/triad_core.cjs file.triad arg1 arg2` |
| Windows (seed) | `seed\windows-x86_64\seed.exe file.triad` or `bin\triad.cmd file.triad` |
| any (stdin, JS interpreter) | `echo 'println(7 * 6)' \| node seed/dev/triad_core.cjs -` |

Ready examples running today: all the `conformance/core/cases/*/program.td`, i.e. the cases that
the book cites as a normative reference at the end of each chapter.

```sh
node seed/dev/triad_core.cjs conformance/core/cases/recursion/program.td #120, 55
```

```cmd
bin\triad.cmd conformance\core\cases\recursion\program.td
```

The comment `#120, 55` is not part of the command: it indicates the expected output, i.e. what
you should see it appear. The hyphen `-` in place of the file name tells the JS interpreter to
read the program from standard input. The same file can be executed by the two runtimes,
but not always with the same result: the difference is the topic of [chapter 15](#chap-15).

### 2.3 Materialize the seed

The seed source is the hex dump; the executable is obtained with a decoder of
system. This is only needed if you want to test the seed: the JS interpreter does not require this step.

```powershell
Remove-Item seed\windows-x86_64\seed.exe -ErrorAction SilentlyContinue
certutil -decodehex seed\windows-x86_64\seed.hex seed\windows-x86_64\seed.exe
```

```sh
# Linux: ELF seed at E0 stage (only prints "Triad seed Linux OK")
xxd -r -p seed/linux-x86_64/seed.hex seed/linux-x86_64/seed && chmod +x seed/linux-x86_64/seed
```

The Windows command first deletes the previous executable, if it exists, and then recreates it from the dump; up
Linux the result is a minimal ELF, the E0 stage, which for now simply prints a message
startup: not yet an interpreter. It's not an installation error, it's the status of the port
described in [`STATUS.md`](STATUS.md).

### 2.4 Launcher `bin/triad` and `bin/triad.cmd`

A launcher helps you avoid having to remember every time which binary to use and which folder it is in
find. It's not mandatory, but it's convenient: when `bin/` is in the `PATH` just `triad file.triad`, like
with a language installed on the system. The runtime search follows a specific order, from
best runtime available:

1. `bin/triad-native` (standalone executable, **not yet produced**: will come with S2–S3);
2. `seed/<platform>/seed` (on Windows `seed\windows-x86_64\seed.exe`).

On Linux the launcher finds the ELF E0 seed, which **does not yet interpret programs**: for
Running code on Linux uses the JS interpreter directly. `triad --build` is a remnant of the
old Julia implementation: Print a message explaining why the build is no longer
supported and exits with code 2. When no runtime is available, the launcher does not fail
silence: Print instructions for materializing the seed.

### 2.5 Exit Codes

Exit codes are part of the language contract, not a convenience detail: the
conformance suite also compares the code, so a program that prints the right output but
comes out with the wrong code does not pass.

| code | meaning |
|---|---|
| `0` | success |
| `1` | parsing or execution error (message on stderr), file unreadable |
| `2` | invalid use (e.g. no file) |

SPEC §14 options (`-e`, `-E`, `-l`, `-i`, `--tree`, `--help`, REPL) **are not yet
implemented**: the JS interpreter treats them as a file name, and the Windows seed, which documents
just use `seed.exe FILE`, it doesn't recognize them. For this reason, when an example doesn't work, the first one
question to ask yourself is which of the three codes you got: a `2` indicates a problem in the command, a
`1` a problem in the program.

### 2.6 The development CLI in brief

The CLI is optional: it collects in a single command the operations that you would otherwise do manually
in the repository. The following lines show the most used ones, each with the comment that says that
what it does.

```sh
bin/triad-cli status # environment and seed found (Windows: bin\triad-cli.cmd)
bin/triad-cli test conformance # conformance Core
bin/triad-cli ai verify -v # verify solutions of ai/tasks/
bin/triad-cli seed generate windows # regenerate seed.hex and print the SHA-256
node conformance/run.mjs # direct conformance runner (Core)
```

`bin/triad-cli*` launchers run `npm install` in `cli/` on first launch. Alternatively yes
use the standalone executable `triad-cli.exe` / `triad-cli` attached to the
[beta release](https://github.com/GPuntobit/triad2.0/releases). Details in
[chapter 39](#chap-39). To follow Part II the CLI is not needed: the examples are executed
directly with `node`.

---

<a id="cap-3"></a>

## 3. The first program

A Triad program requires no ceremony: there is no configuration file, there are no imports
to declare, there is no `main` function to invoke. The first program is a text file that
contains the instructions in the order in which they must be executed.

Create `ciao.triad`:

```triad
#!/usr/bin/env triad
# my first Triad program
name = "Triad"
println("hello, " * name)
println(6 * 7)
```

Outputs:

```text
Hi, Triad
42
```

Run it:

```sh
node seed/dev/triad_core.cjs hello.triad # Linux/macOS
```

```cmd
seed\windows-x86_64\seed.exe hello.triad # Windows
```

What to note:

- the first line `#!` (shebang) is ignored: it starts with `#`, so it is a comment;
- `println` prints its arguments **without separators** and adds a newline;
- `*` between strings is **concatenation** (not `+`);
- there is no `main` function: top level instructions are executed in order.

You can follow the execution line by line. The line `name="Triad"` evaluates the string and matches
that value to the name `name`. In the following line the runtime reads `name`, concatenates the two values
string with `*` and pass the result to `println`. In the last line, `6 * 7` is evaluated first
of the call: `println` gets the integer value `42`, not the calculation text. Every
instruction is executed only once and in the order in which it appears; a function called can
naturally run your body before the program moves on to the next instruction.

The `#!` line is not a necessary directive for the interpreter: in these examples it is a form
conventional useful when the operating system can directly launch an executable file. The
Triad runtime ignores it because it treats it as a comment. If an example doesn't work, check
separately that the file is saved with a `.triad` or `.td` extension, that the command points to the
correct runtime and that the source only uses constructs supported by the declared profile.

### 3.1 Command line arguments

The arguments after the file name are in `ARGS`, a list of strings (without the name of the
program). Example with the JS interpreter:

```sh
printf 'println(ARGS)\nprintln(length(ARGS))\n' > args.triad
node seed/dev/triad_core.cjs args.triad one two # [one, two] then 2
```

> Windows seed only documents `seed.exe FILE` usage: `ARGS` is not among the features
> listed in `seed/windows-x86_64/README.md`. Use the JS interpreter for programs with arguments.

### 3.2 The recommended duty cycle

1. write the program using only Triad-Core (Part II);
2. run it with the JS interpreter (`node seed/dev/triad_core.cjs`);
3. if it must also run on the Windows seed, check the table in [chapter 15](#cap-15);
4. if it is a language behavior that needs to be fixed, transform it into a case of conformance
   ([chapter 38](#ch-38)).

The same cycle applies to the exercises in chapter 17: first you write the program, then you write it
compare the output with the expected one, and only at the end, if necessary, do you look at the solution.

---
<a id="part-2"></a>

# Part II — Triad-Core step by step (run today)

Each chapter of this part uses only Triad-Core. Examples with **Output:** were
run with the JS interpreter; the conformance case indicated at the end of each chapter is the
regulatory reference to read and pass around.

The structure of the chapters is always the same, so you always know where to look: first
explanation of the construct and the problem it solves, then the syntax and rules, then a
complete example with its output, and finally the conformance case from which the example derives.
When a rule hides a trap, the text explicitly indicates it.

<a id="cap-4"></a>

## 4. Vocabulary

The lexicon is the set of bricks with which a program is written: what a name is, how
writes a number or string, what the runtime considers separator between an instruction and
the other. It is not a list to be learned by heart: it is used to understand why a certain text is read
one way and not another, and therefore why a program that seems right produces a
`parse error`.

The table collects the elements of Triad-Core, with the permitted form and an example for each:

| element | shape | examples |
|---|---|---|
| identifier | letter or `_`, then letters/digits/`_`; a final `!` is allowed | `x`, `sum_2`, `push!` |
| integer | decimal places, `_` as separator; the sign is the unary operator | `42`, `1_000_000`, `-5` |
| boolean | `true`, `false` | |
| nothing | `nothing` | |
| string | `"..."` escaped `\n \t \" \\`; **no interpolation** | `"hello\n"` |
| symbol | `:` followed by a name or | operator `:alice`, `:+` |
| comment | `#` to end of line; `#= ... =#` on multiple lines | |
| separator | newline or `;` | `println(1); println(2)` |

Core operators: `+ - * % ^ == != < <= > >= && || ! = += -= *= -> ?:`.

Reserved words used by Core: `function end if elseif else while let begin return break
continue true false nothing`.

Not part of Core: `Float` literals (`1.5`), `?x` logical variables, `@name` macros,
interpolation `$x`, the `/` operator.

The `->` operator constructs a lambda, while `?` and `:` form the conditional: they are tokens of the
lexicon, but their meaning is the subject of [chapter 7](#chap-7) and of
[chapter 10](#chap-10). Reserved words cannot be used as variable names: the
parser recognizes them as constructions, and an assignment like `let = 3` produces an error of
syntax. The list of reserved words is short because Core is a small language: everything
what is not listed here belongs to Triad-Full, and using it in a Core program is not code
executable today."

Another distinction to keep in mind is that between spaces and separators. Spaces and tabs
they separate tokens but not instructions; the semicolon and carriage return yes. For this
`println(1); println(2)` puts two statements on the same line, while a blank line does not
produces an education. In short, the semicolon has the same role as the carriage return: it is a
separator, not a block end.

```triad
#= comment
   on multiple lines =#
x = 1_000 # line comment
println(x); println("tab:\t|", " quotes: \"", " backslash: \\")
println(:alice, " ", :+)
```

Outputs:

```text
1000
tab: | quotes: " backslash: \
alice +
```
> **Caution.** `"x = $x"` in Core literally prints `x = $x`: interpolation is just
> Triad-Full. In Core you concatenate: `"x = " * string(x)`.
>
> `#= … =#` comments **do not nest** in the JS interpreter: the comment closes on the first one
> `=#` encountered. Don't count on nesting; if you need to comment code that already contains a
> block `#= … =#`, use line comments.

The two warnings have the same root: in Core the vocabulary is deliberately minimal, and what in
another language is «just a detail» here it may not exist. The text of a Core program
it should not be interpreted with the habits of another language: if an escape or a symbol does not
appears in the table, the runtime does not recognize it.

Reference: `conformance/core/cases/arithmetic`, `base_symbols`, `base_strings`.

---

<a id="cap-5"></a>

## 5. Values, types and printing

Triad is a dynamic type language: each value has a specific type, but variables do not.
The same variable can contain an integer and then a string, and the type is checked al
moment of the operation, not of the declaration. From here derives a practical consequence: for
to know what a value contains you have to ask the runtime with `typeof`, and to write code
robust you have to think about the types who may arrive, not just the ones you intended to pass.

The table lists the types that a Core program may encounter:

| type | values ​​| `typeof(v)` |
|---|---|---|
| `Int` | 64-bit signed integers, wrapped arithmetic (two's complement) | `Int` |
| `Bool` | `true`, `false` | `Bool` |
| `String` | immutable sequence of UTF-8 bytes | `String` |
| `Symbol` | `:name`; equal if they have the same name | `Symbol` |
| `List` | heterogeneous list **mutable**, indices of 1 | `List` |
| `Function` | named function, lambda or closure | `Function` |
| `Nothing` | `nothing` | `Nothing` |

`typeof` returns the **type name as symbol**.
The symbol detail is not pedantic: `typeof(1)` is `:Int`, not `"Int"`. Compare the
result with a string doesn't work, and the correct comparison is `typeof(v) == :Int`. In
general, in Triad a type is named with a symbol; the string is used for those who print a message,
not to those who schedule a check-up.

Types are not an ornament: it depends on them what an operation accepts. `Int` is 64-bit
because it must be in a machine word, which is the unit with which the seed works; `String` is
immutable because the language offers no ways to modify it on the spot; `Symbol` is meant for
internal names and identifiers; `List` is mutable because it is the working data structure of the
language; `Nothing` represents the absence of a useful value, not an error.

### 5.1 `print`/`println` printing rules

- concatenate arguments without separators; `println` adds `\n`;
- `Int` to decimal, `Bool` as `true`/`false`, `String` as is, `Nothing` as `nothing`;
- a directly passed `Symbol` is printed **without** `:`; inside a list **with** `:`;
- a `List` is printed as `[a, b]`; strings inside a list are printed without
  quotes.

```triad
xs = [1, :a, "s", true, nothing, [2, 3]]
println(xs)
println(:alice)
println(typeof(1), " ", typeof("s"), " ", typeof(:a), " ", typeof(xs))
println(typeof(nothing), " ", typeof(true), " ", typeof(x -> x))
print("without ", "return")
println()
```
Outputs:

```text
[1, :a, s, true, nothing, [2, 3]]
alice
Int String Symbol List
Nothing Bool Function
without a leader
```

### 5.2 Equality

`==` and `!=` compare numbers, strings and symbols **by value**, lists **element by
element** (also nested), functions **per identity**.

```triad
println([1, [2, [3]]] == [1, [2, [3]]])
println("ab" == "a" * "b", " ", :a == :a, " ", 1 == 2)
```

Outputs:

```text
true
true true false
```

The printed value is not always a representation to be reused as a source. For example,
a symbol passed directly to `println` appears without a colon (`alice`), while inside a
list is shown as `:alice`; Strings inside a list are shown without quotes.
`typeof` is therefore the correct way to test the type of the value, while the visual form of
`println` is primarily for human reading. Similarly, `==` compares the contents for
numbers, strings, symbols and lists, but functions for identity: two functions written with the same
text are therefore not the same function object.

The UTF-8 representation is measured in bytes, not necessarily visible letters. A letter
accented can occupy more bytes; so `length` on a string is not always the count of
characters perceived by a person. In Core there are no character indexing operations:
bootstrap primitives work explicitly on bytes and should only be used for the purpose of
reading and analysis of the source.

Reference: `conformance/core/cases/values`, `nothing_base`, `comparisons`.

---

<a id="cap-6"></a>

## 6. Variables and assignment

A variable, in Triad, is a name tied to a value. You do not declare it or announce its type:
the first assignment creates the link, the subsequent ones update it. This makes the code short,
but it shifts attention to two questions that in a language with declarations would be
automatic: what value is inside a name at this point in the program, and in which environment
that name is visible.

The basic rules are these:

- `name = expr` binds or updates a name; the assignment is an expression and is the value
  assigned.
- `+=`, `-=`, `*=` update an existing variable (the left side is evaluated once).
- Using a name that was never assigned is an execution error (`undefined variable`).
- There are no declarations or types: variables are dynamic.

That the assignment is an expression, and not a statement, is the least obvious rule. It means
that `x = 42` doesn't "just do something": it produces the value `42`, and that value can be used
where the assignment appears. In practice it is needed when an assignment appears inside a block
which returns a value, but is also why you don't find a hard distinction between
«education» and «expression» in the rest of the book. The compound assignment (`+=`, `-=`, `*=`) is
sugar for a read and a write of the same variable, with the guarantee that the side
claim is evaluated only once: if it contains an index, that index is not calculated
twice.

A name used before being assigned is not worth `nothing` and is not worth zero: it is an error that
interrupts the program. It is a deliberate choice, because an implicit "empty" value would hide
a logical error; [chapter 14](#cap-14) explains how this case is recognized and what
you can see it on the terminal.

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

Outputs:

```text
43 50 186
24
```

**Visibility** rules (inside functions, `let`, lambda) are in [chapter 10](#ch-10).

A useful way to follow the program is to keep a small table of current bonds:

| instruction completed | `x` | `y` | `z` |
|---|---:|---:|---:|
| `x = 42` | 42 | — | — |
| `y = x + 8` | 42 | 50 | — |
| `x = x + 1` | 43 | 50 | — |
| `z = (x + y) * 2` | 43 | 50 | 186 |

This table shows why assignment is not a reactive formula: `y` preserves the result
calculated when its line is executed, even after `x` changes. By contrast, a list is
mutable and can be reached by multiple names; modifying one of its elements affects the object
shared, not just on a single name-value association. Chapter 11 shows how to recognize
this difference in the code.

Reference: `conformance/core/cases/variables`.

---

<a id="cap-7"></a>

## 7. Operators and expressions

An expression is a way of combining values to produce another. Triad doesn't have one
strict distinction between expressions and instructions: almost everything is an expression, and so are i
Control constructs have value. To read an expression without ambiguity you need two
information: how "strongly linked" each operator is and in which direction the operators are grouped
of the same level.

### 7.1 Precedence (lowest to highest)

| level | operators | associativity |
|---|---|---|
| 1 | `=` `+=` `-=` `*=` | right |
| 2 | `c ? a : b` | right |
| 3 | `\|\|` | left, short circuit |
| 4 | `&&` | left, short circuit |
| 5 | `==` `!=` `<` `<=` `>` `>=` | left |
| 6 | `+` `-` | left |
| 7 | `*` `%` | left |
| 8 | `^` | **right** |
| 9 | unary `-` `!` | prefixes |
| 10 | `f(args)` `xs[i]` | postfixes |

The table should be read as a ranking: level 1 ties the least, level 10 the most. In
`2 + 3 * 4` level 6 (`+`) and level 7 (`*`) coexist; the tallest one wins, so yes
calculate `3 * 4` first. When two operators are on the same level, associativity decides:
`-` is on the left, so `8 - 3 - 2` is `(8 - 3) - 2` and not `8 - (3 - 2)`. The exception anymore
important is `^`, which is on the right: `2^3^2` means `2^(3^2)` and is equal to 512, not 64.

This table describes Triad-Core. Triad-Full adds more operators and more layers — the
range `a:b`, `in`/`isa`/`is`, the type assertion `e::T`, the lambda `x -> e` — described in
specification (SPEC §2). Those who write only Core can reason with this table; who passes to Full
must consult the complete one.

### 7.2 Integer arithmetic

- `+ - * ^` to `Int` with **64-bit wrap**;
- `%` is the **signed remainder of the dividend** (like Julia's `rem`): `-7 % 3 == -1`;
- `^` with negative exponent is an error; `%` for zero is an error;
- **there is no `/`** in Core (division is Triad-Full).

```triad
println(2 + 3 * 4, " ", (2 + 3) * 4, " ", 2 ^ 3 ^ 2)
println(7 % 3, " ", -7 % 3, " ", 10 % 4)
println(9223372036854775807 + 1)
```

Outputs:

```text
14 20 512
1 -1 2
-9223372036854775808
```

The result `-9223372036854775808` is the visible face of the wrap: the maximum integer plus one not
produces an error, produces the minimum. Triad-Core does not have a "large integer" type or controls
overflow, because it must remain implementable with a few machine instructions; if a calculation
must remain in the domain, the control must be written in the program.

The negative remainder follows the same logic: `-7 % 3` is equal to `-1` because the sign is given by the dividend,
not the divider. This is the behavior of `rem` in Julia and should be kept in mind when using `%` for
calculate cyclic positions: with negative values an explicit correction is needed.

### 7.3 Logic and conditions

- Conditions (`if`, `while`, ternary, `&&`, `||`, `!`) accept **only `Bool`**: there is no
  "truthiness" (`if 1` is an error).
- `&&` and `||` short circuit.
- Comparisons do not chain: `1 < 2 < 3` is an error (compare `Bool < Int`); write
  `1 < 2 && 2 < 3`.

```triad
println(!false, " ", true && false, " ", false || true)
println(1 < 2 && 2 < 3)
x = 3
println(x > 2 ? "large" : "small")
```
Outputs:

```text
true false true
true
big
```

The **short circuit** is observable: with `a && b`, if `a` is `false`, `b` is not evaluated; with
is || b`, if `a` is `true`, `b` is not evaluated. It's not just an optimization: it also prevents
that an unnecessary calculation produces an error. A check like `i <= length(xs) &&
xs[i] > 0` can then check the limit before accessing the list, as long as `i` is an integer
valid. Both operands evaluated must still be Boolean.

Choosing to accept only `Bool` avoids an entire class of ambiguity: in many languages `0`,
`""` and `nothing` are `false' by convention, and every programmer comes with a convention
different. In Triad there are no conventions to remember: a condition is true or false, and
any other type is an error. This is why `1 < 2 < 3` doesn't work: comparisons map to
left, so the parser reads `(1 < 2) < 3`, i.e. a `Bool` compared to an `Int`.

A related trap involves `=` and `==`: `if x = 0` does not compare `x` with zero, assigns zero and
produces `0` as the condition value; the runtime rejects that value because it is not a `Bool`.
The comparison is `==`, and it's worth getting into the habit of always writing it.

The precedence table describes the grouping: `a + b * c` is equivalent to `a + (b * c)`.
When two operators have the same level, associativity comes into play. In case of doubt,
use parentheses: they make the structure you want explicit and help distinguish an error of
grouping from an error in the value of the operands.

Reference: `conformance/core/cases/arithmetic`, `operators`, `integers`, `comparisons`.

---

<a id="cap-8"></a>

## 8. Flow control

Flow control decides which instructions to execute and how many times. Triad has a constraint that
simplifies the mental model: **everything is an expression**, and so are `if`, `while`, `let` and
`begin` have a value (that of the last executed statement, `nothing` if none are executed
none). There are therefore no two separate worlds — instructions that are worthless ed
expressions that are worth something — but only one mechanism, and blocks are expressions that
contain other expressions.

### 8.1 `if` / `elseif` / `else`

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

Outputs:

```text
negative zero positive
yes
```

The `if` evaluates one condition at a time, from first to last, and executes only the branch
corresponding to the first `true` value; if no conditions are true and an `else` exists, execute
that, otherwise it does nothing and is `nothing`. `elseif` is not a sugar for an `else`
which contains another `if`: it is a branch of the same chain, and this avoids accumulating `end` a
every level. The last line of the example shows that an `if` can go to the right of a
assignment: its value is that of the chosen branch, here the symbol `:si`.

Two recurring traps: forgetting the `end` (which closes `if`, `while`, `function` and `let`) and
write `else if` instead of `elseif`: in Core `elseif` is a single branch of the chain, while
`else if` nests a second `if` and requires an extra `end`. The `? :` from chapter 7 is the
compact version of the same scheme, convenient when the two branches are very short expressions.

### 8.2 `while`, `break`, `continue`

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

Outputs:

```text
25
end
```

The `while` is the only Triad-Core loop: there is no `for`, and iterating over a list is written
with a counter and a limit, as [chapter 11](#chap-11) will do. The choice is consistent with the
bootstrap: a single loop construct is easier to implement in machine code, and `for`
can be added later, in S1, without changing the semantics of the `while`.

The classic `while` trap is the order of statements within the body: if `continue`
skips the counter update, the cycle does not end. In the example the counter comes
incremented before each `continue`, and this is no coincidence: the exit condition must be
reachable along all paths of the body. `break` and `continue` always affect the `while`
innermost, therefore in nested cycles they must be read carefully.

### 8.3 `let` and `begin`

`let` introduces a new scope with local bindings; `begin … end` groups statements without
create new bonds.

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

Outputs:

```text
20
10
1
42
```

A `begin … end` block groups instructions and is valid last: it is used to use multiple instructions where
Only one is needed, for example to the right of an assignment. `let` instead opens a new environment,
and the names that bind in there can hide the external ones without touching them: it is the mechanism with
which Triad-Core isolates a computation. The example shows the three bonds of `x` (`20`, `10`, `1`) and then the
value of the `begin` (`42`), which arrives at the assignment like any other value.

The difference between the two constructs is the same as between «group» and «isolate»: use `begin`
when you just want to keep statements together, `let` when a local name needs to stay local.

Reference: `conformance/core/cases/controllo`, `if_else`, `if_elseif`, `if_nested`,
`if_no_else`, `while_loop`, `let_nested`, `begin_block`.

---

<a id="cap-9"></a>

## 9. Functions

A function is a piece of program that you give a name, with parameters, that returns a
value. It is the brick with which everything else is built: in Triad-Core there are no structs either
methods, so the function is also the only way to name an operation and reuse it.

### 9.1 Three ways to define a function

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

Outputs:

```text
16 8 42
```

When `compute(3)` is called, `n` receives `3`; the body calculates `m = 4`, then evaluates `m * 2`
and returns `8` because it is the last expression. The binding `m` belongs to the call and not
automatically becomes a global variable. With the short form, the expression to the right of `=`
it is directly the body. The anonymous function can be given a name, passed as
argument or returned by another function: the name is a useful reference, not a property
necessary of the function value.

### 9.2 `return`, recursion, arity

- `return e` exits the function immediately; `return` alone returns `nothing`.
- A named function is visible in its body: direct recursion works.
- The number of arguments must match the parameters (otherwise `arity mismatch`).

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

Outputs:

```text
big small
3628800 610 6
```

Recursion is understood by following a chain of calls, each with its own parameter. In
`factorial(4)`, for example, the call reduces `n` to 3, 2, and 1; arrived at the base case it returns
1, then the suspended calls resume and multiply the results by 2, 3 and 4. The base case is
therefore a termination condition, not a simple additional example. If the parameter does not
approaches a base case, the function continues to be called; in the Core runtime the execution budget
it is not a language construct, so it is the program's responsibility to avoid recursions
unlimited.

Without `return`, the value of the function is the last expression executed, even when the body
ends inside an `if`. A function is a value bound to a name when the statement of
definition is executed: this is why calling it before its definition line produces
`undefined variable`, not an early termination. There are no default arguments either
variadic: the arity must coincide exactly with the parameters.

### 9.3 Annotation of `!io` effect

In Triad-Full a function that prints must declare `!io` ([chapter 28](#ch-28)). Core
accepts the annotation and ignores it: writing it makes the code ready for Full.

```triad
function show() !io
println("hello from block")
    20 + 22
end
println(show())
```

Outputs:

```text
hello from block
42
```

The annotation is part of the signature in Triad-Full: there a function that prints without `!io` violates the
effects check and the caller gets `Err(:effect)` ([chapter 28](#cap-28)). In Core
the control does not exist, so the annotation is accepted and ignored: the program runs, but
you have no extra guarantee. Writing it right away is still useful, because the code
it will be valid when it changes to Full and because it documents the intention of whoever wrote it.

Reference: `conformance/core/cases/functions`, `simple_functions`, `block_functions`,
`io_functions`, `recursion`, `gcd`, `formula`.

---

<a id="cap-10"></a>

## 10. Lambdas, closures and scopes

A lambda is a function that doesn't need a name: you write it where you need it, and its value is
the function itself. Used whenever you want to pass a behavior to another function —
«apply this transformation to each element», «call this check on each value» —
without inventing a name that you will only use once. A closure is a lambda that remembers
the environment in which it was born; it is the mechanism that makes it possible to construct parametric functions
without resorting to global variables.

### 10.1 Lambda

```triad
double = x -> x * 2
sum = (a, b) -> a + b
apply = f -> f(3)
println(double(5), " ", sum(1, 2), " ", apply(x -> x * x))
```

Outputs:

```text
10 3 9
```

A lambda with a multi-statement body is written with `begin … end` or with `function (…) … end`.
Parameterless lambdas (`() -> …`) are **not** supported: use `function () … end`.

### 10.2 Closures

A lambda captures the environment in which it is created. According to SPEC-CORE §5 the captured variables are
**shared**: mutations are visible.

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

Outputs:

```text
15 105
15
```

> The Windows seed captures **by value** and covers only the last binding of the frame: a
> accumulator as `counter` may not work on seed ([chapter 15](#cap-15)).

The difference between an ordinary function and a closure is the external context that remains
accessible. `add(10)` terminates, but the returned lambda retains the `n = 10` bond; another
calling `add` creates a distinct environment. In the meter, however, closure is not limited to
read `v`: update the shared binding. The JS interpreter follows the Core contract where this
mutation is visible on subsequent calls. The Windows seed has a more limited capture, then
a program that depends on this case must be tested with the reference interpreter and not inferred
by the mere fact that the seed accepts the syntax.

### 10.3 Scope rules

1. `function`, lambda, `let` and `while` introduce environments; a name is visible in the environment
   in which it is linked and in the internal ones (lexical scope).
2. **Within a named function** the assignment binds in the local frame: a function **not
   edit globals**.
3. **Inside a lambda** the assignment to a name already bound outside updates that binding (this is
   which works the accumulator above).
4. **At the top level** the loops update the globals.
5. `let x = …` creates a new `x`; assigning `x` inside the `let` does not affect the outer `x`.

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

Outputs:

```text
2 1
0
```

The tricky point is that rules 2 and 3 seem to contradict each other: a named function does not
modifies a global, a lambda yes. The difference is not capricious, it depends on how they come
captured the environments. The lambda brings with it the reference to the environment in which it was created,
then the assignment finds the external link and updates it. The named function is intended for
be callable on its own, without hidden effects on the names of the global scope: the assignment
it creates a local bond, and the global remains what it was. The example shows this with `x` (which remains
`1`) and with `c` (which remains `0` even after `increment()`).

If you need to communicate a result, there are two paths consistent with this model: giving back
the value with `return`, or put the state in a list, which is mutable and therefore shared
also from a named function ([chapter 11](#chap-11)).

Reference: `conformance/core/cases/lambda`, `closure`, `closures`, `closures_local`,
`closing_in_if`, `let_closing`, `scope`.

---

<a id="cap-11"></a>

## 11. Lists
A list is an ordered sequence of values, reachable by position. In Triad-Core it is the
working data structure: there are no structs or dictionaries, so lists, lists of lists and lists
tagged are how records, environments and trees are represented. Understand how it behaves
a list — which is mutable and whose indices start from 1 — is the passage that opens the whole
Non-trivial programming in Core.

The basic operations are few, and it's worth reading them thinking about what they do to the list
as an object, not just the value they return:

- Literal: `[1, 2, 3]`, `[]`, heterogeneous and nestable.
- Indexes **from 1**: `xs[1]` is the first element; out of range is an error.
- Assignment by index: `xs[i] = v`, also `xs[i] += v`.
- `length(xs)` number of elements; `push!(xs, v)` appends, **mutates** the list and the
  returns.
- Lists are references: two names can indicate the same list.

```triad
xs = [1, 2, 3]
println(xs[1], " ", length(xs))
push!(xs, 4)
xs[1] += 100
println(xs)
alias = xs
push!(aka, 5)
println(xs)
total = 0
i = 1
while i <= length(xs)
    tot += xs[i]
    i += 1
end
println(tot)
```

Outputs:

```text
1 3
[101, 2, 3, 4]
[101, 2, 3, 4, 5]
115
```

Core does not have `map`, `filter`, `reduce`, `sum`, `sort`: they are written in Core (see
[chapter 16](#chap-16)).

> On the Windows seed: lists of integers only, `push!` yes, `xs[i]` and `length(xs)` **no**; there is instead
> the non-standard helper `get(xs, i)` with indices **from 0** ([chapter 15](#chap-15)).

Reference: `conformance/core/cases/liste`, `liste_base`, `liste_push`.

Remember the alias pattern: after `alias = xs`, the names do not identify two copies, but the same one
list. Changing `xs[1]` or adding an element via `alias` modifies an observed object
from both. If you need an independent value, explicitly construct a new list e
you copy the elements with a loop. This behavior is different from an integer variable: assign
`y = x` copies the numeric value and a subsequent reassignment of `x` does not update `y`.

In indexed algorithms, the pair `i = 1` and `i <= length(xs)` expresses the complete range
of Core positions. Before reading `xs[i]`, make sure `i` is within that range;
an out-of-bounds index is an error, not a `nothing` element. The case of conformance `lists`
it just checks the standard operations, while the seed's `get` helper has 0-based and non-0-based indices
should be confused with `xs[i]`.

---

<a id="cap-12"></a>

## 12. Strings, symbols and conversions

Strings and symbols seem like close relatives — they both contain text — but they have roles
different. A string is data that is constructed, concatenated and printed; a symbol is a name
which the language treats as an atomic value, suitable for labels, keys, record tags, and names of
type. Conversions between the two, and between text and numbers, are the bridge needed when a program
reads input, constructs messages, or compares values that arrive as text.

The table summarizes the operations available in Core:

| operation | meaning |
|---|---|
| `a * b` | string concatenation |
| `length(s)` | number of **bytes** UTF-8 (`length("é") == 2`) |
| `string(x)` | textual representation of any value (`string(:a) == "a"`, `string([1, 2]) == "[1, 2]"`) |
| `Int(s)` | string to integer (`Int("42") == 42`); from Bool: `0`/`1` |
| `Symbol(s)` | from string to symbol (`Symbol("hello") == :hello`) |
| `typeof(x)` | type as symbol |

```triad
name = "Triad"
greeting = "hello " * name
println(greeting, " (", length(greeting), " byte)")
println("response: " * string(40 + 2))
println(Int("41") + 1, " ", Symbol("bob"), " ", string(true))
println(:ok == Symbol("ok"))
```

Outputs:

```text
hello Triad (10 bytes)
answer: 42
42 bob true
true
```

To access the individual bytes of a string you need the chapter bootstrap primitives
next.
Three things deserve attention. First, the strings are **immutable**: `greeting = "hello " * name`
it doesn't modify `"hello "`, it constructs a new string. This is consistent with the rest of the
language, where only lists are mutable, and makes passing a string to a function harmless:
whoever receives it cannot alter it. Second, concatenation uses `*` and not `+`: `+` remains
numerical addition, and the choice avoids having to guess the type of operands in an expression
like `a + b`. Third, `length` counts **bytes**, not perceived characters: an accented letter
can take up two bytes, so in Core “length of a string” means “size in bytes
UTF-8", and operations on individual characters are done at byte level with the primitives of
[chapter 13](#chap-13).

`string(x)` is a representation meant for reading, not a promise that the result will
can read back as source: `string(:a)` produces `"a"` (without the colon), and printing a
list is not necessarily valid Triad code. For messages it's fine; to rebuild a
value are explicit conversions. The conversion is also not a validation: `Int("42")`
assumes that the text is in the right format, and what `Int` does to text that is not a
number **is not specified**; the program must check first, not hope for a result
useful.

The final trap concerns symbols. `println(:ok)` prints `ok`, but the value is still a
symbol: `:ok == "ok"` is `false`, and the correct comparison is with `:ok` or with
`Symbol("ok")`. The printed appearance of a value is not the value.

Reference: `conformance/core/cases/strings`, `concat_strings`, `multi_strings`,
`base_symbols`.

---

<a id="cap-13"></a>

## 13. Bootstrap primitives

They are used by S1 to read and analyze Triad source. They are **not** part of Triad-Full
(SPEC-CORE §8): Use them only in bootstrap code.
The name «bootstrap» explains their existence. To write in Triad you need a Triad interpreter
the ability to read a file, look at the individual bytes of that file, and extract pieces of it: they are
operations that the language does not offer with normal types, because strings are immutable and
not indexable. Primitives fill this gap at the lowest possible level, that of gods
bytes, and they stay outside the normal language because a complete string library will arrive
with S1, written in Triad.

The table lists the five primitives and their semantics:

| primitive | semantics |
|---|---|
| `readfile(path)` | file contents as `String`; error if not readable |
| `strlen(s)` | number of bytes |
| `strbyte(s, i)` | bytes (`Int` 0–255) at position `i`, from 1 |
| `strsub(s, a, b)` | substring from bytes `a` to `b` inclusive, 1 |
| `exit(n)` | terminate the process with code `n` |

All positions are **1-based**, like list indices, and `strsub` includes both
extremes: `strsub(s, 1, 3)` returns the first three bytes. `strbyte` returns an integer between 0 and
255, not a character: the program must know which codes it is interested in. An index out
range is an execution error, not a zero byte; this is why those who analyze a source
Always check the limits before reading.

Example: Count the digits of a string and separate the first word.

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

Outputs:

```text
3
abc
```

The first loop counts the digits by comparing the byte to the ASCII codes `48`–`57`: `strbyte` does not
says "this is a character", says "this is the number 48", and the program needs to know what 48 is
the digit `0`. The second loop looks for the first space (code `32`) and then `strsub` extracts the bytes
up to the previous one; note that `end - 1` can be `0` if the string begins with one
space, and it's a case that a real tokenizer needs to handle explicitly.

A program can read itself or another source with `readfile(ARGS[1])`: that's exactly
the first step of a self-hosted interpreter ([chapter 37](#chap-37)). However, it is worth reiterating
the boundary: a program that uses `readfile`, `strlen`, `strbyte`, `strsub` or `exit` is **not** a
Valid Triad-Full program. It is one of the few exceptions to the rule «Core is a subset of
Full", and that's why these primitives appear in a separate chapter instead of between
normal string operations.

---
<a id="cap-14"></a>

## 14. Execution errors

An execution error is a point at which the program can no longer continue: a name that does not
exists, wrong type, index out of range. In Triad-Full the errors are values and yes
they can manage; in Triad-Core no, and the difference is important: here an error **ends the
process with exit code 1** and prints a diagnostic message to stderr. What had already been
printed on stdout remains.

Since there is no way to catch the error, the strategy of a Core program is not to "handle" it but
«don't provoke him»: check limits before access, convert values before using them,
test hypotheses at the beginning of a function. The runtime message is used to understand where it is
because the program stopped.

```triad
println("before")
println(does_not_exist)
println("after")
```

```text
stdout: first
stderr: error: undefined variable does not_exist
exit: 1
```

JS interpreter (stderr) messages and typical causes:

| message | cause |
|---|---|
| `parse error: unexpected token …` / `parse error: expected …` | non-Core syntax (e.g. `1.5`, `/`, `() -> …`, `end` missing) |
| `error: undefined variable NAME` | name never assigned, or function called before being defined |
| `error: not a function` | a value that is not a function is called (`x = 5; x(1)`) |
| `error: arity mismatch` | number of arguments other than parameters |
| `error: index out of range` | `xs[i]` with `i < 1` or `i > length(xs)` |
| `error: + type error` (and similar for `- * % < …`) | operands of wrong type (`1 + "a"`) |
| `error: if cond` / `while cond` / `ternary cond` / `&& expects bool` | non `Bool` condition |
| `error: div by zero` / `negative exponent` | `x % 0`, `2 ^ -1` |
| `error: unknown function NAME` | reserved builtin used in an unsupported way |
| `cannot read file: …` | file non-existent or unreadable |
| `usage: triad FILE [ARG...]` (exit 2) | no files passed |

The Windows seed does not print detailed messages: it exits with code `1` (syntax, variable o
undefined function, arity, read) or `2` (no arguments).

To diagnose an error, separate the **level** from the **program point**. A `parse error`
indicates that the text was not recognized as Core grammar: check the profile first,
brackets and `end`, then the non-Core operators. An `undefined variable` or type error arrives
instead during the evaluation: check the order of the definitions, the environment in which the
name and actual type of the arguments. If the program prints a first line and then fails,
that previous output is not canceled; reproduce minimal case and compare stdout, stderr
and exit code separately.

Do not automatically copy the error text produced by a runtime into a test. The suite
Core compares stdout and exit code, not stderr: the important contract is the class of
behavior declared by the standard. Diagnostic details may change between runtimes,
while a return value or output test must remain repeatable.

### 14.1 Errors as values, in Core

To propagate errors without terminating the process (as S1 will do for Full programs) use
a list convention: `[:Err, kind, msg]`.

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

Outputs:

```text
domain error: division by zero
3
```

The convention `[:Err, kind, msg]` is not a type of the language: it is a protocol between functions,
written with the means that Core offers (lists and symbols). Whoever detects an error builds it with
`err`; whoever receives it must check the tag before reading the fields, and this is why
`is_err` exists. The advantage is that the error travels like any other value: it can be
returned, saved, compared, printed. The limit is that nothing forces a function to
respect the protocol: if it returns a normal list, the tag check fails and the
program continues with the wrong value.

When S1 executes Triad-Full, the language will have true `Err` values
([chapter 24](#chap-24)) and this convention will become superfluous; in the meantime it's the way to do it
living with "error as given" with a runtime that doesn't allow for it.

Note: `&&` shorts, so `v[1]` is only evaluated if `v` is a list of 3 elements.

---

<a id="cap-15"></a>

## 15. JS interpreter and Windows seed: differences

Triad-Core has two implementations, and they are not the same. The JS interpreter is the tool
development: runs wherever Node.js is, is easy to modify and is the reference used for
verify cases of compliance. The Windows seed is the first step of the bootstrap: an interpreter in
machine code, without guest runtime, more limited because it is written by hand. Know what
works on both is essential if a program must also run on the seed, like the code of
S1.

The contract is `conformance/core/`: both runtimes must produce the same goldens. Today
the JS interpreter passes them all, the Windows seed the 33 cases listed in the `seed-windows` job of the
CI. Outside of those cases the two runtimes differ:

| functionality | JS interpreter (`seed/dev/triad_core.cjs`) | seed Windows (`seed.exe`) |
|---|---|---|
| integers, Bool, operators, comparisons, ternary | ✅ | ✅ |
| `if`/`elseif`/`else`, `while`, `let`, `begin` | ✅ | ✅ |
| short form and block functions, recursion | ✅ | ✅ (max 4 parameters) |
| `return`, `break`, `continue` | ✅ | not listed in `seed/windows-x86_64/README.md` |
| lambda | ✅ more parameters | ✅ **only one parameter** |
| closures | shared (visible mutations, SPEC-CORE §5) | **by value**, only the last binding of the frame |
| strings, `*`, `length(s)` | ✅ | ✅ |
| `string(x)` | ✅ all types | only `Int` and `String` |
| symbols, `nothing` | ✅ | ✅ |
| lists | heterogeneous, `xs[i]`, `xs[i] = v`, `length`, `push!` | only integers; construction, printing and `push!` (max 64 elements) |
| `get(xs, i)` | does not exist | helper **non-standard**, indexes **from 0** |
| `-=`, `*=`, `Int`, `Symbol`, `typeof` | ✅ | not listed in the seed README |
| `ARGS`, bootstrap primitives | ✅ | not listed in the seed README |
| printing a function | `#lambda(x)` | `fun` |
| `triad -` (stdin) | ✅ | no |
| error messages | on stderr | exit code only |

The table should be read as a portability map: the left column is the behavior that
a correct Core program can use, the right says what the seed can do today. «Not listed
in the README" doesn't automatically mean "it doesn't work", but it means it's not a behavior
that you can count on without trying it. The most insidious differences are semantic ones, not those
syntax: the seed can accept a lambda and capture it differently, therefore a program
which is executed does not necessarily give the same result.

Rule of thumb: **write code that respects SPEC-CORE and test it with the JS interpreter**; if
must run on the seed (like `selfhost/`), narrow down to the right column and check it on
Windows.

---

<a id="cap-16"></a>

## 16. Triad-Core Idiomatic Patterns

Previous chapters have explained the individual constructs; this brings them together in some
recurring patterns. They are not the only way to write Triad-Core, but they are the ways in which the
language is actually used in the repository, including the S1 code in `selfhost/`.
Recognizing them helps you read other people's code and choose a structure when you don't already have one
one in mind.

### 16.1 Higher-order functions written in Core

Core has no `map`/`filter`/`reduce`: they are written once with `while` and lambda.

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

Outputs:

```text
[1, 4, 9, 16, 25, 36]
[2, 4, 6]
21
```

These three patterns show that higher order functions do not require support
syntactic: a function receiving another function is already possible, and `while` is enough for
scroll through the list. `map` builds a new list, `filter` decides element by element,
`reduce` brings forward an accumulator. They are also the starting point when your program
must transform data without the conveniences of Triad-Full.

### 16.2 Records as tagged lists

Core has no `struct`: a record is a list with a symbol as a tag in the first position.

```triad
point(x, y) = [:Point, x, y]
px(p) = p[2]
py(p) = p[3]
sum_points(a, b) = point(px(a) + px(b), py(a) + py(b))
p = sum_points(point(1, 2), point(10, 20))
println(p, " ", p[1] == :Point)
```

Outputs:

```text
[:Point, 11, 22] true
```

The tag is not decoration: it is the discriminant that allows us to recognize the type of record a
runtime and write functions like `px` and `py` that take a precise form. In Full the same
role will be of the `struct` ([chapter 20](#cap-20)), with the advantage of field control; in
Core the tagged list gives the same structure without that control, and it's up to the programmer
comply with the convention.

### 16.3 Environment as a list of associations

This is the structure used by user agents in `selfhost/`: a flat list `[name1, value1,
name2, value2, …]` (in Core you can also use nested pairs).

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

Outputs:

```text
[:x, 11, :y, 20] 11 nothing
```

The flat list alternates name and value: `env_get` advances two positions, `env_set` updates if
finds the name and otherwise adds to the queue. The `while i < length(env)` (not `<=`) is deliberate:
the last useful position is `length(env) - 1`, because `env[i + 1]` must remain inside the list.
It's the same structure that makes an interpreter written in Core possible: environments are given
like the others, not a hidden mechanism of language.

### 16.4 Shared mutable state

Since a named function cannot reassign a global, the shared state is held in
a (mutable) list or in a closure.

```triad
status = [0]
function tick()
    status[1] += 1
end
tick()
tick()
println(state[1])
```

Outputs:

```text
2
```

The list acts as a shared cell: the named function cannot reassign `state`, but it can
change the object that `state` points to, and the mutation remains visible outside. It's the most way
simple to get mutable state in Core without closures; the closure
([chapter 10](#chap-10)) is the alternative when the state must remain private.

### 16.5 Constructing strings

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

Outputs:

```text
ababab
1, 2, 3
```

Building a string by successive concatenations is correct but expensive: each `*` creates a new one
string, then the loop constructs as many intermediate strings as there are iterations. In Core
there are no better alternatives — there is no support structure — and for the programs of
studying is fine; in a real interpreter it is better to accumulate the pieces in a list and join them together
only once at the end.

### 16.6 Style

The following rules are not aesthetic: they arise from the fact that the code itself may have to
switch to Triad-Full and that the repository is written in Italian.

- Small functions with clear names (in Italian, as in the rest of the repository).
- Explicit base case in every recursion; for large depths prefer `while`.
- Loops with explicit counters (`i = 1 … while i <= length(xs)`).
- Don't use `fact`, `rule`, `solve`, `struct` and other Full keywords as names:
  the code must also remain valid in Triad-Full.
- Write `!io` on functions that print: Core ignores it, Full requires it.

They are conventions, not rules of the language: the runtime does not control them. But a program that
respect remains valid both in Core and in Full, and this is the quality that makes the code of
reusable project in subsequent bootstrap stages.

---

<a id="cap-17"></a>

## 17. Guided exercises

The exercises put chapters 4–16 into practice and, read below, tell a journey: yes
it starts with calculation and recursion, moves on to lists and strings, and ends up with a small tokenizer
and an expression evaluator, that is, with the first two pieces of an interpreter. Each exercise has
a verified solution, hidden in a box: open it only after trying, because the
The point is not to read the solution but to write one that produces the same output.

To check your solution, save it to a file and run it with
`node seed/dev/triad_core.cjs`; then compare the output with that shown in the solution. If
the output matches but the code is different, that's fine: the exercises describe a behavior, not
a single possible writing.

### Exercise 1 — Power and sums
Without using `^`, write `power(b, e)` recursive and `sum_up(n)` (sum `1 + … + n`) with
`while`. Prints `power(3, 13)`, `power(2, 10)` and `sum_up(100)`.
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

Outputs:

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

Outputs:

```text
[2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
```

</details>

### Exercise 3 — Reverse a list

Type `reverse(xs)` which returns a new list with the elements in reverse order.

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

Outputs:

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

Outputs:

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

Outputs:

```text
3
```

</details>

### Exercise 6 — A mini-tokenizer

Transforms `"12+x*3"` into a list of `[type, text]` tokens, with types `:num`, `:id`, `:op`.
It is the first step of an interpreter (see `selfhost/tokenizer.td`).

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
Outputs:

```text
[[:num, 12], [:op, +], [:id, x], [:op, *], [:num, 3]]
```

</details>

### Exercise 7 — Evaluating an expression

Using the tokens from Exercise 6, write a recursive drop-down evaluator for `+` and `*` with
precedence, where the variables come from a list of associations. Tip: keep the
current position in a list `pos = [1]` to be able to update it from functions.

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
Outputs:

```text
42
26
```

</details>

---
<a id="part-3"></a>

# Part III — Triad-Full (the complete standard)

This part describes the language defined by [`SPEC.md`](SPEC.md). **Not yet
executable** from the current runtime: it is used to know the standard, write ready code for
S1 and understand the goldens of `conformance/cases/`. Each chapter indicates the section of SPEC from which
drifts. Outputs marked **Output (golden Full):** come from frozen goldens.

<a id="cap-18"></a>

## 18. Full vocabulary and types (SPEC §1, §4)

Full extends the Core lexicon with:

| element | shape | examples |
|---|---|---|
| identifier | like Core, also non-ASCII letters; final `!` if not followed by `=` | `age`, `push!` |
| logical variable | `?` **attached** to a name | `?x`, `?who` |
| anonymous variable | `?_` (each occurrence is new) | `parent(?x, ?_)` |
| `Float` | `3.14`, `1e-9` | |
| interpolation | `"x = $x"`, `"$(a + b)"`; additional escape `\$` | |
| nested comments | `#= a #= b =# c =#` | |
| macros | `@name(...)` | `@unless(c, e)` |

**Keywords:** `function struct macro end if elseif else for in while let begin return
break continue fact rule solve quote try catch with requires ensures true false nothing isa is`.
Contextual after `solve`: `limit depth steps trace`.

**Colon Rules `:`**
- `1:n`, `xs[2:end]`: `:` attached to a value, without spaces → range;
- `f(:a)`, `x = :a`: `:` not preceded by a value and followed by a name → symbol;
- `:( … )` → quoted code;
- `c ? a : b`: `:` surrounded by spaces → ternary.

**`?` rule:** `?x` attached = logical variable; `? ` with space = ternary.

Newlines close a statement, except inside `( )`, `[ ]`, and `:( )`, and immediately after
binary operator or a `rule` comma.

**Full Types** (in addition to Core types):

| type | values ​​|
|---|---|
| `Int`, `Float` (subtypes of `Number`) | `42`, `3.5` |
| `Expr` | quoted code (`Node`) |
| `Term`, `Cons` | logical terms and patterns list |
| `Solution` | `{who = :dave}` |
| `Err` | error as given |
| `Type` | `typeof(3) == Int` |
| struct user | `Point(3.0, 4.0)` |
| `Any` | supertype of everything, used in signatures |

**Typed variables:**

```triad-full
x::Int = 5
x = 6 # good
x = 5.5 # Err(:type): the name maintains the declared type
y::Float = 1.0
y = 2 # 2.0: Int → Float conversion
```

The bond arises with the declaration and lives in the environment in which the name was created.

---

<a id="cap-19"></a>

## 19. Typed and multiple dispatch functions (SPEC §5)

```triad-full
sq(x) = x * x
area(n::Number) = :number
area(n::Int) = :int

function dist(a::Point, b::Point)::Float
    requires a.x != b.x || a.y != b.y
    sqrt((a.x - b.x)^2 + (a.y - b.y)^2)
end

function +(a::Point, b::Point) # operators are redefinable functions
    Point(a.x + b.x, a.y + b.y)
end
```

Rules:
- the **most specific** method among the applicable ones wins (`area(1) == :int`, `area(1.5) == :number`);
- no applicable methods → `Err(:method)` (or builtin fallback for numeric operators);
- multiple equally specific methods → `Err(:ambiguous)`;
- the `::R` return type is checked at output (with Int→Float conversion);
- functions and operators are values: `reduce(+, xs)`, `map(sq, xs)`;
- lambda type: `function (x::Int) x end` → `f(2.0)` is `Err(:type)`.

To predict which implementation will be called, first check the number of arguments and then
the type of each. With the `area(n::Number)` and `area(n::Int)` methods, the integer `1` is compatible
with both, but `Int` is more specific than `Number`; the `Float` `1.5` is only compatible with the
method on `Number`. In methods with multiple parameters the comparison is per tuple: a signature can be
more specific on the first parameter but more general on the second. If no signature dominates all
others, you can't guess the intent: the result is the `:ambiguous` error, which requires a signature
more specific or a revision of existing signatures.
The control of the return type occurs after the body. This is why `::Float` does not convert them
arguments in advance and does not guarantee that every intermediate operation is valid; requires that the
value produced in the end is convertible or compatible with the declared type. The annotations
parameter and return are therefore distinct parts of the method contract.

---

<a id="cap-20"></a>

## 20. Struct (SPEC §4)

```triad-full
struct Point
    x::Float
    y::Float
end

p = Point(3, 4) # positional constructor, Int → Float
p.x # 3.0
typeof(p) == Point # true
p isa Point # true
```

- Immutable; typed fields.
- Field does not exist → `Err(:field)`; wrong type → `Err(:type)`.
- In Core the same concept is represented with a tagged list ([§16.2](#cap-16)).

A struct provides a **named** record: the type name distinguishes `Point` from another record,
while field names (`x`, `y`) avoid remembering numeric positions. The construction
checks values against field types; accessing `p.x` resolves the field by name. The
structure is immutable in the standard, so the fields describe the state of the created instance and
they do not update with a subsequent assignment. The Core tagged list is more flexible, but
moves these guarantees to the code that constructs, reads, and modifies the record.

---

<a id="cap-21"></a>

## 21. Full flow control: `for`, range, comprehension, `try` (SPEC §2)

```triad-full
s = 0
for i in 1:10
    s += i
end #s == 55

xs = [1, 2, 3]
xs[end] #3
xs[2:end] # [2, 3]
[x^2 for x in 1:4 if x > 2] # [9, 16]
x = 3; x > 2 ? :big : :small # :big

e = try div(1, 0) end # the error becomes the value
r = try div(1, 0) catch err; 0 end # with catch: err is the Err, the value is that of the branch
```

Other expected values (from old tests of the Julia implementation):

```triad-full
x = 2; y = x * 21; y #42
7 / 2 #3.5
"ab" * "cd" # "abcd"
let a = 1, b = a + 1; a + b; end #3
if 1 > 2; :to; elseif 2 > 1; :b; else; :c; end # :b
sq(x) = x * x; map(sq, [1, 2, 3]) # [1, 4, 9]
reduce(+, [1, 2, 3, 4]) #10
filter(x -> x % 2 == 0, 1:6) # [2, 4, 6]
function fact_(n::Int)::Int
    if n <= 1; return 1; end
    n * fact_(n - 1)
end; fact_(10) #3628800
```

`requires c` at the top level is an assertion; `ensures c` is only allowed inside `function`.

In the loop, the range `1:10` represents inclusive integer values from 1 to 10: it is not a list
literal that you have to write by hand. `for` binds each subsequent value to `i`, executes the body
for that association and continues until the end of the iterable. A comprehension combines the
same scheme with the construction of the result: evaluate the filter for each element and add
only the matching expressions are output. The reading order is therefore "iterator, filter,
expression", not a simultaneous evaluation.

`try` instead delimits the point at which an error can be transformed into a result. Without
`catch`, the expression directly returns the `Err`; with `catch err`, the local name `err`
identifies the error and the final value is that of the recovery block. This makes it possible
handle a case without confusing an error with a success value of the same type.

---

<a id="cap-22"></a>

## 22. Logic: facts, rules, `solve` (SPEC §6)

```triad-full
fact parent(:alice, :bob)
fact parent(:alice, :carol)
fact parent(:bob, :dave)

rule grandparent(?x, ?z) :- parent(?x, ?y), parent(?y, ?z)
rule ancestor(?a, ?d) :- parent(?a, ?d)
rule ancestor(?a, ?d) :- parent(?a, ?x), ancestor(?x, ?d)
```

`solve` returns a **list of `Solution`** (it's a value, it doesn't print anything):

```triad-full
sols = solve grandparent(:alice, ?who) limit 5
[s.who for s in sols] # [:dave]
[s.d for s in solve ancestor(:alice, ?d)]
```

- Options: `limit n`, `depth d`, `steps s` (default 1 000 000), `trace`.
- A predicate used as a function is a `Bool`: `grandparent(:alice, :dave)` → `true`;
  can be used in `if`.
- Goal: `p(t…)`, `g1 && g2`, `(g1, g2)`, `g1 || g2`, `!g`/`not(g)`, `a = b` (unification),
  `?y is expr`, comparisons, Triad function returning `Bool`, `true`/`false`.
- Occurs-check active: `solve ?x = f(?x)` has no solutions (does not loop).
- Prolog style lists in patterns: `[?h | ?t]`.
- `vars(s)` returns the names bound in a `Solution`; accessed with `s.name` or `s[:name]`.

To read a rule, separate the **head** from the **body**. In
`grandparent(?x, ?z) :- parent(?x, ?y), parent(?y, ?z)`, the head describes what values the rule
can demonstrate; the body requires two tests in sequence. The engine searches for a `parent` for the first
goal, keep the found binding for `?y`, then use that binding in the second goal. If the second
goal fails, go back to the previous choice and try the next compatible fact: it is the
backtracking. If both succeed, `?z` is returned in the solution.

Variables with the same name in different clauses do not accidentally share theirs
status: each time the rule is used they are renamed. Occurs-check prevents recursive bindings
impossible like `?x = f(?x)`. The `depth` limit cuts branches that are too deep; `steps` limits the
total work; `limit` limits how many solutions are collected. They are different controls, e.g
an empty list obtained within bounds is not equivalent to a search interrupted by `Err(:budget)`.

Examples:

```triad-full
# route with cost
fact edge(:a, :b, 2)
fact edge(:b, :c, 3)
rule path(?x, ?y, ?c) :- edge(?x, ?y, ?c)
rule path(?x, ?y, ?c) :- edge(?x, ?z, ?c1), path(?z, ?y, ?c2), ?c is ?c1 + ?c2
(solve path(:a, :c, ?cost))[1].cost # 5

# append to Prolog
rule app([], ?l, ?l)
rule app([?h | ?t], ?l, [?h | ?r]) :- app(?t, ?l, ?r)
(solve app([1, 2], [3], ?r))[1].r # [1, 2, 3]
length(solve app(?a, ?b, [1, 2, 3])) # 4

# denial for failure
fact parent(:tom, :bob)
people = [:tom, :bob]
leaves = filter(p -> !parent(p, ?_), people) # [:bob]
```

---

<a id="cap-23"></a>

## 23. Deconstruction (SPEC §2)

List pattern with **exact arity**; the brackets around the pattern are mandatory.

```triad-full
(a, b) = [1, 2] # a == 1, b == 2
e = try (a, b) = [1] end # e.kind == :bounds
e = try (a, b) = [1, 2, 3] end # e.kind == :bounds

xs = []
for (k, v) in [[1, 2], [3, 4]]
    push!(xs, k + v)
end # xs == [3, 7]
```

- A non-list or different-arity element in `for` → `Err(:bounds)` or `Err(:type)`.
- `function f((a, b))` defines **two parameters** `a` and `b` (parameters are flattened):
  `f(10, 20) == 30`. To destructure a single list argument use `(a, b) = pair` in the body.
- Recursive nested patterns are not yet provided.

---

<a id="cap-24"></a>

## 24. Errors as data (SPEC §8)

An error is an `Err(kind, msg, data)` value; does not become a host exception unless
is managed at the top level (then the process exits with code 1 and stdout empty for the instruction
failed: this is the case of conformance `error`).

```triad-full
e = try div(1, 0) end # Err(:domain, ...)
e.kind # :domain
e.msg # message
iserr(e) # true
7.0 / 0 # Inf: Float division is not an error
throw(err(:my, "oops", 42))
error("boom") # Err(:error, ...)

describe(e::Err) = string("error ", e.kind, ": ", e.msg)
describe(x::Any) = string("value ", x)
for r in [try div(10, d) end for d in [2, 0, 5]]
println(describe(r))
end
```

Standard Kinds: `:syntax`, `:undef`, `:type`, `:method`, `:ambiguous`, `:field`, `:bounds`,
`:domain`, `:instantiation`, `:contract`, `:budget`, `:effect`, `:host`.

`Err(:syntax)` brings the position (`e.data.line`, `e.data.col`) to `data`.

Error handling separates the failed operation from the point at which the program decides how
react. `try` does not automatically repair the state: it converts the outcome to an `Err` or value
pass that value to the `catch` block. The caller can then choose between showing a message,
try an alternative or propagate the error by returning it. If no `try` intercepts it, the
runtime reports this to the upper level and the process ends with failed code. In this
way the management is explicit, but a mistake does not become a success just because it is represented by
a value.

---

<a id="cap-25"></a>

## 25. Contracts (SPEC §9)

```triad-full
function safe_div(a::Number, b::Number)::Float
    requires b != 0
    ensures abs(result * b - a) < 1e-9
    a/b
end

safe_div(6, 3) # 2.0
e = try safe_div(1, 0) end
e.kind # :contract
e.data.clause # :requires
e.data.fn # :safe_div
```

- `requires c` is checked where it appears (beginning of the body, or at the top level as an assertion).
- `ensures c` is checked on exit, with `result` tied to the return value, after the
  return type control.
- Violation → `Err(:contract, …)` with `data.clause`, `data.fn`, `data.cond`, `data.result`.
- Contracts are **pure**: an effect inside a contract → `Err(:effect)`.
- `ensures` outside `function` → `Err(:syntax)`.

Think of `requires` as the entry condition of the operation and `ensures` as the
exit condition. A precondition specifies what the caller must guarantee; one
postcondition specifies what the function promises when it finishes successfully. The clauses
they do not replace type checking: a function can receive arguments of the right type and
violate a domain precondition anyway, or return a typed value that violates the
postcondition. Since contracts are pure, their evaluation cannot print or modify the
knowledge base: the check must not change the program it is checking.

---

<a id="cap-26"></a>

## 26. Budget (SPEC §10)

```triad-full
r = with budget(steps = 10_000)
    while true end
end
r.kind # :budget — infinite loop becomes a value
```

- One step = one call, one loop iteration, one resolution step.
- Budgets are nested: the tightest applies; only the budget of the current `with` becomes value,
  the external one propagates.
- `solve … steps N` is the budget of a single query.
- Infinite recursion doesn't stack overflow: it ends in `Err(:budget)` (explicit stack).

The budget measures standard-defined units of work, not seconds of CPU and not memory
allocated. It is therefore a reproducible limit on the number of steps of the execution model, not a
general operating system timeout. Use this to potentially limit computations
long, especially logical resolution or a loop that may not finish. The result
`Err(:budget)` is distinct from the valid result body and can be handled with `try` or the
checking the value returned by the `with`.

---

<a id="cap-27"></a>

## 27. Tracks (SPEC §11)

Trace is a **value**, not output.

```triad-full
fib(n::Int) = n < 2 ? n : fib(n - 1) + fib(n - 2)
t = with trace
    fib(3)
end
t.result #2
t.trace # [Event(port=:call, fn=:fib, args=[3], depth=0), …]

t = solve path(:a, :c) trace
t.trace # Byrd ports: :call, :exit, :redo, :fail, :depth
```

Events are records with `port`, `goal`/`fn`, `depth` (and `value`/`args` for functions):
they filter like any value.
The trace records the history of the calculation, not just its result. In a function trace
`call` indicates entry and `exit` indicates exit; `redo` and `fail` also appear in a logical query,
because research can test multiple alternatives. The `result` value remains available next to the
events: you can compare the final result with the path followed. The trace is not a log
automatically printed; the program decides which events to filter, count or present.

---

<a id="cap-28"></a>

## 28. Declared effects (SPEC §12)

The functions are pure by default. Effects: `io` (`println`, `print`) and `state` (`fact`/`rule`
inside a function).

```triad-full
function hello(name::String) !io
    println("hello, ", name)
end

function learn(x) !state
    fact seen($x)
end
```

- Dynamic control: a pure function that calls an `!io` or `println` → `Err(:effect)`.
- The top level allows all effects; lambdas inherit those of the context.
- Macros and contracts are pure; reading the KB (`solve`, predicates) is pure.
- Mutating lists or local variables is not an effect.

The effect declaration is a dynamic check of execution permissions, not an annotation
purely descriptive. The runtime checks the call chain when a function tries
an operation with effect: an `!io` function can print only if the calling context lo
allows. The top level is the most permissive context; a pure function called from there does not become
therefore authorized to print. Listing `!io` in the signature documents the requirement for i
callers and allows the runtime to reject the effect at the point where it would violate the declaration.

---

<a id="cap-29"></a>

## 29. Code as data, uniform tree and macros (SPEC §3, §7)

### 29.1 The uniform tree

The parser produces only one node type, `Node(head, args)`: it is the same tree as the kernel
executes, which `:( … )` returns and which `--tree` prints as an S-expression.

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

Read a table row as a map between **visible syntax** and **representation
internal**. For example `a + b` does not require a special node type for the sum: it is a call
to the name `+` with two arguments. Conversely `&&` becomes a dedicated node because the evaluator
must be able to avoid evaluating the second operand. The shape of the tree is therefore not one
decoration: encodes the decisions that the runtime must make to respect the semantics.

This pattern is also useful when you read an error: if `sexpr` shows a tree that doesn't
corresponds to the expected grouping, the problem arises in parsing; if the tree is correct but the
result is wrong, the problem is more likely in the evaluation. The distinction between form
of the program and value of the program is the foundation of metaprogramming.

### 29.2 Odds, unquotes, eval

```triad-full
c = :(a.x + f(b, 2))
c.head # :call
sexpr(c) # "(call + (dot a x) (call f b 2))"

n = 7
square = :($n * $n)
eval(square) #49
parse("if x > 0; :pos; else; :neg; end") # tree
unparse(parse_program("1:n")) # "1:n"
Expr(:call, :f, 1) # construct a Node
```

### 29.3 Macros
Macros receive code and return code; the expansion is pure and **unhygienic**:
use `gensym()` for fresh names.

```triad-full
macro unless(c, body)
    :(if !$c; $body; end)
end

macro swap(a, b)
    tmp = gensym(:tmp)
    odds
        $tmp = $a
        $a = $b
        $b = $tmp
    end
end

macro time_it(label, e)
    :(begin
        r = $e
        println($label, " -> ", r)
        r
    end)
end

@swap(x, y)
@unless(x < y, println("x is not less than y"))
@time_it("sum", reduce(+, 1:100)) # print "sum -> 5050"
```

To evaluate a macro, compare the source argument to the code it builds. In
`@unless(c, body)`, `c` and `body` arrive as nodes; the macro puts them in an `if` with the
denied condition. The body will only run if the original condition is false, just like
if the programmer had written that code manually. If the macro used a function
Ordinary, the arguments would be calculated before the call and this would not be possible
check if `body` is evaluated. This ability is powerful, but it makes reading more difficult
execution: Explicit expansion and generated temporary names are essential tools for
avoid surprises.

### 29.4 Code generating code

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
eval(p) # 17
```

---

<a id="cap-30"></a>

## 30. Builtin Full (SPEC §13)

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

Of these, Core only provides `+ - * % ^`, comparisons, `&& || !`, `length`, `push!`, indexing,
`*` on strings, `Int`, `string`, `Symbol`, `print`, `println`, `typeof` (SPEC-CORE §7).

---

<a id="cap-31"></a>

## 31. Command line and REPL (SPEC §14)

Regulatory interface of `triad` (today the runtime only implements `triad FILE [ARG...]` and,
in the JS interpreter, `triad -`):

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

- The `.triad`/`.td` extension can be omitted; the shebang `#!` is ignored.
- Exit: `0` success, `1` unhandled error (printed to stderr), `2` invalid use.

**REPL** (Prolog style):

```
triad > 1 + 2
3
triad> ?- ancestor(:tom, ?d)
?d = :bob ;
?d = :liz.
triad> parent(:jim, ?x)
false.
```

- Open blocks wait until `end`.
- `?- goal` (or a goal on a KB predicate) executes a query; after each solution
  `;`/`n`/space = next, `a` = all, enter/`.` = stop.
- Commands: `:load FILE…` (`:l`), `:reload` (`:r`, `make`), `:listing [name|name/arity]`
  (`:ls`), `:tree CODE`, `:reset`, `:help` (`:h`), `:quit` (`:q`, `halt`, Ctrl-D).

---

<a id="cap-32"></a>

## 32. Full examples with golden output

The files are in `examples/` (executable when S1 is ready); the outputs are golden
frozen in `conformance/cases/`.

| files | covers | golden case |
|---|---|---|
| `examples/assaggio.td` | struct, dispatch, logic, macros, contracts | `tasting` |
| `examples/family.td` | facts/rules, recursion, Prolog lists, negation | `family` |
| `examples/garanzie.td` | errors, contracts, budgets, tracks, effects | `core_guarantees` |
| `examples/macro.td` | quote, eval, macro, gensym | `macros` |
| `examples/tour.td` | all paradigms | `tour` |
| `examples/hello_shebang.td` | shebang, `ARGS`, effects | `hello_shebang` |
| `examples/benvenuto.triad` | canonical extension, `Float`, `solve` | — |

### 32.1 `tasting.td`

```triad-full
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

result = solve grandparent(:alice, ?who) limit 5
println("grandchildren: ", result) # [{who = :dave}]
println("first: ", result[1].who) # :dave
```

Output (golden Full) of the complete file:

```text
alice's grandchildren: [{who = :dave}]
first: dave
how many: 1
dist(p, q) = 5.0
dist(p, p) -> Err(:contract, "requires violated in dist: a.x != b.x || a.y != b.y", Info(fn = :dist, clause = :requires, cond = :(a.x != b.x || a.y != b.y)))
type: contract
at least one grandchild
Is Alice Dave's grandmother? true
```

### 32.2 `family.td`

Output (golden Full):

```text
tom's descendants: [:bob, :liz, :ann, :pat, :jim]
ann's brothers: [:pat]
mothers: ["pat -> jim"]
no children: [:liz, :ann, :jim]
over 50: [:tom, :bob]
ways to break [1, 2, 3]:
  [] ++ [1, 2, 3]
  [1] ++ [2, 3]
  [1, 2] ++ [3]
  [1, 2, 3] ++ []
bob's sons: [:ann, :pat]
```

### 32.3 `guarantees.td`

Output (golden Full, shortened track):

```text
2.5
violation: contract — requires violated in safe_div: b != 0
clause: requires, function: safe_div
value 5
domain error: integer division by zero
value 2
value 42
input error: invalid age
caught mine with data [1, 2, 3]
infinite loop -> budget
solve infinite -> budget
fib(3) = 2 in 10 events
calls: [[3], [2], [1], [0], [1]]
  call path(:a, :c) @0
  call edge(:a, :c) @1
  fail edge(:a, :c) @1
  …
Hi, Triad
undeclared effect -> println requires !io but noisy doesn't declare it
learned: [:cat]
```

### 32.4 `macro.td`

Output (golden Full):

```text
code: :(a.x + f(b, 2))
head: call
args: [:+, :(a.x), :(f(b, 2))]
sexpr: (call + (dot a x) (call f b 2))
:(7 * 7) = 49
parse: (if (call > x 0) (block (sym pos)) (block (sym neg)))
unparse: if x > 0; :pos; else; :neg; end
after @swap: x = 2, y = 1
x is not less than y
sum -> 5050
polynomial: :(0 + 1 * x ^ 0 + 2 * x ^ 1 + 3 * x ^ 2)
p(2) = 17
```

### 32.5 Contracts and budgets together

```triad-full
function safe_div(a::Number, b::Number)::Float
    requires b != 0
    ensures abs(result * b - a) < 1e-9
    a/b
end
e = try safe_div(1, 0) end
e.kind # :contract
r = with budget(steps = 1000)
    while true end
end
r.kind # :budget
```

---
<a id="part-4"></a>

# Part IV — The project code

This part explains how the repository is made and how to write (or modify) each type
code it contains.

<a id="cap-33"></a>

## 33. Repository map

| route | language | what it contains |
|---|---|---|
| `SPEC.md`, `SPEC-CORE.md`, `VERSION`, `CHANGELOG.md` | Markdown | the standard (Full and Core), version, history |
| `BOOTSTRAP.md`, `STATUS.md`, `TASK.md`, `plan.md` | Markdown | plan S0→S4, status, backlog and tasks |
| `conformance/` | Triad + Node | golden cases (`cases/` Full, `core/cases/` Core) and runner `run.mjs` |
| `seed/windows-x86_64/` | machine code | `seed.hex` (source), `seed.exe` (decoded), README with layout |
| `seed/linux-x86_64/` | machine code | seed ELF E0 (`seed.hex`, `seed`) |
| `seed/dev/` | Node.js | seed generators (`gen_seed.js`, `gen_seed_linux.js`) and reference interpreter `triad_core.cjs` |
| `selfhost/` | Triad-Core | S1: Triad interpreter written in Triad-Core (in progress) |
| `examples/` | Triad-Full | sample programs of the standard |
| `cli/` | Node.js (ESM) | `triad-cli`: Development CLI (commander, execa, chalk) |
| `bin/` | sh / cmd | launcher `triad`, `triad.cmd`, `triad-cli`, `triad-cli.cmd` |
| `ai/` | Triad + Node | code generation benchmarks for LLM, prompts, tasks with golden |
| `editors/` | JSON / Vim script | VS Code grammar (TextMate), Vim syntax, Linguist voice |
| `docs/` | HTML/CSS/JS | GitHub site Pages and materials published from the repository |
| `obsidian-triad/` | Markdown | Obsidian vault with file index and project graph |
| `.github/workflows/` | YAML | CI (`ci.yml`) and site publishing (`pages.yml`, `static.yml`) |
| `test_*.td`, `min_*.td` (root) | Triad-Core | small probes used during seed development (e.g. `test_get.td` in CI) |

Common conventions:
- documentation, comments and messages are in **Italian**;
- line endings **LF** everywhere except `*.cmd` (CRLF), enforced by `.gitattributes`;
- `.gitignore` excludes `*.out` with the exception `!conformance/**/expected.out`.

---

<a id="cap-34"></a>

## 34. The JS Reference Interpreter (`seed/dev/triad_core.cjs`)

It's a complete Triad-Core interpreter in a single CommonJS file (~1000 lines, no dependencies).
It is the tool with which you check Core conformance on Linux/macOS and it is the fastest way
to understand the semantics of Core by reading code.

### 34.1 Architecture

```
source ──tokenize()──▶ token ──Parser──▶ AST {kind: …} ──evalStmt/evalExpr──▶ effects on stdout
```

1. **Values** (top of file): `{t, v}` objects constructed from `I` (Int, `BigInt` with
   `wrap()` (64-bit), `B`, `S`, `Y` (Symbol), `L` (List), `F` (function: `params`, `body`,
`env`, `isLambda`) and the constant `NOTHING`. Builtins are `{t:'builtin', name}`.
2. **`tokenize(src)`**: produces tokens `SEP` (newline or `;`), `NUM`, `STR`, `SYM`, `IDENT`, `OP`,
   `LPAREN`/`RPAREN`, `LBRACKET`/`RBRACKET`, `COMMA`, `QMARK`, `COLON`, `EOF`. Comments and spaces
   they are discarded here.
3. **`class Parser`**: recursive descent that follows the precedence of [§7.1](#cap-7):
   `parseProgram → parseStmt → parseExpr → parseAssign → parseTernary → … → parsePostfix →
   parsePrimary`, plus `parseBlock(terminators)` for bodies up to `end`/`else`/`elseif`.
   Product nodes: `program`, `funcdef`, `return`, `break`, `continue`, `exprstmt`, `num`,
   `str`, `sym`, `bool`, `nothing`, `var`, `list`, `lambda`, `assign`, `indexassign`,
   `binary`, `unary`, `ternary`, `call`, `index`, `if`, `while`, `let`, `begin`.
4. **Environments**: `makeFrame(parent, owner, isLambda)` creates a frame with a `Map` of bonds;
   `lookup` goes up the chain. `writeVar` implements the scope rules of [§10.3](#cap-10):
   updates a binding of the same "owner" (function), or, inside a lambda, a
   external bond; otherwise create a room.
5. **Evaluation**: `evalStmt`, `evalExpr` → `evalExprBinary` → `evalExprRest` →
   `evalExprBlocks`. `return`, `break`, `continue` are JS exceptions (`ReturnSignal`,
   `BreakSignal`, `ContinueSignal`) captured by the call or `while`.
6. **Builtin**: set `BUILTIN_NAMES` + `callBuiltin(name, args, env)`; print with
   `printValue` (symbols without `:` only at top level) and conversion with `stringOf`.
7. **`main()`**: read file (or stdin with `-`), bind `ARGS`, execute; parsing errors →
   `parse error: …`, execution errors → `error: …`, both with exit 1; no files →
   exit 2.

This flow separates responsibilities that are best diagnosed one at a time. If the token
produced by `tokenize` is wrong, the problem is before the parser; if the parser generates the shape
incorrect, the AST tree does not match the grammar; if the tree is correct but the result is not, the
flaw is in the environment, evaluation or a builtin. A small conformance case
allows you to fix the observed behavior while correcting the responsible level. When
you change syntax or semantics, the test, the interpreter and the specification must remain consistent:
adding a branch to the parser without corresponding evaluation creates a recognized shape but
not executable.

### 34.2 Example: Adding a builtin

Suppose we want to experiment with an `abs` builtin (it is not in Core: it must first be proposed in the
standard, see [§43](#cap-43)). Two changes are needed:

```js
// 1. record the name
const BUILTIN_NAMES = new Set(['print','println','length','push!','Int','string','Symbol',
  'typeof','readfile','strlen','strbyte','strsub','exit','abs']);

// 2. implement it in callBuiltin, before the final throw
  if (name === 'abs') {
    if (args.length !== 1 || args[0].t !== 'int') throw new Error('abs');
    return I(args[0].v < 0n ? -args[0].v : args[0].v);
  }
```

Then: a case in `conformance/core/cases/` ([§38](#cap-38)) and `node conformance/run.mjs`.
Remember that `Int` are `BigInt` (`0n`, `1n`) and that the results must be constructed with
helper (`I`, `B`, `S`, `Y`, `L`, `NOTHING`).

### 34.3 Example: Add syntax

1. if you need a new token, extend `tokenize` (e.g. an operator in `twoOps`);
2. add the precedence level in the `Parser` producing a new `kind`;
3. handle `kind` in `evalExpr*`;
4. update `SPEC-CORE.md` (grammar §4 and semantics §5) and add a Core case.

Rule: JS interpreter must remain **faithful to SPEC-CORE**; do not add extensions that the
seed and S1 should not have.

---

<a id="cap-35"></a>

## 35. The S0 Windows seed and its generator

### 35.1 What is it

`seed/windows-x86_64/seed.exe` is a **25,088 byte** x86-64 PE32+ that only imports
`KERNEL32.dll` (`GetStdHandle`, `GetCommandLineA`, `CreateFileA`, `ReadFile`, `WriteFile`,
`CloseHandle`, `ExitProcess`, `VirtualAlloc`). It doesn't use libc or runtime. The **source** is the dump
`seed.hex` (SHA-256 verified by CI: `3A75A21E2F47D8DC4C88D4BC2580A85D5349BCDF7550E5FFA16E2C0AC7CA8C11`).

The seed **does not build an AST**: it interprets the source text directly, with a cursor
(`rsi`) which iterates through bytes; function bodies and lambdas are pointers to the source they come from
re-executed for each call.

### 35.2 Internal conventions

| register | role |
|---|---|
| `r14` | memory base `VirtualAlloc` (source at `+0`, environment at `+0x10000`, functions at `+0x20000`, heap at `+0x30000`) |
| `r15` | environment variables (24 byte entry: name ptr, len, value) |
| `rbx` | variable counter |
| `r13` | function table (128 byte entry) |
| `r12` | stdout handle |
| `rsi` | cursor in source |

2-bit tagged values: `Int = n << 2`, `false = 1`, `true = 5`, closure `= ptr | 2`, objects
heap (strings `[type][len][byte…]`) with tags 3. The complete layout (PE header, IAT, map
of the labels `parse_program`, `st_if`, `parse_primary`, `env_find`, …) is in
[`seed/windows-x86_64/README.md`](seed/windows-x86_64/README.md).

### 35.3 The `seed/dev/gen_seed.js` generator

Writing thousands of bytes by hand is impractical: the generator is **assembler-lite** in
JavaScript that outputs bytes and resolves labels. File sections:

| section | what |
|---|---|
| `emitter` | `B(...)` outputs bytes, `B32(v)` a dword, `L(name)` defines a label, `reloc`/`je`/`jne`/`jmp`/`callL` outputs jumps with relative patches, `callIat(i)` calls the import `i` |
| instruction helper | functions with the instruction name (`incRsi`, `cmpByteRsiImm('(')`, `testRax`, `leaRdxR14(d)`, …) that output the corresponding x86-64 bytes |
| `PE/data layout` | constants `IAT = 0x4000`, `SEC_RAW`, `HEADERS` |
| `main` | prologue, reading the command line, opening/reading the file |
| `parser` | the heart of the interpreter: statements, expressions, functions, lambdas |
| `environment` | `env_find`, `env_store`, `env_assign` |
| `exit labels` | `fail`, `read_fail`, `open_fail`, `usage` |
| `PE builder` | writes DOS/PE/COFF header, `.text` section, import tables, and hex dump |

Style example (from `main`): Skip the program name on the command line.

```js
cmpByteRsiImm(0x22); jne('skip_plain');   // the path begins with " ?
L('q_loop');
incRsi();
cmpByteRsiImm(0); je('no_arg');           // end of string: no arguments → exit 2
cmpByteRsiImm(0x22); jne('q_loop');
```

### 35.4 Flow to modify the seed

1. edit `seed/dev/gen_seed.js` (add a label, a branch in the dispatcher, …);
2. regenerate the dump: `node seed/dev/gen_seed.js seed/windows-x86_64/seed.hex`
   (or `bin/triad-cli seed generate windows`, which also prints SHA-256);
3. decode on Windows: `certutil -decodehex -f seed\windows-x86_64\seed.hex seed\windows-x86_64\seed.exe`;
4. run the Core cases on the `test_get.td` seed and probe;
5. update **together**: hash in `.github/workflows/ci.yml` (job `seed-windows`, step
   `Hash check`), `seed/windows-x86_64/README.md`, `seed/dev/README.md`, `STATUS.md`; if a
   new Core case passes on the seed, add it to the job's `$cases` array.

Known traps (from `STATUS.md`): code grows and can overlap data (names import now
start from RVA `0x5000`); registers used before being initialized (`pbs_int` bug);
order of arguments on the stack in builtin (`get`) calls. Defender can report the
PE as false positive (CI adds an exclusion).

---

<a id="cap-36"></a>

## 36. The Linux seed (E0)

`seed/linux-x86_64/seed` is a static ELF64 of **173 bytes** generated by
`seed/dev/gen_seed_linux.js`: entry `0x400078`, single `PT_LOAD` R|X, direct syscalls
`write`/`exit`. It prints `Triad seed Linux OK` and exits with 0. This is the first step of the milestone
M7; E1/E2/E3 (read file, interpreter) are to be done, reusing the Windows seed logic with a
different `os_*` layer.

```sh
node seed/dev/gen_seed_linux.js seed/linux-x86_64/seed.hex # verify magic, entry, round-trip
xxd -r -p seed/linux-x86_64/seed.hex seed/linux-x86_64/seed && chmod +x seed/linux-x86_64/seed
./seed/linux-x86_64/seed # Triad seed Linux OK
```

---

<a id="cap-37"></a>

## 37. Self-hosting: S1 in `selfhost/`

S1 is the interpreter of all Triad written in Triad-Core and executed by the seed. Today he is at the stadium
of separate prototypes, each with a small test at the bottom of the file:

| files | what he feels |
|---|---|
| `main.td` | inline environment as flat list `[key, value]`; smoke test in CI (expected `Value: 10`) |
| `value.td` | 2-bit tagged values ​​simulated with integers (`make_int`, `make_bool`, `as_int`) |
| `tokenizer.td` | `next_token(chars, pos)` on a source encoded as a list `[length, byte…]`; token `[type, value, pos]` |
| `parser.td` | recognition of `if`/`end` keywords from ASCII codes |
| `eval.td`, `program.td` | evaluating numeric tokens, identifiers, assignments, and `println` |
| `env.td`, `heap.td`, `ast.td`, `interpreter.td` | environment, bump allocator, and AST stub |

### 37.1 How to write S1 code today

The S1 code must run on the **Windows seed**, so it follows the restrictions in the right column
of [chapter 15](#chap-15):

- use `get(xs, i)` with indices **from 0** instead of `xs[i]` (non-standard: should be replaced with
  Core indexing when the seed supports it);
- lists of integers only: the source strings are represented as lists of ASCII codes,
  with the length in position 0;
- `push!` returns the list: write `env = push!(env, v)`;
- constants for token types (`0` EOF, `1` NUMBER, `2` IDENTIFIER, …) documented in a
  comment at the top of the file;
- functions with at most 4 parameters, one-parameter lambda, no multi-binding capture.

```triad
# S1 style: flat environment and lookup with get (0-based)
env = []
env = push!(env, 1) # key
env = push!(env, 10) # value
if get(env, 0) == 1
  println("Value: " * string(get(env, 1)))
end
```

On Linux these files **do not run** with the JS interpreter (which does not have `get`): they must be tried on
Windows with `seed\windows-x86_64\seed.exe selfhost\main.td`.

### 37.2 Where S1 goes

Tasks S1.3–S1.15 are in [`TASK.md`](TASK.md): tagged values, tokenizer and inline parser,
eval of expressions, `lets`, complete programs, functions and calls, closures, and finally far
turn the conformance to seed+S1. Exercises 6 and 7 of [chapter 17](#chap-17) are one
Standard Core version of the same steps.

---

<a id="cap-38"></a>

## 38. Conformance: Read, write and verify cases

### 38.1 Format

```
conformance/core/cases/<name>/ (or conformance/cases/<name>/ for Full)
  program.td Triad program executed as a script
optional args.txt: one argument per line (ARGS)
  expected.out stdout expected, byte by byte, end of line LF
  expected.golden copy of expected.out (runner fallback)
  expected.code exit code expected
```

A case passes if stdout and exit code match; stderr is not matched. No stdin
nor interactive input.

### 38.2 The `conformance/run.mjs` runner

```sh
node conformance/run.mjs # Core (default conformance/core/cases)
node conformance/run.mjs --cases conformance/cases # Full (only error passes today)
node conformance/run.mjs --skip lists,values # skip cases (default: lists)
node conformance/run.mjs --update # REGENERATE goldens from the current runtime
```

Runtime chosen, in order: variable `TRIAD_SEED`; on Linux/macOS the JS interpreter; on Windows
`bin/triad-native.exe`, then `seed/windows-x86_64/seed.exe`. Example to test the seed with a
explicit path: `TRIAD_SEED=/path/seed node conformance/run.mjs`.

On Linux/macOS the runner uses the JS interpreter and checks all 37 cases. On Windows use seed e
skips the `lists` case by default, because the seed does not implement indexing
standard `xs[i]`: the runner then prints 36 cases. To test the excluded case with the JS interpreter:

```sh
node seed/dev/triad_core.cjs conformance/core/cases/liste/program.td
```

Messages:
- `PASS name` / `FAIL name (exit X, expected Y, stdout N bytes, expected M)`;
- `golden missing`: checkout does not have `expected.out` (usually `git pull` is enough).

A golden is a versioned expectation, not the normative source of semantics. The file
`program.td` defines the input, `args.txt` the arguments, `expected.out` the byte-by-byte output, and
`expected.code` the exit code. The runner compares these results with the chosen runtime;
thus the same case can be performed by multiple interpreters and make the divergences visible. If
runtime behavior is in doubt, first compare the case with SPEC-CORE and then fix the
golden only when the specification confirms the new expected value. The `--update` option copies the
current behavior in the expected results: using it without review would turn a bug into a
claim of correctness.

### 38.3 Add a Core case

1. choose a descriptive name in Italian (`liste_nested`, `stringhe_vuote`, …);
2. write `program.td` using **only** SPEC-CORE §2–§7 (no bootstrap primitives: they must
   also turn on Full);
3. write `expected.out` (with final LF) and `expected.code` (`0`) by hand, reasoning about the
   specify — **don't** blindly generate them with `--update`, otherwise you'll fix runtime bugs;
4. copy `expected.out` to `expected.golden`;
5. `node conformance/run.mjs` should print `PASS <name>`;
6. if the case also passes on the Windows seed, add it to `$cases` in the `seed-windows` job of
   `.github/workflows/ci.yml`.

```sh
mkdir conformance/core/cases/sum_list
cat > conformance/core/cases/somma_lista/program.td <<'TD'
xs = [3, 4, 5]
total = 0
i = 1
while i <= length(xs)
    tot += xs[i]
    i += 1
end
println(tot)
TD
printf '12\n' > conformance/core/cases/sum_list/expected.out
cp conformance/core/cases/somma_lista/expected.out conformance/core/cases/somma_lista/expected.golden
printf '0' > conformance/core/cases/sum_list/expected.code
node conformance/run.mjs | grep sum_list # PASS sum_list
```
Golden Fulls (`conformance/cases/`) are **frozen**: they must not be regenerated until it exists
a Full implementation.

---

<a id="cap-39"></a>

## 39. The `triad-cli` development CLI

### 39.1 Use

| command | what it does |
|---|---|
| `triad-cli status` | Node version, platform, seed found, project root |
| `triad-cli test conformance [-c DIR] [-u]` | run `conformance/run.mjs` (default Core, `--skip liste`) |
| `triad-cli test run` | alias of the conformance Core (the old Julia tests no longer exist) |
| `triad-cli ai verify [-t DIR] [-v]` | runs the `solution.triad` of `ai/tasks/` on the native seed and compares them to the golden |
| `triad-cli seed generate windows\|linux [-o FILE]` | runs the seed generator and prints the SHA-256 dump |
| `triad-cli build standalone` | not available: print a message |

Launching: `node cli/triad-cli.mjs …` (after `cd cli && npm install`), launchers `bin/triad-cli` /
`bin\triad-cli.cmd` (install dependencies on first boot and stop if `npm install`
fails), or the release's standalone executable.

### 39.2 Code structure

```
cli/
  triad-cli.mjs defining commands with commander
  lib/utils.mjs findProjectRoot, findSeed, runSeed, runNode, projectPath, …
  lib/commands/test.mjs handleTestRun, handleTestConformance
  lib/commands/ai.mjs handleAIVerify
  lib/commands/seed.mjs handleSeedGenerate (windows/linux)
  lib/commands/build.mjs handleBuildStandalone
  build-exe.mjs build of the Node SEA executable (esbuild + postject)
```

- `findProjectRoot()` searches for the root (a folder with `conformance/run.mjs` and `seed/`) starting
  from `TRIAD_HOME`, the module folder, the executable folder and the folder
  current.
- Each handler returns `true`/`false`; `triad-cli.mjs` translates this to exit code 0/1.

### 39.3 Add a command

1. create `cli/lib/commands/<name>.mjs` with a function `handle<Name>(options)` that returns
a boolean and use `projectPath`, `runNode`, `runSeed` from `utils.mjs`;
2. register it in `triad-cli.mjs`:

```js
import { handleLint } from './lib/commands/lint.mjs';

program
  .command('lint')
  .description('Check .triad files')
  .option('-v, --verbose', 'Verbose output')
  .action(async (options) => {
    const success = await handleLint(options);
    process.exit(success ? 0 : 1);
  });
```

3. add the line in `status` and document it in [`cli/README.md`](cli/README.md).

### 39.4 Standalone executable

```sh
cd cli && npm install
npm run build:exe # dist/triad-cli for the current platform
node build-exe.mjs path/to/win/node.exe # dist/triad-cli.exe for Windows, also from Linux
```

The binary Node passed determines the platform; must have the same version as the Node that
runs the build.

---

<a id="cap-40"></a>

## 40. AI Benchmark (`ai/`)

Measures how well an LLM writes Triad-Core.

- `ai/SYSTEM_PROMPT.md`: system prompt with the allowed subset (cautious: prohibit lists,
  `string()`, `elseif`, `return` because the seed didn't support them all);
- `ai/tasks/NN_name/`: `task.md` (request), `expected.out`, `solution.triad` (solution
  reference);
- verify: `node cli/triad-cli.mjs ai verify` (or `--tasks ai/tasks/01_sum`): `PASS`/`FAIL`,
  `SKIP` if solution is missing;
- `ai/jev_audit.mjs`, `ai/jev_prompt.md`: separate audit (see `PROMPT_JEV.md`).

Add a task: create `ai/tasks/06_name/` with `task.md` (expected output described with
precision), `expected.out` and a passing reference `solution.triad`. Run the code
generated from a model alone in an isolated environment.

---

<a id="cap-41"></a>

## 41. Editor, launcher and site

- **VS Code** (`editors/vscode/`): `package.json` declares the `triad` language (extensions
  `.triad`, `.td`); `syntaxes/triad.tmLanguage.json` is the TextMate grammar (`source.triad`)
  with `keywords` rules, strings with interpolation, numbers, `:-`, shebang;
`language-configuration.json` handles comments and parentheses. Package:
  `cd editors/vscode && npx @vscode/vsce package`.
- **Vim/Neovim** (`editors/vim/`): `ftdetect/triad.vim` and `syntax/triad.vim`.
- **Linguist** (`editors/linguist/`): `languages.yml` entry ready for a PR to GitHub Linguist.
- If you add a keyword to the standard, update it in **all** grammars.
- **Launcher** (`bin/`): `triad` (POSIX, resolve symlinks and calculate `TRIAD_HOME`) and
  `triad.cmd` (Windows, CRLF file); see [§2.4](#chap-2).
- **Site** (`docs/`): Static HTML published to GitHub Pages; `docs/assets/js/app.js` loads i
  Repository markdown with `marked` (e.g. `docs/pages/tutorial.html` loads this file).
  Index anchors use explicit `<a id="…">` to work there too.

---

<a id="cap-42"></a>

## 42. Continuous integration

`.github/workflows/ci.yml`, on each push and pull request:

| jobs | what checks |
|---|---|
| `conformance-core` (Ubuntu, Node 20) | `node conformance/run.mjs --cases conformance/core/cases --skip liste` with the JS interpreter |
| `seed-windows` | decode `seed.hex`, run 33 Core cases on PE comparing stdout, probe `test_get.td` (expected `20`), smoke test `selfhost/main.td` (expected `Value: 10`), hash of `seed.hex` |
| `seed-linux` | decodes the ELF E0, executes it and checks its hash |

`pages.yml` and `static.yml` publish `docs/` to GitHub Pages with each push to `main`.

The Full profile **is not in CI** because it is not implemented: do not present it as green.

---

<a id="cap-43"></a>

## 43. Contribution flow

Checklist by type of change:

| edit | to do |
|---|---|
| language behavior | update `SPEC.md`/`SPEC-CORE.md`, `CHANGELOG.md` and, if normative, `VERSION`; add or update conformance cases |
| JS interpreter | stay true to SPEC-CORE; `node conformance/run.mjs` green |
| seed Windows | regenerate `seed.hex`, update hash in CI and READMEs, test on Windows |
| S1 (`selfhost/`) | runs on `seed.exe`; if the output of `main.td` changes, update the smoke test in CI |
| CLI | handler returning a boolean; `cli/README.md`; rebuild the executable if needed |
| editor | VS Code and Vim grammars aligned to the keywords of SPEC §1 |
| documentation | `README.md`, `STATUS.md` and repository texts describe what actually runs |

General rules: do not declare working what is not verified; goldens are written
thinking about the specification; new development tools must not enter the S0→S4 chain.

---

<a id="part-5"></a>

# Part V — Reference

<a id="cap-44"></a>

## 44. Triad-Core Grammar (EBNF)

From [`SPEC-CORE.md`](SPEC-CORE.md) §4:

```ebnf
program = { sep } { stmt sep { sep } };
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

The Full grammar (Pratt, 12 levels) is in [`SPEC.md`](SPEC.md) §2.

---

<a id="cap-45"></a>

## 45. Core and Full quick tabs
**Triad-Core** (runs today):

```
assignment: x = e x += e x -= e x *= e xs[i] = e
function: f(a, b) = e
               function f(a, b) ... end (also !io, ignored)
anonymous: x -> e (a, b) -> e function (a) ... end
condition: if c ... elseif c ... else ... end c ? a : b
loop: while c ... end break continue
blocks: let a = 1, b = 2 ... end begin ... end
output: return e
lists: [1, 2] xs[i] (from 1) length(xs) push!(xs, v)
strings: "a" * "b" length(s) string(x)
conversions: Int("42") Symbol("s") typeof(x)
I/O: print(...) println(...) ARGS
bootstrap: readfile(p) strlen(s) strbyte(s, i) strsub(s, a, b) exit(n)
```

**Triad-Full** (specification):

```
structure: struct Name; x::T; y::T; end
function: function f(a::T)::R !eff ... end
fact: fact p(:a, :b)
rule: rule p(?x, ?y) :- q(?x), r(?y)
query: solve p(?x) limit N depth D steps S trace
destructure: (a, b) = [1, 2] for (k, v) in [[1,2],[3,4]] ... end
for loop: for v in it ... end 1:n xs[2:end] [and for x in xs if c]
try/catch: try b catch e h end / try b end
contract: requires c / ensures c
budget: with budget(steps = N) ... end
trace: with trace ... end / solve p trace
effect: function f() !io ... end
macro: macro m(a) ... end / @m(e)
quote: :(expr) / quote ... end / $expr
eval: eval(code)
```

---

<a id="cap-46"></a>

## 46. Debugging and common problems

**Core (today):**

| symptom | probable cause | solution |
|---|---|---|
| `parse error: expected RPAREN` | `1.5`, `/`, `() -> …` or other syntax Full | remains in the Core subset ([§4](#cap-4)) |
| `"x = $x"` printed literally | interpolation is only Full | `"x = " * string(x)` |
| `error: if cond` | non `Bool` condition | use a comparison (`x != 0`) |
| `error: < type error` on `a < b < c` | chained comparisons | `a < b && b < c` |
| a function does not update a global | named functions assign locally | return the value or use a list ([§16.4](#cap-16)) |
| `error: undefined variable f` | function called before definition | define it higher |
| `FAIL … (golden missing …)` | checkout without `expected.out` | `git pull`; check `.gitignore` |
| the seed comes out with 1 without messages | functionality not supported by seed | try the JS interpreter; see [§15](#cap-15) |
| the Windows seed is blocked | antivirus false positive | exclude `seed\windows-x86_64` |

**Full (specification):**

| symptom | probable cause | solution |
|---|---|---|
| `Err(:syntax)` "waited for end of statement" | missing `end` or a | separator add `end` or `;` |
| `Err(:undef)` | undefined name | define it, or use `:name` for a | symbol
| `Err(:method)` / `Err(:ambiguous)` | no method / multiple equally specific methods | add or redraw signatures |
| `Err(:bounds)` in destructuring | arity different from the pattern | exact length lists |
| `Err(:effect)` | `!io`/`!state` called from pure function | declare the effect in the caller |
| `Err(:budget)` in `solve` | too many steps | increase `steps` or use `limit`/`depth` |

Expected Full tools: `triad --tree file`, `sexpr(code)`, `parse`/`unparse`,
`with trace … end`, `solve … trace`, `try … end` with `.kind`/`.msg`/`.data`.

---

<a id="cap-47"></a>

## 47. Glossary

- **S0 / seed**: Triad-Core interpreter in machine code (`seed/`).
- **S1**: All-Triad interpreter written in Triad-Core (`selfhost/`).
- **S2 / S3 / S4**: native compiler, self-hosting, full runtime (see `BOOTSTRAP.md`).
- **E0 / E1 / …**: Linux port stages of the seed (milestone M7).
- **Triad-Core / Triad-Full**: the two compliance profiles.
- **JS interpreter**: `seed/dev/triad_core.cjs`, Core reference for development and CI.
- **Golden**: Committed expected output (`expected.out`, `expected.code`).
- **Bootstrap primitives**: `readfile`, `strlen`, `strbyte`, `strsub`, `exit` (Core only).
- **Tagged list**: Core record of the type `[:Tag, field1, …]`.
- **Node**: the only tree type of Triad Full (`head`, `args`): code and data match.
- **Solution**: `{name = value, …}` returned by `solve`; `s.name` or `s[:name]`.
- **Err**: error as given (`kind`, `msg`, `data`).
- **Traced**: `(result, trace)` returned by `with trace` / `solve … trace`.
- **Occurs-check**: Unification rejects `?x = f(?x)`.
- **Multiple dispatch**: choice of the most specific method among those applicable.
- **Declared effects**: `!io`, `!state` in signature; dynamic control.
- **Contracts**: `requires` (pre) / `ensures` (post, with `result`).
- **Budget**: `with budget(steps = N)`; the exhaustion is `Err(:budget)`.
- **Destructuring**: `(a, b) = list`, `for (k, v) in list_of_lists`.

---

<a id="cap-48"></a>

## 48. Status, known limits and historical fixes

**Status** (details in [`STATUS.md`](STATUS.md)):
- Core: 37/37 cases with the JS interpreter; 33 cases on the Windows seed in CI.
- Full: 12 frozen golden cases, only `error` passes.
- S1: prototypes in `selfhost/`, smoke tests in CI; not yet conformance.
- S2–S4: uninitiated. Seed Linux: E0.
- CLI `triad`: file execution only (REPL and SPEC §14 options to do).

**Limitations of the standard** (SPEC §15): named arguments (except `budget(steps = …)`), struct
mutable, user abstract and parametric types, macros without brackets, multi-nested dimensions
Prolog levels and cuts are not foreseen; Effects control is dynamic.

**Historical fixes** applied to old Julia implementation; the "after" behavior is that
required by SPEC.md for each implementation:

| # | fix | after |
|---|---|---|
| 1 | range round-trip | `unparse(1:n)` produces `"1:n"` (no spaces) |
| 2 | `unparse` of `:destructure`/`:dfor` | have their own branches and make round-trips |
| 3 | `xs[end] = v` | `end` is also bound in writing: `xs[end] = 7` works |
| 4 | unknown escapes | only `\n \t \" \\ \$`; others → `Err(:syntax)` with row and column |
| 5 | nested `#=` comments | the depth is counted; `#=` not closed → `incomplete` error |
| 6 | lambda with typed parameters | `function (x::Int) x end` checks types: `f(2.0)` → `Err(:type)` |

---

<a id="cap-49"></a>

## 49. FAQ

**Do you need Julia?** No. The Julia implementation has been removed; Triad runs on the coded seed
machine (Windows) or on the development JS interpreter.

**Why don't my examples with `struct` or `fact` run?** I'm Triad-Full: the current runtime
runs Triad-Core only. See the profile table at the beginning of the Tutorial.

**`.td` or `.triad`?** `.triad` is canonical; `.td` is accepted as an alias (and is also
the LLVM TableGen extension, so `.triad` is better for external recognition).

**How do I check if a program is "pure" Core?** Run it with the JS interpreter and check
not to use bootstrap primitives if this also applies to Full; for regulatory cases
add it to the Core conformance.

**Why do `selfhost/*.td` fail with JS interpreter?** They use `get(xs, i)`, helper not
Windows seed standard; they must be executed with `seed.exe`.

**Where do I propose a change to the language?** In the standard (`SPEC.md`/`SPEC-CORE.md`) with
entry in `CHANGELOG.md` and conformance cases; then in the implementations.

---

Core examples marked **Output:** are verified by running them with
`node seed/dev/triad_core.cjs`.