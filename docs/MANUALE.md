# Manuale di Triad 2.0

> Il manuale completo del linguaggio: lessico, valori, controllo di flusso, funzioni, dispatch,
> logica, codice come dato, errori, contratti, budget, tracce, effetti, esercizi e riferimento.

Triad è un linguaggio di programmazione autonomo: sintassi a blocchi e tipi dichiarati, multiple
dispatch, programmazione logica integrata e codice come dato, in una sola sintassi. La sua
definizione è una specifica normativa indipendente da qualsiasi implementazione
([`SPEC.md`](SPEC.md), standard `0.2.0`), accompagnata da una specifica eseguibile
([`SPEC-CORE.md`](SPEC-CORE.md)) e da una suite di conformità con golden verificabili
([`conformance/`](conformance/README.md)).

Questo manuale insegna il linguaggio per come è definito dallo standard. Non è un riassunto della
specifica: è un percorso di studio, con spiegazioni, esempi ed esercizi. Puoi leggerlo dall'inizio
alla fine senza altro materiale: ogni concetto che serve per capire un capitolo è spiegato prima o
in quel capitolo, e i rimandi esterni sono approfondimenti facoltativi. Non è una raccolta di pagine
da consultare a caso: è un libro, e l'ordine dei capitoli costruisce il modello mentale del
linguaggio un pezzo alla volta.

---

## Come leggere questo manuale

### A chi è indirizzato

Sai programmare, in qualunque linguaggio: sai cosa sono una variabile, una funzione, un ciclo, una
ricorsione. Questo manuale non spiega la programmazione in generale, spiega **Triad**.

Il manuale non presume che tu abbia letto nient'altro: ogni concetto è spiegato dove serve. I
documenti normativi del progetto — `SPEC.md`, `SPEC-CORE.md` — e la suite di conformità in
`conformance/` sono i testi e le prove a cui puoi risalire per approfondire o per controllare un
caso limite, ma non sono prerequisiti: sono il riferimento di chi vuole verificare, non il manuale
di chi vuole imparare. Per questo il testo distingue sempre ciò che è regola del linguaggio da ciò
che è comportamento di una particolare implementazione.

### Due profili, una sola lingua

Lo standard definisce due profili di conformità, ed è utile saperli distinguere prima di cominciare:

| profilo | che cosa contiene | dove è definito |
|---|---|---|
| **Triad-Core** | valori, funzioni, chiusure, controllo di flusso, liste, stringhe, I/O | [`SPEC-CORE.md`](SPEC-CORE.md) |
| **Triad-Full** | tutto: tipi dichiarati, dispatch, logica, macro, contratti, budget, tracce, effetti | [`SPEC.md`](SPEC.md) |

Triad-Core è un **sottoinsieme** di Triad-Full: ogni programma Core è anche un programma Full
valido e deve comportarsi allo stesso modo. Il manuale presenta i due profili **sullo stesso piano**,
per costruzione logica: ogni capitolo introduce un costrutto e dice in quale profilo esiste. Non
perché Full sia "più avanti", ma perché sono due facce della stessa specifica.

Il profilo Core non è una versione semplificata per comodità didattica: è il sottoinsieme scelto
perché un interprete di bootstrap, scritto in poche migliaia di righe, possa eseguirlo, e perché lo
stesso linguaggio possa descrivere se stesso. Full aggiunge i costrutti che richiedono un motore più
ricco — dispatch multiplo, unificazione, espansione di macro — ma non cambia il significato di
quelli che Core ha già. Imparare Core, quindi, non è tempo speso per un linguaggio diverso.

Dove la differenza conta, trovi due marcatori:

- **[Core]** — il costrutto esiste nel sottoinsieme di bootstrap;
- **[Full]** — il costrutto esiste solo nello standard completo.

Un marcatore di profilo descrive ciò che lo standard definisce, non ciò che ogni programma
installato sa già eseguire. Per questo il manuale distingue tre livelli: la regola normativa
(che cosa deve significare il costrutto), la disponibilità nel profilo Core o Full e lo stato
delle implementazioni presenti nel repository. Un esempio Full può essere corretto secondo lo
standard e, allo stesso tempo, non essere ancora eseguibile dal runtime corrente. Quando un
esempio riporta **Output (golden Full)**, il risultato è un valore atteso conservato dalla suite,
non una verifica appena eseguita da un interprete Full completo.

Per studiare un costrutto senza confondere questi livelli, chiediti nell'ordine: che forma
accetta la grammatica? quali valori legge e produce? quali effetti o errori può generare? in quale
profilo è definito? quale implementazione e quale caso di conformance lo verificano? Questa
sequenza permette di passare dal codice alla semantica e poi alle prove, invece di trattare
l'output di un singolo runtime come definizione del linguaggio.

### Convenzioni di notazione

| notazione | significa |
|---|---|
| `monospace` | codice Triad o un valore letterale |
| **Output:** | l'output esatto prodotto dal programma |
| **[Core]** / **[Full]** | il profilo in cui il costrutto esiste |
| `SPEC §n` | la sezione normativa corrispondente |

I blocchi di codice sono marcati con il loro livello di eseguibilità:

| fence | significa |
|---|---|
| ```` ```triad ```` | programma **eseguibile oggi** con l'interprete di riferimento |
| ```` ```triad-full ```` | programma **specifica dello standard**: definito e normativo, ma non ancora eseguibile dal runtime corrente |

### Come eseguire gli esempi

Gli esempi marcati `triad` si eseguono con l'interprete di riferimento JavaScript:

```sh
node seed/dev/triad_core.cjs programma.triad
```

Il programma riceve gli argomenti in `ARGS` (lista di stringhe, senza il nome del programma) e lo
shebang `#!` in prima riga viene ignorato dal parser.

```triad
#!/usr/bin/env triad
# saluto.triad
println("ciao, " * "Triad")
println(6 * 7)
```

```sh
node seed/dev/triad_core.cjs saluto.triad uno due
```

**Output:**

```text
ciao, Triad
42
```

L'esempio mostra tre cose che valgono in tutto il libro. Lo shebang è solo una comodità dei sistemi
operativi: il parser lo salta, quindi il programma comincia davvero dalla seconda riga. `println`
non inserisce separatori tra gli argomenti, quindi la virgola e lo spazio che vedi nell'output sono
caratteri scritti nel programma, non una formattazione automatica. Infine `6 * 7` viene calcolato
prima della stampa: gli argomenti di una chiamata sono espressioni, non testo. Gli argomenti passati
da riga di comando (`uno`, `due`) non diventano variabili con quei nomi: finiscono tutti nella lista
`ARGS`, come spiegato nel capitolo 20.

### Indice

**Parte I — Il linguaggio**

1. [Lessico](#cap-1) · 2. [Valori e tipi](#cap-2) · 3. [Variabili e assegnamento](#cap-3) ·
4. [Operatori e precedenza](#cap-4) · 5. [Controllo di flusso](#cap-5) ·
6. [Funzioni](#cap-6) · 7. [Tipi e multiple dispatch](#cap-7) ·
8. [Lambda, chiusure e scope](#cap-8) · 9. [Liste](#cap-9) ·
10. [Stringhe, simboli e conversioni](#cap-10) · 11. [Errori come dati](#cap-11) ·
12. [Contratti](#cap-12) · 13. [Budget](#cap-13) · 14. [Tracce](#cap-14) ·
15. [Effetti dichiarati](#cap-15) · 16. [Logica](#cap-16) ·
17. [Codice come dato](#cap-17) · 18. [Macro](#cap-18) ·
19. [Builtin](#cap-19) · 20. [Riga di comando e REPL](#cap-20) ·
21. [Primitivi di bootstrap](#cap-21) · 22. [Stile e pattern idiomatici](#cap-22)

**Parte II — Esercizi** · [23. Esercizi guidati](#cap-23) · [24. Esercizi su Triad-Full](#cap-24)

**Parte III — Riferimento** · [25. Grammatica](#cap-25) · [26. Schede rapide](#cap-26) ·
[27. Tabella degli errori](#cap-27) · [28. Glossario](#cap-28) ·
[29. Cosa gira oggi](#cap-29)

**Appendici** · [A. Influenze dichiarate](#app-a) · [B. Dove guardare](#app-b)

---

<a id="parte-1"></a>

# Parte I — Il linguaggio

La prima parte costruisce il linguaggio strato per strato: prima i mattoni (lessico e valori),
poi le espressioni e il controllo di flusso, quindi le funzioni e i modelli di calcolo che Triad
aggiunge — dispatch, chiusure, logica, codice come dato — e infine gli strumenti con cui un
programma comunica con l'esterno (errori, contratti, budget, tracce, effetti). Ogni capitolo si
appoggia ai precedenti; gli esempi sono brevi apposta, perché il punto non è ammirare un programma
ma capire una regola.

<a id="cap-1"></a>

## 1. Lessico

### 1.1 Identificatori

Un identificatore comincia con una lettera o `_`, seguito da lettere, cifre o `_`. Un `!` finale è
ammesso se non è seguito da `=`. **[Core]**

```triad
x = 1
somma_2 = 2
_ = 3
nome_valido = 4
```

`push!`, `sort!` e simili sono nomi legittimi: la convenzione del `!` finale è per le funzioni che
mutano il loro argomento (cap. 9).

Il `!` non cambia il significato del nome e non è un operatore: è un segnale per chi legge. Il parser
lo accetta solo come ultimo carattere, e solo se il carattere seguente non è `=`; altrimenti
comincerebbe un confronto. Questa è la prima delle convenzioni che Triad eredita da Julia: il nome
dichiara un contratto, ma è il programmatore a doverlo rispettare.

In Triad-Full gli identificatori ammettono anche lettere non ASCII. **[Full]**

```triad-full
età = 42
```

### 1.2 Numeri

Gli interi si scrivono con cifre decimali; `_` funziona come separatore. Il segno è un operatore
unario, non parte del letterale. **[Core]**

La distinzione è più importante di quanto sembri: `-5` è l'applicazione dell'operatore `-` al
letterale `5`, non un numero negativo scritto in un modo speciale. Per questo non esiste una
"sintassi negativa" da ricordare: le parentesi e i livelli di precedenza del capitolo 4 spiegano già
che cosa succede in un'espressione come `-x * y`.

```triad
println(42)
println(1_000_000)
println(-5)
```

**Output:**

```text
42
1000000
-5
```

`Float` esiste solo in Triad-Full. **[Full]**

```triad-full
println(3.14)
println(1e-9)
```

### 1.3 Stringhe

Una stringa è una sequenza di byte UTF-8 **immutabile**, tra apici doppi. Gli escape sono `\n`,
`\t`, `\"`, `\\`. **[Core]**

```triad
println("ciao\n")
println("tab:\t|")
println("virgolette: \"")
println("backslash: \\")
```

**Output:**

```text
ciao

tab:	|
virgolette: "
backslash: \
```

In Core **non esiste l'interpolazione**: `"x = $x"` stampa letteralmente `x = $x`. In Full esiste, e
si scrive `$x` per un'espressione semplice e `$(espr)` per una complessa. **[Full]**

```triad-full
x = 42
println("x = $x")
println("x + 1 = $(x + 1)")
```

### 1.4 Simboli

Un simbolo è `:` seguito da un nome o da un operatore: `:alice`, `:+`. Due simboli sono uguali se
hanno lo stesso nome. In Triad-Full il simbolo è anche l'atomo della logica (cap. 16). **[Core]**

Un simbolo serve a dare un nome stabile a una cosa — una categoria, una chiave, un atomo — senza la
flessibilità e il costo di una stringa. La differenza rispetto a una stringa non è solo di comodità:
`:alice` è un'identità, `"alice"` è una sequenza di byte; due simboli con lo stesso nome sono lo
stesso valore ovunque compaiano, mentre due stringhe vanno confrontate carattere per carattere. È
questa proprietà che rende i simboli adatti alle chiavi dei record (cap. 2), ai tag delle liste e
agli atomi dei fatti (cap. 16).

```triad
println(:alice)
println(:+)
println(:ok == Symbol("ok"))
```

**Output:**

```text
alice
+
true
```

### 1.5 Commenti

`#` commenta fino a fine riga. `#= … =#` commenta su più righe; lo standard descrive questa forma
ma **non** stabilisce che i commenti a blocco si annidino, e l'interprete di riferimento chiude al
primo `=#`: non contare sull'annidamento. **[Core]**

```triad
#= commento
   su più righe =#
x = 1_000   # commento di riga
println(x)
```

**Output:**

```text
1000
```

### 1.6 Separatori e fine-riga

Un'istruzione termina con un a capo o con `;`. Gli a capo **chiudono** un'istruzione, tranne dentro
`( )`, `[ ]` e `:( )`, e tranne subito dopo un operatore binario o una virgola di `rule`.

```triad
println(1); println(2)
```

Una conseguenza pratica: **in Triad-Core ogni a capo chiude l'istruzione**. La grammatica di Core
non ha una regola di continuazione di riga: un'espressione spezzata su più righe non è un
programma valido. Scrivi **una istruzione per riga** e usa `;` per separare due istruzioni.

```triad
totale = 1 + 2 + 3
println(totale);
println("seconda istruzione")
```

**Output:**

```text
6
seconda istruzione
```

La regola ha una conseguenza sulla formattazione: quando vuoi spezzare un'espressione lunga, le
parentesi non bastano in Core. L'interprete di riferimento chiude l'istruzione al primo a capo anche
dentro una chiamata, quindi `println(1 +` e `2)` su righe diverse non sono un programma valido oggi.
Per il codice destinato al runtime attuale vale una regola sola: una istruzione per riga, e `;` solo
quando due istruzioni devono stare sulla stessa riga.

> **In Triad-Full** la regola è più permissiva: `SPEC §1` stabilisce che un a capo **non** chiude
> l'istruzione dentro `( )`, `[ ]` e `:( )`, né subito dopo un operatore binario. L'interprete di
> riferimento attuale non implementa ancora questa eccezione, quindi anche in Full la forma
> sicura resta una istruzione per riga.

### 1.7 La regola dei due punti e del punto interrogativo

`:` ha tre significati e `?` ne ha due. La specifica li chiama esplicitamente «il problema classico
di `:`» — è il primo punto in cui Triad si discosta dalla sintassi che conosci.

| scrittura | significato |
|---|---|
| `1:n`, `xs[2:end]` | `:` attaccato a un valore e senza spazi → **range** |
| `f(:a)`, `x = :a` | `:` non preceduto da un valore e seguito da un nome → **simbolo** |
| `:( … )` | → **codice quotato** |
| `c ? a : b` | `:` circondato da spazi → **separatore del ternario** |

| scrittura | significato |
|---|---|
| `?x` | `?` attaccato → **variabile logica** |
| `? ` | `?` con spazio dopo → **ternario** |

Da qui la regola pratica: quando `:` è ambiguo, **metti o togli gli spazi**. `xs[2:end]` è un range;
`c ? a : b` è un ternario perché i due spazi lo circondano.

Le due tabelle sembrano un elenco di casi speciali, ma discendono da un'unica idea: un carattere
aderente al token precedente appartiene a quel token, uno separato appartiene alla sintassi.
Per questo in Triad la spaziatura non è questione di stile: è informazione che il parser legge. Se
scrivi `xs[2: end]` oppure `a ? b:c`, cambiando gli spazi non cambi l'aspetto del programma: cambi
che cosa il parser riconosce, e il più delle volte ottieni un errore di sintassi. Il consiglio è di
scrivere sempre gli spazi che rendono esplicito il significato.

### 1.8 Parole chiave

Lo standard definisce **29 parole chiave**:

```
function struct macro end if elseif else for in while let begin return
break continue fact rule solve quote try catch with requires ensures
true false nothing isa is
```

E **4 parole contestuali**, valide solo dopo `solve`:

```
limit depth steps trace
```

`true`, `false` e `nothing` sono valori, non parole strutturali.

Le parole chiave sono riservate perché il parser deve riconoscerle prima di sapere che cosa stanno
facendo: se `if` potesse essere anche un nome di variabile, la lettura di una riga dipenderebbe dal
contesto in modo imprevedibile. `true`, `false` e `nothing` fanno eccezione solo in apparenza: sono
valori che il linguaggio predefinisce, non forme sintattiche. Le quattro parole contestuali mostrano
lo stesso principio al contrario: `limit`, `depth`, `steps` e `trace` sono nomi normalissimi finché
non seguono `solve`, e solo lì hanno un significato speciale. Questa distinzione riduce il numero di
parole riservate e ti permette di usare nomi naturali nel resto del programma.

### 1.9 Identificatori avanzati e convenzioni

In Triad-Core gli identificatori sono limitati all'ASCII: lettere, cifre e `_`. In Triad-Full si
ammettono anche lettere non ASCII (accentate, greche, cirilliche): `età`, `π`, `Δx` sono nomi
validi. **[Full]**

```triad-full
età = 42
π = 3.14159
Δx = 0.001
println(età + π)
```

La convenzione del `!` finale (`push!`, `sort!`) indica funzioni che **mutano** il loro argomento.
È l'unico carattere speciale ammesso dentro un identificatore: la grammatica accetta lettere, cifre,
`_` e il `!` finale, e nulla di più. In particolare il `?` **non** fa parte del nome, perché in Triad
introduce una variabile logica o un ternario: `valido?` non è un identificatore valido. Per un
predicato usa un nome normale e lascia che sia il tipo `Bool` del risultato a dire che cos'è —
`vuoto`, `is_valido`. **[Core]**

```triad
function push!(xs, v)
    # muta xs e lo restituisce
    xs
end

function vuoto(xs)
    length(xs) == 0
end
```

Il corpo di `push!` qui è volutamente vuoto: l'esempio parla dei nomi, non dell'implementazione. La
mutazione vera delle liste, con `push!` e con l'assegnamento a un elemento, è nel capitolo 9.

Gli identificatori che coincidono con una parola chiave non sono ammessi: `function`, `end`,
`if` non possono essere usati come nomi di variabile o funzione. **[Core]**

### 1.10 Escape e stringhe avanzate

Lo standard fissa quattro escape nelle stringhe: `\n`, `\t`, `\"`, `\\`; in Triad-Full si aggiunge
`\$`, perché il `$` introduce l'interpolazione e va neutralizzato quando deve restare un carattere
normale. Le forme estese `\r`, `\0`, `\u{…}` e `\x{…}` che compaiono nel frammento seguente non sono
elencate in `SPEC §1`: trattale come estensioni di una singola implementazione, non come garanzia del
linguaggio. Un programma portabile usa le escape documentate. **[Full]**

```triad-full
println("a\r\nb")          # ritorno a capo CRLF
println("unicode: \u{1F600}")  # emoji
println("hex: \x{41}")     # 'A'
```

Una stringa è una sequenza di byte UTF-8 e le stringhe sono **immutabili**: ogni operazione di
concatenazione crea una nuova stringa, come mostra l'esempio qui sotto. La lunghezza si misura in
byte e non in caratteri, un dettaglio che conta appena esci dall'alfabeto latino (cap. 10). **[Core]**

```triad
a = "ciao"
b = a * " mondo"
println(a)        # "ciao" — inalterato
println(b)        # "ciao mondo"
```

**Output:**

```text
ciao
ciao mondo
```

### 1.11 Esercizi sul lessico

1. Scrivi un programma che stampi il tuo nome e la tua età su due righe, usando `\n` e
   concatenazione di stringhe.
2. Definisci un identificatore con `_` iniziale e uno con `!` finale; stampali.
3. Prova a scrivere `x = 1_000_000` e verifica che l'output sia `1000000`.
4. (Full) Scrivi una stringa con interpolazione `$x` e `$(x + 1)`.
5. (Full) Definisci il simbolo `:ok` e confrontalo con `Symbol("ok")`.

---

<a id="cap-2"></a>

## 2. Valori e tipi

### 2.1 I tipi

Un valore Triad appartiene sempre a un tipo, e il tipo si può sempre osservare: la tabella elenca i
tipi dello standard, con il nome che `typeof` restituisce e il profilo in cui esistono.

| tipo | valori | `typeof(v)` |
|---|---|---|
| `Int` | interi con segno a 64 bit, aritmetica con wrap | `Int` |
| `Float` | numeri in virgola mobile **[Full]** | `Float` |
| `Bool` | `true`, `false` | `Bool` |
| `String` | sequenza di byte UTF-8 immutabile | `String` |
| `Symbol` | `:nome` | `Symbol` |
| `List` | lista eterogenea mutabile, indici da 1 | `List` |
| `Function` | funzione nominata, lambda, builtin | `Function` |
| `Nothing` | `nothing` | `Nothing` |
| `Expr` | codice quotato **[Full]** | `Expr` |
| `Term`, `LVar` | termini e variabili logiche **[Full]** | — |
| `Solution` | `{who = :dave}` **[Full]** | — |
| `Err` | errore come dato **[Full]** | — |
| `Type` | i tipi stessi sono valori **[Full]** | — |
| struct utente | `Point(3.0, 4.0)` **[Full]** | `Point` |

Il set dei tipi Core è **chiuso e piccolo**: `Int`, `Bool`, `String`, `Symbol`, `List`, `Function`,
`Nothing`. In Core non esistono `Float`, `Term`, `Solution`, `Err` come valori del linguaggio: un
errore è una lista taggata `[:Err, kind, msg]` (cap. 11) e una struct è `[:Point, x, y]`. Il set
chiuso non è una limitazione arbitraria: un interprete di bootstrap deve poter rappresentare ogni
valore con poche strutture, e i concetti Full che mancano — errore, struct, soluzione — si
ricostruiscono per convenzione sopra liste e simboli.

`typeof` restituisce il **nome del tipo come simbolo**. Il dettaglio del profilo conta: in Core il
risultato è un `Symbol`, quindi `typeof(1) == :Int` è il confronto naturale; in Triad-Full i tipi sono
valori di tipo `Type`, per cui `typeof(3) == Int` confronta direttamente con il tipo. La stampa è la
stessa (`Int`), ma l'operazione che scrivi è diversa — ed è per questo che la tabella qui sopra ha una
colonna `typeof(v)` con il nome e non con il tipo.

È utile separare tre idee che nella sintassi possono sembrare la stessa cosa. Il **valore** è il
dato concreto, per esempio `5` o `"ciao"`; il **tipo dinamico** descrive la categoria del valore
che il programma sta manipolando; un **vincolo dichiarato** restringe invece quali valori può
assumere un nome o un parametro. In Core il tipo si osserva con `typeof`, ma non si dichiara una
variabile come `x::Int`. In Full i tipi entrano anche nelle firme, nelle struct e nel dispatch.
Una conversione come `Float(3)` costruisce un valore compatibile; un'asserzione come `x::Int`
controlla un valore già ottenuto. Sono operazioni diverse: convertire può cambiare il valore,
asserire non è una richiesta di conversione.

Un'altra distinzione importante è tra tipo **nominale** e forma strutturale. In Full una
`struct Point` dichiara un'identità di tipo, quindi un valore `Point` non diventa un altro tipo
solo perché possiede campi simili. In Core, dove non ci sono struct, la stessa informazione è
convenzionale: una lista come `[:Point, 3, 4]` porta il tag `:Point` e i campi in posizioni
concordate dal programma. Il tag rende possibile riconoscere il record, ma non aggiunge da solo
controlli di campo, immutabilità o dispatch.

```triad
xs = [1, :a, "s"]
println(typeof(1), " ", typeof("s"), " ", typeof(:a), " ", typeof(xs))
println(typeof(nothing), " ", typeof(true), " ", typeof(x -> x))
```

**Output:**

```text
Int String Symbol List
Nothing Bool Function
```

### 2.2 Gerarchia dei tipi

`Int <: Number`, `Float <: Number`, e ogni tipo è sottotipo di `Any`. `Any` è il supertipo usato
nelle firme quando un parametro accetta qualunque cosa. **[Full]**

La gerarchia esiste per il dispatch (cap. 7): un metodo dichiarato su `Number` accetta anche gli
`Int`, perché `Int` è un sottotipo di `Number`. In Core la gerarchia non si può osservare, perché non
c'è dispatch multiplo, ma resta il motivo per cui i tipi hanno un nome e non sono solo etichette di
comodo: la relazione fra i nomi è ciò che permette di scrivere un metodo una volta e di applicarlo a
una famiglia di valori.

```triad-full
function accetta_qualsiasi(x::Any)
    "qualunque cosa: " * string(x)
end
```

### 2.3 Struct

Una `struct` è un record immutabile con campi tipizzati e costruttore posizionale. Il
costruttore controlla i campi; un `Int` passato a un campo `Float` viene convertito, un valore non
convertibile produce `Err(:type)`. **[Full]**

```triad-full
struct Point
    x::Float
    y::Float
end

p = Point(3, 4)
println(p.x, " ", p.y)
println(typeof(p) == Point)
println(p isa Point)
```

**Output (golden Full):**

```text
3.0 4.0
true
true
```

In Core lo stesso concetto si rappresenta con una **lista taggata**: `[:Point, x, y]`, con il
simbolo del tipo in prima posizione. È così che gli interpreti di `selfhost/` rappresentano le
struct Full. La differenza tra il record Full e quello Core non è solo di scrittura: la struct ha
un'identità di tipo e campi immutabili, il record Core è una lista, quindi può essere mutata e
nessuno impedisce di costruirne una con un tag sbagliato. Il tag rende il dato riconoscibile, non
lo rende sicuro: i controlli che una struct fa da sola, in Core li deve fare il programma.

```triad
punto(x, y) = [:Point, x, y]
px(p) = p[2]
py(p) = p[3]
println(punto(1, 2), " ", px(punto(1, 2)))
```

**Output:**

```text
[:Point, 1, 2] 1
```

### 2.4 Conversioni

`Int(x)`, `Float(x)`, `String(x)`, `Symbol(x)`. Il nome del tipo usato come funzione converte; il
nome di una struct usato come funzione **costruisce**. **[Full]**

La conversione è un'operazione esplicita: Triad non trasforma i tipi da solo, tranne nei punti in
cui la specifica lo prescrive — un `Int` passato a un campo `Float` di una struct, o il valore di
ritorno controllato con `::R`. Altrove la conversione la chiedi tu, e questo rende leggibile il
punto in cui il tipo cambia. `string(x)`, che vedi nella tabella del capitolo 10, è un caso a parte:
è definita per ogni valore e serve a costruire testo, per questo nei programmi Core è il modo
normale di convertire un numero in stringa.

```triad-full
println(Int("42") + 1)
println(Float(3))
println(Symbol("ciao"))
println(String(42))
```

`Int(s)` e `Symbol(s)` esistono anche in Core, ma solo per stringhe e simboli. **[Core]**

```triad
println(Int("41") + 1)
println(Symbol("bob"))
```

**Output:**

```text
42
bob
```

### 2.5 Asserzione di tipo

`e::T` restituisce `e` se è di tipo `T`, altrimenti produce `Err(:type)`. **[Full]**

```triad-full
x = 3
println(x::Int)
println(iserr(x::String))
```

### 2.6 Il vincolo del dichiarato

`x::T = e` — e un parametro `x::T` — **fissa** il tipo di quel nome nell'ambiente in cui nasce. Gli
assegnamenti successivi sono controllati e convertiti contro `T`. Una nuova dichiarazione
`x::U = …` sostituisce il vincolo; un nome non dichiarato con tipo resta libero; una rilegatura in
un ambiente interno (`let x = 2.5`) non eredita il vincolo esterno. **[Full]**

```triad-full
x::Int = 5
x = 6            # bene
x = 5.5          # Err(:type)

y::Float = 1.0
y = 2            # 2.0: conversione Int -> Float

s = "a"
s = 3            # bene: s non è dichiarato con un tipo
```

Il vincolo vale per l'ambiente in cui il nome nasce, non per sempre: è un'annotazione locale, non
una dichiarazione globale. Questo permette di introdurre i tipi in un programma Core già scritto
senza riscriverne la struttura, e spiega perché `let x = 2.5` dentro una funzione non è un errore
anche quando fuori `x` era vincolato a `Int`. Il controllo avviene a ogni assegnamento, quindi il
costo è un controllo in più per ogni scrittura; in cambio, un valore del tipo sbagliato non entra
mai nel nome, e l'errore arriva dove il tipo è stato promesso, non molto più tardi.

### 2.7 Le condizioni accettano solo `Bool`

Non esiste il concetto di «verità implicita»: un valore non diventa vero o falso per convenzione.
`if 1` è un errore, non `true`. Questo vale per `if`,
`while`, `&&`, `||`, `!`, il ternario e i filtri delle comprehension. **[Core]**

```triad
println(1 < 2 && 2 < 3)
x = 3
println(x > 2 ? "grande" : "piccolo")
```

**Output:**

```text
true
grande
```

La scelta è deliberata. In un linguaggio con tipi dinamici e con gli errori come valori, l'unica
cosa che una condizione deve fare è produrre `true` o `false`; ammettere valori "veri" per
convenzione (`0`, `""`, `[]`) renderebbe ambiguo il significato di un programma e sposterebbe
l'errore lontano dalla sua causa. Con la regola stretta, `if xs` è un errore immediato e dice che lì
serve un confronto — per esempio `if length(xs) > 0`. Lo stesso vale per `&&` e `||`: entrambi gli
operandi che vengono valutati devono essere `Bool`, anche se il cortocircuito ne risparmia uno.

### 2.8 Come stampa un valore

`print` e `println` concatenano gli argomenti **senza separatori**; `println` aggiunge un a capo.

| valore | come viene stampato |
|---|---|
| `Int` | decimale |
| `Bool` | `true` / `false` |
| `String` | così com'è |
| `Nothing` | `nothing` |
| `Symbol` | **senza** `:` se passato direttamente, **con** `:` dentro una lista |
| `List` | `[a, b]`; le stringhe dentro non hanno virgolette |
| `Function` | `#lambda(x)` |

```triad
xs = [1, :a, "s", true, nothing, [2, 3]]
println(xs)
println(:alice)
print("senza ", "a capo")
println()
```

**Output:**

```text
[1, :a, s, true, nothing, [2, 3]]
alice
senza a capo
```

La differenza tra un simbolo stampato da solo e dentro una lista non è un capriccio: fuori da una
lista il simbolo è l'unico contenuto dell'output, dentro una lista serve un modo per distinguerlo da
una stringa con lo stesso testo. Per questo `println(:a)` stampa `a` mentre le liste usano `:a`, e
per questo la tabella va letta come «come appare un valore quando è stampato», non come «come è
fatto il valore». Le stringhe dentro una lista non hanno virgolette per la stessa ragione: la
stampa è pensata per essere leggibile, non per essere riletta dal parser.

L'uguaglianza confronta numeri, stringhe e simboli **per valore**, le liste **elemento per
elemento** (anche annidate), le funzioni **per identità**. **[Core]**

```triad
println([1, [2, [3]]] == [1, [2, [3]]])
println("ab" == "a" * "b", " ", :a == :a, " ", 1 == 2)
```

**Output:**

```text
true
true true false
```

---

<a id="cap-3"></a>

## 3. Variabili e assegnamento

`nome = espr` lega o aggiorna un nome. L'assegnamento **è un'espressione** e vale il valore
assegnato. `+=`, `-=`, `*=` aggiornano una variabile esistente e valutano il lato sinistro una
volta sola. Usare un nome mai assegnato è un errore di esecuzione. **[Core]**

Il segno `=` non si legge «scrivi in memoria»: lega un nome a un valore. Quando il nome non esiste
lo crea, quando esiste ne sostituisce il legame. Triad non distingue i due casi con parole chiave
diverse e non ha una parola per dichiarare una variabile: `let` introduce uno scope, non dichiara un
tipo. Questa semplicità ha un prezzo che conviene conoscere subito: un nome scritto male non viene
segnalato mentre scrivi, ma solo quando quella riga viene eseguita.

```triad
x = 42
y = x + 8
x = x + 1
z = (x + y) * 2
println(x, " ", y, " ", z)
n = 10
n += 5
n -= 3
n *= 2
println(n)
```

**Output:**

```text
43 50 186
24
```

Non esistono dichiarazioni: le variabili sono dinamiche. Le regole di **visibilità** si vedono nel
capitolo 8.

Perché mai un assegnamento dovrebbe avere un valore? Perché in Triad tutto ciò che può comparire in
un programma è un'espressione, e l'assegnamento non fa eccezione: così `x = 42` può stare dentro un
`if`, un `let` o un argomento di funzione senza una sintassi speciale. Il valore è quello assegnato,
non un `Bool` di successo come in altri linguaggi; per questo non scriverai `if x = 5` aspettandoti
un controllo, perché `5` non è un `Bool` e la condizione fallisce con un errore di tipo.

Anche `+=`, `-=` e `*=` sono espressioni e valgono il valore aggiornato. Non sono forme
dichiarative e non introducono un nome nuovo: aggiornano un legame che deve già esistere. In cambio
valutano il lato sinistro una volta sola, un dettaglio che con un semplice nome non si nota ma che
conta quando il bersaglio è un elemento di lista (`xs[i] += 1`, cap. 9): così l'indice non viene
calcolato due volte.

Leggi l'esempio distinguendo il **nome** dal valore: dopo `x = 42`, `x` è un legame
dell'ambiente corrente; `y = x + 8` legge quel legame e memorizza il risultato `50` in un legame
diverso; `x = x + 1` calcola prima `43` e poi rimpiazza il valore associato a `x`. Di conseguenza
`y` resta `50`: non è un alias automatico dell'espressione che lo ha prodotto. L'assegnamento
ritorna il nuovo valore, perciò può comparire dentro un'espressione, ma questo non significa che
ogni assegnamento sia globale: funzione, lambda e `let` definiscono regole di scope distinte.

Infine, riassegnare un nome non equivale a mutare un oggetto. Con `x = 43` cambia il legame di
`x`; con `xs[1] = 43` cambia un elemento della lista a cui `xs` fa riferimento. Se un secondo nome
indica la stessa lista, vedrà la mutazione; una riassegnazione locale di `xs`, invece, non cambia
automaticamente il legame dell'altro nome. Questa differenza diventa essenziale quando una
funzione condivide una lista con il chiamante.

---

<a id="cap-4"></a>

## 4. Operatori e precedenza

Il parser è un **Pratt** con dodici livelli. «Pratt» significa che ogni operatore ha un numero di
precedenza e il parser, leggendo da sinistra, sa quando fermarsi e restituire il controllo al
livello più basso: è un modo compatto di descrivere l'albero senza scrivere una regola per ogni
combinazione di operatori. Dalla precedenza più bassa alla più alta:

| livello | operatori | associatività |
|---|---|---|
| 1 | `=` `+=` `-=` `*=` | destra |
| 2 | `x -> e`, `(a, b) -> e`, `c ? a : b` | destra |
| 3 | `\|\|` | sinistra, cortocircuito |
| 4 | `&&` | sinistra, cortocircuito |
| 5 | `==` `!=` `<` `<=` `>` `>=` `in` `isa` `is` | sinistra |
| 6 | `a:b` | range, senza spazi |
| 7 | `+` `-` | sinistra |
| 8 | `*` `/` `%` | sinistra |
| 9 | `-x` `!x` `+x` `$x` | prefissi |
| 10 | `^` | **destra** |
| 11 | `e::T` | asserzione di tipo |
| 12 | `f(args)` `xs[i]` `a.campo` | postfissi, senza spazio prima di `(` e `[` |

I livelli 6, 8 (la divisione), 9 (`$x`), 11 (`::`) e alcuni operatori di confronto esistono solo in
Triad-Full. In Triad-Core i livelli effettivamente usati sono **dieci**, perché mancano il range, la
divisione, `$x`, `::` e gli operatori `in`, `isa`, `is`; tolti quelli, la tabella si compatta ma il
rapporto fra gli operatori che restano è lo stesso. Il numero dodici, che il glossario riporta, è
quindi il conteggio del profilo Full: non è in contraddizione con i dieci livelli di Core, è il
conto di un profilo più grande. **[Core]**

La precedenza decide **come il parser raggruppa** gli operatori, non quale calcolo avviene per
primo in ogni possibile programma. Per esempio, `2 + 3 * 4` viene letto come `2 + (3 * 4)`: la
moltiplicazione appartiene a un livello più forte della somma. Le parentesi non cambiano la regola
del linguaggio; rendono esplicita una scelta del programmatore e aiutano chi legge.
L'associatività risolve invece la parità di precedenza: `2 ^ 3 ^ 2` è `2 ^ (3 ^ 2)`, mentre le
sottrazioni a catena si raggruppano a sinistra. Quando la precedenza è poco familiare, scrivere le
parentesi è una forma di documentazione eseguibile.

Il raggruppamento non va confuso con la valutazione. `&&` e `||` sono operatori a cortocircuito:
il secondo operando viene valutato solo se il primo non determina già il risultato. Ciò consente
di mettere a destra un controllo che dipende da un valore valido a sinistra, per esempio prima
verificare che un indice sia entro i limiti e poi leggere la lista. In Core ogni condizione deve
comunque produrre un `Bool`; un intero o una lista non vengono convertiti implicitamente in
vero/falso.

### 4.1 Aritmetica intera

L'aritmetica di Core è interamente intera e queste quattro regole vanno lette come un modello unico,
non come curiosità isolate: il tipo `Int` è un blocco di 64 bit, le operazioni lo trattano come tale,
e la divisione è lasciata a Full perché richiede un altro tipo di numero.

- `+ - * ^` su `Int` con **wrap a 64 bit** (complemento a due);
- `%` è il **resto con il segno del dividendo**, come `rem` di Julia: `-7 % 3 == -1`;
- `^` con esponente negativo è un errore; `%` per zero è un errore;
- **`/` non esiste in Core**: la divisione è di Triad-Full.

```triad
println(2 + 3 * 4, " ", (2 + 3) * 4, " ", 2 ^ 3 ^ 2)
println(7 % 3, " ", -7 % 3, " ", 10 % 4)
println(9223372036854775807 + 1)
```

**Output:**

```text
14 20 512
1 -1 2
-9223372036854775808
```

Nota `2 ^ 3 ^ 2 == 512`: l'esponente è associativo a destra, come in matematica.

Il wrap non è un difetto da aggirare: `Int` è un intero a 64 bit e l'aritmetica è quella del
complemento a due, quindi superare il massimo riporta al minimo. Se il tuo calcolo può crescere
oltre i 64 bit, in Full puoi passare a `Float` (con i suoi limiti di precisione); in Core devi
progettare il calcolo per restare nei limiti, per esempio controllando i valori prima di
moltiplicare.

`%` segue il segno del dividendo perché è il resto della divisione intera troncata verso zero, non
il modulo matematico, che sarebbe sempre non negativo: `-7 % 3` è `-1` e non `2`. La distinzione
conta negli algoritmi che usano il resto per alternare indici o per normalizzare valori negativi.

Infine `/`: in Core non esiste perché la divisione esatta di due interi non ha un tipo in cui vivere
senza i numeri in virgola mobile. In Full `/` produce un `Float` e `div` fa la divisione intera; se
lavori in Core, la divisione intera la scrivi a mano, come nell'esempio del capitolo 11.4.

### 4.2 Logica e confronti

`&&` e `||` cortocircuitano. I confronti **non** si concatenano: `1 < 2 < 3` è un errore (si
confronta `Bool < Int`); scrivi `1 < 2 && 2 < 3`. **[Core]**

```triad
println(!false, " ", true && false, " ", false || true)
println(1 < 2 && 2 < 3)
```

**Output:**

```text
true false true
true
```

---

<a id="cap-5"></a>

## 5. Controllo di flusso

In Triad **tutto è un'espressione**: `if`, `while`, `let`, `begin` hanno un valore, quello
dell'ultima istruzione eseguita (`nothing` se non ce n'è).

Le eccezioni sono `return`, `break` e `continue`: non producono un valore, interrompono il flusso.
L'assegnamento invece è un'espressione (cap. 3), e questa uniformità è ciò che rende possibile
scrivere `v = if condizione … end` senza una sintassi speciale: un blocco è un'espressione come lo
è una somma.

Questa regola unifica due usi che in altri linguaggi spesso hanno sintassi separate: scegliere un
ramo e calcolare un risultato. In `v = if condizione ... end`, l'espressione completa produce il
valore dell'ultima espressione del ramo scelto; il codice dei rami non scelti non viene eseguito.
Le istruzioni che producono output o mutano una lista possono stare nello stesso blocco di
un'espressione che restituisce un valore: il risultato del blocco è l'ultima espressione, non una
combinazione automatica di tutti i risultati intermedi.

Le condizioni sono intenzionalmente restrittive: `if`, `while`, ternario, `&&` e `||` chiedono
un valore `Bool`. Non si usa una regola di «verità implicita» che interpreti `0`, stringhe vuote o liste
vuote come falsi. Questo rende visibili gli errori di tipo vicino alla decisione che li ha
provocati, invece di trasformarli in rami inattesi.

### 5.1 `if` / `elseif` / `else` **[Core]**

```triad
function classifica(x)
    if x < 0
        "negativo"
    elseif x == 0
        "zero"
    else
        "positivo"
    end
end
println(classifica(-3), " ", classifica(0), " ", classifica(7))
v = if 2 > 1 :si else :no end
println(v)
```

**Output:**

```text
negativo zero positivo
si
```

Nell'esempio `classifica` restituisce l'ultima espressione del ramo scelto, quindi non serve
nessun `return`. `v = if 2 > 1 :si else :no end` mostra la stessa cosa senza funzione: il blocco è
un valore e `v` riceve `:si`. Il ramo che non vince non viene eseguito affatto, non viene valutato
e poi scartato: se contenesse una stampa o una mutazione, non la vedresti.

Il ternario `c ? a : b` è la forma breve di `if` e ha la stessa precedenza del `->`. **[Core]**

### 5.2 `while`, `break`, `continue` **[Core]**

`break` e `continue` agiscono sul ciclo **più interno**.

```triad
i = 0
somma_dispari = 0
while i < 10
    i += 1
    if i % 2 == 0
        continue
    end
    somma_dispari += i
end
println(somma_dispari)
while true
    break
end
println(:fine)
```

**Output:**

```text
25
fine
```

Il primo ciclo somma solo i dispari: `continue` salta il resto del corpo, quindi l'aggiunta non
avviene per i pari, e il contatore `i` è già stato incrementato prima del salto. Se l'incremento
fosse stato in fondo al corpo, `continue` lo avrebbe saltato e il ciclo sarebbe stato infinito:
è la trappola classica di `continue` nei cicli con contatore manuale, e il motivo per cui conviene
incrementare subito, prima di ogni possibile uscita anticipata.

`break` e `continue` agiscono sul ciclo **più interno**; non esiste un'etichetta per uscire da due
cicli in un colpo, quindi in quel caso si usa una variabile di stato.

In Core **non esiste `for`**: si itera con un contatore e `while`. In Full `for` esiste (cap. 5.6).

### 5.3 `let` e `begin` **[Core]**

`let` introduce un nuovo scope con legami locali. `begin … end` raggruppa istruzioni in una sola
espressione, ma non è «senza conseguenze» sullo scope: l'interprete di riferimento aggiorna un nome
già legato fuori dal blocco, mentre un nome **nuovo** assegnato dentro `begin` non risulta visibile
fuori. La specifica non elenca `begin` fra i costrutti che introducono ambienti e nessun caso di
conformità fissa il punto: per i nomi nuovi è prudente trattare il blocco come un confine.

```triad
x = 1
let x = 10
    let x = 20
        println(x)
    end
    println(x)
end
println(x)
r = begin
    a = 2
    a * 21
end
println(r)
```

**Output:**

```text
20
10
1
42
```

L'esempio mostra tre legami distinti per `x`: quello esterno, quello introdotto dal primo `let` e
quello introdotto dal secondo. Ogni `let` crea un ambiente nuovo, e un nome viene cercato prima
nell'ambiente più interno; per questo le tre stampe danno `20`, `10`, `1` e nessuna delle tre
rilegature tocca le altre. `begin`, invece, è solo un raggruppamento: l'esempio assegna `a = 2` e
usa `a * 21` nello stesso blocco, quindi non dipende da che cosa resta visibile dopo. La regola da
tenere presente è che il blocco non serve a far uscire nomi nuovi: se un valore deve essere usato
fuori, assegnalo a un nome che esiste già prima del `begin` o restituiscilo come valore
dell'espressione. In pratica `let` serve quando vuoi isolare un nome o riusare un nome già preso
senza alterarne il legame esterno; `begin` serve a raggruppare istruzioni in un'espressione unica.

### 5.4 `for` e i range **[Full]**

`for` itera su una lista, un range o un risultato di `solve`. `a:b` produce il range da `a` a `b`
inclusi.

```triad-full
s = 0
for i in 1:10
    s += i
end
println(s)

xs = [1, 2, 3]
println(xs[end])
println(xs[2:end])
```

**Output (golden Full):**

```text
55
3
[2, 3]
```

`end` è un nome speciale che vale la posizione dell'ultimo elemento e si può usare dentro le
parentesi quadre di un indice: `xs[end]` è l'ultimo elemento, `xs[2:end]` è la coda dal secondo
elemento in poi. Il range `a:b` è inclusivo su entrambi gli estremi, quindi `1:10` contiene dieci
valori; è una forma di Triad-Full, e in Core si ottiene con un ciclo. La destrutturazione nel `for`
è trattata nel capitolo 24.

### 5.5 Le comprehension **[Full]**

La comprehension `[e for x in xs]` costruisce una lista; con `if` aggiunge un filtro.

```triad-full
println([x^2 for x in 1:4])
println([x^2 for x in 1:4 if x > 2])
```

**Output (golden Full):**

```text
[1, 4, 9, 16]
[9, 16]
```

La comprehension è zucchero per un ciclo che accumula in una lista: per ogni `x` di `1:4` valuta
`x^2` e aggiunge il risultato, senza un contatore esplicito. Il filtro `if x > 2` agisce
sull'elemento, non sull'indice: `9` e `16` restano perché `3` e `4` superano la soglia. In Core
`[e for x in xs]` non esiste e lo stesso lavoro lo fanno le funzioni scritte a mano del capitolo
22.1; in Full spesso la comprehension è la forma più leggibile, purché l'espressione resti breve.

### 5.6 `try` / `catch` **[Full]**

In Full l'errore è un **valore**, quindi `try` ha due forme: con `catch` il ramo gestito produce il
valore dell'espressione; senza `catch`, l'errore **diventa** il valore dell'espressione.

```triad-full
e = try div(1, 0) end
println(iserr(e), " ", e.kind)

r = try div(1, 0) catch err; 0 end
println(r)
```

**Output (golden Full):**

```text
true domain
0
```

Le due forme non sono intercambiabili. `try e end` non gestisce l'errore: lo rende il valore
dell'espressione, così puoi controllarlo con `iserr` e decidere dopo. `try e catch err; h end` invece
recupera: lega `err` all'errore e valuta `h`, il cui valore diventa il risultato. Nel primo caso
`e` è un `Err`, nel secondo `r` è `0`. Scegliere fra i due è una decisione di progetto: la prima
forma tiene l'errore nel flusso normale, la seconda lo confina in un punto preciso. È il motivo per
cui il capitolo 11 insiste sul fatto che «errore come dato» non significa «il programma continua da
solo»: senza un `try` che lo osservi, l'errore arriva al livello superiore e il programma termina.

---

<a id="cap-6"></a>

## 6. Funzioni

### 6.1 Tre forme di definizione **[Core]**

Una funzione nominata si definisce in due modi — forma breve e forma a blocco — e la terza forma è
una funzione anonima legata a un nome. La differenza è solo sintattica: la funzione che ottieni è la
stessa. La forma breve si usa quando il corpo è una sola espressione; la forma `function … end`
quando il corpo ha più istruzioni o un `return` che esce prima della fine; la lambda assegnata a un
nome è utile quando il valore funzione nasce dentro un'espressione.

```triad
# forma breve: il corpo è un'espressione
quadrato(x) = x * x

# forma blocco: il valore è quello dell'ultima espressione
function calcola(n)
    m = n + 1
    m * 2
end

# funzione anonima assegnata a un nome
moltiplica = function (a, b)
    a * b
end

println(quadrato(4), " ", calcola(3), " ", moltiplica(6, 7))
```

**Output:**

```text
16 8 42
```

`quadrato` e `calcola` sono funzioni nominate, `moltiplica` è un valore di tipo funzione legato a un
nome: dal punto di vista della chiamata non c'è differenza. Scegli la forma che rende più leggibile
il corpo, non quella che sembra più moderna; la forma breve con una sola espressione rende evidente
che non ci sono effetti nascosti tra le righe.

### 6.2 `return`, ricorsione, arità

`return e` esce subito dalla funzione; `return` da solo restituisce `nothing`. Una funzione nominata
è visibile nel proprio corpo, quindi la ricorsione diretta funziona. Il numero di argomenti deve
coincidere con i parametri. **[Core]**

```triad
function taglia(n)
    if n > 100
        return :grande
    end
    :piccola
end
fattoriale(n) = n < 2 ? 1 : n * fattoriale(n - 1)
fib(n) = n < 2 ? n : fib(n - 1) + fib(n - 2)
mcd(a, b) = b == 0 ? a : mcd(b, a % b)
println(taglia(500), " ", taglia(5))
println(fattoriale(10), " ", fib(15), " ", mcd(48, 18))
```

**Output:**

```text
grande piccola
3628800 610 6
```

Una chiamata può essere letta come una sequenza precisa: si valutano gli argomenti, si crea il
contesto della funzione, si associano i valori ai parametri e si esegue il corpo. Il corpo termina
in uno di due modi: raggiunge la fine e restituisce l'ultima espressione, oppure esegue `return`,
che interrompe immediatamente il corpo e restituisce il valore indicato. `return` senza
espressione restituisce `nothing`. Una ricorsione è una nuova chiamata con un proprio insieme di
parametri locali; il caso base impedisce di continuare a creare chiamate senza fine.

L'arità è parte della firma anche in Core: `somma(1, 2)` non è intercambiabile con `somma(1)`.
Triad-Full aggiunge i tipi alle firme e consente più metodi con lo stesso nome; questo non cambia
la nozione di chiamata, ma aggiunge una fase di selezione del metodo prima di eseguirne il corpo.

Un'ultima nota pratica: la ricorsione profonda consuma spazio di chiamata, quindi per profondità
grandi conviene un `while` con uno stato esplicito (cap. 22.6). Il caso base non è una formalità:
senza di esso la chiamata ricorsiva non si ferma e il programma non arriva a un risultato.

### 6.3 Funzioni di ordine superiore

Le funzioni sono valori di prima classe: si passano, si restituiscono, si compongono. In Core
`map`, `filter` e `reduce` **non esistono**: si scrivono a mano (cap. 22.1). In Full sono builtin.
**[Core]**

```triad
function applica_tutti(f, xs)
    out = []
    i = 1
    while i <= length(xs)
        push!(out, f(xs[i]))
        i += 1
    end
    out
end
println(applica_tutti(x -> x * x, [1, 2, 3]))
```

**Output:**

```text
[1, 4, 9]
```

In Full, `reduce(+, xs)` e `map(sq, xs)` funzionano perché anche gli **operatori sono funzioni**.

Il punto di `applica_tutti` non è la funzione specifica: è che `f` è un parametro come gli altri, e
`x -> x * x` è un valore costruito al momento della chiamata. Questa è la differenza fra scrivere
dieci cicli quasi uguali e scrivere un ciclo una volta sola; in Core `map` e `filter` non esistono
perché il linguaggio di bootstrap deve restare piccolo, non perché l'idea sia estranea a Triad. Le
funzioni del capitolo 22.1 sono la risposta pratica: scrivile una volta e riusale.

### 6.4 L'annotazione di effetto `!io`

Una funzione che stampa deve dichiarare `!io` nella firma. Core **accetta l'annotazione e la
ignora**: scriverla rende il codice già pronto per Full. **[Core]**

```triad
function mostra() !io
    println("hello from block")
    20 + 22
end
println(mostra())
```

**Output:**

```text
hello from block
42
```

L'annotazione non è decorativa. In Triad-Full una funzione dichiara le capacità che usa, e il
runtime verifica che il chiamante le permetta (cap. 15); in Core il controllo non esiste, ma
scrivere `!io` adesso significa non dover riscrivere la firma quando il programma passerà a Full.
La parola `io` è un permesso, non un'etichetta descrittiva: dice che la funzione può produrre
output, e chi la chiama deve essere autorizzato a farlo.

---

<a id="cap-7"></a>

## 7. Tipi e multiple dispatch

Una funzione generica è un insieme di metodi. Ridefinire la stessa firma sostituisce il metodo
precedente. Tra i metodi applicabili (stessa arità, ogni argomento sottotipo del parametro) vince
il **più specifico**. **[Full]**

```triad-full
area(n::Number) = :number
area(n::Int) = :int

println(area(1))
println(area(1.5))
```

**Output (golden Full):**

```text
int
number
```

L'esempio va letto come una ricerca: `area(1)` ha un `Int`, che è sottotipo sia di `Int` sia di
`Number`; entrambi i metodi sono applicabili, ma `Int` è più specifico e vince. `area(1.5)` ha un
`Float`, che è sottotipo di `Number` ma non di `Int`, quindi resta un solo metodo applicabile. Se
avessi definito solo `area(n::Number)`, entrambe le chiamate avrebbero usato quello: il dispatch non
sceglie il metodo «migliore», sceglie il più specifico fra quelli che accettano gli argomenti.

Un metodo A è più specifico di B se ogni suo parametro è sottotipo del corrispondente parametro di B
e le firme differiscono.

- Se nessun metodo è applicabile: `Err(:method)`.
- Se più metodi sono massimali: `Err(:ambiguous)`.
- Se il nome è anche un builtin (per esempio `+` sui numeri), si usa il builtin.

Il dispatch si può modellare come una ricerca in due passaggi. Prima si eliminano i metodi con
arità errata o con almeno un argomento che non soddisfa il tipo dichiarato; poi si confrontano
quelli rimasti secondo la relazione di sottotipo, parametro per parametro. Un metodo è più
specifico solo se non è più generale in nessuna posizione e lo è in almeno una. Non basta quindi
scegliere il metodo aggiunto più di recente. Se restano due firme incomparabili, la chiamata è
ambigua e produce `Err(:ambiguous)` invece di dipendere dall'ordine dei file o dall'ordine di
registrazione. Questo comportamento consente di aggiungere metodi specializzati senza riscrivere
la funzione generica, mantenendo però espliciti i casi che non hanno una risposta univoca.

Gli operatori si estendono come funzioni, ridefinendoli:

```triad-full
struct Point
    x::Float
    y::Float
end

function +(a::Point, b::Point)
    Point(a.x + b.x, a.y + b.y)
end

p = Point(1, 2) + Point(3, 4)
println(p.x, " ", p.y)
```

**Output (golden Full):**

```text
4.0 6.0
```

### 7.1 Il tipo di ritorno

`::R` è controllato all'uscita, con la conversione `Int -> Float`. Se il valore non è conforme:
`Err(:type)`. **[Full]**

```triad-full
function metà(n::Number)::Float
    n / 2
end
println(metà(3))
```

**Output (golden Full):**

```text
1.5
```

Il controllo avviene all'uscita perché solo allora il valore esiste; la conversione `Int -> Float`
permette di scrivere `n / 2` senza preoccuparti del tipo letterale del risultato. Se il valore non è
convertibile, ottieni un `Err(:type)` e non un'eccezione: anche una promessa di firma violata entra
nel flusso degli errori come dato.

### 7.2 Funzioni locali

Una `function` definita dentro un'altra funzione è una **chiusura locale**, senza dispatch. **[Full]**

```triad-full
function esterno(x)
    function interno(y)
        y * 2
    end
    interno(x) + 1
end
println(esterno(5))
```

---

<a id="cap-8"></a>

## 8. Lambda, chiusure e scope

### 8.1 Lambda **[Core]**

Una lambda è una funzione senza nome: `x -> x * 2` è un valore, non una definizione. La forma
`(a, b) -> …` dichiara più parametri, e il corpo è un'espressione oppure un blocco. Le lambda si
passano come argomenti e si restituiscono come risultati, ed è così che una funzione di ordine
superiore (cap. 6.3) descrive un'operazione senza eseguirla subito.

```triad
doppio = x -> x * 2
somma = (a, b) -> a + b
applica = f -> f(3)
println(doppio(5), " ", somma(1, 2), " ", applica(x -> x * x))
```

**Output:**

```text
10 3 9
```

Una lambda con corpo a più istruzioni si scrive con `begin … end` o con `function (…) … end`. Le
lambda senza parametri (`() -> …`) **non** sono supportate: usa `function () … end`.

### 8.2 Chiusure

Una lambda cattura l'ambiente in cui è creata. Secondo `SPEC-CORE §5` le variabili catturate sono
**condivise**: le mutazioni sono visibili. **[Core]**

```triad
function add(n)
    x -> x + n
end
f = add(10)
g = add(100)
println(f(5), " ", g(5))

function contatore()
    v = 0
    x -> begin
        v += x
        v
    end
end
acc = contatore()
acc(5)
println(acc(10))
```

**Output:**

```text
15 105
15
```

> **Attenzione.** Il seed Windows cattura **per valore** e copre solo l'ultimo legame del frame: un
> accumulatore come `contatore` può non funzionare sul seed. L'interprete JS e la specifica usano il
> modello condiviso.

Una chiusura non conserva una fotografia del solo testo della lambda: mantiene accesso ai legami
che il suo corpo può leggere. Nel primo esempio la funzione restituita da `add(10)` mantiene il
valore `n = 10` anche dopo che la chiamata a `add` è terminata; `add(100)` crea una chiusura
distinta. Nel contatore, invece, la variabile `v` è un legame condiviso: ogni chiamata aggiorna
lo stesso stato e la successiva lo osserva. È il motivo per cui una chiusura può rappresentare
un piccolo oggetto con stato privato. È anche il motivo per cui il comportamento specifico del
seed Windows va verificato separatamente dall'interprete di riferimento.

La differenza fra cattura condivisa e cattura per valore non è teorica: con il modello condiviso
due chiusure create dallo stesso frame vedono lo stesso stato, con il modello per valore ognuna ha
la sua copia. Quando progetti un oggetto con stato, sappi quale modello stai usando, perché è quello
che decide se due contatori sono indipendenti o no.

### 8.3 Le regole di scope

Le regole seguono un principio unico: lo scope è **lessicale**, cioè conta dove il codice è scritto,
non da dove viene chiamato. Da quel principio discendono le cinque regole che seguono; leggerle in
ordine aiuta a prevedere che cosa modifica davvero un assegnamento.

1. `function`, lambda, `let`, `while`, `for` e le comprehension introducono **ambienti**; un nome è
   visibile nell'ambiente in cui è legato e in quelli interni (scope lessicale), mai in quelli
   esterni.
2. **Dentro una funzione nominata** l'assegnamento lega nel frame locale: una funzione **non
   modifica i globali**.
3. **Dentro una lambda** l'assegnamento a un nome già legato fuori aggiorna quel legame.
4. **Al top level** i cicli possono aggiornare i globali.
5. `let x = …` crea un nuovo `x`: assegnare `x` dentro il `let` non tocca l'`x` esterno.

```triad
x = 1
function f()
    x = 2
    x
end
println(f(), " ", x)
c = 0
function incrementa()
    c += 1
end
incrementa()
println(c)
```

**Output:**

```text
2 1
0
```

Per far uscire un risultato da una funzione, restituiscilo — oppure usa una lista, che è mutabile.

L'esempio mostra il caso più importante: `f` restituisce `2` e il globale `x` resta `1`, perché
l'assegnamento dentro una funzione nominata crea un legame locale. `incrementa` incrementa un
legame locale `c` che nasce e muore nella chiamata, e il globale `c` resta `0`. Non è una svista del
linguaggio: è ciò che rende il comportamento di una funzione indipendente dallo stato globale.
Quando hai bisogno di stato condiviso, le strade sono due — una lista mutabile passata come
argomento (cap. 9) o una chiusura (cap. 8.2) — e in entrambi i casi la condivisione è visibile
nella firma o nella definizione.

---

<a id="cap-9"></a>

## 9. Liste

Una lista è eterogenea, annidabile e **mutabile**. Gli indici partono da **1**. **[Core]**

Una lista si scrive fra parentesi quadre, `[1, 2, 3]`; l'ordine degli elementi è significativo e i
valori possono essere di tipi diversi. La mutabilità è la proprietà che distingue la lista da un
record: la lista cresce e cambia, e più nomi possono osservare la stessa lista. È la struttura
d'appoggio di quasi tutto il codice Core, dai record alle code, dagli ambienti ai parser.

```triad
xs = [1, 2, 3]
println(xs[1], " ", length(xs))
push!(xs, 4)
xs[1] += 100
println(xs)
alias = xs
push!(alias, 5)
println(xs)
```

**Output:**

```text
1 3
[101, 2, 3, 4]
[101, 2, 3, 4, 5]
```

`push!` **muta** la lista e la restituisce. Le liste sono riferimenti: due nomi possono indicare la
stessa lista, come si vede sopra.

Il fatto che `push!` restituisca la lista, e non `nothing`, è una scelta comoda: permette di
concatenare l'aggiunta con un'altra operazione, ma rende anche possibile scrivere `xs = push!(xs, 4)`,
che è ridondante ma innocuo. L'assegnamento a un elemento (`xs[1] += 100`) funziona anche con gli
operatori composti: il lato sinistro viene valutato una volta sola, quindi l'indice non viene
calcolato due volte.

Una lista è un oggetto mutabile; una variabile contiene un riferimento a quell'oggetto. Se `ys =
xs`, i due nomi permettono di raggiungere la stessa lista: `push!(ys, valore)` e `xs[i] = valore`
sono osservabili anche leggendo `xs`. Se invece scrivi `ys = [1, 2]`, hai sostituito soltanto il
legame `ys`; `xs` continua a riferirsi alla lista precedente. Questa distinzione spiega perché
assegnare una lista non ne crea automaticamente una copia e perché gli argomenti lista possono
essere usati per condividere stato tra funzioni.

La convenzione 1-based è coerente con esempi e specifica: per visitare `n` elementi, il contatore
inizia da 1 e la condizione tipica è `i <= length(xs)`. In un ciclo, aggiornare il contatore
dopo aver letto l'elemento evita di saltare il primo elemento; aumentarlo in ogni iterazione
assicura che la condizione prima o poi diventi falsa. Sul seed Windows la funzione ausiliaria
sperimentale `get(xs, i)` è diversa e 0-based: non va usata come se fosse la semantica standard
delle liste.

La scelta di partire da 1 non è un dettaglio estetico: rende coerente l'accesso con le posizioni
umane e con i range, e permette di usare `length(xs)` come ultimo indice valido. Il prezzo è che un
indice calcolato pensando allo 0 va corretto; l'errore tipico è `xs[0]`, che non restituisce un
valore ma produce un errore. Un indice fuori intervallo non è `nothing`: in Core il programma
termina, in Full arriva un `Err(:bounds)` da gestire. Per questo, quando l'indice è calcolato, è
buona norma controllarlo prima con `1 <= i && i <= length(xs)`.

La somma degli elementi con un ciclo esplicito:

```triad
xs = [101, 2, 3, 4, 5]
tot = 0
i = 1
while i <= length(xs)
    tot += xs[i]
    i += 1
end
println(tot)
```

**Output:**

```text
115
```

Il ciclo mostra la forma canonica di attraversamento in Core: contatore da 1, condizione
`i <= length(xs)`, lettura di `xs[i]`. `length` viene ricalcolata a ogni iterazione, quindi se il
corpo del ciclo cambia la lista il confine si sposta; mutare la lista mentre la si attraversa è
possibile, ma va fatto con consapevolezza. Aggiungere elementi allunga la lista e il ciclo li
visiterà; in Full, dove esistono `pop!` e `append!`, togliere elementi mentre l'indice cresce fa
saltare quelli successivi.

In Full esistono anche `reverse`, `sort`, `sum`, `first`, `last`, `rest`, `pop!`, `append!`, `vcat`,
`collect` e l'operatore `x in xs`. Nessuno di questi nomi esiste in Core: se ti servono, li scrivi a
mano con `while` e `push!`, come nel capitolo 22.1. Non è una perdita: gli algoritmi scritti a mano
mostrano che cosa fanno e quanto costano, e in un bootstrap questa trasparenza vale più della
brevità.

---

<a id="cap-10"></a>

## 10. Stringhe, simboli e conversioni

Le stringhe in Triad sono valori immutabili e le operazioni sono poche, volutamente esplicite: si
concatena con `*`, si misura la lunghezza in byte, si converte con funzioni dal nome chiaro. La
tabella raccoglie le operazioni disponibili in Core; dove Full si comporta diversamente lo trovi
indicato sotto, con il perché.

| operazione | significato |
|---|---|
| `a * b` | concatenazione di stringhe |
| `length(s)` | numero di **byte** UTF-8 (`length("é") == 2`) |
| `string(x)` | rappresentazione testuale di qualsiasi valore (`string(:a) == "a"`, `string([1, 2]) == "[1, 2]"`) |
| `Int(s)` | da stringa a intero (`Int("42") == 42`) |
| `Symbol(s)` | da stringa a simbolo (`Symbol("ciao") == :ciao`) |
| `typeof(x)` | in Core, il nome del tipo come simbolo (cap. 2.1) |

```triad
nome = "Triad"
saluto = "ciao " * nome
println(saluto, " (", length(saluto), " byte)")
println("risposta: " * string(40 + 2))
println(Int("41") + 1, " ", Symbol("bob"), " ", string(true))
```

**Output:**

```text
ciao Triad (10 byte)
risposta: 42
42 bob true
```

La prima cosa da notare è che `length(saluto)` vale `10`: "ciao Triad" ha dieci caratteri e dieci
byte, perché l'alfabeto latino occupa un byte per carattere. Con `"é"` il conto cambia
(`length("é") == 2`), e con un'emoji cambia ancora: la lunghezza è una proprietà della codifica
UTF-8, non del testo come lo vedi. È il motivo per cui in Triad non si indicizza una stringa come
una lista: `s[1]` restituirebbe un byte, non un carattere, e sarebbe una trappola silenziosa. Per
lavorare sui singoli byte servono i primitivi di bootstrap (cap. 21).

La concatenazione con `*` non modifica `saluto`: crea una nuova stringa, e la vecchia resta
disponibile a chiunque la stia usando. Questa immutabilità rende le stringhe sicure da passare alle
funzioni, ma significa anche che ogni `*` alloca una stringa nuova: in un ciclo lungo il costo
cresce con la stringa, non con il numero di giri.

`string(x)` e `Symbol(s)` vanno tenute distinte: `string` trasforma un valore in testo, `Symbol`
trasforma testo in un'identità. `string(42)` produce la stringa `"42"`; `Symbol("42")` produce un
simbolo, che è un valore completamente diverso. `Int("42")` fa il cammino inverso: è una
conversione, non una valutazione, quindi il testo deve essere un intero scritto in decimale. Che
cosa succeda con un testo non numerico non è fissato dallo standard: l'interprete di riferimento
restituisce `0`, ma è un comportamento da verificare prima di contarci.

In Full le stringhe hanno in più l'interpolazione (cap. 1.3) e `repr`, che produce una
rappresentazione pensata per essere riletta; in Core `string` è l'unica porta dal valore al testo,
e non esiste l'interpolazione.

---

<a id="cap-11"></a>

## 11. Errori come dati

Questa è una delle idee portanti di Triad: **l'errore è un valore**, non un'eccezione che
 interrompe il programma.

### 11.1 La forma `Err`

Un errore è un valore `Err` con tre campi:

- `kind::Symbol` — la categoria, su cui si può fare dispatch;
- `msg::String` — il messaggio;
- `data` — un valore qualsiasi, spesso un record `Info(...)` con i dettagli.

**[Full]**

I tre campi separano tre domande diverse: *che cosa* è successo (`kind`), *come raccontarlo* (`msg`) e
*quali informazioni servono per reagire* (`data`). Tenerle separate è ciò che permette di scrivere
codice che decide in base alla categoria senza analizzare il testo del messaggio, che è pensato per
una persona e non per un programma.

```triad-full
e = err(:mio, "ops", 42)
println(e.kind, " ", e.msg)
println(iserr(e))
```

### 11.2 Produrre e propagare

La tabella riassume i costrutti che creano, propagano o osservano un errore: leggerla dall'alto in
basso è anche l'ordine in cui un errore attraversa un programma, dal punto in cui nasce al punto in
cui qualcuno decide che cosa farne.

| costrutto | effetto |
|---|---|
| `err(:kind, "msg"[, data])` | costruisce un `Err` **senza** sollevarlo |
| `throw(e)`, `error("msg")` | solleva (`error` produce `Err(:error, …)`) |
| `try b catch e h end` | se `b` solleva, `e` è legato all'`Err` e si valuta `h` |
| `try b end` | **l'errore diventa il valore** dell'espressione |
| `iserr(x)` | controlla se `x` è un `Err` |

Tutti i fallimenti del linguaggio — divisione intera per zero, `sqrt(-1.0)`, indici fuori range,
nessun metodo applicabile — arrivano come `Err` e **mai** come fallimenti fatali. **[Full]**

```triad-full
e = try div(1, 0) end
println(e.kind)
println(iserr(e))

r = try div(10, 2) catch err; 0 end
println(r)
```

**Output (golden Full):**

```text
domain
true
5
```

È utile distinguere tre momenti: **produrre**, **propagare** e **gestire** un errore. `err(...)`
costruisce un dato e non interrompe nulla; un'operazione che fallisce produce un `Err` secondo la
specifica; `try` stabilisce il punto in cui quel valore viene osservato o recuperato. In Full,
`try espressione end` restituisce l'errore come valore, mentre `try ... catch nome ... end`
permette al ramo di recupero di esaminare la categoria, il messaggio o i dettagli. Se l'errore
non viene gestito, arriva al livello superiore e diventa un codice di uscita non riuscito: "errore
come dato" non significa che il programma continui automaticamente dopo qualunque operazione.

Il tipo del dato permette di scrivere politiche diverse per categorie diverse. Per esempio, un
errore `:bounds` può essere presentato come input non valido, mentre `:method` può indicare che
manca un'implementazione. Separare la categoria stabile (`kind`) dal testo leggibile (`msg`) evita
di dover analizzare stringhe di diagnostica per decidere come reagire.

### 11.3 Le categorie di errore

La categoria è la parte stabile dell'errore: è un simbolo, il programma può confrontarlo e fare
dispatch su di esso. La tabella elenca le categorie che lo standard definisce; i messaggi che vedi
stampati sono invece dell'implementazione e possono cambiare.

| kind | quando |
|---|---|
| `:syntax` | errore di parse; `data` contiene `line`, `col` e `incomplete` |
| `:undef` | nome, funzione, macro o predicato non definito |
| `:type` | tipo sbagliato (campi, ritorno, `::`, condizioni non `Bool`) |
| `:method` | nessun metodo applicabile; `data.types` contiene i tipi degli argomenti |
| `:ambiguous` | più metodi ugualmente specifici |
| `:field`, `:bounds`, `:domain` | campo inesistente, indice fuori range, errore matematico |
| `:instantiation` | variabile logica non legata dove serve un valore |
| `:contract` | `requires`/`ensures` violata (cap. 12) |
| `:budget` | passi esauriti (cap. 13) |
| `:effect` | effetto non dichiarato (cap. 15) |
| `:host` | qualsiasi altro errore dell'interprete |

Un errore non gestito al top level interrompe il programma: il messaggio riporta la riga
dell'istruzione (`riga 12: …`) e il codice di uscita è `1`.

### 11.4 In Core: errori come liste taggate

Core non ha `try`/`catch` né il tipo `Err`: un errore **termina il processo** con exit code `1` e un
messaggio diagnostico su stderr. Ma il pattern "errore come dato" si può già scrivere, ed è
esattamente così che S1 implementerà Full. La convenzione è `[:Err, kind, msg]`. **[Core]**

```triad
err(kind, msg) = [:Err, kind, msg]
is_err(v) = typeof(v) == :List && length(v) == 3 && v[1] == :Err

function div_intera(a, b)
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

r = div_intera(7, 0)
if is_err(r)
    println("errore ", r[2], ": ", r[3])
end
println(div_intera(17, 5))
```

**Output:**

```text
errore domain: divisione per zero
3
```

Nota che `&&` cortocircuita: `v[1]` viene valutato solo se `v` è una lista di 3 elementi.

Il perché di una lista taggata è semplice: in Core non esiste un tipo `Err`, ma esistono le liste e i
simboli, e una lista con il tag in prima posizione può rappresentare qualunque record. `is_err` è
quindi una convenzione, non una garanzia di tipo: chiunque può costruire una lista `[:Err, ...]` con
campi sbagliati, e chi la riceve deve controllare ciò che gli serve. È lo stesso patto che gli
interpreti in `selfhost/` usano per le struct (cap. 2.3). La parte importante non è il contenitore,
è l'idea: un fallimento è un valore che viaggia come gli altri, e chi lo riceve può scegliere se
gestirlo, trasformarlo o restituirlo.

---

<a id="cap-12"></a>

## 12. Contratti

Un contratto è una precondizione (`requires`) o una postcondizione (`ensures`) dichiarata nel corpo
di una funzione. **[Full]**

Un contratto non è un commento: è una condizione eseguita, e una sua violazione è un errore come
dato. Serve a rendere esplicito che cosa una funzione pretende da chi la chiama e che cosa promette
a chi la riceve, senza affidare il patto alla buona volontà di chi legge. Non dimostra che la
proprietà valga per ogni input possibile — la controlla per le esecuzioni che avvengono — ma
trasforma una violazione silenziosa in un `Err` che riporta quale clausola è fallita.

```triad-full
function safe_div(a::Number, b::Number)::Float
    requires b != 0
    ensures abs(result * b - a) < 1e-9
    a / b
end
```

- `requires c` viene controllata **nel punto in cui compare**: per convenzione all'inizio del corpo.
- `ensures c` viene registrata e controllata all'uscita della funzione, con `result` legato al
  valore restituito, **dopo** il controllo del tipo di ritorno.
- Una violazione produce
  `Err(:contract, "requires violata in safe_div: b != 0", Info(fn, clause, cond[, result]))`.
  `cond` contiene il **codice** della condizione: è un dato, si può ispezionare.
- Le condizioni sono **pure**: un effetto dentro un contratto dà `Err(:effect)`.
- Al top level `requires c` funziona come un'asserzione.
- `ensures` ha senso solo dentro una `function`: usa `result`, che esiste soltanto quando la funzione
  sta per restituire un valore. Fuori da una funzione non c'è un risultato a cui riferirsi.

```triad-full
println(safe_div(6, 3))

e = try safe_div(1, 0) end
println(e.kind)
println(e.data.clause)
println(e.data.fn)
```

**Output (golden Full):**

```text
2.0
contract
requires
safe_div
```

Nell'esempio `safe_div(6, 3)` produce `2.0`: il tipo di ritorno `Float` converte il risultato e lo
espone come promessa mantenuta. `safe_div(1, 0)` non arriva mai a dividere: la precondizione viene
controllata all'inizio, l'errore è già un valore e il programma continua. Il messaggio dell'errore
porta con sé `clause = requires` e `fn = safe_div`, quindi chi chiama può distinguere una violazione
d'ingresso da una promessa d'uscita non mantenuta senza leggere il testo.

La sequenza di controllo è significativa: il corpo valuta le clausole nell'ordine in cui
compaiono; le precondizioni vengono verificate nel punto in cui sono dichiarate, mentre le
postcondizioni vengono conservate fino al completamento della funzione. Il valore finale viene
prima sottoposto al vincolo di ritorno e poi esposto come `result` alle clausole `ensures`.
Un errore di contratto include quale clausola è fallita e il codice che la rappresenta, così chi
chiama può distinguere una violazione d'ingresso da una promessa d'uscita non mantenuta. I
contratti controllano un'invariante osservabile, ma non provano matematicamente che valga per ogni
input possibile: vengono valutati per le esecuzioni che avvengono.

---

<a id="cap-13"></a>

## 13. Budget

Un **budget** limita quanti passi il programma può consumare. Un passo è una chiamata, un'iterazione
di ciclo o un passo di risoluzione. Quando il budget si esaurisce, **il valore del `with` è
`Err(:budget)`**: il programma non si blocca e non viene interrotto. **[Full]**

```triad-full
r = with budget(steps = 10_000)
    while true end
end
println(r.kind)
```

**Output (golden Full):**

```text
budget
```

I budget si annidano e vale il più stretto. Un `with` converte in valore **solo** l'esaurimento del
proprio budget, mentre quello di un budget esterno continua a propagarsi. `solve … steps N` è il
budget specifico di una query.

Il budget misura il **lavoro**, non il tempo: due esecuzioni dello stesso programma con lo stesso
budget consumano gli stessi passi, quindi il risultato è riproducibile. Un timeout basato
sull'orologio non lo sarebbe e renderebbe i test instabili. Per questo il limite è parte del
linguaggio e non dell'ambiente: un programma può decidere che cosa fare quando lo esaurisce, e
quella decisione è anch'essa codice.

Il motore logico usa uno stack esplicito: la ricorsione infinita, anche sinistra, finisce in
`Err(:budget)` e **non** in uno stack overflow.

Il limite è parte del risultato del calcolo perché il programma può scegliere come trattarlo:
mostrare una diagnosi, ridurre il problema o restituire un risultato parziale solo se la propria
logica lo consente. Non confondere `limit n`, che limita il numero di soluzioni restituite,
`depth d`, che taglia i rami oltre una profondità, e `steps s`, che limita il lavoro complessivo.
Una query che ha esplorato lo spazio previsto senza trovare soluzioni restituisce una lista vuota;
una query fermata dall'esaurimento dei passi segnala invece `Err(:budget)`.

---

<a id="cap-14"></a>

## 14. Tracce

La traccia di un calcolo è un **valore**, non output stampato. **[Full]**

```triad-full
fib(n::Int) = n < 2 ? n : fib(n - 1) + fib(n - 2)

t = with trace
    fib(3)
end
println(t.result)
println(length(t.trace))
```

**Output (golden Full):**

```text
2
10
```

`fib(3)` effettua 5 chiamate (`fib(3)`, `fib(2)`, `fib(1)`, `fib(0)`, `fib(1)`): la traccia registra
**due eventi per ogni chiamata**, `:call` e `:exit`, quindi 10 eventi. Per `fib(5)` sono 15 chiamate
e 30 eventi — è il valore atteso dal caso di conformance `garanzie_core`.

`with trace … end` restituisce `Traced(result, trace)` con gli eventi `:call` e `:exit` di ogni
funzione generica chiamata nel corpo. `solve … trace` restituisce `Traced(result, trace)` dove
`result` è la lista delle soluzioni e gli eventi sono le porte del modello a scatole di Byrd
(`call`, `exit`, `redo`, `fail`) più `depth`, quando un ramo viene tagliato da `depth`.

Gli eventi sono record: si filtrano e si contano come ogni altro valore.

Raccogliere una traccia non è gratis: ogni evento è un valore allocato, e su calcoli grandi la
traccia può pesare più del risultato. Chiedila quando ti serve, non come impostazione predefinita.

Una traccia aggiunge una dimensione temporale ai dati di debug: due esecuzioni possono avere lo
stesso risultato ma seguire percorsi diversi, per esempio se una query ha dovuto provare e
scartare alternative. Invece di scrivere log dentro ogni funzione, il chiamante racchiude il
calcolo in `with trace` oppure chiede `trace` a `solve`; il risultato e gli eventi vengono
restituiti insieme. Questo mantiene separati il risultato applicativo e la diagnostica, e consente
di analizzare la traccia con gli stessi strumenti usati per liste e record.

### Glossario degli eventi di traccia (porte di Byrd)

Quando si usa `solve … trace`, ogni passo della ricerca produce un evento che registra **a che
riferimento** (quale goal, quale clausola, quali variabili logiche) si sta lavorando. Le quattro
porte del modello a scatole di Byrd sono:

| porta | quando si verifica | significato |
|---|---|---|
| `:call` | si entra in un goal | inizio della valutazione della clausola candidata |
| `:exit` | unificazione **riuscita** | il goal è dimostrato: è il "success" della ricerca |
| `:redo` | backtracking | si torna indietro per cercare un'altra soluzione |
| `:fail` | nessuna clausola applicabile | il goal **fallisce**: nessuna soluzione per quel ramo |

Note importanti:

- **"success" e "fail" non sono esiti generici**: sono le porte `:exit` e `:fail` della traccia,
  riferite al goal/clausola in corso. Il fallimento di un goal non è un'eccezione: si manifesta
  come **lista di soluzioni vuota** nel `result` di `Traced(result, trace)`.
- **`depth`** appare come evento aggiuntivo quando un ramo viene tagliato dal limite di profondità
  (`solve … depth N`), segnalando che la ricerca è stata interrotta prima di un `:exit`/`:fail`.
- Gli eventi sono **record ordinari**: si filtrano (`[e for e in t.trace if e.port == :fail]`),
  si contano (`length`), si ispezionano (`e.args`, `e.depth`) come ogni altro valore Triad.
- Il riferimento di ogni evento è il **goal corrente e le variabili logiche** (`?x`, `?y`, …)
  coinvolte in quel passo: leggendo la traccia si ricostruisce *quale* alternativa è stata
  provata e *perché* è fallita.

```triad-full
# Conta i fallimenti di una ricerca
t = solve path(:a, :c) trace
fails = [e for e in t.trace if e.port == :fail]
println(length(fails))
```

```triad-full
fib(n::Int) = n < 2 ? n : fib(n - 1) + fib(n - 2)
t = with trace
    fib(3)
end
println([e.args for e in t.trace if e.port == :call])
```

**Output (golden Full):**

```text
[[3], [2], [1], [0], [1]]
```

---

<a id="cap-15"></a>

## 15. Effetti dichiarati

Le funzioni sono **pure per impostazione predefinita**. Gli effetti si dichiarano nella firma, dopo i
parametri. **[Full]**

«Puro per impostazione predefinita» è una scelta di sicurezza: se dimentichi una dichiarazione, la
funzione non può fare più del previsto, e l'errore arriva quando l'effetto viene tentato. In questo
senso un effetto è una **capacità**, non un'annotazione descrittiva: `!io` dice che la funzione ha il
permesso di stampare, e il controllo dinamico verifica il permesso al momento dell'esecuzione.

```triad-full
function saluta(nome::String) !io
    println("ciao, ", nome)
end

function impara(x) !state
    fact visto($x)
end
```

| effetto | operazioni |
|---|---|
| `io` | `println`, `print` |
| `state` | `fact`/`rule` eseguiti dentro una funzione (modificano la knowledge base) |

Il controllo è **dinamico**. Una funzione viene eseguita solo con gli effetti che dichiara, e solo
se il chiamante li permette. Se una funzione pura chiama `println`, o chiama una funzione `!io`, si
ottiene `Err(:effect)`; `data` contiene `fn`, `caller` e `missing`.

La purezza per impostazione predefinita significa che una funzione può calcolare e restituire valori
senza modificare lo stato esterno né produrre I/O; non significa che il runtime analizzi
staticamente ogni possibile percorso prima dell'esecuzione. Il controllo dinamico osserva gli effetti mentre
avvengono e li confronta con il contesto attivo. Le mutazioni locali e quelle di liste non sono
classificate come effetti dichiarati in questa specifica: `!state` si riferisce alla modifica
della knowledge base tramite `fact` e `rule`, non a qualunque assegnamento.

- Il top level permette tutti gli effetti.
- Le lambda ereditano gli effetti del contesto in cui vengono eseguite.
- Macro e contratti sono puri.
- Leggere la knowledge base (`solve`, chiamare un predicato) è puro.
- La mutazione locale di dati (`push!` su una lista, assegnamento a variabili locali) **non** è un
  effetto: modifica solo valori raggiungibili dall'ambiente locale.

```triad-full
function rumorosa()
    println("faccio rumore")
end

function tranquilla()
    rumorosa()
end

e = try tranquilla() end
println(e.kind)
```

**Output (golden Full):**

```text
effect
```

`rumorosa` non dichiara `!io`, quindi il suo `println` è un effetto non permesso; `tranquilla` la
chiama da un contesto puro e riceve lo stesso errore. `data` contiene `fn` (chi ha tentato
l'effetto), `caller` (da dove) e `missing` (quale effetto mancava): sono le tre informazioni che
servono per correggere la firma. Il controllo è dinamico, quindi un ramo che non viene eseguito non
produce errori di effetto, e non c'è un'analisi statica che ti avvisa prima: la dichiarazione è un
patto che il runtime verifica mentre il codice gira.

---

<a id="cap-16"></a>

## 16. Logica

Triad integra la programmazione logica **nella sintassi a blocchi**: i fatti e le regole sono
costrutti di primo livello, non un linguaggio incorporato. **[Full]**

Fatti e regole formano la **knowledge base**, che il programma costruisce mentre gira. Un fatto
asserisce che una relazione vale; una regola dice che vale a condizione che valgano altre cose.
`solve` pone una domanda alla base e restituisce le risposte come valori: non c'è un interprete
separato da invocare, perché la logica sta dentro la stessa sintassi e lo stesso motore del resto
del linguaggio.

### 16.1 Fatti, regole, termini

```triad-full
fact parent(:tom, :bob)
fact parent(:bob, :jim)

rule ancestor(?a, ?d) :- parent(?a, ?d)
rule ancestor(?a, ?d) :- parent(?a, ?x), ancestor(?x, ?d)
```

Dentro un termine:

- `:atomo` è un simbolo; `?x` è una variabile logica; numeri, stringhe e liste sono se stessi;
- `f(t1, t2)` è un termine composto. Anche `?x + 1` è un termine (`+(?x, 1)`) e **non viene
  valutato**;
- un **nome nudo** è un valore dell'ambiente corrente, letto al momento in cui viene eseguito `fact`,
  `rule` o `solve`: `chi = :bob; solve parent(chi, ?c)`;
- `$(espr)` inserisce esplicitamente un valore calcolato: `fact eta(:bob, $(2026 - 1975))`;
- `[a, b]` e `[?h | ?t]` sono liste e forme che unificano con le liste;
- il nome di una struct con argomenti, come `Point(?x, ?y)`, unifica con le istanze di quella struct.

Le variabili di una clausola vengono **rinominate a ogni uso** (standardizzazione a parte).
L'unificazione fa l'**occurs-check**: `solve ?x = f(?x)` non ha soluzioni.

Per leggere una query occorre distinguere i **termini** dai normali valori calcolati. Un simbolo
come `:alice` è un termine costante; `?who` è una variabile logica che cerca un valore; una forma
come `parent(:alice, ?who)` descrive un goal da dimostrare. Le variabili logiche non sono variabili
locali Triad assegnate con `=`: il motore cerca associazioni che rendano compatibile il goal con
fatti e regole. In particolare, `?x + 1` dentro un termine non si calcola da sé; l'operatore `is`
esprime esplicitamente la richiesta di valutare un'espressione usando variabili già legate.

L'unificazione costruisce progressivamente un insieme di associazioni. Se si confrontano
`parent(:alice, ?who)` e `parent(:alice, :bob)`, gli argomenti corrispondenti coincidono e il
motore può legare `?who` a `:bob`; se un argomento è diverso, quel tentativo fallisce. Quando più
clausole possono soddisfare un goal, il backtracking torna al punto di scelta e prova la clausola
successiva. Ogni soluzione è una fotografia delle variabili richieste dalla query; una lista
vuota significa "nessuna dimostrazione trovata", non un errore di esecuzione. I limiti `limit`,
`depth` e `steps` controllano quante soluzioni o quanti passi di ricerca sono ammessi.

### 16.2 I goal

Un goal è la descrizione di ciò che vuoi che sia vero: il motore cerca legami per le variabili che
lo rendono dimostrabile. La tabella raccoglie le forme che un goal può assumere; le prime due sono
le più importanti, perché `p(t…)` è l'unico modo per interrogare la knowledge base e la congiunzione
è l'unico modo per chiedere più cose insieme.

| goal | significato |
|---|---|
| `p(t…)` | predicato della knowledge base, risolto con SLD e backtracking, clausole in ordine |
| `g1 && g2`, `(g1, g2)` | congiunzione; nelle `rule` anche con `,` |
| `g1 \|\| g2` | disgiunzione |
| `!g`, `not(g)` | negazione per fallimento |
| `not(b)` *fuori* da un goal | è una funzione: nega un `Bool` (`not(true) == false`) |
| `a = b` | unificazione |
| `?y is espr` | valuta `espr` (le variabili devono essere legate) e unifica con `?y` |
| `a < b`, `==`, `!=`, `<=`, `>`, `>=` | confronto tra valori, valutati |
| `f(t…)` con `f` funzione Triad | chiama la funzione con gli argomenti valutati; deve restituire `Bool` |
| `true`, `false` | successo, fallimento |

Un predicato senza clausole con quell'arità, che non sia nemmeno una funzione, dà
`Err(:undef, "predicato sconosciuto: p/2")`. Una variabile non legata dentro un'espressione dà
`Err(:instantiation)`.

### 16.3 `solve` è un valore

`solve` **restituisce una lista** di `Solution`. Non stampa nulla: è un valore come un altro.

```triad-full
fact parent(:alice, :bob)
fact parent(:alice, :carol)
fact parent(:bob, :dave)

rule grandparent(?x, ?z) :- parent(?x, ?y), parent(?y, ?z)

sols = solve grandparent(:alice, ?who) limit 5
println(sols)
println(sols[1].who)
println(length(sols))
```

**Output (golden Full):**

```text
[{who = :dave}]
dave
1
```

Ogni soluzione lega le variabili della query **non anonime**, nell'ordine in cui compaiono. Le
variabili rimaste libere restano `?x#n`. `vars(sol)` restituisce i nomi legati.

`Solution` è un record con i nomi della query: `sols[1].who` legge il legame, e `vars(sol)` elenca i
nomi. Il risultato di `solve` è una lista normale, quindi puoi filtrare, ordinare o contare le
soluzioni con gli strumenti del resto del linguaggio: la logica non produce un formato speciale,
produce valori.

Opzioni di `solve`:

- `limit n` — al massimo `n` soluzioni;
- `depth d` — i rami più profondi di `d` vengono tagliati (falliscono);
- `steps s` — al massimo `s` passi di risoluzione, altrimenti `Err(:budget)`; il valore predefinito
  è `1 000 000`;
- `trace` — vedi cap. 14.

Le opzioni non sono equivalenti: `limit` ferma la ricerca quando hai abbastanza soluzioni, `depth`
taglia i rami troppo profondi e li considera falliti, `steps` limita il lavoro complessivo e segnala
l'esaurimento con `Err(:budget)`. Distinguerle conta perché solo l'ultima è un errore: le altre due
producono un risultato parziale ma legittimo.

### 16.4 Un predicato usato come funzione

Chiamare un predicato dove ci si aspetta un valore restituisce un `Bool`: dice se il goal è
dimostrabile.

```triad-full
if grandparent(:alice, :dave)
    println("alice è nonna di dave")
end
```

### 16.5 Esempi

Percorso con costo:

```triad-full
fact edge(:a, :b, 2)
fact edge(:b, :c, 3)
rule path(?x, ?y, ?c) :- edge(?x, ?y, ?c)
rule path(?x, ?y, ?c) :- edge(?x, ?z, ?c1), path(?z, ?y, ?c2), ?c is ?c1 + ?c2
println((solve path(:a, :c, ?costo))[1].costo)
```

**Output (golden Full):**

```text
5
```

Il costo si accumula per composizione: `path(:a, :c, ?costo)` dimostra il goal unendo il fatto
`edge(:a, :b, 2)` alla regola ricorsiva; il secondo passo trova `edge(:b, :c, 3)` e `?c is ?c1 + ?c2`
calcola `2 + 3`. `is` è necessario perché `?c1 + ?c2` dentro un termine resterebbe un termine non
valutato; `is` è il punto in cui la logica chiede al valutatore di fare l'aritmetica.

Append in stile Prolog:

```triad-full
rule app([], ?l, ?l)
rule app([?h | ?t], ?l, [?h | ?r]) :- app(?t, ?l, ?r)
println((solve app([1, 2], [3], ?r))[1].r)
println(length(solve app(?a, ?b, [1, 2, 3])))
```

**Output (golden Full):**

```text
[1, 2, 3]
4
```

`app([1, 2], [3], ?r)` unifica la lista concatenata e restituisce `[1, 2, 3]`. La seconda query non
fissa il risultato ma chiede tutte le coppie di liste che, concatenate, danno `[1, 2, 3]`: sono
quattro, perché il primo pezzo può essere la lista vuota, `[1]`, `[1, 2]` o `[1, 2, 3]`. Il numero
non è un errore: è il motore che enumera le alternative, e `limit` serve proprio a fermarlo quando
non ti interessano tutte.

Negazione per fallimento:

```triad-full
fact parent(:tom, :bob)
persone = [:tom, :bob]
foglie = filter(p -> !parent(p, ?_), persone)
println(foglie)
```

**Output (golden Full):**

```text
[:bob]
```

`!parent(p, ?_)` è la negazione per fallimento: `p` passa il filtro solo se il goal `parent(p, ?_)`
non è dimostrabile. `:tom` ha un figlio, quindi non passa; `:bob` non ne ha, quindi passa. La
variabile anonima `?_` è quella che non compare nel risultato: ogni sua occorrenza è una variabile
nuova, così non devi inventare un nome per una variabile che non ti interessa.

---

<a id="cap-17"></a>

## 17. Codice come dato

Il parser produce **un solo tipo di nodo**, `Node(head, args)`. È lo stesso albero che il kernel
esegue, che `:( … )` restituisce come valore e che `triad --tree` stampa come S-expression.
**[Full]**

L'idea che sta dietro è radicale: il programma non è una sequenza di comandi che il valutatore
interpreta a mano, è un **dato**. Il parser produce l'albero, il valutatore esegue l'albero, le
macro ricevono pezzi di albero e ne restituiscono altri. Poiché esiste un solo tipo di nodo, chi
scrive codice che manipola il programma non deve conoscere dieci rappresentazioni diverse: conosce
`Node(head, args)` e basta.

La tabella mostra come le forme che hai già incontrato diventano nodi: leggila come un dizionario
tra la sintassi che scrivi e il dato che il programma può ispezionare.

| sintassi | nodo |
|---|---|
| `f(a, b)`, `a + b` | `(call f a b)`, `(call + a b)` |
| `a && b`, `a \|\| b` | `(and a b)`, `(or a b)` |
| `x = e` | `(assign x e)` |
| `:alice` | `(sym alice)` |
| `a.x`, `xs[i]` | `(dot a x)`, `(index xs i)` |
| `[a, b]`, `[h \| t]` | `(list a b)`, `(cons (list h) t)` |
| `[e for x in xs if c]` | `(comprehension e x xs c)` |
| `x -> e` | `(lambda (tuple x) e)` |
| `x::T` | `(typed x T)` |
| `"a $x"` | `(string "a " x)` |
| `if c a else b end`, `c ? a : b` | `(if c (block a) (block b))` |
| `while`, `for`, `let`, `begin` | `(while c body)`, `(for x iter body)`, `(let (tuple …) body)`, `(block …)` |
| `function f(a::T)::R !io … end` | `(function f (tuple (typed a T)) R (tuple io) body)` |
| `struct P; x::Float; end` | `(struct P (tuple (typed x Float)))` |
| `macro m(a) … end`, `@m(e)` | `(macro m (tuple a) body)`, `(macrocall m e)` |
| `:(e)`, `quote … end`, `$e` | `(quasi e)`, `(quasi (block …))`, `(unquote e)` |
| `fact t`, `rule h :- g1, g2` | `(fact t)`, `(rule h g1 g2)` |
| `solve g limit 5 trace` | `(solve g (tuple (assign limit 5) (assign trace true)))` |
| `try b catch e h end` | `(try b e h)` |
| `with budget(steps = N), trace … end` | `(with (tuple (call budget (assign steps N)) trace) body)` |

### 17.1 Quote, unquote, eval

```triad-full
c = :(a.x + f(b, 2))
println(c.head)
println(sexpr(c))

n = 7
quadrato = :($n * $n)
println(eval(quadrato))
```

**Output (golden Full):**

```text
call
(call + (dot a x) (call f b 2))
49
```

Dentro un quote, `$x` e `$(e)` inseriscono il **valore** di un'espressione: se è codice viene
innestato, se è un numero o una lista diventa una costante, se è un Symbol diventa un identificatore.
`eval(c)` esegue codice **nello scope globale**. Gli altri builtin del gruppo "codice" sono `parse`,
`unparse`, `sexpr`, `Expr` e `gensym`.

Quotare e valutare sono operazioni opposte ma non intercambiabili. Il parser normalmente trasforma
il sorgente in un albero e il valutatore esegue quell'albero; `:(...)` ferma il processo al
confine tra le due fasi e restituisce l'albero come valore `Expr`. `eval(expr)` lo consegna di
nuovo al valutatore, nello scope globale. L'unquote `$x` dentro una quote inserisce il valore
calcolato di `x` nel nuovo albero: se è un `Expr`, innesta codice; se è un numero, crea un nodo
costante. `sexpr` serve a ispezionare la struttura e non esegue il programma.

L'esempio mostra il viaggio completo: `:(a.x + f(b, 2))` restituisce un `Expr` senza eseguirlo,
`c.head` vale `call` e `sexpr` lo scrive in forma lineare. `:($n * $n)` con `n = 7` non crea una
funzione: crea un albero che contiene già la costante `7`, e `eval` lo esegue. La differenza fra
`eval` e una chiamata normale è lo scope: `eval` parte dallo scope globale, quindi non vede le
variabili locali di chi lo invoca. È il motivo per cui `eval` si usa per costruire codice completo,
non per leggere valori del contesto.

---

<a id="cap-18"></a>

## 18. Macro

Una macro riceve gli argomenti **come codice**, non valutati, e restituisce codice, che viene poi
eseguito al posto della chiamata `@nome(...)` nello scope del chiamante. **[Full]**

La differenza rispetto a una funzione non è solo tecnica: una funzione riceve valori già calcolati,
quindi non può decidere se valutare un argomento una volta, due volte o mai. Una macro riceve la
forma sorgente, e questa è la sua unica vera ragione d'essere: si usa quando il comportamento
dipende dal codice, non dal valore degli argomenti.

```triad-full
macro unless(c, body)
    :(if !$c; $body; end)
end

macro swap(a, b)
    t = gensym(:tmp)
    quote
        $t = $a
        $a = $b
        $b = $t
    end
end

x = 1
y = 2
@swap(x, y)
println(x, " ", y)
```

**Output (golden Full):**

```text
2 1
```

L'espansione è **pura** (§15) e **non è igienica**: per i nomi temporanei si usa `gensym()`.

Questa distinzione è importante per gli effetti. Una funzione riceve normalmente valori già
calcolati; una macro riceve la forma sorgente e può quindi decidere se inserirla una volta, più
volte o non inserirla. Le macro di Triad non sono igieniche: un nome temporaneo introdotto dalla
macro può collidere con un nome del chiamante. `gensym` crea un simbolo fresco per i temporanei,
ma non rende automaticamente sicuro ogni riferimento libero. Per questo conviene limitare le
macro a trasformazioni piccole e ispezionare l'albero espanso prima di attribuire al risultato
un comportamento inatteso.

### 18.1 Codice che genera codice

```triad-full
function poly(coeffs)
    acc = :(0)
    i = 0
    for c in coeffs
        acc = :($acc + $c * x ^ $i)
        i += 1
    end
    acc
end

p = poly([1, 2, 3])
x = 2
println(eval(p))
```

**Output (golden Full):**

```text
17
```

`poly` costruisce un albero a ogni giro: `:(0)` è il punto di partenza, e ogni coefficiente innesta
l'albero precedente con `$acc`, la costante `$c` e l'esponente `$i`. Il `for` qui lavora su valori
normali; solo i quote e gli unquote costruiscono codice. Con `[1, 2, 3]` l'albero finale rappresenta
`1 + 2 * x + 3 * x^2`, e con `x = 2` vale `1 + 4 + 12 = 17`. `eval(p)` cerca `x` nello scope
globale: se `x` fosse stato locale a una funzione, l'albero non l'avrebbe visto.

---

<a id="cap-19"></a>

## 19. Builtin

Un **builtin** è una funzione che il linguaggio fornisce senza che tu la definisca. Alcuni sono
primitive vere e proprie (l'aritmetica), altri sono comodità costruite sopra il nucleo (le funzioni
di ordine superiore in Full). La tabella elenca i builtin di Triad-Full, raggruppati per ambito;
sotto trovi la parte che esiste anche in Core.

| ambito | funzioni |
|---|---|
| aritmetica e confronto | `+ - * / ^ % == != < <= > >= !`, `abs sqrt floor ceil round exp log sin cos div mod min max`; `*` concatena le stringhe |
| liste | `length isempty first last rest reverse sort sum push! pop! append! vcat collect`, `a:b`, `x in xs` |
| ordine superiore | `map filter reduce any all count` |
| stringhe e output | `string repr println print` |
| tipi | `typeof`, `isa`, `Int Float String Symbol` |
| errori | `err iserr throw error` |
| codice | `eval parse unparse sexpr Expr gensym` |
| logica | `vars(sol)` |

Due dettagli che la tabella nasconde. Primo, gli **operatori sono funzioni**: in Full `+` è un nome
come gli altri, quindi `reduce(+, xs)` funziona e puoi aggiungere metodi a un operatore (cap. 7).
Secondo, builtin e funzioni utente non sono mondi separati: in Full puoi aggiungere metodi a un
nome che è anche un builtin, come `+` su `Point`, e il builtin resta la scelta per i valori che non
hanno un metodo più specifico.

**Il sottoinsieme di Core** è più piccolo: `+ - * % ^`, i confronti, `&& || !`, `length`, `push!`,
la costruzione `[a, b]` e l'indicizzazione `xs[i]`, `*` sulle stringhe, `Int`, `string`, `Symbol`,
`print`, `println`, `typeof` (`SPEC-CORE §7`). La riduzione è per progetto: un interprete di bootstrap
deve poter eseguire se stesso, e ogni builtin in più è codice che quel bootstrap deve fornire. Per
questo in Core `map`, `filter`, `reduce`, `sum`, `sort`, `div` e `mod` **non esistono**: si scrivono
a mano (cap. 22.1).

---

<a id="cap-20"></a>

## 20. Riga di comando e REPL

Un programma Triad non vive solo dentro un file: lo standard definisce anche come si invoca
l'interprete. L'interfaccia di `triad` è normativa (`SPEC §14`), cioè fa parte del linguaggio tanto
quanto la sintassi; se due implementazioni leggono gli argomenti in modo diverso, i programmi non
sono portabili.

```
triad                            # REPL
triad FILE [ARG...]              # esegue FILE; ARGS == [ARG...]
triad -l FILE                    # carica FILE e apre il REPL
triad -i FILE                    # esegue FILE e poi apre il REPL
triad -e CODE                    # esegue CODE
triad -E CODE                    # esegue CODE e stampa il valore
triad --tree FILE                # stampa l'albero uniforme come S-expression
triad -q                         # REPL senza banner
triad -h, --help
triad -v, --version
triad -                          # legge lo script da stdin
```

Le opzioni coprono tre esigenze diverse. `-e` e `-E` servono per provare un frammento da terminale,
con la differenza che la seconda stampa anche il valore; `-l` e `-i` combinano un file e la sessione
interattiva, secondo che il file vada caricato o anche eseguito; `--tree` mostra l'albero uniforme
del capitolo 17, utile quando vuoi vedere come il parser ha raggruppato il codice. Il trattino finale
legge lo script da stdin, così Triad può stare in una pipeline.

- L'estensione `.triad`/`.td` si può omettere; lo shebang `#!` è ignorato.
- Il programma vede gli argomenti in `ARGS`, lista di stringhe, senza il nome del programma.
- Codici di uscita: `0` successo, `1` errore non gestito (su stderr), `2` uso non valido.

Questa interfaccia è normativa, ma non tutte le implementazioni la coprono: il seed Windows oggi
esegue un file e basta, senza REPL né opzioni (cap. 29). Per eseguire gli esempi di questo manuale
basta la forma `triad FILE`, oppure l'`node seed/dev/triad_core.cjs` mostrato in apertura.

### 20.1 Il REPL

Il REPL è una sessione interattiva: scrivi un'espressione, vedi il valore, e le definizioni restano
attive tra un comando e l'altro. È utile per esplorare, per provare un goal logico o per capire
perché un'espressione dà un certo risultato, senza creare un file ogni volta.

Il REPL è in stile Prolog:

```
triad> 1 + 2
3
triad> ?- ancestor(:tom, ?d)
?d = :bob ;
?d = :liz.
triad> parent(:jim, ?x)
false.
```

Le risposte mostrano i due modi del REPL: `1 + 2` è un'espressione Triad normale e stampa il valore;
`?- ancestor(...)` è una query e stampa le soluzioni una per una, con `;` per chiedere la successiva
e `.` per fermarsi. `false.` non è un errore: significa che non ci sono altre soluzioni.

- I blocchi restano aperti finché non sono chiusi da `end`.
- `?- goal` (il `.` finale è facoltativo) esegue una query con le opzioni di `solve`: `limit`,
  `depth`, `steps`, `trace`.
- Un'istruzione che è un goal su un predicato della knowledge base è trattata come query.
- Dopo ogni soluzione: `;`, `n` o spazio per la successiva, `a` per tutte le rimanenti, invio o `.`
  per fermarsi. `false.` significa nessun'altra soluzione.
- Comandi: `:load FILE…` (`:l`), `:reload` (`:r`), `:listing [nome]` (`:ls`), `:tree CODICE`,
  `:reset`, `:help` (`:h`), `:quit` (`:q`, `halt`, Ctrl-D).
- Ctrl-C interrompe il calcolo in corso; un errore non gestito è stampato e il REPL continua.

---

<a id="cap-21"></a>

## 21. Primitivi di bootstrap

Cinque primitive servono a S1 per leggere e analizzare il sorgente Triad. **Non fanno parte di
Triad-Full** (`SPEC-CORE §8`): usale solo nel codice di bootstrap.

Sono primitive e non funzioni perché stanno **sotto** il linguaggio: servono a un interprete scritto
in Triad per leggere il proprio sorgente come sequenza di byte. Per questo non fanno parte di
Triad-Full: un programma applicativo non dovrebbe dipendere da loro, e il codice che le usa non è
portabile fuori dal bootstrap. La loro presenza nel profilo Core spiega perché una stringa è una
sequenza di byte e non una sequenza di caratteri (cap. 10).

| primitiva | semantica |
|---|---|
| `readfile(path)` | contenuto del file come `String`; errore se non leggibile |
| `strlen(s)` | numero di byte |
| `strbyte(s, i)` | byte (`Int` 0–255) alla posizione `i`, da 1 |
| `strsub(s, a, b)` | sottostringa dai byte `a` a `b` inclusi, da 1 |
| `exit(n)` | termina il processo con codice `n` |

Le cinque primitive sono volutamente minime: nessuna conosce i caratteri, nessuna conosce la
sintassi. `strbyte` restituisce un `Int` fra 0 e 255 e `strsub` lavora su intervalli di byte
inclusivi, quindi un programma che analizza sorgente deve fare da sé il confronto con i codici dei
caratteri che gli interessano.

```triad
s = "abc 123 xyz"
cifre = 0
i = 1
while i <= strlen(s)
    b = strbyte(s, i)
    if b >= 48 && b <= 57
        cifre += 1
    end
    i += 1
end
println(cifre)
fine = 1
while fine <= strlen(s) && strbyte(s, fine) != 32
    fine += 1
end
println(strsub(s, 1, fine - 1))
```

**Output:**

```text
3
abc
```

Il primo ciclo conta le cifre confrontando il byte con `48` e `57`, che sono i codici ASCII di `0` e
`9`: è il modo in cui un analizzatore lessicale distingue un numero da un nome senza avere funzioni
sulle stringhe (cap. 23, esercizio 6). Il secondo ciclo cerca il primo spazio e si ferma, poi
`strsub(s, 1, fine - 1)` estrae i byte dalla posizione 1 all'ultimo prima dello spazio: `abc`. Nota
l'ordine della condizione nel `while`: prima si controlla di essere dentro la stringa, poi si legge
il byte; invertirle produrrebbe un accesso fuori intervallo.

Un programma può leggere se stesso con `readfile(ARGS[1])`: è il primo passo di un interprete
self-hosted.

---

<a id="cap-22"></a>

## 22. Stile e pattern idiomatici

Questo capitolo non introduce costrutti nuovi: mostra come combinare quelli dei capitoli precedenti
nei casi che ricorrono sempre — trasformare una lista, rappresentare un record, tenere uno stato
condiviso, costruire una stringa. Sono pattern, non regole del linguaggio, e li riconoscerai nel
codice del progetto.

### 22.1 Funzioni di ordine superiore scritte in Core

In Core non esistono `map`/`filter`/`reduce`: si scrivono una volta, con `while` e lambda, e poi si
usano ovunque.

La differenza rispetto alle versioni Full non è solo nel nome: qui il ciclo è esplicito, quindi vedi
l'indice, la condizione di fine e il punto in cui l'elemento viene aggiunto. Se un giorno una di
queste funzioni dà un risultato inatteso, il difetto è visibile in tre righe.

```triad
function mappa(f, xs)
    out = []
    i = 1
    while i <= length(xs)
        push!(out, f(xs[i]))
        i += 1
    end
    out
end

function filtra(p, xs)
    out = []
    i = 1
    while i <= length(xs)
        if p(xs[i])
            push!(out, xs[i])
        end
        i += 1
    end
    out
end

function riduci(f, acc, xs)
    i = 1
    while i <= length(xs)
        acc = f(acc, xs[i])
        i += 1
    end
    acc
end

xs = [1, 2, 3, 4, 5, 6]
println(mappa(x -> x * x, xs))
println(filtra(x -> x % 2 == 0, xs))
println(riduci((a, b) -> a + b, 0, xs))
```

**Output:**

```text
[1, 4, 9, 16, 25, 36]
[2, 4, 6]
21
```

`mappa` e `filtra` restituiscono liste nuove, `riduci` restituisce un valore; in tutti e tre i casi
la funzione ricevuta è un parametro normale, quindi il comportamento si può cambiare senza toccare
il ciclo. Nota che `riduci` accumula in `acc` e non muta `xs`: la lista in ingresso resta la stessa.

### 22.2 Record come liste taggate

In Core non c'è `struct`: un record è una lista con un simbolo come tag in prima posizione. La
convenzione è importante perché senza struct non esiste un tipo nominale: il significato del record
sta interamente nel tag e nell'ordine dei campi, che il programma deve rispettare da solo.

```triad
punto(x, y) = [:Punto, x, y]
px(p) = p[2]
py(p) = p[3]
somma_punti(a, b) = punto(px(a) + px(b), py(a) + py(b))
p = somma_punti(punto(1, 2), punto(10, 20))
println(p, " ", p[1] == :Punto)
```

**Output:**

```text
[:Punto, 11, 22] true
```

L'esempio è costruito per mostrare il patto: `punto` è il costruttore, `px`/`py` sono gli accessori
e nessuna funzione tocca gli elementi a mano tranne loro. Se un giorno cambi l'ordine dei campi,
cambi solo il costruttore e gli accessori; chi usa `px` e `py` non se ne accorge. È lo stesso
principio di incapsulamento di una struct, ottenuto con convenzioni invece che con il tipo.

### 22.3 Ambiente come lista di associazioni

È la struttura usata dagli interpreti in `selfhost/`: una lista piatta `[nome1, valore1, nome2,
valore2, …]`.

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

env = []
env_set(env, :x, 10)
env_set(env, :y, 20)
env_set(env, :x, 11)
println(env, " ", env_get(env, :x), " ", env_get(env, :z))
```

**Output:**

```text
[:x, 11, :y, 20] 11 nothing
```

È una lista piatta per non pagare un livello di annidamento: le coppie sono affiancate e `env[i+1]`
legge il valore del nome in posizione `i`. Il costo è che ogni ricerca è lineare e che le due
funzioni devono avanzare di due in due; il vantaggio è che la struttura è una lista normale, quindi
si stampa e si ispeziona senza conversioni. È lo stesso schema che un interprete usa per l'ambiente
dei nomi.

### 22.4 Stato mutabile condiviso

Poiché una funzione nominata non può riassegnare un globale, lo stato condiviso si tiene in una
lista mutabile o in una chiusura.

```triad
stato = [0]
function tick()
    stato[1] += 1
end
tick()
tick()
println(stato[1])
```

**Output:**

```text
2
```

`tick` non riassegna `stato`: muta l'elemento della lista che `stato` indica. È la differenza del
capitolo 3 fra cambiare un legame e mutare un oggetto, e qui è ciò che permette a una funzione
nominata di aggiornare uno stato esterno senza violare la regola 8.3 sull'assegnamento locale. La
lista fa da contenitore: il legame `stato` resta lo stesso, il contenuto cambia. Se lo stato deve
avere più campi, si allunga la lista (o si usa un record taggato come in 22.2).

### 22.5 Costruire stringhe

Due funzioni che tornano sempre: ripetere una stringa e unire una lista con un separatore. In Core
non c'è una funzione che unisca una lista con un separatore, quindi il separatore va inserito a mano,
e la posizione è tutto: va messo davanti a ogni elemento tranne il primo. Ricorda che ogni `*` crea
una stringa nuova (cap. 10).

```triad
function ripeti(s, n)
    out = ""
    while n > 0
        out = out * s
        n -= 1
    end
    out
end

function unisci(xs, sep)
    out = ""
    i = 1
    while i <= length(xs)
        if i > 1
            out = out * sep
        end
        out = out * string(xs[i])
        i += 1
    end
    out
end

println(ripeti("ab", 3))
println(unisci([1, 2, 3], ", "))
```

**Output:**

```text
ababab
1, 2, 3
```

`unisci` mette il separatore prima di ogni elemento tranne il primo: per questo il controllo `i > 1`
viene prima delle due concatenazioni. Se lo mettessi dopo l'elemento, l'ultima concatenazione
lascerebbe il separatore in fondo alla stringa.

### 22.6 Regole di stile

- Funzioni piccole con nomi chiari; caso base esplicito in ogni ricorsione; per profondità grandi
  preferisci `while`.
- Cicli con contatori espliciti (`i = 1 … while i <= length(xs)`).
- Non usare `fact`, `rule`, `solve`, `struct` e le altre parole chiave di Full come nomi: il codice
  deve restare valido anche in Triad-Full.
- Scrivi `!io` sulle funzioni che stampano: Core lo ignora, Full lo richiede.
- Non spezzare un'espressione su più righe: l'interprete di riferimento chiude l'istruzione a ogni
  a capo anche dentro le parentesi (cap. 1.6). Una istruzione per riga.

Queste regole non sono gusti personali: ognuna evita un problema concreto — un nome che collide in
Full, un effetto non dichiarato, un'ambiguità di lettura, una riga spezzata che il runtime rifiuta.

---

<a id="parte-2"></a>

# Parte II — Esercizi

Ogni esercizio ha una soluzione verificata. Prova prima, poi apri il riquadro «Soluzione».

Gli esercizi della prima serie sono programmi Triad-Core e si eseguono con l'interprete di
riferimento; quelli della seconda usano costrutti Full, quindi hanno risultati attesi ma non sono
eseguibili oggi. In entrambi i casi la soluzione non è l'unico programma giusto: è un programma che
funziona, ed è utile confrontarla con la tua per capire quale delle due è più chiara.

<a id="cap-23"></a>

## 23. Esercizi guidati (Triad-Core)

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

<a id="cap-24"></a>

## 24. Esercizi su Triad-Full

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

---

<a id="parte-3"></a>

# Parte III — Riferimento

Questa parte è pensata per la consultazione, dopo la lettura della prima: raccoglie la grammatica,
le schede rapide, la tabella degli errori, il glossario e lo stato reale delle implementazioni. Non
è materiale nuovo: se un punto non torna, il rimando al capitolo della Parte I ti riporta alla
spiegazione. Tieni presente che le sezioni di riferimento descrivono lo **standard**; lo stato di
ciò che è eseguibile oggi è raccolto nell'ultimo capitolo.

<a id="cap-25"></a>

## 25. Grammatica

La grammatica è la forma più compatta in cui una specifica dice che cosa è un programma valido. Si
legge come una ricetta: `=` significa «è fatto di», `{ … }` significa «zero o più», `[ … ]`
«opzionale». Le due grammatiche che seguono non descrivono due linguaggi: la prima è il sottoinsieme
Core, la seconda è Full, e le produzioni che Core condivide compaiono in Full con la stessa forma.

### 25.1 Triad-Core (EBNF normativa)

```
program  = { sep } { stmt sep { sep } } ;
sep      = NEWLINE | ";" ;
stmt     = funcdef | "return" [ expr ] | "break" | "continue" | expr ;
funcdef  = "function" NAME "(" [ NAME { "," NAME } ] ")" block "end"
         | NAME "(" [ NAME { "," NAME } ] ")" "=" expr ;
expr     = assegnamento ;
assegnamento = NAME ( "=" | "+=" | "-=" | "*=" ) expr | ternario ;
ternario = or_expr [ "?" expr ":" expr ] ;
or_expr  = and_expr { "||" and_expr } ;
and_expr = cmp_expr { "&&" cmp_expr } ;
cmp_expr = sum_expr { ( "==" | "!=" | "<" | "<=" | ">" | ">=" ) sum_expr } ;
sum_expr = mul_expr { ( "+" | "-" ) mul_expr } ;
mul_expr = pow_expr { ( "*" | "%" ) pow_expr } ;
pow_expr = unary { "^" unary } ;                    (* destra *)
unary    = ( "-" | "!" ) unary | postfix ;
postfix  = primary { "(" args ")" | "[" expr "]" } ;
primary  = INT | STRING | SYMBOL | "true" | "false" | "nothing" | NAME
         | "(" expr ")"
         | "[" [ expr { "," expr } ] "]"
         | "(" NAME { "," NAME } ")" "->" expr
         | "if" expr block { "elseif" expr block } [ "else" block ] "end"
         | "while" expr block "end"
         | "let" [ NAME "=" expr { "," NAME "=" expr } ] block "end"
         | "begin" block "end"
         | "function" "(" [ NAME { "," NAME } ] ")" block "end" ;
block    = { stmt sep { sep } } ;                   (* fino a end/else/elseif *)
```

La grammatica Core è volutamente piccola: niente `for`, niente range, niente tipi nelle firme. Non
descrive però ogni dettaglio che l'esecuzione accetta: l'assegnamento a un elemento (`xs[i] = e`,
`xs[i] += e`), che gli esempi del capitolo 9 usano per mutare le liste, non compare nella produzione
`assegnamento`. È una lacuna del testo della specifica, non del linguaggio: l'interprete di
riferimento lo supporta, e il codice che lo usa è portabile fra le implementazioni Core.

### 25.2 Triad-Full (EBNF normativa)

```
program    = { sep } { stmt sep { sep } } ;
sep        = NEWLINE | ";" ;
block      = { sep } { stmt sep { sep } } ;

stmt       = funcdef | structdef | macrodef | fact | rule
           | "requires" expr | "ensures" expr
           | "return" [ expr ] | "break" | "continue"
           | "(" NAME { "," NAME } ")" "=" expr
           | expr ;

funcdef    = "function" fname "(" [ params ] ")" [ "::" TYPE ] [ "!" EFFECT { "," EFFECT } ]
             block "end"
           | NAME "(" [ params ] ")" "=" expr ;
fname      = NAME | "+" | "-" | "*" | "/" | "%" | "^" | "==" | "<" | "<=" | ">" | ">=" ;
params     = param { "," param } ;
param      = NAME [ "::" TYPE ] | "(" NAME { "," NAME } ")" ;
structdef  = "struct" NAME sep { NAME [ "::" TYPE ] sep } "end" ;
macrodef   = "macro" NAME "(" [ NAME { "," NAME } ] ")" block "end" ;

fact       = "fact" term ;
rule       = "rule" term [ ":-" goal { "," goal } ] ;

expr       = (* Pratt: precedenze dalla più bassa alla più alta *)
  1  a = b   a += b   a -= b   a *= b                 (destra)
  2  x -> e   (a, b) -> e   c ? a : b                 (destra)
  3  ||
  4  &&
  5  ==  !=  <  <=  >  >=  in  isa  is
  6  a:b                                               (range, senza spazi)
  7  +  -
  8  *  /  %
  9  -x  !x  +x  $x                                    (unari)
 10  ^                                                 (destra)
 11  e::T                                              (asserzione di tipo)
 12  f(args)  xs[i]  a.campo                           (postfissi, senza spazio prima di ( e [)

primary    = NUMBER | STRING | SYMBOL | LVAR | NAME | "true" | "false" | "nothing"
           | "(" expr ")" | "(" expr "," ... ")"       (* tupla: parametri di lambda *)
           | "[" [ expr { "," expr } [ "|" expr ] ] "]"
           | "[" expr "for" NAME "in" expr [ "if" expr ] "]"
           | ":(" expr ")" | "quote" block "end"
           | "@" NAME "(" args ")"
           | "if" expr block { "elseif" expr block } [ "else" block ] "end"
           | "while" expr block "end"
           | "for" NAME "in" expr block "end"
           | "for" "(" NAME { "," NAME } ")" "in" expr block "end"
           | "let" [ NAME "=" expr { "," NAME "=" expr } ] block "end"
           | "begin" block "end"
           | "try" block [ "catch" [ NAME ] block ] "end"
           | "with" modifier { "," modifier } block "end"
           | "solve" goal { "limit" expr | "depth" expr | "steps" expr | "trace" }
           | "function" "(" params ")" block "end" ;
modifier   = "budget" "(" "steps" "=" expr ")" | "trace" ;
```

La grammatica Full elenca i livelli di precedenza nella forma numerata che il parser usa: è la
stessa tabella del capitolo 4, e la produzione `primary` dice quali forme possono stare alla base di
un'espressione. Le produzioni `stmt` e `block` dicono invece che cosa può contenere un blocco, e
quindi in quali punti `fact`, `rule`, `requires` e `ensures` sono ammessi.

---

<a id="cap-26"></a>

## 26. Schede rapide

Le schede rapide non sostituiscono i capitoli: servono a ricordare la forma esatta di un costrutto
quando sai già che cosa vuoi scrivere. Sono divise per tipo di problema — un valore, un controllo di
flusso, una funzione — e ogni riga rimanda, quando serve, al capitolo che spiega la scelta.

### 26.1 Valori

| vuoi | scrivi |
|---|---|
| un intero | `42`, `1_000` |
| un float **[Full]** | `3.14`, `1e-9` |
| un booleano | `true`, `false` |
| il vuoto | `nothing` |
| una stringa | `"testo"` |
| un simbolo | `:alice` |
| una lista | `[1, 2, 3]` |
| una lambda | `x -> x + 1` |
| una funzione | `function (x) x end` |
| un record Core | `[:Punto, 1, 2]` |
| una struct **[Full]** | `Point(3, 4)` |
| codice come dato **[Full]** | `:(a + b)`, `quote … end` |

### 26.2 Controllo di flusso

| vuoi | scrivi |
|---|---|
| una condizione | `if c … elseif d … else … end` |
| una condizione breve | `c ? a : b` |
| un ciclo | `while c … end` **[Core]** · `for x in xs … end` **[Full]** |
| uscire dal ciclo | `break` |
| saltare al passo dopo | `continue` |
| uscire dalla funzione | `return e` |
| uno scope nuovo | `let x = 1 … end` |
| un blocco senza scope | `begin … end` |
| una lista costruita **[Full]** | `[x * x for x in xs]` |
| catturare un errore **[Full]** | `try b catch e h end` |

### 26.3 Funzioni

| vuoi | scrivi |
|---|---|
| una funzione | `f(x) = x + 1` |
| un corpo multi-istruzione | `function f(x) … end` |
| un tipo di ritorno **[Full]** | `function f(x)::Float … end` |
| un effetto **[Full]** | `function f(x) !io … end` |
| un predicato in un goal **[Full]** | `function evena(n) n % 2 == 0 end` |
| una precondizione **[Full]** | `requires cond` |
| una postcondizione **[Full]** | `ensures cond` |

---

<a id="cap-27"></a>

## 27. Tabella degli errori

La tabella raccoglie i messaggi che l'interprete di riferimento stampa oggi in Triad-Core, con la
causa tipica. I messaggi sono dell'implementazione, non dello standard: la categoria dell'errore è
normativa (cap. 11.3), il testo no, quindi non scrivere programmi che dipendono da queste stringhe.

### 27.1 In Core

Core non ha `try`/`catch` né valori `Err`: un errore **termina il processo** con exit code `1` e un
messaggio diagnostico su stderr. Quello già stampato su stdout resta.

| messaggio | causa |
|---|---|
| `parse error: unexpected token …` / `parse error: expected …` | sintassi non Core (`1.5`, `/`, `() -> …`, `end` mancante) |
| `error: undefined variable NOME` | nome mai assegnato, o funzione chiamata prima di essere definita |
| `error: not a function` | si chiama un valore che non è una funzione (`x = 5; x(1)`) |
| `error: arity mismatch` | numero di argomenti diverso dai parametri |
| `error: index out of range` | `xs[i]` con `i < 1` o `i > length(xs)` |
| `error: + type error` (e simili) | operandi di tipo sbagliato (`1 + "a"`) |
| `error: if cond` / `while cond` / `ternary cond` / `&& expects bool` | condizione non `Bool` |
| `error: div by zero` / `negative exponent` | `x % 0`, `2 ^ -1` |
| `error: unknown function NOME` | builtin riservato usato in modo non supportato |
| `cannot read file: …` | file inesistente o non leggibile |
| `usage: triad FILE [ARG...]` (exit 2) | nessun file passato |

### 27.2 In Triad-Full

Gli stessi fallimenti arrivano come `Err` con un `kind` (cap. 11.3), invece di terminare il
processo. Un errore non gestito al top level stampa `riga N: …` e esce con codice `1`.

---

<a id="cap-28"></a>

## 28. Glossario

Il glossario raccoglie i termini che il manuale usa con un significato preciso e che ricorrono in
capitoli diversi. Le definizioni sono brevi apposta: il rimando al capitolo serve quando la parola
da sola non basta.

| termine | significato |
|---|---|
| **Albero uniforme** | l'unico tipo di nodo prodotto dal parser, `Node(head, args)`; è anche ciò che il kernel esegue |
| **Ambiente** | l'insieme dei legami di nomi a valori visibile in un punto del programma |
| **Backtracking** | il motore logico torna sui legami e prova la clausola successiva |
| **Budget** | limite di passi eseguibili; esaurito produce `Err(:budget)` |
| **Clausola** | un `fact` o una `rule` della knowledge base |
| **Chiusura** | funzione che cattura l'ambiente in cui è stata creata |
| **Dispatch** | scelta del metodo in base ai **tipi** degli argomenti |
| **Effetto** | capacità dichiarata di una funzione: `io`, `state` |
| **Err** | l'errore come dato: `kind`, `msg`, `data` |
| **Goal** | una domanda alla knowledge base: predicato, congiunzione, disgiunzione, unificazione |
| **Knowledge base** | l'insieme dei fatti e delle regole |
| **Macro** | una funzione che riceve e restituisce codice |
| **Occurs-check** | la regola che impedisce a `?x` di unificarsi con un termine che contiene `?x` |
| **Porta (di Byrd)** | uno dei quattro eventi `:call`, `:exit`, `:redo`, `:fail` che descrivono un passo della ricerca logica (cap. 14) |
| **Precedenza** | l'ordine in cui gli operatori si raggruppano (12 livelli in Full, 10 in Core) |
| **Profilo** | un sottoinsieme normativo dello standard: Core o Full |
| **Scope lessicale** | un nome è visibile dove è stato legato e all'interno, mai all'esterno |
| **Soluzione** | una `Solution`: i legami prodotti da un goal risolto |
| **Standardizzazione a parte** | le variabili di una clausola vengono rinominate a ogni uso |
| **Termine** | un dato della logica: costante, variabile logica o forma composta, non valutata finché non serve |
| **Tracciato** | il valore `Traced(result, trace)` restituito da `with trace` o `solve … trace` |
| **Unificazione** | l'uguaglianza logica: due termini si rendono identici legando le variabili |
| **Valori di prima classe** | funzioni e operatori usabili come qualsiasi altro valore |

---

<a id="cap-29"></a>

## 29. Cosa gira oggi

Questa sezione non fa parte del linguaggio: è lo stato delle implementazioni, utile per orientarsi
prima di scrivere codice. Serve a rispondere a una domanda che un manuale rischia di lasciare
implicita: quello che hai appena letto è **definito** dallo standard, ma che cosa puoi **eseguire**
oggi? Le due cose non coincidono, e confonderle porta a due errori opposti: credere che un esempio
Full non funzioni perché è sbagliato, o credere che un programma Core funzioni su ogni runtime.

| profilo | stato |
|---|---|
| **Triad-Core** | **eseguibile**: interprete di riferimento JavaScript `seed/dev/triad_core.cjs` (37/37 casi Core) e, in parte, il seed Windows `seed/windows-x86_64/seed.exe` |
| **Triad-Full** | **non eseguibile**: struct, dispatch, logica, macro, contratti, budget, tracce, effetti, destrutturazione, `for`, `try`, `Float` sono specifica; nella conformance Full passa solo `errore` |

Il profilo Full non è «quasi pronto»: è definito per intero nello standard, e i suoi esempi hanno
risultati attesi conservati dalla suite, ma nessuno dei runtime del repository lo esegue oggi. Quando
nel libro vedi `**Output (golden Full):**`, quindi, leggi un valore atteso, non una verifica appena
fatta. Sul versante Core la situazione è diversa: l'interprete JavaScript passa l'intera suite,
mentre il seed Windows copre solo una parte dei casi — in particolare le liste restano parziali.

Anche restando in Core, «eseguibile» non significa «identico ovunque»: esistono due runtime, e non
coprono lo stesso sottoinsieme. La tabella elenca le differenze che contano per chi scrive codice
destinato a girare su entrambi; leggerla prima di scegliere un costrutto evita di scoprire il
problema solo quando il programma arriva sul seed.

Differenze note fra i due runtime Core:

| funzionalità | interprete JS | seed Windows |
|---|---|---|
| `return`, `break`, `continue` | sì | non elencati nel README del seed |
| lambda | più parametri | **un solo parametro** |
| chiusure | condivise | **per valore**, solo l'ultimo legame del frame |
| `string(x)` | tutti i tipi | solo `Int` e `String` |
| liste | eterogenee, `xs[i]`, `length`, `push!` | solo interi; costruzione, stampa, `push!` |
| `get(xs, i)` | non esiste | funzione ausiliaria **non standard**, indici **da 0** |
| `ARGS`, primitivi di bootstrap | sì | non elencati nel README del seed |
| messaggi di errore | su stderr | solo exit code |

Le righe più importanti sono le prime tre. Un `return` o un `break` che l'interprete JS esegue può
non essere supportato dal seed; una lambda con due parametri funziona su uno e non sull'altro; una
chiusura che aggiorna uno stato condiviso si comporta diversamente. Sono differenze di
implementazione, non di standard: la semantica corretta è quella dell'interprete JS e della
specifica, e il seed è il runtime più limitato. Se un programma deve girare su entrambi, scegli il
sottoinsieme comune e non contare su ciò che una sola colonna dichiara.

Regola pratica: **scrivi codice che rispetta `SPEC-CORE` e verificalo con l'interprete JS**; se deve
girare anche sul seed, restringiti alle funzionalità elencate nella colonna di destra e verificalo
su Windows.

Due limiti noti che il lettore deve conoscere prima di scrivere codice:

- **ogni a capo chiude l'istruzione**, anche dentro `( )`, `[ ]` e negli argomenti di una chiamata.
  L'eccezione prevista da `SPEC §1` per Triad-Full (a capo dentro le parentesi, o subito dopo un
  operatore binario) non è implementata nell'interprete di riferimento. Scrivi una istruzione per
  riga;
- **il seed Windows non implementa l'indicizzazione standard `xs[i]`**: lì c'è la funzione
  ausiliaria non standard `get(xs, i)`, con indici **da 0**.

A questi due limiti va aggiunto un dettaglio di piattaforma: il seed Linux è allo stadio E0 e stampa
solo un messaggio di prova, quindi per eseguire programmi su Linux oggi si usa l'interprete
JavaScript (`node seed/dev/triad_core.cjs`). Il seed Windows è il runtime in codice macchina più
completo, ma non è l'unico modo di eseguire Triad.

Che cosa farne, in pratica: per studiare e per scrivere codice usa l'interprete JS; per verificare la
portabilità verso il bootstrap prova sul seed; per gli esempi Full leggi e confronta con i golden,
sapendo che nessun runtime li esegue ancora. Il manuale non promette ciò che il repository non sa
fare, e questa sezione esiste per rendere esplicito il confine.

---

<a id="app-a"></a>

# Appendice A — Influenze dichiarate

Triad nasce da idee di Julia, Prolog e Lisp, ma **non è un dialetto di nessuno dei tre**: la
definizione del linguaggio è la specifica.

Conoscere le influenze non è curiosità: se vieni da uno di questi linguaggi, sapere che cosa Triad
ha ripreso e che cosa ha cambiato ti aiuta a non importare abitudini sbagliate. La tabella non è un
elenco di parentele, è un avviso: le somiglianze sono di idea, non di comportamento.

| da | idea ripresa |
|---|---|
| Julia | blocchi `function … end`, `struct`, tipi con `::`, multiple dispatch, operatori-funzione, `if`/`for`/`while`/`let` |
| Prolog | `fact`/`rule` come costrutti, unificazione con occurs-check, backtracking, `solve`, variabili logiche `?x` |
| Lisp | codice come dato, albero uniforme, `:( … )`/`quote` con `$`, macro |

**Propri di Triad**, non presi in prestito: errori come dati, contratti, budget, tracce ed effetti
dichiarati come parte del linguaggio, e l'integrazione dei tre modelli in una sintassi a blocchi.

---

<a id="app-b"></a>

# Appendice B — Dove guardare

Questa appendice elenca dove approfondire. Sono materiali **facoltativi**: il manuale è
autosufficiente, e questi rimandi servono a chi vuole risalire alla fonte normativa, controllare un
caso limite o vedere il codice del progetto. Il percorso di studio per capitoli e la visita al
codice sono un complemento, non un prerequisito.

| vuoi | leggi |
|---|---|
| the complete regulatory definition | [`SPEC.md`](SPEC.md) |
| the bootstrap subset | [`SPEC-CORE.md`](SPEC-CORE.md) |
| the study path by chapters and the project code | [`TUTORIAL.md`](tutorial/TUTORIAL.md) |
| the complete examples with output | `examples/` |
| the executable contract, with the golden | [`conformance/`](conformance/README.md) |
| the state of the bootstrap | [`STATUS.md`](STATUS.md) · [`BOOTSTRAP.md`](BOOTSTRAP.md) |
| the work plan | [`plan.md`](plan.md) · [`TASK.md`](TASK.md) |
| tools for editors | [`editors/`](editors/README.md) |
| the license | [`LICENSE`](LICENSE) — MIT |

---

*Manuale scritto per lo standard Triad `0.2.0`. Le sezioni normative sono in [`SPEC.md`](SPEC.md) e
[`SPEC-CORE.md`](SPEC-CORE.md); in caso di divergenza, prevale la specifica.*
