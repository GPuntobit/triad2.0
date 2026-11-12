#!/usr/bin/env python3
"""Pulizia di testo: ridondanze, riferimenti spostati, refusi, spazi.

Va eseguito dopo `_extract_esercizi.py` e `_fix_riferimenti.py`.

Uso: python3 docs/_cleanup_testi.py [--dry]
"""
import os
import sys

DOCS = os.path.dirname(os.path.abspath(__file__))
DRY = '--dry' in sys.argv


def edit(path, pairs, required=True):
    with open(os.path.join(DOCS, path), encoding='utf-8') as f:
        txt = f.read()
    for old, new in pairs:
        if old not in txt:
            if required:
                raise SystemExit(f'{path}: frammento non trovato:\n{old[:120]!r}')
            continue
        txt = txt.replace(old, new, 1)
    if not DRY:
        with open(os.path.join(DOCS, path), 'w', encoding='utf-8') as f:
            f.write(txt)
    print(f'{path}: {len(pairs)} modifiche')


# ---------------------------------------------------------------- MANUALE

MANUALE = [
    # --- apertura e indice -------------------------------------------------
    ("""> Il manuale completo del linguaggio: lessico, valori, controllo di flusso, funzioni, dispatch,
> logica, codice come dato, errori, contratti, budget, tracce, effetti, esercizi e riferimento.
""",
     """> Il manuale completo del linguaggio: lessico, valori, controllo di flusso, funzioni, dispatch,
> logica, codice come dato, errori, contratti, budget, tracce, effetti e riferimento. Gli esercizi
> sono in un file a parte: [`MANUALE-ESERCIZI.it.md`](MANUALE-ESERCIZI.it.md).
"""),
    ("""specifica: è un percorso di studio, con spiegazioni, esempi ed esercizi. Puoi leggerlo dall'inizio
alla fine senza altro materiale: ogni concetto che serve per capire un capitolo è spiegato prima o
in quel capitolo, e i rimandi esterni sono approfondimenti facoltativi. Non è una raccolta di pagine
da consultare a caso: è un libro, e l'ordine dei capitoli costruisce il modello mentale del
linguaggio un pezzo alla volta.""",
     """specifica: è un percorso di studio, con spiegazioni ed esempi. Puoi leggerlo dall'inizio
alla fine senza altro materiale: ogni concetto che serve per capire un capitolo è spiegato prima o
in quel capitolo, e i rimandi esterni sono approfondimenti facoltativi. Non è una raccolta di pagine
da consultare a caso: è un libro, e l'ordine dei capitoli costruisce il modello mentale del
linguaggio un pezzo alla volta. Gli esercizi, con le relative soluzioni, sono raccolti in
[`MANUALE-ESERCIZI.it.md`](MANUALE-ESERCIZI.it.md)."""),
    ("""**Parte II — Esercizi** · [23. Esercizi guidati](#cap-23) · [24. Esercizi su Triad-Full](#cap-24)

**Parte III — Riferimento** ·""",
     """**Esercizi** · [Esercizi per capitolo, esercizi guidati e esercizi di riferimento](MANUALE-ESERCIZI.it.md)

**Parte II — Riferimento** ·"""),
    ("""<a id="parte-3"></a>

# Parte III — Riferimento""",
     """<a id="parte-2"></a>

# Parte II — Riferimento"""),
    ("""spiegazione. Tieni presente che le sezioni di riferimento descrivono lo **standard**; lo stato di
ciò che è eseguibile oggi è raccolto nell'ultimo capitolo.""",
     """spiegazione. Tieni presente che le sezioni di riferimento descrivono lo **standard**; lo stato di
ciò che è eseguibile oggi è raccolto nell'ultimo capitolo. Gli esercizi di queste sezioni sono in
[`MANUALE-ESERCIZI.it.md`](MANUALE-ESERCIZI.it.md)."""),
    # --- rimandi ai capitoli spostati --------------------------------------
    ("""valori; è una forma di Triad-Full, e in Core si ottiene con un ciclo. La destrutturazione nel `for`
è trattata nel capitolo 24.""",
     """valori; è una forma di Triad-Full, e in Core si ottiene con un ciclo. La destrutturazione nel `for`
è trattata negli esercizi su Triad-Full."""),
    ("""sulle stringhe (cap. 23, esercizio 6).""",
     """sulle stringhe (esercizi guidati, esercizio 6)."""),
    # --- ridondanze --------------------------------------------------------
    ("""La sequenza di controllo è significativa: il corpo valuta le clausole nell'ordine in cui
compaiono; le precondizioni vengono verificate nel punto in cui sono dichiarate, mentre le
postcondizioni vengono conservate fino al completamento della funzione. Il valore finale viene
prima sottoposto al vincolo di ritorno e poi esposto come `result` alle clausole `ensures`.
Un errore di contratto include quale clausola è fallita e il codice che la rappresenta, così chi
chiama può distinguere una violazione d'ingresso da una promessa d'uscita non mantenuta. I
contratti controllano un'invariante osservabile, ma non provano matematicamente che valga per ogni
input possibile: vengono valutati per le esecuzioni che avvengono.""",
     """La sequenza di controllo è significativa: il corpo valuta le clausole nell'ordine in cui
compaiono; le precondizioni vengono verificate nel punto in cui sono dichiarate, mentre le
postcondizioni vengono conservate fino al completamento della funzione. Il valore finale viene
prima sottoposto al vincolo di ritorno e poi esposto come `result` alle clausole `ensures`."""),
    ("""La purezza per impostazione predefinita significa che una funzione può calcolare e restituire valori
senza modificare lo stato esterno né produrre I/O; non significa che il runtime analizzi
staticamente ogni possibile percorso prima dell'esecuzione. Il controllo dinamico osserva gli effetti mentre
avvengono e li confronta con il contesto attivo. Le mutazioni locali e quelle di liste non sono
classificate come effetti dichiarati in questa specifica: `!state` si riferisce alla modifica
della knowledge base tramite `fact` e `rule`, non a qualunque assegnamento.""",
     """La purezza per impostazione predefinita significa che una funzione può calcolare e restituire valori
senza modificare lo stato esterno né produrre I/O; non significa che il runtime analizzi
staticamente ogni possibile percorso prima dell'esecuzione. Il controllo dinamico osserva gli effetti mentre
avvengono e li confronta con il contesto attivo."""),
    ("""distinta. Nel contatore, invece, la variabile `v` è un legame condiviso: ogni chiamata aggiorna
lo stesso stato e la successiva lo osserva. È il motivo per cui una chiusura può rappresentare
un piccolo oggetto con stato privato. È anche il motivo per cui il comportamento specifico del
seed Windows va verificato separatamente dall'interprete di riferimento.""",
     """distinta. Nel contatore, invece, la variabile `v` è un legame condiviso: ogni chiamata aggiorna
lo stesso stato e la successiva lo osserva. È il motivo per cui una chiusura può rappresentare
un piccolo oggetto con stato privato."""),
    ("""Una lista è un oggetto mutabile; una variabile contiene un riferimento a quell'oggetto. Se `ys =
xs`, i due nomi permettono di raggiungere la stessa lista: `push!(ys, valore)` e `xs[i] = valore`
sono osservabili anche leggendo `xs`. Se invece scrivi `ys = [1, 2]`, hai sostituito soltanto il
legame `ys`; `xs` continua a riferirsi alla lista precedente. Questa distinzione spiega perché
assegnare una lista non ne crea automaticamente una copia e perché gli argomenti lista possono
essere usati per condividere stato tra funzioni.""",
     """Se scrivi `ys = [1, 2]`, hai sostituito soltanto il legame `ys`; `xs` continua a riferirsi alla
lista precedente. Questa distinzione spiega perché assegnare una lista non ne crea automaticamente
una copia e perché gli argomenti lista possono essere usati per condividere stato tra funzioni."""),
]


# -------------------------------------------------------------- FONDAMENTA

FONDAMENTA = [
    # --- apertura ----------------------------------------------------------
    ("""Alla fine della parte trovi esercizi con soluzioni, un glossario dei termini
tecnici usati e una mappa per proseguire nel resto del libro.""",
     """Gli esercizi con le relative soluzioni sono in un file a parte
([`FONDAMENTA-ESERCIZI.it.md`](FONDAMENTA-ESERCIZI.it.md)); in questa parte trovi il glossario
dei termini tecnici usati e una mappa per proseguire nel resto del libro."""),
    # --- capitolo 8: la sezione dei sottogeneri resta, gli esercizi no ------
    ("""### 8.1 Esercizi per sottogenere""", """### 8.1 I cinque sottogeneri"""),
    ("""Tutte le soluzioni qui sotto girano identiche sul seed e sull'interprete di riferimento: prova
prima a scriverle da solo, esegui e confronta l'output, e solo allora leggi la soluzione.""",
     """Le soluzioni di questi esercizi sono in
[`FONDAMENTA-ESERCIZI.it.md`](FONDAMENTA-ESERCIZI.it.md)."""),
    # --- refusi -------------------------------------------------------------
    ("""Ho aggiunto a `alias` eppure è cambiata anche `xs`:""",
     """Ho aggiunto a `alias` e pure è cambiata anche `xs`:"""),
    # --- rimandi -----------------------------------------------------------
    ("""Ultima cosa, la più importante: progettare bene si impara solo progettando. Prendi gli esercizi
del [capitolo 14](#fond-14), applica questi cinque passi a ciascuno""",
     """Ultima cosa, la più importante: progettare bene si impara solo progettando. Prendi gli esercizi
di [`FONDAMENTA-ESERCIZI.it.md`](FONDAMENTA-ESERCIZI.it.md), applica questi cinque passi a ciascuno"""),
    ("""- Il **Manuale di Triad 2.0** spiega il linguaggio capitolo per capitolo: lessico, valori,
  controllo di flusso, funzioni, logica, errori, contratti, con esercizi a fine capitolo e
  riferimenti finali (grammatica, schede rapide, tabella degli errori, glossario, appendici). È
  il testo in cui approfondire ogni concetto che qui abbiamo solo sfiorato.""",
     """- Il **Manuale di Triad 2.0** spiega il linguaggio capitolo per capitolo: lessico, valori,
  controllo di flusso, funzioni, logica, errori, contratti, con riferimenti finali (grammatica,
  schede rapide, tabella degli errori, glossario, appendici). È il testo in cui approfondire ogni
  concetto che qui abbiamo solo sfiorato; i suoi esercizi sono in
  [`MANUALE-ESERCIZI.it.md`](MANUALE-ESERCIZI.it.md)."""),
    ("""**Tutorial, parti I e II** (scrivere programmi Core veri) → **Manuale** (approfondire, con gli
esercizi) →""",
     """**Tutorial, parti I e II** (scrivere programmi Core veri) → **Manuale** (approfondire) e i suoi
esercizi →"""),
]


# -------------------------------------------------------- file degli esercizi

ESERCIZI_FONDAMENTA = [
    # la nota sulle soluzioni dei sottogeneri torna accanto agli esercizi
    ("""### Esercizi per sottogenere
""",
     """### Esercizi per sottogenere

Tutte le soluzioni qui sotto girano identiche sul seed e sull'interprete di riferimento: prova
prima a scriverle da solo, esegui e confronta l'output, e solo allora leggi la soluzione.
"""),
    # rimando rotto: il capitolo 8.1 non contiene gli errori dei principianti
    ("""   classico del capitolo 8.1 potrebbe esserne la causa? Verifica la tua ipotesi.""",
     """   classico del capitolo 12.4 potrebbe esserne la causa? Verifica la tua ipotesi."""),
    # rimando ai capitoli delle Fondamenta: puntare al file principale
    ("""La funzione `massimo` del [capitolo 10](#fond-10) torna utile:""",
     """La funzione `massimo` del [capitolo 10](FONDAMENTA.it.md#fond-10) torna utile:"""),
]


if __name__ == '__main__':
    edit('MANUALE.it.md', MANUALE)
    edit('FONDAMENTA.it.md', FONDAMENTA)
    edit('FONDAMENTA-ESERCIZI.it.md', ESERCIZI_FONDAMENTA)
