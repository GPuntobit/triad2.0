# TRID-Core 0.5 — Multi-level proof dependencies and cognitive pulses

This is a **bounded, genuinely native Triad S1 logic experiment**, running via
`./bin/triad --logic`. No Python, Node.js or external LLM is used to compute
these deductions or the activation steps.

It does **not** replace the unverified persistent S0 pipeline of 0.4. The old
0.3/0.4 development reference tools and prior experimental branches stay
unchanged. The 0.5 gate is independent of that unresolved S0 failure.

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
- The 0.4 native S0 journal transport must pass its independent CI before
  any claim of complete 0.1–0.5 runtime migration.

Next prioritize a native Triad source-backed graph with durable facts and a
proof witness representation, then an independent revocation audit and
bounded activation scheduler with deduplication/limits. Keep experimental
hypotheses separate from accepted facts.
