const fs = require('fs');
const path = require('path');
const htmlToDocx = require('html-to-docx');

const root = path.join(__dirname, '..', '..');
const libroDir = path.join(root, 'docs', 'libro');
let html = fs.readFileSync(path.join(libroDir, 'libro.html'), 'utf8');

// html-to-docx non decodifica l'entità numerica &#39; (apostrofo) generata dal TOC:
// la sostituzione con il carattere reale è sicura anche dentro gli attributi,
// che sono delimitati da virgolette doppie.
html = html.replace(/&#39;/g, "'");

// Remove webp images (not supported by every version of Word)
html = html.replace(/<img[^>]*webp[^>]*>/gi, '');

// html-to-docx embeds only http(s) or data-URI images: local images
// (cover, logo) must be turned into data-URIs, otherwise they are lost.
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
    title: 'The Book of Triad',
    creator: 'GPuntobit',
    description: 'The Book of Triad',
    font: 'Times New Roman',
    fontSize: 22,
    complexScriptFontSize: 22,
    pageSize: { width: 8640, height: 12960 },
    // Margini KDP: gutter interno >= 0.625" (15.875mm) per 301-400 pagine.
    // html-to-docx non scrive w:mirrorMargins, ma il layout del PDF e' comunque
    // a margini equi: 1080 twips = 19.05mm (0.75") su tutti i lati, stessa
    // geometria su ogni pagina, come Il-libro-di-triad.pdf.
    // header/footer/gutter vanno passati espliciti: altrimenti html-to-docx scrive
    // "undefined" (OOXML invalido) negli attributi w:header/w:footer/w:gutter.
    margins: { top: 1080, right: 1080, bottom: 1080, left: 1080, header: 720, footer: 720, gutter: 0 },
    pageNumber: true,
    footer: true,
    skipFirstHeaderFooter: true
  }, '<p style="text-align: center;"></p>');
  fs.writeFileSync(path.join(root, 'docs', 'libro', 'libro.docx'), buffer);
  console.log('wrote libro.docx, size:', buffer.length);
})();