(function () {
  if (new URLSearchParams(location.search).get('app') === '1') {
    document.documentElement.classList.add('app-embed');
  }
})();

/**
 * Site chrome behaviors shared by every MusNote page:
 * - mobile nav open/close
 * - smooth in-page anchors
 * - Escape closes the menu
 */
(function () {
  function closeMobileNav() {
    const navMenu = document.getElementById('nav-menu');
    const mobileToggle = document.getElementById('mobile-menu-toggle');
    if (!navMenu || !mobileToggle) return;
    navMenu.classList.remove('active');
    mobileToggle.classList.remove('active');
    document.body.classList.remove('menu-open');
  }

  function setupMobileMenu() {
    const mobileToggle = document.getElementById('mobile-menu-toggle');
    const navMenu = document.getElementById('nav-menu');
    if (!mobileToggle || !navMenu) return;

    mobileToggle.addEventListener('click', () => {
      navMenu.classList.toggle('active');
      mobileToggle.classList.toggle('active');
      document.body.classList.toggle('menu-open');
    });

    navMenu.querySelectorAll('.nav-link').forEach((link) => {
      link.addEventListener('click', closeMobileNav);
    });

    document.addEventListener('click', (e) => {
      if (!navMenu.contains(e.target) && !mobileToggle.contains(e.target)) {
        closeMobileNav();
      }
    });

    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') closeMobileNav();
    });
  }

  function setupSmoothAnchors() {
    document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
      anchor.addEventListener('click', (e) => {
        const id = anchor.getAttribute('href');
        if (!id || id === '#') return;
        const target = document.querySelector(id);
        if (!target) return;
        e.preventDefault();
        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      });
    });
  }

  document.addEventListener('DOMContentLoaded', () => {
    setupMobileMenu();
    setupSmoothAnchors();
  });
})();
