/**
 * graphify subgraph — Render the graph neighbourhood around one or more seed nodes
 */

import { cli, Strategy } from '@agentrhq/webcmd/registry';
import { mcpCall, rowsFrom, listArg } from './lib/client.js';

cli({
  site: 'graphify',
  name: 'subgraph',
  description: 'Render the graph neighbourhood around one or more seed nodes',
  access: 'read',
  strategy: Strategy.LOCAL,
  browser: false,
  args: [
    {
      "name": "seeds",
      "required": true,
      "help": "Seed node ids or symbol names, comma separated"
    },
    {
      "name": "repo",
      "help": "Repository id or owner/name (defaults to the connected repo)"
    },
    {
      "name": "depth",
      "type": "number",
      "default": 1,
      "help": "Hops to expand from each seed"
    },
    {
      "name": "node-limit",
      "type": "number",
      "default": 60,
      "help": "Maximum number of nodes to reveal"
    },
    {
      "name": "edge-limit",
      "type": "number",
      "default": 200,
      "help": "Maximum number of edges to return"
    }
  ],
  columns: ["id","symbol","file","kind","commit"],
  func: async (kwargs) => {
    const args = {
      seeds: listArg(kwargs.seeds) ?? [],
      ...(kwargs.repo ? { repository_id: String(kwargs.repo) } : {}),
      ...(kwargs.depth !== undefined ? { depth: Number(kwargs.depth) } : {}),
      ...(kwargs['node-limit'] !== undefined ? { node_limit: Number(kwargs['node-limit']) } : {}),
      ...(kwargs['edge-limit'] !== undefined ? { edge_limit: Number(kwargs['edge-limit']) } : {}),
    };

    const payload = await mcpCall('graphify_render_subgraph', args);
    return rowsFrom(payload, (row) => ({
      id: row.id,
      symbol: row.symbol ?? row.label ?? row.name,
      file: row.file ?? row.src ?? row.path,
      kind: row.kind ?? row.type,
    }), ["nodes","results"]);
  },
});
