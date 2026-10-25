/**
 * graphify recall — retrieve workspace knowledge about past decisions and gotchas.
 *
 * When the workspace has no memory for the query, the command still reports
 * the recall state instead of returning nothing.
 */

import { cli, Strategy } from '@agentrhq/webcmd/registry';
import { mcpCall, unwrap } from './lib/client.js';

cli({
  site: 'graphify',
  name: 'recall',
  description: 'Recall workspace knowledge, decisions and gotchas recorded for this codebase',
  access: 'read',
  strategy: Strategy.LOCAL,
  browser: false,
  args: [
    { name: 'query', positional: true, required: true, help: 'What to recall' },
    { name: 'repo', help: 'Repository id or owner/name (defaults to the connected repo)' },
    { name: 'k', type: 'number', default: 10, help: 'Maximum number of memories to return' },
    { name: 'profile', help: 'Recall profile: agent, team or audit' },
    { name: 'grounded-only', type: 'boolean', help: 'Keep only records anchored in the current code graph' },
  ],
  columns: ['id', 'subject', 'kind', 'text', 'date'],
  func: async (kwargs) => {
    const args = {
      query: String(kwargs.query ?? ''),
      ...(kwargs.repo ? { repository_id: String(kwargs.repo) } : {}),
      ...(kwargs.k !== undefined ? { k: Number(kwargs.k) } : {}),
      ...(kwargs.profile ? { profile: String(kwargs.profile) } : {}),
      ...(kwargs['grounded-only'] !== undefined ? { grounded_only: Boolean(kwargs['grounded-only']) } : {}),
    };

    const payload = await mcpCall('recall', args);
    const data = unwrap(payload);
    const facts = Array.isArray(data?.facts) ? data.facts : [];
    const turns = Array.isArray(data?.turns) ? data.turns : [];

    if (facts.length === 0 && turns.length === 0) {
      return [
        {
          id: '(none)',
          subject: '(no workspace memory for this query)',
          kind: data?.recall_state ?? 'empty',
          text: data?.next_step ?? '',
          date: data?.last_consolidated_at,
        },
      ];
    }

    return [...facts, ...turns].map((row) => ({
      id: row.id ?? row.record_id,
      subject: row.subject ?? row.title,
      kind: row.kind ?? row.type ?? 'fact',
      text: row.text ?? row.content ?? row.body,
      date: row.recorded_at ?? row.observed_at ?? row.date,
    }));
  },
});
