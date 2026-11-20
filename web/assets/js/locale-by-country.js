/**
 * Pick site language from visitor country (Cloudflare loc=); remember a manual choice.
 * Redirects only to LIVE locales so missing /pl/ etc. never 404.
 */
(function () {
  var LIVE = { en: 1, ru: 1, de: 1 };
  var PREFIX_RE = /^\/(ru|de|pl|es|pt|ja|ko|zh-tw|zh-cn|vi)(?=\/|$)/;
  var STORAGE_KEY = 'mn_lang';
  var GEO_FLAG = 'mn_geo_checked';

  var COUNTRY_TO_LANG = {
    PL: 'pl',
    ES: 'es', MX: 'es', AR: 'es', CO: 'es', CL: 'es', PE: 'es', VE: 'es',
    UY: 'es', EC: 'es', GT: 'es', CU: 'es', DO: 'es', BO: 'es', PY: 'es',
    HN: 'es', SV: 'es', NI: 'es', CR: 'es', PA: 'es',
    BR: 'pt', PT: 'pt',
    RU: 'ru', BY: 'ru', KZ: 'ru', KG: 'ru',
    DE: 'de', AT: 'de',
    JP: 'ja',
    KR: 'ko',
    TW: 'zh-tw', HK: 'zh-tw',
    CN: 'zh-cn', SG: 'zh-cn',
    VN: 'vi',
    US: 'en', GB: 'en', AU: 'en', NZ: 'en', IE: 'en', CA: 'en'
  };

  function pathLang() {
    var m = location.pathname.match(PREFIX_RE);
    return m ? m[1] : 'en';
  }

  function stripLocale(pathname) {
    var path = pathname.replace(PREFIX_RE, '') || '/';
    if (path.charAt(0) !== '/') path = '/' + path;
    return path;
  }

  function hrefFor(lang, pathname, search, hash) {
    var rest = stripLocale(pathname);
    var path = lang === 'en' ? rest : '/' + lang + (rest === '/' ? '/' : rest);
    return path + (search || '') + (hash || '');
  }

  function go(lang) {
    if (!LIVE[lang]) return;
    if (pathLang() === lang) return;
    location.replace(hrefFor(lang, location.pathname, location.search, location.hash));
  }

  function readStored() {
    try {
      return localStorage.getItem(STORAGE_KEY) || '';
    } catch (e) {
      return '';
    }
  }

  function parseLoc(text) {
    var m = String(text).match(/^loc=([A-Za-z]{2})$/m);
    return m ? m[1].toUpperCase() : '';
  }

  function fetchCountry() {
    var urls = ['/cdn-cgi/trace', 'https://www.cloudflare.com/cdn-cgi/trace'];
    return urls.reduce(function (chain, url) {
      return chain.catch(function () {
        return fetch(url, { credentials: 'omit' }).then(function (r) {
          if (!r.ok) throw new Error('trace');
          return r.text();
        }).then(parseLoc).then(function (loc) {
          if (!loc) throw new Error('no loc');
          return loc;
        });
      });
    }, Promise.reject());
  }

  window.MusnoteLocale = {
    LIVE: LIVE,
    PREFIX_RE: PREFIX_RE,
    STORAGE_KEY: STORAGE_KEY,
    pathLang: pathLang,
    stripLocale: stripLocale,
    hrefFor: hrefFor,
    remember: function (lang) {
      try {
        localStorage.setItem(STORAGE_KEY, lang);
      } catch (e) {}
    }
  };

  var stored = readStored();
  if (stored && LIVE[stored]) {
    go(stored);
    return;
  }

  try {
    if (sessionStorage.getItem(GEO_FLAG)) return;
    sessionStorage.setItem(GEO_FLAG, '1');
  } catch (e) {}

  fetchCountry()
    .then(function (cc) {
      var lang = COUNTRY_TO_LANG[cc] || 'en';
      if (LIVE[lang]) go(lang);
    })
    .catch(function () {});
})();
