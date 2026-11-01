# Repository Architecture

[⬅ Home](Home.md) · guided tour version: Tutorial Part IV ([`tutorial/TUTORIAL.md`](../tutorial/TUTORIAL.md))

## Layout after the folder reorganization

```
triad2.0/
├── bin/                  # `triad` launcher (dispatches to native seed or Node fallback)
├── seed/                 # machine-code seeds + dev reference interpreter
│   ├── windows-x86_64/seed.exe
│   ├── linux-x86_64/seed
│   └── dev/triad_core.cjs          # JS reference interpreter (Core)
├── conformance/          # golden cases + run.mjs harness (37/37 Core)
├── selfhost/             # bootstrap artifacts & scaffolding for the self-hosted compiler
├── probes/               # tiny .td programs used by install.sh and CI smoke tests
├── examples/             # sample Triad programs
├── cli/                  # CLI tooling around the language
├── editors/              # editor integrations (syntax highlighting etc.)
├── tutorial/             # TUTORIAL.md + translations (.it/.ru/.zh/.ja)
├── docs/                 # MANUALE.md, PREFazione.md, SPEC pages site, releases/, libro/
├── scripts/
│   ├── docs/             # build-libro.mjs, build-epub.cjs, download_chart.py, translations
│   ├── seed-runner/      # helpers that execute against the seeds
│   └── experiments/      # exploratory tooling
├── tools/                # external tool bundles (e.g. webcmd-graphify)
├── tests/security/       # security regression suite (run.sh — 5 checks)
├── ai/                   # AI-assistant skills/hooks (.github/ecc mirrors included)
├── obsidian-triad/       # Obsidian vault (graph + generated notes)
├── .github/              # workflows (SHA-pinned), issue/PR templates, skills
├── SPEC.md SPEC-CORE.md  # normative specifications (Full / Core)
├── BOOTSTRAP.md STATUS.md TASK.md CHANGELOG.md VERSION LICENSE
└── README.md SECURITY.md wiki/   # entry points (wiki = this English reference)
```

## How a program runs

1. `triad file.td` (launcher in `bin/`) picks the platform path: native seed if one exists for your OS/arch, otherwise `node seed/dev/triad_core.cjs file.td`.
2. The interpreter parses with a Pratt parser (twelve precedence levels) into `Node(head, args)` values and evaluates them per `SPEC-CORE.md`.
3. `node conformance/run.mjs` replays every golden case in `conformance/cases/` against the same interpreter and compares stdout + exit codes.

## Key code reading order (from Tutorial Part IV)

1. `seed/dev/triad_core.cjs` — lexer → parser → evaluator in one readable file.
2. `conformance/run.mjs` + a few `conformance/cases/*` — how the standard is tested without trusting any implementation.
3. `bin/triad` — the seed/fallback dispatch.
4. `install.sh` — installation contract and probe verification.
5. `selfhost/` + `BOOTSTRAP.md` — the path from S0 seed to a self-hosted Triad compiler.

## Generated artifacts

`docs/assets/img/downloads.svg` (CI-generated download chart via `scripts/docs/download_chart.py`), `docs/libro/` (HTML/EPUB book builds), `obsidian-triad/Grafo Graphify.md` (regenerate with the graphify tool under `tools/`). Treat these as outputs, not sources.

## See also

- [Contributing Guide](Contributing-Guide.md) — validation pipeline before merge
- [Project Status](Project-Status.md) — what each component can execute today
