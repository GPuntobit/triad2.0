# 09 — CLI e toolchain senza Node

Type: grilling
Status: open
Blocked by: 07

## Question

(Da [04 — Parità: suite di riferimento, CI e politica delle divergenze](04-parita-suite-ci.md),
round 2 Q3 scelta (c) rettificata in round 3: promosso dalla foglia «`triad-cli` senza
Node», che con questa ticket esce da «Not yet specified» della mappa.)

Con il percorso d'uso chiuso da
[07 — Installazione e launcher: il contratto zero-install](07-installazione-launcher.md),
qual è il contratto della **CLI senza Node**?

- quali sotto-comandi restano (`run`, `test`, `status`, …) e quali restano Node per ora
  (es. `ai verify`, strumento di sviluppo fuori dalla catena S0→S4);
- in cosa sono implementati (shell POSIX + seed nativo) e dove vivono (`cli/`, `bin/`);
- cosa succede a `cli/triad-cli.mjs`: sostituzione, affiancamento o retirement tracciato;
- coerenza col confine zero-install (solo shell POSIX + repo) e con la regola operativa 2
  (Node tollerato solo come strumento di sviluppo, mai nel percorso d'uso né di verifica).

Cross-ref: [04](04-parita-suite-ci.md) (scope: solo ciò che serve al percorso d'uso e alla
verifica, niente rimozione completa di JS);
[08 — Harness di verifica senza Node (shell POSIX)](08-harness-verifica-senza-node.md)
(stessa direzione per la verifica).
