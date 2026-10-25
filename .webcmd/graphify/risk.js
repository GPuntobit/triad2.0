/**
 * graphify risk — Rank change-impact hotspots by their linked test coverage
 */

import { cli, Strategy } from '@agentrhq/webcmd/registry';
import { mcpCall, rowsFrom, listArg } from './lib/client.js';

cli({
  site: 'graphify',
  name: 'risk',
  description: 'Rank change-impact hotspots by their linked test coverage',
  access: 'read',
  strategy: Strategy.LOCAL,
  browser: false,
  args: [
    {
      "name": "target",
      "positional": true,
      "required": true,
      "help": "Symbol or file to assess"
    },
    {
      "name": "repo",
      "help": "Repository id or owner/name (defaults to the connected repo)"
    },
    {
      "name": "limit",
      "type": "number",
      "default": 30,
      "help": "Maximum number of ranked files"
    },
    {
      "name": "max-seeds",
      "type": "number",
      "default": 8,
      "help": "Number of seed nodes to fan out from"
    }
  ],
  columns: ["file","risk","tests","nodes","commit"],
  func: async (kwargs) => {
    const args = {};
    if (kwargs.repo) args.repository_id = String(kwargs.repo);
    if (kwargs.target !== undefined) args.target = String(kwargs.target);
    if (kwargs.limit !== undefined) args.limit = Number(kwargs.limit);
    if (kwargs.max-seeds !== undefined) args.max_seeds = Number(kwargs.max-seeds);

    const payload = await mcpCall('impact_and_risk', args);
    return rowsFrom(payload, (row) => ({
      file: row.file ?? row.path ?? row.src,
      risk: row.risk ?? row.score,
      tests: row.tests ?? row.test_count ?? row.linked_tests,
      nodes: row.nodes ?? row.n_nodes,
    }), ["files","ranked_files","results"]);
  },
});
