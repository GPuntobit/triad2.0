/**
 * graphify expand — Expand graph node handles into their full definition bodies
 */

import { cli, Strategy } from '@agentrhq/webcmd/registry';
import { mcpCall, rowsFrom, listArg } from './lib/client.js';

cli({
  site: 'graphify',
  name: 'expand',
  description: 'Expand graph node handles into their full definition bodies',
  access: 'read',
  strategy: Strategy.LOCAL,
  browser: false,
  args: [
    {
      "name": "ids",
      "required": true,
      "help": "Node ids, comma separated"
    }
  ],
  columns: ["id","symbol","file","loc","text"],
  func: async (kwargs) => {
    const args = { ids: listArg(kwargs.ids) ?? [] };

    const payload = await mcpCall('graphify_expand', args);
    return rowsFrom(payload, (row) => ({
      id: row.id,
      symbol: row.symbol ?? row.label ?? row.name,
      file: row.file ?? row.src ?? row.path,
      loc: row.loc,
      text: row.text ?? row.body ?? row.source ?? row.content,
    }), ["nodes","definitions","results"]);
  },
});
