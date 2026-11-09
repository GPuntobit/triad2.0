# TRIAD S2.6 — Native multi-function compiler and controlled recursion

**Status:** Linux x86-64 experimental compiler subset. Phase one (multiple
functions, nested AST and local scopes) was merged via PR #112 after CI.
The controlled-recursion extension is developed separately and reviewed
in PR #113. No JavaScript, Node.js, Python, C, Rust or external
compiler/assembler is used to implement the compiler semantics.

The native machine-code S0 seed executes Triad-Core implementations of
all source parsing, typed expression AST construction, symbol/arity
validation, lexical local assignment, intermediate representation,
fixed-point CFG checking, signed relative branch encoding and ELF layout.
POSIX scripts only stage, validate and transfer the input/output bytes.
This is **not** a general Triad compiler and **not** S3 self-hosting.

## Compilation path

```text
restricted Triad source (.triad)
   -> frontend_s2_6.triad (+ recursion_s2_6.triad)
      AST, lexical environments, checked signatures and decreasing parameter
   -> typed intermediate representation (.tir)
   -> cfg_s2_6.triad
      per-function must-def fixed point, branch joins, loop backedges
   -> ir_stream_s2_6.triad
      validated i32 ABI and call/return frame lifecycle
   -> S2.1 native assembler, streaming two-pass labels/rel32
   -> Linux ELF64 x86-64
```

```sh
sh selfhost/toolchain/tests/run_s2_6.sh
sh selfhost/toolchain/compile-triad-s2-6.sh \
  selfhost/toolchain/tests/frontend26/chain.triad /tmp/triad-chain
/tmp/triad-chain
echo "$?" # 9
```

## Profile A — Multiple independent functions

S2.6 accepts **two or three** named functions, declared before any
top-level assignment. Each has **one or two `i32` parameters**,
a sequence of simple assignments and an implicit return from the last
initialized variable expression. The main program assigns values,
calls an earlier-defined function and ends with `exit(variable)`.

A function may call only another function whose definition **has
already completed**. This establishes an acyclic call graph for
Profile A: self-recursion, mutual recursion and unresolved calls
are rejected. Calls have the same EDI/ESI arguments and EAX result
convention introduced in S2.5.

### Example: a call chain

```triad
function inc(v)
    delta = v + 2
    delta
end

function combine(a, b)
    x = inc(a)
    total = x + b
    total
end

seed = 4
answer = combine(seed, 3)
exit(answer)
```

Expected native exit status: **9**. The CI executes the ELF64 and
interprets the original source using S0, comparing status and stdout.

### Lexical environments

Every function and `main` has its **own** symbol table and distinct
native stack frame. Thus `temp` inside two different functions is
not the same variable as `temp` in `main`. A function cannot read
an uninitialized local or implicitly access a variable in another
function or at top level. This is function-level lexical isolation;
nested `let` blocks and closure captures are **not implemented**.

Up to seven source i32 locals are allowed per frame. Slots are 4-byte
offsets 0, 4, ..., 24. The 8th slot, offset 28, is reserved as a
compiler-owned temporary for a parenthesized expression. The callee
allocates 40 bytes, preserving 16-byte call-site stack alignment;
the top level allocates 32 bytes.

### Nested AST and expression limits

The typed expression representation supports constants, initialized
variables, direct `a + b` and `a - b`, simple function calls
`f(a)` and `f(a,b)`, plus **one explicitly parenthesized group
on the right**: `a + (b - c)`, `a - (b + c)`, etc.

The nested case is structurally represented as a typed binary node
whose right child is another typed binary node. The lowerer computes
that child in EDI, saves it at `[rsp+28]`, evaluates the left operand,
then performs the outer operation using the saved value. The syntax
does not yet include unbounded expression nesting, multiplication,
operator precedence beyond this declared form or nested call arguments.

Input is line-oriented with lowercase ASCII, digits, spaces and
supported punctuation; no comments, quoted strings, complex types,
structs, general loops in these function bodies or arbitrary Triad-Full
features. The source is bounded to 8 KiB / 42 statements / 3 functions.
The verifier handles up to **45 IR instructions per CFG unit**.

## Profile B — Statically controlled native recursion

Because arbitrary recursion could exhaust the native stack, the
separate `recursion_s2_6.triad` frontend recognizes only the following
**explicitly verified primitive-recursion schema**:

```triad
function count(n)
    if n == 0
        n
    else
        next = n - 1
        value = count(next)
        result = value + 1
        result
    end
end

answer = count(5)
exit(answer)
```

All source names may be changed consistently, but the zero base case,
strict `n - 1` step, self-call with the decreased variable, and
result composition `value + 1` are mandatory. The top-level argument
must be a **decimal literal from 0 to 32**. No signed input,
unbounded input, altered guard, non-decreasing argument or mutual
recursion is accepted in this profile.

The compiler proves termination for this specific schema by
construction: each recursive step decreases a natural integer by
exactly one and the base case handles zero. Therefore the maximum
number of **simultaneously active** callee frames is at most 33,
including the initial call. This is a structural bound for the
admitted program, not a general termination prover.

The generated machine code performs **real x86-64 CALL/RET**
recursion, with a separate 40-byte stack frame for every call.
The recursive and base paths converge on a single common epilogue
that restores `RSP` before RET, transferring the i32 result via EAX.

Tests compare the ELF results at input 0, 5, 12 against direct S0
interpretation; a separate test executes the generated ELF at the
maximum permitted input 32. Golden IR and failure cases protect
against regression in the static guard and decrement proof.

## CFG validation and tests

The verifier in `cfg_s2_6.triad` splits `main` and each function
into an independent native IR unit. The units are scanned and solved
in a **single Triad evaluator frame**, respecting the S0 temporary-list
budget. Every unit has its own root state and must-def bitmask.

For each node, reachable predecessor output masks are intersected;
stores add definite assignments. The analysis iterates until a fixed
point before allowing any reachable load/add/sub/compare of a slot.
Forward branch joins and backward edges are supported in this bounded
IR. Call edges return to the caller continuation while the callee has
its own isolated analysis root. This proves local initialization in
the tested subset, **not** full interprocedural equivalence, function
termination in Profile A or general stack/heap safety.

```sh
sh selfhost/toolchain/tests/run_s2_6.sh
sh selfhost/toolchain/tests/run_s2_5.sh
sh selfhost/toolchain/tests/run_s2_4.sh
sh selfhost/toolchain/tests/run_s2_3.sh
sh selfhost/toolchain/tests/run_s2_2.sh
sh selfhost/toolchain/tests/run_s2_1.sh
sh selfhost/toolchain/tests/run.sh
sh verify.sh
```

The S2.6 test suite covers five multi-function and nested expression
programs, the controlled recursion cases, exact IR goldens, source
vs executable result comparisons, deterministic builds, invalid
function call graphs, scope access and arity failures, CFG local
initialization errors, unsafe recursive shapes and out-of-range input.
The workflow also gates all S2.0–S2.5 native and no-JavaScript tests.

## Next technical milestones

A production Triad compiler will still need general recursive AST
parsing and precedence, more function arguments, general recursion
analysis or explicit runtime stack guards, proper lexical `let`
scopes and closures, larger CFGs with interprocedural analyses,
heap memory management, register allocation, and a wider native ABI.

**Most importantly:** full S0 reproduction and reproducible
self-compilation of the compiler (fixed-point S3 bootstrap) have
**not** been achieved by S2.6.
