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

Il volume è organizzato in quattro parti. La prima, *Fondamenti*, introduce il lessico, i valori e
i tipi, il controllo di flusso, le funzioni, il dispatch, la logica, il codice come dato, gli errori,
i contratti, il budget, le tracce e gli effetti. La seconda, *Triad-Core*, copre il sottoinsieme
eseguibile oggi dall'interprete di riferimento, con tutti i 37 casi di conformance. La terza,
*Triad-Full*, presenta i costrutti dello standard completo, oggi studiabili ma non ancora
eseguibili dal runtime corrente. La quarta, *Dentro il progetto*, accompagna il lettore nel codice
del repository: il seed in codice macchina, la suite di conformance, la CLI, gli strumenti per
gli editor.

Due profili di conformità attraversano tutto il libro. Triad-Core è il sottoinsieme di bootstrap:
valori, funzioni, chiusure, controllo di flusso, liste, stringhe, I/O. Triad-Full è lo standard
completo. Ogni programma Core è anche un programma Full valido e deve comportarsi allo stesso modo.
I marcatori **[Core]** e **[Full]** indicano in quale profilo esiste ciascun costrutto; i blocchi
di codice sono marcati `triad` (eseguibile oggi) o `triad-full` (specificato
ma non ancora eseguibile).

Il runtime di riferimento è il seed S0: un interprete Triad-Core scritto direttamente in codice
macchina x86-64, senza alcun linguaggio ospite. Il piano di bootstrap prevede S1 (un interprete
Triad scritto in Triad-Core), S2 (compilatore nativo), S3 (self-hosting) e S4 (parità
cross-platform). Il libro riflette questo stato: dove il runtime non copre un costrutto, il testo
lo dice esplicitamente.

Buona lettura, e buon codice.

— GPuntobit