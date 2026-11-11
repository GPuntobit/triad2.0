# Triad 2.0 comparison — what is it better at than other languages
- **Reference Document:** [`SPEC.md`](../SPEC.md) (v0.2.0), [`README.md`](../README.md), Appendix A
- **Code analyzed:** `SEIS0-official/triad2.0` @ `98e3fdb5c3cbb5785c4a0597d6f60d10060e7aac` (= local HEAD = org `main`)
- **Graphify Index:** repository `6a4868d9-5f27-483e-a13b-3b71a04433d1`, build `783641b1-08f0-4162-9aa6-cd36259bb583`, 648 nodes / 1,497 edges / 21 communities, model `minishlab/potion-base-8M`, indexed 2026-10-23T00:22Z
- **Date of analysis:** 2026-10-23
- **Method:** ANCHOR / PENALTY / RADAR / MIRROR kit + 20 Graphify queries (`query_graph`, `graphify_find`, `graphify_callers`, `graphify_tests_for`, `impact_and_risk`) + running local suites
- **Outcome:** the mechanics are verified in the code and in the tests; comparative primates are marked as Inferred where the document does not state them.
Rule applied: base each value on what the document and code actually say; if a comparison is not sustainable, leave the field blank and indicate the reason.
## 1. Basis of analysis
**What Graphify provided.** Localization of symbols and line numbers (`solve_goal` L431, `solve_opts` L1425, `check_contract` L1192, `assert_clause` L1398, `invoke_method` L1223, `with_effects` L855, `expand_macro` L1324, `known_type` L258, `applicable_m` L1200, `morespecific` L1202), the blast radius via `impact_and_risk`, and the 21 symbols of the graph families. All 20 queries returned with `grounded=true`.
**What was tested by running the code.** `test/runtests.jl` → 261/261 PASS; `conformance/run.jl` → 12/12 Full OK (`conformance: OK`); `test/oracles/oracle_tests.jl` → 4/4 PASS against SWI-Prolog, SBCL and Julia. All three external interpreters are installed on this machine, so oracle testsets are not skipped.
**What remains out of scope.** Graphify describes indexed relations and symbols: it does not certify semantic correctness, test coverage, or absence of bugs (see `TASKS.md`). The graph was queried against the snapshot at `98e3fdb`; the repository may have changed since then.
## 2. Comparative summary (AGAIN)
**1. Logic is a value, not a subsystem.** In Prolog the goal is a solver command; in Julia and Python the logic is a library to import. In Triad `solve` **is a value** (§6.3), allowed in expressions and comprehensions, and the engine is iterative with stack and trail (`triad.jl: solve_goal` L431). The advantage: no bridging between two worlds.
**2. Failure is a data, not an abort.** Errors have a taxonomic `kind` and structured data: `:syntax` with row and column (`syntax.jl: syntax_error` L25), `:contract` with function, clause and condition (`triad.jl: check_contract` L1192), plus `:effect`, `:budget`, `:method`. In Python, Java, and Go the error jumps the stack; here it is inspectable, treatable with `try`, and filterable by type.
**3. Effects are checked, not declared.** `!state` and `!io` are not annotations: `assert_clause` (L1398) rejects a clause that modifies the knowledge base without `!state`, and `invoke_method` (L1223) rejects a callee that declares effects that the caller does not allow. Haskell models the effects, but statically: here the control is dynamic and applied on every call.
**4. Contracts, budgets, and traces are values.** `requires`/`ensures` (§9), `with budget` (§10), and `with trace` (§11) live in the language, and their failure is an `Err(:contract)` or `Err(:budget)` with context. Elsewhere the contracts are macros or libraries, and the budget is almost always a timeout external to the process.
**5. Code as data without giving up the rest.** Lisp and derivatives make code-data the only model: here the uniform tree (`Node`) and macros (`expand_macro` L1324) coexist with dispatch on types, contracts and effects in the same block syntax.
**6. Semantics are checked against references, not declared.** `test/oracles/oracle_tests.jl` compares Triad output to **SWI-Prolog** (family), **SBCL** (closure/lambda), and **Julia** (multiple dispatch): I ran it here and it passes 4/4. And compliance is at the standards level: 41 static goldens that another implementation — the seed in machine code, a future native compiler — must pass without Julia.
## 3. Table (STILL + RADAR)
| Area | What he can do | Section | Where he is better than the others | Source | Evidence | Reason (if blank) |
|---|---|---|---|---|---|---|
| Integrated Logic | `fact`/`rule`, unification with occurs-check, backtracking; `solve` is a value; predicate in expression; `limit/depth/steps/trace` | §6, §10 | The engine is in the language: `solve` enters expressions and comprehensions; infinite recursion closes in `Err(:budget)` instead of saturating the stack | Inferred | SPEC §6.3, §10; `triad.jl solve_goal` L431, `solve_opts` L1425 | — |
| Errors as data | `Err(kind,msg,data)`; `try b end` makes the error the value; kind `:syntax`, `:contract`, `:effect`, `:budget`, `:method`, `:ambiguous`, `:type` | §8 | The failure is inspectable data with `kind` to dispatch and `data` with details, instead of an exception that overrides the stack | Extract | Appendix A; SPEC §8 (`kind` table); `syntax.jl` L25; `triad.jl` `struct Err` L74 | — |
| Contracts, budgets, tracks, effects | `requires`/`ensures` at runtime; `with budget` → `Err(:budget)`; `with trace` → `Traced(result, trace)`; `!io`/`!state` effects with dynamic control | §9–§12 | Contract, budget and track are values that can be combined with errors as data; effects are checked at each call, not noted | Extract | Appendix A; README; `triad.jl check_contract` L1192, `w.budget` L210, `w.tracer` L214, `assert_clause` L1398, `invoke_method` L1223 | — |
| Code as data and macros | `:(e)`/`quote` return code; `$x` inserts code or constants; macro with unevaluated arguments | §7 | The uniform tree coexists with logic, contracts and effects in the same block syntax, instead of being the only model | Inferred | SPEC §3, §7; `triad.jl Node`, `expand_macro` L1324, `syntax.jl string_node` | — |
| Types, `struct`, multiple dispatch | `::` and `struct` declared; dispatch on argument types with `Err(:method)`/`:ambiguous`; constructor that checks the types of fields | §4–§5 | *(empty)* | *(empty)* | *(empty)* | The document states that Triad **takes** multiple dispatch from Julia (Appendix A) and does not claim any advantages: without benchmarks the comparison would be invented. The feature exists and is verified (`known_type` L258, `applicable_m` L1200, `morespecific` L1202) |
| Standard with executable contract | SPEC v0.2.0 + 41 golden (12 Full, 29 Core); seed S0 in machine code (PE Windows, ELF Linux); CI Windows+Linux; Jev audit in `ai/` | §16, §15 | Equality is third-party verifiable: goldens are static and do not require Julia, and an implementation cannot conform without executing them | Extract | SPEC §16.2; `conformance/README.md`; `STATUS.md`; `conformance/run.jl`; `.github/workflows/ci.yml`; `seed/dev/gen_seed.js`, `gen_seed_linux.js`; `ai/jev_audit.mjs` | — |
## 4. Inferred Voices (RADAR)
Three statements are not taken word for word from the document and are marked **Inferred** in the table:
1. **“Logic is better because it is a value”** — derived from SPEC §6.3 (“solve is a value”) and §10 (iterative engine with stack, trail, and budget), plus implementation in `triad.jl` (`solve_goal` L431, `solve_opts` L1425). The comparison with Prolog and Julia is a judgment, not a measurement.
2. **«The data-code coexists with types, contracts and effects»** — derived from SPEC §3 and §7 and from Appendix A («integration of the three models into a single block syntax»), confirmed by the symbols `Node` and `expand_macro` L1324. The primacy over Lisp is argumentative.
3. **«Dynamic effects beat static ones»** — derived from `assert_clause` L1398 and `invoke_method` L1223 (runtime control) compared to Haskell's static effects system: the comparison is limited to the mechanism, not extended to other dimensions.
All other lines are **Excerpt**: mechanisms and taxonomies are taken from Appendix A, §8–§12 and §16, and anchored to real symbols.
## 5. What was not stated (PENALTY)
- No performance: There is no benchmark in the repository, so there are no claims that Triad is faster, more secure, or more productive.
- No record on multiple dispatch: Triad takes the mechanism from Julia (Appendix A) without declaring advantages; the field remains empty.
- No "general" superiority over Lisp: the balance between simplicity and expressive power is a judgment of taste, not a documented fact.
- The comparison with Eiffel (contracts in the language) and Haskell (effects) is limited to the mechanisms described and is not extended.
- Oracle testsets are optional by construction (looked at by `isfile` on the executable): the result 4/4 applies to this machine, where SWI-Prolog, SBCL and Julia are installed.
## 6. MIRROR — problem fields
| Affirmation | 1. Non-explicit assumptions? | 2. Alternative interpretations? | 3. Calculations between sections? | 4. Reliability | Why |
|---|---|---|---|---|---|
| «Better than Prolog because logic is a value» | Yes | Yes: it can mean less verbosity, not more power | No | **Medium** | The mechanism is verified in the code; primacy is my judgment |
| «Better than Haskell on effects» | No | Yes: dynamic vs static is a compromise, not an absolute advantage | No | **Medium** | Mechanism verified (`assert_clause` L1398, `invoke_method` L1223); partial comparison |
| «Better than Lisp because it holds types and contracts» | Yes | Yes: you can lose in simplicity | No | **Medium** | Verified coexistence; the budget is interpretative |
| «Better than Julia on dispatch» | No | — | No | **Low** | No declared benefits and no benchmarks: field left blank |
| «Semantics checked against SWI-Prolog/SBCL/Julia» | No | No | No | **High** | Suite performed in this session: 4/4 PASS, exit 0 |
| «Compliance verifiable by third parties» | No | No | Yes: SPEC §16.2 + `conformance/` + `STATUS.md` + CI | **High** | 41 static goldens; runner executed: `conformance: OK`, exit 0 |
| Graph counting | No | Yes: 648/1,497/21 now vs 649/1,494/21 in `TASKS.md` | Yes | **High** | `TASKS.md` describes the index to `b4fb8ae`; the current one is at `98e3fdb` |
## 7. Checks performed
| Command | Outcome |
|---|---|
| `julia --startup-file=no test/runtests.jl` | `Triad \| 261 261 44.1s` — exit 0 |
| `julia --startup-file=no conformance/run.jl` | 12/12 PASS (dispatch, error, family, guarantee_core, hello_shebang, macro, macro_eval, prolog, tour, values, …) — `conformance: OK` — exit 0 |
| `julia --startup-file=no test/oracles/oracle_tests.jl` | `SWI-Prolog vs Triad (family) 2/2`; `SBCL vs Triad (closure/lambda) 1/1`; `Julia vs Triad (multiple dispatch) 1/1` — exit 0 |
## 8. Documents to be updated (reported, not modified)
- `PROMPT_JEV.md`: declares «243 tests, all green (243/243)», but at `98e3fdb` the suite is at **261/261**.
- `TASKS.md`: reports 649 nodes / 1,494 relationships / 21 communities (index to `b4fb8ae`); the current index is **648 / 1,497 / 21**.
## 9. Login to Graphify
- MCP Server: `https://api.graphify.com/v1/mcp` with header `Authorization: Bearer gfy_mcp_…` (Workspace API Token, valid only for MCP: REST `api.graphify.com/v1/*` responds 401).
- Workspace: `gpuntobit-01-s-workspace`, tenant `a3bccac0-3ea8-49ce-8114-bf5b8fbadb11`.
- The token is pinned to the workspace and cannot change it (`workspace_pinned`).
- `GPuntobit/triad2.1` is **not** indexed: the GitHub App is only linked to the `SEIS0-official` organization installation. Since `98e3fdb` is also `main` of `SEIS0-official/triad2.0`, the index contains the same code as `triad2.1`. To index the fork you need to hook your personal installation to the tenant (`link/start` + OAuth GitHub flow started from the browser session).