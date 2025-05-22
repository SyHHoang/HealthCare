<template>
  <div class="doctor-profile">
    <div class="profile-container">
      <!-- Header Section -->
      <div class="profile-header">
        <div class="header-content">
          <div class="avatar-section">
            <div class="avatar-wrapper">
              <img 
                :src="doctor.avatar || 'https://ui-avatars.com/api/?name=' + doctor.fullName + '&background=4a90e2&color=fff&size=150'" 
                alt="Avatar" 
                class="avatar" 
              />
              <div class="avatar-overlay">
                <button @click="triggerAvatarUpload" class="change-avatar-btn">
                  <i class="fas fa-camera"></i>
                </button>
              </div>
            </div>
            <input
              type="file"
              ref="avatarInput"
              @change="handleAvatarChange"
              accept="image/*"
              style="display: none"
            />
          </div>
          <div class="basic-info">
            <div class="name-section">
              <h2>{{ doctor.fullName }}</h2>
              <span class="status-badge" :class="{ 
                verified: doctor.status === 'active',
                pending: doctor.status === 'pending',
                inactive: doctor.status === 'inactive',
                pendingProcessing: doctor.status === 'pending processing'
              }">
                <i :class="{
                  'fas fa-check-circle': doctor.status === 'active',
                  'fas fa-clock': doctor.status === 'pending',
                  'fas fa-times-circle': doctor.status === 'inactive',
                  'fas fa-check-audible': doctor.status === 'pending processing',
                }"></i>
                {{ 
                  doctor.status === 'active' ? 'Đã xác thực' : 
                  doctor.status === 'pending' ? 'Chưa xác thực' : 
                  doctor.status === 'inactive' ? 'Đơn xác thực bị từ chối' :
                  doctor.status === 'pending processing' ? 'Đang chờ xử lý' : ''
                }}
              </span>
              <button v-if="doctor.verifiID" @click="showVerificationModal" class="view-request-btn">
                <i class="fas fa-file-alt"></i>
                Xem đơn xác thực
              </button>
            </div>
            <p class="specialty">
              <i class="fas fa-stethoscope"></i>
              {{ doctor.specialty }}
            </p>
          </div>
        </div>
      </div>

      <!-- Modal xem đơn xác thực -->
      <div v-if="showVerificationDetails" class="modal">
        <div class="modal-content verification-modal">
          <div class="modal-header">
            <h3>Chi tiết đơn xác thực</h3>
            <button @click="closeVerificationModal" class="close-btn">
              <i class="fas fa-times"></i>
            </button>
          </div>
          <div class="modal-body">
            <div v-if="verificationRequest" class="verification-details">
              <div class="info-section">
                <div class="info-group">
                  <h4>Thông tin cơ bản</h4>
                  <div class="info-item">
                    <i class="fas fa-user"></i>
                    <span>Họ và tên: {{ verificationRequest.fullName }}</span>
                  </div>
                  <div class="info-item">
                    <i class="fas fa-envelope"></i>
                    <span>Email: {{ verificationRequest.email }}</span>
                  </div>
                  <div class="info-item">
                    <i class="fas fa-phone"></i>
                    <span>Số điện thoại: {{ verificationRequest.phone }}</span>
                  </div>
                </div>

                <div class="info-group">
                  <h4>Thông tin chuyên môn</h4>
                  <div class="info-item">
                    <i class="fas fa-stethoscope"></i>
                    <span>Chuyên khoa: {{ verificationRequest.specialty }}</span>
                  </div>
                  <div class="info-item" v-if="verificationRequest.otherSpecialties">
                    <i class="fas fa-certificate"></i>
                    <span>Chuyên khoa khác: {{ verificationRequest.otherSpecialties }}</span>
                  </div>
                  <div class="info-item">
                    <i class="fas fa-briefcase"></i>
                    <span>Kinh nghiệm: {{ verificationRequest.experience }} năm</span>
                  </div>
                  <div class="info-item">
                    <i class="fas fa-hospital"></i>
                    <span>Nơi làm việc: {{ verificationRequest.currentWorkplace }}</span>
                  </div>
                </div>

                <div class="info-group">
                  <h4>Thông tin học vấn</h4>
                  <div class="info-item">
                    <i class="fas fa-graduation-cap"></i>
                    <span>Trường: {{ verificationRequest.education }}</span>
                  </div>
                  <div class="info-item">
                    <i class="fas fa-calendar"></i>
                    <span>Năm tốt nghiệp: {{ verificationRequest.graduationYear }}</span>
                  </div>
                  <div class="info-item">
                    <i class="fas fa-id-card"></i>
                    <span>Số giấy phép: {{ verificationRequest.licenseNumber }}</span>
                  </div>
                </div>

                <div class="info-group">
                  <h4>Trạng thái đơn</h4>
                  <div class="info-item">
                    <i class="fas fa-clock"></i>
                    <span>Gửi lúc: {{ formatDate(verificationRequest.submittedAt) }}</span>
                  </div>
                  <div class="info-item" v-if="verificationRequest.reviewedAt">
                    <i class="fas fa-check-circle"></i>
                    <span>Xử lý lúc: {{ formatDate(verificationRequest.reviewedAt) }}</span>
                  </div>
                  <div class="info-item" v-if="verificationRequest.rejectionReason">
                    <i class="fas fa-times-circle"></i>
                    <span>Lý do từ chối: {{ verificationRequest.rejectionReason }}</span>
                  </div>
                </div>
              </div>
            </div>
            <div v-else class="loading">
              <i class="fas fa-spinner fa-spin"></i>
              Đang tải thông tin...
            </div>
          </div>
        </div>
      </div>

      <!-- Main Content -->
      <div class="profile-content">
        <!-- Contact Information -->
        <div class="section-card">
          <div class="section-header">
            <i class="fas fa-address-card"></i>
            <h3>Thông tin liên hệ</h3>
          </div>
          <div class="info-grid">
            <div class="info-item">
              <div class="info-icon">
                <i class="fas fa-envelope"></i>
              </div>
              <div class="info-content">
                <label>Email</label>
                <p>{{ doctor.email }}</p>
              </div>
            </div>
            <div class="info-item">
              <div class="info-icon">
                <i class="fas fa-phone"></i>
              </div>
              <div class="info-content">
                <label>Số điện thoại</label>
                <p>{{ doctor.phone }}</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Professional Information -->
        <div class="section-card">
          <div class="section-header">
            <i class="fas fa-briefcase-medical"></i>
            <h3>Thông tin chuyên môn</h3>
          </div>
          <div class="info-grid">
            <div class="info-item">
              <div class="info-icon">
                <i class="fas fa-hospital"></i>
              </div>
              <div class="info-content">
                <label>Chuyên khoa chính</label>
                <p>{{ doctor.specialty }}</p>
              </div>
            </div>
            <div class="info-item">
              <div class="info-icon">
                <i class="fas fa-certificate"></i>
              </div>
              <div class="info-content">
                <label>Các chuyên khoa khác</label>
                <p>{{ doctor.otherSpecialties || 'Không có' }}</p>
              </div>
            </div>
            <div class="info-item">
              <div class="info-icon">
                <i class="fas fa-clock"></i>
              </div>
              <div class="info-content">
                <label>Kinh nghiệm</label>
                <p>{{ doctor.experience }} năm</p>
              </div>
            </div>
            <div class="info-item">
              <div class="info-icon">
                <i class="fas fa-building"></i>
              </div>
              <div class="info-content">
                <label>Nơi làm việc</label>
                <p>{{ doctor.currentWorkplace || 'Chưa cập nhật' }}</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Education Information -->
        <div class="section-card">
          <div class="section-header">
            <i class="fas fa-graduation-cap"></i>
            <h3>Thông tin học vấn</h3>
          </div>
          <div class="info-grid">
            <div class="info-item">
              <div class="info-icon">
                <i class="fas fa-university"></i>
              </div>
              <div class="info-content">
                <label>Trường đại học</label>
                <p>{{ doctor.education || 'Chưa cập nhật' }}</p>
              </div>
            </div>
            <div class="info-item">
              <div class="info-icon">
                <i class="fas fa-calendar-alt"></i>
              </div>
              <div class="info-content">
                <label>Năm tốt nghiệp</label>
                <p>{{ doctor.graduationYear || 'Chưa cập nhật' }}</p>
              </div>
            </div>
            <div class="info-item">
              <div class="info-icon">
                <i class="fas fa-id-card"></i>
              </div>
              <div class="info-content">
                <label>Số giấy phép hành nghề</label>
                <p>{{ doctor.licenseNumber || 'Chưa cập nhật' }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Action Buttons -->
      <div class="profile-actions">
        <button @click="editProfile" class="action-btn edit-btn">
          <i class="fas fa-edit"></i>
          Chỉnh sửa thông tin
        </button>
        <router-link to="/doctor/change-password" class="action-btn change-password-btn">
          <i class="fas fa-key"></i>
          Đổi mật khẩu
        </router-link>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import axiosInstance from '@/services/axiosInstance';
import { doctorService } from '@/services/doctorService';

const router = useRouter();
const loading = ref(true);
const avatarInput = ref(null);
const imgbbApiKey = '5363b9940d5d3b36966e0d7454b73dc0';
const doctor = ref({
  fullName: '',
  specialty: '',
  email: '',
  phone: '',
  avatar: '',
  status: '',
  address: '',
  education: '',
  graduationYear: '',
  licenseNumber: '',
  experience: '',
  currentWorkplace: '',
  otherSpecialties: ''
});

const showVerificationDetails = ref(false);
const verificationRequest = ref(null);

// Lấy thông tin bác sĩ
const fetchDoctorProfile = async () => {
  try {
    const doctorResponse = await doctorService.getDoctorProfile();
    doctor.value = doctorResponse.data;
    console.log('Thông tin bác sĩ:', doctor.value);
  } catch (error) {
    console.error('Lỗi khi tải thông tin:', error);
    alert('Không thể tải thông tin cá nhân. Vui lòng thử lại sau.');
  } finally {
    loading.value = false;
  }
};

// Xử lý upload ảnh
const triggerAvatarUpload = () => {
  avatarInput.value.click();
};

const handleAvatarChange = async (event) => {
  const file = event.target.files[0];
  if (!file) return;

  // Kiểm tra kích thước file
  if (file.size > 2 * 1024 * 1024) { // 2MB limit
    alert('Kích thước ảnh không được vượt quá 2MB');
    return;
  }

  // Kiểm tra định dạng file
  if (!file.type.match('image.*')) {
    alert('Vui lòng chỉ chọn file ảnh');
    return;
  }

  try {
    // Lấy imageId và delete_token của ảnh cũ
    const responseImageId = await axiosInstance.get('/api/doctors/imageId');
    const oldImageId = responseImageId.data.imageId;
    const oldDeleteToken = responseImageId.data.delete_token;

    // Nếu có ảnh cũ, xóa nó
    if (oldImageId && oldDeleteToken) {
      await axiosInstance.get(`https://api.imgbb.com/1/delete/${oldImageId}/${oldDeleteToken}?key=${imgbbApiKey}`);
    }

    // Upload ảnh mới lên ImageBB
    const uploadFormData = new FormData();
    uploadFormData.append('image', file);
    
    const response = await axiosInstance.post(
      `https://api.imgbb.com/1/upload?key=${imgbbApiKey}`,
      uploadFormData
    );

    const imageUrl = response.data.data.url;
    const imageId = response.data.data.id;
    const deleteUrl = response.data.data.delete_url;
    const deleteToken = deleteUrl.split('/').pop();

    // Cập nhật thông tin ảnh cho bác sĩ
    await axiosInstance.put('/api/doctors/profile', {
      avatar: imageUrl,
      imageId: imageId,
      delete_token: deleteToken
    });

    // Cập nhật UI
    doctor.value.avatar = imageUrl;
    alert('Cập nhật ảnh đại diện thành công!');
  } catch (error) {
    console.error('Lỗi khi cập nhật ảnh:', error);
    alert('Không thể cập nhật ảnh đại diện. Vui lòng thử lại sau.');
  }
};

// Chỉnh sửa thông tin
const editProfile = () => {
  router.push('/doctor/profile/edit');
};

// Hiển thị modal xác thực
const showVerificationModal = async () => {
  try {
    showVerificationDetails.value = true;
    const response = await doctorService.getVerificationRequest();
    console.log('Verification response:', response);
    if (response.success) {
      verificationRequest.value = response.data;
      console.log('Verification request data:', verificationRequest.value);
    } else {
      throw new Error(response.message || 'Không thể lấy thông tin đơn xác thực');
    }
  } catch (error) {
    console.error('Lỗi khi lấy thông tin đơn xác thực:', error);
    alert('Không thể lấy thông tin đơn xác thực. Vui lòng thử lại sau.');
    closeVerificationModal();
  }
};

// Đóng modal xác thực
const closeVerificationModal = () => {
  showVerificationDetails.value = false;
  verificationRequest.value = null;
};

// Format date
const formatDate = (dateString) => {
  if (!dateString) return '';
  const date = new Date(dateString);
  return new Intl.DateTimeFormat('vi-VN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  }).format(date);
};

onMounted(() => {
  fetchDoctorProfile();
});
</script>

<style scoped>
.doctor-profile {
  min-height: 100vh;
  background: #f8f9fa;
  padding: 40px 20px;
}

.profile-container {
  max-width: 1200px;
  margin: 0 auto;
  background: white;
  border-radius: 20px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.profile-header {
  background: linear-gradient(135deg, #4a90e2 0%, #357abd 100%);
  padding: 40px 20px;
  color: white;
}

.header-content {
  max-width: 1000px;
  margin: 0 auto;
  display: flex;
  align-items: center;
  gap: 40px;
}

.avatar-section {
  position: relative;
}

.avatar-wrapper {
  position: relative;
  width: 180px;
  height: 180px;
  border-radius: 50%;
  overflow: hidden;
  border: 4px solid white;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.avatar {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.avatar-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.avatar-wrapper:hover .avatar-overlay {
  opacity: 1;
}

.change-avatar-btn {
  background: white;
  border: none;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  color: #4a90e2;
  cursor: pointer;
  transition: transform 0.3s ease;
}

.change-avatar-btn:hover {
  transform: scale(1.1);
}

.basic-info {
  flex: 1;
}

.name-section {
  display: flex;
  align-items: center;
  gap: 20px;
  margin-bottom: 10px;
  flex-wrap: wrap;
}

.basic-info h2 {
  margin: 0;
  font-size: 2.5rem;
  font-weight: 600;
}

.status-badge {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 0.9rem;
  
}

.status-badge.verified {
  color: #ffffff;
}

.status-badge.pending {
  
  color: #ffc107;
}

.status-badge.inactive {
  background: rgba(0, 123, 255, 0.2);
  color: #dc3545;
}
.status-badge.pendingProcessing {
  background: rgba(0, 123, 255, 0.2);
  color: #ffc107;
}

.specialty {
  font-size: 1.2rem;
  opacity: 0.9;
  display: flex;
  align-items: center;
  gap: 10px;
}

.profile-content {
  padding: 40px;
}

.section-card {
  background: white;
  border-radius: 15px;
  padding: 30px;
  margin-bottom: 30px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  border: 1px solid #eee;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 25px;
  padding-bottom: 15px;
  border-bottom: 2px solid #f0f0f0;
}

.section-header i {
  font-size: 1.5rem;
  color: #4a90e2;
}

.section-header h3 {
  margin: 0;
  font-size: 1.3rem;
  color: #333;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 25px;
}

.info-item {
  display: flex;
  align-items: flex-start;
  gap: 15px;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 10px;
  transition: transform 0.3s ease;
}

.info-item:hover {
  transform: translateY(-2px);
}

.info-icon {
  width: 40px;
  height: 40px;
  background: #4a90e2;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.info-content label {
  display: block;
  color: #666;
  font-size: 0.9rem;
  margin-bottom: 5px;
}

.info-content p {
  margin: 0;
  color: #333;
  font-size: 1rem;
}

.profile-actions {
  display: flex;
  gap: 20px;
  justify-content: center;
  padding: 30px;
  background: #f8f9fa;
  border-top: 1px solid #eee;
}

.action-btn {
  padding: 12px 25px;
  border: none;
  border-radius: 10px;
  cursor: pointer;
  font-size: 1rem;
  display: flex;
  align-items: center;
  gap: 10px;
  transition: all 0.3s ease;
  text-decoration: none;
}

.edit-btn {
  background: #4a90e2;
  color: white;
}

.edit-btn:hover {
  background: #357abd;
  transform: translateY(-2px);
}

.change-password-btn {
  background: #6c757d;
  color: white;
}

.change-password-btn:hover {
  background: #5a6268;
  transform: translateY(-2px);
}

.verification-section {
  margin: 20px 0;
  padding: 20px;
  background-color: #f8f9fa;
  border-radius: 8px;
  text-align: center;
}

.verification-section .alert {
  margin-bottom: 15px;
}

.verification-section .btn {
  padding: 10px 20px;
  font-size: 1.1rem;
}

.verification-section .btn i {
  margin-right: 8px;
}

.view-request-btn {
  padding: 6px 12px;
  border: none;
  border-radius: 20px;
  background: #4a90e2;
  color: white;
  font-size: 0.9rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 5px;
  transition: all 0.3s ease;
}

.view-request-btn:hover {
  background: #357abd;
  transform: translateY(-2px);
}

.view-request-btn i {
  font-size: 0.9rem;
}

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

.verification-modal {
  width: 80%;
  max-width: 800px;
  max-height: 80vh;
  overflow-y: auto;
  background: white;
  border-radius: 10px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.modal-header {
  padding: 15px 20px;
  border-bottom: 1px solid #dee2e6;
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: sticky;
  top: 0;
  background: white;
  z-index: 1;
}

.modal-header h3 {
  margin: 0;
  font-size: 1.2rem;
  color: #333;
}

.close-btn {
  background: none;
  border: none;
  color: #666;
  cursor: pointer;
  font-size: 1.2rem;
  padding: 5px;
}

.close-btn:hover {
  color: #333;
}

.modal-body {
  padding: 20px;
}

.verification-details {
  display: grid;
  gap: 20px;
}

.info-group {
  background: #f8f9fa;
  padding: 15px;
  border-radius: 8px;
  border: 1px solid #e0e0e0;
}

.info-group h4 {
  margin: 0 0 10px;
  color: #333;
  font-size: 1rem;
  padding-bottom: 5px;
  border-bottom: 1px solid #dee2e6;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 8px;
  color: #555;
}

.info-item i {
  color: #4a90e2;
  width: 20px;
}

.loading {
  text-align: center;
  padding: 20px;
  color: #666;
}

.loading i {
  margin-right: 10px;
  color: #4a90e2;
}

@media (max-width: 768px) {
  .doctor-profile {
    padding: 20px 10px;
  }

  .header-content {
    flex-direction: column;
    text-align: center;
    gap: 20px;
  }

  .name-section {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }

  .basic-info h2 {
    font-size: 2rem;
  }

  .profile-content {
    padding: 20px;
  }

  .section-card {
    padding: 20px;
  }

  .info-grid {
    grid-template-columns: 1fr;
  }

  .profile-actions {
    flex-direction: column;
    padding: 20px;
  }

  .view-request-btn {
    width: 100%;
    justify-content: center;
  }

  .verification-modal {
    width: 95%;
    margin: 10px;
  }
  
  .modal-header {
    padding: 10px 15px;
  }
  
  .modal-body {
    padding: 15px;
  }
  
  .info-group {
    padding: 10px;
  }
}
</style>
