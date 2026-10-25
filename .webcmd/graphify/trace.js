/**
 * graphify trace â€” Trace the directed call paths between two symbols
 */

import { cli, Strategy } from '@agentrhq/webcmd/registry';
import { mcpCall, rowsFrom, listArg } from './lib/client.js';

cli({
  site: 'graphify',
  name: 'trace',
  description: 'Trace the directed call paths between two symbols',
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
    },
    {
      "name": "paths",
      "type": "number",
      "default": 3,
      "help": "Number of distinct call paths to return"
    },
    {
      "name": "strict-calls",
      "type": "boolean",
      "help": "Count only resolved call edges"
    }
  ],
  columns: ["src","tgt","resolved","commit"],
  func: async (kwargs) => {
    const args = {};
    if (kwargs.repo) args.repository_id = String(kwargs.repo);
    if (kwargs.src !== undefined) args.src = String(kwargs.src);
    if (kwargs.tgt !== undefined) args.tgt = String(kwargs.tgt);
    if (kwargs.paths !== undefined) args.k_paths = Number(kwargs.paths);
    if (kwargs['strict-calls'] !== undefined) args.strict_calls = Boolean(kwargs['strict-calls']);

    const payload = await mcpCall('graphify_trace', args);
    return rowsFrom(payload, (row) => ({
      src: row.src ?? row.source,
      tgt: row.tgt ?? row.target,
      resolved: row.resolved,
      path: row.path,
    }), ["paths","results"]);
  },
});
