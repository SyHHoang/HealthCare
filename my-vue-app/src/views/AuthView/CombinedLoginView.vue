<template>
  <div class="login">
    <h1>Đăng nhập</h1>
    <div class="role-select">
      <button :class="{ active: role === 'user' }" @click="role = 'user'">
        <span class="icon">👤</span> Bệnh nhân
      </button>
      <button :class="{ active: role === 'doctor' }" @click="role = 'doctor'">
        <span class="icon">🩺</span> Bác sĩ
      </button>
    </div>
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
        <a @click="showForgotPassword = true" class="forgot-password">Quên mật khẩu?</a>
      </div>
      <div v-if="errorMessage" class="error-message">
        {{ errorMessage }}
      </div>
      <button type="submit" class="submit-btn" :disabled="isLoading">
        {{ isLoading ? 'Đang đăng nhập...' : 'Đăng nhập' }}
      </button>
    </form>
    <p class="register-link">
      Chưa có tài khoản? <router-link to="/auth/register" class="register-link-highlight">Đăng ký</router-link>
    </p>
    <!-- Modal quên mật khẩu -->
    <div class="modal" v-if="showForgotPassword">
      <div class="modal-content">
        <h2>Khôi phục mật khẩu</h2>
        <p>Nhập email của bạn để nhận link đặt lại mật khẩu</p>
        <form @submit.prevent="sendResetLink" class="forgot-password-form">
          <div class="form-group">
            <input
              type="email"
              v-model="resetEmail"
              placeholder="Nhập email của bạn"
              required
            />
          </div>
          <div class="modal-buttons">
            <button type="submit" class="submit-btn">Gửi link</button>
            <button type="button" @click="showForgotPassword = false" class="cancel-btn">Hủy</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import axiosInstance from '@/services/axiosInstance.js';
import { jwtDecode } from 'jwt-decode';

const router = useRouter();
const route = useRoute();

const role = ref('user'); // 'user' hoặc 'doctor'
const form = reactive({
  email: '',
  password: '',
});
const showForgotPassword = ref(false);
const resetEmail = ref('');
const errorMessage = ref('');
const isLoading = ref(false);

const login = async () => {
  errorMessage.value = '';
  isLoading.value = true;
  try {
    let response;
    if (role.value === 'doctor') {
      console.log('Đang đăng nhập bác sĩ với:', {
        email: form.email,
        password: form.password
      });
      response = await axiosInstance.post('/api/doctors/login', {
        email: form.email,
        password: form.password
      });
    } else {
      response = await axiosInstance.post('/api/auth/login', {
        email: form.email,
        password: form.password
      });
    }
    if (response.data && response.data.token) {
      const decodedToken = jwtDecode(response.data.token);
      localStorage.setItem('token', response.data.token);
      localStorage.setItem('role', decodedToken.role || role.value);
      if (role.value === 'doctor') {
        localStorage.setItem('user', JSON.stringify(response.data.doctor));
        router.push('/doctor/dashboard');
      } else {
        // Kiểm tra role và chuyển hướng
        const payload = JSON.parse(atob(response.data.token.split('.')[1]));
        if (payload.role === 'admin') {
          router.push('/admin');
        } else if (payload.role === 'doctor') {
          router.push('/doctor/dashboard');
        } else {
          router.push('/user/dashboard');
        }
      }
    } else {
      throw new Error('Không nhận được token');
    }
  } catch (error) {
    if (error.response) {
      errorMessage.value = `Đăng nhập thất bại: ${error.response.data.message || 'Vui lòng kiểm tra lại thông tin'}`;
    } else if (error.request) {
      errorMessage.value = 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
    } else {
      errorMessage.value = 'Đã có lỗi xảy ra. Vui lòng thử lại sau.';
    }
    // Không điều hướng khi đăng nhập thất bại
  } finally {
    isLoading.value = false;
  }
};

const sendResetLink = async () => {
  try {
    if (role.value === 'doctor') {
      await axiosInstance.post('/api/auth/forgot-password', {
        email: resetEmail.value
      });
    } else {
      await axiosInstance.post('/api/users/forgot-password', {
        email: resetEmail.value
      });
    }
    alert('Link đặt lại mật khẩu đã được gửi đến email của bạn!');
    showForgotPassword.value = false;
    resetEmail.value = '';
  } catch (error) {
    alert('Không thể gửi link: ' + (error.response?.data.message || error.message));
  }
};
</script>

<style scoped>
.login {
  max-width: 400px;
  margin: 40px auto;
  padding: 20px;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}

h1 {
  text-align: center;
  font-size: 28px;
  color: #333;
  margin-bottom: 18px;
}

.role-select {
  display: flex;
  justify-content: center;
  gap: 12px;
  margin-bottom: 18px;
}
.role-select button {
  flex: 1;
  padding: 10px 0;
  border: 1px solid #ddd;
  background: #f7f7f7;
  color: #333;
  border-radius: 6px;
  font-size: 16px;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
}
.role-select button.active {
  background: gold;
  color: #fff;
  border-color: gold;
}
.role-select .icon {
  font-size: 18px;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.form-group {
  display: flex;
  flex-direction: column;
  position: relative;
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
.forgot-password {
  position: absolute;
  right: 0;
  top: 0;
  font-size: 14px;
  color: gold;
  text-decoration: none;
  cursor: pointer;
  transition: all 0.3s ease;
}
.forgot-password:hover {
  color: #ffd700;
  text-decoration: underline;
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
.submit-btn:hover {
  background: #ffd700;
  transform: translateY(-1px);
}
.submit-btn:disabled {
  background: #cccccc;
  cursor: not-allowed;
  transform: none;
}
.register-link {
  text-align: center;
  margin-top: 20px;
  font-size: 14px;
  color: #666;
}
.register-link-highlight {
  color: gold;
  text-decoration: none;
  font-weight: bold;
  margin-left: 5px;
  transition: all 0.3s ease;
}
.register-link-highlight:hover {
  color: #ffd700;
  text-decoration: underline;
}
/* Modal styles */
.modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}
.modal-content {
  background: white;
  padding: 30px;
  border-radius: 10px;
  max-width: 400px;
  width: 90%;
}
.modal-content h2 {
  margin-bottom: 15px;
  color: #333;
  font-size: 24px;
}
.modal-content p {
  color: #666;
  margin-bottom: 20px;
}
.forgot-password-form {
  display: flex;
  flex-direction: column;
  gap: 15px;
}
.modal-buttons {
  display: flex;
  gap: 10px;
  margin-top: 10px;
}
.cancel-btn {
  padding: 12px;
  background: #f4f4f4;
  color: #333;
  border: none;
  border-radius: 5px;
  font-size: 16px;
  cursor: pointer;
  transition: all 0.3s ease;
  flex: 1;
}
.cancel-btn:hover {
  background: #e4e4e4;
}
.modal-buttons .submit-btn {
  flex: 1;
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
@media (max-width: 768px) {
  .login {
    margin: 20px;
  }
  .modal-content {
    margin: 20px;
  }
}
</style> 
