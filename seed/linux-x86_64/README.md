# S0 / Linux x86-64 — ELF seed (E2: interprete Triad-Core)
The Linux seed is a static **ELF64** without libc or dynamic linker, which uses Linux
syscalls only (`openat`/`read`/`write`/`exit`, isolated in the `os_*` routines). **E2**
carries the same machine-code domain as the Windows PE: Triad-Core integers, variables,
functions (short form and `function … end`), recursion, Bool, operators, `if`/`elseif`/
`else`, `while`, `let`, `begin`, lambda/closures, basic strings + `string()`, `nothing`,
symbols, lists (build, print, `push!`, `get`). Stdout is **byte-identical** to the PE on
the shared goldens (parity N17, `TASK.md`).
The hex dump is [`seed.hex`](seed.hex): it is the committed source.
## Behavior (E2)
| invocation | stdout | stderr | exit |
|---|---|---|---|
| `./seed file.td [ARG…]` | program output, byte-exact | empty | `0` (or the program's exit) |
| `./seed` (no args) | empty | `usage: seed FILE.td` | `2` |
| `./seed ""` (empty path) | empty | `usage: seed FILE.td` | `2` |
| `./seed missing.td` | empty | `seed: cannot open file` | `1` |
| source ≥ `0xF000` bytes | empty | `seed: file too large` | `1` |

Exit codes follow the `os_*` contract (`.scratch/seed-linux-nativo/issues/03`): `2` = usage,
`1` = open/read failure or source too large (mask slot at `+0xF000`, same bound as the PE).
The PE is silent: stderr diagnostics exist **only** on the ELF, outside the parity contract
(which covers byte-identical stdout only). Runtime errors of a program (e.g. `bad_*` probes)
exit non-zero with empty stdout, identically to the PE; the known PE limits stay documented
limits (see [`tests/probes/README.md`](../../tests/probes/README.md) and the registered gap
`liste` in [`conformance/run.sh`](../../conformance/run.sh)).
## Numbers
- **ELF file:** 8499 bytes (`0x2133`)
- **Base:** `0x400000`; **entry:** `0x400078`
- **Program header:** a single `PT_LOAD` R|X, offset 0, filesz/memsz `0x2133`, align `0x1000`
  (no section headers, like the PE dump: the artifact is pure machine code)
- **sha256 of `seed.hex`:** `0E121DB8B4C126062C05BA55621635DE4C47751E25F0AE617036440F9451EC4D`
- **sha256 of the decoded ELF:** `C8C82BC9C77C69E603E07AB7287065076E04C8139A57AE3EE454A472CEE2A0CE`
## Build and test (Linux)
```sh
cd seed/linux-x86_64
xxd -r -p seed.hex seed
chmod +x seed
./seed ../../../tests/probes/test_simple.td   # prints: test
echo $?          # 0
sh check_seed.sh # 7 acceptance cases (error/limits contract), byte-exact
```
Full gate from the repository root (conformance 39 + probes + golden S1 + smoke):
```sh
sh verify.sh
```

Optional checks with binutils:
```sh
readelf -h seed      # ELF64, ET_EXEC, entry 0x400078
readelf -l seed      # un PT_LOAD R E
```

## Reproducibility
```sh
node seed/dev/gen_seed.js linux seed/linux-x86_64/seed.hex
```
(the default output path is already `seed/linux-x86_64/seed.hex`; the explicit form is
shown for clarity). The dump is the canonical and reproducible source; the ELF binary can
be committed along with it (it's no longer in `.gitignore`). The generator is a development
tool and is not part of the S0→S4 chain. The CI `seed-linux` job re-runs the generator and
requires `cmp` equality (anti-drift), plus `check_seed.sh` and `verify.sh`.
## Known limits (unchanged from the PE)
- Path buffer: 256 bytes, unbounded copy (mirrors `GetCommandLineA` parsing in the PE).
- Source: max `0xEFFF` bytes (`0xF000` is the mask slot); read buffer `0x10000`.
- The PE's machine-code domain limits (list-literal heap, dynamic scoping, max 4 parameters,
  multi-line list literals, …) are measured and registered in
  [`tests/probes/README.md`](../../tests/probes/README.md); `xs[i]` and `push!`-statement
  remain outside the seed domain (gap `liste`, registered in `conformance/run.sh`).
## Next steps
- **E3 (N18):** toolchain Linux without Wine — `install.sh` → `bin/triad` with this seed as
  the only runtime (the stub/fallback logic exits), POSIX `bin/triad-cli`, CI `seed-linux`
  on the native ELF.

> **Task principale dal 2026-11-03:** E1/E2/E3 sono la task principale del progetto
> (`TASK.md` → «Task principale (2026-11-03): seed Linux nativo — senza Wine», N15–N18)
> e precedono N03 e le altre sotto-task meccaniche.
Meanwhile the POSIX toolchain is ready: `./install.sh` decodes this seed,
install `bin/triad` and `bin/triad-cli` in `~/.local/bin` and the launchers use the
seed ELF (the JS reference fallback remains only for stubs < 4 KB during the N18
transition). The `linux-toolchain` CI job covers launcher + install + conformance.
See [`../dev/README.md`](../dev/README.md) and [`../../BOOTSTRAP.md`](../../BOOTSTRAP.md).
