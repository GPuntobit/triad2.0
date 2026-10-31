# Capitolo 10 — Liste e dati strutturati

Triad-Core non ha array tipizzati, dizionari, record o oggetti. Ha una sola struttura dati
composta, la **lista**, ed è sorprendente quanto si possa costruire con essa. Questo capitolo
mostra le operazioni sulle liste e poi tre modi di usarle per rappresentare dati strutturati:
record, tabelle associative e pile.

## 10.1 Costruire e leggere

Una lista si scrive tra parentesi quadre: `[1, 2, 3]`, `[]` (vuota), `[1, "due", :tre, [4]]`
(mista e annidata). Si legge un elemento con l'**indice**, che parte da **1**:

```julia
xs = [10, 20, 30]
println(xs[1], " ", xs[3], " ", length(xs))
```

Output:

```text
10 30 3
```

Leggere fuori dai limiti (`xs[0]` o `xs[4]` qui) è un errore di esecuzione. Gli indici da 1
sono la convenzione di Julia e della matematica; chi viene da C o Python deve abituarsi a
scrivere i cicli come `i = 1 … while i <= length(xs)`.

## 10.2 Modificare

Le liste sono **mutabili**. Si può cambiare un elemento con un assegnamento indicizzato e
aggiungere elementi in coda con `push!`:

```julia
xs = [1, 2, 3]
xs[2] = 200
xs[1] += 100
push!(xs, 4)
println(xs)
```

Output:

```text
[101, 200, 3, 4]
```

`push!` modifica la lista che riceve e la restituisce; il punto esclamativo nel nome è proprio
il segnale di questa modifica.

## 10.3 Riferimenti: due nomi, una lista

Quando si assegna una lista a un'altra variabile, o la si passa a una funzione, **non** se ne fa
una copia: entrambi i nomi indicano la stessa lista.

```julia
a = [1, 2]
b = a
push!(b, 3)
println(a)
function svuota_primo!(xs)
    xs[1] = 0
end
svuota_primo!(a)
println(b)
```

Output:

```text
[1, 2, 3]
[0, 2, 3]
```

È il comportamento più utile (copiare liste grandi a ogni chiamata sarebbe costoso) e anche
quello che permette a una funzione di "restituire" più risultati modificando una lista
ricevuta. Ma è anche fonte di errori quando non lo si tiene presente. Per avere una copia
indipendente la si costruisce elemento per elemento.

> **Liste e funzioni nominate.** Il capitolo 9 ha mostrato che una funzione nominata non può
> riassegnare una variabile globale. Può però *modificare il contenuto* di una lista globale,
> perché non sta riassegnando il nome, sta cambiando l'oggetto a cui il nome si riferisce. Una
> lista di un elemento, `stato = [0]`, è il modo più semplice di avere un contatore condiviso.

## 10.4 Percorrere

Lo schema di iterazione è sempre lo stesso: un indice, un `while`, un incremento. Con esso si
scrivono le operazioni che Triad-Full offre già pronte. Ecco `filtra` e `riduci`:

```julia
function filtra(p, xs)
    out = []
    i = 1
    while i <= length(xs)
        if p(xs[i])
            push!(out, xs[i])
        end
        i += 1
    end
    out
end
function riduci(f, acc, xs)
    i = 1
    while i <= length(xs)
        acc = f(acc, xs[i])
        i += 1
    end
    acc
end
numeri = [3, 8, 1, 9, 4]
println(filtra(x -> x > 3, numeri))
println(riduci((a, b) -> a + b, 0, numeri))
println(riduci((a, b) -> a > b ? a : b, numeri[1], numeri))
```

Output:

```text
[8, 9, 4]
25
9
```

`riduci` merita un commento: combina gli elementi uno alla volta con un accumulatore. Con la
somma come funzione calcola il totale; con "il maggiore dei due" calcola il massimo. Somma,
massimo, conteggio, concatenazione sono tutti casi particolari della stessa idea.

## 10.5 Record come liste etichettate

Senza `struct`, un dato con più campi si rappresenta come una lista il cui primo elemento è un
simbolo che ne dichiara la natura. Le funzioni di accesso danno un nome ai campi e nascondono la
posizione:

```julia
persona(nome, eta) = [:Persona, nome, eta]
nome_di(p) = p[2]
eta_di(p) = p[3]
is_persona(v) = typeof(v) == :List && length(v) == 3 && v[1] == :Persona
anna = persona("Anna", 34)
println(nome_di(anna), " ha ", eta_di(anna), " anni; record? ", is_persona(anna))
```

Output:

```text
Anna ha 34 anni; record? true
```

È esattamente la tecnica che `SPEC-CORE.md` prevede per S1: le struct di Triad-Full saranno
rappresentate, dentro l'interprete scritto in Core, come liste etichettate.

## 10.6 Tabelle associative

Una tabella che associa chiavi a valori si può rappresentare come una lista piatta di coppie
alternate, `[chiave1, valore1, chiave2, valore2, …]`. È la struttura usata per l'ambiente delle
variabili negli interpreti di `selfhost/`:

```julia
function tab_get(t, k)
    i = 1
    while i < length(t)
        if t[i] == k
            return t[i + 1]
        end
        i += 2
    end
    nothing
end
function tab_set!(t, k, v)
    i = 1
    while i < length(t)
        if t[i] == k
            t[i + 1] = v
            return t
        end
        i += 2
    end
    push!(t, k)
    push!(t, v)
end
voti = []
tab_set!(voti, :anna, 28)
tab_set!(voti, :luca, 30)
tab_set!(voti, :anna, 30)
println(voti, " ", tab_get(voti, :anna), " ", tab_get(voti, :zoe))
```

Output:

```text
[:anna, 30, :luca, 30] 30 nothing
```

La ricerca è lineare: per tabelle piccole va benissimo, per tabelle grandi servirebbe una
struttura più furba (un albero, una tabella hash), che si può comunque costruire con le liste.

## 10.7 Pile

Una pila (stack) è una lista a cui si aggiunge e si toglie dalla stessa estremità. Core ha
`push!` ma non `pop!`; il "togliere" si ottiene tenendo a parte l'altezza della pila:

```julia
pila = [[], 0]
function spingi!(p, v)
    if p[2] < length(p[1])
        p[1][p[2] + 1] = v
    else
        push!(p[1], v)
    end
    p[2] += 1
end
function estrai!(p)
    v = p[1][p[2]]
    p[2] -= 1
    v
end
spingi!(pila, :a)
spingi!(pila, :b)
spingi!(pila, :c)
println(estrai!(pila), " ", estrai!(pila))
spingi!(pila, :d)
println(estrai!(pila), " ", estrai!(pila))
```

Output:

```text
c b
d a
```

Le pile sono lo strumento con cui gli interpreti valutano le espressioni e gestiscono le
chiamate: le ritroveremo parlando del seed.

## Riepilogo

- Le liste si indicizzano da 1, sono mutabili e vengono condivise per riferimento.
- `push!` aggiunge in coda e restituisce la lista; `length` ne dà la lunghezza.
- Con un indice e un `while` si scrivono `map`, `filtra`, `riduci` e ogni altra operazione.
- Record, tabelle e pile si rappresentano con liste e funzioni di accesso.

## Esercizi

1. Scrivi `inverti(xs)` che restituisca una nuova lista con gli elementi in ordine inverso.
2. Scrivi `copia(xs)` che restituisca una copia indipendente (anche delle liste annidate).
3. Ordina una lista di interi con l'ordinamento per inserzione, modificandola sul posto.
<!-- nav -->

---

← [Capitolo 9 — Lambda, chiusure e visibilità dei nomi](Libro-09-Chiusure-e-scope) · [Sommario](Home) · [Capitolo 11 — Stringhe, simboli e byte](Libro-11-Stringhe-e-byte) →
