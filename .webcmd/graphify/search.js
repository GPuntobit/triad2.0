/**
 * graphify search — Search the indexed codebases for definitions matching a term
 */

import { cli, Strategy } from '@agentrhq/webcmd/registry';
import { mcpCall, rowsFrom, listArg } from './lib/client.js';

cli({
  site: 'graphify',
  name: 'search',
  description: 'Search the indexed codebases for definitions matching a term',
  access: 'read',
  strategy: Strategy.LOCAL,
  browser: false,
  args: [
    {
      "name": "query",
      "positional": true,
      "required": true,
      "help": "Symbol name fragment"
    },
    {
      "name": "repo",
      "help": "Repository id or owner/name (defaults to the connected repo)"
    }
  ],
  columns: ["id","symbol","file","loc","commit"],
  func: async (kwargs) => {
    const args = {};
    if (kwargs.repo) args.repository_id = String(kwargs.repo);
    if (kwargs.query !== undefined) args.query = String(kwargs.query);

    const payload = await mcpCall('search', args);
    return rowsFrom(payload, (row) => ({
      id: row.id,
      symbol: row.symbol ?? row.label ?? row.name,
      file: row.file ?? row.src ?? row.path,
      loc: row.loc,
    }), ["results","matches","definitions"]);
  },
});
