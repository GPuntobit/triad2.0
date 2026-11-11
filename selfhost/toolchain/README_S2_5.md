# TRIAD S2.5 — Bounded Typed AST, Fixed-Point CFG and Native Function ABI

**Status: experimental, Linux x86-64, no JavaScript.** This is a narrow
native compiler milestone, **not** full Triad-Core or Triad-Full self-hosting.

The source parser, typed expression AST, control-flow proof, IR lowering,
instruction selection, labels and ELF code layout are all **written in Triad**
and run on the committed native S0 seed. POSIX shell only validates, stages,
and transports bytes; `xxd` decodes Triad-emitted hexadecimal machine code.
No Node.js, JavaScript, Python, C compiler or external assembler participates.

## Compilation stages

```text
Triad-Core i32 function source
   | frontend_s2_5.triad: typed expression AST and symbol/parameter checks
   v
S2.5 typed i32 IR
   | cfg_s2_5.triad: reachability + must-def fixed point across all edges
   v
Verified IR
   | ir_stream_s2_5.triad: native ABI, frame lifetime and call lowering
   v
S2.1 native assembly (x86-64)
   | assembler_stream_s2_4.triad: two-pass instruction/symbol encoding
   v
Linux ELF64 standalone executable
```

```sh
sh selfhost/toolchain/tests/run_s2_5.sh

sh selfhost/toolchain/lower-triad-s2-5.sh \
  selfhost/toolchain/tests/frontend25/add.triad /tmp/add.tir

sh selfhost/toolchain/verify-cfg-s2-5.sh /tmp/add.tir

sh selfhost/toolchain/compile-triad-s2-5.sh \
  selfhost/toolchain/tests/frontend25/add.triad /tmp/triad-add

/tmp/triad-add
echo "$?"   # 12
```

## The source subset (the precise contract)

S2.5 accepts exactly **one named function definition before the top-level
program**, with **one or two `i32` parameters**, one or more local
assignments and an explicit `return local` (the parameter itself may
be returned). The function ends with `end`.

The top level accepts assignments, function-call expressions and a
**final `exit(local)`**; it must call that function at least once.
A source file may contain up to 35 nonempty statements, 8 local
variables in each stack frame, and 8,000 source bytes. Each source
line is tokenized separately to respect S0 resource bounds.

Assignments are `name = atom` or `name = atom + atom` /
`name = atom - atom`, where an atom is a definitely initialized
variable or a nonnegative decimal integer from 0 through 65535.
On the right side, `name = function_name(atom)` and
`name = function_name(atom, atom)` are supported according to the
declared arity. Calls are allowed in top-level assignments only.
The result expression has inferred type **i32**; this same type is
checked for arithmetic and parameters.

**Not supported:** multiple function definitions, recursion, nested
function calls, optional or named parameters, default arguments,
variadic functions, function pointers, function closures, control
flow inside these S2.5 functions, nested expression trees,
lexically scoped lets, casts, heap allocations, strings, structs,
arrays, or the Triad logical solver. The full S2.4 frontend remains
available separately for `if/else` and `while`. This S2.5 frontend
is an additional, restricted **functions profile**, not a replacement.

### Typed AST and source examples

The AST representation for each admitted expression is a native Triad
record of five fields:

```text
[tag, type, first, operator-or-arg1, second-or-arg2]

["const",  "i32", "7",    "",  ""]
["var",    "i32", "left", "",  ""]
["binary", "i32", "left", "+", "right"]
["call",   "i32", "add",  "a", "b"]
```

Unlike raw textual substitution, the AST is parsed and checked by Triad
before emission; invalid ASTs and uninitialized reads fail before
codegen.

A complete, supported source program is:

```triad
function add(left, right)
    total = left + right
    return total
end
a = 5
b = 7
answer = add(a, b)
exit(answer)
```

The generated ELF returns exit status `12`. The native source interpreter
and generated ELF are both executed and compared in the regression suite.

## Native calling convention

S2.5 uses a carefully restricted **SysV AMD64-compatible i32 subset**:

- First `i32` parameter: `EDI`; second: `ESI`.
- `i32` return: `EAX`. The caller copies the return value into `EDI`
  before storing it into its local frame.
- The ELF entrypoint owns a fixed **32-byte** local frame. The called
  function subtracts **40 bytes** from `RSP`, keeping it 16-byte aligned
  inside the function after the 8-byte return address pushed by CALL.
- Parameters are stored to separate 4-byte locals at `[rsp+0]` and
  `[rsp+4]`; subsequent locals use offsets 8, 12, ..., 28.
- Before returning, the function moves the `i32` result into `EAX`,
  releases all **40 bytes** of its frame, and executes RET.
- The subset uses only caller-saved registers and does not require
  callee-saved register preservation. No external C ABI interoperation
  or varargs are claimed.

The instruction backend now encodes `mov esi, imm32`,
`mov eax, edi`, `mov edi, eax`, and 32-bit `ESI`
load/store via `[rsp+disp8]` with independent machine-byte goldens.

## Genuine CFG fixed-point verifier

`cfg_s2_5.triad` is an **independent analysis of the emitted typed IR**.
It builds a bounded graph of up to 48 IR instructions and resolves
`label`, `jump`, `br_zero`, `br_nonzero` edges. Every nonterminal
ordinary instruction has a fallthrough edge; unconditional jumps,
`exit` and `return` have no fallthrough.

A call is a fallthrough to the caller continuation; the named
function entry is analyzed as a **second root** with fresh local state.
This models stack-slot definite assignment, *not* call side effects or
interprocedural alias analysis.

For each reachable node, a bit mask represents definitely initialized
4-byte i32 local slots. The transfer function marks stores. For a CFG
join, the input set is the **intersection** of reachable predecessors'
output masks. A monotone iterative solver recomputes masks until
a fixed point; it rejects an over-budget/nonconverging graph. After
convergence, all reachable load, arithmetic or comparison operations
must read only definitely initialized slots.

This differs from the earlier structured one-pass S2.4 analysis:
the S2.5 verifier handles explicit **backedges and arbitrary forward
join points** in its supported IR subset. Tests include valid backward
loops and two-branch joins and reject a load initialized on only
one possible path. It is a must-initialization analysis; it does not
prove loop termination, memory lifetime, stack safety across arbitrary
calls, or program equivalence for all i32 inputs.

## Tests, limits and milestones

```sh
sh selfhost/toolchain/tests/run_s2_5.sh
sh selfhost/toolchain/tests/run_s2_4.sh
sh selfhost/toolchain/tests/run_s2_3.sh
sh selfhost/toolchain/tests/run_s2_2.sh
sh selfhost/toolchain/tests/run_s2_1.sh
sh selfhost/toolchain/tests/run.sh
sh verify.sh
```

S2.5 checks AST-to-IR golden fixtures, independently verified x86-64
opcode sequences, successful execution of function calls, direct
interpretation-versus-ELF exit/output comparison, deterministic build,
bad source/arity/type/initialization rejection, malformed ABI frame
rejection, and CFG tests with loops and joins.

The ISA uses 32-bit arithmetic; the Core seed defines 64-bit signed
integers. No semantic equivalence is claimed for overflowing values,
negative operands outside this profile, or unsupported operations.

**Next gates:** extend AST precedence/nested expressions, multiple
functions, recursion and lexical scopes; introduce a typed interprocedural
CFG, independent proofs for ABI correctness, richer register allocation,
and source-derived S0 reconstruction. Finally the compiler must compile
its own complete source with reproducible, verified fixed-point builds
before claiming full S3 self-hosting.

**Repository sequencing:** S2.5 is based on the S2.4 streaming fix branch,
which is reviewed separately in PR #110. No direct push to `main`.
