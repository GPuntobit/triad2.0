# 10 — Esperienza di sviluppo / IDE: scope e forma

Type: grilling
Status: resolved

## Question

Graduata dalla foschia «IDE / tooling di sviluppo per Triad» di `map.md` (condizione di
crystallizzazione — «quando la catena nativa è chiara» — soddisfatta: i contratti
installazione/launcher/harness/CLI sono firmati da
[07 — Installazione e launcher: il contratto zero-install](07-installazione-launcher.md),
[08 — Harness di verifica senza Node (shell POSIX)](08-harness-verifica-senza-node.md),
[09 — CLI e toolchain senza Node](09-cli-toolchain-senza-node.md)). È la «decisione di
scope del maintainer PRIMA del codice» che `TASK.md` N19 richiede (accettazione «da
definire alla decisione»): decidere cosa — se qualcosa — consegna l'esperienza di
sviluppo per Triad.

Fatti accertati (non da decidere):

- `editors/` oggi: syntax Vim (`editors/vim/`), grammatica tmLanguage + language-config
  VS Code (`editors/vscode/`, package `triad` 0.2.0, packaging locale via `vsce package`),
  entry GitHub Linguist (`editors/linguist/`). **Nessun Language Server nel repo** —
  «l'estensione VS Code già preparata» è solo grammar.
- Il seed è **muto per contratto**: errori = exit 1/2, stdout vuoto, nessun messaggio
  ([03 — Contratto delle routine `os_*`](03-contratto-os-star.md),
  [04 — Parità: suite di riferimento, CI e politica delle divergenze](04-parita-suite-ci.md)).
  Diagnostica con posizioni ⇒ parser JS di riferimento (`seed/dev/triad_core.cjs`),
  strumento dev lecito (regola operativa 2, fuori catena S0→S4).
- «Run da editor» può solo invocare il launcher contrattuale `bin/triad` (07).

Decisioni da chiudere (albero di grilling, round successivi):

- **Forma**: LSP minimo su `editors/` (diagnostica di parse + run del seed), oppure solo
  pubblicare l'estensione VS Code già preparata, oppure entrambe, oppure **niente** in
  questa mappa (esperienza di sviluppo oltre la destinazione zero-dep → Out of scope,
  `TASK.md` N19 resta per uno sforzo futuro)?
- **Perimetro del «minimo»**: run senza debug (breakpoint/step fuori scope)?
  Autocomplete dentro o fuori?
- **Accettazione di N19**: cosa la chiude e come si verifica.

Cross-ref: `TASK.md` N19 (collocazione ultima, «se deciso», Q2 → b = ambiente di sviluppo);
confine dev/utente di
[09 — CLI e toolchain senza Node](09-cli-toolchain-senza-node.md).

## Answer

**Ruling di scope (2026-11-05, maintainer, Q1 → c): niente in questa mappa.**
L'esperienza di sviluppo / IDE è *oltre* la destinazione — che chiede solo la catena
zero-dep `./install.sh` → `bin/triad` — e il frontier si ferma alla destinazione. Il
ticket è chiuso **fuori scope**: non entra in *Decisions so far* (un confine di scope non
è un passo della rotta); la riga vive nella sezione *Out of scope* della
[mappa](../map.md).

Conseguenze:

- I rami discendenti dell'albero (perimetro del «minimo»: debug/autocomplete; accettazione
  di N19) **non si decidono qui**: restano alla «decisione di scope del maintainer» che
  `TASK.md` N19 colloca «se deciso», in uno sforzo futuro con destinazione propria.
- I fatti accertati restano come base per quello sforzo (corpo della ticket): `editors/`
  oggi è solo grammar (nessun Language Server), il seed è muto per contratto (diagnostica
  ⇒ parser JS di riferimento `seed/dev/triad_core.cjs`, fuori catena S0→S4), il run può
  solo invocare `bin/triad`.
- Ritorno solo se la destinazione viene ridisegnata — e allora come sforzo fresco, non
  come ripresa di questa mappa.
