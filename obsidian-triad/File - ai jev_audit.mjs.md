# `ai/jev_audit.mjs`

File sorgente: [`ai/jev_audit.mjs`](../ai/jev_audit.mjs) · [cartella `ai/`](../ai/)

## Ruolo nel progetto

Script di audit dei file versionati: individua i file, raccoglie fatti di contesto, costruisce lo stato da analizzare e produce un report. Graphify ha riportato 20 simboli.

## Chiamate verificate

La funzione [`sweep()`](../ai/jev_audit.mjs#L281) chiama:

- [`trackedFiles()`](../ai/jev_audit.mjs#L67) per ottenere i file;
- [`knownFacts()`](../ai/jev_audit.mjs#L142) e [`buildState()`](../ai/jev_audit.mjs#L245) per preparare il contesto;
- [`callSystemOne()`](../ai/jev_audit.mjs#L261) per l’analisi;
- [`writeReport()`](../ai/jev_audit.mjs#L334) per il report.

Graphify collega inoltre `sweep()` al punto d’ingresso del file (call site a L448). Le chiamate sopra sono archi `calls` restituiti con risoluzione stretta.

## Collegamenti

- [[Grafo Graphify]]
- [Cartella `ai/`](../ai/)
