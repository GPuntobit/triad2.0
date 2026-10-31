> Copia di [`editors/README.md`](https://github.com/GPuntobit/triad2.0/blob/main/editors/README.md) — torna a [Documenti](Documenti) · [Home](Home)

# Supporto editor

Questa cartella contiene gli strumenti che rendono Triad riconoscibile come linguaggio nei
vari editor. Sono indipendenti dall'implementazione: descrivono la sintassi di `SPEC.md`.

| cartella | cosa |
|---|---|
| `vscode/` | estensione VS Code: linguaggio `triad`, grammatica TextMate `source.triad`, configurazione di parentesi/commenti/indentazione |
| `vim/` | `ftdetect` + `syntax` per Vim/Neovim |
| `linguist/` | voce pronta per `github-linguist` e istruzioni per il riconoscimento su GitHub |

## Estensione canonica

`.triad` è l'estensione canonica del linguaggio; `.td` resta accettata come alias storico.
`.td` è però anche l'estensione di **LLVM TableGen**, quindi per il riconoscimento esterno
la scelta consigliata è `.triad`.

## Installazione

### VS Code

```sh
cd editors/vscode
npx @vscode/vsce package
code --install-extension triad-0.2.0.vsix
```

Oppure copia `editors/vscode/` in `~/.vscode/extensions/triad/`.

### Vim / Neovim

```sh
mkdir -p ~/.vim
cp -r editors/vim/syntax editors/vim/ftdetect ~/.vim/
```

Per Neovim: `cp -r editors/vim/* ~/.config/nvim/`.

## Riconoscimento come linguaggio

La specifica (`SPEC.md`), la suite di conformità (`conformance/`), la versione (`VERSION`) e
la grammatica sono i requisiti per presentare Triad come linguaggio autonomo. Per GitHub il
passo esterno è la PR a `github-linguist/linguist`: vedi `linguist/README.md`.
