# Bundle KarpathyWiki — `main.js`

File sorgente: [`main.js`](./.obsidian/plugins/karpathywiki/main.js) · [cartella del plugin](./.obsidian/plugins/karpathywiki/)

## Ruolo nel progetto

Bundle JavaScript del plugin Obsidian KarpathyWiki presente nel vault. Graphify associa al file 2.161 simboli; il conteggio include codice bundled e componenti incorporati, perciò non equivale al numero di API scritte nel progetto.

## Chiamate verificate

- [`buildFolderTree()`](./.obsidian/plugins/karpathywiki/main.js#L89357) costruisce la gerarchia cartelle/file e chiama `sortNode()` (L89392).
- Graphify riporta `onOpen()` come caller di `buildFolderTree()` (call site L89499).
- Altri simboli trovati nel grafo includono `getOrBuild()` (L84869), `buildGraphFromContent()` (L84816), `pageLinks()` (L85222) e `filterSeedsToGraph()` (L87016).

## Collegamenti

- [[Grafo Graphify]]
- [Cartella Obsidian del vault](./.obsidian/)
- [Cartella plugins](./.obsidian/plugins/)
