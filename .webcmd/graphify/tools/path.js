/**
 * graphify path — the most confident connecting path between two symbols.
 *
 * `shortest_path` returns a resolved pair plus a list of path hops, so this
 * command emits one row per hop.
 */

import { cli, Strategy } from '@agentrhq/webcmd/registry';
import { mcpCall, unwrap, freshnessOf } from './lib/client.js';

cli({
  site: 'graphify',
  name: 'path',
  description: 'Show the most confident connecting path between two symbols',
  access: 'read',
  strategy: Strategy.LOCAL,
  browser: false,
  args: [
    { name: 'src', positional: true, required: true, help: 'Source symbol' },
    { name: 'tgt', required: true, help: 'Target symbol' },
    { name: 'repo', help: 'Repository id or owner/name (defaults to the connected repo)' },
  ],
  columns: ['hop', 'src', 'tgt', 'cost', 'hops', 'commit'],
  func: async (kwargs) => {
    const args = {
      src: String(kwargs.src ?? ''),
      tgt: String(kwargs.tgt ?? ''),
      ...(kwargs.repo ? { repository_id: String(kwargs.repo) } : {}),
    };

    const payload = await mcpCall('shortest_path', args);
    const data = unwrap(payload);
    const meta = freshnessOf(data);
    const hops = Array.isArray(data?.path) ? data.path : [];
    const resolved = data?.resolved ?? {};

    if (hops.length === 0) {
      return [
        {
          hop: 0,
          src: resolved.src,
          tgt: resolved.tgt,
          cost: data?.cost,
          hops: data?.hops,
          ...meta,
        },
      ];
    }

    return hops.map((hop, index) => ({
      hop: index + 1,
      src: resolved.src,
      tgt: resolved.tgt,
      cost: data?.cost,
      hops: data?.hops,
      path: hop,
      ...meta,
    }));
  },
});
