<template>
  <div>
    <PrimeToast />
  </div>
</template>

<script setup>
import { onMounted, onUnmounted } from 'vue';
import { onMessageListener } from '../firebase-config';
import { useToast } from 'primevue/usetoast';

const toast = useToast();

const handlePayload = (payload) => {
  console.log('FCM payload received:', payload);
  
  // Lấy thông tin từ notification hoặc data
  const title = payload.notification?.title || payload.data?.title || 'Thông báo mới';
  const body = payload.notification?.body || payload.data?.body || '';
  const data = payload.data || {};

  // Kiểm tra xem có phải là thông báo thanh toán không
  if (data.type === 'payment_success') {
    let message = '';
    
    switch(data.orderType) {
      case 'consultation':
        message = `Thanh toán tư vấn thành công với số tiền ${parseInt(data.amount).toLocaleString('vi-VN')}đ`;
        break;
      case 'Extend':
        message = `Gia hạn tư vấn thành công với số tiền ${parseInt(data.amount).toLocaleString('vi-VN')}đ`;
        break;
      case 'AddCallVideo':
        message = `Mua thêm ${data.quantity} cuộc gọi video thành công với số tiền ${parseInt(data.amount).toLocaleString('vi-VN')}đ`;
        break;
      default:
        message = `Thanh toán thành công với số tiền ${parseInt(data.amount).toLocaleString('vi-VN')}đ`;
    }

    // Hiển thị thông báo hệ thống
    if (Notification.permission === 'granted') {
      const notification = new Notification(title, {
        body: message,
        icon: data.icon || '/logo.png',
        badge: data.badge || '/logo.png',
        tag: data.tag || 'payment-notification',
        requireInteraction: true,
        vibrate: [200, 100, 200]
      });

      // Xử lý khi click vào thông báo
      notification.onclick = function() {
        window.focus();
        notification.close();
      };
    }

    // Hiển thị toast
    toast.add({
      severity: 'success',
      summary: title,
      detail: message,
      life: 5000,
      closable: true
    });
  } else {
    // Xử lý các loại thông báo khác
    if (Notification.permission === 'granted') {
      const notification = new Notification(title, {
        body: body,
        icon: data.icon || '/logo.png',
        badge: data.badge || '/logo.png',
        requireInteraction: true,
        vibrate: [200, 100, 200]
      });

      // Xử lý khi click vào thông báo
      notification.onclick = function() {
        window.focus();
        notification.close();
      };
    }

    // Hiển thị toast
    toast.add({
      severity: 'info',
      summary: title,
      detail: body,
      life: 5000,
      closable: true
    });
  }

  // Kích hoạt sự kiện refresh notifications
  window.dispatchEvent(new Event('refresh-notifications'));
};

// Hàm lắng nghe message
const setupMessageListener = async () => {
  try {
    console.log('Setting up message listener...');
    const messaging = await import('firebase/messaging').then(m => m.getMessaging());
    const onMessage = await import('firebase/messaging').then(m => m.onMessage);
    
    onMessage(messaging, (payload) => {
      console.log('Message received in NotificationHandler:', payload);
      handlePayload(payload);
    });
    
    console.log('Message listener setup completed');
  } catch (error) {
    console.error('Error setting up message listener:', error);
  }
};

onMounted(async () => {
  console.log('NotificationHandler mounted');
  await setupMessageListener();
});

onUnmounted(() => {
  console.log('NotificationHandler unmounted');
});
</script>

<style>
/* Thêm style cho thông báo hệ thống */
::v-deep .p-toast {
  z-index: 9999;
}

::v-deep .p-toast-message {
  min-width: 300px;
  max-width: 400px;
}

::v-deep .p-toast-message-content {
  padding: 1rem;
}

::v-deep .p-toast-message-icon {
  font-size: 1.5rem;
}

::v-deep .p-toast-message-text {
  margin: 0 0 0 1rem;
}

::v-deep .p-toast-message-summary {
  font-weight: 600;
  margin-bottom: 0.5rem;
}

::v-deep .p-toast-message-detail {
  margin: 0;
  line-height: 1.5;
}
</style> 