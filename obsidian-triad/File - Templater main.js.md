# Bundle Templater — `main.js`
Source file: [`main.js`](./.obsidian/plugins/templater-obsidian/main.js) · [plugin folder](./.obsidian/plugins/templater-obsidian/)
## Role in the project
Templater plugin JavaScript bundle configured for this vault. Graphify associates 323 symbols with the file; among those identified: `get_new_file_template_for_file()`, `get_new_file_template_for_folder()`, `resolve_template_file()`, `update_file_menu()` and `on_file_creation()`.
## File creation flow
The Graphify definition of [`on_file_creation()`](./.obsidian/plugins/templater-obsidian/main.js#L20) handles templates when a new file arrives:
- select a template for folder or for regex, via `get_new_file_template_for_folder()` or `get_new_file_template_for_file()`;
- write the template with `write_template_to_file()`;
- for non-empty Markdown files, can switch to `overwrite_file_commands()`.
## Links
- [[Grafo Graphify|Graphify graph]]
- [Vault Obsidian folder](./.obsidian/)
- [plugins folder](./.obsidian/plugins/)