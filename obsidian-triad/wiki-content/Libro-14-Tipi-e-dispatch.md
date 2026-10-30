# Capitolo 14 — Tipi, struct e multiple dispatch

Con questo capitolo entriamo in **Triad-Full**, il linguaggio completo definito da `SPEC.md`. Una
premessa vale per tutta la parte terza: i programmi qui descritti **non girano ancora** sul
runtime attuale, che esegue solo Triad-Core. Li presentiamo perché sono lo standard, la meta
verso cui lavora l'implementazione self-hosted, e perché capirli aiuta a scrivere oggi codice
Core che domani si integrerà senza attriti. Dove esiste un output di riferimento (i golden della
suite Full), lo indichiamo.

## 14.1 Perché i tipi

In Core i tipi esistono ma restano impliciti: si scoprono durante l'esecuzione. Full permette di
**dichiararli**. Una dichiarazione di tipo è insieme documentazione e controllo: dice al lettore
che cosa ci si aspetta e chiede al linguaggio di verificarlo. Full aggiunge anche nuovi tipi:
`Float` (numeri decimali, con `Number` come supertipo comune a `Int` e `Float`), i tipi definiti
dall'utente con `struct`, e `Any`, il tipo che comprende tutti gli altri.

```julia
x::Int = 5
x = 6          # va bene
x = 5.5        # Err(:type): x è stata dichiarata Int
y::Float = 1.0
y = 2          # diventa 2.0: un Int si converte in Float
```

Il vincolo nasce con la dichiarazione e vive nell'ambiente in cui il nome è stato creato. Un
nome mai dichiarato con un tipo resta libero, come in Core.

## 14.2 Struct

Una `struct` definisce un nuovo tipo con campi nominati e, facoltativamente, tipizzati:

```julia
struct Punto
    x::Float
    y::Float
end

p = Punto(3, 4)        # costruttore posizionale; 3 e 4 diventano 3.0 e 4.0
p.x                    # 3.0
typeof(p) == Punto     # true
p isa Punto            # true
```

Le struct sono **immutabili**: una volta costruito, un `Punto` non cambia. Leggere un campo che
non esiste produce `Err(:field)`; costruirne uno con un tipo incompatibile produce `Err(:type)`.
Nel capitolo 10 abbiamo rappresentato la stessa idea in Core con una lista etichettata
`[:Punto, x, y]`: è precisamente il modo in cui S1 implementerà le struct dentro l'interprete.

## 14.3 Funzioni tipate

I parametri e il valore di ritorno di una funzione possono essere annotati:

```julia
function distanza(a::Punto, b::Punto)::Float
    sqrt((a.x - b.x)^2 + (a.y - b.y)^2)
end
```

Il tipo di ritorno `::Float` viene controllato all'uscita (con la stessa conversione da `Int` a
`Float` degli assegnamenti). Anche le lambda possono avere parametri tipati:
`function (x::Int) x end` rifiuta un `Float` con `Err(:type)`.

## 14.4 Multiple dispatch

Qui sta l'idea più caratteristica che Triad eredita da Julia. In molti linguaggi a oggetti, la
scelta del codice da eseguire dipende dal tipo di **un** oggetto, il destinatario del metodo. In
Triad una funzione è un insieme di **metodi**, ognuno con la sua firma, e la scelta dipende dai
tipi di **tutti** gli argomenti.

```julia
area(n::Number) = :numero
area(n::Int) = :intero
area(p::Punto) = :punto

area(1)            # :intero  — Int è più specifico di Number
area(1.5)          # :numero
area(Punto(0, 0))  # :punto
```

La regola è che vince il metodo **più specifico** tra quelli applicabili. Se nessun metodo è
applicabile si ottiene `Err(:method)`; se due metodi sono ugualmente specifici e nessuno prevale,
`Err(:ambiguous)`: il linguaggio rifiuta di scegliere a caso.

> **Perché dispatch multiplo?** Perché molte operazioni non "appartengono" a un solo argomento.
> Sommare un intero e un decimale, far collidere due forme geometriche, convertire un valore da
> un tipo a un altro: sono relazioni tra tipi, e il dispatch multiplo permette di definirle
> caso per caso senza gerarchie forzate.

## 14.5 Gli operatori sono funzioni

In Triad `a + b` è zucchero sintattico per la chiamata `+(a, b)`. Ne segue che un operatore si
può estendere a un nuovo tipo semplicemente aggiungendo un metodo:

```julia
function +(a::Punto, b::Punto)
    Punto(a.x + b.x, a.y + b.y)
end

r = Punto(3, 4) + Punto(1, 2)   # Punto(4.0, 6.0)
```

E poiché gli operatori sono funzioni, si possono passare come valori: `reduce(+, xs)` somma una
lista, `map(sq, xs)` applica `sq` a ogni elemento.

## 14.6 Un esempio dal repository

Il caso di conformità Full `dispatch` (si veda il [Catalogo conformance Full](Catalogo-conformance-Full#dispatch))
mette insieme struct, operatori estesi, dispatch ed errori come dati. Leggerlo con l'output di
riferimento accanto è un ottimo esercizio di comprensione.

## Riepilogo

- Full aggiunge annotazioni di tipo controllate, `Float`, `Number`, `Any` e le struct.
- Le struct sono immutabili, con costruttore posizionale e campi tipizzati.
- Una funzione è un insieme di metodi; vince il più specifico tra gli applicabili; l'ambiguità è
  un errore.
- Gli operatori sono funzioni estendibili e passabili come valori.

## Esercizi

1. Definisci una struct `Frazione` con numeratore e denominatore interi e un metodo `*` per
   moltiplicarle.
2. Scrivi tre metodi di `descrivi` per `Int`, `String` e `Any` e prevedi quale viene scelto per
   `descrivi(:a)`.
3. Riscrivi in Core (liste etichettate e `typeof`) l'esempio `area` del paragrafo 14.4.
<!-- nav -->

---

← [Capitolo 13 — Progetto: un piccolo interprete](Libro-13-Progetto-interprete) · [Sommario](Home) · [Capitolo 15 — Programmazione logica](Libro-15-Logica) →
