<template>
  <div class="test-doctor-auth">
    <h2>Test & Fix Doctor Authentication</h2>
    
    <div class="test-section">
      <h3>1. Test Đăng nhập bác sĩ</h3>
      <form @submit.prevent="testLogin" class="test-form">
        <div class="form-group">
          <label>Email:</label>
          <input v-model="loginForm.email" type="email" placeholder="bs1@gmail.com" required />
        </div>
        <div class="form-group">
          <label>Password:</label>
          <input v-model="loginForm.password" type="password" placeholder="111111" required />
        </div>
        <button type="submit" :disabled="isLoading">
          {{ isLoading ? 'Đang test...' : 'Test Login' }}
        </button>
      </form>
      
      <div v-if="loginResult" class="result" :class="loginResult.success ? 'success' : 'error'">
        <h4>Kết quả đăng nhập:</h4>
        <pre>{{ JSON.stringify(loginResult, null, 2) }}</pre>
      </div>
    </div>

    <div class="test-section">
      <h3>2. Tạo bác sĩ test mới</h3>
      <button @click="createTestDoctor" :disabled="isLoading" class="test-button">
        {{ isLoading ? 'Đang tạo...' : 'Tạo bác sĩ test' }}
      </button>
      <p class="note">Tạo bác sĩ test với email: test-doctor@gmail.com, password: 123456</p>

      <div v-if="createResult" class="result" :class="createResult.success ? 'success' : 'error'">
        <h4>Kết quả tạo bác sĩ:</h4>
        <pre>{{ JSON.stringify(createResult, null, 2) }}</pre>
      </div>
    </div>

    <div class="test-section">
      <h3>3. Reset mật khẩu bác sĩ (Fix double hash)</h3>
      <form @submit.prevent="resetPassword" class="test-form">
        <div class="form-group">
          <label>Email:</label>
          <input v-model="resetForm.email" type="email" placeholder="bs1@gmail.com" required />
        </div>
        <div class="form-group">
          <label>New Password:</label>
          <input v-model="resetForm.newPassword" type="password" placeholder="111111" required />
        </div>
        <button type="submit" :disabled="isLoading">
          {{ isLoading ? 'Đang reset...' : 'Reset Password' }}
        </button>
      </form>

      <div v-if="resetResult" class="result" :class="resetResult.success ? 'success' : 'error'">
        <h4>Kết quả reset:</h4>
        <pre>{{ JSON.stringify(resetResult, null, 2) }}</pre>
      </div>
    </div>

    <div class="instructions">
      <h3>Hướng dẫn debug:</h3>
      <ol>
        <li><strong>Tạo bác sĩ test:</strong> Click "Tạo bác sĩ test" để tạo bác sĩ mới với thông tin clean</li>
        <li><strong>Test đăng nhập:</strong> Thử đăng nhập với thông tin từ kết quả tạo bác sĩ</li>
        <li><strong>Nếu lỗi double hash:</strong> Sử dụng "Reset Password" để fix bác sĩ cũ</li>
        <li><strong>Kiểm tra console:</strong> Mở Developer Tools để xem log chi tiết</li>
        <li><strong>Kiểm tra server:</strong> Đảm bảo server backend đang chạy</li>
      </ol>
      <div class="debug-info">
        <h4>Thông tin debug:</h4>
        <p>• Server backend: http://localhost:5000</p>
        <p>• Endpoint đăng nhập: POST /api/doctors/login</p>
        <p>• Mật khẩu được gửi dưới dạng plain text (chưa hash)</p>
        <p>• Hash được thực hiện ở backend trong pre-save middleware</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue';
import axiosInstance from '@/services/axiosInstance.js';

const isLoading = ref(false);
const loginResult = ref(null);
const resetResult = ref(null);
const createResult = ref(null);

const loginForm = reactive({
  email: 'bs1@gmail.com',
  password: '111111'
});

const resetForm = reactive({
  email: 'bs1@gmail.com',
  newPassword: '111111'
});

const testLogin = async () => {
  isLoading.value = true;
  loginResult.value = null;
  
  try {
    const response = await axiosInstance.post('/api/doctors/login', {
      email: loginForm.email,
      password: loginForm.password
    });
    
    loginResult.value = {
      success: true,
      message: 'Đăng nhập thành công!',
      data: response.data
    };
  } catch (error) {
    loginResult.value = {
      success: false,
      message: 'Đăng nhập thất bại',
      error: error.response?.data || error.message
    };
  } finally {
    isLoading.value = false;
  }
};

const createTestDoctor = async () => {
  isLoading.value = true;
  createResult.value = null;

  try {
    const response = await axiosInstance.post('/api/doctors/test-create');

    createResult.value = {
      success: true,
      message: 'Tạo bác sĩ test thành công!',
      data: response.data
    };
  } catch (error) {
    createResult.value = {
      success: false,
      message: 'Tạo bác sĩ test thất bại',
      error: error.response?.data || error.message
    };
  } finally {
    isLoading.value = false;
  }
};

const resetPassword = async () => {
  isLoading.value = true;
  resetResult.value = null;

  try {
    const response = await axiosInstance.post('/api/doctors/reset-password', {
      email: resetForm.email,
      newPassword: resetForm.newPassword
    });

    resetResult.value = {
      success: true,
      message: 'Reset mật khẩu thành công!',
      data: response.data
    };
  } catch (error) {
    resetResult.value = {
      success: false,
      message: 'Reset mật khẩu thất bại',
      error: error.response?.data || error.message
    };
  } finally {
    isLoading.value = false;
  }
};
</script>

<style scoped>
.test-doctor-auth {
  max-width: 800px;
  margin: 20px auto;
  padding: 20px;
  background: #f9f9f9;
  border-radius: 8px;
}

.test-section {
  margin-bottom: 30px;
  padding: 20px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.test-form {
  display: flex;
  flex-direction: column;
  gap: 15px;
  margin-bottom: 20px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.form-group label {
  font-weight: bold;
  color: #333;
}

.form-group input {
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 16px;
}

button {
  padding: 12px 20px;
  background: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 16px;
  cursor: pointer;
  transition: background 0.3s;
}

button:hover:not(:disabled) {
  background: #0056b3;
}

button:disabled {
  background: #ccc;
  cursor: not-allowed;
}

.test-button {
  padding: 12px 20px;
  background: #28a745;
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 16px;
  cursor: pointer;
  transition: background 0.3s;
  margin-bottom: 10px;
}

.test-button:hover:not(:disabled) {
  background: #218838;
}

.note {
  font-size: 14px;
  color: #666;
  font-style: italic;
  margin-bottom: 15px;
}

.result {
  padding: 15px;
  border-radius: 4px;
  margin-top: 15px;
}

.result.success {
  background: #d4edda;
  border: 1px solid #c3e6cb;
  color: #155724;
}

.result.error {
  background: #f8d7da;
  border: 1px solid #f5c6cb;
  color: #721c24;
}

.result pre {
  background: rgba(0,0,0,0.1);
  padding: 10px;
  border-radius: 4px;
  overflow-x: auto;
  font-size: 12px;
}

.instructions {
  padding: 20px;
  background: #e9ecef;
  border-radius: 8px;
  border-left: 4px solid #007bff;
}

.instructions h3 {
  margin-top: 0;
  color: #007bff;
}

.instructions ol {
  margin: 10px 0;
  padding-left: 20px;
}

.instructions li {
  margin-bottom: 8px;
  line-height: 1.5;
}

.debug-info {
  margin-top: 20px;
  padding: 15px;
  background: rgba(0,123,255,0.1);
  border-radius: 4px;
  border-left: 3px solid #007bff;
}

.debug-info h4 {
  margin-top: 0;
  margin-bottom: 10px;
  color: #007bff;
}

.debug-info p {
  margin: 5px 0;
  font-family: monospace;
  font-size: 13px;
}
</style>
