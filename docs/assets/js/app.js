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
  const navLinks = document.createElement('nav');
  navLinks.className = 'nav-links';
  NAV.forEach(n => {
    const a = document.createElement('a');
    a.href = n.href;
    a.textContent = n.label;
    if (n.label === active) {
      a.className = 'active';
      a.setAttribute('aria-current', 'page');
    }
    navLinks.appendChild(a);
  });

  const header = document.createElement('header');
  header.className = 'site-header';
  const container = document.createElement('div');
  container.className = 'container nav';

  const brand = document.createElement('a');
  brand.className = 'brand';
  brand.href = 'index.html';
  const logo = document.createElement('span');
  logo.className = 'logo';
  logo.textContent = 'T';
  brand.appendChild(logo);
  brand.appendChild(document.createTextNode(' Triad 2.0'));

  const navToggle = document.createElement('button');
  navToggle.className = 'nav-toggle';
  navToggle.textContent = '☰';

  container.appendChild(brand);
  container.appendChild(navToggle);
  container.appendChild(navLinks);
  header.appendChild(container);

  return header;
}

function renderFooter() {
  const footer = document.createElement('footer');
  footer.className = 'site-footer';
  const container = document.createElement('div');
  container.className = 'container';

  const footerGrid = document.createElement('div');
  footerGrid.className = 'footer-grid';

  // Triad 2.0 section
  const section1 = document.createElement('div');
  const h4_1 = document.createElement('h4');
  h4_1.textContent = 'Triad 2.0';
  const p1 = document.createElement('p');
  p1.textContent = 'Self-contained programming language: block syntax, declared types, multiple dispatch, integrated logic, code as data.';
  section1.appendChild(h4_1);
  section1.appendChild(p1);

  // Documents section
  const section2 = document.createElement('div');
  const h4_2 = document.createElement('h4');
  h4_2.textContent = 'Documents';
  section2.appendChild(h4_2);
  [
    { href: 'pages/spec.html', text: 'SPEC.md' },
    { href: 'pages/tutorial.html', text: 'TUTORIAL.md' },
    { href: 'pages/bootstrap.html', text: 'BOOTSTRAP.md' },
    { href: 'pages/status.html', text: 'STATUS.md' },
    { href: 'libro/book.html', text: 'The book' },
    { href: 'libro/The-book-of-Triad.epub', text: 'EPUB' }
  ].forEach(linkData => {
    const a = document.createElement('a');
    a.href = linkData.href;
    a.textContent = linkData.text;
    section2.appendChild(a);
  });

  // Resources section
  const section3 = document.createElement('div');
  const h4_3 = document.createElement('h4');
  h4_3.textContent = 'Resources';
  section3.appendChild(h4_3);
  [
    { href: 'https://github.com/GPuntobit/triad2.0', text: 'Repository', external: true },
    { href: 'pages/examples.html', text: 'Examples' },
    { href: 'pages/conformance.html', text: 'Conformance' },
    { href: 'pages/editors.html', text: 'Editor' }
  ].forEach(linkData => {
    const a = document.createElement('a');
    a.href = linkData.href;
    a.textContent = linkData.text;
    if (linkData.external) {
      a.target = '_blank';
      a.rel = 'noopener';
    }
    section3.appendChild(a);
  });

  // Community section
  const section4 = document.createElement('div');
  const h4_4 = document.createElement('h4');
  h4_4.textContent = 'Community';
  section4.appendChild(h4_4);
  [
    { href: 'pages/ai.html', text: 'AI benchmark' },
    { href: 'https://github.com/GPuntobit/triad2.0/issues', text: 'Issues', external: true },
    { href: 'pages/license.html', text: 'MIT license' }
  ].forEach(linkData => {
    const a = document.createElement('a');
    a.href = linkData.href;
    a.textContent = linkData.text;
    if (linkData.external) {
      a.target = '_blank';
      a.rel = 'noopener';
    }
    section4.appendChild(a);
  });

  footerGrid.appendChild(section1);
  footerGrid.appendChild(section2);
  footerGrid.appendChild(section3);
  footerGrid.appendChild(section4);

  const copyright = document.createElement('div');
  copyright.className = 'copyright';
  copyright.textContent = '2026 Triad 2.0 - distributed under the MIT license. Standard 0.2.0.';

  container.appendChild(footerGrid);
  container.appendChild(copyright);
  footer.appendChild(container);

  return footer;
}

function mount(active) {
  const headerSlot = globalThis.document.getElementById('site-header');
  const footerSlot = globalThis.document.getElementById('site-footer');
  if (headerSlot) {
    headerSlot.replaceChildren(renderHeader(active));
    const navToggle = headerSlot.querySelector('.nav-toggle');
    const navLinks = headerSlot.querySelector('.nav-links');
    if (navToggle && navLinks) {
      navToggle.addEventListener('click', (e) => {
        e.stopPropagation();
        navLinks.classList.toggle('open');
        navToggle.setAttribute('aria-expanded', navLinks.classList.contains('open') ? 'true' : 'false');
      });
      navLinks.querySelectorAll('a').forEach(a => {
        a.addEventListener('click', () => navLinks.classList.remove('open'));
      });
      globalThis.document.addEventListener('click', (e) => {
        if (!headerSlot.contains(e.target)) navLinks.classList.remove('open');
      });
    }
  }
  if (footerSlot) footerSlot.replaceChildren(renderFooter());
  const prefix = /\/pages\/[^/]*$/.test(globalThis.location.pathname) ? '../' : '';
  if (prefix) [headerSlot, footerSlot].forEach(slot => slot && slot.querySelectorAll('a[href]').forEach(a => {
    const href = a.getAttribute('href');
    if (!/^([a-z]+:|#|\/)/i.test(href)) a.setAttribute('href', prefix + href);
  }));
}

async function loadMarkdown(targetId, file) {
  const el = globalThis.document.getElementById(targetId);
  if (!el) return;
  const loading = globalThis.document.createElement('div');
  loading.className = 'doc-loading';
  loading.textContent = 'Loading…';
  el.replaceChildren(loading);
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
