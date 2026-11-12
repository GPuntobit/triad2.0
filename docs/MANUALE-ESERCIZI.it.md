# Esercizi — Manuale di Triad 2.0

> Gli esercizi del [Manuale di Triad 2.0](MANUALE.it.md), raccolti in un file
> separato per non appesantire il testo del manuale. I rimandi a «cap. N»
> e a «cap. N.M» indicano i capitoli e le sezioni del manuale.

## Esercizi per capitolo

### 1. Lessico

#### Esercizi

1. Scrivi un programma che stampi il tuo nome e la tua età su due righe, usando `\n` e
   concatenazione di stringhe.
2. Definisci un identificatore con `_` iniziale e uno con `!` finale; stampali.
3. Prova a scrivere `x = 1_000_000` e verifica che l'output sia `1000000`.
4. (Full) Scrivi una stringa con interpolazione `$x` e `$(x + 1)`.
5. (Full) Definisci il simbolo `:ok` e confrontalo con `Symbol("ok")`.
6. Scrivi un programma con un commento `#` e un commento lungo `#= ... =#`: che cosa cambia
   nell'output? E nel sorgente?
7. Scrivi tre istruzioni su una sola riga separate da `;`: il programma funziona ancora?
8. Quale di questi è un identificatore valido? `_x`, `x!`, `x-y`, `2x`, `x2`, `!x`, `x y`.
   Prova a usarli davvero, non solo a guardarli.
9. Scrivi una stringa che contenga tutti e quattro gli escape Core (`\n`, `\t`, `\"`, `\\`) e
   stampala: l'output corrisponde a ciò che avevi in mente?
10. Quali di queste righe vengono accettate? `x = 1_000_000`, `y = 1__0`, `z = 1.5` (l'ultimo
    caso è Full: `Float`).
11. Prova a innestare due commenti lunghi (`#= ... #= ... =# ... =#`): quale `=#` chiude il
    commento?
12. Scrivi una chiamata a `println` spezzata su due righe: che cosa succede e perché?

### 2. Valori e tipi

#### Esercizi

1. **Tutti i tipi.** Scrivi un programma che stampi `typeof` di un valore per ciascuno dei tipi
   di base e confronta i risultati con la tabella 2.1.
2. **Gerarchia.** **[Full]** Con `isa` verifica che `1` è `Int`, `Number` e `Any`, ma non `String`.
3. **Struct.** **[Full]** Definisci `struct Punto x::Int y::Int end`, costruisci un valore e
   stampalo; poi accedi a un campo.
4. **Conversioni.** **[Full]** Converti `3` in `Float`, `"42"` in `Int`, `42` in `String`,
   `"ciao"` in `Symbol` e stampa tutto.
5. **Conversioni Core.** Quali conversioni funzionano anche in Core? Prova `Int("41") + 1` e
   `Symbol("bob")` e confronta con il caso `Float(3)`.
6. **Asserzione di tipo.** **[Full]** Dato `x = 3`, che cosa producono `x::Int` e `x::String`?
   Come verifichi il secondo caso senza far terminare il programma?
7. **Vincolo del dichiarato.** **[Full]** `x::Int = 5`, poi `x = 6`, poi `x = 5.5`: quale riga
   fallisce, e perché l'errore arriva proprio lì?
8. **Vincolo e `let`.** **[Full]** Dato `x::Int = 5`, che cosa succede a `let x = 2.5` dentro una
   funzione? Che regola del capitolo 2.6 si applica?
9. **Solo `Bool`.** Quali di queste condizioni sono ammesse? `if 1`, `if x`, `if x == 0`,
   `if length(xs) > 0`. Prova a eseguirle tutte.
10. **Come stampa.** Prevedi e verifica l'output di `println([1, :a, "s", true, nothing, [2, 3]])`
    e di `println(:alice)`: perché il simbolo appare in due forme diverse?
11. **Uguaglianza.** Che cosa valgono `[1, [2]] == [1, [2]]`, `"ab" == "a" * "b"` e `f == f` dove
    `f(x) = x`? Spiega la regola applicata in ciascun caso.
12. **Funzione stampata.** Assegna una lambda a un nome e stampala: che cosa vedi? Confronta con
    la tabella 2.8 e con la nota sul seed.

### 3. Variabili e assegnamento

#### Esercizi

1. **L'assegnamento vale un valore.** Che cosa stampa `println(x = 42)`? Perché in Triad ha
   senso che un assegnamento sia un'espressione?
2. **Senza scorciatoie.** Riscrivi `n += 5`, `n -= 3`, `n *= 2` nella forma esplicita: l'output
   finale cambia?
3. **Valore aggiornato.** Dopo `n = 10`, che cosa stampa `println(n += 1)`? Di che tipo è quel
   valore?
4. **Una volta sola.** Spiega perché in `xs[i] += 1` il lato sinistro viene valutato una sola
   volta, e che cosa succederebbe se venisse valutato due volte.
5. **Nome inesistente.** `println(contatore)` senza assegnamento: quale errore? Perché nessun
   controllo segnala il refuso mentre scrivi?
6. **Riassegnare o mutare.** Dati `xs = [1, 2]` e `alias = xs`: che cosa vede `alias` dopo
   `xs[1] = 9`? E dopo `xs = [5]`?
7. **`if x = 5`.** Perché è un errore anche se l'assegnamento produce un valore? Quale regola
   del capitolo 2.7 si applica?
8. **Tabella dei valori.** Traccia `x = 42`, `y = x + 8`, `x = x + 1`, `z = (x + y) * 2` e
   conferma l'output `43 50 186`.
9. **Due legami indipendenti.** Dimostra con un programma che cambiare `x` dopo `y = x + 8` non
   cambia `y`.
10. **Vincolato e libero.** **[Full]** Confronta `x::Int = 5` e `s = "a"`: come si comportano gli
    assegnamenti successivi con tipi diversi? Scrivi un esempio per ciascuno.

### 4. Operatori e precedenza

#### Esercizi

1. **Precedenza.** Calcola a mano `2 + 3 * 4`, `2 ^ 3 ^ 2`, `!true && false`, `1 + 2 == 3` e
   verifica con un programma.
2. **`^` è destra.** Perché `2 ^ 3 ^ 2` vale `512` e non `64`? Scrivi con le parentesi il
   raggruppamento effettivo.
3. **Cortocircuito.** **[Full]** Scrivi una condizione che usi `&&` per evitare la divisione per
   zero in `a / b > 1`, e provala con `b = 0`.
4. **Ternario e lambda.** A che livello di precedenza stanno `?:` e `->`? Scrivi un'espressione
   che usi entrambi e spiegane il raggruppamento.
5. **Resto dei negativi.** Che cosa valgono `-7 % 3` e `7 % -3`? Verifica e confronta con la tua
   idea di «resto».
6. **Catene di confronto.** Che cosa succede con `1 < 2 < 3`? Perché il risultato (o l'errore) è
   quello che vedi?
7. **`in`, `isa`, `is`.** **[Full]** Prova `1 in [1, 2]`, `isa(1, Int)` e `is(1, 1)`: che ruolo ha
   ciascuno dei tre operatori?
8. **Range senza spazi.** **[Full]** Scrivi `1:5` e poi `1 : 5`: perché il secondo non è un
   range?
9. **Segno e potenza.** Prevedi i valori di `-2 ^ 2` e `(-2) ^ 2`, poi verifica: a quale regola
   di precedenza si riconduce la differenza?
10. **Parentesi esplicite.** Riscrivi `1 + 2 * 3 == 7 || false` introducendo tutte le parentesi
    che rispecchiano la tabella dei livelli: il risultato cambia?

### 5. Controllo di flusso

#### Esercizi

1. **`if` come espressione.** Usa un `if` come valore in un assegnamento e come argomento di
   `println`.
2. **Cerca con `break`.** Scrivi un ciclo che trovi il primo intero il cui quadrato superi 1000
   e lo stampi.
3. **`continue`.** Scrivi un ciclo che stampi i dispari da 1 a 9 usando `continue`; poi riscrivilo
   senza `continue` (la forma equivalente del volume) e confronta gli output.
4. **Uscire da due cicli.** Con due `while` annidati e una variabile di stato, interrompi entrambi
   appena `a * b` supera 20.
5. **`let`.** Che cosa succede a una variabile creata dentro un `let` dopo il blocco? Verifica con
   un accesso dall'esterno.
6. **`begin`.** A cosa serve `begin … end`? Usalo dove serve un'espressione ma devono eseguirsi
   più istruzioni.
7. **`for` e range.** **[Full]** Riscrivi un `while` che somma 1..10 con un `for i in 1:10`.
8. **Comprehension.** **[Full]** Costruisci con una comprehension la lista dei quadrati da 1 a 5;
   poi aggiungi un filtro che tenga solo i dispari.
9. **`try`/`catch`.** **[Full]** Cattura `Int("ciao")` con `try/catch` e stampa la categoria
   dell'errore catturato.
10. **`while` come espressione.** Che cosa produce `x = while … end`? Provalo sull'interprete di
    riferimento e confronta con la nota sul seed del capitolo 27.

### 6. Funzioni

#### Esercizi

1. **Tre forme.** Scrivi la stessa funzione (`triplo`) nelle tre forme: breve, blocco e anonima
   assegnata a un nome.
2. **Che cosa restituisce?** Che valore produce una funzione il cui corpo termina con
   `println(...)`? Verifica usando il risultato in un'espressione.
3. **`return` e ultima espressione.** Scrivi `segno(n)` in due versioni: con `return` anticipati e
   solo con l'ultima espressione.
4. **Arity.** Quali errori ottieni chiamando `f(1)` e `f(1, 2, 3)` per `function f(a, b)`?
5. **Ricorsione.** Scrivi `fib(n)` e `fattoriale(n)` ricorsivi e riscrivi `fattoriale` a ciclo:
   confronta i due programmi.
6. **Ordine superiore.** Scrivi `applica(f, x)` e usala con una lambda e con una funzione con
   nome.
7. **Funzione come valore.** Assegna una funzione a una variabile, passala come argomento e
   restituiscila da un'altra funzione.
8. **Effetto `!io`.** **[Full]** Perché una funzione senza `!io` che chiama `println` produce
   `Err(:effect)`? Scrivi l'esempio e correggi la firma.
9. **Effetti delle lambda.** **[Full]** Una lambda creata dentro una funzione `!io` può stampare?
   Verifica con un esempio.
10. **Ordine di definizione.** Che cosa succede se chiami una funzione prima della sua riga di
    definizione? Perché?
11. **Ricorsione sinistra.** **[Full]** `f(n) = f(n + 1)` senza limiti: che cosa succede? Avvolgi
    la chiamata in `with budget` e confronta i due comportamenti.

### 7. Tipi e multiple dispatch

#### Esercizi

1. **Tipo di ritorno.** **[Full]** In `function f(x)::Int`: che cosa succede se il corpo
   restituisce una stringa? E se restituisce un `Float`?
2. **Firme tipate.** **[Full]** Definisci `area(x::Int)` e `area(x::Float)`: quale metodo viene
   scelto per `area(1)` e per `area(1.5)`?
3. **Più specifico vince.** **[Full]** Aggiungi `area(x::Number)`: per `1.5` quale dei tre metodi
   scatta, e perché?
4. **Nessun metodo.** **[Full]** `area("x")`: quale errore? Che cosa contiene `data.types`?
5. **Ambiguità.** **[Full]** Costruisci due firme incomparabili (`f(a::Int, b::Number)` e
   `f(a::Number, b::Int)`) e osserva `Err(:ambiguous)` con `f(1, 1)`.
6. **Funzioni locali.** Definisci una funzione dentro un'altra: dove è visibile? Prova a chiamarla
   dall'esterno.
7. **Fallback su `Any`.** **[Full]** Un metodo su `Any`: quando viene scelto? Scrivi un esempio con
   due metodi più specifici e uno su `Any`.
8. **Ridefinire una firma.** **[Full]** Dichiarare due volte la stessa firma: sostituisce o
   aggiunge un metodo? Verifica.
9. **Metodi su un operatore.** **[Full]** Definisci `+` per una struct `Point` e prova `p1 + p2`:
   che cosa succede al builtin `+` per gli altri tipi?
10. **Conversione del ritorno.** **[Full]** Scrivi una funzione `::Float` che restituisce un `Int`:
    il risultato arriva convertito? Verifica stampandolo.

### 8. Lambda, chiusure e scope

#### Esercizi

1. **Lambda e chiamata.** Scrivi `x -> x * 2`, assegnala a un nome e chiamala su un valore.
2. **Due parametri.** Riscrivi `function (a, b) a + b end` in forma lambda: quale limite ha questa
   forma sul seed Windows (cap. 27)?
3. **Un contatore.** Scrivi `contatore()` che restituisce una funzione che a ogni chiamata restituisce
   il valore successivo: quale tecnica di stato usi, e come si comporta sui due runtime?
4. **Visibilità.** Una funzione vede le variabili del programma che la contiene? E il programma
   vede quelle nate dentro la funzione? Verifica entrambe le direzioni.
5. **Shadowing con `let`.** Dato `x = 1` esterno, che cosa stampa `let x = 2` dentro il blocco e
   che cosa resta fuori?
6. **Parametri e argomenti.** Modificare un parametro dentro la funzione cambia l'argomento del
   chiamante? Prova con un `Int` e con una lista.
7. **Lambda come argomento.** Passa `f = x -> x + 1` a una funzione di ordine superiore e usala
   nel corpo.
8. **Chiusura su una lista.** Una chiusura che cattura una lista vede le modifiche fatte con
   `push!`? Verifica.
9. **Conteggio delle chiamate.** Scrivi una funzione che restituisca una lambda e osserva quante
   volte la cattura «per valore» del seed cambia il risultato rispetto alla cattura condivisa.
10. **Anonima o lambda?** Riscrivi ciascuna delle due forme nell'altra: `function (x) x * x end`
    e `(a, b) -> a - b`.

### 9. Liste

#### Esercizi

1. **Costruzione.** Crea liste miste e annidate e stampale: confronta l'output con le regole di
   formattazione del capitolo 2.8.
2. **Indici ed `end`.** **[Full]** Prova `xs[1]`, `xs[length(xs)]` e `xs[end]`: quale forma è
   più leggibile? Verifica anche in scrittura (`xs[end] = v`).
3. **Modificare la lista.** **[Full]** Usa `push!`, `pop!` e `append!` e stampa la lista dopo ogni
   operazione.
4. **`sum` scritto a mano.** Calcola la somma di una lista con un ciclo Core, poi confronta con il
   builtin `sum` **[Full]**.
5. **`reverse` scritto a mano.** Implementa l'inversione di una lista senza `reverse`, poi
   confronta con il builtin.
6. **Ordine superiore su liste.** **[Full]** Con `map`, `filter` e `count` seleziona i numeri
   maggiori di 10 e conta gli elementi pari.
7. **Alias e mutabilità.** Dati `xs` e `alias = xs`, dimostra che `xs[1] = 9` è visibile ad
   `alias`, mentre `xs = [5]` no.
8. **Contatore di frequenze.** Data una lista di interi 1..3, usa `xs[i] += 1` per contare le
   occorrenze di ciascun valore.
9. **Fuori intervallo.** Quali errori si ottengono con `xs[0]`, `xs[length(xs) + 1]` su una lista
   di 3 elementi? Confronta con la categoria `:bounds`.
10. **Liste e funzioni.** Scrivi `massimo(xs)` e `ultima_posizione(xs, v)` e provalle su casi limite
    (lista vuota, elemento assente): che cosa devono restituire?

### 10. Stringhe, simboli e conversioni

#### Esercizi

1. **Concatenazione.** Costruisci una frase da almeno quattro pezzi usando `*` e `string()`.
2. **Byte, non lettere.** Spiega e verifica `length("è") == 2`: che implicazioni ha per un
   programma che «taglia» testo?
3. **Escape conosciuti e sconosciuti.** Prova `"a\nb"`, `"a\tb"`, `"a\"b"`, `"a\\b"` e poi
   `"a\q"`: quale riga produce `Err(:syntax)` e con quali informazioni?
4. **Interpolazione.** **[Full]** Riscrivi con l'interpolazione `"$x"` e `"$(x + 1)"` un saluto
   che in Core richiedeva concatenazione.
5. **`string` e `repr`.** **[Full]** Confronta `string(:a)` e `repr(:a)`, e `string("s")` con
   `repr("s")`: quando serve l'uno e quando l'altro?
6. **Da testo a numero.** Converti `"41"` con `Int`, aggiungi 1 e riconverti in testo; poi prova
   `Int("ciao")` e spiega l'errore.
7. **Simboli.** Confronta `:alice` con `Symbol("alice")` e spiega l'output di `println(:alice)`
   rispetto a `println([:alice])`.
8. **Funzione stampata.** **[Full]** Stampa una funzione (`repr` e `string`): che forma ha la sua
   rappresentazione?
9. **`ripeti` con un ciclo.** Scrivi `ripeti(s, n)` che concateni `s` `n` volte senza ricorsione.
10. **Conversioni a catena.** Partendo da `"123"`, arriva a `"124"` usando solo `Int`, `string` e
    aritmetica, e spiega ogni passaggio.

### 11. Errori come dati

#### Esercizi

1. **Costruire un errore.** **[Full]** Crea un `Err` con `err(...)`/`Err(...)`, ispeziona `.kind` e
   stampalo.
2. **Catturare.** **[Full]** Con `try … end` cattura un errore di tipo e stampa la sua categoria.
3. **Le categorie.** Abbina ogni categoria a un programma che la produce: `:syntax`, `:undef`,
   `:type`, `:method`, `:bounds`, `:contract`, `:budget`, `:effect`.
4. **Propagazione.** **[Full]** Un errore non gestito a che cosa porta? Verifica codice di uscita,
   messaggio e riga segnalata.
5. **Errori in Core.** Scrivi `err(kind, msg) = [:Err, kind, msg]` e `iserr(x)` come nel capitolo
   11.4 e usali in un piccolo programma.
6. **Dispatch sulla categoria.** **[Full]** Scrivi una funzione che, dato un `Err`, restituisca un
   messaggio diverso per `:type` e per `:bounds`.
7. **`:method` o `:ambiguous`?** Scrivi un esempio per ciascuna delle due categorie e spiega la
   differenza.
8. **I dati dell'errore.** **[Full]** Che cosa contengono `data` per un `:syntax` (`line`, `col`,
   `incomplete`) e per un `:method` (`data.types`)? Costruisci un esempio per ciascuno.
9. **Fallire come valore.** Riscrivi una funzione che termina il programma con `exit`/errore in
   una che restituisce un `Err` (o una lista taggata) e gestiscilo al chiamante.
10. **Messaggi o categorie?** Perché il programma deve confrontare `kind` e non il testo del
    messaggio? Scrivi un esempio in cui il testo cambia ma la categoria no.

### 12. Contratti

#### Esercizi

1. **`requires`.** **[Full]** Scrivi `radice(x::Number)::Float` con una precondizione `x >= 0` e
   provala con input validi e non validi.
2. **`ensures` e `result`.** **[Full]** Aggiungi a una funzione una postcondizione sul valore
   restituito usando `result`.
3. **Leggere la violazione.** **[Full]** Dopo una `requires` violata, stampa `e.kind`, `e.data.clause`
   e `e.data.fn`: che cosa ti dicono?
4. **L'ordine dei controlli.** Perché il tipo di ritorno viene controllato prima delle
   `ensures`? Scrivi una funzione in cui l'ordine si nota.
5. **Condizioni pure.** **[Full]** Metti un `println` dentro un contratto: che errore ottieni e
   perché?
6. **`requires` al top level.** Che cosa fa `requires c` fuori da una funzione? Usalo come
   asserzione in un piccolo programma.
7. **`ensures` fuori da una funzione.** Perché non ha senso? Che cosa manca?
8. **`safe_div`.** Riscrivi l'esempio del capitolo e prova `safe_div(6, 3)` e `safe_div(1, 0)`:
   il secondo interrompe il programma?
9. **Contratti che controllano, non provano.** Scrivi un contratto che passi per alcuni input e
   fallisca per altri: che cosa ti dice sulla differenza tra controllo e dimostrazione?
10. **Contratto o test?** Scrivi la stessa proprietà prima come test e poi come contratto: quando
    conviene l'uno e quando l'altro?

### 13. Budget

#### Esercizi

1. **Il budget scatta.** **[Full]** Avvolgi un `while true` in `with budget(steps = 10_000)` e
   verifica che il valore del blocco sia `Err(:budget)`.
2. **Che cos'è un passo?** Individua nel capitolo tre costrutti che consumano passi e spiega
   perché il budget misura lavoro e non tempo.
3. **Budget annidati.** **[Full]** Con un budget interno di 100 passi dentro uno esterno di 1000:
   quale dei due scatta per primo e che cosa produce il blocco interno?
4. **Riproducibilità.** Perché due esecuzioni con lo stesso budget danno gli stessi passi? Che
   problema risolverebbe (e quale no) un timeout sull'orologio?
5. **Ricorsione sinistra.** **[Full]** `f(n) = f(n + 1)` dentro un budget: quale errore invece di
   uno stack overflow? Verifica.
6. **`limit`, `depth`, `steps`.** **[Full]** Distingui le tre opzioni di `solve` con un esempio per
   ciascuna e indica quale delle tre produce un errore.
7. **Diagnosi.** **[Full]** Scrivi un programma che, ricevuto `Err(:budget)`, stampi una diagnosi
   invece di propagare il panico.
8. **Quanti passi?** Stima e poi verifica quanti passi consuma un ciclo che gira 10 volte dentro
   un budget: quale relazione osservi tra iterazioni e passi?
9. **Vuoto o esaurito?** **[Full]** Spiega la differenza tra una query che restituisce una lista
   vuota e una terminata da `Err(:budget)`: scrivi due query che mostrino entrambi i casi.
10. **Perché nel linguaggio.** Scrivi due righe sul perché il budget è parte del linguaggio e non
    dell'ambiente di esecuzione.

### 14. Tracce

#### Esercizi

1. **La prima traccia.** **[Full]** Avvolgi un piccolo `solve` in `with trace` e leggi la sequenza
   degli eventi prodotti.
2. **Le porte di Byrd.** Che cosa significano `:call`, `:redo`, `:exit`, `:fail`? Collega
   ciascuna a un momento preciso della ricerca.
3. **Contare i `:redo`.** **[Full]** Traccia un goal con due soluzioni e conta quanti `:redo`
   compaiono: a cosa corrispondono nel backtracking?
4. **Contare i fallimenti.** Riscrivi l'esempio del capitolo che conta i fallimenti di una ricerca
   e provalo su una knowledge base tua.
5. **Debug di un goal.** Un goal non trova risposte: come usi la traccia per capire dove la
   ricerca fallisce? Scrivi la sequenza che ti aspetti.
6. **Eventi come dati.** La traccia produce valori: scrivi un programma che filtri gli eventi per
   tipo e ne conti ciascuna categoria.
7. **Traccia o `println`?** Perché per un programma logico una traccia è meglio di `println`
   di debug? Rispondi con un esempio in cui l'ordine dei tentativi conta.
8. **Prevedere l'ordine.** Dato un goal con due soluzioni e una clausola che fallisce, scrivi a
   mano l'ordine atteso degli eventi e verifica con `with trace`.
9. **Profondità e traccia.** **[Full]** Aggiungi `depth` a una query tracciata: che cosa cambia
   negli eventi osservati?
10. **Trace e budget.** **[Full]** Unisci `trace` e `steps` in una query: come si riconosce
    nell'emissione degli eventi l'esaurimento del budget?

### 15. Effetti dichiarati

#### Esercizi

1. **Pura di default.** **[Full]** Scrivi una funzione che stampi senza dichiarare `!io`: quale
   errore ottieni e da chi viene segnalato?
2. **Dichiarare `!io`.** Aggiungi la dichiarazione alla funzione dell'esercizio 1 e verifica che
   ora funziona.
3. **`!state`.** **[Full]** Scrivi una funzione che aggiunga un fatto (`fact visto($x)`): quale
   effetto richiede e perché `fact` è un effetto mentre un assegnamento locale no?
4. **Chiamata indiretta.** Come nell'esempio `tranquilla` → `rumorosa`: chi riceve l'errore?
   Scrivi un caso con tre livelli di chiamata.
5. **`fn`, `caller`, `missing`.** **[Full]** Costruisci un `Err(:effect)` e ispeziona i tre campi
   di `data`: a che cosa serve ciascuno per correggere il codice?
6. **Al top level.** Perché al top level si può stampare senza dichiarazioni? Che cosa significa
   che il top level «permette tutti gli effetti»?
7. **Lambda ed effetti.** Da dove una lambda eredita gli effetti? Scrivi un esempio con una lambda
   creata dentro una funzione `!io`.
8. **Puro leggere, impuro scrivere.** Perché `solve` è puro mentre `fact` e `rule` eseguiti dentro
   una funzione no?
9. **Mutazione locale.** Perché `push!` e gli assegnamenti su variabili locali non sono effetti
   dichiarati? Dove passa il confine secondo la specifica?
10. **Progetta una firma.** Data una funzione che stampa una relazione e aggiunge un fatto alla
    knowledge base, scrivi la firma corretta e giustifica ogni effetto dichiarato.

### 16. Logica

#### Esercizi

1. **Fatti.** **[Full]** Dichiara i fatti `parent(:tom, :bob)`, `parent(:bob, :jim)` e altri due
   tuoi, e interroga la base con `solve parent(:tom, ?c)`.
2. **Regole.** **[Full]** Scrivi `rule ancestor(?a, ?d)` nelle due forme del capitolo e verifica
   che `ancestor(:tom, ?jim)` sia dimostrabile.
3. **`solve` è un valore.** **[Full]** Raccogli le soluzioni in una variabile, stampa `length(sols)`
   e leggi un legame con `sols[1].who`.
4. **Variabili anonime.** **[Full]** Usa `?_` in una query dove non ti interessa un legame e
   spiega perché ogni occorrenza è una variabile nuova.
5. **`is` valuta.** **[Full]** Perché in `path` il costo si calcola con `?c is ?c1 + ?c2` e non con
   `?c = ?c1 + ?c2`? Verifica su una knowledge base con costi.
6. **`app` in stile Prolog.** **[Full]** Riscrivi le regole di `app` e spiega perché
   `solve app(?a, ?b, [1, 2, 3])` ha quattro soluzioni.
7. **Occurs-check.** **[Full]** `solve ?x = f(?x)`: quante soluzioni? Perché l'unificazione si
   rifiuta?
8. **Predicato come funzione.** **[Full]** Usa `grandparent(:alice, :dave)` come condizione di un
   `if`: che valore produce?
9. **Negazione per fallimento.** **[Full]** Con `!parent(p, ?_)` seleziona le «foglie» di una
   knowledge base familiare, come nell'esempio.
10. **Le opzioni.** **[Full]** Costruisci una query con molte soluzioni e applica `limit`, `depth`
    e `steps` separatamente: che risultato ottieni in ciascun caso?

### 17. Codice come dato

#### Esercizi

1. **Quotare.** **[Full]** Scrivi `:(1 + 2)` e osserva il valore prodotto: è un calcolo o un
   albero?
2. **Unquote.** **[Full]** Inserisci con `$` un valore calcolato dentro una quote e verifica che
   venga valutato prima di entrare nell'albero.
3. **`eval`.** **[Full]** Valuta una struttura quotata con `eval` e confronta il risultato con
   quello della forma non quotata.
4. **Round-trip.** **[Full]** Con `parse` e `unparse` fai il round-trip di una piccola espressione:
   il testo cambia?
5. **Albero uniforme.** Perché `1`, `:x`, `[1, 2]` e `:(f(1))` sono tutti nodi `Node(head, args)`?
   Scrivi per ciascuno head e args.
6. **Codice che costruisce codice.** **[Full]** Scrivi una funzione che, dato un nome, produca la
   quote di una funzione che lo stampa.
7. **`gensym`.** **[Full]** A cosa serve generare nomi freschi? Scrivi un esempio in cui un nome
   fisso creerebbe un conflitto.
8. **Quotare un blocco.** **[Full]** Quota un `function … end` completo e riscrivilo in testo con
   `unparse`.
9. **Dati o codice?** Riconosci quali di questi sono valori e quali sono codice quotato: `1`,
   `:(1)`, `:(x)`, `:x`, `"x"`.
10. **`--tree`.** Usa `triad --tree FILE` su un programma piccolo e confronta l'S-expression con
    la struttura `Node` vista nel capitolo.

### 18. Macro

#### Esercizi

1. **`@misura`.** **[Full]** Scrivi la macro `@misura(label, espr)` che stampa etichetta e valore e
   restituisce il valore.
2. **Macro o funzione?** Perché una macro riceve **codice** e non valori? Scrivi un esempio in cui
   la differenza si vede (per esempio un costrutto che non deve essere valutato subito).
3. **`@due_volte`.** **[Full]** Scrivi una macro che esegua due volte la sua espressione e
   provala con una `println`.
4. **Unquote dei parametri.** Usa `$` per inserire ciascun parametro della macro nella quote:
   che cosa succede se lo dimentichi?
5. **Igiene.** **[Full]** Costruisci un esempio in cui una macro con un nome fisso «calpesta» una
   variabile del chiamante, poi correggila con `gensym`.
6. **Codice che genera codice.** **[Full]** Scrivi una macro che, dato un nome, definisca una
   funzione che lo restituisca.
7. **Macro pure.** Perché macro e contratti sono puri? Che cosa succede se una macro provasse a
   stampare durante l'espansione?
8. **Guardare l'espansione.** **[Full]** Osserva il codice prodotto da una macro (con `unparse` o
   `--tree`) e confrontalo con la tua aspettativa.
9. **Ordine di espansione.** Con due macro annidate, in quale ordine avviene l'espansione?
   Verifica con un esempio.
10. **Quando non serve.** Scrivi un caso in cui una funzione basta e una macro sarebbe solo
    complicazione, e spiega la scelta.

### 19. Builtin

#### Esercizi

1. **Core o Full?** Dividi la tabella dei builtin in due colonne: quali esistono anche in Core e
   quali no? Confronta con `SPEC-CORE §7`.
2. **Operatori come funzioni.** **[Full]** Perché `reduce(+, xs)` funziona? Che cosa implica per
   la possibilità di aggiungere metodi a `+`?
3. **`map` scritto a mano.** Implementa `mappa(f, xs)` in Core (cap. 22.1) e confronta il
   risultato con `map` **[Full]**.
4. **`reduce` scritto a mano.** Implementa la riduzione con un ciclo e usala per somma e
   prodotto.
5. **La famiglia `first last rest`.** **[Full]** Usali su una lista; poi riscrivi `first` e `rest`
   con l'indicizzazione e `length`.
6. **`div` e `mod`.** **[Full]** Confronta `div(7, 2)`, `mod(7, 2)`, `7 / 2` e `7 % 2`: quali
   differenze di tipo e di risultato?
7. **Produrre e gestire errori.** **[Full]** Con `err`, `iserr`, `throw` e `error` scrivi un
   esempio per ciascun ruolo e spiega quando usare l'uno o l'altro.
8. **Il gruppo «codice».** **[Full]** Fai un esempio per ciascuno: `eval`, `parse`, `unparse`,
   `sexpr`, `gensym`.
9. **`typeof` e `isa`.** Scrivi un esempio in cui danno informazioni diverse e spiega la
   differenza.
10. **Estendere un builtin.** **[Full]** Aggiungi un metodo `*` per una struct `Stringa`... meglio:
    aggiungi un metodo `+` a una struct e verifica che `+` continui a funzionare per gli `Int`.

### 20. Riga di comando e REPL

#### Esercizi

1. **Quale opzione?** Indica l'opzione giusta per: eseguire un frammento, eseguirlo e stampare il
   valore, caricare un file nel REPL, eseguire un file e poi aprire il REPL, vedere l'albero.
2. **`ARGS`.** Scrivi un programma che stampi i suoi argomenti e provalo con
   `triad programma.triad a b c`.
3. **Codici di uscita.** Quali codici restituiscono: un programma riuscito, un errore non
   gestito, un uso non valido del comando? Verifica con `$?`/`%ERRORLEVEL%`.
4. **REPL stile Prolog.** Che cosa fanno `;`, `a`, `.` e `false.` durante una query al REPL?
5. **I comandi del REPL.** Carica un file con `:load`, ricaricalo con `:reload` e ispeziona una
   definizione con `:listing`.
6. **Query interattive.** Esegui `?- ancestor(:tom, ?d)` con `limit` e poi con `trace`: che cosa
   cambia nella risposta?
7. **Dalla pipeline.** Usa `triad -` per leggere uno script da stdin e componilo con altri
   comandi del terminale.
8. **Estensione omessa.** `triad programma` senza `.triad`: funziona? E con uno shebang `#!` in
   testa al file?
9. **`-e` contro `-E`.** Scrivi un frammento il cui valore non sia `nothing` e confronta le due
   forme.
10. **Oggi, in pratica.** Perché il seed Windows non supporta queste opzioni? Con quale comando
    esegui oggi gli esempi di questo capitolo?

### 21. Primitivi di bootstrap

#### Esercizi

1. **Una per ciascuna.** Scrivi un programma minimo per ogni primitiva: `readfile`, `strlen`,
   `strbyte`, `strsub`, `exit`.
2. **Byte, non caratteri.** Verifica `strlen("è") == 2`: perché una stringa è una sequenza di
   byte? Che conseguenza ha per gli analizzatori di testo?
3. **Contare le cifre.** Riscrivi l'esempio del capitolo e provalo su tre stringhe diverse.
4. **La prima parola.** Estrai la prima parola di una stringa con `strsub`, come nell'esempio, e
   generalizzala in una funzione.
5. **Codici ASCII.** Conta le maiuscole di una stringa (byte da 65 a 90) senza funzioni sui
   caratteri.
6. **`exit(n)`.** Termina un programma con codice di uscita 3 e verificalo dal terminale.
7. **Leggere sé stessi.** Con `readfile(ARGS[1])` fai stampare a un programma il proprio
   sorgente: quale riga del capitolo rende possibile questo?
8. **Solo cifre.** Scrivi un programma che dica se una stringa rappresenta un intero (tutti byte
   cifra, con gestione del segno).
9. **Perché non fanno parte di Full.** Scrivi due righe sul perché queste primitive vanno usate
   solo nel codice di bootstrap.
10. **Sottostringhe.** Con `strsub(s, a, b)` scrivi una funzione che stampi i primi `n` byte di
    una stringa e gestisca il caso `n > strlen(s)`.

### 22. Stile e pattern idiomatici

#### Esercizi

1. **HOF in Core.** Scrivi `mappa(f, xs)` e `filtra(f, xs)` con un ciclo, senza builtin di ordine
   superiore.
2. **Record come liste taggate.** Costruisci un record `[:Persona, "Ada", 36]` e scrivi le
   funzioni di accesso ai campi per posizione.
3. **Ambiente come associazioni.** Riscrivi `env_get`, `env_set` e `env_rimuovi` e provali con
   tre coppie.
4. **Stato condiviso.** Scrivi un contatore basato su una lista mutabile condivisa e spiega perché
   funziona anche senza assegnamenti condivisi.
5. **Costruire stringhe.** Riscrivi l'esempio che costruisce una riga con uno spazio fra i valori
   e usalo per stampare una lista di interi.
6. **Le regole di stile.** Prendi un tuo programma e riscrivilo applicando tutte le regole del
   capitolo 22.6: cosa è cambiato nella leggibilità?
7. **`get` non è standard.** Perché `get(xs, i)` non si usa nei programmi portabili? Riscrivi un
   programma che lo usi con l'indicizzazione standard.
8. **Una funzione, un compito.** Dividi una funzione lunga in tre funzioni piccole collegate e
   verifica che il programma resti corretto.
9. **Nomi che aiutano.** Rinomina i nomi di un programma (`x`, `y`, `tmp`) secondo le convenzioni
   del capitolo e commenta le scelte.
10. **Sottoinsieme comune.** Riscrivi un programma perché giri sia sull'interprete JS sia sul
    seed, usando solo le funzionalità comuni elencate nel capitolo 27.

---

Ogni esercizio ha una soluzione verificata. Prova prima, poi apri il riquadro «Soluzione».

Gli esercizi della prima serie sono programmi Triad-Core e si eseguono con l'interprete di
riferimento; quelli della seconda usano costrutti Full, quindi hanno risultati attesi ma non sono
eseguibili oggi. In entrambi i casi la soluzione non è l'unico programma giusto: è un programma che
funziona, ed è utile confrontarla con la tua per capire quale delle due è più chiara.

## Esercizi guidati (Triad-Core)

### Esercizio 1 — Potenza e somme

Senza usare `^`, scrivi `potenza(b, e)` ricorsiva e `somma_fino(n)` (somma `1 + … + n`) con `while`.
Stampa `potenza(3, 13)`, `potenza(2, 10)` e `somma_fino(100)`.

<details>
<summary>Soluzione</summary>

```triad
potenza(b, e) = e == 0 ? 1 : b * potenza(b, e - 1)

function somma_fino(n)
    s = 0
    i = 1
    while i <= n
        s += i
        i += 1
    end
    s
end

println(potenza(3, 13), " ", potenza(2, 10), " ", somma_fino(100))
```

**Output:**

```text
1594323 1024 5050
```

</details>

### Esercizio 2 — Numeri primi

Stampa la lista dei numeri primi minori di 30.

<details>
<summary>Soluzione</summary>

```triad
function primo(n)
    if n < 2
        return false
    end
    d = 2
    while d * d <= n
        if n % d == 0
            return false
        end
        d += 1
    end
    true
end

primi = []
n = 2
while n < 30
    if primo(n)
        push!(primi, n)
    end
    n += 1
end
println(primi)
```

**Output:**

```text
[2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
```

</details>

### Esercizio 3 — Inverti una lista

Scrivi `inverti(xs)` che restituisca una nuova lista con gli elementi in ordine inverso.

<details>
<summary>Soluzione</summary>

```triad
function inverti(xs)
    out = []
    i = length(xs)
    while i >= 1
        push!(out, xs[i])
        i -= 1
    end
    out
end

println(inverti([1, :due, "tre"]))
```

**Output:**

```text
[tre, :due, 1]
```

</details>

### Esercizio 4 — Ordinamento per inserzione

Ordina in loco `[5, 2, 9, 1, 7]`.

<details>
<summary>Soluzione</summary>

```triad
function ordina!(xs)
    i = 2
    while i <= length(xs)
        k = xs[i]
        j = i - 1
        while j >= 1 && xs[j] > k
            xs[j + 1] = xs[j]
            j -= 1
        end
        xs[j + 1] = k
        i += 1
    end
    xs
end

println(ordina!([5, 2, 9, 1, 7]))
```

**Output:**

```text
[1, 2, 5, 7, 9]
```

Il `!` finale nel nome segnala, per convenzione, una funzione che muta il suo argomento.

</details>

### Esercizio 5 — Contatore di parole

Conta le parole (separate da spazi) di `"il  linguaggio Triad "` usando `strbyte`.

<details>
<summary>Soluzione</summary>

```triad
function conta_parole(s)
    n = 0
    dentro = false
    i = 1
    while i <= strlen(s)
        spazio = strbyte(s, i) == 32
        if !spazio && !dentro
            n += 1
        end
        dentro = !spazio
        i += 1
    end
    n
end

println(conta_parole("il  linguaggio Triad "))
```

**Output:**

```text
3
```

</details>

### Esercizio 6 — Un mini-analizzatore lessicale

Trasforma `"12+x*3"` in una lista di token `[tipo, testo]`, con tipi `:num`, `:id`, `:op`. È il primo
passo di un interprete.

<details>
<summary>Soluzione</summary>

```triad
cifra(b) = b >= 48 && b <= 57
lettera(b) = (b >= 97 && b <= 122) || (b >= 65 && b <= 90) || b == 95

function tokenizza(s)
    toks = []
    i = 1
    while i <= strlen(s)
        b = strbyte(s, i)
        if cifra(b)
            j = i
            while j <= strlen(s) && cifra(strbyte(s, j))
                j += 1
            end
            push!(toks, [:num, strsub(s, i, j - 1)])
            i = j
        elseif lettera(b)
            j = i
            while j <= strlen(s) && (lettera(strbyte(s, j)) || cifra(strbyte(s, j)))
                j += 1
            end
            push!(toks, [:id, strsub(s, i, j - 1)])
            i = j
        else
            push!(toks, [:op, strsub(s, i, i)])
            i += 1
        end
    end
    toks
end

println(tokenizza("12+x*3"))
```

**Output:**

```text
[[:num, 12], [:op, +], [:id, x], [:op, *], [:num, 3]]
```

</details>

### Esercizio 7 — Valutare un'espressione

Usando i token dell'esercizio 6, scrivi un valutatore a discesa ricorsiva per `+` e `*` con
precedenza, dove le variabili vengono da una lista di associazioni. Suggerimento: tieni la posizione
corrente in una lista `pos = [1]`, così le funzioni possono aggiornarla.

<details>
<summary>Soluzione</summary>

```triad
cifra(b) = b >= 48 && b <= 57
lettera(b) = (b >= 97 && b <= 122) || b == 95

function tokenizza(s)
    toks = []
    i = 1
    while i <= strlen(s)
        b = strbyte(s, i)
        if cifra(b)
            j = i
            while j <= strlen(s) && cifra(strbyte(s, j))
                j += 1
            end
            push!(toks, [:num, strsub(s, i, j - 1)])
            i = j
        elseif lettera(b)
            j = i
            while j <= strlen(s) && lettera(strbyte(s, j))
                j += 1
            end
            push!(toks, [:id, strsub(s, i, j - 1)])
            i = j
        else
            push!(toks, [:op, strsub(s, i, i)])
            i += 1
        end
    end
    toks
end

function cerca(env, nome)
    i = 1
    while i < length(env)
        if env[i] == nome
            return env[i + 1]
        end
        i += 2
    end
    0
end

function primario(toks, pos, env)
    t = toks[pos[1]]
    pos[1] += 1
    if t[1] == :num
        Int(t[2])
    else
        cerca(env, t[2])
    end
end

function prodotto(toks, pos, env)
    v = primario(toks, pos, env)
    while pos[1] <= length(toks) && toks[pos[1]][2] == "*"
        pos[1] += 1
        v = v * primario(toks, pos, env)
    end
    v
end

function somma(toks, pos, env)
    v = prodotto(toks, pos, env)
    while pos[1] <= length(toks) && toks[pos[1]][2] == "+"
        pos[1] += 1
        v = v + prodotto(toks, pos, env)
    end
    v
end

valuta(s, env) = somma(tokenizza(s), [1], env)
println(valuta("12+x*3", ["x", 10]))
println(valuta("2*3+4*5", []))
```

**Output:**

```text
42
26
```

</details>

### Esercizio 8 — Un ambiente a dizionario

Estendi l'esercizio 7 (il valutatore con ambiente) con la rimozione di un nome, e scrivi
`ambiente_da_elenco` che costruisce un ambiente da coppie `[nome, valore]`. Verifica con `env_get` ed
`env_set` del capitolo 22.3.

<details>
<summary>Soluzione</summary>

```triad
function env_get(env, nome)
    i = 1
    while i < length(env)
        if env[i] == nome
            return env[i + 1]
        end
        i += 2
    end
    nothing
end

function env_set(env, nome, valore)
    i = 1
    while i < length(env)
        if env[i] == nome
            env[i + 1] = valore
            return env
        end
        i += 2
    end
    push!(env, nome)
    push!(env, valore)
end

function env_rimuovi(env, nome)
    out = []
    i = 1
    while i < length(env)
        if env[i] == nome
            i += 2
        else
            push!(out, env[i])
            push!(out, env[i + 1])
            i += 2
        end
    end
    out
end

function ambiente_da_elenco(coppie)
    env = []
    i = 1
    while i < length(coppie)
        env_set(env, coppie[i], coppie[i + 1])
        i += 2
    end
    env
end

env = ambiente_da_elenco([:x, 10, :y, 20])
println(env, " ", env_get(env, :x))
env = env_rimuovi(env, :x)
println(env, " ", env_get(env, :x))
```

**Output:**

```text
[:x, 10, :y, 20] 10
[:y, 20] nothing
```
</details>

### Esercizi supplementari

1. **Somma dei quadrati.** Calcola `1² + 2² + … + n²` per `n = 10` con un ciclo.
2. **Prodotti pari.** Calcola il prodotto di tutti i numeri pari da 2 a 12.
3. **Ricerca lineare.** Dati una lista e un valore `v`, restituisci la posizione del primo
   elemento uguale a `v` (0 se non c'è), con un ciclo.
4. **Rotazione.** Sposta il primo elemento di una lista in fondo e stampa il risultato.
5. **Diagonale.** Data una lista di liste 3×3, stampa gli elementi della diagonale principale.
6. **Palindromo.** Verifica se una lista di interi è uguale alla sua inversione (senza `reverse`).
7. **Ordinamento per selezione.** Ordina una lista di cinque interi con l'algoritmo di selezione,
   una coppia alla volta.
8. **Intersezione.** Costruisci la lista degli elementi comuni a due liste, senza duplicati.

## Esercizi su Triad-Full

Questi esercizi usano i costrutti dello standard completo. Sono definiti dalla specifica e hanno
risultati attesi in `conformance/cases/`, ma **non sono ancora eseguibili** dal runtime corrente.

Studiarli serve comunque: le soluzioni sono codice normativo, e vederle accanto agli esercizi Core
mostra che i costrutti Full si innestano nella stessa sintassi, non in un linguaggio separato.
L'output riportato è un valore atteso conservato dalla suite, non una verifica eseguita oggi.

### Esercizio 9 — Dispatch su struct

Definisci `struct Vec2` con due campi `Float` e tre metodi di `area`: uno per `Vec2`, uno per `Number`
e uno per `Any`. Verifica che il metodo più specifico vinca.

<details>
<summary>Soluzione</summary>

```triad-full
struct Vec2
    x::Float
    y::Float
end

area(v::Vec2) = v.x * v.y
area(n::Number) = n * n
area(x::Any) = 0

println(area(Vec2(3, 4)))
println(area(5))
println(area("ciao"))
```

**Output (golden Full):**

```text
12.0
25
0
```

</details>

### Esercizio 10 — Una base di conoscenza

Scrivi fatti e regole per `parent` e `sorella`, e usa `solve` per trovare le sorelle di `:bob` e
i nipoti di `:alice`.

<details>
<summary>Soluzione</summary>

```triad-full
fact parent(:alice, :bob)
fact parent(:alice, :carol)
fact parent(:bob, :dave)
fact parent(:carol, :erin)

rule grandparent(?x, ?z) :- parent(?x, ?y), parent(?y, ?z)

rule sorella(?a, ?b) :- parent(?p, ?a), parent(?p, ?b), ?a != ?b

println([s.b for s in solve sorella(:bob, ?b)])
println([s.z for s in solve grandparent(:alice, ?z)])
```

**Output (golden Full):**

```text
[:carol]
[:dave, :erin]
```

</details>

### Esercizio 11 — Contratti in pratica

Scrivi `dividi(a, b)` con `requires b != 0` e `ensures abs(result * b - a) < 1e-9`, e usa `try` per
distinguere il caso di contratto violata dal caso di successo.

<details>
<summary>Soluzione</summary>

```triad-full
function dividi(a::Number, b::Number)::Float
    requires b != 0
    ensures abs(result * b - a) < 1e-9
    a / b
end

r = try dividi(1, 0) end
if iserr(r)
    println("contratto: ", r.data.clause)
else
    println("valore: ", r)
end
```

**Output (golden Full):**

```text
contratto: requires
```

</details>

### Esercizio 12 — Una macro che misura

Scrivi la macro `@misura(label, espr)` che valuta l'espressione e stampa etichetta e valore,
restituendo il valore.

<details>
<summary>Soluzione</summary>

```triad-full
macro misura(label, e)
    :(begin
        r = $e
        println($label, " -> ", r)
        r
    end)
end

totale = @misura("somma", 1 + 2 + 3)
println(totale)
```

**Output (golden Full):**

```text
somma -> 6
6
```
</details>

### Esercizi supplementari

1. **Struct e dispatch.** **[Full]** Definisci `Quadrato` e `Cerchio` con un metodo `area` per
   ciascuno e chiama `area` su entrambi.
2. **`for` e comprehension.** **[Full]** Con una comprehension costruisci la lista delle coppie
   `(i, j)` con `i` da 1 a 3 e `j` da 1 a 3.
3. **`try`/`catch`.** **[Full]** Cattura un `Err(:type)` e rilancialo o trasformalo in un messaggio
   personalizzato.
4. **Contratto.** **[Full]** Aggiungi `requires` e `ensures` a una funzione che calcoli la media
   di una lista (con `/` **[Full]**) e prova una violazione.
5. **Budget.** **[Full]** Limita con `with budget` una ricerca ricorsiva e gestisci `Err(:budget)`.
6. **Knowledge base.** **[Full]** Con `fact`, `rule` e `solve` descrivi un piccolo albero
   genealogico e trova tutti i nonni.
7. **Macro.** **[Full]** Scrivi `@due_volte(e)` che esegua due volte la sua espressione.
8. **Destrutturazione.** **[Full]** Con `[a, b] = [1, 2]` e un match su una lista `[h | t]`
   riscrivi `app` senza usare `length`.

---

---

## Esercizi di riferimento

### 23. Grammatica

#### Esercizi

1. **Si legge o no?** Usando la grammatica, decidi quali di queste righe sono programmi validi:
   `x = 1`, `x =`, `x 1 =`, `x = 1 2`.
2. **Dove sta la precedenza.** Nelle regole EBNF individua dove compaiono il ternario, `->` e
   `^`: come si collegano ai livelli del capitolo 4?
3. **Separatori.** Perché newline e `;` sono separatori e non terminatori? Scrivi un esempio in
   cui un a capo in più cambia il programma.
4. **Commenti.** Dove ammette la grammatica i commenti `#` e `#= =#`? Prova a metterli in tre
   posizioni insolite (dentro una chiamata, tra un `if` e la sua condizione...).
5. **Le stringhe.** Scrivi la regola degli escape con un esempio per ciascun escape ammesso e un
   esempio di escape rifiutato.
6. **Chi richiede `end`?** Elenca dalla grammatica tutti i costrutti che aprono un blocco chiuso
   da `end`.
7. **Regole ricorsive.** Scegli una regola ricorsiva della grammatica e spiega perché lo è, con
   un esempio di albero di derivazione.
8. **Grammatica e parser.** Come si collegano le regole della grammatica ai dodici livelli del
   parser Pratt del capitolo 4?
9. **Range e due punti.** Perché `1:5` è un range e `1 : 5` no? Quale regola della grammatica lo
   dice?
10. **Token.** Scrivi la sequenza dei token di un programma piccolo e confrontala con ciò che
    `triad --tree` mostra dell'albero.

### 24. Schede rapide

#### Esercizi

1. **Valori.** Con la sola scheda 26.1, scrivi un programma che usi tutti i tipi di base.
2. **Controllo di flusso.** Con la scheda 26.2 scrivi un `while` con `break` e un `if`/`elseif`.
3. **Funzioni.** Con la scheda 26.3 scrivi una funzione blocco con `return` e una breve.
4. **Senza guardare.** Scrivi in due minuti un programma con ternario, `+=` e un confronto:
   controlla con la scheda solo alla fine.
5. **Lambda.** Dalla scheda, scrivi una lambda, assegnala e chiamala.
6. **Liste.** Costruisci una lista, accedi al primo e ultimo elemento, aggiungi con `push!`.
7. **Stringhe.** Costruisci una frase con `*`, `string()` e `Int()`.
8. **Errori attesi.** Usando la scheda e la tabella del capitolo 25, scrivi tre programmi che
   producano tre errori diversi annunciati.
9. **Core o Full?** Con le schede decidi per ciascuno se è eseguibile oggi: `for`, `map`, `/`,
   `solve`, `lambda`, `try`.
10. **Sfida a tempo.** In cinque minuti scrivi un programma che usi almeno cinque voci diverse
    delle schede rapide, senza consultare i capitoli.

### 25. Tabella degli errori

#### Esercizi

1. **Quattro errori Core.** Scrivi un programma minimo per ciascuno: `:syntax`, `:undef`,
   `:type`, `:bounds`.
2. **Cinque errori Full.** **[Full]** Un esempio per ciascuno: `:method`, `:ambiguous`,
   `:contract`, `:budget`, `:effect`.
3. **Dal messaggio alla categoria.** Dato il messaggio `error: index out of range` (Core) e
   `Err(:bounds)` (Full), spiega la relazione fra i due.
4. **Core o Full?** Quali categorie di errore si possono incontrare in un programma Core puro?
   Giustifica la risposta.
5. **`:host`.** Che cosa significa la categoria `:host`? Scrivi un caso in cui potrebbe comparire.
6. **Due modi di fallire.** Confronta il comportamento di un errore in Core (exit code 1) e in
   Full (`Err` come valore) con due programmi paralleli.
7. **Catturare.** **[Full]** Scrivi un programma che catturi due categorie diverse e reagisca in
   modo diverso a ciascuna.
8. **Diagnosi da riga.** Un programma con un errore segnala la riga: scrivi un programma con tre
   errori potenziali e determina quale viene segnalato per primo.
9. **Ordine di scoperta.** In un programma con un errore di sintassi e uno di esecuzione, quale
   viene scoperto per primo? Perché?
10. **La tua tabella.** Aggiungi alla tabella un esempio personale per due categorie e verificalo
    eseguendolo.

### 26. Glossario

#### Esercizi

1. **Definizioni tue.** Definisci con le tue parole: *unificazione*, *backtracking*,
   *occurs-check*, *dispatch*, *chiusura*.
2. **Tre lingue, idee proprie.** Collega ciascuna influenza (Julia, Prolog, Lisp) a due idee che
   Triad ha ripreso e a una che non ha ripreso.
3. **Parlare di `solve`.** Quali termini del glossario servono per descrivere `solve` e la sua
   ricerca? Scrivi una frase che li usi tutti.
4. **Vero o falso.** Valuta: «il budget misura il tempo», «`ensures` è una precondizione»,
   «le macro ricevono valori», «una soluzione logica è una lista di legami», «`Err` è un tipo».
5. **Coppie che confondono.** Distingui con un esempio: *effetto* e *contratto*; *budget* e
   *limit*; *parametro* e *argomento*; *simbolo* e *variabile logica*.
6. **Albero uniforme.** Scrivi la tua definizione di «albero uniforme» e falla vedere su un
   esempio `:(f(1))`.
7. **Termini in inglese.** Quali termini tecnici restano in inglese nel libro e perché? Scrivi la
   traduzione che useresti per tre di essi.
8. **Il glossario di un programma.** Prendi un programma Full del capitolo 16 e annota almeno
   sei termini del glossario che servono per descriverlo.
9. **Cinque domande.** Scrivi cinque domande di ripasso sul glossario e rispondi senza guardare.
10. **Aggiungi una voce.** Scegli un concetto del libro non presente nel glossario e scrivi la voce
    che aggiungeresti, nello stesso stile.

### 27. Cosa gira oggi

#### Esercizi

1. **Sottoinsieme comune.** Scrivi un programma che gira su entrambi i runtime Core usando solo
   le funzionalità della colonna destra della tabella delle differenze.
2. **`get` non è portabile.** Perché `get(xs, i)` non si può usare in codice portabile? Riscrivi
   un programma che lo usi con `xs[i]`.
3. **Lambda a due parametri.** Scrivi una lambda con due parametri e spiega su quale runtime non
   girerebbe.
4. **Chiusure diverse.** Costruisci un esempio in cui la cattura per valore del seed e quella
   condivisa dell'interprete JS danno risultati diversi.
5. **`string(x)` limitato.** Perché `string(true)` non gira sul seed? Che cosa succede invece
   sull'interprete JS?
6. **Due runtime, un test.** Esegui lo stesso caso di conformance con l'interprete JS e con il
   seed Windows e confronta gli output.
7. **Limiti del seed.** Elenca cinque limiti del seed Windows e per ciascuno scrivi la variante
   di programma che funziona ugualmente.
8. **Limiti noti.** Spiega i due limiti noti del capitolo (ogni a capo chiude l'istruzione;
   `xs[i]` non implementato) con un programma che li incontri.
9. **Golden, non verificati.** Perché gli esempi Full hanno «Output (golden Full)»? Che cosa puoi
   e non puoi dedurne?
10. **La tua regola.** Scrivi la checklist personale che userai prima di pubblicare un programma
    Core destinato a girare su entrambi i runtime.
