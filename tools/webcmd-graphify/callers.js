/**
 * graphify callers â€” List the callers of a symbol in the indexed codebase
 */

import { cli, Strategy } from '@agentrhq/webcmd/registry';
import { mcpCall, rowsFrom, listArg } from './lib/client.js';

cli({
  site: 'graphify',
  name: 'callers',
  description: 'List the callers of a symbol in the indexed codebase',
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
      "help": "Maximum number of callers"
    },
    {
      "name": "strict-calls",
      "type": "boolean",
      "help": "Count only resolved call edges"
    }
  ],
  columns: ["symbol","file","loc","kind","commit"],
  func: async (kwargs) => {
    const args = {};
    if (kwargs.repo) args.repository_id = String(kwargs.repo);
    if (kwargs.symbol !== undefined) args.symbol = String(kwargs.symbol);
    if (kwargs.limit !== undefined) args.limit = Number(kwargs.limit);
    if (kwargs['strict-calls'] !== undefined) args.strict_calls = Boolean(kwargs['strict-calls']);

    const payload = await mcpCall('graphify_callers', args);
    return rowsFrom(payload, (row) => ({
      symbol: row.symbol ?? row.label ?? row.caller,
      file: row.file ?? row.src ?? row.from_file,
      loc: row.loc,
      kind: row.rel ?? row.kind ?? row.type,
    }), ["callers","results","matches"]);
  },
});
