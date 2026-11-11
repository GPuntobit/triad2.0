# Capitolo 21 — Verso il self-hosting

S1 è l'interprete di tutto Triad scritto in Triad-Core ed eseguito dal seed. Quando esisterà,
gli esempi di `examples/` gireranno e la suite Full diventerà verde. Oggi è allo stadio di
prototipi, nella cartella `selfhost/`.

## 21.1 Che cosa c'è

Ogni file esplora un pezzo del futuro interprete e termina con un piccolo test: `main.td`
(ambiente come lista piatta, verificato dalla CI che si aspetta `Value: 10`), `value.td` (valori
taggati simulati con interi), `tokenizer.td` (lettura di un token da un sorgente codificato come
lista di byte), `parser.td`, `eval.td`, `program.td` e alcuni abbozzi. I sorgenti completi sono
nell'appendice [Sorgenti self-hosted](Sorgenti-self-hosted).

## 21.2 Scrivere per il seed

Poiché S1 deve girare sul seed, ne rispetta i limiti (capitolo 12): usa l'helper `get(xs, i)` con
indici da 0 invece di `xs[i]`, rappresenta le stringhe come liste di codici ASCII con la lunghezza
in testa, scrive `env = push!(env, v)`, usa lambda a un parametro e funzioni con al massimo
quattro parametri. Questi file non girano con l'interprete di riferimento, che non ha `get`.

## 21.3 La strada

Le task S1.3–S1.15 di `TASK.md` tracciano il percorso: valori taggati, tokenizer e parser
completi, valutazione di espressioni e programmi, funzioni, chiusure e infine la conformità
eseguita sopra seed + S1. Il progetto del capitolo 13 è una versione in Core standard degli
stessi passi.

## Riepilogo

- S1 è in `selfhost/`, a prototipi; la CI esegue `main.td` sul seed.
- Il codice S1 rispetta i limiti del seed (`get` da 0, liste di interi).
- Il percorso è descritto in `TASK.md`.
<!-- nav -->

---

← [Capitolo 20 — Il seed in codice macchina](Libro-20-Seed) · [Sommario](Home) · [Capitolo 22 — Gli strumenti di sviluppo](Libro-22-Strumenti) →
