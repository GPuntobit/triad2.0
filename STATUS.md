# Triad and S0 bootstrap status

Updated after the A03 verification and conformance runner cleanup.

## Goal

Triad as a standalone, recognized language: its own standard, conformance, `.triad` extension, editor tooling, bootstrap without host languages and self-hosting.

## What is ready

- **Standard**: `SPEC.md` (v0.2.0), `SPEC-CORE.md`, `VERSION`, `CHANGELOG.md`.
- **Conformance**: Node runner `conformance/run.mjs` (no Julia); Triad-Core 37/37 green
  (Linux: interpreter `seed/dev/triad_core.cjs`; Windows: seed PE). Triad-Full: 12 cases, today
  only `errore` passes. Golden `expected.out`/`expected.code` versioned; a missing golden
  fails the case with `golden mancante`. See `conformance/README.md`.
- **Canonical extension**: `.triad` (`.td` historical alias), VS Code/Vim grammars and Linguist entry prepared.
- **Seed S0** (Windows PE, no runtime/compiler): Triad-Core interpreter with
  support for integers, variables, functions (short form and multi-statement `function ... end`),
  recursion, Bool, operators (`% ^ ! && || +=`), `if`/`elseif`/`else`, `while`, `let`, `begin`,
  lambda, closures with capture by value, basic strings + concatenation + `string()`,
  `nothing`, symbols and construction/printing of integer lists.
- **Launcher/CLI**: the default runtime for `.triad` is the machine-code seed (`bin/triad`, `bin/triad.cmd`, `cli/lib/utils.mjs`); the Julia implementation (`triad.jl`, `syntax.jl`, `test/`, `bin/build_standalone.jl`) has been removed.
- **CI**: `.github/workflows/ci.yml` — `conformance-core` (Ubuntu, `--skip liste`), `seed-windows`
  (33 Core cases on the PE, `get` probe, `selfhost/main.td` smoke test, `seed.hex` hash
  `3A75A21E...8C11`), `seed-linux` (ELF E0 + hash).

## What is missing

| area | status |
|---|---|
| `stringhe` (`string()`) | implemented (Int/String); Bool/Symbol/Nothing not implemented |
| `liste` | Core case passes with the runner; on the seed PE: construction/printing and `push!` of integer lists, standard indexing, `length` and iteration not supported |
| `valori` (lists/symbols/strings together) | partial; integer lists only, no operations or mixed values |
| `controllo` (`elseif`) | implemented |
| S1 (Triad in Triad-Core) | in progress in `selfhost/` (smoke test in CI, not yet conformance) |
| Triad-Full | 11/12 cases not implemented (only `errore` passes) |
| CLI seed | file execution only; REPL and SPEC section 14 options to do |
| S2-S3 (native compiler, self-hosting) | not started |
| S4 / M7 (parity, Linux ELF) | **E0 done** minimal Linux ELF; E1/E2/E3 and parity to do. POSIX Linux toolchain: `install.sh` + launcher `bin/triad`/`bin/triad-cli` with automatic fallback to the JS reference when the seed is a stub; dedicated CI job `linux-toolchain` |

## Verification commands

```sh
node conformance/run.mjs                                 # Core, 37 cases
node conformance/run.mjs --cases conformance/cases       # Full, 12 cases
```

Windows, seed:

```powershell
certutil -decodehex -f seed/windows-x86_64/seed.hex seed/windows-x86_64/seed.exe
.\seed\windows-x86_64\seed.exe conformance\core\cases\closure\program.td
```

## External recognition (requires the maintainer)

- `LICENSE` added (MIT, 2026-10-22);
- PR to GitHub Linguist with `editors/linguist/languages.yml`;
- publishing the VS Code / Open VSX and Vim extensions;
- possible registration of the language/standard.

## Final verification (round 31; previous baseline)

- Seed S0 Windows: PE 25088 bytes, hash `445CB428EFF44B39C2103DF776E6D9A1D1B5BDD8904C2C93D661950321C4ED60`, reproducible dump.
- Stage0: **Triad-Core 31/31**, **Triad-Full 12/12**.
- Seed Windows: new `funzioni_io` regression verified with byte-exact stdout; 27/28 cases listed in the CI job pass locally. `if_else` ends with exit `1` (even with the previous PE); hosted CI verification is still needed.
- CI: seed hash updated; Ubuntu/Windows matrix for conformance and Windows job for the seed.

### Core cases not yet covered by the seed

- `liste`: the seed covers construction, printing and `push!` of integer lists; standard
  indexing, `length`, iteration and mixed values remain to be implemented.
- `valori`: partial support; mixed values and full string handling are missing.

### Distance from the goal

The goal **is not complete**:
- S0 is a machine-code interpreter, but **S1 (Triad in Triad-Core) has not started**, so there is no self-hosting yet;
- S2-S3 (native compiler in Triad, fixed point) not started;
- S4/M7 (conformance parity, Linux ELF port) not started; the E0 artifact exists (`seed/linux-x86_64/seed.hex`), CI is ready but parity has not started;
- external recognition: MIT LICENSE chosen; Linguist PR and extension publishing require the maintainer.

## Seed Windows verification (round 32)

- Fixed the crash caused by overlap of PE import names with machine code:
  the generator placed the names at RVA `0x2cde`, inside code that had grown beyond
  that offset. Now the names start at RVA `0x5000`.
- Added `liste_base`: construction and printing of `[1, 2, 3]`; the seed exits with code `0`.
  Indexing, `push!`, `length`, iteration and lists with non-integer elements remain unsupported.
- The local Windows seed job passes 28/29 cases including the new regression; `if_else` remains
  the only known failure (exit `1`). The Julia suite of the new conformance passes.
- PE regenerated: 25,088 bytes; SHA-256 of the dump: `1B88C89A9D3EACD0D05594BC2CECFAA3A4B56A0B76553F904CB96339F4B3CE65`.

## `get` probe seed Windows (round 33)

- The generator already contained the body of `get`, but the call dispatcher did not
  recognize the name; moreover the body read arguments from the stack in the wrong order.
- Added dispatch and fixed 0-based access with checks on list type, index type
  and bounds. `test_get.td` now prints `20` and exits with code `0`; the probe is verified
  also in the Windows CI job.
- `get(xs, i)` is an extra helper of the seed and not a primitive defined by Triad-Core.
  Standard indexing `xs[i]` remains 1-based and is not yet implemented by the seed.
- Reproducible HEX dump: SHA-256 `EF8EB3D7DB47B55E2C455B8D79A45351EC80F1BBA01CA8918951FF1F15D7A802`.

## `push!` probe seed Windows (round 34)

- Connected the `push!` builtin to the dispatcher, added the `!` suffix to identifier parsing
  and fixed append: the mutated list is returned, with a seed limit of
  64 elements.
- `test_push.td` and the new Core case `liste_push` print `[10, 20]`; both exit with
  code `0`. `liste_push` is included in the Windows CI.
- The seed implementation remains limited to integer lists; Core indexing, `length`,
  iteration and printing of mixed values are not implemented.
- The local Windows seed matrix passes 29/30 cases; `if_else` is the only case still failing
  (exit `1`). All 33 Core cases pass on the seed.
- PE: 25,088 bytes; SHA-256 of the dump: `76FC146BA7E070522A5445B5CC0810997E035CBC3135911F62B9C6E6B3CB255F`.

## Seed Windows: Triad-Core conditionals (A02)

- Fixed dispatch of `if`/`elseif`/`else`: `elseif` conditions are evaluated
  in order, nested branches are delimited correctly and only the first
  selected branch is executed.
- Added Core cases `if_elseif`, `if_nested` and `if_no_else`; the seed passes these and
  `if_else` with byte-exact output and exit `0`. The Core conformance Julia passes all
  cases.
- PE regenerated: 25,088 bytes, code 8315 bytes; SHA-256 of `seed.hex`:
  `9987105DCD56F42A1AD73451821A281E6F24374ED6CE83993BB8CA56F5EC4822`.

## Seed Windows: fix `string()` Int conversion (A03)

- Fixed bug in `pbs_int` (Int to string conversion): r10 was used in the loop
  to write digits BEFORE being initialized, causing an access violation (0xC0000005).
- Moved initialization of r10 (`lea r10, [rbp-8]`) BEFORE the loop to ensure
  it always points to the valid stack buffer.
- Tested: `string(42)`, `string(0)`, `string(-5)`, `string("ciao")` work correctly.
- Conformance `stringhe` passes with correct output: `ciao Triad\n5\n42`.
- Bool/Symbol/Nothing remain unimplemented (they crashed before too; now they return fail).
