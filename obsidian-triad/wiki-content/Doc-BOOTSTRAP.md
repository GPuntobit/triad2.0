> Copia di [`BOOTSTRAP.md`](https://github.com/GPuntobit/triad2.0/blob/main/BOOTSTRAP.md) — torna a [Documenti](Documenti) · [Home](Home)

# Triad senza linguaggi ospiti — piano di bootstrap

Stato: **fase 0** (contratto di conformità + piano). Obiettivo: Triad che non dipende da
Julia né da qualunque altro linguaggio di programmazione, in nessuna fase (runtime,
bootstrap, build).

## 0. Requisito e conseguenza

Il requisito "nessun altro linguaggio" esclude le scorciatoie ovvie:

| Scorciatoia | Perché è esclusa |
|---|---|
| Riscrivere il kernel in Rust/C/Go | introdurrebbe una dipendenza da un altro linguaggio |
| Tenere Julia come runtime dentro un binario impacchettato | è ancora Julia che esegue Triad |
| Committare un seed binario precompilato (prodotto una volta da Julia) | viola "nessun seed precompilato" |

L'unica catena coerente è:

1. il **primo eseguibile** è un interprete per un sottoinsieme di Triad (**Triad-Core**)
   scritto a mano in **codice macchina** (byte x86-64 annotati, nessun compilatore/assembler);
2. con quel seed si esegue l'**implementazione completa di Triad scritta in Triad-Core**;
3. l'implementazione completa include un **compilatore nativo scritto in Triad** che compila
   se stesso: da lì in poi il seed è ritirato e la catena è Triad → Triad.

Questo è l'unico modo per non dipendere da un altro linguaggio: un linguaggio non può
"compilarsi dal nulla", e il seed qui non è un binario ereditato ma la parte scritta a mano
in codice macchina, che resta nel repository come sorgente (dump esadecimale annotato).

## 1. Catena di bootstrap

```
S0  seed: interprete Triad-Core in codice macchina (manuale, x86-64)
     │  esegue
S1  implementazione completa di Triad scritta in Triad-Core
     │  include
S2  compilatore nativo scritto in Triad (Triad-Core + capacita' gia' disponibili)
     │  compila S1
S3  compilatore nativo self-hosted (nessun seed, nessun altro linguaggio)
     │  compila
S4  Triad completo: REPL, CLI, esempi, conformance
```

Punti fissi:
- il seed **non contiene Julia** e non è generato da Julia;
- S1/S2 sono sorgenti Triad nel repository (`selfhost/`), versionati come testo;
- il repository finale non richiede Julia, Rust o C per costruire o usare Triad.

## 2. Il seed: cosa deve fare (e quanto costa)

Il seed è un interprete per **Triad-Core**, non per tutto Triad. Deve saper leggere un
sorgente Triad-Core da file, valutarlo e stampare su stdout. Triad-Core è scelto per essere:

- **abbastanza piccolo** da stare in un interprete scritto a mano in codice macchina;
- **abbastanza espressivo** (Turing-completo) da implementarci sopra tutto Triad.

Componenti del seed:
1. lettura del file (apertura, read, chiusura) e parsing del lessico Triad-Core;
2. valutatore con ambienti e chiusure;
3. valori dinamici: Int, Bool, String, Symbol, List, Function, Nothing;
4. primitive aritmetiche/confronti, liste, stringhe, I/O byte su stdout/stderr;
5. allocatore (arena bump) e, in una fase successiva, GC mark-sweep;
6. entrypoint CLI: `seed program.td [args...]` + argomenti in `ARGS`.

**Costo**: questa è la parte critica del progetto. Un interprete del genere in codice
macchina scritto a mano è nell'ordine delle migliaia di byte/istruzioni; è un lavoro
plurisettimanale e va fatto a milestone verificabili (vedi §6). Non è comprimibile con
scorciatoie senza reintrodurre un linguaggio ospite.

## 3. Triad-Core (minimo sindacale)

Definito in modo normativo in [`SPEC-CORE.md`](https://github.com/GPuntobit/triad2.0/blob/main/SPEC-CORE.md). Sintesi:

- tipi: `Int`, `Bool`, `String`, `Symbol`, `List`, `Function`, `Nothing` (niente `Float`:
  S1 rappresenta i `Float` di Triad-Full con i tipi Core);
- forme: `x = e`, `if/elseif/else`, `while`, `let`, `begin`, `function`/lambda, `return`,
  `break`, `continue`, chiamata, ternario; niente `quote`, macro, `for`, `struct`, `try`;
- primitive: `+ - * % ^`, confronti, logica, `length`, `push!`, indicizzazione, `*` per
  stringhe, `string`, `Symbol`, `Int`, `typeof`, `print`/`println`;
- primitivi di bootstrap (solo S1, non Triad-Full): `readfile`, `strlen`, `strbyte`,
  `strsub`, `exit`;
- niente Prolog nel seed: `fact`/`rule`/`solve` sono implementati in S1 a livello Triad;
- niente eccezioni nel seed: gli errori terminano con exit code 1.

Il seed implementa **solo** Triad-Core; S1 usa Triad-Core per implementare il resto
(Prolog, dispatch, macro, contratti, effetti, budget, tracce, REPL). I casi
`conformance/core/` usano solo il sottoinsieme condiviso con Triad-Full.

## 4. Rappresentazione, memoria, generazione di codice

- Valori: word taggata a 64 bit (tag nei bit bassi), heap a blocchi con header; liste come
  vettori dinamici; stringhe come (ptr,len) immutabili.
- Ambiente: catena di frame o hash table lineare (inizialmente liste di associazioni).
- GC: inizialmente **nessun GC** (arena che cresce; i programmi di bootstrap sono brevi),
  poi mark-sweep per far girare S1 e la suite.
- Codice: x86-64. Il seed è **una funzione nativa** con codice e dati in un unico file PE
  per Windows e, in seguito, ELF per Linux. Chiamate OS isolate in 4–5 routine
  (`os_open`, `os_read`, `os_write`, `os_exit`, `os_alloc`), unico punto da riportare.
- Niente libc: su Windows si importa solo `kernel32` (ReadFile/WriteFile/GetCommandLineA/
  ExitProcess); su Linux si usano syscall dirette (`open/read/write/mmap/exit`).

## 5. Piattaforme

| Piattaforma | Stato | Motivo |
|---|---|---|
| Windows x86-64 (PE) | **prima**, testabile qui | unica piattaforma eseguibile in questo ambiente; nessun compilatore installato |
| Linux x86-64 (ELF) | in corso: **E0 ✅** (ELF minimale testato su CachyOS); E1/E2/E3 dopo | ambiente Linux disponibile (CachyOS nativo) |
| macOS/ARM | dopo | dipende dalle prime due |

La logica del seed è per la gran parte indipendente dall'OS: si cambia solo il layer
`os_*` e il formato dell'eseguibile. Il primo traguardo è Windows; il port Linux è una
milestone dedicata, non un'aggiunta a posteriori.

## 6. Milestone e criteri di accettazione

| # | Milestone | Accettazione |
|---|---|---|
| M0 | piano + conformance suite golden | `conformance/` esiste, lo stage0 Julia la passa; nessuna dipendenza finale da Julia |
| M1 | seed "hello" in codice macchina | un PE x86-64 scritto come byte nel repository stampa una riga ed esce con 0 su Windows |
| M2 | seed con I/O file/argomenti | legge il file dal primo argomento e ne scrive i byte su stdout; exit 1/2 per errori (il vettore `ARGS` completo arriva con l'interprete in M3) |
| M3 | seed = interprete Triad-Core | esegue un programma Triad-Core con funzioni, liste, stringhe, chiusure |
| M4 | S1: Triad completo in Triad-Core | esempi `examples/*.td` e conformance girano sopra seed+S1 |
| M5 | S2: compilatore nativo in Triad | compila S1; S1 compilato passa la conformance senza seed |
| M6 | self-hosting | il compilatore nativo compila se stesso (fixed point), seed ritirato |
| M7 | parità + port Linux | conformance verde su Linux ELF; CLI/REPL; docs |

## 7. Tool di sviluppo (fuori dal prodotto)

Il prodotto e la catena di bootstrap non usano altri linguaggi. Per **sviluppare e
verificare** serve però qualcosa che esegua i test mentre il seed non esiste ancora:

- lo **stage0 attuale** (kernel Julia) è usato solo come generatore una tantum dei golden
  e come riferimento di comportamento durante M0–M4; non fa parte di S0–S4;
- i golden sono file di testo committati: da M3 in poi nessun test richiede Julia;
- il runner di conformità definitivo è `triad --conformance DIR`, implementato in Triad
  (S1/M4). Fino ad allora si usa `conformance/run.jl` come strumento temporaneo;
- materializzare il seed dai byte committati usa solo strumenti di sistema (decodifica esadecimale, `certutil`/`xxd`), non compilatori o interpreti; - il runner di conformance e' `conformance/run.mjs` (Node).
- il generatore del seed (`seed/dev/gen_seed.js`, Node) è uno strumento di **sola
  manutenzione**: produce il dump, non è richiesto per costruire/usare il seed e non fa parte
  di S0–S4. È versionato perché il codice macchina altrimenti non sarebbe più estendibile
  (è già stato perso una volta e ricostruito, verificato contro l'hash).

Regola: **nessuno di questi strumenti deve essere necessario per usare Triad o per
ricostruire la catena S0→S4** quando M6 è raggiunta.

## 8. Contratto di conformità

La specifica eseguibile è `conformance/`: ogni caso è

```
conformance/cases/<nome>/
  program.td        # programma Triad
  args.txt          # opzionale: un argomento per riga
  expected.out      # stdout atteso (byte esatti, LF)
  expected.code     # exit code atteso
```

Un'implementazione passa la suite se, eseguendo `program.td` come script con `ARGS` da
`args.txt`, produce `expected.out` e `expected.code`. La suite è indipendente dal
linguaggio dell'implementazione: la eseguiranno il seed, S1 e il compilatore nativo.

I golden sono generati una tantum con lo stage0 (`conformance/run.mjs --update`) e poi committati: da quel momento sono il contratto e il runner Node basta per verificarli.

## 9. Rischi

| Rischio | Mitigazione |
|---|---|
| Scrivere a mano un interprete in codice macchina è lentissimo e fragile | Triad-Core minimale; milestone M1/M2 verificabili subito; annotazioni byte per byte; niente GC all'inizio |
| Nessun ambiente Linux per testare ELF | risolto: CachyOS su secondo disco; E0 verificato, CI Linux in arrivo |
| Divergenza tra stage0 e implementazione indipendente | conformance golden come unico contratto; oracle stage0 solo per rigenerare i golden |
| Seed troppo legato a Windows | M2 usa ancora `KERNEL32` direttamente: isolare le chiamate in routine `os_*` prima di M3/M7 |
| Aspettative sui tempi | il seed è un progetto plurisettimanale: M0-M2 sono le tappe intermedie da verificare |

## 10. Stato attuale

- [x] Requisito definito: nessun linguaggio ospite, nessun seed precompilato.
- [x] Piano S0→S4 e milestone.
- [x] `SPEC-CORE.md` — sottoinsieme Triad-Core normativo (tipi, forme, primitive,
  primitivi di bootstrap, conformità).
- [x] `conformance/` — 12 casi Full + 29 casi Core, verdi sullo stage0.
- [x] **M1** — seed "Triad seed OK" in codice macchina: Windows x86-64 PE da 1024 byte,
  `seed/windows-x86_64/`, costruito solo decodificando un dump esadecimale.
- [x] **M2** — seed con I/O: legge il file dal primo argomento e ne scrive i byte su stdout
  (blocchi da 4 KiB), exit `0`/`1`/`2`, path tra virgolette; PE da 2560 byte, nessun runtime.
- [ ] **M3** (in corso) — `SPEC-CORE.md` ✅ e `conformance/core/` ✅ pronti;
  **M3b1** ✅ interi; **M3b2a** ✅ variabili; **M3b2b1** ✅ funzioni; **M3b2b2** ✅
  confronti/ternario/ricorsione; **M3b2b3a-e** ✅ Bool, operatori, `if`, `while`, lambda;
  **M3b2b3f** ⚠️ cattura instabile. **M3b2b3g** ✅ `!`, `&&`, `||`, `+=`; **M3b2b3h** ✅ `function … end`; **M3b2b3i** ✅ corpo multi-istruzione; **M3b2b3j** ✅ frame lessicali e `let`; **M3b2b3k** ✅ chiusure; **M3b2b3l** ✅ `begin`/`end` e **CI**; **M3b2b3m** ✅ stringhe heap base; **M3b2b3n** ✅ `nothing`; **M3b2b3o/p/q** ✅ concat/simboli/coverage; **M7/E0** ✅ ELF Linux minimale. Serve AST/bytecode per cattura multi-binding, `elseif`, liste; poi E1/E2 del seed Linux.
  Prossimo: `elseif` (caso `controllo`), liste (casi `liste` e `valori`), cattura multi-binding; poi E1/E2 del seed Linux.
