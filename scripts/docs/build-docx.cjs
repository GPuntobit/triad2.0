const fs = require('fs');
const path = require('path');
const htmlToDocx = require('html-to-docx');

const root = path.join(__dirname, '..', '..');
const libroDir = path.join(root, 'docs', 'libro');
let html = fs.readFileSync(path.join(libroDir, 'libro.html'), 'utf8');

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
    margins: { top: 850, right: 680, bottom: 850, left: 680 },
    pageNumber: true,
    footer: true,
    skipFirstHeaderFooter: true
  }, '<p style="text-align: center;"></p>');
  fs.writeFileSync(path.join(root, 'docs', 'libro', 'libro.docx'), buffer);
  console.log('wrote libro.docx, size:', buffer.length);
})();