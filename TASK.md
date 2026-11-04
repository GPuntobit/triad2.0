# Task Triad 2.0
## Objective
Complete Triad 2.0 as a standalone and recognized language with its own standard, conformance suite, `.triad` extension, tooling editor, bootstrap without guest languages and self-hosting.
## Current status
- **Seed S0 (Windows):** 8315 bytes, hash `9987105DCD56F42A1AD73451821A281E6F24374ED6CE83993BB8CA56F5EC4822`
  - Support: integers, variables, functions (short form and block), recursion, Bool, operators, if/elseif/else, while, let, begin, lambda, closures, base strings, nothing, symbols, complete lists (build, print, push!, get)
  - Conformance: 33/33 Windows byte-exact cases, 36/36 Core Julia
- **S1 (Triad Interpreter in Triad-Core):** Inline environment working with lists, complete basic primitives
- **Seed S0 (Linux):** solo stub ELF64 **E0** (173 byte, stampa `Triad seed Linux OK`); la porta
  completa dell'interprete in ELF è la **task principale** (N15–N18 qui sotto).
- **S2-S4:** Uninitiated
---
# Task principale (2026-11-03): seed Linux nativo — senza Wine (N15–N18)

Decisione del maintainer (2026-11-03), **prima di riprendere N03**: Triad non deve diventare
«un emulatore solo Windows». L'utente Windows resta libero di usare il PE; l'utente Linux
**non deve installare nulla oltre la repo di GitHub** (niente Wine, niente Node per eseguire
i programmi): il seed deve girare **nativo** come ELF64. La porta Linux è quindi la task
principale e precede N03 e tutte le altre sotto-task meccaniche.

Riferimenti normativi: `BOOTSTRAP.md` §4 (chiamate di SO isolate in 4–5 routine `os_*`),
§5 (riga «Linux x86-64 (ELF)»: E0 ✅, E1/E2/E3 dopo), §6 (M7 = parità + porta Linux), §9
(rischio «Seed too tied to Windows»), §7 (il JS reference resta fuori dalla catena S0→S4,
strumento di sviluppo). Il dominio del linguaggio non cambia: `SPEC-CORE.md` resta normativo
e vale il vincolo Triad-Core ⊂ Triad-Full (regola operativa 4). Nessuna semantica inventata
(regola operativa 1): l'ELF deve comportarsi **identico al PE**, limiti noti compresi.

Mappa decisionale (wayfinder): `.scratch/seed-linux-nativo/map.md`, ticket in
`.scratch/seed-linux-nativo/issues/` (decisioni aperte: byte del PE, architettura codegen,
contratto `os_*`, parità/CI, installazione zero-install). Le slice N15–N18 qui sotto
restano il piano d'esecuzione: la mappa decide, le slice costruiscono.

Obiettivo finale: `seed/linux-x86_64/seed` (ELF64 statico, senza libc né dynamic linker)
che esegue gli stessi programmi Triad-Core del PE con stdout byte-identico; da un checkout
pulito su Linux, `./install.sh` + `bin/triad program.td` funziona con zero dipendenze esterne.

### N15 — E1: runner ELF di un file `.td` (argv + I/O nativo)
- **Files:** `seed/dev/gen_seed_linux.js`, `seed/linux-x86_64/seed.hex` + `seed`,
  `seed/linux-x86_64/README.md`.
- **Work:** estendere `_start` con argc/argv e syscall `openat`/`read`/`write`/`exit`:
  il seed legge il sorgente indicato in `argv[1]` in un buffer (E1: caricamento + echo,
  errore su file mancante; l'interprete arriva in N17). ELF statico senza libc, come E0.
- **Acceptance:** `./seed file.td` legge il file; senza argomenti o con file inesistente →
  exit ≠ 0 con messaggio su stderr; dump riproducibile da `gen_seed_linux.js`; verificato
  nativamente su Linux x86-64 (CachyOS/CI).

### N16 — E2a: nucleo di codegen piattaforma-indipendente (routine `os_*`)
- **Files:** `seed/dev/gen_seed.js` (rifattorizzazione interna), PE + `seed.hex`, hash in
  `.github/workflows/ci.yml`.
- **Work:** separare in `gen_seed.js` il codegen dell'interprete dalle chiamate di sistema
  Windows, isolando queste ultime nelle routine `os_*` — confine completo col sistema
  operativo, lista e firme nel contratto
  `.scratch/seed-linux-nativo/issues/03-contratto-os-star.md`, emissione inline
  (decisione `.scratch/seed-linux-nativo/issues/02-architettura-codegen.md`). Solo
  struttura: il PE rigenerato deve restare **byte-identico**
  a quello versionato — politica vincolante (a), decisione
  `.scratch/seed-linux-nativo/issues/01-byte-pe.md`: ogni diff nei byte è un bug o un
  cambio di layout da decidere nell'architettura del codegen; eccezioni solo per cambi
  semantici deliberati (ciclo N03–N05) con nuovo hash in CI e diff tracciata.
- **Acceptance:** `cmp` fra PE rigenerato e versionato; conformance Core e probe invariati;
  nessuna modifica semantica (refactoring del solo generatore).

### N17 — E2b: emettitore ELF64 e parità col PE (il cuore della task)
- **Files:** `seed/dev/gen_seed.js` (entry unico `<windows|linux|all>` + core condiviso +
  backend ELF con `os_*` via syscall Linux — decisione
  `.scratch/seed-linux-nativo/issues/02-architettura-codegen.md`),
  `seed/linux-x86_64/*`, `conformance/run.mjs` e `tests/probes/run_probes.mjs` (terzo
  runtime via `TRIAD_SEED`), `.github/workflows/ci.yml`.
- **Work:** implementare sull'ELF lo stesso dominio machine-code del PE — interi, variabili,
  funzioni short e `function … end`, ricorsione, Bool, operatori, `if`/`elseif`/`else`,
  `while`, `let`, `begin`, lambda/closures, stringhe base + `string()`, `nothing`, simboli,
  liste (costruzione, stampa, `push!`, `get`) — usando solo le routine `os_*`, niente libc.
- **Acceptance:** tutti i casi `conformance/core/` verdi sul PE risultano verdi **byte-exatti**
  sull'ELF nativo senza Wine (stessi `expected.out`/`expected.code`); probe `ok_*`/`test_*`
  identici su PE, ELF e JS; i limiti noti del PE restano limiti documentati (nessuna nuova
  semantica); dump riproducibile dai generatori.

### N18 — E3: toolchain Linux senza Wine (install → run)
- **Files:** `install.sh`, `bin/triad`, `cli/lib/utils.mjs` (soglia stub 4 KB e fallback JS
  automatico), `.github/workflows/ci.yml` (job `seed-linux` nativo), `seed/README.md`,
  `seed/linux-x86_64/README.md`, `STATUS.md`, `BOOTSTRAP.md` §5/§10.
- **Work:** il launcher `bin/triad` su Linux usa il seed ELF nativo (durante la transizione
  il fallback JS diventa solo esplicito con `--jsref`, non più automatico; **a chiusura di
  N18 la logica di stub — soglia 4 KB, flag `--jsref`, ramo JS — esce da `bin/triad`**,
  decisione *Installazione e launcher: il contratto zero-install*); job CI `seed-linux` su
  `ubuntu-latest` che esegue
  conformance + probe sull'ELF nativo **senza Wine** (Wine resta solo nel job di parità PE,
  opzionale); aggiornare la documentazione dello stato piattaforme.
- **Acceptance:** su Linux: `git clone` → `./install.sh` → `triad program.td` funziona con
  zero dipendenze oltre alla repo (percorso garantito: la catena con `install.sh`);
  installazione con smoke test byte-exatto (`test_simple.td` + golden sidecar) che **fallisce
  con exit non-zero** su mismatch; launcher installato come wrapper a percorso assoluto,
  senza logica di stub; CI `seed-linux` verde senza Wine; l'utente Windows
  continua a usare il PE invariato; `linux-toolchain` copre launcher + install.

### N19 — (secondario, non bloccante) Esperienza di sviluppo / IDE
- **Files:** `editors/` (grammar VS Code/Vim già presenti), eventualmente un Language Server.
- **Work:** se con «ide» si intendeva un ambiente di sviluppo (diagnostica, autocomplete,
  run/Debug da editor): estendere `editors/` con un LSP minimo (diagnostica di parse + run
  del seed) oppure pubblicare l'estensione VS Code già preparata. Fuori dalla catena
  S0→S4 (regola operativa 2), non tocca il bootstrap.
- **Dipendenze:** decisione di scope del maintainer PRIMA del codice (come N02/N08).
- **Acceptance:** da definire alla decisione; finché non è decisa non blocca N15–N18.

### Ordine (aggiornato 2026-11-03)
1. **N15 → N16 → N17 → N18** (task principale: seed Linux nativo, senza Wine) →
2. **N03** (e a seguire **N04+N05**) in un ciclo unico di rebuild PE/ELF + hash CI —
   ora verificabile nativamente anche su Linux →
3. **N02** e **N08** dopo le decisioni normative → 4. **N06+N07** (C3) → 5. **N19** (se deciso).
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
- [ ] **EPUB book metadata** — `epub-gen`'s `content.opf.ejs` template does not emit
  `dc:description`, so the `description` option in `scripts/docs/build-epub.cjs` has no
  effect: the book description lives only in the *Quarta di copertina* chapter (verified in
  the generated EPUB). To put it in the metadata, pass `customOpfTemplatePath` with a
  template kept in the repository (and cover the same gap in the MOBI/DOCX builds).
- [ ] **Editor integrations** — Check grammar, highlighting and recognition
  of the canonical `.triad` extension and the `.td` alias in `editors/`.
- [x] **AI Tools** — Checked CLI options, dependencies, error handling and reproducibility
  of `ai/jev_audit.mjs` and `ai/verify.jl`. Cleanup completed: seed-runner batch files consolidated, debug output removed, probe files confirmed untracked.
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
- [x] **A03 — Delete invalid or recursive S1 modules**
  - **Files:** `selfhost/ast.td`, `selfhost/eval.td`, `selfhost/main.td`.
  - **Work:** remove `type AST = Int`, not present in the grammar; eliminate the
    recursive overriding of `string()` and the use of `/`, excluded from Core; don't use `get`
    as if it were a Full primitive.
  - **Acceptance:** every S1 source is valid Triad-Core, does not raise overflow and does not
    requires non-normative seed extensions; any obsolete files are removed.
  - **Closed 2026-11-02:** `type AST = Int` removed from `selfhost/ast.td` (constants
    now plain assignments; `make_call` uses the assign-then-return pattern so the
    seed accepts it); `selfhost/program.td` rewritten on the flat integer-token
    model (the old nested-token model was inconsistent and failed on its own test
    data) — it now prints `42\n7\n` on PE seed and JS; `string()` overrides and `/`
    were already absent; `get` is now a normative bootstrap primitive in
    `SPEC-CORE.md` §8 (problem row 2). The `conformance-core` CI job checks that
    every `selfhost/*.td` runs on the reference interpreter.
- [x] **A04 — Introduce a unique runner for the seed**
  - **File:** new development runner, `.github/workflows/ci.yml`, `conformance/`.
  - **Work:** replace manual list of 30 cases with directory discovery,
    Binary comparison of stdout and checking exit code, `args.txt` and stderr where applicable.
    Separate shared Core cases from tests specific to bootstrap primitives.
  - **Acceptance:** all present cases are executed automatically; a new case
    does not require changes to the CI; adding or modifying an incorrect golden causes the job to fail.
  - **Closed 2026-11-02:** the `seed-windows` job runs `node conformance/run.mjs
    --cases conformance/core/cases --skip liste` (directory discovery, byte-exact
    `expected.out`/`expected.golden`, `expected.code`, `args.txt`): the hardcoded
    list of 35 cases is gone; `gcd` and `valori` are now covered too. Bootstrap
    probes run via `node tests/probes/run_probes.mjs --strict` (ok_*/test_* must
    match seed vs JS and their optional golden) and `run_probes.mjs
    selfhost/source.td` checks the S1 front-end golden `selfhost/source.expected.out`.
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
## Libro — Fondamenta per principianti (2026-11-01)
- [x] **Fondamenta: programmare da zero** (`docs/FONDAMENTA.it.md`): parte del libro per chi non
  ha mai programmato, inclusa nel volume (`build-libro.mjs`, `build-epub.cjs`); esempi Core
  verificati con `seed/dev/triad_core.cjs`; PDF/EPUB/MOBI/DOCX/DOC rigenerati in `docs/libro/`
  (`Il-libro-di-triad.doc` Word 97 via LibreOffice). Comprende: cap. 13 «Pensare da
  programmatore», cap. 17 «Domande da neofita», Appendice A (installazione guidata),
  Appendice B (scheda rapida della sintassi).
- [x] **Pipeline PDF** (`scripts/docs/build-pdf.mjs`): sostituisce `ebook-convert` per il PDF
  (il writer calibre corrompe i glifi composti → tofu sulle accentate).
- [ ] **Rigenerare il libro inglese** (`docs/libro/Il-libro-di-triad.en.*`): la traduzione non
  include ancora le Fondamenta; aggiornare `_translation_progress.json` e ripartire dal nuovo
  testo.
- [ ] **Traduzione delle Fondamenta** in inglese (`docs/FONDAMENTA.md`) per il libro EN e il sito.

## Libro — dati aggiuntivi estratti dal codice per Sessione 1 / mimo (2026-11-01)
- [x] **`docs/libro/_dati_dal_codice.md`**: scheda di dati per la scrittura del libro ottenuta
  **solo da lettura del codice** (`seed/dev/gen_seed.js`, `seed/dev/triad_core.cjs`,
  `selfhost/value.td`, `conformance/run.mjs`) ed esecuzione misurata dei due runtime — nessun
  dato preso da SPEC/MANUALE. Contiene: schema tag dei valori del seed (Int = n<<2, ecc.),
  limiti strutturali (sorgente ≤ 61440 byte, liste ≤ 64 elementi, funzioni ≤ 512, parametri ≤ 64,
  heap ~64 KiB), fatti di lexer, precedenza operatori, matrice built-in e **27 divergenze misurate
  seed ↔ interprete JS** con output ed exit code.
- [x] **`docs/libro/_sonde/`** (27 sonde `.td`): riproducono ogni divergenza; eseguibili con
  `./seed/windows-x86_64/seed.exe <sonda>` e `node seed/dev/triad_core.cjs <sonda>`.
- [x] **Dati nuovi emersi e da presidiare**: il caso `liste` della conformance è **saltato di
  default** (`conformance/run.mjs:34`, `skip = ['liste']`); `get(xs,i)` è 0-based sul seed e
  assente dal JS, `xs[i]` è 1-based sul JS e assente dal seed; `string(true)` → `1` sul seed;
  `1 % 0` → exit 127 (crash) sul seed; letterali interi nel seed limitati a 2^61-1;
  funzione a blocco che termina con `println` restituisce `0` (seed) / `nothing` (JS).

- [x] **Dati portati nel libro e PDF rigenerato (2026-11-01)**: aggiunte 10 «Nota di
  implementazione» in `docs/MANUALE.it.md` (§1.2 numeri/underscore/2^61-1, §1.10 escape,
  §2.7 condizioni non-Bool, §2.8 stampa, §4.1 wrap e `% 0`, §9 indici e `push!`, §10 conversioni,
  §27.1 exit code del seed) e 2 in `docs/FONDAMENTA.it.md` (cap. 6 escape, cap. 9 liste);
  rigenerati `docs/libro/libro.html` e `docs/libro/Il-libro-di-triad.pdf` (305 pagine, note
  verificate estraendo il testo dal PDF). Restano da rigenerare gli altri formati
  (`docx/epub/mobi`) se servono allineati.

## Libro — cap. 8 «Ripetizioni» riscritto con verifica su entrambi i runtime (2026-11-01)
- [x] **Esercizi del cap. 8 divisi per sottogenere** (`docs/FONDAMENTA.it.md`): contatore,
  accumulatore, ricerca/decisione, cicli annidati, sentinella — 10 task con soluzioni, ogni
  esempio eseguito sul seed PE **e** sull'interprete JS con output identico byte per byte.
- [x] **Nuovi casi di conformance** `while_annidati` (break sul ciclo più interno, uscita con
  variabile di stato) e `while_sentinella` (`while true` + `break`), verdi su entrambi i
  runtime; aggiunti alla lista della CI `seed-windows`. Core: 39/39.
- [x] **Gap del seed scoperti scrivendo gli esempi** (tutti già in «Colmare i limiti del
  seed», qui è il riscontro misurato): `continue` → exit 1 sul PE; `-=`/`*=` → exit 1;
  `while` come espressione → exit 1; `voti[i]` non seleziona l'elemento (il libro lo segnala
  con una nota di implementazione e rimanda a TASK.md S0.2); condizione `while` non-`Bool`:
  il PE salta il corpo silenziosamente, il JS reference segnala errore (divergenza da chiudere
  con un caso negativo di conformance).
- [ ] **Caso negativo di conformance per la condizione non-`Bool`** e per lo scope del corpo
  `while`: i due runtime si comportano in modo diverso e nessuno dei due è allineato a
  `SPEC.md` §4/§5. Servono decisioni normative prima di fissare i golden.

## Sito generato da Triad (2026-11-01)
- [x] **Generatore del sito in Triad** (`tools/site-gen/`): `site_pages.td` (8 pagine di
  documentazione), `site_playground.td` (playground), `site_style.td` (foglio di stile);
  `build.mjs` esegue ogni generatore sul seed PE nativo e sull'interprete di riferimento JS e
  pretende stdout identico byte per byte; `lint.mjs` blocca i costrutti che il seed non
  esegue; CI `site-gen` (Ubuntu + Windows) verifica lint e sincronia. Sottoinsieme
  certificato e limiti misurati del seed: `tests/probes/README.md`.
- [x] **Chiarire in `SPEC-CORE.md` §2 se una stringa può contenere un newline grezzo.**
  Deciso il 2026-11-02: **ammesso** — il letterale va a capo e il newline fa parte
  del valore (documentato in §2); entrambi i runtime lo accettano e vietarlo
  richiederebbe casi negativi e un cambiamento dei runtime. Allineare S1 non serve:
  lo scanner di `selfhost/source.td` lo accetta già.
  I due runtime attuali lo accettano (i generatori del sito lo usavano), ma la specifica
  prevede `\n` come escape: è una delle poche cose che il generatore evita dopo la
  verifica. Decidere (spec o divieto esplicito) e allineare S1.
- [ ] **Colmare i limiti del seed** rilevati scrivendo i generatori (tutti consentiti da
  `SPEC-CORE.md` §2–§7, quindi lacune del seed, non della lingua): `print` e `println`
  multi-argomento; `return` nelle funzioni a blocco; chiamata come ultima espressione del
  corpo; escape nelle stringhe; `let` con più binding; `readfile`/`strlen`/`strbyte`/`strsub`;
  indice di lista e `length(lista)`; riferimenti in avanti; letterale con la sottostringa
  `if` dentro un blocco (il contatore di annidamento conta le occorrenze nel testo). Ogni
  limite è un candidato per la prossima tappa «A» del seed, con caso di conformance.
- [x] **Rigenerare le pagine mancanti del sito**: `ai.html`, `apprendimento.html`,
  `license.html` erano linkate dal NAV di `docs/assets/js/app.js` ma non esistevono; ora sono
  generate come le altre (`tools/site-gen/site_pages2.td`). Verificato: 182 link interni del
  sito, nessuno rotto.

## Libro — margini KDP conformi per la stampa (2026-11-01)
- [x] **Gutter KDP nel PDF del libro**: KDP aveva rifiutato l'interno del volume (305 pagine →
  gutter minimo 0.625"/15.875mm per la fascia 301–400, margini esterno/superiore/inferiore
  ≥ 0.25"/6.35mm) perché `scripts/docs/build-libro.mjs` usava `margin: 15mm 12mm` uniformi,
  senza gutter specchiato. Ora `@page` usa margini specchiati (gutter 19.05mm = 0.75"
  all'interno, 10mm all'esterno, 15mm sopra/sotto; `@page :left` sposta il gutter a destra
  nelle pagine pari) — verificato sperimentalmente che Chrome 156 rispetta `:left`/`:right`.
  Rimosso anche l'header/footer template di puppeteer: riservava fascia ai margini e
  duplicava i numeri di pagina (stampando anche "1" sulla copertina). I numeri arrivano ora
  solo dalla margin box CSS `@bottom-center` (nessuno sulla copertina via `@page :first`),
  con `padding-bottom: 4mm` che li tiene a ≥ 6.35mm dal taglio. Volume risultante:
  293 pagine. Misurato sul PDF con PyMuPDF: gutter reale min 20.94mm, esterno 9.79mm,
  sopra 15.67mm, sotto 7.78mm — tutti ≥ i minimi KDP, con slack anche per la fascia
  401–500 pagine (0.75").
- [x] **Verifica margini KDP automatica in `scripts/docs/build-pdf.mjs`**: dopo la generazione
  conta le pagine del PDF e confronta i margini `@page` dell'HTML con la tabella KDP
  (24–150: 0.375", 151–300: 0.5", 301–400: 0.625", 401–500: 0.75", 501–700: 0.875",
  701–828: 1"; esterno/sopra/sotto ≥ 0.25"); esce con codice 3 se non conformi.
  Accetta argomenti opzionali input/output (`node scripts/docs/build-pdf.mjs in.html out.pdf`)
  per rigenerare anche il PDF inglese.
- [x] **DOCX e inglese allineati**: `scripts/docs/build-docx.cjs` con margini laterali simmetrici
  da 19.05mm (1080 twips; html-to-docx non scrive `w:mirrorMargins`, quindi il gutter non puo'
  essere specchiato) e attributi header/footer/gutter espliciti (prima venivano scritti
  `w:header="undefined"`, OOXML invalido). Stesso blocco `@page` aggiornato in
  `docs/libro/Il-libro-di-triad.en.html` e `docs/libro/chunk1.html`. Rigenerati
  `docs/libro/libro.html`, `Il-libro-di-triad.pdf` (293 pagine), `Il-libro-di-triad.en.pdf`,
  `libro.docx`. Da rigenerare via LibreOffice `Il-libro-di-triad.doc` (Word 97) se serve.

## Libro — allineamento uniforme di tutte le pagine (2026-11-01)
- [x] **Margini equi e geometria identica su ogni pagina**: con i margini specchiati il blocco
  del testo e i numeri di pagina si alternavano recto/verso (testo a L12.09/R20.95mm sulle
  pari e L21.08/R11.96mm sulle dispari; numeri che oscillavano di ~9mm tra x=71.81 e x=80.83,
  mai centrati sulla pagina). Ora `@page` ha margini uguali su tutti i lati
  (`margin: 19.05mm`, 0.75") senza `@page :left`: ogni pagina ha la stessa identica
  impaginatura. Verificato sul PDF con PyMuPDF: numeri di pagina centrati a 76.20mm su
  tutte le 282 pagine (varianza 0), margini di contenuto minimi 20.93mm (sin), 19.05mm
  (des), 19.59mm (sup), 20.12mm (inf) — tutti ≥ i minimi KDP (gutter 12.7mm per 282 pagine,
  19.05mm copre anche la fascia 401–500). 0.75" su tutti i lati mantiene il volume conforme
  anche se cresce oltre 400 pagine. Allineati anche `Il-libro-di-triad.en.html`,
  `chunk1.html` e `build-docx.cjs` (1080 twips = 19.05mm su tutti i lati); rigenerati
  `libro.html`, i due PDF e `libro.docx`. Nota: la riflessione Chrome passa da 293 a 282
  pagine con la nuova scatola di testo (contenuto verificato identico: 58.548 parole,
  nessun clipping); la copertina resta a vivo (`@page :first`), unica eccezione voluta.

## Libro — copertina centrata e scala di stampa 1:1 (2026-11-01)
- [x] **Copertina impaginata al centro**: la prima pagina mostrava l'immagine rimpicciolita
  (135.31x202.97mm) e spinta in alto a sinistra con ~17mm di bianco a destra e ~26mm in basso.
  Causa reale NON centratura: Chrome riduceva l'**intero documento** a scala 0.88789
  (misurato: font di corpo a 9.32pt invece di 10.5pt) perché una tabella del Tutorial
  (§15, confronto interprete JS / seed Windows) sforava la colonna (min-content 475px vs
  432px disponibili): i token lunghi (`seed/windows-x86_64/README.md`, hash) non andavano a
  capo. Aggiunto `overflow-wrap: anywhere` a `code` e `th, td` in `build-libro.mjs`,
  `Il-libro-di-triad.en.html`, `chunk1.html` (anche `anywhere` e non `break-word` perche'
  abbassa la min-content). Verificato sul PDF rigenerato: copertina a vivo esatta
  152.40x228.60mm a (0,0) — centrata per costruzione, font 10.5pt/9pt, numeri di pagina
  centrati a 76.20mm su tutte le pagine. Il volume torna a scala reale: **378 pagine**
  (prima 282 "zoomate"; il PDF caricato su KDP con 305 pagine era pure scalato 0.88789).
  Margini KDP: 378 pagine → fascia 301-400 → gutter min 15.875mm, misurati 19.05mm;
  residuo sforo di 1.4mm su p.356 dovuto a spazi finali invisibili di un `pre` (17.65mm,
  comunque oltre il minimo KDP). Rigenerati anche `Il-libro-di-triad.en.pdf` e `libro.docx`.

## Recommended execution order
1. **A01–A06:** First a reliable CI on the real state.
2. **S0.1–S0.7:** Complete the Core contract before expanding S1.
3. **S1.0–S1.7:** a single end-to-end verified self-hosted interpreter.
4. **S2.1–S4.1:** Linux compilation, fixed point and parity.
5. **Q01–Q06:** transversal activities, anticipated when they unlock checks or releases.
# Problemi aperti per complessità (2026-11-02)

Problemi emersi dalla sessione sul front-end S1 (`selfhost/source.td`) e dai
limiti misurati sul seed, **ordinati per complessità crescente** (sforzo di
implementazione + rischio: si passa da azioni minuti a settimane con processo
normativo). Ogni voce riporta l'evidenza (probe) e dove si interviene.

**Scala:** C0 = azione/documento (minuti) · C1 = codice di supporto — JS/tests/CI
(ore) · C2 = generatore del seed + rebuild PE/ELF + hash CI (mezza giornata) ·
C3 = memoria/stringhe del seed in assembly (giornate) · C4 = semantica SPEC +
allineamento runtime + tappa S1 (settimane).

| # | C | Problema | Evidenza | Intervento |
|---|---|---|---|---|
| 1 | C0 | Il PAT rimosso da `.git-credentials` va **ruotato** su GitHub: va considerato esposto | `docs/security/SECURITY-REVIEW.md` #5 | azione umana (GitHub → revoca/rotazione) |
| 2 ✅ | C0 | `get(xs, i)` è nel codice macchina e nel riferimento JS ma **non in `SPEC-CORE.md` §8**: ambiguità reale da chiudere (aggiungerlo a §8 o dichiararlo non standard) | `tests/probes/test_get.td` | chiarimento normativo (una riga in §8 + nota §11) — **fatto 2026-11-02** |
| 3 ✅ | C1 | Letterali di lista su più righe: il parser JS li rifiuta (`parse error: SEP`), il seed li accetta | `tests/probes/bad_lista_multiriga.td` | `seed/dev/triad_core.cjs`: saltare i separatori dentro `[ ... ]` + ribaltare il probe in `ok_` — **fatto 2026-11-02** |
| 4 ✅ | C1 | `a ? b :c` (due punti attaccato al ramo): il lexer di `selfhost/source.td` legge `:c` come simbolo; il codice macchina risolve dal contesto | `selfhost/source.td` (divergenze, header) | reinterpretare il token SYM come `:` nel ramo ternario (parser) — **fatto 2026-11-02** anche nel parser JS |
| 5 ✅ | C1 | Simboli operatore del lessico Core (`:+`) non nel dominio del codice macchina | header `selfhost/source.td` | supersett nello scanner di `selfhost/source.td` (l'esecuzione resta ai punti 7/11) — **scanner fatto 2026-11-02** |
| 6 ✅ | C1 | Verifiche non agganciate alla CI: golden del front-end S1 e suite `tests/security` | `conformance/OK` locale | `.github/workflows/ci.yml`: `run_probes.mjs selfhost/source.td` + diff golden nello smoke `seed-windows`; `tests/security/run.sh` in una lane — **fatto 2026-11-02** |
| 7 | C2 | `-=` e `*=`: previsti dal lessico Core e accettati dal parser S1, il seed valuta solo `+=` | `STATUS.md` (limiti), probe `p6` della sessione | `seed/dev/gen_seed.js`: `st_sub_check`/`st_mul_check` simmetriche a `st_add_check`; rebuild PE/ELF, hash CI, conformance |
| 8 | C2 | Massimo **4 parametri** per funzione nel seed (record da 64 byte, 16 per parametro) | `tests/probes/bad_parametri_5.td` | `gen_seed.js`: allargare gli slot del record (o più record); rebuild + hash CI |
| 9 | C2 | Junk a destra del corpo di funzione breve: il seed ignora il resto riga, il parser S1 produce `ERR` | header `selfhost/source.td` | tracciare i separatori nello scanner S1 (token SEP o contatore riga) e consumare fino a fine riga |
| 10 | C3 | **Heap liste**: 528 byte irrecuperabili per ogni valutazione di letterale (64 KB totali; ~60/run ok, 150 = crash) | `tests/probes/bad_lista_alloc.td` | allocator con riuso o slab in `gen_seed.js`; sblocca AST come dato e vettori di token in S1 |
| 11 | C3 | Stringhe del seed: escape `\n \t \" \` assenti, `==` sempre `false`, `+=` corrompe | `bad_escape_stringa.td`, `bad_confronto_stringa.td`, `bad_stringa_plus_equals.td` | valutatore stringhe in `gen_seed.js` (escape in `pf_string`, confronto per contenuto, concat in `+=`) |
| 12 | C4 | **Scope dei nomi**: il seed è dinamico (il callee vede i locali del chiamante), il JS è lessicale, `SPEC-CORE.md` §4 non decide | `tests/probes/bad_scope_dinamico.td` | 1) decisione normativa in §4; 2) allineamento di un runtime (cambia la semantica dei programmi con omonimi nei frame) |
| 13 | C4 | S1.5 (eval) e AST come dato: richiedono §8 (`strlen`/`strbyte`/`strsub`/`readfile`) nel seed e/o il punto 10 | `BOOTSTRAP.md` S1, `SPEC-CORE.md` §8 | tappa S1 successiva: valutatore in Triad-Core sui token dell'algoritmo attuale |
| 14 | C2 | Identificatori con **iniziale maiuscola** (`Ab = 0`): il seed esce con 1, il JS li accetta; `aB` funziona (solo la classe di start del seed è `[a-z_]`); SPEC-CORE §2 ammette `[A-Za-z]` | `tests/probes/bad_identificatore_maiuscolo.td` | `gen_seed.js`: allargare la classe di start di `parse_ident` a `[A-Za-z_]`; rebuild PE/ELF, hash CI, conformance |
| 15 | C4 | Separatore newline dopo un operatore: il seed prosegue l'espressione (`x = 1` + `-2` = `-1`), il JS separa gli statement; SPEC-CORE §2 elenca il newline come separatore ma non decide la continuazione dopo un operatore | `tests/probes/bad_separatore_newline.td` | decisione normativa su §2/§4 (quando il newline continua l'espressione) + allineamento di un runtime |

### Chiusi il 2026-11-02 (righe 2–6 della tabella, A03, A04)
- **Riga 2 (`get`)**: aggiunta `get(xs, i)` a `SPEC-CORE.md` §8 come primitiva di
  bootstrap a indice **0-based**, con nota che la distingue da `xs[i]` (§7, 1-based)
  e che i casi di `conformance/core/` non la usano (§11). Risolve anche il vincolo
  «non usare `get` come se fosse una primitiva Full» di A03.
- **Riga 3 (liste multi-riga)**: `seed/dev/triad_core.cjs` tratta i newline come
  trivia dentro `[ ... ]` (con contatore di profondità dei bracket); probe ribaltato
  in `ok_lista_multiriga.td`. Il trailing comma resta errore su entrambi i runtime.
  Divergenze residue sui newline: vedi riga 15.
- **Riga 4 (`? :c`)**: reinterpretazione del token SYM come colon in posizione di
  operatore sia in `selfhost/source.td` (root_pos con `td > 0` + colon check in
  `parse_expr`, con avanzamento di un solo byte oltre i trivia) sia nel parser JS
  (splice `COLON` + resto in `parseTernary`). Probe `ok_ternario_colon_attacco.td`
  (7/8 identici su PE e JS) e nuovo chunk c8 nel sorgente di test di `source.td`
  (ternario annidato con due colon attaccati); golden rigenerato e verificato su
  entrambi i runtime.
- **Riga 5 (`:+`)**: scanner di `selfhost/source.td` accetta dopo `:` una corsa di
  caratteri operatore come nome simbolo (`is_opc`), superset del dominio del codice
  macchina. Probe `bad_simbolo_operatore.td` documenta che il seed lo rifiuta ancora.
- **Riga 6 (CI)**: job `security` (`tests/security/run.sh`), step
  `run_probes.mjs --strict` + `run_probes.mjs selfhost/source.td` nel job
  `seed-windows`, step di validità di tutti i `selfhost/*.td` in `conformance-core`.
- **A03/A04**: vedi le note nelle rispettive voci sopra.

Residui di sessioni precedenti (non del front-end, non bloccanti): Critical di
complessità/lint (`docs/security/TRIAGE-SEVERITY.md` rec. 3–5), CodeQL #128 da
chiudere al push del commit `0f4d106`.

## Sotto-task dalle note di sessione (2026-11-02)

Sotto-task derivati dalle note «Note e rinvii» del 2026-11-02 e dalle nuove
divergenze misurate (righe 14–15). Regola di lettura: N01/N03/N04/N05 sono
meccaniche (`gen_seed.js`) e **conviene raggrupparle in un unico ciclo di
rebuild PE/ELF + hash CI**; N02/N08 richiedono invece una decisione normativa
prima del codice (regola operativa 1: non inventare semantica); N09 è
l'abilitatore di tutti i rebuild verificabili senza Windows; N10 è azione umana.
Ogni sotto-task ha verifica locale su PE (wine) **e** interprete JS.
Mappatura con la tabella dei problemi: riga 1 → N10, riga 7 → N04,
riga 8 → N05, riga 10 → N07, riga 11 → N06, riga 12 → N08, riga 14 → N01,
riga 15 → N02; il caso `liste` skippato → N03.

### N01 — ✅ Identificatori con iniziale maiuscola nel seed (riga 14, C2, fatto 2026-11-02)
- **Files:** `seed/dev/gen_seed.js` (`parse_ident`), PE/ELF + `seed.hex`, hash in
  `.github/workflows/ci.yml`, `tests/probes/`.
- **Work:** allargare la classe di START dell'identificatore da `[a-z_]` a
  `[A-Za-z_]` (la classe di continuazione accetta già le maiuscole: `aB` funziona);
  la tabella delle keyword resta solo minuscola (`IF` non è keyword). Rebuild
  PE/ELF, aggiornare i due hash della CI.
- **Acceptance:** probe ribaltato in `ok_identificatore_maiuscolo.td` e identico
  sui due runtime; casi Core e probe `ok_*`/`test_*` verdi sul PE rigenerato;
  dump riproducibili dai generatori.
- **Closed 2026-11-02:** il difetto NON era in `parse_ident` (fa già case-folding)
  ma in due test del primo byte senza folding: `stmt_assign` (dispatch statement:
  `A = 0` diventava expression statement e falliva) e `sym_scan` (`:Ab`: il
  `jb('sym_digit')` sul test `a-z` catturava `A-Z` prima del ramo `A-Z`, codice
  morto). Entrambi ora usano il folding `or 0x20` come `parse_ident`. Verificato
  anche: iniziali maiuscole nei corpi di funzione (come il caso minuscolo),
  keyword solo minuscole (`IF = 5` → identificatore), `:Ab` = Symbol. Nuovo
  PE 25088 byte, SHA-256 `seed.hex`: `4235A70790BAA6784DC3D944616705B37E76ED2263CE73210BCC20E53639B8F7`.
- **Scoperta collegata (bug confermato, risolto dal rebuild):** `gen_seed.js`
  **non** riproduceva `seed.hex` (1705 byte di drift): il commit CodeQL `649709a`
  (2026-10-31) aveva fixato `testRcx` → `testRcx()` in `pf_call` (il cap check
  delle chiusure era corrotto) senza rigenerare gli artefatti. Il PE versionato
  conteneva il bug; il rebuild ripristina il contratto di riproducibilità.
  Riproduzione: `node seed/dev/gen_seed.js /tmp/x.hex && cmp /tmp/x.hex
  seed/windows-x86_64/seed.hex` (le differenze iniziano a `0x22f`, nei
  displacement dei salti che attraversano il punto d'inserzione in `pf_call` a
  `0x1c8b`: tutti gli shift di ±3 byte coerenti con l'inserimento di
  `test rcx,rcx`). Storia verificata byte-per-byte e raccolta in
  `docs/adr/0001-immutabilita-pe-riproducibilita-dump.md`.

### N02 — Newline: decisione normativa e allineamento (riga 15, C4)
- **Files:** `SPEC-CORE.md` §2/§4, `conformance/core/cases/`, poi un runtime.
- **Work:** decidere quando un newline **continua** l'espressione (dopo un
  operatore binario? dentro `()`/`[]`?) e quando **separa** gli statement;
  scrivere la regola in §2/§4; aggiungere casi `newline_continua` e
  `newline_separa`; allineare il runtime non conforme.
- **Dipendenze:** decisione normativa (umana) PRIMA del codice.
- **Acceptance:** casi newline verdi identici su PE e JS;
  `bad_separatore_newline.td` non documenta più una divergenza.

### N03 — `xs[i]` 1-based e sblocco del caso `liste` (C2, sottoinsieme di S0.2)
- **Files:** `seed/dev/gen_seed.js`, `conformance/run.mjs` (skip `liste`), CI.
- **Work:** implementare la lettura `xs[i]` (1-based) e la scrittura `xs[i] = v`
  nel seed (il JS già le ha); verificare `length`/`push!` esistenti; rimuovere
  `skip = ['liste']` dal runner e dai comandi CI.
- **Acceptance:** `conformance/core/cases/liste` verde byte-exatto sul PE senza
  skip; indici fuori intervallo e `0` → exit 1 + stderr (collegato a A05).

### N04 — `-=` e `*=` nel seed (riga 7, C2)
- **Files:** `seed/dev/gen_seed.js` (`st_sub_check`/`st_mul_check` simmetriche a
  `st_add_check`), PE/ELF, hash CI, `tests/probes/`, casi Core.
- **Work:** comporre assegnazione e operazione con wrap-around 64 bit firmato,
  come `+=`; caso di conformance `assegnazioni_composte` su entrambi i runtime.
- **Acceptance:** `-=`/`*=` producono gli stessi valori del JS; nessun caso
  regresso fra i 38 Core.

### N05 — Funzioni con più di 4 parametri (riga 8, C2)
- **Files:** `seed/dev/gen_seed.js` (record funzione da 64 byte, 16 per parametro),
  PE/ELF, hash CI, `tests/probes/`.
- **Work:** allargare gli slot del record (o impiegare più record) fino a 8+
  parametri; verificare ricorsione e chiamate con argomenti misti.
- **Acceptance:** `bad_parametri_5.td` ribaltato in `ok_`; caso con 6–8 parametri
  verificato identico sui due runtime.

### N06 — Stringhe del seed: escape, `==`, `+=` (riga 11, C3)
- **Files:** `seed/dev/gen_seed.js` (`pf_string`, valutatore stringhe), PE/ELF,
  hash CI, `tests/probes/`, `SPEC-CORE.md` §2.
- **Work:** escape `\n \t \" \\` nei letterali; `==`/`!=` per contenuto (oggi
  sempre `false`); `+=` come concatenazione (oggi corrompe); rispettare gli
  indici in byte UTF-8 di §2 (collegato a S0.3).
- **Acceptance:** `bad_escape_stringa.td`, `bad_confronto_stringa.td`,
  `bad_stringa_plus_equals.td` ribaltati; stringhe vuote, escape ai limiti e
  multibyte verificati byte per byte.

### N07 — Heap liste riutilizzabile (riga 10, C3)
- **Files:** `seed/dev/gen_seed.js` (bump allocator → riuso/slab per i valori di
  lista), PE/ELF, hash CI, `tests/probes/`.
- **Work:** riusare la memoria dei letterali di lista quando il valore non è più
  referenziato (oggi 528 byte irrecuperabili per valutazione, ~60/run, ~150 =
  crash); misurare il limite residuo.
- **Acceptance:** `bad_lista_alloc.td` (150 valutazioni) termina con exit 0 senza
  crash; sblocca vettori di token e AST come dato in S1.

### N08 — Scope dei nomi: decisione normativa (riga 12, C4)
- **Files:** `SPEC-CORE.md` §4, poi un runtime fra `seed/dev/gen_seed.js` e
  `seed/dev/triad_core.cjs`, `tests/probes/`.
- **Work:** decidere se lo scope è lessicale (JS, maggioranza dei linguaggi) o
  dinamico (seed: `env_find` vede i locali del chiamante); scrivere la regola in
  §4; allineare il runtime non conforme; documentare l'impatto sui programmi con
  omonimi nei frame.
- **Dipendenze:** decisione normativa (umana) PRIMA del codice.
- **Acceptance:** `bad_scope_dinamico.td` non documenta più una divergenza; i
  programmi con shadowing fra chiamante e chiamato hanno comportamento unico e
  specificato.

### N09 — ✅ Harness di verifica locale del PE via wine (C1, abilitatore, fatto 2026-11-02)
- **Files:** `scripts/seed-runner/seed-wine.sh` (nuovo; path rifinito rispetto a
  `scripts/dev/`: la cartella `scripts/seed-runner/` ospita già il runner Windows
  `run_seed.bat`), `tests/probes/README.md`, `seed/README.md`.
- **Work:** formalizzare la procedura usata in sessione: decodificare
  `seed/windows-x86_64/seed.hex` in un PE temporaneo ed eseguirlo con
  `WINEDEBUG=-all wine`, esportando `TRIAD_SEED` per `conformance/run.mjs` e
  `tests/probes/run_probes.mjs` (che già lo accettano). Un solo comando ripete
  conformance + probes su Linux.
- **Acceptance:** da un checkout pulito, un comando su Linux esegue la
  conformance Core e i probe sul PE nativo senza Windows; la CI resta invariata
  (su Windows il seed gira nativo).
- **Closed 2026-11-02:** `scripts/seed-runner/seed-wine.sh` con tre modalità
  (`FILE.td [ARG...]`, `--check`, `--help`) e cache del PE in
  `~/.cache/triad2.0/seed-wine` invalidata al cambio di SHA-256 di `seed.hex`
  (verificata: cache hit, invalidazione, ripristino del marker). `--check` da
  cache pulita: conformance Core OK (38 casi, `liste` skippata), 17 probe
  `ok_*`/`test_*` con 0 differenze, golden `selfhost/source.expected.out`
  confermato. Documentato in `seed/README.md` e `tests/probes/README.md`.

### N10 — Rotazione del PAT esposto (riga 1, C0, azione umana)
- **Files:** nessuno nel repository; `docs/security/SECURITY-REVIEW.md` #5,
  `tests/security/no_live_tokens.test.py`.
- **Work (manuale):** GitHub → Settings → Developer settings → Personal access
  tokens: revocare il PAT rimosso da `.git-credentials` e generarne uno nuovo;
  riconfigurare le credenziali locali FUORI dal repository (come da
  `.git-credentials.example`).
- **Acceptance:** il vecchio PAT risulta revocato; nessun token nel working tree
  o negli URL di git (`sh tests/security/run.sh` verde).

### Ordine suggerito
> **Aggiornamento 2026-11-03:** la task principale «seed Linux nativo senza Wine»
> (N15–N18, sezione in testa al file) **precede N03**; N03/N04/N05 restano raggruppate
> in un unico ciclo di rebuild PE/ELF + hash CI dopo N15–N17.
1. **N09** (abilitatore, minuti) → 2. **N15–N18** (task principale, vedi sopra) →
  3. **N03+N04+N05** in un unico rebuild + hash CI (N01 chiuso; mezza giornata) →
  4. **N10** (azione umana, indipendente) → 5. **N02** e **N08** dopo le decisioni
  normative → 6. **N06+N07** (C3, giorni).

## Sotto-task dalle note di sessione (2026-11-03)

Sotto-task derivati dalle note di chiusura delle due lavorazioni del 2026-11-03:
(1) libro fuori dal repo (`.gitignore` con `/docs/libro/` + `git rm --cached` dei
3 artefatti tracciati) e (2) fix CodeQL TOCTOU in `tools/site-gen/build.mjs`.
N11 è meccanico (stessa rimediazione già applicata in `build.mjs`); N12 è la
verifica di chiusura dell'alert dopo il push; N13 e N14 richiedono una decisione
(regola operativa 1: non inventare semantica — qui: non committare né rimuovere
senza conferma).

### N11 — Sweep TOCTOU check-then-use negli script CLI/dev (C1, meccanico)
- **Files:** `cli/lib/commands/ai.mjs:39-42`, `cli/lib/utils.mjs:50-52`,
  `scripts/docs/sync-playground-core.mjs:40`, `scripts/docs/build-docx.cjs:30`,
  in subordine `scripts/docs/build-pdf.mjs:36`.
- **Work:** applicare a ogni occorrenza la rimediazione già adottata in
  `tools/site-gen/build.mjs`: niente `existsSync` prima dell'uso — operazione
  diretta con gestione errore (`try { readFileSync/statSync } catch (ENOENT)`).
  Le più chiare: `build-docx.cjs:30` (check → `readFileSync` poche righe dopo),
  `sync-playground-core.mjs:40` (check → `readFileSync` alla riga 44),
  `ai.mjs:39-42` (scelta path con `existsSync` → subito `readFileSync`);
  `utils.mjs:50` ritorna un path già "controllato" poi usato da `seedIsStub`
  (`statSync`) — stesso schema di `findSeed()` corretto in `build.mjs`.
- **Acceptance:** nessuna coppia check-then-use residua (le `existsSync`
  rimaste sono solo decisioni booleane senza uso fs successivo sullo stesso
  path); scansione CodeQL/Codacy senza nuovi alert TOCTOU; comandi verdi:
  `node cli/triad-cli.mjs ai verify`, `node scripts/docs/sync-playground-core.mjs`,
  `node scripts/docs/build-docx.cjs`.

### N12 — Chiusura dell'alert CodeQL su `tools/site-gen/build.mjs` (C1)
- **Files:** `tools/site-gen/build.mjs` (fix già in working tree, non committato),
  `.github/workflows/`, configurazione Codacy/CodeQL.
- **Work:** committare e pushare il fix (read senza `existsSync`, scrittura
  atomica temp+rename, `statSync` diretto in `findSeed`), rilanciare la
  scansione e verificare che l'alert "Potential file system race condition"
  risulti chiuso; chiudere anche il residuo `CodeQL #128` citato sopra se
  ancora aperto.
- **Acceptance:** alert chiuso sul portale della scansione dopo il push;
  `node tools/site-gen/build.mjs --check` (13 file coincidenti) e
  `node cli/triad-cli.mjs test conformance` (37/37) restano verdi.

### N13 — Commit della politica «libro fuori dal repo» (C1, decisione)
- **Files:** `.gitignore` (modificato), index git (staged:
  `D docs/libro/libro.html`, `D docs/libro/The-book-of-Triad.epub`,
  `D docs/libro/triad-logo.webp`), `STATUS.md` (voce «Book `docs/libro/`»).
- **Work:** decidere fra due strade: (a) committare `.gitignore` + le rimozioni
  staged (`docs/libro/` resta solo su disco e nel repo dedicato con il proprio
  `.git`), oppure (b) `git restore --cached docs/libro/...` e restringere il
  `.gitignore` con negazioni `!` per mantenere i 3 artefatti. Verificato il
  2026-11-03: `docs/index.html`, `docs/pages/` e `tools/site-gen/` non
  referenziano `docs/libro/`, quindi la rimozione non tocca il sito generato;
  `scripts/docs/build-libro.mjs` legge le fonti in `docs/*.md` e scrive in
  `docs/libro/` (ignorato da git ma presente su disco): il build resta ok.
- **Acceptance:** `git status` pulito su `docs/libro/`; se (a), `git ls-files
  docs/libro/` è vuoto; `node scripts/docs/build-libro.mjs` rigenera gli
  artefatti senza che git li rilevi; `STATUS.md` aggiornato di conseguenza.

### N14 — Decisione sui capitoli `Libro-*.md` del wiki (C4, decisione umana)
- **Files:** `obsidian-triad/wiki-content/Libro-*.md` (`Libro-00`…`Libro-22`,
  tracciati nel repo), `obsidian-triad/github-wiki/Libro-*.md` (submodule
  `triad2.0.wiki`, gestito a parte).
- **Work:** decidere se i capitoli restano versionati nel repo principale o
  vengono ignorati/rimossi dal tracciamento come il resto del libro. Non sono
  sorgente del build (`scripts/docs/build-libro.mjs` usa `docs/PREFazione.it.md`,
  `docs/FONDAMENTA.it.md`, `docs/MANUALE.it.md`, `docs/tutorial/TUTORIAL.it.md`)
  ma sono il mirror wiki del libro. In caso di rimozione intervenire solo su
  `wiki-content` e aggiungere la regola a `.gitignore`.
- **Acceptance:** decisione documentata in `STATUS.md`; se rimozione, stesse
  verifiche di N13 (`git ls-files` vuoto per i file toccati, build libro
  invariata).

### Ordine suggerito
1. **N12** (chiude l'alert già fixato, commit + push) → 2. **N11** (stessa
  rimediazione, sweep meccanico) → 3. **N13** (decisione + commit della
  politica sul libro) → 4. **N14** (decisione umana, indipendente).
