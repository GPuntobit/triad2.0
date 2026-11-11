# 11 — Ternario con simbolo nel ramo *then*: il seed prende il `:` del simbolo

Type: task
Status: resolved

## Question

Il ternario del seed (codice macchina, `seed/dev/core.js`) è implementato con uno scanner
byte-per-byte che cerca il separatore `:` contando **solo** parentesi tonde, quadre e graffe.
Quando il ramo *then* è un **simbolo** (`:nome`), il `:` del simbolo è a profondità zero e
viene scambiato per il separatore: il programma viene **rifiutato** (exit 1) quando la
condizione è falsa, con la sola diagnostica generica `seed: error`.

`SPEC.md` §1 (regole dei due punti) stabilisce: «`c ? a : b`: a `:` **surrounded by
spaces** is the ternary separator» — il separatore è il `:` circondato da spazi, non il `:` di
un simbolo.

- (Q1) il comportamento è conforme a `SPEC-CORE.md`/`SPEC.md` o è un difetto del seed?
- (Q2) come si dichiara nel **contratto del seed** (`seed/dev/certified-subset.txt`) e come
  si presidia (guardia statica)?
- (Q3) che golden prende il caso di conformance `ternario_simbolo`, dato che il seed non
  lo esegue?
- (Q4) il fix del codice macchina è una sessione separata (ciclo di rebuild dei dump)?

## Facts (misurate in questa sessione)

Ripro minimo (`conformance/core/cases/ternario_simbolo/program.td`):

```triad
f(n) = n == 1 ? :intero : :numero
println(f(1))
println(f(2))
```

| runtime | stdout | exit |
|---|---|---|
| seed ELF (`seed/linux-x86_64/seed`) | `intero` (una riga) | 1 (`seed: error` su stderr) |
| riferimento JS (`seed/dev/triad_core.cjs`) | `intero` / `numero` | 0 |

- Il **riferimento JS è corretto**: è byte-exatto sui 39 casi Core già congelati (verificato
  con `cmp` su stdout + exit code, 39/39).
- Il caso **verde** del ternario maschera il difetto: sul ramo *true* il seed parsa il ramo
  *then* dalla posizione subito dopo `?` (che punta a `:intero`) → il simbolo è letto bene.
  Sul ramo *false* il seed parsa da `:` + 1, cioè da `intero : :numero` → variabile `intero`
  inesistente → errore.
- Il simbolo nel ramo *else* **non** è un problema: lo scanner trova prima il `:` del
  separatore (`? 1 : :numero` → il primo `:` è quello del separatore).
- Causa: `seed/dev/core.js`, routine `pt_scan`/`pt_colon` (ternario a valutazione corta):
  lo scanner accetta **qualunque** `:` a profondità zero come separatore e non distingue il
  `:` di un simbolo.

## Answer (parziale — 2026-11-08)

- (Q1) **Difetto del seed**, non conforme a `SPEC.md` §1: il ternario Core deve separare i
  rami come specificato. Il riferimento JS (autorità semantica) è conforme.
- (Q2) **Divergenza `D23 = noisy`** (exit 1) aggiunta a `seed/dev/certified-subset.txt`, con
  la riga corrispondente nella tabella delle divergenze di `seed/README.md`. Presidio:
  **guardia statica `G-D23`** in `tools/selfhost-guard/rules.mjs` (livello `error`: il
  costrutto è vietato nella sorgente di S1, che gira sul seed), con fixture
  `tools/selfhost-guard/fixtures/d23_ternario_simbolo.td` e voce nel self-test. La regola
  copre il ternario il cui ramo *then* contiene un simbolo **a profondità zero** (fuori da
  parentesi/liste/indici: lì il `:` del simbolo è dentro e non confonde lo scanner).
  Quando il seed sarà corretto, `D23` sparisce dal contratto e `G-D23` si spegne da sola.
- (Q3) **Golden del riferimento JS**: `conformance/core/cases/ternario_simbolo/` con
  `program.td`, `expected.out` (`intero` / `numero` / `numero`), `expected.code` (`0`) e
  `expected.golden` (legacy). Il caso contiene anche il **controllo** del ramo *else*
  (`g(n) = n == 1 ? 1 : :numero`), che il seed esegue senza problemi: serve a distinguere il
  difetto specifico del ramo *then*. Finché il seed non lo esegue, il caso è il **2° gap
  noto** della suite Core: `conformance/gate.sh` lo esclude in modo esplicito e rumoroso
  (`KNOWN_GAP`), **nessun golden è stato riscritto per mascherarlo**. Il gate passa con
  38/40 verdi.
  Il difetto **non** è presidiabile da un probe `bad_*`: quei probe esigono stdout vuoto,
  mentre il seed emette `intero` prima di fallire → il caso di conformance + gap noto è
  l'unico strumento adatto.
- (Q4) **Il fix del codice macchina è rinviato a una sessione separata**: tocca
  `seed/dev/core.js` → rigenerazione di `seed.hex` + dump ELF/PE + hash CI, ciclo oggi
  bloccato dal known issue anti-drift (vedi `TASK.md`, handoff «2026-11-07 22:40 (ter)»).
  Ipotesi di fix (da decidere in quella sessione): in `pt_scan`, ignorare un `:` che è
  seguito da un identificatore (inizio di simbolo) invece di trattarlo come separatore;
  in alternativa, esigere che il separatore sia circondato da spazi come in `SPEC.md` §1
  (attenzione: la regola dei due punti deve restare coerente con `SPEC-CORE.md`, dove il
  `:` è solo prefisso di simbolo).

### Da fare quando il fix entra

1. togliere `D23` da `seed/dev/certified-subset.txt` (la guardia `G-D23` si spegne da sola);
2. togliere `ternario_simbolo` dalla `KNOWN_GAP` di `conformance/gate.sh` → il caso diventa
   verde (39/40 verdi, un solo gap noto: `liste`);
3. rigenerare i dump (PE/ELF + `seed.hex`) e i hash CI;
4. aggiornare i conteggi nella documentazione (book/tutorial: 39/39 → 40 casi).

## Comments

- 2026-11-08 (sessione «perché il seed rifiuta un programma Full?»): la diagnosi è partita
  da un programma **Triad-Full** (`struct Point` con campi `Float`, `area(n::Int)` /
  `area(n::Number)`) che il seed rifiuta correttamente — `struct`, annotazioni `::`, `Float`,
  `Number` e il multiple dispatch non sono in `SPEC-CORE.md` (§1, §2, §3, §4). Costruendo
  l'equivalente Core è emerso questo difetto, che non riguarda il programma ma il seed.
- 2026-11-08: il difetto è **non presidiato** dalle guardie precedenti (nessuna regola
  copriva il ternario): aggiunta la regola `G-D23` + fixture + voce nel self-test
  (`node tools/selfhost-guard/test.mjs` → 27 test, 0 falliti). Guardie sul corpus: 0 errori;
  gate differenziale seed↔JS: 0 differenze.

## Risolto — 2026-11-08 (ciclo di rebuild del seed)

Il difetto è **risolto**: il ternario col ramo *then* simbolico è eseguito dal seed e il
caso di conformance `ternario_simbolo` è verde (nessun golden riscritto).

| passo | stato |
|---|---|
| fix in `seed/dev/core.js` (il `:` del simbolo non è più scambiato per il separatore) | fatto |
| rigenerazione dump PE/ELF + binari + hash CI | fatto (ciclo di rebuild, ADR 0001) |
| `D23` tolta dal contratto (`seed/dev/certified-subset.txt`) | fatto |
| guardia `G-D23` rimossa (il costrutto non è più vietato) | fatto (cleanup PR #83) |
| `ternario_simbolo` tolto dai gap noti del gate | fatto: `conformance/gate.sh` non ha più esclusioni |
| conteggi nella documentazione | fatto (42 casi Core, 44 probe) |

Misurato: `sh conformance/gate.sh` → **42/42** (0 esclusioni); `sh verify.sh` → **OK**
(Core 42/42, probe 44/44, logica 29/29); seed ELF e PE (via wine) byte-identici sul caso.

Resta **fuori da questo ticket** la decisione su `D25` (interi a 62 bit invece di 64 bit
signed): è un'altra divergenza, **silenziosa**, dichiarata nel contratto e nel probe
`bad_intero_64bit.td`; la decisione (documentare il limite / implementare l'aritmetica a
64 bit / dichiarare la specifica imprecisa) è aperta e registrata in `TASK.md`.
