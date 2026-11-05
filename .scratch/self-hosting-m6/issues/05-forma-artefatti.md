# 05 — Forma degli artefatti compilati

Type: grilling
Status: open

## Question

Il compilatore emette codice macchina e nessun linker, compilatore o runtime esterno è
ammesso nel percorso (destinazione): gli artefatti sono quindi **eseguibili PE/ELF statici
emessi direttamente**, nella stessa forma dei seed attuali (formato eseguibile + `os_*` +
fixup). Da decidere:

- l'unità dell'artefatto: un eseguibile per sorgente (S1, compilatore, …) o una toolchain
  monolitica?
- i binari compilati **si committano** come `seed.hex` (con anti-drift `cmp` in CI e
  riproducibilità del dump) o si ricostruiscono sempre dalla catena?
- la parità PE/ELF degli artefatti: stessa forma del «Parità byte-a-byte» già definito per
  i seed (stessi programmi → stessi byte su stdout e stessi exit code)?

Dipende dal linguaggio scelto in *Linguaggio sorgente del compilatore S2* e informa
l'architettura del codegen e il destino della toolchain.

## Riferimenti

- Dipende da: [04 — Linguaggio sorgente del compilatore S2](04-linguaggio-sorgente-s2.md).
- Informa: [06 — Architettura codegen del compilatore nativo](06-architettura-codegen-compilatore.md), [08 — Certificazione del punto fisso: meccanica e CI](08-certificazione-punto-fisso-ci.md), [09 — Toolchain e launcher alla destinazione](09-toolchain-alla-destinazione.md).
- Politica dei byte / riproducibilità del dump ([01 — Politica dei byte del PE nella rifattorizzazione](../../seed-linux-nativo/issues/01-byte-pe.md)).
