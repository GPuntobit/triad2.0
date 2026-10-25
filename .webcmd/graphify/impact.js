/**
 * graphify impact — Show the blast radius of changing a symbol or file
 */

import { cli, Strategy } from '@agentrhq/webcmd/registry';
import { mcpCall, rowsFrom, listArg } from './lib/client.js';

cli({
  site: 'graphify',
  name: 'impact',
  description: 'Show the blast radius of changing a symbol or file',
  access: 'read',
  strategy: Strategy.LOCAL,
  browser: false,
  args: [
    {
      "name": "target",
      "positional": true,
      "required": true,
      "help": "Symbol or file to assess"
    },
    {
      "name": "repo",
      "help": "Repository id or owner/name (defaults to the connected repo)"
    },
    {
      "name": "limit",
      "type": "number",
      "default": 40,
      "help": "Maximum number of impacted nodes"
    },
    {
      "name": "max-seeds",
      "type": "number",
      "default": 8,
      "help": "Number of seed nodes to fan out from"
    }
  ],
  columns: ["symbol","file","kind","commit"],
  func: async (kwargs) => {
    const args = {};
    if (kwargs.repo) args.repository_id = String(kwargs.repo);
    if (kwargs.target !== undefined) args.target = String(kwargs.target);
    if (kwargs.limit !== undefined) args.limit = Number(kwargs.limit);
    if (kwargs.max-seeds !== undefined) args.max_seeds = Number(kwargs.max-seeds);

    const payload = await mcpCall('graphify_impact', args);
    return rowsFrom(payload, (row) => ({
      symbol: row.symbol ?? row.label,
      file: row.file ?? row.src ?? row.path,
      kind: row.kind ?? row.type,
    }), ["impacted","nodes","results"]);
  },
});
