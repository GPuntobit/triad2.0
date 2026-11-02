# Probe — matrice di portabilità Triad-Core

Questi probe **misurano** quali costrutti di Triad-Core danno lo stesso risultato
sul seed in codice macchina (Windows, `seed/windows-x86_64/seed.exe`) e
sull'interprete di riferimento in JavaScript (`seed/dev/triad_core.cjs`).

Non sono test di conformance: non hanno golden. Sono il **guardrail** che
permette al generatore del sito (`tools/site-gen/`) di produrre output identico
byte per byte sui due runtime.

## Esecuzione

```sh
node tests/probes/run_probes.mjs                 # tutti i probe
node tests/probes/run_probes.mjs ok_builder.td  # un probe
```

Output per ogni file: exit code e stdout dei due runtime, e il flag `same`
quando coincidono.

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
| letterale di lista su più righe | sì | **no** (parse error) | `bad_lista_multiriga.td` |
| scope dei nomi nelle funzioni | **dinamico** (il callee vede i locali del chiamante) | lessicale | `bad_scope_dinamico.td` |
| funzioni con più di 4 parametri | **no** | sì | `bad_parametri_5.td` |
| `if`/`elseif`/`else`, `while` | sì | sì | `ok_if_assegna.td`, `ok_while_in_funzione.td` |
| ternario `? :` | sì | sì | `ok_ternario.td` |
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
| front-end S1 (scanner + parser, `selfhost/source.td`) | sì | sì | `node tests/probes/run_probes.mjs selfhost/source.td` |

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
   implementa correttamente ed è il runtime con cui la suite di conformance
   viene eseguita su Linux.
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

I limiti sono anche codificati nel lint del generatore:
`node tools/site-gen/lint.mjs`.
