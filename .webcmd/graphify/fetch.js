/**
 * graphify fetch — Read a search result body by its node id
 */

import { cli, Strategy } from '@agentrhq/webcmd/registry';
import { mcpCall, rowsFrom, listArg } from './lib/client.js';

cli({
  site: 'graphify',
  name: 'fetch',
  description: 'Read a search result body by its node id',
  access: 'read',
  strategy: Strategy.LOCAL,
  browser: false,
  args: [
    {
      "name": "id",
      "positional": true,
      "required": true,
      "help": "Node id returned by search"
    }
  ],
  columns: ["id","symbol","file","loc","text","commit"],
  func: async (kwargs) => {
    const args = {};
    if (kwargs.id !== undefined) args.id = String(kwargs.id);

    const payload = await mcpCall('fetch', args);
    return rowsFrom(payload, (row) => ({
      id: row.id,
      symbol: row.symbol ?? row.label,
      file: row.file ?? row.src ?? row.path,
      loc: row.loc,
      text: row.text ?? row.body ?? row.source ?? row.content,
    }), ["results","nodes"]);
  },
});
