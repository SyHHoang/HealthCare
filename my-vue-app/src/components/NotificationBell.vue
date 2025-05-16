<template>
  <div class="notification-bell">
    <div class="dropdown">
      <button class="btn btn-link position-relative" type="button" data-bs-toggle="dropdown">
        <i class="fas fa-bell fa-lg"></i>
        <span v-if="unreadCount > 0" class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
          {{ unreadCount }}
        </span>
      </button>
      <div class="dropdown-menu dropdown-menu-end p-0" style="width: 300px; max-height: 400px; overflow-y: auto;">
        <div class="d-flex justify-content-between align-items-center p-2 border-bottom">
          <h6 class="mb-0">Thông báo</h6>
          <button v-if="notifications.length > 0" class="btn btn-sm btn-link" @click="markAllAsRead">
            Đánh dấu tất cả đã đọc
          </button>
        </div>
        <div v-if="notifications.length === 0" class="p-3 text-center">
          Không có thông báo mới
        </div>
        <div v-else>
          <div v-for="notification in notifications" :key="notification._id" 
               class="dropdown-item p-2 border-bottom"
               :class="{ 'bg-light': !notification.isRead }">
            <div class="d-flex justify-content-between align-items-start">
              <div>
                <h6 class="mb-1">{{ notification.title }}</h6>
                <p class="mb-1 small">{{ notification.message }}</p>
                <small class="text-muted">{{ formatDate(notification.createdAt) }}</small>
              </div>
              <div>
                <button v-if="!notification.isRead" 
                        class="btn btn-sm btn-link p-0" 
                        @click="markAsRead(notification._id)">
                  <i class="fas fa-check"></i>
                </button>
                <button class="btn btn-sm btn-link p-0" @click="deleteNotification(notification._id)">
                  <i class="fas fa-trash"></i>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted, onUnmounted } from 'vue';
import { useNotificationStore } from '../stores/notificationStore';
import { format } from 'date-fns';
import { vi } from 'date-fns/locale';

const store = useNotificationStore();
const { notifications, unreadCount, fetchNotifications, markAsRead, markAllAsRead, deleteNotification, connectSocket, disconnectSocket } = store;

const formatDate = (date) => {
  return format(new Date(date), 'HH:mm dd/MM/yyyy', { locale: vi });
};

const refreshNotifications = async () => {
  const userId = JSON.parse(localStorage.getItem('user'))._id;
  await fetchNotifications(userId);
};

onMounted(async () => {
  const token = localStorage.getItem('token');
  if (token) {
    connectSocket(token);
    const userId = JSON.parse(localStorage.getItem('user'))._id;
    await fetchNotifications(userId);
  }
  // Lắng nghe sự kiện refresh-notifications
  window.addEventListener('refresh-notifications', refreshNotifications);
});

onUnmounted(() => {
  disconnectSocket();
  window.removeEventListener('refresh-notifications', refreshNotifications);
});
</script>

<style scoped>
.notification-bell {
  position: relative;
}

.dropdown-menu {
  min-width: 300px;
}

.badge {
  font-size: 0.7rem;
  padding: 0.25rem 0.5rem;
}

.dropdown-item {
  white-space: normal;
}

.dropdown-item:hover {
  background-color: #f8f9fa;
}
</style> 