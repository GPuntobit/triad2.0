# Changelog — standard Triad

Le modifiche normative aggiornano anche `VERSION`, la specifica (`SPEC.md`) e, se cambia
il comportamento, i golden di `conformance/`.

## 0.2.0 — 2026-10-20

- **Standard Triad v0.2.0**: `SPEC.md` diventa un documento normativo indipendente
  dall'implementazione (stato, normatività, profili di conformità e versionamento in §16).
- **Conformità eseguibile**: aggiunta `conformance/` con 12 casi golden (stdout + exit code)
  e un runner di sviluppo basato sullo stage0; la suite è parte dello standard.
- **AI benchmark** (strumento di sviluppo): `ai/` con prompt di sistema, 5 task Triad-Core e
  `ai/verify.jl` per generare codice con un LLM e verificarlo contro i golden.
- **Estensione canonica**: `.triad`; `.td` resta supportata come alias storico.
- **Indipendenza**: piano di bootstrap senza linguaggi ospiti in `BOOTSTRAP.md`.
- **Tooling editor**: grammatiche di sintassi per VS Code e Vim/Neovim (`editors/`) e
  preparazione della voce Linguist per il riconoscimento su GitHub
  (`editors/linguist/`).
- **Seed M1**: primo eseguibile Triad in codice macchina (PE Windows x86-64 da 1024 byte,
  `seed/windows-x86_64/`): stampa `Triad seed OK`, exit 0, nessun compilatore.
- **Seed M2**: I/O reale senza runtime — legge il file dal primo argomento della command line
  e ne scrive i byte su stdout a blocchi da 4 KiB; exit 0/1/2, path tra virgolette, PE da
  2560 byte.
- **Triad-Core**: nuovo standard di profilo [`SPEC-CORE.md`](SPEC-CORE.md) (sottoinsieme
  normativo per il bootstrap self-hosted) e suite `conformance/core/` con 29 casi condivisi
  con Triad-Full.
- **Seed M3b1/M3b2a**: il seed in codice macchina **interpreta** Triad-Core: `println` di
  espressioni intere con `+ - *`, parentesi, unario `-`, commenti (M3b1) e poi variabili
  globali con assegnamenti e lookup per nome (M3b2a). PE da 8704 byte, nessun runtime; casi
  `interi` e `variabili` della suite Core verificati byte per byte.
- **Seed M3b2b1**: il seed interpreta **funzioni in forma breve con parametri**: definizione
  `f(x, y) = expr`, chiamata, ambienti dinamici con shadowing/truncation, composizione di
  funzioni; caso Core `funzioni_semplici` verificato byte per byte. PE da 8704 byte, codice
  1998 byte, nessun runtime.
- **Seed M3b2b2**: aggiunti **confronti** (`== != < <= > >=` → `0/1`), **ternario corto**
  `c ? a : b` (il ramo non scelto viene scansito senza valutarlo) e quindi **ricorsione con
  caso base** (`fattoriale`, `fib`); caso Core `ricorsione` verificato byte per byte.
  Codice 2611 byte.
- **Seed M3b2b3a**: valori **taggati** (`Int = n<<1`, `Bool false = 1`, `Bool true = 3`):
  i confronti producono Bool e `println` stampa `true`/`false`; aritmetica e confronti
  untaggano/ri-taggano. Caso Core `confronti` verificato byte per byte; codice 2892 byte.
- **Seed M3b2b3b**: aggiunti `%` (resto con segno), `^` (destra-associata, precedenza sopra
  l'unario) e letterali `true`/`false`; caso Core `operatori` verificato byte per byte e
  semantica confrontata con lo stage0 (`-2^2=-4`, `2*3^2=18`, `2^3^2=512`). Codice 3112 byte.
- **Seed M3b2b3c**: aggiunti **blocchi `if`/`else`/`end`** con selezione del ramo, esecuzione
  ricorsiva dei blocchi e scansione a profondità per `else`/`end` (annidamento); caso Core
  `if_else` verificato byte per byte. Codice 3706 byte.
- **Seed M3b2b3d**: aggiunto **`while`/`end`** con condizione rivalutata a ogni giro e
  scansione a profondità che conta anche i `while` annidati; l'assegnamento ora **aggiorna**
  la variabile più recente (`env_assign`) invece di accodare una entry per iterazione. Caso
  Core `while_loop` verificato byte per byte. Codice 4002 byte.
- **Seed M3b2b3e**: tag a 2 bit (`Int=n<<2`, `false=1`, `true=5`, chiusura=`ptr|2`) e
  **lambda a un parametro** `x -> expr`, con record da 128 byte in un heap dedicato
  (256 KiB di `VirtualAlloc`), chiamabili anche da variabile/passate come argomento; caso
  Core `lambda` verificato byte per byte. Scoping dinamico (niente cattura dei locali).
  Codice 4415 byte.
- **Seed M3b2b3q**: verificata e coperta la concatenazione concatenata `a * b * c` con `length`; nuovo caso Core `stringhe_multi` (nessuna modifica al codice, hash invariato).
- **Seed M3b2b3p**: simboli `:nome` (oggetto stringa con il nome, stampa senza `:`) e nuovo caso Core `simboli_base` verde (codice 6866 byte).
- **Seed M3b2b3o**: concatenazione di stringhe con `*` (allocazione heap e copia dei due buffer, preservando il cursore del parser), nuovo caso Core `stringhe_concat` verde. Area IAT spostata a RVA `0x2C00` per il codice cresciuto (6680 byte); `string()` resta da fare.
- **Seed M3b2b3n**: aggiunto il valore `nothing` (oggetto statico tipo 4, stampa `nothing`); nuovo caso Core `nothing_base` verde (codice 6451 byte). Concatenazione `*` e `string()` tentate ma rimandate (non stabili); il seed resta su stringhe base + `nothing`.
- **Seed M3b2b3m**: stringhe come oggetti heap (`[tipo=1][len][byte…]`, valore `ptr|3`), parsing di letterali, stampa tramite `WriteFile`, builtin `length`; area IAT spostata a RVA `0x2A00` per far spazio al codice; nuovo caso Core `stringhe_base` verde (codice 6269 byte).`n- **Seed M3b2b3l**: aggiunto `begin … end` (eseguito con maschera di stop) e **CI GitHub Actions** (`.github/workflows/ci.yml`: conformance Full/Core su Ubuntu e Windows, casi del seed su Windows, hash check); nuovo caso Core `begin_block` verde (codice 5891 byte).`n- **Seed M3b2b3k**: **chiusure con cattura per valore** dell'ultimo binding del frame (parametro o locale), ri-aggiunta al call sopra il marker; casi Core closure e chiusure verdi; scan_end conta anche unction/let annidati (codice 5743 byte).
- **Seed M3b2b3j**: **frame lessicali** nelle chiamate (marker nell'ambiente; assegnazioni locali senza toccare i globali) e **let name = expr … end** con binding locale; caso Core scope verde (codice 5584 byte).
- **Seed M3b2b3i**: corpo delle funzioni a blocchi su **più istruzioni** (assegnamenti ed espressioni) con valore dell'ultima espressione; espressioni come statement e lock value in coda al sorgente; nuovo caso Core unzioni_blocco verde (codice 5303 byte).
- **Seed M3b2b3h**: aggiunta la forma blocco unction f(x, …) <espressione> end (corpo a una espressione, end individuato da scan_end); il caso Core unzioni passa byte per byte (codice 5097 byte).
- **Seed M3b2b3g**: aggiunti !, &&/|| (bitwise sui tag Bool) e +=; il caso Core ritmetica passa byte per byte (codice 4763 byte).
- **Seed M3b2b3f (tentativo, instabile)**: aggiunti campi cattura al record chiusura; il
  binding al call non è risultato affidabile ed è stato rimosso. Il seed resta allo stato
  lambda stabile (codice 4570 byte); il caso `closure` passa solo sullo stage0. Cattura
  rimandata ad AST/bytecode o frame catturati.
- **Seed dev tooling**: generatore di sviluppo del PE in `seed/dev/gen_seed.js` con README;
  il dump resta la fonte, la riproducibilità è verificata dall'hash
  `C7915C02…0BF75FAC` e il generatore non è usato dalla catena S0→S4.
- Prima bozza del sottoinsieme **Triad-Core** richiesto dal seed in codice macchina.

## 0.1.0 — iniziale

- Kernel S-expression `legacy/triad_sexpr_v1.jl` (storico).
