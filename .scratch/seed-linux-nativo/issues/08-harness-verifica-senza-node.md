# 08 — Harness di verifica senza Node (shell POSIX)

Type: grilling
Status: open
Blocked by: 06

## Question

(Da [04 — Parità: suite di riferimento, CI e politica delle divergenze](04-parita-suite-ci.md),
round 2 Q3 scelta (c) rettificata in round 3: lo scope si estende a ciò che serve al
percorso d'uso e alla verifica.)

Gli harness di verifica sono oggi Node (`conformance/run.mjs`, `tests/probes/run_probes.mjs`).
Come si riscrivono in **shell POSIX pura** senza perdere il gate di parità?

- scoperta dei casi e iterazione sulle suite (39 conformance + 19 probe + 20 `bad_*`);
- confronto byte-exatto dei golden (`cmp`? `od`? checksum?) e diff leggibile in caso di fallimento;
- esiti dei `bad_*`: exit code + stdout vuoto, niente confronto dei testi d'errore;
- gestione del golden `selfhost/source.expected.out`;
- transizione: il runner Node resta durante la migrazione o si sostituisce in un colpo solo?

I fatti sugli strumenti garantiti da
[06 — Ricerca: strumenti garantiti per la decodifica di `seed.hex`](06-ricerca-decoder.md)
delimitano il vocabolario ammissibile di tool POSIX.

Cross-ref: [04](04-parita-suite-ci.md) (composizione del gate e meccanismo dei golden
condivisi); [07 — Installazione e launcher: il contratto zero-install](07-installazione-launcher.md)
(solo shell POSIX + repo).
