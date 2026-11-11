# Capitolo 17 — Garanzie, costrutti Full e interfaccia

L'ultimo capitolo della parte terza raccoglie ciò che rende Triad-Full un linguaggio
"affidabile per costruzione": errori come dati, contratti, budget, tracce ed effetti. Lo
completano i costrutti di comodità che Core non ha (`for`, range, comprehension,
destrutturazione) e l'interfaccia a riga di comando prevista dallo standard.

## 17.1 Errori come dati

In Full un errore è un valore di tipo `Err`, con tre campi: `kind` (un simbolo che classifica
l'errore), `msg` (un messaggio) e `data` (dettagli). `try espressione end` trasforma un errore in
valore; `try … catch e … end` permette di gestirlo:

```julia
e = try div(1, 0) end     # Err(:domain, …)
e.kind                    # :domain
iserr(e)                  # true
r = try div(1, 0) catch e; 0 end   # 0
throw(err(:mio, "ops", 42))
```

I generi standard sono `:syntax`, `:undef`, `:type`, `:method`, `:ambiguous`, `:field`,
`:bounds`, `:domain`, `:instantiation`, `:contract`, `:budget`, `:effect`, `:host`. Un errore non
gestito al livello più esterno termina il programma con codice 1: è ciò che verifica il caso di
conformità `errore`, l'unico caso Full che passa già oggi. Combinati con il dispatch, gli errori
diventano dati come gli altri: `descrivi(e::Err)` e `descrivi(x::Any)` sono due metodi diversi.

## 17.2 Contratti

`requires` esprime una precondizione, `ensures` una postcondizione in cui `result` è il valore
restituito:

```julia
function safe_div(a::Number, b::Number)::Float
    requires b != 0
    ensures abs(result * b - a) < 1e-9
    a / b
end
e = try safe_div(1, 0) end
e.kind; e.data.clause; e.data.fn      # :contract, :requires, :safe_div
```

Una violazione produce `Err(:contract)` con la clausola, la funzione, la condizione e il
risultato. I contratti devono essere puri; `ensures` fuori da una funzione è un errore di
sintassi; `requires` al livello più esterno funziona come asserzione.

## 17.3 Budget

`with budget(steps = N) … end` esegue un blocco con un limite di passi (chiamate, iterazioni,
passi di risoluzione logica). Se il limite si esaurisce, il valore del blocco è `Err(:budget)`:

```julia
r = with budget(steps = 10_000)
    while true end
end
r.kind      # :budget
```

I budget si annidano e vale il più stretto. Anche la ricorsione infinita si risolve così: Triad
usa uno stack esplicito, quindi non va in crash ma esaurisce il budget.

## 17.4 Tracce

`with trace … end` restituisce, oltre al risultato, la lista degli eventi di esecuzione:

```julia
fib(n::Int) = n < 2 ? n : fib(n - 1) + fib(n - 2)
t = with trace
    fib(3)
end
t.result   # 2
t.trace    # [Event(port=:call, fn=:fib, args=[3], depth=0), …]
```

Per `solve … trace` gli eventi seguono le "porte" del modello di Byrd di Prolog: `:call`,
`:exit`, `:redo`, `:fail`. La traccia è un dato: si filtra e si conta come una lista.

## 17.5 Effetti dichiarati

Le funzioni sono pure per default. Chi stampa dichiara `!io`, chi modifica la base di conoscenza
`!state`:

```julia
function saluta(nome::String) !io
    println("ciao, ", nome)
end
```

Una funzione pura che stampa, o che chiama una funzione `!io`, produce `Err(:effect)`. Il livello
più esterno può tutto; le lambda ereditano gli effetti del contesto; leggere la base di
conoscenza e modificare liste locali non sono effetti.

## 17.6 Costrutti di comodità

Full ha il ciclo `for`, i range e le comprehension, che in Core si scrivono a mano:

```julia
for i in 1:10 … end
xs[2:end]
[x^2 for x in 1:4 if x > 2]       # [9, 16]
```

e la **destrutturazione** con arità esatta:

```julia
(a, b) = [1, 2]
for (k, v) in [[1, 2], [3, 4]] … end
e = try (a, b) = [1] end          # e.kind == :bounds
```

## 17.7 L'interfaccia a riga di comando

Lo standard (`SPEC.md` §14) definisce il comando `triad`: `triad FILE [ARG...]` esegue un file,
`triad` da solo apre un REPL, `-l` e `-i` combinano caricamento e REPL, `-e`/`-E` valutano codice,
`--tree` stampa l'albero uniforme, `-` legge da stdin. Il REPL è in stile Prolog: `?- goal` pone
una domanda e mostra le soluzioni una alla volta (`;` per la successiva, `.` per fermarsi), e
comandi come `:load`, `:listing`, `:tree`, `:reset` gestiscono la sessione. Oggi il runtime
implementa solo l'esecuzione di file.

L'esempio `examples/garanzie.td` mostra in azione errori, contratti, budget, tracce ed effetti;
il suo sorgente completo e l'output di riferimento sono nelle appendici
[Sorgenti degli esempi](Sorgenti-esempi) e [Catalogo conformance Full](Catalogo-conformance-Full#garanzie_core).

## Riepilogo

- `Err`, `try`/`catch`, `iserr`, `throw` rendono gli errori valori gestibili.
- `requires`/`ensures` sono contratti verificati; `with budget` limita il calcolo; `with trace`
  registra gli eventi; `!io`/`!state` dichiarano gli effetti.
- `for`, range, comprehension e destrutturazione sono comodità di Full.
- `SPEC.md` §14 definisce CLI e REPL; oggi si esegue solo un file.

## Esercizi

1. Scrivi `radice_intera(n)` con un `requires n >= 0` e un `ensures` che verifichi il risultato.
2. Usa `with budget` per proteggere una ricerca `solve` su regole ricorsive.
3. Traduci in Core l'esempio di destrutturazione `for (k, v) in …` del paragrafo 17.6.
<!-- nav -->

---

← [Capitolo 16 — Codice come dato e macro](Libro-16-Codice-come-dato) · [Sommario](Home) · [Capitolo 18 — Anatomia del progetto e contratto di conformità](Libro-18-Anatomia-e-conformance) →
