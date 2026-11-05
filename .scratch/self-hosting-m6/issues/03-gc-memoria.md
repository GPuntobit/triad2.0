# 03 — GC e memoria per S1

Type: grilling
Status: open
Blocked by: 01, 11

## Question

`BOOTSTRAP.md` §4: «GC: initially **no GC** (growing arena; bootstrap programs are short),
then mark-sweep **to run S1 and the suite**». Ambiguità reale: *dove* vive il mark-sweep?

- **(a) nel seed**, in codice macchina (evoluzione dell'arena bump attuale, `0x40000`);
- **(b) in S1**, come memoria gestita scritta in Triad-Core sopra primitive di bootstrap;
- **(c) senza GC**: arena più grande o riavvii, se la misura dice che S1 e la suite ci stanno.

Domande figlie: l'arena `0x40000` basta a runnare S1 e l'intera suite? Un GC nel seed
cambierebbe il contratto `os_*` (una sola chiamata `os_alloc` all'avvio)? Le decisioni già
firmate dicono solo che il GC non c'è *oggi*.

## Riferimenti

- Preliminari: [01 — Fork architetturale del seed: gap reali e AST/bytecode](01-fork-architetturale-seed.md), [11 — Ricerca: GC e memoria negli stadi di bootstrap](11-ricerca-gc-bootstrap.md).
- Contratto `os_*` ([03 — Contratto delle routine `os_*`](../../seed-linux-nativo/issues/03-contratto-os-star.md)): una sola chiamata `os_alloc` all'avvio, arena `0x40000`.
- Da coordinare: [02 — Architettura di S1](02-architettura-s1.md).
