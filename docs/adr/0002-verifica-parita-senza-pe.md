# La verifica di parità non riesegue mai il PE

**Status:** accepted (2026-11-04)

La parità PE/ELF si verifica esclusivamente su **ambiente Linux nativo**: la CI non
contiene gambe Windows (job `seed-windows` e matrice `site-gen` rimossi) né Wine. Il lato
PE è garantito da due registri congelati: l'**hash di `seed.hex`** (immutabilità dei byte,
ADR 0001) e i **golden** delle suite come registro del suo comportamento. L'ELF è
verificato byte-exatto contro gli stessi golden; il PE non viene emulato né rieseguito.
Decisione completa, con gate e ordine di verità:
`.scratch/seed-linux-nativo/issues/04-parita-suite-ci.md`.

## Perché

- La destinazione dello sforzo è zero dipendenze esterne su Linux (niente Wine, niente
  Node per l'esecuzione): una verifica che richiede un runner Windows o Wine introdurrebbe
  la dipendenza che l'uso non ha.
- Con l'immutabilità del PE (ADR 0001) il comportamento del PE è congelato per
  costruzione: rieseguirlo è ridondante finché i byte non cambiano.
- Nei cambi semantici deliberati (ciclo N03–N05) i golden si rigenerano da
  `SPEC-CORE.md` — primo nell'ordine di verità `SPEC-CORE.md` > PE > ELF — non da una
  riesecuzione del PE.

## Alternative scartate

- **Runner `windows-latest` per il lato PE** (lo status quo alla data della decisione):
  reso disponibile gratuitamente dalla CI, ma tiene la verifica legata a una piattaforma
  che il percorso d'uso su Linux non ha.
- **Wine per eseguire il PE su Linux**: emulazione, vietata dalla destinazione («nessuna
  delle due piattaforme emula l'altra») e dipendenza esterna.
- **Confronto diretto PE↔ELF via artefatti di output scambiati fra job**: accoppia i job
  di CI senza guadagno rispetto ai golden condivisi.

## Conseguenza

La garanzia «stdout byte-identico al PE» diventa «byte-identico al comportamento PE
*registrato nei golden*»: la rigenerazione dei golden nei cambi deliberati è un atto
documentato che attinge a `SPEC-CORE.md`, e la riesecuzione manuale del PE su una macchina
Windows resta verifica una tantum opzionale, mai meccanismo del gate. Il termine
*Parità byte-a-byte* in `GLOSSARY.md` delimita cosa è dentro (byte su stdout, exit code) e
cosa è fuori (messaggi d'errore).
