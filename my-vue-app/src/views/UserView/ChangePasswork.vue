<template>
  <div class="change-password">
    <h2>Đổi mật khẩu</h2>
    <form @submit.prevent="submitForm">
      <div>
        <label>Mật khẩu cũ:</label>
        <input 
          type="password" 
          v-model="form.oldPassword" 
          required
        >
      </div>
      <div>
        <label>Mật khẩu mới:</label>
        <input 
          type="password" 
          v-model="form.newPassword" 
          required
        >
      </div>
      <div>
        <label>Xác nhận mật khẩu mới:</label>
        <input 
          type="password" 
          v-model="form.confirmPassword" 
          required
        >
      </div>
      <button type="submit">Đổi mật khẩu</button>
    </form>
    <p v-if="message">{{ message }}</p>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import axiosInstance from '@/services/axiosInstance.js';

const form = ref({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
});

const message = ref('');

const submitForm = async () => {
  if (!validateForm()) return;

  isLoading.value = true;
  errorMessage.value = '';
  successMessage.value = '';

  try {
    const token = localStorage.getItem('token');
    console.log(token);
    if (!token) {
      error.value = 'Vui lòng đăng nhập để xem thông tin!';
      router.push('/login');
      return;
    }
    // Kiểm tra mật khẩu mới có khớp không
    if (form.value.newPassword !== form.value.confirmPassword) {
      message.value = 'Mật khẩu mới không khớp';
      form.value.confirmPassword = '';
      return;
    }

    console.log("mật khẩu đúng");
    // Gửi request đến backend
    const response = await axiosInstance.post('/api/users/change-password', {
      currentPassword: form.value.oldPassword,
      newPassword: form.value.newPassword,
      confirmPassword: form.value.confirmPassword
    }, {
      headers: {
        'Authorization': 'Bearer ' + token,
        'Content-Type': 'application/json'
      }
    });

    successMessage.value = response.data.message;
    // Reset form
    form.value.oldPassword = '';
    form.value.newPassword = '';
    form.value.confirmPassword = '';
  } catch (error) {
    console.error('Lỗi khi đổi mật khẩu:', error);
    
    if (error.response && error.response.data) {
      message.value = error.response.data.message || 'Đã có lỗi xảy ra khi đổi mật khẩu';
    } else {
      message.value = 'Không thể kết nối đến máy chủ. Vui lòng thử lại sau';
    }
  } finally {
    isLoading.value = false;
  }
};

const validateForm = () => {
  // Implement form validation logic here
  return true; // Placeholder return, actual implementation needed
};

const resetForm = () => {
  // Implement form reset logic here
};
</script>

<style scoped>
.change-password {
  max-width: 400px;
  margin: 0 auto;
  padding: 20px;
}

form div {
  margin-bottom: 15px;
}

label {
  display: block;
  margin-bottom: 5px;
}

input {
  width: 100%;
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
}

button {
  background-color: #007bff;
  color: white;
  padding: 10px 15px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

button:hover {
  background-color: #0056b3;
}
</style>