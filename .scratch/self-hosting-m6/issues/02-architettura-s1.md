# 02 — Architettura di S1

Type: grilling
Status: open
Blocked by: 01

## Question

S1 deve essere «l'implementazione completa di Triad scritta in Triad-Core»
(`BOOTSTRAP.md` §1): passa l'**intera conformance** (Core + Full) quando è compilata (M5) —
Prolog `fact`/`rule`/`solve`, dispatch, macro, contratti, effetti, budget, trace inclusi.

Oggi `selfhost/` è un interprete inline (~12 sorgenti: tokenizer, parser, ast, env, eval,
heap, interpreter…) con l'ambiente come lista piatta e binding `1 = "x"` accodati. La
decisione: **proseguire e completare questa forma** o **ridisegnare l'interno di S1**
(valutazione su AST vs bytecode, heap con tipi blocco, ambiente a frame)?

Il fork scelto in *Fork architetturale del seed: gap reali e AST/bytecode* fissa cosa il
seed sa eseguire e quindi quali forme S1 può assumere.

## Riferimenti

- Preliminare: [01 — Fork architetturale del seed: gap reali e AST/bytecode](01-fork-architetturale-seed.md).
- Da coordinare: [03 — GC e memoria per S1](03-gc-memoria.md).
- Foschia collegata: «Interno di S1 per le feature Full» ([`../map.md`](../map.md)).
