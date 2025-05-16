<template>
  <div class="doctor-verification">
    <h1>Xác thực thông tin Bác sĩ</h1>
    <div class="alert alert-info">
      <i class="fas fa-info-circle"></i>
      Vui lòng cung cấp đầy đủ thông tin và tài liệu để chúng tôi có thể xác thực tư cách bác sĩ của bạn.
    </div>

    <form @submit.prevent="submitVerification" class="verification-form">
      <!-- Thông tin cơ bản -->
      <div class="section">
        <h2>Thông tin cơ bản</h2>
        <div class="form-group">
          <label for="fullName">Họ và tên đầy đủ *</label>
          <input
            type="text"
            id="fullName"
            v-model="form.fullName"
            required
            class="form-control"
          />
        </div>
        <div class="form-group">
          <label for="specialty">Chuyên khoa chính *</label>
          <select 
            id="specialty" 
            v-model="form.specialty" 
            required 
            class="form-control"
          >
            <option value="">Chọn chuyên khoa</option>
            <option value="general">Đa khoa</option>
            <option value="cardiology">Tim mạch</option>
            <option value="neurology">Thần kinh</option>
            <option value="pediatrics">Nhi khoa</option>
            <option value="dermatology">Da liễu</option>
            <option value="orthopedics">Cơ xương khớp</option>
            <option value="other">Khác</option>
          </select>
        </div>
        <div class="form-group">
          <label for="otherSpecialties">Các chuyên khoa khác (nếu có)</label>
          <input
            type="text"
            id="otherSpecialties"
            v-model="form.otherSpecialties"
            class="form-control"
            placeholder="Ví dụ: Nội khoa, Tai mũi họng"
          />
        </div>
      </div>

      <!-- Thông tin học vấn -->
      <div class="section">
        <h2>Thông tin học vấn</h2>
        <div class="form-group">
          <label for="education">Trường đại học y khoa</label>
          <input
            type="text"
            id="education"
            v-model="form.education"
            required
            class="form-control"
          />
        </div>
        <div class="form-group">
          <label for="graduationYear">Năm tốt nghiệp</label>
          <input
            type="number"
            id="graduationYear"
            v-model="form.graduationYear"
            required
            min="1900"
            :max="new Date().getFullYear()"
            class="form-control"
          />
        </div>
        <div class="form-group">
          <label for="licenseNumber">Số giấy phép hành nghề</label>
          <input
            type="text"
            id="licenseNumber"
            v-model="form.licenseNumber"
            required
            class="form-control"
          />
        </div>
      </div>

      <!-- Kinh nghiệm làm việc -->
      <div class="section">
        <h2>Kinh nghiệm làm việc</h2>
        <div class="form-group">
          <label for="experience">Số năm kinh nghiệm</label>
          <input
            type="number"
            id="experience"
            v-model="form.experience"
            required
            min="0"
            class="form-control"
          />
        </div>
        <div class="form-group">
          <label for="currentWorkplace">Nơi làm việc hiện tại</label>
          <input
            type="text"
            id="currentWorkplace"
            v-model="form.currentWorkplace"
            required
            class="form-control"
          />
        </div>
      </div>

      <!-- Tài liệu đính kèm -->
      <div class="section">
        <h2>Tài liệu đính kèm</h2>
        <div class="form-group">
          <label for="licenseImage">Giấy phép hành nghề</label>
          <input
            type="file"
            id="licenseImage"
            @change="handleLicenseUpload"
            accept="image/*,.pdf"
            required
            class="form-control"
          />
          <small class="text-muted">Chấp nhận file ảnh hoặc PDF</small>
        </div>
        <div class="form-group">
          <label for="degreeImage">Bằng tốt nghiệp</label>
          <input
            type="file"
            id="degreeImage"
            @change="handleDegreeUpload"
            accept="image/*,.pdf"
            required
            class="form-control"
          />
          <small class="text-muted">Chấp nhận file ảnh hoặc PDF</small>
        </div>
        <div class="form-group">
          <label for="certificates">Chứng chỉ chuyên môn (nếu có)</label>
          <input
            type="file"
            id="certificates"
            @change="handleCertificatesUpload"
            accept="image/*,.pdf"
            multiple
            class="form-control"
          />
          <small class="text-muted">Có thể tải lên nhiều file</small>
        </div>
      </div>

      <!-- Thông tin bổ sung -->
      <div class="section">
        <h2>Thông tin bổ sung</h2>
        <div class="form-group">
          <label for="additionalInfo">Thông tin bổ sung</label>
          <textarea
            id="additionalInfo"
            v-model="form.additionalInfo"
            rows="4"
            class="form-control"
            placeholder="Bạn có thể cung cấp thêm thông tin về kinh nghiệm, thành tích hoặc các chứng chỉ khác..."
          ></textarea>
        </div>
      </div>

      <div class="form-actions">
        <button type="submit" class="submit-btn" :disabled="isSubmitting">
          <span v-if="isSubmitting" class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>
          {{ isSubmitting ? 'Đang gửi...' : 'Gửi yêu cầu xác thực' }}
        </button>
      </div>
    </form>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue';
import { useRouter } from 'vue-router';
import { useToast } from 'primevue/usetoast';
import verificationService from '../services/verificationService';

const router = useRouter();
const toast = useToast();
const isSubmitting = ref(false);

const form = reactive({
  fullName: '',
  specialty: '',
  otherSpecialties: '',
  education: '',
  graduationYear: '',
  licenseNumber: '',
  experience: '',
  currentWorkplace: '',
  licenseImage: null,
  degreeImage: null,
  certificates: [],
  additionalInfo: ''
});

const handleLicenseUpload = (event) => {
  form.licenseImage = event.target.files[0];
};

const handleDegreeUpload = (event) => {
  form.degreeImage = event.target.files[0];
};

const handleCertificatesUpload = (event) => {
  form.certificates = Array.from(event.target.files);
};

const submitVerification = async () => {
  // Kiểm tra các trường bắt buộc
  if (!form.fullName || !form.specialty || !form.education || !form.licenseNumber || !form.licenseImage) {
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Vui lòng điền đầy đủ thông tin bắt buộc',
      life: 3000
    });
    return;
  }

  isSubmitting.value = true;
  
  try {
    const formData = new FormData();
    
    // Thêm các trường thông tin vào formData
    Object.keys(form).forEach(key => {
      if (key !== 'licenseImage' && key !== 'degreeImage' && key !== 'certificates') {
        formData.append(key, form[key]);
      }
    });
    
    // Thêm các file vào formData
    if (form.licenseImage) {
      formData.append('licenseImage', form.licenseImage);
    }
    if (form.degreeImage) {
      formData.append('degreeImage', form.degreeImage);
    }
    form.certificates.forEach((cert, index) => {
      formData.append(`certificates`, cert);
    });

    // Gửi yêu cầu xác thực
    const response = await verificationService.requestVerification(formData);

    toast.add({
      severity: 'success',
      summary: 'Thành công',
      detail: 'Yêu cầu xác thực đã được gửi thành công! Chúng tôi sẽ liên hệ với bạn sớm nhất có thể.',
      life: 3000
    });
    
    // Chuyển hướng về trang dashboard
    router.push('/doctor/dashboard');
  } catch (error) {
    console.error('Lỗi gửi yêu cầu xác thực:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: error.response?.data?.message || 'Có lỗi xảy ra khi gửi yêu cầu. Vui lòng thử lại sau.',
      life: 3000
    });
  } finally {
    isSubmitting.value = false;
  }
};
</script>

<style scoped>
.doctor-verification {
  max-width: 800px;
  margin: 40px auto;
  padding: 20px;
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
}

h1 {
  text-align: center;
  color: #333;
  margin-bottom: 30px;
}

.alert {
  padding: 15px;
  margin-bottom: 20px;
  border-radius: 5px;
  background-color: #e3f2fd;
  color: #1976d2;
  border: 1px solid #bbdefb;
}

.alert i {
  margin-right: 10px;
}

.section {
  margin-bottom: 30px;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 8px;
}

.section h2 {
  color: #333;
  font-size: 1.2rem;
  margin-bottom: 20px;
  padding-bottom: 10px;
  border-bottom: 2px solid #e9ecef;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  color: #495057;
  font-weight: 500;
}

.form-control {
  width: 100%;
  padding: 10px;
  border: 1px solid #ced4da;
  border-radius: 5px;
  font-size: 1rem;
}

.form-control:focus {
  border-color: #80bdff;
  outline: 0;
  box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
}

.text-muted {
  color: #6c757d;
  font-size: 0.875rem;
  margin-top: 5px;
}

.form-actions {
  text-align: center;
  margin-top: 30px;
}

.submit-btn {
  padding: 12px 30px;
  background: #007bff;
  color: white;
  border: none;
  border-radius: 5px;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.3s ease;
}

.submit-btn:hover:not(:disabled) {
  background: #0056b3;
  transform: translateY(-1px);
}

.submit-btn:disabled {
  background: #cccccc;
  cursor: not-allowed;
  transform: none;
}

@media (max-width: 768px) {
  .doctor-verification {
    margin: 20px;
    padding: 15px;
  }
}

.is-invalid {
  border-color: #dc3545;
}

.invalid-feedback {
  color: #dc3545;
  font-size: 0.875rem;
  margin-top: 0.25rem;
}

.spinner-border {
  margin-right: 0.5rem;
}
</style> 