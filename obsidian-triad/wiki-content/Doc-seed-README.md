> Copia di [`seed/README.md`](https://github.com/GPuntobit/triad2.0/blob/main/seed/README.md) — torna a [Documenti](Documenti) · [Home](Home)

# Seed di bootstrap (S0)

Questa cartella contiene **S0**, il primo eseguibile Triad: programmi scritti in **codice
macchina**, senza compilatori, assembler o altri linguaggi. Il "sorgente" è un dump
esadecimale; l'eseguibile si ottiene decodificandolo con uno strumento di sistema.

La catena completa è descritta in [`../BOOTSTRAP.md`](https://github.com/GPuntobit/triad2.0/blob/main/BOOTSTRAP.md).

## Stato

| milestone | piattaforma | stato |
|---|---|---|
| M1 — stampa una riga ed esce con 0 | Windows x86-64 (PE) | ✅ |
| M2 — legge il file dal primo argomento e ne scrive i byte | Windows x86-64 (PE) | ✅ |
| M3 — interprete Triad-Core | Windows x86-64 (PE) | in corso: M3b1 ✅, M3b2a ✅, M3b2b1 ✅, M3b2b2 ✅, M3b2b3a-e ✅, **M3b2b3f** ⚠️ (cattura instabile), **M3b2b3g** ✅ (`!`, `&&`, `||`, `+=`), **M3b2b3h** ✅ (`function … end`), **M3b2b3i** ✅ (corpo a più istruzioni), **M3b2b3j** ✅ (frame lessicali, `let`; `scope`), **M3b2b3k** ✅ (chiusure; `closure`/`chiusure`), **M3b2b3l** ✅ (`begin`/`end`), **M3b2b3m** ✅ (stringhe base), **M3b2b3n** ✅ (`nothing`), **M3b2b3o** ✅ (concatenazione), **M3b2b3p** ✅ (simboli `:nome`; `simboli_base`); restano `string()`, cattura multi-binding, `elseif`, liste |
| M7 — port Linux (ELF) | Linux x86-64 | in corso: **E0 ✅** (ELF minimale, syscall write/exit); E1/E2/E3 da fare |

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

Nota: il file prodotto è un PE per Windows; per Linux c'è il seed ELF E0 in
`linux-x86_64/` (vedi sotto). `certutil`/`xxd` sono solo decodificatori: non contengono
logica Triad e non fanno parte della catena.

Linux ELF (E0):

```sh
xxd -r -p seed/linux-x86_64/seed.hex seed/linux-x86_64/seed
chmod +x seed/linux-x86_64/seed
./seed/linux-x86_64/seed          # Triad seed Linux OK
```

## Verifica

Windows (seed PE):

```powershell
$exe = .\seed\windows-x86_64\seed.exe
& $exe conformance\core\cases\interi\program.td       # 7 9 6 -3 5 7
& $exe conformance\core\cases\closure\program.td      # 15 105 15
& $exe conformance\core\cases\funzioni\program.td     # 5 16 120 55
& $exe conformance\core\cases\while_loop\program.td   # 15 5
& $exe ; $LASTEXITCODE                                # 2
& $exe non_esiste.td ; $LASTEXITCODE                  # 1
```

Linux (seed ELF E0):

```sh
xxd -r -p seed/linux-x86_64/seed.hex seed/linux-x86_64/seed
chmod +x seed/linux-x86_64/seed
./seed/linux-x86_64/seed           # Triad seed Linux OK, exit 0
```

Il seed Windows copre **25 dei 29 casi Core**; il seed Linux E0 copre solo la stampa del
messaggio. Dettagli in [`windows-x86_64/README.md`](https://github.com/GPuntobit/triad2.0/blob/main/seed/windows-x86_64/README.md) e
[`linux-x86_64/README.md`](https://github.com/GPuntobit/triad2.0/blob/main/seed/linux-x86_64/README.md).

## Regole

- Il seed **non** contiene Julia né altri linguaggi: solo byte x86-64 e dati.
- Il dump esadecimale è la fonte; il listing/layout in `windows-x86_64/README.md` lo rende
  modificabile senza tool. Il generatore di manutenzione è in `dev/` (non fa parte della
  catena e non è richiesto per usare o ricostruire il seed).
- Gli strumenti di sviluppo (script usa-e-getta che ha prodotto il dump, editor, decoder)
  non fanno parte della catena S0→S4: per usare/ricostruire il seed basta il dump.
- A ogni estensione del seed (M3, …) si aggiornano: dump, documentazione, hash e milestone in
  `../BOOTSTRAP.md`.
