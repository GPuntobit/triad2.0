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

### Immediate: final S1 verification

- All ai/tasks/ tasks completed
- Conformance suite verified
- Bugs fixed and documented

### After S1

- S2: Native compiler - codegen review
- S3: Self-hosting - cross-platform validation
- S4: Full runtime, Linux parity - benchmark

### Cleanup: debug output and throwaway files

- [ ] `seed/dev/gen_seed.js:1589`: remove `console.log('labels', JSON.stringify(labels))`, which dumps all emitter labels on every seed regeneration (debug only).
- [ ] `seed/dev/gen_seed.js:1590`: remove `console.log('code bytes:', code.length)` (intermediate data; final size is already printed at line 1640).
- [ ] `seed/dev/gen_seed_linux.js:113-114`: reduce output to `sha256(ELF)` and the written file; `ELF bytes` and `entry RVA` are debug details.
- Note - to keep (legitimate CLI output): `console.log`/`console.error` in `ai/jev_audit.mjs` (report, `--dry-run`, usage messages) and in `tools/webcmd-graphify/tools/generate.mjs`.
- [ ] `_probe.jl`, `_probe2.jl`, `_probe3.jl`, `_qc.jl`, `_smoke.jl`: `PROMPT_JEV.md` describes them as "gitignored, throwaway scripts", but they are versioned. Remove them from the repository and add them to `.gitignore`.
- [x] Root output files versioned (`out.txt`, `output.txt`, `outfile.txt`, `stdout.txt`, `runoutput.txt`, `test_output.txt`, `error.txt`, `scope_out.txt`, `let_output.txt`, `let_test_out.txt`, `let_annidato_out.txt`): remove them and ignore them.
- [ ] `run_seed.bat` ... `run_seed12.bat` (12 variants): keep one parameterized.

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
