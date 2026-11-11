# Capitolo 11 — Stringhe, simboli e byte

Le stringhe sono il materiale con cui lavora chiunque scriva un interprete: un programma
sorgente, prima di essere analizzato, è una stringa. Per questo Triad-Core, pur essendo
minimale, dedica alle stringhe un piccolo insieme di strumenti, compresi alcuni primitivi pensati
apposta per il bootstrap. Questo capitolo li presenta, insieme alle conversioni tra stringhe,
numeri e simboli.

## 11.1 Che cos'è una stringa in Triad

Una stringa è una sequenza **immutabile di byte**, codificata in UTF-8. Due conseguenze vanno
tenute a mente fin da subito.

La prima: le operazioni non modificano una stringa, ne producono una nuova. `s * "!"` non
cambia `s`; restituisce una stringa diversa.

La seconda: la lunghezza si misura in **byte**, non in caratteri. Le lettere dell'alfabeto
inglese occupano un byte, ma una lettera accentata come `è` ne occupa due:

```julia
println(length("ciao"), " ", length("perché"))
```

Output:

```text
4 7
```

Per la maggior parte dei programmi la differenza non si vede; per un tokenizer, che lavora byte
per byte, è fondamentale.

## 11.2 Concatenare e convertire

`*` unisce due stringhe; `string(v)` trasforma in stringa un valore qualsiasi, con le stesse
regole di stampa di `println`. Insieme sono il modo di comporre testo in Core:

```julia
n = 3
messaggio = "hai " * string(n) * " messaggi" * (n > 1 ? "" : "o")
println(messaggio)
println(string(:ok) * "/" * string(true) * "/" * string([1, :a]))
```

Output:

```text
hai 3 messaggi
ok/true/[1, :a]
```

Le conversioni inverse sono `Int(s)`, che interpreta una stringa come numero decimale, e
`Symbol(s)`, che trasforma una stringa in simbolo:

```julia
eta = Int("41") + 1
colore = Symbol("rosso")
println(eta, " ", colore == :rosso)
```

Output:

```text
42 true
```

`Int` è il ponte tra il testo e i numeri: è ciò che serve per leggere numeri da `ARGS`, che
contiene sempre stringhe.

## 11.3 Dentro la stringa: i primitivi di bootstrap

Per guardare *dentro* una stringa Core offre tre primitivi, che lo standard classifica come
**primitivi di bootstrap**: esistono per costruire l'implementazione di Triad e non fanno parte
di Triad-Full.

- `strlen(s)` restituisce il numero di byte (come `length` sulle stringhe);
- `strbyte(s, i)` restituisce il byte in posizione `i`, un intero da 0 a 255, contando da 1;
- `strsub(s, a, b)` restituisce la sottostringa dal byte `a` al byte `b` inclusi.

Con questi tre si può fare qualunque analisi di testo. I byte si confrontano con i codici ASCII:
48–57 per le cifre, 65–90 per le maiuscole, 97–122 per le minuscole, 32 per lo spazio, 10 per
l'a capo. Scrivere funzioni con nomi parlanti rende il codice leggibile:

```julia
cifra(b) = b >= 48 && b <= 57
spazio(b) = b == 32
function prima_parola(s)
    fine = 1
    while fine <= strlen(s) && !spazio(strbyte(s, fine))
        fine += 1
    end
    strsub(s, 1, fine - 1)
end
function conta_cifre(s)
    n = 0
    i = 1
    while i <= strlen(s)
        if cifra(strbyte(s, i))
            n += 1
        end
        i += 1
    end
    n
end
testo = "Triad 2.0 ha 37 casi"
println(prima_parola(testo), " / ", conta_cifre(testo))
```

Output:

```text
Triad / 4
```

## 11.4 Da stringa a numero, a mano

`Int` fa già la conversione, ma scriverla a mano è istruttivo, perché è esattamente ciò che fa
un tokenizer quando incontra un numero nel sorgente: ogni cifra vale il suo codice meno 48, e il
valore si accumula moltiplicando per dieci.

```julia
function leggi_intero(s)
    v = 0
    i = 1
    while i <= strlen(s)
        v = v * 10 + strbyte(s, i) - 48
        i += 1
    end
    v
end
println(leggi_intero("2026") + 1)
```

Output:

```text
2027
```

## 11.5 File e uscita

Gli ultimi due primitivi di bootstrap collegano il programma al sistema. `readfile(percorso)`
restituisce l'intero contenuto di un file come stringa; `exit(n)` termina il programma con il
codice di uscita `n`. Insieme ad `ARGS` permettono di scrivere un programma che legge un altro
programma:

```julia
# conta_righe.triad — uso: node seed/dev/triad_core.cjs conta_righe.triad FILE
testo = readfile(ARGS[1])
righe = 0
i = 1
while i <= strlen(testo)
    if strbyte(testo, i) == 10
        righe += 1
    end
    i += 1
end
println(righe)
```

È, in miniatura, il primo passo di un interprete self-hosted: leggere il sorgente e
scandirlo. Il capitolo 13 fa il passo successivo.

## 11.6 Simboli o stringhe?

Una domanda ricorrente è quando usare un simbolo e quando una stringa. La regola pratica: una
**stringa** è testo da mostrare o da analizzare; un **simbolo** è un'etichetta da confrontare.
Il nome di un colore scelto da un insieme fisso, il tipo di un token, l'etichetta di un record
sono simboli; un messaggio per l'utente o il contenuto di un file sono stringhe. Confrontare due
simboli è immediato; confrontare due stringhe richiede di esaminarne i byte.

## Riepilogo

- Le stringhe sono byte UTF-8 immutabili; `length` conta i byte.
- `*` concatena, `string` converte in testo, `Int` e `Symbol` convertono dal testo.
- `strlen`, `strbyte`, `strsub`, `readfile`, `exit` sono primitivi di bootstrap: indispensabili
  per un interprete, esclusi da Triad-Full.
- Simboli per le etichette, stringhe per il testo.

## Esercizi

1. Scrivi `maiuscolo(s)` che converta le lettere minuscole ASCII in maiuscole (suggerimento:
   costruisci il risultato concatenando `strsub` di un carattere o, per le lettere, cerca il
   carattere corrispondente in una stringa `"ABCDEFGHIJKLMNOPQRSTUVWXYZ"`).
2. Scrivi `dividi(s)` che restituisca la lista delle parole separate da spazi.
3. Scrivi un programma che legga un file passato in `ARGS[1]` e stampi quante volte vi compare la
   parola `end`.
<!-- nav -->

---

← [Capitolo 10 — Liste e dati strutturati](Libro-10-Liste) · [Sommario](Home) · [Capitolo 12 — Quando le cose vanno storte](Libro-12-Errori-e-runtime) →
