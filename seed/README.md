# Bootstrap seed (S0)
This folder contains **S0**, the first Triad executable: programs written in **code
machine**, without compilers, assemblers or other languages. The "source" is a dump
hexadecimal; the executable is obtained by decoding it with a system tool.
The complete chain is described in [`../BOOTSTRAP.md`](../BOOTSTRAP.md).
## State
| milestones | platform | status |
|---|---|---|
| M1 — prints a line and exits with 0 | Windows x86-64 (PE) | ✅ |
| M2 — reads the file from the first argument and writes its bytes | Windows x86-64 (PE) | ✅ |
| M3 — Triad-Core interpreter | Windows x86-64 (PE) | in progress: M3b1 ✅, M3b2a ✅, M3b2b1 ✅, M3b2b2 ✅, M3b2b3a-e ✅, **M3b2b3f** ⚠️ (unstable capture), **M3b2b3g** ✅ (`!`, `&&`, `||`, `+=`), **M3b2b3h** ✅ (`function … end`), **M3b2b3i** ✅ (multi-statement body), **M3b2b3j** ✅ (lexical frames, `let`; `scope`), **M3b2b3k** ✅ (closures; `closure`/`closures`), **M3b2b3l** ✅ (`begin`/`end`), **M3b2b3m** ✅ (base strings), **M3b2b3n** ✅ (`nothing`), **M3b2b3o** ✅ (concatenation), **M3b2b3p** ✅ (symbols `:name`; `base_symbols`); `string()`, multi-binding capture, `elseif`, lists | remain
| M7 — Linux port (ELF) | Linux x86-64 | in progress: **E0 ✅** (minimal ELF, syscall write/exit); E1/E2/E3 to do |
## Build (no compiler)
Windows:
```powershell
Remove-Item seed\windows-x86_64\seed.exe -ErrorAction SilentlyContinue
certutil -decodehex seed\windows-x86_64\seed.hex seed\windows-x86_64\seed.exe
```

Linux/macOS:
```sh
xxd -r -p seed/windows-x86_64/seed.hex seed/windows-x86_64/seed.exe
```

Note: The product file is a PE for Windows; for Linux there is the ELF E0 seed in
`linux-x86_64/` (see below). `certutil`/`xxd` are decoders only: they do not contain
Triad logic and are not part of the chain.
Linux ELF (E0):
```sh
xxd -r -p seed/linux-x86_64/seed.hex seed/linux-x86_64/seed
chmod +x seed/linux-x86_64/seed
./seed/linux-x86_64/seed          # Triad seed Linux OK
```

Or, for the complete installation of the POSIX toolchain (launcher in
`~/.local/bin`, smoke test and optional desktop entry):
```sh
./install.sh              # dalla radice del repository, senza root
```

## Verify
Windows (PE seed):
```powershell
$exe = .\seed\windows-x86_64\seed.exe
& $exe conformance\core\cases\interi\program.td       # 7 9 6 -3 5 7
& $exe conformance\core\cases\closure\program.td      # 15 105 15
& $exe conformance\core\cases\funzioni\program.td     # 5 16 120 55
& $exe conformance\core\cases\while_loop\program.td   # 15 5
& $exe ; $LASTEXITCODE                                # 2
& $exe non_esiste.td ; $LASTEXITCODE                  # 1
```

Linux (ELF E0 seed):
```sh
xxd -r -p seed/linux-x86_64/seed.hex seed/linux-x86_64/seed
chmod +x seed/linux-x86_64/seed
./seed/linux-x86_64/seed           # Triad seed Linux OK, exit 0
```

The Windows seed covers **25 of the 29 Core cases**; the Linux E0 seed only covers printing the
message. Details in [`windows-x86_64/README.md`](windows-x86_64/README.md) and
[`linux-x86_64/README.md`](linux-x86_64/README.md).
## Rules
- The seed **does not** contain Julia or any other language: just x86-64 bytes and data.
- Hex dump is the source; the listing/layout in `windows-x86_64/README.md` makes it
  editable without tools. The maintenance generator is in `dev/` (not part of the
  chain and is not required to use or rebuild the seed).
- The development tools (disposable script that produced the dump, editor, decoder)
  they are not part of the S0→S4 chain: the dump is enough to use/rebuild the seed.
- With each extension of the seed (M3, ...) the following are updated: dump, documentation, hash and milestone in
  `../BOOTSTRAP.md`.