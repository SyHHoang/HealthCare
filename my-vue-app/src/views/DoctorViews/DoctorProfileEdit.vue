<template>
  <div class="doctor-profile-edit">
    <div class="profile-container">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h2>Chỉnh sửa thông tin cá nhân</h2>
        <div>
          <button class="btn btn-primary me-2" @click="handleVerification">
            <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
            Xác thực tài khoản
          </button>
          <button class="btn btn-secondary" @click="$router.push('/doctor/profile')">
            <i class="fas fa-arrow-left"></i> Quay lại
          </button>
        </div>
      </div>

      <form @submit.prevent="handleSubmit" class="card">
        <div class="card-body">
          <!-- Basic Information -->
          <div class="row mb-4">
            <div class="col-md-6">
              <h5 class="card-title">Thông tin cơ bản</h5>
              <div class="mb-3">
                <label class="form-label">Họ và tên <span class="text-danger">*</span></label>
                <input type="text" class="form-control" v-model="formData.fullName" required />
              </div>
              <div class="mb-3">
                <label class="form-label">Email <span class="text-danger">*</span></label>
                <input type="email" class="form-control" v-model="formData.email" required />
              </div>
              <div class="mb-3">
                <label class="form-label">Số điện thoại <span class="text-danger">*</span></label>
                <input type="tel" class="form-control" v-model="formData.phone" required />
              </div>
            </div>
            <div class="col-md-6">
              <h5 class="card-title">Ảnh đại diện</h5>
              <div class="avatar-upload">
                <img :src="formData.avatar || '/default-avatar.png'" alt="Avatar" class="avatar-preview" />
                <input type="file" ref="avatarInput" @change="handleAvatarChange" accept="image/*" style="display: none" />
                <button type="button" class="btn btn-outline-primary mt-2" @click="triggerAvatarUpload">
                  <i class="fas fa-camera"></i> Thay đổi ảnh
                </button>
              </div>
            </div>
          </div>

          <!-- Professional Information -->
          <div class="mb-4">
            <h5 class="card-title">Thông tin chuyên môn</h5>
            <div class="row">
              <div class="col-md-6">
                <div class="mb-3">
                  <label class="form-label">Chuyên khoa chính <span class="text-danger">*</span></label>
                  <input type="text" class="form-control" v-model="formData.specialty" required />
                </div>
              </div>
              <div class="col-md-6">
                <div class="mb-3">
                  <label class="form-label">Các chuyên khoa khác</label>
                  <input type="text" class="form-control" v-model="formData.otherSpecialties" />
                </div>
              </div>
            </div>
            <div class="row">
              <div class="col-md-6">
                <div class="mb-3">
                  <label class="form-label">Kinh nghiệm (năm) <span class="text-danger">*</span></label>
                  <input type="number" class="form-control" v-model="formData.experience" required />
                </div>
              </div>
              <div class="col-md-6">
                <div class="mb-3">
                  <label class="form-label">Nơi làm việc hiện tại</label>
                  <input type="text" class="form-control" v-model="formData.currentWorkplace" />
                </div>
              </div>
            </div>
          </div>

          <!-- Education Information -->
          <div class="mb-4">
            <h5 class="card-title">Thông tin học vấn</h5>
            <div class="row">
              <div class="col-md-6">
                <div class="mb-3">
                  <label class="form-label">Trường đại học</label>
                  <input type="text" class="form-control" v-model="formData.education" />
                </div>
              </div>
              <div class="col-md-6">
                <div class="mb-3">
                  <label class="form-label">Năm tốt nghiệp</label>
                  <input type="number" class="form-control" v-model="formData.graduationYear" />
                </div>
              </div>
            </div>
            <div class="mb-3">
              <label class="form-label">Số giấy phép hành nghề</label>
              <input type="text" class="form-control" v-model="formData.licenseNumber" />
            </div>
          </div>

          <!-- Tài liệu xác thực -->
          <div class="mb-4">
            <h5 class="card-title">Tài liệu xác thực</h5>
            <div class="row">
              <div class="col-md-4">
                <div class="mb-3">
                  <label class="form-label">Giấy phép hành nghề <span class="text-danger">*</span></label>
                  <input 
                    type="file" 
                    class="form-control" 
                    @change="handleLicenseUpload" 
                    accept="image/*"
                    required
                  />
                  <div v-if="formData.licenseImageUrl" class="preview-image mt-2">
                    <img :src="formData.licenseImageUrl" alt="Giấy phép hành nghề" class="img-fluid" />
                  </div>
                </div>
              </div>
              <div class="col-md-4">
                <div class="mb-3">
                  <label class="form-label">CMND/CCCD mặt trước <span class="text-danger">*</span></label>
                  <input 
                    type="file" 
                    class="form-control" 
                    @change="handleIdCardFrontUpload" 
                    accept="image/*"
                    required
                  />
                  <div v-if="formData.idCardFrontUrl" class="preview-image mt-2">
                    <img :src="formData.idCardFrontUrl" alt="CMND/CCCD mặt trước" class="img-fluid" />
                  </div>
                </div>
              </div>
              <div class="col-md-4">
                <div class="mb-3">
                  <label class="form-label">CMND/CCCD mặt sau <span class="text-danger">*</span></label>
                  <input 
                    type="file" 
                    class="form-control" 
                    @change="handleIdCardBackUpload" 
                    accept="image/*"
                    required
                  />
                  <div v-if="formData.idCardBackUrl" class="preview-image mt-2">
                    <img :src="formData.idCardBackUrl" alt="CMND/CCCD mặt sau" class="img-fluid" />
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </form>

      <!-- Thông báo trạng thái xác thực -->
      <div v-if="verificationStatus" class="alert mt-3" :class="getVerificationAlertClass">
        <i class="fas" :class="getVerificationIcon"></i>
        {{ getVerificationMessage }}
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import { useToast } from 'primevue/usetoast';
import axiosInstance from '@/services/axiosInstance';
import { doctorService } from '@/services/doctorService';
import axios from 'axios';

const router = useRouter();
const toast = useToast();
const loading = ref(false);
const avatarInput = ref(null);
const imgbbApiKey = '5363b9940d5d3b36966e0d7454b73dc0'; // Thay YOUR_IMGBB_API_KEY bằng key thực tế
const verificationStatus = ref(null);

const formData = ref({
  fullName: '',
  email: '',
  phone: '',
  avatar: '',
  specialty: '',
  otherSpecialties: '',
  experience: '',
  currentWorkplace: '',
  education: '',
  graduationYear: '',
  licenseNumber: '',
  status: '',
  licenseImageUrl: '',
  idCardFrontUrl: '',
  idCardBackUrl: ''
});

// Lấy thông tin bác sĩ
const fetchDoctorProfile = async () => {
  try {
    const response = await doctorService.getProfileForEdit();
    if (response.success) {
      formData.value = { ...response.data };
    } else {
      throw new Error(response.message || 'Không thể tải thông tin cá nhân');
    }
  } catch (error) {
    console.error('Lỗi khi tải thông tin:', error);
    alert('Không thể tải thông tin cá nhân. Vui lòng thử lại sau.');
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
  if (file.size > 8 * 1024 * 1024) { // 2MB limit
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Kích thước ảnh không được vượt quá 8MB',
      life: 3000
    });
    return;
  }

  // Kiểm tra định dạng file
  if (!file.type.match('image.*')) {
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Vui lòng chỉ chọn file ảnh',
      life: 3000
    });
    return;
  }

  try {
    loading.value = true;
    
    // Upload ảnh mới lên ImageBB
    const uploadFormData = new FormData();
    uploadFormData.append('image', file);
    
    const response = await axios.post(
      `https://api.imgbb.com/1/upload?key=${imgbbApiKey}`,
      uploadFormData
    );

    if (!response.data.success) {
      throw new Error('Upload ảnh lên ImageBB thất bại');
    }

    const imageUrl = response.data.data.url;
    const imageId = response.data.data.id;
    const deleteUrl = response.data.data.delete_url;
    const deleteToken = deleteUrl.split('/').pop();

    // Cập nhật thông tin ảnh cho bác sĩ
    const updateResponse = await axiosInstance.put('/api/doctors/profile', {
      avatar: imageUrl,
      imageId: imageId,
      delete_token: deleteToken
    });

    if (updateResponse.data.success) {
      // Cập nhật UI
      formData.value.avatar = imageUrl;
      toast.add({
        severity: 'success',
        summary: 'Thành công',
        detail: 'Cập nhật ảnh đại diện thành công!',
        life: 3000
      });
    } else {
      throw new Error(updateResponse.data.message || 'Cập nhật ảnh thất bại');
    }
  } catch (error) {
    console.error('Lỗi khi cập nhật ảnh:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: error.response?.data?.message || 'Không thể cập nhật ảnh đại diện. Vui lòng thử lại sau.',
      life: 3000
    });
  } finally {
    loading.value = false;
  }
};

// Thêm phương thức xóa ảnh đại diện
const removeAvatar = async () => {
  if (!formData.value.avatar) return;
  
  if (!confirm('Bạn có chắc chắn muốn xóa ảnh đại diện?')) return;
  
  try {
    // Lấy thông tin ảnh cũ
    const responseImageId = await axiosInstance.get('/api/doctors/imageId');
    const oldImageId = responseImageId.data.imageId;
    const oldDeleteToken = responseImageId.data.delete_token;

    // Xóa ảnh trên ImageBB
    if (oldImageId && oldDeleteToken) {
      await axios.get(`https://api.imgbb.com/1/delete/${oldImageId}/${oldDeleteToken}?key=${imgbbApiKey}`);
    }

    // Cập nhật thông tin bác sĩ
    const updateResponse = await axiosInstance.put('/api/doctors/update-avatar', {
      avatar: '',
      imageId: '',
      delete_token: ''
    });

    if (updateResponse.data.success) {
      // Cập nhật UI
      formData.value.avatar = '';
      toast.add({
        severity: 'success',
        summary: 'Thành công',
        detail: 'Đã xóa ảnh đại diện thành công!',
        life: 3000
      });
    } else {
      throw new Error(updateResponse.data.message || 'Xóa ảnh thất bại');
    }
  } catch (error) {
    console.error('Lỗi khi xóa ảnh đại diện:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: error.response?.data?.message || 'Không thể xóa ảnh đại diện. Vui lòng thử lại sau.',
      life: 3000
    });
  }
};

// Computed properties cho thông báo xác thực
const getVerificationAlertClass = computed(() => {
  if (!verificationStatus.value) return '';
  switch (verificationStatus.value.status) {
    case 'pending':
      return 'alert-warning';
    case 'approved':
      return 'alert-success';
    case 'rejected':
      return 'alert-danger';
    default:
      return '';
  }
});

const getVerificationIcon = computed(() => {
  if (!verificationStatus.value) return '';
  switch (verificationStatus.value.status) {
    case 'pending':
      return 'fa-clock';
    case 'approved':
      return 'fa-check-circle';
    case 'rejected':
      return 'fa-times-circle';
    default:
      return '';
  }
});

const getVerificationMessage = computed(() => {
  if (!verificationStatus.value) return '';
  switch (verificationStatus.value.status) {
    case 'pending':
      return 'Yêu cầu xác thực của bạn đang được xử lý';
    case 'approved':
      return 'Tài khoản của bạn đã được xác thực';
    case 'rejected':
      return `Yêu cầu xác thực bị từ chối: ${verificationStatus.value.rejectionReason || 'Không có lý do'}`;
    default:
      return '';
  }
});

// Lấy trạng thái xác thực
const fetchVerificationStatus = async () => {
  try {
    const response = await doctorService.getVerificationStatus();
    verificationStatus.value = response;
  } catch (error) {
    console.error('Lỗi khi lấy trạng thái xác thực:', error);
  }
};

// Thêm hàm kiểm tra thông tin
const validateDoctorInfo = () => {
  // Kiểm tra ảnh đại diện
  const defaultAvatarUrl = 'https://ui-avatars.com/api/?name=' + formData.value.fullName + '&background=4a90e2&color=fff&size=150';
  if (!formData.value.avatar || formData.value.avatar === defaultAvatarUrl) {
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Vui lòng cập nhật ảnh đại diện trước khi xác thực tài khoản',
      life: 3000
    });
    return false;
  }

  const requiredFields = {
    fullName: 'Họ và tên',
    specialty: 'Chuyên khoa chính',
    email: 'Email',
    phone: 'Số điện thoại',
    education: 'Trường đại học',
    graduationYear: 'Năm tốt nghiệp',
    licenseNumber: 'Số giấy phép hành nghề',
    experience: 'Kinh nghiệm',
    currentWorkplace: 'Nơi làm việc'
  };

  const missingFields = [];
  
  for (const [field, label] of Object.entries(requiredFields)) {
    const value = formData.value[field];
    if (value === null || value === undefined || 
        (typeof value === 'string' && value.trim() === '') ||
        (typeof value === 'number' && isNaN(value))) {
      missingFields.push(label);
    }
  }

  if (missingFields.length > 0) {
    const message = `Vui lòng điền đầy đủ các thông tin sau:\n${missingFields.join('\n')}`;
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: message,
      life: 3000
    });
    return false;
  }

  // Kiểm tra định dạng email
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(formData.value.email)) {
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Email không hợp lệ',
      life: 3000
    });
    return false;
  }

  // Kiểm tra định dạng số điện thoại
  const phoneRegex = /^[0-9]{10}$/;
  if (!phoneRegex.test(formData.value.phone)) {
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Số điện thoại phải có 10 chữ số',
      life: 3000
    });
    return false;
  }

  // Kiểm tra năm tốt nghiệp
  const currentYear = new Date().getFullYear();
  const graduationYear = parseInt(formData.value.graduationYear);
  if (isNaN(graduationYear) || graduationYear < 1900 || graduationYear > currentYear) {
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Năm tốt nghiệp không hợp lệ',
      life: 3000
    });
    return false;
  }

  // Kiểm tra kinh nghiệm
  const experience = parseInt(formData.value.experience);
  if (isNaN(experience) || experience < 0 || experience > 100) {
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Kinh nghiệm không hợp lệ',
      life: 3000
    });
    return false;
  }

  // Kiểm tra ảnh xác thực
  if (!formData.value.licenseImageUrl || !formData.value.idCardFrontUrl || !formData.value.idCardBackUrl) {
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Vui lòng tải lên đầy đủ các ảnh xác thực',
      life: 3000
    });
    return false;
  }

  return true;
};

// Thêm hàm xử lý xác thực
const handleVerification = async () => {
  try {
    loading.value = true;

    // Kiểm tra thông tin trước khi gửi yêu cầu
    if (!validateDoctorInfo()) {
      return;
    }

    // Chuẩn bị dữ liệu gửi đi
    const verificationData = {
      fullName: formData.value.fullName,
      email: formData.value.email,
      phone: formData.value.phone,
      avatar: formData.value.avatar,
      specialty: formData.value.specialty,
      otherSpecialties: formData.value.otherSpecialties,
      experience: formData.value.experience,
      currentWorkplace: formData.value.currentWorkplace,
      education: formData.value.education,
      graduationYear: formData.value.graduationYear,
      licenseNumber: formData.value.licenseNumber,
      licenseImageUrl: formData.value.licenseImageUrl,
      idCardFrontUrl: formData.value.idCardFrontUrl,
      idCardBackUrl: formData.value.idCardBackUrl
    };
    console.log(verificationData);
    // Gửi yêu cầu xác thực
    const response = await doctorService.requestVerification(verificationData);
    
    if (response.success) {
      toast.add({
        severity: 'success',
        summary: 'Thành công',
        detail: 'Gửi yêu cầu xác thực thành công',
        life: 3000
      });
      
      // Cập nhật trạng thái xác thực
      await fetchVerificationStatus();
      
      router.push('/doctor/profile');
    } else {
      toast.add({
        severity: 'error',
        summary: 'Lỗi',
        detail: response.message || 'Gửi yêu cầu xác thực thất bại',
        life: 3000
      });
    }
  } catch (error) {
    console.error('Lỗi khi gửi yêu cầu xác thực:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: error.response?.data?.message || 'Gửi yêu cầu xác thực thất bại',
      life: 3000
    });
  } finally {
    loading.value = false;
  }
};

// Thêm các hàm xử lý upload ảnh xác thực
const handleLicenseUpload = async (event) => {
  const file = event.target.files[0];
  if (!file) return;

  try {
    loading.value = true;
    const uploadFormData = new FormData();
    uploadFormData.append('image', file);
    
    const response = await axios.post(
      `https://api.imgbb.com/1/upload?key=${imgbbApiKey}`,
      uploadFormData
    );

    if (response.data.success) {
      formData.value.licenseImageUrl = response.data.data.url;
      toast.add({
        severity: 'success',
        summary: 'Thành công',
        detail: 'Tải lên ảnh giấy phép hành nghề thành công!',
        life: 3000
      });
    }
  } catch (error) {
    console.error('Lỗi khi tải lên ảnh:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể tải lên ảnh giấy phép hành nghề',
      life: 3000
    });
  } finally {
    loading.value = false;
  }
};

const handleIdCardFrontUpload = async (event) => {
  const file = event.target.files[0];
  if (!file) return;

  try {
    loading.value = true;
    const uploadFormData = new FormData();
    uploadFormData.append('image', file);
    
    const response = await axios.post(
      `https://api.imgbb.com/1/upload?key=${imgbbApiKey}`,
      uploadFormData
    );

    if (response.data.success) {
      formData.value.idCardFrontUrl = response.data.data.url;
      toast.add({
        severity: 'success',
        summary: 'Thành công',
        detail: 'Tải lên ảnh CMND/CCCD mặt trước thành công!',
        life: 3000
      });
    }
  } catch (error) {
    console.error('Lỗi khi tải lên ảnh:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể tải lên ảnh CMND/CCCD mặt trước',
      life: 3000
    });
  } finally {
    loading.value = false;
  }
};

const handleIdCardBackUpload = async (event) => {
  const file = event.target.files[0];
  if (!file) return;

  try {
    loading.value = true;
    const uploadFormData = new FormData();
    uploadFormData.append('image', file);
    
    const response = await axios.post(
      `https://api.imgbb.com/1/upload?key=${imgbbApiKey}`,
      uploadFormData
    );

    if (response.data.success) {
      formData.value.idCardBackUrl = response.data.data.url;
      toast.add({
        severity: 'success',
        summary: 'Thành công',
        detail: 'Tải lên ảnh CMND/CCCD mặt sau thành công!',
        life: 3000
      });
    }
  } catch (error) {
    console.error('Lỗi khi tải lên ảnh:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể tải lên ảnh CMND/CCCD mặt sau',
      life: 3000
    });
  } finally {
    loading.value = false;
  }
};

onMounted(async () => {
  await Promise.all([
    fetchDoctorProfile(),
    fetchVerificationStatus()
  ]);
});
</script>

<style scoped>
.doctor-profile-edit {
  padding: 20px;
}

.profile-container {
  max-width: 1200px;
  margin: 0 auto;
}

.card {
  box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
}

.avatar-upload {
  text-align: center;
}

.avatar-preview {
  width: 200px;
  height: 200px;
  border-radius: 50%;
  object-fit: cover;
  margin-bottom: 10px;
}

.form-label {
  font-weight: 500;
}

.alert {
  padding: 1rem;
  border-radius: 0.5rem;
  margin-bottom: 1rem;
}

.alert i {
  margin-right: 0.5rem;
}

.alert-warning {
  background-color: #fff3cd;
  border-color: #ffeeba;
  color: #856404;
}

.alert-success {
  background-color: #d4edda;
  border-color: #c3e6cb;
  color: #155724;
}

.alert-danger {
  background-color: #f8d7da;
  border-color: #f5c6cb;
  color: #721c24;
}

.preview-image {
  border: 1px solid #ddd;
  border-radius: 4px;
  padding: 5px;
  background-color: #f8f9fa;
}

.preview-image img {
  max-width: 100%;
  height: auto;
  border-radius: 4px;
}
</style> 