# Graph Report - triad2.0  (2026-10-26)

## Corpus Check
- 109 files · ~87,780 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 226 file(s) not represented in the graph (top: .td 87, .out 53, .code 48)

## Summary
- 1245 nodes · 2272 edges · 75 communities (58 shown, 17 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 9 edges (avg confidence: 0.95)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `aa1841bf`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- gen_seed.js
- B
- client.js
- syntax.jl
- Task S1 (Interprete Triad in Triad-Core)
- Triad 2.0 — Tutorial completo d'uso e programmazione
- triad_sexpr_v1.jl
- S0 / Windows x86-64 — seed con interprete Triad-Core: elseif (M3b2b3q)
- _probe.jl
- B32
- Grafo Graphify.md
- steps
- jev_audit.mjs
- Standard Triad — specifica del linguaggio (versione 0.2.0, bozza)
- info
- triad.jl
- Rec
- tshow
- File da ispezionare (elenco completo)
- lib-client.js
- raise
- gen_seed_linux.js
- B. Esempi avanzati
- README.md
- HANDOFF per Hermes — triad2.0
- Stato di Triad e del bootstrap S0
- Prompt Jev per l'audit del repository Triad
- vscode/package.json
- Piano per completare Triad 2.0 - Stato Aggiornato
- Triad 2.0 — linguaggio di programmazione
- Triad-Core — sottoinsieme di bootstrap (standard 0.2.0)
- solve_goal
- Triad senza linguaggi ospiti — piano di bootstrap
- reloc
- webcmd-plugin-graphify
- Confronto Triad 2.0 — in cosa è più bravo degli altri linguaggi
- Welcome to your LLM-Wiki
- runtests.jl
- Triad
- HANDOFF per Codex — triad2.0
- HANDOFF per Kilo Code — triad2.0
- HANDOFF per Qoder — triad2.0
- HANDOFF per Qwen — triad2.0
- generate.mjs
- leaRdxR14
- run_source
- Triad per LLM — benchmark di generazione e verifica
- Supporto editor
- graphify
- verify.jl
- run.jl
- cc
- oracle_tests.jl
- SYSTEM_PROMPT.md
- Conformance suite — il contratto eseguibile di Triad
- Riconoscimento su GitHub (Linguist)
- Triad per VS Code
- eval_input
- AGENTS.md
- build_standalone.jl
- `ai/jev_audit.mjs`
- 01_somma/task.md
- 02_fattoriale/task.md
- 03_fibonacci/task.md
- 04_stringhe/task.md
- 05_chiusure/task.md
- copilot-instructions.md
- _probe2.jl
- _probe3.jl
- _qc.jl

## God Nodes (most connected - your core abstractions)
1. `B()` - 297 edges
2. `raise()` - 38 edges
3. `B32()` - 36 edges
4. `@agentrhq/webcmd` - 30 edges
5. `mcpCall()` - 27 edges
6. `solve_goal()` - 26 edges
7. `info()` - 24 edges
8. `Triad 2.0 — Tutorial completo d'uso e programmazione` - 24 edges
9. `tshow()` - 22 edges
10. `rowsFrom()` - 21 edges

## Surprising Connections (you probably didn't know these)
- `Chiamate verificate` --references--> `trackedFiles()`  [INFERRED]
  obsidian-triad/File - ai jev_audit.mjs.md → ai/jev_audit.mjs
- `Chiamate verificate` --references--> `knownFacts()`  [INFERRED]
  obsidian-triad/File - ai jev_audit.mjs.md → ai/jev_audit.mjs
- `Chiamate verificate` --references--> `buildState()`  [INFERRED]
  obsidian-triad/File - ai jev_audit.mjs.md → ai/jev_audit.mjs
- `Chiamate verificate` --references--> `callSystemOne()`  [INFERRED]
  obsidian-triad/File - ai jev_audit.mjs.md → ai/jev_audit.mjs
- `4. Secondo passaggio: localizzazione` --references--> `sweep()`  [INFERRED]
  ai/jev_prompt.md → ai/jev_audit.mjs

## Import Cycles
- None detected.

## Communities (75 total, 17 thin omitted)

### Community 0 - "gen_seed.js"
Cohesion: 0.02
Nodes (125): addDlImm(), addR9Rax(), addRaxRcx(), addRdiImm16(), addRdiRax(), addRdxRdi(), addRsiImm(), addRsp8() (+117 more)

### Community 1 - "B"
Cohesion: 0.02
Nodes (132): addR10R9(), addRaxImm128(), addRaxR10(), addRcxRdx(), addRdiR13(), addRdiRcx(), addRdxImm(), addRdxR15() (+124 more)

### Community 2 - "client.js"
Cohesion: 0.09
Nodes (20): @agentrhq/webcmd, CLIENT_INFO, compactRow(), firstText(), freshnessOf(), listArg(), mcpCall(), parseSse() (+12 more)

### Community 3 - "syntax.jl"
Cohesion: 0.17
Nodes (43): binop_info(), desc(), expect_ident!(), expect_kw!(), expect_op!(), interpolation_end(), isidstart(), iskw() (+35 more)

### Community 4 - "Task S1 (Interprete Triad in Triad-Core)"
Cohesion: 0.05
Nodes (38): Backlog: errori e verifiche, CLI, piattaforme e distribuzione, Come registrare un nuovo bug, Editor, strumenti e documentazione, Evidenze di partenza, Mappa del progetto, Note, Nuove task generate dall'audit del 2026-10-25 (+30 more)

### Community 5 - "Triad 2.0 — Tutorial completo d'uso e programmazione"
Cohesion: 0.05
Nodes (39): 10.1 Assegnamento multipla `(a, b) = expr`, 10.2 `for` destrutturato `for (k, v) in xs`, 10.3 Parametri destrutturati `f((a, b))`, 10. Logica: fatti, regole, solve, 11. DESTRUTTURAZIONE (nuova), 12. Errori come dati, 13. Contratti (`requires` / `ensures`), 14. Budget (+31 more)

### Community 6 - "triad_sexpr_v1.jl"
Cohesion: 0.10
Nodes (29): apply_fn(), apply_lam(), apply_op(), apply_sub(), bind_var(), child_env(), class_of(), Clause (+21 more)

### Community 7 - "S0 / Windows x86-64 — seed con interprete Triad-Core: elseif (M3b2b3q)"
Cohesion: 0.06
Nodes (30): 1. Base dell'estrazione, 2. Tabella (ANCÒRA + RADAR), 3. Voci inferite (RADAR), 4.2 Campi problematici, 4. SPECCHIO — controllo di qualità, 5. Limiti dichiarati, Estrazione E0 — `seed/linux-x86_64/README.md`, `gen_seed.js` (+22 more)

### Community 8 - "_probe.jl"
Cohesion: 0.11
Nodes (25): apply_fn(), apply_lam(), apply_op(), apply_sub(), bind_var(), child_env(), class_of(), Clause (+17 more)

### Community 9 - "B32"
Cohesion: 0.06
Nodes (32): addRsp(), B32(), cmpEaxImm32(), cmpEcxImm32(), cmpR13dImm32(), cmpRaxImm32(), leaR13R14(), leaR15R14() (+24 more)

### Community 10 - "Grafo Graphify.md"
Cohesion: 0.08
Nodes (24): `ai/verify.jl`, Chiamate verificate, Collegamenti, Ruolo nel progetto, Bundle KarpathyWiki — `main.js`, Chiamate verificate, Collegamenti, Ruolo nel progetto (+16 more)

### Community 11 - "steps"
Cohesion: 0.10
Nodes (25): runs-on, steps, strategy, jobs, conformance, seed-linux, seed-windows, os (+17 more)

### Community 12 - "jev_audit.mjs"
Cohesion: 0.14
Nodes (19): buildState(), callSystemOne(), dryRun, extractCliFlags(), FOREIGN_FLAGS, knownFacts(), locate(), QUESTIONS (+11 more)

### Community 13 - "Standard Triad — specifica del linguaggio (versione 0.2.0, bozza)"
Cohesion: 0.08
Nodes (24): 10. Budget, 11. Tracce, 12. Effetti, 13. Builtin, 14. Interfaccia a riga di comando, 15. Stato dell'implementazione di riferimento (informativo), 16.1 Profili di conformità, 16.2 Verifica (+16 more)

### Community 14 - "info"
Cohesion: 0.19
Nodes (24): applicable_m(), apply_lam(), apply_value(), call_builtin(), call_generic(), call_named(), check_contract(), conform() (+16 more)

### Community 15 - "triad.jl"
Cohesion: 0.12
Nodes (17): arity(), atom_eq(), bindvar!(), BreakSig, BuiltinFn, collect_vars!(), ContinueSig, defb() (+9 more)

### Community 16 - "Rec"
Cohesion: 0.12
Nodes (19): Cons, construct(), define_function(), define_struct(), Env, event(), Frame, GenericFn (+11 more)

### Community 17 - "tshow"
Cohesion: 0.14
Nodes (21): command!(), command_name(), find_source(), fresh_world(), incomplete(), listing(), load_file!(), main() (+13 more)

### Community 18 - "File da ispezionare (elenco completo)"
Cohesion: 0.10
Nodes (19): Benchmark AI (strumento di sviluppo), CI, Come eseguire la verifica, Contesto, Domande a cui JEV deve rispondere, Elementi già noti da ispezionare (candidati errori/mancanze), Esempi e seed, File da ispezionare (elenco completo) (+11 more)

### Community 19 - "lib-client.js"
Cohesion: 0.15
Nodes (12): CLIENT_INFO, compactRow(), firstText(), freshnessOf(), mcpCall(), parseSse(), pickRows(), resolveToken() (+4 more)

### Community 20 - "raise"
Cohesion: 0.25
Nodes (19): assert_clause(), build_goal(), build_term(), Clause, destructure!(), ev(), eval_call(), eval_with() (+11 more)

### Community 21 - "gen_seed_linux.js"
Cohesion: 0.16
Nodes (15): B(), B32(), check, code, img, lines, movEax(), movEdi() (+7 more)

### Community 22 - "B. Esempi avanzati"
Cohesion: 0.11
Nodes (18): A. Usare Triad da Julia (API del kernel), B.1 Fusione paradigma: funzione che consulta la KB, B.2 Lista in stile Prolog e `app`, B.3 Negazione per fallimento: foglie (nodi senza figli), B.4 Macro `time_it` che misura e stampa, B.5 Polinomio costruito come albero (codice che genera codice), B.6 Errore come dato con dispatch, B.7 Contratti e budget insieme (+10 more)

### Community 23 - "README.md"
Cohesion: 0.17
Nodes (7): 0.1.0 — iniziale, 0.2.0 — 2026-10-20, Changelog — standard Triad, Non rilasciato — 2026-10-22, Casi, Esecuzione, Profilo Triad-Core

### Community 24 - "HANDOFF per Hermes — triad2.0"
Cohesion: 0.13
Nodes (14): 0. Perché eri bloccato (e cosa è cambiato), 1. I path che non trovavi (ENOENT ripetuti), 2. Stato della suite (eseguita da me, più volte), 3-bis. Secondo giro di correzioni (Qoder, 2026-10-20, suite 221/221), 3. Bug **già corretti** (non riapplicarli, non sovrascriverli), 3-ter. Terzo giro (Qoder, 2026-10-20, suite 240/240): i due punti «restanti», 4. Bug **ancora aperti** (roba buona per te, ordinati per convenienza), 5. Su cosa NON stai duplicando (+6 more)

### Community 25 - "Stato di Triad e del bootstrap S0"
Cohesion: 0.13
Nodes (14): Casi Core non ancora coperti dal seed, Comandi di verifica, Cosa manca, Cosa è pronto, Distanza dall'obiettivo, Obiettivo, Probe `get` seed Windows (round 33), Probe `push!` seed Windows (round 34) (+6 more)

### Community 26 - "Prompt Jev per l'audit del repository Triad"
Cohesion: 0.14
Nodes (13): expectedCount(), 1. Perché "quanti errori?" non è una domanda, 2. Il `state`, 3. Le cinque domande (una richiesta, in parallelo), 4. Secondo passaggio: localizzazione, 5. Come si esegue, 6. Limiti, dichiarati, `caught_by_suite` — Noul (+5 more)

### Community 27 - "vscode/package.json"
Cohesion: 0.15
Nodes (12): categories, contributes, grammars, languages, description, displayName, engines, vscode (+4 more)

### Community 28 - "Piano per completare Triad 2.0 - Stato Aggiornato"
Cohesion: 0.15
Nodes (12): Dopo S1, File S1 Implementati, Immediate: Verifica finale S1, Limitazioni Seed Attuali, Piano per completare Triad 2.0 - Stato Aggiornato, S1 (Interprete Triad in Triad-Core) - ORA COMPLETATO ✅, S2-S4 (Bootstrap) - NON INIZIATO, Seed S0 Windows - COMPLETATO ✅ (+4 more)

### Community 29 - "Triad 2.0 — linguaggio di programmazione"
Cohesion: 0.15
Nodes (13): 1. Launcher (consigliato), 2. File .triad eseguibili direttamente (shebang), 3. Packaging standalone (non ancora disponibile), Avvio, Conformità e indipendenza, Esempio veloce (`examples/assaggio.td`), Fallback diretto, Licenza (+5 more)

### Community 30 - "Triad-Core — sottoinsieme di bootstrap (standard 0.2.0)"
Cohesion: 0.15
Nodes (13): 10. Interfaccia a riga di comando, 11. Conformità, 12. Note per l'implementazione in codice macchina (informative), 1. Scopo e criteri, 2. Lessico, 3. Tipi e valori, 4. Sintassi, 5. Semantica (+5 more)

### Community 31 - "solve_goal"
Cohesion: 0.26
Nodes (12): eval_term(), ExitMark, GL, mark(), prepend(), resolve(), Solution, solve_goal() (+4 more)

### Community 32 - "Triad senza linguaggi ospiti — piano di bootstrap"
Cohesion: 0.17
Nodes (12): 0. Requisito e conseguenza, 10. Stato attuale, 1. Catena di bootstrap, 2. Il seed: cosa deve fare (e quanto costa), 3. Triad-Core (minimo sindacale), 4. Rappresentazione, memoria, generazione di codice, 5. Piattaforme, 6. Milestone e criteri di accettazione (+4 more)

### Community 33 - "reloc"
Cohesion: 0.18
Nodes (11): callL(), ja(), jae(), jb(), jbe(), je(), jmp(), jne() (+3 more)

### Community 34 - "webcmd-plugin-graphify"
Cohesion: 0.18
Nodes (10): Change impact, Code navigation, Commands, Credentials, Examples, Install, Notes, Orientation (+2 more)

### Community 35 - "Confronto Triad 2.0 — in cosa è più bravo degli altri linguaggi"
Cohesion: 0.20
Nodes (10): 1. Base dell'analisi, 2. Sintesi comparativa (ANCÒRA), 3. Tabella (ANCÒRA + RADAR), 4. Voci inferite (RADAR), 5. Cosa non è stato affermato (PENALITÀ), 6. SPECCHIO — campi problematici, 7. Verifiche eseguite, 8. Documenti da aggiornare (segnalati, non modificati) (+2 more)

### Community 36 - "Welcome to your LLM-Wiki"
Cohesion: 0.20
Nodes (9): How to use this plugin, How to verify the install, Quick start, The folder layout, The Schema layer (optional), The three core page types, The wikilink graph, Welcome to your LLM-Wiki (+1 more)

### Community 37 - "runtests.jl"
Cohesion: 0.24
Nodes (5): Test, Triad, out(), run(), val()

### Community 38 - "Triad"
Cohesion: 0.22
Nodes (8): Triad, ace_mode, aliases, color, extensions, language_id, tm_scope, type

### Community 39 - "HANDOFF per Codex — triad2.0"
Cohesion: 0.22
Nodes (8): 0. Panoramica sessioni e lane (chi fa cosa ORA), 1. Stato già fatto e verificato (NON duplicare), 2. Regola trasversale (dal main user) — importante, 3. Candidati liberi (scegli un lane e segnalalo), 4. Ambienti / path utili, 5. Come coordinarsi, 6. Note di Codex (compila tu), HANDOFF per Codex — triad2.0

### Community 40 - "HANDOFF per Kilo Code — triad2.0"
Cohesion: 0.22
Nodes (8): 0. Panoramica sessioni e lane (chi fa cosa ORA), 1. Stato già fatto e verificato (NON duplicare), 2. Regola trasversale (dal main user) — importante, 3. Candidati liberi (scegli un lane e segnalalo), 4. Ambienti / path utili, 5. Come coordinarsi, 6. Note di Kilo (compila tu), HANDOFF per Kilo Code — triad2.0

### Community 41 - "HANDOFF per Qoder — triad2.0"
Cohesion: 0.22
Nodes (8): 0. Panoramica sessioni e lane, 1. Cosa ha fatto Hermes da quando hai scritto il tuo handoff (per non duplicare), 2. Regola trasversale (dal main user), 3. Ambienti / path utili (ripresi dalla tua §1), 4. Bachi aperti lato Julia (la tua lista §4 — ancora buoni per te), 5. Richiesta di coordinamento, 6. Note di Qoder IDE (sessione corrente), HANDOFF per Qoder — triad2.0

### Community 42 - "HANDOFF per Qwen — triad2.0"
Cohesion: 0.22
Nodes (8): 0. Panoramica sessioni e lane (chi fa cosa ORA), 1. Stato già fatto e verificato (NON duplicare), 2. Regola trasversale (dal main user) — importante, 3. Candidati liberi (scegli un lane e segnalalo), 4. Ambienti / path utili, 5. Come coordinarsi, 6. Note di Qwen (compila tu), HANDOFF per Qwen — triad2.0

### Community 43 - "generate.mjs"
Cohesion: 0.25
Nodes (5): buildArgsSource(), commands, here, renderCommand(), repoArg

### Community 44 - "leaRdxR14"
Cohesion: 0.22
Nodes (9): blockLoad(), blockStoreRax(), flagLoad(), flagStoreImm(), flagStoreRax(), leaRdxR14(), maskLoad(), maskStoreImm() (+1 more)

### Community 45 - "run_source"
Cohesion: 0.33
Nodes (8): Err, eval_source(), eval_try(), iscontrol(), run_source(), strip_shebang(), to_err(), TriadError

### Community 46 - "Triad per LLM — benchmark di generazione e verifica"
Cohesion: 0.25
Nodes (7): Flusso di lavoro, Limiti attuali, Metriche, Sicurezza, Struttura, Task inclusi, Triad per LLM — benchmark di generazione e verifica

### Community 47 - "Supporto editor"
Cohesion: 0.29
Nodes (6): Estensione canonica, Installazione, Riconoscimento come linguaggio, Supporto editor, Vim / Neovim, VS Code

### Community 48 - "graphify"
Cohesion: 0.29
Nodes (6): type, url, mcp, mcpServers, graphify, $schema

### Community 49 - "verify.jl"
Cohesion: 0.53
Nodes (5): Triad, main(), parse_opts(), run_solution(), task_dirs()

### Community 50 - "run.jl"
Cohesion: 0.47
Nodes (4): case_dirs(), check_or_update(), Triad, run_case()

### Community 51 - "cc"
Cohesion: 0.33
Nodes (6): cc(), cmpAlImm(), cmpByteR8DispImm(), cmpByteRsiDispImm(), cmpByteRsiImm(), movByteRspImm()

### Community 53 - "SYSTEM_PROMPT.md"
Cohesion: 0.40
Nodes (4): Esempio, Regole di output, Sottoinsieme supportato (Triad-Core), Stile

### Community 54 - "Conformance suite — il contratto eseguibile di Triad"
Cohesion: 0.40
Nodes (5): Casi attuali (`cases/`, profilo Full), Conformance suite — il contratto eseguibile di Triad, Formato di un caso, Profili, Runner

### Community 55 - "Riconoscimento su GitHub (Linguist)"
Cohesion: 0.40
Nodes (4): Nel frattempo (prima della PR), Passi per la PR, Perché `.triad` e non `.td`, Riconoscimento su GitHub (Linguist)

### Community 56 - "Triad per VS Code"
Cohesion: 0.40
Nodes (4): Cosa copre, Installazione (sviluppo), Nota su `.td`, Triad per VS Code

### Community 57 - "eval_input"
Cohesion: 0.50
Nodes (4): eval_input(), eval_qq(), is_query(), Node

### Community 61 - "`ai/jev_audit.mjs`"
Cohesion: 0.67
Nodes (3): `ai/jev_audit.mjs`, Collegamenti, Ruolo nel progetto

## Knowledge Gaps
- **13 isolated node(s):** `World`, `Triad`, `Triad`, `Triad`, `Triad` (+8 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 480 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **17 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `B()` connect `B` to `gen_seed.js`, `reloc`, `B32`, `leaRdxR14`, `cc`?**
  _High betweenness centrality (0.036) - this node is a cross-community bridge._
- **What connects `World`, `Triad`, `Triad` to the rest of the system?**
  _13 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `gen_seed.js` be split into smaller, more focused modules?**
  _Cohesion score 0.015151515151515152 - nodes in this community are weakly interconnected._
- **Why does `Triad 2.0 — Tutorial completo d'uso e programmazione` connect `Triad 2.0 — Tutorial completo d'uso e programmazione` to `README.md`?**
  _High betweenness centrality (0.008) - this node is a cross-community bridge._
- **Should `B` be split into smaller, more focused modules?**
  _Cohesion score 0.015151515151515152 - nodes in this community are weakly interconnected._
- **Why does `Standard Triad — specifica del linguaggio (versione 0.2.0, bozza)` connect `Standard Triad — specifica del linguaggio (versione 0.2.0, bozza)` to `README.md`?**
  _High betweenness centrality (0.007) - this node is a cross-community bridge._
- **Should `client.js` be split into smaller, more focused modules?**
  _Cohesion score 0.09096045197740113 - nodes in this community are weakly interconnected._