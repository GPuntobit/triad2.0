# Capitolo 12 — Quando le cose vanno storte

Ogni programmatore passa più tempo a capire perché un programma non funziona che a scriverlo.
Questo capitolo spiega come Triad-Core reagisce agli errori, come leggere i messaggi
dell'interprete, come scrivere codice robusto senza eccezioni e, infine, in che cosa differiscono
oggi i due esecutori, l'interprete di riferimento e il seed.

## 12.1 Errori che fermano il programma

Triad-Core non ha `try`/`catch` né valori di errore (li ha Triad-Full, capitolo 17). Quando
qualcosa va storto durante l'esecuzione — un nome sconosciuto, un'operazione su tipi sbagliati,
un indice fuori dai limiti — il programma **si ferma**, scrive un messaggio diagnostico sullo
standard error e termina con codice di uscita `1`. Tutto ciò che era già stato stampato sullo
standard output resta.

```julia
println("prima")
println(nome_sconosciuto)
println("dopo")
```

Questo programma stampa `prima` sullo standard output, poi
`error: undefined variable nome_sconosciuto` sullo standard error, ed esce con codice 1; `dopo`
non viene mai stampato. La suite di conformità confronta solo standard output e codice di uscita:
i messaggi d'errore sono diagnostici, non normativi, e ogni implementazione può formularli a modo
suo.

Gli errori di **sintassi** sono rilevati prima ancora di iniziare: se il file non si può
analizzare, l'interprete non esegue nessuna istruzione.

## 12.2 Leggere i messaggi

I messaggi dell'interprete di riferimento sono brevi. Questa tabella li traduce:

| messaggio | che cosa significa di solito |
|---|---|
| `parse error: unexpected token …`, `parse error: expected …` | sintassi non valida per Core: un `1.5`, una `/`, una lambda `() -> …`, un `end` mancante o di troppo |
| `error: undefined variable NOME` | il nome non è mai stato assegnato, è scritto male, o la funzione è definita più in basso |
| `error: not a function` | si sta chiamando un valore che non è una funzione |
| `error: arity mismatch` | gli argomenti non sono quanti i parametri |
| `error: index out of range` | indice minore di 1 o maggiore della lunghezza |
| `error: + type error` (e `-`, `*`, `<`, …) | operandi di tipo inadatto, per esempio `1 + "a"` |
| `error: if cond`, `while cond`, `ternary cond`, `&& expects bool` | la condizione non è un booleano |
| `error: div by zero`, `negative exponent` | `x % 0` oppure `x ^ -1` |
| `cannot read file: …` | il file indicato non esiste o non è leggibile |
| `usage: triad FILE [ARG...]` (codice 2) | non è stato indicato nessun file |

Il seed Windows è più laconico: non scrive messaggi, comunica solo il codice di uscita (`1` per
gli errori, `2` se manca il file).

## 12.3 Errori come valori, in Core

Fermarsi al primo problema va bene per un programma piccolo, ma un programma più grande vuole
spesso gestire un errore e proseguire. Senza eccezioni, la tecnica è restituire l'errore **come
valore**. La convenzione che `SPEC-CORE.md` suggerisce, e che S1 userà per rappresentare gli
errori dei programmi Full, è una lista etichettata `[:Err, genere, messaggio]`:

```julia
err(genere, msg) = [:Err, genere, msg]
is_err(v) = typeof(v) == :List && length(v) == 3 && v[1] == :Err
function quoziente(a, b)
    if b == 0
        return err(:domain, "divisione per zero")
    end
    q = 0
    while a >= b
        a -= b
        q += 1
    end
    q
end
function descrivi(r)
    is_err(r) ? "errore " * string(r[2]) * ": " * r[3] : "risultato " * string(r)
end
println(descrivi(quoziente(17, 5)))
println(descrivi(quoziente(1, 0)))
```

Output:

```text
risultato 3
errore domain: divisione per zero
```

Il chiamante controlla il risultato con `is_err` e decide che cosa fare. È più verboso di
un'eccezione, ma ha un pregio: il flusso dell'errore è visibile nel codice. È anche l'anticamera
della filosofia di Triad-Full, dove gli errori *sono* valori di prima classe.

> **Nota.** In `is_err` l'ordine delle condizioni conta: grazie al cortocircuito di `&&`,
> `v[1]` viene letto solo dopo aver verificato che `v` è una lista di tre elementi.

## 12.4 Strategie di debug

Senza un debugger, gli strumenti sono semplici ma efficaci.

- **Stampe mirate.** Un `println("x = ", x)` nel punto giusto vale più di molte ipotesi.
- **Ridurre il problema.** Copia il pezzo sospetto in un file a parte e riducilo finché l'errore
  resta: spesso a quel punto la causa è evidente.
- **Verificare i tipi.** `println(typeof(v))` chiarisce molti `type error`.
- **Confrontare con un caso noto.** I casi di conformità Core sono programmi corretti: se un
  costrutto non funziona come pensi, cerca il caso che lo usa.

## 12.5 Interprete di riferimento e seed: le differenze

Il contratto comune ai due esecutori è la suite di conformità Core: l'interprete di riferimento
la passa tutta, il seed i 33 casi elencati nella CI. Fuori da quel contratto il seed, che è
codice macchina scritto a mano e ancora in crescita, ha dei limiti. Conviene conoscerli se il
codice deve girare su entrambi.

| funzionalità | interprete di riferimento | seed Windows |
|---|---|---|
| interi, booleani, operatori, ternario | sì | sì |
| `if`/`elseif`/`else`, `while`, `let`, `begin` | sì | sì |
| funzioni, ricorsione | sì | sì, fino a 4 parametri |
| lambda | con più parametri | con un solo parametro |
| chiusure | variabili condivise, come da standard | catturate per valore, solo l'ultimo legame |
| `string(v)` | ogni tipo | solo interi e stringhe |
| liste | miste, `xs[i]`, `xs[i] = v`, `length`, `push!` | solo interi: costruzione, stampa e `push!` (fino a 64 elementi) |
| `get(xs, i)` | non esiste | estensione non standard, indici **da 0** |
| `ARGS`, primitivi di bootstrap, `Int`, `Symbol`, `typeof` | sì | non documentati nel README del seed |
| messaggi d'errore | sì | solo codice di uscita |

La regola pratica è: scrivi seguendo lo standard e verifica con l'interprete di riferimento; se
il codice deve girare sul seed (come quello di `selfhost/`, capitolo 21), restringiti alla
colonna di destra e provalo su Windows.

## Riepilogo

- In Core un errore ferma il programma: messaggio su stderr, codice di uscita 1.
- I messaggi d'errore sono diagnostici; la conformità guarda solo stdout e codice di uscita.
- Per gestire errori senza fermarsi si restituiscono valori `[:Err, genere, messaggio]`.
- Il seed Windows ha limiti precisi rispetto all'interprete di riferimento.

## Esercizi

1. Scrivi `elemento(xs, i)` che restituisca `err(:bounds, …)` invece di fermarsi quando l'indice è
   fuori dai limiti.
2. Scrivi `somma_sicura(xs)` che restituisca un errore `:type` se un elemento non è un intero.
3. Prendi un programma che usa una lambda a due parametri e riscrivilo perché giri anche sul
   seed.
<!-- nav -->

---

← [Capitolo 11 — Stringhe, simboli e byte](Libro-11-Stringhe-e-byte) · [Sommario](Home) · [Capitolo 13 — Progetto: un piccolo interprete](Libro-13-Progetto-interprete) →
