# Stato di Triad e del bootstrap S0

Aggiornato al round 27.

## Obiettivo

Triad come linguaggio autonomo e riconosciuto: standard proprio, conformance, estensione `.triad`, tooling editor, bootstrap senza linguaggi ospiti e self-hosting.

## Cosa è pronto

- **Standard**: `SPEC.md` (v0.2.0), `SPEC-CORE.md`, `VERSION`, `CHANGELOG.md`.
- **Conformance**: runner indipendente; 12 casi Triad-Full e 29 casi Triad-Core, tutti verdi sullo stage0 Julia; `conformance/README.md`.
- **Estensione canonica**: `.triad` (`.td` alias storico), grammatiche VS Code/Vim e voce Linguist preparata.
- **Seed S0** (Windows PE, nessun runtime/compilatore): interprete Triad-Core con
  26/29 casi coperti — interi, variabili, funzioni (forma breve e `function … end` multi-istruzione),
  ricorsione, Bool, operatori (`% ^ ! && || +=`), `if`/`else`, `while`, `let`, `begin`,
  lambda, chiusure con cattura per valore, stringhe base + concatenazione + `string()`, `nothing`, simboli.
- **CI**: `.github/workflows/ci.yml` — conformance Full/Core su Ubuntu e Windows, casi del seed su Windows, hash check.

## Cosa manca

| area | stato |
|---|---|
| `stringhe` (`string()`) | ✅ implementato (Int/String); Bool/Symbol/Nothing crashano |
| `liste` | rimandato a S1 |
| `valori` (liste/simboli/stringhe insieme) | parziale (simboli/nothing ok) |
| `controllo` (`elseif`) | ✅ implementato |
| S1 (Triad in Triad-Core) | in corso |
| S2–S3 (compilatore nativo, self-hosting) | non iniziati |
| S4 / M7 (parità, Linux ELF) | **E0 ✅** ELF Linux minimale; E1/E2/E3 e parità da fare |

## Comandi di verifica

```sh
julia --startup-file=no conformance/run.jl
julia --startup-file=no conformance/run.jl --cases conformance/core/cases
```

Windows, seed:

```powershell
certutil -decodehex -f seed/windows-x86_64/seed.hex seed/windows-x86_64/seed.exe
.\seed\windows-x86_64\seed.exe conformance\core\cases\closure\program.td
```

## Riconoscimento esterno (richiede il maintainer)

- `LICENSE` aggiunta (MIT, 2026-10-22);
- PR a GitHub Linguist con `editors/linguist/languages.yml`;
- pubblicazione delle estensioni VS Code / Open VSX e Vim;
- eventuale registrazione del linguaggio/standard.
## Verifica finale (round 31)

- Seed S0 Windows: PE 25088 byte, hash `445CB428EFF44B39C2103DF776E6D9A1D1B5BDD8904C2C93D661950321C4ED60`, dump riproducibile.
- Stage0: **Triad-Core 31/31**, **Triad-Full 12/12**.
- Seed Windows: nuova regressione `funzioni_io` verificata con stdout byte-esatto; 27/28 casi elencati nel job CI passano localmente. `if_else` termina con exit `1` (anche col PE precedente); la verifica CI ospitata resta necessaria.
- CI: hash del seed aggiornato; matrice Ubuntu/Windows per conformance e job Windows per il seed.

### Casi Core non ancora coperti dal seed

- `liste`: non implementate.
- `valori`: supporto parziale; mancano liste e gestione completa delle stringhe.

### Distanza dall'obiettivo

L'obiettivo **non è completo**:
- S0 è un interprete in codice macchina, ma **S1 (Triad in Triad-Core) non è iniziato**, quindi non c'è ancora self-hosting;
- S2–S3 (compilatore nativo in Triad, fixed point) non iniziati;
- S4/M7 (parità conformance, port Linux ELF) non iniziati; l'artefatto E0 esiste (`seed/linux-x86_64/seed.hex`), la CI è pronta ma la parità non è iniziata;
- riconoscimento esterno: LICENSE MIT scelta; PR Linguist e pubblicazione estensioni richiedono il maintainer.
