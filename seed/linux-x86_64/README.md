# S0 / Linux x86-64 — ELF seed (E1)
First step of the Linux port: a static **ELF64** without libc or dynamic linker, which uses
Linux syscalls only. **E1** is the *runner* of a `.td` file: it takes the source path from
`argv[1]`, loads it into a buffer and writes it back to stdout (**echo**). The Triad-Core
interpreter comes with E2 (`TASK.md` N17, `BOOTSTRAP.md` §5).
The hex dump is [`seed.hex`](seed.hex): it is the committed source.
## Behavior (E1)
| invocation | stdout | stderr | exit |
|---|---|---|---|
| `./seed file.td` | byte-exact contents of `file.td` | empty | `0` |
| `./seed` (no args) | empty | `usage: seed FILE.td` | `2` |
| `./seed ""` (empty path) | empty | `usage: seed FILE.td` | `2` |
| `./seed missing.td` | empty | `seed: cannot open file` | `1` |
| source ≥ `0xF000` bytes | empty | `seed: file too large` | `1` |

Exit codes follow the `os_*` contract (`.scratch/seed-linux-nativo/issues/03`): `2` = usage,
`1` = open/read failure or source too large (mask slot at `+0xF000`, same bound as the PE).
The PE is silent: stderr diagnostics exist **only** on the ELF, outside the parity contract
(which covers byte-identical stdout only).
## Numbers
- **ELF File:** 557 bytes (`0x22D`)
- **Machine code + messages:** 437 bytes
- **Base:** `0x400000`; **entry:** `0x400078`
- **Program header:** a single `PT_LOAD` R|X, offset 0, filesz/memsz `0x22D`, align `0x1000`
- **sha256 of `seed.hex`:** `2BE2734FCAD2E87181A420AE176C86F9D9DCA51B3F1E8EA8A271FAFC6973DAEE`
- **sha256 of the decoded ELF:** `BDA8772765436F1692F4E575F4708907CC63D2886F5FC1BB46C06FD804014079`
## Build and test (Linux)
```sh
cd seed/linux-x86_64
xxd -r -p seed.hex seed
chmod +x seed
./seed ../../../tests/probes/test_simple.td   # echoes the source, exit 0
echo $?          # 0
sh check_e1.sh   # 7 acceptance cases, byte-exact
```

Optional checks with binutils:
```sh
readelf -h seed      # ELF64, ET_EXEC, entry 0x400078
readelf -l seed      # un PT_LOAD R E
objdump -D -b binary -m i386:x86-64 --adjust-vma=0x400078 <(tail -c +121 seed)
```

## Reproducibility
```sh
node seed/dev/gen_seed_linux.js seed/linux-x86_64/seed.hex
```

The dump is the canonical and reproducible source; the produced ELF can be committed
along with it (it's no longer in `.gitignore`). The generator is a development tool
and is not part of the S0→S4 chain. The CI `seed-linux` job re-runs the generator and
requires `cmp` equality (anti-drift), plus `check_e1.sh`.
## Known limits (unchanged from the PE)
- Path buffer: 256 bytes, unbounded copy (mirrors `GetCommandLineA` parsing in the PE).
- Source: max `0xEFFF` bytes (`0xF000` is the mask slot); read buffer `0x10000`.
- The seed is still a **stub** for the launcher (`< 4 KB`): `bin/triad` keeps using the
  JS reference interpreter until the E2 interpreter lands (N17/N18 removes the fallback).
## Next steps
- **E2:** port of the Triad-Core interpreter (`os_*` contract, codegen architecture in
  `.scratch/seed-linux-nativo/issues/02-architettura-codegen.md`); target the Core cases
  supported by the Windows seed, byte-identical on the shared goldens.
- **E3:** Native Linux CI job without Wine (toolchain `install.sh` → `bin/triad`).

> **Task principale dal 2026-11-03:** E1/E2/E3 sono la task principale del progetto
> (`TASK.md` → «Task principale (2026-11-03): seed Linux nativo — senza Wine», N15–N18)
> e precedono N03 e le altre sotto-task meccaniche.
Meanwhile the POSIX toolchain is ready: `./install.sh` decodes this seed,
install `bin/triad` and `bin/triad-cli` in `~/.local/bin` and launchers use
automatically the reference JS interpreter as long as the seed remains a stub
(threshold: 4 KB). The `linux-toolchain` CI job covers launcher + install + conformance.
See [`../dev/README.md`](../dev/README.md) and [`../../BOOTSTRAP.md`](../../BOOTSTRAP.md).
