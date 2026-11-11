# TRID-Core 0.5 — Multi-level proof dependencies and cognitive pulses

This is a **bounded, genuinely native Triad S1 logic experiment**, running via
`./bin/triad --logic`. No Python, Node.js or external LLM is used to compute
these deductions or the activation steps.

It does **not** replace the separately tested persistent S0 pipeline of 0.4.
The historical verifier defect was fixed by merged
[PR #99](https://github.com/GPuntobit/triad2.0/pull/99). On
`main` commit `7ff41abad93d2c646617d7d620c3bdda1c920a1a`, both
the S0 and S1 jobs, including this 0.5 golden fixture, passed in
[TRID Required](https://github.com/GPuntobit/triad2.0/actions/runs/43021172705).
This is same-SHA CI evidence, not a claim that the old 0.5 experiment became
a generalized reasoning engine.

## Run

```sh
sh cognitive/native/tests/run_05.sh
./bin/triad --logic cognitive/native/s1_multilevel_05.triad
```

The golden test compares all eleven lines of output byte-for-byte against
`cognitive/native/tests/expected_05.out`.

## Three-level proof graph

The example provides two separate source-labelled paths (six input facts):

```text
TRID --src_01--> logic --src_02--> unification --src_03--> occurs_check
TRID --src_04--> dialogue --src_05--> questions --src_06--> clarification
```

The `proof1`, `proof2`, `proof3` rules construct a chain of one,
two or three evidence edges. Each three-level proof includes two witness
nodes and all three source identifiers. `revoked(:src_02)` is an explicit
source-revocation statement. `retained3` requires every input source not to
have an explicit revocation; `suspended3` records proof paths containing an
explicitly revoked source. In the supplied fixture, `occurs_check` remains
derivable **conditionally** but its supporting proof is suspended; the
independent `clarification` proof remains retained.

This is a *bounded* proof DAG demonstration, **not** a recursive truth
maintenance engine. The absence of a `revoked` fact means only
"not known to be revoked" under a closed-world operational check, not
"reliably verified" or "true". `retained3` is conditional on accepted
source assumptions, and does not independently validate those sources.
The complete proof remains queryable even when suspended.

## Pulses are separate from accepted knowledge

`pulse_seed(:trid)` and six `association` facts define a separate
activation-only network. `pulse1`, `pulse2` and `pulse3` follow one,
two and three links. These are **three bounded propagation waves**, not a
continuous autonomous process or a weighted pulse simulator.

In particular, `occurs_check` is reached by a pulse despite the revocation
of an evidence source on its separate proof path. That is deliberate:
**activation is not truth, source reliability, or proof validity**.

Rules `rule_state` distinguish provided `experimental` and `refuted`
metadata. A refuted generalization is not promoted to truth by activation;
this experiment does not learn rule shapes or change metadata automatically.

## Known limitations and next gates

- Fixed depth of **three**, not arbitrary multi-level recursive provenance.
- No persistent mutable proof graph across runs; all facts, revocations and
  pulses are declared in the S1 program source.
- No source scoring, rule learning, autonomous goals or Socratic dialogue.
- The use of `not(revoked(?s))` is an operational finite closed-world check.
- Supports explicit source revocations, but no live incremental graph update,
  dependency reference counts, cycles, or consolidation/rollback across many
  versions.
- No automatically learned edge-strength weights, decay, or relevance ranking.
- S1 remains bounded by the underlying seed limits (65,535 source bytes,
  finite memory/step budget).
- A future candidate still requires its own passing S0 and S1 CI checks
  before claiming regression safety; historical green runs are not transferable.
- The 65,535-byte ceiling is on a single S1 source input; this is
  asserted by `tests/run_contract.sh`, not a limit on the total event-ledger
  history added in later TRID-011/013 research paths.

**What came later:** the [0.6 S1 graph](README_06.md) now accepts a
restricted source-backed fact file, persists it via POSIX, resolves finite
recursive proof paths and rejects malicious Triad source injection.
[TRID-070/071](QA_070_071_074.md) add separate epistemic and recovery
regression suites. Those developments do **not** retroactively upgrade the
fixed-depth 0.5 example to a complete dependency engine.
