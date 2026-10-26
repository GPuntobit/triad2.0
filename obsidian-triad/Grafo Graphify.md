# Grafo Graphify

## Snapshot

- Repository: [GPuntobit/triad2.0](https://github.com/GPuntobit/triad2.0), ramo `main`.
- Commit indicizzato: `aa1841bf27f50f787964bc8dacb1f4dbec4c4d45`.
- Generato in locale con `graphify update .` (estrazione AST, nessun LLM): 26 ottobre 2026.
- Statistiche: **1245 nodi**, **2272 relazioni**, **75 comunità**, **101 file** rappresentati.
- Relazioni per tipo: `calls` 901, `contains` 857, `defines` 252, `references` 105, `imports` 77, `imports_from` 73, `inherits` 4, `dynamic_import` 2, `declares` 1.

Artefatti dell’esportazione, salvati nel vault:

- [[graphify/GRAPH_REPORT|GRAPH_REPORT]] — report di Graphify (comunità, hub, freschezza del grafo).
- [Grafo interattivo `graph.html`](<./graphify/graph.html>) — da aprire nel browser.

Per rigenerare: `graphify update .` dalla radice del repository, poi copiare `graphify-out/GRAPH_REPORT.md` e `graphify-out/graph.html` in `obsidian-triad/graphify/`.

## Tutti i file nel grafo

Elenco completo dei file presenti in `graph.json`, con il numero di nodi e di relazioni che hanno origine in ciascun file. Le pagine di dettaglio esistenti sono collegate nell’ultima colonna.

| File sorgente | Area | Nodi | Relazioni | Pagina |
|---|---|---:|---:|---|
| [`AGENTS.md`](<../AGENTS.md>) | Radice | 3 | 2 |  |
| [`BOOTSTRAP.md`](<../BOOTSTRAP.md>) | Radice | 13 | 13 |  |
| [`CHANGELOG.md`](<../CHANGELOG.md>) | Radice | 5 | 5 |  |
| [`HANDOFF-CODEX.md`](<../HANDOFF-CODEX.md>) | Radice | 9 | 8 |  |
| [`HANDOFF-HERMES.md`](<../HANDOFF-HERMES.md>) | Radice | 15 | 14 |  |
| [`HANDOFF-KILO.md`](<../HANDOFF-KILO.md>) | Radice | 9 | 8 |  |
| [`HANDOFF-QODER.md`](<../HANDOFF-QODER.md>) | Radice | 9 | 8 |  |
| [`HANDOFF-QWEN.md`](<../HANDOFF-QWEN.md>) | Radice | 9 | 8 |  |
| [`PROMPT_JEV.md`](<../PROMPT_JEV.md>) | Radice | 20 | 19 |  |
| [`README.md`](<../README.md>) | Radice | 14 | 19 |  |
| [`SPEC-CORE.md`](<../SPEC-CORE.md>) | Radice | 14 | 13 |  |
| [`SPEC.md`](<../SPEC.md>) | Radice | 25 | 24 |  |
| [`STATUS.md`](<../STATUS.md>) | Radice | 15 | 14 |  |
| [`TASK.md`](<../TASK.md>) | Radice | 39 | 38 |  |
| [`TUTORIAL.md`](<../TUTORIAL.md>) | Radice | 58 | 60 |  |
| [`_probe.jl`](<../_probe.jl>) | Radice | 30 | 62 |  |
| [`_probe2.jl`](<../_probe2.jl>) | Radice | 2 | 1 |  |
| [`_probe3.jl`](<../_probe3.jl>) | Radice | 2 | 1 |  |
| [`_qc.jl`](<../_qc.jl>) | Radice | 2 | 1 |  |
| [`_smoke.jl`](<../_smoke.jl>) | Radice | 1 | 0 |  |
| [`opencode.json`](<../opencode.json>) | Radice | 7 | 6 |  |
| [`plan.md`](<../plan.md>) | Radice | 13 | 12 |  |
| [`syntax.jl`](<../syntax.jl>) | Radice | 45 | 201 |  |
| [`test_parser.ps1`](<../test_parser.ps1>) | Radice | 1 | 0 |  |
| [`triad.jl`](<../triad.jl>) | Radice | 128 | 463 | [[File - triad.jl]] |
| [`.github/copilot-instructions.md`](<../.github/copilot-instructions.md>) | .github/ | 2 | 1 |  |
| [`.github/workflows/ci.yml`](<../.github/workflows/ci.yml>) | .github/ | 26 | 31 |  |
| [`.kilo/agents/data.md`](<../.kilo/agents/data.md>) | .kilo/ | 1 | 0 |  |
| [`.kiro/settings/mcp.json`](<../.kiro/settings/mcp.json>) | .kiro/ | 1 | 0 |  |
| [`.webcmd/graphify/README.md`](<../.webcmd/graphify/README.md>) | .webcmd/ | 11 | 10 |  |
| [`.webcmd/graphify/callees.js`](<../.webcmd/graphify/callees.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/callers.js`](<../.webcmd/graphify/callers.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/expand.js`](<../.webcmd/graphify/expand.js>) | .webcmd/ | 2 | 7 |  |
| [`.webcmd/graphify/fetch.js`](<../.webcmd/graphify/fetch.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/files.js`](<../.webcmd/graphify/files.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/find.js`](<../.webcmd/graphify/find.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/impact.js`](<../.webcmd/graphify/impact.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/lib/client.js`](<../.webcmd/graphify/lib/client.js>) | .webcmd/ | 19 | 31 |  |
| [`.webcmd/graphify/memories.js`](<../.webcmd/graphify/memories.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/neighbors.js`](<../.webcmd/graphify/neighbors.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/node.js`](<../.webcmd/graphify/node.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/package.json`](<../.webcmd/graphify/package.json>) | .webcmd/ | 8 | 8 |  |
| [`.webcmd/graphify/path.js`](<../.webcmd/graphify/path.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/query.js`](<../.webcmd/graphify/query.js>) | .webcmd/ | 2 | 6 |  |
| [`.webcmd/graphify/recall.js`](<../.webcmd/graphify/recall.js>) | .webcmd/ | 1 | 4 |  |
| [`.webcmd/graphify/references.js`](<../.webcmd/graphify/references.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/remember.js`](<../.webcmd/graphify/remember.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/repos.js`](<../.webcmd/graphify/repos.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/risk.js`](<../.webcmd/graphify/risk.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/search.js`](<../.webcmd/graphify/search.js>) | .webcmd/ | 1 | 4 |  |
| [`.webcmd/graphify/stats.js`](<../.webcmd/graphify/stats.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/subgraph.js`](<../.webcmd/graphify/subgraph.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/tests.js`](<../.webcmd/graphify/tests.js>) | .webcmd/ | 1 | 5 |  |
| [`.webcmd/graphify/tools/expand.js`](<../.webcmd/graphify/tools/expand.js>) | .webcmd/ | 2 | 3 |  |
| [`.webcmd/graphify/tools/generate.mjs`](<../.webcmd/graphify/tools/generate.mjs>) | .webcmd/ | 6 | 9 |  |
| [`.webcmd/graphify/tools/lib-client.js`](<../.webcmd/graphify/tools/lib-client.js>) | .webcmd/ | 19 | 31 |  |
| [`.webcmd/graphify/tools/path.js`](<../.webcmd/graphify/tools/path.js>) | .webcmd/ | 1 | 2 |  |
| [`.webcmd/graphify/tools/query.js`](<../.webcmd/graphify/tools/query.js>) | .webcmd/ | 2 | 3 |  |
| [`.webcmd/graphify/tools/recall.js`](<../.webcmd/graphify/tools/recall.js>) | .webcmd/ | 1 | 2 |  |
| [`.webcmd/graphify/tools/risk.js`](<../.webcmd/graphify/tools/risk.js>) | .webcmd/ | 1 | 2 |  |
| [`.webcmd/graphify/tools/search.js`](<../.webcmd/graphify/tools/search.js>) | .webcmd/ | 1 | 2 |  |
| [`.webcmd/graphify/trace.js`](<../.webcmd/graphify/trace.js>) | .webcmd/ | 1 | 5 |  |
| [`ai/README.md`](<../ai/README.md>) | ai/ | 8 | 7 |  |
| [`ai/SYSTEM_PROMPT.md`](<../ai/SYSTEM_PROMPT.md>) | ai/ | 5 | 4 |  |
| [`ai/jev_audit.mjs`](<../ai/jev_audit.mjs>) | ai/ | 20 | 38 | [[File - ai jev_audit.mjs]] |
| [`ai/jev_prompt.md`](<../ai/jev_prompt.md>) | ai/ | 13 | 15 |  |
| [`ai/tasks/01_somma/task.md`](<../ai/tasks/01_somma/task.md>) | ai/ | 2 | 1 |  |
| [`ai/tasks/02_fattoriale/task.md`](<../ai/tasks/02_fattoriale/task.md>) | ai/ | 2 | 1 |  |
| [`ai/tasks/03_fibonacci/task.md`](<../ai/tasks/03_fibonacci/task.md>) | ai/ | 2 | 1 |  |
| [`ai/tasks/04_stringhe/task.md`](<../ai/tasks/04_stringhe/task.md>) | ai/ | 2 | 1 |  |
| [`ai/tasks/05_chiusure/task.md`](<../ai/tasks/05_chiusure/task.md>) | ai/ | 2 | 1 |  |
| [`ai/verify.jl`](<../ai/verify.jl>) | ai/ | 6 | 8 | [[File - ai verify.jl]] |
| [`bin/build_standalone.jl`](<../bin/build_standalone.jl>) | bin/ | 3 | 2 |  |
| [`bin/triad`](<../bin/triad>) | bin/ | 3 | 3 |  |
| [`conformance/README.md`](<../conformance/README.md>) | conformance/ | 6 | 6 |  |
| [`conformance/core/README.md`](<../conformance/core/README.md>) | conformance/ | 4 | 5 |  |
| [`conformance/run.jl`](<../conformance/run.jl>) | conformance/ | 6 | 7 |  |
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

Moduli esterni referenziati (senza file nel repository): `node:child_process`, `node:util`.

## Copertura

- A differenza dello snapshot precedente (ricerca semantica via MCP, nessun elenco enumerabile), `graph.json` permette di elencare **tutti** i file indicizzati: la tabella sopra è completa.
- Graphify ha saltato 226 file senza estensione supportata (soprattutto `.td`, `.out`, `.code`): i sorgenti Triad `.td` non sono quindi rappresentati nel grafo.
- I bundle dei plugin in `.obsidian/plugins/` non sono inclusi nell’estrazione locale; le pagine [[File - KarpathyWiki main.js]] e [[File - Templater main.js]] restano dallo snapshot precedente.

## Snapshot precedente

Indicizzazione MCP del 25 ottobre 2026 sul commit `929a9269ef08d07088d65217f269c5aeafabd62a`: 3.197 nodi, 7.794 relazioni, 206 comunità. I conteggi non sono confrontabili con quelli attuali (estrattore diverso, bundle dei plugin inclusi).
