# Capitolo 22 — Gli strumenti di sviluppo

L'ultimo capitolo passa in rassegna gli strumenti che accompagnano il lavoro sul progetto.

## 22.1 `triad-cli`

La CLI di sviluppo riunisce i comandi più usati: `status` (ambiente e seed trovato),
`test conformance` (la suite Core), `ai verify` (il benchmark AI), `seed generate windows|linux`
(rigenera il dump e ne stampa l'impronta). Si avvia con `node cli/triad-cli.mjs` dopo
`npm install` in `cli/`, con i launcher `bin/triad-cli` e `bin\triad-cli.cmd`, o con l'eseguibile
standalone allegato alle release. Il codice è in `cli/triad-cli.mjs` (comandi definiti con
`commander`) e `cli/lib/commands/*.mjs` (un modulo per gruppo di comandi; ogni handler
restituisce un booleano che diventa il codice di uscita).

## 22.2 Il benchmark AI

`ai/` misura quanto bene un modello linguistico scrive Triad-Core: `SYSTEM_PROMPT.md` descrive il
sottoinsieme ammesso, ogni cartella di `ai/tasks/` contiene una richiesta, l'output atteso e una
soluzione di riferimento, e `triad-cli ai verify` esegue le soluzioni confrontandole con i golden.

## 22.3 Editor e sito

`editors/` contiene la grammatica TextMate per VS Code, la sintassi per Vim e Neovim e la voce
per GitHub Linguist. Il sito in `docs/` è pubblicato su GitHub Pages e carica i Markdown del
repository, compreso `TUTORIAL.md`.

## 22.4 Integrazione continua

`.github/workflows/ci.yml` esegue a ogni push tre job: `conformance-core` (la suite Core con
l'interprete di riferimento su Ubuntu), `seed-windows` (33 casi Core sul seed, il probe
`test_get.td`, lo smoke test di `selfhost/main.td`, l'impronta di `seed.hex`) e `seed-linux`
(l'ELF E0 e la sua impronta). Il profilo Full non è in CI, perché non è ancora implementato.

## 22.5 Contribuire

La regola che riassume il libro: lo standard viene prima. Una modifica al linguaggio passa da
`SPEC.md` o `SPEC-CORE.md`, da `CHANGELOG.md` e da un caso di conformità; solo dopo dalle
implementazioni. E una dichiarazione vale quanto la verifica che la sostiene.

## Riepilogo

- `triad-cli` raccoglie test, verifica AI e generazione del seed.
- `ai/`, `editors/` e `docs/` completano l'ecosistema.
- La CI verifica Core, il seed Windows e il seed Linux.
<!-- nav -->

---

← [Capitolo 21 — Verso il self-hosting](Libro-21-Self-hosting) · [Sommario](Home) · [Appendici](Home#appendici) →
