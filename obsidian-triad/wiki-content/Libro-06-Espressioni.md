# Capitolo 6 — Espressioni, operatori e variabili

In Triad quasi tutto è un'**espressione**: un pezzo di codice che, valutato, produce un valore.
Lo sono le operazioni aritmetiche e i confronti, ma anche gli assegnamenti, gli `if`, i blocchi.
Questo capitolo si occupa delle espressioni più elementari, gli operatori, e del modo in cui
si combinano; si chiude con le variabili e l'assegnamento.

## 6.1 Aritmetica intera

Gli operatori aritmetici di Core lavorano su interi: `+` somma, `-` sottrazione (e, davanti a un
solo operando, cambio di segno), `*` prodotto, `^` potenza, `%` resto della divisione.

Il resto merita una spiegazione. `a % b` restituisce ciò che avanza dividendo `a` per `b`, e il
risultato ha **lo stesso segno del dividendo** `a`. È la convenzione della funzione `rem` di
Julia, e coincide con quella della maggior parte dei processori:

```julia
println(7 % 3, " ", -7 % 3, " ", 7 % -3)
```

Output:

```text
1 -1 1
```

Non esiste l'operatore di divisione `/`. La ragione è la stessa che esclude i decimali: in
Triad-Full `7 / 2` vale `3.5`, un `Float`, e Core non ha i `Float`. Quando serve una divisione
intera, la si scrive con un ciclo o la si ricava dal resto, come vedremo negli esercizi.

Dividere per zero con `%` o usare un esponente negativo con `^` sono errori di esecuzione.

## 6.2 Il wrap a 64 bit

Gli interi hanno 64 bit, quindi vanno da −9 223 372 036 854 775 808 a 9 223 372 036 854 775 807.
Superare questi limiti non produce un errore: il risultato si avvolge.

```julia
massimo = 9223372036854775807
println(massimo + 1)
println(2 ^ 63)
```

Output:

```text
-9223372036854775808
-9223372036854775808
```

> **Perché non un errore?** Perché il wrap è ciò che fa naturalmente il processore, e il seed in
> codice macchina lo eredita senza costi. Lo standard lo rende comportamento obbligatorio, così
> che tutte le implementazioni diano lo stesso risultato. Chi ha bisogno di numeri più grandi può
> rappresentarli con liste di cifre: un buon esercizio, una volta letti i capitoli successivi.

## 6.3 Confronti e logica

I confronti `<`, `<=`, `>`, `>=` lavorano sugli interi; `==` e `!=` su qualunque valore (capitolo
5). Tutti restituiscono un `Bool`.

Gli operatori logici sono `&&` (e), `||` (o) e `!` (non). Due loro proprietà sono essenziali.

La prima: accettano **solo booleani**. Triad non ha la nozione di "verità implicita" che altri
linguaggi attribuiscono a numeri, stringhe o liste: `if 1` è un errore, non un modo per dire
"vero". Bisogna scrivere un confronto esplicito, come `if n != 0`.

La seconda: `&&` e `||` **cortocircuitano**. Se il lato sinistro di `&&` è falso, il destro non
viene nemmeno valutato, perché il risultato è comunque falso; simmetricamente per `||` quando il
lato sinistro è vero. Questo permette di scrivere condizioni che "si proteggono" da sole:

```julia
xs = []
println(length(xs) > 0 && xs[1] == 5)
```

Output:

```text
false
```

Senza il cortocircuito, `xs[1]` su una lista vuota causerebbe un errore di indice.

> **Attenzione.** I confronti non si concatenano: `1 < x < 10` non significa "x tra 1 e 10".
> L'espressione viene letta come `(1 < x) < 10`, cioè un booleano confrontato con un intero, e
> produce un errore. Si scrive `1 < x && x < 10`.

## 6.4 Il ternario

`condizione ? a : b` vale `a` se la condizione è vera, `b` altrimenti. È la forma compatta di un
`if`, ideale dentro un'espressione:

```julia
n = 7
println(n % 2 == 0 ? "pari" : "dispari")
segno(x) = x > 0 ? 1 : x < 0 ? -1 : 0
println(segno(-4), " ", segno(0), " ", segno(9))
```

Output:

```text
dispari
-1 0 1
```

Il ternario associa a destra: `a ? b : c ? d : e` si legge `a ? b : (c ? d : e)`, che permette
catene come quella di `segno`.

## 6.5 Precedenza e associatività

Quando un'espressione contiene più operatori, la **precedenza** decide quale si applica per
primo. Dalla più debole alla più forte:

| livello | operatori | note |
|---|---|---|
| 1 | `=` `+=` `-=` `*=` | associano a destra |
| 2 | `? :` | associa a destra |
| 3 | `\|\|` | |
| 4 | `&&` | |
| 5 | `==` `!=` `<` `<=` `>` `>=` | |
| 6 | `+` `-` | |
| 7 | `*` `%` | |
| 8 | `^` | associa a destra |
| 9 | `-x` `!x` | prefissi |
| 10 | `f(…)` `xs[…]` | chiamata e indice |

```julia
println(2 + 3 * 4, " ", (2 + 3) * 4, " ", 2 ^ 3 ^ 2, " ", -2 ^ 2)
```

Output:

```text
14 20 512 4
```

Due risultati meritano un commento. `2 ^ 3 ^ 2` vale `512` perché la potenza associa a destra:
è `2 ^ (3 ^ 2)` = `2 ^ 9`, come in matematica. `-2 ^ 2` vale `4` perché in questa grammatica il
meno unario lega **più forte** della potenza: è `(-2) ^ 2`. In caso di dubbio, le parentesi
rendono l'intenzione esplicita e costano nulla.

## 6.6 Variabili e assegnamento

`nome = espressione` valuta l'espressione e lega il risultato al nome. Se il nome non esisteva,
lo crea; se esisteva, lo aggiorna. Usare un nome mai assegnato è un errore.

Le forme composte `+=`, `-=`, `*=` aggiornano una variabile esistente: `n += 5` equivale a
`n = n + 5`.

```julia
n = 10
n += 5
n -= 3
n *= 2
println(n)
```

Output:

```text
24
```

Anche l'assegnamento è un'espressione, e vale il valore assegnato; per questo `a = b = 0` lega
entrambi i nomi a `0` (l'assegnamento associa a destra). È però buona norma non abusarne: un
assegnamento per riga rende il codice più facile da leggere.

Dove sia visibile una variabile e che cosa succeda quando la si assegna dentro una funzione è
una questione più sottile, che il capitolo 9 affronta in dettaglio.

## Riepilogo

- Core ha `+ - * % ^`; `%` ha il segno del dividendo; `/` non esiste.
- Gli interi si avvolgono a 64 bit.
- Le condizioni sono solo booleane; `&&` e `||` cortocircuitano; i confronti non si concatenano.
- La precedenza va dall'assegnamento (più debole) a chiamata e indice (più forte); `^` e il
  ternario associano a destra; il meno unario lega più della potenza.
- `=` crea o aggiorna; `+=`, `-=`, `*=` aggiornano.

## Esercizi

1. Calcola il quoziente intero di 47 diviso 5 usando solo `%`, `-` e un ciclo (anticipazione del
   capitolo 7).
2. Scrivi un'espressione che sia vera se `anno` è bisestile: divisibile per 4 e non per 100,
   oppure divisibile per 400.
3. Spiega perché `-2 ^ 2` vale `4` in Core e come scriveresti "meno (due al quadrato)".
<!-- nav -->

---

← [Capitolo 5 — Valori e tipi](Libro-05-Valori-e-tipi) · [Sommario](Home) · [Capitolo 7 — Decidere e ripetere](Libro-07-Controllo-del-flusso) →
