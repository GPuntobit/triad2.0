# 04 — Parità: suite di riferimento, CI e politica delle divergenze

Type: grilling
Status: open

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

## Comments

- 2026-11-04 (sessione su *Politica dei byte del PE nella rifattorizzazione*): fatto
  accertato per la scelta della suite CI — il gate hash attuale rileva cambi in
  `seed.hex` ma **non** la divergenza generatore/artefatti (classe del drift `649709a`:
  `gen_seed.js` modificato senza rebuild, CI silenziosa). Un controllo
  `node seed/dev/gen_seed.js && cmp` chiuderebbe la lacuna. Storia verificata:
  `docs/adr/0001-immutabilita-pe-riproducibilita-dump.md`.
