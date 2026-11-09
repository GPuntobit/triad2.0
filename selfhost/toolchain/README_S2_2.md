# TRIAD S2.2 — Intermediate Representation (IR) & audited S0 fragments

**State:** experimental, test-gated native bootstrap milestone. The IR parser
and lowerer, two-pass assembler, ELF64 emission and the reconstruction of two
seed fragments are written in **Triad-Core** and executed by the native S0
seed. No JavaScript, Node.js, Python, C compiler or external assembler
participates in the code-generation pipeline.

S2.2 stacks on S2.1 (PR #105). This is **not** a general Triad compiler,
not native seed regeneration and not a claim of self-hosting.

## Two-stage native compilation

```text
small typed i32 IR (.tir)
   |  Triad-Core: ir_s2_2.triad
   v
reviewable S2.1 assembly (.s2asm)
   |  Triad-Core: assembler_s2_1.triad + elf64_exit.triad
   v
Linux ELF64 x86-64, executable with direct syscalls
```

The `lower-ir.sh` and `compile-ir.sh` POSIX wrappers validate input
character ranges, stage source for the S0 seed and transport hex/ELF bytes.
They do **not** choose opcodes, lower expressions, bind symbols or encode
machine instructions. This separation preserves native semantics and makes
the intermediate assembly inspectable.

## First IR vocabulary

Exactly one instruction per line, with no comments, string literals or
inline syntax. `start` is required as the first instruction, cannot repeat,
and each program must contain at least one `exit`. Source tokens are ASCII
lowercase letters, digits and underscores; integers are restricted to
unsigned decimal `0..65535`. An `i32` value occupies the 32-bit EDI
accumulator; native arithmetic uses machine integer semantics.

| IR | Meaning / lowered S2.1 code |
|---|---|
| `start` | IR program start; no bytes |
| `i32_const N` | set accumulator: `mov_edi N` |
| `i32_zero` | clear accumulator: `xor_edi` |
| `i32_add N`, `i32_sub N` | `add_edi N`, `sub_edi N` |
| `i32_inc`, `i32_dec` | `inc_edi`, `dec_edi` |
| `i32_compare N` | compare accumulator, `cmp_edi N` |
| `i32_test_zero` | test accumulator, `test_edi` |
| `br_zero LABEL`, `br_nonzero LABEL` | `jz LABEL`, `jnz LABEL` |
| `label LABEL`, `jump LABEL` | `label LABEL`, `jmp LABEL` |
| `call LABEL`, `return` | `call LABEL`, `ret` |
| `exit` | `mov_eax 60` and `syscall` (Linux `exit`) |

A conditional branch must be preceded by an explicit
`i32_compare` or `i32_test_zero` operation; this is a conservative
**local validation rule**, not a whole-program control-flow graph verifier.
The current IR does **not** represent a general Triad syntax tree, types
other than `i32`, closures, functions with arbitrary arguments, allocations,
or first-class logical predicates.

### Compile and execute

```sh
sh selfhost/toolchain/lower-ir.sh \
  selfhost/toolchain/tests/ir/loop.tir /tmp/loop.s2asm

cat /tmp/loop.s2asm

sh selfhost/toolchain/compile-ir.sh \
  selfhost/toolchain/tests/ir/loop.tir /tmp/triad-loop

/tmp/triad-loop
echo "$?" # 0
```

Example input:

```text
start
i32_const 3
label loop
i32_dec
i32_test_zero
br_nonzero loop
exit
```

Lowering produces an explicit `jnz loop` with a backward signed
displacement resolved by the S2.1 assembler. Other tests cover a forward
`jz`, CALL/RET and zero/inc/dec arithmetic.

## Auditable **real** S0 seed fragments

`s0_fragments_s2_2.triad` reconstructs two specific byte ranges from
**structured, readable fields and x86-64 instruction encoding**:

- File offsets **0..63** (64 bytes): ELF64 header fields including
  architecture, program-header location, entry address `0x400078`, sizes.
- File offsets **120..126** (7 bytes): initial x86-64 instruction
  `sub rsp, 0x1408`, encoded as `48 81 ec 08 14 00 00`.

`tests/run_s2_2.sh` generates the bytes with the native Triad seed,
checks their independent fixtures and then compares them byte-for-byte
with `seed/linux-x86_64/seed.hex` **as actually committed**. This is a
small, independently auditable fragment; the rest of the S0 seed is
unchanged and is **not** rebuilt or claimed to be reproducible from Triad.

The S2.1 backend is also extended with `sub_rsp N`, `add_rsp N`,
`xor_edi`, `inc_edi`, `dec_edi` and `test_edi`.

## Verification and boundaries

```sh
sh selfhost/toolchain/tests/run_s2_2.sh
sh selfhost/toolchain/tests/run_s2_1.sh
sh selfhost/toolchain/tests/run.sh
sh verify.sh
```

The suite tests source/IR-to-assembler text exactly, executes generated
Linux ELF64 binaries with expected exit statuses, verifies stack opcode
goldens, rejects invalid or injected IR, checks deterministic compilation,
and verifies the two S0 fragments against the actual seed.

Caveats:
- Linux x86-64 only; input and output budgets remain finite.
- Only the fixed IR grammar above is accepted. This is **not** the
  language-level parser for Triad 2.0.
- No IR optimizations, SSA, general typed CFG verifier, general register
  allocation, linker relocations across files or Windows PE backend.
- No writable native file API inside S0; filesystem operations are
  delegated to POSIX byte transport.
- The first 71 reconstructed seed bytes do not imply full seed
  source reproducibility. Full reconstruction still requires generating
  the remaining body and metadata from independently reviewed Triad code.

The next milestone should introduce a small Triad source-to-IR front end,
typed CFG validation and an expanded assembler instruction family, while
continuously testing against the native seed byte-for-byte.
