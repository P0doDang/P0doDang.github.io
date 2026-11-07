// 예전 Chirpy 테마가 등록한 서비스 워커를 정리하는 파일이에요.
// 브라우저가 이 파일을 새 버전으로 받으면 캐시를 모두 지우고 스스로 해제해요.
self.addEventListener('install', function () { self.skipWaiting(); });
self.addEventListener('activate', function (event) {
  event.waitUntil((async function () {
    var keys = await caches.keys();
    await Promise.all(keys.map(function (k) { return caches.delete(k); }));
    await self.registration.unregister();
    var clients = await self.clients.matchAll({ type: 'window' });
    clients.forEach(function (c) { c.navigate(c.url); });
  })());
});
