# Capitolo 15 — Programmazione logica

C'è un modo di programmare in cui non si dice al computer *come* trovare una risposta, ma *che
cosa* è vero, e si lascia a lui il compito di cercare. È la programmazione logica, la tradizione
di Prolog, e in Triad-Full è parte integrante del linguaggio.

## 15.1 Fatti

Un **fatto** dichiara che una relazione vale tra certi termini:

```julia
fact parent(:tom, :bob)
fact parent(:tom, :liz)
fact parent(:bob, :ann)
fact parent(:bob, :pat)
fact parent(:pat, :jim)
```

`parent` è un **predicato**; `:tom` e `:bob` sono termini (qui simboli). L'insieme dei fatti e
delle regole forma la **base di conoscenza**.

## 15.2 Domande: `solve` e le variabili logiche

Per interrogare la base di conoscenza si usa `solve` con un **goal** che contiene variabili
logiche, scritte con `?` attaccato al nome:

```julia
figli_di_tom = solve parent(:tom, ?figlio)
# [{figlio = :bob}, {figlio = :liz}]
[s.figlio for s in figli_di_tom]     # [:bob, :liz]
```

Il risultato di `solve` è una **lista di soluzioni**. Ogni soluzione è un valore di tipo
`Solution` che associa a ogni variabile il termine che la rende vera; si legge con
`s.figlio` o `s[:figlio]`, e `vars(s)` elenca le variabili legate. È una differenza importante
rispetto a Prolog: in Triad la ricerca logica non stampa nulla e non vive in un mondo separato,
produce un valore che il resto del programma può usare.

## 15.3 Regole

Una **regola** dichiara che una relazione vale *se* valgono altre relazioni:

```julia
rule grandparent(?x, ?z) :- parent(?x, ?y), parent(?y, ?z)
rule ancestor(?a, ?d) :- parent(?a, ?d)
rule ancestor(?a, ?d) :- parent(?a, ?x), ancestor(?x, ?d)
```

Si legge: "`?x` è nonno di `?z` se `?x` è genitore di un certo `?y` e `?y` è genitore di `?z`".
La virgola significa "e". Le due regole di `ancestor` mostrano la ricorsione logica: un antenato
è un genitore, oppure il genitore di un antenato.

## 15.4 Come funziona la ricerca

Per risolvere un goal il motore prova, nell'ordine, i fatti e le regole il cui capo può
**unificarsi** con il goal. Unificare due termini significa trovare valori per le variabili che li
rendono uguali: `parent(:tom, ?figlio)` si unifica con `parent(:tom, :bob)` legando `?figlio` a
`:bob`. Se una regola ha un corpo, i suoi goal diventano nuovi sotto-problemi. Quando una strada
fallisce, il motore **torna indietro** (backtracking) all'ultima scelta e prova l'alternativa
successiva. Ogni strada che arriva in fondo produce una soluzione.

L'unificazione di Triad fa l'**occurs-check**: rifiuta di legare una variabile a un termine che la
contiene, come in `?x = f(?x)`. Senza questo controllo si otterrebbero strutture infinite; con
esso, `solve ?x = f(?x)` semplicemente non ha soluzioni.

Il motore è iterativo, non usa la ricorsione dell'implementazione ospite, e per questo una
ricerca troppo lunga si può limitare con un budget invece di esaurire la memoria.

## 15.5 Opzioni della ricerca

`solve` accetta alcune parole chiave contestuali:

| opzione | effetto |
|---|---|
| `limit n` | al massimo `n` soluzioni |
| `depth d` | profondità massima della ricerca |
| `steps s` | passi massimi (default 1 000 000); oltre, `Err(:budget)` |
| `trace` | restituisce anche la traccia degli eventi (capitolo 17) |

```julia
solve ancestor(:tom, ?d) limit 3
```

## 15.6 Goal composti e aritmetica

Un goal può essere più di un predicato: `g1 && g2` o `(g1, g2)` per la congiunzione, `g1 || g2`
per la disgiunzione, `!g` o `not(g)` per la negazione, `a = b` per l'unificazione esplicita,
`?y is espressione` per calcolare un valore, i confronti, e perfino una funzione Triad che
restituisce un `Bool`. L'operatore `is` collega la logica all'aritmetica:

```julia
fact edge(:a, :b, 2)
fact edge(:b, :c, 3)
rule path(?x, ?y, ?c) :- edge(?x, ?y, ?c)
rule path(?x, ?y, ?c) :- edge(?x, ?z, ?c1), path(?z, ?y, ?c2), ?c is ?c1 + ?c2
(solve path(:a, :c, ?costo))[1].costo     # 5
```

## 15.7 Predicati come funzioni e negazione

Un predicato si può anche chiamare come una funzione: restituisce `true` se il goal ha almeno
una soluzione. Questo permette di usare la logica dentro il codice ordinario, per esempio in un
`if` o in un `filter`. Unito alla variabile anonima `?_` (ogni occorrenza è una variabile nuova),
dà la **negazione per fallimento**:

```julia
persone = [:tom, :bob, :liz, :ann, :pat, :jim]
senza_figli = filter(p -> !parent(p, ?_), persone)   # [:liz, :ann, :jim]
```

"Non ha figli" significa "il goal `parent(p, ?_)` fallisce".

## 15.8 Liste alla maniera di Prolog

Nei termini logici una lista si può scomporre in testa e coda con `[?h | ?t]`. La classica
relazione `app` (append) funziona in tutte le direzioni: concatena due liste, ma sa anche
enumerare tutti i modi di spezzarne una.

```julia
rule app([], ?l, ?l)
rule app([?h | ?t], ?l, [?h | ?r]) :- app(?t, ?l, ?r)
(solve app([1, 2], [3], ?r))[1].r          # [1, 2, 3]
length(solve app(?a, ?b, [1, 2, 3]))       # 4
```

L'esempio `examples/famiglia.td` sviluppa tutti questi temi; il suo output di riferimento è:

```text
discendenti di tom: [:bob, :liz, :ann, :pat, :jim]
fratelli di ann: [:pat]
madri: ["pat -> jim"]
senza figli: [:liz, :ann, :jim]
over 50: [:tom, :bob]
modi di spezzare [1, 2, 3]:
  [] ++ [1, 2, 3]
  [1] ++ [2, 3]
  [1, 2] ++ [3]
  [1, 2, 3] ++ []
figli di bob: [:ann, :pat]
```

Il sorgente completo è nell'appendice [Sorgenti degli esempi](Sorgenti-esempi).

## Riepilogo

- `fact` e `rule` costruiscono la base di conoscenza; `solve` restituisce una lista di soluzioni.
- La ricerca unifica (con occurs-check) e torna indietro quando fallisce.
- `limit`, `depth`, `steps`, `trace` controllano la ricerca; `is` calcola valori.
- I predicati si usano come funzioni booleane; `!p(…, ?_)` è la negazione per fallimento.

## Esercizi

1. Aggiungi alla famiglia la regola `fratello(?a, ?b)` (stesso genitore, persone diverse).
2. Scrivi la regola `lunghezza(?lista, ?n)` con `is`.
3. Spiega perché `solve ?x = f(?x)` non ha soluzioni.
<!-- nav -->

---

← [Capitolo 14 — Tipi, struct e multiple dispatch](Libro-14-Tipi-e-dispatch) · [Sommario](Home) · [Capitolo 16 — Codice come dato e macro](Libro-16-Codice-come-dato) →
