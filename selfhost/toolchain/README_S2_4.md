# TRIAD S2.4 — Multi-variable i32 frontend and structured CFG checks

**Status:** experimental, native Triad-Core subset. Source, typed variable
analysis, structured control-flow validation, IR lowering, x86-64 encoding and
ELF generation are all written in **Triad**, running on the S0 machine-code
seed. POSIX shell stages validated text and output bytes; it does not decide
which registers, instructions, variables or branches to use. No JavaScript,
Node.js, Python or C compiler is introduced.

This milestone builds on S2.3, S2.2 and S2.1. It is **not yet a general
Triad compiler**, a true general-purpose typed CFG optimizer or a self-hosting
compiler.

## Native compilation path

```text
Multi-variable Triad-Core subset (.triad)
  -> frontend_s2_4.triad (symbol table, inferred i32, definite assignment,
                          structured control flow / branch joins)
  -> S2.4 extended i32 IR (.tir, with stack frame and stack slots)
  -> ir_s2_2.triad (IR -> S2.1 assembly)
  -> assembler_s2_1.triad (opcode/rel32/stack addressing -> ELF64)
  -> Linux x86-64 standalone executable
```

### Usage

```sh
sh selfhost/toolchain/lower-triad-s2-4.sh \
  selfhost/toolchain/tests/frontend24/loop.triad /tmp/trid-loop.tir
cat /tmp/trid-loop.tir

sh selfhost/toolchain/compile-triad-s2-4.sh \
  selfhost/toolchain/tests/frontend24/loop.triad /tmp/trid-loop

/tmp/trid-loop
echo "$?"   # 12

sh selfhost/toolchain/tests/run_s2_4.sh
```

## Accepted source syntax and semantics

The admitted language uses up to **eight variables** with lowercase
ASCII identifiers such as `counter`, `step` and `total`.
A variable's **inferred type is i32** on first assignment; a condition
comparison has type **Bool**. No other type can be created or implicitly
converted. Only integer immediate literals 0..65535 are accepted.

| Source form | Behavior |
|---|---|
| `name = N` | store immediate i32 into a variable |
| `name = other` | copy initialized i32 variable |
| `name = a + b`, `name = a - b` | i32 addition/subtraction; `a` and `b` may be initialized variables or supported immediates |
| `name += other`, `name -= other` | in-place i32 arithmetic; immediate or initialized variable |
| `if name == other ... end` | conditional block, comparing i32 values |
| `if name != other ... else ... end` | explicit two-branch CFG join |
| `while name == other ... end` or `!=` | loop with condition re-evaluated from the stored slots each iteration |
| `exit(name)` | compulsory final top-level Linux exit syscall |

Only `==` and `!=` conditions are accepted. The frontend supports
nested `while` and `if/else` blocks, but no general expressions,
short-circuit boolean expressions, signed literals, function declarations,
structs, strings, arrays, `break`, `continue`, `elseif`, comments
or general logical rules.

The source must contain one terminal top-level `exit(name)` and no
statements afterward; the exited value must be definitely initialized.
Source bytes are restricted to lowercase ASCII, digits, underscores,
spaces, newlines, `=`, `+`, `-`, `!` and parentheses. This is a
**subset of valid Triad-Core programs**, not a replacement for its parser.

## Inferred types and definite-assignment flow

The frontend stores a deterministic symbol table
`[identifier, stack_offset, ...]` with **i32** entries. It assigns
slots on the first assignment to each variable and separately tracks
which entries are **definitely assigned on every feasible path** through
the current structured region.

Each `if`/`else`/`while` has a typed frame with an ID, parent
index and an initialization mask:

- At an `if` without `else`, definite initialization after the block
  is the pre-`if` initialization set, since the body may be skipped.
- At a matching `if/else`, the post-join set is the **intersection**
  of both branch exit sets, with the original set restored at the start
  of the alternate branch.
- At a `while` exit, the post-loop set is the pre-loop set, because
  the loop may execute **zero times**.
- Reads in a condition, expression, compound update or `exit` require
  the corresponding i32 variable to be definitely initialized.

This is **structured CFG dataflow with conservative joins** for a single
terminal-exit function. It is not a general graph worklist algorithm,
SSA, arbitrary loop fixed-point analysis or support for unstructured
`goto`/multi-exit control flow. Invalid code is rejected instead of
being compiled with an uninitialized stack read.

For example, this source **must be rejected**:

```triad
flag = 1
if flag == 1
    result = 7
end
exit(result)
```

The assignment to `result` may not execute. With an `else` assigning
`result` on both paths, the use after `end` is accepted.

## Native memory: local stack slots

S2.4 adds the following IR operations:

| IR | S2.1 assembler | Machine behavior |
|---|---|---|
| `i32_frame 32` | `sub_rsp 32` | allocate a fixed 32-byte local frame |
| `i32_load N` | `load_edi_rsp N` | load 32-bit value from `[rsp+N]` to EDI |
| `i32_store N` | `store_edi_rsp N` | write EDI to `[rsp+N]` |
| `i32_add_slot N` | `add_edi_rsp N` | add another local i32 |
| `i32_sub_slot N` | `sub_edi_rsp N` | subtract another local i32 |
| `i32_compare_slot N` | `cmp_edi_rsp N` | compare i32 local operands and set flags |

Valid offsets are **0,4,8,...,28**, always aligned. The frame is fixed
to 32 bytes; the native lowerer rejects missing/duplicate frame
declarations and out-of-bounds or misaligned slot accesses.

This is true **machine memory access on the native stack**, not
simulated variables in a host language or a heap allocator. There is
**no heap, garbage collector, general allocator or closure environment**
yet. The entrypoint ends in `syscall exit`, so no return through the
stack is needed. Stack arithmetic and memory semantics use 32-bit x86
integers; this differs from S0's 64-bit `Int` on overflow. Differential
semantics are claimed only for tested programs whose values stay
within the compatible positive range.

## Tests and compatibility

```sh
sh selfhost/toolchain/tests/run_s2_4.sh
sh selfhost/toolchain/tests/run_s2_3.sh
sh selfhost/toolchain/tests/run_s2_2.sh
sh selfhost/toolchain/tests/run_s2_1.sh
sh selfhost/toolchain/tests/run.sh
sh verify.sh
```

The S2.4 tests include:
- golden byte-exact source→IR records for multi-variable arithmetic,
  a loop, a branch join and variable comparison;
- executable ELF and S0 interpretation comparison for eight source
  programs, including **eight distinct stack slots**;
- a byte-exact x86 memory-opcode fixture plus real Linux execution;
- reproducible output across independent builds;
- rejected uninitialized reads, missing branches, zero-iteration
  loop assignments, invalid types, over-budget variables, invalid
  literals, unsupported syntax and out-of-bounds IR accesses;
- unmodified regressions for all previous S2.0–S2.3 toolchains.

## Next phases

1. General expression parsing and a typed AST with distinct `i32`
   and `Bool` values.
2. A general CFG with explicit successor/predecessor edges, a worklist
   definite-assignment solver and correct loop fixed-point semantics.
3. Multiple functions, calling conventions, parameter passing, stack
   frame lifetime, spill/reload and lexical scopes.
4. Heap allocation with an independently specified ownership/GC policy.
5. Progressive verified source reconstruction of the actual S0 seed,
   then reproducible self-compilation of the compiler itself.

S2.4 is developed on a branch stacked over the already implemented
S2.3/S2.2 lineage. Do not claim complete S2/S3 self-hosting from
these limited native source-to-ELF tests.
