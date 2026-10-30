# Graphify graph
## Snapshots
- Repository: [GPuntobit/triad2.0](https://github.com/GPuntobit/triad2.0), `main` branch.
- Indexed commit: `aa1841bf27f50f787964bc8dacb1f4dbec4c4d45`.
- Generated locally with `graphify update.` (AST extraction, no LLM): October 26, 2026.
- Statistics: **1245 nodes**, **2272 relationships**, **75 communities**, **101 files** represented.
- Relationships by type: `calls` 901, `contains` 857, `defines` 252, `references` 105, `imports` 77, `imports_from` 73, `inherits` 4, `dynamic_import` 2, `declares` 1.
Export artifacts, saved in the vault:
- [[graphify/GRAPH_REPORT|GRAPH_REPORT]] — Graphify report (community, hub, graph freshness).
- [Interactive graph `graph.html`](<./graphify/graph.html>) — opens in browser.
To regenerate: `graphify update .` from the repository root, then copy `graphify-out/GRAPH_REPORT.md` and `graphify-out/graph.html` to `obsidian-triad/graphify/`.
## All files in the graph
Complete list of files in `graph.json`, with the number of nodes and relationships that originate in each file. Existing detail pages are linked in the last column.
| Source File | Area | Nodes | Relationships | Page |
|---|---|---:|---:|---|
| [`AGENTS.md`](<../AGENTS.md>) | Root | 3 | 2 |  |
| [`BOOTSTRAP.md`](<../BOOTSTRAP.md>) | Root | 13 | 13 |  |
| [`CHANGELOG.md`](<../CHANGELOG.md>) | Root | 5 | 5 |  |
| [`HANDOFF-CODEX.md`](<../HANDOFF-CODEX.md>) | Root | 9 | 8 |  |
| [`HANDOFF-HERMES.md`](<../HANDOFF-HERMES.md>) | Root | 15 | 14 |  |
| [`HANDOFF-KILO.md`](<../HANDOFF-KILO.md>) | Root | 9 | 8 |  |
| [`HANDOFF-QODER.md`](<../HANDOFF-QODER.md>) | Root | 9 | 8 |  |
| [`HANDOFF-QWEN.md`](<../HANDOFF-QWEN.md>) | Root | 9 | 8 |  |
| [`PROMPT_JEV.md`](<../PROMPT_JEV.md>) | Root | 20 | 19 |  |
| [`README.md`](<../README.md>) | Root | 14 | 19 |  |
| [`SPEC-CORE.md`](<../SPEC-CORE.md>) | Root | 14 | 13 |  |
| [`SPEC.md`](<../SPEC.md>) | Root | 25 | 24 |  |
| [`STATUS.md`](<../STATUS.md>) | Root | 15 | 14 |  |
| [`TASK.md`](<../TASK.md>) | Root | 39 | 38 |  |
| [`TUTORIAL.md`](<../tutorial/TUTORIAL.md>) | Root | 58 | 60 |  |
| [`_probe.jl`](<../_probe.jl>) | Root | 30 | 62 |  |
| [`_probe2.jl`](<../_probe2.jl>) | Root | 2 | 1 |  |
| [`_probe3.jl`](<../_probe3.jl>) | Root | 2 | 1 |  |
| [`_qc.jl`](<../_qc.jl>) | Root | 2 | 1 |  |
| [`_smoke.jl`](<../_smoke.jl>) | Root | 1 | 0 |  |
| [`opencode.json`](<../opencode.json>) | Root | 7 | 6 |  |
| [`plan.md`](<../plan.md>) | Root | 13 | 12 |  |
| [`syntax.jl`](<../syntax.jl>) | Root | 45 | 201 |  |
| [`test_parser.ps1`](<../test_parser.ps1>) | Root | 1 | 0 |  |
| [`triad.jl`](<../triad.jl>) | Root | 128 | 463 | [[File - triad.jl]] |
| [`.github/copilot-instructions.md`](<../.github/copilot-instructions.md>) | .github/ | 2 | 1 |  |
| [`.github/workflows/ci.yml`](<../.github/workflows/ci.yml>) | .github/ | 26 | 31 |  |
| [`.kilo/agents/data.md`](<../.kilo/agents/data.md>) | .kilo/ | 1 | 0 |  |
| [`.kiro/settings/mcp.json`](<../.kiro/settings/mcp.json>) | .kiro/ | 1 | 0 |  |
| [`.webcmd/graphify/README.md`](<../tools/webcmd-graphify/README.md>) | .webcmd/ | 11 | 10 |  |
| [`.webcmd/graphify/callees.js`](<../tools/webcmd-graphify/callees.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/callers.js`](<../tools/webcmd-graphify/callers.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/expand.js`](<../tools/webcmd-graphify/expand.js>) | .webcmd/ | 2 | 7 |  |
| [`.webcmd/graphify/fetch.js`](<../tools/webcmd-graphify/fetch.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/files.js`](<../tools/webcmd-graphify/files.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/find.js`](<../tools/webcmd-graphify/find.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/impact.js`](<../tools/webcmd-graphify/impact.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/lib/client.js`](<../tools/webcmd-graphify/lib/client.js>) | .webcmd/ | 19 | 31 |  |
| [`.webcmd/graphify/memories.js`](<../tools/webcmd-graphify/memories.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/neighbors.js`](<../tools/webcmd-graphify/neighbors.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/node.js`](<../tools/webcmd-graphify/node.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/package.json`](<../tools/webcmd-graphify/package.json>) | .webcmd/ | 8 | 8 |  |
| [`.webcmd/graphify/path.js`](<../tools/webcmd-graphify/path.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/query.js`](<../tools/webcmd-graphify/query.js>) | .webcmd/ | 2 | 6 |  |
| [`.webcmd/graphify/recall.js`](<../tools/webcmd-graphify/recall.js>) | .webcmd/ | 1 | 4 |  |
| [`.webcmd/graphify/references.js`](<../tools/webcmd-graphify/references.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/remember.js`](<../tools/webcmd-graphify/remember.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/repos.js`](<../tools/webcmd-graphify/repos.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/risk.js`](<../tools/webcmd-graphify/risk.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/search.js`](<../tools/webcmd-graphify/search.js>) | .webcmd/ | 1 | 4 |  |
| [`.webcmd/graphify/stats.js`](<../tools/webcmd-graphify/stats.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/subgraph.js`](<../tools/webcmd-graphify/subgraph.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/tests.js`](<../tools/webcmd-graphify/tests.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/tools/expand.js`](<../tools/webcmd-graphify/tools/expand.js>) | .webcmd/ | 2 | 3 |  |
| [`.webcmd/graphify/tools/generate.mjs`](<../tools/webcmd-graphify/tools/generate.mjs>) | .webcmd/ | 6 | 9 |  |
| [`.webcmd/graphify/tools/lib-client.js`](<../tools/webcmd-graphify/tools/lib-client.js>) | .webcmd/ | 19 | 31 |  |
| [`.webcmd/graphify/tools/path.js`](<../tools/webcmd-graphify/tools/path.js>) | .webcmd/ | 1 | 2 |  |
| [`.webcmd/graphify/tools/query.js`](<../tools/webcmd-graphify/tools/query.js>) | .webcmd/ | 2 | 3 |  |
| [`.webcmd/graphify/tools/recall.js`](<../tools/webcmd-graphify/tools/recall.js>) | .webcmd/ | 1 | 2 |  |
| [`.webcmd/graphify/tools/risk.js`](<../tools/webcmd-graphify/tools/risk.js>) | .webcmd/ | 1 | 2 |  |
| [`.webcmd/graphify/tools/search.js`](<../tools/webcmd-graphify/tools/search.js>) | .webcmd/ | 1 | 2 |  |
| [`.webcmd/graphify/trace.js`](<../tools/webcmd-graphify/trace.js>) | .webcmd/ | 1 | 5 |  |
| [`ai/README.md`](<../ai/README.md>) | ai/ | 8 | 7 |  |
| [`ai/SYSTEM_PROMPT.md`](<../ai/SYSTEM_PROMPT.md>) | ai/ | 5 | 4 |  |
| [`ai/jev_audit.mjs`](<../ai/jev_audit.mjs>) | ai/ | 20 | 38 | [[File - ai jev_audit.mjs]] |
| [`ai/jev_prompt.md`](<../ai/jev_prompt.md>) | ai/ | 13 | 15 |  |
| [`ai/tasks/01_somma/task.md`](<../ai/tasks/01_somma/task.md>) | ai/ | 2 | 1 |  |
| [`ai/tasks/02_fattoriale/task.md`](<../ai/tasks/02_fattoriale/task.md>) | ai/ | 2 | 1 |  |
| [`ai/tasks/03_fibonacci/task.md`](<../ai/tasks/03_fibonacci/task.md>) | ai/ | 2 | 1 |  |
| [`ai/tasks/04_strings/task.md`](<../ai/tasks/04_strings/task.md>) | ai/ | 2 | 1 |  |
| [`ai/tasks/05_chiusure/task.md`](<../ai/tasks/05_chiusure/task.md>) | ai/ | 2 | 1 |  |
| [`ai/verify.jl`](<../ai/verify.jl>) | ai/ | 6 | 8 | [[File - ai verify.jl]] |
| [`bin/build_standalone.jl`](<../bin/build_standalone.jl>) | bin/ | 3 | 2 |  |
| [`bin/triad`](<../bin/triad>) | bin/ | 3 | 3 |  |
| [`conformance/README.md`](<../conformance/README.md>) | conformance/ | 6 | 6 |  |
| [`conformance/core/README.md`](<../conformance/core/README.md>) | conformance/ | 4 | 5 |  |
| [`conformance/run.mjs`](<../conformance/run.mjs>) | conformance/ | 6 | 7 |  |
| [`docs/confronto-linguaggi.md`](<../docs/confronto-linguaggi.md>) | docs/ | 11 | 12 |  |
| [`docs/estrazione-e0.md`](<../docs/estrazione-e0.md>) | docs/ | 8 | 8 |  |
| [`editors/README.md`](<../editors/README.md>) | editors/ | 7 | 6 |  |
| [`editors/linguist/README.md`](<../editors/linguist/README.md>) | editors/ | 5 | 4 |  |
| [`editors/linguist/languages.yml`](<../editors/linguist/languages.yml>) | editors/ | 9 | 8 |  |
| [`editors/vscode/README.md`](<../editors/vscode/README.md>) | editors/ | 5 | 4 |  |
| [`editors/vscode/package.json`](<../editors/vscode/package.json>) | editors/ | 13 | 12 |  |
| [`legacy/triad_sexpr_v1.jl`](<../legacy/triad_sexpr_v1.jl>) | legacy/ | 34 | 72 |  |
| [`obsidian-triad/File - KarpathyWiki main.js.md`](<./File - KarpathyWiki main.js.md>) | obsidian-triad/ | 5 | 5 |  |
| [`obsidian-triad/File - Templater main.js.md`](<./File - Templater main.js.md>) | obsidian-triad/ | 5 | 5 |  |
| [`obsidian-triad/File - ai jev_audit.mjs.md`](<./File - ai jev_audit.mjs.md>) | obsidian-triad/ | 5 | 11 |  |
| [`obsidian-triad/File - ai verify.jl.md`](<./File - ai verify.jl.md>) | obsidian-triad/ | 5 | 5 |  |
| [`obsidian-triad/File - triad.jl.md`](<./File - triad.jl.md>) | obsidian-triad/ | 5 | 5 |  |
| [`obsidian-triad/Grafo Graphify.md`](<./Grafo Graphify.md>) | obsidian-triad/ | 5 | 5 |  |
| [`obsidian-triad/Indice.md`](<./Indice.md>) | obsidian-triad/ | 5 | 9 |  |
| [`obsidian-triad/wiki/Welcome to Karpathy LLM Wiki.md`](<./wiki/Welcome to Karpathy LLM Wiki.md>) | obsidian-triad/ | 10 | 9 |  |
| [`seed/README.md`](<../seed/README.md>) | seed/ | 6 | 8 |  |
| [`seed/dev/README.md`](<../seed/dev/README.md>) | seed/ | 6 | 5 |  |
| [`seed/dev/gen_seed.js`](<../seed/dev/gen_seed.js>) | seed/ | 322 | 677 |  |
| [`seed/dev/gen_seed_linux.js`](<../seed/dev/gen_seed_linux.js>) | seed/ | 16 | 25 |  |
| [`seed/linux-x86_64/README.md`](<../seed/linux-x86_64/README.md>) | seed/ | 6 | 7 |  |
| [`seed/windows-x86_64/README.md`](<../seed/windows-x86_64/README.md>) | seed/ | 9 | 8 |  |
| [`test/oracles/oracle_tests.jl`](<../test/oracles/oracle_tests.jl>) | test/ | 6 | 5 |  |
| [`test/runtests.jl`](<../test/runtests.jl>) | test/ | 10 | 11 |  |
Referenced external modules (no files in repository): `node:child_process`, `node:util`.
## Coverage
- Unlike the previous snapshot (semantic search via MCP, no enumerable list), `graph.json` allows you to list **all** indexed files: the table above is complete.
- Graphify skipped 226 files without supported extension (mostly `.td`, `.out`, `.code`): Triad `.td` sources are therefore not represented in the graph.
- Plugin bundles in `.obsidian/plugins/` are not included in the local extraction; the [[File - KarpathyWiki main.js]] and [[File - Templater main.js]] pages remain from the previous snapshot.
## Previous snapshot
October 25, 2026 MCP indexing on commit `929a9269ef08d07088d65217f269c5aeafabd62a`: 3,197 nodes, 7,794 relationships, 206 communities. Counts are not comparable with current ones (different extractor, plugin bundle included).