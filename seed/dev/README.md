# Native seed maintenance — no JavaScript toolchain

The repository no longer ships its former JavaScript-based interpreter,
assemblers, seed generators, or Node.js development oracle.

The supported runtime uses committed x86-64 machine-code seed dumps:
- `seed/linux-x86_64/seed.hex` (Linux ELF)
- `seed/windows-x86_64/seed.hex` (Windows PE)

The corresponding native bootstrap and conformance tests are executed without
Node.js. On Linux, start with:

```sh
./install.sh --no-desktop
sh verify.sh
sh scripts/no-js.sh
```

## Important reproducibility limitation

**Removing the previous JavaScript seed generator does not supply a native
source-to-machine-code generator.** The committed seed hex dumps remain usable,
but regenerating new machine code after changes to seed internals needs a future
assembler/compiler written in Triad or another explicitly approved native
bootstrap stage. Do not claim bootstrap source regeneration or full development
feature parity until that implementation exists and passes the seed hash and
conformance gates.

The files `certified-corpus.txt` and `certified-subset.txt` are historical
test/profile references, not executable JavaScript.

See `docs/NO_JAVASCRIPT_MIGRATION.md` for the migration boundaries.
