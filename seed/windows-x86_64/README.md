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

Il dump esadecimale è [`seed.hex`](seed.hex).

- **Uso:** `seed.exe FILE`
- **Output:** per ogni `println(expr)` il valore in decimale/stringa + newline
- **Exit:** `0` successo; `1` errore (sintassi, variabile/funzione non definita, arità,
  lettura); `2` senza argomento
- **Entry point:** RVA `0x1000`
- **Sezione:** `.text`, RVA `0x1000`, file offset `0x200`, 24576 byte, caratteristiche `0xE0000020`
- **Immagine:** base `0x140000000`, `SizeOfImage` `0x7000`, header `0x200`, subsystem console, ASLR disattivata
- **Codice:** 8315 byte
- **sha256 di `seed.hex`:** `9987105DCD56F42A1AD73451821A281E6F24374ED6CE83993BB8CA56F5EC4822`

## Layout del file

| offset/RVA | cosa |
|---|---|
| `0x000` | DOS header: `MZ`, `e_lfanew = 0x40` |
| `0x040` | firma `PE\0\0` |
| `0x044` | COFF: machine `0x8664`, 1 sezione, `SizeOfOptionalHeader = 0xF0`, caratteristiche `0x0022` |
| `0x058` | optional header PE32+, entry `0x1000`, base `0x140000000` |
| `0x0D0` | data directory import: RVA `0x40A0`, size `0x28` |
| `0x148` | section header `.text` (VirtualSize/RawSize `0x2400`) |
| file `0x200` / RVA `0x1000` | codice (8315 byte) |
| RVA `0x4000` (file `0x3200`) | IAT, 8 slot + null |
| RVA `0x4050` (file `0x3250`) | ILT, 8 slot + null |
| RVA `0x40A0` (file `0x32A0`) | import descriptor + terminatore |
| RVA `0x40D0` (file `0x32D0`) | `KERNEL32.dll` |
| RVA `0x5000` (file `0x4200`) | hint/name delle 8 funzioni |

Mappatura della sezione: `file offset = 0x200 + (RVA - 0x1000)`.

## Memoria (`VirtualAlloc` 192 KiB, base `r14`)

| offset | cosa |
|---|---|
| `+0x00000` | sorgente Triad (max 60 KiB; a `+0xF000` c'è la maschera di stop dei blocchi) |
| `+0x10000` | ambiente variabili (`r15`): contatore `rbx`, entry da 24 byte (`+0` nome ptr, `+8` len, `+16` valore) |
| `+0x20000` | tabella funzioni (`r13`): contatore qword a `[r13]`, entry da 128 byte a `r13+8+i*128` |
| `+0x30000` | heap condiviso: bump pointer qword; record chiusura da 128 byte da `+0x30008`; stringhe `[tipo=1][len][byte…]` (dati a `+16`) |

`VirtualAlloc` riserva 256 KiB. Una chiusura è un record con la stessa forma di una entry
funzione (nome/len del parametro, n=1, body, parametro); il valore è `record|2`. Il record ha
anche una cattura: `+0x60` conteggio, `+0x68` nome ptr, `+0x70` len, `+0x78` valore.
La cattura era prevista quando la lambda è creata dentro un corpo di funzione (flag a
`r14+0xF008`) e copia l'ultimo binding dell'ambiente, di solito il parametro; al momento della
chiamata, ma il meccanismo non è risultato affidabile: rimandato ad AST/bytecode.

Entry funzione: `+0` nome ptr, `+8` nome len, `+16` numero parametri, `+24` body ptr nel
sorgente, `+32` parametri (max 4, ciascuno ptr a `+0`, len a `+8`).

L'assegnamento usa `env_assign`: cerca la variabile più recente e la aggiorna; se non esiste la
crea. I parametri di funzione sono legati con `env_store` (append) e l'ambiente viene troncato
al ritorno; in questo modo un ciclo aggiorna le variabili invece di creare una entry per giro.

## Codice (mappa per etichette, offset dall'inizio del codice)

| offset | etichetta | cosa fa |
|---|---|---|
| `0x000` | — | prologo, `GetStdHandle`, `GetCommandLineA`, parsing path |
| `0xEE` | `path_check` | path vuoto → exit 2 |
| — | — | `CreateFileA`; `VirtualAlloc(0,0x40000,…)`; `ReadFile`; `CloseHandle`; NUL; inizializza ambiente, funzioni e heap chiusure |
| `0x220` | `parse_program` | ciclo statement: `println`, assegnamento, funzione, `if`, `while` |
| `0x40D` | `stmt_assign` | nome; `=` → assegnamento, `(` → funzione |
| `0x4E4` | `st_func` | definizione: entry, parametri (max 4), `=`, body, salta a fine riga |
| `0x598` | `st_func_skip` | avanza fino a LF/`;`/EOF dopo il body |
| `0x5C4` | `scan_end` | scansione a profondità: trova `elseif`/`else`/`end` con annidamento |
| `0x7A7` | `st_if` | seleziona il primo ramo vero tra `if`/`elseif`, altrimenti `else` |
| `0x8E5` | `st_while` | `while cond … end`: rivaluta la condizione, esegue il corpo |
| `0x96B` | `st_function` | `function f(x) <espressione> end`: definizione con corpo a una espressione |
| `0xBA0` | `pp_eof` | EOF: errore se dentro un blocco (maschera ≠ 0) |
| `0xBB4` | `skip_ws` | spazi, tab, LF, CR, `;`, commenti `#` |
| `0xC74` | `parse_cmp` | confronti, risultato Bool |
| `0xDBB` | `parse_ternary` | `cmp ? a : b` con scansione del ramo non scelto |
| `0xF36` | `parse_sum` | `term { (+\|-) term }` |
| `0xF94` | `parse_term` | `factor { (*\|%) factor }` |
| `0x10F6` | `parse_factor` | unario `-` o potenza |
| `0x1192` | `parse_primary` | intero, Bool, variabile, chiamata, `( expr )` |
| `0x14BD` | `pf_lambda` | `x -> expr`: record chiusura + cattura (1 binding) |
| `0x1561` | `skip_text` | salta il corpo della lambda fino a un delimitatore |
| `0x185D` | `pf_call` | chiamata nominata o di chiusura, argomenti, cattura, binding, body |
| `0x19F9` | `pf_call_nocap` | prosegue senza cattura |
| `0x1AFB` | `fn_find` | cerca una funzione per nome |
| `0x1B57` | `parse_ident` | identificatore |
| `0x1BC3` | `env_find` | cerca una variabile (dalla più recente) |
| `0x1C32` | `env_store` | aggiunge un parametro/variabile nuova |
| `0x1C4C` | `env_assign` | aggiorna la variabile più recente (o la crea) |
| `0x164D` | `print_int` | Int decimale, `true`/`false`, `fun` |
| `0x11BD` … | `fail`, `read_fail`, `open_fail`, `usage` | uscite |

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

Verificati anche: `stringhe`, `stringhe_concat`, `nothing_base`, `stringhe_base`, `begin_block`, `closure`, `chiusure`, `scope`, `funzioni_blocco`, `funzioni_io`, `funzioni`, `aritmetica`, `lambda`, `while_loop`, `controllo` (elseif), `operatori`, `confronti`, `ricorsione`
(120/55), `funzioni_semplici`, `variabili`, `interi`; chiusura che cattura il parametro
(`f=crea(10); f(5)=15`) e due chiusure indipendenti (`g=crea(100)`); errore di arità → exit 1.

## Limiti attuali

- cattura delle chiusure: copre l'ultimo binding del frame; la cattura multi-binding resta da fare (AST/bytecode);
- lambda solo a **un parametro**; body di una funzione: massimo 4 parametri;
- il seed non verifica staticamente gli effetti: `!io` è accettato per eseguire output nei corpi funzione;
- mancano le liste (casi `liste` e `valori`);
- `string()` copre Int e String; Bool/Symbol/Nothing non implementati;
- `elseif` ✅ implementato;
- solo Windows PE; `os_*` ed ELF sono del port M7.
