<template>
  <div class="login">
    <h1>Đăng nhập</h1>
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
      Chưa có tài khoản? <router-link to="/auth/register">Đăng ký</router-link>
    </p>
    <p class="doctor-link">
      Bạn có phải là bác sĩ? <router-link to="/auth/doctor/login">Đăng nhập ngay</router-link>
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
    console.log('Đang gửi request đăng nhập với:', {
      email: form.email,
      password: '***'
    });

    const response = await axiosInstance.post('/api/auth/login', {
      email: form.email,
      password: form.password,
    });

    console.log('Response từ server:', response.data);

    if (response.data && response.data.token) {
      const decodedToken = jwtDecode(response.data.token);
      console.log('Token đã được giải mã:', decodedToken);
      
      localStorage.setItem('token', response.data.token);
      localStorage.setItem('role', decodedToken.role || 'user');
      
      console.log('Đã lưu token vào localStorage');
      console.log('Token hiện tại:', localStorage.getItem('token'));
      
      // Kiểm tra role và chuyển hướng
      const payload = JSON.parse(atob(response.data.token.split('.')[1]));
      if (payload.role === 'admin') {
        // Nếu có redirect query, sử dụng nó
        const redirect = route.query.redirect || '/admin/feedbacks';
        router.push(redirect);
      } else if (payload.role === 'doctor') {
        router.push('/doctor/dashboard');
      } else {
        // Người dùng thông thường
        router.push('/user/dashboard');
      }
    } else {
      throw new Error('Không nhận được token');
    }
  } catch (error) {
    console.error('Chi tiết lỗi đăng nhập:', error);
    if (error.response) {
      // Lỗi từ server
      errorMessage.value = `Đăng nhập thất bại: ${error.response.data.message || 'Vui lòng kiểm tra lại thông tin'}`;
    } else if (error.request) {
      // Lỗi không thể kết nối đến server
      errorMessage.value = 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
    } else {
      // Lỗi khác
      errorMessage.value = 'Đã có lỗi xảy ra. Vui lòng thử lại sau.';
    }
  } finally {
    isLoading.value = false;
  }
};

const sendResetLink = async () => {
  try {
    await axiosInstance.post('/api/users/forgot-password', {
      email: resetEmail.value
    });
    alert('Link đặt lại mật khẩu đã được gửi đến email của bạn!');
    showForgotPassword.value = false;
    resetEmail.value = '';
  } catch (error) {
    console.error('Lỗi gửi link:', error);
    alert('Không thể gửi link: ' + (error.response?.data.message || error.message));
  }
};
</script>

<style scoped>
.login {
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

.register-link {
  text-align: center;
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #eee;
  font-size: 14px;
  color: #666;
}

.register-link a {
  color: gold;
  text-decoration: none;
  font-weight: bold;
  margin-left: 5px;
  transition: all 0.3s ease;
}

.register-link a:hover {
  color: #ffd700;
  text-decoration: underline;
}

.doctor-link {
  text-align: center;
  margin-top: 10px;
  font-size: 14px;
}

.doctor-link a {
  color: gold;
  text-decoration: none;
  font-weight: 500;
}

.doctor-link a:hover {
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

.submit-btn:disabled {
  background: #cccccc;
  cursor: not-allowed;
  transform: none;
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