import admin from 'firebase-admin';
import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import User from '../models/User.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Đọc file service account
const serviceAccount = JSON.parse(
  readFileSync(join(__dirname, 'firebase-service-account.json'), 'utf8')
);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

export const messaging = admin.messaging();

export const sendNotification = async (token, title, body, data = {}) => {
  try {
    // Kiểm tra xem token có tồn tại không
    if (!token) {
      console.log('Không có FCM token');
      return null;
    }

    // Lấy thông tin user từ token
    const user = await User.findOne({ fcmToken: token });
    if (!user) {
      console.log('Không tìm thấy user với token này');
      return null;
    }

    // Kiểm tra cài đặt thông báo dựa vào loại thông báo
    const notificationType = data.type || 'system';
    let shouldSendNotification = true;

    switch (notificationType) {
      case 'system':
        shouldSendNotification = user.notificationSettings.systemNotifications;
        break;
      case 'payment':
        shouldSendNotification = user.notificationSettings.paymentNotifications;
        break;
      case 'message':
        shouldSendNotification = user.notificationSettings.messageNotifications;
        break;
      case 'appointment':
        shouldSendNotification = user.notificationSettings.appointmentNotifications;
        break;
    }

    if (!shouldSendNotification) {
      console.log('Thông báo bị tắt theo cài đặt của user');
      return null;
    }

    // Đảm bảo luôn có trường notification để foreground nhận được
    const message = {
      notification: {
        title: title || (data && data.title) || 'Thông báo',
        body: body || (data && data.body) || ''
      },
      data: {
        ...data,
        title: title || (data && data.title) || 'Thông báo',
        body: body || (data && data.body) || ''
      },
      token
    };

    const response = await messaging.send(message);
    console.log('Successfully sent notification:', response);
    return response;
  } catch (error) {
    console.error('Error sending notification:', error);
    throw error;
  }
}; 