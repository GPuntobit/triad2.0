const RAW_BASE = 'https://raw.githubusercontent.com/GPuntobit/triad2.0/main/';

const NAV = [
  { href: 'index.html', label: 'Home' },
  { href: 'pages/getting-started.html', label: 'Inizia' },
  { href: 'pages/language-tour.html', label: 'Tour' },
  { href: 'pages/spec.html', label: 'Spec' },
  { href: 'pages/tutorial.html', label: 'Tutorial' },
  { href: 'pages/apprendimento.html', label: 'Apprendimento' },
  { href: 'pages/examples.html', label: 'Esempi' },
  { href: 'pages/playground.html', label: 'Playground' },
  { href: 'pages/conformance.html', label: 'Conformance' },
  { href: 'pages/bootstrap.html', label: 'Bootstrap' },
  { href: 'pages/editors.html', label: 'Editor' },
  { href: 'pages/ai.html', label: 'AI' },
  { href: 'pages/status.html', label: 'Stato' },
];

function renderHeader(active) {
  const links = NAV.map(n => `<a href="${n.href}" ${n.label===active?'class="active" aria-current="page"':''}>${n.label}</a>`).join('');
  return `
<header class="site-header">
  <div class="container nav">
    <a class="brand" href="index.html"><span class="logo">T</span> Triad 2.0</a>
    <button class="nav-toggle" onclick="document.querySelector('.nav-links').classList.toggle('open')">☰</button>
    <nav class="nav-links">${links}</nav>
  </div>
</header>`;
}

function renderFooter() {
  return `
<footer class="site-footer">
  <div class="container">
    <div class="footer-grid">
      <div>
        <h4>Triad 2.0</h4>
        <p>Linguaggio di programmazione autonomo: sintassi a blocchi, tipi dichiarati, multiple dispatch, logica integrata, codice come dato.</p>
      </div>
      <div>
        <h4>Documenti</h4>
        <a href="pages/spec.html">SPEC.md</a>
        <a href="pages/tutorial.html">TUTORIAL.md</a>
        <a href="pages/bootstrap.html">BOOTSTRAP.md</a>
        <a href="pages/status.html">STATUS.md</a>
      </div>
      <div>
        <h4>Risorse</h4>
        <a href="https://github.com/GPuntobit/triad2.0" target="_blank" rel="noopener">Repository</a>
        <a href="pages/examples.html">Esempi</a>
        <a href="pages/conformance.html">Conformance</a>
        <a href="pages/editors.html">Editor</a>
      </div>
      <div>
        <h4>Comunita</h4>
        <a href="pages/ai.html">AI benchmark</a>
        <a href="https://github.com/GPuntobit/triad2.0/issues" target="_blank" rel="noopener">Issue</a>
        <a href="pages/license.html">Licenza MIT</a>
      </div>
    </div>
    <div class="copyright">2026 Triad 2.0 - distribuito sotto licenza MIT. Standard 0.2.0.</div>
  </div>
</footer>`;
}

function mount(active) {
  const headerSlot = document.getElementById('site-header');
  const footerSlot = document.getElementById('site-footer');
  if (headerSlot) headerSlot.innerHTML = renderHeader(active);
  if (footerSlot) footerSlot.innerHTML = renderFooter();
  const prefix = /\/pages\/[^/]*$/.test(location.pathname) ? '../' : '';
  if (prefix) [headerSlot, footerSlot].forEach(slot => slot && slot.querySelectorAll('a[href]').forEach(a => {
    const href = a.getAttribute('href');
    if (!/^([a-z]+:|#|\/)/i.test(href)) a.setAttribute('href', prefix + href);
  }));
}

async function loadMarkdown(targetId, file) {
  const el = document.getElementById(targetId);
  if (!el) return;
  el.innerHTML = '<div class="doc-loading">Caricamento…</div>';
  try {
    const res = await fetch(RAW_BASE + file);
    if (!res.ok) throw new Error('HTTP ' + res.status);
    const md = await res.text();
    el.innerHTML = marked.parse(md);
    el.querySelectorAll('a').forEach(a => {
      const href = a.getAttribute('href');
      if (href && !href.startsWith('http') && !href.startsWith('#') && !href.startsWith('mailto:')) {
        a.href = 'https://github.com/GPuntobit/triad2.0/blob/main/' + href;
        a.target = '_blank';
      }
    });
    const siteRoot = /\/pages\/[^/]*$/.test(location.pathname) ? '../' : '';
    const fileDir = file.includes('/') ? file.slice(0, file.lastIndexOf('/') + 1) : '';
    el.querySelectorAll('img[src]').forEach(img => {
      const src = img.getAttribute('src');
      if (/^([a-z]+:|\/|#)/i.test(src)) return;
      const path = fileDir + src;
      img.src = path.startsWith('docs/') ? siteRoot + path.slice(5) : RAW_BASE + path;
    });
  } catch (e) {
    el.innerHTML = '<div class="doc-loading">Impossibile caricare il documento: ' + e.message + '</div>';
  }
}

function initDocViewer() {
  const params = new URLSearchParams(location.search);
  const file = params.get('file');
  const title = params.get('title');
  const t = document.getElementById('doc-title');
  if (t && title) t.textContent = title;
  if (file) loadMarkdown('doc-content', file);
}

window.TriadSite = { mount, loadMarkdown, initDocViewer };
