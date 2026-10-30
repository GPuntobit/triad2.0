# Jev prompt for auditing the Triad repository
This document contains the prompt for **Jev** (TypeSafe / System One) used for
understand *what is wrong* and *how many errors* there are in this repository, and the
runner that runs it: [`jev_audit.mjs`](jev_audit.mjs).
---
## 1. Why "how many errors?" it's not a question
Jev is a **judgment** model: it receives a `state` and returns responses
typed with probability (Choice, Score, Noul). Does not read the repository instead
ours and it doesn't count.
Put the whole repository in one prompt and ask "how many errors are there?"
produces an unreliable answer: the state becomes huge, the model must
overestimate and the result cannot be aggregated or verified.
The prompt is therefore **decomposed**:
| Level | Question to Jev | Who aggregates |
| --- | --- | --- |
| 1 file | "does this file have a defect? ​​what class? how serious? how many?" | — |
| 2 project | sum of per-file waits | **the code** (`expectedCount`) |
| 3 localization | "in which 40 line window does the defect fit?" | **the code** (window → lines) |
The counting is never asked of the model. The model classifies each file into
a band (`0`, `1`, `2`, `3+` defects) and returns the distribution of
probability; the code calculates the expected number as a weighted average of the bands.
---
## 2. The `state`
One `state` per file, in JSON, with named fields (the form recommended by
TypeSafe documentation):
```jsonc
{
  "project": { "name": "Triad", "summary": "..." },
  "file":    { "path": "ai/SYSTEM_PROMPT.md", "role": "prompt", "lines": 71 },
  "contract": "Che cosa questo artefatto doveva fare, in termini verificabili.",
  "known_facts": {
    "local_suite_results": { "unit_tests": "243/243 passed", "...": "..." },
    "cli_flags": { "interpreter_implemented": [], "launcher_implemented": [], "claimed_by_docs": [] },
    "observed_runtime_behaviour": ["println of a lambda prints '#lambda(x)', not 'fun'.", "..."]
  },
  "content": "il testo del file"
}
```

Three deliberate choices:
1. **`contract` for role.** A judgment only makes sense if the model knows what
   the artifact had to do. Roles are defined in `ROLE_RULES` in the runner:
   `spec`, `reference-implementation`, `test`, `golden`, `launcher`, `ci`,
   `prompt`, `tooling`, `doc`, `source`. Each role has a different contract.
2. **`known_facts` is calculated locally, not handwritten.** The runner
   performs testing and compliance and injects the true results. It serves two things:
   prevent the model from "discovering" a defect that is already covered by the tests, e
   give him the material to judge by (the flags that the code implements vs
   those that the documents declare).
3. **`content` is the raw file, with line numbers?** No: line numbers
   they would make the text artificial and distort localization. The lines
   they are obtained later, from the window.
---
## 3. The five questions (one request, in parallel)
All five read the same `state` and run in parallel: they do not see the
responses of the others, so none can contaminate the others.
### `has_defect` — Noul
> Does `content` contain at least one defect? A defect is: a statement in the text
> that is false about the Triad implementation; code that contradicts its
> contract; a broken path, link or file reference; or a declared value (byte size,
> hash, count, flag, exit code) that does not match reality.
The Noul returns the **probability of "yes"**, not a boolean. The code chooses
a threshold (0.5) and leaves the rest below threshold in an explicit gray zone.
### `defect_class` — Choice
Taxonomy of 12 classes, including `none`. It helps to answer *"what's wrong"*:
classes are actionable (`exit_code_contract`, `prompt_mismatch`,
`false_documentation`, `broken_reference`, `portability`, `build_ci`,
`coverage_gap`, `stale_claim`, `spec_mismatch`, `runtime_bug`, `other`).
The answer carries `choice`, `confidence` and the `probabilities` of each class: the
probabilities are what allow you to distinguish "a clear defect" from "a file
where the model is guessing".
### `severity` — Score
Four tiered levels, from cosmetic to crash. The `score` is the position
weighted (0..3) with its distribution. It serves to sort the backlog: an artifact
with severity 3 and low confidence it should still be looked at first.
### `defect_count` — Score
Bands: `0`, `1`, `2`, `3+`. The code calculates
```
expectedCount = Σ (indice del livello) × (probabilità del livello)
```

and sum over all files. The result is an **expected estimate**, not an integer
exactly: it must be said that way, because the number is not measured.
### `caught_by_suite` — Noul
> Is the most serious defect in this artifact one that the project's own test
> suite and conformance suite would detect?
This is the most useful question of the set. The suites are green (243/243, 12/12,
29/29, 25/25 on the seed), so **any true defect is by definition out
coverage**. The filter separates defects that the repository already captures from those
which would go unnoticed: the latter are the priority.
---
## 4. Second step: localization
The `sweep` knows *which file* is suspicious, not *where*. For the reported file:
```bash
node ai/jev_audit.mjs locate ai/SYSTEM_PROMPT.md
```

The runner divides the file into windows of 40 lines and asks, for each window, a
Noul (`defect_here`) and a Choice (`defect_class`). The model selects the
window; the code converts it to a range of rows:
```
ai/SYSTEM_PROMPT.md:34-73  P=0.81  class=prompt_mismatch  conf=0.72
```

The windows are numbered starting from 1 and the range is that of the window
integer: it is a window granularity localization, not a single row localization. For
getting the exact line uses a second pass with narrower windows
only on files already confirmed.
---
## 5. How to do it
```bash
export TYPESAFE_API_KEY=...          # richiesto per le chiamate reali
export TYPESAFE_MODEL=jev-latest     # opzionale

node ai/jev_audit.mjs sweep --dry-run   # stampa i payload JSON, senza chiamare l'API
node ai/jev_audit.mjs sweep              # chiama l'API e scrive ai/jev_audit_report.md
node ai/jev_audit.mjs locate <file>      # localizza i difetti di un file
```

Endpoint: `POST https://api.typesafe.ai/v1/systemone`, header
`Authorization: Bearer $TYPESAFE_API_KEY` e
`TypeSafe-Danger-Zone-Long-Context: true` (required: `triad.jl` and `syntax.jl`
they are long).
The report written in `ai/jev_audit_report.md` contains: number of files analyzed,
files reported, **expected number of defects**, defects per class, how many not
are covered by the suites, and token consumption.
---
## 6. Limits, stated
- **Expected number is an estimate**, not a count. Jev's odds
  they are calibrated but not necessarily corrected on this domain: the 186 artifacts
  they should be evaluated as benchmarks, not as truth.
- **One request per file means 186 requests.** Cost scales with
  repository. For a partial audit all you need is a subset of files in `sweep`.
- **The 0.5 threshold is a choice, not a measurement.** Files below the threshold remain
  outside the report; with `--dry-run` you see the payload, with the report you see it
  only what has passed the threshold.
- **Jev doesn't run the code.** Anything related to actual behavior
  must come from `known_facts` or the specification, never from the inference of
  model.
- **The language of the questions is English**, even if the repository is in Italian:
  the TypeSafe documentation notes that English is the training language
  main of Jev and that other languages have lower accuracy. The
  `content` remains in the original language.
- **The prompt does not replace tests.** It is used to find defects that tests
  they don't cover, which is exactly what `caught_by_suite` returns for
  "no".