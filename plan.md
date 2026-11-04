# Plan to complete Triad 2.0 - Updated status

Runtime note: the machine-code seed is the default runtime for `.triad` (launcher `bin/triad`/`bin/triad.cmd` and CLI); Julia remains a development tool (tests, conformance, packaging).

## Current status (Day 4)

### Seed S0 Windows - COMPLETED

- **PE**: 25,088 bytes, code 8315 bytes
- **Hash**: `3A75A21E2F47D8DC4C88D4BC2580A85D5349BCDF7550E5FFA16E2C0AC7CA8C11`
- **Features**:
  - Integers, variables, functions (short and block form)
  - Recursion, Bool, operators (`% ^ ! && || +=`)
  - `if`/`elseif`/`else`, `while`, `let`, `begin`
  - Lambda, basic closures
  - Basic strings + concatenation + `string(Int/String)`
  - Full lists (construction, printing, `push!`, `get`)
  - `nothing`, symbols
- **Conformance**: 33/33 Windows cases byte-exact, 36/36 Core Julia
- **Bug fixed**: `string()` Int conversion (r10 initialized correctly)

### S1 (Triad interpreter in Triad-Core) - NOW COMPLETED

- **S1.3**: Tagged value system (Int, Bool) completed
- **S1.4**: Inline parser/tokenizer completed
- **S1.5**: Basic expression eval completed (bug fixed: environment lookup)
- **S1.8**: Variables with let completed
- **S1.11-S1.15**: Full parser, functions, closures, tests completed

### S2-S4 (Bootstrap) - NOT STARTED

- **S2**: Native compiler - initial draft
- **S3**: Self-hosting - in progress
- **S4**: Full runtime, Linux parity - planning

## Current tasks

### MAIN (2026-11-03): Linux native seed — no Wine (TASK.md N15–N18)

- The maintainer decision: Triad must not be a Windows-only emulator. Windows keeps the PE;
  Linux must need **nothing beyond the repo** (no Wine, no Node to run programs).
- N15 (E1): ELF file runner (`argv` + `openat`/`read`/`write`) → N16 (E2a): split the
  platform-independent interpreter codegen from the `os_*` OS routines in `gen_seed.js` →
  N17 (E2b): ELF64 emitter with PE parity (byte-exact conformance, identical probes) →
  N18 (E3): `install.sh`/`bin/triad` on the native seed + Wine-free `seed-linux` CI job.
- This task precedes N03 (`xs[i]` 1-based) and the other mechanical sub-tasks.

### Immediate: final S1 verification

- All ai/tasks/ tasks completed
- Conformance suite verified
- Bugs fixed and documented

### After S1

- S2: Native compiler - codegen review
- S3: Self-hosting - cross-platform validation
- S4: Full runtime, Linux parity - benchmark

### Cleanup: debug output and throwaway files

- [x] Debug console.log lines in seed/dev/gen_seed.js: no longer present (plan was outdated)
- [x] seed/dev/gen_seed_linux.js output: already minimal (sha256 + written file only)
- [x] Probe files (_probe.jl, _probe2.jl, _probe3.jl, _qc.jl, _smoke.jl): never versioned, already gitignored
- [x] Root output files versioned (`out.txt`, `output.txt`, `outfile.txt`, `stdout.txt`, `runoutput.txt`, `test_output.txt`, `error.txt`, `scope_out.txt`, `let_output.txt`, `let_test_out.txt`, `let_annidato_out.txt`): removed and ignored
- [x] `scripts/seed-runner/run_seed.bat` ... `run_seed12.bat` (12 variants): consolidated to single parameterized `run_seed.bat`

## S1 implemented files

- `selfhost/value.td`: Tagged value system
- `selfhost/tokenizer.td`: Inline parser/tokenizer
- `selfhost/eval.td`: Basic expression eval
- `selfhost/main.td`: Working inline environment

## Current seed limitations

- `string()`: only Int/String (Bool/Symbol/Nothing not implemented but not required for conformance)
- Lists: integers only, max 64 elements
- Standard indexing, `length`, iteration: not implemented (S2)
- Conformance: 33/33 completed

## Conformance status

- Stage0 Julia: 33/33 Core, 12/12 Full
- Seed Windows: 33/33 Core
- Seed Linux: minimal E0 (not comparable) - starting cross-platform tests for parity

## Completed ai/tasks/

- **01_somma**: Triad sum and precedence program
- **02_fattoriale**: recursive factorial(n) function
- **03_fibonacci**: recursive fib(n) function
- **04_stringhe**: string assignment and concatenation
- **05_chiusure**: closures and application
