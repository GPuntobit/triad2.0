# 04 — Linguaggio sorgente del compilatore S2

Type: grilling
Status: open

## Question

`BOOTSTRAP.md` §1: «S2 compilatore nativo **scritto in Triad** (Triad-Core + capacità già
disponibili)». L'inciso è un'**ambiguità reale** (regola 1: segnalata, non risolta): cosa
sono le «capacità già disponibili»? Il vincolo duro è doppio:

1. la sorgente del compilatore deve **girare sul seed** (è S1 che la esegue per produrre il
   primo compilatore nativo) → deve stare nel dominio che il seed sa eseguire;
2. deve essere **auto-compilabile** (M6: il compilatore compila sé stesso).

Quindi: Triad-Core puro, sottoinsieme Core + primitive di bootstrap (`readfile`, `strlen`,
`strbyte`, `strsub`, `exit`), o Triad-Full? E cosa deve *accettare* in ingresso la prima
generazione — solo la propria sorgente, o tutto Triad-Core? (La compilazione nativa di
programmi utente è foschia di questa mappa, non decide qui.)

## Riferimenti

- Attendono questa risposta: [05 — Forma degli artefatti compilati](05-forma-artefatti.md), [06 — Architettura codegen del compilatore nativo](06-architettura-codegen-compilatore.md).
- Informata da: [10 — Ricerca: punto fisso e root del bootstrap in catene self-hosted note](10-ricerca-punto-fisso-root.md).
- `BOOTSTRAP.md` §1 (S2), §3 (primitive di bootstrap).
