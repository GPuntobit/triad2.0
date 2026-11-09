# site-gen — il sito di Triad generato da Triad

Questa cartella contiene il **generatore del sito**: il sito statico in `docs/`
(prodotto da programmi Triad) è ricostruito da zero a partire da programmi
scritti nel linguaggio Triad stesso.

```
tools/site-gen/
  site_pages.td        # genera le pagine di documentazione
  site_pages2.td       # genera le pagine rimanenti (apprendimento, AI, licenza)
  site_playground.td   # genera la pagina del playground (interattiva nel browser)
  site_style.td        # genera il foglio di stile del sito
  build.mjs            # driver: esegue i generatori, confronta i runtime, scrive i file
  lint.mjs             # controlla che i generatori restino nel sottoinsieme certificato
  generate_site_core.td# prima versione del generatore (una sola pagina): conservata per i
                       #   riferimenti storici in CHANGELOG e release notes; non gira sul
                       #   seed nativo (usa print e gli escape) e non è più il riferimento
```

## Costruire il sito

```sh
node tools/site-gen/build.mjs           # genera e scrive i file in docs/
node tools/site-gen/build.mjs --check   # verifica: i file su disco coincidono col generato
node tools/site-gen/build.mjs --dry     # esegue e confronta i due runtime, non scrive
node tools/site-gen/lint.mjs            # controlla il sorgente Triad dei generatori attivi
```

Il lint controlla per default i generatori attivi (`site_*.td`); un altro file `.td` della
cartella si controlla passandolo esplicitamente (`node tools/site-gen/lint.mjs
generate_site_core.td`).

Un generatore si può eseguire anche da solo, con il runtime Triad:

```sh
seed\windows-x86_64\seed.exe tools\site-gen\site_pages.td    # Windows: seed nativo
node seed/dev/triad_core.cjs tools/site-gen/site_pages.td    # interprete di riferimento
bin\triad.cmd tools\site-gen\site_pages.td                   # launcher del repository
```

Il launcher sceglie il runtime: il seed in codice macchina quando è utilizzabile,
l'interprete di riferimento altrimenti. Per il sito la differenza non conta: i
due runtime devono dare lo stesso output.

## Il protocollo del bundle

Il Core non ha I/O su file: un programma Triad scrive su **stdout**. Ogni
generatore stampa quindi un *bundle* testuale, e `build.mjs` fa da splitter:

```
=== FILE: docs/pages/spec.html ===
<!DOCTYPE html>
<html lang='en'>
...
```

Ogni riga del file è un `println` separato (nel Core gli escape `\n` non
esistono). Il driver rifiuta i bundle senza marcatore e i percorsi fuori dal
repository.

## Il criterio di accettazione: due runtime, stesso output

`build.mjs` esegue ogni generatore **su due runtime**:

1. il **seed in codice macchina** (`seed/windows-x86_64/seed.exe`), che è il
   runtime di default di `bin/triad` su Windows;
2. l'**interprete di riferimento** in JavaScript (`seed/dev/triad_core.cjs`),
   che è il runtime con cui la suite di conformance viene eseguita su Linux.

Il build fallisce se i due non producono **stdout identico byte per byte** e lo
stesso exit code. È il motivo per cui il sito è scritto in un sottoinsieme
stretto di Triad-Core: il generatore deve essere eseguibile dal seed, non solo
dall'interprete comodo.

## Il sottoinsieme certificato

I limiti del seed sono **misurati**, non dedotti: la matrice è in
`tests/probes/` (vedi `tests/probes/README.md`) e si riesgue con
`node tests/probes/run_probes.mjs`.

Funziona su entrambi i runtime:

- `println(<una sola espressione>)`;
- `let <nome> = <expr>` … `end` con un solo binding;
- `if`/`elseif`/`else`, `while`, ternario `? :`;
- funzioni in forma breve `f(x) = e` e a blocco `function f(x) … end`, con il
  valore dell'ultima espressione;
- concatenazione di stringhe con `*`, `string(<Int>)`, `length("...")`;
- ricorsione, se il corpo segue il pattern "assegna a una variabile, poi
  restituisci la variabile".

Non funziona sul seed (e il lint lo segnala):

| Costrutto | Errore |
|---|---|
| `print(...)`, `println` con più argomenti | `E020` |
| `return` in una funzione a blocco | `E021` |
| `readfile`, `strlen`, `strbyte`, `strsub`, `ARGS` | `E022` |
| escape `\n`, `\"`, `\\` nelle stringhe | `E011` |
| `let` con più binding | `E030` |
| `==` fra stringhe | `E023` |
| chiamata come ultima espressione del corpo | `W023` |
| `+=` su stringhe | `W024` |

Due conseguenze pratiche per chi scrive un generatore:

1. **Ogni riga generata è un `println`.** Gli escape non esistono: una riga con
   un `\n` dentro viene stampata con i due caratteri.
2. **Gli attributi HTML si scrivono con apici singoli** (`href='spec.html'`):
   l'escape `\"` non è supportato.

> **Aggiornato il 2026-11-09:** la regola `E010` (letterale con `if` dentro un
> blocco) è stata rimossa: il seed riconosce le parole chiave come token
> esatti e salta il testo di un letterale quando scandisce la fine di un
> blocco, quindi un letterale può contenere `if` anche dentro un blocco.

## I file generati

| File | Contenuto |
|---|---|
| `docs/pages/getting-started.html` | installazione, CLI, primi programmi |
| `docs/pages/language-tour.html` | i tre paradigmi e le funzionalità del linguaggio |
| `docs/pages/spec.html` | `SPEC.md` 0.2.0 e come si legge |
| `docs/pages/tutorial.html` | percorso di apprendimento |
| `docs/pages/apprendimento.html` | curva di apprendimento e soglia Triad-Core / Triad-Full |
| `docs/pages/conformance.html` | la suite golden e come eseguirla |
| `docs/pages/bootstrap.html` | il piano S0→S4 del bootstrap |
| `docs/pages/editors.html` | VS Code, Vim/Neovim, Linguist |
| `docs/pages/ai.html` | il benchmark di generazione di codice Triad |
| `docs/pages/license.html` | la licenza MIT del progetto |
| `docs/pages/status.html` | stato corrente e roadmap |
| `docs/pages/playground.html` | il playground: Triad nel browser |
| `docs/assets/css/triad-generated.css` | stili del layout documentale e del playground |

Le pagine sono generate, ma non sostituiscono il sito già pubblicato: i
sorgenti a mano restano in `docs/` e i file generati convivono con essi.
`docs/pages/generated.html` è l'output della prima versione del generatore: non è
più rigenerata (il prototipo non gira sul seed nativo) e resta per i riferimenti
storici; non è nel menu del sito.

## Agenti che aiutano a costruire il sito

Il lavoro è suddiviso fra tre ruoli (sotto-agenti del runtime):

- `triad-web-builder` — scrive i programmi Triad che generano il sito;
- `triad-web-ui` — cura il layer browser: pagine, stile, glue del runtime;
- `triad-verifier` — verifica in modo indipendente: esecuzione, conformance,
  output identico sui due runtime, smoke test della pagina.

Tutti e tre hanno nel loro prompt il sottoinsieme certificato qui sopra.
