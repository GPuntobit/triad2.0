# AGENTS.md — Triad 2.0

> **Scopo di questo file**: è il prompt di progetto letto automaticamente da *tutte* le AI/agenti
> di coding che operano su questo repository (Codex, Copilot, Cursor, Claude Code, Devin, ecc.,
> che riconoscono `AGENTS.md` alla radice). Le regole qui sotto sono vincolanti per qualsiasi
> agente, a prescindere dal modello o dallo strumento usato.
>
> Nota: `ai/SYSTEM_PROMPT.md` ha un altro scopo — è il prompt usato *dall'AI che genera soluzioni
> Triad per il benchmark* (`ai/tasks/*/task.md`). Non sostituisce e non è sostituito da questo file.

---

## 1. Che cos'è Triad 2.0

Linguaggio di programmazione autonomo, **indipendente da host language** (versione `0.8.0-beta.8`), con:

- **Sintassi a blocchi** (`function … end`), **tipi dichiarati** (`x :: Int`), **multiple dispatch**;
- **Programmazione logica integrata** (stile Prolog): `fact`, `rule`, unificazione con occurs-check,
  backtracking, `solve`, variabili logiche `?x`;
- **Codice come dato** (stile Lisp): `Node`, `:( … )` / `quote` con unquote `$`, macro;
- Funzionalità di primo livello nel linguaggio (non librerie): errori come dati (`Err`),
  contratti (`requires`/`ensures`), budget (`with budget`), tracce (`with trace`),
  effetti dichiarati (`!io`, `!state`).

Estensione canonica dei file: `.triad` (alias storico `.td`).

## 2. Documenti di riferimento

| File | Ruolo |
|---|---|
| `SPEC.md` | Specifica **normativa** di Triad-Full (standard 0.2.0). Appendice A: influenze (Julia, Prolog, Lisp) come note informative, non dipendenze. |
| `SPEC-CORE.md` | Profilo normativo **Triad-Core**: sottoinsieme eseguibile dal seed in machine code (S0) e in cui è scritto l'interprete self-hosted (S1). Tutto il Full extra-Core è sugar implementato in Core. |
| `BOOTSTRAP.md` | Piano S0→S4: seed in machine code scritto a mano (PE x86-64 Windows + ELF Linux), poi interprete Triad-Core, poi Triad-Full senza linguaggi host. |
| `conformance/` | Suite golden test (`expected.out` / `expected.code`). Stato: Triad-Core 37/37 verdi; Triad-Full passa solo il caso `errore`. |
| `ai/` | Benchmark di generazione codice Triad da parte di LLM: `SYSTEM_PROMPT.md` + `tasks/*/task.md`, soluzione in `solution.triad`, verifica con `node cli/triad-cli.mjs ai verify`. |
| `bin/triad`, `cli/triad-cli.mjs` | Launcher e CLI (SPEC.md §14). L'implementazione Julia è stata **rimossa**: il runtime è il seed in machine code. |
| `editors/` | Grammar VS Code, Vim/Neovim, entry GitHub Linguist. |
| `STATUS.md`, `TASK.md`, `plan.md`, `CHANGELOG.md` | Stato corrente, task aperti, storia. Aggiornarli quando il lavoro cambia lo stato del progetto. |

## 3. Regole operative (vincolanti per ogni agente)

1. **La specifica è normativa.** In caso di conflitto tra codice, test o documentazione, fa fede
   `SPEC.md` / `SPEC-CORE.md`. Se un'ambiguità è reale, segnalala invece di inventare semantica.
2. **Nessuna dipendenza da linguaggi host** nel percorso di bootstrap: niente Julia, niente runtime
   esterni nel seed S0. Strumenti di sviluppo (runner Node per la conformance) sono tollerati ma
   restano fuori dalla catena S0→S4.
3. **Conformance prima di tutto.** Ogni modifica a lessico, parser, tipi, valutazione o I/O deve
   essere accompagnata da casi in `conformance/` e deve mantenere verdi i 37 casi Triad-Core.
   Verificare con: `node cli/triad-cli.mjs test conformance` (oppure `conformance/run.mjs`).
4. **Triad-Core ⊂ Triad-Full.** Ogni programma Core (esclusi i primitivi §8 di SPEC-CORE.md) deve
   comportarsi identicamente anche in un'implementazione Full. Non aggiungere al Core feature non
   implementabili in machine code scritto a mano.
5. **Output deterministico.** Gli stdout dei golden test sono esatti (newline finali e exit code
   inclusi). Il seed usa interi a 64 bit signed con aritmetica wrapped (two's complement).
6. **Lessico Core**: identifier `[A-Za-z_][A-Za-z0-9_]*` con `!` finale consentito; interi `42`,
   `1_000`; stringhe `"`…`"` con escape `\n \t \" \\` e **senza** interpolazione `$`; simboli
   `:name` / `:+`; commenti `#` e `#= … =#`; separatori newline o `;`; operatori
   `+ - * % ^ == != < <= > >= && || ! = += -= *= -> ?:`. Esclusi dal Core: float, `?x`, macro `@name`.
7. **Per il benchmark `ai/`**: quando il compito è generare una soluzione, restituire **solo un
   unico blocco di codice Triad**, senza spiegazioni né markdown, conforme a `ai/SYSTEM_PROMPT.md`,
   e verificare con `node cli/triad-cli.mjs ai verify`.

## 4. Formato della risposta richiesto agli agenti

1. Breve analisi del requisito rispetto alla specifica (citare sezioni di `SPEC.md` / `SPEC-CORE.md`).
2. Elenco dei file toccati e perché.
3. Codice/diff completi e funzionanti.
4. Test di conformance aggiunti/aggiornati + output del runner che dimostra il PASS.
5. Note su limiti noti o decisioni rinviate (da riportare in `STATUS.md` / `TASK.md`).

## 5. Varianti d'uso

- **Sviluppo seed/bootstrap**: applicare le regole 1–6 e compilare l'obiettivo con una tappa di
  `BOOTSTRAP.md` (es. "S1: interprete Triad-Full scritto in Triad-Core").
- **Review di PR**: validare la patch contro le regole operative 1–7.
- **Generazione soluzioni per il benchmark AI**: usare regola 7 + `ai/SYSTEM_PROMPT.md`.
