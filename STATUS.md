# Stato di Triad e del bootstrap S0

Aggiornato al round 27.

## Obiettivo

Triad come linguaggio autonomo e riconosciuto: standard proprio, conformance, estensione `.triad`, tooling editor, bootstrap senza linguaggi ospiti e self-hosting.

## Cosa è pronto

- **Standard**: `SPEC.md` (v0.2.0), `SPEC-CORE.md`, `VERSION`, `CHANGELOG.md`.
- **Conformance**: runner indipendente; 12 casi Triad-Full e 29 casi Triad-Core, tutti verdi sullo stage0 Julia; `conformance/README.md`.
- **Estensione canonica**: `.triad` (`.td` alias storico), grammatiche VS Code/Vim e voce Linguist preparata.
- **Seed S0** (Windows PE, nessun runtime/compilatore): interprete Triad-Core con
  25/29 casi coperti — interi, variabili, funzioni (forma breve e `function … end` multi-istruzione),
  ricorsione, Bool, operatori (`% ^ ! && || +=`), `if`/`else`, `while`, `let`, `begin`,
  lambda, chiusure con cattura per valore, stringhe base + concatenazione, `nothing`, simboli.
- **CI**: `.github/workflows/ci.yml` — conformance Full/Core su Ubuntu e Windows, casi del seed su Windows, hash check.

## Cosa manca

| area | stato |
|---|---|
| `stringhe` (`string()`) | non stabile: implementazione tentata e ritirata |
| `liste` | non implementate |
| `valori` (liste/simboli/stringhe insieme) | parziale (simboli/nothing ok) |
| `controllo` (`elseif`) | manca `elseif`; il resto è pronto |
| S1 (Triad in Triad-Core) | non iniziato |
| S2–S3 (compilatore nativo, self-hosting) | non iniziati |
| S4 / M7 (parità, Linux ELF) | non iniziato; CI pronta per test Linux |

## Comandi di verifica

```sh
julia --startup-file=no conformance/run.jl
julia --startup-file=no conformance/run.jl --cases conformance/core/cases
```

Windows, seed:

```powershell
certutil -decodehex seed/windows-x86_64/seed.hex seed/windows-x86_64/seed.exe
.\seed\windows-x86_64\seed.exe conformance\core\cases\closure\program.td
```

## Riconoscimento esterno (richiede il maintainer)

- scelta e aggiunta di `LICENSE`;
- PR a GitHub Linguist con `editors/linguist/languages.yml`;
- pubblicazione delle estensioni VS Code / Open VSX e Vim;
- eventuale registrazione del linguaggio/standard.
## Verifica finale (round 30)

- Seed S0 Windows: PE 8704 byte, hash `ECF1F483F7FAB783102B6FA695193ECEC4EFFEE3C4D5B0D25AD35231F527BDC4`, dump riproducibile.
- Casi Core supportati: **25/29**, tutti con stdout/exit code byte-esatti; suite Core sul seed `0` errori; exit 2 senza argomento, 1 file mancante.
- Stage0: **Triad-Core 29/29**, **Triad-Full 12/12**.
- CI: hash del seed allineato, matrice Ubuntu/Windows per conformance e job Windows per il seed.

### Casi Core non ancora coperti dal seed

- `controllo`: manca `elseif` (il resto — while/let/begin — è pronto).
- `stringhe`: manca `string()` (concatenazione e `length` funzionano).
- `liste`: non implementate.
- `valori`: mancano liste e stringhe complete (simboli e `nothing` ci sono).

### Distanza dall'obiettivo

L'obiettivo **non è completo**:
- S0 è un interprete in codice macchina, ma **S1 (Triad in Triad-Core) non è iniziato**, quindi non c'è ancora self-hosting;
- S2–S3 (compilatore nativo in Triad, fixed point) non iniziati;
- S4/M7 (parità conformance, port Linux ELF) non iniziati; la CI è pronta ma manca l'artefatto ELF;
- riconoscimento esterno: LICENSE non scelta, PR Linguist e pubblicazione estensioni richiedono il maintainer.