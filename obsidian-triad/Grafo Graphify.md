# Grafo Graphify

## Snapshot

- Repository: [GPuntobit/triad2.0](https://github.com/GPuntobit/triad2.0), ramo `main`.
- Commit indicizzato: `929a9269ef08d07088d65217f269c5aeafabd62a`.
- Indicizzazione: 25 ottobre 2026, 16:19 UTC.
- Statistiche globali Graphify: **3.197 nodi**, **7.794 relazioni**, **206 comunità**.

Graphify descrive lo snapshot indicato, che potrebbe non coincidere con lo stato corrente del checkout.

## File letti tramite Graphify

| File sorgente | Nodi/simboli riportati per il file | Pagina |
|---|---:|---|
| [`triad.jl`](../triad.jl) | 124 | [[File - triad.jl]] |
| [`ai/verify.jl`](../ai/verify.jl) | 6 (5 definizioni elencate nella risposta) | [[File - ai verify.jl]] |
| [`ai/jev_audit.mjs`](../ai/jev_audit.mjs) | 20 | [[File - ai jev_audit.mjs]] |
| [KarpathyWiki `main.js`](./.obsidian/plugins/karpathywiki/main.js) | 2.161 | [[File - KarpathyWiki main.js]] |
| [Templater `main.js`](./.obsidian/plugins/templater-obsidian/main.js) | 323 | [[File - Templater main.js]] |

Le pagine riportano link ai sorgenti e le chiamate/caller che Graphify ha restituito per le definizioni consultate. Per navigare: [[Indice]].

## Limite di copertura

Le statistiche globali contano nodi e relazioni, non file. Gli strumenti Graphify disponibili in questa sessione forniscono ricerca semantica e vicinati per file, ma non un’esportazione enumerabile/paginata di tutti i nodi o di tutti i percorsi sorgente. Di conseguenza, i cinque file sopra sono **tutti quelli individuati e letti durante questa esportazione**, ma non è possibile attestare che esauriscano i percorsi rappresentati nei 3.197 nodi. Non considero i risultati di una ricerca semantica come un dump completo del grafo.

Inoltre, i due file dei plugin sono bundle JavaScript molto grandi: Graphify associa loro migliaia di simboli, inclusi componenti incorporati. Qui sono indicati i conteggi e i punti d’ingresso utili, non sono state replicate nel vault le definizioni di ogni simbolo del bundle.

Graphify non ha restituito archi espliciti di import/export tra i file interrogati. Le chiamate riportate nelle pagine sono invece gli archi `calls` risolti o i riferimenti osservati nelle definizioni restituite.
