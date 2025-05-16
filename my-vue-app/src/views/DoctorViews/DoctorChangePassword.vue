<template>
  <div class="change-password">
    <h1>Đổi mật khẩu</h1>
    <div class="alert alert-info">
      <i class="fas fa-info-circle"></i>
      Vui lòng nhập mật khẩu hiện tại và mật khẩu mới để thay đổi.
    </div>

    <form @submit.prevent="handleChangePassword" class="password-form">
      <div class="form-group">
        <label for="currentPassword">Mật khẩu hiện tại</label>
        <input
          type="password"
          id="currentPassword"
          v-model="form.currentPassword"
          required
          class="form-control"
          placeholder="Nhập mật khẩu hiện tại"
        />
      </div>

      <div class="form-group">
        <label for="newPassword">Mật khẩu mới</label>
        <input
          type="password"
          id="newPassword"
          v-model="form.newPassword"
          required
          class="form-control"
          placeholder="Nhập mật khẩu mới"
        />
        <small class="text-muted">Mật khẩu phải có ít nhất 6 ký tự</small>
      </div>

      <div class="form-group">
        <label for="confirmPassword">Xác nhận mật khẩu mới</label>
        <input
          type="password"
          id="confirmPassword"
          v-model="form.confirmPassword"
          required
          class="form-control"
          placeholder="Nhập lại mật khẩu mới"
        />
      </div>

      <div class="form-actions">
        <button type="submit" class="submit-btn" :disabled="isSubmitting">
          {{ isSubmitting ? 'Đang xử lý...' : 'Đổi mật khẩu' }}
        </button>
      </div>
    </form>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue';
import { useRouter } from 'vue-router';
import axiosInstance from '../services/axios-config';

const router = useRouter();
const isSubmitting = ref(false);

const form = reactive({
  currentPassword: '',
  newPassword: '',
  confirmPassword: ''
});

const handleChangePassword = async () => {
  // Kiểm tra mật khẩu mới và xác nhận mật khẩu
  if (form.newPassword !== form.confirmPassword) {
    alert('Mật khẩu mới và xác nhận mật khẩu không khớp!');
    return;
  }

  // Kiểm tra độ dài mật khẩu mới
  if (form.newPassword.length < 6) {
    alert('Mật khẩu mới phải có ít nhất 6 ký tự!');
    return;
  }

  isSubmitting.value = true;

  try {
    await axiosInstance.post('/api/doctors/change-password', {
      currentPassword: form.currentPassword,
      newPassword: form.newPassword
    });

    alert('Đổi mật khẩu thành công!');
    
    // Xóa form
    form.currentPassword = '';
    form.newPassword = '';
    form.confirmPassword = '';
    
    // Chuyển hướng về trang profile
    router.push('/doctor/profile');
  } catch (error) {
    console.error('Lỗi đổi mật khẩu:', error);
    alert(error.response?.data?.message || 'Có lỗi xảy ra khi đổi mật khẩu. Vui lòng thử lại!');
  } finally {
    isSubmitting.value = false;
  }
};
</script>

<style scoped>
.change-password {
  max-width: 500px;
  margin: 40px auto;
  padding: 20px;
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
}

h1 {
  text-align: center;
  color: #333;
  margin-bottom: 30px;
}

.alert {
  padding: 15px;
  margin-bottom: 20px;
  border-radius: 5px;
  background-color: #e3f2fd;
  color: #1976d2;
  border: 1px solid #bbdefb;
}

.alert i {
  margin-right: 10px;
}

.password-form {
  padding: 20px;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  color: #495057;
  font-weight: 500;
}

.form-control {
  width: 100%;
  padding: 10px;
  border: 1px solid #ced4da;
  border-radius: 5px;
  font-size: 1rem;
}

.form-control:focus {
  border-color: #80bdff;
  outline: 0;
  box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
}

.text-muted {
  color: #6c757d;
  font-size: 0.875rem;
  margin-top: 5px;
}

.form-actions {
  text-align: center;
  margin-top: 30px;
}

.submit-btn {
  padding: 12px 30px;
  background: #007bff;
  color: white;
  border: none;
  border-radius: 5px;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.3s ease;
}

.submit-btn:hover:not(:disabled) {
  background: #0056b3;
  transform: translateY(-1px);
}

.submit-btn:disabled {
  background: #cccccc;
  cursor: not-allowed;
  transform: none;
}

@media (max-width: 768px) {
  .change-password {
    margin: 20px;
    padding: 15px;
  }
}
</style>
