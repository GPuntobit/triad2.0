# 01 — Fork architetturale del seed: gap reali e AST/bytecode

Type: grilling
Status: resolved

## Question

Il seed interprete (M3) deve essere completo prima che S1 possa girarci sopra. La prima
domanda è **fattuale** (regola 1: nessuna semantica inventata): qual è l'elenco *vero* dei
gap? I documenti si contraddicono — `TASK.md` dichiara il PE già capace di `elseif` e
liste «complete (build, print, push!, get)», mentre `BOOTSTRAP.md` §10 elenca ancora
«AST/bytecode for multi-binding capture, `elseif`, lists» come mancanti (M3b2b3f: capture
multi-binding instabile). La ricognizione dei gap reali apre il ticket.

Poi la decisione: di fronte ai gap reali — capture multi-binding in primis — si
- **(a) estende l'interprete diretto** in codice macchina così com'è, o
- **(b) introduce un livello AST/bytecode** nel seed (il fork annotato in `BOOTSTRAP.md` §10)?

Il risultato si colloca nel ciclo di rebuild PE/ELF + hash CI previsto per N03–N05
(`TASK.md`), sotto la politica dei byte del PE (cambi semantici deliberati ammessi con hash
CI + diff tracciati): è lì che si implementa, qui si decide.

## Fatti — la ricognizione dei gap reali (misurata 2026-11-07)

La contraddizione fra `TASK.md` («PE già capace di `elseif` e liste complete») e
`BOOTSTRAP.md` §10 («needs AST/bytecode for multi-binding capture, `elseif`, lists») è
**risolta a favore della misura**: `elseif` è implementato, le liste sono *parziali*, e la
motivazione originaria del fork AST/bytecode (capture multi-binding, `elseif`, liste) è
**obsoleta**. Il seed oggi è un **interprete diretto scannerless** (parser ricorsivo
discendente + valutatore, entrambi in codice macchina: `seed/dev/core.js` §«parser», ~1600
righe di generatore) — **non** c'è alcun livello AST/bytecode.

Il seed **esegue già** il front-end S1 (`selfhost/source.td`, 1311 righe: scanner + parser +
AST in pre-order) con golden byte-esatto: la premessa «il seed deve essere completo prima
che S1 possa girarci sopra» è **parzialmente falsa** — S1 gira, ma su un sottoinsieme
ristretto.

### D — divergenze semantiche (il seed **non** è un'implementazione Core conforme)

| # | Costrutto | SPEC-CORE | Seed (misurato) |
|---|---|---|---|
| D1 | Scope dei nomi | §5 lessicale | **dinamico**: `env_find` vede i locali del chiamante → un locale del chiamante oscura il globale del callee (misurato) |
| D2 | Chiusure | §5 cattura **condivisa** (mutazioni visibili) | cattura **per valore**: la mutazione successiva del captured non si vede (misurato) |
| D3 | Escape nelle stringhe | §2 `\n \t \" \\` | non interpretati: `"a\nb"` stampa `a\nb` (misurato) |
| D4 | Uguaglianza stringhe | §5 per valore | `"abc" == "abc"` → `false` (misurato) |
| D5 | `continue` | §4/§6 | assente: exit 1 alla prima `continue` (misurato) |
| D6 | `-=`, `*=` | §6 | assenti: exit 1 (misurato) |
| D7 | `while` come espressione | §4 (`x = while … end`) | assente: exit 1 (misurato) |
| D8 | `if`/`else` come valore | §5 (il blocco vale l'ultima espressione) | assente: exit 1 (misurato) |
| D9 | Chiamata come statement | §4 (`stmt = expr`) | una chiamata *in posizione finale* di programma/blocco non è valutata: exit 1 (misurato) |
| D10 | `return` in funzione a blocco | §4/§5 | assente: exit 1 (misurato) |
| D11 | Blocco-lambda `function (a) … end` | §4 | assente (qualsiasi forma): exit 1 (misurato) |
| D12 | `let` multi-binding | §4 (`let x = e, y = e`) | assente: exit 1 (misurato) |
| D13 | Indicizzazione `xs[i]` (1-based) | §7 | assente: exit 1 (misurato) → **caso conformance `liste` FAIL** |
| D14 | `typeof`, `Int()`, `Symbol()` | §7 | assenti: exit 1 (misurato) |
| D15 | `string(x)` | §7 | solo `Int`/`String`; `Bool`/`Symbol`/`Nothing` assenti |
| D16 | `readfile`, `strlen`, `strbyte`, `strsub` | §8 (**`readfile` obbligatorio**: «the seed must still provide `readfile` to load S1 itself») | assenti: exit 1 (misurato) |
| D17 | Simbolo operatore `:+` | §2 | rifiutato (exit 1) |
| D18 | Riferimento in avanti a funzione | §5 | non risolto (exit 1) |
| D19 | Newline dopo operatore | §2 separatore | il seed **prosegue** l'espressione oltre il newline (divergenza dal JS; serve decisione normativa — `TASK.md` N02) |
| D20 | Scope del corpo `while` | §5 ambiente dedicato | le variabili assegnate nel corpo **escono** dal blocco |
| D21 | Condizione `while` non-`Bool` | §5 solo `Bool` | **salta silenziosamente** il corpo (exit 0) invece di errore |
| D22 | `if` dentro un letterale | §2 | il seed conta `if` anche nel *testo* del letterale → annidamento sbagliato, exit 1 |

### F — funzionalità mancanti (misurate, già mappate in `TASK.md`)

- `xs[i]` 1-based → **N03** (sblocca il caso `liste`, oggi l'unico FAIL: 38/39).
- `-=`/`*=` → **N04**. — Funzioni con >4 parametri → **N05**.
- Escape/`==`/`+=` su stringhe → **N06**. — Heap liste riusabile (528 B per valutazione,
  arena 64 KB senza `free`: ~60 liste per esecuzione, ~150 → crash) → **N07**.
- Newline e scope: decisioni normative prima del codice → **N02**, **N08**.

### R — limiti di risorsa (non semantici)

- Arena: regione unica `0x40000` (256 KB) di cui **heap 64 KB** (`0x30000`), bump senza GC
  né `free`; tabella funzioni `0x20000`; nessuna riciclicità.
- Record funzione: 64 byte, 16 per parametro → **max 4 parametri**.
- `+=` su stringhe corrompe la memoria (puntatori leakati, ASLR → output non deterministico).

### E — envelope del seed: limiti strutturali (misurati 2026-11-07)

L'arena è **una sola regione** `0x40000` (256 KiB) allocata **a runtime**
(`os_alloc` → `mmap`/`VirtualAlloc`: nessun impatto sul layout del PE), con una
ripartizione fissa di offset:

| regione | offset (da `r14`) | dimensione | uso |
|---|---|---|---|
| buffer sorgente | `0x00000` | **64 KiB** | il programma Triad letto da file (`os_read` con `max=0x10000`) |
| maschera di stop | `0x0F000` | — | bit di fine blocco in coda al buffer |
| base ambiente | `0x10000` | — | frame chain |
| tabella funzioni | `0x20000` | 128 KiB | record funzione da 64 B (16 B per parametro) |
| heap | `0x30000` | **64 KiB** | bump allocator senza `free` (stringhe, liste, chiusure) |

Misure:

- **Sorgente: 64 KiB hard**. Un programma di 75.794 byte → `seed: read error`, exit 1
  (misurato). `os_read` legge tutto e chiude, con `max = 0x10000`.
- **Heap: 64 KiB**, nessuna riciclicità: ogni *valutazione* di un letterale di lista
  consuma 528 B fissi → ~60 per esecuzione, ~150 → crash (misurato dai probe).
- **Liste: max 64 elementi.** Un letterale con 64 elementi funziona, con 65 → exit 1
  (misurato); `push!` ha lo stesso tetto. Ogni lista è un blocco fisso da 64 slot.
- **Funzioni: max 4 parametri** (record da 64 B).
- Il layout è quindi un **envelope rigido**: sorgente ≤ 64 KiB, heap ≤ 64 KiB,
  oggetto-lista = 528 B.

Conseguenza per la destinazione: **S1 (Triad completo in Triad-Core) non sta in questo
envelope** — la sua sorgente supera i 64 KiB e le sue strutture dati non entrano in 64 KiB
di heap con liste da 64 elementi. L'elenco dei gap D1–D22 non basta: occorre anche
**ri-proporzionare l'arena** (buffer sorgente e heap), che è una modifica di **costanti e
offset nel generatore** (nessun impatto sul layout del PE: l'arena è allocata a runtime).

### Correzioni documentali emerse

- `conformance/gate.sh` (non versionato) commenta che il seed non implementa «`xs[i]` **ne**
  `length(xs)`»: **`length(xs)` funziona** (misurato: `length([1,2,3])` → `3`).
- `tests/probes/README.md` è la matrice dei limiti **misurata** ed è la fonte più affidabile
  insieme a `STATUS.md`; `TASK.md` «Current status» (elenco delle feature del seed) è
  **ottimistico e superato**.

### Metodo di misura

Seed ELF nativo `seed/linux-x86_64/seed` (PE ed ELF condividono la stessa macchina: parità
byte-a-byte, decisione 04). Micro-programmi di prova in `/tmp` (non versionati): lettura
`length(xs)`, `readfile`, `-=`, `continue`, `let` multi-binding, `return` in blocco, scope
dinamico, cattura per valore, blocco-lambda, escape, `==` stringhe, `xs[i]`, `typeof`,
`Int()`, `Symbol()`, `while`/`if` come valore, chiamata come statement, `>4` parametri.

## Answer — 2026-11-07 (grilling, 3 round: Q1–Q3, Q4–Q6)

**Sintesi.** Il seed **resta** un interprete diretto: **nessun fork AST/bytecode**. Il suo
ruolo è quello di **veicolo di transizione per S1**, non di implementazione Core conforme;
il suo *pavimento* è (i) i primitivi §8, (ii) le divergenze che la sorgente di S1 tocca,
(iii) `liste` verde (39/39). Il resto è **fuori contratto** e va dichiarato tale. Nessuna
chirurgia nel seed per le costruzioni *rumorose*; per le *silenziose* si mettono guardie
statiche sulla sorgente di S1, con fallback alla chirurgia solo se una regola non è
presidiabile. L'arena del seed va **ri-proporzionata** (buffer sorgente e heap), perché
l'envelope attuale (64 KiB di sorgente, 64 KiB di heap, liste da 64 elementi) non ospita
S1.

### Q1 — Il ruolo del seed: veicolo di transizione, non implementazione Core

Il seed **non** punta alla conformità Core completa (§7–§8 + semantica §5): il seed
esegue la **sorgente di S1**, non i programmi degli utenti (li esegue S1, che implementa la
semantica): le divergenze del seed filtrano quindi nel *comportamento del codice di S1*,
non nei risultati di conformance.

**Pavimento (minimo) del seed:**
1. **§8 completi**: `readfile`, `strlen`, `strbyte`, `strsub`, `get`, `exit` — senza
   `readfile` S1 non può leggere il programma da interpretare: non è un extra, è il modo in
   cui S1 esiste.
2. **Divergenze che la sorgente di S1 tocca**: vedi la tabella «destino dei gap» sotto.
3. **`liste` verde** → conformance 39/39: è il gate di verifica del repository, non
   un'opzione.

**Fuori contratto** (dichiarato, non implementato): `typeof`, `Int()`, `Symbol()`,
`string()` per Bool/Symbol/Nothing, `:+`, riferimenti in avanti a funzione.

### Q2 — Architettura: nessun livello AST/bytecode nel seed

Si **estende l'interprete diretto** scannerless com'è oggi. La motivazione originaria del
fork (`BOOTSTRAP.md` §10: «capture multi-binding, `elseif`, lists») è **misurata obsoleta**:
`elseif` è implementato, le liste sono parziali, il vero ostacolo è lo *scope dinamico*
(D1), non l'assenza di un livello AST. Il livello AST in Triad lo dà **S1**, che è il
componente che sopravvive alla destinazione; il seed è codice macchina che a M6 sparisce.

**Criterio di riapertura (misurato, non per principio)**: se il costo stimato
dell'aggiunta di D8–D13 all'interprete diretto (in giorni di codice macchina **e**
numero di regressioni sui 38 casi verdi) supera il costo di un nucleo AST/bytecode
equivalente, la domanda si riapre con quei numeri alla mano.

### Q3 — Il lavoro meccanico sul seed: un solo ciclo di rebuild

**Dentro** il ciclo (PE + ELF + hash CI + diff tracciato, ADR 0001):
`xs[i]` 1-based (N03, sblocca `liste`), `-=`/`*=` (N04), escape/`==`/`+=` su stringhe
(N06), i §8, la chiusura del gap `liste` in `gate.sh` (`KNOWN_GAP` vuoto) e
il **ri-proporzionamento dell'arena** (Q4).

**Fuori** dal ciclo: heap/GC (N07 e ticket [03 — GC e memoria per S1](03-gc-memoria.md)),
le funzionalità fuori contratto (Q1), e ogni lavoro sul seed che non serva a S1.

### Q4 — L'envelope: ri-proporzionare l'arena

L'arena (`0x40000`) è allocata **a runtime** (`mmap`/`VirtualAlloc`): ri-proporzionarla è
una modifica di **costanti e offset nel generatore** (`seed/dev/core.js`), **nessun impatto
sul layout del PE** (cambiano i byte del codice macchina → hash CI + diff tracciato).

- **Buffer sorgente**: 64 KiB → **1 MiB**. Un programma più grande oggi muore con
  `seed: read error` (misurato a 75.794 byte). Nota: `os_read` oggi legge *tutto e chiude*
  con `max=0x10000` → il tetto sale con `max`, e resta un errore oltre (la sorgente di S1
  deve stare nel buffer: 1 MiB è ampio).
- **Heap**: 64 KiB → **8 MiB** (bump, senza GC: il GC è di S1, vedi ticket 03).
- **Liste**: il tetto di **64 elementi resta**: il chunking è un problema di S1, e la
  crescita delle liste è legata a N07 (riuso dell'heap), fuori ciclo.
- **Criterio**: l'arena deve contenere S1 completo (sorgente + heap di lavoro) con
  margente ×2.

### Q5 — Proteggere la sorgente di S1 dalle divergenze del seed

**Nessuna chirurgia nel seed** per le costruzioni *rumorose*; **guardie statiche** sulla
sorgente di S1; il **riferimento JS** `seed/dev/triad_core.cjs` (misurato: scope
lessicale, escape, `==` su stringhe, `continue`, `-=`, `xs[i]`, `readfile`) è
l'**autorità semantica** per lo sviluppo; il seed è il **gate di esecuzione** (prova che
la catena minima funziona). La CI esegue già `node seed/dev/triad_core.cjs` su ogni
`selfhost/*.td` (job `conformance-core`): l'infrastruttura esiste.

**Classificazione dei gap (misurata) e destino:**

| gap | classe | destino |
|---|---|---|
| D5 `continue`, D6 `-=`/`*=`, D7 `while` come espressione, D8 `if` come valore, D9 chiamata come statement, D10 `return` in blocco, D11 blocco-lambda, D12 `let` multi-binding, D13 `xs[i]`, D14 `typeof`/`Int()`/`Symbol()`, D15 `string()` parziale, D16 §8, D17 `:+`, D18 riferimento in avanti, D22 `if` nel letterale | **rumorosa** (exit 1) | **vietata** nella sorgente di S1 (guardia statica: il costrutto è rifiutato dal seed) — tranne §8 e `xs[i]`, che sono nel pavimento (Q1) |
| D1 scope dinamico, D2 cattura per valore, D3 escape, D4 `==` su stringhe, D19 newline dopo operatore, D20 scope del corpo `while`, D21 condizione `while` non-`Bool` | **silenziosa** (risultato sbagliato, nessun errore) | **guardia statica dedicata**; se una regola non è presidabile in modo affidabile ⇒ **chirurgia nel seed per quella singola divergenza** (criterio: *silenziosa + non presidabile*) |

Le guardie vivono nel lint (`tools/site-gen/lint.mjs`, che già «blocca le costrutti che il
seed non può eseguire») e nei probe; l'elenco esatto delle regole e la loro forma è il
ticket successivo: [12 — Guardie statiche per la sorgente di S1](12-guardie-statiche-sorgente-s1.md).

### Q6 — Il contratto del seed: un solo artefatto, macchina-leggibile

Il contratto (cosa il seed esegue correttamente, cosa rifiuta, cosa esegue in modo
divergente, con quali limiti d'infrastruttura) vive in **`seed/README.md`** (sezione
normativa) più un **elenco macchina-leggibile** (`seed/dev/certified-subset.txt`) consumato
da `tools/site-gen/lint.mjs` e da `tests/probes/run_probes.sh`. **In `SPEC-CORE.md` non si
scrive nulla**: la specifica descrive il linguaggio, non lo stato di un'implementazione.

Il termine canonico è **«sottoinsieme certificato»** (già in uso in
`tests/probes/README.md`): *l'insieme dei programmi Triad-Core che il seed nativo esegue
con semantica identica a quella specificata*. «Non nel sottoinsieme certificato» significa
una cosa precisa. Definizione in `GLOSSARY.md`.

### Destino dei gap — sintesi

- **nel seed, in questo ciclo**: `xs[i]` (N03), `-=`/`*=` (N04), escape/`==`/`+=` stringhe
  (N06), §8 (`readfile`, `strlen`, `strbyte`, `strsub`), ri-proporzionamento arena,
  `gate.sh` senza gap noti → 39/39.
- **fuori contratto, dichiarato**: `typeof`, `Int()`, `Symbol()`, `string()` per
  Bool/Symbol/Nothing, `:+`, riferimenti in avanti.
- **fuori dal ciclo, ma presidio nella sorgente di S1**: D1–D12, D15, D17, D18, D19–D22
  (regole statiche; chirurgia solo per le silenziose non presidabili).
- **fuori dai due round**: heap/GC (N07 + ticket 03), crescita delle liste (chunking in S1).

### Note e limiti noti

- La misura dei gap è **sul seed ELF**; il PE condivide la stessa macchina (parità
  byte-a-byte, decisione 04 della mappa precedente) → i gap valgono per entrambi.
- `conformance/gate.sh` (non versionato) commenta che il seed non implementa «`xs[i]` **ne**
  `length(xs)`»: **`length(xs)` funziona** (misurato: `length([1,2,3])` → `3`). La riga va
  corretta.
- `TASK.md` «Current status» (l'elenco delle feature del seed) e `BOOTSTRAP.md` §10
  (l'elenco dei gap) sono **superati** da questa ricognizione: vanno aggiornati quando
  il ciclo di rebuild parte.
- Il **riferimento JS** resta fuori dalla catena S0→S4 (regola operativa 2): è strumento
  di sviluppo, ed è *solo* l'autorità semantica di sviluppo — il gate del repository
  (`verify.sh`) resta senza Node.

### Esecuzione

Le slice sono in `TASK.md` (gruppo «N20–N24 — ciclo di rebuild del seed per S1»): N20
ri-proporzionamento arena, N21 §8, N22 guardie statiche + contratto del seed, N23
`gate.sh` a 39/39, N24 aggiornamento di `BOOTSTRAP.md` §10 / `TASK.md` / `STATUS.md`.

## Riferimenti

- Politica dei byte del PE ([01 — Politica dei byte del PE nella rifattorizzazione](../../seed-linux-nativo/issues/01-byte-pe.md)): cambi semantici deliberati ammessi con hash CI + diff tracciati.
- Slice di esecuzione: `TASK.md` N03–N05 (ciclo rebuild PE/ELF + hash CI), N06–N08.
- Limiti misurati del seed: `tests/probes/README.md`; stato: `STATUS.md`.
- Successore: [02 — Architettura di S1](02-architettura-s1.md).
