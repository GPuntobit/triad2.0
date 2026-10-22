# Estrazione E0 — `seed/linux-x86_64/README.md`

- **Documento di riferimento:** [`seed/linux-x86_64/README.md`](../seed/linux-x86_64/README.md)
- **Data dell'estrazione:** 2026-10-22
- **Nota:** il README E0 è stato aggiornato dopo questa estrazione (i binari del seed sono ora pubblicabili, vedi `.gitignore`); la tabella riflette il testo originale.
- **Metodo:** kit ANCÒRA / PENALITÀ / RADAR / SPECCHIO
- **Esito:** base confermata dall'utente (documento e campi); valori estratti dal documento, nessun dato aggiunto.

Regola applicata: estrarre solo valori esplicitamente dichiarati nel documento; se un valore è ambiguo o assente, lasciare il campo vuoto e indicarne il motivo.

## 1. Base dell'estrazione

- **Documento:** scelto dall'agente su autorizzazione esplicita («Documento: scegli tu») e confermato dall'utente («Confermo!»). La scelta in sé non è nel documento: Fonte **Inferito**.
- **Campi:** 21 righe, di cui 19 valorizzate e 2 lasciate vuote (Licenza, Data di rilascio) perché assenti nel documento. L'elenco dei campi non era fornito dall'utente: proposto dall'agente leggendo le sezioni del documento (Fonte **Inferito**) e confermato.

## 2. Tabella (ANCÒRA + RADAR)

| Campo | Valore | Sezione | Motivo (se vuoto) | Fonte | Evidenza |
|---|---|---|---|---|---|
| Titolo / artefatto | `S0 / Linux x86-64 — seed ELF (E0)` | Titolo | — | Estratto | — |
| Piattaforma | `Linux x86-64`; prova su `CachyOS/Linux x86-64` | Titolo; Introduzione | — | Estratto | — |
| Formato | `ELF64 statico` | Introduzione | — | Estratto | — |
| Dipendenze runtime | «senza libc né linker dinamico»; «solo syscall Linux» | Introduzione; §Build e prova (Linux) | — | Estratto | — |
| Dimensione ELF | `173 byte (0xAD)` | §Numeri | — | Estratto | — |
| Codice macchina | `33 byte` | §Numeri | — | Estratto | — |
| Messaggio | `20 byte` | §Numeri | — | Estratto | — |
| Base di caricamento | `0x400000` | §Numeri | — | Estratto | — |
| Entry point | `0x400078` | §Numeri | — | Estratto | — |
| Segmenti | un solo `PT_LOAD` R\|X, offset 0, filesz/memsz `0xAD`, align `0x1000` | §Numeri | — | Estratto | — |
| sha256 di `seed.hex` | `AD4C9F08176D9964D5BE17D44C72230184434025980447395E7A3250F63CA5EA` | §Numeri | — | Estratto | — |
| sha256 dell'ELF | `6d504451e1d8a39c6e139a8a120bfaf03373131894292be12f0039eb8a7797f9` | §Numeri | — | Estratto | — |
| Output stdout | `Triad seed Linux OK` | Introduzione; §Build e prova (Linux) | — | Estratto | — |
| Exit code | `0` | Introduzione; §Build e prova (Linux) | — | Estratto | — |
| Comandi di build | `xxd -r -p seed.hex seed`; `chmod +x seed`; `./seed` | §Build e prova (Linux) | — | Estratto | — |
| Rigenerazione | `node seed/dev/gen_seed_linux.js seed/linux-x86_64/seed.hex` | §Riproducibilità | — | Estratto | — |
| Cosa è committato | solo `seed.hex` (dump); l'ELF non viene committato | Introduzione; §Riproducibilità | — | Estratto | — |
| Stato / cosa non è ancora | «Non è ancora l'interprete Triad-Core»; E0 = primo passo del port | Titolo; Introduzione | — | Estratto | — |
| Prossimi passi | E1 (`argc/argv`, `openat`/`read`/`write`); E2 (port interprete, 25 casi Core); E3 (CI Linux nativo senza Wine) | §Prossimi passi | — | Estratto | — |
| Licenza | *(vuoto)* | — | Il documento non nomina alcuna licenza. | — | — |
| Data di rilascio | *(vuoto)* | — | Nessuna data è dichiarata nel documento. | — | — |

## 3. Voci inferite (RADAR)

Tutti i campi della tabella hanno Fonte **Estratto**. Le sole voci **Inferite** sono fuori documento:

| Voce | Fonte | Evidenza |
|---|---|---|
| Documento scelto | Inferito | «scegli tu» autorizza la scelta, ma nessun criterio è dichiarato; è stato scelto il README dell'artefatto E0 per recenza e verificabilità. |
| Elenco dei campi | Inferito | L'elenco non è mai stato fornito; è stato derivato dalle sezioni del documento, quindi la selezione è dell'agente. |
| Data dell'estrazione | Inferito | Presa dall'orologio di sistema, non dal documento. |

## 4. SPECCHIO — controllo di qualità

1. **Assunzioni non esplicite:** il documento è stato scelto dall'agente (Inferito, poi confermato) e l'elenco dei campi è stato proposto dall'agente (Inferito, poi confermato).
2. **Valori interpretabili diversamente:** `173 byte` di file contro `33 + 20` byte di codice e messaggio può sembrare incoerente (il resto è header/padding, ma il documento non lo spiega: non è stato aggiunto); «E0» può essere letto come stato completo o come inizio del port; `exit 0` è dichiarato, non verificato eseguendo l'ELF.
3. **Calcoli tra sezioni diverse:** nessuno; nessuna somma, nessun hash ricalcolato, nessun valore combinato.
4. **Affidabilità per riga:** vedi §4.2.

### 4.2 Campi problematici

| Campo | Affidabilità | Perché |
|---|---|---|
| Documento scelto | Media | Scelta arbitraria (pur autorizzata); nessun criterio esplicito nel documento. |
| Elenco dei campi | Bassa | Mai fornito dall'utente; derivato dall'agente, possibile selezione orientata. |
| Output stdout / Exit code | Media | Valori letterali nel documento, ma non eseguiti in questa sessione (ambiente Windows). |
| sha256 `seed.hex` / ELF | Media | Copiati letteralmente, non ricalcolati. |
| Licenza / Data di rilascio | Alta | Campi confermati e correttamente vuoti: assenza verificata nel documento. |
| Altri campi (titolo, numeri, comandi, prossimi passi) | Alta | Valori letterali, sezione citata. |

## 5. Limiti dichiarati

- L'ELF Linux non è stato eseguito in questa sessione: output ed exit code sono valori dichiarati dal documento, non verificati qui.
- Gli hash sono copiati carattere per carattere, non ricalcolati.
- Licenza e data di rilascio restano vuote per assenza nel documento, non per dimenticanza.
