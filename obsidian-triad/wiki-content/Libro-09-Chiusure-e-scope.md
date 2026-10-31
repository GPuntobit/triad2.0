# Capitolo 9 — Lambda, chiusure e visibilità dei nomi

Nel capitolo 5 abbiamo detto che le funzioni sono valori. Questo capitolo prende sul serio
quell'affermazione: vedremo funzioni create al volo, passate come argomenti, restituite da altre
funzioni, e il meccanismo, le **chiusure**, che permette loro di ricordare l'ambiente in cui sono
nate. Per capirlo fino in fondo bisogna prima chiarire una questione che finora abbiamo
rimandato: dove è visibile un nome, e che cosa succede quando lo si assegna.

## 9.1 Lambda

Una **lambda** è una funzione anonima scritta in forma compatta con la freccia `->`:

```julia
doppio = x -> x * 2
somma = (a, b) -> a + b
println(doppio(21), " ", somma(2, 3))
```

Output:

```text
42 5
```

A sinistra della freccia ci sono i parametri (tra parentesi se sono più di uno), a destra il
corpo, che è un'unica espressione. Se servono più istruzioni si usa `begin … end`, oppure la
forma `function (…) … end`. Le lambda senza parametri, `() -> …`, non sono ammesse dalla
grammatica di Core: al loro posto si usa `function () … end`.

## 9.2 Funzioni come argomenti

Poiché una funzione è un valore, la si può passare a un'altra funzione. Questo permette di
separare *che cosa* fare da *come* iterare:

```julia
function applica_a_tutti(f, xs)
    out = []
    i = 1
    while i <= length(xs)
        push!(out, f(xs[i]))
        i += 1
    end
    out
end
println(applica_a_tutti(x -> x * x, [1, 2, 3, 4]))
println(applica_a_tutti(x -> x > 2, [1, 2, 3, 4]))
```

Output:

```text
[1, 4, 9, 16]
[false, false, true, true]
```

`applica_a_tutti` non sa nulla di quadrati o confronti: sa solo percorrere una lista. Il lavoro
vero lo fa la funzione ricevuta. È l'idea dietro `map`, che Triad-Full fornisce già pronta e che
in Core si scrive così, una volta per tutte.

## 9.3 Funzioni che creano funzioni

Il passo successivo è una funzione che **restituisce** una funzione:

```julia
function sommatore(n)
    x -> x + n
end
piu10 = sommatore(10)
piu100 = sommatore(100)
println(piu10(5), " ", piu100(5), " ", piu10(1))
```

Output:

```text
15 105 11
```

Qui accade qualcosa di notevole. Quando `sommatore(10)` termina, il suo parametro `n` dovrebbe
sparire, come tutte le variabili locali. Eppure `piu10`, chiamata molto dopo, sa ancora che `n`
vale 10. La lambda ha **catturato** l'ambiente in cui è stata creata: insieme al codice, porta
con sé i nomi che quel codice usa. Una funzione con il suo ambiente catturato si chiama
**chiusura**. `piu10` e `piu100` condividono il codice ma hanno ambienti diversi.

## 9.4 Chiusure con stato

Lo standard Core stabilisce che le variabili catturate sono **condivise**: se la chiusura le
modifica, la modifica persiste tra una chiamata e l'altra. Questo permette di costruire funzioni
con memoria:

```julia
function crea_contatore()
    conteggio = 0
    passo -> begin
        conteggio += passo
        conteggio
    end
end
c = crea_contatore()
c(1)
c(1)
println(c(10))
d = crea_contatore()
println(d(1))
```

Output:

```text
12
1
```

Ogni chiamata a `crea_contatore` crea una nuova variabile `conteggio` e una nuova chiusura che
la custodisce; `c` e `d` sono contatori indipendenti. È un modo elegante di avere stato privato
senza oggetti né variabili globali.

> **Attenzione al seed.** Il seed Windows, oggi, cattura le variabili *per valore* e solo l'ultimo
> legame dell'ambiente: un contatore come questo può non funzionare lì. L'interprete di
> riferimento segue lo standard. Il capitolo 12 riassume tutte le differenze.

## 9.5 Le regole di visibilità

Arriviamo alla questione rimandata. Triad usa uno **scope lessicale**: la visibilità di un nome
dipende da dove è scritto nel testo del programma, non da chi chiama chi durante l'esecuzione.
Le regole di Core sono cinque.

1. `function`, lambda, `let` e `while` introducono un nuovo ambiente. Un nome è visibile
   nell'ambiente in cui è legato e in tutti quelli annidati al suo interno.
2. **Dentro una funzione nominata, l'assegnamento crea una variabile locale.** Anche se esiste
   una variabile globale con lo stesso nome, la funzione non la modifica.
3. **Dentro una lambda, assegnare un nome già esistente all'esterno aggiorna quel nome.** È la
   regola che fa funzionare il contatore del paragrafo precedente.
4. Al livello più esterno (il *top level*), anche i cicli aggiornano le variabili globali.
5. `let x = …` crea sempre una `x` nuova; assegnare `x` dentro il `let` modifica quella nuova.

La regola 2 sorprende chi viene da linguaggi in cui le funzioni possono modificare i globali:

```julia
totale = 0
function aggiungi(n)
    totale += n
    totale
end
println(aggiungi(5))
println(totale)
```

Output:

```text
5
0
```

Dentro `aggiungi`, `totale += n` legge il `totale` globale (0) e crea un `totale` **locale**
che vale 5; il globale resta 0. È una scelta deliberata: una funzione nominata non può alterare
di nascosto lo stato del programma, e questo rende il codice più facile da ragionare (e prepara
il terreno agli effetti dichiarati di Full).

> **Come condividere stato, allora?** In tre modi: restituendo il nuovo valore e lasciando al
> chiamante l'assegnamento (il più chiaro); usando una lista, che è mutabile e viene passata per
> riferimento (capitolo 10); usando una chiusura, come il contatore.

## Riepilogo

- Le lambda (`x -> e`, `(a, b) -> e`) sono funzioni anonime; per più istruzioni si usa `begin`.
- Le funzioni si passano come argomenti e si restituiscono come risultati.
- Una chiusura cattura l'ambiente in cui nasce; in Core le variabili catturate sono condivise.
- Lo scope è lessicale; le funzioni nominate assegnano in locale, le lambda possono aggiornare
  i nomi esterni.

## Esercizi

1. Scrivi `componi(f, g)` che restituisca la funzione `x -> f(g(x))` e provala con due lambda.
2. Scrivi `crea_accumulatore()` che restituisca una lambda che aggiunge un elemento a una lista
   interna e restituisce la lista.
3. Spiega, con le regole del paragrafo 9.5, che cosa stampa un programma in cui una funzione
   nominata assegna una variabile globale e poi la stampa.
<!-- nav -->

---

← [Capitolo 8 — Funzioni e ricorsione](Libro-08-Funzioni) · [Sommario](Home) · [Capitolo 10 — Liste e dati strutturati](Libro-10-Liste) →
