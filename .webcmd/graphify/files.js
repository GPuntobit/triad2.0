/**
 * graphify files — list the source files the Graphify index knows about.
 */

import { cli, Strategy } from '@agentrhq/webcmd/registry';
import { mcpCall, rowsFrom } from './client.js';

cli({
  site: 'graphify',
  name: 'files',
  description: 'List the indexed source files of a repository, ranked by relevance',
  access: 'read',
  strategy: Strategy.LOCAL,
  browser: false,
  args: [
    {
      name: 'question',
      default: 'all source files in this repository',
      help: 'Optional relevance question used to rank the files',
    },
    { name: 'repo', help: 'Repository id or owner/name (defaults to the connected repo)' },
    { name: 'limit', type: 'number', default: 50, help: 'Maximum number of files to return' },
  ],
  columns: ['file', 'score', 'nodes', 'seeds', 'commit'],
  func: async (kwargs) => {
    const args = {
      question: String(kwargs.question ?? 'all source files in this repository'),
      limit: Number(kwargs.limit ?? 50),
    };
    if (kwargs.repo) args.repository_id = String(kwargs.repo);

    const payload = await mcpCall('graphify_rank_files', args);
    return rowsFrom(
      payload,
      (row) => ({
        file: row.src,
        score: row.score,
        nodes: row.n_nodes,
        seeds: row.seeds,
        reasons: row.reasons,
      }),
      ['ranked_files', 'files', 'results', 'matches'],
    );
  },
});
