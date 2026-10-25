/**
 * graphify find — locate where a symbol is defined in the indexed codebase.
 */

import { cli, Strategy } from '@agentrhq/webcmd/registry';
import { mcpCall, rowsFrom } from './client.js';

cli({
  site: 'graphify',
  name: 'find',
  description: 'Find where a symbol, function or class is defined in the indexed codebase',
  access: 'read',
  strategy: Strategy.LOCAL,
  browser: false,
  args: [
    { name: 'term', positional: true, required: true, help: 'Symbol name fragment to look for' },
    { name: 'repo', help: 'Repository id or owner/name (defaults to the connected repo)' },
    { name: 'limit', type: 'number', default: 30, help: 'Maximum number of matches' },
    { name: 'code-only', type: 'boolean', help: 'Exclude non-code matches' },
  ],
  columns: ['symbol', 'file', 'loc', 'kind', 'sig', 'commit'],
  func: async (kwargs) => {
    const args = { term: String(kwargs.term ?? '') };
    if (kwargs.repo) args.repository_id = String(kwargs.repo);
    if (kwargs.limit !== undefined) args.limit = Number(kwargs.limit);
    if (kwargs['code-only'] !== undefined) args.code_only = Boolean(kwargs['code-only']);

    const payload = await mcpCall('graphify_find', args);
    return rowsFrom(payload, (row) => ({
      symbol: row.label,
      file: row.src,
      loc: row.loc,
      kind: row.file_type,
      sig: row.sig,
    }), ['matches']);
  },
});
