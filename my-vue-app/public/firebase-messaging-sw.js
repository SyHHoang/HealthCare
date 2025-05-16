importScripts('https://www.gstatic.com/firebasejs/9.6.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.6.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyD5OIE5aosX5kAUquq_kyGCccJiG23AWVo",
  authDomain: "appmusic-caa79.firebaseapp.com",
  projectId: "appmusic-caa79",
  storageBucket: "appmusic-caa79.firebasestorage.app",
  messagingSenderId: "278060018675",
  appId: "1:278060018675:web:389379f0ea655ad2308086"
});

const messaging = firebase.messaging();

// Xử lý thông báo khi app đang ở background
messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/logo.png',
    badge: '/logo.png',
    tag: 'payment-notification'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
}); 