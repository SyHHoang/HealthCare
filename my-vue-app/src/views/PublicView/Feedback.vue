<template>
  <div class="feedback-page">
    <div class="container py-5">
      <div class="row justify-content-center">
        <div class="col-lg-8">
          <div class="feedback-form">
            <h2 class="section-title text-center mb-4">Đánh Giá Dịch Vụ</h2>
            <p class="text-center text-muted mb-5">
              Ý kiến của bạn giúp chúng tôi cải thiện chất lượng dịch vụ tốt hơn
            </p>

            <form @submit.prevent="handleSubmit">
              <!-- Đánh giá sao -->
              <div class="mb-4 text-center">
                <label class="form-label d-block">Mức độ hài lòng</label>
                <div class="rating">
                  <i v-for="star in 5" 
                     :key="star" 
                     class="fas fa-star"
                     :class="{ 'active': star <= rating }"
                     @click="rating = star"
                  ></i>
                </div>
              </div>

              <!-- Loại dịch vụ -->
              <div class="mb-4">
                <label class="form-label">Dịch vụ đã sử dụng</label>
                <select class="form-select" v-model="formData.service" required>
                  <option value="">Chọn dịch vụ</option>
                  <option value="ai">Tư vấn AI</option>
                  <option value="online">Tư vấn trực tuyến</option>
                  <option value="appointment">Đặt lịch khám</option>
                  <option value="other">Khác</option>
                </select>
              </div>

              <!-- Tiêu đề -->
              <div class="mb-4">
                <label class="form-label">Tiêu đề</label>
                <input 
                  type="text" 
                  class="form-control" 
                  v-model="formData.title"
                  placeholder="Nhập tiêu đề đánh giá"
                  required
                >
              </div>

              <!-- Nội dung -->
              <div class="mb-4">
                <label class="form-label">Nội dung đánh giá</label>
                <textarea 
                  class="form-control" 
                  rows="5" 
                  v-model="formData.content"
                  placeholder="Chia sẻ trải nghiệm của bạn..."
                  required
                ></textarea>
              </div>

              <!-- Ưu điểm -->
              <div class="mb-4">
                <label class="form-label">Ưu điểm</label>
                <textarea 
                  class="form-control" 
                  rows="3" 
                  v-model="formData.pros"
                  placeholder="Những điểm bạn thấy hài lòng..."
                ></textarea>
              </div>

              <!-- Nhược điểm -->
              <div class="mb-4">
                <label class="form-label">Điểm cần cải thiện</label>
                <textarea 
                  class="form-control" 
                  rows="3" 
                  v-model="formData.cons"
                  placeholder="Những điểm bạn nghĩ chúng tôi cần cải thiện..."
                ></textarea>
              </div>

              <!-- Đề xuất -->
              <div class="mb-4">
                <label class="form-label">Đề xuất cải thiện</label>
                <textarea 
                  class="form-control" 
                  rows="3" 
                  v-model="formData.suggestions"
                  placeholder="Ý kiến đóng góp của bạn..."
                ></textarea>
              </div>

              <!-- Thông tin liên hệ -->
              <div class="mb-4">
                <label class="form-label">Thông tin liên hệ (không bắt buộc)</label>
                <input 
                  type="email" 
                  class="form-control mb-2" 
                  v-model="formData.email"
                  placeholder="Email của bạn"
                >
                <input 
                  type="tel" 
                  class="form-control" 
                  v-model="formData.phone"
                  placeholder="Số điện thoại"
                >
              </div>

              <!-- Đính kèm file -->
              <div class="mb-4">
                <label class="form-label">Đính kèm hình ảnh (không bắt buộc)</label>
                <input 
                  type="file" 
                  class="form-control" 
                  @change="handleFileUpload"
                  accept="image/*"
                  multiple
                >
              </div>

              <div class="text-center">
                <button type="submit" class="btn btn-primary" :disabled="isSubmitting">
                  <i class="fas fa-paper-plane me-2"></i>
                  {{ isSubmitting ? 'Đang gửi...' : 'Gửi đánh giá' }}
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, inject } from 'vue';
import axiosInstance from '@/services/axiosInstance.js';

const rating = ref(0);
const formData = reactive({
  service: '',
  title: '',
  content: '',
  pros: '',
  cons: '',
  suggestions: '',
  email: '',
  phone: '',
  images: []
});

const isSubmitting = ref(false);
const toast = inject('$toast');

const handleFileUpload = (event) => {
  const files = event.target.files;
  formData.images = Array.from(files);
};

const handleSubmit = async () => {
  if (!validateForm()) return;

  isSubmitting.value = true;
  const formDataToSend = new FormData();
  formDataToSend.append('rating', rating.value);
  formDataToSend.append('service', formData.service);
  formDataToSend.append('title', formData.title);
  formDataToSend.append('content', formData.content);
  formDataToSend.append('pros', formData.pros);
  formDataToSend.append('cons', formData.cons);
  formDataToSend.append('suggestions', formData.suggestions);
  formDataToSend.append('email', formData.email);
  formDataToSend.append('phone', formData.phone);

  formData.images.forEach((file) => {
    formDataToSend.append('images', file);
  });

  try {
    const response = await axiosInstance.post('/api/feedback', formDataToSend);
    
    resetForm();
  } catch (error) {
    console.error("Lỗi khi gửi feedback:", error);
    
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: error.response?.data?.message || 'Đã xảy ra lỗi khi gửi phản hồi. Vui lòng thử lại sau.',
      life: 5000
    });
  } finally {
    isSubmitting.value = false;
  }
};

const validateForm = () => {
  // Implement form validation logic here
  return true; // Placeholder return, actual implementation needed
};

const resetForm = () => {
  rating.value = 0;
  Object.assign(formData, {
    service: '',
    title: '',
    content: '',
    pros: '',
    cons: '',
    suggestions: '',
    email: '',
    phone: '',
    images: []
  });
};
</script>

<style scoped>
.feedback-page {
  margin-top: 80px;
  background-color: #f8f9fa;
  min-height: calc(100vh - 80px);
}

.feedback-form {
  background: white;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.section-title {
  color: #2c3e50;
  font-weight: 600;
}

.rating {
  display: flex;
  justify-content: center;
  gap: 10px;
  font-size: 2rem;
  margin: 1rem 0;
}

.rating i {
  color: #ddd;
  cursor: pointer;
  transition: color 0.3s ease;
}

.rating i:hover,
.rating i.active {
  color: #ffd700;
}

.form-control:focus,
.form-select:focus {
  border-color: #3498db;
  box-shadow: 0 0 0 0.2rem rgba(52,152,219,0.25);
}

.btn-primary {
  background-color: #3498db;
  border-color: #3498db;
  padding: 10px 30px;
}

.btn-primary:hover {
  background-color: #2980b9;
  border-color: #2980b9;
}

.btn-primary:disabled {
  background-color: #bdc3c7;
  border-color: #bdc3c7;
}

@media (max-width: 768px) {
  .feedback-form {
    padding: 1rem;
  }

  .rating {
    font-size: 1.5rem;
  }
}
</style> 