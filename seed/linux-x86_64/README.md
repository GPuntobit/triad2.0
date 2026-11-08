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
| source ≥ `0x100000` bytes | empty | `seed: read error` | `1` |

Exit codes follow the `os_*` contract (`.scratch/seed-linux-nativo/issues/03`): `2` = usage,
`1` = open/read failure or source too large (the arena reserves 1 MiB of source since N20,
the block-stop mask slot is at `+0x100000`, same bound as the PE). The too-large case shares
the `read_fail` label with the genuine read errors (known limit of the seed: one exit label
for both, so the diagnostic is `seed: read error`).
The PE is silent: stderr diagnostics exist **only** on the ELF, outside the parity contract
(which covers byte-identical stdout only). Runtime errors of a program (e.g. `bad_*` probes)
exit non-zero with empty stdout, identically to the PE; the known PE limits stay documented
limits (see [`tests/probes/README.md`](../../tests/probes/README.md)).
## Numbers
- **ELF file:** 11465 bytes (`0x2cc9`)
- **Base:** `0x400000`; **entry:** `0x400078`
- **Program header:** a single `PT_LOAD` R|X, offset 0, filesz/memsz `0x2682`, align `0x1000`
  (no section headers, like the PE dump: the artifact is pure machine code)
- **sha256 of `seed.hex`:** `A5FA3E506B91BF444D8EE6D673F703BBEC31DF649F01D7061264F91424C441D8`
- **sha256 of the decoded ELF:** `47C950E30C147CBD137C5419BF1EF11ABEF265B39D931A87294D1E98A6F3307E`
## Build and test (Linux)
```sh
cd seed/linux-x86_64
xxd -r -p seed.hex seed
chmod +x seed
./seed ../../../tests/probes/test_simple.td   # prints: test
echo $?          # 0
sh check_seed.sh # 7 acceptance cases (error/limits contract), byte-exact
```
Full gate from the repository root (conformance 42 + probes + golden S1 + smoke):
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
- Source: max `0xFFFFF` bytes (1 MiB − 1, arena N20; `0x100000` is the mask slot); read
  buffer `0x100000`. A source of `0x100000` bytes or more is rejected (exit 1).
- The PE's machine-code domain limits (list-literal heap, dynamic scoping, max 4 parameters,
  multi-line list literals, …) are measured and registered in
  [`tests/probes/README.md`](../../tests/probes/README.md). All 40 Core cases, including
  `liste`, are required by the gate without exclusions.
## Next steps
- **E3 (N18) ✅ chiusa:** toolchain Linux senza Node — `install.sh` → `bin/triad` con questo
  seed come unico runtime (la logica di stub/fallback è uscita dal launcher), CLI POSIX
  `bin/triad-cli` (`run`/`test`/`status`), CI `seed-linux` sull'ELF nativo.

> **Task principale dal 2026-11-03:** E1/E2/E3 sono la task principale del progetto
> (`TASK.md` → «Task principale (2026-11-03): seed Linux nativo — senza Wine», N15–N18)
> e precedono N03 e le altre sotto-task meccaniche.
La toolchain POSIX è pronta: `./install.sh` ridecodifica questo seed da `seed.hex`
(anti-drift), installa `bin/triad` e `bin/triad-cli` come wrapper a percorso assoluto in
`~/.local/bin` e supera uno **smoke test byte-exatto** (mismatch => installazione
fallisce). Il launcher esegue sempre il seed: nessun fallback JS nel percorso utente
(il riferimento `../dev/triad_core.cjs` resta solo nel tooling di sviluppo). Il job CI
`linux-toolchain` copre launcher + install + gate; `seed-linux` copre check_seed.sh,
hash PE/ELF, dump riproducibili e `verify.sh`.
Vedi [`../dev/README.md`](../dev/README.md) e [`../../BOOTSTRAP.md`](../../BOOTSTRAP.md).
