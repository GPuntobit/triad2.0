<p align="center">
  <img src="https://raw.githubusercontent.com/GPuntobit/triad2.0/main/docs/triad-logo.webp" alt="Logo di Triad" width="160">
</p>

# Triad 2.0 — Tutorial: imparare il linguaggio e il codice del progetto

Questo tutorial è il percorso guidato con cui impari Triad partendo da zero. Non dà per
scontato che tu conosca il linguaggio: dà per scontato solo che tu sappia programmare in
qualche altro linguaggio. Se sai già scrivere cicli, funzioni e liste, hai tutto il necessario;
il resto — la sintassi di Triad, il comportamento dei valori, la distinzione tra il
sottoinsieme eseguibile e lo standard completo — è spiegato qui, nell'ordine in cui conviene
impararlo.

Il percorso porta a tre risultati. Primo, **scrivere programmi Triad-Core che girano davvero**,
cioè programmi completi, eseguibili oggi con l'interprete di riferimento. Secondo, **conoscere
Triad-Full**, il linguaggio completo definito dallo standard, comprese le parti che il runtime
attuale non esegue ancora. Terzo, **saper leggere il codice del progetto**: l'interprete di
riferimento, il seed in codice macchina, la suite di conformità e gli strumenti di sviluppo.
Il tutorial non rimanda altrove per capire i concetti: la specifica (`SPEC.md`, `SPEC-CORE.md`)
e i casi di `conformance/` sono approfondimenti facoltativi, non prerequisiti.

## Che cosa impari e come è organizzato

Il tutorial è un libro in cinque parti, pensate per essere lette in ordine ma abbastanza
autonome da poter essere consultate separatamente.

- **Parte I — Primi passi.** Che cos'è Triad, come si installa e si esegue, il primo
  programma spiegato riga per riga.
- **Parte II — Triad-Core passo per passo.** Il sottoinsieme eseguibile oggi, costrutto per
  costrutto: lessico, valori, variabili, espressioni, controllo di flusso, funzioni, chiusure,
  liste, stringhe, primitivi di bootstrap, errori e differenze tra i runtime. Gli esercizi
  guidati in fondo alla parte servono a fissare quello che hai letto.
- **Parte III — Triad-Full (lo standard completo).** Tipi dichiarati, multiple dispatch,
  struct, `for` e comprehension, logica con fatti e regole, macro, contratti, budget, tracce
  ed effetti. È il linguaggio definito dalla specifica: qui lo studi, ma il runtime attuale non
  lo esegue ancora.
- **Parte IV — Il codice del progetto.** Una visita guidata al repository: l'interprete di
  riferimento, il seed, S1, i casi di conformità, la CLI, il benchmark, il flusso di contributo.
  Serve a capire come il linguaggio è implementato, non solo come si usa.
- **Parte V — Riferimento.** Grammatica, schede rapide, messaggi di errore, glossario, stato
  del progetto e FAQ: capitoli da consultare, più che da leggere di seguito.

**Che cosa significa «eseguibile oggi».** Lo standard Triad definisce due profili di
conformità. Un esempio è *eseguibile oggi* quando gira, senza modifiche, su
un'implementazione che esiste già nel repository; è *definito dallo standard* quando la
specifica lo descrive ma nessun runtime attuale lo esegue. Il tutorial distingue sempre i due
casi, e ogni blocco di codice dichiara il profilo a cui appartiene.

| profilo | dove è definito | eseguibile oggi? |
|---|---|---|
| **Triad-Core** | `SPEC-CORE.md` | **sì**: i seed in codice macchina (`seed/windows-x86_64/seed.exe`, `seed/linux-x86_64/seed`) passano 42/42 casi Core byte per byte; anche l'interprete di riferimento JavaScript `seed/dev/triad_core.cjs` li passa tutti |
| **Triad-Full** | `SPEC.md` | **no**: struct, dispatch, logica, macro, contratti, budget, tracce, effetti, destrutturazione, `for`, `try`, `Float` sono specifica; nella conformance Full passa solo `errore` |

Due precisazioni sul contesto, utili per non confondere il libro con il progetto. La versione
dello standard è la `0.2.0`, registrata in `VERSION`. Triad non dipende da Julia: quella
vecchia implementazione è stata rimossa, e gli output Triad-Full che leggi nel libro sono i
**golden**, cioè i risultati attesi prodotti a suo tempo da quell'implementazione e congelati
in `conformance/cases/`; non sono stati riprodotti dal runtime attuale. Al contrario, ogni
esempio marcato **Output:** è un programma Triad-Core verificato con
`node seed/dev/triad_core.cjs`; gli esempi Full sono marcati **Output (golden Full):** oppure
non riportano output.

---

## Come usare questo tutorial

Non c'è un solo modo di leggere il libro: dipende da quello che ti serve. La tabella qui sotto
riassume i percorsi principali. Chi non conosce Triad, però, dovrebbe cominciare dalla Parte I:
i capitoli successivi danno per acquisito il lessico del linguaggio.

| vuoi… | leggi |
|---|---|
| scrivere programmi Triad che girano oggi | [Parte I](#parte-1) → [Parte II](#parte-2) (capitoli 4–17, con esercizi) |
| conoscere il linguaggio completo dello standard | [Parte III](#parte-3) (capitoli 18–32) |
| contribuire all'interprete JS, al seed, a S1, alla CLI o alla conformance | [Parte IV](#parte-4) (capitoli 33–43) |
| consultare grammatica, schede rapide, errori, glossario | [Parte V](#parte-5) (capitoli 44–49) |

Alcune convenzioni rendono più facile seguire gli esempi. I comandi sono mostrati per
Linux/macOS (`sh`) e, quando sono diversi, per Windows (`cmd`/PowerShell). I blocchi `triad`
contengono codice Core, normalmente eseguibile con l'interprete JS; i frammenti specifici del
seed Windows sono indicati nel testo. I blocchi `triad-full` mostrano codice definito dallo
standard Full, non ancora eseguibile dal runtime corrente. Con **interprete JS** si intende
`seed/dev/triad_core.cjs`, l'interprete di riferimento Triad-Core usato su Linux/macOS e dal
runner di conformità; con **seed** si intende `seed/windows-x86_64/seed.exe`, l'interprete
Triad-Core in codice macchina (S0). Dove i due si comportano diversamente lo dice il
[capitolo 15](#cap-15). I sorgenti si scrivono in file `.triad` (estensione canonica) o `.td`
(alias storico).

## Indice

**[Parte I — Primi passi](#parte-1)**
1. [Cos'è Triad](#cap-1)
2. [Installare ed eseguire](#cap-2)
3. [Il primo programma](#cap-3)

**[Parte II — Triad-Core passo per passo (eseguibile oggi)](#parte-2)**

4. [Lessico](#cap-4)
5. [Valori, tipi e stampa](#cap-5)
6. [Variabili e assegnamento](#cap-6)
7. [Operatori ed espressioni](#cap-7)
8. [Controllo di flusso](#cap-8)
9. [Funzioni](#cap-9)
10. [Lambda, chiusure e scope](#cap-10)
11. [Liste](#cap-11)
12. [Stringhe, simboli e conversioni](#cap-12)
13. [Primitivi di bootstrap](#cap-13)
14. [Errori di esecuzione](#cap-14)
15. [Interprete JS e seed Windows: differenze](#cap-15)
16. [Pattern idiomatici Triad-Core](#cap-16)
17. [Esercizi guidati](#cap-17)

**[Parte III — Triad-Full (lo standard completo)](#parte-3)**

18. [Lessico e tipi Full](#cap-18)
19. [Funzioni tipate e multiple dispatch](#cap-19)
20. [Struct](#cap-20)
21. [Controllo di flusso Full: `for`, range, comprehension, `try`](#cap-21)
22. [Logica: fatti, regole, `solve`](#cap-22)
23. [Destrutturazione](#cap-23)
24. [Errori come dati](#cap-24)
25. [Contratti](#cap-25)
26. [Budget](#cap-26)
27. [Tracce](#cap-27)
28. [Effetti dichiarati](#cap-28)
29. [Codice come dato, albero uniforme e macro](#cap-29)
30. [Builtin Full](#cap-30)
31. [Riga di comando e REPL (SPEC §14)](#cap-31)
32. [Esempi Full con output golden](#cap-32)

**[Parte IV — Il codice del progetto](#parte-4)**

33. [Mappa del repository](#cap-33)
34. [L'interprete di riferimento JS (`seed/dev/triad_core.cjs`)](#cap-34)
35. [Il seed S0 Windows e il suo generatore](#cap-35)
36. [Il seed Linux (E2)](#cap-36)
37. [Self-hosting: S1 in `selfhost/`](#cap-37)
38. [Conformance: leggere, scrivere e verificare casi](#cap-38)
39. [La CLI di sviluppo `triad-cli`](#cap-39)
40. [Benchmark AI (`ai/`)](#cap-40)
41. [Editor, launcher e sito](#cap-41)
42. [Integrazione continua](#cap-42)
43. [Flusso di contributo](#cap-43)

**[Parte V — Riferimento](#parte-5)**

44. [Grammatica Triad-Core (EBNF)](#cap-44)
45. [Schede rapide Core e Full](#cap-45)
46. [Debug e problemi comuni](#cap-46)
47. [Glossario](#cap-47)
48. [Stato, limiti noti e fix storici](#cap-48)
49. [FAQ](#cap-49)

---

<a id="parte-1"></a>

# Parte I — Primi passi

<a id="cap-1"></a>

## 1. Cos'è Triad

Triad è un linguaggio di programmazione autonomo che riunisce tre paradigmi — imperativo,
logico e metaprogrammatorio — in un'unica sintassi a blocchi. L'idea di fondo è che questi
paradigmi non vadano tenuti in linguaggi separati: un programma Triad può definire funzioni e
cicli come un linguaggio imperativo, dichiarare fatti e regole come Prolog e trattare il codice
come un valore costruibile e trasformabile come in Lisp, e le tre cose convivono nello stesso
file senza strati né interfacce.

Le influenze dichiarate sono tre, e per ciascuna il libro mostrerà via via che cosa Triad ha
ripreso:

| influenza | idea ripresa in Triad |
|---|---|
| Julia | `function … end`, `struct`, tipi con `::`, multiple dispatch, operatori come funzioni, `if`/`for`/`while`/`let` |
| Prolog | `fact`, `rule`, unificazione con occurs-check, backtracking, `solve` con variabili logiche `?x` |
| Lisp | codice come dato (`Node`), `:( … )`/`quote` con `$`, macro |

A questi si aggiungono, come parte del linguaggio e non di una libreria: **errori come dati**
(`Err`), **contratti** (`requires`/`ensures`), **budget** (`with budget`), **tracce**
(`with trace`) ed **effetti dichiarati** (`!io`, `!state`).

La distinzione tra «parte del linguaggio» e «libreria» non è nominale, e vale la pena capirla
subito. Un errore che è un valore può essere restituito, ispezionato e composto come qualsiasi
altro dato, invece di interrompere il programma; un contratto scritto nella firma è visibile
all'implementazione, che può controllarlo; un effetto dichiarato permette al runtime di
verificare che una funzione pura non stampi. Sono tutte funzionalità che un linguaggio può
offrire solo se le conosce, e per questo Triad le definisce nello standard anziché lasciarle a
convenzioni tra programmatori.

Da Julia arriva l'ossatura della sintassi: blocchi `function … end`, tipi con `::`, struct e
multiple dispatch. Da Prolog arriva il motore logico: fatti, regole, unificazione con
occurs-check, backtracking e `solve` con variabili logiche. Da Lisp arriva l'idea che il codice
sia un albero uniforme, quindi un valore come gli altri, e la macchina delle macro che su
quell'idea si appoggia. Tenere insieme i tre modelli è la parte propriamente nuova: non esiste
un «linguaggio del lunedì» e un «linguaggio del martedì», esiste un solo programma con una sola
semantica di espressioni e di blocchi.

### 1.1 Due profili: Core e Full

Lo standard definisce due profili di conformità (SPEC §16.1):

- **Triad-Core** ([`SPEC-CORE.md`](SPEC-CORE.md)): interi, Bool, stringhe, simboli, `nothing`,
  liste, funzioni, lambda e chiusure, `if`/`elseif`/`else`, `while`, `let`, `begin`, ternario,
  `return`/`break`/`continue`, più alcuni primitivi di bootstrap. È abbastanza piccolo da
  essere implementato in codice macchina scritto a mano e abbastanza espressivo da scriverci
  l'interprete di tutto Triad.
- **Triad-Full** ([`SPEC.md`](SPEC.md)): tutto il linguaggio.

La separazione risponde a un vincolo pratico, non a una scelta di comodo. Il primo interprete
di Triad deve esistere prima che esista un compilatore Triad, quindi va scritto a mano in codice
macchina: più il linguaggio è piccolo, più quel compito è realistico. Allo stesso tempo il
sottoinsieme deve bastare a scrivere l'interprete completo nella seconda fase. Triad-Core è
esattamente il punto di equilibrio tra le due esigenze, e per questo è definito da una
specifica a sé.

Ogni programma Triad-Core (esclusi i primitivi di bootstrap) è anche un programma Triad-Full
valido e deve comportarsi allo stesso modo. Il contrario non vale: un programma che usa `struct`,
`for` o `float` è Full, e il runtime Core non lo eseguirà. È la distinzione che ritroverai in
tutto il libro: la Parte II insegna il profilo che gira oggi, la Parte III aggiunge il resto.

### 1.2 La catena di bootstrap

Triad non vuole dipendere da nessun linguaggio ospite, ma ogni linguaggio deve pur partire da
qualcosa. La catena di bootstrap risolve il problema in tappe: si comincia con un interprete
scritto a mano in codice macchina, lo si usa per eseguire un interprete scritto in Triad, e
così via fino a un compilatore che compila se stesso. Il piano ([`BOOTSTRAP.md`](BOOTSTRAP.md)):

```
S0  seed: interprete Triad-Core in codice macchina x86-64 (dump esadecimale nel repo)
S1  interprete di tutto Triad scritto in Triad-Core      (selfhost/, in corso)
S2  compilatore nativo scritto in Triad                  (non iniziato)
S3  compilatore self-hosted: S2 compilato da S2          (non iniziato)
S4  Triad completo: REPL, CLI, tooling, parità Linux     (non iniziato)
```

Il seed S0 non è distribuito come eseguibile ma come dump esadecimale: è il modo più semplice
per versionare un binario in un repository testuale, e si materializza con lo strumento di
decodifica del sistema operativo ([capitolo 2](#cap-2)). Gli stadi S1–S4 sono la direzione del
progetto, non ciò che serve per leggere questo libro: per seguire il tutorial basta il seed S0
o l'interprete JS.

Gli strumenti di sviluppo (`seed/dev/*.js` e `cli/` in Node.js, gli harness
`conformance/run.sh` e `verify.sh` in shell POSIX) sono **strumenti di
sviluppo**: aiutano a generare e verificare, ma non fanno parte della catena S0→S4. La Parte IV
del libro li presenta uno per uno, spiegando che cosa fanno e perché sono esterni al bootstrap.

### Esercizi

1. **Core o Full?** Classifica: `while`, `fact`, `struct`, `lambda`, `for`, `macro`, `push!`,
   `solve`, `try`, `println`.
2. **Perché due profili.** Spiega con le tue parole perché il linguaggio ha un profilo Core
   «di bootstrap» e uno Full «standard».
3. **La catena di bootstrap.** Ordina e descrivi le tappe S0–S4: quale è realizzata oggi?
4. **Cosa gira oggi.** Che cosa può fare il seed Linux attuale? E il seed Windows?
5. **Core dentro Full.** Scrivi un programma Core e spiega perché è anche un programma Full
   valido, e che cosa gli sarebbe richiesto in più.
6. **Le fonti normative.** Quali file del repository definiscono il linguaggio? Trovali e apri
   la sezione sugli operatori.
7. **I runtime.** Individua nel repository l'interprete JS di riferimento e il generatore del
   seed Windows: in quali file stanno?
8. **Golden e verifiche.** Perché per gli esempi Full si parla di output golden? Che cosa
   distingue un output verificato da uno atteso?
9. **Tre cose proprie.** Elenca tre aspetti di Triad che non vengono da Julia, Prolog o Lisp.
10. **Il tuo primo Core.** Scrivi un programma che usi variabile, `if` e `while`, eseguilo con
    l'interprete JS e conferma che sia Core puro.

---

<a id="cap-2"></a>

## 2. Installare ed eseguire

«Installare» Triad qui non significa installare un pacchetto: significa avere il repository e
uno dei due runtime disponibili. Non esiste ancora un compilatore da aggiungere al sistema, né
un gestore di pacchetti del linguaggio. Il capitolo risponde quindi a due domande concrete: come
si esegue un file e da quale runtime conviene partire.

La scelta consigliata per chi comincia è l'**interprete JS**: si avvia con Node.js, non richiede
di decodificare binari ed è quello con cui vengono verificati i casi di conformità. Il seed
Windows è interessante quando vuoi vedere il linguaggio eseguito senza runtime ospiti; i suoi
limiti sono elencati nel [capitolo 15](#cap-15). Per seguire il libro puoi usare solo l'interprete
JS, e passare al seed quando un capitolo lo richiede.

### 2.1 Requisiti

- **Node.js ≥ 18** (la CI usa Node 20) per l'interprete JS, il runner di conformance e la CLI.
- Su Windows, nient'altro per il seed: `seed.exe` si ottiene decodificando `seed.hex` con
  `certutil`.
- Git per clonare il repository: `git clone https://github.com/GPuntobit/triad2.0.git`.

I requisiti sono pochi di proposito: Triad non vuole dipendenze da altri linguaggi per eseguire i
programmi, e l'unica dipendenza dello strumentario di sviluppo è Node.js. Se hai Node.js, hai già
tutto ciò che serve per eseguire gli esempi della Parte II.

### 2.2 Eseguire un file

Un programma Triad è un file di testo che il runtime legge, analizza ed esegue. La tabella
mostra come avviarlo sulle due piattaforme e come passargli lo script da stdin:

| piattaforma | comando |
|---|---|
| Linux / macOS | `node seed/dev/triad_core.cjs file.triad arg1 arg2` |
| Windows (seed) | `seed\windows-x86_64\seed.exe file.triad` oppure `bin\triad.cmd file.triad` |
| qualsiasi (stdin, interprete JS) | `echo 'println(7 * 6)' \| node seed/dev/triad_core.cjs -` |

Esempi pronti che girano oggi: tutti i `conformance/core/cases/*/program.td`, cioè i casi che
il libro cita come riferimento normativo in fondo a ogni capitolo.

```sh
node seed/dev/triad_core.cjs conformance/core/cases/ricorsione/program.td   # 120, 55
```

```cmd
bin\triad.cmd conformance\core\cases\ricorsione\program.td
```

Il commento `# 120, 55` non fa parte del comando: indica l'output atteso, cioè quello che
dovresti vedere comparire. Il trattino `-` al posto del nome del file dice all'interprete JS di
leggere il programma dallo standard input. Lo stesso file può essere eseguito dai due runtime,
ma non sempre con lo stesso risultato: la differenza è l'argomento del [capitolo 15](#cap-15).

### 2.3 Materializzare il seed

Il sorgente del seed è il dump esadecimale; l'eseguibile si ottiene con un decodificatore di
sistema. Serve solo se vuoi provare il seed: l'interprete JS non richiede questo passaggio.

```powershell
Remove-Item seed\windows-x86_64\seed.exe -ErrorAction SilentlyContinue
certutil -decodehex seed\windows-x86_64\seed.hex seed\windows-x86_64\seed.exe
```

```sh
# Linux: seed ELF E2 (interprete Triad-Core) — oppure, consigliato: ./install.sh
xxd -r -p seed/linux-x86_64/seed.hex seed/linux-x86_64/seed && chmod +x seed/linux-x86_64/seed
```

Il comando Windows cancella prima l'eseguibile precedente, se c'è, e poi lo ricrea dal dump; su
Linux il risultato è l'interprete Triad-Core in codice macchina (stadio E2). Su Linux la strada
consigliata è `./install.sh` dalla radice del repository: ridecodifica il seed con la sola shell
POSIX, installa i launcher e supera uno smoke test byte-exatto.

### 2.4 Launcher `bin/triad` e `bin/triad.cmd`

Un launcher serve a non dover ricordare ogni volta quale binario usare e in quale cartella si
trova. Non è obbligatorio, ma è comodo: quando `bin/` è nel `PATH` basta `triad file.triad`, come
con un linguaggio installato nel sistema. Il launcher esegue **sempre** il seed in codice
macchina (`seed\windows-x86_64\seed.exe` su Windows, `seed/linux-x86_64/seed` su Linux, stadio
E2): nessun fallback automatico su altri runtime — l'interprete JS resta uno strumento di
sviluppo, mai il percorso utente. La variabile `TRIAD_SEED` permette di forzare un seed
specifico. Quando il seed non è disponibile o non è eseguibile, il launcher non fallisce in
silenzio: stampa le istruzioni per materializzarlo (`./install.sh` o decodifica di `seed.hex`).

### 2.5 Codici di uscita

I codici di uscita sono parte del contratto del linguaggio, non un dettaglio di comodità: la
suite di conformità confronta anche il codice, quindi un programma che stampa l'output giusto ma
esce con il codice sbagliato non passa.

| codice | significato |
|---|---|
| `0` | successo |
| `1` | errore di parsing o di esecuzione (messaggio su stderr), file non leggibile |
| `2` | uso non valido (es. nessun file) |

Le opzioni di SPEC §14 (`-e`, `-E`, `-l`, `-i`, `--tree`, `--help`, REPL) **non sono ancora
implementate**: l'interprete JS le tratta come un nome di file, e il seed Windows, che documenta
solo l'uso `seed.exe FILE`, non le riconosce. Per questo, quando un esempio non funziona, la prima
domanda da farsi è quale dei tre codici hai ottenuto: un `2` indica un problema nel comando, un
`1` un problema nel programma.

### 2.6 La CLI di sviluppo in breve

La CLI è facoltativa: raccoglie in un solo comando le operazioni che altrimenti faresti a mano
nel repository. Le righe seguenti mostrano le più usate, ciascuna con il commento che dice che
cosa fa.

```sh
bin/triad-cli status                 # ambiente e seed trovato (senza Node)
bin/triad-cli test conformance       # conformance Core (42 casi, byte-exatti)
bin/triad-cli test all               # gate completo: conformance + probe
node cli/triad-cli.mjs ai verify -v  # verifica le soluzioni di ai/tasks/ (dev, Node)
node cli/triad-cli.mjs seed generate windows  # rigenera seed.hex e stampa lo SHA-256
sh conformance/run.sh                # harness di conformance diretto (Core)
```

La CLI `bin/triad-cli` è shell POSIX pura e **non richiede Node**: copre `run`/`test`/`status`.
I comandi di sviluppo (`ai verify`, `seed generate`, `ext`) vivono nella CLI Node
`node cli/triad-cli.mjs` (dopo `cd cli && npm install`), oppure nell'eseguibile standalone
`triad-cli.exe` / `triad-cli` allegato alla
[release beta](https://github.com/GPuntobit/triad2.0/releases). Dettagli nel
[capitolo 39](#cap-39). Per seguire la Parte II la CLI non serve: gli esempi si eseguono
direttamente con `node`.

### Esercizi

1. **Requisiti.** Verifica `node --version` e la presenza del repository: quale versione serve?
2. **Eseguire un file.** Esegui un programma con `node seed/dev/triad_core.cjs file.triad` e con
   l'estensione `.td`: entrambe funzionano?
3. **Materializzare il seed.** Segui la procedura del paragrafo 2.3 e verifica il seed ottenuto.
4. **Il launcher.** Prova `bin/triad` (e `bin/triad.cmd` su Windows): quale runtime usano?
5. **Codici di uscita.** Produci programmi con codice `0`, `1` e `2` e verificali dal terminale.
6. **La CLI.** Esegui `bin/triad-cli test all` e leggi il riepilogo.
7. **File mancante.** Esegui un programma inesistente: quale errore e quale codice di uscita?
8. **Percorsi.** Scrivi lo stesso comando di esecuzione nella forma Windows e nella forma
   Linux/macOS: che cosa cambia?
9. **Due runtime, un programma.** Esegui lo stesso programma con `bin/triad` e con l'interprete
   JS: gli output coincidono?
10. **Dalla cartella giusta.** Esegui un programma da un'altra cartella usando percorsi relativi
    e assoluti: che cosa insegna sui percorsi?

---

<a id="cap-3"></a>

## 3. Il primo programma

Un programma Triad non richiede cerimonie: non c'è un file di configurazione, non ci sono import
da dichiarare, non c'è una funzione `main` da invocare. Il primo programma è un file di testo che
contiene le istruzioni nell'ordine in cui devono essere eseguite.

Crea `ciao.triad`:

```triad
#!/usr/bin/env triad
# il mio primo programma Triad
nome = "Triad"
println("ciao, " * nome)
println(6 * 7)
```

Output:

```text
ciao, Triad
42
```

Eseguilo:

```sh
node seed/dev/triad_core.cjs ciao.triad          # Linux/macOS
```

```cmd
seed\windows-x86_64\seed.exe ciao.triad          # Windows
```

Cosa notare:

- la prima riga `#!` (shebang) è ignorata: inizia con `#`, quindi è un commento;
- `println` stampa i suoi argomenti **senza separatori** e aggiunge un a capo;
- `*` tra stringhe è la **concatenazione** (non `+`);
- non c'è una funzione `main`: le istruzioni al top level si eseguono in ordine.

Puoi seguire l'esecuzione riga per riga. La riga `nome = "Triad"` valuta la stringa e associa
quel valore al nome `nome`. Nella riga seguente il runtime legge `nome`, concatena i due valori
stringa con `*` e passa il risultato a `println`. Nell'ultima riga, `6 * 7` viene valutato prima
della chiamata: a `println` arriva il valore intero `42`, non il testo del calcolo. Ogni
istruzione viene eseguita una sola volta e nell'ordine in cui compare; una funzione chiamata può
naturalmente eseguire il proprio corpo prima che il programma passi all'istruzione successiva.

La riga `#!` non è una direttiva necessaria per l'interprete: in questi esempi è una forma
convenzionale utile quando il sistema operativo può avviare direttamente un file eseguibile. Il
runtime Triad la ignora perché la tratta come commento. Se un esempio non funziona, verifica
separatamente che il file sia salvato con estensione `.triad` o `.td`, che il comando punti al
runtime giusto e che il sorgente usi soltanto costrutti supportati dal profilo dichiarato.

### 3.1 Argomenti da riga di comando

Gli argomenti dopo il nome del file sono in `ARGS`, una lista di stringhe (senza il nome del
programma). Esempio con l'interprete JS:

```sh
printf 'println(ARGS)\nprintln(length(ARGS))\n' > args.triad
node seed/dev/triad_core.cjs args.triad uno due      # [uno, due]  poi  2
```

> Il seed Windows documenta solo l'uso `seed.exe FILE`: `ARGS` non è tra le funzionalità
> elencate in `seed/windows-x86_64/README.md`. Usa l'interprete JS per i programmi con argomenti.

### 3.2 Il ciclo di lavoro consigliato

1. scrivi il programma usando solo Triad-Core (Parte II);
2. eseguilo con l'interprete JS (`node seed/dev/triad_core.cjs`);
3. se deve girare anche sul seed Windows, controlla la tabella del [capitolo 15](#cap-15);
4. se è un comportamento del linguaggio da fissare, trasformalo in un caso di conformance
   ([capitolo 38](#cap-38)).

Lo stesso ciclo vale per gli esercizi del capitolo 17: prima si scrive il programma, poi si
confronta l'output con quello atteso, e solo alla fine, se serve, si guarda la soluzione.

### Esercizi

1. **`ARGS`.** Scrivi un programma che stampi i suoi argomenti e provalo con zero, uno e tre
   argomenti.
2. **Senza argomenti.** Che cosa vede `ARGS` quando il programma non riceve nulla? Verifica
   stampandolo.
3. **Ciclo di lavoro.** Applica il ciclo consigliato del paragrafo 3.2 a un programma nuovo di
   tua invenzione.
4. **Una modifica alla volta.** Applica tre modifiche successive a un programma, rieseguendo
   dopo ciascuna: quale modifica ha introdotto l'errore?
5. **Commentare.** Commenta riga per riga un tuo programma: quale riga era la meno chiara?
6. **Output di tre righe.** Produci un output di tre righe esatte con `println` e verificalo
   carattere per carattere.
7. **Il nome conta.** Che cosa succede con un file `prova.triad.txt`? E con `prova.td`?
8. **Errore volontario.** Introduci un errore di sintassi, leggi il messaggio e correggilo in
   meno di un minuto.
9. **Mini-conformance.** Scrivi il tuo output atteso su un foglio prima di eseguire, poi
   confronta: hai previsto tutto?
10. **`ARGS` utile.** Scrivi un programma che, dato un numero `n` come argomento, stampi i numeri
    da 1 a `n`.

---
<a id="parte-2"></a>

# Parte II — Triad-Core passo per passo (eseguibile oggi)

Ogni capitolo di questa parte usa solo Triad-Core. Gli esempi con **Output:** sono stati
eseguiti con l'interprete JS; il caso di conformance indicato in fondo a ogni capitolo è il
riferimento normativo da leggere e far girare.

La struttura dei capitoli è sempre la stessa, così sai sempre dove guardare: prima la
spiegazione del costrutto e del problema che risolve, poi la sintassi e le regole, quindi un
esempio completo con il suo output, e infine il caso di conformance da cui l'esempio deriva.
Quando una regola nasconde una trappola, il testo la segnala esplicitamente.

<a id="cap-4"></a>

## 4. Lessico

Il lessico è l'insieme dei mattoni con cui si scrive un programma: che cosa è un nome, come si
scrive un numero o una stringa, che cosa il runtime considera separatore tra un'istruzione e
l'altra. Non è un elenco da imparare a memoria: serve a capire perché un certo testo viene letto
in un modo e non in un altro, e quindi perché un programma che sembra giusto produce un
`parse error`.

La tabella raccoglie gli elementi di Triad-Core, con la forma ammessa e un esempio per ciascuno:

| elemento | forma | esempi |
|---|---|---|
| identificatore | lettera o `_`, poi lettere/cifre/`_`; un `!` finale è ammesso | `x`, `somma_2`, `push!` |
| intero | cifre decimali, `_` come separatore; il segno è l'operatore unario | `42`, `1_000_000`, `-5` |
| booleano | `true`, `false` | |
| nothing | `nothing` | |
| stringa | `"..."` con escape `\n \t \" \\`; **nessuna interpolazione** | `"ciao\n"` |
| simbolo | `:` seguito da un nome o da un operatore | `:alice`, `:+` |
| commento | `#` fino a fine riga; `#= ... =#` su più righe | |
| separatore | a capo oppure `;` | `println(1); println(2)` |

Operatori di Core: `+ - * % ^ == != < <= > >= && || ! = += -= *= -> ?:`.

Parole riservate usate da Core: `function end if elseif else while let begin return break
continue true false nothing`.

Non fanno parte di Core: letterali `Float` (`1.5`), variabili logiche `?x`, macro `@nome`,
interpolazione `$x`, l'operatore `/`.

L'operatore `->` costruisce una lambda, mentre `?` e `:` formano il condizionale: sono token del
lessico, ma il loro significato è argomento del [capitolo 7](#cap-7) e del
[capitolo 10](#cap-10). Le parole riservate non possono essere usate come nomi di variabile: il
parser le riconosce come costruzioni, e un assegnamento come `let = 3` produce un errore di
sintassi. L'elenco delle parole riservate è breve perché Core è un linguaggio piccolo: tutto
ciò che non figura qui appartiene a Triad-Full, e usarlo in un programma Core non è «codice
eseguibile oggi».

Un'altra distinzione da tenere a mente è quella tra spazi e separatori. Spazi e tabulazioni
separano i token ma non le istruzioni; il punto e virgola e il ritorno a capo sì. Per questo
`println(1); println(2)` mette due istruzioni sulla stessa riga, mentre una riga vuota non
produce un'istruzione. Il punto e virgola, insomma, ha lo stesso ruolo del ritorno a capo: è un
separatore, non una fine di blocco.

```triad
#= commento
   su più righe =#
x = 1_000   # commento di riga
println(x); println("tab:\t|", " virgolette: \"", " backslash: \\")
println(:alice, " ", :+)
```

Output:

```text
1000
tab:	| virgolette: " backslash: \
alice +
```

> **Attenzione.** `"x = $x"` in Core stampa letteralmente `x = $x`: l'interpolazione è solo
> Triad-Full. In Core si concatena: `"x = " * string(x)`.
>
> I commenti `#= … =#` **non si annidano** nell'interprete JS: il commento si chiude al primo
> `=#` incontrato. Non contare sull'annidamento; se devi commentare codice che contiene già un
> blocco `#= … =#`, usa commenti di riga.

I due avvertimenti hanno la stessa radice: in Core il lessico è volutamente minimo, e ciò che in
un altro linguaggio è «solo un dettaglio» qui può non esistere. Il testo di un programma Core
non va interpretato con le abitudini di un altro linguaggio: se un escape o un simbolo non
compare nella tabella, il runtime non lo riconosce.

Riferimento: `conformance/core/cases/aritmetica`, `simboli_base`, `stringhe_base`.

### Esercizi

1. **Identificatori.** Quali nomi sono validi? `_x`, `x!`, `push!`, `2x`, `x2`, `x-y`, `x_y`.
   Provali come nomi di variabili.
2. **Numeri.** Scrivi un milione in tre forme ammesse (`1000000`, `1_000_000`…) e un intero
   negativo: come vengono stampati?
3. **Stringhe ed escape.** Stampa una stringa con `\n`, `\t`, `\"`, `\\`: ricrea a mano l'output
   atteso prima di eseguire.
4. **Simboli.** Scrivi `:ok`, `:nome` e il simbolo `:+`: che cosa cambia rispetto alle stringhe
   con lo stesso testo?
5. **Commenti.** Scrivi un programma con `#` e `#= ... =#` in tre posizioni diverse: il
   comportamento cambia mai?
6. **Separatori.** Due istruzioni su una riga con `;`, poi la stessa coppia su due righe: è lo
   stesso programma per il parser?
7. **Operatori Core.** Elenca tutti gli operatori Core e scrivi un esempio per ciascun gruppo
   (aritmetica, confronto, logica, assegnamento, scelta).
8. **Lettura del codice.** Dividi in token questa riga: `x = n + 1  # avanzamento` e spiega
   quale pezzo il parser ignora.
9. **Refusi.** Scrivi apposta `printn`, `elsa`, `whlie`: quale errore produce ciascuno?
10. **Con la grammatica.** Confronta la sintassi di questo capitolo con la grammatica del
    [capitolo 44](#cap-44): quale regola produce i numeri con `_`?

---

<a id="cap-5"></a>

## 5. Valori, tipi e stampa

Triad è un linguaggio a tipi dinamici: ogni valore ha un tipo ben preciso, ma le variabili no.
Una stessa variabile può contenere un intero e poi una stringa, e il tipo viene controllato al
momento dell'operazione, non della dichiarazione. Da qui deriva una conseguenza pratica: per
sapere che cosa contiene un valore devi chiederlo al runtime con `typeof`, e per scrivere codice
robusto devi pensare ai tipi che possono arrivare, non solo a quelli che intendevi passare.

La tabella elenca i tipi che un programma Core può incontrare:

| tipo | valori | `typeof(v)` |
|---|---|---|
| `Int` | interi con segno a 64 bit, aritmetica con wrap (complemento a due) | `Int` |
| `Bool` | `true`, `false` | `Bool` |
| `String` | sequenza immutabile di byte UTF-8 | `String` |
| `Symbol` | `:nome`; uguali se hanno lo stesso nome | `Symbol` |
| `List` | lista eterogenea **mutabile**, indici da 1 | `List` |
| `Function` | funzione nominata, lambda o chiusura | `Function` |
| `Nothing` | `nothing` | `Nothing` |

`typeof` restituisce il **nome del tipo come simbolo**.

Il dettaglio del simbolo non è pedanteria: `typeof(1)` vale `:Int`, non `"Int"`. Confrontare il
risultato con una stringa non funziona, e il confronto corretto è `typeof(v) == :Int`. In
generale, in Triad un tipo si nomina con un simbolo; la stringa serve a chi stampa un messaggio,
non a chi programma un controllo.

I tipi non sono un ornamento: da essi dipende che cosa un'operazione accetta. `Int` è a 64 bit
perché deve stare in una parola di macchina, che è l'unità con cui il seed lavora; `String` è
immutabile perché il linguaggio non offre modi per modificarla in loco; `Symbol` è pensato per
i nomi e gli identificatori interni; `List` è mutabile perché è la struttura dati di lavoro del
linguaggio; `Nothing` rappresenta l'assenza di un valore utile, non un errore.

### 5.1 Regole di stampa di `print`/`println`

- concatenano gli argomenti senza separatori; `println` aggiunge `\n`;
- `Int` in decimale, `Bool` come `true`/`false`, `String` così com'è, `Nothing` come `nothing`;
- un `Symbol` passato direttamente è stampato **senza** `:`; dentro una lista **con** `:`;
- una `List` è stampata come `[a, b]`; le stringhe dentro una lista sono stampate senza
  virgolette.

```triad
xs = [1, :a, "s", true, nothing, [2, 3]]
println(xs)
println(:alice)
println(typeof(1), " ", typeof("s"), " ", typeof(:a), " ", typeof(xs))
println(typeof(nothing), " ", typeof(true), " ", typeof(x -> x))
print("senza ", "a capo")
println()
```

Output:

```text
[1, :a, s, true, nothing, [2, 3]]
alice
Int String Symbol List
Nothing Bool Function
senza a capo
```

### 5.2 Uguaglianza

`==` e `!=` confrontano numeri, stringhe e simboli **per valore**, le liste **elemento per
elemento** (anche annidate), le funzioni **per identità**.

```triad
println([1, [2, [3]]] == [1, [2, [3]]])
println("ab" == "a" * "b", " ", :a == :a, " ", 1 == 2)
```

Output:

```text
true
true true false
```

Il valore stampato non è sempre una rappresentazione da riutilizzare come sorgente. Per esempio,
un simbolo passato direttamente a `println` appare senza i due punti (`alice`), mentre dentro una
lista viene mostrato come `:alice`; le stringhe dentro una lista sono mostrate senza virgolette.
`typeof` è quindi il modo corretto per verificare il tipo del valore, mentre la forma visiva di
`println` serve soprattutto alla lettura umana. Analogamente, `==` confronta il contenuto per
numeri, stringhe, simboli e liste, ma le funzioni per identità: due funzioni scritte con lo stesso
testo non sono per questo lo stesso oggetto funzione.

La rappresentazione UTF-8 è misurata in byte, non necessariamente in lettere visibili. Una lettera
accentata può occupare più byte; perciò `length` su una stringa non è sempre il conteggio dei
caratteri percepiti da una persona. In Core non ci sono operazioni di indicizzazione dei caratteri:
i primitivi di bootstrap lavorano esplicitamente sui byte e vanno usati solo per il compito di
lettura e analisi del sorgente.

Riferimento: `conformance/core/cases/valori`, `nothing_base`, `confronti`.

### Esercizi

1. **`print` o `println`?** Stampa tre parole su una sola riga con `print` e chiudi con
   `println()`: quale differenza con tre `println`?
2. **Argomenti multipli.** `println("a", 1, true)`: come vengono concatenati? Prevedi e verifica.
3. **Simboli in due modi.** Spiega perché `println(:a)` stampa `a` e `println([:a])` stampa `[:a]`.
4. **Uguaglianza di liste.** Valuta `[1, [2, [3]]] == [1, [2, [3]]]` e `[1, 2] == [2, 1]`:
   quale regola si applica?
5. **Funzioni uguali.** Con `f(x) = x` e `g(x) = x`, che cosa valgono `f == f` e `f == g`? Perché?
6. **`typeof` completo.** Stampa `typeof` per `42`, `"s"`, `true`, `:a`, `[1]`, `nothing`.
7. **`42` e `"42"`.** Perché `42 + 1` funziona e `"42" + 1` no? Quale regola di `+` si applica?
8. **Stampare `nothing`.** Che cosa produce `println(nothing)`? E `println(typeof(nothing))`?
9. **Formattazione esatta.** Producì l'output `a b c` (una riga, spazi esatti) usando almeno due
   tecniche diverse.
10. **Il caso di conformance.** Esegui il caso di conformance da cui deriva questo capitolo e
    confronta byte per byte il tuo output con il golden.

---

<a id="cap-6"></a>

## 6. Variabili e assegnamento

Una variabile, in Triad, è un nome legato a un valore. Non la dichiari e non ne annunci il tipo:
il primo assegnamento crea il legame, i successivi lo aggiornano. Questo rende il codice breve,
ma sposta l'attenzione su due domande che in un linguaggio con le dichiarazioni sarebbero
automatiche: quale valore c'è dentro un nome in questo punto del programma, e in quale ambiente
quel nome è visibile.

Le regole di base sono queste:

- `nome = espr` lega o aggiorna un nome; l'assegnamento è un'espressione e vale il valore
  assegnato.
- `+=`, `-=`, `*=` aggiornano una variabile esistente (il lato sinistro è valutato una volta).
- Usare un nome mai assegnato è un errore di esecuzione (`undefined variable`).
- Non ci sono dichiarazioni né tipi: le variabili sono dinamiche.

Che l'assegnamento sia un'espressione, e non un'istruzione, è la regola meno ovvia. Significa
che `x = 42` non «fa qualcosa e basta»: produce il valore `42`, e quel valore può essere usato
dove compare l'assegnamento. Nella pratica serve quando un assegnamento compare dentro un blocco
che restituisce un valore, ma è anche il motivo per cui non trovi una distinzione rigida tra
«istruzione» e «espressione» nel resto del libro. L'assegnamento composto (`+=`, `-=`, `*=`) è
zucchero per una lettura e una scrittura della stessa variabile, con la garanzia che il lato
sinistro venga valutato una sola volta: se contiene un indice, quell'indice non viene calcolato
due volte.

Un nome usato prima di essere assegnato non vale `nothing` e non vale zero: è un errore che
interrompe il programma. È una scelta voluta, perché un valore «vuoto» implicito nasconderebbe
un errore di logica; il [capitolo 14](#cap-14) spiega come si riconosce questo caso e che cosa
si vede sul terminale.

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

Output:

```text
43 50 186
24
```

Le regole di **visibilità** (dentro funzioni, `let`, lambda) sono nel [capitolo 10](#cap-10).

Un modo utile di seguire il programma è tenere una piccola tabella dei legami correnti:

| istruzione conclusa | `x` | `y` | `z` |
|---|---:|---:|---:|
| `x = 42` | 42 | — | — |
| `y = x + 8` | 42 | 50 | — |
| `x = x + 1` | 43 | 50 | — |
| `z = (x + y) * 2` | 43 | 50 | 186 |

Questa tabella mostra perché l'assegnamento non è una formula reattiva: `y` conserva il risultato
calcolato quando la sua riga viene eseguita, anche dopo che `x` cambia. Per contro, una lista è
mutabile e può essere raggiunta da più nomi; modificare un suo elemento agisce sull'oggetto
condiviso, non solo su una singola associazione nome-valore. Il capitolo 11 mostra come riconoscere
questa differenza nel codice.

Riferimento: `conformance/core/cases/variabili`.

### Esercizi

1. **L'assegnamento produce un valore.** Che cosa stampa `println(x = 7)`? Perché?
2. **Le scorciatoie.** Riscrivi `n += 3`, `n -= 2`, `n *= 4` in forma esplicita: il risultato
   cambia? Su quale runtime delle due le scorciatoie complete non sono disponibili?
3. **Nome indefinito.** `println(k)` senza assegnamento: quale errore? E quale su un programma
   dove `k` è assegnato solo in un ramo di un `if`?
4. **Tabella dei valori.** Traccia `a = 1`, `b = a + 1`, `a = a * 10`, `c = a + b` e conferma
   l'output con `println(a, " ", b, " ", c)`.
5. **Riassegnare o mutare.** Con `xs = [1, 2]` e `alias = xs`: che cosa vede `alias` dopo
   `xs[1] = 9`? E dopo `xs = [5]`?
6. **Nomi.** Perché `eta` e `Eta` sono diverse? Quale convenzione di nomenclatura usa il libro?
7. **Cambio di tipo.** `x = 1` poi `x = "ciao"`: permesso, ma saggio? Scrivi la variante con due
   nomi diversi.
8. **`xs[i] += 1`.** Perché il lato sinistro viene valutato una volta sola? Costruisci un caso
   in cui una doppia valutazione darebbe un risultato diverso.
9. **Contatore.** Senza guardare, scrivi il ciclo che conta da 1 a 5 con `+=` e un `while`.
10. **Il caso di conformance.** Esegui il caso del capitolo e spiega perché usa solo assegnamenti
    su nomi preesistenti.

---

<a id="cap-7"></a>

## 7. Operatori ed espressioni

Un'espressione è un modo di combinare valori per produrne un altro. Triad non ha una
distinzione rigida tra espressioni e istruzioni: quasi tutto è un'espressione, e anche i
costrutti di controllo hanno un valore. Per leggere un'espressione senza ambiguità servono due
informazioni: quanto «lega forte» ogni operatore e in che direzione si raggruppano gli operatori
dello stesso livello.

### 7.1 Precedenza (dalla più bassa alla più alta)

| livello | operatori | associatività |
|---|---|---|
| 1 | `=` `+=` `-=` `*=` | destra |
| 2 | `c ? a : b` | destra |
| 3 | `\|\|` | sinistra, cortocircuito |
| 4 | `&&` | sinistra, cortocircuito |
| 5 | `==` `!=` `<` `<=` `>` `>=` | sinistra |
| 6 | `+` `-` | sinistra |
| 7 | `*` `%` | sinistra |
| 8 | `^` | **destra** |
| 9 | unari `-` `!` | prefissi |
| 10 | `f(args)` `xs[i]` | postfissi |

La tabella va letta come una classifica: il livello 1 lega meno, il livello 10 di più. In
`2 + 3 * 4` convivono il livello 6 (`+`) e il livello 7 (`*`); vince il più alto, quindi si
calcola prima `3 * 4`. Quando due operatori stanno sullo stesso livello decide l'associatività:
`-` è a sinistra, quindi `8 - 3 - 2` è `(8 - 3) - 2` e non `8 - (3 - 2)`. L'eccezione più
importante è `^`, che è a destra: `2 ^ 3 ^ 2` significa `2 ^ (3 ^ 2)` e vale 512, non 64.

Questa tabella descrive Triad-Core. Triad-Full aggiunge altri operatori e altri livelli — il
range `a:b`, `in`/`isa`/`is`, l'asserzione di tipo `e::T`, la lambda `x -> e` — descritti nella
specifica (SPEC §2). Chi scrive solo Core può ragionare con questa tabella; chi passa a Full
deve consultare quella completa.

### 7.2 Aritmetica intera

- `+ - * ^` su `Int` con **wrap a 64 bit**;
- `%` è il **resto con il segno del dividendo** (come `rem` di Julia): `-7 % 3 == -1`;
- `^` con esponente negativo è un errore; `%` per zero è un errore;
- **non esiste `/`** in Core (la divisione è di Triad-Full).

```triad
println(2 + 3 * 4, " ", (2 + 3) * 4, " ", 2 ^ 3 ^ 2)
println(7 % 3, " ", -7 % 3, " ", 10 % 4)
println(9223372036854775807 + 1)
```

Output:

```text
14 20 512
1 -1 2
-9223372036854775808
```

Il risultato `-9223372036854775808` è la faccia visibile del wrap: il massimo intero più uno non
produce un errore, produce il minimo. Triad-Core non ha un tipo «intero grande» né controlli di
overflow, perché deve restare implementabile con poche istruzioni di macchina; se un calcolo
deve restare nel dominio, il controllo va scritto nel programma.

Il resto negativo segue la stessa logica: `-7 % 3` vale `-1` perché il segno lo dà il dividendo,
non il divisore. È il comportamento di `rem` in Julia e va tenuto presente quando si usa `%` per
calcolare posizioni cicliche: con valori negativi serve una correzione esplicita.

### 7.3 Logica e condizioni

- Le condizioni (`if`, `while`, ternario, `&&`, `||`, `!`) accettano **solo `Bool`**: non c'è
  "truthiness" (`if 1` è un errore).
- `&&` e `||` cortocircuitano.
- I confronti non si concatenano: `1 < 2 < 3` è un errore (si confronta `Bool < Int`); scrivi
  `1 < 2 && 2 < 3`.

```triad
println(!false, " ", true && false, " ", false || true)
println(1 < 2 && 2 < 3)
x = 3
println(x > 2 ? "grande" : "piccolo")
```

Output:

```text
true false true
true
grande
```

Il **cortocircuito** è osservabile: con `a && b`, se `a` è `false`, `b` non viene valutato; con
`a || b`, se `a` è `true`, `b` non viene valutato. Non è solo un'ottimizzazione: impedisce anche
che un calcolo non necessario produca un errore. Un controllo del tipo `i <= length(xs) &&
xs[i] > 0` può quindi verificare il limite prima di accedere alla lista, purché `i` sia un intero
valido. Entrambi gli operandi valutati devono comunque essere booleani.

La scelta di accettare solo `Bool` evita una classe intera di ambiguità: in molti linguaggi `0`,
`""` e `nothing` sono «falsi» per convenzione, e ogni programmatore arriva con una convenzione
diversa. In Triad non ci sono convenzioni da ricordare: una condizione è vera o falsa, e
qualsiasi altro tipo è un errore. Per questo `1 < 2 < 3` non funziona: i confronti si associano a
sinistra, quindi il parser legge `(1 < 2) < 3`, cioè un `Bool` confrontato con un `Int`.

Una trappola collegata riguarda `=` e `==`: `if x = 0` non confronta `x` con zero, assegna zero e
produce `0` come valore della condizione; il runtime rifiuta quel valore perché non è un `Bool`.
Il confronto è `==`, e vale la pena prendere l'abitudine di scriverlo sempre.

La tabella di precedenza descrive il raggruppamento: `a + b * c` equivale a `a + (b * c)`.
Quando due operatori hanno lo stesso livello, entra in gioco l'associatività. In caso di dubbio,
usa parentesi: rendono esplicita la struttura che vuoi e aiutano a distinguere un errore di
raggruppamento da un errore nel valore degli operandi.

Riferimento: `conformance/core/cases/aritmetica`, `operatori`, `interi`, `confronti`.

### Esercizi

1. **Precedenza.** Calcola a mano `2 + 3 * 4`, `(2 + 3) * 4`, `2 ^ 3 ^ 2`, `1 + 2 == 3` e
   verifica con un programma.
2. **`^` associativo a destra.** Scrivi con le parentesi il raggruppamento di `2 ^ 3 ^ 2` e
   spiega il risultato (`512`).
3. **Resto.** Valuta `7 % 3`, `10 % 5`, `-7 % 3`: quale definizione di `%` usa Triad?
4. **A 64 bit, con wrap.** Che cosa stampa `println(9_223_372_036_854_775_807 + 1)`? Verifica e
   spiega con l'aritmetica in complemento a due del volume.
5. **Cortocircuito.** Dimostra che in `false && <secondo>` il secondo operando non viene
   valutato (per esempio con una chiamata che stamperebbe qualcosa).
6. **Ternario.** Riscrivi un `if`/`else` come `cond ? a : b` e viceversa: quando conviene quale?
7. **`=` e `==`.** Che cosa produce `if x = 0`? Perché il linguaggio segnala l'errore invece di
   comportarsi in modo misterioso?
8. **Confronti combinati.** Scrivi un'espressione che sia vera solo per i numeri fra 10 e 20
   inclusi, e provala con quattro valori.
9. **Solo `Bool`.** Perché `if 1` e `while "s"` sono errori? Quale regola del volume difende
   questa scelta?
10. **Il caso di conformance.** Esegui il caso del capitolo, prevedi ogni riga dell'output e poi
    confronta.

---

<a id="cap-8"></a>

## 8. Controllo di flusso

Il controllo di flusso decide quali istruzioni eseguire e quante volte. Triad ha un vincolo che
semplifica il modello mentale: **tutto è un'espressione**, e anche `if`, `while`, `let` e
`begin` hanno un valore (quello dell'ultima istruzione eseguita, `nothing` se non ne esegue
nessuna). Non esistono quindi due mondi separati — istruzioni che non valgono niente ed
espressioni che valgono qualcosa — ma un solo meccanismo, e i blocchi sono espressioni che
contengono altre espressioni.

### 8.1 `if` / `elseif` / `else`

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

Output:

```text
negativo zero positivo
si
```

L'`if` valuta una condizione alla volta, dalla prima all'ultima, ed esegue solo il ramo
corrispondente al primo valore `true`; se nessuna condizione è vera ed esiste un `else`, esegue
quello, altrimenti non esegue niente e vale `nothing`. `elseif` non è uno zucchero per un `else`
che contiene un altro `if`: è un ramo della stessa catena, e questo evita di accumulare `end` a
ogni livello. L'ultima riga dell'esempio mostra che un `if` può stare a destra di un
assegnamento: il suo valore è quello del ramo scelto, qui il simbolo `:si`.

Due trappole ricorrenti: dimenticare l'`end` (che chiude `if`, `while`, `function` e `let`) e
scrivere `else if` al posto di `elseif`: in Core `elseif` è un unico ramo della catena, mentre
`else if` annida un secondo `if` e richiede un `end` in più. Il `? :` del capitolo 7 è la
versione compatta dello stesso schema, comoda quando i due rami sono espressioni brevissime.

### 8.2 `while`, `break`, `continue`

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

Output:

```text
25
fine
```

Il `while` è l'unico ciclo di Triad-Core: non c'è `for`, e l'iterazione su una lista si scrive
con un contatore e un limite, come farà il [capitolo 11](#cap-11). La scelta è coerente con il
bootstrap: un solo costrutto di ciclo è più facile da implementare in codice macchina, e `for`
può essere aggiunto dopo, in S1, senza cambiare la semantica del `while`.

La trappola classica del `while` è l'ordine delle istruzioni dentro il corpo: se `continue`
salta l'aggiornamento del contatore, il ciclo non termina. Nell'esempio il contatore viene
incrementato prima di ogni `continue`, e non è un caso: la condizione di uscita deve essere
raggiungibile lungo tutti i percorsi del corpo. `break` e `continue` agiscono sempre sul `while`
più interno, quindi in cicli annidati vanno letti con attenzione.

### 8.3 `let` e `begin`

`let` introduce un nuovo scope con legami locali; `begin … end` raggruppa istruzioni senza
creare legami nuovi.

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

Output:

```text
20
10
1
42
```

Un blocco `begin … end` raggruppa istruzioni e vale l'ultima: serve a usare più istruzioni dove
ne serve una sola, per esempio a destra di un assegnamento. `let` invece apre un ambiente nuovo,
e i nomi che lega lì dentro possono nascondere quelli esterni senza toccarli: è il meccanismo con
cui Triad-Core isola un calcolo. L'esempio mostra i tre legami di `x` (`20`, `10`, `1`) e poi il
valore del `begin` (`42`), che arriva all'assegnamento come qualsiasi altro valore.

La differenza tra i due costrutti è la stessa che c'è tra «raggruppare» e «isolare»: usa `begin`
quando vuoi solo tenere insieme istruzioni, `let` quando un nome locale deve restare locale.

Riferimento: `conformance/core/cases/controllo`, `if_else`, `if_elseif`, `if_nested`,
`if_no_else`, `while_loop`, `let_annidato`, `begin_block`.

### Esercizi

1. **Classificare.** Con `if`/`elseif`/`else` classifica un intero in `negativo`, `zero`,
   `piccolo` (1–9), `grande` (≥ 10).
2. **Contatore.** Scrivi un `while` che stampi i numeri pari da 2 a 20.
3. **`break`.** Trova il primo numero la cui somma con 10 supera 50, interrompendo il ciclo.
4. **`continue` e la sua variante.** Stampa i dispari da 1 a 9 con `continue`; poi riscrivilo
   senza `continue` perché giri anche sul seed Windows.
5. **Due cicli.** Con una variabile di stato, interrompi due `while` annidati appena `i * j`
   supera 12.
6. **`let` e visibilità.** Che cosa succede a una variabile nata dentro un `let` dopo il blocco?
   Verifica con un accesso dall'esterno.
7. **`begin`.** Costruisci un esempio in cui `begin … end` serve per raggruppare più istruzioni
   dove ci vuole un'espressione.
8. **`while` come espressione.** `x = while … end`: gira sull'interprete JS? E sul seed?
   Confronta con il capitolo 15.
9. **Condizione non `Bool`.** Un `while` con condizione intera: che cosa fanno i due runtime?
   Scrivi il programma che lo dimostra e annota la divergenza.
10. **Il caso di conformance.** Esegui il caso del capitolo e spiega ogni istruzione del golden.

---

<a id="cap-9"></a>

## 9. Funzioni

Una funzione è un pezzo di programma a cui dai un nome, con dei parametri, che restituisce un
valore. È il mattone con cui si costruisce tutto il resto: in Triad-Core non ci sono struct né
metodi, quindi la funzione è anche l'unico modo per dare un nome a un'operazione e riusarla.

### 9.1 Tre modi di definire una funzione

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

Output:

```text
16 8 42
```

Quando `calcola(3)` viene chiamata, `n` riceve `3`; il corpo calcola `m = 4`, poi valuta `m * 2`
e restituisce `8` perché è l'ultima espressione. Il legame `m` appartiene alla chiamata e non
diventa automaticamente una variabile globale. Con la forma breve, l'espressione a destra di `=`
è direttamente il corpo. La funzione anonima può essere assegnata a un nome, passata come
argomento o restituita da un'altra funzione: il nome è un riferimento utile, non una proprietà
necessaria del valore funzione.

### 9.2 `return`, ricorsione, arità

- `return e` esce subito dalla funzione; `return` da solo restituisce `nothing`.
- Una funzione nominata è visibile nel proprio corpo: la ricorsione diretta funziona.
- Il numero di argomenti deve coincidere con i parametri (altrimenti `arity mismatch`).

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

Output:

```text
grande piccola
3628800 610 6
```

La ricorsione si comprende seguendo una catena di chiamate, ciascuna con il proprio parametro. In
`fattoriale(4)`, per esempio, la chiamata riduce `n` a 3, 2 e 1; arrivata al caso base restituisce
1, poi le chiamate sospese riprendono e moltiplicano i risultati per 2, 3 e 4. Il caso base è
quindi una condizione di terminazione, non un semplice esempio aggiuntivo. Se il parametro non si
avvicina a un caso base, la funzione continua a chiamarsi; nel runtime Core il budget di esecuzione
non è un costrutto del linguaggio, quindi è responsabilità del programma evitare ricorsioni
illimitate.

Senza `return`, il valore della funzione è l'ultima espressione eseguita, anche quando il corpo
termina dentro un `if`. Una funzione è un valore legato a un nome quando l'istruzione di
definizione viene eseguita: per questo chiamarla prima della sua riga di definizione produce
`undefined variable`, non una risoluzione anticipata. Non ci sono argomenti di default né
variadici: l'arità deve coincidere esattamente con i parametri.

### 9.3 Annotazione di effetto `!io`

In Triad-Full una funzione che stampa deve dichiarare `!io` ([capitolo 28](#cap-28)). Core
accetta l'annotazione e la ignora: scriverla rende il codice già pronto per Full.

```triad
function mostra() !io
    println("hello from block")
    20 + 22
end
println(mostra())
```

Output:

```text
hello from block
42
```

L'annotazione fa parte della firma in Triad-Full: lì una funzione che stampa senza `!io` viola il
controllo degli effetti e il chiamante ottiene `Err(:effect)` ([capitolo 28](#cap-28)). In Core
il controllo non esiste, quindi l'annotazione viene accettata e ignorata: il programma gira, ma
non hai alcuna garanzia in più. Scriverla fin da subito resta comunque utile, perché il codice
sarà valido quando passerà a Full e perché documenta l'intenzione di chi l'ha scritto.

Riferimento: `conformance/core/cases/funzioni`, `funzioni_semplici`, `funzioni_blocco`,
`funzioni_io`, `ricorsione`, `gcd`, `formula`.

### Esercizi

1. **Tre forme.** Scrivi `quadrato` in forma breve, blocco e anonima: quale usi e quando?
2. **L'ultima espressione.** Cosa restituisce una funzione il cui corpo termina con
   `println(x)`? Verifica usando il risultato.
3. **`return`.** Scrivi `descrizione(n)` con due `return` anticipati e l'ultima espressione.
4. **Arity.** Quali errori ottieni chiamando `f()`, `f(1, 2)` per `f(x)`? E per `f(x, y)`?
5. **Ricorsione.** Scrivi `conta(n)` che stampa da `n` a 1 e poi `via!`; individua caso base e
   passo ricorsivo.
6. **`!io`.** A cosa serve l'annotazione `!io` in una firma? Scrivi una funzione `!io` che
   stampi e una pura che non può.
7. **Funzione come valore.** Assegna una funzione a una variabile e usala dove servirebbe una
   lambda.
8. **Ordine di definizione.** Cosa succede a chiamare una funzione prima di definirla? Verifica
   e spiega.
9. **Comporre.** Scrivi `fattoriale` che usi `prodotto(a, b)`: quante funzioni ci sono e chi chiama
   chi?
10. **Il caso di conformance.** Esegui il caso del capitolo e confronta con il tuo programma.

---

<a id="cap-10"></a>

## 10. Lambda, chiusure e scope

Una lambda è una funzione che non ha bisogno di un nome: la scrivi dove serve, e il suo valore è
la funzione stessa. Serve ogni volta che vuoi passare un comportamento a un'altra funzione —
«applica questa trasformazione a ogni elemento», «chiama questo controllo su ogni valore» —
senza inventare un nome che userai una volta sola. Una chiusura è una lambda che ricorda
l'ambiente in cui è nata; è il meccanismo che rende possibile costruire funzioni parametriche
senza ricorrere a variabili globali.

### 10.1 Lambda

```triad
doppio = x -> x * 2
somma = (a, b) -> a + b
applica = f -> f(3)
println(doppio(5), " ", somma(1, 2), " ", applica(x -> x * x))
```

Output:

```text
10 3 9
```

Una lambda con corpo a più istruzioni si scrive con `begin … end` o con `function (…) … end`.
Le lambda senza parametri (`() -> …`) **non** sono supportate: usa `function () … end`.

### 10.2 Chiusure

Una lambda cattura l'ambiente in cui è creata. Secondo SPEC-CORE §5 le variabili catturate sono
**condivise**: le mutazioni sono visibili.

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

Output:

```text
15 105
15
```

> Il seed Windows cattura **per valore** e copre solo l'ultimo legame del frame: un
> accumulatore come `contatore` può non funzionare sul seed ([capitolo 15](#cap-15)).

La differenza tra una funzione ordinaria e una chiusura è il contesto esterno che resta
accessibile. `add(10)` termina, ma la lambda restituita conserva il legame `n = 10`; un'altra
chiamata ad `add` crea un ambiente distinto. Nel contatore, invece, la chiusura non si limita a
leggere `v`: aggiorna il legame condiviso. L'interprete JS segue il contratto Core in cui questa
mutazione è visibile alle chiamate successive. Il seed Windows ha una cattura più limitata, quindi
un programma che dipende da questo caso va provato con l'interprete di riferimento e non inferito
dal solo fatto che il seed accetti la sintassi.

### 10.3 Regole di scope

1. `function`, lambda, `let` e `while` introducono ambienti; un nome è visibile nell'ambiente
   in cui è legato e in quelli interni (scope lessicale).
2. **Dentro una funzione nominata** l'assegnamento lega nel frame locale: una funzione **non
   modifica i globali**.
3. **Dentro una lambda** l'assegnamento a un nome già legato fuori aggiorna quel legame (è così
   che funziona l'accumulatore sopra).
4. **Al top level** i cicli aggiornano i globali.
5. `let x = …` crea un nuovo `x`; assegnare `x` dentro il `let` non tocca l'`x` esterno.

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

Output:

```text
2 1
0
```

Il punto delicato è che le regole 2 e 3 sembrano in contraddizione: una funzione nominata non
modifica un globale, una lambda sì. La differenza non è capricciosa, dipende da come vengono
catturati gli ambienti. La lambda porta con sé il riferimento all'ambiente in cui è stata creata,
quindi l'assegnamento trova il legame esterno e lo aggiorna. La funzione nominata è pensata per
essere richiamabile da sola, senza effetti nascosti sui nomi dello scope globale: l'assegnamento
crea un legame locale, e il globale resta quello che era. L'esempio lo mostra con `x` (che resta
`1`) e con `c` (che resta `0` anche dopo `incrementa()`).

Se ti serve comunicare un risultato, ci sono due strade coerenti con questo modello: restituire
il valore con `return`, oppure mettere lo stato in una lista, che è mutabile e quindi condivisa
anche da una funzione nominata ([capitolo 11](#cap-11)).

Riferimento: `conformance/core/cases/lambda`, `closure`, `chiusure`, `chiusure_local`,
`chiusura_in_if`, `let_chiusura`, `scope`.

### Esercizi

1. **Lambda.** Scrivi `x -> x * 2`, assegnala a un nome e chiamala.
2. **Quanti parametri?** Una lambda con due parametri: gira sull'interprete JS? E sul seed
   Windows (cap. 15)? Provala.
3. **Chiusure diverse.** Scrivi un contatore con una chiusura e osserva la differenza fra
   cattura per valore (seed) e condivisa (interprete JS) descritta nel capitolo 15.
4. **Cosa vede una funzione.** Una funzione legge le variabili del programma che la contiene?
   E il programma quelle della funzione? Verifica entrambe.
5. **Shadowing.** Con `x = 1` esterno e `let x = 2` interno, che cosa stampa dentro e fuori il
   blocco?
6. **Cattura e mutazione.** Una chiusura che cattura una lista vede le modifiche fatte con
   `push!`? Verifica.
7. **Lambda come argomento.** Passa una lambda a una funzione di ordine superiore scritta in
   Core (cap. 16.1).
8. **Anonima o lambda.** Riscrivi `function (x) x + 1 end` in forma lambda e viceversa.
9. **Parametri locali.** Modificare un parametro dentro la funzione cambia l'argomento del
   chiamante? Prova con un `Int` e con una lista.
10. **Il caso di conformance.** Esegui il caso del capitolo e spiega l'output atteso.

---

<a id="cap-11"></a>

## 11. Liste

Una lista è una sequenza ordinata di valori, raggiungibili per posizione. In Triad-Core è la
struttura dati di lavoro: non ci sono struct né dizionari, quindi liste, liste di liste e liste
taggate sono il modo in cui si rappresentano record, ambienti e alberi. Capire come si comporta
una lista — che è mutabile e che gli indici partono da 1 — è il passaggio che apre tutta la
programmazione non banale in Core.

Le operazioni di base sono poche, e vale la pena leggerle pensando a che cosa fanno alla lista
come oggetto, non solo al valore che restituiscono:

- Letterale: `[1, 2, 3]`, `[]`, eterogenee e annidabili.
- Indici **da 1**: `xs[1]` è il primo elemento; fuori range è un errore.
- Assegnamento per indice: `xs[i] = v`, anche `xs[i] += v`.
- `length(xs)` numero di elementi; `push!(xs, v)` aggiunge in coda, **muta** la lista e la
  restituisce.
- Le liste sono riferimenti: due nomi possono indicare la stessa lista.

```triad
xs = [1, 2, 3]
println(xs[1], " ", length(xs))
push!(xs, 4)
xs[1] += 100
println(xs)
alias = xs
push!(alias, 5)
println(xs)
tot = 0
i = 1
while i <= length(xs)
    tot += xs[i]
    i += 1
end
println(tot)
```

Output:

```text
1 3
[101, 2, 3, 4]
[101, 2, 3, 4, 5]
115
```

Core non ha `map`, `filter`, `reduce`, `sum`, `sort`: si scrivono in Core (vedi
[capitolo 16](#cap-16)).

> Sul seed Windows: liste solo di interi, `push!` sì, `xs[i]` e `length(xs)` **no**; c'è invece
> l'helper non standard `get(xs, i)` con indici **da 0** ([capitolo 15](#cap-15)).

Riferimento: `conformance/core/cases/liste`, `liste_base`, `liste_push`.

Ricorda il modello di alias: dopo `alias = xs`, i nomi non identificano due copie, ma la stessa
lista. Cambiare `xs[1]` o aggiungere un elemento attraverso `alias` modifica un oggetto osservato
da entrambi. Se hai bisogno di un valore indipendente, costruisci esplicitamente una nuova lista e
copi gli elementi con un ciclo. Questo comportamento è diverso da una variabile intera: assegnare
`y = x` copia il valore numerico e una successiva riassegnazione di `x` non aggiorna `y`.

Negli algoritmi con indici, la coppia `i = 1` e `i <= length(xs)` esprime l'intervallo completo
delle posizioni Core. Prima di leggere `xs[i]`, assicurati che `i` sia dentro quell'intervallo;
un indice fuori limite è un errore, non un elemento `nothing`. Il caso di conformance `liste`
verifica proprio le operazioni standard, mentre l'helper `get` del seed ha indici 0-based e non
deve essere confuso con `xs[i]`.

### Esercizi

1. **Costruire e leggere.** Crea `[7, 2, 9]`, stampa primo e ultimo elemento e la lunghezza.
2. **Indici da 1.** Che cosa producono `xs[0]` e `xs[length(xs) + 1]`? Quale errore?
3. **`push!` sul seed.** Perché sul seed si usa la forma `xs = push!(xs, v)`? Verifica la
   differenza con `push!(xs, v)` da solo.
4. **Giro completo.** Stampa tutti gli elementi con un `while` e un contatore, senza guardare
   l'esempio.
5. **Somma e massimo.** Scrivi `somma(xs)` e `massimo(xs)` e provalle su una lista vuota: che
   cosa devono restituire?
6. **Alias.** Dimostra che `alias = xs` non crea una copia e che `xs[1] = 9` è visibile ad
   `alias`.
7. **Copia manuale.** Crea una copia vera di una lista con un ciclo e prova a dimostrare che è
   indipendente.
8. **Annidate.** Costruisci `[[1, 2], [3, 4]]` e stampa il primo elemento interno.
9. **Interi soltanto.** Perché sul seed le liste sono solo di interi? Che cosa succede con
   `[1, "due"]`?
10. **Il caso `liste`.** Esegui il caso di conformance `liste` con l'interprete JS e con il seed:
    perché sul seed è escluso di default?

---

<a id="cap-12"></a>

## 12. Stringhe, simboli e conversioni

Stringhe e simboli sembrano parenti stretti — entrambi contengono testo — ma hanno ruoli
diversi. Una stringa è un dato che si costruisce, si concatena e si stampa; un simbolo è un nome
che il linguaggio tratta come valore atomico, adatto a etichette, chiavi, tag di record e nomi di
tipo. Le conversioni tra i due, e tra testo e numeri, sono il ponte che serve quando un programma
legge input, costruisce messaggi o confronta valori che arrivano come testo.

La tabella riassume le operazioni disponibili in Core:

| operazione | significato |
|---|---|
| `a * b` | concatenazione di stringhe |
| `length(s)` | numero di **byte** UTF-8 (`length("é") == 2`) |
| `string(x)` | rappresentazione testuale di qualsiasi valore (`string(:a) == "a"`, `string([1, 2]) == "[1, 2]"`) |
| `Int(s)` | da stringa a intero (`Int("42") == 42`); da Bool: `0`/`1` |
| `Symbol(s)` | da stringa a simbolo (`Symbol("ciao") == :ciao`) |
| `typeof(x)` | tipo come simbolo |

```triad
nome = "Triad"
saluto = "ciao " * nome
println(saluto, " (", length(saluto), " byte)")
println("risposta: " * string(40 + 2))
println(Int("41") + 1, " ", Symbol("bob"), " ", string(true))
println(:ok == Symbol("ok"))
```

Output:

```text
ciao Triad (10 byte)
risposta: 42
42 bob true
true
```

Per accedere ai singoli byte di una stringa servono i primitivi di bootstrap del capitolo
successivo.

Tre cose meritano attenzione. Primo, le stringhe sono **immutabili**: `saluto = "ciao " * nome`
non modifica `"ciao "`, costruisce una nuova stringa. Questo è coerente con il resto del
linguaggio, dove solo le liste sono mutabili, e rende innocuo passare una stringa a una funzione:
chi la riceve non può alterarla. Secondo, la concatenazione usa `*` e non `+`: `+` resta
l'addizione numerica, e la scelta evita di dover indovinare il tipo degli operandi in un'espressione
come `a + b`. Terzo, `length` conta i **byte**, non i caratteri percepiti: una lettera accentata
può occupare due byte, quindi in Core «lunghezza di una stringa» significa «dimensione in byte
UTF-8», e le operazioni sui singoli caratteri si fanno a livello di byte con i primitivi del
[capitolo 13](#cap-13).

`string(x)` è una rappresentazione pensata per la lettura, non una promessa che il risultato si
possa rileggere come sorgente: `string(:a)` produce `"a"` (senza i due punti), e la stampa di una
lista non è necessariamente codice Triad valido. Per i messaggi va benissimo; per ricostruire un
valore servono le conversioni esplicite. Anche la conversione non è una validazione: `Int("42")`
presuppone che il testo sia nel formato giusto, e che cosa faccia `Int` su un testo che non è un
numero **non è specificato**; il programma deve controllare prima, non sperare in un risultato
utile.

L'ultima trappola riguarda i simboli. `println(:ok)` stampa `ok`, ma il valore è ancora un
simbolo: `:ok == "ok"` è `false`, e il confronto corretto è con `:ok` oppure con
`Symbol("ok")`. L'aspetto stampato di un valore non è il valore.

Riferimento: `conformance/core/cases/stringhe`, `stringhe_concat`, `stringhe_multi`,
`simboli_base`.

### Esercizi

1. **Concatenare.** Costruisci `ciao, Ada!` con `*` e almeno tre pezzi.
2. **Byte.** Verifica `length("ciao")` e `length("è")`: su quale runtime il secondo caso cambia
   comportamento e perché?
3. **Convertire.** Con `string()` e `Int()` trasforma `42` in testo, `"42"` in numero e ritorno.
4. **Escape.** Stampa `prima\ndopo` con una sola `println`: che cosa succede sul seed (cap. 15)?
5. **Simboli.** Confronta `:ok` con `"ok"`: uguaglianza, stampa e uso come etichette.
6. **Conversioni impermesse.** `Int("ciao")` e `"42" + 1`: quale errore per ciascuno?
7. **Frasi composte.** Dati `nome = "Ada"` e `anni = 36`, costruisci e stampa la frase completa.
8. **Immutabili.** Dimostra che ogni concatenazione produce una stringa nuova.
9. **Primi `n` byte.** Scrivi una funzione che stampi i primi `n` byte di una stringa (servono le
   primitive del capitolo 13).
10. **Il caso `stringhe`.** Esegui il caso di conformance `stringhe`: quali parti funzionano sul
    seed e quali no?

---

<a id="cap-13"></a>

## 13. Primitivi di bootstrap

Servono a S1 per leggere e analizzare sorgente Triad. **Non** fanno parte di Triad-Full
(SPEC-CORE §8): usali solo nel codice di bootstrap.

Il nome «bootstrap» spiega la loro esistenza. Per scrivere in Triad un interprete di Triad serve
la capacità di leggere un file, di guardare i singoli byte di quel file e di estrarne pezzi: sono
operazioni che il linguaggio non offre con i tipi normali, perché le stringhe sono immutabili e
non indicizzabili. I primitivi colmano questa lacuna al livello più basso possibile, quello dei
byte, e restano fuori dal linguaggio normale perché una libreria di stringhe completa arriverà
con S1, scritta in Triad.

La tabella elenca i cinque primitivi e la loro semantica:

| primitiva | semantica |
|---|---|
| `readfile(path)` | contenuto del file come `String`; errore se non leggibile |
| `strlen(s)` | numero di byte |
| `strbyte(s, i)` | byte (`Int` 0–255) alla posizione `i`, da 1 |
| `strsub(s, a, b)` | sottostringa dai byte `a` a `b` inclusi, da 1 |
| `exit(n)` | termina il processo con codice `n` |

Tutte le posizioni sono **1-based**, come gli indici delle liste, e `strsub` include entrambi gli
estremi: `strsub(s, 1, 3)` restituisce i primi tre byte. `strbyte` restituisce un intero tra 0 e
255, non un carattere: il programma deve sapere quali codici gli interessano. Un indice fuori
intervallo è un errore di esecuzione, non un byte zero; per questo chi analizza un sorgente
controlla sempre i limiti prima di leggere.

Esempio: contare le cifre di una stringa e separare la prima parola.

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

Output:

```text
3
abc
```

Il primo ciclo conta le cifre confrontando il byte con i codici ASCII `48`–`57`: `strbyte` non
dice «questo è un carattere», dice «questo è il numero 48», e il programma deve sapere che 48 è
la cifra `0`. Il secondo ciclo cerca il primo spazio (codice `32`) e poi `strsub` estrae i byte
fino a quello precedente; nota che `fine - 1` può valere `0` se la stringa comincia con uno
spazio, ed è un caso che un tokenizer reale deve gestire esplicitamente.

Un programma può leggere se stesso o un altro sorgente con `readfile(ARGS[1])`: è esattamente
il primo passo di un interprete self-hosted ([capitolo 37](#cap-37)). Vale però la pena ribadire
il confine: un programma che usa `readfile`, `strlen`, `strbyte`, `strsub` o `exit` **non** è un
programma Triad-Full valido. È una delle poche eccezioni alla regola «Core è un sottoinsieme di
Full», ed è il motivo per cui questi primitivi compaiono in un capitolo a parte invece che tra le
operazioni normali sulle stringhe.

### Esercizi

1. **Le cinque primitive.** Scrivi un programma minimo per ciascuna: `readfile`, `strlen`,
   `strbyte`, `strsub`, `exit`.
2. **Byte e caratteri.** Verifica `strlen("è") == 2` e spiega perché una `String` è una sequenza
   di byte.
3. **Codici ASCII.** Conta le cifre di una stringa confrontando i byte con 48–57, come
   nell'esempio.
4. **La prima parola.** Trova il primo spazio e estrai la prima parola con `strsub`: gestisci il
   caso in cui lo spazio non c'è.
5. **Maiuscole.** Conta i byte nell'intervallo 65–90 di una frase.
6. **`exit(n)`.** Termina un programma con codice 3 e verificalo dal terminale.
7. **Leggere sé stessi.** Con `readfile(ARGS[1])` fai stampare a un programma il proprio
   sorgente: perché è il primo passo di un interprete self-hosted?
8. **Solo cifre.** Scrivi un programma che dica se una stringa è un intero scritto in decimale.
9. **Perché «primitive».** Perché queste cinque non fanno parte di Triad-Full e non vanno usate
   nei programmi applicativi?
10. **Analizzatore.** Costruisci un piccolo programma che, data una stringa, ne stampi il numero
    di parole (parole = gruppi separati da spazi, byte 32).

---
<a id="cap-14"></a>

## 14. Errori di esecuzione

Un errore di esecuzione è un punto in cui il programma non può più andare avanti: un nome che non
esiste, un tipo sbagliato, un indice fuori intervallo. In Triad-Full gli errori sono valori e si
possono gestire; in Triad-Core no, e la differenza è importante: qui un errore **termina il
processo con exit code 1** e stampa un messaggio diagnostico su stderr. Quello che era già stato
stampato su stdout resta.

Poiché non c'è modo di catturare l'errore, la strategia di un programma Core non è «gestirlo» ma
«non provocarlo»: controllare i limiti prima di un accesso, convertire i valori prima di usarli,
verificare le ipotesi all'inizio di una funzione. Il messaggio del runtime serve a capire dove e
perché il programma si è fermato.

```triad
println("prima")
println(non_esiste)
println("dopo")
```

```text
stdout:  prima
stderr:  error: undefined variable non_esiste
exit:    1
```

Messaggi dell'interprete JS (stderr) e cause tipiche:

| messaggio | causa |
|---|---|
| `parse error: unexpected token …` / `parse error: expected …` | sintassi non Core (es. `1.5`, `/`, `() -> …`, `end` mancante) |
| `error: undefined variable NOME` | nome mai assegnato, o funzione chiamata prima di essere definita |
| `error: not a function` | si chiama un valore che non è una funzione (`x = 5; x(1)`) |
| `error: arity mismatch` | numero di argomenti diverso dai parametri |
| `error: index out of range` | `xs[i]` con `i < 1` o `i > length(xs)` |
| `error: + type error` (e simili per `- * % < …`) | operandi di tipo sbagliato (`1 + "a"`) |
| `error: if cond` / `while cond` / `ternary cond` / `&& expects bool` | condizione non `Bool` |
| `error: div by zero` / `negative exponent` | `x % 0`, `2 ^ -1` |
| `error: unknown function NOME` | builtin riservato usato in modo non supportato |
| `cannot read file: …` | file inesistente o non leggibile |
| `usage: triad FILE [ARG...]` (exit 2) | nessun file passato |

Il seed Windows non stampa messaggi dettagliati: esce con codice `1` (sintassi, variabile o
funzione non definita, arità, lettura) o `2` (nessun argomento).

Per diagnosticare un errore, separa il **livello** dal **punto del programma**. Un `parse error`
indica che il testo non è stato riconosciuto come grammatica Core: controlla prima il profilo,
parentesi e `end`, poi gli operatori non Core. Un `undefined variable` o un errore di tipo arriva
invece durante la valutazione: controlla l'ordine delle definizioni, l'ambiente in cui nasce il
nome e il tipo effettivo degli argomenti. Se il programma stampa una prima riga e poi fallisce,
quell'output precedente non viene annullato; riproduci il caso minimo e confronta stdout, stderr
e codice di uscita separatamente.

Non copiare automaticamente il testo dell'errore prodotto da un runtime in un test. La suite
Core confronta stdout e codice di uscita, non stderr: il contratto importante è la classe di
comportamento dichiarata dallo standard. I dettagli diagnostici possono cambiare tra runtime,
mentre un test del valore restituito o dell'uscita deve restare ripetibile.

### 14.1 Errori come valori, in Core

Per propagare errori senza terminare il processo (come farà S1 per i programmi Full) si usa
una convenzione con liste: `[:Err, kind, msg]`.

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

Output:

```text
errore domain: divisione per zero
3
```

La convenzione `[:Err, kind, msg]` non è un tipo del linguaggio: è un protocollo tra funzioni,
scritto con i mezzi che Core offre (liste e simboli). Chi rileva un errore lo costruisce con
`err`; chi lo riceve deve controllare il tag prima di leggere i campi, ed è per questo che
`is_err` esiste. Il vantaggio è che l'errore viaggia come qualsiasi altro valore: può essere
restituito, salvato, confrontato, stampato. Il limite è che nulla obbliga una funzione a
rispettare il protocollo: se restituisce una lista normale, il controllo del tag fallisce e il
programma prosegue con il valore sbagliato.

Quando S1 eseguirà Triad-Full, il linguaggio avrà i valori `Err` veri
([capitolo 24](#cap-24)) e questa convenzione diventerà superflua; nel frattempo è il modo di far
convivere «errore come dato» con un runtime che non lo prevede.

Nota: `&&` cortocircuita, quindi `v[1]` è valutato solo se `v` è una lista di 3 elementi.

### Esercizi

1. **Errori classici.** Produci volontariamente: `undefined variable`, `+ type error`,
   `index out of range`, `arity mismatch`, `if cond`, `not a function`.
2. **`parse error` o `error`?** Classifica ciascuno dei casi dell'esercizio 1 nelle due famiglie
   del capitolo 14.
3. **Codice di uscita.** Verifica che ogni programma sbagliato termini con codice `1` e che il
   messaggio finisca su stderr.
4. **Errori come liste taggate.** Scrivi `err(kind, msg) = [:Err, kind, msg]` e `iserr(x)` e
   usali per restituire un errore da una funzione.
5. **Gestire l'errore.** Con `iserr` trasforma il risultato di una funzione in un messaggio
   leggibile.
6. **Categorie tue.** Inventati tre categorie di errore per un programma che lavori su liste e
   usale nel codice.
7. **Diagnosi.** Un programma stampa `0` invece della somma: applica il metodo del capitolo 12
   delle Fondamenta e trova il bug.
8. **Errori del seed.** Perché sul seed Windows non vedi il messaggio ma solo il codice di
   uscita? Come diagnostichi in quel caso?
9. **Errori e output.** Un programma che stampa l'output giusto ma fallisce alla fine: quale
   codice di uscita? Perché è corretto così?
10. **Il caso `errore`.** Esegui il caso di conformance `errore` e spiega golden e codice atteso.

---

<a id="cap-15"></a>

## 15. Interprete JS e seed Windows: differenze

Triad-Core ha due implementazioni, e non sono la stessa cosa. L'interprete JS è lo strumento di
sviluppo: gira ovunque ci sia Node.js, è facile da modificare ed è il riferimento usato per
verificare i casi di conformità. Il seed Windows è il primo passo del bootstrap: un interprete in
codice macchina, senza runtime ospiti, più limitato perché scritto a mano. Sapere che cosa
funziona su entrambi è essenziale se un programma deve girare anche sul seed, come il codice di
S1.

Il contratto è `conformance/core/`: entrambi i runtime devono produrre gli stessi golden. Oggi
sia l'interprete JS sia i seed (PE Windows ed ELF Linux) passano tutti i 42 casi byte per byte:
il gate gira sull'ELF nativo (job `seed-linux`). Restano differenze di dominio misurate,
registrate nei probe e nella tabella:

| funzionalità | interprete JS (`seed/dev/triad_core.cjs`) | seed Windows (`seed.exe`) |
|---|---|---|
| interi, Bool, operatori, confronti, ternario | ✅ | ✅ |
| `if`/`elseif`/`else`, `while`, `let`, `begin` | ✅ | ✅ |
| funzioni forma breve e blocco, ricorsione | ✅ | ✅ (max 4 parametri) |
| `return`, `break`, `continue` | ✅ | non elencati in `seed/windows-x86_64/README.md` |
| lambda | ✅ più parametri | ✅ **un solo parametro** |
| chiusure | condivise (mutazioni visibili, SPEC-CORE §5) | **per valore**, solo l'ultimo legame del frame |
| stringhe, `*`, `length(s)` | ✅ | ✅ |
| `string(x)` | ✅ tutti i tipi | solo `Int` e `String` |
| simboli, `nothing` | ✅ | ✅ |
| liste | eterogenee, `xs[i]`, `xs[i] = v`, `length`, `push!` | solo interi; costruzione, stampa e `push!` (max 64 elementi) |
| `get(xs, i)` | non esiste | helper **non standard**, indici **da 0** |
| `-=`, `*=`, `Int`, `Symbol`, `typeof` | ✅ | non elencati nel README del seed |
| `ARGS`, primitivi di bootstrap | ✅ | non elencati nel README del seed |
| stampa di una funzione | `#lambda(x)` | `fun` |
| `triad -` (stdin) | ✅ | no |
| messaggi d'errore | su stderr | solo exit code |

La tabella va letta come una mappa di portabilità: la colonna di sinistra è il comportamento che
un programma Core corretto può usare, la destra dice che cosa il seed sa fare oggi. «Non elencato
nel README» non significa automaticamente «non funziona», ma significa che non è un comportamento
su cui puoi contare senza provarlo. Le differenze più insidiose sono quelle semantiche, non quelle
sintattiche: il seed può accettare una lambda e catturarla in modo diverso, quindi un programma
che viene eseguito non è detto che dia lo stesso risultato.

Regola pratica: **scrivi codice che rispetta SPEC-CORE e verificalo con l'interprete JS**; se
deve girare sul seed (come `selfhost/`), restringiti alla colonna di destra e verificalo su
Windows.

### Esercizi

1. **Le differenze che contano.** Elenca a memoria le prime tre righe della tabella delle
   differenze fra i due runtime.
2. **Lambda a un parametro.** Scrivi una lambda con due parametri e verifica dove non gira:
   quale alternativa usi?
3. **Chiusure.** Costruisci un esempio in cui la cattura per valore del seed e quella condivisa
   dell'interprete JS danno risultati diversi.
4. **`string(x)` limitato.** `string(true)` e `string(:a)`: su quale runtime falliscono?
5. **Liste del seed.** Scrivi un programma sulle liste che giri su entrambi i runtime: cosa devi
   evitare?
6. **`get` non standard.** Perché non si usa nei programmi portabili? Riscrivi un programma che
   lo usi con `xs[i]`.
7. **`return`, `break`, `continue`.** Quali di questi sono rischiosi per la portabilità? Scrivi
   la variante sicura.
8. **Programma portabile.** Scrivi un programma Core che giri identico su entrambi i runtime e
   verificalo davvero su entrambi.
9. **Semantica giusta.** Quale delle due colonne della tabella descrive la semantica corretta?
   Perché?
10. **La tua checklist.** Scrivi la checklist di controllo che userai prima di dichiarare un
    programma «portabile».

---

<a id="cap-16"></a>

## 16. Pattern idiomatici Triad-Core

I capitoli precedenti hanno spiegato i singoli costrutti; questo li mette insieme in alcuni
schemi ricorrenti. Non sono l'unico modo di scrivere Triad-Core, ma sono i modi in cui il
linguaggio viene effettivamente usato nel repository, compreso il codice di S1 in `selfhost/`.
Riconoscerli aiuta a leggere il codice altrui e a scegliere una struttura quando non ne hai già
una in mente.

### 16.1 Funzioni di ordine superiore scritte in Core

Core non ha `map`/`filter`/`reduce`: si scrivono una volta con `while` e lambda.

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

Output:

```text
[1, 4, 9, 16, 25, 36]
[2, 4, 6]
21
```

Questi tre schemi mostrano che le funzioni di ordine superiore non richiedono supporto
sintattico: una funzione che riceve un'altra funzione è già possibile, e `while` basta per
scorrere la lista. `mappa` costruisce una lista nuova, `filtra` decide elemento per elemento,
`riduci` porta avanti un accumulatore. Sono anche il punto di partenza quando il tuo programma
deve trasformare dati senza le comodità di Triad-Full.

### 16.2 Record come liste taggate

Core non ha `struct`: un record è una lista con un simbolo come tag nella prima posizione.

```triad
punto(x, y) = [:Punto, x, y]
px(p) = p[2]
py(p) = p[3]
somma_punti(a, b) = punto(px(a) + px(b), py(a) + py(b))
p = somma_punti(punto(1, 2), punto(10, 20))
println(p, " ", p[1] == :Punto)
```

Output:

```text
[:Punto, 11, 22] true
```

Il tag non è decorazione: è il discriminante che permette di riconoscere il tipo di record a
runtime e di scrivere funzioni come `px` e `py` che assumono una forma precisa. In Full lo stesso
ruolo sarà dello `struct` ([capitolo 20](#cap-20)), con il vantaggio di un controllo dei campi; in
Core la lista taggata dà la stessa struttura senza quel controllo, e sta al programmatore
rispettare la convenzione.

### 16.3 Ambiente come lista di associazioni

È la struttura usata dagli interpreti in `selfhost/`: una lista piatta `[nome1, valore1,
nome2, valore2, …]` (in Core puoi anche usare coppie annidate).

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

Output:

```text
[:x, 11, :y, 20] 11 nothing
```

La lista piatta alterna nome e valore: `env_get` avanza di due posizioni, `env_set` aggiorna se
trova il nome e altrimenti aggiunge in coda. Il `while i < length(env)` (non `<=`) è deliberato:
l'ultima posizione utile è `length(env) - 1`, perché `env[i + 1]` deve restare dentro la lista.
È la stessa struttura che rende possibile un interprete scritto in Core: gli ambienti sono dati
come gli altri, non un meccanismo nascosto del linguaggio.

### 16.4 Stato mutabile condiviso

Poiché una funzione nominata non può riassegnare un globale, lo stato condiviso si tiene in
una lista (mutabile) o in una chiusura.

```triad
stato = [0]
function tick()
    stato[1] += 1
end
tick()
tick()
println(stato[1])
```

Output:

```text
2
```

La lista fa da cella condivisa: la funzione nominata non può riassegnare `stato`, ma può
modificare l'oggetto a cui `stato` punta, e la mutazione resta visibile fuori. È il modo più
semplice di ottenere stato mutabile in Core senza chiusure; la chiusura
([capitolo 10](#cap-10)) è l'alternativa quando lo stato deve restare privato.

### 16.5 Costruire stringhe

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

Output:

```text
ababab
1, 2, 3
```

Costruire una stringa per concatenazioni successive è corretto ma costa: ogni `*` crea una nuova
stringa, quindi il ciclo costruisce tante stringhe intermedie quante sono le iterazioni. In Core
non ci sono alternative migliori — non c'è una struttura di appoggio — e per i programmi di
studio va bene; in un interprete reale conviene accumulare i pezzi in una lista e unirli una
volta sola alla fine.

### 16.6 Stile

Le regole seguenti non sono estetiche: nascono dal fatto che lo stesso codice potrebbe dover
passare a Triad-Full e che il repository è scritto in italiano.

- Funzioni piccole con nomi chiari (in italiano, come nel resto del repository).
- Caso base esplicito in ogni ricorsione; per profondità grandi preferisci `while`.
- Cicli con contatori espliciti (`i = 1 … while i <= length(xs)`).
- Non usare `fact`, `rule`, `solve`, `struct` e le altre parole chiave di Full come nomi:
  il codice deve restare valido anche in Triad-Full.
- Scrivi `!io` sulle funzioni che stampano: Core lo ignora, Full lo richiede.

Sono convenzioni, non regole del linguaggio: il runtime non le controlla. Ma un programma che le
rispetta resta valido sia in Core sia in Full, e questa è la qualità che rende il codice del
progetto riutilizzabile negli stadi successivi del bootstrap.

### Esercizi

1. **HOF in Core.** Scrivi `mappa(f, xs)`, `filtra(f, xs)` e `riduci(f, acc, xs)` con un ciclo.
2. **Record taggato.** Rappresenta `(:persona, "Ada", 36)` come lista taggata e scrivi le
   funzioni di accesso.
3. **Ambiente.** Riscrivi `env_get`, `env_set` e `env_rimuovi` e provali con quattro coppie.
4. **Stato condiviso.** Scrivi un contatore basato su una lista mutabile e spiega perché
   funziona senza assegnamenti condivisi.
5. **Costruire stringhe.** Stampa una lista di interi nel formato `[1, 2, 3]` costruendo la
   stringa pezzo per pezzo.
6. **Stile.** Riscrivi un tuo programma applicando le regole di stile del capitolo 16.6.
7. **Predicati come funzioni.** Scrivi `tutti(f, xs)` e `qualcuno(f, xs)` con i pattern del
   capitolo.
8. **Una funzione, un compito.** Dividi una funzione da venti righe in tre funzioni piccole e
   verifica che l'output non cambi.
9. **Nomi con `!`.** Perché `push!` ha il punto esclamativo? Scrivi una tua funzione mutante e
   nominala secondo la convenzione.
10. **Sottoinsieme comune.** Riscrivi un programma del capitolo perché giri anche sul seed
    Windows, mantenendo lo stesso output.

---

<a id="cap-17"></a>

## 17. Esercizi guidati

Gli esercizi mettono in pratica i capitoli 4–16 e, letti di seguito, raccontano un percorso: si
parte da calcolo e ricorsione, si passa a liste e stringhe, e si finisce con un piccolo tokenizer
e un valutatore di espressioni, cioè con i primi due pezzi di un interprete. Ogni esercizio ha
una soluzione verificata, nascosta in un riquadro: aprila solo dopo averci provato, perché il
punto non è leggere la soluzione ma scriverne una che produca lo stesso output.

Per controllare la tua soluzione, salvala in un file ed eseguila con
`node seed/dev/triad_core.cjs`; confronta poi l'output con quello mostrato nella soluzione. Se
l'output coincide ma il codice è diverso, va bene: gli esercizi descrivono un comportamento, non
un'unica scrittura possibile.

### Esercizio 1 — Potenza e somme

Senza usare `^`, scrivi `potenza(b, e)` ricorsiva e `somma_fino(n)` (somma `1 + … + n`) con
`while`. Stampa `potenza(3, 13)`, `potenza(2, 10)` e `somma_fino(100)`.

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

Output:

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

Output:

```text
[2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
```

</details>

### Esercizio 3 — Inverti una lista

Scrivi `inverti(xs)` che restituisce una nuova lista con gli elementi in ordine inverso.

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

Output:

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

Output:

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

Output:

```text
3
```

</details>

### Esercizio 6 — Un mini-tokenizer

Trasforma `"12+x*3"` in una lista di token `[tipo, testo]`, con tipi `:num`, `:id`, `:op`.
È il primo passo di un interprete (vedi `selfhost/tokenizer.td`).

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

Output:

```text
[[:num, 12], [:op, +], [:id, x], [:op, *], [:num, 3]]
```

</details>

### Esercizio 7 — Valutare un'espressione

Usando i token dell'esercizio 6, scrivi un valutatore a discesa ricorsiva per `+` e `*` con
precedenza, dove le variabili vengono da una lista di associazioni. Suggerimento: tieni la
posizione corrente in una lista `pos = [1]` per poterla aggiornare dalle funzioni.

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

Output:

```text
42
26
```

</details>

### Esercizi supplementari

1. **Contatore di vocali.** Conta le vocali di una stringa usando i byte (`strbyte`) o i
   confronti sui caratteri.
2. **Massimo comune divisore.** Implementa l'algoritmo di Euclide con il solo operatore `%`.
3. **Divisori.** Stampa tutti i divisori propri di un intero e la loro somma.
4. **Crivello.** Trova i primi numeri primi fino a 50 con un crivello su lista booleana.
5. **Merge.** Unisci due liste ordinate in una terza lista ordinata, senza `sort`.
6. **Torre di Hanoi.** Stampa le mosse per spostare `n` dischi: ricorsione pura.
7. **Cifrario di Cesare.** Sposta di 3 posizioni i byte alfabetici di una stringa (attenzione a
   restare nell'intervallo delle lettere).
8. **Gioco del numero.** Simula «indovina il numero» con una sequenza fissa di tentativi in una
   lista, stampando `troppo alto`/`troppo basso`.

---
<a id="parte-3"></a>

# Parte III — Triad-Full (lo standard completo)

Questa parte descrive il linguaggio definito da [`SPEC.md`](SPEC.md). **Non è ancora
eseguibile** dal runtime attuale: serve per conoscere lo standard, scrivere codice pronto per
S1 e capire i golden di `conformance/cases/`. Ogni capitolo indica la sezione di SPEC da cui
deriva. Gli output marcati **Output (golden Full):** provengono dai golden congelati.

<a id="cap-18"></a>

## 18. Lessico e tipi Full (SPEC §1, §4)

Full estende il lessico di Core con:

| elemento | forma | esempi |
|---|---|---|
| identificatore | come Core, anche lettere non ASCII; `!` finale se non seguito da `=` | `età`, `push!` |
| variabile logica | `?` **attaccato** a un nome | `?x`, `?who` |
| variabile anonima | `?_` (ogni occorrenza è nuova) | `parent(?x, ?_)` |
| `Float` | `3.14`, `1e-9` | |
| interpolazione | `"x = $x"`, `"$(a + b)"`; escape aggiuntivo `\$` | |
| commenti annidati | `#= a #= b =# c =#` | |
| macro | `@nome(...)` | `@unless(c, e)` |

**Parole chiave:** `function struct macro end if elseif else for in while let begin return
break continue fact rule solve quote try catch with requires ensures true false nothing isa is`.
Contestuali dopo `solve`: `limit depth steps trace`.

**Regole dei due punti `:`**
- `1:n`, `xs[2:end]`: `:` attaccato a un valore, senza spazi → range;
- `f(:a)`, `x = :a`: `:` non preceduto da un valore e seguito da un nome → simbolo;
- `:( … )` → codice quotato;
- `c ? a : b`: `:` circondato da spazi → ternario.

**Regola del `?`:** `?x` attaccato = variabile logica; `? ` con spazio = ternario.

Gli a capo chiudono un'istruzione, tranne dentro `( )`, `[ ]` e `:( )`, e subito dopo un
operatore binario o una virgola di `rule`.

**Tipi Full** (oltre a quelli di Core):

| tipo | valori |
|---|---|
| `Int`, `Float` (sottotipi di `Number`) | `42`, `3.5` |
| `Expr` | codice quotato (`Node`) |
| `Term`, `Cons` | termini e pattern lista logici |
| `Solution` | `{who = :dave}` |
| `Err` | errore come dato |
| `Type` | `typeof(3) == Int` |
| struct utente | `Point(3.0, 4.0)` |
| `Any` | supertipo di tutto, usato nelle firme |

**Variabili tipate:**

```triad-full
x::Int = 5
x = 6          # bene
x = 5.5        # Err(:type): il nome mantiene il tipo dichiarato
y::Float = 1.0
y = 2          # 2.0: conversione Int → Float
```

Il vincolo nasce con la dichiarazione e vive nell'ambiente in cui il nome è stato creato.

### Esercizi

1. **Novità di lessico.** Quali forme introduce Triad-Full rispetto al Core (float,
   interpolazione, tipi dichiarati)? Scrivi un esempio per ciascuna.
2. **Interpolazione.** **[Full]** Riscrivi con `"ciao $nome"` e `"$(x + 1)"` un saluto che in
   Core richiedeva `*` e `string()`.
3. **Tipi dichiarati.** **[Full]** Scrivi `x :: Int = 5` e prova assegnamenti successivi di
   tipi diversi: quando scatta l'errore?
4. **Gerarchia.** **[Full]** Disegna la gerarchia fra `Any`, `Number`, `Int`, `Float` e spiega
   cosa significa per il dispatch del [capitolo 19](#cap-19).
5. **Conversioni.** **[Full]** Con `Int(x)`, `Float(x)`, `String(x)`, `Symbol(x)` converti un
   valore per ciascun tipo.
6. **`isa` e `typeof`.** **[Full]** Confronta i due operatori con esempi e spiega quando
   usare l'uno o l'altro.
7. **Escape Full.** Quali escape sono ammessi in Full (`\n \t \" \\ \$`)? Che cosa succede con
   uno sconosciuto?
8. **Float.** **[Full]** Scrivi un programma con `1.5` e `3.0`: come si comportano `+` e la
   stampa rispetto agli `Int`?
9. **Core dentro Full.** Prendi un programma Core del [capitolo 7](#cap-7) e verifica che sia
   valido anche come programma Full.
10. **Golden.** Verifica gli output del capitolo confrontandoli con i golden della conformance:
    quali sono verificati e quali attesi?

---

<a id="cap-19"></a>

## 19. Funzioni tipate e multiple dispatch (SPEC §5)

```triad-full
sq(x) = x * x
area(n::Number) = :number
area(n::Int) = :int

function dist(a::Point, b::Point)::Float
    requires a.x != b.x || a.y != b.y
    sqrt((a.x - b.x)^2 + (a.y - b.y)^2)
end

function +(a::Point, b::Point)      # gli operatori sono funzioni ridefinibili
    Point(a.x + b.x, a.y + b.y)
end
```

Regole:
- vince il metodo **più specifico** tra gli applicabili (`area(1) == :int`, `area(1.5) == :number`);
- nessun metodo applicabile → `Err(:method)` (o fallback builtin per gli operatori numerici);
- più metodi ugualmente specifici → `Err(:ambiguous)`;
- il tipo di ritorno `::R` è controllato all'uscita (con conversione Int→Float);
- funzioni e operatori sono valori: `reduce(+, xs)`, `map(sq, xs)`;
- lambda tipate: `function (x::Int) x end` → `f(2.0)` è `Err(:type)`.

Per prevedere quale implementazione verrà chiamata, controlla prima il numero di argomenti e poi
il tipo di ciascuno. Con i metodi `area(n::Number)` e `area(n::Int)`, l'intero `1` è compatibile
con entrambi, ma `Int` è più specifico di `Number`; il `Float` `1.5` è compatibile solo con il
metodo su `Number`. Nei metodi con più parametri il confronto è per tupla: una firma può essere
più specifica sul primo parametro ma più generale sul secondo. Se nessuna firma domina tutte le
altre, non si indovina l'intenzione: il risultato è l'errore `:ambiguous`, che richiede una firma
più specifica o una revisione delle firme esistenti.

Il controllo del tipo di ritorno avviene dopo il corpo. Per questo `::Float` non converte gli
argomenti in anticipo e non garantisce che ogni operazione intermedia sia valida; richiede che il
valore prodotto alla fine sia convertibile o compatibile con il tipo dichiarato. Le annotazioni
di parametro e di ritorno sono quindi parti distinte del contratto del metodo.

### Esercizi

1. **Firme tipate.** **[Full]** Definisci `area(x::Int)` e `area(x::Float)` e verifica
   `area(1) == :int` e `area(1.5) == :number` come nell'esempio del capitolo.
2. **Più specifico vince.** **[Full]** Aggiungi un metodo su `Number`: quale viene scelto per
   `1.5` e perché?
3. **Confronto per tupla.** **[Full]** Con `f(a::Int, b::Number)` e `f(a::Number, b::Int)`,
   costruisci una chiamata ambigua e una univoca.
4. **Nessun metodo.** **[Full]** Chiama una funzione con un tipo senza metodi: quale errore e
   quali informazioni contiene?
5. **Tipo di ritorno.** **[Full]** In `f(x)::Int` il risultato viene convertito: scrivi un caso
   in cui la conversione è silenziosa e uno in cui fallisce.
6. **Dispatch e gerarchia.** **[Full]** Disegna l'albero dei metodi di una funzione con tre
   firme e indica quale scatta per quattro argomenti diversi.
7. **Operatori-funzione.** **[Full]** Aggiungi un metodo `+` a una struct e prova la somma di
   due istanze.
8. **Funzione generica.** **[Full]** Scrivi una funzione generica con tre metodi e spiega che
   cosa succede quando ne ridefinisci uno.
9. **Parametri e ritorno.** Perché il tipo di ritorno non partecipa alla scelta del metodo?
   Costruisci un esempio che lo dimostri.
10. **Golden.** Verifica l'output golden dell'esempio `area` e spiega perché è «atteso» e non
    «eseguito».

---

<a id="cap-20"></a>

## 20. Struct (SPEC §4)

```triad-full
struct Point
    x::Float
    y::Float
end

p = Point(3, 4)      # costruttore posizionale, Int → Float
p.x                  # 3.0
typeof(p) == Point   # true
p isa Point          # true
```

- Immutabili; campi tipizzati.
- Campo inesistente → `Err(:field)`; tipo sbagliato → `Err(:type)`.
- In Core lo stesso concetto si rappresenta con una lista taggata ([§16.2](#cap-16)).

Una struct fornisce un record **nominato**: il nome del tipo distingue `Point` da un altro record,
mentre i nomi dei campi (`x`, `y`) evitano di ricordare posizioni numeriche. La costruzione
controlla i valori rispetto ai tipi dei campi; l'accesso `p.x` risolve il campo per nome. La
struttura è immutabile nello standard, quindi i campi descrivono lo stato dell'istanza creata e
non si aggiornano con un'assegnazione successiva. La lista taggata Core è più flessibile, ma
sposta queste garanzie sul codice che costruisce, legge e modifica il record.

### Esercizi

1. **Definire una struct.** **[Full]** Definisci `Punto` con campi `x::Int` e `y::Int` e
   costruisci un'istanza.
2. **Campi.** **[Full]** Accedi e modifica un campo; poi prova a leggere un campo inesistente:
   quale errore?
3. **Costruttore.** Perché il nome della struct usato come funzione costruisce un valore? Prova
   con argomenti di tipo sbagliato.
4. **Struct e logica.** **[Full]** Usa `Point(?x, ?y)` come termine in un `fact` e unificalo con
   un'istanza.
5. **Struct e dispatch.** **[Full]** Definisci due struct con un metodo comune e chiama la
   funzione su entrambe.
6. **Stampa.** Come viene stampata una struct? Confronta con la stampa di una lista taggata
   (Manuale, cap. 22.2).
7. **Annidate.** **[Full]** Costruisci una struct che contiene un'altra struct e accedi ai campi
   interni.
8. **Confronto.** **[Full]** Che cosa valgono `p1 == p2` per due istanze con gli stessi campi?
   Verifica.
9. **Struct o lista taggata?** Quando conviene una struct e quando una lista taggata? Scrivi la
   stessa entità in entrambi i modi.
10. **Golden.** Verifica l'output golden dell'esempio sulle struct e annota le differenze con il
    comportamento attuale dei runtime.

---

<a id="cap-21"></a>

## 21. Controllo di flusso Full: `for`, range, comprehension, `try` (SPEC §2)

```triad-full
s = 0
for i in 1:10
    s += i
end                                  # s == 55

xs = [1, 2, 3]
xs[end]                              # 3
xs[2:end]                            # [2, 3]
[x^2 for x in 1:4 if x > 2]          # [9, 16]
x = 3; x > 2 ? :big : :small         # :big

e = try div(1, 0) end                # l'errore diventa il valore
r = try div(1, 0) catch err; 0 end   # con catch: err è l'Err, il valore è quello del ramo
```

Altri valori attesi (dai vecchi test dell'implementazione Julia):

```triad-full
x = 2; y = x * 21; y                           # 42
7 / 2                                          # 3.5
"ab" * "cd"                                    # "abcd"
let a = 1, b = a + 1; a + b; end               # 3
if 1 > 2; :a; elseif 2 > 1; :b; else; :c; end  # :b
sq(x) = x * x; map(sq, [1, 2, 3])              # [1, 4, 9]
reduce(+, [1, 2, 3, 4])                        # 10
filter(x -> x % 2 == 0, 1:6)                   # [2, 4, 6]
function fact_(n::Int)::Int
    if n <= 1; return 1; end
    n * fact_(n - 1)
end; fact_(10)                                 # 3628800
```

`requires c` al top level è un'asserzione; `ensures c` è ammesso solo dentro `function`.

Nel ciclo, il range `1:10` rappresenta i valori interi inclusivi da 1 a 10: non è una lista
letterale che devi scrivere a mano. `for` associa a `i` ciascun valore successivo, esegue il corpo
per quell'associazione e prosegue fino alla fine dell'iterabile. Una comprehension combina lo
stesso schema con la costruzione del risultato: valuta il filtro per ogni elemento e aggiunge
all'output solo le espressioni corrispondenti. L'ordine di lettura è quindi "iteratore, filtro,
espressione", non una valutazione simultanea.

`try` delimita invece il punto in cui un errore può essere trasformato in risultato. Senza
`catch`, l'espressione restituisce direttamente l'`Err`; con `catch err`, il nome locale `err`
identifica l'errore e il valore finale è quello del blocco di recupero. Questo rende possibile
gestire un caso senza confondere un errore con un valore di successo dello stesso tipo.

### Esercizi

1. **`for` e range.** **[Full]** Riscrivi un `while` che somma 1..10 con `for i in 1:10`.
2. **Range.** **[Full]** Scrivi `a:b` con `a > b`: che cosa produce? E con `a == b`?
3. **Comprehension.** **[Full]** Costruisci la lista dei quadrati da 1 a 5 e poi quella dei soli
   dispari con un filtro.
4. **Comprehensione annidata.** **[Full]** Genera le coppie `(i, j)` di una matrice 3×3.
5. **`try`/`catch`.** **[Full]** Cattura `Int("ciao")` e gestisci l'errore per categoria.
6. **`try` come valore.** **[Full]** `e = try f(x) end`: che cosa contiene `e` quando tutto va
   bene e quando c'è un errore?
7. **`x in xs`.** **[Full]** Usa `in` come filtro di una comprehension.
8. **Da Full a Core.** Riscrivi un `for` con comprehension in un `while` Core equivalente e
   confronta gli output.
9. **Ordine di valutazione.** In una comprehension con più generatori, in quale ordine vengono
   prodotte le coppie? Verifica.
10. **Golden.** Verifica gli output golden degli esempi del capitolo su `for`, comprehension e
    `try`.

---

<a id="cap-22"></a>

## 22. Logica: fatti, regole, `solve` (SPEC §6)

```triad-full
fact parent(:alice, :bob)
fact parent(:alice, :carol)
fact parent(:bob, :dave)

rule grandparent(?x, ?z) :- parent(?x, ?y), parent(?y, ?z)
rule ancestor(?a, ?d) :- parent(?a, ?d)
rule ancestor(?a, ?d) :- parent(?a, ?x), ancestor(?x, ?d)
```

`solve` restituisce una **lista di `Solution`** (è un valore, non stampa nulla):

```triad-full
sols = solve grandparent(:alice, ?who) limit 5
[s.who for s in sols]                       # [:dave]
[s.d for s in solve ancestor(:alice, ?d)]
```

- Opzioni: `limit n`, `depth d`, `steps s` (default 1 000 000), `trace`.
- Un predicato usato come funzione è un `Bool`: `grandparent(:alice, :dave)` → `true`;
  si può usare in `if`.
- Goal: `p(t…)`, `g1 && g2`, `(g1, g2)`, `g1 || g2`, `!g`/`not(g)`, `a = b` (unificazione),
  `?y is espr`, confronti, funzione Triad che restituisce `Bool`, `true`/`false`.
- Occurs-check attivo: `solve ?x = f(?x)` non ha soluzioni (non va in ciclo).
- Liste stile Prolog nei pattern: `[?h | ?t]`.
- `vars(s)` restituisce i nomi legati in una `Solution`; si accede con `s.nome` o `s[:nome]`.

Per leggere una regola, separa la **testa** dal **corpo**. In
`grandparent(?x, ?z) :- parent(?x, ?y), parent(?y, ?z)`, la testa descrive quali valori la regola
può dimostrare; il corpo richiede due prove in sequenza. Il motore cerca un `parent` per il primo
goal, conserva il legame trovato per `?y`, poi usa quel legame nel secondo goal. Se il secondo
goal fallisce, torna alla scelta precedente e prova il prossimo fatto compatibile: è il
backtracking. Se entrambi riescono, `?z` viene restituito nella soluzione.

Le variabili con lo stesso nome in clausole diverse non condividono accidentalmente il loro
stato: a ogni uso della regola vengono rinominate. L'occurs-check impedisce legami ricorsivi
impossibili come `?x = f(?x)`. Il limite `depth` taglia i rami troppo profondi; `steps` limita il
lavoro totale; `limit` limita quante soluzioni vengono raccolte. Sono controlli differenti, e
una lista vuota ottenuta entro i limiti non è equivalente a una ricerca interrotta da `Err(:budget)`.

Esempi:

```triad-full
# percorso con costo
fact edge(:a, :b, 2)
fact edge(:b, :c, 3)
rule path(?x, ?y, ?c) :- edge(?x, ?y, ?c)
rule path(?x, ?y, ?c) :- edge(?x, ?z, ?c1), path(?z, ?y, ?c2), ?c is ?c1 + ?c2
(solve path(:a, :c, ?costo))[1].costo      # 5

# append alla Prolog
rule app([], ?l, ?l)
rule app([?h | ?t], ?l, [?h | ?r]) :- app(?t, ?l, ?r)
(solve app([1, 2], [3], ?r))[1].r          # [1, 2, 3]
length(solve app(?a, ?b, [1, 2, 3]))       # 4

# negazione per fallimento
fact parent(:tom, :bob)
persone = [:tom, :bob]
foglie = filter(p -> !parent(p, ?_), persone)   # [:bob]
```

### Esercizi

1. **Fatti e regole.** **[Full]** Costruisci una knowledge base familiare con `fact` e la regola
   `ancestor` del capitolo.
2. **`solve` è un valore.** **[Full]** Raccogli le soluzioni in una variabile, contale e leggi un
   legame.
3. **Percorso con costo.** **[Full]** Riscrivi `path`/`edge` e spiega perché serve `is`.
4. **`app`.** **[Full]** Riscrivi le regole di append con `[?h | ?t]` e spiega le quattro
   soluzioni di `solve app(?a, ?b, [1, 2, 3])`.
5. **Negazione per fallimento.** **[Full]** Con `!parent(p, ?_)` seleziona le foglie di una
   knowledge base.
6. **Occurs-check.** **[Full]** `solve ?x = f(?x)`: quante soluzioni e perché?
7. **Le opzioni.** **[Full]** Applica `limit`, `depth` e `steps` alla stessa query e confronta i
   tre risultati.
8. **Predicato come funzione.** **[Full]** Usa un predicato come condizione di un `if` e spiega
   che valore produce.
9. **Variabile anonima.** **[Full]** Usa `?_` dove non ti interessa il legame e spiega la regola
   delle occorrenze.
10. **Golden.** Verifica l'output golden degli esempi logici del capitolo e annota la differenza
    tra «atteso» e «eseguito oggi».

---

<a id="cap-23"></a>

## 23. Destrutturazione (SPEC §2)

Pattern di lista con **arità esatta**; le parentesi attorno al pattern sono obbligatorie.

```triad-full
(a, b) = [1, 2]                 # a == 1, b == 2
e = try (a, b) = [1] end        # e.kind == :bounds
e = try (a, b) = [1, 2, 3] end  # e.kind == :bounds

xs = []
for (k, v) in [[1, 2], [3, 4]]
    push!(xs, k + v)
end                             # xs == [3, 7]
```

- Un elemento non lista o di arità diversa nel `for` → `Err(:bounds)` o `Err(:type)`.
- `function f((a, b))` definisce **due parametri** `a` e `b` (i parametri sono appiattiti):
  `f(10, 20) == 30`. Per destrutturare un singolo argomento lista usa `(a, b) = pair` nel corpo.
- I pattern annidati ricorsivi non sono ancora previsti.

### Esercizi

1. **Coppie.** **[Full]** Con `[a, b] = [1, 2]` assegna due nomi in una riga e usali.
2. **Testa e coda.** **[Full]** Con `[h | t] = [1, 2, 3]` che cosa leggono `h` e `t`? E con la
   lista vuota?
3. **In una regola.** **[Full]** Riscrivi `app` con i pattern `[?h | ?t]` e confronta con la
   versione senza destrutturazione.
4. **Scambio.** **[Full]** Scambia due variabili con `[a, b] = [b, a]`: funziona? Perché?
5. **Lunghezze diverse.** **[Full]** Che cosa succede destrutturando `[a, b]` su una lista di
   tre elementi? E su una lista vuota?
6. **Pattern annidati.** **[Full]** Destruttura `[[1, 2], [3, 4]]` per estrarre il secondo
   elemento della seconda coppia.
7. **Parametri.** **[Full]** Una funzione può ricevere una lista e destrutturarla nel corpo?
   Scrivi un esempio.
8. **`unparse`.** **[Full]** Osserva con `unparse` la forma `:destructure` di una
   destrutturazione: che cosa mostra il round-trip?
9. **Riscrivere senza pattern.** Riscrivi un esercizio di destrutturazione usando solo
   indicizzazione e `length`, e confronta la leggibilità.
10. **Golden.** Verifica l'output golden degli esempi di destrutturazione del capitolo.

---

<a id="cap-24"></a>

## 24. Errori come dati (SPEC §8)

Un errore è un valore `Err(kind, msg, data)`; non diventa un'eccezione dell'host salvo che non
sia gestito al top level (allora il processo esce con codice 1 e stdout vuoto per l'istruzione
fallita: è il caso di conformance `errore`).

```triad-full
e = try div(1, 0) end     # Err(:domain, ...)
e.kind                    # :domain
e.msg                     # messaggio
iserr(e)                  # true
7.0 / 0                   # Inf: la divisione Float non è un errore
throw(err(:mio, "ops", 42))
error("boom")             # Err(:error, ...)

describe(e::Err) = string("errore ", e.kind, ": ", e.msg)
describe(x::Any) = string("valore ", x)
for r in [try div(10, d) end for d in [2, 0, 5]]
    println(describe(r))
end
```

Kinds standard: `:syntax`, `:undef`, `:type`, `:method`, `:ambiguous`, `:field`, `:bounds`,
`:domain`, `:instantiation`, `:contract`, `:budget`, `:effect`, `:host`.

`Err(:syntax)` porta in `data` la posizione (`e.data.line`, `e.data.col`).

La gestione degli errori separa l'operazione fallita dal punto in cui il programma decide come
reagire. `try` non ripara automaticamente lo stato: converte l'esito in un valore `Err` oppure
passa quel valore al blocco `catch`. Il chiamante può quindi scegliere tra mostrare un messaggio,
provare un'alternativa o propagare l'errore restituendolo. Se nessun `try` lo intercetta, il
runtime lo segnala al livello superiore e il processo termina con codice non riuscito. In questo
modo la gestione è esplicita, ma un errore non diventa un successo solo perché è rappresentato da
un valore.

### Esercizi

1. **La forma `Err`.** **[Full]** Costruisci un `Err` con categoria e messaggio e ispeziona
   `kind` e `data`.
2. **Produrre o propagare.** **[Full]** Scrivi una funzione che restituisce un `Err` e una che lo
   lancia con `throw`: quando usare l'una o l'altra?
3. **Catturare.** **[Full]** Con `try`/`catch` gestisci un errore e stampa la sua categoria.
4. **Le categorie.** Associa a ciascuna categoria (`:type`, `:method`, `:bounds`, `:contract`,
   `:budget`, `:effect`) un programma che la produce.
5. **I dati dell'errore.** **[Full]** Per un `Err(:contract)` leggi `data.clause` e `data.fn`:
   che cosa ti dicono?
6. **Core e Full a confronto.** Riscrivi la convenzione `[:Err, kind, msg]` del Core con il tipo
   `Err` di Full e confronta i due programmi.
7. **Non gestito.** **[Full]** Lascia un errore non gestito al top level: codice di uscita,
   messaggio e riga segnalata.
8. **Un messaggio per ogni categoria.** **[Full]** Scrivi una funzione che traduca gli errori in
   messaggi italiani a seconda della categoria.
9. **Errori e contratti.** Perché la violazione di un contratto è un `Err` e non un arresto del
   programma? Scrivi un programma che continua dopo un errore.
10. **Il caso `errore`.** Esegui il caso di conformance `errore` e spiega perché è l'unico caso
    Full verde oggi.

---

<a id="cap-25"></a>

## 25. Contratti (SPEC §9)

```triad-full
function safe_div(a::Number, b::Number)::Float
    requires b != 0
    ensures abs(result * b - a) < 1e-9
    a / b
end

safe_div(6, 3)            # 2.0
e = try safe_div(1, 0) end
e.kind                    # :contract
e.data.clause             # :requires
e.data.fn                 # :safe_div
```

- `requires c` è controllata dove compare (inizio del corpo, oppure al top level come asserzione).
- `ensures c` è controllata all'uscita, con `result` legato al valore restituito, dopo il
  controllo del tipo di ritorno.
- Violazione → `Err(:contract, …)` con `data.clause`, `data.fn`, `data.cond`, `data.result`.
- I contratti sono **puri**: un effetto dentro un contratto → `Err(:effect)`.
- `ensures` fuori da `function` → `Err(:syntax)`.

Pensa a `requires` come alla condizione d'ingresso dell'operazione e a `ensures` come alla
condizione d'uscita. Una precondizione specifica ciò che il chiamante deve garantire; una
postcondizione specifica ciò che la funzione promette quando termina correttamente. Le clausole
non sostituiscono il controllo dei tipi: una funzione può ricevere argomenti del tipo giusto e
violare comunque una precondizione di dominio, oppure restituire un valore tipato che viola la
postcondizione. Poiché i contratti sono puri, la loro valutazione non può stampare o modificare la
base di conoscenza: il controllo non deve cambiare il programma che sta verificando.

### Esercizi

1. **Precondizione.** **[Full]** Aggiungi `requires` a una funzione che divida per un intero e
   provala con input validi e non validi.
2. **Postcondizione.** **[Full]** Aggiungi `ensures` con `result` a una funzione che calcoli una
   media.
3. **Leggere la violazione.** **[Full]** Stampa `e.kind`, `e.data.clause`, `e.data.fn` dopo una
   violazione: che cosa ti dicono?
4. **Ordine dei controlli.** Perché il tipo di ritorno viene controllato prima di `ensures`?
   Costruisci un caso in cui la differenza si vede.
5. **Condizioni pure.** **[Full]** Metti un `println` dentro un contratto: quale errore?
6. **Al top level.** **[Full]** `requires` fuori da una funzione: che ruolo ha? Usalo come
   asserzione.
7. **Contratto su una ricorsione.** **[Full]** Aggiungi contratti a `fattoriale` e verifica che
   valgano a ogni livello di ricorsione.
8. **Controllo o prova?** Scrivi un contratto che non basti a garantire la correttezza e spiega
   il confine fra controllo e dimostrazione.
9. **Effetti vietati.** Perché le condizioni dei contratti sono pure? Che cosa succede se
   violi questa regola?
10. **Golden.** Verifica l'output golden dell'esempio `safe_div` del capitolo.

---

<a id="cap-26"></a>

## 26. Budget (SPEC §10)

```triad-full
r = with budget(steps = 10_000)
    while true end
end
r.kind                    # :budget — il ciclo infinito diventa un valore
```

- Un passo = una chiamata, un'iterazione di ciclo, un passo di risoluzione.
- I budget si annidano: vale il più stretto; solo il budget del `with` corrente diventa valore,
  quello esterno si propaga.
- `solve … steps N` è il budget di una singola query.
- La ricorsione infinita non fa stack overflow: finisce in `Err(:budget)` (stack esplicito).

Il budget misura unità di lavoro definite dallo standard, non secondi di CPU e non memoria
allocata. È quindi un limite riproducibile sul numero di passi del modello di esecuzione, non un
timeout generale del sistema operativo. Usalo per rendere limitate le computazioni potenzialmente
lunghe, in particolare la risoluzione logica o un ciclo che potrebbe non terminare. Il risultato
`Err(:budget)` è distinto dal risultato valido del corpo e può essere gestito con `try` o con il
controllo del valore restituito dal `with`.

### Esercizi

1. **Budget minimo.** **[Full]** Avvolgi un `while true` in `with budget(steps = 10_000)` e
   verifica `Err(:budget)`.
2. **Che cos'è un passo.** Elenca tre costrutti che consumano passi e spiega perché il budget
   misura lavoro e non tempo.
3. **Annidati.** **[Full]** Un budget di 100 dentro uno di 1000: quale scatta e che cosa restituisce
   il blocco interno?
4. **`solve … steps`.** **[Full]** Confronta `steps` di `solve` con `with budget`: quale vince
   quando valgono entrambi?
5. **Ricorsione sinistra.** **[Full]** `f(n) = f(n + 1)` con budget: quale errore invece dello
   stack overflow?
6. **Riproducibilità.** Perché due esecuzioni con lo stesso budget consumano gli stessi passi?
   Che cosa renderebbe instabile un timeout sull'orologio?
7. **Gestire l'esaurimento.** **[Full]** Scrivi un programma che, ricevuto `Err(:budget)`, stampi
   una diagnosi e riprovi con un budget maggiore.
8. **Vuoto o esaurito.** **[Full]** Distingui una query senza soluzioni da una terminata per
   budget con due esempi.
9. **`limit`, `depth`, `steps`.** Riassumi in tabella le tre opzioni e il tipo di risultato che
   producono.
10. **Golden.** Verifica l'output golden dell'esempio del capitolo.

---

<a id="cap-27"></a>

## 27. Tracce (SPEC §11)

La traccia è un **valore**, non output.

```triad-full
fib(n::Int) = n < 2 ? n : fib(n - 1) + fib(n - 2)
t = with trace
    fib(3)
end
t.result      # 2
t.trace       # [Event(port=:call, fn=:fib, args=[3], depth=0), …]

t = solve path(:a, :c) trace
t.trace       # porte Byrd: :call, :exit, :redo, :fail, :depth
```

Gli eventi sono record con `port`, `goal`/`fn`, `depth` (e `value`/`args` per le funzioni):
si filtrano come qualsiasi valore.

La traccia registra la storia del calcolo, non solo il suo risultato. In una traccia di funzione
`call` indica l'ingresso e `exit` l'uscita; in una query logica compaiono anche `redo` e `fail`,
perché la ricerca può provare più alternative. Il valore `result` resta disponibile accanto agli
eventi: puoi confrontare il risultato finale con il percorso seguito. La traccia non è un log
stampato automaticamente; decide il programma quali eventi filtrare, contare o presentare.

### Esercizi

1. **Prima traccia.** **[Full]** Avvolgi un piccolo `solve … trace` o `with trace` e leggi gli
   eventi prodotti.
2. **Le porte di Byrd.** Spiega `:call`, `:redo`, `:exit`, `:fail` con un esempio per ciascuna.
3. **Contare i fallimenti.** Riscrivi l'esempio che conta i fallimenti di una ricerca e
   provalo su una knowledge base tua.
4. **Eventi come dati.** **[Full]** Filtra gli eventi di traccia per categoria e contali.
5. **Ordine atteso.** Dato un goal con due soluzioni, scrivi a mano la sequenza attesa degli
   eventi e verifica.
6. **Debug di un goal.** Un goal non trova risposte: come usi la traccia per localizzare il
   fallimento?
7. **Traccia o `println`.** Perché per la logica una traccia è meglio di `println` di debug?
   Rispondi con un esempio.
8. **Trace e limit.** **[Full]** Unisci `trace` e `limit` e osserva dove la ricerca si ferma.
9. **Trace e budget.** **[Full]** Con `trace` e `steps` insieme, come si riconosce negli eventi
   l'esaurimento del budget?
10. **Golden.** Verifica l'output golden dell'esempio tracciato del capitolo.

---

<a id="cap-28"></a>

## 28. Effetti dichiarati (SPEC §12)

Le funzioni sono pure per default. Effetti: `io` (`println`, `print`) e `state` (`fact`/`rule`
dentro una funzione).

```triad-full
function saluta(nome::String) !io
    println("ciao, ", nome)
end

function impara(x) !state
    fact visto($x)
end
```

- Controllo dinamico: una funzione pura che chiama una `!io` o `println` → `Err(:effect)`.
- Il top level permette tutti gli effetti; le lambda ereditano quelli del contesto.
- Macro e contratti sono puri; leggere la KB (`solve`, predicati) è puro.
- Mutare liste o variabili locali non è un effetto.

La dichiarazione di effetto è una verifica dinamica dei permessi di esecuzione, non un'annotazione
puramente descrittiva. Il runtime controlla la catena delle chiamate quando una funzione tenta
un'operazione con effetto: una funzione `!io` può stampare solo se il contesto chiamante lo
consente. Il top level è il contesto più permissivo; una funzione pura chiamata da lì non diventa
per questo autorizzata a stampare. Elencare `!io` nella firma documenta il requisito per i
chiamanti e permette al runtime di rifiutare l'effetto nel punto in cui violerebbe la dichiarazione.

### Esercizi

1. **Pura di default.** **[Full]** Scrivi una funzione che stampi senza `!io`: quale errore?
2. **Dichiarare `!io`.** Correggi la firma dell'esercizio 1 e verifica che ora funziona.
3. **`!state`.** **[Full]** Scrivi una funzione che aggiunga un fatto alla knowledge base:
   quale effetto richiede?
4. **Chiamate indirette.** **[Full]** Costruisci una catena di tre funzioni in cui l'effetto è
   tentato alla terza: chi riceve l'errore?
5. **`fn`, `caller`, `missing`.** **[Full]** Ispeziona i tre campi di `data` in un `Err(:effect)`
   e spiega come guidano la correzione.
6. **Top level.** Perché al top level si può stampare senza dichiarazioni?
7. **Lambda.** Da dove una lambda eredita gli effetti? Scrivi un esempio.
8. **Puro e impuro.** Perché `solve` è puro mentre `fact` eseguito in una funzione no?
9. **Mutazione locale.** Perché `push!` e gli assegnamenti locali non sono effetti dichiarati?
10. **Golden.** Verifica l'output golden dell'esempio del capitolo (`effect`).

---

<a id="cap-29"></a>

## 29. Codice come dato, albero uniforme e macro (SPEC §3, §7)

### 29.1 L'albero uniforme

Il parser produce un solo tipo di nodo, `Node(head, args)`: è lo stesso albero che il kernel
esegue, che `:( … )` restituisce e che `--tree` stampa come S-expression.

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

Leggi una riga della tabella come una mappa tra **sintassi visibile** e **rappresentazione
interna**. Per esempio `a + b` non richiede un tipo di nodo speciale per la somma: è una chiamata
al nome `+` con due argomenti. Al contrario `&&` diventa un nodo dedicato perché il valutatore
deve poter evitare di valutare il secondo operando. La forma dell'albero quindi non è una
decorazione: codifica le decisioni che il runtime deve prendere per rispettare la semantica.

Questo modello è utile anche quando si legge un errore: se `sexpr` mostra un albero che non
corrisponde al raggruppamento atteso, il problema nasce nel parsing; se l'albero è corretto ma il
risultato è sbagliato, il problema è più probabilmente nella valutazione. La distinzione tra forma
del programma e valore del programma è il fondamento della metaprogrammazione.

### 29.2 Quote, unquote, eval

```triad-full
c = :(a.x + f(b, 2))
c.head        # :call
sexpr(c)      # "(call + (dot a x) (call f b 2))"

n = 7
quadrato = :($n * $n)
eval(quadrato)                  # 49
parse("if x > 0; :pos; else; :neg; end")   # albero
unparse(parse_program("1:n"))   # "1:n"
Expr(:call, :f, 1)              # costruisce un Node
```

### 29.3 Macro

Le macro ricevono codice e restituiscono codice; l'espansione è pura e **non igienica**:
usa `gensym()` per nomi freschi.

```triad-full
macro unless(c, body)
    :(if !$c; $body; end)
end

macro swap(a, b)
    tmp = gensym(:tmp)
    quote
        $tmp = $a
        $a = $b
        $b = $tmp
    end
end

macro time_it(label, e)
    :(begin
        r = $e
        println($label, " -> ", r)
        r
    end)
end

@swap(x, y)
@unless(x < y, println("x non è minore di y"))
@time_it("somma", reduce(+, 1:100))     # stampa "somma -> 5050"
```

Per valutare una macro, confronta l'argomento sorgente con il codice che essa costruisce. In
`@unless(c, body)`, `c` e `body` arrivano come nodi; la macro li inserisce in un `if` con la
condizione negata. Il corpo verrà eseguito solo se la condizione originale è falsa, proprio come
se il programmatore avesse scritto quel codice manualmente. Se la macro usasse una funzione
ordinaria, gli argomenti verrebbero calcolati prima della chiamata e non sarebbe possibile
controllare se `body` viene valutato. Questa capacità è potente, ma rende più difficile leggere
l'esecuzione: l'espansione esplicita e i nomi temporanei generati sono strumenti essenziali per
evitare sorprese.

### 29.4 Codice che genera codice

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
eval(p)        # 17
```

### Esercizi

1. **Albero uniforme.** **[Full]** Scrivi head e args di `Node` per `1`, `:x`, `[1, 2]` e
   `:(f(1))`.
2. **Quote e unquote.** **[Full]** Costruisci `:(x + $n)` con `n` calcolato: che cosa ottieni?
3. **`eval`.** **[Full]** Valuta una quote con `eval` e confronta con la forma non quotata.
4. **Round-trip.** **[Full]** `unparse(parse("1 + 2"))` (o l'equivalente): il testo è lo stesso?
5. **`triad --tree`.** Stampa l'albero uniforme di un programma piccolo e riconosci i nodi.
6. **Una macro.** **[Full]** Scrivi `@due_volte(e)` che esegua due volte la sua espressione.
7. **Igiene.** **[Full]** Costruisci un conflitto di nomi in una macro e correggilo con `gensym`.
8. **Codice che genera codice.** **[Full]** Scrivi una macro che definisca una funzione, come
   nell'esempio 29.4.
9. **Macro o funzione.** Spiega con un esempio quando serve una macro (codice non valutato
   subito) e quando basta una funzione.
10. **Golden.** Verifica l'output golden dell'esempio sulle macro del capitolo.

---

<a id="cap-30"></a>

## 30. Builtin Full (SPEC §13)

| ambito | funzioni |
|---|---|
| aritmetica e confronto | `+ - * / ^ % == != < <= > >= !`, `abs sqrt floor ceil round exp log sin cos div mod min max`; `*` concatena stringhe |
| liste | `length isempty first last rest reverse sort sum push! pop! append! vcat collect`, `a:b`, `x in xs` |
| ordine superiore | `map filter reduce any all count` |
| stringhe e output | `string repr println print` |
| tipi | `typeof`, `isa`, `Int Float String Symbol` |
| errori | `err iserr throw error` |
| codice | `eval parse unparse sexpr Expr gensym` |
| logica | `vars(sol)` |

Di questi, Core fornisce solo `+ - * % ^`, confronti, `&& || !`, `length`, `push!`, indicizzazione,
`*` su stringhe, `Int`, `string`, `Symbol`, `print`, `println`, `typeof` (SPEC-CORE §7).

### Esercizi

1. **Aritmetica completa.** **[Full]** Prova `abs sqrt floor ceil round exp log sin cos div mod
   min max`: quali convertono il risultato e in quale tipo?
2. **Liste.** **[Full]** Usa `isempty first last rest reverse sort sum pop! append! vcat collect`
   su una lista di cinque elementi.
3. **Ordine superiore.** **[Full]** Con `map filter reduce any all count` risolvi tre piccoli
   problemi (quadrati, maggiori di 3, somma).
4. **`x in xs` e `a:b`.** **[Full]** Usa `in` e il range in un programma solo e spiega il tipo
   dei risultati.
5. **Stringhe.** **[Full]** Confronta `string` e `repr` su un intero, una stringa e un simbolo.
6. **Errori.** **[Full]** Fai un esempio per ciascuno: `err`, `iserr`, `throw`, `error`.
7. **Codice.** **[Full]** Fai un esempio per ciascuno: `eval`, `parse`, `unparse`, `sexpr`,
   `gensym`.
8. **Tipi.** **[Full]** Con `typeof`, `isa` e i costruttori `Int Float String Symbol` converti
   un valore per tipo.
9. **`vars(sol)`.** **[Full]** Dopo una `solve`, elenca i nomi legati con `vars`.
10. **Core e Full.** Riscrivi un programma Full del capitolo usando solo i builtin Core e
    confronta la lunghezza dei due sorgenti.

---

<a id="cap-31"></a>

## 31. Riga di comando e REPL (SPEC §14)

Interfaccia normativa di `triad` (oggi il runtime implementa solo `triad FILE [ARG...]` e,
nell'interprete JS, `triad -`):

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

- L'estensione `.triad`/`.td` si può omettere; lo shebang `#!` è ignorato.
- Exit: `0` successo, `1` errore non gestito (stampato su stderr), `2` uso non valido.

**REPL** (stile Prolog):

```
triad> 1 + 2
3
triad> ?- ancestor(:tom, ?d)
?d = :bob ;
?d = :liz.
triad> parent(:jim, ?x)
false.
```

- I blocchi aperti restano in attesa fino a `end`.
- `?- goal` (o un goal su un predicato della KB) esegue una query; dopo ogni soluzione
  `;`/`n`/spazio = successiva, `a` = tutte, invio/`.` = stop.
- Comandi: `:load FILE…` (`:l`), `:reload` (`:r`, `make`), `:listing [nome|nome/arità]`
  (`:ls`), `:tree CODICE`, `:reset`, `:help` (`:h`), `:quit` (`:q`, `halt`, Ctrl-D).

### Esercizi

1. **Eseguire con argomenti.** `triad FILE a b`: come li vede il programma? Verifica con `ARGS`.
2. **`-e` e `-E`.** Confronta le due forme con un frammento il cui valore non sia `nothing`.
3. **`-l` e `-i`.** Prepara un file di definizioni e provalo con entrambe le opzioni: quale
   differenza?
4. **`--tree`.** Stampa l'albero uniforme di un espressione complessa e leggilo.
5. **Dalla pipeline.** Usa `triad -` per leggere uno script da stdin.
6. **Query al REPL.** Esegui `?- goal` con `limit` e con `trace` e leggi le risposte.
7. **I comandi del REPL.** Prova `:load`, `:reload`, `:listing`, `:tree`, `:reset`, `:quit`.
8. **Codici di uscita.** Produci `0`, `1`, `2` con tre programmi diversi e verificali.
9. **Estensioni e shebang.** `triad file` senza estensione e un file con `#!`: che cosa succede?
10. **Oggi, in pratica.** Quale di queste opzioni supporta il seed Windows? Con quale comando
    esegui oggi questi esempi?

---

<a id="cap-32"></a>

## 32. Esempi Full con output golden

I file sono in `examples/` (eseguibili quando S1 sarà pronto); gli output sono i golden
congelati in `conformance/cases/`.

| file | copre | caso golden |
|---|---|---|
| `examples/assaggio.td` | struct, dispatch, logica, macro, contratti | `assaggio` |
| `examples/famiglia.td` | fatti/regole, ricorsione, liste Prolog, negazione | `famiglia` |
| `examples/garanzie.td` | errori, contratti, budget, tracce, effetti | `garanzie_core` |
| `examples/macro.td` | quote, eval, macro, gensym | `macro` |
| `examples/tour.td` | tutti i paradigmi | `tour` |
| `examples/hello_shebang.td` | shebang, `ARGS`, effetti | `hello_shebang` |
| `examples/benvenuto.triad` | estensione canonica, `Float`, `solve` | — |

### 32.1 `assaggio.td`

```triad-full
struct Point
    x::Float
    y::Float
end

function dist(a::Point, b::Point)::Float
    requires a.x != b.x || a.y != b.y
    sqrt((a.x - b.x)^2 + (a.y - b.y)^2)
end

fact parent(:alice, :bob)
fact parent(:bob, :dave)
rule grandparent(?x, ?z) :- parent(?x, ?y), parent(?y, ?z)

result = solve grandparent(:alice, ?who) limit 5
println("nipoti: ", result)     # [{who = :dave}]
println("primo: ", result[1].who) # :dave
```

Output (golden Full) del file completo:

```text
nipoti di alice: [{who = :dave}]
primo: dave
quanti: 1
dist(p, q) = 5.0
dist(p, p) -> Err(:contract, "requires violata in dist: a.x != b.x || a.y != b.y", Info(fn = :dist, clause = :requires, cond = :(a.x != b.x || a.y != b.y)))
tipo: contract
almeno un nipote
alice è nonna di dave? true
```

### 32.2 `famiglia.td`

Output (golden Full):

```text
discendenti di tom: [:bob, :liz, :ann, :pat, :jim]
fratelli di ann: [:pat]
madri: ["pat -> jim"]
senza figli: [:liz, :ann, :jim]
over 50: [:tom, :bob]
modi di spezzare [1, 2, 3]:
  [] ++ [1, 2, 3]
  [1] ++ [2, 3]
  [1, 2] ++ [3]
  [1, 2, 3] ++ []
figli di bob: [:ann, :pat]
```

### 32.3 `garanzie.td`

Output (golden Full, traccia abbreviata):

```text
2.5
violazione: contract — requires violata in safe_div: b != 0
clausola: requires, funzione: safe_div
valore 5
errore domain: divisione intera per zero
valore 2
valore 42
errore input: età non valida
catturato mio con dati [1, 2, 3]
ciclo infinito -> budget
solve infinito -> budget
fib(3) = 2 in 10 eventi
chiamate: [[3], [2], [1], [0], [1]]
  call path(:a, :c) @0
  call edge(:a, :c) @1
  fail edge(:a, :c) @1
  …
ciao, Triad
effetto non dichiarato -> println richiede !io ma rumorosa non lo dichiara
imparato: [:gatto]
```

### 32.4 `macro.td`

Output (golden Full):

```text
codice:  :(a.x + f(b, 2))
head:    call
args:    [:+, :(a.x), :(f(b, 2))]
sexpr:   (call + (dot a x) (call f b 2))
:(7 * 7) = 49
parse:   (if (call > x 0) (block (sym pos)) (block (sym neg)))
unparse: if x > 0; :pos; else; :neg; end
dopo @swap: x = 2, y = 1
x non è minore di y
somma -> 5050
polinomio: :(0 + 1 * x ^ 0 + 2 * x ^ 1 + 3 * x ^ 2)
p(2) = 17
```

### 32.5 Contratti e budget insieme

```triad-full
function safe_div(a::Number, b::Number)::Float
    requires b != 0
    ensures abs(result * b - a) < 1e-9
    a / b
end
e = try safe_div(1, 0) end
e.kind          # :contract
r = with budget(steps = 1000)
    while true end
end
r.kind          # :budget
```

### Esercizi

1. **`assaggio.td`.** Leggi l'esempio 32.1 e annota i costrutti Full che usa; confronta l'output
   con il golden.
2. **`famiglia.td`.** Nell'esempio 32.2 individua i metodi e spiega quale scatta per ogni
   chiamata.
3. **`garanzie.td`.** Nell'esempio 32.3 quali garanzie sono contratti e quali budget? Spiega
   l'ordine dei controlli.
4. **`macro.td`.** Espandi a mano la macro dell'esempio 32.4 e confronta con il golden.
5. **Contratti e budget insieme.** Nell'esempio 32.5 quale dei due interviene per primo e
   perché?
6. **Golden o verificati?** Perché questi output si chiamano golden? Che cosa si può dire e che
   cosa no del programma che li produce?
7. **Dove stanno i golden.** Individua nella suite di conformance i file di output atteso di
   questi esempi.
8. **Tradurre in Core.** Riscrivi un esempio Full in un programma Core equivalente e confronta
   le due versioni.
9. **Un esempio tuo.** Scrivi un programma che usi tre costrutti Full insieme e redigine l'output
   atteso come se fosse un golden.
10. **Dal golden al test.** Spiega come si potrebbe verificare automaticamente il tuo esempio
    quando il runtime Full sarà disponibile.

---
<a id="parte-4"></a>

# Parte IV — Il codice del progetto

Questa parte spiega come è fatto il repository e come si scrive (o si modifica) ogni tipo di
codice che contiene.

<a id="cap-33"></a>

## 33. Mappa del repository

| percorso | linguaggio | cosa contiene |
|---|---|---|
| `SPEC.md`, `SPEC-CORE.md`, `VERSION`, `CHANGELOG.md` | Markdown | lo standard (Full e Core), versione, storia |
| `BOOTSTRAP.md`, `STATUS.md`, `TASK.md`, `plan.md` | Markdown | piano S0→S4, stato, backlog e task |
| `conformance/` | Triad + sh | casi golden (`cases/` Full, `core/cases/` Core) e harness `run.sh` |
| `seed/windows-x86_64/` | codice macchina | `seed.hex` (sorgente), `seed.exe` (decodificato), README con layout |
| `seed/linux-x86_64/` | codice macchina | seed ELF E2, interprete Triad-Core (`seed.hex`, `seed`) |
| `seed/dev/` | Node.js | generatore del seed (`gen_seed.js <windows\|linux\|all>`) e interprete di riferimento `triad_core.cjs` |
| `selfhost/` | Triad-Core | S1: interprete Triad scritto in Triad-Core (in corso) |
| `examples/` | Triad-Full | programmi di esempio dello standard |
| `cli/` | Node.js (ESM) | `triad-cli`: CLI di sviluppo (commander, execa, chalk) |
| `bin/` | sh / cmd | launcher `triad`, `triad.cmd`, `triad-cli`, `triad-cli.cmd` |
| `ai/` | Triad + Node | benchmark di generazione codice per LLM, prompt, task con golden |
| `editors/` | JSON / Vim script | grammatica VS Code (TextMate), sintassi Vim, voce Linguist |
| `docs/` | HTML/CSS/JS | sito GitHub Pages e materiali pubblicati dal repository |
| `obsidian-triad/` | Markdown | vault Obsidian con indice dei file e grafo del progetto |
| `.github/workflows/` | YAML | CI (`ci.yml`) e pubblicazione del sito (`pages.yml`, `static.yml`) |
| `probes/test_*.td` | Triad-Core | piccoli probe usati durante lo sviluppo del seed e nella CI (es. `probes/test_get.td`) |

Convenzioni comuni:
- documentazione, commenti e messaggi sono in **italiano**;
- fine riga **LF** ovunque, tranne `*.cmd` (CRLF), imposto da `.gitattributes`;
- `.gitignore` esclude `*.out` con l'eccezione `!conformance/**/expected.out`.

### Esercizi

1. **I luoghi del progetto.** Dove si trovano: lo standard, l'interprete JS, il seed, la suite
   di conformance? Apri ciascun percorso.
2. **Gli esempi.** Scegli tre file da `examples/` e prevedi l'output prima di eseguirli.
3. **Il benchmark.** Individua `ai/` e apri un task: in quale file sta il problema?
4. **Gli editor.** Quali file definiscono il riconoscimento di `.triad` per VS Code, Vim e
   GitHub Linguist?
5. **Il self-hosting.** Dove sta il codice S1 e quale file lo mette alla prova?
6. **Gli strumenti.** Distingui gli strumenti di sviluppo (`seed/dev/`, `cli/`, `conformance/`)
   dalla catena di bootstrap.
7. **La documentazione.** In quale cartella stanno il Tutorial, il Manuale e questo volume?
8. **I test.** Dove stanno i programmi di prova (`tests/`)? Ne esegui uno a scelta.
9. **Il sito.** Quale cartella genera il sito del progetto e quale file lo costruisce?
10. **Mappa tua.** Disegna la mappa del repository a memoria e poi verificala con `ls`.

---

<a id="cap-34"></a>

## 34. L'interprete di riferimento JS (`seed/dev/triad_core.cjs`)

È un interprete Triad-Core completo in un solo file CommonJS (~1000 righe, nessuna dipendenza).
È lo strumento con cui si verifica la conformance Core su Linux/macOS ed è il modo più rapido
per capire la semantica di Core leggendo codice.

### 34.1 Architettura

```
sorgente ──tokenize()──▶ token ──Parser──▶ AST {kind: …} ──evalStmt/evalExpr──▶ effetti su stdout
```

1. **Valori** (in cima al file): oggetti `{t, v}` costruiti da `I` (Int, `BigInt` con
   `wrap()` a 64 bit), `B`, `S`, `Y` (Symbol), `L` (List), `F` (funzione: `params`, `body`,
   `env`, `isLambda`) e la costante `NOTHING`. I builtin sono `{t:'builtin', name}`.
2. **`tokenize(src)`**: produce token `SEP` (a capo o `;`), `NUM`, `STR`, `SYM`, `IDENT`, `OP`,
   `LPAREN`/`RPAREN`, `LBRACKET`/`RBRACKET`, `COMMA`, `QMARK`, `COLON`, `EOF`. Commenti e spazi
   sono scartati qui.
3. **`class Parser`**: discesa ricorsiva che segue la precedenza del [§7.1](#cap-7):
   `parseProgram → parseStmt → parseExpr → parseAssign → parseTernary → … → parsePostfix →
   parsePrimary`, più `parseBlock(terminators)` per i corpi fino a `end`/`else`/`elseif`.
   Nodi prodotti: `program`, `funcdef`, `return`, `break`, `continue`, `exprstmt`, `num`,
   `str`, `sym`, `bool`, `nothing`, `var`, `list`, `lambda`, `assign`, `indexassign`,
   `binary`, `unary`, `ternary`, `call`, `index`, `if`, `while`, `let`, `begin`.
4. **Ambienti**: `makeFrame(parent, owner, isLambda)` crea un frame con una `Map` di legami;
   `lookup` risale la catena. `writeVar` implementa le regole di scope del [§10.3](#cap-10):
   aggiorna un legame dello stesso "proprietario" (funzione), oppure, dentro una lambda, un
   legame esterno; altrimenti crea un locale.
5. **Valutazione**: `evalStmt`, `evalExpr` → `evalExprBinary` → `evalExprRest` →
   `evalExprBlocks`. `return`, `break`, `continue` sono eccezioni JS (`ReturnSignal`,
   `BreakSignal`, `ContinueSignal`) catturate dalla chiamata o dal `while`.
6. **Builtin**: insieme `BUILTIN_NAMES` + `callBuiltin(name, args, env)`; stampa con
   `printValue` (simboli senza `:` solo al top level) e conversione con `stringOf`.
7. **`main()`**: legge il file (o stdin con `-`), lega `ARGS`, esegue; errori di parsing →
   `parse error: …`, errori di esecuzione → `error: …`, entrambi con exit 1; nessun file →
   exit 2.

Questo flusso separa responsabilità che conviene diagnosticare una alla volta. Se il token
prodotto da `tokenize` è sbagliato, il problema è prima del parser; se il parser genera la forma
errata, l'albero AST non corrisponde alla grammatica; se l'albero è giusto ma il risultato no, il
difetto è nell'ambiente, nella valutazione o in un builtin. Un caso di conformance piccolo
permette di fissare il comportamento osservato mentre si corregge il livello responsabile. Quando
si modifica sintassi o semantica, il test, l'interprete e la specifica devono restare coerenti:
aggiungere un ramo al parser senza la corrispondente valutazione crea una forma riconosciuta ma
non eseguibile.

### 34.2 Esempio: aggiungere un builtin

Supponiamo di voler sperimentare un builtin `abs` (non è in Core: va prima proposto nello
standard, vedi [§43](#cap-43)). Servono due modifiche:

```js
// 1. registrare il nome
const BUILTIN_NAMES = new Set(['print','println','length','push!','Int','string','Symbol',
  'typeof','readfile','strlen','strbyte','strsub','exit','abs']);

// 2. implementarlo in callBuiltin, prima del throw finale
  if (name === 'abs') {
    if (args.length !== 1 || args[0].t !== 'int') throw new Error('abs');
    return I(args[0].v < 0n ? -args[0].v : args[0].v);
  }
```

Poi: un caso in `conformance/core/cases/` ([§38](#cap-38)) e `sh conformance/run.sh`.
Ricorda che gli `Int` sono `BigInt` (`0n`, `1n`) e che i risultati vanno costruiti con gli
helper (`I`, `B`, `S`, `Y`, `L`, `NOTHING`).

### 34.3 Esempio: aggiungere sintassi

1. se serve un nuovo token, estendi `tokenize` (es. un operatore in `twoOps`);
2. aggiungi il livello di precedenza nel `Parser` producendo un nuovo `kind`;
3. gestisci il `kind` in `evalExpr*`;
4. aggiorna `SPEC-CORE.md` (grammatica §4 e semantica §5) e aggiungi un caso Core.

Regola: l'interprete JS deve restare **fedele a SPEC-CORE**; non aggiungere estensioni che il
seed e S1 non dovrebbero avere.

### Esercizi

1. **Architettura.** Leggi il paragrafo 34.1 e indica dove si collocano lexer, parser e
   valutatore.
2. **Un builtin in più.** Segui il paragrafo 34.2 e aggiungi un builtin (per esempio `doppio`):
   provalo e poi rimuovilo.
3. **Nuova sintassi.** Segui il paragrafo 34.3 per aggiungere una piccola forma sintattica e
   verifica che il parser la accetti.
4. **La conformance dopo la modifica.** Esegui la suite dopo ogni modifica: quali casi proteggono
   il tuo cambiamento?
5. **Trovare il codice.** Dove sono implementati `push!`, `length` e `println`? Individua le
   funzioni.
6. **`ARGS`.** Come arriva `ARGS` al programma? Traccia il percorso nel codice.
7. **Un errore da vicino.** Individua dove viene prodotto `error: index out of range` e cosa
   contiene il messaggio.
8. **Debug dell'interprete.** Inserisci una stampa di debug nel valutatore e osserva l'ordine di
   valutazione di un'espressione; poi rimuovila.
9. **Perché è fuori dal bootstrap.** Spiega perché l'interprete JS è uno strumento di sviluppo e
   non parte della catena S0→S4.
10. **Refactor sicuro.** Scegli una piccola funzione dell'interprete, rinominala ovunque e
    verifica la suite: perché i test sono il tuo contratto?

---

<a id="cap-35"></a>

## 35. Il seed S0 Windows e il suo generatore

### 35.1 Cos'è

`seed/windows-x86_64/seed.exe` è un PE32+ x86-64 di **25.088 byte** che importa solo
`KERNEL32.dll` (`GetStdHandle`, `GetCommandLineA`, `CreateFileA`, `ReadFile`, `WriteFile`,
`CloseHandle`, `ExitProcess`, `VirtualAlloc`). Non usa libc né runtime. La **fonte** è il dump
`seed.hex` (SHA-256 verificato dalla CI: `3A75A21E2F47D8DC4C88D4BC2580A85D5349BCDF7550E5FFA16E2C0AC7CA8C11`).

Il seed **non costruisce un AST**: interpreta direttamente il testo sorgente, con un cursore
(`rsi`) che scorre i byte; i corpi di funzioni e lambda sono puntatori nel sorgente che vengono
rieseguiti a ogni chiamata.

### 35.2 Convenzioni interne

| registro | ruolo |
|---|---|
| `r14` | base della memoria `VirtualAlloc` (sorgente a `+0`, ambiente a `+0x10000`, funzioni a `+0x20000`, heap a `+0x30000`) |
| `r15` | ambiente variabili (entry da 24 byte: nome ptr, len, valore) |
| `rbx` | contatore variabili |
| `r13` | tabella funzioni (entry da 128 byte) |
| `r12` | handle di stdout |
| `rsi` | cursore nel sorgente |

Valori taggati a 2 bit: `Int = n << 2`, `false = 1`, `true = 5`, chiusura `= ptr | 2`, oggetti
heap (stringhe `[tipo][len][byte…]`) con tag 3. Il layout completo (header PE, IAT, mappa
delle etichette `parse_program`, `st_if`, `parse_primary`, `env_find`, …) è in
[`seed/windows-x86_64/README.md`](seed/windows-x86_64/README.md).

### 35.3 Il generatore `seed/dev/gen_seed.js`

Scrivere migliaia di byte a mano è impraticabile: il generatore è un **assembler-lite** in
JavaScript che emette i byte e risolve le etichette. Sezioni del file:

| sezione | cosa |
|---|---|
| `emitter` | `B(...)` emette byte, `B32(v)` un dword, `L(nome)` definisce un'etichetta, `reloc`/`je`/`jne`/`jmp`/`callL` emettono salti con patch relative, `callIat(i)` chiama l'import `i` |
| helper di istruzione | funzioni con il nome dell'istruzione (`incRsi`, `cmpByteRsiImm('(')`, `testRax`, `leaRdxR14(d)`, …) che emettono i byte x86-64 corrispondenti |
| `PE/data layout` | costanti `IAT = 0x4000`, `SEC_RAW`, `HEADERS` |
| `main` | prologo, lettura della riga di comando, apertura/lettura del file |
| `parser` | il cuore dell'interprete: statement, espressioni, funzioni, lambda |
| `ambiente` | `env_find`, `env_store`, `env_assign` |
| `exit labels` | `fail`, `read_fail`, `open_fail`, `usage` |
| `PE builder` | scrive header DOS/PE/COFF, sezione `.text`, tabelle import, e il dump esadecimale |

Esempio di stile (dal `main`): saltare il nome del programma nella riga di comando.

```js
cmpByteRsiImm(0x22); jne('skip_plain');   // il path inizia con " ?
L('q_loop');
incRsi();
cmpByteRsiImm(0); je('no_arg');           // fine stringa: nessun argomento → exit 2
cmpByteRsiImm(0x22); jne('q_loop');
```

### 35.4 Flusso per modificare il seed

1. modifica `seed/dev/gen_seed.js` (aggiungi un'etichetta, un ramo nel dispatcher, …);
2. rigenera i dump: `node seed/dev/gen_seed.js all`
   (oppure `node cli/triad-cli.mjs seed generate windows|linux`, che stampa anche lo SHA-256);
3. decodifica: su Windows `certutil -decodehex -f seed\windows-x86_64\seed.hex seed\windows-x86_64\seed.exe`;
   su Linux `xxd -r -p seed/linux-x86_64/seed.hex seed/linux-x86_64/seed && chmod +x seed/linux-x86_64/seed`
   (oppure `./install.sh`, che ridecodifica e fa lo smoke test);
4. esegui il gate: `sh verify.sh` (conformance 39 + probe + golden S1) e
   `sh seed/linux-x86_64/check_seed.sh`;
5. aggiorna **insieme**: hash in `.github/workflows/ci.yml` (job `seed-linux`, step
   `Hash check`), `seed/windows-x86_64/README.md`, `seed/linux-x86_64/README.md`,
   `seed/dev/README.md`, `STATUS.md`; i casi Core non vanno elencati da nessuna parte:
   il harness `conformance/run.sh` li scopre da `conformance/core/cases`.

Trappole note (da `STATUS.md`): il codice cresce e può sovrapporsi ai dati (i nomi import ora
partono da RVA `0x5000`); registri usati prima di essere inizializzati (bug `pbs_int`);
ordine degli argomenti sullo stack nelle chiamate builtin (`get`). Defender può segnalare il
PE come falso positivo (la CI aggiunge un'esclusione).

### Esercizi

1. **Che cos'è il seed.** Spiega con le tue parole che cos'è S0 e perché è scritto in codice
   macchina.
2. **Dump esadecimale.** Perché il seed è versionato come `seed.hex` e non come binario? Quale
   comando lo materializza?
3. **Convenzioni interne.** Leggi il paragrafo 35.2 e annota tre convenzioni del generatore.
4. **`gen_seed.js`.** Rigenera il seed con il generatore e verifica che l'hash corrisponda a
   quello documentato.
5. **Il flusso di modifica.** Descrivi i passi del paragrafo 35.4 per modificare il seed senza
   romperlo.
6. **Verificare sul codice macchina.** Esegui tre casi Core sul seed Windows e confronta con
   l'interprete JS.
7. **Limiti misurati.** Scegli tre limiti del seed (lambda, `string`, liste…) e scrivi un
   programma per ciascuno che li incontri.
8. **`continue` mancante.** Riscrivi un programma con `continue` nella forma equivalente con
   `break` e verifica che giri sul seed.
9. **`-=` e `*=`.** Perché conviene usare solo `+=` nel codice destinato al seed? Riscrivi un
   esempio.
10. **Hash e CI.** Perché la CI controlla l'hash del seed? Che cosa garantirebbe un hash
    diverso?

---

<a id="cap-36"></a>

## 36. Il seed Linux (E2)

`seed/linux-x86_64/seed` è un ELF64 statico di **11465 byte** generato da
`seed/dev/gen_seed.js linux`: entry `0x400078`, un solo `PT_LOAD` R|X, syscall dirette
(`openat`/`read`/`write`/`exit`, isolate nelle routine `os_*`). È l'**interprete Triad-Core**
completo: stessa macchina del seed Windows, stdout byte-identico sui golden condivisi
(conformance 42/42 + probe + golden S1). La milestone M7 (port Linux) è completa: E0
(minimale) → E1 (lettura file) → E2 (interprete) → E3 (toolchain senza Node, `./install.sh`).

```sh
node seed/dev/gen_seed.js linux seed/linux-x86_64/seed.hex   # rigenera il dump (riproducibile)
xxd -r -p seed/linux-x86_64/seed.hex seed/linux-x86_64/seed && chmod +x seed/linux-x86_64/seed
./seed/linux-x86_64/seed tuo_programma.td                     # esegue il programma
```

### Esercizi

1. **Che fa oggi.** Esegui un programma Core sul seed Linux e confronta l'output col golden.
2. **Materializzare l'ELF.** Genera il binario Linux a partire dal dump e verificane l'hash.
3. **Confronto fra seed.** Metti a confronto seed Windows e seed Linux: quali funzionalità ha
   ciascuno?
4. **Parità.** Perché la parità si misura in byte e non solo negli stessi valori? Cosa
   dimostra il gate `sh verify.sh`?
5. **Il layer `os_*`.** Che cosa deve cambiare per portare il seed su un'altra piattaforma?
   Consulta `seed/dev/gen_seed.js`.
6. **Su Linux oggi.** Quali comandi eseguono un programma Triad su Linux? E su una piattaforma
   senza seed nativo?
7. **Hash e verifica.** Verifica l'hash del seed Linux come fa la CI e spiega cosa protegge.
8. **Programmi portabili.** Scrivi un programma che giri identico su PE ed ELF: quale
   sottoinsieme usi?
9. **Stato del bootstrap.** Dove si documenta lo stato del seed (`STATUS.md`, `TASK.md`)? Che
   cosa dicono oggi?
10. **La milestone M7.** Riscrivi la storia E0→E3 con le date di `STATUS.md`: quali gate
    verificano ogni stadio?

---

<a id="cap-37"></a>

## 37. Self-hosting: S1 in `selfhost/`

S1 è l'interprete di tutto Triad scritto in Triad-Core ed eseguito dal seed. Oggi è allo stadio
di prototipi separati, ognuno con un piccolo test in fondo al file:

| file | cosa prova |
|---|---|
| `main.td` | ambiente inline come lista piatta `[chiave, valore]`; smoke test in CI (atteso `Value: 10`) |
| `value.td` | valori taggati a 2 bit simulati con interi (`make_int`, `make_bool`, `as_int`) |
| `tokenizer.td` | `next_token(chars, pos)` su un sorgente codificato come lista `[lunghezza, byte…]`; token `[tipo, valore, pos]` |
| `parser.td` | riconoscimento delle keyword `if`/`end` dai codici ASCII |
| `eval.td`, `program.td` | valutazione di token numerici, identificatori, assegnamenti e `println` |
| `env.td`, `heap.td`, `ast.td`, `interpreter.td` | stub dell'ambiente, dell'allocatore bump e dell'AST |

### 37.1 Come si scrive codice S1 oggi

Il codice S1 deve girare sul **seed Windows**, quindi segue le restrizioni della colonna destra
del [capitolo 15](#cap-15):

- usa `get(xs, i)` con indici **da 0** invece di `xs[i]` (non standard: andrà sostituito con
  l'indicizzazione Core quando il seed la supporterà);
- liste solo di interi: le stringhe sorgente si rappresentano come liste di codici ASCII,
  con la lunghezza nella posizione 0;
- `push!` restituisce la lista: si scrive `env = push!(env, v)`;
- costanti per i tipi di token (`0` EOF, `1` NUMBER, `2` IDENTIFIER, …) documentate in un
  commento in testa al file;
- funzioni con al massimo 4 parametri, lambda a un parametro, niente cattura multi-binding.

```triad
# stile S1: ambiente piatto e lookup con get (0-based)
env = []
env = push!(env, 1)      # chiave
env = push!(env, 10)     # valore
if get(env, 0) == 1
  println("Value: " * string(get(env, 1)))
end
```

Su Linux questi file **non girano** con l'interprete JS (che non ha `get`): vanno provati su
Windows con `seed\windows-x86_64\seed.exe selfhost\main.td`.

### 37.2 Dove va S1

Le task S1.3–S1.15 sono in [`TASK.md`](TASK.md): valori taggati, tokenizer e parser inline,
eval di espressioni, `let`, programmi completi, funzioni e chiamate, chiusure, e infine far
girare la conformance sopra seed+S1. Gli esercizi 6 e 7 del [capitolo 17](#cap-17) sono una
versione in Core standard degli stessi passi.

### Esercizi

1. **Che cos'è S1.** Definisci S1 con le tue parole: linguaggio, forma e ruolo nel bootstrap.
2. **Lo stile S1.** Perché `selfhost/` usa `get(xs, i)` con indici da 0? Dove si trova questo
   helper?
3. **Smoke test.** Esegui `selfhost/main.td` con il runtime indicato dal capitolo e leggi
   l'output.
4. **Primitive di bootstrap.** Quali primitive del capitolo 13 servono a S1 e perché?
5. **Leggere un pezzo.** Scegli una funzione di `selfhost/` e spiegala riga per riga.
6. **Cosa manca.** Quanto dista S1 dalla conformance? Elenca i passi rimanenti.
7. **Verso S2.** Descrivi cosa farà S2 e che cosa deve avere S1 per produrlo.
8. **Portabilità di S1.** Su quale runtime gira oggi S1 e perché non gira sull'interprete JS?
9. **Verifica in CI.** Quale comando della CI mette alla prova S1? Eseguilo in locale.
10. **Perché self-hosting.** Scrivi un paragrafo sul perché il self-hosting è la prova definitiva
    di un linguaggio autonomo.

---

<a id="cap-38"></a>

## 38. Conformance: leggere, scrivere e verificare casi

### 38.1 Formato

```
conformance/core/cases/<nome>/      (oppure conformance/cases/<nome>/ per Full)
  program.td        programma Triad eseguito come script
  args.txt          opzionale: un argomento per riga (ARGS)
  expected.out      stdout atteso, byte per byte, fine riga LF
  expected.golden   copia di expected.out (fallback del runner)
  expected.code     exit code atteso
```

Un caso passa se stdout e codice di uscita coincidono; stderr non è confrontato. Niente stdin
né input interattivo.

### 38.2 L'harness `conformance/run.sh`

```sh
sh conformance/run.sh              # Core (42 casi, scoperti da conformance/core/cases)
sh conformance/run.sh --update     # RIGENERA i golden dal runtime corrente (uso dev)
```

La suite Full (`conformance/cases`) resta fuori dal gate: oggi passa solo `errore`. Il runner
Node `conformance/run.mjs` è stato sostituito dall'harness POSIX (2026-11-05).

Runtime scelto: il seed ELF del repository (`seed/linux-x86_64/seed`), con override possibile
via variabile `TRIAD_SEED`. Esempio per provare un seed con percorso esplicito:
`TRIAD_SEED=/percorso/seed sh conformance/run.sh`. Nessun fallback JS: il gate verifica il
seed nativo, byte per byte contro i golden.

Il gate copre tutti i 42 casi senza esclusioni: il gap storico `liste` (il seed non
implementava l'indicizzazione standard `xs[i]`) è **chiuso** dal ciclo di rebuild del seed:
`xs[i]`, `xs[i] = v` e la chiamata in posizione finale funzionano, e il caso `liste` è verde
come gli altri, senza esclusioni nell'harness. Per vedere il caso con l'interprete JS di
sviluppo:

```sh
node seed/dev/triad_core.cjs conformance/core/cases/liste/program.td
```

Messaggi:
- `PASS  nome` / `FAIL  nome  (exit X, atteso Y, stdout N byte, attesi M)`;
- `golden mancante`: il checkout non ha `expected.out` (di solito basta `git pull`).

Un golden è un'aspettativa versionata, non la fonte normativa della semantica. Il file
`program.td` definisce l'input, `args.txt` gli argomenti, `expected.out` l'output byte per byte e
`expected.code` il codice d'uscita. Il runner confronta questi risultati con il runtime scelto;
così uno stesso caso può essere eseguito da più interpreti e rendere visibili le divergenze. Se
il comportamento del runtime è in dubbio, confronta prima il caso con SPEC-CORE e poi correggi il
golden solo quando la specifica conferma il nuovo valore atteso. L'opzione `--update` copia il
comportamento corrente nei risultati attesi: usarla senza revisione trasformerebbe un bug in una
pretesa di correttezza.

### 38.3 Aggiungere un caso Core

1. scegli un nome descrittivo in italiano (`liste_annidate`, `stringhe_vuote`, …);
2. scrivi `program.td` usando **solo** SPEC-CORE §2–§7 (niente primitivi di bootstrap: devono
   girare anche su Full);
3. scrivi a mano `expected.out` (con LF finale) ed `expected.code` (`0`), ragionando sulla
   specifica — **non** generarli alla cieca con `--update`, altrimenti fissi i bug del runtime;
4. `sh conformance/run.sh` deve stampare `PASS  <nome>`;
5. nessun elenco da aggiornare: il harness scopre i casi dalla directory e il job `seed-linux`
   esegue la suite sull'ELF nativo; assicurati solo che `expected.out`/`expected.code` siano
   committati.

```sh
mkdir conformance/core/cases/somma_lista
cat > conformance/core/cases/somma_lista/program.td <<'TD'
xs = [3, 4, 5]
tot = 0
i = 1
while i <= length(xs)
    tot += xs[i]
    i += 1
end
println(tot)
TD
printf '12\n' > conformance/core/cases/somma_lista/expected.out
cp conformance/core/cases/somma_lista/expected.out conformance/core/cases/somma_lista/expected.golden
printf '0' > conformance/core/cases/somma_lista/expected.code
sh conformance/run.sh | grep somma_lista          # PASS  somma_lista
```

I golden Full (`conformance/cases/`) sono **congelati**: non vanno rigenerati finché non esiste
un'implementazione Full.

### Esercizi

1. **Il formato.** Quali file compongono un caso di conformance e che cosa dichiara ciascuno?
2. **Il runner.** Esegui `sh conformance/run.sh` (o il comando della CLI) e leggi il
   riepilogo.
3. **Un caso alla volta.** Esegui un singolo caso Core e confronta output e codice con i golden.
4. **Aggiungi un caso.** Segui il paragrafo 38.3 e crea un caso Core tuo (programma, output
   atteso, codice atteso).
5. **Golden mancante.** Cosa succede quando manca un `expected.out`? Provocalo e osserva.
6. **Casi che falliscono.** Aggiungi un caso il cui programma termini con codice 1: come si
   esprime il codice atteso?
7. **Core e Full.** Quali sono le due suite e perché solo pochi casi Full sono verdi?
8. **Portabilità.** Esegui la suite con il seed Windows: quali casi escono e perché?
9. **Un golden è un contratto.** Spiega perché i golden vanno versionati e non rigenerati alla
   leggera.
10. **La tua routine.** Scrivi la sequenza di comandi che eseguirai prima di ogni cambiamento al
    linguaggio.

---

<a id="cap-39"></a>

## 39. La CLI di sviluppo `triad-cli`

### 39.1 Uso

La toolchain è divisa in due livelli: `bin/triad-cli` (POSIX, **senza Node**, percorso utente)
e `node cli/triad-cli.mjs` (Node, soli comandi di sviluppo).

| comando | cosa fa |
|---|---|
| `triad-cli status` | root del progetto, piattaforma, seed trovato, stato del PATH |
| `triad-cli run <file> [-- args]` | esegue un programma Triad via `bin/triad` |
| `triad-cli test conformance [--update]` | esegue `conformance/run.sh` (42 casi Core) |
| `triad-cli test probes` / `test all` | probe / gate completo (`verify.sh`) |
| `node cli/triad-cli.mjs ai verify [-t DIR] [-v]` | esegue le `solution.triad` di `ai/tasks/` sul seed nativo e le confronta con i golden |
| `node cli/triad-cli.mjs seed generate windows\|linux [-o FILE]` | esegue il generatore del seed e stampa lo SHA-256 del dump |
| `node cli/triad-cli.mjs ext check\|package` | valida/impacchetta l'estensione VS Code |

Avvio: `bin/triad-cli` è già pronto (shell POSIX, nessuna installazione); i comandi dev si
invocano come `node cli/triad-cli.mjs …` (dopo `cd cli && npm install`), oppure con
`bin\triad-cli.cmd` su Windows o l'eseguibile standalone della release.

### 39.2 Struttura del codice

```
cli/
  triad-cli.mjs            definizione dei comandi dev con commander (seed/ai/ext)
  lib/utils.mjs            findProjectRoot, runNode, projectPath, fileExists
  lib/commands/ai.mjs      handleAIVerify
  lib/commands/seed.mjs    handleSeedGenerate (windows/linux)
  lib/commands/ext.mjs     handleExtCheck, handleExtPackage
  build-exe.mjs            build dell'eseguibile Node SEA (esbuild + postject)
```

- `findProjectRoot()` cerca la root (una cartella con `conformance/run.sh` e `seed/`) partendo
  da `TRIAD_HOME`, dalla cartella del modulo, da quella dell'eseguibile e dalla cartella
  corrente.
- Ogni handler restituisce `true`/`false`; `triad-cli.mjs` lo traduce in exit code 0/1.

### 39.3 Aggiungere un comando

1. crea `cli/lib/commands/<nome>.mjs` con una funzione `handle<Nome>(options)` che restituisce
   un booleano e usa `projectPath`, `runNode`, `runSeed` da `utils.mjs`;
2. registralo in `triad-cli.mjs`:

```js
import { handleLint } from './lib/commands/lint.mjs';

program
  .command('lint')
  .description('Controlla i file .triad')
  .option('-v, --verbose', 'Verbose output')
  .action(async (options) => {
    const success = await handleLint(options);
    process.exit(success ? 0 : 1);
  });
```

3. aggiungi la riga in `status` e documentalo in [`cli/README.md`](cli/README.md).

### 39.4 Eseguibile standalone

```sh
cd cli && npm install
npm run build:exe                         # dist/triad-cli per la piattaforma corrente
node build-exe.mjs path/to/win/node.exe   # dist/triad-cli.exe per Windows, anche da Linux
```

Il binario Node passato determina la piattaforma; deve avere la stessa versione del Node che
esegue la build.

### Esercizi

1. **I comandi.** Esegui `node cli/triad-cli.mjs --help` (o il paragrafo 39.1) e l'elenco dei
   comandi disponibili.
2. **Test di conformance.** Lancia la suite dalla CLI e interpreta il riepilogo.
3. **Verifica AI.** Usa il comando `ai verify` su una soluzione corretta e su una sbagliata.
4. **Codici di uscita.** Che codice restituisce la CLI quando un test fallisce? Verifica.
5. **CLI o launcher?** Spiega la differenza fra `triad-cli` (strumento di sviluppo) e `bin/triad`
   (launcher del runtime).
6. **Un comando tuo.** Scrivi uno script di shell che esegua un caso, il runner e la stampa del
   risultato in una riga.
7. **Errori di uso.** Invoca la CLI con argomenti sbagliati: che messaggi ottieni?
8. **Automatizzare.** Come faresti a eseguire solo i casi il cui nome contiene `list`?
9. **Dentro la CLI.** Apri il sorgente della CLI e indica dove vengono lanciati i runner.
10. **Documentazione.** Scrivi la riga di aiuto che vorresti trovare per un comando che manca.

---

<a id="cap-40"></a>

## 40. Benchmark AI (`ai/`)

Misura quanto bene un LLM scrive Triad-Core.

- `ai/SYSTEM_PROMPT.md`: prompt di sistema con il sottoinsieme ammesso (prudente: vieta liste,
  `string()`, `elseif`, `return` perché il seed non li supportava tutti);
- `ai/tasks/NN_nome/`: `task.md` (richiesta), `expected.out`, `solution.triad` (soluzione di
  riferimento);
- verifica: `node cli/triad-cli.mjs ai verify` (o `--tasks ai/tasks/01_somma`): `PASS`/`FAIL`,
  `SKIP` se manca la soluzione;
- `ai/jev_audit.mjs`, `ai/jev_prompt.md`: audit separato (vedi `PROMPT_JEV.md`).

Aggiungere un task: crea `ai/tasks/06_nome/` con `task.md` (output atteso descritto con
precisione), `expected.out` e una `solution.triad` di riferimento che passa. Esegui il codice
generato da un modello solo in un ambiente isolato.

### Esercizi

1. **Leggere un task.** Apri `ai/tasks/01_sum`: quali parti compongono un task e dove sta
   l'output atteso?
2. **Risolvere un task.** Scrivi la soluzione di un task e verificala con il comando della CLI.
3. **PASS e FAIL.** Perché il verdetto è il confronto con l'output atteso? Costruisci una
   soluzione che stampi il risultato giusto ma in un formato sbagliato.
4. **pass@1 e pass@k.** Con tre tentativi di cui il secondo giusto: pass@1 e pass@3 che valore
   hanno?
5. **Lo `SYSTEM_PROMPT`.** Che cosa richiede `ai/SYSTEM_PROMPT.md` al modello? Perché «solo un
   blocco di codice»?
6. **Tentativi.** Simula cinque tentativi di uno stesso task e calcola pass@1 e pass@5.
7. **Conformance e benchmark.** Spiega la differenza fra un caso di conformance e un task del
   benchmark.
8. **Un task tuo.** Scrivi un task nuovo (problema + output atteso) con la struttura di
   `ai/tasks/`.
9. **Perché misurare.** Che cosa misura il benchmark e che cosa non misura? Scrivi due righe.
10. **Senza guardare.** Risolvi un task senza leggere la soluzione, poi confronta i due programmi.

---

<a id="cap-41"></a>

## 41. Editor, launcher e sito

- **VS Code** (`editors/vscode/`): `package.json` dichiara il linguaggio `triad` (estensioni
  `.triad`, `.td`); `syntaxes/triad.tmLanguage.json` è la grammatica TextMate (`source.triad`)
  con le regole `keywords`, stringhe con interpolazione, numeri, `:-`, shebang;
  `language-configuration.json` gestisce commenti e parentesi. Pacchetto:
  `cd editors/vscode && npx @vscode/vsce package`.
- **Vim/Neovim** (`editors/vim/`): `ftdetect/triad.vim` e `syntax/triad.vim`.
- **Linguist** (`editors/linguist/`): voce `languages.yml` pronta per una PR a GitHub Linguist.
- Se aggiungi una parola chiave allo standard, aggiornala in **tutte** le grammatiche.
- **Launcher** (`bin/`): `triad` (POSIX, risolve i symlink e calcola `TRIAD_HOME`) e
  `triad.cmd` (Windows, file CRLF); vedi [§2.4](#cap-2).
- **Sito** (`docs/`): HTML statico pubblicato su GitHub Pages; `docs/assets/js/app.js` carica i
  Markdown del repository con `marked` (es. `docs/pages/tutorial.html` carica questo file).
  Le ancore dell'indice usano `<a id="…">` espliciti perché funzionino anche lì.

### Esercizi

1. **L'editor.** Apri un file `.triad` in VS Code (o Vim) e verifica l'evidenziazione della
   sintassi.
2. **Le grammatiche.** Individua i file della grammatica per VS Code e Vim: quale regola colora
   le parole chiave?
3. **GitHub Linguist.** Che cosa serve perché GitHub riconosca `.triad` e `.td`? Trova la voce.
4. **Il launcher.** Esegui un programma con `bin/triad` e con `bin/triad.cmd`: quale runtime
   scelgono?
5. **Il sito generato.** Esplora `tools/site-gen/`: perché i generatori sono scritti in Triad?
6. **Due runtime, un output.** Che cosa controlla `build.mjs` quando genera il sito? Perché
   richiede output identici?
7. **Il lint.** Che proibisce `lint.mjs` e perché? Prova a violare una regola e osserva l'errore.
8. **Le pagine.** Quale file del sito carica questo Tutorial? Come funzionano le ancore?
9. **Aggiungere una pagina.** Descrivi i passi per aggiungere una pagina al sito generato.
10. **La demo.** Spiega come funziona la demo di battitura del sito e da quale interprete gira.

---

<a id="cap-42"></a>

## 42. Integrazione continua

`.github/workflows/ci.yml`, a ogni push e pull request:

| job | cosa verifica |
|---|---|
| `conformance-core` (Ubuntu) | `sh conformance/run.sh` (42 casi Core, byte-exatti) + validità dei sorgenti `selfhost/` |
| `seed-linux` (ELF nativo, senza Wine) | `check_seed.sh` (contratto errori/limiti), hash di `seed.hex` PE **ed** ELF (gate anti-tampering), dump riproducibili (`gen_seed.js` + `cmp`), `sh verify.sh` (conformance + probe + golden S1 + smoke) |
| `linux-toolchain` (senza Node) | launcher `bin/triad`, `install.sh` con smoke test byte-exatto (un golden alterato fa fallire l'installazione), `triad-cli status` e `triad-cli test all` |
| `security` | `tests/security/run.sh` (azioni pinnate, path hijack, token, sanitizzazione) |
| `site-gen` | lint dei generatori Triad e corrispondenza byte-exatta del sito pubblicato |

`pages.yml` e `static.yml` pubblicano `docs/` su GitHub Pages a ogni push su `main`.

Il profilo Full **non è in CI** perché non è implementato: non presentarlo come verde.

### Esercizi

1. **I job.** Leggi `.github/workflows/ci.yml` e l'elenco dei job: cosa verifica ciascuno?
2. **`conformance-core`.** Quanti casi copre il job e perché nessuno viene saltato?
3. **`seed-linux`.** Perché il job confronta l'hash di `seed.hex` (PE ed ELF) e rigenera i dump?
4. **`linux-toolchain`.** Perché lo smoke test di `install.sh` deve fallire su un golden diverso?
5. **Site-gen.** Perché la generazione del sito è in CI e cosa richiede ai due runtime?
6. **Smoke test.** Che cosa verifica lo smoke test di `selfhost/main.td` e perché è in CI?
7. **Locale e CI.** Esegui in locale gli stessi comandi della CI: quali risultati ottieni?
8. **Un fallimento.** Immagina un cambiamento che rompa un caso: quale job fallisce per primo e
   come diagnostichi?
9. **Hash e riproducibilità.** Spiega il rapporto fra hash del seed, golden e riproducibilità
   delle build.
10. **Prima di una PR.** Scrivi la checklist di ciò che deve essere verde prima di aprire una
    modifica.

---

<a id="cap-43"></a>

## 43. Flusso di contributo

Checklist per tipo di modifica:

| modifica | da fare |
|---|---|
| comportamento del linguaggio | aggiorna `SPEC.md`/`SPEC-CORE.md`, `CHANGELOG.md` e, se normativa, `VERSION`; aggiungi o aggiorna casi di conformance |
| interprete JS | resta fedele a SPEC-CORE; `sh conformance/run.sh` verde |
| seed Windows | rigenera `seed.hex`, aggiorna hash in CI e nei README, prova su Windows |
| S1 (`selfhost/`) | gira su `seed.exe`; se cambia l'output di `main.td`, aggiorna lo smoke test in CI |
| CLI | handler che restituisce un booleano; `cli/README.md`; ricostruisci l'eseguibile se serve |
| editor | grammatiche VS Code e Vim allineate alle parole chiave di SPEC §1 |
| documentazione | `README.md`, `STATUS.md` e i testi del repository descrivono ciò che gira davvero |

Regole generali: non dichiarare funzionante ciò che non è verificato; i golden si scrivono
ragionando sulla specifica; i nuovi strumenti di sviluppo non devono entrare nella catena S0→S4.

### Esercizi

1. **Cosa aggiornare.** Quali documenti vanno aggiornati quando il lavoro cambia lo stato del
   progetto?
2. **Conformance prima di tutto.** Scrivi la frase che riassume la regola operativa 3 e
   applicala a un caso concreto.
3. **Modifiche al linguaggio.** Quali passi servono per proporre una modifica allo standard?
   Elencali in ordine.
4. **Niente linguaggi host.** Perché il percorso di bootstrap non può dipendere da runtime
   esterni? Dove si applica la regola?
5. **Output deterministico.** Perché i golden includono newline finali e codici di uscita?
   Costruisci un caso che lo dimostri.
6. **Test con il cambiamento.** Immagina una modifica al parser: quali test aggiungeresti?
7. **Documentare.** Scrivi la voce di CHANGELOG che descriverebbe l'aggiunta degli esercizi a
   un capitolo del libro.
8. **Review.** Elabora la checklist per revisionare una patch di un altro agente/autore.
9. **Il benchmark.** Quale regola vale quando si generano soluzioni per `ai/`?
10. **Contributo end-to-end.** Simula un contributo completo: modifica, test, documentazione,
    descrizione del cambiamento.

---

<a id="parte-5"></a>

# Parte V — Riferimento

<a id="cap-44"></a>

## 44. Grammatica Triad-Core (EBNF)

Da [`SPEC-CORE.md`](SPEC-CORE.md) §4:

```ebnf
program  = { sep } { stmt sep { sep } } ;
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

La grammatica Full (Pratt, 12 livelli) è in [`SPEC.md`](SPEC.md) §2.

### Esercizi

1. **Si legge o no?** Con la grammatica EBNF decidi quali righe sono programmi Core validi:
   `x = 1`, `x =`, `f(1, 2)`, `f(1,,2)`.
2. **Derivazione.** Scrivi la derivazione di `x = 1 + 2 * 3` a partire dalla regola delle
   espressioni.
3. **Terminali e non terminali.** Nel frammento EBNF del capitolo, elenca tre terminali e tre
   non terminali e spiega la differenza.
4. **Separatori.** Perché newline e `;` sono separatori? Costruisci un caso in cui un a capo in
   più cambia il programma.
5. **Blocchi ed `end`.** Quali regole della grammatica aprono un blocco? Scrivi un programma
   con tre livelli di annidamento.
6. **Stringhe e escape.** Dalla grammatica, elenca gli escape ammessi e scrivi una stringa per
   ciascuno.
7. **Operatori.** Come descrive la grammatica la precedenza? Confronta con la tabella del
   capitolo 7.
8. **Tokenizzare.** Scrivi la sequenza dei token di `xs[i] += 1` e commentala.
9. **EBNF a mano.** Scrivi in EBNF una piccola sotto-grammatica (per esempio i commenti) e
   verificala su tre esempi.
10. **Grammatica e parser.** Spiega perché una grammatica EBNF da sola non basta a descrivere la
    precedenza e come il parser Pratt la risolve.

---

<a id="cap-45"></a>

## 45. Schede rapide Core e Full

**Triad-Core** (eseguibile oggi):

```
assegnamento:  x = e    x += e    x -= e    x *= e    xs[i] = e
funzione:      f(a, b) = e
               function f(a, b) ... end        (anche !io, ignorato)
anonima:       x -> e    (a, b) -> e    function (a) ... end
condizione:    if c ... elseif c ... else ... end    c ? a : b
ciclo:         while c ... end    break    continue
blocchi:       let a = 1, b = 2 ... end    begin ... end
uscita:        return e
liste:         [1, 2]    xs[i] (da 1)    length(xs)    push!(xs, v)
stringhe:      "a" * "b"    length(s)    string(x)
conversioni:   Int("42")    Symbol("s")    typeof(x)
I/O:           print(...)    println(...)    ARGS
bootstrap:     readfile(p)  strlen(s)  strbyte(s, i)  strsub(s, a, b)  exit(n)
```

**Triad-Full** (specifica):

```
struttura:   struct Nome; x::T; y::T; end
funzione:    function f(a::T)::R !eff ... end
fatto:       fact p(:a, :b)
regola:      rule p(?x, ?y) :- q(?x), r(?y)
query:       solve p(?x) limit N depth D steps S trace
destruttura: (a, b) = [1, 2]        for (k, v) in [[1,2],[3,4]] ... end
ciclo for:   for v in it ... end    1:n    xs[2:end]    [e for x in xs if c]
try/catch:   try b catch e h end / try b end
contratto:   requires c / ensures c
budget:      with budget(steps = N) ... end
traccia:     with trace ... end / solve p trace
effetto:     function f() !io ... end
macro:       macro m(a) ... end / @m(e)
quote:       :(espr) / quote ... end / $espr
eval:        eval(codice)
```

### Esercizi

1. **Scheda valori.** Con la sola scheda 45 scrivi un programma con tutti i tipi Core.
2. **Scheda controllo.** Scrivi un `while` con `break` e un `if`/`elseif`/`else` senza guardare
   i capitoli.
3. **Scheda funzioni.** Scrivi una funzione breve, una blocco e una lambda.
4. **Scheda liste.** Costruisci, indicizza, aggiungi e attraversa una lista.
5. **Scheda stringhe.** Concatena, converti con `string()` e `Int()`, misura con `length`.
6. **Core o Full.** Dalla scheda, decidi per `for`, `solve`, `map`, `try`, `/` se sono Core o
   Full.
7. **Sfida a tempo.** In cinque minuti scrivi un programma che usi almeno cinque voci della
   scheda.
8. **Dalla scheda al codice.** Scegli cinque righe della scheda e trasformale in un programma
   funzionante.
9. **Errori rapidi.** Produci tre errori della scheda errori e riconoscili senza guardare il
   capitolo 46.
10. **La tua scheda.** Scrivi la scheda rapida «dei tuoi errori più comuni» con la correzione.

---

<a id="cap-46"></a>

## 46. Debug e problemi comuni

**Core (oggi):**

| sintomo | causa probabile | soluzione |
|---|---|---|
| `parse error: expected RPAREN` | `1.5`, `/`, `() -> …` o altra sintassi Full | resta nel sottoinsieme Core ([§4](#cap-4)) |
| `"x = $x"` stampato letteralmente | l'interpolazione è solo Full | `"x = " * string(x)` |
| `error: if cond` | condizione non `Bool` | usa un confronto (`x != 0`) |
| `error: < type error` su `a < b < c` | confronti concatenati | `a < b && b < c` |
| una funzione non aggiorna un globale | le funzioni nominate assegnano in locale | restituisci il valore o usa una lista ([§16.4](#cap-16)) |
| `error: undefined variable f` | funzione chiamata prima della definizione | definiscila più in alto |
| `FAIL … (golden mancante …)` | checkout senza `expected.out` | `git pull`; controlla `.gitignore` |
| il seed esce con 1 senza messaggi | funzionalità non supportata dal seed | prova con l'interprete JS; vedi [§15](#cap-15) |
| il seed Windows viene bloccato | falso positivo dell'antivirus | escludi `seed\windows-x86_64` |

**Full (specifica):**

| sintomo | causa probabile | soluzione |
|---|---|---|
| `Err(:syntax)` "atteso fine istruzione" | manca `end` o un separatore | aggiungi `end` o `;` |
| `Err(:undef)` | nome non definito | definiscilo, o usa `:nome` per un simbolo |
| `Err(:method)` / `Err(:ambiguous)` | nessun metodo / più metodi ugualmente specifici | aggiungi o ridisegna le firme |
| `Err(:bounds)` in destrutturazione | arità diversa dal pattern | liste di lunghezza esatta |
| `Err(:effect)` | `!io`/`!state` chiamata da funzione pura | dichiara l'effetto nel chiamante |
| `Err(:budget)` in `solve` | troppi passi | aumenta `steps` o usa `limit`/`depth` |

Strumenti Full previsti: `triad --tree file`, `sexpr(codice)`, `parse`/`unparse`,
`with trace … end`, `solve … trace`, `try … end` con `.kind`/`.msg`/`.data`.

### Esercizi

1. **Diagnosi guidata.** Dato un programma che non parte, applica la sequenza: nome file,
   cartella, comando, Node.js.
2. **`parse error`.** Scrivi tre programmi con errori di sintassi diversi e riconosci la causa
   dal messaggio.
3. **`error:` di esecuzione.** Produci `undefined variable`, `type error`, `index out of range`
   e spiega ciascuno.
4. **Ciclo infinito.** Scrivi un ciclo che gira all'infinito, interrompilo e correggilo.
5. **Due runtime.** Un programma gira sull'interprete JS e no sul seed: individua la causa nella
   tabella delle differenze.
6. **UTF-8 e nomi.** Verifica la codifica di un file e l'estensione `.triad`/`.td` in un caso
   problematico.
7. **Messaggi del runtime.** Traduci in italiano tre messaggi d'errore del runtime.
8. **Debug con `println`.** Trova il bug di un programma dato usando solo stampe di controllo.
9. **Problemi comuni.** Prendi i problemi elencati nel capitolo e scrivi per ciascuno un
   programma che li riproduca.
10. **La tua casella degli attrezzi.** Scrivi la checklist di debug che userai prima di chiedere
    aiuto.

---

<a id="cap-47"></a>

## 47. Glossario

- **S0 / seed**: interprete Triad-Core in codice macchina (`seed/`).
- **S1**: interprete di tutto Triad scritto in Triad-Core (`selfhost/`).
- **S2 / S3 / S4**: compilatore nativo, self-hosting, runtime completo (vedi `BOOTSTRAP.md`).
- **E0 / E1 / E2 / E3**: stadi del port Linux del seed (milestone M7): minimale, lettura file, interprete Triad-Core, toolchain senza Node.
- **Triad-Core / Triad-Full**: i due profili di conformità.
- **Interprete JS**: `seed/dev/triad_core.cjs`, riferimento Core per sviluppo e CI.
- **Golden**: output atteso committato (`expected.out`, `expected.code`).
- **Primitivi di bootstrap**: `readfile`, `strlen`, `strbyte`, `strsub`, `exit` (solo Core).
- **Lista taggata**: record Core del tipo `[:Tag, campo1, …]`.
- **Node**: l'unico tipo di albero di Triad Full (`head`, `args`): codice e dati coincidono.
- **Solution**: `{nome = valore, …}` restituita da `solve`; `s.nome` o `s[:nome]`.
- **Err**: errore come dato (`kind`, `msg`, `data`).
- **Traced**: `(result, trace)` restituito da `with trace` / `solve … trace`.
- **Occurs-check**: l'unificazione rifiuta `?x = f(?x)`.
- **Multiple dispatch**: scelta del metodo più specifico tra gli applicabili.
- **Effetti dichiarati**: `!io`, `!state` nella firma; controllo dinamico.
- **Contratti**: `requires` (pre) / `ensures` (post, con `result`).
- **Budget**: `with budget(steps = N)`; l'esaurimento è `Err(:budget)`.
- **Destrutturazione**: `(a, b) = lista`, `for (k, v) in lista_di_liste`.

### Esercizi

1. **Definizioni.** Definisci con le tue parole: *unificazione*, *backtracking*, *dispatch*,
   *chiusura*, *albero uniforme*.
2. **Coppie che confondono.** Distingui con un esempio: budget/limit, effetto/contratto,
   simbolo/variabile logica, parametro/argomento.
3. **Parlare di logica.** Scrivi una frase che usi: goal, soluzione, knowledge base, occurs-check.
4. **Parlare di macro.** Scrivi una frase che usi: quote, unquote, espansione, igiene.
5. **Vero o falso.** Valuta cinque affermazioni tratte dal glossario e correggi quelle false.
6. **Dalle lingue madri.** Quali parole arrivano da Julia, Prolog e Lisp? Collega ciascuna alla
   sua origine.
7. **Tradurre.** Scegli cinque voci in inglese e scrivi la spiegazione che daresti a un
   principiante italiano.
8. **Il glossario di un programma.** Annota un tuo programma con almeno sei termini del
   glossario.
9. **Domande di ripasso.** Scrivi cinque domande sul glossario e rispondi senza guardare.
10. **Una voce nuova.** Aggiungi al glossario un termine che manca, nello stile delle voci
    esistenti.

---

<a id="cap-48"></a>

## 48. Stato, limiti noti e fix storici

**Stato** (dettagli in [`STATUS.md`](STATUS.md)):
- Core: 42/42 casi byte-exatti su PE, ELF e interprete JS.
- Full: 12 casi golden congelati, passa solo `errore`.
- S1: prototipi in `selfhost/`, smoke test in CI; non ancora conformance.
- S2–S4: non iniziati. Seed Linux: E2/E3 completi (interprete + toolchain senza Node).
- CLI `triad`: solo esecuzione di file (REPL e opzioni di SPEC §14 da fare).

**Limiti dello standard** (SPEC §15): argomenti con nome (salvo `budget(steps = …)`), struct
mutabili, tipi astratti utente e parametrici, macro senza parentesi, quote annidate a più
livelli, cut di Prolog non sono previsti; il controllo degli effetti è dinamico.

**Fix storici** applicati alla vecchia implementazione Julia; il comportamento "dopo" è quello
richiesto da SPEC.md per ogni implementazione:

| # | fix | dopo |
|---|---|---|
| 1 | round-trip del range | `unparse(1:n)` produce `"1:n"` (senza spazi) |
| 2 | `unparse` di `:destructure`/`:dfor` | hanno rami propri e fanno round-trip |
| 3 | `xs[end] = v` | `end` è legato anche in scrittura: `xs[end] = 7` funziona |
| 4 | escape sconosciuti | solo `\n \t \" \\ \$`; altri → `Err(:syntax)` con riga e colonna |
| 5 | commenti `#=` annidati | la profondità è contata; `#=` non chiuso → errore `incomplete` |
| 6 | lambda con parametri tipati | `function (x::Int) x end` controlla i tipi: `f(2.0)` → `Err(:type)` |

### Esercizi

1. **Verificare un fix.** Scegli uno dei fix storici della tabella (per esempio `xs[end] = v`)
   e scrivi il programma che lo mette alla prova.
2. **Round-trip.** Verifica `unparse(1:n)` produce `"1:n"` e spiega perché contano i dettagli di
   forma.
3. **Escape sconosciuti.** Prova `"\q"` e verifica che l'errore riporti riga e colonna.
4. **Commenti annidati.** Prova `#=` annidati e un `#=` non chiuso: quali comportamenti?
5. **Lambda tipata.** Verifica che `function (x::Int) x end` controlli il tipo degli argomenti.
6. **Limiti noti.** Scrivi un programma per ciascuno dei limiti noti del capitolo e annota la
   divergenza fra i runtime.
7. **Documentare una divergenza.** Trova un comportamento diverso fra i due runtime e scrivi la
   voce che aggiungeresti allo stato del progetto.
8. **Prima e dopo.** Immagina il comportamento di un programma prima di un fix e dopo: scrivi
   entrambi gli output attesi.
9. **Lo stato del progetto.** Dove si tengono aggiornati limiti e fix (`STATUS.md`, `TASK.md`,
   `CHANGELOG.md`)? Che cosa va scritto in ciascuno?
10. **Regressioni.** Perché ogni fix storico merita un caso di conformance? Scrivi il caso per un
    fix a scelta.

---

<a id="cap-49"></a>

## 49. FAQ

**Serve Julia?** No. L'implementazione Julia è stata rimossa; Triad gira sul seed in codice
macchina (Windows) o sull'interprete JS di sviluppo.

**Perché i miei esempi con `struct` o `fact` non girano?** Sono Triad-Full: il runtime attuale
esegue solo Triad-Core. Vedi la tabella dei profili all'inizio del Tutorial.

**`.td` o `.triad`?** `.triad` è canonica; `.td` è accettata come alias (ed è anche
l'estensione di LLVM TableGen, quindi per il riconoscimento esterno conviene `.triad`).

**Come verifico che un programma sia Core "puro"?** Eseguilo con l'interprete JS e controlla
di non usare primitivi di bootstrap se deve valere anche per Full; per i casi normativi
aggiungilo alla conformance Core.

**Perché `selfhost/*.td` falliscono con l'interprete JS?** Usano `get(xs, i)`, helper non
standard del seed Windows; vanno eseguiti con `seed.exe`.

**Dove propongo una modifica al linguaggio?** Nello standard (`SPEC.md`/`SPEC-CORE.md`) con
voce in `CHANGELOG.md` e casi di conformance; poi nelle implementazioni.

**Cosa sono i «tentativi» di successo e fallimento (PASS/FAIL, `pass@k`) del benchmark `ai/`?**
Un task è un piccolo esercizio (somma, fattoriale, stringhe…) con un output atteso; la soluzione
si verifica eseguendola e confrontando l'output: **PASS** se coincide, **FAIL** altrimenti. Un
*tentativo* è una generazione della soluzione: `pass@1` conta solo il primo tentativo riuscito,
`pass@k` accetta che basti uno dei k tentativi per task («il primo che riesce conta»). Il
riferimento di successo/fallimento è dunque l'output atteso del task, non il linguaggio. Le
stesse parole nella programmazione logica (SPEC §6, [capitolo 22](#cap-22)) indicano invece
l'esito di un goal: `:call`/`:redo`/`:exit`/`:fail` sono i tentativi del motore registrati da
`solve … trace`. Vedasi anche le Fondamenta del volume, capitolo 16.

### Esercizi

1. **No Julia.** Perché il programma non ha più bisogno di Julia? Quale runtime esegue oggi
   Triad?
2. **Perché non gira.** Prendi un esempio con `struct` o `fact` e spiega perché non viene
   eseguito oggi.
3. **`.td` o `.triad`.** Qual è l'estensione canonica? Prova a eseguire un file con ciascuna.
4. **Codice Core puro.** Verifica con l'interprete JS che un tuo programma sia Core «puro»: su
   cosa ti fidi?
5. **`get` in `selfhost/`.** Perché `selfhost/*.td` gira con `seed.exe` e non con l'interprete
   JS? Verifica.
6. **Proporre una modifica.** Descrivi i passi per proporre una modifica al linguaggio secondo
   la FAQ.
7. **PASS, FAIL e pass@k.** Spiega a voce il significato delle tre espressioni con un esempio.
8. **Successo e fallimento in logica.** Spiega la seconda faccia di `success`/`fail` con le
   porte di Byrd.
9. **Le tue FAQ.** Scrivi tre domande che avresti voluto trovare nella FAQ con la risposta.
10. **Domande senza risposta.** Scegli una domanda aperta sul progetto e scrivi come la
    investigheresti.

---

Gli esempi Core marcati **Output:** si verificano eseguendoli con
`node seed/dev/triad_core.cjs`.
