/**
 * graphify recall — Recall workspace knowledge, decisions and gotchas recorded for this codebase
 */

import { cli, Strategy } from '@agentrhq/webcmd/registry';
import { mcpCall, rowsFrom, listArg } from './lib/client.js';

cli({
  site: 'graphify',
  name: 'recall',
  description: 'Recall workspace knowledge, decisions and gotchas recorded for this codebase',
  access: 'read',
  strategy: Strategy.LOCAL,
  browser: false,
  args: [
    {
      "name": "query",
      "positional": true,
      "required": true,
      "help": "What to recall"
    },
    {
      "name": "repo",
      "help": "Repository id or owner/name (defaults to the connected repo)"
    },
    {
      "name": "k",
      "type": "number",
      "default": 10,
      "help": "Maximum number of memories to return"
    },
    {
      "name": "profile",
      "help": "Recall profile: agent, team or audit"
    },
    {
      "name": "grounded-only",
      "type": "boolean",
      "help": "Keep only records anchored in the current code graph"
    }
  ],
  columns: ["id","subject","kind","text","date"],
  func: async (kwargs) => {
    const args = {};
    if (kwargs.repo) args.repository_id = String(kwargs.repo);
    if (kwargs.query !== undefined) args.query = String(kwargs.query);
    if (kwargs.k !== undefined) args.k = Number(kwargs.k);
    if (kwargs.profile !== undefined) args.profile = String(kwargs.profile);
    if (kwargs.grounded-only !== undefined) args.grounded_only = Boolean(kwargs.grounded-only);

    const payload = await mcpCall('recall', args);
    return rowsFrom(payload, (row) => ({
      id: row.id ?? row.record_id,
      subject: row.subject ?? row.title,
      kind: row.kind ?? row.type,
      text: row.text ?? row.content ?? row.body,
      date: row.recorded_at ?? row.observed_at ?? row.date,
    }), ["facts","records","results"]);
  },
});
