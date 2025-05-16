<template>
  <div class="doctor-login">
    <h1>Đăng nhập Bác sĩ</h1>
    <form @submit.prevent="login" class="login-form">
      <div class="form-group">
        <label for="email">Email</label>
        <input
          type="email"
          id="email"
          v-model="form.email"
          placeholder="Nhập email"
          required
        />
      </div>
      <div class="form-group">
        <label for="password">Mật khẩu</label>
        <input
          type="password"
          id="password"
          v-model="form.password"
          placeholder="Nhập mật khẩu"
          required
        />
      </div>
      <div class="form-group checkbox">
        <input
          type="checkbox"
          id="remember"
          v-model="form.remember"
        />
        <label for="remember">Ghi nhớ đăng nhập</label>
      </div>
      <div v-if="errorMessage" class="error-message">
        {{ errorMessage }}
      </div>
      <button type="submit" class="submit-btn" :disabled="isSubmitting">
        {{ isSubmitting ? 'Đang đăng nhập...' : 'Đăng nhập' }}
      </button>
    </form>
    <p class="forgot-password">
      <a href="#" @click.prevent="showForgotPasswordModal = true">Quên mật khẩu?</a>
    </p>
    <p class="register-link">
      Chưa có tài khoản bác sĩ? <router-link to="/auth/doctor/register">Đăng ký ngay</router-link>
    </p>
    <p class="user-link">
      Bạn là người dùng thường? <router-link to="/auth/login">Đăng nhập ngay</router-link>
    </p>

    <!-- Modal quên mật khẩu -->
    <div class="modal" v-if="showForgotPasswordModal">
      <div class="modal-content">
        <h2>Quên mật khẩu</h2>
        <p>Vui lòng nhập email của bạn để nhận hướng dẫn đặt lại mật khẩu.</p>
        <form @submit.prevent="handleForgotPassword">
          <div class="form-group">
            <label for="forgotEmail">Email</label>
            <input
              type="email"
              id="forgotEmail"
              v-model="forgotPasswordEmail"
              placeholder="Nhập email"
              required
            />
          </div>
          <div class="modal-actions">
            <button type="button" class="cancel-btn" @click="showForgotPasswordModal = false">
              Hủy
            </button>
            <button type="submit" class="submit-btn">
              Gửi yêu cầu
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, inject } from 'vue';
import { useRouter } from 'vue-router';
import axiosInstance from '@/services/axiosInstance.js';

const router = useRouter();
const errorMessage = ref('');
const isSubmitting = ref(false);
const showForgotPasswordModal = ref(false);
const forgotPasswordEmail = ref('');

const form = reactive({
  email: '',
  password: '',
  remember: false
});

const login = async () => {
  isSubmitting.value = true;
  errorMessage.value = '';
  
  try {
    const response = await axiosInstance.post('/api/doctors/login', {
      email: form.email,
      password: form.password
    });
    console.log(response.data);
    // Lưu token và thông tin bác sĩ
    localStorage.setItem('token', response.data.token);
    localStorage.setItem('role', 'doctor');
    localStorage.setItem('user', JSON.stringify(response.data.doctor));
    
    // Lưu thông tin ghi nhớ nếu được chọn
    if (form.remember) {
      localStorage.setItem('rememberedEmail', form.email);
    } else {
      localStorage.removeItem('rememberedEmail');
    }
    
    // Thông báo thành công
    const toast = inject('$toast', null);
    if (toast) {
      toast.add({
        severity: 'success',
        summary: 'Đăng nhập thành công',
        detail: 'Chào mừng bạn trở lại!',
        life: 3000
      });
    } else {
      alert('Đăng nhập thành công!');
    }
    
    // Chuyển hướng đến trang dashboard của bác sĩ
    router.push('/doctor/dashboard');
  } catch (error) {
    console.error('Lỗi đăng nhập:', error);
    
    if (error.response) {
      // Lỗi từ server
      errorMessage.value = error.response.data.message || 'Email hoặc mật khẩu không chính xác!';
    } else if (error.request) {
      // Không thể kết nối đến server
      errorMessage.value = 'Không thể kết nối đến server, vui lòng kiểm tra kết nối!';
    } else {
      errorMessage.value = 'Đã xảy ra lỗi, vui lòng thử lại sau!';
    }
  } finally {
    isSubmitting.value = false;
  }
};

const handleForgotPassword = async () => {
  try {
    await axiosInstance.post('/api/auth/forgot-password', {
      email: forgotPasswordEmail.value
    });
    
    // Thông báo thành công
    const toast = inject('$toast', null);
    if (toast) {
      toast.add({
        severity: 'success',
        summary: 'Gửi yêu cầu thành công',
        detail: 'Vui lòng kiểm tra email của bạn để đặt lại mật khẩu.',
        life: 3000
      });
    } else {
      alert('Vui lòng kiểm tra email của bạn để đặt lại mật khẩu.');
    }
    
    showForgotPasswordModal.value = false;
    forgotPasswordEmail.value = '';
  } catch (error) {
    console.error('Lỗi gửi yêu cầu:', error);
    errorMessage.value = 'Không thể gửi yêu cầu, vui lòng thử lại sau!';
  }
};
</script>

<style scoped>
.doctor-login {
  max-width: 500px;
  margin: 40px auto;
  padding: 20px;
  background: #f9f9f9;
  border-radius: 10px;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
}

h1 {
  text-align: center;
  font-size: 28px;
  color: #333;
  margin-bottom: 20px;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.form-group label {
  font-size: 14px;
  color: #555;
  margin-bottom: 5px;
}

.form-group input {
  padding: 10px;
  font-size: 16px;
  border: 1px solid #ddd;
  border-radius: 5px;
  outline: none;
}

.form-group input:focus {
  border-color: gold;
}

.checkbox {
  flex-direction: row;
  align-items: center;
  gap: 10px;
}

.checkbox label {
  font-size: 14px;
  color: #333;
}

.submit-btn {
  padding: 12px;
  background: gold;
  color: white;
  border: none;
  border-radius: 5px;
  font-size: 16px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.submit-btn:hover:not(:disabled) {
  background: #ffd700;
  transform: translateY(-1px);
}

.submit-btn:disabled {
  background: #cccccc;
  cursor: not-allowed;
  transform: none;
}

.forgot-password {
  text-align: right;
  margin-top: 10px;
}

.forgot-password a {
  color: gold;
  text-decoration: none;
  font-size: 14px;
}

.forgot-password a:hover {
  text-decoration: underline;
}

.register-link,
.user-link {
  text-align: center;
  margin-top: 10px;
  font-size: 14px;
}

.register-link a,
.user-link a {
  color: gold;
  text-decoration: none;
  font-weight: 500;
}

.register-link a:hover,
.user-link a:hover {
  text-decoration: underline;
}

.error-message {
  color: #ff4444;
  margin: 10px 0;
  padding: 10px;
  background: #ffebee;
  border-radius: 5px;
  font-size: 14px;
  text-align: center;
}

/* Modal styles */
.modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  padding: 30px;
  border-radius: 10px;
  width: 90%;
  max-width: 400px;
}

.modal-content h2 {
  margin-bottom: 15px;
  color: #333;
}

.modal-content p {
  margin-bottom: 20px;
  color: #666;
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 20px;
}

.cancel-btn {
  padding: 8px 16px;
  background: #f5f5f5;
  color: #666;
  border: none;
  border-radius: 5px;
  cursor: pointer;
}

.cancel-btn:hover {
  background: #e0e0e0;
}
</style> 