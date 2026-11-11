# TRID-001 — Baseline verificabile su `main` (11 novembre 2026)

**Stato: evidenza CI disponibile sul commit indicato, non attestazione perpetua del ramo.**

## Commit, ambiente e provenienza dell'evidenza

- Repository: `GPuntobit/triad2.0`.
- `main` ispezionato: `7ff41abad93d2c646617d7d620c3bdda1c920a1a`.
- GitHub Actions: [TRID Required run 43021172705](https://github.com/GPuntobit/triad2.0/actions/runs/43021172705), conclusione **success** su quello SHA.
- I log dei singoli job registrano `SHA=7ff41abad93d2c646617d7d620c3bdda1c920a1a`, Linux x86_64, Ubuntu 24.04. I job sono indipendenti, ma eseguono lo **stesso commit**.
- Verificatore S0 storico: PR [#99](https://github.com/GPuntobit/triad2.0/pull/99) integrata. Il test corrente `cognitive/native/tests/run.sh` riavvia il verificatore sullo stesso fixture, prova l'idempotenza, la revoca e il rifiuto del journal manomesso; la suite non è una prova generale di equivalenza fra ogni versione passata e presente.

## Mappatura dei cinque test richiesti dal backlog

| Suite del backlog | Job `TRID Required` | Evidenza |
|---|---|---|
| `sh cognitive/tests/run.sh` | `TRID / S1` | PASS: job verde |
| `sh cognitive/native/tests/run.sh` | `TRID / S0` | PASS: job verde; inclusi i sotto-test nativi |
| `sh cognitive/native/tests/run_05.sh` | `TRID / S1` | PASS: golden byte-exact del demo 0.5 |
| `sh cognitive/native/tests/run_06.sh` | `TRID / S1` | PASS: golden byte-exact, riavvio, revoca e rifiuto input ostile |
| `sh verify.sh` | `TRID / Conformance` | PASS: suite conformance |

Nella stessa esecuzione risultano verdi anche `TRID / Epistemic`, `TRID / Integration` e `TRID / Merge Gate`.
I job hanno timeout di 20–25 minuti e limite virtuale di memoria configurato nei comandi. Un job verde indica che tutte le sue istruzioni sono terminate con codice zero, senza dimostrare assenza di bug fuori dai casi coperti.

Le durate **per singola suite** non sono riportate dal workflow `TRID Required`: per riprodurle, con le etichette `PASS/FAIL`, `exit` e `duration_seconds`, usare il workflow [`trid-baseline.yml`](../../.github/workflows/trid-baseline.yml), che le emette per ciascuna delle cinque suite sul suo checkout. Il workflow baseline ha filtri sui path e può non partire automaticamente per una modifica estranea a `cognitive/`.

## Riproduzione locale su checkout pulito

```sh
git rev-parse HEAD
git status --short
xxd -r -p seed/linux-x86_64/seed.hex seed/linux-x86_64/seed
chmod +x seed/linux-x86_64/seed
sh cognitive/tests/run.sh
sh cognitive/native/tests/run.sh
sh cognitive/native/tests/run_05.sh
sh cognitive/native/tests/run_06.sh
sh verify.sh
```

Il seed ricostruito è un artefatto locale ignorato da Git. In CI si usa `actions/checkout` sullo SHA candidato, senza adattare manualmente i golden. I test nativi emettono `exit != 0` e diagnostica su stderr quando falliscono.

## Limiti dell'evidenza

- È una verifica per **quel commit**, per quei test e per quell'ambiente Ubuntu; un nuovo merge necessita una nuova run.
- Il test di certificazione reale CachyOS precedente ha prodotto 7/7 PASS su `3a8b64f9b43da935e49360f1d760ae3f04b81adf`, **non** su `7ff41abad93d2c646617d7d620c3bdda1c920a1a`.
- SIGKILL è un'iniezione di crash di processo, non uno spegnimento elettrico e non una transazione distribuita S0/S1.
- Il progetto usa deduzioni **condizionali** alle fonti dichiarate, non autentica l'attendibilità del mondo reale.
- GitHub Pages può fallire separatamente: non è una delle cinque suite di TRID-001; non va nascosto né reinterpretato come errore cognitivo.

Per ogni nuovo audit aggiornare SHA e link alla run; **non sovrascrivere prove precedenti attribuendole al nuovo `main`**.
