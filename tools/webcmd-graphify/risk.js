/**
 * graphify risk — change impact ranked by linked test coverage.
 *
 * `impact_and_risk` nests the impacted files under `result.impact.files` and
 * returns the linked tests next to them, so this command reads both and
 * reports one row per impacted file.
 */

import { cli, Strategy } from '@agentrhq/webcmd/registry';
import { mcpCall, unwrap, freshnessOf } from './lib/client.js';

cli({
  site: 'graphify',
  name: 'risk',
  description: 'Rank change-impact hotspots by their linked test coverage',
  access: 'read',
  strategy: Strategy.LOCAL,
  browser: false,
  args: [
    { name: 'target', positional: true, required: true, help: 'Symbol or file to assess' },
    { name: 'repo', help: 'Repository id or owner/name (defaults to the connected repo)' },
    { name: 'limit', type: 'number', default: 30, help: 'Maximum number of ranked files' },
    { name: 'max-seeds', type: 'number', default: 8, help: 'Number of seed nodes to fan out from' },
  ],
  columns: ['file', 'nodes', 'tests', 'untested', 'commit'],
  func: async (kwargs) => {
    const args = {
      target: String(kwargs.target ?? ''),
      ...(kwargs.repo ? { repository_id: String(kwargs.repo) } : {}),
      ...(kwargs.limit !== undefined ? { limit: Number(kwargs.limit) } : {}),
      ...(kwargs['max-seeds'] !== undefined ? { max_seeds: Number(kwargs['max-seeds']) } : {}),
    };

    const payload = await mcpCall('impact_and_risk', args);
    const data = unwrap(payload);
    const meta = freshnessOf(data);

    const files = data?.impact?.files ?? data?.files ?? [];
    const tests = data?.tests ?? [];
    const testCount = Array.isArray(tests) ? tests.length : 0;

    if (!Array.isArray(files) || files.length === 0) {
      return [
        {
          file: data?.target ?? args.target,
          nodes: 0,
          tests: testCount,
          untested: testCount === 0 ? 'yes' : 'no',
          ...meta,
        },
      ];
    }

    return files.map((file) => ({
      file: file.src ?? file.file ?? file.path,
      nodes: file.nodes?.length ?? file.n_nodes ?? 0,
      tests: testCount,
      untested: testCount === 0 ? 'yes' : 'no',
      ...meta,
    }));
  },
});
