# Prefazione

Questo libro racconta Triad: un linguaggio di programmazione giovane, nato con un'ambizione
precisa e un po' ostinata. Non vuole essere l'ennesimo dialetto ospitato da un altro
linguaggio, né una libreria travestita da sintassi. Vuole essere un linguaggio **autonomo**,
definito da una specifica scritta, verificato da una suite di test che chiunque può eseguire, e
capace, un giorno, di compilare se stesso partendo da poche migliaia di byte di codice macchina
scritti a mano.

È un'ambizione che si capisce meglio leggendo il codice che la sta realizzando. Per questo il
libro ha due anime. La prima insegna a **programmare in Triad**: parte dai mattoni più semplici,
i numeri e le variabili, e arriva fino alle chiusure, alle liste, alla manipolazione dei byte di
una stringa e alla costruzione di un piccolo interprete. La seconda accompagna il lettore
**dentro il progetto**: come è fatta la suite di conformità, come lavora l'interprete di
riferimento, come si scrive un interprete in codice macchina senza assembler, come si prepara il
salto verso l'auto-ospitalità.

## A chi è rivolto

A chi sa già programmare in almeno un linguaggio e vuole capire Triad a fondo, non solo usarlo.
Non serve conoscere Julia, Prolog o Lisp, anche se chi li conosce riconoscerà molte idee; non
serve conoscere l'assembly x86-64 per leggere la quarta parte, anche se aiuta. Ogni concetto
viene introdotto spiegando prima **perché** esiste, poi **come** si usa, infine **dove** lo si
trova nel repository.

## Come è organizzato

- **Parte prima — Fondamenti.** Che cos'è Triad, quali promesse fa, come è diviso in due
  profili (Core e Full) e come si prepara l'ambiente per scrivere il primo programma.
- **Parte seconda — Programmare in Triad-Core.** Il cuore pratico del libro. Triad-Core è la
  parte del linguaggio che oggi si può eseguire davvero; ogni esempio di questa parte è stato
  eseguito e il suo output è riportato fedelmente. Si chiude con un progetto guidato: un
  tokenizer e un valutatore di espressioni scritti in Triad.
- **Parte terza — Il linguaggio completo.** Triad-Full: tipi e multiple dispatch, programmazione
  logica, codice come dato e macro, e le "garanzie" (errori come dati, contratti, budget, tracce,
  effetti). Questa parte descrive lo standard: i programmi non girano ancora sul runtime attuale,
  e il testo lo dice ogni volta.
- **Parte quarta — Dentro il progetto.** L'anatomia del repository, l'interprete di riferimento,
  il seed in codice macchina, il lavoro verso il self-hosting, gli strumenti di sviluppo.

In fondo trovi le **appendici**: il riferimento dei builtin, i cataloghi completi dei casi di
conformità, i sorgenti degli esempi e di `selfhost/`, le copie dei documenti normativi, un indice
analitico e un manuale di consultazione rapida.

## Convenzioni di lettura

Gli esempi di codice sono scritti così:

```julia
println("ciao")
```

Quando un esempio è seguito dalla parola **Output:** e da un riquadro di testo, quel testo è
esattamente ciò che il programma stampa, verificato eseguendolo con l'interprete di riferimento
`node seed/dev/triad_core.cjs`:

```julia
println(6 * 7)
```

Output:

```text
42
```

Gli esempi della parte terza riportano invece, quando c'è, l'output **di riferimento** (i
"golden" della suite Full), segnalato come tale.

I riquadri che iniziano con **Nota**, **Attenzione** o **Perché** contengono approfondimenti:
si possono saltare a una prima lettura, ma spiegano spesso le scelte di progetto più
interessanti.

## Una parola sullo stato del progetto

Triad è in costruzione, e un libro onesto deve dirlo. Oggi esistono uno standard completo
(`SPEC.md`), un sottoinsieme eseguibile (Triad-Core, `SPEC-CORE.md`), un interprete in codice
macchina per Windows che ne esegue gran parte, un interprete di riferimento in JavaScript usato
per lo sviluppo, e i primi passi di un interprete scritto in Triad stesso. Il resto è strada da
percorrere. Dove il libro descrive qualcosa che non gira ancora, lo dichiara; dove descrive
qualcosa che gira, lo dimostra.

Buona lettura.
<!-- nav -->

---

[Sommario](Home) · [Capitolo 1 — Perché Triad](Libro-01-Perche-Triad) →
