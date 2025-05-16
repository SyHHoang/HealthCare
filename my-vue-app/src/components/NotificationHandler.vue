<template>
  <div>
    <PrimeToast />
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue';
import { getFCMToken, onMessageListener } from '../firebase-config';
import axiosInstance from '@/services/axiosInstance';
import { useToast } from 'primevue/usetoast';

const toast = useToast();
const notificationPermission = ref(Notification.permission);

const requestNotificationPermission = async () => {
  try {
    if (Notification.permission === 'default') {
      const permission = await Notification.requestPermission();
      notificationPermission.value = permission;
      if (permission === 'granted') {
        toast.add({
          severity: 'success',
          summary: 'Thành công',
          detail: 'Bạn đã cho phép nhận thông báo',
          life: 3000
        });
        await updateFCMToken();
      } else {
        toast.add({
          severity: 'warn',
          summary: 'Cảnh báo',
          detail: 'Bạn cần cho phép thông báo để nhận thông tin về giao dịch',
          life: 5000
        });
      }
    } else if (Notification.permission === 'denied') {
      toast.add({
        severity: 'warn',
        summary: 'Cảnh báo',
        detail: 'Bạn đã từ chối thông báo. Vui lòng cập nhật cài đặt trình duyệt để nhận thông báo.',
        life: 5000
      });
    }
  } catch (error) {
    console.error('Error requesting notification permission:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể yêu cầu quyền thông báo',
      life: 3000
    });
  }
};

const updateFCMToken = async () => {
  try {
    const token = await getFCMToken();
    if (token) {
      await axiosInstance.post('/api/users/update-fcm-token', { fcmToken: token });
      toast.add({
        severity: 'success',
        summary: 'Thành công',
        detail: 'Đã cập nhật token thông báo',
        life: 3000
      });
    }
  } catch (error) {
    console.error('Error updating FCM token:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể cập nhật token thông báo',
      life: 3000
    });
  }
};

function handlePayload(payload) {
  console.log('FCM payload:', payload);
  if (
    Notification.permission === 'granted' &&
    payload.notification &&
    payload.notification.title
  ) {
    new Notification(payload.notification.title, {
      body: payload.notification.body,
      icon: '/logo.png',
      badge: '/logo.png',
      tag: 'payment-notification'
    });
    toast.add({
      severity: 'success',
      summary: payload.notification.title,
      detail: payload.notification.body,
      life: 5000
    });
    window.dispatchEvent(new Event('refresh-notifications'));
  }
  onMessageListener().then(handlePayload);
}

onMounted(async () => {
  await requestNotificationPermission();
  if (Notification.permission === 'granted') {
    onMessageListener().then(handlePayload);
  }
});

onUnmounted(() => {
  // Không cần unsubscribe vì onMessageListener là promise một lần, ta gọi lại mỗi lần nhận được payload
});
</script> 