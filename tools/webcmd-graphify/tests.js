/**
 * graphify tests â€” List the tests linked to a symbol or file in the indexed codebase
 */

import { cli, Strategy } from '@agentrhq/webcmd/registry';
import { mcpCall, rowsFrom, listArg } from './lib/client.js';

cli({
  site: 'graphify',
  name: 'tests',
  description: 'List the tests linked to a symbol or file in the indexed codebase',
  access: 'read',
  strategy: Strategy.LOCAL,
  browser: false,
  args: [
    {
      "name": "target",
      "positional": true,
      "required": true,
      "help": "Symbol name or repository-relative file path"
    },
    {
      "name": "repo",
      "help": "Repository id or owner/name (defaults to the connected repo)"
    },
    {
      "name": "limit",
      "type": "number",
      "default": 25,
      "help": "Maximum number of linked tests"
    }
  ],
  columns: ["test","file","loc","via","match","commit"],
  func: async (kwargs) => {
    const args = {};
    if (kwargs.repo) args.repository_id = String(kwargs.repo);
    if (kwargs.target !== undefined) args.target = String(kwargs.target);
    if (kwargs.limit !== undefined) args.limit = Number(kwargs.limit);

    const payload = await mcpCall('graphify_tests_for', args);
    return rowsFrom(payload, (row) => ({
      test: row.test ?? row.label ?? row.symbol ?? row.name,
      file: row.file ?? row.src ?? row.path,
      loc: row.loc,
      via: row.via,
      match: row.match,
    }), ["tests","results","matches"]);
  },
});
