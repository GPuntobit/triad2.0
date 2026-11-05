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
| `length(xs)` su lista | sì | sì | `bad_lista_indice.td` |
| indice di lista `xs[i]` | **no** | sì | `bad_lista_indice.td` |
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
| `if`/`else` come *valore* del corpo | **no** | sì | `bad_if_valore_funzione.td` |
| chiamata come *ultima espressione* del corpo | **no** | sì | `bad_chiamata_ultima_espressione.td` |
| chiamata annidata con argomento Int | **no** | sì | `bad_chiamata_nested_int.td` |
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
2. **Chiamata come ultima espressione.** Il seed non valuta una chiamata nella
   posizione finale del corpo di una funzione. Il pattern sicuro è
   `r = inner(x)` e poi `r`.
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
