# TRID-013 — Identificatori stabili e riconciliazione incrementale S0/S1

**Stato:** percorso sperimentale opt-in, basato sulle PR TRID-011 e
TRID-012. Tutta la selezione delle identità logiche, il confronto,
l'assegnazione delle revisioni e la vista corrente avvengono in Triad-Core
nativo. Shell/Linux si occupa esclusivamente del trasporto sicuro dei
record, degli hash SHA-256 e del commit atomico già introdotto in TRID-011.

## Contratto delle identità

Gli importatori TRID-012 usano nomi posizionali come
`legacy_1`, `s0memory_2` e `s1graph_3`. Tali nomi
cambiano se una riga viene inserita prima di un'altra.

TRID-013 seleziona in modo deterministico una **chiave naturale**
in Triad-Core per ogni record importato. L'identificatore v1 è
`k` seguito dai primi 40 caratteri esadecimali di SHA-256
della chiave più newline (digest da 160 bit). Il trasporto calcola
l'hash ma non decide quale osservazione sia equivalente a un'altra.
Due chiavi naturali uguali nello stesso snapshot sono rifiutate.

| Origine | Chiave naturale (indipendente dalla posizione) |
|---|---|
| S0 edge | record completo, inclusi sorgente ed estremi |
| S0 review | target + riferimento della revisione umana |
| S0 target, approve, revoke | record completo |
| S0 definition | target + identificatore della definizione |
| S0 memory rule | target + struttura della regola |
| S0 memory claim | soggetto, oggetto, forma, testimone e fonti |
| S1 evidence, association, revoked | contenuto del fatto, inclusa la sorgente |
| S1 rule_state | identificatore della regola |

La modifica di un campo della chiave naturale **crea un'identità nuova**.
Le altre modifiche producono una nuova revisione dello stesso ID.
La corrispondenza è deterministica per il profilo supportato, non una
verifica crittografica dell'identità delle fonti. Un'eventuale collisione
di digest è estremamente improbabile ma non logicamente impossibile;
i vecchi e nuovi record con lo stesso ID sono confrontati anche sulla
chiave naturale nativa e un disaccordo viene rifiutato.

## Operazioni

    # Produci la fotografia sorgente secondo TRID-012, senza scriverla.
    sh cognitive/native/unify_v1.sh --build \
      cognitive/native/fixture.txt \
      "$HOME/trid-s0/.current/memory.txt" \
      cognitive/native/graph_06.facts > snapshot.v1

    # Osserva gli ID stabili, senza modificare il registro.
    sh cognitive/native/normalize_v1.sh snapshot.v1 > stable-snapshot.v1

    # Nuovo namespace TRID-013: diff e commit atomici sotto lo stesso flock.
    TRID_EVENT_STATE_DIR="$HOME/trid-events-v2" \
      sh cognitive/native/unify_v1.sh --reconcile \
        cognitive/native/fixture.txt \
        "$HOME/trid-s0/.current/memory.txt" \
        cognitive/native/graph_06.facts

    TRID_EVENT_STATE_DIR="$HOME/trid-events-v2" \
      sh cognitive/native/journal_v1.sh --replay > history.v1

    # Una sola revisione per ID, senza modificare history.v1.
    sh cognitive/native/unify_v1.sh --project-current history.v1 > current.view

`--reconcile` legge un registro già verificato, normalizza
le nuove chiavi, computa un delta e pubblica soltanto eventi
nuovi o realmente modificati. Tutto avviene mantenendo il lock
del registro TRID-011. Uno snapshot identico produce **zero
eventi nuovi e nessuna modifica al puntatore di commit**.

Le righe assenti dalla fotografia successiva NON sono considerate
false o automaticamente revocate: occorre un evento esplicito di
revoca della fonte. La vista corrente mostra l'ultima revisione
di ogni identità, ma la storia append-only conserva quelle vecchie.

## Barriere epistemiche

Una riconciliazione **rifiuta** per un ID già esistente una
transizione da uno stato non verificato verso
`consolidated_conditional` o `demonstrated_conditional`
per una RuleCandidate, oppure verso
`demonstrated_conditional` per un ProofNode/ProofEdge.
Una modifica dello snapshot non è un'approvazione umana né
una dimostrazione.

I record nuovi possono contenere lo stato originario fornito dal
verificatore indipendente S0, ma **la provenienza dichiarata non
è autenticata da questo bridge**. Anche un record inizialmente
consolidato rimane condizionato alle premesse e alle approvazioni
accertate dal motore S0. Le pulsazioni di attivazione restano
separate dalle prove e non attribuiscono alcuna verità.

L'identità derivata non è una firma, non certifica che la fonte
sia attendibile e non impedisce a un amministratore ostile di
riscrivere un intero archivio e i relativi checksum.

## Migrazione e limiti

Il percorso incrementale **rifiuta** di mescolare eventi
importati TRID-012 con ID posizionali e nuovi eventi con ID
stabili. Conservare quel registro in sola lettura ed eseguire
la nuova riconciliazione in un namespace separato. Non è
prevista una migrazione automatica che indovini equivalenze
storiche.

Il registro e ogni snapshot canonico sono limitati a 12.000 byte;
il confronto incrementale nativo accetta fino a 24.000 byte
complessivi tra storico e nuovo snapshot. La dimensione totale del
registro pubblicato resta limitata a 12.000 byte, quindi il numero di
revisioni ulteriori dipende dallo spazio ancora disponibile. I due stati originali S0 e S1 devono essere acquisiti
in modo coerente prima della riconciliazione; non viene creata
una transazione distribuita tra i due storage. Python JSONL,
archiviazione senza limiti, autenticazione delle fonti e
autonomia cognitiva completa restano fuori dallo scope.

Test: `sh cognitive/native/tests/run_reconcile_v1.sh`,
suite S0/S1 e conformance sul medesimo commit.
