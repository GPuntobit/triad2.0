/**
 * graphify expand — materialize node handles into full definitions.
 *
 * `graphify_expand` answers with a Markdown context built from NODE blocks,
 * the same shape `query_graph` uses, so the same parser applies.
 */

import { cli, Strategy } from '@agentrhq/webcmd/registry';
import { mcpCall, unwrap, freshnessOf, listArg } from './lib/client.js';

const NODE_PATTERN = /^NODE (.+?) \[src=(.+?) loc=(.+?)\](.*)$/gm;

function parseNodes(context) {
  const nodes = [];
  for (const match of context.matchAll(NODE_PATTERN)) {
    nodes.push({
      symbol: match[1].trim(),
      file: match[2].trim(),
      loc: match[3].trim(),
      summary: (match[4] ?? '').trim(),
    });
  }
  return nodes;
}

cli({
  site: 'graphify',
  name: 'expand',
  description: 'Expand graph node handles into their full definition bodies',
  access: 'read',
  strategy: Strategy.LOCAL,
  browser: false,
  args: [
    { name: 'ids', required: true, help: 'Node ids, comma separated' },
    { name: 'repo', help: 'Repository id or owner/name (defaults to the connected repo)' },
  ],
  columns: ['id', 'symbol', 'file', 'loc', 'text', 'commit'],
  func: async (kwargs) => {
    const ids = listArg(kwargs.ids) ?? [];
    if (ids.length === 0) throw new Error('Provide at least one node id.');

    const args = {
      ids,
      ...(kwargs.repo ? { repository_id: String(kwargs.repo) } : {}),
    };
    const payload = await mcpCall('graphify_expand', args);
    const data = unwrap(payload);
    const meta = freshnessOf(data);
    const context = typeof data?.context === 'string' ? data.context : '';

    const nodes = parseNodes(context);
    if (nodes.length === 0) {
      return [
        {
          id: ids.join(','),
          symbol: '(no definition)',
          file: '',
          loc: '',
          text: context.slice(0, 600),
          ...meta,
        },
      ];
    }

    return nodes.map((node, index) => ({
      id: ids[index] ?? '',
      ...node,
      text: context.slice(0, 600),
      ...meta,
    }));
  },
});
