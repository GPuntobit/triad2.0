/**
 * graphify repos — list the codebases indexed by Graphify.
 */

import { cli, Strategy } from '@agentrhq/webcmd/registry';
import { mcpCall, rowsFrom } from './client.js';

cli({
  site: 'graphify',
  name: 'repos',
  description: 'List repositories indexed by Graphify with index readiness',
  access: 'read',
  strategy: Strategy.LOCAL,
  browser: false,
  columns: ['fullName', 'repositoryId', 'status', 'queryable', 'nodeCount', 'provider', 'defaultBranch'],
  func: async () => {
    const payload = await mcpCall('list_repositories', {});
    return rowsFrom(payload, (row) => ({
      fullName: row.fullName,
      repositoryId: row.repositoryId,
      status: row.status,
      queryable: row.queryable,
      nodeCount: row.nodeCount,
      provider: row.provider,
      defaultBranch: row.defaultBranch,
    }));
  },
});
