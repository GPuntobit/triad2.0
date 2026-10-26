# Triad per LLM — benchmark di generazione e verifica

Questa directory contiene un kit minimo per far generare codice **Triad** a un
modello linguistico e verificarlo in modo oggettivo con la conformance.

L'idea: il modello riceve `SYSTEM_PROMPT.md` e un `task.md`, restituisce un
programma Triad; il programma viene salvato come `solution.triad` e `verify.jl`
lo esegue con lo stage0, confrontando stdout ed exit code con i golden.

> Strumento di sviluppo: non fa parte della catena S0→S4. La conformance
> ufficiale resta `conformance/`; qui si misura la qualità della generazione.

## Struttura

```
ai/
  README.md           questo file
  SYSTEM_PROMPT.md    prompt di sistema per il modello
  verify.jl           esecutore/verificatore delle soluzioni
  tasks/
    01_somma/
      task.md         richiesta in linguaggio naturale
      expected.out    stdout atteso (golden)
      expected.code   exit code atteso (default 0)
      solution.triad  codice generato (non committato)
    ...
```

## Flusso di lavoro

1. Fornisci al modello `SYSTEM_PROMPT.md` + il `task.md` del caso.
2. Il modello deve restituire **solo** un blocco di codice Triad.
3. Salva il contenuto in `ai/tasks/<caso>/solution.triad`.
4. Verifica:

```sh
node cli/triad-cli.mjs ai verify
```

Output: `PASS`/`FAIL` per caso, riepilogo, exit 1 se almeno una soluzione
fallisce. Le soluzioni mancanti sono `SKIP` (non falliscono la verifica).

Per un singolo caso:

```sh
node cli/triad-cli.mjs ai verify --tasks ai/tasks/01_somma
```

## Metriche

- **pass@1**: una generazione per task, tutte verdi.
- **pass@k**: k tentativi per task, conta il primo riuscito.
- **errore di sintassi / runtime / output**: classifica i FAIL per capire se
  manca specifica, esempi o tooling.

Un modello che passa i 5 task dimostra di conoscere il sottoinsieme Triad-Core
usato qui; non dimostra la conoscenza del linguaggio completo.

## Task inclusi

| task | copre |
|---|---|
| `01_somma` | `println`, precedenza, interi |
| `02_fattoriale` | funzioni, ricorsione, ternario |
| `03_fibonacci` | ricorsione doppia |
| `04_stringhe` | stringhe, concatenazione `*`, `length` |
| `05_chiusure` | funzione che restituisce una lambda con cattura |

## Sicurezza

`verify.jl` **esegue** codice generato dal modello. I task usano il profilo
Triad-Core e non dovrebbero contenere effetti, ma un modello può generare loop
infiniti o codice inatteso: esegui la verifica in una VM/container, senza rete e
con risorse limitate. Non incollare output non verificato in produzione.

## Limiti attuali

- Il seed copre 26/29 casi Core; il verificatore usa il **seed**, che
  è più completo del seed.
- Mancano liste e `elseif` completi; `string()` copre Int e String: i task evitano queste feature.
- Il `.triad` è l'estensione canonica; `.td` resta accettato come alias.
