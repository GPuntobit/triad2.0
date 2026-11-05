# 07 — Certificazione del lato PE degli artefatti compilati

Type: grilling
Status: open

## Question

La decisione _Parità: suite di riferimento, CI e politica delle divergenze_ della mappa
_Seed Linux nativo senza Wine_ ha **rimosso le gambe Windows dalla CI**: lato PE garantito
da hash `seed.hex` + golden congelati. Ma alla destinazione M6 gli eseguibili PE sono
**nuovi** — nessuno hash storico, nessun golden congelato — e il percorso zero-install
vieta Wine per verificarli da Linux. Come si certifica il lato PE (punto fisso incluso)?

- **(a) runner Windows nella CI**, dedicato alla certificazione (le gambe tornano, per un
  compito solo);
- **(b) certificazione manuale una tantum** su macchina Windows + fiducia strutturale
  (parità degli output, golden condivisi) dopo;
- **(c) certificazione solo al release**: il PE si congela con hash e golden come per il
  seed, verificato offline su Windows.

La risposta fissa dove gira il gate di parità e cosa conta come «PE verificato».

## Riferimenti

- Politica ridecisa parzialmente: [04 — Parità: suite di riferimento, CI e politica delle divergenze](../../seed-linux-nativo/issues/04-parita-suite-ci.md) (gambe Windows rimosse dalla CI).
- Collegato: [08 — Certificazione del punto fisso: meccanica e CI](08-certificazione-punto-fisso-ci.md).
