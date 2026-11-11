# Dati aggiuntivi estratti dal codice — per la Sessione 1 e Mimo

> **Metodo (vincolante per questo file):** ogni dato qui sotto proviene **dalla lettura
> diretta del codice sorgente** (citato come `file:riga`) oppure dall'**esecuzione misurata**
> dei due runtime del repository su sonde riproducibili (`docs/libro/_sonde/`).
> **Nessun dato proviene da `SPEC.md`, `SPEC-CORE.md`, `MANUALE`, `TUTORIAL` o altra
> documentazione esistente.** Se un fatto non è nel codice o nelle sonde, non è in questo file.
>
> Generato il 2026-11-01 dalla sessione di supporto (pi), in sincronia con mimo.

---

## 1. Fonti ispezionate (solo codice)

| File | Che cos'è (dal codice stesso) |
|---|---|
| `seed/dev/gen_seed.js` (1671 righe) | Generatore del seed PE x86-64 Windows: emette byte macchina. Il parser **è** l'interprete (single-pass: parse = esecuzione). |
| `seed/windows-x86_64/seed.exe` | Il seed nativo generato. |
| `seed/dev/triad_core.cjs` (1041 righe) | Interprete JS di riferimento: `tokenize` → `Parser` → AST → `evalStmt`. Usato anche dal playground browser. |
| `selfhost/value.td`, `selfhost/tokenizer.td` | S1 (interprete scritto in Triad-Core): conferma indipendente dello schema di tagging e delle regole lessicali. |
| `conformance/run.sh`, `conformance/gate.sh`, `conformance/core/cases/*` | Runner (POSIX) e 42 casi golden (programma + output atteso + exit code). |
| `cli/triad-cli.mjs` | CLI di sviluppo: `seed generate`, `ai verify`, `build standalone`, `test run`, `test conformance`, `run`, `ext check/package`. |

Comandi di riproduzione usati (dalla root del progetto):

```sh
./seed/windows-x86_64/seed.exe <file>.td ; echo "EXIT=$?"
node seed/dev/triad_core.cjs <file>.td ; echo "EXIT=$?"
node conformance/run.mjs            # suite Core sul seed
```

---

## 2. Rappresentazione dei valori (dal codice, due fonti concordi)

Dal generatore del seed — **attenzione alle trappole dei nomi**: `shlRax1`/`sarRax1`
emettono in realtà `shl/sar rax, 2` (`gen_seed.js:211-212`), quindi gli interi sono
codificati **n << 2**:

| Valore | Encoding (seed) | Citazioni |
|---|---|---|
| Int | `n << 2` (interi macchina a 64 bit, wrap two's complement) | `gen_seed.js:211-212`; commento a `print_int`: "Int = n<<2" |
| Bool | `false = 1`, `true = 5` (2 bit tag `01`); `!` = `xor 4` | `gen_seed.js:277`, `pf_not` |
| Chiusura | puntatore heap `\| 2` | `gen_seed.js:247` (`orRaxImm2`) |
| String/Symbol/List/Nothing | puntatore heap `\| 3` con header `[tipo][len]`: tipo `1` = stringa/simbolo, `2` = lista, `4` = nothing | `gen_seed.js:329`, `print_int` (`pi_object`), `pf_string` |
| Simbolo `:nome` | **non è un tipo distinto nel seed**: oggetto stringa (tipo 1) che stampa senza `:` | `gen_seed.js:1128-1129` (commento) |

Conferma indipendente da `selfhost/value.td:1-6` (S1): *"2 bit tag... Tag 0: Int (valore * 4),
Tag 1: Bool (false=1, true=5), Tag 2: List (ptr*4+2), Tag 3: String/Nothing/Symbol (ptr*4+3)"*.

**Conseguenza misurata** (sonda `_sonde/02_wrap.td`): nel seed il letterale
`9223372036854775807` viene codificato `<<2` durante il parsing e **diventa `-1`**.
Il massimo letterale intero utilizzabile nel seed è quindi **2^61-1**. L'interprete JS usa
`BigInt` con wrap a signed 64-bit (`triad_core.cjs:15-22`) e accetta l'intero intervallo
int64.

---

## 3. Limiti strutturali del seed (dal codice)

| Limite | Valore | Citazione |
|---|---|---|
| Sorgente | ≤ `0xFFFFF` = **1 048 575 byte** (1 MiB − 1); da `0x100000` in poi → exit 1 | `seed/dev/core.js` (`MEM.SRC_MAX = 0x100000`; `cmpR13dImm32(MEM.SRC_MAX); jae('read_fail')`) |
| Ambiente variabili | voci da 24 byte da `r14+0x110000` → max **16 384** binding | `seed/dev/core.js` (`MEM.ENV`, `MEM.ENV_MAX`, `env_store`) |
| Tabella funzioni | voci da 128 byte da `r14+0x190000` → max **3 584** record | `seed/dev/core.js` (`MEM.FUNC`, `MEM.FUNC_MAX`, `shlRcx7`) |
| Heap chiusure/stringhe/liste | bump allocator da `r14+0x200000` (dati da `+0x200008`), allineamento 16; regione `0xA00000` → **8 MiB** utilizzabili | `seed/dev/core.js` (`MEM.HEAP`, `MEM.HEAP_SIZE`, `leaR10Rcx31; andR10ImmNeg16`) |
| Lista | max **64 elementi** (allocazione fissa `0x210` = header + 64×8) | `gen_seed.js:1088-1098`, `pf_builtin_push` (`:1293`) |
| Parametri per funzione | max **64** | `gen_seed.js:610`, `:801` |
| Lambda `x -> expr` | **un solo parametro**, cattura **un solo** binding esterno | `gen_seed.js:1209-1228` (`pf_lambda`, record `0x68/0x70/0x78`) |
| Effetti `!io` | sintassi accettata e **ignorata** da entrambi i runtime | `gen_seed.js:822-827` (`sf_effect`); `triad_core.cjs` (`parseStmt`/`parsePrimary`, ramo `!`) |
| Interi (`Int`) | il tag del tipo occupa il bit basso: range utile **±(2^61 − 1)**; un letterale o un risultato aritmetico fuori range è **rifiutato** (exit 1, `seed: integer overflow` su stderr ELF), non prodotto sbagliato in silenzio: divergenza `D25` rispetto al wrap a 64 bit signed di `SPEC-CORE.md` §5 | `seed/dev/core.js` (`shlRax1`/`sarRax1`: il valore è spostato di un bit per il tag; `int_chk62` → `overflow_fail`) |
| File letto da `readfile` | max **1 048 576 byte** (1 MiB): un file più grande è **rifiutato** (exit 1), non troncato; il path è copiato in un buffer scratch di max **1024 byte** | `seed/dev/core.js` (`FILE_MAX`, `PATH_MAX`, `PATH_BUF`) |

---

## 4. Lexer: fatti puntuali dai sorgenti

| Fatto | Seed PE | Interprete JS |
|---|---|---|
| Separatori | `\n`, `\r`, `;` + blank (` `, `\t`) in `skip_ws` (`gen_seed.js:881-897`) | `\n`, `\r`, `\r\n`, `;` + blank anche `\f`, `\v` (`triad_core.cjs:24-35`) |
| Commento `#` riga | sì (`sw_hash`) | sì (`triad_core.cjs:38-44`) |
| Commento `#= ... =#` | **no** — le righe successive vengono parse come codice → exit 1 (misurato, sonda `11_commenti.td`) | sì ma **non annidati** (`indexOf('=#')`, `triad_core.cjs:38-43`) |
| Identificatori | `[A-Za-z_][A-Za-z0-9_]*` + `!` finale (`parse_ident`, `gen_seed.js:1385-1408`) | idem (`triad_core.cjs:88-93`) |
| Numeri | **solo cifre decimali** (`pf_num_loop`, `gen_seed.js:1111-1121`); `1_000` → exit 1 (misurato) | decimali con `_` ammesso e scartato (`triad_core.cjs:77-83`) |
| Stringhe | **byte grezzi tra virgolette, nessun escape** (`pf_string`, `gen_seed.js:1159-1180`): `"\n"` è backslash + `n` | escape `\n \t \" \\`; `\<altro>` conservato come backslash+carattere (`triad_core.cjs:49-66`) |
| Simboli | solo `:nome` alfanumerico/underscore (`pf_symbol`, `gen_seed.js:1130-1157`) | `:nome` e anche operator symbols `:+` (`triad_core.cjs:69-87`) |
| Esecuzione | **single-pass**: emette output durante il parse; un errore in coda lascia l'output parziale già stampato (misurato) | il programma viene **tutto parsato prima**: errore di sintassi ⇒ stdout vuoto (misurato) |

---

## 5. Operatori e precedenza (dai parser: `triad_core.cjs:231-345`, `gen_seed.js` `parse_ternary`→`parse_primary`)

Dal livello più basso al più alto — **identica in entrambi i runtime**:

1. `?:` ternario (nel seed con scansione del ramo non scelto senza valutarlo, `pt_tern`)
2. `= += -= *=` (assegnamento, destra-associativo; **nel seed solo `=` e `+=`**, `st_add_check`)
3. `||`
4. `&&`
5. `== != < <= > >=` (livello unico, sinistra-associativi)
6. `+ -`
7. `* %` — `*` fa anche **concatenazione di stringhe** in entrambi (JS: `triad_core.cjs:631-632`; seed: ramo stringhe di `pt_mul`, `gen_seed.js:958-980`)
8. `^` (destra-associativo in entrambi — misurato: `2^3^2` = `512`)
9. unario `- !`
10. postfix: chiamata `f(...)`; **indicizzazione `xs[i]` solo JS**

Fatti misurati/dal codice:
- **La divisione `/` non esiste in nessuno dei due runtime** (non è nei parser):
  `println(10/2)` → JS `parse error: expected RPAREN` exit 1; seed exit 1.
- `&&`/`||`: il JS è a **valutazione corta** e richiede Bool (`triad_core.cjs:594-610`);
  nel seed sono **bitwise sui tag** (`orRaxRcx`/`andRaxRcx`, commento `gen_seed.js:899`):
  valutano **entrambi gli operandi** e funzionano solo su Bool puri.
- Confronti JS: `<` accetta anche String; `<= > >=` solo Int; `== !=` è uguaglianza
  strutturale per le liste, per identità per le funzioni (`equals`, `triad_core.cjs:835-850`).
  Nel seed i confronti decodificano con `sar 2` e confrontano come interi (anche i Bool).
- `% 0`: JS → `error: div by zero` exit 1 (`triad_core.cjs:641`); seed → **exit 127**
  (divisione hardware per zero, nessun messaggio — misurato).

---

## 6. Built-in: matrice di copertura (dai dispatcher)

| Costrutto | Seed PE | Interprete JS | Note (codice) |
|---|---|---|---|
| `println(expr)` | ✅ unico statement di stampa, **1 argomento**, sempre + `\n` (`gen_seed.js:533-553` + `print_int`) | ✅ multi-argomento (`triad_core.cjs:856-861`) | `println(1, 2, "tre")` → seed exit 1; JS `12tre` |
| `print(expr)` | ❌ exit 1 (viene letto come definizione `print(...) = ...`) | ✅ senza newline | |
| `length(x)` | ✅ su lista **e** stringa (`pf_builtin_length`, header `len`) | ✅ lista = numero elementi; stringa = **byte UTF-8** (`Buffer.byteLength`) | |
| `push!(xs, v)` | ✅ ma **solo come espressione**: `xs = push!(xs, v)`; come statement da solo → exit 1 (misurato) | ✅ in entrambe le forme | muta la lista e la restituisce |
| `get(xs, i)` | ✅ **indice 0-based** (misurato: `get(xs, 0)` = primo) | ❌ `undefined variable get` | |
| `xs[i]` | ❌ exit 1 | ✅ **indice 1-based** (`i < 1 || i > len`, `triad_core.cjs:581`) | **divergenza di forma e di base indice** |
| `string(x)` | ✅ Int → decimale (con `-`); **Bool→"1"/"0"** (misurato!); String/Symbol → identità (`pf_builtin_string`) | ✅ totale: `true`/`false`, `nothing`, liste... (`stringOf`, `triad_core.cjs:940-950`) | il commento del seed dice "Bool/Symbol/Nothing non supportati" ma il percorso Bool produce `"1"`/`"0"` senza errore |
| `Int(x)`, `Symbol(x)`, `typeof(x)` | ❌ exit 1 | ✅ (`triad_core.cjs:868-902`); `typeof` restituisce i simboli `Int Bool String Symbol List Function Nothing` | |
| `readfile`, `strlen`, `strbyte`, `strsub`, `exit` | ✅ (`pf_builtin_readfile`, `pf_builtin_strlen`, `pf_builtin_strbyte`, `pf_builtin_strsub`, `pf_builtin_exit`): `readfile` legge il file (max 1 MiB, path max 1024 byte), `strlen` conta i byte, `strbyte`/`strsub` sono **indicizzati per byte, 1-based**, `exit(n)` termina con il codice `n & 0xff` | ✅ (`triad_core.cjs:907-938`); `strbyte`/`strsub` sono **indicizzati per byte, 1-based** | il simbolo **non** è una stringa: `strlen(:x)` fallisce su entrambi i runtime |
| `ARGS` | ❌ exit 1 | ✅ lista di String dagli argomenti CLI (`triad_core.cjs:974`) | |
| Stampa di funzione | `fun` (`pi_fun`) | `#lambda(params)` (`printValue`) | misurato |
| Stampa di lista | solo **elementi Int**; su stringhe/simboli stampa `[` e poi exit 1 (output parziale!) | elementi misti; String e Symbol senza virgolette/`:` nei listali (`printValue(x, false)`) | misurato: `println(["a","b"])` → seed `[`+exit 1; JS `[a, b]` |
| `return` | ❌ assente (il valore di una funzione a blocco è l'**ultima espressione** del corpo, `blockLoad`) | ✅ (`ReturnSignal`) | se l'ultima istruzione del corpo è `println(...)`, il valore restituito è **`0`** sul seed e **`nothing`** sul JS (misurato, sonda `25_effetti`) |
| Effetti `!io` | sintassi ok, ignorata | sintassi ok, ignorata | misurato con `function f(a,b) !io` |

---

## 7. Divergenze misurate — tabella completa (sonde in `docs/libro/_sonde/`)

Ogni riga è verificata con entrambi i runtime; `EXIT=n` è il codice di uscita.

| Sonda | Programma (essenziale) | Seed PE | Interprete JS |
|---|---|---|---|
| `01_numeri` | `println(1_000 + 1)` | exit 1, nessun output | `1001` |
| `02_wrap` | `println(9223372036854775807)` | `-1` | `9223372036854775807` |
| `02_wrap` | `println(9223372036854775807 + 1)` | `0` | `-9223372036854775808` (wrap int64) |
| `02_wrap` | `println(0 - 9223372036854775807 - 2)` | `-1` | `9223372036854775807` |
| `02_wrap` | `println(1000000 * 1000000 * 1000000)` | `1000000000000000000` | idem |
| `03_escape` | `println("a\nb")` poi `length("a\nb")` | `a\nb` letterale, `4` | `a`+newline+`b`, `3` |
| `04_print` | `print(1)` | exit 1 | `1` senza newline |
| `05_print_multi` | `println(1, 2, "tre")` | exit 1 | `12tre` |
| `06_push_stmt` | `push!(xs, 2)` (statement) | exit 1 | `[1, 2]` |
| `07_push_expr` | `xs = push!(xs, 2)` | `[1, 2]` | `[1, 2]` |
| `08_get` | `get(xs, 0)`, `get(xs, 1)` | `10`, `20` → **indice 0-based** | `error: undefined variable get` |
| `09_indice` | `println(xs[1])` | exit 1 | `10` → **indice 1-based** |
| `10_meno_uguale` | `n = 5; n -= 2` | exit 1 | `3` |
| `11_continue` | `continue` in `while` | exit 1 | `3` |
| `12_let_multi` | `let a = 1, b = 2 ... end` | exit 1 (solo binding singolo) | `3` |
| `13_if_expr` | `r = if x > 0 \n 10 \n else \n 20 \n end` | exit 1 | `10` |
| `14_while_expr` | `z = while w < 3 \n w += 1 \n end` | exit 1 | `3` (valore ultima expr del corpo) |
| `15_if_nonbool` | `if 1 ... else ... end` | `false-branch` → **ramo else**, silenzioso | `error: if cond` exit 1 |
| `16_while_nonbool` | `while w` con `w = 7` | `7` → **corpo saltato**, silenzioso | `error: while cond` exit 1 |
| `17_mod_zero` | `println(1 % 0)` | **exit 127** (eccezione hardware, nessun msg) | `error: div by zero` exit 1 |
| `18_commenti` | commento `#= ... =#` su più righe | exit 1 | `1`, `2` (non annidati) |
| `19_args` | `println(ARGS)` | exit 1 | `[alfa, beta]`, `2` (con `node ... a.td alfa beta`) |
| `20_string_bool` | `string(true)` / `string(false)` | `1` / `0` | `true` / `false` |
| `21_simboli` | `println(:ok)`, `string(:sym)`, `typeof(42)`, `Int("42")` | `ok`, `sym`, poi exit 1 | `ok`, `sym`, `Int`, `42` |
| `22_funzione_stampata` | `println(f)` con `f = x -> x` | `fun` | `#lambda(x)` |
| `22_funzione_stampata` | `string(0 - 42)` | `-42` | `-42` |
| `23_lista_stringhe` | `println(["a", "b"])` | `[` poi exit 1 | `[a, b]` |
| `24_lambda` | `f = x -> x * 2; println(f(21))` | `42` | `42` |
| `24_lambda` | `g = function (a) \n a + 1 \n end` (espressione) | exit 1 | `42` |
| `25_effetti` | `function somma(a, b) !io ... end`; `println(somma(2, 3))` | `5` poi **`0`** | `5` poi **`nothing`** |
| `26_potenza` | `2 ^ 3 ^ 2`, `!false`, `true ? 10 : 20` | `512`, `true`, `10` | idem |
| `27_divisione` | `println(10 / 2)` | exit 1 | `parse error: expected RPAREN` exit 1 |

Comportamento su errore (dai codici di uscita del codice): il seed usa etichette
`fail`/`read_fail`/`open_fail` → `ExitProcess(1)` **senza messaggi**; `usage`/`no_arg` →
`ExitProcess(2)` (`gen_seed.js:1607-1612`). Il JS scrive `parse error: ...`/`error: ...`
su **stderr** ed esce con 1; senza argomenti `usage: triad FILE [ARG...]` ed esce con 2
(`triad_core.cjs:968-1005`).

---

## 8. Conformance: cosa garantisce davvero (dal codice)

- Suite Core: **42 casi** in `conformance/core/cases/` (ognuno: `program.td`,
  `expected.out`, `expected.code`, a volte `expected.golden`).
- `conformance/gate.sh`: `KNOWN_GAP` **vuota** — i due gap storici sono chiusi e nessun
  golden è stato riscritto per mascherarli: `liste` (indicizzazione `xs[i]` 1-based,
  `push!`-statement, N03) e `ternario_simbolo` (il `:` del simbolo non è più scambiato
  per il separatore del ternario, D23) sono verdi sul seed.
- Misurato `sh conformance/run.sh` → **42 PASS** su 42 (sul seed ELF);
  `node seed/dev/triad_core.cjs` sullo stesso programma → **42/42** (il riferimento JS è
  l'autorità semantica ed è conforme alla specifica).
- Il caso `liste_push` documenta (golden `[10, 20]`) che `alias = lst` **condivide
  l'oggetto**: `push!` muta in posto e gli alias vedono la modifica.
- Esiste anche `conformance/cases/` (profilo **Full**: `assaggio`, `destruttura`,
  `dispatch`, `errore`, `famiglia`, `garanzie_core`, `hello_shebang`, `macro`,
  `macro_eval`, `prolog`): non è eseguibile dai due runtime Core qui descritti.

---

## 9. Fuori perimetro: assente da entrambi i parser Core (verificato per negazione nei sorgenti)

Se il libro tratta questi temi, sono feature **Full** e NON vanno presentate come
eseguibili sui runtime attuali: `/` e float, `for`/`irange`, comprehension, `try/catch`,
`struct`, annotazioni `::` e multiple dispatch, `fact`/`rule`/`solve` e `?x`,
macro `@name`, `quote`/`:( )`, interpolazione `$`, `xs[end]`, destrutturazione,
contratti `requires`/`ensures`, `with budget`, `with trace`.

---

## 10. Indicazioni operative per la Sessione 1 (e mimo)

1. **Capitolo Liste**: la forma `push!(xs, v)` scritta come statement **non gira sul
   seed**. Se il libro vuole esempi eseguibili ovunque usare `xs = push!(xs, v)`.
   L'indicizzazione `xs[i]` è 1-based sul JS e assente sul seed; `get(xs, i)` è 0-based
   sul seed e assente sul JS: **non presentare un solo "indice Triad" senza nota**.
2. **Capitolo Stringhe**: gli escape `\n \t \" \\` valgono per il profilo Full/JS; sul
   seed le stringhe sono byte grezzi (una stringa può contenere newline reali).
   `length(stringa)` conta i **byte**, non i caratteri.
3. **Capitolo Interi**: wraparound a 64 bit due's complement in entrambi; ma i
   **letterali** nel seed sono limitati a 2^61-1 (`9223372036854775807` → `-1`).
   `1_000` (underscore) è Core per la specifica ma **non dal seed**.
4. **Condizioni**: specificare che `if`/`while` richiedono `Bool`; sapere che il seed
   oggi *degrada silenziosamente* (if → else, while → salta) mentre il JS errore: il
   libro non deve usare questo comportamento come semantica voluta.
5. **Errori**: il seed non stampa messaggi (exit 1 / 127 / 2); i testi di errore citati
   nel libro provengono dall'interprete JS (`error: ...` su stderr).
6. **Output parziale**: il seed esegue mentre legge; un programma con errore in coda
   può aver già stampato qualcosa. Nei golden la sequenza di stdout è quindi
   "fino al primo fallimento".
7. Per qualsiasi esempio del libro che deve passare su entrambi i runtime: usare
   `println(expr)` con un solo argomento, assegnamenti `=`/`+=`, `while`/`if` con
   condizioni Bool, funzioni con valore = ultima espressione del corpo, liste ≤ 64
   elementi con soli interi, e verificarli con le sonde in `_sonde/`.

---

## 11. Sondaggi disponibili (`docs/libro/_sonde/`)

Ogni sonda è eseguibile su entrambi i runtime con i comandi della §1. La colonna
«risultato atteso» richiama la §7.

| File | Verifica |
|---|---|
| `01_numeri.td` | underscore nei letterali (`1_000`) |
| `02_wrap.td` | wrap int64 e letterali > 2^61-1 |
| `03_escape.td` | escape nelle stringhe + `length` |
| `04_print.td` | `print(1)` |
| `05_print_multi.td` | `println` multi-argomento |
| `06_push_stmt.td` | `push!` come statement (nudo) |
| `07_push_expr.td` | `push!` come espressione (forma certificata) |
| `08_get.td` | `get(xs, i)` 0-based |
| `09_indice.td` | `xs[i]` 1-based |
| `10_meno_uguale.td` | `-=` |
| `11_continue.td` | `continue` |
| `12_let_multi.td` | `let` con più binding |
| `13_if_expr.td` | `if` come espressione |
| `14_while_expr.td` | `while` come espressione |
| `15_if_nonbool.td` | condizione `if` non-Bool |
| `16_while_nonbool.td` | condizione `while` non-Bool |
| `17_mod_zero.td` | `% 0` |
| `18_commenti.td` | `#= ... =#` |
| `19_args.td` | `ARGS` |
| `20_string_bool.td` | `string(true/false)` |
| `21_simboli.td` | simboli, `typeof`, `Int` |
| `22_funzione_stampata.td` | stampa di una funzione, `string` di negativo |
| `23_lista_stringhe.td` | lista con stringhe |
| `24_lambda.td` | lambda e funzione-blocco come espressione |
| `25_effetti.td` | `function ... !io` e valore di ritorno del corpo |
| `26_potenza.td` | `2^3^2`, unario `!`, ternario |
| `27_divisione.td` | `/` inesistente |
