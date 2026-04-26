// Service Worker: cache-first strategy de game chay duoc offline
// va dap ung dieu kien installable cua Chrome PWA.
const CACHE_NAME = 'ctetris-v1';
const ASSETS = [
    './',
    'ctetris.html',
    'ctetris.js',
    'ctetris.wasm',
    'manifest.webmanifest',
    'favicon.svg',
    'icon-192.png',
    'icon-512.png'
];

// Install: pre-cache toan bo asset
self.addEventListener('install', function(event) {
    event.waitUntil(
        caches.open(CACHE_NAME).then(function(cache) {
            // Cache tung file riêng le -- tranh fail toan bo neu mot file 404
            return Promise.all(ASSETS.map(function(url) {
                return cache.add(url).catch(function(err) {
                    console.warn('SW: khong cache duoc', url, err);
                });
            }));
        })
    );
    self.skipWaiting();
});

// Activate: xoa cache phien ban cu
self.addEventListener('activate', function(event) {
    event.waitUntil(
        caches.keys().then(function(keys) {
            return Promise.all(keys.filter(function(k) {
                return k !== CACHE_NAME;
            }).map(function(k) {
                return caches.delete(k);
            }));
        })
    );
    self.clients.claim();
});

// Fetch: cache-first, fallback ve network, lazy-cache asset moi
self.addEventListener('fetch', function(event) {
    if (event.request.method !== 'GET') return;
    event.respondWith(
        caches.match(event.request).then(function(cached) {
            return cached || fetch(event.request).then(function(response) {
                if (response && response.status === 200) {
                    var clone = response.clone();
                    caches.open(CACHE_NAME).then(function(c) {
                        c.put(event.request, clone);
                    });
                }
                return response;
            }).catch(function() {
                return new Response('Offline va asset chua duoc cache', { status: 503 });
            });
        })
    );
});