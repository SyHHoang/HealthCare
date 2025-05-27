<template>
  <div class="notifications-page">
    <div class="container py-4">
      <div class="row">
        <div class="col-12">
          <div class="notifications-header d-flex justify-content-between align-items-center mb-4">
            <h2 class="page-title">Thông báo</h2>
            <div class="header-actions">
              <button 
                class="btn btn-outline-primary" 
                @click="markAllAsRead"
                :disabled="!hasUnreadNotifications"
              >
                <i class="bi bi-check2-all me-2"></i>
                Đánh dấu tất cả đã đọc
              </button>
            </div>
          </div>

          <div class="notifications-list">
            <div v-if="loading" class="text-center py-5">
              <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">Loading...</span>
              </div>
            </div>

            <div v-else-if="notifications.length === 0" class="empty-state text-center py-5">
              <i class="bi bi-bell-slash display-1 text-muted"></i>
              <p class="mt-3 text-muted">Không có thông báo nào</p>
            </div>

            <div v-else class="notification-items">
              <div 
                v-for="notification in notifications" 
                :key="notification._id"
                class="notification-item"
                :class="{ 'unread': !notification.read }"
                @click="handleNotificationClick(notification)"
              >
                <div class="notification-icon">
                  <i :class="getNotificationIcon(notification.type)"></i>
                </div>
                <div class="notification-content">
                  <div class="notification-header">
                    <h5 class="notification-title">{{ notification.title }}</h5>
                    <span class="notification-time">{{ formatTime(notification.createdAt) }}</span>
                  </div>
                  <p class="notification-message">{{ notification.message }}</p>
                  <div v-if="notification.data" class="notification-data">
                    <div v-for="(value, key) in notification.data" :key="key" class="data-item">
                      <span class="data-label">{{ formatDataLabel(key) }}:</span>
                      <span class="data-value">{{ formatDataValue(value) }}</span>
                    </div>
                  </div>
                </div>
                <div class="notification-actions">
                  <button 
                    v-if="!notification.read"
                    class="btn btn-sm btn-light"
                    @click.stop="markAsRead(notification._id)"
                  >
                    <i class="bi bi-check2"></i>
                  </button>
                  <button 
                    class="btn btn-sm btn-light text-danger"
                    @click.stop="deleteNotification(notification._id)"
                  >
                    <i class="bi bi-trash"></i>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { format, parseISO } from 'date-fns';
import { vi } from 'date-fns/locale';
import axiosInstance from '@/services/axiosInstance';
import { useToast } from 'primevue/usetoast';

const toast = useToast();
const notifications = ref([]);
const loading = ref(true);

// Computed property để kiểm tra có thông báo chưa đọc không
const hasUnreadNotifications = computed(() => {
  return notifications.value.some(notification => !notification.read);
});

// Lấy icon tương ứng với loại thông báo
const getNotificationIcon = (type) => {
  const icons = {
    appointment: 'bi bi-calendar-check',
    message: 'bi bi-chat-dots',
    system: 'bi bi-info-circle',
    prescription: 'bi bi-clipboard2-pulse',
    cancel: 'bi bi-x-circle',
    reminder: 'bi bi-bell',
    feedback: 'bi bi-star'
  };
  return icons[type] || 'bi bi-bell';
};

// Format thời gian
const formatTime = (time) => {
  try {
    const date = time instanceof Date ? time : parseISO(time);
    const now = new Date();
    if (date.toDateString() === now.toDateString()) {
      return format(date, 'HH:mm', { locale: vi });
    }
    return format(date, 'dd/MM/yyyy - HH:mm', { locale: vi });
  } catch (error) {
    return 'Không rõ thời gian';
  }
};

// Thêm hàm format label
const formatDataLabel = (key) => {
  const labels = {
    'Mã đơn hàng': 'Mã đơn hàng',
    'Số tiền': 'Số tiền',
    'Loại giao dịch': 'Loại giao dịch',
    'Ngày thanh toán': 'Ngày thanh toán'
  };
  return labels[key] || key;
};

// Thêm hàm format value
const formatDataValue = (value) => {
  if (typeof value === 'number' && value >= 1000) {
    return new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency: 'VND'
    }).format(value);
  }
  if (value instanceof Date || (typeof value === 'string' && value.includes('T'))) {
    try {
      const date = new Date(value);
      return format(date, 'dd/MM/yyyy HH:mm', { locale: vi });
    } catch (e) {
      return value;
    }
  }
  return value;
};

// Lấy danh sách thông báo
const fetchNotifications = async () => {
  try {
    loading.value = true;
    const response = await axiosInstance.get('/api/notifications');
    notifications.value = response.data;
  } catch (error) {
    console.error('Lỗi khi lấy thông báo:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể tải danh sách thông báo',
      life: 3000
    });
  } finally {
    loading.value = false;
  }
};

// Đánh dấu thông báo đã đọc
const markAsRead = async (notificationId) => {
  try {
    await axiosInstance.patch(`/api/notifications/${notificationId}/read`);
    const notification = notifications.value.find(n => n._id === notificationId);
    if (notification) {
      notification.read = true;
    }
  } catch (error) {
    console.error('Lỗi khi đánh dấu đã đọc:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể đánh dấu thông báo đã đọc',
      life: 3000
    });
  }
};

// Đánh dấu tất cả đã đọc
const markAllAsRead = async () => {
  try {
    await axiosInstance.patch('/api/notifications/read-all');
    notifications.value.forEach(notification => {
      notification.read = true;
    });
    toast.add({
      severity: 'success',
      summary: 'Thành công',
      detail: 'Đã đánh dấu tất cả thông báo đã đọc',
      life: 3000
    });
  } catch (error) {
    console.error('Lỗi khi đánh dấu tất cả đã đọc:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể đánh dấu tất cả thông báo đã đọc',
      life: 3000
    });
  }
};

// Xóa thông báo
const deleteNotification = async (notificationId) => {
  try {
    await axiosInstance.delete(`/api/notifications/${notificationId}`);
    notifications.value = notifications.value.filter(n => n._id !== notificationId);
    toast.add({
      severity: 'success',
      summary: 'Thành công',
      detail: 'Đã xóa thông báo',
      life: 3000
    });
  } catch (error) {
    console.error('Lỗi khi xóa thông báo:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể xóa thông báo',
      life: 3000
    });
  }
};

// Xử lý khi click vào thông báo
const handleNotificationClick = (notification) => {
  if (!notification.read) {
    markAsRead(notification._id);
  }
  
  // Xử lý điều hướng dựa vào loại thông báo và data
  if (notification.data) {
    switch (notification.type) {
      case 'appointment':
        // Điều hướng đến trang chi tiết lịch hẹn
        break;
      case 'message':
        // Điều hướng đến trang chat
        break;
      case 'prescription':
        // Điều hướng đến trang đơn thuốc
        break;
      // Thêm các case khác tùy theo loại thông báo
    }
  }
};

onMounted(() => {
  fetchNotifications();
});
</script>

<style scoped>
.notifications-page {
  background-color: #f8f9fa;
  min-height: calc(100vh - 70px);
}

.page-title {
  color: #2c3e50;
  font-weight: 600;
  margin: 0;
}

.notification-items {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.notification-item {
  display: flex;
  align-items: flex-start;
  padding: 1.25rem;
  background-color: white;
  border-radius: 10px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
  transition: all 0.3s ease;
  cursor: pointer;
  margin-bottom: 1rem;
}

.notification-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.notification-item.unread {
  background-color: #f0f7ff;
  border-left: 4px solid #3498db;
}

.notification-icon {
  width: 45px;
  height: 45px;
  border-radius: 50%;
  background-color: #e8f4fc;
  color: #3498db;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 1.25rem;
  flex-shrink: 0;
  font-size: 1.25rem;
}

.notification-content {
  flex: 1;
  min-width: 0;
}

.notification-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 0.5rem;
}

.notification-title {
  margin: 0;
  font-size: 1.1rem;
  font-weight: 600;
  color: #2c3e50;
}

.notification-time {
  font-size: 0.875rem;
  color: #95a5a6;
  white-space: nowrap;
  margin-left: 1rem;
}

.notification-message {
  margin: 0.5rem 0;
  color: #34495e;
  font-size: 0.9375rem;
  line-height: 1.5;
}

.notification-data {
  margin-top: 0.75rem;
  padding: 0.75rem;
  background-color: #f8f9fa;
  border-radius: 6px;
  font-size: 0.875rem;
}

.data-item {
  display: flex;
  margin-bottom: 0.5rem;
  line-height: 1.4;
}

.data-item:last-child {
  margin-bottom: 0;
}

.data-label {
  font-weight: 600;
  color: #495057;
  min-width: 120px;
  margin-right: 0.5rem;
}

.data-value {
  color: #6c757d;
  flex: 1;
}

.notification-actions {
  display: flex;
  gap: 0.5rem;
  margin-left: 1rem;
}

.btn-light {
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
}

.empty-state {
  color: #95a5a6;
}

.empty-state i {
  font-size: 4rem;
}

@media (max-width: 768px) {
  .notifications-header {
    flex-direction: column;
    gap: 1rem;
  }

  .header-actions {
    width: 100%;
  }

  .header-actions button {
    width: 100%;
  }

  .notification-header {
    flex-direction: column;
  }

  .notification-time {
    margin-left: 0;
    margin-top: 0.25rem;
  }
}
</style> 