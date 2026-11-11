<a id="parte-5"></a>

# Parte V — Riferimento

<a id="cap-44"></a>

## 44. Grammatica Triad-Core (EBNF)

Da [`SPEC-CORE.md`](https://github.com/GPuntobit/triad2.0/blob/main/SPEC-CORE.md) §4:

```ebnf
program  = { sep } { stmt sep { sep } } ;
stmt     = funcdef | "return" [ expr ] | "break" | "continue" | expr ;
funcdef  = "function" NAME "(" [ NAME { "," NAME } ] ")" block "end"
         | NAME "(" [ NAME { "," NAME } ] ")" "=" expr ;
expr     = assegnamento ;
assegnamento = NAME ( "=" | "+=" | "-=" | "*=" ) expr | ternario ;
ternario = or_expr [ "?" expr ":" expr ] ;
or_expr  = and_expr { "||" and_expr } ;
and_expr = cmp_expr { "&&" cmp_expr } ;
cmp_expr = sum_expr { ( "==" | "!=" | "<" | "<=" | ">" | ">=" ) sum_expr } ;
sum_expr = mul_expr { ( "+" | "-" ) mul_expr } ;
mul_expr = pow_expr { ( "*" | "%" ) pow_expr } ;
pow_expr = unary { "^" unary } ;                    (* destra *)
unary    = ( "-" | "!" ) unary | postfix ;
postfix  = primary { "(" args ")" | "[" expr "]" } ;
primary  = INT | STRING | SYMBOL | "true" | "false" | "nothing" | NAME
         | "(" expr ")"
         | "[" [ expr { "," expr } ] "]"
         | "(" NAME { "," NAME } ")" "->" expr
         | "if" expr block { "elseif" expr block } [ "else" block ] "end"
         | "while" expr block "end"
         | "let" [ NAME "=" expr { "," NAME "=" expr } ] block "end"
         | "begin" block "end"
         | "function" "(" [ NAME { "," NAME } ] ")" block "end" ;
block    = { stmt sep { sep } } ;                   (* fino a end/else/elseif *)
```

La grammatica Full (Pratt, 12 livelli) è in [`SPEC.md`](https://github.com/GPuntobit/triad2.0/blob/main/SPEC.md) §2.

---

<a id="cap-45"></a>

## 45. Schede rapide Core e Full

**Triad-Core** (eseguibile oggi):

```
assegnamento:  x = e    x += e    x -= e    x *= e    xs[i] = e
funzione:      f(a, b) = e
               function f(a, b) ... end        (anche !io, ignorato)
anonima:       x -> e    (a, b) -> e    function (a) ... end
condizione:    if c ... elseif c ... else ... end    c ? a : b
ciclo:         while c ... end    break    continue
blocchi:       let a = 1, b = 2 ... end    begin ... end
uscita:        return e
liste:         [1, 2]    xs[i] (da 1)    length(xs)    push!(xs, v)
stringhe:      "a" * "b"    length(s)    string(x)
conversioni:   Int("42")    Symbol("s")    typeof(x)
I/O:           print(...)    println(...)    ARGS
bootstrap:     readfile(p)  strlen(s)  strbyte(s, i)  strsub(s, a, b)  exit(n)
```

**Triad-Full** (specifica):

```
struttura:   struct Nome; x::T; y::T; end
funzione:    function f(a::T)::R !eff ... end
fatto:       fact p(:a, :b)
regola:      rule p(?x, ?y) :- q(?x), r(?y)
query:       solve p(?x) limit N depth D steps S trace
destruttura: (a, b) = [1, 2]        for (k, v) in [[1,2],[3,4]] ... end
ciclo for:   for v in it ... end    1:n    xs[2:end]    [e for x in xs if c]
try/catch:   try b catch e h end / try b end
contratto:   requires c / ensures c
budget:      with budget(steps = N) ... end
traccia:     with trace ... end / solve p trace
effetto:     function f() !io ... end
macro:       macro m(a) ... end / @m(e)
quote:       :(espr) / quote ... end / $espr
eval:        eval(codice)
```

---

<a id="cap-46"></a>

## 46. Debug e problemi comuni

**Core (oggi):**

| sintomo | causa probabile | soluzione |
|---|---|---|
| `parse error: expected RPAREN` | `1.5`, `/`, `() -> …` o altra sintassi Full | resta nel sottoinsieme Core ([§4](Parte-II-Triad-Core#cap-4)) |
| `"x = $x"` stampato letteralmente | l'interpolazione è solo Full | `"x = " * string(x)` |
| `error: if cond` | condizione non `Bool` | usa un confronto (`x != 0`) |
| `error: < type error` su `a < b < c` | confronti concatenati | `a < b && b < c` |
| una funzione non aggiorna un globale | le funzioni nominate assegnano in locale | restituisci il valore o usa una lista ([§16.4](Parte-II-Triad-Core#cap-16)) |
| `error: undefined variable f` | funzione chiamata prima della definizione | definiscila più in alto |
| `FAIL … (golden mancante …)` | checkout senza `expected.out` | `git pull`; controlla `.gitignore` |
| il seed esce con 1 senza messaggi | funzionalità non supportata dal seed | prova con l'interprete JS; vedi [§15](Parte-II-Triad-Core#cap-15) |
| il seed Windows viene bloccato | falso positivo dell'antivirus | escludi `seed\windows-x86_64` |

**Full (specifica):**

| sintomo | causa probabile | soluzione |
|---|---|---|
| `Err(:syntax)` "atteso fine istruzione" | manca `end` o un separatore | aggiungi `end` o `;` |
| `Err(:undef)` | nome non definito | definiscilo, o usa `:nome` per un simbolo |
| `Err(:method)` / `Err(:ambiguous)` | nessun metodo / più metodi ugualmente specifici | aggiungi o ridisegna le firme |
| `Err(:bounds)` in destrutturazione | arità diversa dal pattern | liste di lunghezza esatta |
| `Err(:effect)` | `!io`/`!state` chiamata da funzione pura | dichiara l'effetto nel chiamante |
| `Err(:budget)` in `solve` | troppi passi | aumenta `steps` o usa `limit`/`depth` |

Strumenti Full previsti: `triad --tree file`, `sexpr(codice)`, `parse`/`unparse`,
`with trace … end`, `solve … trace`, `try … end` con `.kind`/`.msg`/`.data`.

---

<a id="cap-47"></a>

## 47. Glossario

- **S0 / seed**: interprete Triad-Core in codice macchina (`seed/`).
- **S1**: interprete di tutto Triad scritto in Triad-Core (`selfhost/`).
- **S2 / S3 / S4**: compilatore nativo, self-hosting, runtime completo (vedi `BOOTSTRAP.md`).
- **E0 / E1 / …**: stadi del port Linux del seed (milestone M7).
- **Triad-Core / Triad-Full**: i due profili di conformità.
- **Interprete JS**: `seed/dev/triad_core.cjs`, riferimento Core per sviluppo e CI.
- **Golden**: output atteso committato (`expected.out`, `expected.code`).
- **Primitivi di bootstrap**: `readfile`, `strlen`, `strbyte`, `strsub`, `exit` (solo Core).
- **Lista taggata**: record Core del tipo `[:Tag, campo1, …]`.
- **Node**: l'unico tipo di albero di Triad Full (`head`, `args`): codice e dati coincidono.
- **Solution**: `{nome = valore, …}` restituita da `solve`; `s.nome` o `s[:nome]`.
- **Err**: errore come dato (`kind`, `msg`, `data`).
- **Traced**: `(result, trace)` restituito da `with trace` / `solve … trace`.
- **Occurs-check**: l'unificazione rifiuta `?x = f(?x)`.
- **Multiple dispatch**: scelta del metodo più specifico tra gli applicabili.
- **Effetti dichiarati**: `!io`, `!state` nella firma; controllo dinamico.
- **Contratti**: `requires` (pre) / `ensures` (post, con `result`).
- **Budget**: `with budget(steps = N)`; l'esaurimento è `Err(:budget)`.
- **Destrutturazione**: `(a, b) = lista`, `for (k, v) in lista_di_liste`.

---

<a id="cap-48"></a>

## 48. Stato, limiti noti e fix storici

**Stato** (dettagli in [`STATUS.md`](https://github.com/GPuntobit/triad2.0/blob/main/STATUS.md)):
- Core: 37/37 casi con l'interprete JS; 33 casi sul seed Windows in CI.
- Full: 12 casi golden congelati, passa solo `errore`.
- S1: prototipi in `selfhost/`, smoke test in CI; non ancora conformance.
- S2–S4: non iniziati. Seed Linux: E0.
- CLI `triad`: solo esecuzione di file (REPL e opzioni di SPEC §14 da fare).

**Limiti dello standard** (SPEC §15): argomenti con nome (salvo `budget(steps = …)`), struct
mutabili, tipi astratti utente e parametrici, macro senza parentesi, quote annidate a più
livelli, cut di Prolog non sono previsti; il controllo degli effetti è dinamico.

**Fix storici** applicati alla vecchia implementazione Julia; il comportamento "dopo" è quello
richiesto da SPEC.md per ogni implementazione:

| # | fix | dopo |
|---|---|---|
| 1 | round-trip del range | `unparse(1:n)` produce `"1:n"` (senza spazi) |
| 2 | `unparse` di `:destructure`/`:dfor` | hanno rami propri e fanno round-trip |
| 3 | `xs[end] = v` | `end` è legato anche in scrittura: `xs[end] = 7` funziona |
| 4 | escape sconosciuti | solo `\n \t \" \\ \$`; altri → `Err(:syntax)` con riga e colonna |
| 5 | commenti `#=` annidati | la profondità è contata; `#=` non chiuso → errore `incomplete` |
| 6 | lambda con parametri tipati | `function (x::Int) x end` controlla i tipi: `f(2.0)` → `Err(:type)` |

---

<a id="cap-49"></a>

## 49. FAQ

**Serve Julia?** No. L'implementazione Julia è stata rimossa; Triad gira sul seed in codice
macchina (Windows) o sull'interprete JS di sviluppo.

**Perché i miei esempi con `struct` o `fact` non girano?** Sono Triad-Full: il runtime attuale
esegue solo Triad-Core. Vedi la tabella in testa alla wiki.

**`.td` o `.triad`?** `.triad` è canonica; `.td` è accettata come alias (ed è anche
l'estensione di LLVM TableGen, quindi per il riconoscimento esterno conviene `.triad`).

**Come verifico che un programma sia Core "puro"?** Eseguilo con l'interprete JS e controlla
di non usare primitivi di bootstrap se deve valere anche per Full; per i casi normativi
aggiungilo alla conformance Core.

**Perché `selfhost/*.td` falliscono con l'interprete JS?** Usano `get(xs, i)`, helper non
standard del seed Windows; vanno eseguiti con `seed.exe`.

**Dove propongo una modifica al linguaggio?** Nello standard (`SPEC.md`/`SPEC-CORE.md`) con
voce in `CHANGELOG.md` e casi di conformance; poi nelle implementazioni.

---

Wiki mantenuta insieme allo standard: quando cambia `SPEC.md`, `SPEC-CORE.md`, il runtime o gli
strumenti, aggiorna il capitolo corrispondente. Gli esempi Core marcati **Output:** si
verificano eseguendoli con `node seed/dev/triad_core.cjs`.

---

← [Parte IV Codice del progetto](Parte-IV-Codice-del-progetto) · [Home](Home)
