# webcmd-plugin-graphify

Access the Graphify code graph from the command line via webcmd.

The plugin talks to the Graphify control plane over the MCP streamable-HTTP
endpoint (`https://api.graphify.com/v1/mcp`) and exposes each Graphify
operation as a deterministic CLI command.

## Install

```bash
# Local development (symlinked, changes reflect immediately)
webcmd plugin install file://C:\Users\xbos\Documents\progetti\triad2.0\.webcmd\graphify

# Verify registration
webcmd list | Select-String graphify
```

## Commands

| Command | Graphify tool | Description |
|---------|---------------|-------------|
| `webcmd graphify repos` | `list_repositories` | Indexed repositories, status and node counts |
| `webcmd graphify query "<question>"` | `query_graph` | Natural-language question over the code graph |
| `webcmd graphify find <term>` | `graphify_find` | Where a symbol is defined |
| `webcmd graphify stats` | `graph_stats` | Node/edge counts and languages |

Common flags: `--repo <id|owner/name>`, `-f json|yaml|md|csv`, `--help`.

Examples:

```bash
webcmd graphify repos -f json
webcmd graphify query "where is the web fetch implemented" --repo SEIS0-official/triad2.0
webcmd graphify find "fetch" --limit 10
webcmd graphify stats
```

## Credentials

Resolved at runtime, never written to the command line or logs:

1. `GRAPHIFY_TOKEN` (or `GRAPHIFY_API_KEY`) environment variable
2. `mcpServers.graphify.headers.Authorization` in the local MCP config —
   defaults to `~/.minimax/mcp.json`, override the path with `MINIMAX_MCP_CONFIG`

The endpoint can be overridden with `GRAPHIFY_MCP_URL`.

## Notes

- Commands are plain ESM JavaScript (`.js`): the host transpiles only `.ts`
  files, and esbuild is not required at install time.
- `client.js` is the shared MCP transport: `initialize` →
  `notifications/initialized` → `tools/call`, parsing the SSE response frames.
- `structuredContent` from the MCP response is preferred; text payloads are
  parsed as JSON when possible, otherwise returned as a single row.
