/**
 * graphify references — List non-call references (reads, mentions, uses) of a symbol
 */

import { cli, Strategy } from '@agentrhq/webcmd/registry';
import { mcpCall, rowsFrom, listArg } from './lib/client.js';

cli({
  site: 'graphify',
  name: 'references',
  description: 'List non-call references (reads, mentions, uses) of a symbol',
  access: 'read',
  strategy: Strategy.LOCAL,
  browser: false,
  args: [
    {
      "name": "symbol",
      "positional": true,
      "required": true,
      "help": "Symbol to inspect"
    },
    {
      "name": "repo",
      "help": "Repository id or owner/name (defaults to the connected repo)"
    },
    {
      "name": "limit",
      "type": "number",
      "default": 25,
      "help": "Maximum number of references"
    }
  ],
  columns: ["symbol","file","loc","kind","commit"],
  func: async (kwargs) => {
    const args = {};
    if (kwargs.repo) args.repository_id = String(kwargs.repo);
    if (kwargs.symbol !== undefined) args.symbol = String(kwargs.symbol);
    if (kwargs.limit !== undefined) args.limit = Number(kwargs.limit);

    const payload = await mcpCall('graphify_references', args);
    return rowsFrom(payload, (row) => ({
      symbol: row.symbol ?? row.label,
      file: row.file ?? row.src ?? row.path,
      loc: row.loc,
      kind: row.kind ?? row.type,
    }), ["references","results","matches"]);
  },
});
