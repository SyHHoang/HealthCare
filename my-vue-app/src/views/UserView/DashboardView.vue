<template>
  <div class="dashboard">
    
    <div class="dashboard-grid">
      <div class="dashboard-card history-card">
        <div class="card-content">
          <h3>
            <i class="bi bi-clock-history me-2"></i>
            Lịch sử tư vấn
          </h3>
          <p>Xem lại các cuộc tư vấn trước đây</p>
          <router-link to="/user/consultation-history" class="card-button">
            <i class="bi bi-eye"></i> Xem ngay
          </router-link>
        </div>
      </div>
      
      <div class="dashboard-card doctor-card">
        <div class="card-content">
          <h3>
            <i class="bi bi-person-vcard me-2"></i>
            Tìm bác sĩ
          </h3>
          <p>Tìm bác sĩ phù hợp với nhu cầu của bạn</p>
          <router-link to="/user/doctors" class="card-button">
            <i class="bi bi-search"></i> Tìm kiếm
          </router-link>
        </div>
      </div>
      
      <div class="dashboard-card medical-card">
        <div class="card-content">
          <h3>
            <i class="bi bi-file-earmark-medical me-2"></i>
            Hồ sơ y tế
          </h3>
          <p>Quản lý thông tin y tế cá nhân</p>
          <router-link to="/user/medical-record" class="card-button">
            <i class="bi bi-journal-medical"></i> Xem hồ sơ
          </router-link>
        </div>
      </div>
    </div>
    
    <div class="faq-section">
      <h2>
        <i class="bi bi-question-circle me-2"></i>
        Hướng dẫn sử dụng hệ thống
      </h2>
      <div class="accordion">
        <div v-for="(faq, index) in faqs" :key="index" class="accordion-item">
          <div 
            class="accordion-header" 
            @click="toggleAccordion(index)"
            :class="{ 'active': activeIndex === index }"
          >
            <h3>{{ faq.question }}</h3>
            <i class="bi" :class="activeIndex === index ? 'bi-chevron-up' : 'bi-chevron-down'"></i>
          </div>
          <div class="accordion-content" v-show="activeIndex === index">
            <p>{{ faq.answer }}</p>
          </div>
        </div>
      </div>
    </div>
    
    <div class="guide-articles">
      <h2>
        <i class="bi bi-journal-text me-2"></i>
        Bài viết hướng dẫn
      </h2>
      <div v-if="loadingGuides" class="loading">
        <i class="bi bi-arrow-repeat fa-spin"></i> Đang tải...
      </div>
      <div v-else-if="guideArticles.length > 0" class="articles-grid">
        <div v-for="article in guideArticles" :key="article._id" class="article-card">
          <div class="article-image" v-if="article.coverImage">
            <img :src="article.coverImage" :alt="article.title">
          </div>
          <div class="article-content">
            <h3>{{ article.title }}</h3>
            <p class="article-summary">{{ article.summary }}</p>
            <div class="article-meta">
              <span class="article-date">
                <i class="bi bi-calendar-event"></i> {{ formatDate(article.createdAt) }}
              </span>
              <router-link :to="'/news/' + article._id" class="read-more">
                Đọc thêm <i class="bi bi-arrow-right"></i>
              </router-link>
            </div>
          </div>
        </div>
      </div>
      <div v-else class="no-articles">
        <i class="bi bi-newspaper"></i>
        <p>Chưa có bài viết hướng dẫn nào</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axiosInstance from '@/services/axiosInstance.js';
import { format, parseISO } from 'date-fns';
import { vi } from 'date-fns/locale';

const userName = ref('');
const activeIndex = ref(null);
const loadingGuides = ref(true);
const guideArticles = ref([]);

const faqs = ref([
  {
    question: "Làm thế nào để xem lịch sử tư vấn?",
    answer: "Bạn có thể xem lịch sử tư vấn bằng cách nhấp vào nút 'Xem ngay' trong mục Lịch sử tư vấn. Tại đây, bạn sẽ thấy danh sách các cuộc tư vấn đã thực hiện, bao gồm thời gian, bác sĩ tư vấn và tóm tắt nội dung tư vấn."
  },
  {
    question: "Cách tìm và đặt lịch với bác sĩ?",
    answer: "Để tìm bác sĩ, bạn có thể sử dụng tính năng tìm kiếm theo chuyên khoa, tên bác sĩ hoặc đánh giá. Sau khi chọn được bác sĩ phù hợp, bạn có thể xem lịch trống và đặt lịch tư vấn. Hệ thống sẽ gửi xác nhận qua email và thông báo trong ứng dụng."
  },
  {
    question: "Quản lý hồ sơ y tế như thế nào?",
    answer: "Trong mục Hồ sơ y tế, bạn có thể cập nhật thông tin cá nhân, lịch sử bệnh án, đơn thuốc, kết quả xét nghiệm và các thông tin y tế khác. Tất cả thông tin được bảo mật và chỉ chia sẻ với bác sĩ khi bạn cho phép."
  },
  {
    question: "Các hình thức tư vấn có sẵn?",
    answer: "Hệ thống hỗ trợ nhiều hình thức tư vấn bao gồm: chat trực tuyến, gọi video call, và gửi tin nhắn. Bạn có thể chọn hình thức phù hợp với nhu cầu của mình khi đặt lịch tư vấn."
  },
  {
    question: "Làm thế nào để bảo mật thông tin?",
    answer: "Hệ thống của chúng tôi tuân thủ các tiêu chuẩn bảo mật y tế quốc tế. Tất cả thông tin được mã hóa, chỉ người dùng và bác sĩ được chỉ định mới có quyền truy cập vào hồ sơ y tế của bạn."
  }
]);

const toggleAccordion = (index) => {
  activeIndex.value = activeIndex.value === index ? null : index;
};

const fetchGuideArticles = async () => {
  try {
    const response = await axiosInstance.get('/api/news', {
      params: {
        category: 'guide'
      }
    });
    guideArticles.value = response.data;
  } catch (error) {
    console.error('Lỗi khi tải bài viết hướng dẫn:', error);
  } finally {
    loadingGuides.value = false;
  }
};

const formatDate = (date) => {
  try {
    return format(parseISO(date), 'dd/MM/yyyy', { locale: vi });
  } catch (error) {
    return 'Không rõ ngày';
  }
};

onMounted(async () => {
  try {
    const userResponse = await axiosInstance.get('/api/users/profile');
    if (userResponse.data) {
      userName.value = userResponse.data.fullName || 'Người dùng';
    }
    await fetchGuideArticles();
  } catch (error) {
    console.error('Lỗi khi tải dữ liệu:', error);
  }
});
</script>

<style scoped>
.dashboard {
  padding: 100px;
}

.greeting {
  font-size: 24px;
  margin-bottom: 30px;
  color: #2c3e50;
}

.dashboard-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
  margin-bottom: 40px;
}

.dashboard-card {
  position: relative;
  border-radius: 12px;
  overflow: hidden;
  height: 200px;
  background-size: cover;
  background-position: center;
  transition: transform 0.3s ease;
}

.dashboard-card:hover {
  transform: translateY(-5px);
}

.dashboard-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(to bottom, rgba(0,0,0,0.1), rgba(0,0,0,0.7));
  z-index: 1;
}

.history-card {
  background-image: url('https://images.unsplash.com/photo-1576091160550-2173dba999ef?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80');
}

.doctor-card {
  background-image: url('https://images.unsplash.com/photo-1579684385127-1ef15d508118?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80');
}

.medical-card {
  background-image: url('https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80');
}

.card-content {
  position: relative;
  z-index: 2;
  padding: 20px;
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  color: white;
}

.card-content h3 {
  margin: 0 0 10px 0;
  font-size: 24px;
  font-weight: 600;
  text-shadow: 0 2px 4px rgba(0,0,0,0.3);
}

.card-content p {
  margin: 0 0 15px 0;
  font-size: 16px;
  opacity: 0.9;
  text-shadow: 0 1px 2px rgba(0,0,0,0.3);
}

.card-button {
  display: inline-block;
  padding: 10px 20px;
  background-color: rgba(255, 255, 255, 0.9);
  color: #2c3e50;
  text-decoration: none;
  border-radius: 6px;
  font-weight: 500;
  transition: all 0.3s ease;
  text-align: center;
  width: fit-content;
}

.card-button:hover {
  background-color: white;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}

.faq-section {
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.05);
  padding: 20px;
}

.faq-section h2 {
  margin-top: 0;
  margin-bottom: 20px;
  color: #2c3e50;
  font-size: 20px;
  border-bottom: 1px solid #ecf0f1;
  padding-bottom: 10px;
}

.accordion {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.accordion-item {
  border: 1px solid #ecf0f1;
  border-radius: 8px;
  overflow: hidden;
}

.accordion-header {
  padding: 15px 20px;
  background-color: #f8f9fa;
  cursor: pointer;
  display: flex;
  justify-content: space-between;
  align-items: center;
  transition: background-color 0.3s;
}

.accordion-header:hover {
  background-color: #e9ecef;
}

.accordion-header.active {
  background-color: #e9ecef;
}

.accordion-header h3 {
  margin: 0;
  font-size: 16px;
  color: #2c3e50;
}

.accordion-content {
  padding: 20px;
  background-color: white;
  color: #7f8c8d;
  font-size: 14px;
  line-height: 1.6;
}

.guide-articles {
  margin-top: 40px;
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.05);
  padding: 20px;
}

.guide-articles h2 {
  margin-top: 0;
  margin-bottom: 20px;
  color: #2c3e50;
  font-size: 20px;
  border-bottom: 1px solid #ecf0f1;
  padding-bottom: 10px;
}

.articles-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
}

.article-card {
  background-color: #fff;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  transition: transform 0.3s ease;
}

.article-card:hover {
  transform: translateY(-5px);
}

.article-image {
  width: 100%;
  height: 200px;
  overflow: hidden;
}

.article-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.article-content {
  padding: 20px;
}

.article-content h3 {
  margin: 0 0 10px 0;
  color: #2c3e50;
  font-size: 18px;
  line-height: 1.4;
}

.article-summary {
  color: #7f8c8d;
  font-size: 14px;
  line-height: 1.6;
  margin-bottom: 15px;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.article-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 15px;
}

.article-date {
  color: #95a5a6;
  font-size: 12px;
}

.read-more {
  color: #3498db;
  text-decoration: none;
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 5px;
  transition: color 0.3s;
}

.read-more:hover {
  color: #2980b9;
}

.read-more i {
  font-size: 12px;
  transition: transform 0.3s;
}

.read-more:hover i {
  transform: translateX(3px);
}

.loading {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100px;
  color: #7f8c8d;
}

.no-articles {
  text-align: center;
  padding: 40px 0;
  color: #7f8c8d;
}

@media (max-width: 768px) {
  .dashboard-grid {
    grid-template-columns: 1fr;
  }
  
  .dashboard-card {
    height: 180px;
  }
}
</style> 