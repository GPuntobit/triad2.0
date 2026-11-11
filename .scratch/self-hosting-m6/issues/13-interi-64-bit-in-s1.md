# 13 — Semantica a 64 bit degli interi in S1

Type: grilling
Status: open
Blocked by: 02

## Question

`SPEC-CORE.md` §5 fissa `Int` a **64 bit signed con wrap**. Il seed, che gira in codice
macchina, rappresenta `Int` come `n<<2` (2 bit di tag per `Bool`, chiusure e oggetti
heap): il suo payload utile è un intero signed a **62 bit**, `[-2^61, 2^61-1]`, e un
valore fuori range è **rifiutato** (exit 1) invece di essere prodotto sbagliato in
silenzio (divergenza `D25`, ora `noisy`: decisione
[`docs/adr/0003-range-interi-del-seed.md`](../../../../docs/adr/0003-range-interi-del-seed.md)).

S1 è scritto in Triad-Core e **gira sul seed**: `selfhost/value.td` fa `n * 4`, quindi
S1 eredita la rappresentazione (e il range) dell'host. Se S1 implementa l'aritmetica
delegando all'host, i programmi che S1 interpreta hanno semantica a 62 bit: **S1 non
sarebbe conforme a `SPEC-CORE.md` §5**, e il divario si trasformerebbe in una divergenza
silenziosa (il caso peggiore).

Domande:

- **(Q1)** S1 deve implementare da sé la semantica a 64 bit (per es. `Int` come due
  parole da 31 bit, con aritmetica a 64 bit e riporto), accettando il costo, oppure il
  limite dei 62 bit dell'host è un vincolo accettato per S1?
- **(Q2)** se S1 implementa il livello a 64 bit, quali primitive di bootstrap servono
  (`readfile`/`strbyte`/`strsub` per il I/O dei bit? `^` per le potenze? `&`/`|`/`>>`
  mancano in Core: §8)?
- **(Q3)** come si presidia: il gate differenziale seed↔JS oggi confronta i programmi
  del corpus, non l'aritmetica interna di S1. Serve un caso di conformance con valori
  oltre 2^61 (che il seed non può eseguire: il golden viene dal riferimento JS, che è
  conforme)?
- **(Q4)** il livello a 64 bit di S1 è una decisione di S1 o un obiettivo della catena
  S2 (compilatore nativo, dove l'host non è più il seed)?

## Facts (misurate)

- Il seed rappresenta `Int` come `n<<2`: i due bit bassi sono il tag (`0` = Int,
  `1` = Bool, `2` = chiusura, `3` = heap). Il payload è quindi un intero signed a 62 bit.
- Misurato sul seed (2026-11-08): `2305843009213693951` (2^61 − 1) è il massimo
  rappresentabile; `2305843009213693952` (2^61) e `9223372036854775807` (2^63 − 1) sono
  **rifiutati** (exit 1, `seed: integer overflow`); `-2^61` è raggiungibile via
  aritmetica (`0 - 2305843009213693951 - 1`).
- Il riferimento JS (`seed/dev/triad_core.cjs`) implementa i 64 bit con `BigInt` e
  `MASK64`: è conforme a §5 ed è l'autorità semantica.
- `selfhost/value.td`: `make_int(n)` = `n * 4` → S1 eredita il range dell'host.
- `SPEC-CORE.md` §8 non prevede `&`, `|`, `>>`: un livello a 64 bit in Core puro
  deve implementare le primitive bit a bit con l'aritmetica disponibile (`/`, `%`, `^`).

## Riferimenti

- Decisione: [`docs/adr/0003-range-interi-del-seed.md`](../../../../docs/adr/0003-range-interi-del-seed.md).
- [02 — Architettura di S1](02-architettura-s1.md) (da coordinare: la rappresentazione
  dei valori in S1 è parte dell'architettura).
- [01 — Fork architetturale del seed](01-fork-architetturale-seed.md): il seed è un
  veicolo di transizione per S1, non un'implementazione Core conforme.
- `BOOTSTRAP.md` §3 (vincolo registrato: i 64 bit sono un obbligo per S1).
