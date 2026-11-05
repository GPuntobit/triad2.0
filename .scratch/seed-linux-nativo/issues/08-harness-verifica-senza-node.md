# 08 — Harness di verifica senza Node (shell POSIX)

Type: grilling
Status: resolved
Blocked by: 06

## Question

(Da [04 — Parità: suite di riferimento, CI e politica delle divergenze](04-parita-suite-ci.md),
round 2 Q3 scelta (c) rettificata in round 3: lo scope si estende a ciò che serve al
percorso d'uso e alla verifica.)

Gli harness di verifica sono oggi Node (`conformance/run.mjs`, `tests/probes/run_probes.mjs`).
Come si riscrivono in **shell POSIX pura** senza perdere il gate di parità?

- scoperta dei casi e iterazione sulle suite (39 conformance + 19 probe + 20 `bad_*`);
- confronto byte-exatto dei golden (`cmp`? `od`? checksum?) e diff leggibile in caso di fallimento;
- esiti dei `bad_*`: exit code + stdout vuoto, niente confronto dei testi d'errore;
- gestione del golden `selfhost/source.expected.out`;
- transizione: il runner Node resta durante la migrazione o si sostituisce in un colpo solo?

I fatti sugli strumenti garantiti da
[06 — Ricerca: strumenti garantiti per la decodifica di `seed.hex`](06-ricerca-decoder.md)
delimitano il vocabolario ammissibile di tool POSIX.

Cross-ref: [04](04-parita-suite-ci.md) (composizione del gate e meccanismo dei golden
condivisi); [07 — Installazione e launcher: il contratto zero-install](07-installazione-launcher.md)
(solo shell POSIX + repo).

## Answer

Contratto firmato via grilling (3 round, 2026-11-04):

- **Oracle dei probe (Q1)**: golden sidecar committati per tutti i 19 `ok_*`/`test_*`
  (più `selfhost/source.td` e il sidecar `test_simple.expected.out` dello smoke test di
  07): un solo meccanismo di verità per tutte le suite; il confronto seed↔JS esce dal
  gate (JS fuori dalla catena di verifica, regola operativa 2 + *Parità: suite di
  riferimento*).
- **Grado del confronto (Q2)**: **byte-exatto `cmp`**, nessuna normalizzazione CRLF —
  regola operativa 5; su Linux nativo un `\r\n` è un bug che deve far fallire il gate.
- **Runtime (Q3)**: seed ELF del repo (`seed/linux-x86_64/seed`) con override
  `TRIAD_SEED`; nessun fallback JS (la logica di stub/fallback decade con `run.mjs`,
  come da *CLI e toolchain senza Node*), nessuna dipendenza da `install.sh`: il gate gira
  su checkout nudo; seed mancante/non eseguibile → exit ≠ 0 con errore chiaro.
  Conseguenze registrate senza dibattito: nessuna logica stub/soglia 4 KB nell'harness
  (transitoria per contratto *Installazione e launcher*);
  `conformance/cases` (Triad-Full) fuori dal gate, come già in CI.
- **Transizione (Q4)**: **un colpo solo** — `conformance/run.mjs`,
  `tests/probes/run_probes.mjs` e `conformance/run.test.mjs` escono nello stesso cambio,
  CI ripuntata ai nuovi entry point; affiancamento scartato (due fonti di verità per lo
  stesso gate).
- **Semantica dei `bad_*` (Q5)**: exit ≠ 0 (qualsiasi codice) + stdout vuoto; nessun
  vincolo sui testi d'errore né sul codice specifico (il contratto `os_*` fissa 1/2 sulle
  due piattaforme ma il gate non riesegue il PE — ADR 0002).
- **Casa di `--update` (Q6)**: flag di `conformance/run.sh`, con avviso «i golden si
  rigenerano solo per cambi semantici deliberati da SPEC-CORE.md»; nessun nuovo comando
  nella dev CLI.
- **Perimetro di `verify.sh` (Q7)**: solo gli entry point sh (`run.sh` +
  `run_probes.sh`); l'anti-drift Node (`gen_seed.js && cmp`) resta step CI/dev separato.
- **Report di fallimento (Q8)**: `diff -u` (LC_ALL=C) fra golden e output reale + riga
  exit atteso/ottenuto su stdout, sintesi compatta come riga di riepilogo del caso.
- **Interfaccia (Q9)**: `conformance/run.sh [--update]`, `tests/probes/run_probes.sh`
  senza flag, suite cablate (39 + 19 + `bad_*` + selfhost); niente `--cases`/`--skip`/
  `--strict`; `expected.golden` legacy resta solo come fallback di lettura.
- **Fonte della generazione una tantum dei golden (Q10)**: **PE**, riesecuzione manuale
  una tantum (lecita per *Parità: suite di riferimento*), JS reference come controllo
  incrociato; fallback documentato: ELF validato ↔ JS con uguaglianza stretta attestata
  nel commit. I golden si congelano poi secondo la policy di 04.
- **Esito dei probe (Q11)**: sidecar `<file>.expected.code` esplicito per tutti (come
  nei casi conformance): il gate registra sempre «stdout + exit code», nessuna
  assunzione implicita.

Aggiornamenti: `TASK.md` (N17: gli entry point sh sostituiscono i runner Node nella
lista files). Nessun ADR (nessuna delle tre condizioni: il contratto vive nella ticket e
in `TASK.md`; ADR 0002 copre già la scelta di fondo «la verifica non riesegue il PE»).

## Comments

- 2026-11-04 (sessione su *CLI e toolchain senza Node*): vincolo d'interfaccia imposto da
  [09](09-cli-toolchain-senza-node.md) (Q5, risolta): questa ticket deve consegnare entry
  point POSIX `conformance/run.sh`, `tests/probes/run_probes.sh` e `verify.sh` (root),
  invocabili da qualunque cwd, exit 0 = gate verde, report su stdout. La CLI sh
  `bin/triad-cli` li chiama 1:1 via `test conformance|probes|all`. Meccanismo interno e
  transizione dal runner Node restano di pertinenza di questa ticket.
