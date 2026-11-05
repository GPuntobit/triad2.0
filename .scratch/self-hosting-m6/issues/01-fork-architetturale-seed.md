# 01 — Fork architetturale del seed: gap reali e AST/bytecode

Type: grilling
Status: open

## Question

Il seed interprete (M3) deve essere completo prima che S1 possa girarci sopra. La prima
domanda è **fattuale** (regola 1: nessuna semantica inventata): qual è l'elenco *vero* dei
gap? I documenti si contraddicono — `TASK.md` dichiara il PE già capace di `elseif` e
liste «complete (build, print, push!, get)», mentre `BOOTSTRAP.md` §10 elenca ancora
«AST/bytecode for multi-binding capture, `elseif`, lists» come mancanti (M3b2b3f: capture
multi-binding instabile). La ricognizione dei gap reali apre il ticket.

Poi la decisione: di fronte ai gap reali — capture multi-binding in primis — si
- **(a) estende l'interprete diretto** in codice macchina così com'è, o
- **(b) introduce un livello AST/bytecode** nel seed (il fork annotato in `BOOTSTRAP.md` §10)?

Il risultato si colloca nel ciclo di rebuild PE/ELF + hash CI previsto per N03–N05
(`TASK.md`), sotto la politica dei byte del PE (cambi semantici deliberati ammessi con hash
CI + diff tracciati): è lì che si implementa, qui si decide.

## Riferimenti

- Politica dei byte del PE ([01 — Politica dei byte del PE nella rifattorizzazione](../../seed-linux-nativo/issues/01-byte-pe.md)): cambi semantici deliberati ammessi con hash CI + diff tracciati.
- Slice di esecuzione: `TASK.md` N03–N05 (ciclo rebuild PE/ELF + hash CI).
- Successore: [02 — Architettura di S1](02-architettura-s1.md).
