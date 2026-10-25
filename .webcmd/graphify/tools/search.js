/**
 * graphify search — search the indexed codebases for a symbol name.
 *
 * `search` returns its own envelope ({results}) with items shaped
 * {id, title, url, source_file, source_location, ...}.
 */

import { cli, Strategy } from '@agentrhq/webcmd/registry';
import { mcpCall, unwrap } from './lib/client.js';

cli({
  site: 'graphify',
  name: 'search',
  description: 'Search the indexed codebases for definitions matching a term',
  access: 'read',
  strategy: Strategy.LOCAL,
  browser: false,
  args: [
    { name: 'query', positional: true, required: true, help: 'Symbol name fragment' },
    { name: 'repo', help: 'Repository id or owner/name (defaults to the connected repo)' },
  ],
  columns: ['id', 'symbol', 'file', 'loc', 'url'],
  func: async (kwargs) => {
    const args = {
      query: String(kwargs.query ?? ''),
      ...(kwargs.repo ? { repository_id: String(kwargs.repo) } : {}),
    };

    const payload = await mcpCall('search', args);
    const data = unwrap(payload);
    const results = Array.isArray(data?.results) ? data.results : Array.isArray(data) ? data : [];

    return results.map((row) => ({
      id: row.id,
      symbol: row.symbol ?? (row.title ? String(row.title).split(' -- ')[0] : undefined),
      file: row.source_file ?? row.file ?? row.src ?? row.path,
      loc: row.source_location ?? row.loc,
      url: row.url,
      title: row.title,
    }));
  },
});
