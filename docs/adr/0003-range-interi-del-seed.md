# Il range degli interi del seed: 62 bit con overflow rumoroso, non silenzioso

**Status:** accepted (2026-11-08)

`SPEC-CORE.md` §5 fissa `Int` a **64 bit signed con wrap**; il seed rappresenta `Int`
come `n<<2` (2 bit di tag per `Bool`, chiusure e oggetti heap), quindi il suo payload
utile è un intero signed a **62 bit**, `[-2^61, 2^61-1]`. La divergenza `D25` era
dichiarata nel contratto del seed come **silenziosa**: oltre il range, il seed
restituiva un numero sbagliato **senza errore**. Decisione:

1. **La specifica non si muove**: `Int` resta a 64 bit signed con wrap in
   `SPEC-CORE.md` §5. Il seed non ha il diritto di ridefinire il linguaggio.
2. **Il seed mantiene la rappresentazione a 62 bit**: arrivare a 64 bit veri richiede
   una ridisegnazione della rappresentazione dei valori (`Int` boxed o bignum a due
   parole, con aritmetica a 128 bit per la moltiplicazione) — sproporzionata per un
   veicolo di transizione verso S1, e con un costo di byte/rischio ben oltre una
   sessione.
3. **Il seed smette di mentire**: un letterale o un risultato aritmetico fuori dal
   range diventa un **errore di esecuzione** (exit 1, diagnostica `overflow`), non un
   numero sbagliato. `D25` passa da `silent` a `noisy` nel contratto del seed.
4. **I 64 bit diventano un vincolo esplicito per S1**: S1 è scritto in Core e gira sul
   seed, quindi eredita la rappresentazione a 62 bit dell'host (`selfhost/value.td`
   fa `n * 4`). Per essere conforme a §5, S1 deve implementare da sé la semantica a
   64 bit (per es. `Int` a due parole da 31 bit ciascuna), invece di delegare
   all'host.

## Perché

- Una divergenza **silenziosa** è la classe più insidiosa (vedi `GLOSSARY.md`,
  «Divergenza silenziosa»): non si vede, non lascia traccia, e l'utente che scrive
  `x = 10000000000 * 10000000000` riceve un numero falso con exit 0. Il `-=` rotto
  del ciclo N03/N04 è stato corretto per la stessa ragione: il seed non deve produrre
  risultati sbagliati in silenzio.
- Il **rifiuto esplicito** è già la lingua del seed per i limiti (indice fuori range →
  exit 1): l'overflow entra nella stessa classe, non in una nuova.
- La decisione **non è** delegabile al codice: il limite del seed è una scelta di
  progetto (62 bit) che va dichiarata, non un incidente da correggere in silenzio.

## Alternative scartate

- **Implementare i 64 bit veri nel seed** (`Int` boxed / bignum): conforme a §5, ma
  richiede aritmetica a 128 bit e una ridisegnazione dei valori in codice macchina
  scritto a mano; costo e rischio incompatibili con il ruolo di S0 (veicolo di
  transizione). Rimane un obiettivo legittimo per la linea S1+, che può implementare
  la semantica a 64 bit **in Core**.
- **Dichiarare imprecisa la specifica** (ad es. «interi a almeno 62 bit»): la
  specifica è normativa (regola operativa 1) e descrive il linguaggio, non una
 implementazione; il seed è il deviatore, non la norma.
- **Lasciare l'overflow silenzioso** (stato quo): scartato — è la classe di
  divergenza che il progetto dichiara esplicitamente la più insidiosa.

## Conseguenze

- **Ciclo di rebuild**: `seed/dev/core.js` cambia → dump PE ed ELF, binari, hash CI
  (ADR 0001: ogni diff nei byte è deliberato e tracciato). I golden di conformance
  non cambiano (nessun caso Core usa valori fuori range).
- **Contratto**: `D25` cambia classe (`silent` → `noisy`) e la sua descrizione dice
  che il seed **rifiuta** i valori fuori range invece di produrli sbagliati. Il
  letterale decimale è ammesso fino a `2^61-1`; il risultato aritmetico deve stare in
  `[-2^61, 2^61-1]`.
- **Probe**: `bad_intero_64bit` non è più una divergenza silenziosa ma un **rifiuto**:
  il probe verifica exit 1 e stdout vuoto. Il presidio di D25 resta il **gate
  differenziale** (`DIFFERENTIAL_ONLY`): è una divergenza decidibile solo a runtime.
- **Diagnostica**: nuova uscita `overflow` (exit 1). Su ELF il messaggio è
  `seed: integer overflow` su stderr (fuori parità, come gli altri messaggi); il PE
  resta muto.
- **Vincolo per S1**: `BOOTSTRAP.md` (tappa S1) deve eseguire la semantica a 64 bit
  di `SPEC-CORE.md` §5 **dentro** S1, non ereditarla dal seed.
