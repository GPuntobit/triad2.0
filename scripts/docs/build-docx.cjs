const fs = require('fs');
const path = require('path');
const htmlToDocx = require('html-to-docx');

const root = path.join(__dirname, '..', '..');
const libroDir = path.join(root, 'docs', 'libro');
let html = fs.readFileSync(path.join(libroDir, 'libro.html'), 'utf8');

// Rimuovi immagini webp (non supportate da tutte le versioni di Word)
html = html.replace(/<img[^>]*webp[^>]*>/gi, '');

// html-to-docx incorpora solo immagini http(s) o data-URI: le immagini locali
// (copertina, logo) vanno trasformate in data-URI, altrimenti vengono perse.
const mimeByExt = {
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.webp': 'image/webp'
};
html = html.replace(/<img\b([^>]*?)\bsrc="([^"]+)"([^>]*)>/gi, (match, before, src, after) => {
  if (/^(?:data:|https?:)/i.test(src)) return match;
  const file = path.join(libroDir, decodeURIComponent(src));
  if (!fs.existsSync(file)) return match;
  const mime = mimeByExt[path.extname(file).toLowerCase()] || 'application/octet-stream';
  const data = fs.readFileSync(file).toString('base64');
  return `<img${before}src="data:${mime};base64,${data}"${after}>`;
});

(async () => {
  const buffer = await htmlToDocx(html, null, {
    title: 'Il libro di Triad',
    creator: 'GPuntobit',
    description: 'Il libro di Triad',
    font: 'Times New Roman',
    fontSize: 22,
    complexScriptFontSize: 22,
    pageSize: { width: 8640, height: 12960 },
    margins: { top: 850, right: 680, bottom: 850, left: 680 },
    pageNumber: true,
    footer: true,
    skipFirstHeaderFooter: true
  }, '<p style="text-align: center;"></p>');
  fs.writeFileSync(path.join(root, 'docs', 'libro', 'libro.docx'), buffer);
  console.log('scritto libro.docx, size:', buffer.length);
})();