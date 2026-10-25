/**
 * graphify remember â€” Save a durable note (decision, constraint, gotcha) for the workspace
 */

import { cli, Strategy } from '@agentrhq/webcmd/registry';
import { mcpCall, rowsFrom, listArg } from './lib/client.js';

cli({
  site: 'graphify',
  name: 'remember',
  description: 'Save a durable note (decision, constraint, gotcha) for the workspace',
  access: 'write',
  strategy: Strategy.LOCAL,
  browser: false,
  args: [
    {
      "name": "text",
      "positional": true,
      "required": true,
      "help": "One self-contained statement to remember"
    },
    {
      "name": "repo",
      "help": "Repository id or owner/name (defaults to the connected repo)"
    },
    {
      "name": "tags",
      "help": "Comma-separated labels"
    },
    {
      "name": "session",
      "help": "Optional session id grouping related notes"
    },
    {
      "name": "occurred-at",
      "help": "ISO timestamp the note is about, when it differs from now"
    }
  ],
  columns: ["id","status","text","tags"],
  func: async (kwargs) => {
    const tags = String(kwargs.tags ?? '')
      .split(',')
      .map((tag) => tag.trim())
      .filter(Boolean);
    const args = {
      text: String(kwargs.text ?? ''),
      ...(kwargs.repo ? { repository_id: String(kwargs.repo) } : {}),
      ...(tags.length ? { tags } : {}),
      ...(kwargs.session ? { session_id: String(kwargs.session) } : {}),
      ...(kwargs['occurred-at'] ? { occurred_at: String(kwargs['occurred-at']) } : {}),
    };

    const payload = await mcpCall('remember', args);
    return rowsFrom(payload, (row) => ({
      id: row.id ?? row.record_id,
      status: row.status ?? 'saved',
      text: row.text ?? row.subject,
      tags: row.tags,
    }), ["records","results"]);
  },
});
