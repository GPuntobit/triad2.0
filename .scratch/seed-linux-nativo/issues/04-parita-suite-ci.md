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
