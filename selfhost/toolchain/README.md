# Triad-native toolchain — S2.0 machine-code emission experiment

This folder is the **first narrow step** toward a source-maintainable
self-hosted Triad compiler. The actual emitter and instruction encodings are
written in **Triad-Core** and run under the existing native x86-64 seed.
There is no JavaScript/Node, Python, C, Rust, or external assembler involved
in generating the machine-code bytes.

## S2.6 — Multi-function typed AST and controlled native recursion

The experimental [`README_S2_6.md`](README_S2_6.md) documents two
native Triad-Core compiler profiles: up to three acyclic functions with
lexically isolated stack locals and one RHS-nested arithmetic expression;
and a **strictly controlled primitive-recursion** form with a decreasing
natural parameter and initial input limited to 0..32.

Each function has a separate must-def CFG fixed-point check. Native
`CALL`/`RET`, EDI/ESI parameters, EAX results and balanced stack frames
are tested by executing generated Linux x86-64 ELF binaries.

```sh
sh selfhost/toolchain/tests/run_s2_6.sh
sh selfhost/toolchain/compile-triad-s2-6.sh selfhost/toolchain/tests/frontend26/rec_five.triad /tmp/triad-rec
```

This is **not** arbitrary recursion, full lexical closure support, a
Triad-Full compiler, full S0 seed reproduction, or S3 self-hosting.

## S2.5 — Native typed AST, CFG fixed point and i32 function ABI

[`README_S2_5.md`](README_S2_5.md) describes the S2.5 restricted
function compiler. In Triad-Core it builds typed AST expression records,
compiles one/two `i32` parameters and return values using SysV AMD64
register conventions, and runs a separate Triad-native iterative
**CFG definite-assignment verifier** before producing an ELF64 binary.

```sh
sh selfhost/toolchain/tests/run_s2_5.sh
sh selfhost/toolchain/compile-triad-s2-5.sh selfhost/toolchain/tests/frontend25/add.triad /tmp/triad-add
```

The S2.5 functions profile is intentionally narrow, separately tested
from the S2.4 multi-variable `if/while` profile. Neither implements
arbitrary Triad source, the complete self-hosted compiler or the
regeneration of the full S0 seed.

## S2.4 — Native multi-variable stack and structured control flow

[`README_S2_4.md`](README_S2_4.md) documents up to eight `i32`
locals, a 32-byte native stack frame and the streaming source/IR/
assembler chain needed for larger source programs.

## S2.3 — first Triad source-to-IR frontend

The experimental frontend in [`README_S2_3.md`](README_S2_3.md)
compiles a **restricted but actual Triad-Core source subset** (one integer
variable, assignments, nested `while`/`if`/`else`, `exit(x)`)
to native IR, then uses S2.2 and S2.1 to produce Linux ELF64. The tests
compare executable behavior against the existing native S0 interpreter.

```sh
sh selfhost/toolchain/tests/run_s2_3.sh
```

This is the first source-level compiler path, **not** full Triad-Core
compatibility or compiler self-hosting.

## S2.2 — native i32 IR lowering & auditable S0 seed fragments

The next experiment is documented in [`README_S2_2.md`](README_S2_2.md):
a constrained typed `i32` intermediate representation is lowered **by
Triad-Core** into readable S2.1 assembly, then assembled to a native ELF64.
The test suite also reconstructs and checks the *actual first 64 ELF
header bytes* and *first seven machine-code bytes* from the committed
S0 seed, without claiming the full seed is reproducible yet.

```sh
sh selfhost/toolchain/tests/run_s2_2.sh
```

## S2.1 — assembler nativo a due passaggi

La fase successiva è ora disponibile nel prototipo
[`README_S2_1.md`](README_S2_1.md): un assembler dichiarativo scritto
in Triad-Core con etichette, simboli, salti relativi `rel32` in avanti
e all'indietro, `call`/`ret` e indirizzi RIP-relative per dati.
Il programma genera un ELF64 di dimensioni variabili.

```sh
sh selfhost/toolchain/tests/run_s2_1.sh
sh selfhost/toolchain/assemble.sh selfhost/toolchain/tests/fixtures/forward.s2asm /tmp/triad-forward
```

S2.1 non ricostruisce ancora il seed S0 e non è un compilatore per
programmi arbitrari scritti in Triad.

## What is implemented

`elf64_exit.triad` creates a complete Linux x86-64 **ELF64 ET_EXEC**
image (ELF header, executable PT_LOAD, entry point, native code) represented
as a lowercase hexadecimal byte stream. Its small instruction encoder
supports `mov edi, imm32`, `mov eax, imm32` and `syscall`.
The emitted program calls Linux `exit(status)`, for any status in 0..255.

The POSIX wrapper concatenates the Triad emitter with one chosen numeric
entry invocation and invokes `bin/triad`. `xxd -r -p` only converts
the hex digits emitted by Triad into raw bytes; it does not select
instructions or compile source code.

## Linux x86-64 usage

```sh
sh selfhost/toolchain/build-elf-exit.sh 42 /tmp/triad-exit-42
/tmp/triad-exit-42
echo "$?"                 # 42
sh selfhost/toolchain/tests/run.sh
```

The test requires the output to match the independently recorded 132-byte
ELF64 golden exactly, then **executes the generated binary on Linux** with
status 42, 0 and 255. Out-of-range statuses are rejected.

## Non-goals and open work

**This is not yet a Triad compiler or a replacement S0 seed generator.**
It compiles only a fixed, reviewed machine-code template with a parameterized
exit status; it does not parse arbitrary Triad source, generate the S0
interpreter, support Windows PE, relocate symbols, provide a linker, or
compile itself. The canonical seed hex files remain unchanged.

The larger roadmap is:

1. Establish a native Triad opcode assembler/relocation test corpus for
   x86-64, with independent byte-level golden fixtures.
2. Implement a small **Triad input IR** and code generator, including labels,
   jumps, symbol tables, and deterministic code layout.
3. Reproduce a documented portion of the S0 interpreter's seed bytes from
   auditable Triad source, retaining independent integrity checks.
4. Extend the generator to full Linux ELF and Windows PE seeds, verify
   byte-exact output and run Core/S1 conformance.
5. Implement the source-to-native Triad compiler S2 and verify that it
   compiles its own source (S3 self-hosting fixed point).

Do not claim completed self-hosting before item 5 passes independently.
The HTML site, conformance, and existing S0/S1 remain unaffected.
