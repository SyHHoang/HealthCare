import admin from 'firebase-admin';
import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import User from '../models/User.js';
import Doctor from '../models/Doctor.js';

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

    // Chuẩn bị message với cấu trúc mới
    const message = {
      token,
      notification: {
        title,
        body
      },
      data: {
        ...data,
        title: title,
        body: body,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
        sound: 'default',
        status: 'done',
        screen: data.screen || 'notification',
        icon: '/logo.png',
        badge: '/logo.png',
        tag: data.type || 'notification',
        requireInteraction: 'true',
        vibrate: '[200,100,200]',
        actions: JSON.stringify([
          {
            action: 'view',
            title: 'Xem chi tiết'
          }
        ])
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'high_importance_channel',
          priority: 'high',
          defaultSound: true,
          defaultVibrateTimings: true,
          defaultLightSettings: true
        }
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1
          }
        }
      },
      webpush: {
        headers: {
          Urgency: 'high'
        },
        notification: {
          icon: '/logo.png',
          badge: '/logo.png',
          tag: data.type || 'notification',
          requireInteraction: true,
          vibrate: [200, 100, 200],
          actions: [
            {
              action: 'view',
              title: 'Xem chi tiết'
            }
          ]
        }
      }
    };

    console.log('Sending notification with payload:', JSON.stringify(message, null, 2));
    const response = await messaging.send(message);
    console.log('Successfully sent notification:', response);
    return response;
  } catch (error) {
    console.error('Error sending notification:', error);
    
    // Xử lý token không hợp lệ
    if (error.code === 'messaging/invalid-registration-token' || 
        error.code === 'messaging/registration-token-not-registered') {
      console.log('Token không hợp lệ, đang xóa token...');
      
      // Tìm và xóa token khỏi user hoặc doctor
      const user = await User.findOne({ fcmTokens: token });
      if (user) {
        user.fcmTokens = user.fcmTokens.filter(t => t !== token);
        await user.save();
        console.log('Đã xóa token khỏi user');
        return null;
      }

      const doctor = await Doctor.findOne({ fcmTokens: token });
      if (doctor) {
        doctor.fcmTokens = doctor.fcmTokens.filter(t => t !== token);
        await doctor.save();
        console.log('Đã xóa token khỏi doctor');
        return null;
      }
    }
    
    throw error;
  }
};

// Hàm gửi thông báo cho nhiều token
export const sendMulticastNotification = async (tokens, title, body, data = {}) => {
  try {
    if (!tokens || tokens.length === 0) {
      console.log('Không có FCM tokens');
      return null;
    }

    const message = {
      tokens,
      notification: {
        title,
        body
      },
      data: {
        ...data,
        title: title,
        body: body,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
        sound: 'default',
        status: 'done',
        screen: data.screen || 'notification',
        icon: '/logo.png',
        badge: '/logo.png',
        tag: data.type || 'notification',
        requireInteraction: 'true',
        vibrate: '[200,100,200]',
        actions: JSON.stringify([
          {
            action: 'view',
            title: 'Xem chi tiết'
          }
        ])
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'high_importance_channel',
          priority: 'high',
          defaultSound: true,
          defaultVibrateTimings: true,
          defaultLightSettings: true
        }
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1
          }
        }
      },
      webpush: {
        headers: {
          Urgency: 'high'
        },
        notification: {
          icon: '/logo.png',
          badge: '/logo.png',
          tag: data.type || 'notification',
          requireInteraction: true,
          vibrate: [200, 100, 200],
          actions: [
            {
              action: 'view',
              title: 'Xem chi tiết'
            }
          ]
        }
      }
    };

    console.log('Sending multicast notification with payload:', JSON.stringify(message, null, 2));
    const response = await messaging.sendMulticast(message);
    console.log('Successfully sent multicast notification:', response);

    // Xử lý các token không hợp lệ
    if (response.failureCount > 0) {
      const failedTokens = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          failedTokens.push({
            token: tokens[idx],
            error: resp.error
          });
        }
      });

      // Xóa các token không hợp lệ
      for (const failedToken of failedTokens) {
        if (failedToken.error.code === 'messaging/invalid-registration-token' || 
            failedToken.error.code === 'messaging/registration-token-not-registered') {
          
          // Xóa token khỏi user
          const user = await User.findOne({ fcmTokens: failedToken.token });
          if (user) {
            user.fcmTokens = user.fcmTokens.filter(t => t !== failedToken.token);
            await user.save();
            console.log(`Đã xóa token không hợp lệ khỏi user: ${failedToken.token}`);
          }

          // Xóa token khỏi doctor
          const doctor = await Doctor.findOne({ fcmTokens: failedToken.token });
          if (doctor) {
            doctor.fcmTokens = doctor.fcmTokens.filter(t => t !== failedToken.token);
            await doctor.save();
            console.log(`Đã xóa token không hợp lệ khỏi doctor: ${failedToken.token}`);
          }
        }
      }
    }

    return response;
  } catch (error) {
    console.error('Error sending multicast notification:', error);
    throw error;
  }
}; 