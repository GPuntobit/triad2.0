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
    margins: { top: 1440, right: 1440, bottom: 1440, left: 1440 }
  });
  fs.writeFileSync(path.join(root, 'docs', 'libro', 'libro.docx'), buffer);
  console.log('scritto libro.docx, size:', buffer.length);
})();