/**
 * graphify repos â€” List repositories indexed by Graphify with index readiness
 */

import { cli, Strategy } from '@agentrhq/webcmd/registry';
import { mcpCall, rowsFrom, listArg } from './lib/client.js';

cli({
  site: 'graphify',
  name: 'repos',
  description: 'List repositories indexed by Graphify with index readiness',
  access: 'read',
  strategy: Strategy.LOCAL,
  browser: false,
  args: [],
  columns: ["fullName","repositoryId","status","queryable","nodeCount","provider","defaultBranch"],
  func: async (kwargs) => {
    const args = {};

    const payload = await mcpCall('list_repositories', args);
    return rowsFrom(payload, (row) => ({
      fullName: row.fullName,
      repositoryId: row.repositoryId,
      status: row.status,
      queryable: row.queryable,
      nodeCount: row.nodeCount,
      provider: row.provider,
      defaultBranch: row.defaultBranch,
    }), []);
  },
});
