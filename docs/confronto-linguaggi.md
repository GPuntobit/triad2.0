# Confronto Triad 2.0 — in cosa è più bravo degli altri linguaggi

- **Documento di riferimento:** [`SPEC.md`](../SPEC.md) (v0.2.0), [`README.md`](../README.md), Appendice A
- **Codice analizzato:** `SEIS0-official/triad2.0` @ `98e3fdb5c3cbb5785c4a0597d6f60d10060e7aac` (= HEAD locale = `main` dell'organizzazione)
- **Indice Graphify:** repository `6a4868d9-5f27-483e-a13b-3b71a04433d1`, build `783641b1-08f0-4162-9aa6-cd36259bb583`, 648 nodi / 1.497 archi / 21 comunità, modello `minishlab/potion-base-8M`, indicizzato 2026-10-23T00:22Z
- **Data dell'analisi:** 2026-10-23
- **Metodo:** kit ANCÒRA / PENALITÀ / RADAR / SPECCHIO + 20 interrogazioni Graphify (`query_graph`, `graphify_find`, `graphify_callers`, `graphify_tests_for`, `impact_and_risk`) + esecuzione delle suite locali
- **Esito:** le meccaniche sono verificate nel codice e nei test; i primati comparativi sono marcati come Inferiti dove il documento non li dichiara.

Regola applicata: basare ogni valore su ciò che il documento e il codice dicono effettivamente; se un confronto non è sostenibile, lasciare il campo vuoto e indicarne il motivo.

## 1. Base dell'analisi

**Cosa ha fornito Graphify.** Localizzazione dei simboli e dei numeri di riga (`solve_goal` L431, `solve_opts` L1425, `check_contract` L1192, `assert_clause` L1398, `invoke_method` L1223, `with_effects` L855, `expand_macro` L1324, `known_type` L258, `applicable_m` L1200, `morespecific` L1202), il blast radius via `impact_and_risk`, e i 21 simboli delle famiglie del grafo. Tutte le 20 query sono tornate con `grounded=true`.

**Cosa è stato verificato eseguendo il codice.** `test/runtests.jl` → 261/261 PASS; `conformance/run.jl` → 12/12 Full OK (`conformance: OK`); `test/oracles/oracle_tests.jl` → 4/4 PASS contro SWI-Prolog, SBCL e Julia. Tutti e tre gli interpreti esterni sono installati su questa macchina, quindi i testset oracolo non si saltano.

**Cosa resta fuori portata.** Graphify descrive relazioni e simboli indicizzati: non certifica la correttezza semantica, la copertura dei test o l'assenza di bug (vedi `TASKS.md`). Il grafo è stato interrogato sullo snapshot a `98e3fdb`; il repository può essere cambiato da allora.

## 2. Sintesi comparativa (ANCÒRA)

**1. La logica è un valore, non un sottosistema.** In Prolog il goal è un comando del risolutore; in Julia e Python la logica è una libreria da importare. In Triad `solve` **è un valore** (§6.3), ammesso in espressioni e comprehension, e il motore è iterativo con stack e trail (`triad.jl: solve_goal` L431). Il vantaggio: nessun bridging fra due mondi.

**2. Il fallimento è un dato, non un'interruzione.** Gli errori hanno un `kind` tassonomico e dati strutturati: `:syntax` con riga e colonna (`syntax.jl: syntax_error` L25), `:contract` con funzione, clausola e condizione (`triad.jl: check_contract` L1192), più `:effect`, `:budget`, `:method`. In Python, Java e Go l'errore scavalca lo stack; qui è ispezionabile, trattabile con `try`, e filtrabile per tipo.

**3. Gli effetti sono verificati, non dichiarati.** `!state` e `!io` non sono annotazioni: `assert_clause` (L1398) rifiuta una clausola che modifica la knowledge base senza `!state`, e `invoke_method` (L1223) rifiuta un callee che dichiara effetti che il chiamante non consente. Haskell modella gli effetti, ma staticamente: qui il controllo è dinamico e applicato a ogni chiamata.

**4. Contratti, budget e tracce sono valori.** `requires`/`ensures` (§9), `with budget` (§10) e `with trace` (§11) vivono nel linguaggio, e il loro fallimento è un `Err(:contract)` o `Err(:budget)` con contesto. Altrove i contratti sono macro o librerie, e il budget quasi sempre un timeout esterno al processo.

**5. Codice come dato senza rinunciare al resto.** Lisp e derivati fanno del codice-dato l'unico modello: qui l'albero uniforme (`Node`) e i macro (`expand_macro` L1324) convivono con dispatch sui tipi, contratti ed effetti nella stessa sintassi a blocchi.

**6. La semantica è verificata contro i riferimenti, non dichiarata.** `test/oracles/oracle_tests.jl` confronta l'output di Triad con **SWI-Prolog** (famiglia), **SBCL** (closure/lambda) e **Julia** (multiple dispatch): l'ho eseguito qui e passa 4/4. E la conformità è a livello di standard: 41 golden statici che un'altra implementazione — il seed in codice macchina, un futuro compilatore nativo — deve passare senza Julia.

## 3. Tabella (ANCÒRA + RADAR)

| Area | Cosa sa fare | Sezione | Dove è più bravo degli altri | Fonte | Evidenza | Motivo (se vuoto) |
|---|---|---|---|---|---|---|
| Logica integrata | `fact`/`rule`, unificazione con occurs-check, backtracking; `solve` è un valore; predicato in espressione; `limit/depth/steps/trace` | §6, §10 | Il motore è nel linguaggio: `solve` entra in espressioni e comprehension; la ricorsione infinita chiude in `Err(:budget)` invece di saturare lo stack | Inferito | SPEC §6.3, §10; `triad.jl solve_goal` L431, `solve_opts` L1425 | — |
| Errori come dati | `Err(kind,msg,data)`; `try b end` fa dell'errore il valore; kind `:syntax`, `:contract`, `:effect`, `:budget`, `:method`, `:ambiguous`, `:type` | §8 | Il fallimento è un dato ispezionabile con `kind` su cui fare dispatch e `data` con dettagli, invece di un'eccezione che scavalca lo stack | Estratto | Appendice A; SPEC §8 (tabella `kind`); `syntax.jl` L25; `triad.jl` `struct Err` L74 | — |
| Contratti, budget, tracce, effetti | `requires`/`ensures` a runtime; `with budget` → `Err(:budget)`; `with trace` → `Traced(result, trace)`; effetti `!io`/`!state` con controllo dinamico | §9–§12 | Contratto, budget e traccia sono valori combinabili con gli errori come dati; gli effetti sono verificati a ogni chiamata, non annotati | Estratto | Appendice A; README; `triad.jl check_contract` L1192, `w.budget` L210, `w.tracer` L214, `assert_clause` L1398, `invoke_method` L1223 | — |
| Codice come dato e macro | `:(e)`/`quote` restituiscono codice; `$x` inserisce codice o costanti; macro con argomenti non valutati | §7 | L'albero uniforme convive con logica, contratti ed effetti nella stessa sintassi a blocchi, invece di essere l'unico modello | Inferito | SPEC §3, §7; `triad.jl Node`, `expand_macro` L1324, `syntax.jl string_node` | — |
| Tipi, `struct`, multiple dispatch | `::` e `struct` dichiarati; dispatch sui tipi degli argomenti con `Err(:method)`/`:ambiguous`; costruttore che verifica i tipi dei campi | §4–§5 | *(vuoto)* | *(vuoto)* | *(vuoto)* | Il documento dichiara che Triad **riprende** il multiple dispatch da Julia (Appendice A) e non afferma alcun vantaggio: senza benchmark il confronto sarebbe inventato. La funzionalità esiste ed è verificata (`known_type` L258, `applicable_m` L1200, `morespecific` L1202) |
| Standard con contratto eseguibile | SPEC v0.2.0 + 41 golden (12 Full, 29 Core); seed S0 in codice macchina (PE Windows, ELF Linux); CI Windows+Linux; audit Jev in `ai/` | §16, §15 | L'uguaglianza è verificabile da terzi: i golden sono statici e non richiedono Julia, e un'implementazione non può dichiararsi conforme senza eseguirli | Estratto | SPEC §16.2; `conformance/README.md`; `STATUS.md`; `conformance/run.jl`; `.github/workflows/ci.yml`; `seed/dev/gen_seed.js`, `gen_seed_linux.js`; `ai/jev_audit.mjs` | — |

## 4. Voci inferite (RADAR)

Tre affermazioni non sono prese parola per parola dal documento e sono marcate **Inferito** nella tabella:

1. **«La logica è migliore perché è un valore»** — derivata da SPEC §6.3 («solve è un valore») e §10 (motore iterativo con stack, trail e budget), più l'implementazione in `triad.jl` (`solve_goal` L431, `solve_opts` L1425). Il confronto con Prolog e Julia è un giudizio, non una misura.
2. **«Il codice-dato convive con tipi, contratti ed effetti»** — derivata da SPEC §3 e §7 e dall'Appendice A («integrazione dei tre modelli in un'unica sintassi a blocchi»), confermata dai simboli `Node` ed `expand_macro` L1324. Il primato su Lisp è argomentativo.
3. **«Gli effetti dinamici battono quelli statici»** — derivata da `assert_clause` L1398 e `invoke_method` L1223 (controllo a runtime) confrontati con il sistema di effetti statico di Haskell: il confronto è limitato al meccanismo, non esteso ad altre dimensioni.

Tutte le altre righe sono **Estratto**: meccanismi e tassonomie sono ripresi da Appendice A, §8–§12 e §16, e ancorati a simboli reali.

## 5. Cosa non è stato affermato (PENALITÀ)

- Nessuna prestazione: nel repository non esiste alcun benchmark, quindi non si afferma che Triad sia più veloce, più sicuro o più produttivo.
- Nessun primato sul multiple dispatch: Triad riprende il meccanismo da Julia (Appendice A) senza dichiarare vantaggi; il campo resta vuoto.
- Nessuna superiorità "generale" su Lisp: il bilancio tra semplicità e potenza espressiva è un giudizio di gusto, non un fatto documentato.
- Il confronto con Eiffel (contratti nel linguaggio) e Haskell (effetti) è limitato ai meccanismi descritti e non viene esteso.
- I testset oracolo sono opzionali per costruzione (guardati da `isfile` sull'eseguibile): l'esito 4/4 vale per questa macchina, dove SWI-Prolog, SBCL e Julia risultano installati.

## 6. SPECCHIO — campi problematici

| Affermazione | 1. Assunzioni non esplicite? | 2. Interpretazione alternativa? | 3. Calcoli tra sezioni? | 4. Affidabilità | Perché |
|---|---|---|---|---|---|
| «Meglio di Prolog perché la logica è un valore» | Sì | Sì: può voler dire meno verbosità, non più potenza | No | **Medio** | Il meccanismo è verificato nel codice; il primato è giudizio mio |
| «Meglio di Haskell sugli effetti» | No | Sì: dinamico vs statico è un compromesso, non un vantaggio assoluto | No | **Medio** | Meccanismo verificato (`assert_clause` L1398, `invoke_method` L1223); confronto parziale |
| «Meglio di Lisp perché tiene tipi e contratti» | Sì | Sì: si può perdere in semplicità | No | **Medio** | Coesistenza verificata; il bilancio è interpretativo |
| «Meglio di Julia sul dispatch» | No | — | No | **Basso** | Nessun vantaggio dichiarato e nessun benchmark: campo lasciato vuoto |
| «Semantica verificata contro SWI-Prolog/SBCL/Julia» | No | No | No | **Alto** | Suite eseguita in questa sessione: 4/4 PASS, exit 0 |
| «Conformità verificabile da terzi» | No | No | Sì: SPEC §16.2 + `conformance/` + `STATUS.md` + CI | **Alto** | 41 golden statici; runner eseguito: `conformance: OK`, exit 0 |
| Conteggio del grafo | No | Sì: 648/1.497/21 ora vs 649/1.494/21 in `TASKS.md` | Sì | **Alto** | `TASKS.md` descrive l'indice a `b4fb8ae`; quello corrente è a `98e3fdb` |

## 7. Verifiche eseguite

| Comando | Esito |
|---|---|
| `julia --startup-file=no test/runtests.jl` | `Triad \| 261 261 44.1s` — exit 0 |
| `julia --startup-file=no conformance/run.jl` | 12/12 PASS (dispatch, errore, famiglia, garanzie_core, hello_shebang, macro, macro_eval, prolog, tour, valori, …) — `conformance: OK` — exit 0 |
| `julia --startup-file=no test/oracles/oracle_tests.jl` | `SWI-Prolog vs Triad (famiglia) 2/2`; `SBCL vs Triad (closure/lambda) 1/1`; `Julia vs Triad (multiple dispatch) 1/1` — exit 0 |

## 8. Documenti da aggiornare (segnalati, non modificati)

- `PROMPT_JEV.md`: dichiara «243 test, tutti verdi (243/243)», ma a `98e3fdb` la suite è a **261/261**.
- `TASKS.md`: riporta 649 nodi / 1.494 relazioni / 21 comunità (indice a `b4fb8ae`); l'indice corrente è **648 / 1.497 / 21**.

## 9. Accesso a Graphify

- Server MCP: `https://api.graphify.com/v1/mcp` con header `Authorization: Bearer gfy_mcp_…` (Workspace API Token, valido solo per l'MCP: la REST `api.graphify.com/v1/*` risponde 401).
- Workspace: `gpuntobit-01-s-workspace`, tenant `a3bccac0-3ea8-49ce-8114-bf5b8fbadb11`.
- Il token è pinnato al workspace e non può cambiarlo (`workspace_pinned`).
- `GPuntobit/triad2.1` **non** è indicizzato: la GitHub App è collegata solo all'installazione dell'organizzazione `SEIS0-official`. Poiché `98e3fdb` è anche `main` di `SEIS0-official/triad2.0`, l'indice contiene lo stesso codice di `triad2.1`. Per indicizzare il fork serve agganciare l'installazione personale al tenant (flusso `link/start` + OAuth GitHub avviato dalla sessione del browser).
