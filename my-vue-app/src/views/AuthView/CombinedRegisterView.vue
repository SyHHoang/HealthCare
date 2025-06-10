<template>
  <div class="register">
    <h1>Đăng ký</h1>
    <div class="role-select">
      <button :class="{ active: role === 'user' }" @click="role = 'user'">
        <span class="icon">👤</span> Bệnh nhân
      </button>
      <button :class="{ active: role === 'doctor' }" @click="role = 'doctor'">
        <span class="icon">📋</span> Bác sĩ
      </button>
    </div>
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
      <button type="submit" class="submit-btn" :disabled="isSubmitting || !form.terms">
        {{ isSubmitting ? 'Đang đăng ký...' : 'Đăng ký' }}
      </button>
    </form>
    <p class="login-link">
      Đã có tài khoản? <router-link to="/auth/login" class="login-link-highlight">Đăng nhập</router-link>
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
const role = ref('user'); // 'user' hoặc 'doctor'

const form = reactive({
  email: '',
  password: '',
  confirmPassword: '',
  terms: false
});

const register = async () => {
  if (form.password !== form.confirmPassword) {
    errorMessage.value = 'Mật khẩu xác nhận không khớp!';
    return;
  }
  if (!form.terms) {
    errorMessage.value = 'Bạn cần đồng ý với điều khoản và chính sách bảo mật!';
    return;
  }
  isSubmitting.value = true;
  errorMessage.value = '';
  try {
    let response;
    if (role.value === 'doctor') {
      response = await axiosInstance.post('/api/doctors/register', {
        email: form.email,
        password: form.password
      });
    } else {
      response = await axiosInstance.post('/api/auth/UserRegister', {
        email: form.email,
        password: form.password,
      });
    }
    if (response.data.token) {
      localStorage.setItem('token', response.data.token);
      try {
        const payload = JSON.parse(atob(response.data.token.split('.')[1]));
        localStorage.setItem('role', payload.role || role.value);
      } catch (e) {
        localStorage.setItem('role', role.value);
      }
    }
    // Thông báo thành công
    const toast = inject('$toast', null);
    if (toast) {
      toast.add({
        severity: 'success',
        summary: 'Đăng ký thành công',
        detail: 'Đăng ký thành công! Vui lòng đăng nhập.',
        life: 3000
      });
    } else {
      alert('Đăng ký thành công! Vui lòng đăng nhập.');
    }
    // Chuyển hướng đến trang đăng nhập
    router.push('/auth/login');
  } catch (error) {
    if (error.response) {
      errorMessage.value = error.response.data.message || 'Đăng ký thất bại!';
    } else if (error.request) {
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

.register-form {
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
  margin-top: 20px;
  font-size: 14px;
  color: #666;
}
.login-link-highlight {
  color: gold;
  text-decoration: none;
  font-weight: bold;
  margin-left: 5px;
  transition: all 0.3s ease;
}
.login-link-highlight:hover {
  color: #ffd700;
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
@media (max-width: 768px) {
  .register {
    margin: 20px;
  }
}
</style> 