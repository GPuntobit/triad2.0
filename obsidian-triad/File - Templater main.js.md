# Bundle Templater — `main.js`

File sorgente: [`main.js`](./.obsidian/plugins/templater-obsidian/main.js) · [cartella del plugin](./.obsidian/plugins/templater-obsidian/)

## Ruolo nel progetto

Bundle JavaScript del plugin Templater configurato per questo vault. Graphify associa al file 323 simboli; tra quelli individuati: `get_new_file_template_for_file()`, `get_new_file_template_for_folder()`, `resolve_template_file()`, `update_file_menu()` e `on_file_creation()`.

## Flusso di creazione file

La definizione Graphify di [`on_file_creation()`](./.obsidian/plugins/templater-obsidian/main.js#L20) gestisce i template all’arrivo di un nuovo file:

- seleziona un template per cartella o per regex, tramite `get_new_file_template_for_folder()` o `get_new_file_template_for_file()`;
- scrive il template con `write_template_to_file()`;
- per i file Markdown non vuoti, può passare a `overwrite_file_commands()`.

## Collegamenti

- [[Grafo Graphify]]
- [Cartella Obsidian del vault](./.obsidian/)
- [Cartella plugins](./.obsidian/plugins/)
