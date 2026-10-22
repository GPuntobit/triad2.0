# Prompt Jev per l'audit del repository Triad

Questo documento contiene il prompt per **Jev** (TypeSafe / System One) usato per
capire *cosa si sbaglia* e *quanti errori* ci sono in questo repository, e il
runner che lo esegue: [`jev_audit.mjs`](jev_audit.mjs).

---

## 1. Perché "quanti errori?" non è una domanda

Jev è un modello di **giudizio**: riceve uno `state` e restituisce risposte
tipizzate con probabilità (Choice, Score, Noul). Non legge il repository al posto
nostro e non conta.

Mettere tutto il repository in un unico prompt e chiedere "quanti errori ci sono?"
produce una risposta poco attendibile: lo stato diventa enorme, il modello deve
sopravvalutare e il risultato non è aggregabile né verificabile.

Il prompt è quindi **decomposto**:

| Livello | Domanda a Jev | Chi aggrega |
| --- | --- | --- |
| 1 file | "questo file ha un difetto? di che classe? quanto grave? quanti?" | — |
| 2 progetto | somma delle attese per-file | **il codice** (`expectedCount`) |
| 3 localizzazione | "in quale finestra di 40 righe sta il difetto?" | **il codice** (finestra → righe) |

Il conteggio non è mai chiesto al modello. Il modello classifica ogni file in
una fascia (`0`, `1`, `2`, `3+` difetti) e restituisce la distribuzione di
probabilità; il codice calcola il numero atteso come media pesata delle fasce.

---

## 2. Il `state`

Uno `state` per file, in JSON, con campi nominati (la forma raccomandata dalla
documentazione TypeSafe):

```jsonc
{
  "project": { "name": "Triad", "summary": "..." },
  "file":    { "path": "ai/SYSTEM_PROMPT.md", "role": "prompt", "lines": 71 },
  "contract": "Che cosa questo artefatto doveva fare, in termini verificabili.",
  "known_facts": {
    "local_suite_results": { "unit_tests": "243/243 passed", "...": "..." },
    "cli_flags": { "interpreter_implemented": [], "launcher_implemented": [], "claimed_by_docs": [] },
    "observed_runtime_behaviour": ["println of a lambda prints '#lambda(x)', not 'fun'.", "..."]
  },
  "content": "il testo del file"
}
```

Tre scelte deliberate:

1. **`contract` per ruolo.** Un giudizio ha senso solo se il modello sa cosa
   l'artefatto doveva fare. I ruoli sono definiti in `ROLE_RULES` nel runner:
   `spec`, `reference-implementation`, `test`, `golden`, `launcher`, `ci`,
   `prompt`, `tooling`, `doc`, `source`. Ogni ruolo ha un contratto diverso.

2. **`known_facts` è calcolato localmente, non scritto a mano.** Il runner
   esegue i test e la conformità e inietta i risultati veri. Serve a due cose:
   impedire al modello di "scoprire" un difetto che è già coperto dai test, e
   dargli il materiale su cui giudicare (i flag che il codice implementa vs
   quelli che i documenti dichiarano).

3. **`content` è il file grezzo, con numeri di riga?** No: i numeri di riga
   renderebbero il testo artificiale e falserebbero la localizzazione. Le righe
   si ricavano dopo, dalla finestra.

---

## 3. Le cinque domande (una richiesta, in parallelo)

Tutte e cinque leggono lo stesso `state` e girano in parallelo: non vedono le
risposte delle altre, quindi nessuna può contaminare le altre.

### `has_defect` — Noul
> Does `content` contain at least one defect? A defect is: a statement in the text
> that is false about the Triad implementation; code that contradicts its
> contract; a broken path, link or file reference; or a declared value (byte size,
> hash, count, flag, exit code) that does not match reality.

Il Noul restituisce la **probabilità di "sì"**, non un booleano. Il codice sceglie
una soglia (0.5) e lascia il resto sotto soglia in una zona grigia esplicita.

### `defect_class` — Choice
Tassonomia di 12 classi, inclusa `none`. Serve a rispondere a *"cosa si sbaglia"*:
le classi sono azionabili (`exit_code_contract`, `prompt_mismatch`,
`false_documentation`, `broken_reference`, `portability`, `build_ci`,
`coverage_gap`, `stale_claim`, `spec_mismatch`, `runtime_bug`, `other`).

La risposta porta `choice`, `confidence` e le `probabilities` di ogni classe: le
probabilità sono ciò che permette di distinguere "un difetto chiaro" da "un file
dove il modello sta indovinando".

### `severity` — Score
Quattro livelli ordinati, dal cosmetico al crash. Lo `score` è la posizione
pesata (0..3) con la sua distribuzione. Serve a ordinare il backlog: un artefatto
con severity 3 e confidence bassa va comunque guardato per primo.

### `defect_count` — Score
Fasce: `0`, `1`, `2`, `3+`. Il codice calcola

```
expectedCount = Σ (indice del livello) × (probabilità del livello)
```

e somma su tutti i file. Il risultato è una **stima attesa**, non un intero
esatto: va detto così, perché il numero non è misurato.

### `caught_by_suite` — Noul
> Is the most serious defect in this artifact one that the project's own test
> suite and conformance suite would detect?

Questa è la domanda più utile del set. Le suite sono verdi (243/243, 12/12,
29/29, 25/25 sul seed), quindi **qualsiasi difetto vero è per definizione fuori
copertura**. Il filtro separa i difetti che il repository già cattura da quelli
che passerebbero inosservati: sono questi ultimi la priorità.

---

## 4. Secondo passaggio: localizzazione

Il `sweep` sa *quale file* è sospetto, non *dove*. Per il file segnalato:

```bash
node ai/jev_audit.mjs locate ai/SYSTEM_PROMPT.md
```

Il runner divide il file in finestre di 40 righe e chiede, per ogni finestra, un
Noul (`defect_here`) e una Choice (`defect_class`). Il modello seleziona la
finestra; il codice la converte in un intervallo di righe:

```
ai/SYSTEM_PROMPT.md:34-73  P=0.81  class=prompt_mismatch  conf=0.72
```

Le finestre sono numerate a partire da 1 e l'intervallo è quello della finestra
intera: è una localizzazione a granularità di finestra, non di singola riga. Per
ottenere la riga esatta si usa un secondo passaggio con finestre più strette
sui soli file già confermati.

---

## 5. Come si esegue

```bash
export TYPESAFE_API_KEY=...          # richiesto per le chiamate reali
export TYPESAFE_MODEL=jev-latest     # opzionale

node ai/jev_audit.mjs sweep --dry-run   # stampa i payload JSON, senza chiamare l'API
node ai/jev_audit.mjs sweep              # chiama l'API e scrive ai/jev_audit_report.md
node ai/jev_audit.mjs locate <file>      # localizza i difetti di un file
```

Endpoint: `POST https://api.typesafe.ai/v1/systemone`, header
`Authorization: Bearer $TYPESAFE_API_KEY` e
`TypeSafe-Danger-Zone-Long-Context: true` (necessario: `triad.jl` e `syntax.jl`
sono lunghi).

Il report scritto in `ai/jev_audit_report.md` contiene: numero di file analizzati,
file segnalati, **numero atteso di difetti**, difetti per classe, quanti non
sono coperti dalle suite, e il consumo di token.

---

## 6. Limiti, dichiarati

- **Il numero atteso è una stima**, non un conteggio. Le probabilità di Jev
  sono calibrate ma non corrette per forza su questo dominio: i 186 artefatti
  vanno valutati come benchmark, non come verità.
- **Una richiesta per file significa 186 richieste.** Il costo scala con il
  repository. Per un audit parziale basta un sottoinsieme di file in `sweep`.
- **La soglia 0.5 è una scelta, non una misura.** I file sotto soglia restano
  fuori dal report; con `--dry-run` si vede il payload, con il report si vede
  solo ciò che ha superato la soglia.
- **Jev non esegue il codice.** Tutto ciò che riguarda il comportamento reale
  deve arrivare da `known_facts` o dalla specificazione, mai dall'inferenza del
  modello.
- **La lingua delle domande è l'inglese**, anche se il repository è in italiano:
  la documentazione TypeSafe segnala che l'inglese è la lingua di addestramento
  principale di Jev e che le altre lingue hanno accuratezza inferiore. Il
  `content` resta nella lingua originale.
- **Il prompt non sostituisce i test.** Serve a trovare i difetti che i test
  non coprono, che sono esattamente quelli per cui `caught_by_suite` restituisce
  "no".
