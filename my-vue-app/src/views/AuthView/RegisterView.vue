<template>
  <div class="register">
    <h1>Đăng ký</h1>
    <form @submit.prevent="register" class="register-form">
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
      <div class="form-group">
        <label for="confirmPassword">Xác nhận mật khẩu</label>
        <input
          type="password"
          id="confirmPassword"
          v-model="form.confirmPassword"
          placeholder="Xác nhận mật khẩu"
          required
        />
      </div>
      <div class="form-group checkbox">
        <input
          type="checkbox"
          id="terms"
          v-model="form.terms"
          required
        />
        <label for="terms">
          Tôi đồng ý với <router-link to="/policy">Điều khoản và Chính sách bảo mật</router-link>
        </label>
      </div>
      <div v-if="errorMessage" class="error-message">
        {{ errorMessage }}
      </div>
      <button type="submit" class="submit-btn" :disabled="isSubmitting">
        {{ isSubmitting ? 'Đang đăng ký...' : 'Đăng ký' }}
      </button>
    </form>
    <p class="login-link">
      Đã có tài khoản? <router-link to="/auth/login">Đăng nhập</router-link>
    </p>
  </div>
</template>

<script setup>
import { ref, reactive, inject } from 'vue';
import { useRouter } from 'vue-router';
import axiosInstance from '@/services/axiosInstance.js';

const router = useRouter();
const errorMessage = ref('');
const isSubmitting = ref(false);

const form = reactive({
  email: '',
  password: '',
  confirmPassword: '',
  terms: false
});

const register = async () => {
  if (form.password !== form.confirmPassword) {
    errorMessage.value = 'Mật khẩu không khớp!';
    return;
  }
  
  isSubmitting.value = true;
  errorMessage.value = '';
  
  try {
    const userData = {
      email: form.email,
      password: form.password,
      role: 'user' // Mặc định role là user
    };

    const response = await axiosInstance.post('/api/auth/register', userData);
    
    // Lưu token
    localStorage.setItem('token', response.data.token);
    
    // Giải mã token để lấy role nếu có
    if (response.data.token) {
      try {
        const payload = JSON.parse(atob(response.data.token.split('.')[1]));
        localStorage.setItem('role', payload.role || 'user');
      } catch (e) {
        console.error('Lỗi khi giải mã token:', e);
      }
    }
    
    // Thông báo thành công
    const toast = inject('$toast', null);
    if (toast) {
      toast.add({
        severity: 'success',
        summary: 'Đăng ký thành công',
        detail: 'Đăng ký thành công! Vui lòng cập nhật thông tin cá nhân của bạn.',
        life: 3000
      });
    } else {
      alert('Đăng ký thành công! Vui lòng cập nhật thông tin cá nhân của bạn.');
    }
    
    // Chuyển hướng đến trang profile
    router.push('/profile?new_user=true');
  } catch (error) {
    console.error('Lỗi đăng ký:', error);
    
    if (error.response) {
      // Lỗi từ server
      errorMessage.value = error.response.data.message || 'Đăng ký thất bại, vui lòng thử lại!';
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
</script>

<style scoped>
.register {
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

.register-form {
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

.login-link {
  text-align: center;
  margin-top: 15px;
  font-size: 14px;
}

.login-link a {
  color: gold;
  text-decoration: none;
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
</style>