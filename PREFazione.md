# Prefazione

Triad è un linguaggio di programmazione autonomo: sintassi a blocchi e tipi dichiarati, multiple
dispatch, programmazione logica integrata, codice come dato. La sua definizione è una specifica
normativa indipendente dall'implementazione, accompagnata da una specifica eseguibile e da una
suite di conformità con golden verificabili. Questo libro ne è il percorso di studio.

Il libro nasce da un'esigenza semplice: imparare Triad non significa solo leggere la specifica,
ma costruire un modello mentale del linguaggio, dei suoi costrutti e del suo runtime. La specifica
è normativa e precisa, ma è scritta per essere implementata, non per essere letta come un romanzo.
Questo volume la traduce in un percorso: spiegazioni, esempi, esercizi, marcatori di profilo.

Il lettore ideale sa già programmare in un altro linguaggio: sa cosa sono una variabile, una
funzione, un ciclo, una ricorsione. Questo libro non insegna la programmazione in generale, insegna
Triad. Le influenze del linguaggio (Julia, Prolog, Lisp) sono documentate nell'Appendice A della
specifica: sono note informative, non definizioni. Triad non è un dialetto di nessuno dei tre.

Il volume riunisce due testi complementari. Il *Manuale di Triad 2.0* spiega il linguaggio,
propone esercizi e chiude con grammatica, schede rapide, tabella degli errori, glossario e
appendici. Il *Tutorial di Triad 2.0* è diviso in cinque parti: primi passi, Triad-Core,
Triad-Full, codice del progetto e riferimento. I due indici che seguono questa prefazione sono
indipendenti: il primo appartiene al Manuale, il secondo al Tutorial.

Se vuoi scrivere programmi eseguibili oggi, comincia dal Tutorial, parti I e II; usa il Manuale
per approfondire i concetti e fare gli esercizi. Per studiare lo standard completo, prosegui con
la parte III del Tutorial e i capitoli corrispondenti del Manuale. La parte IV è pensata per chi
vuole esplorare o modificare il repository.

Le appendici del Manuale orientano tra le influenze del linguaggio e le fonti del progetto. I
testi normativi integrali non sono riprodotti nel volume: sono disponibili nei file `SPEC.md` e
`SPEC-CORE.md` del repository, che restano le fonti definitive in caso di divergenza.

Due profili di conformità attraversano tutto il libro. Triad-Core è il sottoinsieme di bootstrap:
valori, funzioni, chiusure, controllo di flusso, liste, stringhe, I/O. Triad-Full è lo standard
completo. Ogni programma Core è anche un programma Full valido e deve comportarsi allo stesso modo.
I marcatori **[Core]** e **[Full]** indicano in quale profilo esiste ciascun costrutto; i blocchi
di codice sono marcati `triad` per il codice Core e `triad-full` per il codice definito dallo
standard Full, non ancora eseguibile dal runtime corrente. Gli esempi Core si possono provare
con l'interprete JavaScript di riferimento (`node seed/dev/triad_core.cjs`); i frammenti indicati
come specifici del seed fanno eccezione.

Il seed S0 è un interprete Triad-Core scritto direttamente in codice macchina x86-64, senza un
linguaggio ospite; oggi il seed eseguibile è quello per Windows. Non va confuso con l'interprete
JavaScript usato per eseguire gli esempi Core e verificare la conformance. Il piano di bootstrap
prevede S1 (un interprete Triad scritto in Triad-Core), S2 (compilatore nativo), S3 (self-hosting)
e S4 (parità cross-platform). Dove il runtime non copre un costrutto, il testo lo dice
esplicitamente.

Buona lettura, e buon codice.

— GPuntobit