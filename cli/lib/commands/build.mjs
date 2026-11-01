/**
 * Build standalone: non piu' supportato (nessuna dipendenza Julia).
 * Il runtime predefinito e' il seed in codice macchina.
 */
export async function buildStandalone(options = {}) {
  console.log('==> Build standalone non disponibile: nessuna dipendenza da Julia.');
  console.log('    Usa il seed in codice macchina (bin/triad / seed/<piattaforma>/seed).');
  return true;
}

export async function handleBuildStandalone(options) {
  try { return await buildStandalone(options); }
  catch (error) { console.error(`Errore: ${error.message}`); return false; }
}

