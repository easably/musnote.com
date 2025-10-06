// Simple Service Worker for MusNote
const CACHE_NAME = 'musnote-v1';
const urlsToCache = [
  '/',
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
  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        // Return cached version or fetch from network
        return response || fetch(event.request);
      })
  );
});
