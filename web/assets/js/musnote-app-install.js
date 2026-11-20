/**
 * MusNote mobile install links (TestFlight / Play).
 * Public surface: window.MUSNOTE_APP
 * Paste TestFlight public URL into testflightUrl when ASC Public Link is on.
 * Until then CTAs with data-app-cta stay in "waiting" copy.
 */
(function () {
  const cfg = {
    /** e.g. https://testflight.apple.com/join/XXXXXXXX */
    testflightUrl: '',
    /** Optional later: Google Play internal/open testing */
    playUrl: '',
  };

  window.MUSNOTE_APP = cfg;

  function wire() {
    document.querySelectorAll('[data-app-cta]').forEach((el) => {
      const kind = el.getAttribute('data-app-cta');
      const url = kind === 'play' ? cfg.playUrl : cfg.testflightUrl;
      const waiting = el.getAttribute('data-waiting') || el.textContent;
      const ready = el.getAttribute('data-ready') || el.textContent;

      if (url) {
        el.setAttribute('href', url);
        el.removeAttribute('aria-disabled');
        el.classList.remove('is-waiting');
        el.textContent = ready;
      } else {
        el.setAttribute('href', '#beta-status');
        el.setAttribute('aria-disabled', 'true');
        el.classList.add('is-waiting');
        el.textContent = waiting;
      }
    });

    document.querySelectorAll('[data-app-status]').forEach((el) => {
      const open = Boolean(cfg.testflightUrl);
      el.hidden = open ? el.getAttribute('data-when') === 'closed' : el.getAttribute('data-when') === 'open';
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', wire);
  } else {
    wire();
  }
})();
