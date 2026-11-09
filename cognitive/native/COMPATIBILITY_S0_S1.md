# TRID-004 — S0/S1 compatibility contract (bounded research profiles)

**Status:** versioned working contract, grounded in the native seed probes and
S1 conformance at the selected revision. It is not a claim that every
construct of `SPEC.md` or `SPEC-CORE.md` is implemented.

Use `bin/triad FILE` for S0 and `bin/triad --logic FILE` for the Triad-native
S1 logic frontend. The POSIX launcher handles byte transport only; S1 parsing,
unification and logical search run on the native Core seed.

## Feature / profile / automated test / limit matrix

| Feature | S0 observable contract | S1 or TRID implication | Permanent automated regression |
|---|---|---|---|
| Seed selection and CLI | `bin/triad FILE` invokes native S0; `TRIAD_SEED` can override the seed | `--logic` invokes `scripts/run-logic.sh` with exactly one file or `-` | `verify.sh`; `cognitive/native/tests/run_contract.sh` |
| Logic-source size | No general S0 text budget is certified by this row | S1 wrapper rejects source input **over 65535 bytes**, without silent truncation | `cognitive/native/tests/run_contract.sh` |
| Lists and indexing | List `xs[i]` is 1-based; `get(xs,i)` is 0-based; `push!` supported; bounded bump heap | Don't assume unlimited allocations for rule/proof structures | `tests/probes/ok_lista_indice.td`, `test_get.td`, `bad_lista_alloc.td` |
| Strings and comparison | `*` concatenates; native string `==` diverges (cannot be used for content equality); use explicit byte comparison where needed | `common.triad::same` compares string bytes | `tests/probes/bad_confronto_stringa.td`, `ok_ciclo_concat.td`; TRID native golden |
| String escapes | Native seed does not implement the expected escape handling | Generated S0 source must avoid relying on backslash escape semantics | `tests/probes/bad_escape_stringa.td` |
| File input/output | `readfile` available, up to 1 MiB; path up to 1024 bytes. No certified native `writefile` | Journal and graph use POSIX transport, **not** native transactional persistence | `tests/probes/ok_readfile.td`, `bad_readfile_inesistente.td`; `cognitive/native/tests/run.sh` |
| Printing | `println` accepts one expression; multi-argument print not certified | stdout is the serialization channel: reject diagnostics mixed into data | `tests/probes/bad_print_multi_arg.td`; `cognitive/native/tests/run_transport.sh` |
| Function values | Block function uses final expression; explicit `return` unsupported in seed | Triad cognitive functions use last-expression return idiom | `tests/probes/ok_funzione_valore.td`, `bad_return_blocco.td` |
| Function name scope | Seed may resolve caller locals dynamically (deviates from normative lexical scope) | Avoid dependence on caller-local names when composing S0 cognitive functions | `tests/probes/bad_scope_dinamico.td` |
| Function arguments | At most four parameters supported on the measured seed | Refactor larger parameter tuples into explicit lists | `tests/probes/bad_parametri_5.td` |
| Statement separators | Seed differs from reference on newline after operator | Avoid source that relies on newline in that ambiguous position | `tests/probes/bad_separatore_newline.td` |
| Integer range | Native tagged integer arithmetic is limited to approx. `[-2^61, 2^61-1]` and rejects overflow | No claim of full 64-bit parity or unbounded proof counters | `tests/probes/bad_intero_64bit.td`, `bad_intero_overflow_add.td` |
| S1 negation / missing facts | Not an S0 journal rule | `not(P)` is a bounded operational closed-world check, **not** external proof that P is false | `conformance/logic/cases/negation`; `cognitive/native/tests/run_05.sh` |
| S1 recursion | Not equivalent to arbitrary S0 metaprogramming | Native S1 recursion operates within finite memory, step and query budgets | `conformance/logic/cases/recursive`, `budget`; `cognitive/native/tests/run_06.sh` |
| Revocation versus activation | S0 journal histories retain explicit source revocations | S1 path invalidation and bounded pulses remain independent; `pulse != proof` | `cognitive/native/tests/run_05.sh`, `run_06.sh` |
| Persistent state | S0 verified journal stores polynomial checksums, **not cryptographic authentication** | S1 `graph.facts` is durable input copied/checked by POSIX; no native multi-file transaction | `cognitive/native/tests/run.sh`, `run_06.sh` |

## Unverified or explicitly limited behaviour

- The full normative `ARGS` contract is **not certified** for the research
  S0 seed. The TRID native launcher does not depend on it. Do not claim it
  is usable because `SPEC.md` describes it.
- Logical closed-world negation is operationally finite; absence of a
  source record does not establish source reliability or worldly truth.
- The code in `cognitive/native/common.triad` documents an S0 eager
  evaluation concern for `&&`; this should not be treated as a language-wide
  semantic guarantee without an independent dedicated probe.
- Snapshot publication and crash recovery remain TRID-005. Versioned common
  memory and native persistence are TRID-010/011/013, not completed here.
- Large or cyclic S1 queries can exhaust the finite bump heap or step
  budget. Success on the shipped small fixtures does not certify scale.

## Reproducible gates

From repository root on Linux x86-64 (with the native seed available):

```sh
sh cognitive/native/tests/run_contract.sh
sh cognitive/native/tests/run.sh
sh cognitive/native/tests/run_05.sh
sh cognitive/native/tests/run_06.sh
sh verify.sh
```

The same-SHA CI job is defined by
[`trid-baseline.yml`](../../.github/workflows/trid-baseline.yml).
Sources of the measured seed contract:
[`tests/probes/README.md`](../../tests/probes/README.md),
[`conformance/core/README.md`](../../conformance/core/README.md),
[`scripts/run-logic.sh`](../../scripts/run-logic.sh),
[`cognitive/native/README.md`](README.md).
