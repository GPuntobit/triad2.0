# 09 — CLI e toolchain senza Node

Type: grilling
Status: resolved
Blocked by: 07

## Question

(Da [04 — Parità: suite di riferimento, CI e politica delle divergenze](04-parita-suite-ci.md),
round 2 Q3 scelta (c) rettificata in round 3: promosso dalla foglia «`triad-cli` senza
Node», che con questa ticket esce da «Not yet specified» della mappa.)

Con il percorso d'uso chiuso da
[07 — Installazione e launcher: il contratto zero-install](07-installazione-launcher.md),
qual è il contratto della **CLI senza Node**?

- quali sotto-comandi restano (`run`, `test`, `status`, …) e quali restano Node per ora
  (es. `ai verify`, strumento di sviluppo fuori dalla catena S0→S4);
- in cosa sono implementati (shell POSIX + seed nativo) e dove vivono (`cli/`, `bin/`);
- cosa succede a `cli/triad-cli.mjs`: sostituzione, affiancamento o retirement tracciato;
- coerenza col confine zero-install (solo shell POSIX + repo) e con la regola operativa 2
  (Node tollerato solo come strumento di sviluppo, mai nel percorso d'uso né di verifica).

Cross-ref: [04](04-parita-suite-ci.md) (scope: solo ciò che serve al percorso d'uso e alla
verifica, niente rimozione completa di JS);
[08 — Harness di verifica senza Node (shell POSIX)](08-harness-verifica-senza-node.md)
(stessa direzione per la verifica).

## Answer

Decisioni firmate via grilling (2 round, 2026-11-04):

**Sotto-comandi (Q1, Q4)**: la CLI senza Node è **completa**: `bin/triad-cli` in shell
POSIX sostituisce uno-a-uno `triad-cli`, con semantica di **pura delega**:

- `run <file> [-- args]` → `bin/triad` (contratto di *Installazione e launcher*, incluso
  `--jsref`; nessun fallback JS proprio);
- `test conformance|probes|all` → gli harness POSIX di 08 (vedi sotto); nomenclatura
  ripulita dai nomi legacy `run`/`conformance` (dove `test run` significava «conformance
  core»: ambiguo);
- `status` → info ambiente: root del progetto, `uname -s -m`, seed trovato/eseguibile e
  percorso, stato del `PATH` d'installazione; output deterministico, niente colori.

Exit code = quello del comando delegato.

**Interfaccia imposta a 08 (Q5)**: entry point POSIX invocabili da qualunque cwd, exit 0 =
gate verde, exit ≠ 0 = fallimento (report su stdout, diff leggibili):

- `conformance/run.sh` — conformance + golden `selfhost` + esiti `bad_*`;
- `tests/probes/run_probes.sh` — probe `ok_*`/`test_*`;
- `verify.sh` alla root — gate completo di *Parità: suite di riferimento*.

`triad-cli test conformance|probes|all` mappa 1:1 sui tre. Meccanismo interno e transizione
dal runner Node restano decisione di 08 (vincolo registrato come commento su 08).

**CLI Node di sviluppo (Q3, Q6, Q7)**: `cli/triad-cli.mjs` **resta col nome attuale**
(rinomina `triad-dev` scartata: churn su `AGENTS.md` regola 7, README, CI, `ai/` per
beneficio cosmetico — i percorsi d'invocazione già disambiguano), ma si assottiglia ai soli
comandi dev: `seed generate`, `ai verify`, `ext check|package`. Escono `run`/`test`/`status`
(coperti dalla CLI sh) e `build standalone` (già morto). Il fallback JS automatico resta
lecito negli strumenti dev (regola operativa 2); il riferimento JS si invoca come
`node seed/dev/triad_core.cjs`. La logica di stub/fallback (`seedIsStub`, `runSeed`) decade
con `run.mjs`.

**Launcher e installazione (Q2, Q8)**: il ramo `bin/triad-native` **esce da `bin/triad`**:
exec-sempre-il-seed, nessun artefatto opzionale devia silenziosamente il runtime (l'unico
bundle standalone attuale è la CLI Node impacchettata con esbuild, non un interprete; S2
reintrodurrà la sua risoluzione quando esisterà). `install.sh` installa `triad` +
`triad-cli` come wrapper a percorso assoluto; **avvisi Node fuori dal percorso utente**;
verifica finale = smoke test byte-exatto (07) + `triad-cli status`, ormai senza Node.

Conseguenze registrate senza dibattito:

- `bin/triad.cmd` / `bin/triad-cli.cmd` (Windows) restano invariati: fuori dalla
  destinazione Linux; il PE resta la piattaforma Windows;
- CI `seed-linux` punta agli stessi entry point (le invocazioni attuali `triad-cli status`
  e `triad-cli test conformance` diventano CLI sh → `conformance/run.sh`);
- promessa zero-install invariata nella formulazione (sola esecuzione): la CLI sh essendo
  shell POSIX non aggiunge dipendenze.

Aggiornamenti: `TASK.md` (N18: CLI sh e dev CLI), vincolo d'interfaccia commentato su
[08 — Harness di verifica senza Node (shell POSIX)](08-harness-verifica-senza-node.md).
Nessun ADR.

## Comments

- 2026-11-05 (chiusura N18, attuazione completa): CLI senza Node **consegnata**.
  (Q1/Q4) `bin/triad-cli` in shell POSIX, pura delega: `run <file> [-- args]` → `bin/triad`;
  `test conformance [--update]|probes|all` → `conformance/run.sh`/`run_probes.sh`/`verify.sh`;
  `status` deterministico senza colori (root, `uname -s -m`, seed trovato/eseguibile, stato del
  PATH d'installazione); exit code = comando delegato, exit 2 = errori d'uso; invocabile da
  qualunque cwd. (Q3/Q6/Q7) `cli/triad-cli.mjs` assottigliata ai soli comandi dev
  (`seed generate`, `ai verify`, `ext check|package`) con il nome invariato; escono
  `run`/`test`/`status` e `build standalone`; `run.mjs`/`test.mjs`/`build.mjs` eliminati e con
  loro `seedIsStub`/`runSeed`/`runSh`/`findSeed` («la logica di stub/fallback decade»).
  (Q2/Q8) `bin/triad-native` fuori dal launcher; `install.sh` installa `triad` + `triad-cli`
  come wrapper a percorso assoluto; verifica finale = smoke byte-exatto + `triad-cli status`,
  senza Node; `linux-toolchain` gira senza `setup-node` e copre launcher + install + smoke
  negativo (golden alterato → installazione fallisce).
  Nota d'implementazione: i comandi dev non sono raggiungibili da `bin/triad-cli` (solo
  `node cli/triad-cli.mjs …`): la CLI sh resta così a pura delega senza Node per intero.
  Conseguenza registrata: `bin/triad-cli.cmd` (Windows) resta invariato ma i comandi
  `run`/`test`/`status` sono usciti da `triad-cli.mjs` — su Windows restano da disambiguare
  in uno sforzo futuro (fuori destinazione Linux). Deviazione minore dall'acceptance:
  il job `seed-linux` resta su runner pinnato `ubuntu-24.04` (non `ubuntu-latest`), per
  coerenza col resto della CI e riproducibilità del gate.
