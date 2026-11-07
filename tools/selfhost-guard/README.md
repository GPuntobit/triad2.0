# Guardie statiche sulla sorgente di S1

Il **guard** presidia il *sottoinsieme certificato* del seed: l'insieme dei programmi
Triad-Core che il seed esegue con la semantica di `SPEC-CORE.md`.

Il seed non è un'implementazione Core completa: esegue il **front-end di S1**, non i
programmi degli utenti. Le sue divergenze dal comportamento della specifica filtrano
quindi nel *comportamento del codice di S1*, non nei risultati di conformance. Per questo
la sorgente di S1 viene vincolata da due presidî complementari:

| presidio | domanda a cui risponde | strumento |
|---|---|---|
| **guardia statica** | «questo costrutto il seed lo rifiuta o lo esegue diversamente?» | `guard.mjs` |
| **gate differenziale** | «questo programma dà lo stesso risultato sui due runtime?» | `differential.mjs` |

## I pezzi

| file | ruolo |
|---|---|
| `../selfhost-guard/guard.mjs` | CLI: applica le regole ai file del corpus, exit 1 se ci sono errori |
| `rules.mjs` | le regole: una per divergenza del seed, ciascuna con il suo id (`G-D01`, …) |
| `analysis.mjs` | analisi degli ambienti (scope) sull'AST del riferimento JS |
| `scan.mjs` | scanner grezzo del sorgente (escape, keyword cieche, fine riga) |
| `contract.mjs` | lettore del contratto del seed |
| `differential.mjs` | gate differenziale seed ↔ riferimento JS sul corpus certificato |
| `test.mjs` | self-test: un fixture per regola + il corpus pulito |
| `fixtures/` | i fixture (uno per regola) e `pulito.td` |
| `../../seed/dev/certified-subset.txt` | il **contratto** del seed (fatti, macchina-leggibile) |
| `../../seed/dev/certified-corpus.txt` | il **corpus certificato** (i programmi che il seed deve eseguire) |

## Il contratto guida le regole

Ogni regola è legata a una divergenza del seed (`G-D01` → `D1`, …) ed è **attiva solo se
la divergenza è ancora presente nel contratto**. Quando il seed viene corretto (un gap
chiuso nel ciclo di rebuild), la divergenza sparisce da `certified-subset.txt` e la regola
si spegne da sola: nessun codice da toccare, nessuna regola da ricordare.

Le divergenze che il contratto dichiara assenti sono anche le regole «spente»: se il
contratto non le elenca, il guard non segnala nulla.

## Corpus certificato e file fuori contratto

`seed/dev/certified-corpus.txt` elenca i programmi che il seed deve poter eseguire: il
front-end di S1 (`selfhost/`), lo smoke test e i generatori del sito (`tools/site-gen/`,
che `build.mjs` confronta gia' sui due runtime). Gli altri file `.td` (prototipi storici
in `selfhost/`, la prima versione del generatore) restano validi — la CI li esegue sul
riferimento JS — ma sono **fuori contratto**: le violazioni su quei file sono segnalate come
avvisi e non falliscono il gate. Aggiungere un file al manifesto è un atto deliberato.

## Uso

```sh
node tools/selfhost-guard/guard.mjs            # corpus certificato + selfhost/ (fuori contratto)
node tools/selfhost-guard/guard.mjs file.td    # un file (considerato certificato)
node tools/selfhost-guard/guard.mjs --list     # l'elenco delle regole
node tools/selfhost-guard/test.mjs             # self-test (un fixture per regola)
node tools/selfhost-guard/differential.mjs     # gate differenziale seed <-> JS
```

## Perché due guardie e non una

Una regola statica può decidere solo ciò che si vede **nell'AST**: la presenza di un
costrutto, il nome di una variabile, la forma di una condizione. Non può decidere ciò che
dipende dai **tipi a runtime** (per esempio `string(x)` quando `x` è un `Bool`: il seed
stampa `1` invece di `true`). Per quelle divergenze il presidio è il gate differenziale:
stesso programma, stesso stdout byte per byte, stesso exit code sui due runtime.

Se il gate differenziale trova una differenza, la risposta è **una sola**: correggere il
seed (è il gate di esecuzione: se il seed mente, mente tutto). Questo è il *criterio di
non presidabilità* della decisione 01 della mappa M6: «silenziosa + non decidibile
staticamente ⇒ chirurgia nel seed».

Il guard e il gate differenziale sono **strumenti di sviluppo** (Node): stanno fuori dalla
catena S0→S4, come il riferimento JS. `verify.sh` resta senza Node.
