# Triad-native toolchain — S2.0 machine-code emission experiment

This folder is the **first narrow step** toward a source-maintainable
self-hosted Triad compiler. The actual emitter and instruction encodings are
written in **Triad-Core** and run under the existing native x86-64 seed.
There is no JavaScript/Node, Python, C, Rust, or external assembler involved
in generating the machine-code bytes.

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
