# Audit del codice inutilizzato — 2026-11-08

Base: `48564e1` (main dopo PR #82). Riferimenti cercati anche nei file
nascosti, nei launcher, script, workflow e documentazione; verifica di esecuzione
sui runtime nativo e di sviluppo. L'assenza di riferimenti da sola non prova che
un comando pubblico o un esempio sia eliminabile.

| Elemento | Evidenza | Intervento |
|---|---|---|
| `seed/dev/test_small.mjs` | stampa solo `hello`, nessun richiamo nel repository | rimosso |
| `seed/dev/run_all.cjs` | runner abbandonato con percorsi Windows personali, nessun richiamo; sostituito dagli harness correnti | rimosso |
| inizializzazione `lnames = []` di S1 | sovrascritta da `init.td` prima di ogni lettura | rimossa |
| `ppos_unused` di S1 | assegnazione senza letture | rimossa |
| `sm` nel ramo fact | vettore allocato e mai letto | rimosso |
| regola G-D23 e helper `hasTopLevelSymbol` | D23 assente dal contratto dopo il fix; helper usato solo dalla regola inattiva | rimossi |
| prototipi `selfhost/*.td` | CI li valida; tokenizer richiamato dai tutorial; classificati fuori contratto dal guard | mantenuti |
| seconda sequenza numerica dopo `jmp('pt_loop')` in `pt_mul_num`, `seed/dev/core.js` | nessuna etichetta/ingresso tra salto e duplicato: istruzioni irraggiungibili | segnalata, mantenuta per ADR 0001 |

L'ultimo punto richiede un intervento separato sul layout del codice macchina:
anche togliere istruzioni irraggiungibili sposta indirizzi e displacement nei dump.
ADR 0001 richiede immutabilità degli artefatti nel lavoro strutturale. Questo
cleanup non modifica generatori, dump, hash o binari.

Verifiche PASS: Core 42/42; probe 39/39; logica 25/25 sui due runtime;
verify.sh; self-test guardie 27/27 e guard sul corpus; differenziale 6 file;
sicurezza; desktop; git diff --check. I golden sono invariati.
