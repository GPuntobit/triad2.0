# Capitolo 13 — Progetto: un piccolo interprete

La parte seconda si chiude con un progetto che mette insieme tutto ciò che abbiamo visto:
funzioni, ricorsione, liste, stringhe e byte. Costruiremo, in Triad-Core, un valutatore di
espressioni aritmetiche come `12+x*3`, con variabili e precedenza degli operatori. È una versione
in miniatura di ciò che l'interprete self-hosted S1 dovrà fare per tutto Triad, e attraversa le
stesse due fasi: **analisi lessicale** (dal testo ai token) e **analisi sintattica con
valutazione** (dai token al valore).

## 13.1 Il problema

Vogliamo una funzione `valuta(testo, ambiente)` tale che `valuta("12+x*3", ["x", 10])` restituisca
`42`. Le regole: numeri interi, nomi di variabili fatti di lettere minuscole, gli operatori `+`
e `*`, con `*` che lega più forte di `+`. L'ambiente è una tabella piatta `[nome, valore, …]`
come quelle del capitolo 10.

## 13.2 Prima fase: il tokenizer

Il tokenizer scorre la stringa byte per byte e produce una lista di token. Ogni token è una
coppia `[tipo, testo]`, con tipo `:num`, `:id` oppure `:op`. L'idea è semplice: guardando il byte
corrente si capisce che genere di token inizia; poi si avanza finché il token continua.

```julia
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
        elseif b == 32
            i += 1
        else
            push!(toks, [:op, strsub(s, i, i)])
            i += 1
        end
    end
    toks
end
println(tokenizza("12 + x*3"))
```

Output:

```text
[[:num, 12], [:op, +], [:id, x], [:op, *], [:num, 3]]
```

Si noti la struttura a due indici: `i` segna l'inizio del token, `j` avanza finché il token
continua; alla fine `strsub(s, i, j - 1)` ritaglia il testo e `i = j` riparte dal byte
successivo. Gli spazi vengono semplicemente saltati. Nella stampa, `12` e `x` appaiono senza
virgolette perché sono stringhe dentro una lista (capitolo 5).

## 13.3 Seconda fase: la discesa ricorsiva

Per valutare i token rispettando la precedenza useremo la tecnica più classica, la **discesa
ricorsiva**: una funzione per ogni livello di precedenza, dalla più debole alla più forte, ognuna
delle quali chiama quella del livello successivo.

- `somma` gestisce una sequenza di prodotti separati da `+`;
- `prodotto` gestisce una sequenza di primari separati da `*`;
- `primario` gestisce un singolo numero o una variabile.

Poiché `*` è gestito "più in basso" di `+`, in `12+x*3` il prodotto `x*3` viene calcolato prima di
essere sommato a `12`: la precedenza emerge dalla struttura delle chiamate, senza tabelle.

Resta un problema pratico: le tre funzioni devono condividere la **posizione corrente** nella
lista dei token, e ognuna deve poterla far avanzare. Una variabile globale non funzionerebbe,
perché (capitolo 9) le funzioni nominate non possono riassegnarla. La soluzione è una lista di un
solo elemento, `pos = [1]`, passata a tutte: modificare `pos[1]` cambia il contenuto della lista
condivisa.

```julia
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
        elseif b == 32
            i += 1
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
    t[1] == :num ? Int(t[2]) : cerca(env, t[2])
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
println(valuta("12 + x*3", ["x", 10]))
println(valuta("2*3 + 4*5", []))
println(valuta("larghezza * altezza + 1", ["larghezza", 6, "altezza", 7]))
```

Output:

```text
42
26
43
```

Seguiamo `valuta("2*3 + 4*5", [])`. `somma` chiama `prodotto`, che chiama `primario` e ottiene 2;
vede `*`, avanza, ottiene 3 e calcola 6; il token successivo è `+`, non `*`, quindi `prodotto`
restituisce 6. `somma` vede `+`, avanza e chiama di nuovo `prodotto`, che calcola 20. Il
risultato è 26.

## 13.4 Che cosa manca, e dove porta

Il nostro valutatore è volutamente piccolo. Per farlo crescere verso un vero interprete
bisognerebbe aggiungere, nell'ordine:

1. **sottrazione e parentesi**: un nuovo caso in `primario` per `(`, che richiama `somma`
   ricorsivamente e poi consuma `)`;
2. **controllo degli errori**: token inattesi, parentesi non chiuse, variabili sconosciute,
   restituendo valori `[:Err, …]` come nel capitolo 12;
3. **un albero sintattico**: invece di calcolare subito, le funzioni costruiscono nodi (liste
   etichettate come `[:somma, sinistro, destro]`) che un valutatore separato percorre; è la
   struttura che permette di aggiungere istruzioni, funzioni e cicli;
4. **istruzioni e ambienti**: assegnamenti, blocchi, funzioni con il loro ambiente di chiusura.

È esattamente il percorso descritto dalle task S1 in `TASK.md` e avviato nei file di
`selfhost/`, che vedremo nel capitolo 21. Chi arriva fin qui ha già in mano tutti gli strumenti
per contribuirvi.

## Riepilogo

- Un interprete lavora in due fasi: tokenizzazione e analisi con valutazione.
- Il tokenizer usa due indici e i primitivi `strbyte`/`strsub`.
- La discesa ricorsiva codifica la precedenza nella struttura delle chiamate.
- Uno stato condiviso tra funzioni nominate si tiene in una lista (`pos = [1]`).

## Esercizi

1. Aggiungi la sottrazione con la stessa precedenza di `+`.
2. Aggiungi le parentesi, come descritto al punto 1 del paragrafo 13.4.
3. Fai in modo che una variabile sconosciuta produca un errore `[:Err, :undef, nome]` invece di
   valere 0, e propagalo fino a `valuta`.
<!-- nav -->

---

← [Capitolo 12 — Quando le cose vanno storte](Libro-12-Errori-e-runtime) · [Sommario](Home) · [Capitolo 14 — Tipi, struct e multiple dispatch](Libro-14-Tipi-e-dispatch) →
