# 06 — Architettura codegen del compilatore nativo

Type: prototype
Status: open
Blocked by: 04, 05

## Question

La mappa _Seed Linux nativo senza Wine_ ha fissato per il *generatore del seed*: un core del
codegen condiviso + due backend di piattaforma (PE/ELF), con il confine `os_*` a piazzamenti
ordinati. Il compilatore nativo è un programma Triad che deve emettere gli stessi formati:
questa decisione stabilisce se **speculare quell'architettura dentro il compilatore** —

- core del codegen in Triad + backend PE/ELF riutilizzabili per ogni artefatto;
- il confine `os_*` come contratto anche per gli artefatti compilati (il S1 compilato deve
  parlare col SO: stessa lista `os_*`, nuova interfaccia, o ABI intermedio?);
- cosa del contratto attuale (piazzamenti ordinati, emissioni inline, `r14` base, arena
  `0x40000`) sopravvive a un artefatto che non è più il seed.

Prodotto atteso: uno **spike** (prototipo grezzo che emette un eseguibile minimo PE **e**
ELF da sorgente Triad) su branch `prototype/codegen-s2`, da cui discutere la forma.

## Riferimenti

- Preliminari: [04 — Linguaggio sorgente del compilatore S2](04-linguaggio-sorgente-s2.md), [05 — Forma degli artefatti compilati](05-forma-artefatti.md).
- Contratti da speculare: [02 — Architettura del codegen per due piattaforme](../../seed-linux-nativo/issues/02-architettura-codegen.md), [03 — Contratto delle routine `os_*`](../../seed-linux-nativo/issues/03-contratto-os-star.md).
- Collegato: [07 — Certificazione del lato PE degli artefatti compilati](07-certificazione-pe.md).
