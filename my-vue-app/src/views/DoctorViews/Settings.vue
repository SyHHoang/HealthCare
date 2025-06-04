<template>
  <div class="settings-container">
    <div class="settings-header">
      <h2>Cài đặt</h2>
    </div>

    <div class="settings-content">
      <div class="settings-section">
        <div class="settings-item" @click="navigateTo('/doctor/feedback')">
          <div class="settings-item-info">
            <i class="pi pi-comment" style="font-size: 1.5rem; color: #4CAF50;"></i>
            <div class="settings-text">
              <h4>Phản hồi</h4>
              <p>Gửi phản hồi và đánh giá về ứng dụng</p>
            </div>
          </div>
          <i class="pi pi-chevron-right"></i>
        </div>

        <div class="settings-item" @click="navigateTo('/doctor/contact')">
          <div class="settings-item-info">
            <i class="pi pi-envelope" style="font-size: 1.5rem; color: #2196F3;"></i>
            <div class="settings-text">
              <h4>Liên hệ</h4>
              <p>Liên hệ với chúng tôi</p>
            </div>
          </div>
          <i class="pi pi-chevron-right"></i>
        </div>

        <div class="settings-item" @click="navigateTo('/doctor/change-password')">
          <div class="settings-item-info">
            <i class="pi pi-lock" style="font-size: 1.5rem; color: #FF9800;"></i>
            <div class="settings-text">
              <h4>Đổi mật khẩu</h4>
              <p>Thay đổi mật khẩu tài khoản của bạn</p>
            </div>
          </div>
          <i class="pi pi-chevron-right"></i>
        </div>
        <div class="settings-item" @click="showNotificationSettings">
          <div class="settings-item-info">
            <i class="pi pi-bell" style="font-size: 1.5rem; color: #9C27B0;"></i>
            <div class="settings-text">
              <h4>Cài đặt thông báo</h4>
              <p>Quản lý cài đặt thông báo của bạn</p>
            </div>
          </div>
          <i class="pi pi-chevron-right"></i>
        </div>
      </div>
    </div>

    <!-- Dialog cài đặt thông báo -->
    <Dialog v-model:visible="notificationDialog" modal header="Cài đặt thông báo" :style="{width: '450px'}" class="p-fluid">
      <div class="notification-settings">
        <div class="settings-item">
          <div class="settings-item-info">
            <h4>Thông báo</h4>
            <p>Bật/tắt thông báo từ ứng dụng</p>
          </div>
          <div class="settings-item-action">
            <InputSwitch v-model="settings.enabled" @change="updateSettings" />
          </div>
        </div>
      </div>
    </Dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useToast } from 'primevue/usetoast';
import { useRouter } from 'vue-router';
import InputSwitch from 'primevue/inputswitch';
import Dialog from 'primevue/dialog';
import axiosInstance from '../../services/axiosInstance';

const router = useRouter();
const toast = useToast();
const notificationDialog = ref(false);
const settings = ref({
  enabled: true
});

const fetchSettings = async () => {
  try {
    const response = await axiosInstance.get('/api/doctors/settings');
    if (response.data.success) {
      settings.value.enabled = response.data.settings.enabled;
    }
  } catch (error) {
    console.error('Lỗi khi lấy cài đặt:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể tải cài đặt thông báo',
      life: 3000
    });
  }
};

const updateSettings = async () => {
  try {
    const response = await axiosInstance.put('/api/doctors/settings', {
      enabled: settings.value.enabled
    });
    
    if (response.data.success) {
      toast.add({
        severity: 'success',
        summary: 'Thành công',
        detail: 'Cài đặt thông báo đã được cập nhật',
        life: 3000
      });
    }
  } catch (error) {
    console.error('Lỗi khi cập nhật cài đặt:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể cập nhật cài đặt thông báo',
      life: 3000
    });
    // Khôi phục lại giá trị cũ nếu cập nhật thất bại
    await fetchSettings();
  }
};

const showNotificationSettings = () => {
  notificationDialog.value = true;
};

const navigateTo = (path) => {
  router.push(path);
};

onMounted(() => {
  fetchSettings();
});
</script>

<style scoped>
.settings-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
}

.settings-header {
  margin-bottom: 30px;
}

.settings-header h2 {
  color: #2c3e50;
  font-size: 24px;
  font-weight: 600;
}

.settings-section {
  background: white;
  border-radius: 10px;
  padding: 20px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.05);
}

.settings-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  border-bottom: 1px solid #eee;
  cursor: pointer;
  transition: background-color 0.3s;
}

.settings-item:hover {
  background-color: #f8f9fa;
}

.settings-item:last-child {
  border-bottom: none;
}

.settings-item-info {
  display: flex;
  align-items: center;
  gap: 15px;
  flex: 1;
}

.settings-text {
  flex: 1;
}

.settings-text h4 {
  color: #2c3e50;
  font-size: 16px;
  margin-bottom: 5px;
}

.settings-text p {
  color: #7f8c8d;
  font-size: 14px;
  margin: 0;
}

.notification-settings {
  padding: 20px;
}

.notification-settings .settings-item {
  padding: 15px 0;
}

.notification-settings .settings-item:last-child {
  border-bottom: none;
}

@media (max-width: 768px) {
  .settings-container {
    padding: 15px;
  }

  .settings-item {
    padding: 15px;
  }

  .settings-item-info {
    gap: 10px;
  }
}
</style> 