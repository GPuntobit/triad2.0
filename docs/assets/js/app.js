/* global DOMPurify, marked */
const RAW_BASE = 'https://raw.githubusercontent.com/GPuntobit/triad2.0/main/';

const NAV = [
  { href: 'index.html', label: 'Home' },
  { href: 'pages/getting-started.html', label: 'Get started' },
  { href: 'pages/language-tour.html', label: 'Tour' },
  { href: 'pages/spec.html', label: 'Spec' },
  { href: 'pages/tutorial.html', label: 'Tutorial' },
  { href: 'pages/apprendimento.html', label: 'Learning' },
  { href: 'pages/examples.html', label: 'Examples' },
  { href: 'pages/playground.html', label: 'Playground' },
  { href: 'pages/conformance.html', label: 'Conformance' },
  { href: 'pages/bootstrap.html', label: 'Bootstrap' },
  { href: 'pages/editors.html', label: 'Editor' },
  { href: 'pages/ai.html', label: 'AI' },
  { href: 'pages/status.html', label: 'Status' },
];

function renderHeader(active) {
  const links = NAV.map(n => `<a href="${n.href}" ${n.label===active?'class="active" aria-current="page"':''}>${n.label}</a>`).join('');
  return `
<header class="site-header">
  <div class="container nav">
    <a class="brand" href="index.html"><span class="logo">T</span> Triad 2.0</a>
    <button class="nav-toggle">☰</button>
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
        <p>Self-contained programming language: block syntax, declared types, multiple dispatch, integrated logic, code as data.</p>
      </div>
      <div>
        <h4>Documents</h4>
        <a href="pages/spec.html">SPEC.md</a>
        <a href="pages/tutorial.html">TUTORIAL.md</a>
        <a href="pages/bootstrap.html">BOOTSTRAP.md</a>
        <a href="pages/status.html">STATUS.md</a>
      </div>
      <div>
        <h4>Resources</h4>
        <a href="https://github.com/GPuntobit/triad2.0" target="_blank" rel="noopener">Repository</a>
        <a href="pages/examples.html">Examples</a>
        <a href="pages/conformance.html">Conformance</a>
        <a href="pages/editors.html">Editor</a>
      </div>
      <div>
        <h4>Community</h4>
        <a href="pages/ai.html">AI benchmark</a>
        <a href="https://github.com/GPuntobit/triad2.0/issues" target="_blank" rel="noopener">Issues</a>
        <a href="pages/license.html">MIT license</a>
      </div>
    </div>
    <div class="copyright">2026 Triad 2.0 - distributed under the MIT license. Standard 0.2.0.</div>
  </div>
</footer>`;
}

function mount(active) {
  const headerSlot = globalThis.document.getElementById('site-header');
  const footerSlot = globalThis.document.getElementById('site-footer');
  if (headerSlot) {
    headerSlot.replaceChildren(DOMPurify.sanitize(renderHeader(active), { RETURN_DOM_FRAGMENT: true }));
    const navToggle = headerSlot.querySelector('.nav-toggle');
    if (navToggle) {
      navToggle.addEventListener('click', () => {
        headerSlot.querySelector('.nav-links').classList.toggle('open');
      });
    }
  }
  if (footerSlot) footerSlot.replaceChildren(DOMPurify.sanitize(renderFooter(), { RETURN_DOM_FRAGMENT: true }));
  const prefix = /\/pages\/[^/]*$/.test(globalThis.location.pathname) ? '../' : '';
  if (prefix) [headerSlot, footerSlot].forEach(slot => slot && slot.querySelectorAll('a[href]').forEach(a => {
    const href = a.getAttribute('href');
    if (!/^([a-z]+:|#|\/)/i.test(href)) a.setAttribute('href', prefix + href);
  }));
}

async function loadMarkdown(targetId, file) {
  const el = globalThis.document.getElementById(targetId);
  if (!el) return;
  el.innerHTML = '<div class="doc-loading">Loading…</div>';
  try {
    const res = await globalThis.fetch(RAW_BASE + file);
    if (!res.ok) throw new Error('HTTP ' + res.status);
    const md = await res.text();
    const safeMarkdown = DOMPurify.sanitize(marked.parse(md), {
      USE_PROFILES: { html: true },
      RETURN_DOM_FRAGMENT: true
    });
    el.replaceChildren(safeMarkdown);
    el.querySelectorAll('a').forEach(a => {
      const href = a.getAttribute('href');
      if (href && !href.startsWith('http') && !href.startsWith('#') && !href.startsWith('mailto:')) {
        a.href = 'https://github.com/GPuntobit/triad2.0/blob/main/' + href;
        a.target = '_blank';
      }
    });
    const siteRoot = /\/pages\/[^/]*$/.test(globalThis.location.pathname) ? '../' : '';
    const fileDir = file.includes('/') ? file.slice(0, file.lastIndexOf('/') + 1) : '';
    el.querySelectorAll('img[src]').forEach(img => {
      const src = img.getAttribute('src');
      if (/^([a-z]+:|\/|#)/i.test(src)) return;
      const path = fileDir + src;
      img.src = path.startsWith('docs/') ? siteRoot + path.slice(5) : RAW_BASE + path;
    });
  } catch (e) {
    const errorMessage = globalThis.document.createElement('div');
    errorMessage.className = 'doc-loading';
    errorMessage.textContent = 'Could not load the document: ' + e.message;
    el.replaceChildren(errorMessage);
  }
}

function initDocViewer() {
  const params = new globalThis.URLSearchParams(globalThis.location.search);
  const file = params.get('file');
  const title = params.get('title');
  const t = globalThis.document.getElementById('doc-title');
  if (t && title) t.textContent = title;
  if (file) loadMarkdown('doc-content', file);
}

globalThis.TriadSite = { mount, loadMarkdown, initDocViewer };
