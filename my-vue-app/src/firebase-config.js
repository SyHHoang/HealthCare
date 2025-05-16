// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import { getMessaging, getToken, onMessage } from "firebase/messaging";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyD5OIE5aosX5kAUquq_kyGCccJiG23AWVo",
  authDomain: "appmusic-caa79.firebaseapp.com",
  databaseURL: "https://appmusic-caa79-default-rtdb.firebaseio.com",
  projectId: "appmusic-caa79",
  storageBucket: "appmusic-caa79.firebasestorage.app",
  messagingSenderId: "278060018675",
  appId: "1:278060018675:web:389379f0ea655ad2308086",
  measurementId: "G-FVZZGZFNEE"
};

// VAPID key từ Firebase Console
const vapidKey = "BKu5ToCnZOzho7jSdb7AXKwluiPzbgQDUCpd1wUF2l0uTrlqcunb9DQSEcnDMk7Kk2Cml8MWdb60LnsBxVMvBIM"; // Thay thế bằng VAPID key của bạn

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
const messaging = getMessaging(app);

// Hàm lấy FCM token
export const getFCMToken = async () => {
  try {
    // Kiểm tra xem service worker đã được đăng ký chưa
    if ('serviceWorker' in navigator) {
      const registration = await navigator.serviceWorker.register('/firebase-messaging-sw.js');
      console.log('Service Worker registered:', registration);
    }

    // Lấy token
    const currentToken = await getToken(messaging, {
      vapidKey: vapidKey,
      serviceWorkerRegistration: await navigator.serviceWorker.getRegistration()
    });

    if (currentToken) {
      console.log('Current FCM token:', currentToken);
      return currentToken;
    } else {
      console.log('No registration token available.');
      return null;
    }
  } catch (err) {
    console.error('An error occurred while retrieving token:', err);
    return null;
  }
};

// Hàm lắng nghe thông báo khi app đang mở
export const onMessageListener = () =>
  new Promise((resolve) => {
    onMessage(messaging, (payload) => {
      console.log('Message received:', payload);
      resolve(payload);
    });
  });

export { messaging };