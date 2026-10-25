/**
 * graphify node — Show a symbol definition with its immediate graph neighbours
 */

import { cli, Strategy } from '@agentrhq/webcmd/registry';
import { mcpCall, rowsFrom, listArg } from './lib/client.js';

cli({
  site: 'graphify',
  name: 'node',
  description: 'Show a symbol definition with its immediate graph neighbours',
  access: 'read',
  strategy: Strategy.LOCAL,
  browser: false,
  args: [
    {
      "name": "symbol",
      "positional": true,
      "required": true,
      "help": "Symbol to read"
    },
    {
      "name": "repo",
      "help": "Repository id or owner/name (defaults to the connected repo)"
    },
    {
      "name": "limit",
      "type": "number",
      "default": 12,
      "help": "Maximum number of neighbours"
    }
  ],
  columns: ["symbol","file","loc","kind","text","commit"],
  func: async (kwargs) => {
    const args = {};
    if (kwargs.repo) args.repository_id = String(kwargs.repo);
    if (kwargs.symbol !== undefined) args.symbol = String(kwargs.symbol);
    if (kwargs.limit !== undefined) args.limit = Number(kwargs.limit);

    const payload = await mcpCall('graphify_node', args);
    return rowsFrom(payload, (row) => ({
      symbol: row.symbol ?? row.label ?? row.name,
      file: row.file ?? row.src ?? row.path,
      loc: row.loc,
      kind: row.kind ?? row.type,
      text: row.text ?? row.body ?? row.source ?? row.content,
    }), ["nodes","definitions","results"]);
  },
});
