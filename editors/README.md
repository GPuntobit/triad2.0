# Editor support
This folder contains the tools that make Triad recognizable as a language
various editors. They are implementation independent: they describe the syntax of `SPEC.md`.
| folder | what |
|---|---|
| `vscode/` | VS Code extension: `triad` language, `source.triad` TextMate grammar, parentheses/comments/indentation configuration |
| `vim/` | `ftdetect` + `syntax` for Vim/Neovim |
| `linguist/` | ready entry for `github-linguist` and recognition instructions on GitHub |
## Canonical extension
`.triad` is the canonical extension of the language; `.td` remains accepted as a historical alias.
However, `.td` is also the extension of **LLVM TableGen**, therefore for external recognition
the recommended choice is `.triad`.
## Installation
### VS Code
```sh
cd editors/vscode
npx @vscode/vsce package
code --install-extension triad-0.2.0.vsix
```

Or copy `editors/vscode/` to `~/.vscode/extensions/triad/`.
### Vim / Neovim
```sh
mkdir -p ~/.vim
cp -r editors/vim/syntax editors/vim/ftdetect ~/.vim/
```

For Neovim: `cp -r editors/vim/* ~/.config/nvim/`.
## Recognition as a language
The specification (`SPEC.md`), the conformance suite (`conformance/`), the version (`VERSION`), and
grammar are the requirements to present Triad as an autonomous language. For GitHub the
external step is the PR to `github-linguist/linguist`: see `linguist/README.md`.