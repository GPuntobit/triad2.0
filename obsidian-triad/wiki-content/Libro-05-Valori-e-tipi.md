# Capitolo 5 — Valori e tipi

Un programma manipola **valori**: il numero 42, la stringa `"ciao"`, la lista `[1, 2, 3]`. Ogni
valore ha un **tipo**, che dice che genere di cosa è e che cosa ci si può fare. Triad-Core ha
sette tipi, pochi ma sufficienti a costruire qualunque struttura. Questo capitolo li presenta,
spiega come si stampano e come si confrontano.

## 5.1 Tipizzazione dinamica

In Triad-Core i tipi appartengono ai **valori**, non alle variabili. Una variabile è
un'etichetta attaccata a un valore e può essere riattaccata a un valore di tipo diverso:

```julia
x = 42
println(typeof(x))
x = "ora sono una stringa"
println(typeof(x))
```

Output:

```text
Int
String
```

Si dice che la tipizzazione è *dinamica*: il controllo dei tipi avviene durante l'esecuzione,
quando un'operazione riceve un valore che non sa trattare. Sommare un numero e una stringa, per
esempio, non è vietato dalla sintassi ma fallisce quando viene eseguito.

> **E Triad-Full?** Full permette di annotare i tipi (`x::Int = 5`, `function f(a::Int)`), e
> le annotazioni vengono controllate. Core non ha annotazioni: tutti i suoi controlli sono
> dinamici.

## 5.2 I sette tipi

**`Int`** — interi con segno a 64 bit. Il dettaglio "a 64 bit" è importante: un intero non può
crescere all'infinito. Se un calcolo supera il valore massimo, il risultato **si avvolge**
(wrap) e riparte dal minimo, come un contachilometri che torna a zero. Torneremo su questo nel
capitolo 6.

**`Bool`** — i due valori di verità `true` e `false`. Sono il risultato dei confronti e l'unico
tipo ammesso nelle condizioni di `if` e `while`.

**`String`** — sequenze immutabili di byte in codifica UTF-8. "Immutabili" significa che una
stringa non si modifica: concatenare due stringhe ne crea una terza.

**`Symbol`** — le etichette introdotte nel capitolo 4, come `:alice`.

**`List`** — sequenze ordinate di valori, di qualunque tipo e anche miste, **mutabili**: si
possono aggiungere elementi e cambiare quelli esistenti. Sono la struttura dati universale di
Core e hanno un capitolo tutto loro, il 10.

**`Function`** — le funzioni sono valori come gli altri: si possono assegnare a variabili,
passare ad altre funzioni, restituire. È la base delle chiusure (capitolo 9).

**`Nothing`** — un tipo con un solo valore, `nothing`, che rappresenta l'assenza di un valore
significativo. È ciò che restituisce `println`, ciò che vale un blocco vuoto, ciò che una
funzione di ricerca può restituire quando non trova nulla.

## 5.3 Chiedere il tipo: `typeof`

`typeof(v)` restituisce il nome del tipo di `v` **sotto forma di simbolo**:

```julia
println(typeof(1), " ", typeof(true), " ", typeof("s"), " ", typeof(:a))
println(typeof([1, 2]), " ", typeof(x -> x), " ", typeof(nothing))
println(typeof(1) == :Int)
```

Output:

```text
Int Bool String Symbol
List Function Nothing
true
```

Il fatto che il risultato sia un simbolo permette di confrontarlo direttamente con `:Int`,
`:List` e così via. È così che, in Core, si scrive codice che si comporta diversamente a seconda
del tipo di un valore, come vedremo nel capitolo 10.

## 5.4 Come si stampano i valori

`println` e `print` accettano qualunque numero di argomenti, li convertono in testo e li
scrivono uno dopo l'altro **senza spazi** in mezzo; `println` aggiunge alla fine un a capo,
`print` no. Le regole di conversione sono poche ma vanno conosciute, perché la suite di
conformità confronta l'output byte per byte:

- un intero è scritto in decimale, un booleano come `true` o `false`, `nothing` come `nothing`;
- una stringa è scritta così com'è, senza virgolette;
- un simbolo passato **direttamente** è scritto senza i due punti (`alice`);
- una lista è scritta tra parentesi quadre con gli elementi separati da `, `; **dentro una
  lista** i simboli mantengono i due punti (`:alice`) e le stringhe restano senza virgolette.

```julia
println(:alice, " ", [:alice, "bob", 3, true, nothing])
print("senza ")
print("a capo")
println()
println([[1, 2], []])
```

Output:

```text
alice [:alice, bob, 3, true, nothing]
senza a capo
[[1, 2], []]
```

> **Perché i simboli cambiano aspetto dentro una lista?** Perché in una lista mista bisogna
> poter distinguere il simbolo `:a` dalla stringa `"a"`. Al livello più esterno il contesto è
> chiaro e i due punti sarebbero solo rumore; dentro una lista diventano informazione. (Le
> stringhe, invece, nella stampa di Core restano senza virgolette: la distinzione è garantita
> per i simboli, non per le stringhe.)

## 5.5 Uguaglianza

L'operatore `==` confronta due valori e restituisce un `Bool`; `!=` è il suo contrario. Le
regole riflettono la natura di ciascun tipo:

- interi, booleani, stringhe e simboli sono confrontati **per valore**;
- le liste sono confrontate **elemento per elemento**, anche se annidate;
- le funzioni sono confrontate **per identità**: due funzioni sono uguali solo se sono lo stesso
  oggetto.

```julia
println("ab" == "a" * "b", " ", [1, [2, 3]] == [1, [2, 3]], " ", [1, 2] == [2, 1])
f = x -> x
g = x -> x
println(f == f, " ", f == g)
```

Output:

```text
true true false
true false
```

`f` e `g` fanno la stessa cosa, ma sono due funzioni create separatamente: per Triad sono
diverse. Stabilire se due funzioni calcolano la stessa cosa è, in generale, un problema
impossibile da risolvere, e il linguaggio non ci prova.

## Riepilogo

- I tipi appartengono ai valori; le variabili possono cambiare tipo.
- Core ha sette tipi: `Int`, `Bool`, `String`, `Symbol`, `List`, `Function`, `Nothing`.
- `typeof` restituisce il tipo come simbolo, da confrontare con `:Int`, `:List`, …
- `println` concatena senza spazi; i simboli perdono i due punti solo al livello più esterno.
- `==` confronta per valore, le liste elemento per elemento, le funzioni per identità.

## Esercizi

1. Prevedi l'output di `println([:x, "x", [:y]], :z)` e verificalo.
2. Scrivi `descrivi(v)` che restituisca `"numero"`, `"testo"` o `"altro"` a seconda del tipo di
   `v`, usando `typeof`.
3. Perché `[1, 2] == [2, 1]` è `false` mentre `"ab" == "a" * "b"` è `true`?
<!-- nav -->

---

← [Capitolo 4 — Le parole del linguaggio](Libro-04-Lessico) · [Sommario](Home) · [Capitolo 6 — Espressioni, operatori e variabili](Libro-06-Espressioni) →
