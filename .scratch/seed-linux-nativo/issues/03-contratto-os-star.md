# 03 — Contratto delle routine `os_*`

Type: prototype
Status: resolved
Blocked by: 02

## Question

`BOOTSTRAP.md` §4 nomina 4–5 routine (`os_open`, `os_read`, `os_write`, `os_exit`,
`os_alloc`): qual è il contratto concreto che il corpo dell'interprete può usare
**identico** su PE ed ELF?

Da firmare: registri/parametri e convenzione di chiamata; chi apre e chiude i file;
gestione errori (exit code, stderr); `os_alloc` (arena bump vs heap) e i suoi limiti;
quanto serve al caricamento del sorgente (`argv`, buffer) previsto da N15 in `TASK.md`.

Si risolve con uno **spike a bassa fedeltà** (prototipo gettabile): il confine `os_*`
dietro una chiamata già esistente del PE **e** una micro-ELF che lo usa nativamente, per
reagire alla forma del contratto prima di scriverlo nelle slice di `TASK.md`. Input utile
ma non bloccante: [05 — Ricerca: come altri seed scritti a mano isolano il confine
OS](05-ricerca-confine-os.md).

## Answer

**Decisione 2026-11-04 (sessione wayfinder, HITL col maintainer, Q1–Q6): forma
(c) — piazzamenti ordinati.** Conferme: Q2 sì, Q3 (ii), Q4 «PE muto», Q5 arena
bump, Q6 `openat`.

**Forma del contratto (Q1).** Emissioni **inline** da funzioni-generatore (decisione
_Architettura del codegen per due piattaforme_). Ogni chiamata del corpo è una
**lista ordinata di materializzazioni di argomenti astratti** (slot `handle`, `buf`,
`len`, …) terminata dalla chiamata stessa; il backend di piattaforma mappa gli slot
sui propri registri **nell'ordine della lista**. Le materializzazioni possono vivere
in blocchi separati — copre lo storico `mov r8d,len` carico prima dei `jmp` e gli
ordini intrecciati dei call site. Conseguenza: **byte-identico su PE ovunque, per
costruzione** — nessuna eccezione di layout a _Politica dei byte del PE nella
rifattorizzazione_ né ad _Architettura del codegen per due piattaforme_. Cautela:
l'interfaccia resta *dati di piazzamento di slot di syscall*, mai costrutti nuovi —
per non scivolare nel meta-linguaggio respinto dall'architettura.

**Registro/stato (Q2).** Stato del corpo: `r14` = base regione `0x40000`; `r12` =
handle stdout (**solo PE**, inutilizzato su ELF); `rbx` = handle file; `r13` =
conteggio. `os_*` può sporcacciare solo `rcx, rdx, rsi, rdi, r8, r9, r11` (volatili);
su ELF non tocca i registri-stato del corpo.

**Lista e firme (Q3 ii, Q6).**

| routine | semantica | PE (inline) | ELF (inline) |
|---|---|---|---|
| `os_arg(buf)` | copia `argv[1]` nel buffer path; vuoto → usage (exit 2) | parsing di `GetCommandLineA` **dentro** `os_arg` | copia da `[rsp+16]` (`_start`) |
| `os_open(path) → handle` | apre in sola lettura | `CreateFileA(GENERIC_READ, FILE_SHARE_READ, OPEN_EXISTING, NORMAL)` | `openat(AT_FDCWD, path, O_RDONLY)` |
| `os_read(handle, buf, max) → n` | legge tutto e **chiude l'handle** (nessuna `os_close` — peso minimo sul load) | `ReadFile` + `CloseHandle` adiacenti | loop `read` + `close` |
| `os_write(buf, len)` | scrive su stdout, nessun check (come oggi) | `WriteFile` (`r12`, `lpNumberOfBytesWritten=&[rsp+0x28]`, `lpOverlapped=NULL`) | `write(1, …)` |
| `os_exit(code)` | terminale, mai ritorna | `ExitProcess` | `exit` (60) |
| `os_alloc(size) → base` | **una sola chiamata**, all'avvio | `VirtualAlloc(NULL, 0x40000, COMMIT\|RESERVE, RW)` | `mmap(NULL, size, RW, PRIVATE\|ANON, -1, 0)` |

Il corpo sposta la base in `r14` (identico sulle due piattaforme) e dopo `os_read`
controlla `n < 0xF000` (slot maschera) → exit 1 se il sorgente è troppo grande,
com'è oggi. `openat` (N15) e non `open`: `BOOTSTRAP.md` §4 nomina il *nome funzione*,
non il numero syscall.

**Errori (Q4 «PE muto»).** Exit code identici sulle due piattaforme: 1 =
fail/read/open, 2 = usage. Il PE non scrive **mai** su stderr. Diagnostica su stderr
ammessa **solo sull'ELF**, fuori dal contratto di parità (che copre stdout
byte-identico): soddisfa l'accettazione di _N15 — E1: runner ELF di un file `.td`_
senza toccare il PE.

**Memoria (Q5).** Regione fissa `0x40000`, **arena bump** senza GC: nessun `free`,
nessuna seconda chiamata di `os_alloc`; le chiusure avanzano il puntatore da
`0x30000`. Limiti invariati: sorgente ≤ `0xF000`, regione `0x40000`, allocazioni
esaurite → exit 1. Il GC mark-sweep arriva con S1 (`BOOTSTRAP.md` §4), fuori da
questo contratto. Differenza rispetto all'alternativa *heap*: `os_alloc`
richiamabile più volte/memoria riutilizzabile — scartata: costa complessità al seed
e il GC comunque non è in questa fase.

**Asset.** Spike gettabile `seed/dev/proto_os_star.mjs` (misura byte su tutti e 7 i
call site WriteFile reali + micro-ELF eseguita nativamente: `os_alloc` → r14,
`os_write`, `os_exit(7)` → `"OK\n"`, PASS) catturato sul branch throwaway
**`prototype/os-star-contract`** (commit `73c7403` lo rimuove dal ramo di lavoro;
il ramo di lavoro tiene solo la decisione). La misura dello spike è ciò che ha
fatto emergere la forma: la canónica a ordine fisso è byte-identica solo su 4/7
call site; la forma (c) è byte-identica su 7/7 per costruzione.

**Effetti.** `TASK.md` N15/N16 puntano già qui (nessun cambio). Nessuna modifica a
_SPEC-CORE.md_. Glossario: aggiunte le voci *Piazzamenti ordinati* e *Arena bump*.

## Comments
