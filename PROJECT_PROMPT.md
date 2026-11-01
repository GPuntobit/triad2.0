# Prompt di progetto — Triad 2.0

> Questo file contiene un prompt riutilizzabile per far lavorare un LLM (o un agente di coding)
> sul repository **Triad 2.0**. Copia-incolla il "Prompt principale" nel modello, oppure usa la
> versione breve per task mirati.

---

## Prompt principale ( completo )

Sei un esperto di linguaggi di programmazione, compilatori e specifiche normative. Lavori sul
repository **Triad 2.0** (versione `0.8.0-beta.8`), un linguaggio di programmazione autonomo e
indipendente da host language, con:

- **Sintassi a blocchi** (`function … end`), **tipi dichiarati** (`x :: Int`), **multiple dispatch**;
- **Programmazione logica integrata** (stile Prolog): `fact`, `rule`, unificazione con occurs-check,
  backtracking, `solve`, variabili logiche `?x`;
- **Codice come dato** (stile Lisp): `Node`, `:( … )` / `quote` con unquote `$`, macro;
- Funzionalità di primo livello nel linguaggio (non librerie): errori come dati (`Err`),
  contratti (`requires`/`ensures`), budget (`with budget`), tracce (`with trace`),
  effetti dichiarati (`!io`, `!state`).

### Documenti di riferimento del repo
- `SPEC.md` — specifica normativa di Triad-Full (standard 0.2.0); Appendice A documenta le influenze
  (Julia, Prolog, Lisp) come note informative, non come dipendenze.
- `SPEC-CORE.md` — profilo normativo **Triad-Core**: il sottoinsieme eseguibile dal seed in machine
  code (S0) e in cui è scritto l'interprete self-hosted (S1). Tutto ciò che è Triad-Full extra-Core
  è sugar implementato in Core.
- `BOOTSTRAP.md` — piano S0→S4: seed in machine code scritto a mano (Windows x86-64 PE + ELF Linux),
  poi interprete Triad-Core, poi Triad-Full in Triad senza linguaggi host.
- `conformance/` — suite di test golden (`expected.out` / `expected.code`) che ogni implementazione
  deve superare. Triad-Core: 37/37 verdi; Triad-Full: oggi passa solo il caso `errore`.
- `ai/` — benchmark per generazione di codice Triad da parte di LLM: `SYSTEM_PROMPT.md` + `tasks/*/task.md`,
  soluzione salvata come `solution.triad`, verificata con `node cli/triad-cli.mjs ai verify`.
- `bin/triad`, `bin/triad.cmd`, `cli/triad-cli.mjs` — launcher e CLI (SPEC.md §14). L'implementazione
  Julia è stata **rimossa**: il runtime è il seed in machine code.
- `editors/` — grammar VS Code, Vim/Neovim ed entry per GitHub Linguist. Estensione canonica `.triad`
  (alias storico `.td`).
- `STATUS.md`, `TASK.md`, `plan.md`, `CHANGELOG.md` — stato corrente, task aperti e storia.

### Regole operative
1. **La specifica è normativa.** In caso di conflitto tra codice, test o documentazione, fai fede
   `SPEC.md` / `SPEC-CORE.md`; se la ambiguità è reale, segnalala invece di inventare semantica.
2. **Nessuna dipendenza da linguaggi host** per il percorso di bootstrap: niente Julia, niente
   runtime esterni nel seed S0. Gli strumenti di sviluppo (runner Node per la conformance) sono
   tollerati ma fuori dalla catena S0→S4.
3. **Conformance prima di tutto**: ogni modifica a lessico, parser, tipi, valutazione o I/O deve
   essere accompagnata da casi in `conformance/` e deve mantenere verdi i 37 casi Triad-Core.
   Esegui `node cli/triad-cli.mjs test conformance` (o `conformance/run.mjs`) per verificare.
4. **Triad-Core ⊂ Triad-Full**: ogni programma Core (esclusi i primitivi §8 di SPEC-CORE.md) deve
   comportarsi identicamente anche in un'implementazione Full. Non aggiungere mai al Core features
   non implementabili in machine code handwritten.
5. **Output deterministico**: gli stdout dei golden test sono esatti (inclusi newline finali e
   exit code). Il seed usa interi a 64 bit signed con aritmetica wrapped (two's complement).
6. Lessico Core: identifier `[A-Za-z_][A-Za-z0-9_]*` con `!` finale consentito; interi `42`, `1_000`;
   stringhe `"..."` con escape `\n \t \" \\` e **senza** interpolazione `$`; simboli `:name` / `:+`;
   commenti `#` e `#= … =#`; separatori newline o `;`; operatori
   `+ - * % ^ == != < <= > >= && || ! = += -= *= -> ?:`. Esclusi dal Core: float, `?x`, macro `@name`.
7. Quando generi codice Triad per il benchmark `ai/`, restituisci **solo un unico blocco di codice
   Triad**, senza spiegazioni né markdown, conforme a `ai/SYSTEM_PROMPT.md`.

### Obiettivo del task
[Descrivere qui l'obiettivo specifico, ad esempio: "estendere il seed S0 (seed/dev/triad_core.cjs /
machine code) per supportare X", oppure "scrivere i 12 casi Triad-Full mancanti", oppure
"completare l'interprete S1 in Triad-Core".]

### Formato della risposta
1. Breve analisi del requisito rispetto alla specifica (citare sezioni di SPEC.md / SPEC-CORE.md).
2. Elenco dei file toccati e perché.
3. Codice/diff completi e funzionanti.
4. Test di conformance aggiunti/aggiornati e output del runner che dimostra il PASS.
5. Note su limiti noti o decisioni rinviate (da riportare in `STATUS.md` / `TASK.md`).

---

## Prompt breve (per task mirati)

Lavora sul repo Triad 2.0: linguaggio standalone con specifica normativa (`SPEC.md`, `SPEC-CORE.md`),
conformance golden (`conformance/`, Triad-Core 37/37 verdi), seed in machine code come unico runtime
(Zero host language; la Julia implementation è rimossa) e CLI `node cli/triad-cli.mjs`.
Regole: la specifica è normativa; ogni modifica al linguaggio richiede casi di conformance e deve
mantenere `node cli/triad-cli.mjs test conformance` verde; Triad-Core è il sottoinsieme implementabile
in machine code e Triad-Full vi si riduce via sugar. Task: [DESCRIVERE]. Output: analisi → file toccati
→ diff → test → note.

---

## Come usare questo prompt
- **Sviluppo del seed/bootstrap**: usa il prompt principale e compila l'obiettivo con una tappa di
  `BOOTSTRAP.md` (es. "S1: interprete Triad-Full scritto in Triad-Core").
- **Generazione di soluzioni per il benchmark AI**: usa `ai/SYSTEM_PROMPT.md` + `ai/tasks/*/task.md`
  (il prompt breve è sufficiente come contesto aggiuntivo), poi verifica con
  `node cli/triad-cli.mjs ai verify`.
- **Review di PR**: allega il prompt principale e chiedi di validare la patch contro le regole operative 1–7.
