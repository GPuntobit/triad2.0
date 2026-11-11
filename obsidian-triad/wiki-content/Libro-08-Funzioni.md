# Capitolo 8 — Funzioni e ricorsione

Le funzioni sono il modo in cui un programma dà un nome a un'idea e la riusa. In Triad sono anche
valori di prima classe, ma questo aspetto è materia del capitolo 9; qui ci concentriamo su come
si definiscono, come si chiamano e su una tecnica che in Core è fondamentale: la ricorsione.

## 8.1 Due forme di definizione

La **forma breve** è adatta alle funzioni che si riducono a un'espressione:

```julia
quadrato(x) = x * x
ipotenusa2(a, b) = quadrato(a) + quadrato(b)
println(ipotenusa2(3, 4))
```

Output:

```text
25
```

La **forma a blocco** ammette un corpo di più istruzioni; il valore restituito è quello
dell'ultima:

Calcoliamo, per esempio, la media intera di tre numeri. In un altro linguaggio si scriverebbe
`(a + b + c) / 3`, ma Core non ha `/`: il quoziente si calcola con un ciclo di sottrazioni. È un
buon promemoria di che cosa significhi programmare con un vocabolario ridotto, e di come le
funzioni permettano di costruirsi il vocabolario mancante:

```julia
function quoziente(a, b)
    q = 0
    while a >= b
        a -= b
        q += 1
    end
    q
end
function media_intera(a, b, c)
    quoziente(a + b + c, 3)
end
println(media_intera(4, 8, 10))
```

Output:

```text
7
```

Esiste anche una terza forma, la funzione **anonima** `function (a, b) … end`, che si assegna a
una variabile come qualunque valore: `moltiplica = function (a, b) a * b end`.

## 8.2 Parametri e chiamata

Una funzione si chiama scrivendo il suo nome seguito dagli argomenti tra parentesi, **senza
spazio** prima della parentesi. Il numero di argomenti deve coincidere con quello dei
parametri, altrimenti l'esecuzione si ferma con un errore di arità. Non esistono parametri
facoltativi né con nome in Core.

Dentro la funzione, i parametri sono variabili locali, inizializzate con i valori degli
argomenti. Assegnare un parametro (come fa `quoziente` con `a -= b`) modifica la copia locale,
non la variabile del chiamante: gli interi, le stringhe e gli altri valori semplici vengono
passati "per valore". Le liste fanno eccezione, perché vengono passate per riferimento: il
capitolo 10 spiega le conseguenze.

## 8.3 `return`

`return espressione` termina la funzione subito, restituendo quel valore; `return` da solo
restituisce `nothing`. Serve soprattutto per le **uscite anticipate**, quando un caso
particolare si risolve prima di arrivare in fondo:

```julia
function primo_negativo(xs)
    i = 1
    while i <= length(xs)
        if xs[i] < 0
            return i
        end
        i += 1
    end
    nothing
end
println(primo_negativo([3, 5, -2, 8]), " ", primo_negativo([1, 2]))
```

Output:

```text
3 nothing
```

## 8.4 L'ordine conta

Una funzione esiste dal momento in cui la sua definizione viene eseguita. Chiamarla più in alto
nel file è un errore (`undefined variable`). Una funzione può però chiamare se stessa nel
proprio corpo, perché quando il corpo viene eseguito la definizione è già avvenuta: è questo
che rende possibile la ricorsione.

## 8.5 Pensare ricorsivo

Una funzione è **ricorsiva** quando, per risolvere un problema, si chiama su un problema più
piccolo dello stesso tipo. Ogni funzione ricorsiva ha due ingredienti:

- un **caso base**, abbastanza semplice da risolversi direttamente;
- un **caso ricorsivo**, che riduce il problema e si fida che la chiamata su quello più piccolo
  dia la risposta giusta.

```julia
fattoriale(n) = n < 2 ? 1 : n * fattoriale(n - 1)
fib(n) = n < 2 ? n : fib(n - 1) + fib(n - 2)
mcd(a, b) = b == 0 ? a : mcd(b, a % b)
println(fattoriale(10), " ", fib(20), " ", mcd(1071, 462))
```

Output:

```text
3628800 6765 21
```

Prendiamo `mcd`, l'algoritmo di Euclide. Il caso base è `b == 0`: il massimo comun divisore di
`a` e `0` è `a`. Il caso ricorsivo si basa su un fatto matematico: il MCD di `a` e `b` è uguale
al MCD di `b` e del resto di `a` diviso `b`. Ogni chiamata riduce il secondo argomento, che
prima o poi arriva a zero.

`fib`, invece, mostra un rischio: ogni chiamata ne genera due, e il numero totale di chiamate
cresce esponenzialmente con `n`. `fib(20)` è ancora istantaneo, `fib(35)` sarebbe molto lento.
Quando la ricorsione rifà più volte lo stesso lavoro, conviene trasformarla in un ciclo:

```julia
function fib_veloce(n)
    a = 0
    b = 1
    while n > 0
        t = a + b
        a = b
        b = t
        n -= 1
    end
    a
end
println(fib_veloce(90))
```

Output:

```text
2880067194370816120
```

> **Ricorsione e profondità.** Ogni chiamata ricorsiva occupa memoria finché non termina. Per
> ricorsioni molto profonde (migliaia di livelli) un ciclo è più sicuro. Triad-Full promette di
> trasformare la ricorsione infinita in un `Err(:budget)` invece che in un crash; in Core vale
> la regola del buon senso.

## 8.6 L'annotazione `!io`

In Triad-Full una funzione che stampa deve dichiararlo con `!io` dopo i parametri. Core accetta
l'annotazione e la ignora: scriverla fin da ora rende il codice pronto per Full e documenta
l'intenzione.

```julia
function saluta(nome) !io
    println("ciao, " * nome)
end
saluta("mondo")
```

Output:

```text
ciao, mondo
```

## Riepilogo

- Forma breve `f(x) = e`, forma a blocco `function f(x) … end`, anonima `function (x) … end`.
- Il valore di una funzione è l'ultima espressione eseguita; `return` serve per uscire prima.
- Gli argomenti devono essere esattamente quanti i parametri; una funzione esiste dopo la sua
  definizione.
- La ricorsione richiede un caso base e un caso che riduca il problema; se ripete lavoro, meglio
  un ciclo.

## Esercizi

1. Scrivi `potenza(b, e)` ricorsiva senza usare `^`.
2. Scrivi `cifre(n)` che conti le cifre decimali di un intero positivo (usa `%` e un ciclo per
   dividere per 10).
3. Scrivi `hanoi(n, da, a, via)` che stampi le mosse della torre di Hanoi con `n` dischi.
<!-- nav -->

---

← [Capitolo 7 — Decidere e ripetere](Libro-07-Controllo-del-flusso) · [Sommario](Home) · [Capitolo 9 — Lambda, chiusure e visibilità dei nomi](Libro-09-Chiusure-e-scope) →
