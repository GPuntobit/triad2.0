# 01 — Politica dei byte del PE nella rifattorizzazione

Type: grilling
Status: open

## Question

N16 (`TASK.md`) rifattorizza `gen_seed.js` isolando le chiamate di sistema in `os_*`, con
acceptance «il PE rigenerato deve restare byte-identico a quello versionato; se così non
fosse: nuovo hash in CI e diff tracciata». Quale politica rendiamo vincolante?

- (a) **Byte-identico obbligatorio**: il PE versionato non cambia in questa fase; ogni
  diff nei byte blocca la rifattorizzazione. Vincolo forte sull'architettura del codegen.
- (b) **Byte-identico come regola, con eccezione tracciata**: se il refactoring rende il
  dump inevitabilmente diverso (stessa semantica, disposizione diversa), si accetta un
  nuovo `seed.hex` con nuovo hash in CI e diff documentata.

La risposta vincola [02 — Architettura del codegen per due piattaforme](02-architettura-codegen.md):
la scelta fra generatore unico e doppio emettitore pesa diversamente a seconda di
quanto è stretto questo vincolo.

## Comments
