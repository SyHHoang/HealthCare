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

// Hàm xóa token không hợp lệ
const removeInvalidToken = async (token, platform = 'web') => {
  try {
    // Tìm và xóa token khỏi user
    const user = await User.findOne({
      $or: [
        { 'fcmTokens.web': token },
        { 'fcmTokens.mobile': token }
      ]
    });
    
    if (user) {
      if (user.fcmTokens[platform] === token) {
        user.fcmTokens[platform] = '';
        await user.save();
        console.log(`Đã xóa token không hợp lệ khỏi user (${platform}): ${token}`);
      }
      return true;
    }

    // Tìm và xóa token khỏi doctor
    const doctor = await Doctor.findOne({
      $or: [
        { 'fcmTokens.web': token },
        { 'fcmTokens.mobile': token }
      ]
    });
    
    if (doctor) {
      if (doctor.fcmTokens[platform] === token) {
        doctor.fcmTokens[platform] = '';
        await doctor.save();
        console.log(`Đã xóa token không hợp lệ khỏi doctor (${platform}): ${token}`);
      }
      return true;
    }

    return false;
  } catch (error) {
    console.error('Error removing invalid token:', error);
    return false;
  }
};

// Hàm kiểm tra cài đặt thông báo
const checkNotificationSettings = (user) => {
  return user.notificationsEnabled ?? true;
};

// Hàm gửi thông báo
export const sendNotification = async (userId, title, body, data = {}, notificationType = 'system') => {
  try {
    const user = await User.findById(userId);
    if (!user || !user.fcmTokens) return;

    // Kiểm tra cài đặt thông báo
    if (!checkNotificationSettings(user)) {
      console.log(`Thông báo bị tắt cho user ${userId}`);
      return;
    }

    const message = {
      notification: {
        title,
        body
      },
      data: {
        ...data,
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      },
      android: {
        notification: {
          sound: 'default',
          channelId: 'default'
        }
      },
      apns: {
        payload: {
          aps: {
            sound: 'default'
          }
        }
      }
    };

    // Gửi thông báo cho web
    if (user.fcmTokens.web) {
      try {
        await admin.messaging().send({
          ...message,
          token: user.fcmTokens.web
        });
        console.log('Đã gửi thông báo web thành công');
      } catch (error) {
        console.error('Lỗi khi gửi thông báo web:', error);
        if (error.code === 'messaging/invalid-registration-token') {
          await removeInvalidToken(userId, user.fcmTokens.web, 'web');
        }
      }
    }

    // Gửi thông báo cho mobile
    if (user.fcmTokens.mobile) {
      try {
        await admin.messaging().send({
          ...message,
          token: user.fcmTokens.mobile
        });
        console.log('Đã gửi thông báo mobile thành công');
      } catch (error) {
        console.error('Lỗi khi gửi thông báo mobile:', error);
        if (error.code === 'messaging/invalid-registration-token') {
          await removeInvalidToken(userId, user.fcmTokens.mobile, 'mobile');
        }
      }
    }
  } catch (error) {
    console.error('Lỗi khi gửi thông báo:', error);
  }
};

// Hàm gửi thông báo cho bác sĩ
export const sendDoctorNotification = async (doctorId, title, body, data = {}, notificationType = 'system') => {
  try {
    const doctor = await Doctor.findById(doctorId);
    if (!doctor || !doctor.fcmTokens) return;

    // Kiểm tra cài đặt thông báo
    if (!checkNotificationSettings(doctor)) {
      console.log(`Thông báo bị tắt cho bác sĩ ${doctorId}`);
      return;
    }

    const message = {
      notification: {
        title,
        body
      },
      data: {
        ...data,
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      },
      android: {
        notification: {
          sound: 'default',
          channelId: 'default'
        }
      },
      apns: {
        payload: {
          aps: {
            sound: 'default'
          }
        }
      }
    };

    // Gửi thông báo cho web
    if (doctor.fcmTokens.web) {
      try {
        await admin.messaging().send({
          ...message,
          token: doctor.fcmTokens.web
        });
        console.log('Đã gửi thông báo web thành công');
      } catch (error) {
        console.error('Lỗi khi gửi thông báo web:', error);
        if (error.code === 'messaging/invalid-registration-token') {
          await removeInvalidToken(doctorId, doctor.fcmTokens.web, 'web', true);
        }
      }
    }

    // Gửi thông báo cho mobile
    if (doctor.fcmTokens.mobile) {
      try {
        await admin.messaging().send({
          ...message,
          token: doctor.fcmTokens.mobile
        });
        console.log('Đã gửi thông báo mobile thành công');
      } catch (error) {
        console.error('Lỗi khi gửi thông báo mobile:', error);
        if (error.code === 'messaging/invalid-registration-token') {
          await removeInvalidToken(doctorId, doctor.fcmTokens.mobile, 'mobile', true);
        }
      }
    }
  } catch (error) {
    console.error('Lỗi khi gửi thông báo:', error);
  }
};

export const sendMulticastNotification = async (tokens, title, body, data = {}, platform = 'web') => {
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

      for (const failedToken of failedTokens) {
        if (failedToken.error.code === 'messaging/invalid-registration-token' || 
            failedToken.error.code === 'messaging/registration-token-not-registered') {
          await removeInvalidToken(failedToken.token, platform);
        }
      }
    }

    return response;
  } catch (error) {
    console.error('Error sending multicast notification:', error);
    throw error;
  }
}; 