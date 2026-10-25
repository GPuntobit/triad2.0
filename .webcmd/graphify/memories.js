/**
 * graphify memories â€” Show what Graphify remembers about a specific file or symbol
 */

import { cli, Strategy } from '@agentrhq/webcmd/registry';
import { mcpCall, rowsFrom, listArg } from './lib/client.js';

cli({
  site: 'graphify',
  name: 'memories',
  description: 'Show what Graphify remembers about a specific file or symbol',
  access: 'read',
  strategy: Strategy.LOCAL,
  browser: false,
  args: [
    {
      "name": "target",
      "positional": true,
      "required": true,
      "help": "Repository-relative file path or symbol name"
    },
    {
      "name": "repo",
      "help": "Repository id or owner/name (defaults to the connected repo)"
    },
    {
      "name": "k",
      "type": "number",
      "default": 5,
      "help": "Maximum number of memories to return"
    }
  ],
  columns: ["id","subject","kind","text","date"],
  func: async (kwargs) => {
    const args = {};
    if (kwargs.repo) args.repository_id = String(kwargs.repo);
    if (kwargs.target !== undefined) args.target = String(kwargs.target);
    if (kwargs.k !== undefined) args.k = Number(kwargs.k);

    const payload = await mcpCall('graphify_memories_about', args);
    return rowsFrom(payload, (row) => ({
      id: row.id ?? row.record_id,
      subject: row.subject ?? row.title,
      kind: row.kind ?? row.type,
      text: row.text ?? row.content ?? row.body,
      date: row.recorded_at ?? row.observed_at ?? row.date,
    }), ["records","facts","results"]);
  },
});
