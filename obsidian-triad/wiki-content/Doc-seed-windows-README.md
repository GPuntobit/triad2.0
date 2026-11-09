> Copia di [`seed/windows-x86_64/README.md`](https://github.com/GPuntobit/triad2.0/blob/main/seed/windows-x86_64/README.md) — torna a [Documenti](Documenti) · [Home](Home)

# S0 / Windows x86-64 — seed con interprete Triad-Core: elseif (M3b2b3q)

Eseguibile PE32+ da **25088 byte**, senza runtime e senza libc: importa solo `KERNEL32.dll`.
Legge il file indicato dal primo argomento e interpreta un sottoinsieme di Triad-Core:

- statement `println(expr)`, `NAME = expr`, funzioni `f(x, y) = expr` e forma blocco `function f(x) … end` con **corpo a più istruzioni**, annotazione `!io` ignorata dal seed, `if`/`elseif`/`else`/`end`, `while`/`end`, **`let name = expr … end`**;
  `while`/`end` (annidati);
- espressioni con interi, variabili, chiamate, `+ - * % ^`, parentesi, `-` unario,
  confronti, ternario, letterali `true`/`false` e **lambda a un parametro** `x -> expr`;
- lambda a un parametro, anche passate come argomento e restituite da funzioni; cattura delle chiusure rimandata;
- `!`, `&&`, `||` (bitwise sui tag Bool) e assegnamento composto `+=`; `string(x)` conversione in stringa;
- valori taggati a 2 bit: `Int=n<<2`, `Bool false=1`/`true=5`, `chiusura=ptr|2`; `println`
  stampa interi, Bool, stringhe heap e `nothing`.

Il dump esadecimale è [`seed.hex`](https://github.com/GPuntobit/triad2.0/blob/main/seed/windows-x86_64/seed.hex).

- **Uso:** `seed.exe FILE`
- **Output:** per ogni `println(expr)` il valore in decimale/stringa + newline
- **Exit:** `0` successo; `1` errore (sintassi, variabile/funzione non definita, arità,
  lettura); `2` senza argomento
- **Entry point:** RVA `0x1000`
- **Sezione:** `.text`, RVA `0x1000`, file offset `0x200`, 24576 byte, caratteristiche `0xE0000020`
- **Immagine:** base `0x140000000`, `SizeOfImage` `0x7000`, header `0x200`, subsystem console, ASLR disattivata
- **Codice:** 11996 byte
- **sha256 di `seed.hex`:** `20AA566DAE21D2B102E684F7A8C1B67B1B2B44C61C1116E16D196DE31683D7B7`

## Layout del file

| offset/RVA | cosa |
|---|---|
| `0x000` | DOS header: `MZ`, `e_lfanew = 0x40` |
| `0x040` | firma `PE\0\0` |
| `0x044` | COFF: machine `0x8664`, 1 sezione, `SizeOfOptionalHeader = 0xF0`, caratteristiche `0x0022` |
| `0x058` | optional header PE32+, entry `0x1000`, base `0x140000000` |
| `0x0D0` | data directory import: RVA `0x40A0`, size `0x28` |
| `0x148` | section header `.text` (VirtualSize/RawSize `0x2400`) |
| file `0x200` / RVA `0x1000` | codice (11996 byte) |
| RVA `0x4000` (file `0x3200`) | IAT, 8 slot + null |
| RVA `0x4050` (file `0x3250`) | ILT, 8 slot + null |
| RVA `0x40A0` (file `0x32A0`) | import descriptor + terminator |
| RVA `0x40D0` (file `0x32D0`) | `KERNEL32.dll` |
| RVA `0x5000` (file `0x4200`) | hint/name delle 8 funzioni |

Mappatura delle sezioni: `file offset = 0x200 + (RVA - 0x1000)`.

## Memoria (`VirtualAlloc` 10 MiB, base `r14`)

| offset | cosa |
|---|---|
| `+0x00000` | sorgente Triad (max `0xFFFFF` = 1 MiB − 1 byte; a `+0x100000` c'è la mask di stop dei blocchi) |
| `+0x100000` | scratch: mask di stop dei blocchi (`+0x100000`), flag di chiusura (`+0x100008`), flag di break (`+0x100010`), modalità print inline (`+0x100028`) |
| `+0x110000` | variabili d'ambiente (`r15`): contatore `rbx`, voci da 24 byte (`+0` ptr nome, `+8` len, `+16` valore), max 16384 legami |
| `+0x190000` | tabella funzioni (`r13`): contatore qword a `[r13]`, voci da 128 byte a `r13+8+i*128`, max 3584 record |
| `+0x200000` | heap condiviso: bump pointer qword; record di chiusura da 128 byte a partire da `+0x200008`; stringhe `[type=1][len][byte…]` (dati a `+16`), 8 MiB utilizzabili |

`VirtualAlloc` riserva 10 MiB (`0xA00000`): il layout sopra è la mappa di memoria
dell'arena (N20: sorgente 1 MiB, heap 8 MiB).

Una chiusura è un record con la stessa forma di una voce funzione (nome/len del
parametro, n=1, body, parametro); il valore è `record|2`. Il record ha anche una
cattura: `+0x60` conteggio, `+0x68` ptr nome, `+0x70` len, `+0x78` valore.

La cattura era prevista quando la lambda è creata dentro il corpo di una funzione (flag
a `r14+0x100008`) e copia l'ultimo legame d'ambiente, di solito il parametro; al momento
della chiamata, ma il meccanismo non era affidabile: rimandato ad AST/bytecode.

Funzione d'ingresso: `+0` ptr nome, `+8` len nome, `+16` numero di parametri, `+24` ptr
del body nel sorgente, `+32` parametri (max 4, ciascuno con ptr a `+0` e len a `+8`).

L'assegnazione usa `env_assign`: cerca la variabile più recente e la aggiorna; se non
esiste la crea. I parametri delle funzioni sono legati con `env_store` (append) e
l'ambiente viene troncato al ritorno: in questo modo un ciclo aggiorna le variabili
invece di creare una voce per iterazione.

## Codice (mappa delle etichette, offset dall'inizio del codice)

| offset | etichetta | cosa fa |
|---|---|---|
| `0x000` | — | prologue, `GetStdHandle`, `GetCommandLineA`, parsing del path |
| `0xEE` | `path_check` | path vuoto → exit 2 |
| — | — | `CreateFileA`; `VirtualAlloc(0,0xA00000,…)`; `ReadFile`; `CloseHandle`; NUL; inizializza ambiente, funzioni e chiusure dell'heap |
| `0x22E` | `parse_program` | ciclo di statement: `println`, assegnazione, funzione, `if`, `while` |
| `0x51E` | `stmt_assign` | nome; `=` → assegnazione, `(` → funzione |
| `0x83C` | `st_func` | definizione: ingresso, parametri (max 4), `=`, body, salta a fine riga |
| `0x910` | `st_func_skip` | avanza fino a LF/`;`/EOF dopo il body |
| `0x93C` | `scan_end` | scansione di profondità: trova `elseif`/`else`/`end` con annidamento |
| `0xB98` | `sc_string` | salta il testo di un letterale (un letterale non è codice) |
| `0xBBD` | `st_if` | seleziona il primo ramo vero fra `if`/`elseif`, altrimenti `else` |
| `0xD52` | `st_while` | `while cond … end`: rivaluta la condizione, esegue il body |
| `0xDFE` | `st_function` | `function f(x) <espressione> end`: definizione con body di un'espressione |
| `0x1040` | `pp_eof` | EOF: errore se dentro un blocco (mask ≠ 0) |
| `0x1054` | `skip_ws` | spazi, tab, LF, CR, `;`, commenti `#` |
| `0x1114` | `parse_cmp` | confronti, risultato Bool |
| `0x125B` | `parse_ternary` | `cmp ? a : b` con scansione del ramo non scelto |
| `0x1408` | `parse_sum` | `term { (+\|-) term }` |
| `0x1470` | `parse_term` | `factor { (*\|%) factor }` |
| `0x15E8` | `parse_factor` | unario `-` o potenza |
| `0x17C4` | `parse_primary` | intero, Bool, variabile, chiamata, `( expr )` |
| `0x1B6F` | `pf_lambda` | `x -> expr`: record chiusura + cattura (1 binding) |
| `0x1C37` | `skip_text` | salta il corpo della lambda fino a un delimitatore |
| `0x2426` | `pf_call` | chiamata nominata o di chiusura, argomenti, cattura, binding, body |
| `0x2765` | `pf_call_nocap` | prosegue senza cattura |
| `0x2892` | `fn_find` | cerca una funzione per nome |
| `0x28EE` | `parse_ident` | identificatore |
| `0x295A` | `kw_bound` | confine bilatero di una parola chiave (una keyword è un token *esatto*) |
| `0x29D7` | `env_find` | cerca una variabile (dalla più recente) |
| `0x2A46` | `env_store` | aggiunge un parametro/variabile nuova |
| `0x2A6D` | `env_assign` | aggiorna la variabile più recente (o la crea) |
| `0x2ADD` | `print_int` | Int decimale, `true`/`false`, `fun` |
| `0x2E8C` | `fail`, `read_fail`, `open_fail`, `usage` | uscite |

### Chiamata di funzione (stack)

`push rbx` (env count), `push rbp` (argc), slot per il cursore di ritorno, `push entry`,
poi gli argomenti valutati, poi il cursore dopo `)`. Si legano i parametri in ordine inverso
con `env_store`, si esegue il body con `rsi` sul body, si ripristinano cursore ed `rbx`
(l'ambiente torna troncato). `r13` = tabella funzioni, `r15` = ambiente, `rbx` = contatore
variabili, `r12` = stdout, `r14` = base VirtualAlloc.

## Import

`GetStdHandle`, `GetCommandLineA`, `CreateFileA`, `ReadFile`, `WriteFile`, `CloseHandle`,
`ExitProcess`, `VirtualAlloc` (indici IAT 0–7; IAT a RVA `0x4000`).

## Build e verifica

```powershell
Remove-Item seed.exe -ErrorAction SilentlyContinue
certutil -decodehex seed.hex seed.exe

$out = Join-Path $env:TEMP 'out.txt'
$p = Start-Process .\seed.exe -ArgumentList 'conformance\core\cases\simboli_base\program.td' `
       -NoNewWindow -Wait -PassThru -RedirectStandardOutput $out
$p.ExitCode                                                       # 0
((Get-Content $out -Raw) -eq (Get-Content '..\..\conformance\core\cases\simboli_base\expected.out' -Raw))  # True

.\seed.exe ; $LASTEXITCODE                                        # 2
.\seed.exe non_esiste.td ; $LASTEXITCODE                          # 1
```

Verificati anche: `strings`, `concat_strings`, `nothing_base`, `base_strings`,
`begin_block`, `closure`, `closures`, `scope`, `funzioni_blocco`, `funzioni_io`,
`funzioni`, `aritmetica`, `lambda`, `while_loop`, `controllo` (elseif), `operatori`,
`confronti`, `ricorsione` (120/55), `funzioni_semplici`, `variabili`, `interi`; chiusura
che cattura il parametro (`f=crea(10); f(5)=15`) e due chiusure indipendenti
(`g=crea(100)`); errore di arità → exit 1.

## Limiti attuali

- cattura delle chiusure: copre l'ultimo binding del frame; la cattura multi-binding resta da fare (AST/bytecode);
- lambda solo a **un parametro**; body di una funzione: massimo 4 parametri;
- il seed non verifica staticamente gli effetti: `!io` è accettato per eseguire output nei corpi funzione;
- liste: ✅ implementate (costruzione, `push!`, `get`, indice `xs[i]` e scrittura `xs[i] = v`; il gap storico `liste` del gate di conformance è chiuso);
- `string()` copre Int e String; Bool/Symbol/Nothing non implementati;
- `elseif` ✅ implementato;
- solo Windows PE; `os_*` ed ELF sono del port M7.

> **Aggiornato il 2026-11-09 (D22 risolta):** le parole chiave sono riconosciute come
> token *esatti* (helper `kw_bound`: `iffy`, `myif`, `endx`, `elsewhere` non sono
> keyword) e il testo di un letterale non conta per l'annidamento dei blocchi
> (routine `sc_string`): un letterale può contenere `if` anche dentro un blocco.
