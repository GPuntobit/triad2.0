/**
 * graphify stats â€” Show Graphify index statistics for a repository
 */

import { cli, Strategy } from '@agentrhq/webcmd/registry';
import { mcpCall, rowsFrom, listArg } from './lib/client.js';

cli({
  site: 'graphify',
  name: 'stats',
  description: 'Show Graphify index statistics for a repository',
  access: 'read',
  strategy: Strategy.LOCAL,
  browser: false,
  args: [
    {
      "name": "repo",
      "help": "Repository id or owner/name (defaults to the connected repo)"
    }
  ],
  columns: ["nodes","edges","communities","model","commit","indexedAt"],
  func: async (kwargs) => {
    const args = {};
    if (kwargs.repo) args.repository_id = String(kwargs.repo);

    const payload = await mcpCall('graph_stats', args);
    return rowsFrom(payload, (row) => ({
      nodes: row.n_nodes,
      edges: row.n_edges,
      communities: row.n_communities,
      model: row.model,
    }), []);
  },
});
