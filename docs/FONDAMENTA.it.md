# Fondamenta: programmare da zero con Triad

> Questa parte del libro non presuppone nulla: è pensata per chi non ha mai scritto un programma
> in vita sua. Spiega cosa fa un computer quando esegue un programma, come si scrive e si esegue
> il primo programma Triad, e costruisce uno alla volta i concetti — valori, variabili,
> espressioni, decisioni, ripetizioni, liste, funzioni, ricorsione, errori — che tutto il resto
> del libro dà per noti. Chi non ha mai installato uno strumento di sviluppo parte
> dall'Appendice A (installazione guidata); l'Appendice B raccoglie la scheda rapida della
> sintassi. Se sai già programmare, puoi saltare tutto e cominciare dal Manuale o dal
> Tutorial; se non sai da dove cominciare, comincia da qui.

Questo testo nasce da una constatazione: il Manuale e il Tutorial spiegano **Triad**, ma danno
per scontato che il lettore sappia già cosa sono una variabile, un ciclo o una funzione. Chi non
ha mai programmato non ha questi concetti, e senza di essi nessun manuale di nessun linguaggio
è leggibile. Le *Fondamenta* colmano la distanza: insegnano la programmazione **usando Triad**,
così impari due cose insieme — a pensare come un programmatore e a scrivere i primi programmi in
questo linguaggio.

Non serve nient'altro che un computer e la voglia di provare. Ogni esempio di questa parte è
scritto in **Triad-Core**, il sottoinsieme del linguaggio che oggi è eseguibile: puoi digitarlo e
vederlo funzionare. Alla fine della parte trovi esercizi con soluzioni, un glossario dei termini
tecnici usati e una mappa per proseguire nel resto del libro.

---

<a id="fond-1"></a>

## 1. Che cos'è un programma

Un computer è una macchina che esegue **istruzioni**. Non capisce né ragiona: legge un'istruzione,
la esegue, passa alla successiva, con una velocità enorme ma con un'intelligenza nulla. Tutto ciò
che un computer fa — mostrare una pagina web, salvare una fotografia, far muovere un robot — è il
risultato di migliaia o milioni di istruzioni semplici eseguite una dopo l'altra.

Un **programma** è il testo di quelle istruzioni, scritto in una forma che il computer può leggere.
Il testo di un programma si chiama anche **codice sorgente**, o semplicemente codice. Chi scrive
programmi si chiama programmatore; scrivere un programma si chiama programmare.

Le istruzioni non si scrivono in italiano, perché l'italiano è ambiguo e pieno di eccezioni, e una
macchina che deve eseguire letteralmente non può permettersi ambiguità. Si scrivono in un
**linguaggio di programmazione**: una lingua con regole precise e pochissime eccezioni, fatta
apposta per descrivere calcoli e azioni. Triad è uno di questi linguaggi. Come ogni linguaggio di
programmazione, ha una grammatica (come si compongono le frasi), un vocabolario (le parole ammesse)
e una semantica (che cosa significa ogni frase). La differenza rispetto alle lingue parlate è che
le regole sono poche, assolute e vanno imparate una volta per tutte: se un programma non rispetta
le regole, il computer non «ci prova lo stesso», si ferma e dice che cosa non ha capito.

Il programma scritto in un linguaggio di programmazione deve prima o poi essere tradotto in
qualcosa che il computer esegue davvero. Ci sono due modi principali per farlo:

- un **compilatore** traduce tutto il programma in anticipo, in una forma che il computer esegue
  direttamente;
- un **interprete** legge ed esegue il programma istruzione per istruzione, al momento.

Triad si esegue oggi con un interprete: il programma resta testo leggibile, e l'interprete lo
esegue mentre lo legge. Questo rende il ciclo di lavoro immediato: scrivi, esegui, vedi il
risultato, correggi.

Vediamo subito un programma vero. Questo è un intero programma Triad:

```triad
println("ciao, mondo")
```

Output:

```text
ciao, mondo
```

Il programma contiene una sola istruzione: `println("ciao, mondo")`. Quando l'interprete la
esegue, il computer mostra la scritta `ciao, mondo`. La parola `println` significa «print line»,
stampa riga: mostra qualcosa a schermo e poi va a capo. Il testo tra le virgolette è una
**stringa**, cioè una sequenza di caratteri che il programma tratta come testo.

Nota che il programma non *descrive* il risultato: lo *produce*. Non c'è un motore che «capisce»
che vuoi dire ciao; c'è un'istruzione che, quando viene eseguita, fa apparire dei caratteri sullo
schermo. Se scrivi `printn` invece di `println`, il programma non funziona: non perché il
computer si offenda, ma perché `printn` non è un'istruzione del linguaggio, così come «acqua»
non è un verbo all'infinito.

Tre parole chiave restino da questo capitolo, perché le useremo spesso: **programma** (il testo
delle istruzioni), **interprete** (il programma che esegue il tuo programma), **stringa** (un
testo trattato come dato). Il resto viene da sé.

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

---

<a id="fond-2"></a>

## 2. Il terminale e il primo programma

Per scrivere ed eseguire programmi non serve un ambiente speciale: servono tre cose. Un **editor
di testo** per scrivere il programma (il Blocco note di Windows va benissimo; meglio ancora un
editor come Visual Studio Code). Il **terminale**, ovvero la finestra in cui dai comandi al
computer digitandoli (su Windows si chiama «Prompt dei comandi» o «PowerShell», su Linux e macOS
«Terminale»). E un **runtime** per Triad, cioè il programma che esegue i tuoi programmi: in
questo libro useremo l'interprete JavaScript di riferimento, che richiede
[Node.js](https://nodejs.org) (versione 18 o superiore) e il repository del progetto. Se non hai
mai installato uno strumento di sviluppo, o se un passaggio non ti è chiaro, l'**Appendice A**
riprende tutto da zero, con un controllo da fare dopo ogni tappa e la tabella dei guasti comuni.

### 2.1 Il terminale in tre comandi

Il terminale è un modo per parlare al computer scrivendo comandi invece di cliccare. Quando lo
apri, vedi una scritta (il **prompt**) che ti dice in quale **cartella** stai lavorando: una
cartella è una delle directory in cui sono organizzati i file del computer, la stessa che vedi
nella finestra «Esplora file». I comandi che servono per questo libro sono pochissimi:

| comando | che cosa fa |
|---|---|
| `cd percorso` | entra nella cartella indicata (*change directory*) |
| `cd ..` | torna alla cartella superiore |
| `ls` (Linux/macOS) · `dir` (Windows) | elenca i file della cartella corrente |
| `node file.triad` | esegue un programma Triad con l'interprete JavaScript |

Il **percorso** è il «nome lungo» di una cartella, per esempio
`C:\Users\mario\triad2.0` su Windows o `/home/mario/triad2.0` su Linux. Il repository del progetto
si ottiene con un solo comando, da digitare nella cartella in cui vuoi tenerlo:

```sh
git clone https://github.com/GPuntobit/triad2.0.git
```

Poi si entra nella cartella creata (`cd triad2.0`) e il gioco è fatto: tutti gli esempi di questo
libro si eseguono da lì. Su Windows il comando per eseguire un programma è
`node seed\dev\triad_core.cjs file.triad`; su Linux e macOS
`node seed/dev/triad_core.cjs file.triad`. Nel resto del libro mostreremo la forma Linux/macOS:
su Windows cambia solo la forma delle barre nei percorsi.

### 2.2 Il primo programma, passo per passo

Apri l'editor, scrivi queste tre righe e salva il file con il nome `ciao.triad` nella cartella del
repository:

```triad
# ciao.triad — il mio primo programma
nome = "Triad"
println("ciao, " * nome)
```

Da terminale, esegui il comando:

```sh
node seed/dev/triad_core.cjs ciao.triad
```

Output:

```text
ciao, Triad
```

Se vedi `ciao, Triad`, hai scritto, salvato ed eseguito il tuo primo programma: congratulazioni,
sei un programmatore. Se invece vedi un messaggio che comincia con `error:` o `parse error:`, non
è successo niente di male: il [capitolo 12](#fond-12) spiega come leggere quei messaggi, che sono
il modo del computer di dire «non ho capito questa parte».

Analizziamo le tre righe, perché contengono già quasi tutti i concetti dei prossimi capitoli.

- La prima riga, `# ciao.triad — il mio primo programma`, è un **commento**: inizia con `#` e non
  è un'istruzione. L'interprete la ignora completamente. I commenti servono a spiegare il
  programma a chi lo legge (tra un mese, quel chi sarai tu).
- La seconda riga, `nome = "Triad"`, crea una **variabile**: un nome a cui è associato un valore,
  qui il testo `Triad`. Da questo punto in poi, ogni volta che il programma usa `nome`, intende
  quel valore.
- La terza riga, `println("ciao, " * nome)`, è una chiamata: chiede a `println` di mostrare il
  risultato di `"ciao, " * nome`. Il simbolo `*` tra due stringhe significa **concatenarle**,
  cioè incollarle una dopo l'altra (in Triad `+` serve solo per i numeri). Il risultato è
  `ciao, Triad`, che viene mostrato a schermo.

### 2.3 Il ciclo di lavoro

Scrivere programmi è un ciclo di quattro passi, sempre gli stessi: **scrivi** il programma,
**eseguilo**, **guarda il risultato**, **correggi**. Non esiste programmatore che scriva un
programma giusto al primo colpo: la differenza tra principiante ed esperto è che l'esperto si
aspetta gli errori e ha un metodo per trovarli. Alcune abitudini che fin da subito fanno risparmiare
tempo: cambia una cosa alla volta e riesegui; scrivi programmi piccoli e fai crescere un pezzo
alla volta; quando qualcosa non funziona, non indovinare — rileggi.

> **Attenzione.** Il nome del file deve finire con `.triad` (o con l'alias storico `.td`), e va
> salvato come **testo semplice**. Se l'editor salva con nomi come `ciao.triad.txt`, l'interprete
> non troverà il programma. Controlla sempre il nome completo del file.

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

---

<a id="fond-3"></a>

## 3. Valori: i dati con cui si calcola

Un programma manipola **valori**: numeri, testi, risposte vero/falso, elenchi di cose. Ogni valore
ha un **tipo**, che dice che cosa quel valore è e che operazioni si possono farci. In Triad i tipi
di base che incontri all'inizio sono questi:

| tipo | che cos'è | esempi |
|---|---|---|
| `Int` | un numero intero, con segno | `42`, `0`, `-7`, `1_000_000` |
| `String` | un testo, tra virgolette doppie | `"ciao"`, `"42"`, `""` |
| `Bool` | una verità: vero o falso | `true`, `false` |
| `Symbol` | un nome o un'etichetta, con i due punti davanti | `:ok`, `:alice` |
| `List` | un elenco ordinato di valori, tra parentesi quadre | `[1, 2, 3]`, `[]` |
| `Nothing` | «nessun valore» | `nothing` |

Osserva subito una distinzione importante: `42` è un numero, `"42"` è un testo. Sono due cose
diverse, anche se si vedono uguali a schermo: `42 + 1` fa `43`, mentre `"42" + 1` è un errore,
perché non si può aggiungere un numero a un testo. Le virgolette dicono all'interprete: «questo
è testo, trattalo come tale».

I numeri interi di Triad-Core sono a 64 bit, cioè hanno un limite enorme (circa 9 miliardi di
miliardi) ma un limite: se lo superi, il contatore «gira» e riparte dal numero negativo più
piccolo. Nei primi programmi non ci penserai, ma è bene saperlo. In Triad-Core non esistono i
numeri decimali (quelli con la virgola): fanno parte di Triad-Full, la versione completa del
linguaggio descritta più avanti nel libro.

Per sapere di che tipo è un valore si usa `typeof`, che risponde con il nome del tipo:

```triad
println(42)
println("ciao")
println(true)
println(nothing)
println(:alice)
println([1, 2, 3])
println(typeof(42), " ", typeof("ciao"), " ", typeof(true))
```

Output:

```text
42
ciao
true
nothing
alice
[1, 2, 3]
Int String Bool
```

Due dettagli di questo esempio meritano attenzione, perché sono il primo assaggio del fatto che un
linguaggio di programmazione è preciso fino in fondo. Primo: `println(:alice)` mostra `alice`
senza i due punti, ma il valore resta un simbolo — i due puntini servono a scriverlo nel codice,
non fanno parte del nome. Secondo: `println` accetta **più valori separati da virgola** e li
stampa uno accanto all'altro senza spazi; `println()` senza argomenti serve solo per andare a
capo.

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

---

<a id="fond-4"></a>

## 4. Variabili: dare un nome a un valore

Una **variabile** è un nome a cui è associato un valore. Il nome serve a ritrovare il valore più
avanti nel programma; l'associazione si crea con `=`, che si chiama **assegnamento**:

```triad
eta = 42
```

Da qui in poi `eta` significa `42`. L'assegnamento non è una formula matematica: `eta = 42` non
«dice che eta è uguale a 42», **fa sì** che lo diventi. Per questo una riga come questa ha senso:

```triad
eta = 42
println(eta)
eta = eta + 1
println(eta)
eta += 5
println(eta)
nome = "Ada"
messaggio = "ciao " * nome
println(messaggio)
```

Output:

```text
42
43
48
ciao Ada
```

Riga per riga: `eta = 42` crea il legame; la prima `println(eta)` mostra `42`; `eta = eta + 1`
legge il valore corrente (`42`), calcola `43` e **sostituisce** il valore di `eta`; dopo `eta += 5`
il valore è `48`. La forma `+=` è una scorciatoia per `eta = eta + 5`: esistono anche `-=` e `*=`.

Alcune regole e alcune buone abitudini:

- Un nome può contenere lettere, cifre e il carattere `_`, e non può cominciare con una cifra.
  Vanno bene `eta`, `eta_utente`, `x2`, `somma_totale`; non vanno bene `2eta`, `eta utente`.
- I nomi distinguono maiuscole e minuscole: `eta` e `Eta` sono due variabili diverse. Scegli un
  criterio e usalo sempre (in questo libro i nomi sono minuscoli, con `_` tra le parole).
- Il nome deve dire qualcosa: `n` va bene per un contatore in dieci righe, `numero_di_studenti` è
  meglio in un programma lungo. Il nome è la prima documentazione del programma.
- Usare una variabile **prima** di assegnarle un valore è un errore: in Triad non esistono
  variabili «vuote» che valgono zero o niente. Se il programma dice
  `error: undefined variable`, il nome è sbagliato o l'assegnamento manca.
- Una variabile può cambiare tipo durante il programma (`x = 1` poi `x = "ciao"` è permesso),
  ma farlo senza un motivo rende il programma difficile da leggere: di solito a una variabile
  conviene dare un tipo e tenerlo.

Un esercizio mentale utile, che i programmatori fanno di continuo: segui il programma riga per
riga tenendo in mano una tabella dei valori correnti. Dopo ogni istruzione, «che valore ha
`eta`? E `nome`?» Se sai rispondere sempre, sai già prevedere il comportamento del programma: è
la competenza fondamentale del programmatore.

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

---

<a id="fond-5"></a>

## 5. Espressioni: combinare i valori

Un'**espressione** è un calcolo che produce un valore. `42` è un'espressione (produce `42`);
`2 + 3` è un'espressione (produce `5`); `"ciao " * nome` è un'espressione (produce un testo). Le
espressioni si compongono: dentro `eta + 1` ci sono due espressioni più piccole, `eta` e `1`, e
un **operatore**, il `+`, che le combina.

Gli operatori aritmetici di base sono:

| operatore | che cosa fa | esempio | risultato |
|---|---|---|---|
| `+` | addizione | `2 + 3` | `5` |
| `-` | sottrazione | `10 - 4` | `6` |
| `*` | moltiplicazione | `6 * 7` | `42` |
| `%` | resto della divisione intera | `7 % 3` | `1` |
| `^` | potenza | `2 ^ 10` | `1024` |

In Triad-Core non c'è l'operatore `/` della divisione: la divisione decimale appartiene a
Triad-Full. Con `%` hai comunque il **resto** della divisione intera, che serve in moltissime
situazioni (sapere se un numero è pari, «girare» un contatore su un intervallo, estrarre cifre).
`7 % 3` vale `1` perché 7 diviso 3 fa 2 con resto 1; `10 % 5` vale `0` perché la divisione è
esatta.

Quando in un'espressione ci sono più operatori, decide la **precedenza**: la moltiplicazione si
esegue prima dell'addizione, quindi `2 + 3 * 4` vale `14`, non `20`. Quando hai dubbi, usa le
parentesi: `(2 + 3) * 4` vale `20` e non si sbaglia a leggerlo. Le parentesi sono tue amiche:
rendono il programma chiaro a chi lo legge, e chi lo legge sarà spesso te stesso.

Oltre ai numeri, ci sono gli operatori di **confronto**, che producono un `Bool` (`true` o
`false`), e gli operatori **logici**, che combinano le verità:

| operatore | significato | esempio | risultato |
|---|---|---|---|
| `==` | uguale a | `2 == 2` | `true` |
| `!=` | diverso da | `2 != 2` | `false` |
| `<` `<=` `>` `>=` | minore, minore o uguale, maggiore, maggiore o uguale | `10 > 3` | `true` |
| `&&` | e (vero se entrambi sono veri) | `true && false` | `false` |
| `\|\|` | o (vero se almeno uno è vero) | `true \|\| false` | `true` |
| `!` | non (inverte la verità) | `!false` | `true` |

```triad
println(2 + 3 * 4)
println((2 + 3) * 4)
println(7 % 3)
println(2 ^ 10)
println(10 > 3, " ", 2 == 2, " ", 2 != 2)
println(true && false, " ", true || false, " ", !false)
eta = 17
println(eta >= 18 ? "maggiorenne" : "minorenne")
```

Output:

```text
14
20
1
1024
true true false
false true true
minorenne
```

L'ultima riga introduce una forma comoda, il **condizionale ternario**: `condizione ? a : b`
produce `a` se la condizione è vera, `b` se è falsa. Serve quando il programma deve scegliere un
valore, non eseguire un blocco di istruzioni: la forma estesa della scelta è l'`if` del
[capitolo 7](#fond-7).

Un avvertimento su due simboli che confondono tutti i principianti: `=` **assegna** (fa diventare
qualcosa), `==` **confronta** (chiede se due cose sono uguali). Scrivere `if x = 0` quando si
intendeva `if x == 0` è l'errore più classico della storia della programmazione: in Triad produce
un errore del linguaggio invece di un comportamento misterioso, ma l'abitudine di leggere `=` e
`==` come due parole diverse va presa subito.

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

---

<a id="fond-6"></a>

## 6. Stringhe: lavorare col testo

Una **stringa** è un testo trattato come dato: si scrive tra virgolette doppie, si può associare a
una variabile, passare a una funzione, costruire pezzo per pezzo. Le operazioni di base sono la
**concatenazione** con `*`, che unisce due stringhe, e qualche funzione per misurarle e
convertirle:

| operazione | che cosa fa | esempio | risultato |
|---|---|---|---|
| `a * b` | incolla le due stringhe | `"ciao " * "Ada"` | `"ciao Ada"` |
| `length(s)` | quanti byte contiene `s` | `length("ciao")` | `4` |
| `string(x)` | trasforma un valore in testo | `string(40 + 2)` | `"42"` |
| `Int(s)` | trasforma un testo in numero intero | `Int("41") + 1` | `42` |

```triad
nome = "Triad"
saluto = "ciao " * nome
println(saluto)
println("riga1\nriga2")
println("la risposta è " * string(40 + 2))
println(length("ciao"))
println(Int("41") + 1)
```

Output:

```text
ciao Triad
riga1
riga2
la risposta è 42
4
42
```

La seconda riga dell'output mostra gli **escape**: dentro una stringa, `\n` non sono due caratteri
ma il comando «vai a capo», e `\t` è una tabulazione. Se vuoi scrivere una virgoletta dentro una
stringa, usa `\"`. Il carattere `\` diventa `\\`. Questi sono tutti gli escape di Triad-Core; se
ne vedi altri, non fidarti.

**Nota di implementazione.** Gli escape valgono come descritto, ma il seed in codice macchina
attuale non li processa: legge i byte grezzi fino alla virgoletta di chiusura, quindi
`println("riga1\nriga2")` su quel runtime stampa `riga1\nriga2` su una riga sola. Anche `Int("41")`
non è ancora disponibile sul seed. Sull'interprete di riferimento l'output è quello mostrato
(`TASK.md`, «Colmare i limiti del seed»).

Tre regole da sapere sulle stringhe:

- Le stringhe sono **immutabili**: non si può cambiare un carattere dentro una stringa esistente.
  Ogni operazione come la concatenazione ne produce una **nuova**. Non è un limite pratico, è una
  regola che rende i programmi più prevedibili.
- `length` conta i **byte**, non le lettere: per l'italiano con le accentate la differenza si
  vede (`length("è")` è `2`, non `1`). Nei primi programmi non importa; è bene solo saperlo.
- `Int("42")` funziona se il testo **è** un numero: `Int("ciao")` è un errore del programma,
  non un risultato «nullo». Chi converte testo in numero deve prima controllare che il testo sia
  un numero.

Il motivo per cui esistono `string` e `Int` è presto detto: i numeri si calcolano, i testi si
stampano e si leggono. Per passare dall'uno all'altro mondo serve la conversione esplicita —
un altro piccolo atto di precisione che il linguaggio ti chiede.

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

---

<a id="fond-7"></a>

## 7. Decisioni: `if`, `elseif`, `else`

Fino a qui ogni istruzione è stata eseguita una volta, in ordine. Il primo salto di qualità è
poter dire: **se** è vero questo, fai una cosa, **altrimenti** ne fai un'altra. Si scrive con
`if`:

```triad
punteggio = 15
if punteggio >= 18
    println("promosso")
else
    println("bocciato")
end
```

Output:

```text
bocciato
```

La struttura è sempre la stessa: la parola `if`, una **condizione** (un'espressione che vale
`true` o `false`), le istruzioni da eseguire se la condizione è vera, poi `else` con le istruzioni
del caso contrario, e infine `end` che chiude la costruzione. L'indentazione (gli spazi a inizio
riga) non è obbligatoria per il computer, ma lo è per chi legge: rende visibile la struttura.

Quando i casi sono più di due, si aggiungono rami con `elseif`:

```triad
x = -3
if x > 0
    println("positivo")
elseif x == 0
    println("zero")
else
    println("negativo")
end
```

Output:

```text
negativo
```

L'`if` prova le condizioni una alla volta, dall'alto in basso, ed esegue **solo** il primo ramo
la cui condizione è vera; se nessuna condizione è vera esegue `else`, se non c'è `else` non fa
niente. Per questo l'ordine dei rami conta: `elseif x == 0` va dopo `x > 0` e prima dell'`else`,
che è il ramo «per tutti gli altri casi».

Le regole da ricordare sono tre. La condizione deve essere un `Bool`: in Triad non esistono
valori «falsi per convenzione» come lo zero o il testo vuoto in altri linguaggi, e `if 1` è un
errore (`error: if cond`). Ogni `if` va chiuso con `end`, e dimenticarlo produce un
`parse error`. Infine `else if` (con lo spazio) **non** è `elseif`: sono due parole che aprono un
`if` annidato, che richiede un `end` in più; se ti ritrovi con `end` che non tornano, guarda lì.

Un `if` è anche un'espressione, e produce un valore — quello del ramo eseguito. Questo permette
scelte compatte come `stato = eta >= 18 ? "maggiorenne" : "minorenne"`, oppure:

```triad
x = 3
etichetta = if x > 2
    :grande
else
    :piccolo
end
println(etichetta)
```

Output:

```text
grande
```

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

---

<a id="fond-8"></a>

## 8. Ripetizioni: `while`

Il computer è bravissimo a ripetere: è letteralmente ciò che sa fare meglio. La ripetizione si
chiama **ciclo** (o *loop*), e il ciclo di Triad-Core è il `while`: «finché questa condizione è
vera, ripeti queste istruzioni».

```triad
i = 1
while i <= 5
    println(i)
    i += 1
end
```

Output:

```text
1
2
3
4
5
```

Il `while` funziona così: controlla la condizione; se è falsa, salta tutto il corpo del ciclo e
prosegue dopo `end`; se è vera, esegue le istruzioni del corpo e ricontrolla la condizione. Le
componenti del ciclo sono quindi sempre le stesse: una **variabile contatore** che cambia a ogni
girata (`i`), una **condizione di uscita** che arriva a essere falsa (`i <= 5`), e l'**avanzamento**
che porta lì (`i += 1`).

Se l'avanzamento manca o non viene eseguito, il ciclo non finisce mai: è il **ciclo infinito**, e
il programma gira senza produrre nulla di utile finché non lo interrompi tu (su terminale, con
`Ctrl+C`). Non è un dramma: capita a tutti. Se sospetti un ciclo infinito, guarda se la variabile
del contatore cambia davvero a ogni girata e se la condizione può diventare falsa.

Due precisazioni utili. La condizione di un `while` deve essere un `Bool`: in Triad non esiste
la «verità implicita» per cui `0`, una stringa vuota o una lista vuota valgono `false` (SPEC.md).
E se un ciclo infinito sfugge, in Triad-Full c'è un freno automatico: `with budget(steps = N) … end`
(cap. 13 del Manuale) interrompe il calcolo al posto tuo e restituisce un errore `Err(:budget)`;
in Triad-Core il freno resta il `Ctrl+C`.

Con il ciclo si risolvono tutti i problemi «fai questa cosa N volte» e «passa in rassegna questi
valori». Ecco due esempi classici — sommare e cercare:

```triad
somma = 0
n = 1
while n <= 100
    somma += n
    n += 1
end
println("somma: " * string(somma))

voti = [7, 4, 9, 6]
trovato = false
i = 1
while i <= length(voti)
    if voti[i] < 5
        trovato = true
    end
    i += 1
end
println(trovato)
```

Output:

```text
somma: 5050
true
```

**Nota di implementazione.** La parte «sommare» gira su ogni runtime. La parte «cercare» usa
`voti[i]`, l'accesso a un elemento di lista che imparerai al capitolo 9: il seed in codice
macchina attuale non lo implementa ancora — `voti[i]` non seleziona l'elemento — e quel
programma oggi stampa `false` invece di `true`, senza dare errori. Sull'interprete di
riferimento l'output è quello mostrato. I limiti misurati del seed sono elencati in `STATUS.md`;
il lavoro sull'indice di lista è tracciato in `TASK.md` (S0.2).

Due strumenti completano il quadro. `break` esce **immediatamente** dal ciclo, qualunque cosa dica
la condizione; `continue` salta alla girata successiva, cioè al nuovo controllo della condizione:

```triad
i = 0
while true
    i += 1
    if i % 2 == 0
        continue
    end
    if i > 7
        break
    end
    println(i)
end
println("fatto")
```

Output:

```text
1
3
5
7
fatto
```

Attenzione all'ordine dentro il corpo: se `continue` salta la riga che aggiorna il contatore, il
ciclo non finirà mai. L'aggiornamento va fatto **prima** del `continue`, come nell'esempio.

Entrambi agiscono sul ciclo **più interno** che li contiene: dentro due cicli annidati un
`break` ferma solo quello di dentro, e il ciclo esterno prosegue con le sue girate:

```triad
i = 1
while i <= 2
    j = 1
    while j <= 3
        if j == 2
            break
        end
        println(string(i) * "-" * string(j))
        j += 1
    end
    i += 1
end
```

Output:

```text
1-1
2-1
```

Per uscire in un colpo da **entrambi** i cicli non esiste una scorciatoia: si usa una variabile
di stato, che le condizioni di tutti e due controllano:

```triad
esci = false
a = 1
while a <= 3 && !esci
    b = 1
    while b <= 3 && !esci
        if a * b == 6
            esci = true
        else
            println(string(a) * "x" * string(b) * " = " * string(a * b))
        end
        b += 1
    end
    a += 1
end
println("fine")
```

Output:

```text
1x1 = 1
1x2 = 2
1x3 = 3
2x1 = 2
2x2 = 4
fine
```

Appena `a * b` arriva a 6, `esci` diventa `true` ed entrambe le condizioni lo vedono: il ciclo
interno chiude la girata corrente e quello esterno non ne comincia nessun'altra.

**Nota di implementazione.** `break` funziona su tutti i runtime attuali; `continue` fa parte
di Triad-Core (è nella grammatica di `SPEC-CORE.md`) ma il seed in codice macchina non lo
implementa ancora: con `bin/triad` l'esempio qui sopra si interrompe alla prima `continue` con
codice 1. Finché non sarà pronto (`TASK.md`, S0.4), la stessa identica logica si scrive
capovolgendo la condizione — e gira oggi su entrambi i runtime:

```triad
i = 0
while true
    i += 1
    if i > 7
        break
    end
    if i % 2 == 1
        println(i)
    end
end
println("fatto")
```

Output:

```text
1
3
5
7
fatto
```

---

### 8.1 Esercizi per sottogenere

Ogni problema «a ciclo», per quanto sembri diverso dagli altri, rientra quasi sempre in una di
queste cinque forme. Riconoscere la forma ti dice subito quali pezzi ti servono:

| sottogenere | domanda tipo | pezzi che servono |
|---|---|---|
| **Contatore** | «quante volte?» | contatore, condizione, avanzamento |
| **Accumulatore** | «qual è il risultato di tutti insieme?» | variabile risultato, aggiornamento a ogni girata |
| **Ricerca e decisione** | «ce n'è uno che…?» | condizione di scoperta, `break` o variabile di stato |
| **Cicli annidati** | «quali combinazioni?» | contatore interno ri-azzerato a ogni girata |
| **Sentinella** | «fino a quando?» | `while true`, `break` alla condizione di uscita |

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

### 8.2 Soluzioni

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

---

<a id="fond-9"></a>

## 9. Liste: tenere insieme molti valori

Una variabile contiene un valore; una **lista** contiene un elenco di valori, nell'ordine in cui
sono scritti. Si scrive tra parentesi quadre, con i valori separati da virgola:

```triad
frutta = ["mele", "pere", "banane"]
println(frutta)
println(frutta[1])
push!(frutta, "ciliegie")
println(frutta)
println(length(frutta))
```

Output:

```text
[mele, pere, banane]
mele
[mele, pere, banane, ciliegie]
4
```

**Nota di implementazione.** Questo programma è verificato sull'interprete di riferimento. Il
seed in codice macchina attuale non esegue ancora `frutta[1]`, non esegue `push!` scritto da solo
(la forma `frutta = push!(frutta, "ciliegie")` invece funziona) e non stampa liste di testi: il
programma qui sopra oggi si ferma dopo la sola `[`. Finché non saranno pronti (`TASK.md`, S0.2),
questi esempi vanno letti come sintassi corretta del linguaggio.

Le operazioni di base sono queste:

- `[a, b, c]` crea una lista; `[]` è la lista vuota. Una lista può contenere valori di tipi
  diversi, e anche altre liste.
- `xs[i]` è l'elemento nella posizione `i`. **Le posizioni partono da 1**: `frutta[1]` è il primo
  elemento, l'ultimo è `frutta[length(frutta)]`. Una posizione fuori dall'intervallo è un errore
  (`error: index out of range`), non un valore «vuoto».
- `xs[i] = v` sostituisce l'elemento in posizione `i`.
- `length(xs)` conta gli elementi.
- `push!(xs, v)` aggiunge `v` alla fine della lista. Il `!` nel nome dice che la funzione
  **modifica** la lista: è una convenzione di nomenclatura che Triad riprende da altri linguaggi.

Le liste sono **mutabili**, e questo ha una conseguenza che sorprende i principianti: due nomi
possono indicare la **stessa** lista.

```triad
xs = [1, 2, 3]
alias = xs
push!(alias, 4)
println(xs)
```

Output:

```text
[1, 2, 3, 4]
```

Ho aggiunto a `alias` eppure è cambiata anche `xs`: non perché ci sia un errore, ma perché dopo
`alias = xs` i due nomi guardano lo stesso oggetto, come due etichette sulla stessa scatola. Con
i numeri non succede (`y = x` copia il valore), con le liste sì. Se ti serve una copia vera, crea
una lista nuova e copia gli elementi uno a uno con un ciclo.

Il giro d'insieme di una lista — passare in rassegna tutti gli elementi — si scrive con un `while`
e un contatore, ed è talmente comune che vale la pena impararlo a memoria:

```triad
numeri = [3, 5, 8, 1]
totale = 0
i = 1
while i <= length(numeri)
    totale += numeri[i]
    i += 1
end
println(totale)
```

Output:

```text
17
```

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

---

<a id="fond-10"></a>

## 10. Funzioni: dare un nome a un'operazione

Scrivere le stesse quattro righe dieci volte è noioso e pericoloso: se trovi un errore, devi
correggerlo dieci volte. La soluzione di ogni linguaggio di programmazione è la **funzione**: un
pezzo di programma a cui dai un nome, che puoi **chiamare** quante volte vuoi.

```triad
quadrato(x) = x * x

function saluta(nome)
    "ciao " * nome
end

println(quadrato(7))
println(saluta("Ada"))
```

Output:

```text
49
ciao Ada
```

La prima funzione usa la **forma breve**: `quadrato(x) = x * x` significa «`quadrato` è la
funzione che, dato `x`, produce `x * x`». La seconda usa la **forma blocco**: `function` apre,
`end` chiude, e il valore prodotto dalla funzione è quello dell'**ultima espressione** del corpo
(qui `"ciao " * nome`). Le due forme sono equivalenti: la breve quando il corpo è un'espressione
sola, la blocco quando servono più istruzioni.

Quando scrivi `quadrato(7)`, si chiama la funzione: il valore `7` viene associato al parametro
`x`, il corpo viene eseguito e produce `49`, che prende il posto della chiamata nell'espressione.
I valori passati alla chiamata si chiamano **argomenti**; i nomi nella definizione si chiamano
**parametri**. Sono due parole per la stessa cosa, viste dai due lati.

Una funzione può avere più parametri (separati da virgola), può servire a isolare un calcolo
complesso, e — questa è la parte importante — può essere chiamata **da un'altra funzione**.
Costruire programmi significa proprio questo: comporre pezzi piccoli e affidabili in pezzi
più grandi.

```triad
function massimo(a, b)
    if a >= b
        a
    else
        b
    end
end

function area_rettangolo(larghezza, altezza)
    larghezza * altezza
end

println(massimo(3, 9))
println(area_rettangolo(5, 4))
```

Output:

```text
9
20
```

Per uscire da una funzione prima della fine si usa `return`: `return espressione` termina la
funzione subito, producendo quel valore. Nella maggior parte dei casi non serve, perché basta
l'ultima espressione, ma è l'ideale quando ci sono più strade di uscita:

```triad
function descrivi(n)
    if n < 0
        return "negativo"
    end
    if n == 0
        return "zero"
    end
    "positivo"
end

println(descrivi(-5), " ", descrivi(0), " ", descrivi(5))
```

Output:

```text
negativo zero positivo
```

Le regole pratiche da ricordare: il numero di argomenti nella chiamata deve coincidere con il
numero di parametri nella definizione (altrimenti `error: arity mismatch`); i parametri esistono
solo dentro la funzione — una variabile nata dentro la funzione non esiste fuori; e la funzione
produce un valore, che puoi usare, associare a una variabile o passare a un'altra funzione.

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

---

<a id="fond-11"></a>

## 11. Ricorsione: una funzione che chiama sé stessa

Una funzione può chiamare altre funzioni — compresa sé stessa. Si chiama **ricorsione**, e serve
per i problemi che si riducono allo stesso problema più piccolo: contare alla rovescia, calcolare
un fattoriale, attraversare una struttura ad albero. Vediamola in azione:

```triad
function conta_alla_rovescia(n)
    if n <= 0
        println("via!")
        return
    end
    println(n)
    conta_alla_rovescia(n - 1)
end

conta_alla_rovescia(3)
```

Output:

```text
3
2
1
via!
```

Seguiamo cosa succede: `conta_alla_rovescia(3)` stampa `3` e chiama `conta_alla_rovescia(2)`;
questa stampa `2` e chiama `conta_alla_rovescia(1)`; questa stampa `1` e chiama
`conta_alla_rovescia(0)`; quest'ultima trova `n <= 0`, stampa `via!` e termina con `return`.
Ogni chiamata aspetta che la chiamata successiva finisca, poi finisce anche lei. Le chiamate in
attesa si accumulano (il computer le tiene in una struttura chiamata *stack*) e si risolvono
nell'ordine inverso.

Ogni funzione ricorsiva ha bisogno di due pezzi: il **caso base**, che risolve subito il problema
più piccolo e **interrompe la catena** delle chiamate (qui `n <= 0`), e il **passo ricorsivo**,
che riduce il problema e richiama la funzione (qui `conta_alla_rovescia(n - 1)`). Se manca il
caso base, o se il problema non si riduce mai, le chiamate si accumulano all'infinito e il
programma termina con un errore: la ricorsione infinita è il corrispettivo ricorsivo del ciclo
infinito.

L'esempio classico per capire il valore della ricorsione è il **fattoriale**: il fattoriale di `n`
(o `n!`) è `n × (n-1) × … × 1`, e si può definire come «`n` per il fattoriale di `n-1`», con il
fattoriale di `1` che vale `1`:

```triad
fattoriale(n) = n < 2 ? 1 : n * fattoriale(n - 1)
println(fattoriale(5))
```

Output:

```text
120
```

La lettura è: `fattoriale(5)` vale `5 * fattoriale(4)`, che vale `5 * 4 * fattoriale(3)`, e così
via fino a `fattoriale(1)`, che vale `1` e chiude la catena. Il risultato
`5 * 4 * 3 * 2 * 1 = 120` risale indietro per le chiamate in attesa.

Non tutti i problemi chiedono la ricorsione: per «ripeti N volte» e «passa in rassegna la lista»
il ciclo `while` è più diretto. La ricorsione diventa naturale quando il problema **è** un albero
o una struttura fatta di pezzi simili, oppure quando la definizione del problema è già ricorsiva,
come il fattoriale. In entrambi i casi la domanda da farsi è sempre la stessa: qual è il caso
base, e come si riduce il problema?

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

---

<a id="fond-12"></a>

## 12. Errori e debug: cosa fare quando il programma non funziona

Un programma che non funziona non è un fallimento: è la normalità del mestiere. Anche gli
programmatori esperti passano gran parte del tempo a correggere errori (in inglese, *bug*) e a
cercarli (*debug*). La differenza è che loro sanno leggere ciò che il computer risponde, e hanno
un metodo. Questo capitolo ti dà entrambe le cose.

### 12.1 Le due famiglie di errori

Quando esegui un programma sbagliato, il messaggio che vedi appartiene a una di due famiglie:

- **`parse error:`** — l'interprete non è riuscito a **leggere** il programma. Qualcosa non torna
  nella forma: una parentesi non chiusa, un `end` mancante, una parola scritta male. Il programma
  non è nemmeno cominciato: l'interprete si è fermato mentre lo analizzava.
- **`error:`** — il programma è stato letto, è cominciato, e si è fermato **durante
  l'esecuzione**: una variabile senza valore, un'operazione tra tipi che non si combinano, una
  posizione fuori lista. L'esecuzione si interrompe nel punto dell'errore.

In entrambi i casi il programma termina con **codice di uscita `1`** (il codice è il numero con cui
un programma «risponde» al terminale: `0` significa tutto bene). I messaggi vanno sul canale di
errore del terminale, ma ti arrivano comunque sugli occhi.

### 12.2 I messaggi più comuni, tradotti in italiano

| messaggio | che cosa significa | la causa tipica |
|---|---|---|
| `parse error: expected IDENT end` | manca un `end` oppure c'è una parola inattesa | `if` o `function` o `while` non chiusi |
| `parse error: expected RPAREN` | manca una parentesi tonda | `println("ciao"` senza chiudere |
| `error: undefined variable x` | `x` non è mai stata assegnata | refuso nel nome, o ordine sbagliato |
| `error: arity mismatch` | numero di argomenti sbagliato nella chiamata | `f(1, 2)` per una funzione con un parametro |
| `error: + type error` | `+` usato tra valori di tipo incompatibile | `"ciao" + 1` (serve `*` e `string`) |
| `error: index out of range` | posizione fuori dalla lista | `xs[10]` quando la lista ha 4 elementi |
| `error: if cond` | la condizione non è un `Bool` | `if 1` oppure `if x = 0` (assegna!) |
| `error: not a function` | si è «chiamato» qualcosa che non è una funzione | `x()` dove `x` è un numero |

Leggere il messaggio è già mezzo lavoro: dice **che cosa** non è andato e, spesso, **dove**. La
prima domanda da farsi non è «perché non funziona?», ma «che cosa esattamente non ha funzionato,
secondo il messaggio?».

### 12.3 Il metodo in quattro passi

1. **Leggi il messaggio tutto intero**, senza saltare. Traducilo: quale regola del linguaggio è
   stata violata?
2. **Trova il punto**. Se il messaggio non dice la riga, guarda l'ultima riga di codice che hai
   modificato: il più delle volte l'errore è lì.
3. **Riduci il problema**. Commenta (con `#`) metà del programma e riesegui: se l'errore resta, è
   nella metà attiva; se sparisce, era nell'altra. Ripeti e dimezzi: in pochi passi sei alla riga
   colpevole.
4. **Verifica le ipotesi, una alla volta**. Stampa le variabili con `println` proprio prima del
   punto sospetto: i valori reali sono più affidabili di quelli che credi ci siano.

Quest'ultimo trucco — stampare i valori intermedi — è il debugger più antico del mondo e funziona
ancora benissimo. Un `println("qui, n = " * string(n))` inserito nel punto giusto dice se il
programma arriva lì e con quali valori: in un solo esame sai se il problema è «non ci arriva» o
«ci arriva con il valore sbagliato».

### 12.4 Gli errori dei principianti, per nome

- **`=` invece di `==`** in una condizione. Assegna invece di confrontare.
- **`end` mancante** (o in più). Ogni `if`, `while`, `function`, `let` aperti vanno chiusi.
- **`else if` invece di `elseif`**.
- **`+` tra stringhe**. In Triad la concatenazione è `*`.
- **Indice da 0**. Le liste di Triad partono da 1: il primo elemento è `xs[1]`.
- **Contatore del ciclo non aggiornato**, spesso per un `continue` scritto prima
  dell'aggiornamento: il ciclo non finisce più.
- **Variabile aggiornata nel punto sbagliato**: se la somma viene azzerata dentro il ciclo invece
  che prima, il risultato è sempre l'ultimo pezzo.
- **Refuso in un nome** (`punteggio` vs `punteggio_totale`): il linguaggio dice
  `undefined variable`, e ha ragione.

A tutto questo si aggiunge un errore «di mancanza»: credere che il computer faccia quello che
avevi in mente invece di quello che hai scritto. Il programma fa **esattamente** ciò che dice il
testo, mai ciò che volevi dire. Quando il risultato è misterioso, la domanda giusta è «che cosa
sta eseguendo davvero il programma, riga per riga?», e la risposta si trova rileggendo.

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
   classico del capitolo 8.1 potrebbe esserne la causa? Verifica la tua ipotesi.
10. **Allenamento al metodo.** Scrivi tre programmi sbagliati apposta (uno di sintassi, uno di
    tipo, uno di logica) e riscoprili usando solo il metodo in quattro passi.

---

<a id="fond-13"></a>

## 13. Pensare da programmatore: scomporre un problema

Scrivere programmi non è digitare velocemente: è **risolvere problemi**. Il computer esegue,
ma non aiuta: tocca a te capire che cosa fare, scomporlo in passi piccoli abbastanza da poter
essere scritti come istruzioni, e controllare che ogni passo faccia davvero quello che pensavi.
Questa è la parte che i programmatori chiamano *progettazione*, e si impara solo facendola. Un
metodo semplice, in cinque passi, basta per i primi programmi e regge anche per quelli grandi.

### 13.1 Capire il problema, con esempi in mano

Prima di scrivere una riga, riformula il problema con le tue parole e scrivi **almeno due esempi
di risultato atteso**, fatti a mano. Se non sai dire che cosa deve comparire a schermo per un
caso semplice, non lo saprà nemmeno il programma. Gli esempi servono anche più avanti: sono il
criterio con cui dire «funziona» oppure no — lo stesso meccanismo dei task e dei PASS/FAIL del
[capitolo 16](#fond-16).

Prendiamo un problema vero, piccolo ma non banale: *stampare tutti gli anni bisestili tra il 2000
e il 2040*. Esempi fatti a mano: il 2000 è bisestile (è divisibile per 400), il 2004 è bisestile,
il 2005 no. Una regola nota dice: un anno è bisestile se è divisibile per 4, e in più non è
un secolo oppure è divisibile per 400.

### 13.2 Scomporre in passi, in italiano

Scrivi i passi come se dovessi spiegarli a una persona pazientissima che non sa nulla del
problema. In italiano, non in codice: questa è la bozza del programma.

1. parti dall'anno 2000;
2. finché l'anno è minore o uguale a 2040:
3. — se l'anno è bisestile, stampalo;
4. — passa all'anno successivo;
5. quando superi il 2040, fermati.

Sembra banale scritto così, ed è esattamente il punto: la programmazione consiste nel rendere
espliciti passi che nella nostra testa erano impliciti. Nota che ogni riga della bozza corrisponde
a un costrutto che conosci già: un assegnamento, un `while`, un `if`, una `println`.

### 13.3 Prima la versione semplice, poi aggiungi

L'errore più comune del principiante è voler scrivere il programma completo subito. Invece si
procede per versioni: prima una versione che funziona **in un caso più semplice**, poi la si
guarnisce. La nostra bozza ha due pezzi indipendenti: il giro sugli anni e il riconoscimento
dell'anno bisestile. Prima il giro, che sappiamo già scrivere:

```triad
anno = 2000
while anno <= 2040
    println(anno)
    anno += 1
end
```

Output (primi tre e ultima riga):

```text
2000
2001
2002
...
2040
```

Funziona: il giro c'è. Ora resta da filtrare, e il filtro è la regola del caso a mano:
divisibile per 4 (`anno % 4 == 0`) **e** (`&&`) non un secolo (`anno % 100 != 0`) **oppure**
(`||`) divisibile per 400. Attenzione alle parentesi attorno al secondo pezzo: senza, la regola
si leggerebbe in un altro modo:

```triad
anno = 2000
while anno <= 2040
    if anno % 4 == 0 && (anno % 100 != 0 || anno % 400 == 0)
        println(anno)
    end
    anno += 1
end
```

Output:

```text
2000
2004
2008
2012
2016
2020
2024
2028
2032
2036
2040
```

Confronta l'output con gli esempi del passo 1: il 2000 c'è, il 2004 c'è, il 2005 non c'è. Il
caso limite più interessante è proprio il 2000: un anno secolo **è** bisestile solo se divisibile
per 400, e il programma lo stampa. Se il compito avesse compreso anche il 2100, il tuo esempio a
mano avrebbe scoperto il caso: per questo conviene inventarsene sempre qualcuno di scomodo.

### 13.4 Scrivere poco, verificare spesso

Ogni versione va **eseguita** prima di passare alla successiva. Se qualcosa non torna, non
continuare: un errore scoperto oggi costa un decimo di quello scoperto tra dieci righe. E quando
il programma è complesso, i tuoi migliori alleati sono le `println` di controllo — stampare un
valore intermedio «per vedere com'è» non è roba da principianti: è quello che fa anche
chi programma da trent'anni.

### 13.5 Quando sei bloccato

Succede a tutti, letteralmente. Una sequenza che funziona: **rileggi il testo del problema**
(molte volte il programma fa la cosa sbagliata per bene); **rifallo a mano** con un caso piccolo
scrivendo ogni passaggio; **simplifica** (commenta metà programma, vedi il [capitolo 12](#fond-12));
**rileggi il messaggio d'errore** per intero; e se proprio non ne vuoi uscire, **stacca**. Il
problema non scappa, e spesso la soluzione arriva mentre non stai guardando.

Ultima cosa, la più importante: progettare bene si impara solo progettando. Prendi gli esercizi
del [capitolo 14](#fond-14), applica questi cinque passi a ciascuno — capire, esempi, scomporre,
versione semplice, verificare — e dopo una decina di problemi il metodo non sarà più una lista
nel libro: sarà il tuo modo di lavorare.

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

---

<a id="fond-14"></a>

## 14. Esercizi

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
altri. La funzione `massimo` del [capitolo 10](#fond-10) torna utile:

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

<a id="fond-15"></a>

## 15. Glossario dei termini informatici

Le parole che seguono sono il vocabolario minimo del mestiere: il Manuale e il Tutorial le usano
dandole per note. Qui ciascuna ha la sua spiegazione in una riga.

| termine | che cosa significa |
|---|---|
| argomento | il valore passato a una funzione al momento della chiamata |
| assegnamento | l'operazione `=`: associare un valore a un nome di variabile |
| bug | un errore in un programma |
| caso base | la condizione che interrompe una ricorsione, risolvendo il caso più piccolo |
| chiamata | l'uso di una funzione, con i suoi argomenti: `quadrato(7)` |
| ciclo (loop) | un blocco di istruzioni eseguito più volte |
| codice / sorgente | il testo di un programma |
| compilatore | programma che traduce un intero programma in una forma eseguibile dal computer |
| condizione | un'espressione che vale `true` o `false` |
| contatore | variabile che tiene il conto delle girate di un ciclo |
| debug | l'attività di trovare e correggere gli errori di un programma |
| espressione | un calcolo che produce un valore |
| file | un documento salvato su disco, identificato da un nome |
| funzione | un pezzo di programma con un nome, che riceve argomenti e produce un valore |
| interprete | programma che esegue un altro programma istruzione per istruzione |
| iterazione | una singola girata di un ciclo |
| lista | un elenco ordinato di valori, raggiungibili per posizione |
| parametro | il nome con cui una funzione riceve un argomento |
| percorso | l'indirizzo di una cartella o di un file nel computer |
| ricorsione | una funzione che chiama sé stessa su un problema più piccolo |
| runtime | il programma che esegue i programmi Triad (interprete o compilatore) |
| stringa | un testo trattato come dato |
| terminale | la finestra in cui si danno comandi al computer scrivendoli |
| tipo | la categoria di un valore: numero intero, testo, verità, lista… |
| variabile | un nome associato a un valore, che può cambiare nel tempo |
| valore | un dato con cui il programma calcola: un numero, un testo, una lista… |

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

---

<a id="fond-16"></a>

## 16. Una domanda che capita spesso: cosa sono «success» e «fail»?

Chi guarda il progetto da fuori — sito, repository, benchmark — trova descrizioni come questa:
Triad si impara risolvendo piccoli **task** con operazioni aritmetiche e su stringhe, e le
soluzioni sono sottoposte a **tentativi** che finiscono in **success** (successo) o **fail**
(fallimento). La domanda che ne nasce è giusta, e merita una risposta precisa: *tentativi di
che cosa? e successo o fallimento rispetto a quale riferimento?*

### 15.1 Il riferimento: la verifica automatica di un task

Un **task** è un piccolo esercizio di programmazione: un problema da risolvere scritto in
linguaggio naturale, con alcuni esempi di ciò che il programma deve produrre. Nel repository,
la cartella `ai/tasks/` ne contiene alcuni che riguardano proprio le operazioni di base:
una somma (`01_sum`), un fattoriale (`02_factorial`), la successione di Fibonacci
(`03_fibonacci`), operazioni su stringhe (`04_strings`), una funzione che restituisce un'altra
funzione (`05_closures`). Il task consegna il problema; la soluzione è un programma Triad.

La **verifica** di una soluzione è interamente meccanica, e qui sta il punto: il programma
viene **eseguito** con l'interprete e il suo output viene **confrontato** con quello che il
task dichiara atteso. Se coincidono, l'esito è **PASS** (successo); se non coincidono — o se
il programma va in errore e non produce nulla — l'esito è **FAIL** (fallimento). «Successo» e
«fallimento» non sono dunque proprietà misteriose del linguaggio: sono il **verdetto di un
confronto** tra ciò che il programma fa e ciò che il task si aspetta. Il riferimento, in altre
parole, è **l'output atteso scritto nel task** — nient'altro.

Si può vedere tutta la faccenda in piccolo, con un programma che fa entrambe le parti —
calcola la risposta e la confronta con l'atteso:

```triad
atteso = "42"

risposta() = 6 * 7

if string(risposta()) == atteso
    println("PASS")
else
    println("FAIL")
end
```

Output:

```text
PASS
```

Se `atteso` fosse `"43"`, lo stesso programma stamperebbe `FAIL`: non perché il calcolo sia
sbagliato, ma perché il **confronto** non è andato a buon fine. Il verdetto dice «questa
soluzione soddisfa il task», non «questo programma è giusto in assoluto» — ed è per questo che
ogni task specifica con cura i propri esempi attesi: sono il criterio con cui si misura.

### 15.2 I tentativi: pass@1 e pass@k

Restano i «tentativi». Quando si misura la capacità di un modello di intelligenza artificiale
di scrivere Triad, non gli si chiede una soluzione sola: gli si chiedono **più soluzioni dello
stesso task**, una per tentativo, e ciascuna viene verificata da sola, con lo stesso confronto di
prima. Un tentativo è quindi **una generazione della soluzione**, e il suo esito è PASS o FAIL:

```triad
atteso = "42"
tentativi = ["41", "43", "42"]
i = 1
while i <= length(tentativi)
    esito = tentativi[i] == atteso ? "PASS" : "FAIL"
    println("tentativo " * string(i) * ": " * tentativi[i] * " -> " * esito)
    i += 1
end
```

Output:

```text
tentativo 1: 41 -> FAIL
tentativo 2: 43 -> FAIL
tentativo 3: 42 -> PASS
```

Le metriche del benchmark (`ai/README.md`) si leggono esattamente così. **pass@1** significa:
«il primo tentativo risolve il task» — la misura più severa, quella che conta solo la soluzione
che esce giusta subito. **pass@k** significa: «dati k tentativi per task, ne basta uno che
riesca» — *il primo che riesce conta*. Sono due modi di rispondere alla domanda «quanto è
affidabile chi scrive questo codice?»: pass@1 misura la precisione al primo colpo, pass@k
misura se, dato qualche tentativo, il task alla fine si risolve. Un modello con pass@k alto e
pass@1 basso «ci arriva», ma ci riprova.

### 15.3 Le altre due facce di «successo e fallimento» in Triad

Le stesse due parole ricorrono in altri due punti del progetto, ed è utile saperle
riconoscere per non confonderle con quelle del benchmark.

Il primo l'hai già incontrato nel [capitolo 12](#fond-12): quando un programma termina, lo fa
con un **codice di uscita** — `0` significa successo, `1` errore, `2` uso non valido del
comando. È il verdetto sull'intera esecuzione, non su una singola risposta: un programma che
stampa l'output giusto ma va in errore alla fine esce comunque con `1`.

Il secondo appartiene alla **programmazione logica** di Triad-Full, la parte del linguaggio in
cui si descrivono fatti e regole e si fanno domande (`solve`) al sistema. Lì ogni domanda —
ciò che il linguaggio chiama *goal* — può **riuscire o fallire**: riesce se il sistema trova
un modo di renderla vera collegando le variabili, fallisce se nessun modo esiste. E poiché
una domanda può ammettere più risposte, il motore fa letteralmente dei **tentativi**: prova una
clausola, e se quella strada fallisce torna indietro e ne prova un'altra (si chiama
*backtracking*: riprendere da un bivio precedente e tentare la strada successiva). La traccia di una ricerca (`solve … trace`)
registra proprio questi tentativi con quattro etichette: `:call` (il tentativo comincia),
`:redo` (un nuovo tentativo sulla stessa domanda), `:exit` (il tentativo riesce), `:fail` (il
tentativo fallisce). Se incontri `success` e `fail` parlando di `fact`, `rule` o `solve`, il
riferimento è a questo: l'esito dei tentativi del motore logico, non la verifica di un task.

### 15.4 La domanda dietro la domanda

Tutte queste facce hanno lo stesso scheletro: il computer **confronta qualcosa con un criterio
preciso** — un output atteso, un codice di uscita, una condizione da dimostrare — e ne trae un
verdetto binario. Non c'è un «fallimento» da temere: un FAIL è informazione, il modo in cui la
verifica dice dove guardare. Anzi, nel lavoro di tutti i giorni — e questo libro lo darà per
fatto nei capitoli successivi — il FAIL arriva prima del PASS quasi sempre, e leggerlo bene è
metà del mestiere.

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
   il fallimento di un goal nella programmazione logica del capitolo 16.3.
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

---

<a id="fond-17"></a>

## 17. Domande da neofita

Le domande che seguono sono quelle che ogni persona pone nei primi mesi di programmazione —
nessuna è sciocca, e ognuna ha una risposta secca. Se ti riconosci in una, sei nel posto giusto.

**Devo imparare tutto a memoria?** No. Nessun programmatore conosce a memoria un intero
linguaggio: si ricordano i costrutti che si usano ogni giorno e si consulta il resto. Questo
libro ha apposta una scheda rapida ([Appendice B](#fond-appb)) e una grammatica: usarli non è
«barare», è il modo normale di lavorare. La memoria che conta è un'altra: riconoscere i
problemi e i modelli con cui si risolvono, e quella si costruisce solo scrivendo programmi.

**Perché il programma fa esattamente quello che scrivo e non quello che voglio?** Perché il
computer non legge nella mente, legge il testo. Se hai scritto `+` dove intendevi `*`, o
`=` dove intendevi `==`, il programma esegue fedelmente il tuo testo — e il risultato sembra
"sbagliato" solo rispetto a ciò che avevi in mente. È la prima lezione del mestiere, e non è
una tua mancanza: è la natura stessa del programmare.

**Quanto tempo ci vuole per imparare?** Per i fondamentali di questo libro bastano alcune
settimane di esercizi regolari; per sentirsi a proprio agio servono mesi di pratica, come per
qualsiasi mestiere. La variabile che conta non è il talento, è la costanza: un'ora al giorno
batte dieci ore il sabato.

**Va bene sbagliare così tanto?** Gli errori non sono un incidente del lavoro: **sono** il
lavoro. Anche un programmatore esperto passa gran parte del tempo a leggere messaggi d'errore e
correggere. L'unica differenza è che a lui non spaventano più. Il [capitolo 12](#fond-12) ti ha
dato il metodo; il resto viene con la pratica.

**Dove scrivo il codice? Serve un programma speciale?** In qualsiasi **editor di testo**: il
Blocco note va bene per cominciare, Visual Studio Code è meglio (colora il codice e ti avvisa
degli errori). Non usare il programma di videoscrittura (Word e simili): salva formattazione
invisibile che rovina il sorgente. Vedi [Appendice A](#fond-appa).

**Ho scritto il programma ma non parte: il computer dice che il comando non esiste.** Quasi
sempre il terminale è aperto nella cartella sbagliata, il nome del file ha un refuso, oppure
Node.js non è installato o non è nel `PATH`. La tabella diagnostica dell'Appendice A elenca
sintomo per sintomo i casi più comuni.

**Come faccio a sapere cosa si può scrivere in Triad?** Tre riferimenti: la **scheda rapida**
in Appendice B per ciò che hai imparato finora; la **grammatica** e le schede del Manuale per
l'elenco completo; e il runtime stesso, che ti dice subito se una forma non è ammessa. Il
confine tra Triad-Core (eseguibile oggi) e Triad-Full (definito dallo standard) è segnato nel
libro dai marcatori **[Core]** e **[Full]**.

**Posso fare programmi utili adesso?** Sì, entro i limiti di Triad-Core, che è piccolo apposta:
calcoli, conversioni, analisi di liste e di testi, piccoli algoritmi, giochi da terminale con
argomenti passati da riga di comando (`ARGS`, vedi il Tutorial). I programmi "da vero mondo" —
file, finestre, rete — richiedono librerie e parti del linguaggio che arriveranno con il
completamento di Triad-Full e del bootstrap: nel frattempo, ciò che stai imparando è la parte
che non cambia mai.

**Il mio programma gira all'infinito e non si ferma.** Hai un ciclo senza uscita: premi `Ctrl+C`
sul terminale per interromperlo e rileggi il [capitolo 8](#fond-8). Nove volte su dieci manca
l'aggiornamento del contatore, o la condizione del `while` non può mai diventare falsa.

**Cosa sono i numeri e le scritte in inglese negli errori?** Sono i messaggi del runtime: il
linguaggio li scrive in inglese perché è la convenzione dei linguaggi di programmazione. Il
[capitolo 12](#fond-12) traduce i più comuni; dopo un po' li riconoscerai a colpo d'occhio.

**Perché `42 + 1` funziona e `"42" + 1` no?** Perché il primo è un numero, il secondo un testo:
sono tipi diversi e non si combinano con `+`. La spiegazione è nel [capitolo 3](#fond-3), la
conversione esplicita nel [capitolo 6](#fond-6). È il tipo di errore che impara a evitare dopo
una settimana — e a prevedere da subito.

**Devo sapere l'inglese?** Non per questo libro, che è in italiano. Aiuta, perché la
documentazione tecnica e i messaggi dei linguaggi sono quasi sempre in inglese: ma si impara
anche strada facendo, e i termini tecnici essenziali sono nel glossario del [capitolo 15](#fond-15).

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

---

<a id="fond-18"></a>

## 18. Come proseguire

Hai appena costruito il vocabolario di base: valori, variabili, espressioni, decisioni,
ripetizioni, liste, funzioni, ricorsione, errori. Con questi concetti — e non servono altri per
iniziare — il resto del libro diventa leggibile. Ecco come è organizzato e come ti conviene
proseguire.

- Il **Manuale di Triad 2.0** spiega il linguaggio capitolo per capitolo: lessico, valori,
  controllo di flusso, funzioni, logica, errori, contratti, con esercizi a fine capitolo e
  riferimenti finali (grammatica, schede rapide, tabella degli errori, glossario, appendici). È
  il testo in cui approfondire ogni concetto che qui abbiamo solo sfiorato.
- Il **Tutorial di Triad 2.0** è il percorso pratico in cinque parti: primi passi (installare ed
  eseguire), Triad-Core passo per passo, Triad-Full (la parte completa dello standard), il codice
  del progetto e un riferimento rapido. Le parti I e II sono il seguito naturale di queste
  *Fondamenta*.

Due cose è bene sapere prima di proseguire. La prima: Triad ha **due profili di conformità**.
**Triad-Core** è il sottoinsieme del linguaggio che oggi è eseguibile — quello che abbiamo usato
in questa parte. **Triad-Full** è lo standard completo, con tipi dichiarati, programmazione
logica, macro, contratti e molto altro: definito e documentato, ma non ancora eseguibile
dall'runtime corrente. Nel libro, i marcatori **[Core]** e **[Full]** dicono a quale profilo
appartiene ogni costrutto, e i blocchi di codice sono etichettati `triad` (eseguibile oggi) o
`triad-full` (definito dallo standard). Ogni programma Core è anche un programma Full valido.

La seconda: per eseguire gli esempi Core basta l'interprete di riferimento, il comando
`node seed/dev/triad_core.cjs file.triad` che hai già usato. Niente altro da installare, niente
altro da imparare per ora: la macchina è già pronta.

Il percorso che consigliamo a chi parte da zero è questo: **Fondamenta** (questa parte) →
**Tutorial, parti I e II** (scrivere programmi Core veri) → **Manuale** (approfondire, con gli
esercizi) → **Tutorial, parte III** e capitoli del Manuale su Triad-Full (lo standard completo) →
**Tutorial, parte IV** (il codice del progetto, se vuoi vedere come il linguaggio è costruito).

Ultima raccomandazione, la più importante di tutto il libro: **scrivi codice**. La programmazione
si impara programmando, come il pianoforte si impara suonando: leggere non basta. Prendi gli
esempi, modificali, rompili e aggiustali; inventati i tuoi problemi piccoli e risolvili. Ogni
programma che esegui con successo ti lascia qualcosa che nessuna pagina può darti.

Due appendici chiudono questa parte e restano tue compagne per il cammino: l'**Appendice A**,
l'installazione guidata passo passo con la diagnosi dei guasti comuni, e l'**Appendice B**, la
scheda rapida della sintassi di tutto ciò che hai imparato, da tenere a portata di mano mentre
scrivi i tuoi primi programmi.

Buon lavoro, e buon codice.

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

<a id="fond-appa"></a>

## Appendice A — Installazione guidata passo passo

Questa appendice è per chi non ha mai installato uno strumento di programmazione: ogni passaggio
ha un **controllo** da fare prima di proseguire, così se qualcosa non torna lo sai subito e non
dopo venti passaggi. Al termine avrai sul computer tutto ciò che serve per eseguire ogni esempio
di questo libro. Tempo stimato: un quarto d'ora.

### A.1 Che cosa ti serve

- un computer Windows, macOS o Linux, con una connessione internet;
- **Node.js**, il programma che esegue i programmi Triad (l'interprete);
- un **editor di testo** per scrivere i sorgenti (il Blocco note va bene per cominciare);
- il **repository del progetto**, cioè la cartella con gli esempi e l'interprete.

### A.2 Passo 1 — Installare Node.js

1. Apri il browser e vai su <https://nodejs.org>.
2. Scarica la versione **LTS** (il sito la indica come «consigliata»): il sito riconosce da solo
   il tuo sistema operativo.
3. Avvia l'installatore e prosegui con le impostazioni predefinite («Avanti», «Avanti»,
   «Installa»). Su Linux segui le istruzioni del sito per la tua distribuzione.
4. **Chiudi e riapri il terminale**: un terminale aperto prima dell'installazione non vede i
   programmi nuovi.
5. Controlla, digitando nel terminale:

```sh
node --version
```

Devi vedere una riga come `v20.11.0`: il primo numero deve essere **18 o superiore**. Se il
terminale risponde che il comando non esiste, vai alla tabella [A.6](#fond-appa).

### A.3 Passo 2 — Ottenere il repository del progetto

Ci sono due strade equivalenti; scegli quella che ti è più comoda.

- **Senza Git** (adatta a chi comincia): apri la pagina
  <https://github.com/GPuntobit/triad2.0>, premi il pulsante verde **Code** e scegli
  **Download ZIP**. Estrai l'archivio in una cartella di tua scelta, per esempio nei Documenti:
  ne nascerà una cartella chiamata `triad2.0`.
- **Con Git**, se lo conosci già:

```sh
git clone https://github.com/GPuntobit/triad2.0.git
```

Ricorda dove hai messo la cartella `triad2.0`: ti servirà al passo successivo.

### A.4 Passo 3 — Il terminale nella cartella giusta

Il terminale lavora sempre **in una cartella**: prima di eseguire un programma devi portarlo
dove si trova il programma. Il comando è `cd` seguito dal percorso della cartella:

```sh
cd Documenti/triad2.0
```

Su Windows il percorso usa la barra rovesciata, per esempio:

```cmd
cd C:\Users\tuo-nome\Documents\triad2.0
```

Controllo: digita `ls` (Windows: `dir`). Devi vedere elencate cartelle come `seed/`,
`conformance/`, `docs/`, `cli/`. Se le vedi, sei nel posto giusto.

### A.5 Passo 4 — Il programma di prova

Scrivi il programma del [capitolo 2](#fond-2) in un file chiamato `ciao.triad`, salvalo dentro la
cartella `triad2.0`, e dal terminale esegui:

```sh
node seed/dev/triad_core.cjs ciao.triad
```

Atteso:

```text
ciao, Triad
```

Se vedi `ciao, Triad`, l'installazione è completa e questo libro è tutto alla tua portata. Vuoi
un secondo controllo, con un programma già pronto nel repository? Esegui:

```sh
node seed/dev/triad_core.cjs conformance/core/cases/aritmetica/program.td
```

Atteso: una colonna di numeri che comincia con `14`, `20`, `1`, `1024`.

### A.6 Se qualcosa non funziona

Prima di pensare a un problema grave, guarda la tabella: i guasti di installazione sono pochi e
sempre gli stessi.

| sintomo | causa probabile | rimedio |
|---|---|---|
| «`node` non è riconosciuto come comando» (Windows) o `command not found: node` | Node.js non installato, oppure il terminale era aperto prima dell'installazione | reinstalla Node.js da nodejs.org, poi **chiudi e riapri** il terminale |
| `Cannot find module ... triad_core.cjs` | il terminale è aperto nella cartella sbagliata | `cd` nella cartella `triad2.0` e ricontrolla con `ls`/`dir` (passo A.4) |
| `error: file non leggibile` o `ENOENT` con il nome del programma | il file non è dove pensi, o il nome è diverso | controlla nome ed estensione: deve essere `ciao.triad`, non `ciao.triad.txt` |
| il file si apre in Word, o con icone strane | salvato come documento formattato | salva di nuovo come **testo semplice**: «Salva con nome» → tipo «Tutti i file» → nome `ciao.triad` → codifica UTF-8 |
| il programma non si ferma più | ciclo senza uscita | premi `Ctrl+C` sul terminale; poi [capitolo 8](#fond-8) e [capitolo 17](#fond-17) |
| nell'output le accentate appaiono strane | il file non è salvato in UTF-8 | salva in codifica UTF-8 (l'editor la chiama «UTF-8» o «Unicode») |
| il programma risponde `error: …` o `parse error: …` | non è un guasto di installazione: è il programma che segnala un problema | [capitolo 12](#fond-12) |

### A.7 Windows, macOS e Linux: le differenze

Sono poche e nessuna cambia il programma: i percorsi usano `\` su Windows e `/` altrove; per
elencare i file si digita `dir` su Windows e `ls` su macOS e Linux; il resto — editor, comandi
`node`, testo dei programmi — è identico. Dove servono entrambe le forme, questo libro mostra
quella Linux/macOS: su Windows cambia solo la barra.

---

<a id="fond-appb"></a>

## Appendice B — Scheda rapida della sintassi (Triad-Core)

Questa è la pagina da tenere aperta mentre scrivi: tutto ciò che le Fondamenta insegnano, in
ordine di uso, con la forma esatta da digitare. Solo **Triad-Core**, cioè ciò che oggi è
eseguibile; il resto del linguaggio (Triad-Full) è nel Manuale e nella parte III del Tutorial.

### B.1 Il minimo indispensabile

| cosa | forma | note |
|---|---|---|
| commento di riga | `# fino a fine riga` | ignorato dall'interprete |
| commento lungo | `#= … =#` | non si annida |
| fine istruzione | a capo oppure `;` | uno spazio non basta |
| nome del file | `programma.triad` | alias storico: `.td` |
| eseguire | `node seed/dev/triad_core.cjs programma.triad` | da terminale, nella cartella giusta |

### B.2 Valori e tipi

| tipo | esempi | `typeof(v)` |
|---|---|---|
| `Int` | `42`, `0`, `-7`, `1_000` | `:Int` |
| `String` | `"ciao"`, `"42"`, `""` | `:String` |
| `Bool` | `true`, `false` | `:Bool` |
| `Symbol` | `:ok`, `:alice` | `:Symbol` |
| `List` | `[1, 2, 3]`, `[]` | `:List` |
| `Nothing` | `nothing` | `:Nothing` |

### B.3 Operatori

| gruppo | operatori | esempi |
|---|---|---|
| aritmetica | `+ - * % ^` | `7 % 3` → `1`; `2 ^ 10` → `1024` |
| confronto | `== != < <= > >=` | `2 == 2` → `true` |
| logica | `&& \|\| !` | `true && false` → `false` |
| assegnamento | `= += -= *=` | `n += 1` |
| scelta compatta | `cond ? a : b` | `x > 2 ? :grande : :piccolo` |

Attenzione: `=` **assegna**, `==` **confronta**. In Core non esistono `/` né i numeri decimali:
per dividere si usa il resto (`%`) o si aspetta Triad-Full. Quando hai dubbi sul raggruppamento,
usa le parentesi.

### B.4 Stampa e stringhe

| cosa | forma | esempio |
|---|---|---|
| stampare e andare a capo | `println(a, b)` | `println("ciao, ", "mondo")` |
| stampare senza a capo | `print(a)` | poi `println()` per chiudere la riga |
| unire stringhe | `a * b` | `"ciao " * "Ada"` |
| escape | `\n \t \" \\` | `"riga1\nriga2"` |
| lunghezza in byte | `length(s)` | `length("ciao")` → `4` |
| da valore a testo | `string(x)` | `string(40 + 2)` → `"42"` |
| da testo a intero | `Int(s)` | `Int("41") + 1` → `42` |

### B.5 Decisioni

```text
if condizione
    …
elseif altra_condizione
    …
else
    …
end
```

La condizione deve essere un `Bool`; ogni `if` si chiude con `end`; il ramo corretto è `elseif`,
non `else if`.

### B.6 Cicli

```text
i = 1
while i <= n
    …            # corpo
    i += 1       # avanzamento: non dimenticarlo!
end
```

`break` esce dal ciclo, `continue` passa alla girata successiva (dopo aver aggiornato il
contatore!).

### B.7 Liste

| cosa | forma | nota |
|---|---|---|
| creare | `xs = [1, 2, 3]` | anche miste e annidate |
| leggere | `xs[1]` | gli indici partono **da 1** |
| scrivere | `xs[i] = v` | anche `xs[i] += v` |
| contare | `length(xs)` | numero di elementi |
| aggiungere in coda | `push!(xs, v)` | modifica la lista (`!`) |
| giro completo | `while i <= length(xs)` … | contatore da 1 |

### B.8 Funzioni

| forma | esempio | quando |
|---|---|---|
| breve | `quadrato(x) = x * x` | corpo di una sola espressione |
| blocco | `function saluta(nome)` … `end` | più istruzioni; il valore è l'ultima espressione |
| anonima | `function (a, b)` … `end` | da passare o assegnare a un nome |
| lambda | `x -> x * 2` | forma compatta dell'anonima |
| uscita anticipata | `return espr` | termina la funzione subito |

Regole: gli argomenti devono essere **esattamente** quanto i parametri; le variabili nate nella
funzione esistono solo lì dentro; una funzione si può chiamare solo dopo la sua riga di
definizione.

### B.9 I messaggi d'errore, in pillole

| messaggio | significato |
|---|---|
| `parse error: …` | il programma non si legge: sintassi (spesso un `end` mancante) |
| `error: undefined variable x` | `x` non è mai stata assegnata (refuso?) |
| `error: arity mismatch` | numero di argomenti sbagliato nella chiamata |
| `error: + type error` | operazione tra tipi incompatibili (`"ciao" + 1`) |
| `error: index out of range` | posizione fuori dalla lista |
| `error: if cond` | la condizione non è un `Bool` |
| `error: not a function` | hai «chiamato» qualcosa che non è una funzione |

### B.10 Che cosa NON c'è in Triad-Core

Numeri decimali (`1.5`), la divisione `/`, il ciclo `for` e i range, l'interpolazione `"$x"`,
funzioni di lista come `map`/`filter`/`sort`, la lettura da tastiera. Sono parti di **Triad-Full**
(studiato nel Manuale e nella parte III del Tutorial) o di librerie che arriveranno: se li cerchi
e non li trovi, non è un tuo errore.
