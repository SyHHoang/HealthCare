<template>
  <div class="profile">
    <h1>Thông tin cá nhân</h1>
    
    <div v-if="isNewUser" class="welcome-message">
      <div class="welcome-card">
        <h2>Chào mừng bạn đến với hệ thống!</h2>
        <p>Vui lòng cập nhật thông tin cá nhân để có trải nghiệm tốt nhất.</p>
      </div>
    </div>
    
    <div v-if="loading" class="loading">
      Đang tải thông tin...
    </div>

    <div v-else-if="error" class="error-message">
      {{ error }}
    </div>

    <form v-else @submit.prevent="updateProfile" class="profile-form">
      <div class="avatar-section">
        <div class="avatar-container">
          <img 
            :src="userInfo.avatar || 'https://ui-avatars.com/api/?name=User&background=FFD700&color=fff&size=150'" 
            alt="Avatar" 
            class="avatar-image" 
          />
          <div class="avatar-upload">
            <label for="avatar-upload" class="upload-label">
              <i class="fas fa-camera"></i>
              <span>Đổi ảnh</span>
            </label>
            <input
              type="file"
              id="avatar-upload"
              accept="image/*"
              @change="onAvatarChange"
              class="avatar-input"
            />
          </div>
        </div>
        <div v-if="isUploading" class="uploading-status">Đang tải ảnh lên...</div>
        <div v-if="avatarPreview" class="avatar-preview">
          <h3>Xem trước</h3>
          <img :src="avatarPreview" alt="Avatar Preview" class="preview-image" />
          <div class="preview-actions">
            <button type="button" @click="uploadAvatar" class="upload-btn" :disabled="isUploading">
              <i class="fas fa-check"></i> Lưu ảnh
            </button>
            <button type="button" @click="cancelUpload" class="cancel-btn">
              <i class="fas fa-times"></i> Hủy
            </button>
          </div>
        </div>
        
        <div v-if="userInfo.avatar && !avatarPreview" class="avatar-actions">
          <button type="button" @click="removeAvatar" class="remove-avatar-btn">
            <i class="fas fa-trash-alt"></i> Xóa ảnh đại diện
          </button>
        </div>
      </div>

      <div class="form-group">
        <label for="fullname">Họ và tên</label>
        <input
          type="text"
          id="fullname"
          v-model="userInfo.fullname"
          required
        />
      </div>

      <div class="form-group">
        <label for="email">Email</label>
        <input
          type="email"
          id="email"
          v-model="userInfo.email"
          disabled
        />
      </div>

      <div class="form-group">
        <label for="age">Tuổi</label>
        <input
          type="number"
          id="age"
          v-model="userInfo.age"
        />
      </div>

      <div class="form-group">
        <label for="gender">Giới tính</label>
        <select id="gender" v-model="userInfo.gender">
          <option value="">Chọn giới tính</option>
          <option value="male">Nam</option>
          <option value="female">Nữ</option>
          <option value="other">Khác</option>
        </select>
      </div>

      <div class="form-group">
        <label for="phone">Số điện thoại</label>
        <input
          type="tel"
          id="phone"
          v-model="userInfo.phone"
        />
      </div>

      <div class="form-actions">
        <button type="submit" class="submit-btn" :disabled="isUpdating">
          {{ isUpdating ? 'Đang cập nhật...' : 'Cập nhật thông tin' }}
        </button>
      </div>
    </form>
  </div>
</template>

<script setup>
import { ref, onMounted, inject } from 'vue';
import axiosInstance from '@/services/axiosInstance.js';
import { useRouter, useRoute } from 'vue-router';
import axios from 'axios';

const router = useRouter();
const route = useRoute();

const userInfo = ref({
  fullname: '',
  email: '',
  age: null,
  gender: '',
  phone: '',
  avatar: '',
  imageId:'',
  delete_token:''
});

const loading = ref(true);
const error = ref(null);
const isUpdating = ref(false);
const isNewUser = ref(false);
const toast = inject('$toast', null);

// Thêm biến cho xử lý avatar
const selectedAvatar = ref(null);
const avatarPreview = ref(null);
const isUploading = ref(false);
const imgbbApiKey = '5363b9940d5d3b36966e0d7454b73dc0'; // API key ImageBB

const onAvatarChange = (event) => {
  const file = event.target.files[0];
  if (!file) return;
  //giới hạn ảnhảnh
  if (file.size > 2 * 1024 * 1024) { // 2MB limit
    if (toast) {
      toast.add({
        severity: 'error',
        summary: 'Lỗi',
        detail: 'Kích thước ảnh không được vượt quá 2MB',
        life: 3000
      });
    } else {
      alert('Kích thước ảnh không được vượt quá 2MB');
    }
    return;
  }
  
  // Chỉ chấp nhận định dạng ảnh
  if (!file.type.match('image.*')) {
    if (toast) {
      toast.add({
        severity: 'error',
        summary: 'Lỗi',
        detail: 'Vui lòng chỉ chọn file ảnh',
        life: 3000
      });
    } else {
      alert('Vui lòng chỉ chọn file ảnh');
    }
    return;
  }
  
  selectedAvatar.value = file;
  avatarPreview.value = URL.createObjectURL(file);
};
const uploadAvatar = async () => {
  if (!selectedAvatar.value) return;
  //tải ảnh lên
 const responseImageId = await axiosInstance.get('/api/users/imageId');
 //console.log(responseImageId.data.imageId);
 //console.log(responseImageId.data.delete_token);
 //if(responseImageId.data.delete_token && responseImageId.data.imageId){
 //const responseDeleteIdimage=await axios.get(`https://api.imgbb.com/1/delete/${responseImageId.data.imageId}/${responseImageId.data.delete_token}?key=${imgbbApiKey}`)
 //.then(response => {
 //   console.log('Image deleted successfully:', response.data);
 // })
 //.catch(error => {
 //   console.error('Error deleting image:', error.response.data);
 // });
 //console.log(responseDeleteIdimage);
 //}
  isUploading.value = true;
  
  try {
    const formData = new FormData();
    formData.append('image', selectedAvatar.value);
    
    // Lưu URL ảnh cũ để xóa sau khi tải lên thành công
    const oldAvatarUrl = userInfo.value.avatar;
    
    // Tải ảnh lên ImageBB
    const response = await axios.post(
      `https://api.imgbb.com/1/upload?key=${imgbbApiKey}`,
      formData
    );
    console.log(response);
    // Lấy URL ảnh sau khi tải lên
    const imageUrl = response.data.data.url;
    const imageIdbbbb = response.data.data.id;
    const deleteurl = response.data.data.delete_url;
    const delete_token = deleteurl.split('/').pop();
    console.log('Ảnh mới:', imageUrl);
    console.log('id Ảnh mới:', imageIdbbbb);
    console.log('delete_token:', delete_token);
    // Cập nhật URL ảnh cho người dùng
    userInfo.value.avatar = imageUrl;
    userInfo.value.imageId = imageIdbbbb;
    // Cập nhật thông tin người dùng với avatar mới
    await axiosInstance.put('/api/users/profile', {
      avatar: imageUrl,
      imageId: imageIdbbbb,
      delete_token: delete_token
    });
    
    // Xóa ảnh cũ nếu có (ghi log)
    if (oldAvatarUrl && oldAvatarUrl.includes('ibb.co')) {
      console.log('Ảnh cũ đã được thay thế:', oldAvatarUrl);
      // Lưu ý: ImageBB không hỗ trợ API xóa ảnh qua URL, ảnh sẽ được giữ trên server
      // Nhưng không còn được tham chiếu từ database của chúng ta nữa
    }
    
    if (toast) {
      toast.add({
        severity: 'success',
        summary: 'Thành công',
        detail: 'Ảnh đại diện đã được cập nhật',
        life: 3000
      });
    } else {
      alert('Ảnh đại diện đã được cập nhật');
    }
    
    // Reset trạng thái
    selectedAvatar.value = null;
    avatarPreview.value = null;
  } catch (error) {
    console.error('Lỗi khi tải ảnh lên:', error);
    
    if (toast) {
      toast.add({
        severity: 'error',
        summary: 'Lỗi',
        detail: 'Không thể tải ảnh lên, vui lòng thử lại sau',
        life: 3000
      });
    } else {
      alert('Không thể tải ảnh lên, vui lòng thử lại sau');
    }
  } finally {
    isUploading.value = false;
  }
};

const cancelUpload = () => {
  selectedAvatar.value = null;
  avatarPreview.value = null;
};

const fetchUserInfo = async () => {
  try {
    const token = localStorage.getItem('token');
    if (!token) {
      error.value = 'Vui lòng đăng nhập để xem thông tin!';
      router.push('/auth/login');
      return;
    }

    const response = await axiosInstance.get('/api/users/profile');
    console.log(response.data);
    if (response.data) {
      userInfo.value = response.data;
      
      // Kiểm tra nếu là người dùng mới (không có họ tên hoặc đến từ trang đăng ký)
      if (!userInfo.value.fullname || route.query.new_user) {
        isNewUser.value = true;
      }
      
      loading.value = false;
    } else {
      throw new Error('Không nhận được dữ liệu từ server');
    }
  } catch (err) {
    console.error('Lỗi khi tải thông tin:', err);
    
    if (err.response) {
      if (err.response.status === 401) {
        error.value = 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại!';
        localStorage.removeItem('token');
        router.push('/auth/login');
      } else if (err.response.status === 404) {
        error.value = 'Không tìm thấy thông tin người dùng!';
      } else {
        error.value = err.response.data.message || 'Lỗi khi tải thông tin!';
      }
    } else if (err.request) {
      error.value = 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối!';
    } else {
      error.value = err.message || 'Đã xảy ra lỗi không xác định!';
    }
    loading.value = false;
  }
};

const updateProfile = async () => {
  try {
    isUpdating.value = true;
    
    const response = await axiosInstance.put('/api/users/profile', {
      fullname: userInfo.value.fullname,
      age: userInfo.value.age,
      gender: userInfo.value.gender,
      phone: userInfo.value.phone,
      avatar: userInfo.value.avatar
    });

    if (response.data && response.data.user) {
      userInfo.value = response.data.user;
      isNewUser.value = false;
      
      if (toast) {
        toast.add({
          severity: 'success',
          summary: 'Thành công',
          detail: 'Cập nhật thông tin thành công!',
          life: 3000
        });
      } else {
        alert('Cập nhật thông tin thành công!');
      }
    } else {
      throw new Error('Không nhận được phản hồi từ server');
    }
  } catch (err) {
    console.error('Lỗi khi cập nhật:', err);
    
    if (err.response) {
      if (err.response.status === 401) {
        if (toast) {
          toast.add({
            severity: 'error',
            summary: 'Lỗi',
            detail: 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại!',
            life: 5000
          });
        } else {
          alert('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại!');
        }
        
        localStorage.removeItem('token');
        router.push('/auth/login');
      } else {
        const errorMsg = err.response.data.message || 'Không thể cập nhật thông tin!';
        
        if (toast) {
          toast.add({
            severity: 'error',
            summary: 'Lỗi',
            detail: errorMsg,
            life: 5000
          });
        } else {
          alert(errorMsg);
        }
      }
    } else {
      const errorMsg = err.message || 'Đã xảy ra lỗi khi cập nhật thông tin!';
      
      if (toast) {
        toast.add({
          severity: 'error',
          summary: 'Lỗi',
          detail: errorMsg,
          life: 5000
        });
      } else {
        alert(errorMsg);
      }
    }
  } finally {
    isUpdating.value = false;
  }
};

// Thêm phương thức để xóa ảnh đại diện
const removeAvatar = async () => {
  if (!userInfo.value.avatar) return;
  
  if (!confirm('Bạn có chắc chắn muốn xóa ảnh đại diện?')) return;
  
  isUploading.value = true;
  
  try {
    // Lưu URL ảnh cũ để log
    const oldAvatarUrl = userInfo.value.avatar;
    // Đặt avatar về rỗng
    userInfo.value.avatar = '';
    // Cập nhật thông tin người dùng với avatar rỗng
    await axiosInstance.put('/api/users/profile', {
      avatar: ''
    });
    
    // Log thông tin ảnh cũ đã bị xóa
    if (oldAvatarUrl) {
      console.log('Ảnh đã bị xóa:', oldAvatarUrl);
    }
    
    if (toast) {
      toast.add({
        severity: 'success',
        summary: 'Thành công',
        detail: 'Đã xóa ảnh đại diện',
        life: 3000
      });
    } else {
      alert('Đã xóa ảnh đại diện');
    }
  } catch (error) {
    console.error('Lỗi khi xóa ảnh đại diện:', error);
    
    if (toast) {
      toast.add({
        severity: 'error',
        summary: 'Lỗi',
        detail: 'Không thể xóa ảnh đại diện, vui lòng thử lại sau',
        life: 3000
      });
    } else {
      alert('Không thể xóa ảnh đại diện, vui lòng thử lại sau');
    }
    
    // Khôi phục lại giá trị avatar nếu có lỗi
    await fetchUserInfo();
  } finally {
    isUploading.value = false;
  }
};

onMounted(fetchUserInfo);
</script>

<style scoped>
.profile {
  max-width: 600px;
  margin: 40px auto;
  padding: 20px;
  background: #f9f9f9;
  border-radius: 10px;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
}

h1 {
  text-align: center;
  color: #333;
  margin-bottom: 30px;
}

.welcome-message {
  margin-bottom: 20px;
}

.welcome-card {
  padding: 20px;
  background: #fff8e1;
  border-left: 4px solid gold;
  border-radius: 4px;
  margin-bottom: 20px;
}

.welcome-card h2 {
  color: #333;
  margin-top: 0;
  font-size: 20px;
}

.welcome-card p {
  color: #666;
  margin-bottom: 0;
}

/* Styles for avatar section */
.avatar-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 30px;
}

.avatar-container {
  position: relative;
  width: 150px;
  height: 150px;
  margin-bottom: 15px;
}

.avatar-image {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  object-fit: cover;
  border: 3px solid gold;
}

.avatar-upload {
  position: absolute;
  bottom: 0;
  right: 0;
  background: gold;
  border-radius: 50%;
  padding: 8px;
  cursor: pointer;
  box-shadow: 0 2px 5px rgba(0,0,0,0.2);
}

.upload-label {
  display: flex;
  flex-direction: column;
  align-items: center;
  font-size: 12px;
  color: #333;
  cursor: pointer;
}

.upload-label i {
  font-size: 16px;
  margin-bottom: 2px;
}

.avatar-input {
  display: none;
}

.avatar-preview {
  width: 100%;
  text-align: center;
  margin-top: 15px;
  padding: 15px;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.avatar-preview h3 {
  margin-top: 0;
  color: #333;
  font-size: 18px;
}

.preview-image {
  width: 120px;
  height: 120px;
  border-radius: 50%;
  object-fit: cover;
  margin: 10px 0;
  border: 2px solid #eee;
}

.preview-actions {
  display: flex;
  justify-content: center;
  gap: 10px;
  margin-top: 10px;
}

.upload-btn, .cancel-btn {
  padding: 8px 15px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 5px;
}

.upload-btn {
  background-color: gold;
  color: #333;
}

.upload-btn:hover {
  background-color: #ffd700;
}

.upload-btn:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}

.cancel-btn {
  background-color: #f0f0f0;
  color: #333;
}

.cancel-btn:hover {
  background-color: #e0e0e0;
}

.uploading-status {
  color: #666;
  font-style: italic;
  margin: 5px 0;
}

/* Form styles */
.profile-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.form-group label {
  font-weight: bold;
  color: #555;
}

.form-group input,
.form-group select {
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 5px;
  font-size: 16px;
}

.form-group input:disabled {
  background: #f5f5f5;
  cursor: not-allowed;
}

.form-group input:focus,
.form-group select:focus {
  border-color: gold;
  outline: none;
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
}

.loading {
  text-align: center;
  color: #666;
  padding: 20px;
}

.error-message {
  color: #ff4444;
  text-align: center;
  padding: 20px;
  background: #ffebee;
  border-radius: 5px;
  margin: 20px 0;
}

.avatar-actions {
  margin-top: 10px;
}

.remove-avatar-btn {
  background-color: #ff4444;
  color: white;
  border: none;
  border-radius: 4px;
  padding: 8px 15px;
  font-size: 14px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 5px;
  transition: background-color 0.3s;
}

.remove-avatar-btn:hover {
  background-color: #ff0000;
}

@media (max-width: 768px) {
  .profile {
    margin: 20px;
  }
  
  .avatar-container {
    width: 120px;
    height: 120px;
  }
  
  .preview-image {
    width: 100px;
    height: 100px;
  }
}
</style>