/**
 * Deterministic generator for the webcmd Graphify plugin.
 *
 * Usage: node gen.mjs <target-dir>
 *
 * The plugin source lives inside a git repository whose workflow (commit,
 * clean, checkout) can wipe generated files, so this script rebuilds the
 * whole command surface from one declarative table.
 */

import { copyFileSync, mkdirSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const out = process.argv[2];
if (!out) {
  console.error('usage: node gen.mjs <target-dir>');
  process.exit(2);
}

const repoArg = { name: 'repo', help: 'Repository id or owner/name (defaults to the connected repo)' };

const commands = [
  {
    file: 'repos.js',
    name: 'repos',
    description: 'List repositories indexed by Graphify with index readiness',
    tool: 'list_repositories',
    columns: ['fullName', 'repositoryId', 'status', 'queryable', 'nodeCount', 'provider', 'defaultBranch'],
    map: {
      fullName: 'row.fullName',
      repositoryId: 'row.repositoryId',
      status: 'row.status',
      queryable: 'row.queryable',
      nodeCount: 'row.nodeCount',
      provider: 'row.provider',
      defaultBranch: 'row.defaultBranch',
    },
  },
  {
    file: 'stats.js',
    name: 'stats',
    description: 'Show Graphify index statistics for a repository',
    tool: 'graph_stats',
    args: [repoArg],
    columns: ['nodes', 'edges', 'communities', 'model', 'commit', 'indexedAt'],
    map: {
      nodes: 'row.n_nodes',
      edges: 'row.n_edges',
      communities: 'row.n_communities',
      model: 'row.model',
    },
  },
  {
    file: 'find.js',
    name: 'find',
    description: 'Find where a symbol, function or class is defined in the indexed codebase',
    tool: 'graphify_find',
    args: [
      { name: 'term', positional: true, required: true, help: 'Symbol name fragment to look for' },
      repoArg,
      { name: 'limit', type: 'number', default: 30, help: 'Maximum number of matches' },
      { name: 'code-only', type: 'boolean', help: 'Exclude non-code matches' },
    ],
    extra: {
      term: { flag: 'term', type: 'string' },
      limit: { flag: 'limit', type: 'number' },
      code_only: { flag: 'code-only', type: 'boolean' },
    },
    keys: ['matches'],
    columns: ['symbol', 'file', 'loc', 'kind', 'sig', 'commit'],
    map: {
      symbol: 'row.label ?? row.symbol',
      file: 'row.src ?? row.file',
      loc: 'row.loc',
      kind: 'row.file_type ?? row.kind',
      sig: 'row.sig',
      id: 'row.id',
    },
  },
  {
    file: 'files.js',
    name: 'files',
    description: 'List the indexed source files of a repository, ranked by relevance',
    tool: 'graphify_rank_files',
    args: [
      {
        name: 'question',
        default: 'all source files in this repository',
        help: 'Optional relevance question used to rank the files',
      },
      repoArg,
      { name: 'limit', type: 'number', default: 50, help: 'Maximum number of files to return' },
    ],
    extra: {
      question: { flag: 'question', type: 'string' },
      limit: { flag: 'limit', type: 'number' },
    },
    keys: ['ranked_files'],
    columns: ['file', 'score', 'nodes', 'seeds', 'commit'],
    map: {
      file: 'row.src ?? row.file',
      score: 'row.score',
      nodes: 'row.n_nodes',
      seeds: 'row.seeds',
    },
  },
  {
    file: 'callers.js',
    name: 'callers',
    description: 'List the callers of a symbol in the indexed codebase',
    tool: 'graphify_callers',
    args: [
      { name: 'symbol', positional: true, required: true, help: 'Symbol to inspect' },
      repoArg,
      { name: 'limit', type: 'number', default: 25, help: 'Maximum number of callers' },
      { name: 'strict-calls', type: 'boolean', help: 'Count only resolved call edges' },
    ],
    extra: {
      symbol: { flag: 'symbol', type: 'string' },
      limit: { flag: 'limit', type: 'number' },
      strict_calls: { flag: 'strict-calls', type: 'boolean' },
    },
    keys: ['callers', 'results', 'matches'],
    columns: ['symbol', 'file', 'loc', 'kind', 'commit'],
    map: {
      symbol: 'row.symbol ?? row.label ?? row.caller',
      file: 'row.file ?? row.src ?? row.from_file',
      loc: 'row.loc',
      kind: 'row.rel ?? row.kind ?? row.type',
    },
  },
  {
    file: 'callees.js',
    name: 'callees',
    description: 'List the functions and symbols called by a symbol',
    tool: 'graphify_callees',
    args: [
      { name: 'symbol', positional: true, required: true, help: 'Symbol to inspect' },
      repoArg,
      { name: 'limit', type: 'number', default: 25, help: 'Maximum number of callees' },
      { name: 'strict-calls', type: 'boolean', help: 'Count only resolved call edges' },
    ],
    extra: {
      symbol: { flag: 'symbol', type: 'string' },
      limit: { flag: 'limit', type: 'number' },
      strict_calls: { flag: 'strict-calls', type: 'boolean' },
    },
    keys: ['callees', 'results', 'matches'],
    columns: ['symbol', 'file', 'loc', 'kind', 'commit'],
    map: {
      symbol: 'row.symbol ?? row.label ?? row.callee',
      file: 'row.file ?? row.src ?? row.to_file',
      loc: 'row.loc',
      kind: 'row.rel ?? row.kind ?? row.type',
    },
  },
  {
    file: 'impact.js',
    name: 'impact',
    description: 'Show the blast radius of changing a symbol or file',
    tool: 'graphify_impact',
    args: [
      { name: 'target', positional: true, required: true, help: 'Symbol or file to assess' },
      repoArg,
      { name: 'limit', type: 'number', default: 40, help: 'Maximum number of impacted nodes' },
      { name: 'max-seeds', type: 'number', default: 8, help: 'Number of seed nodes to fan out from' },
    ],
    extra: {
      target: { flag: 'target', type: 'string' },
      limit: { flag: 'limit', type: 'number' },
      max_seeds: { flag: 'max-seeds', type: 'number' },
    },
    keys: ['files', 'seeds', 'contained'],
    columns: ['file', 'nodes', 'symbol', 'commit'],
    map: {
      file: 'row.src ?? row.file ?? row.path',
      nodes: 'row.nodes?.length ?? row.n_nodes',
      symbol: 'row.label ?? row.symbol',
    },
  },
  {
    file: 'tests.js',
    name: 'tests',
    description: 'List the tests linked to a symbol or file in the indexed codebase',
    tool: 'graphify_tests_for',
    args: [
      {
        name: 'target',
        positional: true,
        required: true,
        help: 'Symbol name or repository-relative file path',
      },
      repoArg,
      { name: 'limit', type: 'number', default: 25, help: 'Maximum number of linked tests' },
    ],
    extra: {
      target: { flag: 'target', type: 'string' },
      limit: { flag: 'limit', type: 'number' },
    },
    keys: ['tests', 'results', 'matches'],
    columns: ['test', 'file', 'loc', 'via', 'match', 'commit'],
    map: {
      test: 'row.test ?? row.label ?? row.symbol ?? row.name',
      file: 'row.file ?? row.src ?? row.path',
      loc: 'row.loc',
      via: 'row.via',
      match: 'row.match',
    },
  },
  {
    file: 'neighbors.js',
    name: 'neighbors',
    description: 'Map the dependencies and dependents of a file in the indexed codebase',
    tool: 'graphify_file_neighbors',
    args: [
      { name: 'file', positional: true, required: true, help: 'Repository-relative file path' },
      repoArg,
      { name: 'limit', type: 'number', default: 40, help: 'Maximum number of neighbors per side' },
    ],
    extra: {
      file: { flag: 'file', type: 'string' },
      limit: { flag: 'limit', type: 'number' },
    },
    keys: ['symbols', 'neighbor_files', 'files', 'results'],
    columns: ['file', 'direction', 'symbol', 'loc', 'commit'],
    map: {
      file: 'row.file ?? row.path ?? row.src',
      direction: 'row.direction ?? row.rel ?? row.relation ?? row.kind',
      symbol: 'row.symbol ?? row.label',
      loc: 'row.loc',
    },
  },
  {
    file: 'trace.js',
    name: 'trace',
    description: 'Trace the directed call paths between two symbols',
    tool: 'graphify_trace',
    args: [
      { name: 'src', positional: true, required: true, help: 'Source symbol' },
      { name: 'tgt', required: true, help: 'Target symbol' },
      repoArg,
      { name: 'paths', type: 'number', default: 3, help: 'Number of distinct call paths to return' },
      { name: 'strict-calls', type: 'boolean', help: 'Count only resolved call edges' },
    ],
    extra: {
      src: { flag: 'src', type: 'string' },
      tgt: { flag: 'tgt', type: 'string' },
      k_paths: { flag: 'paths', type: 'number' },
      strict_calls: { flag: 'strict-calls', type: 'boolean' },
    },
    keys: ['paths', 'results'],
    columns: ['src', 'tgt', 'resolved', 'commit'],
    map: {
      src: 'row.src ?? row.source',
      tgt: 'row.tgt ?? row.target',
      resolved: 'row.resolved',
      path: 'row.path',
    },
  },
  {
    file: 'node.js',
    name: 'node',
    description: "Show a symbol definition with its immediate graph neighbours",
    tool: 'graphify_node',
    args: [
      { name: 'symbol', positional: true, required: true, help: 'Symbol to read' },
      repoArg,
      { name: 'limit', type: 'number', default: 12, help: 'Maximum number of neighbours' },
    ],
    extra: {
      symbol: { flag: 'symbol', type: 'string' },
      limit: { flag: 'limit', type: 'number' },
    },
    keys: ['nodes', 'definitions', 'results'],
    columns: ['symbol', 'file', 'loc', 'kind', 'text', 'commit'],
    map: {
      symbol: 'row.symbol ?? row.label ?? row.name',
      file: 'row.file ?? row.src ?? row.path',
      loc: 'row.loc',
      kind: 'row.kind ?? row.type',
      text: 'row.text ?? row.body ?? row.source ?? row.content',
    },
  },
  {
    file: 'references.js',
    name: 'references',
    description: 'List non-call references (reads, mentions, uses) of a symbol',
    tool: 'graphify_references',
    args: [
      { name: 'symbol', positional: true, required: true, help: 'Symbol to inspect' },
      repoArg,
      { name: 'limit', type: 'number', default: 25, help: 'Maximum number of references' },
    ],
    extra: {
      symbol: { flag: 'symbol', type: 'string' },
      limit: { flag: 'limit', type: 'number' },
    },
    keys: ['references', 'results', 'matches'],
    columns: ['symbol', 'file', 'loc', 'kind', 'commit'],
    map: {
      symbol: 'row.symbol ?? row.label',
      file: 'row.file ?? row.src ?? row.path',
      loc: 'row.loc',
      kind: 'row.kind ?? row.type',
    },
  },
  {
    file: 'fetch.js',
    name: 'fetch',
    description: 'Read a search result body by its node id',
    tool: 'fetch',
    args: [{ name: 'id', positional: true, required: true, help: 'Node id returned by search' }],
    extra: {
      id: { flag: 'id', type: 'string' },
    },
    keys: ['results', 'nodes'],
    columns: ['id', 'symbol', 'file', 'loc', 'text', 'commit'],
    map: {
      id: 'row.id',
      symbol: 'row.symbol ?? row.label',
      file: 'row.file ?? row.src ?? row.path',
      loc: 'row.loc',
      text: 'row.text ?? row.body ?? row.source ?? row.content',
    },
  },
  {
    file: 'subgraph.js',
    name: 'subgraph',
    description: 'Render the graph neighbourhood around one or more seed nodes',
    tool: 'graphify_render_subgraph',
    args: [
      { name: 'seeds', required: true, help: 'Seed node ids or symbol names, comma separated' },
      repoArg,
      { name: 'depth', type: 'number', default: 1, help: 'Hops to expand from each seed' },
      { name: 'node-limit', type: 'number', default: 60, help: 'Maximum number of nodes to reveal' },
      { name: 'edge-limit', type: 'number', default: 200, help: 'Maximum number of edges to return' },
    ],
    customBuild:
      "const args = {\n      seeds: listArg(kwargs.seeds) ?? [],\n      ...(kwargs.repo ? { repository_id: String(kwargs.repo) } : {}),\n      ...(kwargs.depth !== undefined ? { depth: Number(kwargs.depth) } : {}),\n      ...(kwargs['node-limit'] !== undefined ? { node_limit: Number(kwargs['node-limit']) } : {}),\n      ...(kwargs['edge-limit'] !== undefined ? { edge_limit: Number(kwargs['edge-limit']) } : {}),\n    };",
    keys: ['nodes', 'results'],
    columns: ['id', 'symbol', 'file', 'loc', 'kind', 'commit'],
    map: {
      id: 'row.id',
      symbol: 'row.symbol ?? row.label ?? row.name',
      file: 'row.source_file ?? row.file ?? row.src ?? row.path',
      loc: 'row.source_location ?? row.loc',
      kind: 'row.file_type ?? row.kind ?? row.type',
    },
  },
  {
    file: 'memories.js',
    name: 'memories',
    description: 'Show what Graphify remembers about a specific file or symbol',
    tool: 'graphify_memories_about',
    args: [
      {
        name: 'target',
        positional: true,
        required: true,
        help: 'Repository-relative file path or symbol name',
      },
      repoArg,
      { name: 'k', type: 'number', default: 5, help: 'Maximum number of memories to return' },
    ],
    extra: {
      target: { flag: 'target', type: 'string' },
      k: { flag: 'k', type: 'number' },
    },
    keys: ['records', 'facts', 'results'],
    columns: ['id', 'subject', 'kind', 'text', 'date'],
    map: {
      id: 'row.id ?? row.record_id',
      subject: 'row.subject ?? row.title',
      kind: 'row.kind ?? row.type',
      text: 'row.text ?? row.content ?? row.body',
      date: 'row.recorded_at ?? row.observed_at ?? row.date',
    },
  },
  {
    file: 'remember.js',
    name: 'remember',
    description: 'Save a durable note (decision, constraint, gotcha) for the workspace',
    tool: 'remember',
    access: 'write',
    args: [
      {
        name: 'text',
        positional: true,
        required: true,
        help: 'One self-contained statement to remember',
      },
      repoArg,
      { name: 'tags', help: 'Comma-separated labels' },
      { name: 'session', help: 'Optional session id grouping related notes' },
      {
        name: 'occurred-at',
        help: 'ISO timestamp the note is about, when it differs from now',
      },
    ],
    customBuild:
      "const tags = String(kwargs.tags ?? '')\n      .split(',')\n      .map((tag) => tag.trim())\n      .filter(Boolean);\n    const args = {\n      text: String(kwargs.text ?? ''),\n      ...(kwargs.repo ? { repository_id: String(kwargs.repo) } : {}),\n      ...(tags.length ? { tags } : {}),\n      ...(kwargs.session ? { session_id: String(kwargs.session) } : {}),\n      ...(kwargs['occurred-at'] ? { occurred_at: String(kwargs['occurred-at']) } : {}),\n    };",
    keys: ['records', 'results'],
    columns: ['id', 'status', 'text', 'tags'],
    map: {
      id: 'row.id ?? row.record_id',
      status: "row.status ?? 'saved'",
      text: 'row.text ?? row.subject',
      tags: 'row.tags',
    },
  },
];

function buildArgsSource(command) {
  if (command.customBuild) return command.customBuild;

  const lines = ['const args = {};'];
  if (command.args?.some((arg) => arg.name === 'repo')) {
    lines.push('if (kwargs.repo) args.repository_id = String(kwargs.repo);');
  }
  for (const [toolKey, spec] of Object.entries(command.extra ?? {})) {
    const flag = spec.flag ?? toolKey;
    // Hyphenated flags must use bracket notation: kwargs['strict-calls'].
    const access = flag.includes('-') ? "kwargs['" + flag + "']" : 'kwargs.' + flag;
    const cast =
      spec.type === 'number'
        ? 'Number(' + access + ')'
        : spec.type === 'boolean'
          ? 'Boolean(' + access + ')'
          : 'String(' + access + ')';
    lines.push('if (' + access + ' !== undefined) args.' + toolKey + ' = ' + cast + ';');
  }
  return lines.join('\n    ');
}

function renderCommand(command) {
  const argsSource = buildArgsSource(command);
  const mapping = command.mapWith ?? command.map;
  const mapBody = Object.entries(mapping)
    .map(([key, expr]) => `      ${key}: ${expr},`)
    .join('\n');
  const mapSignature = command.mapWith ? '(row, data)' : '(row)';

  return `/**
 * graphify ${command.name} â€” ${command.description}
 */

import { cli, Strategy } from '@agentrhq/webcmd/registry';
import { mcpCall, rowsFrom, listArg } from './lib/client.js';

cli({
  site: 'graphify',
  name: '${command.name}',
  description: '${command.description}',
  access: '${command.access ?? 'read'}',
  strategy: Strategy.LOCAL,
  browser: false,
  args: ${JSON.stringify(command.args ?? [], null, 2).replace(/\n/g, '\n  ')},
  columns: ${JSON.stringify(command.columns ?? [])},
  func: async (kwargs) => {
    ${argsSource}

    const payload = await mcpCall('${command.tool}', args);
    return rowsFrom(payload, ${mapSignature} => ({
${mapBody}
    }), ${JSON.stringify(command.keys ?? [])});
  },
});
`;
}

mkdirSync(join(out, 'lib'), { recursive: true });

for (const command of commands) {
  writeFileSync(join(out, command.file), renderCommand(command), 'utf-8');
}

copyFileSync(join(here, 'lib-client.js'), join(out, 'lib', 'client.js'));
copyFileSync(join(here, 'query.js'), join(out, 'query.js'));
copyFileSync(join(here, 'risk.js'), join(out, 'risk.js'));
copyFileSync(join(here, 'path.js'), join(out, 'path.js'));
copyFileSync(join(here, 'recall.js'), join(out, 'recall.js'));
copyFileSync(join(here, 'expand.js'), join(out, 'expand.js'));
copyFileSync(join(here, 'search.js'), join(out, 'search.js'));

// Keep the generator inside the plugin so the command surface can be rebuilt
// from source after a checkout, a clean, or a fresh clone.
mkdirSync(join(out, 'tools'), { recursive: true });
copyFileSync(join(here, 'gen.mjs'), join(out, 'tools', 'generate.mjs'));
for (const source of [
  'query.js',
  'risk.js',
  'path.js',
  'recall.js',
  'expand.js',
  'search.js',
  'lib-client.js',
]) {
  copyFileSync(join(here, source), join(out, 'tools', source));
}
copyFileSync(join(here, 'README.md'), join(out, 'README.md'));

writeFileSync(
  join(out, 'webcmd-plugin.json'),
  `${JSON.stringify(
    {
      name: 'graphify',
      version: '1.0.0',
      description:
        'Graphify code-graph access for agents: find, query, trace, impact, test coverage and workspace memory',
      webcmd: '>=0.8.4',
      author: { name: 'Scorpion', handle: 'xbos' },
    },
    null,
    2,
  )}\n`,
  'utf-8',
);

writeFileSync(
  join(out, 'package.json'),
  `${JSON.stringify(
    {
      name: 'webcmd-plugin-graphify',
      version: '1.0.0',
      type: 'module',
      description:
        'Graphify code-graph access for agents: find, query, trace, impact, test coverage and workspace memory',
      peerDependencies: { '@agentrhq/webcmd': '>=0.8.4' },
    },
    null,
    2,
  )}\n`,
  'utf-8',
);

console.log(`generated ${commands.length} commands into ${out}`);
