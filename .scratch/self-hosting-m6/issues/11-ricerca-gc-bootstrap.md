# 11 — Ricerca: GC e memoria negli stadi di bootstrap

Type: research
Status: open

## Question

Fatti che una decisione attende: dove vive la memoria gestita negli interpreti/compilatori
di bootstrap noti?

- mark-sweep **nello stadio 0** (codice macchina/assembly) o memoria gestita **nel
  linguaggio implementato** (l'interprete gestisce il proprio heap in sé stesso)?
- quali dimensioni di arena/heap servono a eseguire un interprete completo + suite di test?
- esempi di bootstrap interpreter senza GC e quanto reggono.

Servono a *GC e memoria per S1*. Findings attesi su branch `research/11-gc`.

## Riferimenti

- Servono a: [03 — GC e memoria per S1](03-gc-memoria.md).
