// Simple Service Worker for MusNote
const CACHE_NAME = 'musnote-v4';
const urlsToCache = [
  '/assets/css/main.css',
  '/assets/css/responsive.css',
  '/assets/js/main.js',
  '/assets/js/language.js',
  '/assets/translations/translations.json',
  '/assets/images/logo.svg'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        return cache.addAll(urlsToCache);
      })
  );
});

self.addEventListener('fetch', (event) => {
  const accept = event.request.headers.get('accept') || '';
  if (event.request.mode === 'navigate' || accept.includes('text/html')) {
    event.respondWith(fetch(event.request).catch(() => caches.match(event.request)));
    return;
  }
  event.respondWith(
    caches.match(event.request).then((response) => response || fetch(event.request))
  );
});

self.addEventListener('activate', (event) => {
  const cacheWhitelist = [CACHE_NAME];
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheWhitelist.indexOf(cacheName) === -1) {
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => {
      // Force update of all clients
      return self.clients.claim();
    })
  );
});
