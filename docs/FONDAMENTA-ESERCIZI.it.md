# Esercizi — Fondamenta: programmare da zero con Triad

> Gli esercizi delle [Fondamenta](FONDAMENTA.it.md), con le soluzioni, in un
> file separato. I rimandi a «capitolo N» indicano i capitoli delle
> Fondamenta; quelli al «Manuale» indicano il
> [Manuale di Triad 2.0](MANUALE.it.md).

## 1. Che cos'è un programma

### Esercizi

1. **Il programma più piccolo.** Scrivi un file `minimo.triad` con una sola istruzione che stampi
   `ok`, ed eseguilo. Poi togli una virgoletta e riesegui: che cosa ti dice il terminale?
2. **Due istruzioni, in ordine.** Scrivi un programma che stampi `prima` e poi `dopo`, su due righe.
   Scambia le due righe e riesegui: che cosa cambia nell'output?
3. **Tre righe.** Scrivi un programma che stampi su tre righe `Triad`, `è`, `un linguaggio`.
4. **Quante istruzioni?** Scrivi un programma con tre `println`, poi rileggilo e conta le istruzioni:
   quante sono davvero? Che cosa fa ciascuna?
5. **Refuso.** Scrivi `printn("ciao")` ed esegui: il programma funziona? Perché il computer si
   ferma invece di «capire» che intendevi `println`?
6. **Output previsto.** Senza eseguire, scrivi su un foglio l'output di un programma che stampi
   `uno`, `due`, `tre`; poi esegui e confronta: avevi previsto giusto?
7. **Stringa o istruzione?** Nel programma `println("ciao, mondo")` che cosa è istruzione e che
   cosa è dato? Prova a spiegarlo a voce alta.
8. **Interprete in azione.** Esegui un programma due volte di fila: l'output cambia? Che cosa
   succede al file del programma mentre lo esegui?
9. **Il tuo primo programma originale.** Scrivi un programma che presenti te stesso: nome, città
   e una cosa che ti piace, ciascuna su una riga.
10. **Ripasso a parole.** Rispondi senza guardare il libro: che differenza c'è tra programma e
    interprete? Tra compilatore e interprete? Che cos'è una stringa?

## 2. Il terminale e il primo programma

### Esercizi

1. **Nel posto giusto.** Apri il terminale, entra nella cartella `triad2.0` e verifica con
   `ls`/`dir` di vederle cartelle `seed/`, `conformance/`, `docs/`.
2. **Il primo programma.** Scrivi `ciao.triad` come nel capitolo ed eseguilo con
   `node seed/dev/triad_core.cjs ciao.triad`: vedi `ciao, Triad`?
3. **Un programma tuo.** Crea `mio.triad` che stampi `ciao, <tuo nome>` e fallo girare.
4. **Il nome del file.** Salva volutamente il programma come `ciao.triad.txt` ed eseguilo: che
   cosa succede? Correggi il nome e riesegui.
5. **Un errore di battitura.** Cambia `println` in `printn`, esegui e leggi il messaggio: a quale
   delle due famiglie di errori del capitolo 12 appartiene?
6. **Il commento.** Aggiungi tre commenti `# ...` al tuo programma: che cosa cambia nell'output?
   E nel testo del file?
7. **Concatenazione.** Modifica `ciao.triad` in modo che stampi `ciao, Triad!` usando `*` e la
   stringa `"!"`.
8. **Ciclo di lavoro.** Trasforma il saluto in due righe separate, **una modifica alla volta**,
   rieseguendo dopo ogni modifica: perché conviene lavorare così?
9. **Cartella sbagliata.** Esegui il programma da un'altra cartella usando il percorso completo
   del file: funziona? E se usi solo il nome del file?
10. **Secondo controllo.** Esegui
    `node seed/dev/triad_core.cjs conformance/core/cases/aritmetica/program.td` e confronta
    l'output con la colonna di numeri attesa: comincia con `14`, `20`, `1`, `1024`?

## 3. Valori: i dati con cui si calcola

### Esercizi

1. **Riconoscere i tipi.** Scrivi un programma che stampi `typeof` per `42`, `"42"`, `true`,
   `:ok`, `nothing` e `[1, 2]`.
2. **Numero o testo?** Esegui `println(42 + 1)` e poi `println("42" + 1)`: perché uno funziona e
   l'altro no? Leggi il messaggio d'errore.
3. **Stessa faccia, tipo diverso.** Stampa `42` e `"42"`: l'output è uguale? In che cosa i due
   valori sono diversi per il programma?
4. **Verità.** Stampa il risultato di `2 == 2` e di `2 != 2`: di che tipo sono quei valori?
5. **Etichette.** Stampa i simboli `:ok` e `:ciao`: compaiono con i due punti? Di che tipo sono
   secondo `typeof`?
6. **Liste.** Crea una lista con tre valori di tipi diversi e stampala: Triad lo permette?
7. **Nessun valore.** Che cosa stampa `println(nothing)`? E `println(typeof(nothing))`?
8. **Vuoti, ma valori.** Che tipo hanno `""` e `[]`? Sono «assenza di valore» o valori veri e
   propri? Verifica con `typeof`.
9. **Prevedi e verifica.** Senza eseguire, scrivi l'output di `println(1_000)`, `println(-7)`,
   `println(typeof(1_000))`; poi controlla.
10. **Classifica.** Assegna a ogni esempio il tipo giusto: `42`, `:alice`, `[]`, `false`, `"42"`,
    `nothing`, `[1, "due"]`, `true`.

## 4. Variabili: dare un nome a un valore

### Esercizi

1. **Assegnare e stampare.** Crea le variabili `nome` e `cognome`, costruisci il saluto con `*`
   e stampalo.
2. **Tabella dei valori.** Segui riga per riga `eta = 42`, `eta = eta + 1`, `eta += 5` scrivendo
   su un foglio il valore di `eta` dopo ogni istruzione; poi verifica con `println`.
3. **Nomi validi.** Quali di questi nomi vanno bene? `eta`, `2eta`, `eta_utente`, `eta utente`,
   `Eta`, `x2`, `nome-cognome`. Prova a usarli davvero.
4. **Variabile indefinita.** Stampa una variabile a cui non hai mai assegnato un valore: leggi il
   messaggio e spiega in italiano che cosa è successo.
5. **Maiuscole e minuscole.** `eta = 1` e `Eta = 2`: sono la stessa variabile? Verifica stampando
   entrambe.
6. **Cambiare tipo.** `x = 1` e poi `x = "ciao"`: è permesso? Stampa `typeof(x)` prima e dopo la
   seconda assegnazione.
7. **La scorciatoia `+=`.** Scrivi `n = 10` e `n += 3`; poi riscrivi la seconda riga senza `+=`.
   L'output è lo stesso?
8. **Il contadino e le mele.** Un cesto contiene `mele = 7`; ne vendi 3 e ne compri altre 10.
   Traccia il valore di `mele` a ogni passo e stampa il risultato finale.
9. **Scambio.** Dati `a = 1` e `b = 2`, scambia i loro valori usando una terza variabile, e
   stampa `a` e `b` alla fine.
10. **Nomi che parlano.** Prendi un programma di esempio con variabili `x`, `y`, `z` e rinominale
    con nomi che dicano che cosa contengono: il programma è più facile da leggere?

## 5. Espressioni: combinare i valori

### Esercizi

1. **Precedenza.** Senza eseguire, calcola `2 + 3 * 4`, `2 * 3 + 4`, `(2 + 3) * 4`; poi verifica
   con un programma.
2. **Il resto.** Che cosa stampano `7 % 3`, `10 % 5`, `12 % 10`? Come si legge `n % 2` a parole?
3. **Potenza.** Calcola a mano `2 ^ 10` e `3 ^ 3`, poi controlla con il programma.
4. **Ternario.** Dato `eta = 20`, stampa `maggiorenne` o `minorenne` usando `condizione ? a : b`.
5. **`=` o `==`.** Scrivi apposta `if x = 0` (dopo aver assegnato `x = 0`): che cosa succede?
   Perché è un errore e non un comportamento misterioso?
6. **Confronti.** Stampa il valore di `10 > 3`, `2 == 2`, `2 != 2`, `!false`: di che tipo sono?
7. **Logica.** Valuta a mano poi verifica: `true && false`, `true || false`, `!(3 > 5)`,
   `2 > 1 && 5 > 3`.
8. **Parentesi.** Aggiungendo solo parentesi a `1 + 2 * 3 - 4`, ottieni almeno due risultati
   diversi da quello senza parentesi? Trovali e verificali.
9. **Intervallo.** Scrivi un'espressione Bool che sia `true` se e solo se `n` è compreso fra 10 e
   20 estremi inclusi; provala con `n = 5`, `n = 10`, `n = 15`, `n = 25`.
10. **Tutti e tre.** Scrivi un'espressione che usi insieme `&&`, `||` e `!` e stampi `true`;
    spiega riga per riga come viene calcolata.

## 6. Stringhe: lavorare col testo

### Esercizi

1. **Concatenazione.** Costruisci e stampa `ciao, Ada!` usando `*` e almeno tre pezzi di testo.
2. **Lunghezza.** Prevedi e verifica `length("ciao")`, `length("è")`, `length("")`.
3. **Da numero a testo.** Stampa la riga `la risposta è 42` usando `string(40 + 2)`.
4. **Da testo a numero.** Esegui `println(Int("41") + 1)`; poi prova `Int("ciao")`: che cosa
   succede? Perché conviene controllare prima di convertire?
5. **Escape.** Stampa `prima` e `dopo` su due righe usando una sola `println` con `\n`.
6. **Virgolette dentro le virgolette.** Stampa la frase `disse: "arrivo"` (con le virgolette
   visibili nell'output).
7. **Immutabilità.** Dato `s = "ciao"`, costruisci `s2 = s * "!"` e stampa sia `s` sia `s2`:
   la stringa originale è cambiata?
8. **Una frase da pezzi.** Dati `nome = "Ada"` e `eta = 36` (intero), costruisci e stampa
   `Ada ha 36 anni`.
9. **Andata e ritorno.** Parti da `"123"`, convertilo in intero, aggiungi 1, riconvertilo in
   testo e stampa il risultato atteso: `124`.
10. **Che cosa funziona?** Esegui tutte e tre e spiega i risultati: `println("a" * "b")`,
    `println("a" + "b")`, `println(length("ab"))`.

## 7. Decisioni: `if`, `elseif`, `else`

### Esercizi

1. **Pari o dispari.** Dato `n`, stampa `pari` o `dispari` con un `if`.
2. **I voti.** Dato un voto da 0 a 10, stampa `insufficiente` (fino a 5), `sufficiente` (6),
   `buono` (fino a 8), `ottimo` (oltre), usando `elseif`.
3. **Il più grande di tre.** Dati tre numeri, stampa il più grande usando `if` (senza funzioni).
4. **`if 1`.** Perché `if 1` è un errore? Che cosa dice il messaggio? Che regola del linguaggio
   rispecchia?
5. **`else if` o `elseif`?** Scrivi apposta un `else if` (con lo spazio): quanti `end` servono
   per chiudere tutto? Dove si nasconde l'`if` annidato?
6. **L'ordine conta.** Scrivi un `if` con le condizioni `x > 0` e `x > 10`: in quale ordine vanno
   messe perché `x = 15` dia la risposta giusta? Prova entrambe le versioni.
7. **`if` come espressione.** Assegna a `etichetta` il valore di un `if` che produce `:grande`
   se `x > 2` e `:piccolo` altrimenti; stampa `etichetta`.
8. **Anno bisestile.** Dato `anno`, stampa `bisestile` o `non bisestile` secondo la regola del
   capitolo 13; provalo con 2000, 2005, 1900, 2024.
9. **Senza `else`.** Che cosa succede se nessuna condizione è vera e l'`if` non ha `else`?
   Verifica con un programma.
10. **Fuori intervallo.** Dato un voto, stampa il giudizio come all'esercizio 2, ma per voti
    negativi o maggiori di 10 stampa `voto non valido`.

## 8. Ripetizioni: `while`

### Esercizi per sottogenere

Tutte le soluzioni qui sotto girano identiche sul seed e sull'interprete di riferimento: prova
prima a scriverle da solo, esegui e confronta l'output, e solo allora leggi la soluzione.

**Contatore**

1. **Tabellina del 7.** Stampa i multipli di 7 da 7 a 70, uno per riga.
2. **Conto alla rovescio.** Stampa i numeri da 3 a 1, uno per riga, e poi la riga `via!`.

**Accumulatore**

3. **Fattoriale.** Calcola `10!` (cioè `1 * 2 * … * 10`) e stampalo.
4. **Fila di numeri.** Costruisci la stringa `1-2-3-4-5` unendo con `-` i numeri da 1 a 5 e
   stampala. *(Parti da `s = ""` e a ogni girata aggiungi `string(i)` — e il trattino, tranne
   all'ultimo.)*

**Ricerca e decisione**

5. **Primo quadrato grande.** Qual è il primo numero il cui quadrato supera 5000? Stampalo.
6. **Verifica con uscita anticipata.** Controlla i numeri da 1 a 10: se uno ha il quadrato
   maggiore o uguale a 100 il controllo fallisce e il ciclo si ferma. Stampa `true` se tutti
   passano, `false` se fallisce; in questo secondo caso stampa anche il numero che ha fatto
   fallire il controllo.

**Cicli annidati**

7. **Tabella dei prodotti.** Stampa la tabella 3×3 dei prodotti: tre righe (`1 2 3`, `2 4 6`,
   `3 6 9`), con uno spazio fra i valori.
8. **Triangolo.** Dato `n = 3`, stampa `n` righe: la prima con una `+`, la seconda con due, la
   terza con tre.

**Sentinella**

9. **Potenze di due.** Partendo da 1 e raddoppiando, quante potenze di 2 minori di 1000 ci
   sono? Contale con un ciclo `while true` che si ferma con `break`.
10. **Multipli di 7.** Quanti sono i multipli di 7 da 7 a 100 compreso? Contali con un ciclo
    `while true`.

### Soluzioni

**1. Tabellina del 7**

```triad
n = 7
while n <= 70
    println(n)
    n += 7
end
```

Output:

```text
7
14
21
28
35
42
49
56
63
70
```

**2. Conto alla rovescio**

```triad
i = 3
while i >= 1
    println(i)
    i = i - 1
end
println("via!")
```

Output:

```text
3
2
1
via!
```

**3. Fattoriale** — il risultato si accumula in `f`, che parte da 1 (il neutro della
moltiplicazione, come `0` per la somma):

```triad
f = 1
i = 1
while i <= 10
    f = f * i
    i += 1
end
println(f)
```

Output:

```text
3628800
```

**4. Fila di numeri**

```triad
s = ""
i = 1
while i <= 5
    s = s * string(i)
    if i < 5
        s = s * "-"
    end
    i += 1
end
println(s)
```

Output:

```text
1-2-3-4-5
```

**5. Primo quadrato grande** — qui il ciclo non «fa» nulla dentro: avanza finché la condizione
è vera e alla fine basta leggere il contatore:

```triad
i = 1
while i * i <= 5000
    i += 1
end
println(i)
```

Output:

```text
71
```

(`70 * 70` è `4900`, ancora sotto; `71 * 71` è `5041`, sopra.)

**6. Verifica con uscita anticipata**

```triad
n = 1
ok = true
while n <= 10
    if n * n >= 100
        ok = false
        break
    end
    n += 1
end
println(ok)
println("fallito a " * string(n))
```

Output:

```text
false
fallito a 10
```

**7. Tabella dei prodotti** — il contatore interno `j` riparte da 1 a ogni girata di `i`:

```triad
i = 1
while i <= 3
    riga = ""
    j = 1
    while j <= 3
        riga = riga * string(i * j)
        if j < 3
            riga = riga * " "
        end
        j += 1
    end
    println(riga)
    i += 1
end
```

Output:

```text
1 2 3
2 4 6
3 6 9
```

**8. Triangolo**

```triad
riga = 1
while riga <= 3
    s = ""
    col = 1
    while col <= riga
        s = s * "+"
        col += 1
    end
    println(s)
    riga += 1
end
```

Output:

```text
+
++
+++
```

**9. Potenze di due** — la sentinella `while true` si ferma con `break` appena la potenza
raggiunge la soglia:

```triad
p = 1
conta = 0
while true
    if p >= 1000
        break
    end
    conta += 1
    p = p * 2
end
println(conta)
```

Output:

```text
10
```

(Sono `1, 2, 4, 8, 16, 32, 64, 128, 256, 512`: dieci valori.)

**10. Multipli di 7**

```triad
conta = 0
n = 7
while true
    if n > 100
        break
    end
    conta += 1
    n += 7
end
println(conta)
```

Output:

```text
14
```

## 9. Liste: tenere insieme molti valori

### Esercizi

1. **Creare e stampare.** Crea una lista di quattro frutti, stampala intera, poi il primo e
   l'ultimo elemento.
2. **Posizioni.** Dato `xs = [10, 20, 30, 40]`, che cosa stampano `xs[1]`, `xs[4]`, `xs[5]`?
   Esegui e spiega l'ultimo risultato.
3. **Sostituire.** Dato `xs = [1, 2, 3]`, sostituisci l'elemento in posizione 2 con `20` e
   stampa la lista.
4. **`push!` e `length`.** Parti da una lista vuota e aggiungi tre numeri, stampando la
   lunghezza dopo ogni aggiunta.
5. **Giro completo.** Stampa tutti gli elementi di una lista con un `while` e un contatore.
6. **Somma.** Calcola e stampa la somma degli elementi di `[3, 5, 8, 1]`.
7. **Il più grande.** Trova il valore più grande di una lista di interi con un ciclo.
8. **Conta i pari.** Conta quanti elementi di una lista di interi sono pari.
9. **Alias o copia?** Dimostra che dopo `alias = xs` le due variabili indicano la stessa lista
   (come nell'esempio del capitolo); poi crea una **copia vera** con un ciclo e verifica che
   modificarla non cambi l'originale.
10. **Liste dentro le liste.** Crea `[[1, 2], [3, 4]]`, stampa `xs[1]` e spiega che cosa vedi:
    è un numero o un'altra lista?

## 10. Funzioni: dare un nome a un'operazione

### Esercizi

1. **Forma breve.** Scrivi `doppio(x) = x * 2` e usala in un'espressione che stampi il doppio di
   `21`.
2. **Forma blocco.** Scrivi `massimo(a, b)` con `function`/`end` e un `if`, e provala con le
   coppie `(3, 9)`, `(9, 3)`, `(4, 4)`.
3. **`return` anticipato.** Scrivi `descrivi(n)` che restituisca `negativo`, `zero` o `positivo`
   usando due `return` e l'ultima espressione.
4. **Argomenti e parametri.** Nel programma `quadrato(7)`, quali sono la chiamata, l'argomento,
   il parametro? Scrivi un commento che li nomini tutti.
5. **Arity mismatch.** Chiama una funzione a un parametro con due argomenti: leggi l'errore e
   spiega in italiano che cosa significa.
6. **Comporre.** Scrivi `area_rettangolo(l, h)` e poi `doppia_area(l, h)` che riusi la prima
   funzione: stampa entrambi i risultati per `(3, 4)`.
7. **Variabili locali.** Crea dentro una funzione una variabile `temp` e provaci ad accedere
   fuori: che cosa succede?
8. **Non è una funzione.** Esegui `x = 5` e poi `x()`: quale errore ottieni? Che cosa voleva dire
   il linguaggio?
9. **Testo ripetuto.** Scrivi `ripeti(s, n)` che restituisca `s` concatenata `n` volte e
   provala con `("ab", 3)`: atteso `"ababab"`.
10. **Due saluti.** Scrivi `saluto(nome)` che restituisca `"ciao " * nome` e un programma che la
    chiami due volte con argomenti diversi, usando il risultato in due `println`.

## 11. Ricorsione: una funzione che chiama sé stessa

### Esercizi

1. **Conto alla rovescia.** Scrivi `conta(n)` che stampi i numeri da `n` a 1 e poi `via!` in
   forma ricorsiva.
2. **Fattoriale.** Scrivi `fattoriale(n)` in forma breve con il ternario e verifica `fattoriale(5)`
   (`120`) e `fattoriale(1)` (`1`).
3. **Somma.** Scrivi `somma(n)` che restituisca `1 + 2 + … + n` in forma ricorsiva; confronta il
   risultato con la versione a ciclo del capitolo 8.
4. **Potenza.** Scrivi `potenza(x, n)` che calcoli `x^n` moltiplicando, in forma ricorsiva.
5. **Fibonacci.** Scrivi `fib(n)` ricorsivo (`fib(1) = 0`, `fib(2) = 1`) e stampa i primi dieci
   valori.
6. **Senza caso base.** Togli il caso base a `fattoriale` ed esegui: che cosa succede? Perché il
   programma si ferma invece di girare all'infinito?
7. **La catena.** Scrivi su un foglio tutte le chiamate che fa `fattoriale(5)` prima di produrre
   `120`, nell'ordine in cui cominciano e in cui finiscono.
8. **Troppe chiamate.** Esegui `conta_alla_rovescia(10000)`: che cosa succede quando le chiamate
   in attesa diventano troppe?
9. **Ciclo o ricorsione?** Riscrivi `fattoriale` con un `while` e confronta i due programmi:
   quale preferisci e perché?
10. **Doppia ricorsione.** Scrivi una funzione che, dato `n`, stampi i numeri da 1 a `n` e poi da
    `n` a 1, ricorsivamente (suggerimento: due funzioni che si chiamano a vicenda).

## 12. Errori e debug: cosa fare quando il programma non funziona

### Esercizi

1. **Fine mancante.** Scrivi un `if` senza `end` ed esegui: a quale famiglia appartiene
   l'errore? Leggi il messaggio tutto intero.
2. **Due famiglie.** Classifica questi errori in `parse error` o `error`: parentesi tonda non
   chiusa, variabile senza assegnamento, `end` mancante, operazione `"ciao" + 1`.
3. **Traduci il messaggio.** Dato `error: + type error`, in italiano che cosa è successo? Qual è
   la riga sospetta in un programma che calcola il totale di due prezzi?
4. **Il metodo in quattro passi.** Un programma che dovrebbe sommare i numeri da 1 a 5 stampa
   sempre `0`: applica i quattro passi del capitolo e trova il bug.
5. **Debug con `println`.** Prendi un programma tuo con un errore e aggiungi `println` di controllo
   finché non individui la riga colpevole: quante ne sono bastate?
6. **`end` in più.** Aggiungi un `end` di troppo a un programma corretto: quale messaggio ottieni?
7. **Fuori lista.** Esegui `xs = [1, 2]` e `println(xs[3])`: che errore? Come si chiama la regola
   violata?
8. **Refuso nel nome.** Scrivi un programma che usi `punteggio` e poi `punteggio_totale` per
   errore: quale messaggio? Come si riconosce subito?
9. **Diagnosi.** Un programma stampa sempre l'ultimo valore invece della somma: quale errore
   classico del capitolo 12.4 potrebbe esserne la causa? Verifica la tua ipotesi.
10. **Allenamento al metodo.** Scrivi tre programmi sbagliati apposta (uno di sintassi, uno di
    tipo, uno di logica) e riscoprili usando solo il metodo in quattro passi.

## 13. Pensare da programmatore: scomporre un problema

### Esercizi

1. **Esempi in mano.** Per il problema «stampare i numeri da 1 a 30 che sono multipli di 3 o di
   5», scrivi tre esempi di output atteso **prima** di scrivere codice.
2. **Scomporre.** Scrivi la bozza in italiano (solo passi, nessun codice) per «contare quanti
   numeri di una lista sono maggiori di 10».
3. **Versione semplice.** Risolvi prima «stampare tutti i numeri da 1 a 20» e solo poi aggiungi
   il filtro dei multipli: esegui entrambe le versioni.
4. **Casi scomodi.** Per il riconoscimento dell'anno bisestile, elenca almeno quattro casi
   «scomodi» da provare e spiega perché proprio quelli (2000, 1900, 2040, 2023…).
5. **Verificare spesso.** Scrivi il programma dei multipli in tre versioni successive, eseguendo
   **ognuna** prima di passare alla successiva.
6. **Rifallo a mano.** Un programma dice che il 1900 è bisestile: rifai il calcolo a mano e
   individua l'errore nella regola scritta.
7. **Due pezzi indipendenti.** Scomponi «stampare la tabellina del 7 in forma `7 x 1 = 7`» in due
   pezzi e risolvili separatamente prima di unirli.
8. **Sei bloccato.** Applica la sequenza del capitolo 13.5 a un problema su cui sei davvero
   bloccato: quale passo ti ha sbloccato?
9. **Riusare il metodo.** Applica i cinque passi a «stampare tutti gli anni bisestili tra 1900 e
   2000»: scrivi esempi, bozza, versione semplice, versione completa.
10. **Un problema tuo.** Inventati un piccolo problema che richieda un `if` e un `while`,
    risolvilo col metodo dei cinque passi e scrivi in fondo «come ho verificato che funziona».

## 14. Glossario dei termini informatici

### Esercizi

1. **Argomento o parametro?** In `saluta("Ada")` e in `function saluta(nome)`, dove sono
   l'argomento e il parametro? Spiega la differenza con le tue parole.
2. **Due mestieri.** Differenza tra compilatore e interprete: quale dei due usa Triad oggi e
   come si vede nel tuo ciclo di lavoro?
3. **I pezzi di un ciclo.** Prendi il programma del capitolo 8 che somma i numeri da 1 a 100 e
   nomina: contatore, condizione, avanzamento, iterazione, caso (o girata).
4. **Vero o falso.** Valuta: «le liste sono immutabili», «il caso base interrompe una ricorsione»,
   «una variabile può cambiare tipo», `"42"` e `42` sono lo stesso valore», «`println` è una
   funzione».
5. **La tua definizione.** Scrivi con le tue parole, una frase ciascuna: *espressione*, *tipo*,
   *bug*, *runtime*. Confronta con il glossario.
6. **Associa.** Collega ogni termine al suo esempio: *funzione*, *chiamata*, *parametro*,
   *argomento*, *ritorno* — esempi: `quadrato(x) = x * x`, `quadrato(7)`, `x`, `7`, `49`.
7. **Il glossario di un programma.** Prendi un tuo programma e annota accanto a ogni riga almeno
   un termine del glossario (assegnamento, espressione, condizione…).
8. **Quale parola?** «Un elenco ordinato di valori raggiungibili per posizione», «un nome
   associato a un valore che può cambiare», «una finestra in cui si danno comandi»: quali termini
   del glossario descrivono queste frasi?
9. **Parole che confondono.** Scrivi una frase che distingua *parametro* da *argomento* e una che
   distingua *valore* da *variabile*.
10. **Ripasso senza libro.** Elenca a memoria i sei tipi di base di Triad con un esempio per
    ciascuno, poi controlla con la tabella del capitolo 3.

## 15. Una domanda che capita spesso: cosa sono «success» e «fail»?

### Esercizi

1. **Mini-verificatore.** Scrivi il programma PASS/FAIL dell'esempio, poi cambia `atteso` in
   `"43"` e verifica di ottenere `FAIL`.
2. **Cinque tentativi.** Dati i tentativi `["41", "43", "42", "42", "40"]`, stampa una riga per
   tentativo con il suo esito, come nell'esempio del capitolo.
3. **pass@1 e pass@k.** Con i tentativi dell'esercizio 2: il pass@1 è PASS o FAIL? E il pass@3?
   Spiega la differenza fra le due metriche.
4. **Codice di uscita.** Esegui un programma corretto e uno che va in errore: come controlli il
   codice di uscita dal terminale? (`echo $?` su Linux/macOS, `echo %ERRORLEVEL%` su Windows.)
5. **Due significati di «fail».** Spiega la differenza tra il `FAIL` della verifica di un task e
   il fallimento di un goal nella programmazione logica del capitolo 15.3.
6. **Scrivi un task.** Progetta un task come quelli di `ai/tasks/`: il problema in linguaggio
   naturale e due esempi di output atteso.
7. **Verdetto con `if`.** Riscrivi il mini-verificatore usando un `if` completo invece del
   ternario: l'output è lo stesso?
8. **Conta i PASS.** Dati cinque tentativi con output diversi, stampa quanti sono PASS e quanti
   FAIL.
9. **Perché il FAIL serve.** Un compagno dice che un FAIL significa «ho sbagliato tutto»: scrivi
   due righe per spiegargli che il FAIL è invece informazione su dove guardare.
10. **Verifica automatica.** Scrivi un programma che controlli che `fattoriale(5)` sia `120` e
    stampi `PASS` o `FAIL`; poi rendi «sbagliata» la funzione e verifica che il verdetto cambi.

## 16. Domande da neofita

### Esercizi

1. **Ciclo infinito, apposta.** Scrivi un ciclo senza uscita, interrompilo con `Ctrl+C`, poi
   correggilo e riesegui: quale pezzo mancava?
2. **`+` tra testi.** Dimostra con un programma perché `"42" + 1` è un errore e scrivi la forma
   corretta che ottiene `43`.
3. **Con la scheda in mano.** Usando solo l'Appendice B, scrivi un programma che usi un ciclo,
   una lista e una funzione: quanti sguardi alla scheda ti sono serviti?
4. **`=` per `==`.** Scrivi apposta un programma con questo errore, eseguilo e riconosci il
   problema dal comportamento e dal messaggio.
5. **Accentate.** Salva un programma che stampi `perché` e `già`: se le accentate escono strane,
   il file non è in UTF-8 — risalva e controlla.
6. **Lambda dalla scheda.** Consulta B.8 e scrivi una lambda che raddoppi il suo argomento;
   assegnala a un nome e chiamala.
7. **Memoria.** Senza guardare, scrivi lo scheletro di un `if` e di un `while`; poi confronta con
   B.5 e B.6.
8. **Un programma utile.** Scrivi un piccolo programma che converta dei minuti in secondi e
   stampi la frase completa: è già un programma «da vero mondo» entro i limiti di Core.
9. **Errori in inglese.** Procurati tre messaggi d'errore diversi e traducili con la tabella del
   capitolo 12: quale regola del linguaggio viola ciascuno?
10. **Il tuo elenco.** Prendi spunto dalla domanda «quanto tempo ci vuole?» e scrivi l'elenco di
    cinque piccoli problemi che risolverai nella prossima settimana.

## 17. Come proseguire

### Esercizi

1. **Mappa del volume.** In quale parte del libro trovi la spiegazione di `solve`? E degli errori
   come dati? E della grammatica?
2. **Core o Full?** Classifica questi costrutti: `while`, `fact`, `struct`, `lambda`, `for`,
   `macro`, `push!`, `solve`, `try`.
3. **Il primo esempio del Tutorial.** Scegli un programma della parte II del Tutorial, eseguilo e
   confronta l'output con quello del libro.
4. **Perché non gira?** Un esempio con `fact` non viene eseguito dal runtime attuale: spiega
   perché, usando la distinzione Core/Full.
5. **I marcatori.** Che cosa significano **[Core]** e **[Full]**? Trova tre esempi di ciascuno
   nel libro.
6. **I comandi.** Scrivi a memoria il comando per eseguire `ciao.triad` e quello per eseguire un
   caso di conformance; poi controlla.
7. **Il tuo percorso.** Scrivi l'ordine dei capitoli che studierai dopo le Fondamenta e perché.
8. **Verso il Manuale.** Scegli un capitolo del Manuale, leggilo e risolvi almeno tre dei suoi
   esercizi.
9. **Verso il Tutorial.** Esegui il programma del capitolo 3 del Tutorial passandogli due
   argomenti da riga di comando e osserva `ARGS`.
10. **Il programma finale.** Scrivi un programma che usi almeno quattro costrutti visti nelle
    Fondamenta (variabili, stringhe, `if`, `while`, liste o funzioni) e commentalo riga per riga.

---

## Esercizi generali

Gli esercizi sono in ordine di difficoltà. Per ciascuno scrivi il programma, eseguilo, confronta
l'output: solo dopo, se serve, guarda la soluzione in fondo. Un esercizio «fatto» è un esercizio
**eseguito**, non letto.

1. **Saluto personalizzato.** Scrivi un programma che associ a una variabile `nome` il tuo nome e
   stampi `ciao, <nome>!`.
2. **Doppio e quadrato.** Dato `n = 7`, stampa il suo doppio e il suo quadrato, ciascuno su una
   riga.
3. **Pari o dispari.** Data una variabile `n`, stampa `pari` o `dispari` a seconda del valore.
   *(Suggerimento: guarda il resto della divisione per 2.)*
4. **Tavola del 3.** Stampa i primi dieci multipli di 3, uno per riga, usando un ciclo `while`.
5. **Conto alla rovescia.** Chiedi al programma di stampare i numeri da 10 a 1, uno per riga.
6. **Il più grande.** Data una lista di interi `[4, 19, 2, 8]`, stampa il valore più grande.
7. **Conta i negativi.** Data una lista di interi, stampa quanti sono minori di zero.
8. **Somma di liste.** Scrivi una funzione `somma_lista(xs)` che restituisca la somma degli
   elementi di una lista, e usala con due liste diverse.
9. **Password semplice.** Scrivi una funzione `controlla(password)` che restituisca `:ok` se la
   stringa è lunga almeno 8 byte, `:corta` altrimenti. Provala con tre password diverse.
10. **Fibonacci.** Scrivi una funzione `fib(n)` che produca l'ennesimo numero di Fibonacci
    (0, 1, 1, 2, 3, 5, 8, …; ogni numero è la somma dei due precedenti). Prima con un ciclo,
    poi — se ti va — in forma ricorsiva.
11. **Stella.** Scrivi un programma che, dato un intero `n`, stampi `n` righe: la prima con una
    `*`, la seconda con due, e così via.
12. **Traduttore di voti.** Scrivi una funzione che, dato un voto da 0 a 10, restituisca il
    giudizio: `:insufficiente` fino a 5, `:sufficiente` fino a 6, `:buono` fino a 8,
    `:ottimo` oltre. Controlla anche il caso del voto fuori intervallo.

### Soluzioni

**1. Saluto personalizzato**

```triad
nome = "Ada"
println("ciao, " * nome * "!")
```

Output:

```text
ciao, Ada!
```

**2. Doppio e quadrato**

```triad
n = 7
println(n * 2)
println(n * n)
```

Output:

```text
14
49
```

**3. Pari o dispari** — il resto della divisione per 2 è `0` per i pari:

```triad
n = 7
if n % 2 == 0
    println("pari")
else
    println("dispari")
end
```

Output:

```text
dispari
```

**4. Tavola del 3** — il contatore `i` gira da 1 a 10 e a ogni giro stampa `3 * i`:

```triad
i = 1
while i <= 10
    println(3 * i)
    i += 1
end
```

Output:

```text
3
6
9
12
15
18
21
24
27
30
```

**5. Conto alla rovescia** — il contatore scende, e la condizione si legge al contrario:

```triad
n = 10
while n >= 1
    println(n)
    n -= 1
end
```

Output:

```text
10
9
8
7
6
5
4
3
2
1
```

**6. Il più grande** — si parte dal primo elemento come massimo provvisorio e si confronta con gli
altri. La funzione `massimo` del [capitolo 10](FONDAMENTA.it.md#fond-10) torna utile:

```triad
xs = [4, 19, 2, 8]
migliore = xs[1]
i = 2
while i <= length(xs)
    if xs[i] > migliore
        migliore = xs[i]
    end
    i += 1
end
println(migliore)
```

Output:

```text
19
```

**7. Conta i negativi** — schema «conta se soddisfa»:

```triad
xs = [3, -1, -7, 0, 2]
quanti = 0
i = 1
while i <= length(xs)
    if xs[i] < 0
        quanti += 1
    end
    i += 1
end
println(quanti)
```

Output:

```text
2
```

**8. Somma di liste** — la stessa funzione, chiamata su liste diverse:

```triad
function somma_lista(xs)
    totale = 0
    i = 1
    while i <= length(xs)
        totale += xs[i]
        i += 1
    end
    totale
end

println(somma_lista([1, 2, 3]))
println(somma_lista([10, 20]))
```

Output:

```text
6
30
```

**9. Password semplice** — `length` conta i byte; si restituiscono simboli come etichette:

```triad
function controlla(password)
    if length(password) >= 8
        :ok
    else
        :corta
    end
end

println(controlla("segretissimo"), " ", controlla("abc"))
```

Output:

```text
ok corta
```

**10. Fibonacci** — versione con ciclo, che aggiorna due valori a ogni giro; poi la versione
ricorsiva, che è quasi la definizione stessa del problema:

```triad
function fib(n)
    a = 0
    b = 1
    i = 1
    while i <= n
        t = a + b
        a = b
        b = t
        i += 1
    end
    a
end

fib_ric(n) = n < 2 ? n : fib_ric(n - 1) + fib_ric(n - 2)

println(fib(10), " ", fib_ric(10))
```

Output:

```text
55 55
```

**11. Stella** — doppio ciclo: quello esterno sceglie la riga, quello interno stampa le `*`:

```triad
n = 4
riga = 1
while riga <= n
    riga_di_stelle = ""
    j = 1
    while j <= riga
        riga_di_stelle = riga_di_stelle * "*"
        j += 1
    end
    println(riga_di_stelle)
    riga += 1
end
```

Output:

```text
*
**
***
****
```

**12. Traduttore di voti** — una catena di `elseif`, con un controllo finale sui valori fuori
intervallo. Attenzione all'ordine: il controllo sui fuori intervallo va **prima** degli altri:

```triad
function giudizio(voto)
    if voto < 0 || voto > 10
        :errore
    elseif voto <= 5
        :insufficiente
    elseif voto == 6
        :sufficiente
    elseif voto <= 8
        :buono
    else
        :ottimo
    end
end

println(giudizio(3), " ", giudizio(6), " ", giudizio(7), " ", giudizio(10), " ", giudizio(11))
```

Output:

```text
insufficiente sufficiente buono ottimo errore
```

---
