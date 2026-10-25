/**
 * Minimal MCP (streamable HTTP) client for the Graphify control plane.
 *
 * Credentials are resolved at runtime and never logged:
 *   1. GRAPHIFY_TOKEN / GRAPHIFY_API_KEY environment variable
 *   2. mcpServers.graphify.headers.Authorization in the local MCP config
 *      (defaults to ~/.minimax/mcp.json, override with MINIMAX_MCP_CONFIG)
 */

import { readFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { join } from 'node:path';

const MCP_ENDPOINT = process.env.GRAPHIFY_MCP_URL ?? 'https://api.graphify.com/v1/mcp';

const CLIENT_INFO = { name: 'webcmd-graphify', version: '0.1.0' };

function resolveToken() {
  const fromEnv = process.env.GRAPHIFY_TOKEN ?? process.env.GRAPHIFY_API_KEY;
  if (fromEnv && fromEnv.trim()) return fromEnv.trim();

  const configPath = process.env.MINIMAX_MCP_CONFIG ?? join(homedir(), '.minimax', 'mcp.json');
  try {
    const config = JSON.parse(readFileSync(configPath, 'utf-8'));
    const auth = config?.mcpServers?.graphify?.headers?.Authorization;
    if (auth && String(auth).trim()) return String(auth).trim();
  } catch {
    // fall through to the error below
  }

  throw new Error(
    'Graphify credentials not found. Set GRAPHIFY_TOKEN, or configure ' +
      'mcpServers.graphify.headers.Authorization in the MCP config file.',
  );
}

/** Parse an SSE payload into its JSON-RPC messages. */
function parseSse(body) {
  const messages = [];
  const events = body.split(/\r?\n\r?\n/);

  for (const event of events) {
    const data = event
      .split(/\r?\n/)
      .filter((line) => line.startsWith('data:'))
      .map((line) => line.slice(5).trim())
      .join('');

    if (!data || data === '[DONE]') continue;
    try {
      messages.push(JSON.parse(data));
    } catch {
      // ignore non-JSON keep-alive frames
    }
  }

  return messages;
}

function firstText(result) {
  const content = result?.content;
  if (Array.isArray(content)) {
    const textBlock = content.find((item) => item?.type === 'text' && typeof item.text === 'string');
    if (textBlock) return textBlock.text;
  }
  return '';
}

function tryParseJson(text) {
  if (typeof text !== 'string' || !text) return undefined;
  try {
    return JSON.parse(text);
  } catch {
    return undefined;
  }
}

/** Call a Graphify MCP tool and return its structured payload. */
export async function mcpCall(toolName, args = {}) {
  const headers = {
    'Content-Type': 'application/json',
    Accept: 'application/json, text/event-stream',
    Authorization: resolveToken(),
  };

  const initialize = await fetch(MCP_ENDPOINT, {
    method: 'POST',
    headers,
    body: JSON.stringify({
      jsonrpc: '2.0',
      id: 1,
      method: 'initialize',
      params: {
        protocolVersion: '2025-06-18',
        capabilities: {},
        clientInfo: CLIENT_INFO,
      },
    }),
  });

  if (!initialize.ok) {
    throw new Error(`Graphify initialize failed: HTTP ${initialize.status}`);
  }

  const sessionId = initialize.headers.get('mcp-session-id');
  await initialize.text();
  if (sessionId) headers['Mcp-Session-Id'] = sessionId;

  await fetch(MCP_ENDPOINT, {
    method: 'POST',
    headers,
    body: JSON.stringify({ jsonrpc: '2.0', method: 'notifications/initialized', params: {} }),
  });

  const call = await fetch(MCP_ENDPOINT, {
    method: 'POST',
    headers,
    body: JSON.stringify({
      jsonrpc: '2.0',
      id: 2,
      method: 'tools/call',
      params: { name: toolName, arguments: args },
    }),
  });

  const body = await call.text();
  const messages = parseSse(body);
  const message =
    messages.find((item) => item && typeof item === 'object' && ('result' in item || 'error' in item)) ??
    tryParseJson(body);

  if (!message) throw new Error(`Graphify returned no JSON-RPC response for ${toolName}.`);
  if (message.error) {
    throw new Error(`Graphify error: ${message.error.message ?? JSON.stringify(message.error)}`);
  }

  const result = message.result ?? {};
  if (result.isError) throw new Error(`Graphify tool ${toolName} failed: ${firstText(result)}`);

  return result.structuredContent ?? tryParseJson(firstText(result)) ?? { text: firstText(result) };
}

/**
 * Graphify wraps tool output in an envelope. Some tools return `result` as an
 * object, others as a JSON string. Unwrap it so commands see the payload.
 */
export function unwrap(payload) {
  if (payload && typeof payload === 'object' && 'result' in payload) {
    const parsed = tryParseJson(payload.result);
    if (parsed !== undefined) return parsed;
    if (payload.result && typeof payload.result === 'object') return payload.result;
  }
  return payload;
}

/** Pick the row array out of a payload, whatever shape it uses. */
export function pickRows(data, keys = []) {
  if (Array.isArray(data)) return data;
  if (data && typeof data === 'object') {
    for (const key of [...keys, 'repositories', 'results', 'matches', 'definitions', 'nodes', 'symbols', 'items']) {
      if (Array.isArray(data[key])) return data[key];
    }
    const arrays = Object.entries(data).filter(([, value]) => Array.isArray(value));
    if (arrays.length === 1) return arrays[0][1];
  }
  return [data];
}

function truncate(value, limit) {
  return value.length > limit ? `${value.slice(0, limit)}…` : value;
}

/** Flatten a row into primitives so the CLI table stays readable. */
export function compactRow(row) {
  if (row === null || row === undefined) return { value: String(row) };
  if (typeof row !== 'object') return { value: String(row) };

  const out = {};
  for (const [key, value] of Object.entries(row)) {
    if (value === undefined || value === null) continue;
    if (typeof value === 'string') out[key] = truncate(value, 3000);
    else if (typeof value === 'number' || typeof value === 'boolean') out[key] = value;
    else if (Array.isArray(value)) {
      const primitive = value.every((item) => ['string', 'number', 'boolean'].includes(typeof item));
      out[key] = primitive
        ? value.slice(0, 10).map((item) => (typeof item === 'string' ? truncate(item, 200) : item))
        : truncate(JSON.stringify(value), 1500);
    } else out[key] = truncate(JSON.stringify(value), 1500);
  }
  return out;
}

/** Index freshness metadata, when the payload carries it. */
export function freshnessOf(data) {
  const freshness = data?.freshness ?? {};
  return {
    commit: freshness.commit,
    indexedAt: freshness.indexed_at,
    age: freshness.age,
  };
}

/**
 * Build CLI rows from an MCP payload.
 * `mapper` receives the raw row; `keys` steers array extraction.
 */
export function rowsFrom(payload, mapper, keys = []) {
  const data = unwrap(payload);
  const rows = pickRows(data, keys);
  const meta = freshnessOf(data);

  return rows.map((row) => {
    const mapped = mapper ? mapper(row) : compactRow(row);
    const flat = compactRow(mapped);
    for (const [key, value] of Object.entries(meta)) {
      if (value !== undefined && flat[key] === undefined) flat[key] = value;
    }
    return flat;
  });
}
