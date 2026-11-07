// =====================================================================
//  contract.mjs — lettore del contratto del seed
//
//  Il contratto (seed/dev/certified-subset.txt) è la dichiarazione
//  macchina-leggibile dello stato del seed: envelope, primitivi §8
//  disponibili, divergenze dal comportamento di SPEC-CORE.md ancora
//  presenti. Le guardie statiche si attivano e disattivano in funzione
//  di questo file: quando una divergenza sparisce dal contratto (perché
//  il seed è stato corretto), la regola corrispondente si spegne da
//  sola, senza toccare il codice del guard.
//
//  Formato: sezioni [nome] + righe "chiave = valore"; '#' = commento.
// =====================================================================

/** Restituisce { sezione: { chiave: valore } } dal testo del contratto. */
export function parseContract(text) {
  const sections = {};
  let current = null;
  for (const rawLine of text.split('\n')) {
    const line = rawLine.trim();
    if (!line || line.startsWith('#')) continue;
    const sec = line.match(/^\[(.+)\]$/);
    if (sec) {
      current = sec[1].trim();
      if (!sections[current]) sections[current] = {};
      continue;
    }
    const kv = line.match(/^([^=]+?)\s*=\s*(.*)$/);
    if (!kv || !current) continue;
    sections[current][kv[1].trim()] = kv[2].trim();
  }
  return sections;
}

/** Numeri interi del contratto, con un default. */
export function contractInt(sections, section, key, fallback) {
  const raw = sections?.[section]?.[key];
  if (raw === undefined) return fallback;
  const n = Number.parseInt(raw, 10);
  return Number.isNaN(n) ? fallback : n;
}

/** true se il contratto dichiara la divergenza (quindi la regola e' attiva). */
export function hasDivergence(sections, id) {
  return Object.prototype.hasOwnProperty.call(sections?.divergence ?? {}, id);
}

/** true se il contratto dichiara il primitivo §8 come disponibile. */
export function isAvailable(sections, name) {
  return (sections?.available ?? {})[name] === 'yes';
}
