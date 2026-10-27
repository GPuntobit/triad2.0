const fs = require('fs');
const path = require('path');
const htmlToDocx = require('html-to-docx');

const root = 'c:\\Users\\xbos\\Documents\\progetti\\triad2.0';
const html = fs.readFileSync(path.join(root, 'docs', 'libro', 'libro.html'), 'utf8');

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
    skipFirstHeaderFooter: true
  });
  fs.writeFileSync(path.join(root, 'docs', 'libro', 'libro.docx'), buffer);
  console.log('scritto libro.docx, size:', buffer.length);
})();