# 02 — Architettura del codegen per due piattaforme

Type: grilling
Status: resolved
Blocked by: 01

## Question

Oggi `seed/dev/gen_seed.js` genera il PE mescolando il corpo dell'interprete e le chiamate
KERNEL32; `seed/dev/gen_seed_linux.js` contiene solo lo stub E0. Come si organizza il
codegen per sostenere due piattaforme senza duplicare l'interprete?

- (a) **Un generatore, due backend `os_*`**: il codegen del corpo è condiviso, due
  emettitori proprietari di formato/sistema (PE + KERNEL32, ELF + syscall) — coerente con
  `BOOTSTRAP.md` §4.
- (b) **Due generatori paralleli** che condividono il corpo dell'interprete in qualche
  forma strutturata (macro/concatenazione), ciascuno proprietario del proprio formato.

Sotto-domanda della stessa sessione: dove vivono header ELF/PE, i fixup e le costanti di
syscall. La decisione è vincolata da [01 — Politica dei byte del PE nella
rifattorizzazione](01-byte-pe.md); input utile ma non bloccante:
[05 — Ricerca: come altri seed scritti a mano isolano il confine OS](05-ricerca-confine-os.md).

## Answer

**Decisione 2026-11-04 (sessione wayfinder): architettura (a) — un generatore, core del
codegen condiviso, due backend di piattaforma.** Confermata dal maintainer in tre round di
grilling (Q1–Q3, Q4–Q6, Q7–Q8); nessuna eccezione di layout concessa.

- **Organizzazione (Q1):** (a). Una sola fonte di verità per il corpo dell'interprete (il
  *Core del codegen*): l'emettitore di istruzioni e il codegen del corpo sono condivisi;
  ogni *Backend di piattaforma* possiede formato dell'eseguibile (PE/ELF), fixup e
  costanti di sistema (indici IAT, numeri syscall). L'opzione (b) — due generatori con
  corpo condiviso «strutturato» — è scartata: è duplicazione mascherata o un
  meta-linguaggio da inventare, e la Riproducibilità del dump vuole una sola fonte.
- **Condivisione (Q2):** a livello di **sorgente** — le stesse funzioni JS del core emettono
  il corpo per entrambi i target — con la sola garanzia di *Parità byte-a-byte* (stdout
  identico). Nessuna identità byte del corpo fra PE ed ELF: ogni artefatto resta soggetto
  per-conto-proprio a *Immutabilità del PE* / *Riproducibilità del dump*.
- **Forma di `os_*` (Q3):** emissioni **inline** da funzioni del generatore, forma canonica
  definitiva su entrambe le piattaforme — mai sottoroutine machine-code (`call`). Così
  l'architettura non richiede alcun cambio di layout del PE e la politica di
  [01 — Politica dei byte del PE nella rifattorizzazione](01-byte-pe.md) resta intatta:
  **nessuna eccezione è concessa oggi**; una futura richiesta del genere torna qui come
  decisione esplicita. L'ambiguità «routines» di `BOOTSTRAP.md` §4 è sanata esplicitamente
  (regola operativa 1: nessuna semantica inventata) — vedi *Effetti*.
- **Confine (Q7/Q4):** `os_*` è il confine **completo** fra core e backend: il corpo
  condiviso contiene l'intero flusso del programma (acquisizione argomento, apertura e
  lettura del sorgente, stampa, uscita), e dentro le primitive sta tutto ciò che tocca
  l'OS: parsing di `GetCommandLineA` vs copia da `argv[1]` (es. `os_arg`), ciclo di vita
  dell'handle, handle stdout (oggi cachato in `r12`). Non esistono prologhi
  piattaforma-dipendenti fuori da `os_*`. Conseguenze accettate: (1) la lista reale cresce
  oltre le «4–5 routine» ed è decisa nel contratto
  [03 — Contratto delle routine `os_*`](03-contratto-os-star.md), non qui; (2) l'ordine di
  emissione del corpo resta **congelato a quello di oggi** dall'Immutabilità del PE —
  anche l'ELF eredita quell'ordine (nessun effetto su stdout; i limiti noti restano
  limiti); (3) le convenzioni di registro che legano corpo e primitive entrano nel
  contratto `os_*`.
- **Memory map (Q5/Q4-r2):** **identica su entrambe le piattaforme**. Gli offset
  r14-relativi del corpo (sorgente `0..0x10000`, ambiente `+0x10000`, tabella funzioni
  `+0x20000`, heap chiusure `+0x30000`, slot `0xF000` maschera, `0xF008` flag, `0xF010`
  blocco, `0xF028` print mode, `0xF02C` break, regione `0x40000`) diventano costanti
  condivise del core; piattaforma-dipendente è solo l'ottenimento della base r14
  (`VirtualAlloc` vs `mmap`, cioè `os_alloc`). Divergere non ha benefici e rende la parità
  più difficile da dimostrare.
- **Entry point (Q8/Q6):** **unico** `seed/dev/gen_seed.js <windows|linux|all> [out.hex]`
  (posizionale, allineato ai sottocomandi CLI), path di default canonici
  (`seed/<piattaforma>-x86_64/seed.hex`), formato hex invariato (16 byte/riga,
  `xxd`-compatibile). Il target `all` rigenera entrambi i dump in un colpo solo — un solo
  comando di CI prova la Riproducibilità del dump di tutti e due gli artefatti. La CLI
  resta `triad seed generate windows|linux` come interfaccia pubblica (`all` opzionale):
  `cli/lib/commands/seed.mjs` diventa wrapper sottile dell'entry unico. I due script
  attuali (`gen_seed.js`, `gen_seed_linux.js`) confluiscono nell'entry unico + moduli
  (`core` + `backend_pe` + `backend_elf`, CommonJS come oggi).
- **Effetti:** `BOOTSTRAP.md` §4 sanato («routines» = funzioni del generatore con emissione
  inline; confine completo; lista dal contratto `os_*`); `TASK.md` N16/N17 allineati (non
  più «4–5 routine», non più `gen_seed_linux.js` come emettitore separato). Sblocca
  [03 — Contratto delle routine `os_*`](03-contratto-os-star.md) (prototype: firme, lista,
  stato comune a valle del prologo); gli input [05 — Ricerca: come altri seed scritti a
  mano isolano il confine OS](05-ricerca-confine-os.md) e
  [06 — Ricerca: strumenti garantiti per la decodifica di `seed.hex`](06-ricerca-decoder.md)
  restano utili, non bloccanti. Glossario: voci *Core del codegen*, *Backend di
  piattaforma*, *`os_*`*.

## Comments
