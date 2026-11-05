# 04 — Parità: suite di riferimento, CI e politica delle divergenze

Type: grilling
Status: resolved

## Question

La destinazione chiede stdout byte-identico al PE (confermata: parità = byte-exatto,
limiti noti del PE che restano limiti, nessuna semantica nuova). Restano da decidere i
dettagli operativi:

- **Suite di parità**: `conformance/core/` (39 casi), probe `ok_*`/`test_*`, golden
  `selfhost/source.expected.out` — tutte e tre come gate, o un sottoinsieme?
- **CI**: il job `seed-linux` correrà le suite sull'ELF **senza Wine**; il job di parità PE
  resta con Wine opzionale o necessario? (Oggi `seed-linux` verifica solo lo stub E0:
  «Triad seed Linux OK».)
- **Divergenze**: l'ordine di verità proposto è `SPEC-CORE.md` > PE (riferimento entro i
  limiti noti) > ELF; ogni conflitto si segnala come ticket, senza inventare semantica
  (regola operativa 1). Conferma?

Cross-ref: [03 — Contratto delle routine `os_*`](03-contratto-os-star.md) determina a che
livello la parità si può verificare oltre all'output finale.

## Answer

Decisioni firmate via grilling (3 round, 2026-11-04):

- **Suite di parità come gate (round 1 Q1)**: tutte e tre le suite più gli esiti dei
  `bad_*` — `conformance/core` (39 casi, **senza più lo skip storico `liste`**), probe
  `ok_*`/`test_*` (19), golden `selfhost/source.expected.out`; i `bad_*` (20) entrano solo
  per **exit code + stdout vuoto**, mai per i testi d'errore (PE muto per contratto,
  stderr solo sull'ELF fuori parità).
- **Meccanismo (round 1 Q2)**: confronto su **golden condivisi**, non su scambio di
  artefatti di output fra job.
- **Ambiente di verifica (round 1 Q3 → rettifica round 2 Q1/Q3)**: **solo Linux nativo** —
  niente Wine, niente runner Windows nella verifica. Gambe Windows rimosse dalla CI:
  job `seed-windows` e matrice `site-gen`. Il lato PE resta garantito da **hash di
  `seed.hex`** (gate anti-tampering, *Immutabilità del PE*) + **golden congelati**
  (registro del comportamento PE): il PE non viene emulato né rieseguito dal gate.
- **Anti-drift (round 1 Q4)**: step CI `seed/dev/gen_seed.js <windows|linux>` + `cmp`
  contro gli artefatti versionati, che chiude la lacuna del drift `649709a` (ADR 0001);
  Node come strumento di sviluppo tollerato (regola operativa 2).
- **Ordine di verità e divergenze (round 1 Q5 + round 2 Q2)**: `SPEC-CORE.md` > PE (entro
  i limiti noti, ora registrato nei golden) > ELF; ogni conflitto = **CI rossa + ticket**,
  nessuna semantica inventata (regola operativa 1); i golden si allineano solo per cambi
  semantici deliberati documentati e in quel caso si rigenerano **da `SPEC-CORE.md`** —
  la riesecuzione manuale del PE resta verifica una tantum opzionale, mai il meccanismo
  del gate.
- **Portata del «riscriviamo tutto» (round 2 Q3 → (c), rettificato a (b) in round 3 Q2)**:
  la **destinazione non cambia**; lo scope si estende solo a ciò che serve al percorso
  d'uso (CLI/toolchain) e alla verifica (harness). Niente «rimozione completa di
  JavaScript»: restano fuori-scope generatori `gen_seed.js`, `triad_core.cjs`, tooling
  `ai/`.
- **Ticket nuovi (round 3 Q3)**: _Harness di verifica senza Node (shell POSIX)_, bloccato
  da 06, e _CLI e toolchain senza Node_, bloccato da 07 — entrambi `grilling`.

Asset: ADR [`docs/adr/0002-verifica-parita-senza-pe.md`](../../../docs/adr/0002-verifica-parita-senza-pe.md)
— «La verifica di parità non riesegue mai il PE», con le alternative scartate (runner
Windows, Wine, confronto diretto PE↔ELF).

## Comments

- 2026-11-05 (attuazione): rimozione delle gambe Windows **implementata** nella CI — job
  `seed-windows` eliminato e matrice `site-gen` ridotta a `ubuntu-24.04`, verifica solo su
  Linux nativo. Promemoria: il commit `fc320f4` dichiara questa rimozione nel messaggio
  ma **non la implementa** nel diff (tocca solo `docs/` e `.scratch/`); è stata fatta qui.
  Lato PE resta il gate hash di `seed.hex` (spostato nel job `seed-linux`) + golden
  congelati (ADR 0002). Conseguenza nota: le gate che giravano sul PE (probe `ok_*`/
  `test_*`, golden `selfhost/source.td`, probe `get`, smoke `selfhost/main.td`) non sono
  più eseguite da nessun job: rientrano sull'ELF nativo alla parità N17 (Q1). Ancora da
  attuare da questa decisione: harness senza Node (ticket 08) e rimozione dello skip
  storico `liste` (39/39 già verdi col runner Node).

- 2026-11-04 (sessione su *Politica dei byte del PE nella rifattorizzazione*): fatto
  accertato per la scelta della suite CI — il gate hash attuale rileva cambi in
  `seed.hex` ma **non** la divergenza generatore/artefatti (classe del drift `649709a`:
  `gen_seed.js` modificato senza rebuild, CI silenziosa). Un controllo
  `node seed/dev/gen_seed.js && cmp` chiuderebbe la lacuna. Storia verificata:
  `docs/adr/0001-immutabilita-pe-riproducibilita-dump.md`.
