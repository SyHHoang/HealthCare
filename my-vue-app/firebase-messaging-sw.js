/* firebase-messaging-sw.js */
importScripts('https://www.gstatic.com/firebasejs/9.6.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.6.1/firebase-messaging-compat.js');

firebase.initializeApp({

  apiKey: "AIzaSyD5OIE5aosX5kAUquq_kyGCccJiG23AWVo",
  authDomain: "appmusic-caa79.firebaseapp.com",
  projectId: "appmusic-caa79",
  storageBucket: "appmusic-caa79.firebasestorage.app",
  messagingSenderId: "278060018675",
  appId: "1:278060018675:web:389379f0ea655ad2308086",

});

const messaging = firebase.messaging();

// Xử lý thông báo khi app đang chạy
messaging.onMessage(function(payload) {
  console.log('Message received in foreground:', payload);
  showNotification(payload);
});

// Xử lý thông báo khi app đang chạy ngầm
messaging.onBackgroundMessage(function(payload) {
  console.log('Message received in background:', payload);
  showNotification(payload);
});

// Hàm hiển thị thông báo
function showNotification(payload) {
  console.log('Processing notification payload:', payload);
  
  // Lấy thông tin từ notification hoặc data
  const notificationTitle = payload.notification?.title || payload.data?.title || 'Thông báo mới';
  const notificationBody = payload.notification?.body || payload.data?.body || '';
  
  // Chuẩn bị options cho thông báo
  const notificationOptions = {
    icon: '/logo.png',
    badge: '/logo.png',
    body: notificationBody,
    requireInteraction: true,
    vibrate: [200, 100, 200],
    data: payload.data || {},
    tag: 'payment-notification',
    actions: [
      {
        action: 'view',
        title: 'Xem chi tiết'
      }
    ]
  };

  // Hiển thị thông báo
  return self.registration.showNotification(notificationTitle, notificationOptions);
}

// Xử lý khi click vào thông báo
self.addEventListener('notificationclick', function(event) {
  console.log('Notification click received:', event);

  event.notification.close();

  // Focus vào cửa sổ hiện tại hoặc mở cửa sổ mới
  event.waitUntil(
    clients.matchAll({type: 'window'}).then(function(clientList) {
      // Nếu có cửa sổ đang mở, focus vào cửa sổ đó
      for (let client of clientList) {
        if (client.url === '/' && 'focus' in client) {
          return client.focus();
        }
      }
      // Nếu không có cửa sổ nào đang mở, mở cửa sổ mới
      if (clients.openWindow) {
        return clients.openWindow('/');
      }
    })
  );
});
