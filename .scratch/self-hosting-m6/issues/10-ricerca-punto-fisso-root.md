# 10 — Ricerca: punto fisso e root del bootstrap in catene self-hosted note

Type: research
Status: resolved

## Question

Fatti che una decisione attende: come certificano il punto fisso catene self-hosted note
(Chez Scheme, Chicken, Nim, OCaml, Go, Rust, GCC/Clang stageN; per gli estremi minimali,
Collapse OS e jonesforth)?

- il fixed point è certificato **bit-identico** (stage2 == stage3) o solo semantico? Con
  quali meccanismi di anti-drift?
- come gestiscono la **root del bootstrap**: seed/binari di stadio 0 mantenuti nel repo,
  committati, ricostruiti?
- quali criteri usano per dichiarare lo stadio 0 «ritirato»?

Servono a *Certificazione del punto fisso: meccanica e CI* e a *Linguaggio sorgente del
compilatore S2*. Findings attesi su branch `research/10-punto-fisso`.

## Answer

Findings completi con fonti primarie in
[`../research/10-punto-fisso.md`](../research/10-punto-fisso.md) (branch
`research/10-punto-fisso`). Sintesi:

- **Fixed point bit-identico**: certificato solo da GCC («comparison test of the stage2 and
  stage3 compilers», gate di build), OCaml (`tools/cmpbyt` byte-a-byte dopo `stripdebug`,
  «Fixpoint reached/Not reached»), Nim (`sameFileContent` su 3 iterazioni, ma «except for
  timestamps» e non fatale fuori da Windows) e Chez (`#%$fasl-file-equal?` sui boot file,
  `look-for-fixpoint`). Rust: solo stage3 «same-result test» opzionale; Go, CHICKEN,
  Collapse OS, jonesforth: nessun confronto documentato. **Nessun caso certifica l'eseguibile
  finale byte-identico senza normalizzazione** (debug OCaml, timestamp Nim; chi certifica
  l'identità o normalizza o confronta artefatti intermedi). La definizione di punto fisso di
  questa mappa è quindi più forte di ogni precedente.
- **Root del bootstrap**: o **committata** come artefatti compilati della generazione
  precedente (OCaml `boot/` bytecode, Chez `boot/` + `boot/pb`, Nim `csources_v2` C generati
  pinnati a un commit), o **esterna pinnata** (Rust beta in `src/stage0`, Go 1.4 / Go recente
  via `GOROOT_BOOTSTRAP`, CHICKEN snapshot, GCC compilatore di sistema, GNU `as`, zasm
  emulato).
- **Ritiro dello stadio 0**: nessuno dei casi studiati lo ritira; root congelata con
  re-bootstrap in commit dedicati (OCaml) o prerequisito permanente pinnato. Dove il fixed
  point è certificato per build la root serve solo per *partire*, non per la *fiducia*; dove
  non lo è, resta nella catena di trust. Nessun criterio di «rottamazione» esplicito.
- Clang/LLVM: nessun gate stage2/stage3 trovato nella documentazione primaria (ricerca non
  conclusiva). Limiti e mirror usati elencati nei findings.

## Comments

## Riferimenti

- Servono a: [08 — Certificazione del punto fisso: meccanica e CI](08-certificazione-punto-fisso-ci.md), [04 — Linguaggio sorgente del compilatore S2](04-linguaggio-sorgente-s2.md).
