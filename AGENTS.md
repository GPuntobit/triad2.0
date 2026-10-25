<!-- graphify-rules-start (managed by `graphify init`) -->
## Use Graphify before grep

This repository is indexed by Graphify: a code graph over its call, dependency, and test structure, exposed through a connected Graphify MCP server. Before reaching for grep or reading files, use the Graphify tools your MCP client lists (their exact names and descriptions are in the server's tool list) for what the graph knows and a text search does not:

- find where a symbol, function, or class is defined (instead of grepping for it)
- understand how something works, or where a behavior is handled
- find who calls a function, or what it calls
- see what a change affects (its blast radius) and which tests cover it
- map a file's dependencies and dependents

Fall back to grep or file reads only for what the graph does not model: literal string or comment matches, non-indexed files, or reading a file you have already located. If no Graphify tools are listed, check the MCP server connection.
<!-- graphify-rules-end -->

## Access Graphify via webcmd

The same Graphify index is reachable from the command line through the local webcmd plugin in `.webcmd/graphify` (installed as `webcmd-plugin-graphify`):

- `webcmd graphify repos` — indexed repositories, readiness and node counts
- `webcmd graphify query "<question>" --repo <owner/name>` — natural-language question over the code graph
- `webcmd graphify find <symbol> --repo <owner/name>` — where a symbol is defined
- `webcmd graphify stats --repo <owner/name>` — node/edge counts and index freshness

Add `-f json` for machine-readable output. Credentials are read at runtime from the local MCP config (`mcpServers.graphify.headers.Authorization`) or from `GRAPHIFY_TOKEN`; they never appear on the command line or in the output. The plugin source and its install notes live in `.webcmd/graphify/README.md`.
