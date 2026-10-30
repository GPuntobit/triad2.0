# Capitolo 4 — Le parole del linguaggio

Prima di costruire frasi bisogna conoscere le parole. Questo capitolo descrive il **lessico** di
Triad-Core: come il testo di un programma viene spezzato in unità elementari (i *token*) e quali
regole governano quella suddivisione. Sembra materia arida, ma molti errori dei principianti
nascono proprio qui, e alcune scelte lessicali di Triad hanno conseguenze che si sentono in
tutto il linguaggio.

## 4.1 Dal testo ai token

Quando l'interprete legge un file, la prima cosa che fa è scorrerlo carattere per carattere e
raggrupparlo in token: un nome, un numero, una stringa, un operatore, una parentesi, un
separatore. Gli spazi e i commenti servono solo a separare i token e poi scompaiono. Nel
capitolo 19 vedremo la funzione `tokenize` che fa questo lavoro nell'interprete di riferimento;
qui ci interessa il risultato.

## 4.2 Nomi

Un **identificatore** inizia con una lettera o con `_` e prosegue con lettere, cifre o `_`.
`x`, `somma_parziale`, `_tmp`, `fib2` sono nomi validi; `2fib` no, perché inizierebbe con una
cifra. È ammesso un `!` finale, come in `push!`: per convenzione indica una funzione che
**modifica** il proprio argomento, e lo ritroveremo nei capitoli sulle liste.

Alcuni nomi sono **riservati** perché hanno un significato nella grammatica: `function`, `end`,
`if`, `elseif`, `else`, `while`, `let`, `begin`, `return`, `break`, `continue`, `true`, `false`,
`nothing`. Triad-Full ne aggiunge altri (`struct`, `fact`, `rule`, `solve`, `for`, `try`, …), e
conviene evitarli come nomi anche scrivendo in Core, perché un programma Core deve restare
valido in Full.

## 4.3 Numeri

In Core esistono solo **interi**: `0`, `42`, `1_000_000`. Il trattino basso è un separatore
visivo, ignorato dal lettore, utile per i numeri lunghi. Il segno meno non fa parte del numero:
`-5` è l'operatore "meno unario" applicato a `5`. La differenza è sottile ma ha una conseguenza
pratica: `- 5` e `-5` sono la stessa cosa.

Non esistono numeri decimali: scrivere `1.5` in Core produce un errore di sintassi. È una delle
rinunce più evidenti di Core, giustificata dalla difficoltà di implementare la virgola mobile in
codice macchina scritto a mano; Triad-Full ha il tipo `Float`.

## 4.4 Stringhe

Una stringa è racchiusa tra virgolette doppie: `"ciao"`. Dentro la stringa il carattere `\`
introduce una **sequenza di escape** per i caratteri che non si possono scrivere direttamente:

| escape | significato |
|---|---|
| `\n` | a capo |
| `\t` | tabulazione |
| `\"` | virgolette doppie |
| `\\` | il carattere backslash |

```julia
println("riga uno\nriga due")
println("una \"citazione\" e un backslash: \\")
println("a\tb")
```

Output:

```text
riga uno
riga due
una "citazione" e un backslash: \
a	b
```

> **Attenzione.** In Triad-Full si può scrivere `"x vale $x"` e il valore di `x` viene inserito
> nella stringa (interpolazione). In Core **no**: il `$` resta un carattere qualsiasi e la
> stringa viene stampata letteralmente. Per comporre testo e valori in Core si concatena:
> `"x vale " * string(x)`.

## 4.5 Simboli

Un **simbolo** è un nome preceduto da due punti: `:alice`, `:rosso`, `:ok`. A differenza di una
stringa, un simbolo non è testo da elaborare ma un'etichetta: due simboli sono uguali se e solo
se hanno lo stesso nome, e confrontarli è immediato. Si usano per rappresentare valori di
un'enumerazione (`:nord`, `:sud`), etichette di dati (`:Punto`), risultati (`:ok`, `:errore`).

Anche un operatore può diventare un simbolo: `:+` è il simbolo il cui nome è `+`.

```julia
direzione = :nord
println(direzione)
println(direzione == :nord, " ", :a == :b)
```

Output:

```text
nord
true false
```

Nota che `println` stampa il simbolo senza i due punti. Il capitolo 5 spiega quando li mostra.

## 4.6 Commenti

`#` inizia un commento che dura fino a fine riga. `#=` e `=#` delimitano un commento su più
righe:

```julia
#= Questo programma
   calcola una somma. =#
s = 1 + 2   # somma di prova
println(s)
```

Output:

```text
3
```

> **Nota.** Lo standard Full prevede che i commenti `#= … =#` si possano annidare, uno dentro
> l'altro. L'interprete di riferimento Core non lo fa: si ferma al primo `=#`. Evita quindi di
> annidarli nel codice Core.

## 4.7 Separatori: le righe contano

In Triad un'istruzione finisce **alla fine della riga**. Non serve il punto e virgola, ma lo si
può usare per mettere più istruzioni sulla stessa riga:

```julia
a = 1; b = 2; println(a + b)
```

Output:

```text
3
```

Le righe vuote sono ignorate. In compenso, una riga spezzata nel punto sbagliato cambia il
significato del programma: scrivere `x = 1 +` su una riga e `2` sulla successiva è un errore in
Core, perché la prima riga è un'istruzione incompleta. La regola pratica è tenere ogni
istruzione su una riga, oppure andare a capo solo dentro parentesi e dentro i blocchi.

## 4.8 Operatori e punteggiatura

Gli operatori di Core sono `+ - * % ^` (aritmetica), `== != < <= > >=` (confronto),
`&& || !` (logica), `=  +=  -=  *=` (assegnamento), `->` (lambda) e `? :` (ternario). Le
parentesi tonde raggruppano espressioni e racchiudono gli argomenti, quelle quadre costruiscono
e indicizzano liste, la virgola separa elementi. Il loro significato e la loro precedenza sono
l'argomento del capitolo 6.

## Riepilogo

- I nomi iniziano con una lettera o `_`; un `!` finale segnala per convenzione una funzione che
  modifica i suoi argomenti.
- In Core i numeri sono solo interi; `1.5` e `/` appartengono a Full.
- Le stringhe usano gli escape `\n \t \" \\`; l'interpolazione con `$` è solo Full.
- I simboli (`:nome`) sono etichette confrontabili istantaneamente.
- Un'istruzione finisce a fine riga o al `;`.

## Esercizi

1. Quali di questi sono identificatori validi? `conta!`, `_x1`, `1x`, `valore_finale`, `end`.
2. Scrivi un programma che stampi, su tre righe, un testo che contenga una tabulazione, delle
   virgolette e un backslash.
3. Prova a scrivere `println(1.5)` e osserva il messaggio d'errore dell'interprete.
<!-- nav -->

---

← [Capitolo 3 — L'ambiente e il primo programma](Libro-03-Primo-programma) · [Sommario](Home) · [Capitolo 5 — Valori e tipi](Libro-05-Valori-e-tipi) →
