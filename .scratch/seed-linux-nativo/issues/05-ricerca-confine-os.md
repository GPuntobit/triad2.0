# 05 — Ricerca: come altri seed scritti a mano isolano il confine OS

Type: research
Status: resolved

## Question

Fatti che una decisione attende: come progetti con seed/interpreti scritti a mano in
codice macchina (es. sectorlisp, Collapse OS, bootstrappable.org, Forth classici)
isolano il confine con il sistema operativo — quante routine, quale convenzione di
chiamata, come gestiscono heap e I/O, e quale compromesso scelgono fra confine stretto e
confine funzionale.

Serve come input (non bloccante) per [02 — Architettura del codegen per due
piattaforme](02-architettura-codegen.md) e [03 — Contratto delle routine
`os_*`](03-contratto-os-star.md). Fonti primarie ad alta fiducia; findings catturati come
da skill `research`, con puntatore dal ticket.

## Answer

**Risolto 2026-11-04 (AFK).** Findings completi su branch gettabile
[`research/05-confine-os`](https://github.com/GPuntobit/triad2.0/blob/research/05-confine-os/.scratch/seed-linux-nativo/research/05-confine-os.md)
(commit `2cc8cba`, file `.scratch/seed-linux-nativo/research/05-confine-os.md`; ramo mai
mergeato, come per lo spike di _Contratto delle routine `os_*`_). Fonti primarie: sorgenti
e documentazione di sectorlisp, sectorforth, jonesforth, Collapse OS, Moving Forth (TCJ
#59, 1993), stage0/hex0, bootstrappable.org.

**Sintesi.** (1) *Quante routine*: da **2** (BIOS/syscall minime — sectorlisp, sectorforth,
hex0: tutto il resto costruito in linguaggio sopra il confine) a **2 per classe di
dispositivo** (Collapse OS: `GetC`/`PutC` per stdio e blockdev in tabelle statiche nel glue
code) o **6 + escape hatch generico** (jonesforth: `KEY`/`EMIT`/`SYSCALL0-3` + 7 costanti
syscall); nessun caso ha dozzine di routine. (2) *Convenzione*: o adattamento al bordo
(stack Forth → registri ABI/BIOS dentro le primitive; registri ad-hoc commentati in
sectorlisp) o contratto registri+flag documentato (Collapse OS: `HL` posizione, `A` char,
flag `Z` = errore). (3) *Heap*: nessun seed lo chiede all'OS se può evitarlo — bump + GC in
linguaggio (sectorlisp) o dizionario lineare; userland solo `brk` **una tantum all'avvio**
(jonesforth), poi crescita `HERE`; nessun `free` da nessuna parte. (4) *I/O*: minimo comune
char-at-a-time; chi ha file bufferizza l'input (jonesforth, buffer 4K) e usa seek per i
blocchi (Collapse OS); nessuno fa «leggi tutto e chiudi». (5) *Stretto vs funzionale*:
stretto = superficie minima e auditabile (bootstrappable.org) ma ogni funzione extra va
costruita in linguaggio; funzionale = kernel ignora l'hardware ma cresce il glue;
jonesforth mostra la terza via: insieme chiuso piccolo + sportello generico.

**Impatto sulle decisioni già prese (dati, non nuove decisioni).** Nessuna divergenza
strutturale con _Architettura del codegen per due piattaforme_ e _Contratto delle routine
`os_*`_: le 6 routine di `os_*` cadono nella fascia osservata; `os_alloc` una tantum =
lo schema di jonesforth; «PE muto» + exit code segue il pattern dei seed minimali (silenzio
o codici numerici/flag, mai stringhe d'errore); emissioni inline = prassi (nessun dispatch
table). **Innovazione consapevole**: `os_read` «leggi tutto e chiudi» non ha analoghi nei
casi studio — giustificata dal profilo one-shot (stato minimo: nessun handle vivo né
offset), da tenere presente in N15–N18. Limiti (mirror sr.ht anti-bot, hex0 dedotto dal
README) nel file dei findings.

## Comments
