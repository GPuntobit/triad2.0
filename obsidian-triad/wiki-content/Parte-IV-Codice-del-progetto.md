<a id="parte-4"></a>

# Parte IV — Il codice del progetto

Questa parte spiega come è fatto il repository e come si scrive (o si modifica) ogni tipo di
codice che contiene.

<a id="cap-33"></a>

## 33. Mappa del repository

| percorso | linguaggio | cosa contiene |
|---|---|---|
| `SPEC.md`, `SPEC-CORE.md`, `VERSION`, `CHANGELOG.md` | Markdown | lo standard (Full e Core), versione, storia |
| `BOOTSTRAP.md`, `STATUS.md`, `TASK.md`, `plan.md` | Markdown | piano S0→S4, stato, backlog e task |
| `conformance/` | Triad + Node | casi golden (`cases/` Full, `core/cases/` Core) e runner `run.mjs` |
| `seed/windows-x86_64/` | codice macchina | `seed.hex` (sorgente), `seed.exe` (decodificato), README con layout |
| `seed/linux-x86_64/` | codice macchina | seed ELF E0 (`seed.hex`, `seed`) |
| `seed/dev/` | Node.js | generatori del seed (`gen_seed.js`, `gen_seed_linux.js`) e interprete di riferimento `triad_core.cjs` |
| `selfhost/` | Triad-Core | S1: interprete Triad scritto in Triad-Core (in corso) |
| `examples/` | Triad-Full | programmi di esempio dello standard |
| `cli/` | Node.js (ESM) | `triad-cli`: CLI di sviluppo (commander, execa, chalk) |
| `bin/` | sh / cmd | launcher `triad`, `triad.cmd`, `triad-cli`, `triad-cli.cmd` |
| `ai/` | Triad + Node | benchmark di generazione codice per LLM, prompt, task con golden |
| `editors/` | JSON / Vim script | grammatica VS Code (TextMate), sintassi Vim, voce Linguist |
| `docs/` | HTML/CSS/JS | sito GitHub Pages; carica i Markdown del repo (questa wiki compresa) |
| `obsidian-triad/` | Markdown | vault Obsidian con indice dei file e grafo del progetto |
| `.github/workflows/` | YAML | CI (`ci.yml`) e pubblicazione del sito (`pages.yml`, `static.yml`) |
| `test_*.td`, `min_*.td` (root) | Triad-Core | piccoli probe usati durante lo sviluppo del seed (es. `test_get.td` in CI) |

Convenzioni comuni:
- documentazione, commenti e messaggi sono in **italiano**;
- fine riga **LF** ovunque, tranne `*.cmd` (CRLF), imposto da `.gitattributes`;
- `.gitignore` esclude `*.out` con l'eccezione `!conformance/**/expected.out`.

---

<a id="cap-34"></a>

## 34. L'interprete di riferimento JS (`seed/dev/triad_core.cjs`)

È un interprete Triad-Core completo in un solo file CommonJS (~1000 righe, nessuna dipendenza).
È lo strumento con cui si verifica la conformance Core su Linux/macOS ed è il modo più rapido
per capire la semantica di Core leggendo codice.

### 34.1 Architettura

```
sorgente ──tokenize()──▶ token ──Parser──▶ AST {kind: …} ──evalStmt/evalExpr──▶ effetti su stdout
```

1. **Valori** (in cima al file): oggetti `{t, v}` costruiti da `I` (Int, `BigInt` con
   `wrap()` a 64 bit), `B`, `S`, `Y` (Symbol), `L` (List), `F` (funzione: `params`, `body`,
   `env`, `isLambda`) e la costante `NOTHING`. I builtin sono `{t:'builtin', name}`.
2. **`tokenize(src)`**: produce token `SEP` (a capo o `;`), `NUM`, `STR`, `SYM`, `IDENT`, `OP`,
   `LPAREN`/`RPAREN`, `LBRACKET`/`RBRACKET`, `COMMA`, `QMARK`, `COLON`, `EOF`. Commenti e spazi
   sono scartati qui.
3. **`class Parser`**: discesa ricorsiva che segue la precedenza del [§7.1](Parte-II-Triad-Core#cap-7):
   `parseProgram → parseStmt → parseExpr → parseAssign → parseTernary → … → parsePostfix →
   parsePrimary`, più `parseBlock(terminators)` per i corpi fino a `end`/`else`/`elseif`.
   Nodi prodotti: `program`, `funcdef`, `return`, `break`, `continue`, `exprstmt`, `num`,
   `str`, `sym`, `bool`, `nothing`, `var`, `list`, `lambda`, `assign`, `indexassign`,
   `binary`, `unary`, `ternary`, `call`, `index`, `if`, `while`, `let`, `begin`.
4. **Ambienti**: `makeFrame(parent, owner, isLambda)` crea un frame con una `Map` di legami;
   `lookup` risale la catena. `writeVar` implementa le regole di scope del [§10.3](Parte-II-Triad-Core#cap-10):
   aggiorna un legame dello stesso "proprietario" (funzione), oppure, dentro una lambda, un
   legame esterno; altrimenti crea un locale.
5. **Valutazione**: `evalStmt`, `evalExpr` → `evalExprBinary` → `evalExprRest` →
   `evalExprBlocks`. `return`, `break`, `continue` sono eccezioni JS (`ReturnSignal`,
   `BreakSignal`, `ContinueSignal`) catturate dalla chiamata o dal `while`.
6. **Builtin**: insieme `BUILTIN_NAMES` + `callBuiltin(name, args, env)`; stampa con
   `printValue` (simboli senza `:` solo al top level) e conversione con `stringOf`.
7. **`main()`**: legge il file (o stdin con `-`), lega `ARGS`, esegue; errori di parsing →
   `parse error: …`, errori di esecuzione → `error: …`, entrambi con exit 1; nessun file →
   exit 2.

### 34.2 Esempio: aggiungere un builtin

Supponiamo di voler sperimentare un builtin `abs` (non è in Core: va prima proposto nello
standard, vedi [§43](#cap-43)). Servono due modifiche:

```js
// 1. registrare il nome
const BUILTIN_NAMES = new Set(['print','println','length','push!','Int','string','Symbol',
  'typeof','readfile','strlen','strbyte','strsub','exit','abs']);

// 2. implementarlo in callBuiltin, prima del throw finale
  if (name === 'abs') {
    if (args.length !== 1 || args[0].t !== 'int') throw new Error('abs');
    return I(args[0].v < 0n ? -args[0].v : args[0].v);
  }
```

Poi: un caso in `conformance/core/cases/` ([§38](#cap-38)) e `node conformance/run.mjs`.
Ricorda che gli `Int` sono `BigInt` (`0n`, `1n`) e che i risultati vanno costruiti con gli
helper (`I`, `B`, `S`, `Y`, `L`, `NOTHING`).

### 34.3 Esempio: aggiungere sintassi

1. se serve un nuovo token, estendi `tokenize` (es. un operatore in `twoOps`);
2. aggiungi il livello di precedenza nel `Parser` producendo un nuovo `kind`;
3. gestisci il `kind` in `evalExpr*`;
4. aggiorna `SPEC-CORE.md` (grammatica §4 e semantica §5) e aggiungi un caso Core.

Regola: l'interprete JS deve restare **fedele a SPEC-CORE**; non aggiungere estensioni che il
seed e S1 non dovrebbero avere.

---

<a id="cap-35"></a>

## 35. Il seed S0 Windows e il suo generatore

### 35.1 Cos'è

`seed/windows-x86_64/seed.exe` è un PE32+ x86-64 di **25.088 byte** che importa solo
`KERNEL32.dll` (`GetStdHandle`, `GetCommandLineA`, `CreateFileA`, `ReadFile`, `WriteFile`,
`CloseHandle`, `ExitProcess`, `VirtualAlloc`). Non usa libc né runtime. La **fonte** è il dump
`seed.hex` (SHA-256 verificato dalla CI: `3A75A21E2F47D8DC4C88D4BC2580A85D5349BCDF7550E5FFA16E2C0AC7CA8C11`).

Il seed **non costruisce un AST**: interpreta direttamente il testo sorgente, con un cursore
(`rsi`) che scorre i byte; i corpi di funzioni e lambda sono puntatori nel sorgente che vengono
rieseguiti a ogni chiamata.

### 35.2 Convenzioni interne

| registro | ruolo |
|---|---|
| `r14` | base della memoria `VirtualAlloc` (sorgente a `+0`, ambiente a `+0x10000`, funzioni a `+0x20000`, heap a `+0x30000`) |
| `r15` | ambiente variabili (entry da 24 byte: nome ptr, len, valore) |
| `rbx` | contatore variabili |
| `r13` | tabella funzioni (entry da 128 byte) |
| `r12` | handle di stdout |
| `rsi` | cursore nel sorgente |

Valori taggati a 2 bit: `Int = n << 2`, `false = 1`, `true = 5`, chiusura `= ptr | 2`, oggetti
heap (stringhe `[tipo][len][byte…]`) con tag 3. Il layout completo (header PE, IAT, mappa
delle etichette `parse_program`, `st_if`, `parse_primary`, `env_find`, …) è in
[`seed/windows-x86_64/README.md`](https://github.com/GPuntobit/triad2.0/blob/main/seed/windows-x86_64/README.md).

### 35.3 Il generatore `seed/dev/gen_seed.js`

Scrivere migliaia di byte a mano è impraticabile: il generatore è un **assembler-lite** in
JavaScript che emette i byte e risolve le etichette. Sezioni del file:

| sezione | cosa |
|---|---|
| `emitter` | `B(...)` emette byte, `B32(v)` un dword, `L(nome)` definisce un'etichetta, `reloc`/`je`/`jne`/`jmp`/`callL` emettono salti con patch relative, `callIat(i)` chiama l'import `i` |
| helper di istruzione | funzioni con il nome dell'istruzione (`incRsi`, `cmpByteRsiImm('(')`, `testRax`, `leaRdxR14(d)`, …) che emettono i byte x86-64 corrispondenti |
| `PE/data layout` | costanti `IAT = 0x4000`, `SEC_RAW`, `HEADERS` |
| `main` | prologo, lettura della riga di comando, apertura/lettura del file |
| `parser` | il cuore dell'interprete: statement, espressioni, funzioni, lambda |
| `ambiente` | `env_find`, `env_store`, `env_assign` |
| `exit labels` | `fail`, `read_fail`, `open_fail`, `usage` |
| `PE builder` | scrive header DOS/PE/COFF, sezione `.text`, tabelle import, e il dump esadecimale |

Esempio di stile (dal `main`): saltare il nome del programma nella riga di comando.

```js
cmpByteRsiImm(0x22); jne('skip_plain');   // il path inizia con " ?
L('q_loop');
incRsi();
cmpByteRsiImm(0); je('no_arg');           // fine stringa: nessun argomento → exit 2
cmpByteRsiImm(0x22); jne('q_loop');
```

### 35.4 Flusso per modificare il seed

1. modifica `seed/dev/gen_seed.js` (aggiungi un'etichetta, un ramo nel dispatcher, …);
2. rigenera il dump: `node seed/dev/gen_seed.js seed/windows-x86_64/seed.hex`
   (oppure `bin/triad-cli seed generate windows`, che stampa anche lo SHA-256);
3. decodifica su Windows: `certutil -decodehex -f seed\windows-x86_64\seed.hex seed\windows-x86_64\seed.exe`;
4. esegui i casi Core sul seed e il probe `test_get.td`;
5. aggiorna **insieme**: hash in `.github/workflows/ci.yml` (job `seed-windows`, step
   `Hash check`), `seed/windows-x86_64/README.md`, `seed/dev/README.md`, `STATUS.md`; se un
   nuovo caso Core passa sul seed, aggiungilo all'array `$cases` del job.

Trappole note (da `STATUS.md`): il codice cresce e può sovrapporsi ai dati (i nomi import ora
partono da RVA `0x5000`); registri usati prima di essere inizializzati (bug `pbs_int`);
ordine degli argomenti sullo stack nelle chiamate builtin (`get`). Defender può segnalare il
PE come falso positivo (la CI aggiunge un'esclusione).

---

<a id="cap-36"></a>

## 36. Il seed Linux (E0)

`seed/linux-x86_64/seed` è un ELF64 statico di **173 byte** generato da
`seed/dev/gen_seed_linux.js`: entry `0x400078`, un solo `PT_LOAD` R|X, syscall dirette
`write`/`exit`. Stampa `Triad seed Linux OK` ed esce con 0. È il primo passo della milestone
M7; E1/E2/E3 (lettura file, interprete) sono da fare, riusando la logica del seed Windows con un
layer `os_*` diverso.

```sh
node seed/dev/gen_seed_linux.js seed/linux-x86_64/seed.hex   # verifica magic, entry, round-trip
xxd -r -p seed/linux-x86_64/seed.hex seed/linux-x86_64/seed && chmod +x seed/linux-x86_64/seed
./seed/linux-x86_64/seed                                     # Triad seed Linux OK
```

---

<a id="cap-37"></a>

## 37. Self-hosting: S1 in `selfhost/`

S1 è l'interprete di tutto Triad scritto in Triad-Core ed eseguito dal seed. Oggi è allo stadio
di prototipi separati, ognuno con un piccolo test in fondo al file:

| file | cosa prova |
|---|---|
| `main.td` | ambiente inline come lista piatta `[chiave, valore]`; smoke test in CI (atteso `Value: 10`) |
| `value.td` | valori taggati a 2 bit simulati con interi (`make_int`, `make_bool`, `as_int`) |
| `tokenizer.td` | `next_token(chars, pos)` su un sorgente codificato come lista `[lunghezza, byte…]`; token `[tipo, valore, pos]` |
| `parser.td` | riconoscimento delle keyword `if`/`end` dai codici ASCII |
| `eval.td`, `program.td` | valutazione di token numerici, identificatori, assegnamenti e `println` |
| `env.td`, `heap.td`, `ast.td`, `interpreter.td` | stub dell'ambiente, dell'allocatore bump e dell'AST |

### 37.1 Come si scrive codice S1 oggi

Il codice S1 deve girare sul **seed Windows**, quindi segue le restrizioni della colonna destra
del [capitolo 15](Parte-II-Triad-Core#cap-15):

- usa `get(xs, i)` con indici **da 0** invece di `xs[i]` (non standard: andrà sostituito con
  l'indicizzazione Core quando il seed la supporterà);
- liste solo di interi: le stringhe sorgente si rappresentano come liste di codici ASCII,
  con la lunghezza nella posizione 0;
- `push!` restituisce la lista: si scrive `env = push!(env, v)`;
- costanti per i tipi di token (`0` EOF, `1` NUMBER, `2` IDENTIFIER, …) documentate in un
  commento in testa al file;
- funzioni con al massimo 4 parametri, lambda a un parametro, niente cattura multi-binding.

```julia
# stile S1: ambiente piatto e lookup con get (0-based)
env = []
env = push!(env, 1)      # chiave
env = push!(env, 10)     # valore
if get(env, 0) == 1
  println("Value: " * string(get(env, 1)))
end
```

Su Linux questi file **non girano** con l'interprete JS (che non ha `get`): vanno provati su
Windows con `seed\windows-x86_64\seed.exe selfhost\main.td`.

### 37.2 Dove va S1

Le task S1.3–S1.15 sono in [`TASK.md`](https://github.com/GPuntobit/triad2.0/blob/main/TASK.md): valori taggati, tokenizer e parser inline,
eval di espressioni, `let`, programmi completi, funzioni e chiamate, chiusure, e infine far
girare la conformance sopra seed+S1. Gli esercizi 6 e 7 del [capitolo 17](Parte-II-Triad-Core#cap-17) sono una
versione in Core standard degli stessi passi.

---

<a id="cap-38"></a>

## 38. Conformance: leggere, scrivere e verificare casi

### 38.1 Formato

```
conformance/core/cases/<nome>/      (oppure conformance/cases/<nome>/ per Full)
  program.td        programma Triad eseguito come script
  args.txt          opzionale: un argomento per riga (ARGS)
  expected.out      stdout atteso, byte per byte, fine riga LF
  expected.golden   copia di expected.out (fallback del runner)
  expected.code     exit code atteso
```

Un caso passa se stdout e codice di uscita coincidono; stderr non è confrontato. Niente stdin
né input interattivo.

### 38.2 Il runner `conformance/run.mjs`

```sh
node conformance/run.mjs                              # Core (default conformance/core/cases)
node conformance/run.mjs --cases conformance/cases    # Full (oggi passa solo errore)
node conformance/run.mjs --skip liste,valori          # salta casi (default: liste)
node conformance/run.mjs --update                     # RIGENERA i golden dal runtime corrente
```

Runtime scelto, in ordine: variabile `TRIAD_SEED`; su Linux/macOS l'interprete JS; su Windows
`bin/triad-native.exe`, poi `seed/windows-x86_64/seed.exe`. Esempio per provare il seed con un
percorso esplicito: `TRIAD_SEED=/percorso/seed node conformance/run.mjs`.

Messaggi:
- `PASS  nome` / `FAIL  nome  (exit X, atteso Y, stdout N byte, attesi M)`;
- `golden mancante`: il checkout non ha `expected.out` (di solito basta `git pull`).

### 38.3 Aggiungere un caso Core

1. scegli un nome descrittivo in italiano (`liste_annidate`, `stringhe_vuote`, …);
2. scrivi `program.td` usando **solo** SPEC-CORE §2–§7 (niente primitivi di bootstrap: devono
   girare anche su Full);
3. scrivi a mano `expected.out` (con LF finale) ed `expected.code` (`0`), ragionando sulla
   specifica — **non** generarli alla cieca con `--update`, altrimenti fissi i bug del runtime;
4. copia `expected.out` in `expected.golden`;
5. `node conformance/run.mjs` deve stampare `PASS  <nome>`;
6. se il caso passa anche sul seed Windows, aggiungilo a `$cases` nel job `seed-windows` di
   `.github/workflows/ci.yml`.

```sh
mkdir conformance/core/cases/somma_lista
cat > conformance/core/cases/somma_lista/program.td <<'TD'
xs = [3, 4, 5]
tot = 0
i = 1
while i <= length(xs)
    tot += xs[i]
    i += 1
end
println(tot)
TD
printf '12\n' > conformance/core/cases/somma_lista/expected.out
cp conformance/core/cases/somma_lista/expected.out conformance/core/cases/somma_lista/expected.golden
printf '0' > conformance/core/cases/somma_lista/expected.code
node conformance/run.mjs | grep somma_lista          # PASS  somma_lista
```

I golden Full (`conformance/cases/`) sono **congelati**: non vanno rigenerati finché non esiste
un'implementazione Full.

---

<a id="cap-39"></a>

## 39. La CLI di sviluppo `triad-cli`

### 39.1 Uso

| comando | cosa fa |
|---|---|
| `triad-cli status` | versione Node, piattaforma, seed trovato, root del progetto |
| `triad-cli test conformance [-c DIR] [-u]` | esegue `conformance/run.mjs` (default Core, `--skip liste`) |
| `triad-cli test run` | alias della conformance Core (i vecchi test Julia non esistono più) |
| `triad-cli ai verify [-t DIR] [-v]` | esegue le `solution.triad` di `ai/tasks/` sul seed nativo e le confronta con i golden |
| `triad-cli seed generate windows\|linux [-o FILE]` | esegue il generatore del seed e stampa lo SHA-256 del dump |
| `triad-cli build standalone` | non disponibile: stampa un messaggio |

Avvio: `node cli/triad-cli.mjs …` (dopo `cd cli && npm install`), i launcher `bin/triad-cli` /
`bin\triad-cli.cmd` (installano le dipendenze al primo avvio e si fermano se `npm install`
fallisce), oppure l'eseguibile standalone della release.

### 39.2 Struttura del codice

```
cli/
  triad-cli.mjs            definizione dei comandi con commander
  lib/utils.mjs            findProjectRoot, findSeed, runSeed, runNode, projectPath, …
  lib/commands/test.mjs    handleTestRun, handleTestConformance
  lib/commands/ai.mjs      handleAIVerify
  lib/commands/seed.mjs    handleSeedGenerate (windows/linux)
  lib/commands/build.mjs   handleBuildStandalone
  build-exe.mjs            build dell'eseguibile Node SEA (esbuild + postject)
```

- `findProjectRoot()` cerca la root (una cartella con `conformance/run.mjs` e `seed/`) partendo
  da `TRIAD_HOME`, dalla cartella del modulo, da quella dell'eseguibile e dalla cartella
  corrente.
- Ogni handler restituisce `true`/`false`; `triad-cli.mjs` lo traduce in exit code 0/1.

### 39.3 Aggiungere un comando

1. crea `cli/lib/commands/<nome>.mjs` con una funzione `handle<Nome>(options)` che restituisce
   un booleano e usa `projectPath`, `runNode`, `runSeed` da `utils.mjs`;
2. registralo in `triad-cli.mjs`:

```js
import { handleLint } from './lib/commands/lint.mjs';

program
  .command('lint')
  .description('Controlla i file .triad')
  .option('-v, --verbose', 'Verbose output')
  .action(async (options) => {
    const success = await handleLint(options);
    process.exit(success ? 0 : 1);
  });
```

3. aggiungi la riga in `status` e documentalo in [`cli/README.md`](https://github.com/GPuntobit/triad2.0/blob/main/cli/README.md).

### 39.4 Eseguibile standalone

```sh
cd cli && npm install
npm run build:exe                         # dist/triad-cli per la piattaforma corrente
node build-exe.mjs path/to/win/node.exe   # dist/triad-cli.exe per Windows, anche da Linux
```

Il binario Node passato determina la piattaforma; deve avere la stessa versione del Node che
esegue la build.

---

<a id="cap-40"></a>

## 40. Benchmark AI (`ai/`)

Misura quanto bene un LLM scrive Triad-Core.

- `ai/SYSTEM_PROMPT.md`: prompt di sistema con il sottoinsieme ammesso (prudente: vieta liste,
  `string()`, `elseif`, `return` perché il seed non li supportava tutti);
- `ai/tasks/NN_nome/`: `task.md` (richiesta), `expected.out`, `solution.triad` (soluzione di
  riferimento);
- verifica: `node cli/triad-cli.mjs ai verify` (o `--tasks ai/tasks/01_somma`): `PASS`/`FAIL`,
  `SKIP` se manca la soluzione;
- `ai/jev_audit.mjs`, `ai/jev_prompt.md`: audit separato (vedi `PROMPT_JEV.md`).

Aggiungere un task: crea `ai/tasks/06_nome/` con `task.md` (output atteso descritto con
precisione), `expected.out` e una `solution.triad` di riferimento che passa. Esegui il codice
generato da un modello solo in un ambiente isolato.

---

<a id="cap-41"></a>

## 41. Editor, launcher e sito

- **VS Code** (`editors/vscode/`): `package.json` dichiara il linguaggio `triad` (estensioni
  `.triad`, `.td`); `syntaxes/triad.tmLanguage.json` è la grammatica TextMate (`source.triad`)
  con le regole `keywords`, stringhe con interpolazione, numeri, `:-`, shebang;
  `language-configuration.json` gestisce commenti e parentesi. Pacchetto:
  `cd editors/vscode && npx @vscode/vsce package`.
- **Vim/Neovim** (`editors/vim/`): `ftdetect/triad.vim` e `syntax/triad.vim`.
- **Linguist** (`editors/linguist/`): voce `languages.yml` pronta per una PR a GitHub Linguist.
- Se aggiungi una parola chiave allo standard, aggiornala in **tutte** le grammatiche.
- **Launcher** (`bin/`): `triad` (POSIX, risolve i symlink e calcola `TRIAD_HOME`) e
  `triad.cmd` (Windows, file CRLF); vedi [§2.4](Parte-I-Primi-passi#cap-2).
- **Sito** (`docs/`): HTML statico pubblicato su GitHub Pages; `docs/assets/js/app.js` carica i
  Markdown del repository con `marked` (es. `docs/pages/tutorial.html` carica questo file).
  Le ancore dell'indice usano `<a id="…">` espliciti perché funzionino anche lì.

---

<a id="cap-42"></a>

## 42. Integrazione continua

`.github/workflows/ci.yml`, a ogni push e pull request:

| job | cosa verifica |
|---|---|
| `conformance-core` (Ubuntu, Node 20) | `node conformance/run.mjs --cases conformance/core/cases --skip liste` con l'interprete JS |
| `seed-windows` | decodifica `seed.hex`, esegue 33 casi Core sul PE confrontando stdout, probe `test_get.td` (atteso `20`), smoke test `selfhost/main.td` (atteso `Value: 10`), hash di `seed.hex` |
| `seed-linux` | decodifica l'ELF E0, lo esegue e ne verifica l'hash |

`pages.yml` e `static.yml` pubblicano `docs/` su GitHub Pages a ogni push su `main`.

Il profilo Full **non è in CI** perché non è implementato: non presentarlo come verde.

---

<a id="cap-43"></a>

## 43. Flusso di contributo

Checklist per tipo di modifica:

| modifica | da fare |
|---|---|
| comportamento del linguaggio | aggiorna `SPEC.md`/`SPEC-CORE.md`, `CHANGELOG.md` e, se normativa, `VERSION`; aggiungi o aggiorna casi di conformance |
| interprete JS | resta fedele a SPEC-CORE; `node conformance/run.mjs` verde |
| seed Windows | rigenera `seed.hex`, aggiorna hash in CI e nei README, prova su Windows |
| S1 (`selfhost/`) | gira su `seed.exe`; se cambia l'output di `main.td`, aggiorna lo smoke test in CI |
| CLI | handler che restituisce un booleano; `cli/README.md`; ricostruisci l'eseguibile se serve |
| editor | grammatiche VS Code e Vim allineate alle parole chiave di SPEC §1 |
| documentazione | questa wiki, `README.md`, `STATUS.md` coerenti con ciò che gira davvero |

Regole generali: non dichiarare funzionante ciò che non è verificato; i golden si scrivono
ragionando sulla specifica; i nuovi strumenti di sviluppo non devono entrare nella catena S0→S4.

---

← [Parte III Triad Full](Parte-III-Triad-Full) · [Home](Home) · [Parte V Riferimento](Parte-V-Riferimento) →
