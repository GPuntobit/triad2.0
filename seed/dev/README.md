# Seed development tools (NOT part of the S0→S4 chain)
This folder contains seed **maintenance** tools in machine code. Not
they are part of the product, are not required to build or use Triad and do not introduce
dependencies in the bootstrap chain: the source of the seed remains the hex dump
(`../windows-x86_64/seed.hex`, `../linux-x86_64/seed.hex`), materializable with a simple
system decoder (`certutil -decodehex` / `xxd -r -p`).
## `gen_seed.js`
Seed Windows PE Generator (Node.js, development only). Contains the assembler-lite and the
description of PE structures; produces `seed.hex` and prints its labels and dimensions.
```sh
node seed/dev/gen_seed.js seed/windows-x86_64/seed.hex
```

Current output: **25088 byte** PE, sha256 of `seed.hex` (same as verified by CI):
```
3A75A21E2F47D8DC4C88D4BC2580A85D5349BCDF7550E5FFA16E2C0AC7CA8C11
```

## `gen_seed_linux.js`
Seed ELF Linux x86-64 Generator (E0: syscall `write`/`exit`, message
`Triad seed Linux OK`). Constructs static ELF64, entry `0x400078`, a single `PT_LOAD` R|X.
```sh
node seed/dev/gen_seed_linux.js seed/linux-x86_64/seed.hex
```

Current output: **173 byte** ELF, sha256 of `seed.hex`:
```
AD4C9F08176D9964D5BE17D44C72230184434025980447395E7A3250F63CA5EA
```

sha256 of the decoded ELF:
`6d504451e1d8a39c6e139a8a120bfaf03373131894292be12f0039eb8a7797f9`.
The script checks the dump's magic, `e_machine`, entry, and round-trip before exiting.
## Because they are versioned
Writing a byte interpreter by hand without a generator is impractical beyond a few
instructions; losing the generator blocks the seed extension. Keeping them here makes the work
reproducible and verifiable against hashes.
## Rules
- the **product** and the S0–S4 chain do not use Node or these files;
- `seed.hex` dumps are the committed source; generators are tools, not dependencies;
- every change to a generator must regenerate the dump and update hash/documentation
  (`../windows-x86_64/README.md`, `../linux-x86_64/README.md`).