/**
 * graphify path — Show the most confident connecting path between two symbols
 */

import { cli, Strategy } from '@agentrhq/webcmd/registry';
import { mcpCall, rowsFrom, listArg } from './lib/client.js';

cli({
  site: 'graphify',
  name: 'path',
  description: 'Show the most confident connecting path between two symbols',
  access: 'read',
  strategy: Strategy.LOCAL,
  browser: false,
  args: [
    {
      "name": "src",
      "positional": true,
      "required": true,
      "help": "Source symbol"
    },
    {
      "name": "tgt",
      "required": true,
      "help": "Target symbol"
    },
    {
      "name": "repo",
      "help": "Repository id or owner/name (defaults to the connected repo)"
    }
  ],
  columns: ["src","tgt","resolved","commit"],
  func: async (kwargs) => {
    const args = {};
    if (kwargs.repo) args.repository_id = String(kwargs.repo);
    if (kwargs.src !== undefined) args.src = String(kwargs.src);
    if (kwargs.tgt !== undefined) args.tgt = String(kwargs.tgt);

    const payload = await mcpCall('shortest_path', args);
    return rowsFrom(payload, (row) => ({
      src: row.src ?? row.source,
      tgt: row.tgt ?? row.target,
      resolved: row.resolved,
      path: row.path,
    }), ["paths","results"]);
  },
});
