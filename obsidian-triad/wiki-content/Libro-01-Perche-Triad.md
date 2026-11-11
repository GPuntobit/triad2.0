# Capitolo 1 — Perché Triad

Ogni linguaggio nasce da un'insoddisfazione. Quella da cui nasce Triad è duplice. Da una parte,
le idee migliori della programmazione sono sparse in linguaggi che raramente si parlano: la
chiarezza delle funzioni tipate e del multiple dispatch di Julia, la potenza dichiarativa
dell'unificazione e del backtracking di Prolog, l'eleganza del "codice come dato" di Lisp.
Dall'altra, quasi ogni linguaggio nuovo finisce per dipendere da un linguaggio più vecchio che
lo ospita: è scritto in C, gira dentro una macchina virtuale altrui, si costruisce con un
compilatore che non controlla. Triad prova a rispondere a entrambe le insoddisfazioni.

## 1.1 Tre paradigmi in un'unica sintassi

Il nome stesso dichiara l'intenzione: tre tradizioni, un solo linguaggio. Non si tratta di
incollare tre linguaggi uno accanto all'altro, ma di scegliere da ciascuno l'idea essenziale e
darle una forma coerente con le altre.

Da **Julia** Triad prende la forma del codice: blocchi `function … end`, `if … end`,
`while … end`, annotazioni di tipo con `::`, e soprattutto il **multiple dispatch**, l'idea che
una funzione sia un insieme di metodi e che il metodo da eseguire si scelga guardando i tipi di
*tutti* gli argomenti, non solo del primo. Ne deriva anche un dettaglio che si ritrova ovunque:
gli operatori sono funzioni. `a + b` è una chiamata alla funzione `+`, e chi definisce un nuovo
tipo può insegnare a `+` come sommarlo.

Da **Prolog** Triad prende la programmazione logica: `fact` dichiara un fatto, `rule` una regola,
`solve` cerca le soluzioni di una domanda. Le variabili logiche si scrivono `?x` e vengono legate
dall'unificazione; quando una strada fallisce, il motore torna indietro e ne prova un'altra
(backtracking). La differenza con Prolog è che in Triad la logica non è un mondo a parte: il
risultato di `solve` è un valore normale, una lista, che si può filtrare, contare e passare a
una funzione.

Da **Lisp** Triad prende l'idea che il programma sia esso stesso un dato. Il parser produce un
albero uniforme, fatto di un solo tipo di nodo; quell'albero si può ottenere scrivendo
`:( espressione )`, ispezionare, modificare e rieseguire con `eval`. Su questa base si
costruiscono le macro: funzioni che ricevono codice e restituiscono codice.

## 1.2 Garanzie che fanno parte del linguaggio

C'è una quarta componente, meno appariscente ma forse più caratteristica: Triad tratta come
parte del linguaggio alcune garanzie che altrove sono affidate a librerie o a convenzioni.

- **Errori come dati.** Un errore è un valore di tipo `Err`, con un genere (`kind`), un
  messaggio e dei dati. Si può restituire, confrontare, passare a una funzione che lo descriva.
- **Contratti.** `requires` e `ensures` esprimono precondizioni e postcondizioni di una funzione;
  una violazione produce un `Err(:contract)` con tutti i dettagli.
- **Budget.** `with budget(steps = N) … end` limita il numero di passi di calcolo: un ciclo
  infinito non blocca il programma, diventa un `Err(:budget)`.
- **Tracce.** `with trace … end` restituisce, insieme al risultato, l'elenco degli eventi di
  chiamata e uscita delle funzioni: il debug diventa un dato da analizzare.
- **Effetti dichiarati.** Una funzione che stampa deve dirlo (`!io`); una che modifica la base
  di conoscenza logica deve dirlo (`!state`). Le funzioni sono pure finché non dichiarano
  il contrario.

> **Perché.** Tutte queste garanzie hanno una cosa in comune: trasformano in *valori* fenomeni
> che di solito sono *eventi* (un'eccezione, un blocco, una stampa di debug). Un valore si può
> ispezionare, testare, confrontare con un valore atteso. È la stessa filosofia che rende
> possibile la suite di conformità: ciò che si può esprimere come dato si può verificare.

## 1.3 Un linguaggio definito da uno standard

Molti linguaggi sono definiti, di fatto, dalla loro implementazione principale: "il linguaggio è
quello che fa il compilatore". Triad sceglie la strada opposta. Il linguaggio è definito da un
documento normativo, [`SPEC.md`](https://github.com/GPuntobit/triad2.0/blob/main/SPEC.md), con un
numero di versione (oggi `0.2.0`, nel file `VERSION`) e una storia delle modifiche
(`CHANGELOG.md`). Le implementazioni vengono dopo, e devono adeguarsi allo standard.

Ma un documento, da solo, si presta a interpretazioni. Per questo lo standard comprende anche un
**contratto eseguibile**: la cartella `conformance/`, dove ogni caso è un programma con l'output
che deve produrre, byte per byte, e il codice di uscita atteso. Un'implementazione è conforme se
li passa tutti. Non conta chi l'ha scritta né in quale linguaggio: conta che stampi le stesse
righe.

## 1.4 Nessun linguaggio ospite

L'altra metà dell'ambizione è più radicale. Triad vuole poter essere costruito **senza
dipendere da nessun altro linguaggio di programmazione**: niente C, niente Rust, niente Julia,
nessun binario precompilato ereditato da qualcun altro.

Il ragionamento, sviluppato in `BOOTSTRAP.md`, è stringente. Un linguaggio non può compilarsi
dal nulla: qualcosa deve eseguire il primo programma. Se quel qualcosa è scritto in C, Triad
dipende dal C. L'unica via d'uscita è che il primo eseguibile sia scritto direttamente in codice
macchina, a mano, e che sia abbastanza piccolo da poterlo fare. Quel primo eseguibile si chiama
**seed** (seme) ed è il protagonista del capitolo 20. Il seed sa eseguire solo un sottoinsieme
del linguaggio, Triad-Core; su di esso si costruisce, in Triad-Core, l'interprete di tutto Triad;
da lì un compilatore scritto in Triad, che alla fine compila se stesso. A quel punto il seed può
andare in pensione.

> **Nota storica.** Il progetto ha avuto per un periodo un'implementazione di riferimento
> scritta in Julia. È servita per fissare il comportamento atteso e generare i primi golden della
> conformità, poi è stata rimossa: oggi nessuna parte di Triad richiede Julia. Le influenze di
> Julia restano nella sintassi, non nelle dipendenze.

## 1.5 Un primo sguardo

Ecco un piccolo programma che già oggi gira, scritto nel sottoinsieme Triad-Core. Non serve
capirlo tutto: è un assaggio di come si presenta il codice.

```julia
# il massimo comun divisore, alla maniera di Euclide
mcd(a, b) = b == 0 ? a : mcd(b, a % b)

function descrivi(a, b)
    "mcd(" * string(a) * ", " * string(b) * ") = " * string(mcd(a, b))
end

println(descrivi(48, 18))
println(descrivi(100, 25))
```

Output:

```text
mcd(48, 18) = 6
mcd(100, 25) = 25
```

Si riconoscono una funzione in forma breve (`mcd(a, b) = …`), una in forma a blocco
(`function … end`), l'operatore ternario `? :`, il resto intero `%`, la concatenazione di
stringhe con `*` e la conversione `string(…)`. Nei prossimi capitoli ognuno di questi elementi
avrà la sua spiegazione.

E questo è come si presenta lo stesso spirito nel linguaggio completo, che **non gira ancora**
ma che lo standard definisce in ogni dettaglio:

```julia
fact parent(:alice, :bob)
fact parent(:bob, :dave)
rule grandparent(?x, ?z) :- parent(?x, ?y), parent(?y, ?z)

nipoti = solve grandparent(:alice, ?chi)
println(nipoti[1].chi)        # :dave
```

## Riepilogo

- Triad unisce le idee centrali di Julia (forma del codice, tipi, multiple dispatch), Prolog
  (fatti, regole, unificazione) e Lisp (codice come dato, macro).
- Errori, contratti, budget, tracce ed effetti sono parte del linguaggio e diventano valori.
- Il linguaggio è definito da uno standard scritto e da una suite di conformità eseguibile.
- Il progetto vuole fare a meno di qualunque linguaggio ospite, partendo da un seed in codice
  macchina.
<!-- nav -->

---

← [Prefazione](Libro-00-Prefazione) · [Sommario](Home) · [Capitolo 2 — Due profili e una catena](Libro-02-Profili-e-bootstrap) →
