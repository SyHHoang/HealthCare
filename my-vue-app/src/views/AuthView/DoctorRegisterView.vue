<template>
  <div class="doctor-register">
    <h1>Đăng ký tài khoản Bác sĩ</h1>
    <form @submit.prevent="register" class="register-form">
      <div class="form-group">
        <label for="fullName">Họ và tên</label>
        <input
          type="text"
          id="fullName"
          v-model="form.fullName"
          placeholder="Nhập họ và tên"
          required
        />
      </div>
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
        <label for="phone">Số điện thoại</label>
        <input
          type="tel"
          id="phone"
          v-model="form.phone"
          placeholder="Nhập số điện thoại"
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
          placeholder="Nhập lại mật khẩu"
          required
        />
      </div>
      <div v-if="errorMessage" class="error-message">
        {{ errorMessage }}
      </div>
      <button type="submit" class="submit-btn" :disabled="isSubmitting">
        {{ isSubmitting ? 'Đang đăng ký...' : 'Đăng ký' }}
      </button>
    </form>
    <p class="login-link">
      Đã có tài khoản? <router-link to="/auth/doctor/login">Đăng nhập ngay</router-link>
    </p>
    <p class="user-link">
      Bạn là người dùng thường? <router-link to="/auth/register">Đăng ký ngay</router-link>
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
  fullName: '',
  email: '',
  password: '',
  confirmPassword: ''
});

const register = async () => {
  if (form.password !== form.confirmPassword) {
    errorMessage.value = 'Mật khẩu xác nhận không khớp!';
    return;
  }

  isSubmitting.value = true;
  errorMessage.value = '';
  
  try {
    const response = await axiosInstance.post('/api/doctors/register', {
      fullName: form.fullName,
      email: form.email,
      phone: form.phone,
      password: form.password
    });
    
    if (response.data.token) {
      // Lưu token và thông tin bác sĩ
      localStorage.setItem('token', response.data.token);
      localStorage.setItem('role', 'doctor');
      localStorage.setItem('user', JSON.stringify(response.data.doctor));
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
    
    // Chuyển hướng đến trang đăng nhập bác sĩ
    router.push('/auth/doctor/login');
  } catch (error) {
    console.error('Lỗi đăng ký:', error);
    
    if (error.response) {
      // Lỗi từ server
      errorMessage.value = error.response.data.message || 'Đăng ký thất bại!';
      console.log("lỗi",error.response)
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
.doctor-register {
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

.form-group input,
.form-group select {
  padding: 10px;
  font-size: 16px;
  border: 1px solid #ddd;
  border-radius: 5px;
  outline: none;
}

.form-group input:focus,
.form-group select:focus {
  border-color: gold;
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

.login-link,
.user-link {
  text-align: center;
  margin-top: 10px;
  font-size: 14px;
}

.login-link a,
.user-link a {
  color: gold;
  text-decoration: none;
  font-weight: 500;
}

.login-link a:hover,
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

@media (max-width: 768px) {
  .doctor-register {
    margin: 20px;
  }
}
</style> 