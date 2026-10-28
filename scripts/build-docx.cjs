const fs = require('fs');
const path = require('path');
const htmlToDocx = require('html-to-docx');

const root = path.join(__dirname, '..');
let html = fs.readFileSync(path.join(root, 'docs', 'libro', 'libro.html'), 'utf8');

// Rimuovi immagini webp (non supportate da tutte le versioni di Word)
html = html.replace(/<img[^>]*webp[^>]*>/gi, '');

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