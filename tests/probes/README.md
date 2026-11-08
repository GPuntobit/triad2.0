# Probe — matrice di portabilità Triad-Core

Questi probe **misurano** quali costrutti di Triad-Core danno lo stesso risultato
sul seed in codice macchina (PE Windows `seed/windows-x86_64/seed.exe` ed ELF
Linux `seed/linux-x86_64/seed`) e sull'interprete di riferimento in JavaScript
(`seed/dev/triad_core.cjs`).

Non sono test di conformance: non hanno golden normativi. Sono il **guardrail** che
permette al generatore del sito (`tools/site-gen/`) di produrre output identico
byte per byte sui runtime.

## Esecuzione

```sh
sh tests/probes/run_probes.sh     # suite cablata, senza flag
```

L'harness POSIX (senza Node, ticket `.scratch/seed-linux-nativo/issues/08`)
assegna a ogni probe `ok_*`/`test_*` e a `selfhost/source.td`/`selfhost/main.td`
un golden sidecar committato `<file>.expected.out` + `<file>.expected.code`,
confrontato **byte-exatto** con `cmp`; i `bad_*` devono dare exit ≠ 0 + stdout
vuoto (con le eccezioni misurate congelate come sidecar, vedi header di
`run_probes.sh`). Runtime: `TRIAD_SEED` se impostato, altrimenti il seed ELF del
repo; nessun fallback JS. Lo stesso entry point copre la parità PE via wine:
`TRIAD_SEED="$PWD/scripts/seed-runner/seed-wine.sh" sh tests/probes/run_probes.sh`
(`scripts/seed-runner/seed-wine.sh --check` ripete conformance + probe + golden S1).

## Il sottoinsieme certificato

| Costrutto | seed | interprete JS | probe |
|---|---|---|---|
| `println(<una espressione>)` | sì | sì | `ok_funzione_valore.td` |
| `print(...)` / `println` con più argomenti | **no** | sì | `bad_print_multi_arg.td` |
| `let` con un solo binding | sì | sì | `ok_let_singolo.td` |
| `let` con più binding | **no** | sì | `bad_let_multiplo.td` |
| `get(xs, i)` (indice 0-based) | sì | sì | `test_get.td` |
| `length(xs)` su lista | sì | sì | `ok_lista_indice.td` |
| indice di lista `xs[i]` | sì (probe misurato) | sì | `ok_lista_indice.td` |
| scrittura `xs[i] = v` (1-based) | sì | sì | `ok_lista_indice_scrittura.td` |
| `-=`, `*=` a nome | sì | sì | `ok_composta_sottrai.td` |
| `xs[i] += v` (composta a indice) | **no** (exit 1) | sì | `bad_lista_indice_composta.td` |
| indice fuori range | **errore** (exit 1) | errore (exit 1) | `bad_lista_indice_fuori_range.td` |
| interi oltre ±(2^61 − 1) | **sbagliato in silenzio** | sì (64 bit, §5) | `bad_intero_64bit.td` |
| letterali di lista: ~60 valutazioni per esecuzione | **no** (528 byte fissi per valutazione, heap 64 KB: ~250 fanno crashare il processo) | sì | `bad_lista_alloc.td` |
| letterale di lista su più righe | sì | sì | `ok_lista_multiriga.td` |
| scope dei nomi nelle funzioni | **dinamico** (il callee vede i locali del chiamante) | lessicale | `bad_scope_dinamico.td` |
| funzioni con più di 4 parametri | **no** | sì | `bad_parametri_5.td` |
| `if`/`elseif`/`else`, `while` | sì | sì | `ok_if_assegna.td` (e i casi `while_*` della conformance) |
| ternario `? :` (anche `:` attaccato al ramo, `? 5 :7`) | sì | sì | `ok_ternario.td`, `ok_ternario_colon_attacco.td` |
| simboli operatore `:+` | **no** (exit 1) | sì | `bad_simbolo_operatore.td` |
| identificatore/simbolo con iniziale maiuscola (`Ab`, `:Ab`) | sì | sì | `ok_identificatore_maiuscolo.td` |
| newline come separatore di statement dopo un operatore | divergente (prosegue l'espressione) | separa gli statement | `bad_separatore_newline.td` |
| funzione a blocco, valore = ultima espressione | sì | sì | `ok_funzione_valore.td` |
| `return` dentro una funzione a blocco | **no** | sì | `bad_return_blocco.td` |
| `if`/`else` come *valore* del corpo | sì (probe misurato) | sì | `ok_if_valore_funzione.td` |
| chiamata come *ultima espressione* del corpo | sì (probe misurato) | sì | `ok_chiamata_ultima_espressione.td` |
| chiamata annidata con argomento Int | sì (probe misurato) | sì | `ok_chiamata_nested_int.td` |
| chiamata annidata con argomento String | sì | sì | `ok_chiamata_in_concatenazione.td` |
| chiamata assegnata a variabile, poi restituita | sì | sì | `ok_chiamata_assegnata.td` |
| ricorsione (pattern "assegna e restituisci") | sì | sì | `ok_ricorsione.td` |
| concatenazione stringhe con `*` | sì | sì | `ok_ciclo_concat.td` |
| `+=` su stringhe | **no** (spazzatura) | sì | `bad_stringa_plus_equals.td` |
| escape `\n`, `\t`, `\"`, `\\` nelle stringhe | **no** | sì | `bad_escape_stringa.td` |
| letterale con `if` **dentro un blocco** | **no** | sì | `bad_if_in_blocco.td`, `bad_if_in_blocco_while.td` |
| letterale con `if` a livello di programma | sì | sì | `ok_stringa_toplevel.td` |
| letterale con `end` dentro un blocco | sì | sì | `ok_stringa_end_in_blocco.td` |
| confronto fra stringhe con `==` | **no** (sempre `false`) | sì | `bad_confronto_stringa.td` |
| `readfile` | **no** | sì | `bad_readfile.td` |
| riferimento in avanti a una funzione | **no** | no | `bad_riferimento_avanti.td` |
| costruzione di stringhe con pattern "builder" | sì | sì | `ok_builder.td`, `ok_elenco_funzione.td` |
| front-end S1 (scanner + parser, `selfhost/source.td`) | sì | sì | golden `selfhost/source.expected.out` (eseguito da `run_probes.sh`) |

## Note sui limiti misurati

1. **`if` dentro un letterale in un blocco.** Il contatore di annidamento del
   seed conta anche le occorrenze della sottostringa `if` nel *testo* del
   letterale: il blocco sembra più annidato e il programma termina con exit 1.
   Il testo lungo va quindi stampato a livello di programma.
2. **Chiamata come ultima espressione.** Con i dump di `ff222c2`, il probe
   `ok_chiamata_ultima_espressione.td` passa: stdout `4` + newline, exit 0,
   identico al riferimento JS. Il precedente rifiuto non è più atteso.
3. **Nessun escape nelle stringhe.** Il seed stampa `\n` come due caratteri e
   fallisce su `\"`: ogni riga generata deve essere un `println` separato.
4. Sono limiti **del seed in codice macchina**, non della specifica:
   `SPEC-CORE.md` §2–§7 li consente tutti. L'interprete JS di riferimento li
   implementa correttamente; la suite di conformance gira oggi sul seed ELF
   nativo (`conformance/run.sh`, stessi golden del PE per parità N17).
5. **Heap delle liste.** Ogni *valutazione* di un letterale di lista alloca
   528 byte fissi (64 slot da 8 byte + header) nell'heap del seed (64 KB,
   bump allocator senza liberazione): ~60 liste per esecuzione vanno,
   ~150 fanno terminare il processo per access violation. `selfhost/source.td`
   è scritto senza letterali di lista nelle funzioni per questo motivo.
6. **Scope dinamico.** La ricerca del nome (`env_find`) parte dal frame più
   recente e include i frame dei chiamanti: un locale del chiamante oscura il
   globale del callee (diverso dal JS, dove lo scope è lessicale). I nomi
   locali vanno scelti fuori da `p0..p9`, `sp`, `kw_tab`, `srcs`, `k_*`,
   `o_*`, `w_*`.
7. **Quattro parametri.** `st_function`/`st_func` allocano 16 byte per
   parametro in un record da 64: la quinta chiamata fallisce. Il codice
   Triad-Core portabile usa al massimo 4 parametri per funzione.
8. **Iniziale maiuscola negli identificatori — CORRETTO il 2026-11-02 (N01).**
   Il seed rifiutava `Ab = 0` (exit 1) e `:Ab` per due test del primo byte senza
   case-folding (`stmt_assign`, `sym_scan` con salto morto sul ramo `A-Z`); con il
   folding `or 0x20` (come `parse_ident`) accetta `[A-Za-z_]`. Le keyword restano
   solo minuscole (`IF` è un identificatore, non una keyword).
9. **Separatore newline dopo un operatore.** Il seed è scannerless e prosegue
   l'espressione oltre il newline (`x = 1` seguito da `-2` vale `x = 1 - 2`);
   il JS tratta il newline come separatore di statement. SPEC-CORE §2 elenca il
   newline come separatore ma non decide la continuazione dopo un operatore:
   serve una decisione normativa prima di allineare i runtime.

I limiti sono anche codificati nel lint del generatore:
`node tools/site-gen/lint.mjs`.

## Il contratto del seed e i suoi presidî (2026-11-08)

Questa matrice è la misura; il **contratto** del seed la dichiara in forma
machine-leggibile (`seed/dev/certified-subset.txt`, leggibile in `seed/README.md`) e i
presidî la applicano:

- `node tools/selfhost-guard/guard.mjs` — guardie statiche: una regola per divergenza
  (`G-D01`…`G-D22`, `G-D24`), attive solo se la divergenza è ancora nel contratto (quando il seed
  viene corretto, la regola si spegne da sola); il corpus certificato è
  `seed/dev/certified-corpus.txt`;
- `node tools/selfhost-guard/differential.mjs` — gate differenziale: per ogni programma
  del corpus certificato, seed e riferimento JS devono dare lo **stesso stdout byte per
  byte** e lo **stesso exit code** (è il presidio delle divergenze che una regola statica
  non può decidere, perché dipendono dai tipi a runtime).

Correzioni a questa matrice, misurate il 2026-11-08: `println` **è** ammesso in posizione
finale (gli altri builtin e le funzioni utente no); il seed **risolve** i riferimenti in
avanti *fra funzioni* (rifiuta solo la chiamata a livello di file che precede la
definizione); i corpi di `if`/`while` non hanno un ambiente proprio (`let`/`begin` sì), e il
caso del nome *già legato* coincide nei due runtime (decisione normativa pending); le
keyword cieche contano solo dentro un corpo di blocco.

## Riallineamento dei probe ai dump `ff222c2` — 2026-11-08

Quattro programmi validi secondo SPEC-CORE §§4–7 erano ancora classificati
`bad_*`, ma il seed attuale li esegue correttamente. Ora sono `ok_*`, con
golden derivati dal riferimento JS e verificati sul seed ELF:

| Probe | stdout (ogni valore termina con newline) | exit |
|---|---|---|
| `ok_chiamata_nested_int` | `11` | 0 |
| `ok_chiamata_ultima_espressione` | `4` | 0 |
| `ok_if_valore_funzione` | `55`, `5` | 0 |
| `ok_lista_indice` | `1`, `3` | 0 |

Il runner esistente li scopre come positivi e verifica stdout byte per byte
e codice di uscita. Nessuna eccezione aggiunta al runner e nessun golden
preesistente modificato. Queste misure riguardano i quattro programmi:
le guardie conservative del corpus certificato e le altre divergenze del
contratto richiedono una verifica separata prima di essere rimosse.
La parità eseguibile PE non è stata rieseguita (ADR 0002).

## Ciclo di rebuild N03/N04: `-=`, `xs[i]`, `xs[i] = v` — 2026-11-08

Il rebuild del dump (core.js → `seed.hex` → binari) ha chiuso le capability che
erano state implementate solo nel generatore, e ne ha misurato i limiti reali
confrontando il seed con il riferimento JS (`seed/dev/triad_core.cjs`),
byte per byte su stdout + exit code:

| Costrutto | seed | interprete JS | probe |
|---|---|---|---|
| `-=` a nome | sì | sì | `ok_composta_sottrai.td` |
| `*=` a nome | sì | sì | `ok_composta_sottrai.td` |
| scrittura `xs[i] = v` (1-based) | sì | sì | `ok_lista_indice_scrittura.td` |
| `xs[i] += v` (assegnazione composta a indice) | **no** (exit 1, D24) | sì | `bad_lista_indice_composta.td` |
| indice fuori range | **errore di esecuzione** (exit 1, SPEC-CORE §9) | idem | `bad_lista_indice_fuori_range.td` |
| interi oltre ±(2^61 − 1) | **sbagliato senza errore** (D25) | corretto (64 bit, §5) | `bad_intero_64bit.td` |

Note:

1. **`-=` era sbagliato in silenzio.** Il codegen emetteva `sub rcx, rax`
   (`48 29 c1`) invece di `sub rax, rcx` (`48 29 c8`): il risultato era il
   valore *vecchio* (`x = 10; x -= 3` → `10`, non `7`). Divergenza *silent*
   (risultato sbagliato senza errore): la più insidiosa classe. Corretto in
   `seed/dev/core.js` con l'helper canonico `subRaxRcx()`.
2. **`xs[i] += v` resta una divergenza rumorosa (D24)**: la grammatica di
   Core (SPEC-CORE §4) non prevede l'assegnazione a indice, quindi la forma
   `xs[i] = v` è un'estensione del seed e quella composta no: dichiarata nel
   contratto (`seed/dev/certified-subset.txt`) e vietata dalla guardia
   statica `G-D24` sulla sorgente di S1.
3. **Il range degli interi è di 62 bit (D25)**: il tag del tipo occupa il bit
   basso, quindi il seed rappresenta al massimo ±(2^61 − 1); oltre, il
   risultato è sbagliato **senza errore** (wrap a 62 bit). Divergenza
   *silent*, decidibile solo a runtime: presidio nel gate differenziale.
4. Il rebuild ha anche chiuso `D6` (`-=`, `*=`), `D9` (chiamata in posizione
   finale) e `D13` (indicizzazione `xs[i]`, scrittura `xs[i] = v`): non sono
   più nel contratto, e le guardie `G-D06`/`G-D09`/`G-D13` sono state
   rimosse (i fixture che le facevano scattare sono diventati fixture
   «ammessi»).
