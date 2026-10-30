# Capitolo 7 — Decidere e ripetere

Un programma che esegue sempre le stesse istruzioni nello stesso ordine sa fare poco. Il
**controllo del flusso** gli permette di scegliere tra strade diverse e di ripetere un lavoro
finché serve. Triad-Core offre cinque costrutti: `if`, `while`, `let`, `begin` e il ternario già
visto. Hanno tutti una caratteristica in comune che li distingue da molti linguaggi: sono
**espressioni**, e hanno un valore.

## 7.1 `if`, `elseif`, `else`

La forma completa è:

```julia
function classifica(t)
    if t < 0
        "gelo"
    elseif t < 15
        "freddo"
    elseif t < 25
        "mite"
    else
        "caldo"
    end
end
println(classifica(-3), " ", classifica(10), " ", classifica(20), " ", classifica(30))
```

Output:

```text
gelo freddo mite caldo
```

Le condizioni vengono valutate **nell'ordine**, e si esegue solo il ramo della prima vera; se
nessuna lo è, si esegue `else`, se c'è. I rami `elseif` e `else` sono facoltativi; `end` chiude
sempre l'intero costrutto.

Si noti che la funzione `classifica` non contiene nessun `return`: restituisce il valore
dell'`if`, che a sua volta vale il valore dell'ultima espressione del ramo eseguito. Questo è il
senso di "`if` è un'espressione". Se nessun ramo viene eseguito (un `if` senza `else` con
condizione falsa), il valore è `nothing`.

L'`if` si può anche scrivere su una riga e usare a destra di un assegnamento:

```julia
temperatura = 30
giudizio = if temperatura > 25 :caldo else :fresco end
println(giudizio)
```

Output:

```text
caldo
```

## 7.2 `while`

`while condizione … end` ripete il corpo finché la condizione è vera. La condizione viene
valutata **prima** di ogni giro: se è falsa subito, il corpo non viene mai eseguito.

```julia
# somma dei numeri da 1 a 100
i = 1
somma = 0
while i <= 100
    somma += i
    i += 1
end
println(somma)
```

Output:

```text
5050
```

Lo schema "variabile contatore, condizione, incremento in fondo al corpo" è il modo canonico di
iterare in Core, che non ha il ciclo `for` (lo ha Triad-Full). L'errore più comune è dimenticare
l'incremento: il ciclo non finisce più.

## 7.3 `break` e `continue`

Dentro un `while`, `break` esce immediatamente dal ciclo e `continue` salta al giro successivo
(rivalutando la condizione). Agiscono sempre sul ciclo **più interno**.

```julia
# il primo multiplo di 7 maggiore di 50, e la somma dei dispari fino a 9
n = 51
while true
    if n % 7 == 0
        break
    end
    n += 1
end
println(n)
i = 0
s = 0
while i < 9
    i += 1
    if i % 2 == 0
        continue
    end
    s += i
end
println(s)
```

Output:

```text
56
25
```

`while true … end` con un `break` all'interno è lo schema per i cicli la cui condizione d'uscita
si scopre solo a metà del corpo.

## 7.4 `let`: uno spazio di nomi locale

`let` introduce nomi che esistono **solo al suo interno**:

```julia
x = 1
let x = 10, y = 20
    println(x + y)
end
println(x)
```

Output:

```text
30
1
```

Il `let` crea una nuova `x` che "copre" quella esterna (si dice che la *oscura*). All'uscita dal
`let`, la `x` interna scompare e quella esterna è intatta. È utile per calcoli intermedi che non
devono sporcare il resto del programma. Anche il `let` è un'espressione: vale l'ultima
espressione del suo corpo.

## 7.5 `begin`: raggruppare

`begin … end` raggruppa più istruzioni in un'unica espressione, il cui valore è quello
dell'ultima. A differenza di `let` non crea nomi nuovi: serve dove la grammatica si aspetta una
sola espressione ma si vuole fare più di una cosa, come nel corpo di una lambda (capitolo 9).

```julia
r = begin
    a = 6
    b = 7
    a * b
end
println(r)
```

Output:

```text
42
```

## 7.6 Tutto ha un valore

Riassumendo il filo del capitolo: `if` vale il ramo eseguito, `let` e `begin` l'ultima
espressione, un blocco vuoto `nothing`. Un `while` vale `nothing`. Questa uniformità ha un
vantaggio pratico (meno `return`, funzioni più compatte) e uno concettuale: il linguaggio ha una
sola categoria sintattica, l'espressione, e quindi meno regole da ricordare.

## Riepilogo

- `if`/`elseif`/`else` esegue il primo ramo vero e ne restituisce il valore.
- `while` ripete finché la condizione è vera; `break` esce, `continue` passa al giro successivo.
- `let` crea nomi locali che oscurano quelli esterni; `begin` raggruppa senza creare nomi.
- Ogni costrutto è un'espressione con un valore.

## Esercizi

1. Scrivi `fizzbuzz(n)` che stampi i numeri da 1 a `n`, sostituendo i multipli di 3 con `Fizz`,
   di 5 con `Buzz` e di entrambi con `FizzBuzz`.
2. Con `while` e `break`, trova il più piccolo `n` tale che `n * n > 1000`.
3. Che cosa vale `if false 1 end`? Verifica stampandolo.
<!-- nav -->

---

← [Capitolo 6 — Espressioni, operatori e variabili](Libro-06-Espressioni) · [Sommario](Home) · [Capitolo 8 — Funzioni e ricorsione](Libro-08-Funzioni) →
