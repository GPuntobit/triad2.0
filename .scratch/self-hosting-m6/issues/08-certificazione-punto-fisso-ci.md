# 08 — Certificazione del punto fisso: meccanica e CI

Type: grilling
Status: open
Blocked by: 06, 07, 10

## Question

Il criterio è già deciso (destinazione della mappa): **definizione** = il compilatore
nativo ricompila la propria sorgente producendo un binario identico byte-a-byte al proprio;
**gate** = intera conformance (Core + Full) verde su tutti gli artefatti. Qui si decide la
*meccanica*:

- la sequenza di certificazione: generazione 0 ottenuta col seed che interpreta S1 →
  compilatore nativo → autoriconpilazione → confronto `cmp`;
- dove gira: cosa in CI su runner Linux, cosa tocca al lato PE deciso in *Certificazione
  del lato PE degli artefatti compilati*;
- l'anti-drift: `cmp` fra binari ricostruiti e binari committati (se si committano),
  estensione del meccanismo già usato per `seed.hex`;
- frequenza e costo: ogni commit, ogni PR, notturno?

## Riferimenti

- Preliminari: [06 — Architettura codegen del compilatore nativo](06-architettura-codegen-compilatore.md), [07 — Certificazione del lato PE degli artefatti compilati](07-certificazione-pe.md), [10 — Ricerca: punto fisso e root del bootstrap in catene self-hosted note](10-ricerca-punto-fisso-root.md).
- Dipende in parte da: [05 — Forma degli artefatti compilati](05-forma-artefatti.md) (binari committati o no).
- Collegato: [09 — Toolchain e launcher alla destinazione](09-toolchain-alla-destinazione.md).
