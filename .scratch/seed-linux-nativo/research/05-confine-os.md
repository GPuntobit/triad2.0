# Ricerca 05 — Come altri seed scritti a mano isolano il confine OS

Findings per il ticket
[`issues/05-ricerca-confine-os.md`](../issues/05-ricerca-confine-os.md).
Raccolti il 2026-11-04 per rispondere alla domanda del ticket: quante routine al
confine OS, quale convenzione di chiamata, come gestiscono heap e I/O, e quale
compromesso scelgono fra confine stretto e confine funzionale.

Metodo: fonti primarie (sorgenti in assembly e documentazione dei progetti)
fetched direttamente dai repository upstream o dai loro mirror; ogni fatto
cita la fonte letta. Le righe di confronto col seed Triad sono **dati e
sintesi**, non decisioni: le decisioni restano in
[02 — Architettura del codegen](../issues/02-architettura-codegen.md) e
[03 — Contratto delle routine `os_*`](../issues/03-contratto-os-star.md).

## Casi studio

### 1. sectorlisp — LISP in 512 byte su BIOS (bare metal)

Fonte primaria: [`sectorlisp.S`](https://github.com/jart/sectorlisp/blob/master/sectorlisp.S)
(raw: `raw.githubusercontent.com/jart/sectorlisp/master/sectorlisp.S`), README
upstream. Copyright Justine Tunney et al.

- **Routine al confine: 2 servizi BIOS**, punto. `int $0x16` (AH=0, tastiera) in
  `GetToken` e `int $0x10` (AH=0x0e, teletype) in `PutChar`. Nessun servizio di
  disco (il firmware carica il boot sector) né di memoria.
- **Convenzione di chiamata**: nessun ABI esterno; registri ad-hoc documentati
  nei commenti del sorgente — `GetToken():al`, `Gc(x:di,A:dx,B:si):ax`,
  `Print(x:si)`. Il confine è in routine interne (`GetChar` fa la `int`), il
  corpo del LISP non vede il BIOS.
- **Heap**: interamente in linguaggio. `Cons` è un bump allocator che avanza
  `%cx` di 4 byte per cella (`lea 4(%di),%cx`); quando la memoria basta appena
  scatta il **GC scritto nel LISP stesso** ("ABC Garbage Collector", `Gc`,
  ~20 istruzioni) che ricostruisce la struttura raggiungibile via `Cons`.
- **I/O**: char-at-a-time (tastiera/teletype); il "REPL" è `Read` → `Eval` →
  `PrintObject` in un ciclo.
- **Errori**: nessun canale d'errore: silenzio e re-lettura.

### 2. sectorforth — Forth in 512 byte su BIOS (bare metal)

Fonte primaria: [`sectorforth.asm`](https://github.com/cesarblum/sectorforth/blob/master/sectorforth.asm)
+ README upstream ("16-bit x86 Forth that fits in a 512-byte boot sector").

- **Routine al confine: 2 servizi BIOS** — `int 0x16` (lettura tasto) e
  `int 0x10` (AH=03h posizione cursore + AH=0x0e teletype, in `writechar`).
- **Convenzione di chiamata**: la macchina astratta Forth (stack di dati,
  threading diretto con `SI` come IP); l'adattamento al BIOS sta nelle due
  primitive `getkey`/`writechar` codificate in assembly.
- **Heap**: nessun servizio memoria; il dizionario cresce linearmente in RAM
  fissa (TIB a `0x1000`, offset di lettura `>IN` a `0x1002`), senza free né GC.
- **I/O**: char-at-a-time; l'input si rifornisce una riga alla volta
  (`.readline`).
- **Errori**: nessuno: un boot sector che fallisce semplicemente non risponde.

### 3. jonesforth — Forth in assembly su Linux i386 (userland)

Fonte primaria: [`jonesforth.S`](https://github.com/nornagon/jonesforth/blob/master/jonesforth.S)
(mirror di JONESFORTH di Richard W.M. Jones, `git.annexia.org`), ~2300 righe di
commento+sorgente.

- **Routine al confine**: 80 code words totali, di cui **6 toccano l'OS**
  (`KEY`, `EMIT`, `SYSCALL0`–`SYSCALL3`) più la crescita della memoria (`brk`).
  Esistono inoltre 7 costanti-di-syscall dichiarate al programma Forth —
  `SYS_EXIT`, `SYS_OPEN`, `SYS_CLOSE`, `SYS_READ`, `SYS_WRITE`, `SYS_CREAT`,
  `SYS_BRK` (`defconst`, da `<asm/unistd.h>`).
- **Convenzione di chiamata**: la convenzione della macchina astratta (stack di
  dati) viene adattata all'ABI Linux nei punti di chiamata: le parole
  `SYSCALL0`–`SYSCALL3` poppano i parametri dallo stack nei registri
  `ebx, ecx, edx` e fanno `int $0x80`. Le syscall vanno via *escape hatch
  generico*, così il programma può raggiungere qualunque syscall senza che il
  kernel cresca.
- **Heap**: servizio memoria usato **una volta all'avvio**: `set_up_data_segment`
  fa `brk(0)` per trovare la base, poi `brk(HERE + 65536)` per riservare;
  dopodiché il dizionario avanza con `HERE` (bump), senza free.
- **I/O**: `KEY` legge da fd 0 con `read` **bufferizzato** (buffer di 4096,
  puntatori `currkey`/`bufftop`; a EOF fa `exit(0)`); `EMIT` scrive su fd 1 con
  `write` **un byte alla volta, non bufferizzato**. L'apertura file passa da
  `SYS_OPEN` su richiesta del programma (`INCLUDED` ecc.).
- **Errori**: i messaggi di errore del parsing vanno su **stdout** via `write`
  (non c'è un canale stderr distinto); terminazione con `exit`.

### 4. Collapse OS — kernel Z80 in Forth, hardware astratto (bare metal)

Fonti: documentazione del progetto di Virgil Dupras —
[`doc/glue-code.md`](https://github.com/rdacomp/CollapseOS/blob/master/doc/glue-code.md),
[`doc/blockdev.md`](https://github.com/rdacomp/CollapseOS/blob/master/doc/blockdev.md)
(letti su mirror GitHub `rdacomp/CollapseOS`; il repo canonico è
`git.sr.ht/~vdupras/collapseos-again`, consultato ma protetto da anti-bot al
momento della raccolta) e [`collapseos.org/forth.html`](https://collapseos.org/forth.html).

- **Routine al confine**: il kernel non sa nulla dell'hardware; il **glue code**
  fornito dal port fornisce **una coppia `GetC`/`PutC` per classe di
  dispositivo** in **tabelle statiche** (`.dw aciaGetC, aciaPutC, 0, 0`):
  una coppia per lo stdio e una coppia per i block device (max `0xff` dispositivi
  definiti a tempo di include). Ogni block device ha in più un seek pointer.
- **Convenzione di chiamata**: registri + flag, **scritta nel contratto**:
  `GetC` prende la posizione in `HL` (`DE` = byte alti se serve addressing a 32
  bit), ritorna il carattere in `A`, **flag `Z` azzerato = errore**; `PutC` è lo
  specchio. Metodi dummy (`unsetZ`) per i dispositivi read-only/write-only.
- **Heap**: nessun allocazione nel kernel: la RAM è assegnata staticamente
  modulo per modulo nel glue code (`RAMSTART`/`*_RAMEND`); la gestione memoria
  delle applicazioni vive sopra, in Forth.
- **I/O**: char-at-a-time per lo stdio; storage a blocchi con seek per
  `load`/`save`.
- **Errori**: **codici numerici** (es. `0x04` argomento fuori range) e flag,
  mai stringhe di testo.

### 5. Forth classici — il kernel come confine di porting

Fonte: Brad Rodriguez, *Moving Forth, Part 1: Design Decisions in the Forth
Kernel*, The Computer Journal #59 (gen/feb 1993) —
[`moving1.htm`](https://www.bradrodriguez.com/papers/moving1.htm), e Part 2
([`moving2.htm`](https://www.bradrodriguez.com/papers/moving2.htm)).

- **Quanto è grande il confine**: "the usual 16-bit Forth kernel" occupa
  **~8K byte** (×2 per un modello 32-bit), con minimo 1K di RAM per compilare
  definizioni e 3K+ di buffer se si usa il sistema a blocchi.
- **Convenzione di chiamata**: il kernel parla la macchina astratta Forth
  (stack di dati e stack di ritorno, `NEXT` come interprete interno,
  `ENTER`/`DOCOL` e `EXIT` come meccanica di chiamata); la parte dipendente
  dall'hardware è ristretta alle primitive di I/O e di storage. Le code words
  reali si possono inventariare su un'implementazione concreta: jonesforth ne
  ha 80, di cui 6 toccano l'OS (v. caso 3).
- **Scelte di threading** (come cambia il compromesso): sui 19 Forth IBM PC
  studiati da Guy Kelly citati dall'articolo, 10 usano DTC, 7 ITC, 2 STC — la
  tendenza è alla forma più semplice che il CPU regge.

### 6. stage0 / hex0 e bootstrappable.org — il confine minimo possibile

Fonti: [`stage0/README.org`](https://github.com/oriansj/stage0/blob/master/README.org),
[`bootstrap-seeds/README.md`](https://github.com/oriansj/bootstrap-seeds/blob/master/README.md),
[`bootstrappable.org`](https://bootstrappable.org/).

- **stage0**: "the ultimate lowest level of bootstrap … for systems without
  firmware, operating systems nor any other provided software functionality";
  il primo nodo utile (hex0) fa **una sola cosa**: da sorgente hex a binario
  (`bootstrap-seeds`: `hex0` ≈ `sed 's/[;#].*$//g' $input | xxd -r -p`). Il
  confine OS si riduce a **2–3 syscall** (read/write/exit) usate inline, senza
  né convenzione né wrapper: il minimo che serve a trasformare testo in binari.
- **bootstrappable.org** (manifesto del movimento): l'obiettivo è "minimize the
  amount of bootstrap binaries" perché i binari opachi non sono auditabili.
  È la giustificazione ultima del confine stretto: **meno routine al confine,
  meno codice di cui fidarsi**, e il resto verificabile da sorgente.

## Tavola sinottica

| Progetto | Piattaforma | Routine al confine | Convenzione | Heap | I/O | Errori |
|---|---|---|---|---|---|---|
| sectorlisp | BIOS x86, boot sector | **2** servizi BIOS | registri ad-hoc commentati | bump in-linguaggio + GC in-linguaggio | char-at-a-time | silenzio |
| sectorforth | BIOS x86, boot sector | **2** servizi BIOS | macchina Forth → 2 primitive | dizionario lineare, RAM fissa | char-at-a-time | silenzio |
| jonesforth | Linux i386 userland | **6** parole + 7 costanti syscall | stack Forth → registri ABI (`int $0x80`) | `brk` una volta, poi bump (`HERE`) | `KEY` bufferizzato / `EMIT` no | testi su stdout, `exit` |
| Collapse OS | Z80 bare metal | **2 per classe di dispositivo** (stdio, blockdev) | registri + flag `Z`, tabelle statiche | RAM statica nel glue code | char-at-a-time + blocchi con seek | codici numerici, flag |
| Forth classici | varie | kernel ~8K; I/O+storage dipendono dall'hw | macchina astratta Forth | dizionario lineare + buffer blocchi | char-at-a-time + blocchi | — |
| stage0/hex0 | vari (nudi) | **2–3** syscall inline | nessuna: syscall native inline | buffer fissi | stream hex | nessuno |

## Risposte alle sotto-domande del ticket

1. **Quante routine**: da **2** (BIOS/syscall minime, tutto il resto costruito
   in linguaggio sopra) a **~2 per classe di dispositivo** (Collapse OS) o
   **6 + escape hatch generico** (jonesforth). Non esiste un caso con dozzine di
   routine al confine: ogni routine in più deve guadagnarsi il posto.
2. **Convenzione di chiamata**: due famiglie. (a) *Adattamento al bordo*: la
   convenzione della macchina astratta (stack Forth) o documentata ad-hoc
   (sectorlisp) viene convertita nella convenzione nativa (BIOS/registri
   syscall) **dentro** le primitive, il resto del sistema non la vede.
   (b) *Contratto registri+flag*: Collapse OS fissa posizione/carattere/errore
   in registri e flag specifici, scritto nella documentazione, con tabelle
   statiche di vettori al posto di dispatch dinamici.
3. **Heap**: nessun seed chiede memoria all'OS quando può evitarlo. Bare metal:
   gestione in linguaggio (bump `Cons` + GC in LISP; dizionario lineare in RAM
   fissa). Userland: un servizio memoria **una tantum all'avvio**
   (`brk(0)` + `brk(base+64K)`), poi crescita lineare; nessun `free` in nessun
   caso.
4. **I/O**: il minimo comune è char-at-a-time (`KEY`/`EMIT`, `GetC`/`PutC`).
   Chi ha a che fare con file e stream bufferizza l'input (jonesforth: buffer
   4K + `read`) e usa seek per lo storage a blocchi (Collapse OS). Nessun caso
   fa "leggi tutto e chiudi".
5. **Stretto vs funzionale**: il confine **stretto** (2–3 routine) è praticabile
   quando il seed è piccolo e tutto il resto (GC, parsing, memoria) vive nel
   linguaggio sopra il confine; il costo è che ogni funzione in più va
   costruita da zero, il beneficio è una superficie minima e auditabile
   (bootstrappable.org). Il confine **funzionale** (per classe di dispositivo,
   Collapse OS) nasce quando lo stesso kernel deve girare su hardware diverso:
   più routine e più codice glue, in cambio di un kernel che non sa nulla
   dell'hardware. jonesforth mostra una **terza via**: un insieme chiuso e
   piccolo di routine nominate *più* uno sportello generico (`SYSCALL0-3`) che
   tiene il kernel stretto senza limitare il sistema.

## Confronto col seed Triad (dati, non decisioni)

- Le 6 routine di `os_*` ([03](../issues/03-contratto-os-star.md)) cadono nella
  fascia osservata (2 … ~11): nessun caso studio ha un confine più grande.
  `os_arg` non ha analogo nei casi bare-metal (non c'è argv) ma è un adattamento
  d'obbligo sui due ABI utente (Win32/ELF).
- **`os_read` "leggi tutto e chiudi"** è un'innovazione rispetto ai casi
  (nessuno la fa): è giustificata dal profilo one-shot dell'interprete (una
  sorgente, poi exit) e minimizza lo stato del corpo — nessun handle vivo, né
  offset — ma va registrata come scelta consapevole, non come prassi.
- **`os_alloc` una tantum** (arena bump) è esattamente lo schema di jonesforth
  (`brk` all'avvio, poi `HERE`); i casi bare-metal non hanno nemmeno il
  servizio.
- **"PE muto" + exit code** (03, Q4) segue il pattern ricorrente: i seed
  minimali non stampano testi d'errore (silenzio o codici numerici/flag,
  Collapse OS); nessun caso ha un canale stderr distinto.
- **Emissioni inline, mai sottoroutine** (02): in tutti i casi la syscall/`int`
  vive nel punto di bisogno (o nella micro-primitiva dedicata); nessun sistema
  usa tabelle di dispatch per raggiungere l'OS.
- La forma del contratto 03 ("piazzamenti ordinati di slot su registri") è
  affine al modello Collapse OS (registri assegnati + convenzione fissa
  documentata), con la differenza che i vettori statici diventano ordini di
  emissione nel codegen.

## Limiti e fonti non consultate

- Collapse OS: repo canonico su sr.ht protetto da anti-bot; letta la
  documentazione su mirror GitHub `rdacomp/CollapseOS` (layout `doc/`+`kernel/`
  della release pubblica). Non letti i sorgenti Z80 del kernel.
- jonesforth: letto su mirror `nornagon/jonesforth`; non confrontato col repo
  originale `git.annexia.org`.
- *Moving Forth* è un articolo tecnico (TCJ, 1993), non uno standard; le cifre
  (8K kernel, 19 Forth di Kelly) sono le sue.
- stage0: letto il README.org; non analizzati i sorgenti di hex0 né
  `bootstrapping Steps.org`. Le "2–3 syscall" di hex0 sono dedotte dalla
  descrizione del programma (legge sorgente, scrive binario) e dalla struttura
  del progetto, non da un conteggio diretto del sorgente.
- Non consultati: fig-Forth installation manual (originale), eForth (C.H.
  Ting), xv6/MINIX (confine kernel-utente, fuori dal profilo "seed scritto a
  mano").
