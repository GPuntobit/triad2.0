# Triad per VS Code

Estensione locale di sintassi per il linguaggio **Triad** (`source.triad`).

## Installazione (sviluppo)

```sh
# dentro editors/vscode
npm install -g @vscode/vsce   # una volta
vsce package                  # crea triad-0.2.0.vsix
code --install-extension triad-0.2.0.vsix
```

In alternativa, copia questa cartella in `~/.vscode/extensions/triad` (o
`%USERPROFILE%\.vscode\extensions\triad`) e riavvia VS Code.

## Cosa copre

- estensioni `.triad` (canonica) e `.td` (storica);
- commenti `#` e `#= ... =#`, shebang, stringhe con escape e interpolazione `$x`/`$(...)`;
- variabili logiche `?x`, simboli `:nome`, macro `@nome`, parole chiave e opzioni di
  `solve` (`limit`, `depth`, `steps`, `trace`);
- tipi builtin e nomi di tipo (iniziale maiuscola), call e definizioni di funzione;
- operatori, `:-` delle regole, parentesi e indentazione su `end`.

## Nota su `.td`

`.td` è anche l'estensione di **LLVM TableGen**; se hai installato un'estensione TableGen,
VS Code può chiedere con quale linguaggio associare i `.td`. Per nuovi file usa `.triad`.
