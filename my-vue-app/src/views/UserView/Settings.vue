<template>
  <div class="settings-container">
    <div class="settings-header">
      <h2>Cài đặt</h2>
    </div>

    <div class="settings-content">
      <div class="settings-section">
        <h3>Thông báo</h3>
        <div class="settings-item">
          <div class="settings-item-info">
            <h4>Thông báo hệ thống</h4>
            <p>Nhận thông báo về các hoạt động trong hệ thống</p>
          </div>
          <div class="settings-item-action">
            <InputSwitch v-model="settings.systemNotifications" @change="updateSettings" />
          </div>
        </div>

        <div class="settings-item">
          <div class="settings-item-info">
            <h4>Thông báo thanh toán</h4>
            <p>Nhận thông báo về trạng thái thanh toán</p>
          </div>
          <div class="settings-item-action">
            <InputSwitch v-model="settings.paymentNotifications" @change="updateSettings" />
          </div>
        </div>

        <div class="settings-item">
          <div class="settings-item-info">
            <h4>Thông báo tin nhắn</h4>
            <p>Nhận thông báo khi có tin nhắn mới</p>
          </div>
          <div class="settings-item-action">
            <InputSwitch v-model="settings.messageNotifications" @change="updateSettings" />
          </div>
        </div>

        <div class="settings-item">
          <div class="settings-item-info">
            <h4>Thông báo lịch hẹn</h4>
            <p>Nhận thông báo về lịch hẹn và nhắc nhở</p>
          </div>
          <div class="settings-item-action">
            <InputSwitch v-model="settings.appointmentNotifications" @change="updateSettings" />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue';
import { useToast } from 'primevue/usetoast';
import InputSwitch from 'primevue/inputswitch';
import axiosInstance from '../../services/axiosInstance';

export default {
  name: 'Settings',
  components: {
    InputSwitch
  },
  setup() {
    const toast = useToast();
    const settings = ref({
      systemNotifications: true,
      paymentNotifications: true,
      messageNotifications: true,
      appointmentNotifications: true
    });

    const fetchSettings = async () => {
      try {
        const response = await axiosInstance.get('/api/users/settings');
        settings.value = response.data;
      } catch (error) {
        console.error('Lỗi khi lấy cài đặt:', error);
        toast.add({
          severity: 'error',
          summary: 'Lỗi',
          detail: 'Không thể tải cài đặt',
          life: 3000
        });
      }
    };

    const updateSettings = async () => {
      try {
        await axiosInstance.put('/api/users/settings', settings.value);
        toast.add({
          severity: 'success',
          summary: 'Thành công',
          detail: 'Cài đặt đã được cập nhật',
          life: 3000
        });
      } catch (error) {
        console.error('Lỗi khi cập nhật cài đặt:', error);
        toast.add({
          severity: 'error',
          summary: 'Lỗi',
          detail: 'Không thể cập nhật cài đặt',
          life: 3000
        });
      }
    };

    onMounted(() => {
      fetchSettings();
    });

    return {
      settings,
      updateSettings
    };
  }
};
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

.settings-section h3 {
  color: #2c3e50;
  font-size: 18px;
  margin-bottom: 20px;
  padding-bottom: 10px;
  border-bottom: 1px solid #eee;
}

.settings-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 0;
  border-bottom: 1px solid #eee;
}

.settings-item:last-child {
  border-bottom: none;
}

.settings-item-info {
  flex: 1;
}

.settings-item-info h4 {
  color: #2c3e50;
  font-size: 16px;
  margin-bottom: 5px;
}

.settings-item-info p {
  color: #7f8c8d;
  font-size: 14px;
  margin: 0;
}

.settings-item-action {
  margin-left: 20px;
}

@media (max-width: 768px) {
  .settings-container {
    padding: 15px;
  }

  .settings-item {
    flex-direction: column;
    align-items: flex-start;
  }

  .settings-item-action {
    margin-left: 0;
    margin-top: 10px;
  }
}
</style> 