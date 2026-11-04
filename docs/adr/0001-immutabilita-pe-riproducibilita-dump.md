# Immutabilità del PE e riproducibilità del dump

**Status:** accepted (2026-11-04)

Durante il lavoro strutturale sul seed (es. la rifattorizzazione `os_*` di TASK.md N16) i
byte del PE versionato (`seed.hex` più `seed.exe`/`seed_decoded.exe`, sua decodifica
esatta) non cambiano: ogni diff nei byte è un bug fino a prova contraria. Un cambio di
layout deliberato è una decisione d'architettura del codegen, non un incidente da
accettare in silenzio; solo i cambi semantici deliberati (il ciclo N03–N05) rigenerano
gli artefatti, con nuovo hash in CI e diff tracciata. Due contratti distinti, entrambi
vincolanti: **riproducibilità del dump** (i generatori rigenerano esattamente gli
artefatti versionati) e **immutabilità del PE** (gli artefatti versionati non cambiano
nel lavoro strutturale). Decisione completa, con procedure ed eccezioni:
`.scratch/seed-linux-nativo/issues/01-byte-pe.md`.

## Perché: il drift di 1705 byte (commit `649709a`)

Il 2026-10-31 il commit CodeQL `649709a` corresse `testRcx;` → `testRcx()` in `pf_call`
di `seed/dev/gen_seed.js`: il riferimento senza effetto ometteva il `test rcx,rcx` che
protegge il cap check delle chiusure. Il fix toccò solo il generatore: gli artefatti
versionati — che *contenevano* il bug — non furono rigenerati. Il PE shippato e il
generatore raccontarono due storie diverse e nessun test se ne accorse. Il rebuild di N01
(2026-11-02) scoprì il drift: **1705 byte** diversi sul binario di 25088, tutti
spiegabili da un'unica inserzione di 3 byte (`48 85 c9`, `test rcx,rcx`) in `pf_call`
(offset `0x1c8b`) e dai displacement ±3 ricalcolati — primo effetto visibile a `0x22f`,
in un salto la cui destinazione giace a valle dell'inserzione.

Archivio verificato byte-per-byte il 2026-11-04 rigenerando dai tre generatori storici:
`gen_seed.js` di `649709a^` riproduce esattamente il PE versionato all'epoca; quello di
`649709a` no (1705 byte di differenza); quello odierno riproduce `seed.hex`
(SHA-256 `4235A70790BAA6784DC3D944616705B37E76ED2263CE73210BCC20E53639B8F7`).

## Conseguenza

Il gate hash della CI protegge l'**immutabilità** (rileva cambi in `seed.hex`) ma non la
**riproducibilità**: un cambiamento al generatore senza rebuild passa silenzioso, come in
`649709a`. Un controllo `node seed/dev/gen_seed.js && cmp` in CI chiuderebbe questa
lacuna: materia del ticket
`.scratch/seed-linux-nativo/issues/04-parita-suite-ci.md`.
