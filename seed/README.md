# Seed di bootstrap (S0)

Questa cartella contiene **S0**, il primo eseguibile Triad: programmi scritti in **codice
macchina**, senza compilatori, assembler o altri linguaggi. Il "sorgente" è un dump
esadecimale; l'eseguibile si ottiene decodificandolo con uno strumento di sistema.

La catena completa è descritta in [`../BOOTSTRAP.md`](../BOOTSTRAP.md).

## Stato

| milestone | piattaforma | stato |
|---|---|---|
| M1 — stampa una riga ed esce con 0 | Windows x86-64 (PE) | ✅ |
| M2 — legge il file dal primo argomento e ne scrive i byte | Windows x86-64 (PE) | ✅ |
| M3 — interprete Triad-Core | Windows x86-64 (PE) | in corso: M3b1 ✅, M3b2a ✅, M3b2b1 ✅, M3b2b2 ✅, M3b2b3a-e ✅, **M3b2b3f** ⚠️ (cattura instabile), **M3b2b3g** ✅ (`!`, `&&`, `||`, `+=`), **M3b2b3h** ✅ (`function … end`), **M3b2b3i** ✅ (corpo a più istruzioni), **M3b2b3j** ✅ (frame lessicali, `let`; `scope`), **M3b2b3k** ✅ (chiusure; `closure`/`chiusure`), **M3b2b3l** ✅ (`begin`/`end`), **M3b2b3m** ✅ (stringhe base), **M3b2b3n** ✅ (`nothing`), **M3b2b3o** ✅ (concatenazione), **M3b2b3p** ✅ (simboli `:nome`; `simboli_base`); restano `string()`, cattura multi-binding, `elseif`, liste |
| M7 — port Linux (ELF) | Linux x86-64 | da fare (serve ambiente Linux) |

## Build (nessun compilatore)

Windows:

```powershell
Remove-Item seed\windows-x86_64\seed.exe -ErrorAction SilentlyContinue
certutil -decodehex seed\windows-x86_64\seed.hex seed\windows-x86_64\seed.exe
```

Linux/macOS:

```sh
xxd -r -p seed/windows-x86_64/seed.hex seed/windows-x86_64/seed.exe
```

Nota: il file prodotto è un PE per Windows; su Linux serve il port ELF (M7). `certutil`/`xxd`
sono solo decodificatori: non contengono logica Triad e non fanno parte della catena.

## Verifica (M3b2b3f)

```powershell
$exe = .\seed\windows-x86_64\seed.exe
& $exe conformance\core\cases\simboli_base\program.td        # simboli, exit 0`n& $exe conformance\core\cases\begin_block\program.td          # begin/end, exit 0`n& $exe conformance\core\cases\closure\program.td             # chiusure, exit 0`n& $exe conformance\core\cases\chiusure\program.td            # chiusure via function, exit 0`n& $exe conformance\core\cases\scope\program.td               # frame lessicali e let, exit 0`n& $exe conformance\core\cases\funzioni_blocco\program.td     # corpo multi-istruzione, exit 0`n& $exe conformance\core\cases\funzioni\program.td            # function ... end, exit 0`n& $exe conformance\core\cases\aritmetica\program.td          # logica e +=, exit 0`n& $exe conformance\core\cases\lambda\program.td              # lambda, exit 0
& $exe conformance\core\cases\simboli_base\program.td        # simboli, exit 0`n& $exe conformance\core\cases\begin_block\program.td          # begin/end, exit 0`n& $exe conformance\core\cases\closure\program.td             # chiusure, exit 0`n& $exe conformance\core\cases\chiusure\program.td            # chiusure via function, exit 0`n& $exe conformance\core\cases\scope\program.td               # frame lessicali e let, exit 0`n& $exe conformance\core\cases\funzioni_blocco\program.td     # corpo multi-istruzione, exit 0`n& $exe conformance\core\cases\funzioni\program.td            # function ... end, exit 0`n& $exe conformance\core\cases\aritmetica\program.td          # logica e +=, exit 0`n& $exe conformance\core\cases\lambda\program.td              # lambda, exit 0
& $exe conformance\core\cases\while_loop\program.td          # while, exit 0
& $exe conformance\core\cases\if_else\program.td             # if/else/end, exit 0
& $exe conformance\core\cases\operatori\program.td           # %, ^, true/false, exit 0
& $exe conformance\core\cases\confronti\program.td           # Bool, exit 0
& $exe conformance\core\cases\ricorsione\program.td          # fattoriale/fib, exit 0
& $exe conformance\core\cases\funzioni_semplici\program.td   # funzioni, exit 0
& $exe conformance\core\cases\variabili\program.td           # variabili, exit 0
& $exe conformance\core\cases\interi\program.td              # interi, exit 0
& $exe ; $LASTEXITCODE                                       # 2
& $exe non_esiste.td ; $LASTEXITCODE                         # 1
```

Il seed copre **25 dei 29 casi Core** (`let_chiusura`, `chiusura_in_if`, `chiusure_local`, `let_annidato`, `stringhe_multi`, `simboli_base`, `stringhe_concat`, `nothing_base`, `stringhe_base`, `begin_block`, `closure`, `chiusure`, `scope`, `funzioni_blocco`, `funzioni`, `aritmetica`, `lambda`, `while_loop`, `if_else`,
`operatori`, `confronti`, `ricorsione`, `funzioni_semplici`, `variabili`, `interi`); gli altri
richiedono liste/stringhe, `elseif`/`let`, divisione o effetti, e passano sullo stage0.
Per il confronto byte-esatto e per il layout vedere `windows-x86_64/README.md`.

## Regole

- Il seed **non** contiene Julia né altri linguaggi: solo byte x86-64 e dati.
- Il dump esadecimale è la fonte; il listing/layout in `windows-x86_64/README.md` lo rende
  modificabile senza tool. Il generatore di manutenzione è in `dev/` (non fa parte della
  catena e non è richiesto per usare o ricostruire il seed).
- Gli strumenti di sviluppo (script usa-e-getta che ha prodotto il dump, editor, decoder)
  non fanno parte della catena S0→S4: per usare/ricostruire il seed basta il dump.
- A ogni estensione del seed (M3, …) si aggiornano: dump, documentazione, hash e milestone in
  `../BOOTSTRAP.md`.
