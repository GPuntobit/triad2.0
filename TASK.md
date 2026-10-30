# Task Triad 2.0
## Objective
Complete Triad 2.0 as a standalone and recognized language with its own standard, conformance suite, `.triad` extension, tooling editor, bootstrap without guest languages and self-hosting.
## Current status
- **Seed S0 (Windows):** 8315 bytes, hash `9987105DCD56F42A1AD73451821A281E6F24374ED6CE83993BB8CA56F5EC4822`
  - Support: integers, variables, functions (short form and block), recursion, Bool, operators, if/elseif/else, while, let, begin, lambda, closures, base strings, nothing, symbols, complete lists (build, print, push!, get)
  - Conformance: 33/33 Windows byte-exact cases, 36/36 Core Julia
- **S1 (Triad Interpreter in Triad-Core):** Inline environment working with lists, complete basic primitives
- **S2-S4:** Uninitiated
---
# Backlog: errors and checks
This file collects confirmed problems and checks still to be done on the project.
An open check does **not** imply that the code is bad: file a bug only afterwards
have reproduced it, indicating the command or steps, the expected result and the one obtained.
## Project map
The most recent queryable Graphify map describes commit `d75e31a` (index of
October 24, 2026): 677 nodes, 1,546 relationships and 26 communities. The index includes guards
safety for malformed ASTs; subsequent local changes must be verified
directly.
- `syntax.jl`: lexer, Pratt parser and `Node` tree construction; between the mapped nodes:
  `parse_toplevel`, `parse_stmt`, `parse_function`, `parse_list`, `parse_args`, `parse_for`
  and `skipnl!` (guarding limits on trailing separators).
- `triad.jl`: runtime and execution; Graphify locates, among others, `run_source`,
  `load_file!`, `define_function`, `define_struct`, `solve_opts`, `reload!`, `run_solve`
  (checking the number of arguments) and `solve_goal`.
- `test/runtests.jl` and `conformance/`: implementation tests and conformance cases.
  `test/oracles/oracle_tests.jl` contains optional oracle tests.
- `.github/workflows/ci.yml`, `seed/` and `seed/dev/`: CI checks, Windows/Linux seeds
  and related generators.
- `bin/`: standalone launcher and packaging (`bin/build_standalone.jl`).
- `editors/`: editor integrations; `ai/`: tools and benchmarks.
- `SPEC.md`, `SPEC-CORE.md`, `BOOTSTRAP.md`, `STATUS.md`, `README.md` and
  `TUTORIAL.md`: standards, Core profile, bootstrap plan, status and documentation.
Graphify describes indexed relationships and symbols; does not certify semantic correctness,
test coverage or absence of bugs. The following checks must therefore be confirmed
running code and tests and comparing them to the specification.
## Completion priority
1. **P0 — Parser and specification:** close the check of `syntax.jl` against `SPEC.md`,
   then map regulatory requirements to testing and cover real gaps.
2. **P0 — Cross-platform release:** verify Windows CI lane and execution
   PE seed, including decoding, conformal cases, and hashing.
3. **P1 — Distribubility and integrity:** verify standalone packaging, reproducibility
   of generated files and protection of versioned artifacts.
4. **P1 — Documentation:** compare examples, declared state, and commands with
   implementation and compliance.
5. **P2 — Ecosystem:** Check editor integrations and AI tools.
**Graphify diagnosis:** `lex` is called from `parse_toplevel` and `string_node`, and is linked
to `interpolation_end`, `isidstart` and `syntax_error`; `parse_expr` is called by parsers
instructions, lists/comprehension, rules, solve and blocks. `graphify_tests_for` does not have
returned test for `lex`, `parse_expr` or `skipnl!` (no links in graph for i
AST audit test); for `run_solve` and `solve_opts` returns only `test/runtests.jl`
and `test/oracles/oracle_tests.jl` (match by name, not by content). It's a shortcoming of the
graph connections, not evidence of the absence of testing. The updated index is on commit
`d75e31a`. `raw()` (syntax.jl L310) is not resolvable like `raw!`; the callers of `next!`
include `expect_ident!`, `expect_kw!`, `expect_op!`, `parse_args`, `parse_expr`,
`parse_for` and `parse_function`.
## Recent issues and changes (from `5e8ca470` to `d75e31a`)
- [x] **Guards for malformed ASTs (commit `e201a3e`)** — Added regressions in
  `test/runtests.jl` for `skipnl!` at the token vector boundary, for `run_solve` with
  zero arguments, for `solve_opts` with no options, and for an option with no value.
  Malformed cases return Triad `:syntax` errors with no host exceptions; suites
  Julia: 281/281 tests passed.
- [x] **Seed Windows: Expressions in Block Functions** — The seed parser separated
  the path of the autonomous expressions from the one that saves the identifier registers;
  a literal in the body (e.g. `20`) corrupted the call stack. Corrected the
  path and added `io_functions` conformance, which checks `!io`, output in the body
and value of the last expression. Also check `test_short_func.td` in the form
  Triad `f1() = 10` and the block body; both end with exit `0`.
- [x] **Seed Windows: regenerated and aligned artifacts** — `gen_seed.js` generates
  25,088 bytes; `seed.exe` was decoded from `seed.hex`, SHA-256
  `76FC146BA7E070522A5445B5CC0810997E035CBC3135911F62B9C6E6B3CB255F`.
- [ ] **Seed Windows: `string()` does not cover Bool and Symbol** — The current generator
  handles strings and integers, but sends the `string(false)` error path,
  `string(true)` and `string(:symbol)`. Implement and test these cases
  compliance in the seed PE if they are required by the specification.
- [x] **Seed Windows: Core case `strings`** — After regeneration and decoding
of the 25,088 byte PE, `stringe/program.td` ends with exit code `0` and produces
  exactly `strings/expected.out` (`hi Triad`, `5`, `42`). Of the 28 cases of the CI job
  Windows, 27 pass locally; `if_else` ends with exit `1` and requires verification
  separate (even the previous EP did not overcome this case).
- [x] **Seed Windows: crash on lists and strings after generation** — With the generator
  local, `test_list.td` and also a case of strings ended with
  `STATUS_ILLEGAL_INSTRUCTION`; the Application Error indicated RVA `0x2ce6`. The name area
  import PE started at RVA `0x2cde` and overwrote the machine code grown to
  that address. Moved import names to RVA `0x5000`; the generated seed prints now
`[1, 2, 3]` and the `strings` case with exit code `0`. Added regression case
  `liste_base` to the conformance Core and the Windows CI job. The subsequent local verification
  passes all cases listed except `if_else` (exit `1`, pre-existing problem); the new
  hash of the seed is recorded in the CI.
- [x] **Seed Windows: probe `get(lst, 1)` was not dispatched** — The generator
  contained the `get` primitive parser but `pf_call` didn't recognize it; the seed came out
  with code `1` without output. Added dispatch and fixed argument retrieval
  and bounds checking, with zero-based index as required by the probe. The seed prints
  `20` for `test_get.td`; the probe is included in the Windows CI job. `get` remains an extension
of the seed, not a Triad-Core normative primitive (`xs[i]` is the standard 1-based access).
- [x] **Seed Windows: `push!` was not dispatched** — The builtin body was already
  present but not reachable from `pf_call`; also the seed identifier does not
  consumed the suffix `!`. Added `push!` dispatch, final suffix parsing,
  mutable append with 64 element limit and list return. `test_push.td` prints
  `[10, 20]`; added Core case `liste_push` and registered in Windows CI. The seed
  supports integer lists here; standard indexing, `length` and iteration remain absent.
  The local seed array passes 29/30 cases (remains `if_else`, exit `1`); the 33 Core cases
  they pass with the Julia runtime.
- [x] **Self-host seed smoke test: `selfhost/main.td` prints a list** — Reproduced on
  problem: previous version ended with exit code `1` and stdout empty because
  `env_lookup` used `get` in a function body and `return`, not supported by the seed in
  that context. Replaced the program with a compatible test of `push!` which must
  print `[10, 20]`, and added a check dedicated to the Windows CI. This checks out
  the list in the seed, not the completion of the self-hosted interpreter: `get` and `return`
  in the functions remain to be implemented. Graphify does not yet include `selfhost/` in
  indexed graph.
## Problem confirmed
- [x] **CI Workflow: YAML step name with `:`** — Fixed to
  `.github/workflows/ci.yml` by enclosing the `name` value in quotation marks. The YAML parser
  interpreted the colon as map syntax. `git diff --check` passed;
  validation with a local YAML parser was not available.
- [x] **String interpolation: delimiting and positions** — Fixed in `syntax.jl`.
  The parser closed `$()` at the first `)` parenthesis even when it was inside a string
  of the interpolated expression, and did not update rows/columns for diagnostics and instructions
  subsequent ones. Added regression tests for parentheses in interpolated string, expressions
  multiline and error locations.
- [x] **Range with non-compliant spaces** — Fixed in `syntax.jl`: `a:b` was accepted
although the normative grammar requires the range `a:b` without spaces. Added a test
  which requires a syntax error for `1:2`.
- [x] **`!` internal to identifiers** — Fixed in `syntax.jl`: `foo!bar` was
  tokenized as a unique identifier and produced a `:undef` error in evaluation,
  instead of being rejected by the parser. Now `!` is only allowed as a final suffix;
  added regression test.
- [x] **Return inside multiline comments** — Fixed in `syntax.jl`: newlines in
  `#= ... =#` update row/column but were not kept as separators, so
  `x = 1 #= comment\n=# y = 2` failed with syntax error. Now the lexer outputs the
  separator keeping newlines inside parentheses ignored by the parser; added tests
for both cases.
- [x] **Duplicate fields in `struct`** — Fixed in `triad.jl`: a definition with names
  of duplicate fields reached the constructor, which returned a host error. The definition
  now immediately returns `Err(:type)` with the field name; added regression test.
- [x] **Nested logical query budget** — Fixed in `triad.jl`: query steps
  subqueries `not(...)` were not added to the limit of the calling query. Now the counter
  it is shared; regression test on limits 5/6. Also checked the boundaries of `depth`
  with explicit tests and the existing recursive case.
- [x] **Trace `not(...)` subqueries** — Fixed in `triad.jl`: the inner query
  was not receiving the trace collector and its `:call`/`:exit`/`:fail` events were missing.
Added tests for successful and failed subqueries.
- [x] **Launcher Windows** — `triad.cmd` could select the fake Julia executable
  in `WindowsApps`, leaving the command locked; delayed expansion could also
  alter arguments containing `!`. Now skip alias, preserve arguments and propagate
  the exit code after execution. Checked autodetection, `-v` and forwarding
  of `bang!arg`.
## Checks to be performed
### Parsers and semantics
- [ ] **[P0, IN PROGRESS] Lexers, parsers and AST** — Check token, precedence and associativity
  operators, nested delimiters, strings, comments, syntax errors, and locations
  of errors. Added AST tests for assignment and associative, lambda and ternary operators
  right-handed, logical/unary/postfix precedence, newline continuation, comma rules
  initial and Unicode/`!` identifiers. Also corrected the internal `!`, prohibited by the
  grammar and newlines lost in multiline comments; suite at 275/275. The full audit
  against the specification remains open.
- [x] **Evaluation and scope** — Check local assignment without affecting globals,
  capture and mutation of variables in closures, and local visibility of loop binding.
Added regression tests in `test/runtests.jl`; suite (251 tests) and Core compliance
  they pass.
- [x] **Functions and dispatch** — Checked more specific methods, ambiguity, builtin fallback,
  type mismatch and replacement of a redefined signature. Added test for replacement;
  suite (252 tests) and compliance already performed pass.
- [x] **Types and structures** — Checked typed and untyped fields, conversion
  Int→Float, missing types, accessing non-existent fields, signatures and value constraints. Correct
  also the case of duplicate fields; suite (253 tests) and full compliance pass.
- [x] **Closures and higher-order functions** — Parameter capture and mutation checked
  of variables captured by nested functions; the suite also covers `map`, `filter` and `reduce`.
- [x] **Logic programming** — Check facts, rules, unification/occurs-check,
  backtracking, query, and limit/depth/step options; corrected the aggregate budget
  of the sub-queries. Suite (259 tests) and Core compliance pass.
- [x] **Code as data and macro** — Check nested quasiquote/unquote, evaluation
  of the generated code, macro arguments such as AST, expansion, and `gensym`; probe with
  unquote in nested lists returns the expected result.
- [x] **Errors, contracts and effects** — Host exception conversion verified,
  propagation/interception in `try`, `Err` data, `requires`/`ensures`, purity of
  contracts and dynamic control of `io`/`state`; Dedicated tests and suites pass.
- [x] **Budgets and Tracks** — Checked budget exhaustion and nesting, boundaries of
  `depth`, function trace, resolution and negated subqueries. Corrected count of
  steps and trace propagation; suite (261 tests) and full compliance pass.
### Testing and compliance
- [x] **Full suite** — `julia --startup-file=no test/runtests.jl` passes (275 tests,
  including tests covering guards for malformed ASTs added in `e201a3e`);
  `julia --startup-file=no conformance/run.jl` passes all cases.
- [x] **Triad-Core Profile** — `julia --startup-file=no conformance/run.jl --cases
  conformance/core/cases` passes all cases.
- [ ] **Requirements Coverage** — Link each regulatory requirement from `SPEC.md` and
  `SPEC-CORE.md` to one or more tests; create minimal cases for requirements not covered.
- [x] **Oracle optional** — The suite now locates Julia, SWI-Prolog and SBCL from the `PATH`
  (with override `TRIAD_ORACLE_*`); in Debian all comparisons pass: SWI-Prolog 2/2,
  SBCL 1/1 and Julia 1/1. Oracle process execution errors no longer occur
silently converted to blank output.
### CLI, platforms and distribution
- [x] **CLI and file upload** — Checked options, evaluation, exit codes,
  `ARGS`, shebang, file resolution, errors and REPL in implementation tests and in
  compliance.
- [x] **POSIX Launcher** — In Debian checked shell syntax, symlink resolution,
  paths and arguments with spaces, `!` in arguments, search via `PATH`, override
  `TRIAD_JULIA`, `--build`, real CLI and shebang. Fixed WSL fallback selecting
  `julia.exe` Windows and failed passing Linux paths; now the launcher requires Julia
  native Linux and explicitly rejects a `.exe` override.
- [x] **Windows Launcher** — Check PATH lookup against `WindowsApps` alias, override
  `TRIAD_JULIA`, `-v` mode and forwarding arguments containing `!` through
  `bin/triad.cmd`.
- [x] **Reproducibility of seed artifacts** — Linux and Windows generators recreate
  exactly the respective hex dumps; the decoded bytes match the files
  PE/ELF versioned.
- [x] **Linux seed execution (E0)** — ELF seed executed on Debian x86_64: print
  `Triad seed Linux OK` and exits successfully; ELF hash verified.
- [x] **Portable Probes** — `_probe.jl`, `_probe2.jl`, `_probe3.jl`, `_qc.jl` and
  `_smoke.jl` run with native Julia on Debian; all complete correctly.
- [ ] **Windows seed execution** — Native CI cases remain to be executed; Defender has
  quarantined the regenerated PE in `%TEMP%` during the local test.
- [x] **Scope of `continue-on-error` in Windows CI** — Checked in
`.github/workflows/ci.yml`: option only tolerates failure of `Add-MpPreference`;
  decoding, seed cases and hash verification remain blocking.
- [ ] **Running lane seed Windows** — Verify decoding, cases and hashing
  work even when the optional antivirus exclusion is not available. Defender
  the EP not excluded in the local test got through; it remains to verify the hosted lane
  without assuming that the exclusion will succeed.
- [x] **Cross-platform CI** — Check the lanes defined in
  `.github/workflows/ci.yml` on Windows and Linux. On local Windows the suite passes
  275/275 tests and Full/Core compliance passes. In Debian 13 on WSL, Full/Core compliance and
  Julia suite pass (275/275); the Linux seed decoded into a temporary file boots
and returns the expected output, and the hash of the dump matches. The
  [run GitHub Actions #21](https://github.com/GPuntobit/triad2.0/actions/runs/39983981561)
  (`5e8ca470`, 2026-10-23) succeeded on all four jobs: Ubuntu/Windows conformance
  and Linux/Windows seeds.
  There is no need to register WSL as a self-hosted runner.
- [ ] **Standalone packaging** — Try `bin/build_standalone.jl` in a clean environment and
  check dependencies, layout and startup without Julia. Windows Isolated Trial (Julia 1.13.1):
  PackageCompiler 2.4.5 installs in the temporary depot, then the build ends with
  `TypeError` on `c_driver_program` (`nothing` where `String` is required); no executable
  is produced. Also missing are `Project.toml` and `src/Triad.jl`, which are necessary for the layout
expected by the builder. Updated README to declare prototype unavailable;
  getting the build working and trying to launch it remains open.
### Editors, tools and documentation
- [ ] **Editor integrations** — Check grammar, highlighting and recognition
  of the canonical `.triad` extension and the `.td` alias in `editors/`.
- [ ] **AI Tools** — Check CLI options, dependencies, error handling and reproducibility
  of `ai/jev_audit.mjs` and `ai/verify.jl`, without including output generated in the repository.
- [ ] **Consistent documentation** — Compare examples and commands in `README.md`,
  `TUTORIAL.md`, `SPEC.md`, `SPEC-CORE.md`, `BOOTSTRAP.md` and `STATUS.md` with the
  actual behavior and with tests. All `examples/*.td` and `*.triad` files are
  were performed with Julia; also checked the CLI commands `--version`, `-E` and `--help`.
  Corrected text about distinct POSIX/Windows launcher fallbacks in the tutorial. The README
declares the packaging limit; the complete review of tutorial, specification and status of the
  bootstrap remains to be done.
- [x] **Repositories and artifacts** — Checked `.gitignore` (standalone binaries/cache ignored)
  and `.gitattributes` (binary seeds and hex dumps not normalized as text). I
  generators play both dumps: Windows SHA-256
  `445CB428EFF44B39C2103DF776E6D9A1D1B5BDD8904C2C93D661950321C4ED60`, Linux
  `AD4C9F08176D9964D5BE17D44C72230184434025980447395E7A3250F63CA5EA`; the decoded bytes
  coincide with versioned PE/ELF. Windows PE was intentionally updated
  along with the generator and its CI hash checker.
## How to log a new bug
For each issue reproduced, add an entry with:
1. area and files involved;
2. minimal command or steps to play it;
3. current result and expected result (reference to specification, if applicable);
4. Added or updated test that prevents regression.
---
# Task S1 (Triad Interpreter in Triad-Core)
### S1.3: Tagged value system
**Description:** Implement encoding/decoding to distinguish Int, Bool, String, Nothing, List in S1.
**Details:**
- Use seed encoding (Int: shifted/tagged, Bool: 1/5, String: heap object, List: heap object)
- Implement functions for check type (is_int, is_bool, is_string, is_list)
- Implement functions for encoding/decoding (int_value, bool_value, etc.)
- Test with mixed values in the environment
**Output:** S1 can correctly distinguish and manipulate all Triad-Core types
---
### S1.4: Inline parser/tokenizer
**Description:** Read source, tokenize and recognize numbers, identifiers, operators in S1.
**Details:**
- Read source string (hardcoded input or from file)
- Tokenize: numbers, identifiers, operators (+, -, *, ==, <, >), delimiters (, (, ), ;, newline)
- Recognize keywords (if, else, while, function, let, begin, end)
- Store tokens in list for parsing
**Output:** S1 can tokenize a Triad-Core program
---
### S1.5: Eval basic expressions
**Description:** Evaluate Int, Bool, String with inline environment in S1.
**Details:**
- Implement eval for integers (basic arithmetic)
- Implement eval for Bool (logical operators)
- Implement eval for String (concatenation, string())
- Use inline environment for variable lookups
- Test with complex expressions
**Output:** S1 can evaluate basic expressions with environment
---
### S1.8: Variables with let
**Description:** Extend environment to support scoped local bindings in S1.
**Details:**
- Implement let with local scope (shadowing)
- Manage environment like frame stack
- Support nested let with correct scope
- Test with multiple scopes
**Output:** S1 supports variables with let and local scope
---
### S1.11: Full parser
**Description:** Support if/else, while, function and all Triad-Core constructs in S1.
**Details:**
- Implement if/else parsing
- Implement while parsing
- Implement function parsing (short form and block)
- Implement let/begin parsing
- Generate AST or intermediate structure inline
**Output:** S1 can parse all Triad-Core constructs
---
### S1.12: Eval complete programs
**Description:** Evaluate sequential statements with environment in S1.
**Details:**
- Implement eval of sequential statements
- Manage persistent environment between statements
- Support full program execution
- Test with programs with multiple statements
**Output:** S1 can run complete Triad-Core programs
---
### S1.13: Functions and calls
**Description:** Define functions, parameters, returns and invocation in S1.
**Details:**
- Implement function definition
- Implement call functions with parameters
- Handle explicit and implicit returns
- Support basic recursive functions
**Output:** S1 supports defining and calling functions
---
### S1.14: Closures and recursion
**Description:** Support functions that capture environment in S1.
**Details:**
- Implement environment capture in closures
- Support full recursion
- Handle correct scope in closures
- Test with lambda and higher-order functions
**Output:** S1 supports closures and full recursion
---
### S1.15: Conformance test
**Description:** Run S1 on all Core cases and verify output.
**Details:**
- Run S1 on all 33 Core cases
- Check expected output for each case
- Fix bug in S1 if necessary
- Document past/failed cases
**Output:** S1 passes the full Core conformance suite
---
## Bootstrap Tasks (S2-S4)
### S2: Native compiler
**Description:** Design architecture to compile Triad to machine code.
**Details:**
- Design intermediate IR for Triad
- Implement x86-64 codegen
- Generate PE/ELF executables
- Test on Windows and Linux
**Output:** Native S2 compiler that generates machine code
---
### S3: Self-hosting
**Description:** Implement Triad compiler written in Triad.
**Details:**
- Rewrite S2 in Triad
- Compile S2 with S2 (bootstrap)
- Check fixed points
- Test complete self-hosting
**Output:** S3 self-hosted compiler
---
### S4: Runtime complete
**Description:** Implement REPL, CLI, tooling, Linux parity.
**Details:**
- Implement interactive REPL
- Implement CLI for file execution
- Add development tooling
- Bring Linux ELF seed
- Check Linux/Windows conformance parity
**Output:** Full S4 runtime with Linux/Windows parity
---
## Priority
1. S1.3 (tagged values) - foundation for S1
2. S1.4 (parser/tokenizer) - required to run programs
3. S1.5 (eval base) - interpreter base
4. S1.8 (variables with let) - scope and binding
5. S1.11 (full parser) - all constructs
6. S1.12 (eval programs) - complete execution
7. S1.13 (functions) - language power
8. S1.14 (closures) - functional completeness
9. S1.15 (conformance test) - S1 verification
10. S2-S4 (bootstrap) - final stage
## Notes
- S1 must be implemented inline (without helper functions) due to seed limitations
- Lists in the seed only support integers - use conventions for other types
- The S1 environment uses integers as keys (1="x", 2="y", etc.)
- All S1 tasks must be tested on Windows with the current seed
---
# New tasks generated by the 2026-10-25 audit
This section integrates the previous backlog with tasks that emerged from the examination of the sources and
from local evidence. In case of conflict with older historical summaries, the
code, specification, and results reproduced here.
## Initial evidence
- Graphify: index on commit `f589f89`, 686 nodes and 1,555 relations; covers mostly
  `triad.jl`, `syntax.jl`, tests and tools, but still doesn't adequately model `selfhost/`.
  Local files were then checked directly.
- Julia runtime: **281/281 tests**, **12/12 Full cases**, **33/33 Core cases** passed.
- Seed Windows: `if_else` prints `100` and exits `1`; `lists` exits `1`; `values` and `strings`
  they pass. The seed is not yet a full Triad-Core implementation.
- Windows CI currently inconsistent: `selfhost/main.td` prints `Value: 10`, while the job
  requires `[10, 20]`.
- S1 modules: `ast.td` is not parsed by the Full runtime; `eval.td` stack overflows;
  `main.td` depends on the `get` helper absent in the Full runtime; `env.td`, `heap.td` and
`interpreter.td` are prototypes, not components of a working interpreter.
## P0 — Restore a verifiable baseline
- [x] **A01 — Align self-hosted smoke test with CI**
  - **Files:** `selfhost/main.td`, `.github/workflows/ci.yml`.
  - **Work:** the case checks the lookup of the environment; the golden CI has been aligned
    to the actual output `Value: 10\n`, compared byte by byte. The name of the step makes it clear
    that this smoke test is not equivalent to the conformance of S1.
  - **Check:** local Windows seed: exit `0`, exact stdout `Value: 10\n`, empty stderr;
    the CI step checks exit code and expected bytes.
- [x] **A02 — Fix `if_else` in Windows seed**
  - **Files:** `seed/dev/gen_seed.js`, case `conformance/core/cases/if_else/`, CI and PE dump.
  - **Work:** distinguish `elseif` from `else` when scanning, evaluate conditions
    `elseif` in sequence and skip subsequent branches after the first selected branch.
  - **Check:** `if_else`, `if_elseif`, `if_nested` and `if_no_else` pass byte by byte
    on regenerated PE; exit `0`. Conformance Core Julia: All cases pass.
  - **Artifact:** PE 25088 bytes, code 8315 bytes, SHA-256 of `seed.hex`:
    `9987105DCD56F42A1AD73451821A281E6F24374ED6CE83993BB8CA56F5EC4822`.
- [ ] **A03 — Delete invalid or recursive S1 modules**
  - **Files:** `selfhost/ast.td`, `selfhost/eval.td`, `selfhost/main.td`.
  - **Work:** remove `type AST = Int`, not present in the grammar; eliminate the
    recursive overriding of `string()` and the use of `/`, excluded from Core; don't use `get`
    as if it were a Full primitive.
  - **Acceptance:** every S1 source is valid Triad-Core, does not raise overflow and does not
    requires non-normative seed extensions; any obsolete files are removed.
- [ ] **A04 — Introduce a unique runner for the seed**
  - **File:** new development runner, `.github/workflows/ci.yml`, `conformance/`.
  - **Work:** replace manual list of 30 cases with directory discovery,
    Binary comparison of stdout and checking exit code, `args.txt` and stderr where applicable.
    Separate shared Core cases from tests specific to bootstrap primitives.
  - **Acceptance:** all present cases are executed automatically; a new case
    does not require changes to the CI; adding or modifying an incorrect golden causes the job to fail.
- [ ] **A05 — Add negative cases and limits to Core conformance**
  - **File:** `conformance/core/cases/`, `SPEC-CORE.md` §9–§10, runner seed.
  - **Job:** cover out-of-range indexes, wrong types, undefined variables, module for
    zero, unreadable file, invalid CLI and diagnostics on stderr; add overflow,
    zero value and conversion limits where the specification defines them.
  - **Acceptance:** stdout, stderr normalized if necessary and exit code are checked;
    cases move to the Full runtime when applicable and to the seed after S0 completion.
- [ ] **A06 — Make CI mandatory before new milestones**
  - **File:** `.github/workflows/ci.yml`, `STATUS.md`.
  - **Job:** lane on current commit after A01–A04 and record run, commit and
    actual results; do not rely on historical runs cited in documents.
  - **Acceptance:** conformance, Julia test, Windows seed and Linux seed are all green;
    each antivirus exception remains limited to the optional step already provided.
## P0/P1 — Complete S0 as a Triad-Core interpreter
- [ ] **S0.1 — Define and test a uniform value model**
  - **File:** `seed/dev/gen_seed.js`, `SPEC-CORE.md` §3 and §5.
  - **Work:** distinguish String and Symbol today represented by the same object; make
    `==`, `!=`, `typeof`, `string()` and print consistent for Int, Bool, String, Symbol, List,
    Function and Nothing; explicitly handle zeros and signed integers.
  - **Acceptance:** heterogeneous and nested lists print correctly; conversions e
    mixed comparisons do not crash; symbols and strings with the same text remain different types.
- [ ] **S0.2 — Complete lists and regulatory indexing**
  - **File:** `seed/dev/gen_seed.js`, `list` cases and new Core cases.
  - **Work:** implement `xs[i]` 1-based read and assignment, `length`, `push!`
    on mixed values, structural equality and dynamic capacity; keep `get` just as
    internal extension or withdraw it from the sources intended for compliance.
  - **Acceptance:** the `lists` case and the new cases of mutation, nesting, empty list,
    limits and growth beyond 64 items pass without memory corruption.
- [ ] **S0.3 — Implement bootstrap strings and primitives**
  - **File:** `seed/dev/gen_seed.js`, seed specific tests.
  - **Work:** add escape `\n \t \" \\`, `length`, `readfile`, `strlen`, `strbyte`,
    `strsub` and `exit`; respect UTF-8 indices and bytes defined by `SPEC-CORE.md`.
  - **Acceptance:** byte-exact tests for empty strings, escapes, multibyte UTF-8, substrings
    at limits, I/O errors and reread content; no dependencies on Julia or Node at runtime.
- [ ] **S0.4 — Complete flow control, scopes and closures**
  - **File:** `seed/dev/gen_seed.js`, Core cases.
  - **Work:** implement explicit `return`, `break`, `continue`, `-=`, `*=`, lambda a
    zero/multiple parameters and multiple `let`; replace single/per-value capture with frame
    shared lexicons as required by the specification.
  - **Acceptance:** regressions for nested return, nested loops, shadowing, closure
    mutables with more binding, recursion and higher-order calls pass on the seed.
- [ ] **S0.5 — Complete CLI, `ARGS` and diagnostics**
  - **File:** `seed/dev/gen_seed.js`, `SPEC-CORE.md` §8–§10.
  - **Works:** support multiple and quoted arguments, `ARGS`, script from stdin with `-`,
    multi-argument `print`, stderr and exit `0/1/2`; prevent every error from ending without
    diagnostic message.
  - **Acceptance:** Windows cases with spaces in paths/arguments, stdin, invalid use, file
    missing and runtime errors produce expected streams and exit codes.
- [ ] **S0.6 — Make memory and seed parsers robust**
  - **File:** `seed/dev/gen_seed.js`, negative tests and development fuzz.
  - **Work:** check source, heap, frame, function and list bounds; manage arena
    exhausted and recursion; reject partial tokens/keywords, nested comments, and input
    malformed without reading past the buffers.
  - **Acceptance:** no crash or `STATUS_ILLEGAL_INSTRUCTION` in borderline cases; errors
    deterministic with exit `1`; PE layout, relocations and reproducibility remain verified.
- [ ] **S0.7 — Formally close the M3 milestone**
  - **Dependencies:** A01–A06 and S0.1–S0.6.
  - **Acceptance:** all positive and negative Core cases and all primitive tests
    bootstrap pass on the PE decoded from just `seed.hex`; `STATUS.md`, `BOOTSTRAP.md`,
    `seed/README.md`, `TUTORIAL.md`, dump and hash report the same status.
## P1 — Build S1 as a truly self-hosted deployment
- [ ] **S1.0 — Define architecture, format and unique entrypoint**
  - **Files:** `selfhost/`, `BOOTSTRAP.md`.
  - **Work:** consolidate prototypes into a pipeline `lexer → parser/AST → evaluator →
    runtime/CLI`; define encoding of values, nodes, environments and errors using only Core types.
    Determine how to compose the modules without an `include` not foreseen by the seed.
  - **Acceptance:** a versioned entrypoint loads and runs a minimal program via
    seed; each module has a contract and a test; no stubs presented as features.
- [ ] **S1.1 — Implement Triad-Full lexers and parsers in Core**
  - **Dependencies:** S0.3, S0.7, S1.0.
  - **Work:** tokenize all `SPEC.md` lexicon, build AST with positions,
    precedences, blocks, types, logical terms, quotas and macros; represent errors as data.
  - **Acceptance:** differential AST tests against `syntax.jl` for the entire grammar;
    Malformed input produces `Err(:syntax)` with row/column without terminating the seed.
- [ ] **S1.2 — Implement evaluators, environments and functions**
  - **Dependencies:** S0.4, S1.1.
  - **Work:** evaluate literals, operators, assignments, indexes, blocks, scope, closure,
    `return`/`break`/`continue`; implement generic functions, builtins and calls.
  - **Acceptance:** S1 runs above S0 all Core cases and Full evaluation tests without
    delegate parsing or evaluation to the Julia runtime.
- [ ] **S1.3 — Implement types, structs and multiple dispatch**
  - **Dependencies:** S1.2.
  - **Work:** represent hierarchy, declared constraints, conversions, immutable structs,
    method selection, builtin fallbacks, and ambiguity errors.
  - **Acceptance:** pass `dispatch`, `tasting` and regressions equivalent to those of
    `test/runtests.jl`, including Int→Float, redefinition and ambiguous signatures.
- [ ] **S1.4 — Implement the logic engine**
  - **Dependencies:** S1.2.
  - **Work:** facts/rules, terms, unification with occurs-check, trail/backtracking,
    negation, `is`, queries, solutions, limit/depth/steps and iterative engine.
  - **Acceptance:** pass `family`, `prolog`, recursive queries and budget/trace tests;
    no infinite logical recursion causes host or seed overflow.
- [ ] **S1.5 — Implement macros, errors, contracts, effects, budgets and tracks**
  - **Dependencies:** S1.2–S1.4.
  - **Work:** cover quasiquote/unquote, `Expr`, `eval`, `gensym`, `try`/`throw`, `Err`,
    `requires`/`ensures`, `with`, events and dynamic control of `io`/`state`.
  - **Acceptance:** pass `macro`, `macro_eval`, `error`, `core_guarantees`, `tour` and i
    corresponding semantic tests; Nested effects and budgets retain their scope.
- [ ] **S1.6 — Implement self-hosted CLI and REPL**
  - **Dependencies:** S1.2–S1.5, S0.5.
  - **Jobs:** replay `SPEC.md` §14: sorted options, `ARGS`, stdin, shebang, query
    interactive, REPL commands, diagnostics and exit codes.
  - **Acceptance:** the same CLI/REPL array as the Julia runtime passes to S1 above S0;
    `.triad` and `.td` files are equivalent.
- [ ] **S1.7 — Closing M4 without Julia**
  - **Dependencies:** S1.0–S1.6.
  - **Work:** implement `triad --conformance DIR` in Triad and use committed goldens;
    run all the examples and the 12 Full cases via the `seed.hex + S1` chain alone.
  - **Acceptance:** a CI lane performs compliance without installing Julia/Node; the
    result is byte-exact and the documentation clearly distinguishes stage0 and self-host.
## P2 — Compilation, portability and completion of the product
- [ ] **S2.1 — Specify native compiler IR and ABI**
  - **Dependencies:** S1.7.
  - **Job:** define value representation, frames, calls, allocation, runtime,
    PE/ELF layout, exceptions/checking and debug strategy before codegen.
  - **Acceptance:** Regulatory/implementation document with IR testing and full mapping
    of Triad constructs; no dependency on C/Rust/Julia in the final chain.
- [ ] **S2.2 — Implement x86-64 codegen and close M5**
  - **Dependencies:** S2.1.
  - **Work:** compile S1 into native Windows/Linux executables, link the runtime and
    add differential tests between interpreted S1 and compiled S1.
  - **Acceptance:** Compiled S1 passes all conformance without the seed; dumps and binaries
    playable, with testing on both platforms.
- [ ] **S3.1 — Demonstrate the fixed point and close M6**
  - **Dependencies:** S2.2.
  - **Work:** compile the compiler with itself for at least two generations and compare
    artifacts or canonical hashes; remove the seed from the normal build and use path.
  - **Acceptance:** generation N and N+1 equivalent, green conformance and procedure
    bootstrap documented and repeatable by clean checkout.
- [ ] **S4.1 — Port the full runtime to Linux and close M7**
  - **Dependencies:** S2.2; Don't limit yourself to the current ELF E0.
  - **Work:** Complete syscall/OS layer, files and arguments, REPL, diagnostics and tests
    multiplatform; evaluate macOS/ARM only as an explicit next milestone.
  - **Acceptance:** same Full/Core conformance, same examples and same green CLI on Windows
    and Linux without Julia; no cases silently skipped over.
## Transversal quality and recognition
- [ ] **Q01 — Create a requirement → implementation → test matrix**
  - **Files:** `SPEC.md`, `SPEC-CORE.md`, `test/`, `conformance/`.
  - **Work:** assign an ID to regulatory requirements and link them to positive/negative tests;
    complete the parser audit and explicitly report what is informative or not
    implemented.
  - **Acceptance:** each requirement has at least one verification or a reasoned open gap; the
    matrix is checked in CI to avoid references to non-existent tests.
- [ ] **Q02 — Realign all documentation to measured state**
  - **Files:** `TASK.md`, `STATUS.md`, `BOOTSTRAP.md`, `README.md`, `TUTORIAL.md`, `seed/`, `ai/`.
  - **Work:** fix contradictory counts, hashes, sizes, S0/S1 claims and roadmaps;
    also fix the tutorial code block around §19.5.5/§20 and the wording
    «S0 completed»; archive historical handoffs without using them as current state.
  - **Acceptance:** an automatic check gets counts/hashes from files and no documents
    active declares complete functionalities denied by tests.
- [ ] **Q03 — Make AI tools reproducible and up-to-date**
  - **Files:** `ai/jev_audit.mjs`, `ai/verify.jl`, prompts and tasks.
  - **Work:** replace hardcoded results 243/29/25 with generated data or parameters
    explicit; fix roles calling Core the Full runtime; test dry-run,errors
    API, absent paths and exit codes; keep generated outputs outside of Git.
  - **Acceptance:** local tests without network cover success and failure; no facts
    obsolete is sent as ground truth; benchmarks measure the declared profile.
- [ ] **Q04 — Complete or retire Julia standalone packaging**
  - **File:** `bin/build_standalone.jl`, launcher and documentation.
  - **Work:** create layout `Project.toml`/`src/Triad.jl` if keeping PackageCompiler,
    fix `c_driver_program`, precompilation and `--build`; otherwise remove the
    unsupported path without confusing it with self-hosted S2.
  - **Acceptance:** from a clean environment the executable starts without Julia installed and passes
    a CLI suite; or any reference to packaging is removed and the command is not promising
    a non-existent build.
- [ ] **Q05 — Validate and publish the tooling editor**
  - **File:** `editors/`, examples and grammar.
  - **Work:** Automatically test TextMate/Vim tokens on all constructs and on
    `.triad`/`.td`; verify VSIX package and installation; prepare the PR Linguist without
    appropriate the `.td` extension of LLVM TableGen.
  - **Acceptance:** green grammars test, installable package, instructions
    reproduced and the status of external publications recorded separately from the code.
- [ ] **Q06 — Clean up and secure the repository**
  - **Files:** `.gitignore`, `.gitattributes`, `.vs/`, probe and `test_*.td` in the root, `out.txt`.
  - **Work:** move useful probes into structured tests, eliminate IDE and output artifacts
    empty from versioning, ignore `.vs/` and other local directories; preserve seed dumps
    as sources and check their hashes.
  - **Acceptance:** clean checkout without personal caches; no regression lost during
    displacement; CI ensures that generated binaries and reports are not pushed back into Git.
## Recommended execution order
1. **A01–A06:** First a reliable CI on the real state.
2. **S0.1–S0.7:** Complete the Core contract before expanding S1.
3. **S1.0–S1.7:** a single end-to-end verified self-hosted interpreter.
4. **S2.1–S4.1:** Linux compilation, fixed point and parity.
5. **Q01–Q06:** transversal activities, anticipated when they unlock checks or releases.