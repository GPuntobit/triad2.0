# Capitolo 18 — Anatomia del progetto e contratto di conformità

La parte quarta porta il lettore dentro il repository. Questo capitolo ne disegna la mappa e
spiega il pezzo che tiene insieme tutto il resto: la suite di conformità.

## 18.1 La mappa

Il repository `triad2.0` si legge a strati.

- **Lo standard**: `SPEC.md`, `SPEC-CORE.md`, `VERSION`, `CHANGELOG.md`. Definiscono il
  linguaggio.
- **Il contratto**: `conformance/`, con i casi Full (`cases/`) e Core (`core/cases/`) e il runner
  `run.mjs`.
- **Le implementazioni**: il seed in codice macchina (`seed/windows-x86_64/`,
  `seed/linux-x86_64/`), l'interprete di riferimento (`seed/dev/triad_core.cjs`) e i prototipi
  self-hosted (`selfhost/`).
- **Gli strumenti**: i generatori del seed (`seed/dev/`), la CLI di sviluppo (`cli/`), i launcher
  (`bin/`), il benchmark AI (`ai/`), le grammatiche per editor (`editors/`), il sito (`docs/`).
- **Il piano**: `BOOTSTRAP.md`, `STATUS.md`, `TASK.md`, `plan.md`.

Due convenzioni valgono ovunque: la documentazione è in italiano, e i file hanno fine riga LF
(tranne gli script `.cmd` di Windows, in CRLF), come impone `.gitattributes`.

## 18.2 Che cos'è un caso di conformità

Un caso è una cartella con un programma e il suo comportamento atteso:

```
conformance/core/cases/gcd/
  program.td       il programma
  expected.out     lo standard output atteso, byte per byte
  expected.golden  copia di expected.out
  expected.code    il codice di uscita atteso
  args.txt         (facoltativo) un argomento per riga
```

Un'implementazione passa il caso se, eseguendo `program.td` con gli argomenti di `args.txt`,
produce esattamente `expected.out` sullo standard output ed esce con `expected.code`. Lo standard
error non conta; l'input interattivo non è ammesso, perché la suite deve essere deterministica.

> **Perché byte per byte?** Perché è l'unico criterio che non lascia spazio a interpretazioni.
> Uno spazio in più, un a capo mancante, un simbolo stampato con o senza i due punti: tutto
> conta. È severo, ma rende confrontabili implementazioni scritte in linguaggi diversissimi, dal
> codice macchina a Triad stesso.

## 18.3 Il runner

`conformance/run.mjs` esegue tutti i casi di una cartella e stampa `PASS` o `FAIL` per ciascuno:

```sh
node conformance/run.mjs                              # profilo Core
node conformance/run.mjs --cases conformance/cases    # profilo Full
node conformance/run.mjs --skip liste,valori          # salta alcuni casi
```

Sceglie da solo il runtime: la variabile d'ambiente `TRIAD_SEED` se impostata, altrimenti
l'interprete di riferimento su Linux e macOS, il seed su Windows. Un messaggio
`golden mancante` significa che nel checkout manca `expected.out` (il `.gitignore` esclude i file
`*.out`, con un'eccezione per quelli della conformità): di solito basta un `git pull`.

L'opzione `--update` **rigenera** i golden dall'output del runtime corrente. È uno strumento da
maneggiare con cura: se il runtime ha un bug, `--update` lo trasforma in comportamento ufficiale.
I golden Full, prodotti a suo tempo dall'implementazione Julia, sono congelati e non vanno
rigenerati finché non esisterà un'implementazione Full.

## 18.4 Scrivere un nuovo caso

1. Scegli un aspetto del linguaggio da fissare e un nome descrittivo, in italiano.
2. Scrivi `program.td` usando solo Core, senza primitivi di bootstrap: il caso deve valere anche
   per Full.
3. Scrivi a mano `expected.out` ragionando sulla specifica, non copiando l'output di un
   interprete; poi `expected.golden` (copia) ed `expected.code`.
4. Verifica con `node conformance/run.mjs`.
5. Se il caso passa anche sul seed Windows, aggiungilo all'elenco del job `seed-windows` in
   `.github/workflows/ci.yml`.

L'appendice [Catalogo conformance Core](Catalogo-conformance-Core) mostra tutti i casi esistenti:
sono il modello migliore da imitare.

## Riepilogo

- Il repository si divide in standard, contratto, implementazioni, strumenti e piano.
- Un caso di conformità fissa stdout e codice di uscita di un programma, byte per byte.
- `run.mjs` esegue la suite; `--update` va usato con prudenza.
- I nuovi casi si scrivono a mano, a partire dalla specifica.
<!-- nav -->

---

← [Capitolo 17 — Garanzie, costrutti Full e interfaccia](Libro-17-Garanzie-e-interfaccia) · [Sommario](Home) · [Capitolo 19 — L'interprete di riferimento](Libro-19-Interprete-di-riferimento) →
