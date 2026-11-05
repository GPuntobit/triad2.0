# 10 — Findings: punto fisso e root del bootstrap in catene self-hosted note

Ricerca per [10 — Ricerca: punto fisso e root del bootstrap in catene self-hosted note](../issues/10-ricerca-punto-fisso-root.md).
Fatti, non decisioni: servono a [08 — Certificazione del punto fisso: meccanica e CI](../issues/08-certificazione-punto-fisso-ci.md)
e a [04 — Linguaggio sorgente del compilatore S2](../issues/04-linguaggio-sorgente-s2.md).
Fonti primarie citate per ogni claim; consultazione web 2026-11-05. Dove la fonte primaria
raggiungibile è un mirror, è dichiarato (vedi «Limiti»).

## 0. Tabella riassuntiva

| Catena | Root (stadio 0) | Certificazione fixed point | Anti-drift |
|---|---|---|---|
| GCC | compilatore di sistema (esterno) | **stage2 vs stage3**, gate di build | `make bootstrap` obbligatorio in release; `bootstrap4` |
| OCaml | `boot/` committato (bytecode) | **byte** (`tools/cmpbyt`) dopo `stripdebug` | messaggio «Fixpoint reached/Not reached»; commit policy |
| Nim | `csources_v2` committato (C generati) | **byte** (`sameFileContent`) su 3 iterazioni | check, ma non fatale (warning) fuori da Windows |
| Chez Scheme | `boot/` committato (boot file per macchina + `boot/pb`) | **FASL-equal** (`#%$fasl-file-equal?`) iterato | `look-for-fixpoint`, errore se non converge |
| Rust | beta scaricato, pinnato in `src/stage0` | «same-result test» **stage3, opzionale** | stage0 pinnato; nessun gate di identità |
| Go | Go esterno (`GOROOT_BOOTSTRAP`); root storica Go 1.4 (C) | **nessuno documentato** | test suite; self-hosting da Go 1.5 |
| CHICKEN | `chicken` installato / snapshot tarball | **nessuno documentato** | `boot-chicken`, `scripts/bootstrap.sh` |
| Collapse OS | `zasm` emulato (fuori dalla macchina target) | **nessuno**: criterio funzionale («Replicate itself») | auto-contenimento del repo |
| jonesforth | GNU `as` (esterno) | **nessuno** (bootstrap a stadio singolo) | — |

## 1. Il fixed point: bit-identico o semantico?

### GCC — l'unico gate di identità obbligatorio per build

- In una build nativa il default è un **3-stage bootstrap** e il passo è esplicito:
  «Perform a **comparison test of the stage2 and stage3 compilers**». Il bootstrap serve a
  «ensure that it compiles itself correctly» e il confronto è parte del `make` standard. [S1]
- Se il compilatore di sistema miscompila lo stage1, la documentazione prescrive di
  aumentare gli stadi: «you may need to work around this … by using `make bootstrap4` to
  increase the number of stages of bootstrap». [S1]
- Quindi: il fixed point è certificato **per build, come identità di artefatti** (il
  «comparison test»), non solo semantico. Il dettaglio di *cosa* il confronto escluda
  (timestamp, debug) non è verificato qui (vedi «Limiti»). [S1]

### OCaml — identità byte dopo normalizzazione del debug

- Il ciclo `coreboot` termina con `make compare`: si rimuove il debug dagli artefatti
  (`tools/stripdebug -all` su `ocamlc` e `ocamllex`), poi si confrontano **byte a byte**
  con `tools/cmpbyt` contro i binari di `boot/`: «**Fixpoint reached, bootstrap succeeded.**»
  oppure «**Fixpoint not reached, try one more bootstrapping cycle.**» con `exit 1`. [S5]
- Normalizzazione deliberata: il commento del Makefile dice «The core system has to be
  rebuilt after bootstrap anyway, so strip ocamlc and ocamllex, which means the artefacts
  should be identical»: l'identità è byte-exatta **dopo** la rimozione del debug. [S5]
- Anti-drift procedurale: i cambi che richiedono bootstrap vanno fatti con `make bootstrap`
  e, in upstream, «indicate in the message of the commit that the changes need a bootstrap.
  Perform the bootstrap and **commit the result of the bootstrap separately, after that
  commit**»: il root aggiornato è un commit dedicato e tracciabile. [S6]

### Nim — identità byte «tranne i timestamp», con check non fatale

- `koch boot` documenta 3 stadi: csources → `nim1` («buggy but rock solid for building a
  Nim compiler»), `nim1` → `nim2` («the one you really need»), `nim2` → `nim3`;
  «`nim3.exe` is equal to `nim2.exe` **except for timestamps**. This step ensures a minimum
  amount of quality». [S8]
- Il confronto reale è `sameFileContent` fra le versioni successive: a parità stampa
  «executables are equal: SUCCESS!»; in caso contrario, su non-Windows l'esito è solo
  «[Warning] executables are still not equal»: **il check di fixed point non fallisce la
  build**. [S8]
- La variante `bootic` (compilatore incrementale) mantiene esplicitamente «The 3-step
  fixed-point check … reproduces a stable binary». [S8]

### Chez Scheme — identità dei boot file (FASL), con loop di convergenza

- Il `make` standard bootstra le sorgenti Scheme: «If the new boot files are **equivalent**
  to the old boot files, the system is bootstrapped. Otherwise, the new boot files are used
  to create a newer set, and those are compared. If this succeeds, the system is
  bootstrapped. Otherwise, the **make fails**». [S11]
- Il meccanismo è `look-for-fixpoint` in `s/build.zuo`: ricostruisce, poi verifica con il
  primitive interno `#%$fasl-file-equal?` che i nuovi `petite.boot`/`scheme.boot` siano
  equivalenti ai vecchi; altrimenti itera; dopo `n` tentativi: «**failed to arrive at a
  fixpoint**». [S12]
- Nota: il confronto è sui **boot file compilati** (FASL del compilatore), non
  sull'eseguibile `scheme` (che contiene anche il kernel C). [S11][S12]

### Rust — fixed point solo come test opzionale

- «**Stage 3: the same-result test**. Stage 3 is optional. To sanity check our new compiler,
  we can build the libraries with the `stage2` compiler. The result **ought to** be
  identical to before, unless something has broken». [S2]
- Lo stadio distribuito è lo stage2 («The `stage2` compiler is the one distributed with
  `rustup`»); non risulta alcun gate di identità byte fra stage2 e stage3. [S2]

### Go, CHICKEN, Collapse OS, jonesforth — nessun confronto di fixed point documentato

- **Go**: la documentazione d'installazione descrive solo la catena (toolchain di bootstrap
  → `make.bash`); nessun confronto stage2/stage3 documentato. La root Go 1.4 è «the last
  distribution in which the toolchain was written in C». [S4]
- **CHICKEN**: il bootstrap serve a «generate the compiled C files from the Scheme library
  sources»; nessun confronto di fixed point nel README. [S10]
- **Collapse OS**: il criterio è funzionale — il progetto deve «**Replicate itself**» ed
  essere auto-contenuto («build and install Collapse OS without external resources»);
  nessuna certificazione byte. [S14] L'implementazione Forth «achieves self-hosting» come
  l'incarnazione assembler precedente. [S15]
- **jonesforth**: bootstrap a stadio singolo — `jonesforth.S` è assemblato da GNU `as`
  (esterno); il file `jonesforth.f` contiene solo «the outline of a **simple assembler**»
  in Forth. Nessuno stadio successivo da confrontare. [S16][S17]

### Regolarità osservata

Chi certifica l'identità **normalizza prima il non-determinismo** (OCaml rimuove il debug;
Nim ammette «except for timestamps») **o confronta artefatti intermedi compilati** invece
dell'eseguibile finale (Chez: boot file FASL; GCC: artefatti di stage2/stage3). **Nessuno
dei casi studiati certifica un eseguibile finale byte-identico senza normalizzazione.**

## 2. Root del bootstrap: dove vive lo stadio 0

### Committata nel repository (artefatti *compilati* della generazione precedente)

- **OCaml**: «previously-compiled bytecode versions of the compiler and lexer are included
  in the repository under the `boot/` directory. These bytecode images are used once the
  bytecode runtime (which is written in C) has been built»; `boot/` contiene anche i `.cm*`
  dello stdlib. [S7] Il root si aggiorna solo con `make promote`/bootstrap dedicati. [S5][S6]
- **Chez**: boot file committati per tipo di macchina (`petite.boot`, `scheme.boot`,
  `equates.h`, `scheme.h`) più un set **portable** in `boot/pb` «used to bootstrap the
  compiler». [S11] Il repository conserva anche i boot file delle versioni vecchie («Clone
  this repo with `--filter=blob:none` to avoid eagerly downloading **large boot files for
  older versions**»): il root è storico versionato. [S13]
- **Nim**: il root è un repository separato `csources_v2` contenente **sorgenti C
  generate** («CSources compiled from Nim version 2. Based on
  https://github.com/nim-lang/Nim/commit/7f6681b4…»): compilabili da un qualsiasi
  compilatore C, e pinnate a un commit Nim preciso. [S9]

### Esterna ma pinnata/documentata

- **Rust**: lo stage0 è «the very recent *beta* `rustc` compiler … which bootstrap will
  **download** for you» [S2]; la configurazione (server di download, versione) è
  **committata** in `src/stage0` (`dist_server=https://static.rust-lang.org`, …). [S3]
- **Go**: qualsiasi Go recente come `GOROOT_BOOTSTRAP`; la root storica autocertificata è
  **Go 1.4**, disponibile come branch `release-branch.go1.4` oppure tarball
  `go1.4-bootstrap-20171003.tar.gz` («Go 1.4 source code plus accumulated fixes»); su
  sistemi dove Go 1.4 non gira serve un'altra via (binario, `bootstrap.bash` cross,
  gccgo). [S4]
- **CHICKEN**: da git serve «a `chicken` executable to generate the compiled C files»,
  idealmente dallo snapshot di sviluppo più vicino; `make CHICKEN=… boot-chicken` produce
  un binario statico di boot; `scripts/bootstrap.sh` automatizza scaricando lo snapshot. [S10]
- **GCC**: root = compilatore di sistema qualsiasi (il gate stage2/stage3 non ha bisogno
  di fidarsi di esso). [S1]
- **jonesforth**: root = GNU `as` (assembler esterno). [S16]
- **Collapse OS**: su macchina non-Collapse-OS serve «emulated zasm, which is necessary to
  build Collapse OS from a non-Collapse OS machine» (in `tools/`); sulla macchina target la
  root è il kernel già replicato. [S14]

## 3. Criteri per dichiarare lo stadio 0 «ritirato»

- **Nessuno dei casi studiati ritira la root.** Due forme ricorrenti:
  1. **root congelata e versionata** (OCaml `boot/`, Chez `boot/`, Nim `csources_v2`):
     aggiornata solo da procedure esplicithe di re-bootstrap con commit dedicati [S6];
  2. **root esterna pinnata** (Rust `src/stage0`, Go 1.4/`GOROOT_BOOTSTRAP`, CHICKEN
     snapshot): documentata come prerequisito permanente. [S2][S3][S4][S10]
- Dove il fixed point è certificato **per build** (GCC, OCaml, Chez, Nim), la root non
  serve alla *fiducia* nel binario corrente — serve solo per **partire**; la certificazione
  è il meccanismo anti-drift. Dove non lo è (Go, Rust, Chicken), la root **resta nella
  catena di trust**.
- L'unico criterio de-facto di «self-hosting raggiunto» osservato è: *il toolchain si
  ricompila da sé usando la generazione precedente solo come compilatore*, con un gate di
  identità (dove esiste) come certificato. Nessun caso definisce una «rottamazione» dello
  stadio 0 con criteri espliciti; il caso Go è il più vicino: la root Go 1.4 serve solo
  dove non esiste alcun binario Go recente. [S4]

## 4. Fatti rilevanti per i ticket che attendono questa ricerca

- Per [08](../issues/08-certificazione-punto-fisso-ci.md): la definizione di punto fisso di
  questa mappa («binario **identico byte-a-byte al proprio**») è **più forte** di ogni caso
  studiato: chi certifica identità normalizza non-determinismo (debug OCaml, timestamp Nim)
  o confronta artefatti intermedi (FASL Chez, oggetti GCC). Il meccanismo di confronto per
  Triad va scelto sapendo che non ha precedenti diretti; il vantaggio è che la regola 5
  (determinismo) e la politica dei byte del PE già impongono l'assenza di timestamp/debug
  nei binari.
- Per [04](../issues/04-linguaggio-sorgente-s2.md): il pattern «3 stadi con confronto fra
  stadio 2 e 3» è il più diffuso (GCC, Nim, OCaml, Chez, Rust); la sorgente del compilatore
  in tutti i casi sta nel dominio che lo stadio precedente sa eseguire, e la root è o
  artefatti compilati della generazione precedente (bytecode/C) o un binario esterno
  pinnato.
- Per il «seed ritirato» della destinazione: nessun precedente diretto; la meccanica più
  vicina è *root congelata + fixed point certificato a ogni ricostruzione*, dove il root
  diventa necessario solo per ripartire dalle sorgenti, non per la catena d'uso.

## Limiti

- **GCC**: verificata la documentazione ufficiale (`build.html`); non verificato nel
  sorgente cosa il «comparison test» escluda esattamente (timestamp, debug) né lo script
  `contrib/compare`.
- **Clang/LLVM**: non risulta alcun gate stage2/stage3 nella documentazione primaria
  consultata (`llvm/docs/TestingGuide.md`: nessun match per `bootstrap`/`self-host`); il
  self-hosting è esercitato da CI dedicata — **ricerca non conclusiva** su questo punto.
- **CHICKEN**: il README del progetto è stato letto su un **mirror** dichiarato
  (`kdltr/chicken-core`, «Mirror of the CHICKEN Scheme compiler (from code.call-cc.org)»);
  il repository ufficiale non era raggiungibile direttamente.
- **jonesforth**: letto su mirror (`nornagon/jonesforth`, «Mirror of JONESFORTH»);
  l'originale di Richard WM Jones è su git.annexia.org (non verificato).
- **Collapse OS**: README da mirror (`rdacomp/CollapseOS`); i claim sul self-hosting
  provengono dal sito primario collapseos.org.

## Fonti

- [S1] GCC, *Installing GCC — Building a native compiler* (3-stage bootstrap, «comparison
  test of the stage2 and stage3 compilers», `bootstrap4`):
  https://gcc.gnu.org/install/build.html
- [S2] rustc-dev-guide, *What Bootstrapping does* (stadi 0–3, «Stage 3: the same-result
  test», stage0 scaricato):
  https://github.com/rust-lang/rustc-dev-guide/blob/master/src/building/bootstrapping/what-bootstrapping-does.md
- [S3] rust-lang/rust, `src/stage0` (configurazione pinnata dello stage0):
  https://github.com/rust-lang/rust/blob/master/src/stage0
- [S4] Go, *Installing Go from source* (`GOROOT_BOOTSTRAP`, Go 1.4 ultimo toolchain in C,
  `release-branch.go1.4`, `go1.4-bootstrap-20171003.tar.gz`, `bootstrap.bash`):
  https://go.dev/doc/install/source
- [S5] ocaml/ocaml, `Makefile` (trunk: `coreboot`, `compare` con `tools/cmpbyt` +
  `tools/stripdebug`, «Fixpoint reached, bootstrap succeeded.», `promote`, `bootstrap`):
  https://github.com/ocaml/ocaml/blob/trunk/Makefile
- [S6] ocaml/ocaml, `BOOTSTRAP.adoc` (procedura di re-bootstrap; politica dei commit):
  https://github.com/ocaml/ocaml/blob/trunk/BOOTSTRAP.adoc
- [S7] ocaml/ocaml, `HACKING.adoc` («previously-compiled bytecode versions … included in
  the repository under the `boot/` directory»):
  https://github.com/ocaml/ocaml/blob/trunk/HACKING.adoc
- [S8] nim-lang/Nim, `koch.nim` (devel: `boot` a 3 passi, «equal … except for timestamps»,
  `sameFileContent`, «executables are equal: SUCCESS!», warning non fatale):
  https://github.com/nim-lang/Nim/blob/devel/koch.nim
- [S9] nim-lang/csources_v2, `README.md` (C generati, pinnati al commit Nim 7f6681b4…):
  https://github.com/nim-lang/csources_v2
- [S10] CHICKEN, `README` (mirror `kdltr/chicken-core`): sezioni 2.2 (*Building from Git*)
  e 6 (*Bootstrapping*: `boot-chicken`, `scripts/bootstrap.sh`):
  https://github.com/kdltr/chicken-core/blob/master/README
- [S11] Chez Scheme, `BUILDING` (`boot/pb`, «If the new boot files are equivalent to the
  old boot files, the system is bootstrapped», `make re.boot`):
  https://github.com/cisco/ChezScheme/blob/main/BUILDING
- [S12] Chez Scheme, `s/build.zuo` (`look-for-fixpoint`, `#%$fasl-file-equal?`, «failed to
  arrive at a fixpoint»):
  https://github.com/cisco/ChezScheme/blob/main/s/build.zuo
- [S13] Chez Scheme, `README` (boot file delle versioni vecchie nel repo; `--filter=blob:none`):
  https://github.com/cisco/ChezScheme/blob/main/README.md
- [S14] Collapse OS, `README.md` (mirror `rdacomp/CollapseOS`; obiettivi «Replicate
  itself», auto-contenimento; `tools/` con zasm emulato):
  https://github.com/rdacomp/CollapseOS/blob/master/README.md
- [S15] Collapse OS, *Why Forth?* («achieves self-hosting», prima incarnazione in Z80
  assembler): http://collapseos.org/forth.html
- [S16] JONESFORTH, `README` (mirror `nornagon/jonesforth`; originale di Richard WM Jones):
  https://github.com/nornagon/jonesforth/blob/master/README
- [S17] JONESFORTH, `jonesforth.f` («the outline of a simple assembler» in Forth):
  https://github.com/nornagon/jonesforth/blob/master/jonesforth.f
