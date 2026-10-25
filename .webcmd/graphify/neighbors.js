/**
 * graphify neighbors — Map the dependencies and dependents of a file in the indexed codebase
 */

import { cli, Strategy } from '@agentrhq/webcmd/registry';
import { mcpCall, rowsFrom, listArg } from './lib/client.js';

cli({
  site: 'graphify',
  name: 'neighbors',
  description: 'Map the dependencies and dependents of a file in the indexed codebase',
  access: 'read',
  strategy: Strategy.LOCAL,
  browser: false,
  args: [
    {
      "name": "file",
      "positional": true,
      "required": true,
      "help": "Repository-relative file path"
    },
    {
      "name": "repo",
      "help": "Repository id or owner/name (defaults to the connected repo)"
    },
    {
      "name": "limit",
      "type": "number",
      "default": 40,
      "help": "Maximum number of neighbors per side"
    }
  ],
  columns: ["file","direction","symbol","commit"],
  func: async (kwargs) => {
    const args = {};
    if (kwargs.repo) args.repository_id = String(kwargs.repo);
    if (kwargs.file !== undefined) args.file = String(kwargs.file);
    if (kwargs.limit !== undefined) args.limit = Number(kwargs.limit);

    const payload = await mcpCall('graphify_file_neighbors', args);
    return rowsFrom(payload, (row) => ({
      file: row.file ?? row.path ?? row.src,
      direction: row.direction ?? row.relation ?? row.kind,
      symbol: row.symbol ?? row.label,
    }), ["neighbors","results","files"]);
  },
});
