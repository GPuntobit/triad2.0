# Triad 2.0 — v0.8.0-beta.10 (2026-11-08)

## Highlights

- First native S1 logic profile, implemented in Triad-Core: facts, rules,
  occurs-check unification, iterative backtracking, recursive predicates,
  negation, lists, solutions and comprehensions. Run `triad --logic FILE`.
- Logic trace records, typed structs and Boolean goal functions; compact
  paged source transport supports up to 65535 input bytes.
- The POSIX desktop selects Core or Logic automatically from source code,
  ignoring comments and strings. `:core` / `:logic` force a profile;
  `:auto` restores automatic selection.
- Fixed ternary symbols, indexed assignment looping forever, obsolete seed
  hashes/probe expectations, and truncated output from the JS reference.
- Cross-platform standalone CLI packaging no longer depends on Unix-only npm launchers.
- Core conformance now requires every case without tolerated failures.
- Removed abandoned development scripts and inactive guard code. TASK.md
  records removals, additions and recovery commands.

## Downloads and use

The source archive contains the full runtime, S1 modules, launchers, tests and
installation scripts. On Linux, extract it and run `./install.sh`, then use
`triad FILE`, `triad --logic FILE`, or the desktop session.

`seed-linux-x86_64` and `seed.exe` are the standalone **Core** seeds. They do
not contain S1; logic programs need the source distribution and POSIX launcher.
`triad-cli` / `triad-cli.exe` are standalone **development** CLIs (seed/ai/ext),
not the POSIX runtime CLI. `TriadDesktop.exe` is the Windows desktop build;
the automatic S1 profile selection is currently provided by the POSIX desktop.
SHA256SUMS covers the attached binary and source assets.

## Validation

Core 42/42, probes 39/39, logic 25/25 on native seed and development reference;
launcher/profile detection, pipe output, desktop, security and deterministic
seed rebuild checks. Release builds regenerate development CLIs on Linux and
Windows and compile the Windows desktop application.

## Known limits

This is a prerelease, not complete Triad-Full conformance. S1 still lacks a
general evaluator for arbitrary function bodies, dispatch, escaped/Unicode
strings, full diagnostic payloads and expression-valued query options. Heap,
vector and arity limits remain; the complete profile is documented in
selfhost/logic/README.md. The desktop is a file runner, not the Full REPL.
