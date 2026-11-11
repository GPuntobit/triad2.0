# Capitolo 16 — Codice come dato e macro

Nella tradizione Lisp un programma è fatto della stessa materia dei dati che manipola. Triad-Full
riprende quest'idea: il codice si può catturare come valore, ispezionare, costruire e rieseguire.
Su questa base poggiano le **macro**, funzioni che scrivono codice.

## 16.1 L'albero uniforme

Il parser di Triad non produce decine di tipi di nodo diversi: produce un solo tipo, `Node`, con
una testa (`head`, un simbolo che dice che cosa è il nodo) e una lista di argomenti (`args`).
Gli operatori sono chiamate, i blocchi sono nodi `block`, perfino `fact` e `solve` sono nodi.
Alcuni esempi, in notazione S-expression:

| sintassi | albero |
|---|---|
| `a + b`, `f(a, b)` | `(call + a b)`, `(call f a b)` |
| `x = e` | `(assign x e)` |
| `a.x`, `xs[i]` | `(dot a x)`, `(index xs i)` |
| `if c a else b end` | `(if c (block a) (block b))` |
| `x -> e` | `(lambda (tuple x) e)` |
| `fact t`, `rule h :- g` | `(fact t)`, `(rule h g)` |

L'elenco completo è in `SPEC.md` §3 (appendice [Documenti](Doc-SPEC)). Avere un solo tipo di
nodo significa che uno stesso piccolo insieme di operazioni basta per esplorare e trasformare
qualunque programma.

## 16.2 Quote, unquote, eval

`:( espressione )` non valuta l'espressione: la restituisce come albero, un valore di tipo `Expr`.

```julia
c = :(a.x + f(b, 2))
c.head        # :call
sexpr(c)      # "(call + (dot a x) (call f b 2))"
```

Dentro un'espressione quotata, `$` fa l'opposto: valuta subito ciò che segue e ne inserisce il
valore nell'albero. `eval` esegue un albero:

```julia
n = 7
quadrato = :($n * $n)     # l'albero di 7 * 7
eval(quadrato)            # 49
```

`parse(testo)` trasforma una stringa in albero, `unparse(albero)` fa il contrario, `Expr(:call,
:f, 1)` costruisce un nodo a mano, `quote … end` quota un intero blocco.

## 16.3 Codice che genera codice

Con questi strumenti un programma può costruire altri programmi. Questa funzione costruisce
l'albero di un polinomio a partire dai coefficienti:

```julia
function poly(coeffs)
    acc = :(0)
    i = 0
    for c in coeffs
        acc = :($acc + $c * x ^ $i)
        i += 1
    end
    acc
end
p = poly([1, 2, 3])   # :(0 + 1 * x ^ 0 + 2 * x ^ 1 + 3 * x ^ 2)
x = 2
eval(p)               # 17
```

## 16.4 Macro

Una **macro** è una funzione che riceve codice non valutato e restituisce codice, che prende il
posto della chiamata prima dell'esecuzione. Si definisce con `macro` e si invoca con `@`:

```julia
macro unless(c, body)
    :(if !$c; $body; end)
end
@unless(x < y, println("x non è minore di y"))
```

`@unless(…)` viene sostituita dall'`if` costruito dalla macro. Le macro di Triad non sono
**igieniche**: i nomi introdotti dalla macro possono scontrarsi con quelli del codice che la
usa. Per evitarlo si generano nomi freschi con `gensym`:

```julia
macro swap(a, b)
    tmp = gensym(:tmp)
    quote
        $tmp = $a
        $a = $b
        $b = $tmp
    end
end
```

L'espansione delle macro è **pura**: una macro non deve stampare o modificare lo stato, solo
calcolare codice.

L'esempio `examples/macro.td` raccoglie questi temi; il suo output di riferimento è:

```text
codice:  :(a.x + f(b, 2))
head:    call
args:    [:+, :(a.x), :(f(b, 2))]
sexpr:   (call + (dot a x) (call f b 2))
:(7 * 7) = 49
parse:   (if (call > x 0) (block (sym pos)) (block (sym neg)))
unparse: if x > 0; :pos; else; :neg; end
dopo @swap: x = 2, y = 1
x non è minore di y
somma -> 5050
polinomio: :(0 + 1 * x ^ 0 + 2 * x ^ 1 + 3 * x ^ 2)
p(2) = 17
```

## Riepilogo

- Il parser produce un solo tipo di nodo, `Node(head, args)`.
- `:( … )` quota, `$` inserisce valori, `eval` esegue; `parse`/`unparse`/`sexpr` convertono.
- Le macro trasformano codice in codice; non sono igieniche, quindi si usa `gensym`.

## Esercizi

1. Scrivi una macro `@twice(e)` che esegua `e` due volte.
2. Costruisci con `Expr` l'albero di `f(1, 2)` e confrontalo con `:(f(1, 2))`.
3. Perché `@swap` senza `gensym` fallirebbe se una delle variabili si chiamasse `tmp`?
<!-- nav -->

---

← [Capitolo 15 — Programmazione logica](Libro-15-Logica) · [Sommario](Home) · [Capitolo 17 — Garanzie, costrutti Full e interfaccia](Libro-17-Garanzie-e-interfaccia) →
