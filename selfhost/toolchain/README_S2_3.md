# TRIAD S2.3 — Native source-to-IR frontend (experimental)

This milestone is the **first compilation path that accepts actual Triad-Core
source** rather than requiring the user to author a `.tir` file. A native
Triad-Core program implements lexical analysis, block parsing, safety checks
and source→IR translation. Previous S2.2 and S2.1 code then turns the
intermediate program into a Linux x86-64 ELF executable.

```text
Triad-Core source (.triad)
  |  frontend_s2_3.triad, executed by the native seed S0
  v
Small i32 IR (.tir)
  |  ir_s2_2.triad, native Triad
  v
S2.1 assembly (.s2asm)
  |  assembler_s2_1.triad + elf64_exit.triad, native Triad
  v
Standalone Linux ELF64
```

Shell scripts provide **only validated file transport**, with no opcode,
symbol binding or language semantics written in shell, Node.js, Python, C or
another host language. Both IR and assembly can be saved and inspected.

## Usage (Linux x86-64)

```sh
sh selfhost/toolchain/lower-triad.sh \
  selfhost/toolchain/tests/frontend/loop.triad /tmp/loop.tir
cat /tmp/loop.tir

sh selfhost/toolchain/compile-triad.sh \
  selfhost/toolchain/tests/frontend/loop.triad /tmp/compiled-loop
/tmp/compiled-loop
echo "$?" # 0

sh selfhost/toolchain/tests/run_s2_3.sh
```

## Precisely supported source subset

**One accumulator variable named `x`** is lowered to an unsigned 32-bit
machine register (`EDI`). The frontend accepts the following Triad-Core
syntax, **not** arbitrary programs accepted by the S0 interpreter:

| Accepted Triad source | Meaning / intermediate form |
|---|---|
| `x = N` | `i32_const N` or `i32_zero` |
| `x += N`, `x -= N` | `i32_add N`, `i32_sub N` |
| `x = x + N`, `x = x - N` | same add/sub operations |
| `while x != N ... end` | test/compare, conditional branch, backward jump |
| `while x == N ... end` | inverted comparison and branch |
| `if x == N ... end` | conditional skip |
| `if x != N ... end` | inverted conditional skip |
| `if ... else ... end` | alternate branch with forward jump |
| `exit(x)` | lower to `exit`, Linux syscall `exit(EDI)` |

Here `N` is decimal **0 through 65535**, no sign or underscores. The
only supported variable is exactly `x`; expressions with multiple
variables, functions, structs, macros, logic facts/rules, strings,
arrays, general arithmetic, for/elseif, break/continue, and println
are **not yet compiled**.

Each statement is on a separate line; source bytes are restricted to
lowercase ASCII, digits, underscores, spaces, `=`, `+`, `-`, `!`,
`(`, `)`, and newline. No comments, CRLF, tabs, semicolons, or quotes
in this first profile. All control blocks may be nested, but source has
a fixed budget of 8 KiB, 240 statements and 100 control constructs.
Each source must initialize `x` before use and end with an
**unconditional top-level `exit(x)`**. An exit inside a branch or loop
is deliberately rejected in this first version to prevent fallthrough.

The frontend uses an immutable flat frame history for nesting,
with an explicit parent index for each `if`, `else` or `while`.
It produces unique labels and branch targets, and S2.1 resolves them
into exact signed `rel32` machine displacements.

### Example

```triad
x = 3
while x != 0
    x -= 1
end
exit(x)
```

Compiles to the following IR:

```text
start
i32_const 3
label wloop1
i32_test_zero
br_zero wend1
i32_sub 1
jump wloop1
label wend1
exit
```

The generated ELF exits with status `0`.

## Verification

```sh
sh selfhost/toolchain/tests/run_s2_3.sh
sh selfhost/toolchain/tests/run_s2_2.sh
sh selfhost/toolchain/tests/run_s2_1.sh
sh selfhost/toolchain/tests/run.sh
sh verify.sh
```

The S2.3 regression suite compares the produced IR **byte-for-byte** with
independently recorded expected files. It compiles all sample sources
to ELF64, then executes both the ELF and the *original source* using
the existing S0 native interpreter, comparing their exit statuses and
stdout. It additionally tests nested blocks, equality/inequality,
repeatable compilation and rejection of unsupported or injected syntax.

This provides evidence of equivalence **only for the tested subset**.
It does not establish full Triad-Core semantic equivalence, correct
behavior on all 32-bit overflow inputs, or any version of S3 self-hosting.

## Next engineering gates

1. Broaden lexing to comments, signed constants, more identifiers,
   expressions and unary operators while preserving an explicit grammar.
2. Introduce multi-variable storage and a typed CFG/definite-assignment
   checker with semantics matching source control-flow and scopes.
3. Add function definitions, calls and a portable native runtime ABI.
4. Expand the x86-64 backend, then extend exact source reproduction of
   the actual seed S0 beyond the first verified ELF/prologue fragments.
5. Bootstrap a self-compiled Triad frontend/compiler and verify fixed-point
   builds before claiming **TRIAD compiles TRIAD** in a fully self-hosted
   sense.

S2.3 is stacked on S2.2 (PR #106), which is stacked on S2.1 (PR #105).
These PRs are kept separate, and `main` remains unchanged until reviewed.
