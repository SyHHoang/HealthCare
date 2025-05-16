<template>
  <div class="contact-page">
    <div class="container py-5">
      <div class="row">
        <div class="col-lg-6">
          <div class="contact-info mb-5">
            <h2 class="section-title mb-4">Thông tin liên hệ</h2>
            <div class="info-item mb-3">
              <i class="fas fa-map-marker-alt"></i>
              <div class="info-content">
                <h5>Địa chỉ</h5>
                <p>123 Đường ABC, Quận XYZ, TP. Hồ Chí Minh</p>
              </div>
            </div>
            <div class="info-item mb-3">
              <i class="fas fa-phone-alt"></i>
              <div class="info-content">
                <h5>Điện thoại</h5>
                <p>
                  <a href="tel:1900123456">1900 123 456</a><br>
                  <a href="tel:0901234567">090 123 4567</a>
                </p>
              </div>
            </div>
            <div class="info-item mb-3">
              <i class="fas fa-envelope"></i>
              <div class="info-content">
                <h5>Email</h5>
                <p>
                  <a href="mailto:info@healthcare.com">info@healthcare.com</a><br>
                  <a href="mailto:support@healthcare.com">support@healthcare.com</a>
                </p>
              </div>
            </div>
            <div class="info-item">
              <i class="fas fa-clock"></i>
              <div class="info-content">
                <h5>Giờ làm việc</h5>
                <p>
                  Thứ 2 - Thứ 6: 8:00 - 17:00<br>
                  Thứ 7: 8:00 - 12:00<br>
                  Chủ nhật: Nghỉ
                </p>
              </div>
            </div>
          </div>
        </div>
        
        <div class="col-lg-6">
          <div class="contact-form">
            <h2 class="section-title mb-4">Gửi tin nhắn cho chúng tôi</h2>
            <form @submit.prevent="handleSubmit">
              <div class="mb-3">
                <label for="name" class="form-label">Họ và tên <span class="text-danger">*</span></label>
                <input 
                  type="text" 
                  class="form-control" 
                  id="name" 
                  v-model="formData.name"
                  required
                >
              </div>
              
              <div class="mb-3">
                <label for="email" class="form-label">Email <span class="text-danger">*</span></label>
                <input 
                  type="email" 
                  class="form-control" 
                  id="email" 
                  v-model="formData.email"
                  required
                >
              </div>
              
              <div class="mb-3">
                <label for="phone" class="form-label">Số điện thoại</label>
                <input 
                  type="tel" 
                  class="form-control" 
                  id="phone" 
                  v-model="formData.phone"
                >
              </div>
              
              <div class="mb-3">
                <label for="subject" class="form-label">Chủ đề</label>
                <input 
                  type="text" 
                  class="form-control" 
                  id="subject" 
                  v-model="formData.subject"
                >
              </div>
              
              <div class="mb-3">
                <label for="message" class="form-label">Nội dung <span class="text-danger">*</span></label>
                <textarea 
                  class="form-control" 
                  id="message" 
                  rows="5" 
                  v-model="formData.message"
                  required
                ></textarea>
              </div>
              
              <button type="submit" class="btn btn-primary" :disabled="isSubmitting">
                <i class="fas fa-paper-plane me-2"></i>
                {{ isSubmitting ? 'Đang gửi...' : 'Gửi tin nhắn' }}
              </button>
            </form>
          </div>
        </div>
      </div>

      <div class="row mt-5">
        <div class="col-12">
          <div class="map-container">
            <h2 class="section-title mb-4">Bản đồ</h2>
            <div class="map-frame">
              <iframe 
                src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3919.2887114467376!2d106.69976911471821!3d10.789470992314533!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x317528cb4ba30aa5%3A0x3a0ddc230888b922!2sLandmark%2081!5e0!3m2!1svi!2s!4v1647850823816!5m2!1svi!2s" 
                width="100%" 
                height="450" 
                style="border:0;" 
                allowfullscreen="" 
                loading="lazy"
              ></iframe>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axiosInstance from '@/services/axiosInstance.js';
import Footer from '@/views/GuestViews/Footer.vue';

export default {
  name: 'Contact',
  components: {
    Footer
  },
  data() {
    return {
      formData: {
        name: '',
        email: '',
        phone: '',
        subject: '',
        message: '',
        status: 'new'
      },
      isSubmitting: false
    }
  },
  methods: {
    async handleSubmit() {
      try {
        this.isSubmitting = true;
        
        // Gửi dữ liệu form đến API
        const response = await axiosInstance.post('/api/contact', this.formData);
        
        if (response.status === 200) {
          alert('Cảm ơn bạn đã liên hệ. Chúng tôi sẽ phản hồi sớm nhất có thể!');
          // Reset form
          this.formData = {
            name: '',
            email: '',
            phone: '',
            subject: '',
            message: '',
            status: 'new'
          };
        }
      } catch (error) {
        console.error('Lỗi khi gửi form:', error);
        alert('Có lỗi xảy ra khi gửi tin nhắn. Vui lòng thử lại!');
      } finally {
        this.isSubmitting = false;
      }
    }
  }
}
</script>

<style scoped>
.contact-page {
  background-color: #f8f9fa;
  min-height: calc(100vh - 80px); /* Trừ đi chiều cao của header */
  margin-top: 80px; /* Thêm margin-top bằng chiều cao của header */
  display: flex;
  flex-direction: column;
}

.container {
  flex: 1;
}

.section-title {
  color: #2c3e50;
  font-weight: 600;
}

.info-item {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
}

.info-item i {
  font-size: 1.5rem;
  color: #3498db;
  margin-top: 0.25rem;
}

.info-content h5 {
  margin: 0;
  color: #2c3e50;
  font-size: 1.1rem;
  font-weight: 600;
}

.info-content p {
  margin: 0.5rem 0 0;
  color: #666;
}

.info-content a {
  color: #666;
  text-decoration: none;
  transition: color 0.3s;
}

.info-content a:hover {
  color: #3498db;
}

.contact-form {
  background: white;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.map-frame {
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.form-control:focus {
  border-color: #3498db;
  box-shadow: 0 0 0 0.2rem rgba(52,152,219,0.25);
}

.btn-primary {
  background-color: #3498db;
  border-color: #3498db;
}

.btn-primary:hover {
  background-color: #2980b9;
  border-color: #2980b9;
}

.btn-primary:disabled {
  background-color: #bdc3c7;
  border-color: #bdc3c7;
}
</style> 