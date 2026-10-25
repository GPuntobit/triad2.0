/**
 * graphify query — ask a natural-language question about an indexed codebase.
 *
 * `query_graph` answers with a Markdown context built from NODE blocks:
 *
 *   NODE symbol() [src=file.ext loc=L42]
 *     summary: signature
 *   ```code```
 *
 * Each block becomes one CLI row.
 */

import { cli, Strategy } from '@agentrhq/webcmd/registry';
import { mcpCall, unwrap, freshnessOf } from './lib/client.js';

const NODE_PATTERN = /^NODE (.+?) \[src=(.+?) loc=(.+?)\]\r?\n\s*summary: (.*)\r?\n```\r?\n([\s\S]*?)\r?\n```/gm;

function parseNodes(context) {
  const nodes = [];
  for (const match of context.matchAll(NODE_PATTERN)) {
    nodes.push({
      symbol: match[1].trim(),
      file: match[2].trim(),
      loc: match[3].trim(),
      summary: match[4].trim(),
      code: match[5],
    });
  }
  return nodes;
}

cli({
  site: 'graphify',
  name: 'query',
  description: 'Query the Graphify code graph with a natural-language question',
  access: 'read',
  strategy: Strategy.LOCAL,
  browser: false,
  args: [
    { name: 'question', positional: true, required: true, help: 'What to ask about the codebase' },
    { name: 'repo', help: 'Repository id or owner/name (defaults to the connected repo)' },
    { name: 'budget', type: 'number', default: 5000, help: 'Approximate token budget for materialized context' },
    { name: 'k', type: 'number', help: 'Number of seed nodes to expand' },
    { name: 'skeleton', type: 'boolean', help: 'Return signatures instead of full bodies' },
  ],
  columns: ['symbol', 'file', 'loc', 'summary', 'commit'],
  func: async (kwargs) => {
    const args = {
      question: String(kwargs.question ?? ''),
      ...(kwargs.repo ? { repository_id: String(kwargs.repo) } : {}),
      ...(kwargs.budget !== undefined ? { budget: Number(kwargs.budget) } : {}),
      ...(kwargs.k !== undefined ? { k: Number(kwargs.k) } : {}),
      ...(kwargs.skeleton !== undefined ? { skeleton: Boolean(kwargs.skeleton) } : {}),
    };

    const payload = await mcpCall('query_graph', args);
    const data = unwrap(payload);
    const context = typeof data?.context === 'string' ? data.context : '';
    const meta = freshnessOf(data);

    const nodes = parseNodes(context);
    if (nodes.length === 0) {
      return [
        {
          symbol: '(no structured nodes)',
          file: '',
          loc: '',
          summary: context.slice(0, 600),
          ...meta,
        },
      ];
    }

    return nodes.map((node) => ({ ...node, ...meta }));
  },
});
