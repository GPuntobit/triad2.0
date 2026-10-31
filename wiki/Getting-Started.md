# Getting Started

[⬅ Home](Home.md)

## Install

```bash
git clone https://github.com/GPuntobit/triad2.0.git
cd triad2.0
./install.sh
```

`install.sh` places the `triad` launcher on your PATH and verifies it against a probe program (`probes/test_simple.td`).

### Native platforms

| Platform | Runtime | Notes |
|---|---|---|
| Windows x86-64 | `seed/windows-x86_64/seed.exe` (machine-code seed S0) | 33 Core conformance cases verified in CI |
| Linux x86-64 | `seed/linux-x86_64/seed` (ELF) | Core profile |
| macOS | Node.js fallback (see below) | no native seed yet |

### Termux (Android)

The S0 seeds are **x86-64 only** and do not run on Android ARM64; there is no ARM64 seed yet (see [`STATUS.md`](../STATUS.md)). On Termux, Triad runs through the **Node.js fallback** with the reference interpreter `seed/dev/triad_core.cjs` — the same mechanism used by the conformance runner:

```bash
pkg install nodejs git
git clone https://github.com/GPuntobit/triad2.0.git
cd triad2.0
export PATH="$PWD/bin:$PATH"
triad demo.td              # prints 42
node conformance/run.mjs   # conformance: OK (37/37)
```

This fallback also works on any architecture without a precompiled seed (ARM64 Linux, etc.). The `#!/usr/bin/env triad` shebang works as soon as `bin/` is on the PATH. Limitation: the fallback covers **Triad-Core**; Triad-Full awaits the self-hosted runtime ([`BOOTSTRAP.md`](../BOOTSTRAP.md)).

## Your first program

Create `demo.td`:

```triad
# profile: Triad-Core (runs today)
let x = 40
x + 2
```

Run it:

```bash
triad demo.td
```

**Output:**

```
42
```

The value of the last expression in a block is its result — see [Language Guide → Values & Expressions](Language-Guide.md).

## Run the conformance suite

From the repository root:

```bash
node conformance/run.mjs
```

Expected result: `conformance: OK` (37/37 executable Core cases). This verifies that your checkout behaves exactly as the standard prescribes.

## REPL and CLI

```bash
triad --help        # usage
triad repl          # interactive read-eval-print loop
triad file.td       # run a script
```

Full details: [Syntax Reference → CLI & REPL](Syntax-Reference.md).

## Next steps

- Learn the language: [Language Guide](Language-Guide.md) or the full [Tutorial](../tutorial/TUTORIAL.md) (also available in [Italian](../tutorial/TUTORIAL.it.md), [Russian](../tutorial/TUTORIAL.ru.md), [Chinese](../tutorial/TUTORIAL.zh.md), [Japanese](../tutorial/TUTORIAL.ja.md)).
- Understand what runs today: [Project Status](Project-Status.md).
- Explore the codebase: [Repository Architecture](Repository-Architecture.md).
