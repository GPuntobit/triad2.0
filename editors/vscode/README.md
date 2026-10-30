# Triad for VS Code
Local syntax extension for the **Triad** language (`source.triad`).
## Installation (development)
```sh
# dentro editors/vscode
npm install -g @vscode/vsce   # una volta
vsce package                  # crea triad-0.2.0.vsix
code --install-extension triad-0.2.0.vsix
```

Alternatively, copy this folder to `~/.vscode/extensions/triad` (or
`%USERPROFILE%\.vscode\extensions\triad`) and restart VS Code.
## What it covers
- `.triad` (canonical) and `.td` (historical) extensions;
- comments `#` and `#= ... =#`, shebang, escaped strings and interpolation `$x`/`$(...)`;
- `?x` logical variables, `:name` symbols, `@name` macros, keywords and options
  `solve` (`limit`, `depth`, `steps`, `trace`);
- builtin types and type names (capital letters), calls and function definitions;
- operators, `:-` of rules, brackets and indentation on `end`.
## Note about `.td`
`.td` is also the extension of **LLVM TableGen**; if you have installed a TableGen extension,
VS Code may ask which language to associate the `.td` with. For new files use `.triad`.