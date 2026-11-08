# Seed development tools (NOT part of the S0→S4 chain)
This folder contains seed **maintenance** tools in machine code. Not
they are part of the product, are not required to build or use Triad and do not introduce
dependencies in the bootstrap chain: the source of the seed remains the hex dump
(`../windows-x86_64/seed.hex`, `../linux-x86_64/seed.hex`), materializable with a simple
system decoder (`certutil -decodehex` / `xxd -r -p`).
## `gen_seed.js`
Single entry point of the seed generator (Node.js, development only):

```sh
node seed/dev/gen_seed.js <windows|linux|all> [out.hex]
```

`windows` and `linux` regenerate one dump in its canonical path
(`../windows-x86_64/seed.hex`, `../linux-x86_64/seed.hex`; `out.hex` overrides it),
`all` regenerates both. Structure (decisione 02, `.scratch/seed-linux-nativo/issues/02`):
the assembler-lite and the **shared codegen core** (interpreter body + `os_*` boundary)
live in `core.js`; the two backends contain the inline `os_*` emissions (ordered slot
placements per the `os_*` contract), the system constants and the executable builders —
`backend_pe.js` (Windows PE) and `backend_elf.js` (Linux ELF).

Current output:
- **windows:** 25088 byte PE, sha256 of `seed.hex` (verified by CI):
  `C4A25D2CFA12A9CBE8769A6CE396AFD76ABC0CCF3B752237635096FB9B8E3D33`
- **linux** (E2, Triad-Core interpreter): 9647 byte ELF (entry `0x400078`, single
  `PT_LOAD` R|X), sha256 of `seed.hex`:
  `96789450E25BF2DFD96B27AAC756DE08C3891FA70BCA9A6113B16A3A948652B6`,
  sha256 of the decoded ELF:
  `95CC7E248D55F98670C688655E1F2FA1AE5E7DC62E05AFE03CDBDC6809D396B7`
## Because they are versioned
Writing a byte interpreter by hand without a generator is impractical beyond a few
instructions; losing the generator blocks the seed extension. Keeping them here makes the work
reproducible and verifiable against hashes.
## Rules
- the **product** and the S0–S4 chain do not use Node or these files;
- `seed.hex` dumps are the committed source; generators are tools, not dependencies;
- every change to a generator must regenerate the dump and update hash/documentation
  (`../windows-x86_64/README.md`, `../linux-x86_64/README.md`).