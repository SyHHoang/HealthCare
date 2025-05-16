<template>
  <div class="home">
    <!-- Hero Section -->
    <div class="hero">
      <div class="hero-overlay"></div>
      <div class="container">
        <div class="hero-content">
          <h1 class="hero-title" data-aos="fade-up">
            Chăm Sóc Sức Khỏe Thông Minh
          </h1>
          <p class="hero-subtitle" data-aos="fade-up" data-aos-delay="200">
            Khám phá giải pháp y tế tiên tiến với sự kết hợp của AI và chuyên môn y tế
          </p>
          <div class="hero-buttons" data-aos="fade-up" data-aos-delay="400">
            <router-link to="/services" class="btn btn-primary">
              <i class="fas fa-stethoscope"></i> Dịch Vụ Y Tế
            </router-link>
            <router-link to="/doctors&specialties" class="btn btn-outline">
              <i class="fas fa-calendar-alt"></i> Đặt Lịch Khám
            </router-link>
          </div>
        </div>
      </div>
    </div>
    <!-- About Section -->
<!-- About Smart Healthcare -->
<section class="about-smart-healthcare">
  <div class="container about-wrapper">
    <div class="about-image" data-aos="fade-right">
      <img src="@/assets/images/introduce.jpg" alt="Smart Healthcare" />
    </div>
    <div class="about-text" data-aos="fade-left">
      <router-link to="/about">
        <h2>Giới Thiệu Về Y Tế Thông Minh</h2>
      </router-link>
      <p>
        Y tế thông minh kết hợp trí tuệ nhân tạo (AI), IoT và dữ liệu lớn để nâng cao hiệu quả chẩn đoán, điều trị và chăm sóc sức khỏe. Chúng tôi tiên phong ứng dụng công nghệ để mang đến dịch vụ chăm sóc sức khỏe chính xác, an toàn và cá nhân hóa.
      </p>
      <router-link to="/about" class="btn-detail">
        Chi tiết về Y tế Thông minh
      </router-link>
    </div>
  </div>
</section>
    <!-- Features Section -->
    <div class="features-section">
      <div class="container">
        <div class="hero-features" data-aos="fade-up">
          <div class="feature" style="background-image: url('/images/doctor-feature.jpg')">
            <div class="feature-overlay"></div>
            <div class="feature-content">
              <i class="fas fa-user-md"></i>
              <h3>Bác Sĩ Chuyên Khoa</h3>
              <p>Đội ngũ y bác sĩ giàu kinh nghiệm</p>
            </div>
          </div>
          <div class="feature" style="background-image: url('/images/ai-feature.jpg')">
            <div class="feature-overlay"></div>
            <div class="feature-content">
              <i class="fas fa-robot"></i>
              <h3>Tư Vấn AI</h3>
              <p>Hỗ trợ 24/7 với công nghệ AI</p>
            </div>
          </div>
          <div class="feature" style="background-image: url('/images/hospital-feature.jpg')">
            <div class="feature-overlay"></div>
            <div class="feature-content">
              <i class="fas fa-hospital"></i>
              <h3>Cơ Sở Hiện Đại</h3>
              <p>Trang thiết bị y tế tiên tiến</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- News Section -->
    <section class="news-section" data-aos="fade-up">
      <div class="container">
        <h2 class="section-title">Tin Tức & Sự Kiện Mới Nhất</h2>
        <div class="news-grid">
          <div v-if="loading" class="loading-spinner">
            <i class="fas fa-spinner fa-spin"></i>
          </div>
          <div v-else-if="latestNews.length === 0" class="no-news">
            <p>Chưa có tin tức nào</p>
          </div>
          <div v-else class="news-card" v-for="news in latestNews" :key="news._id">
            <div class="news-image">
              <img :src="news.coverImage" :alt="news.title">
            </div>
            <div class="news-content">
              <span class="news-category">{{ news.category }}</span>
              <h3 class="news-title">{{ news.title }}</h3>
              <p class="news-summary">{{ news.summary }}</p>
              <div class="news-meta">
                <span class="news-date">
                  <i class="far fa-calendar-alt"></i>
                  {{ new Date(news.createdAt).toLocaleDateString('vi-VN') }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Testimonials Section -->
    <div class="testimonials-section">
      <div class="container">
        <div class="section-title" data-aos="fade-up">
          <h2>Đánh Giá Từ Khách Hàng</h2>
          <p>Những trải nghiệm từ khách hàng đã sử dụng dịch vụ của chúng tôi</p>
        </div>
        <div v-if="isReviewsLoading" class="text-center py-5">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Đang tải...</span>
          </div>
        </div>
        <div v-else-if="topReviews.length === 0" class="text-center py-5">
          <p class="text-muted">Chưa có đánh giá nào</p>
        </div>
        <div v-else class="testimonials-grid">
          <div class="testimonial-card" v-for="review in topReviews" :key="review.id" data-aos="fade-up">
            <div class="testimonial-rating">
              <i v-for="star in 5" :key="star" class="fas fa-star" :class="star <= review.rating ? 'filled' : ''"></i>
            </div>
            <div class="testimonial-content">
              <p>"{{ review.content }}"</p>
            </div>
            <div class="testimonial-author">
              <div class="author-avatar">
                <img :src="review.user?.avatar || '/images/default-avatar.jpg'" alt="Avatar">
              </div>
              <div class="author-info">
                <h4>{{ review.user?.fullname || 'Khách hàng' }}</h4>
                <p>{{ review.service }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Announcement Banner Carousel -->
    <div class="announcements-section">
      <div class="container">
        <div class="section-title" data-aos="fade-up">
          <h2>Thông Báo Quan Trọng</h2>
        </div>
        <div class="announcements-carousel" data-aos="fade-up">
          <div 
            class="announcement-item" 
            :class="{ active: currentAnnouncement === index }" 
            v-for="(announcement, index) in announcements" 
            :key="index"
          >
            <div class="announcement-icon">
              <i :class="announcement.icon"></i>
            </div>
            <div class="announcement-content">
              <h3>{{ announcement.title }}</h3>
              <p>{{ announcement.content }}</p>
              <router-link v-if="announcement.link" :to="announcement.link" class="announcement-link">
                {{ announcement.linkText }} <i class="fas fa-arrow-right"></i>
              </router-link>
            </div>
          </div>
          <div class="carousel-controls">
            <button @click="prevAnnouncement" class="control-btn prev">
              <i class="fas fa-chevron-left"></i>
            </button>
            <div class="carousel-indicators">
              <span 
                v-for="(_, index) in announcements" 
                :key="index" 
                :class="{ active: currentAnnouncement === index }"
                @click="goToAnnouncement(index)"
              ></span>
            </div>
            <button @click="nextAnnouncement" class="control-btn next">
              <i class="fas fa-chevron-right"></i>
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import AOS from 'aos';
import 'aos/dist/aos.css';
import axiosInstance from '@/services/axiosInstance.js';

const currentSlide = ref(0);
const slides = ref([
  {
    image: '/images/service1.jpg',
    title: 'Khám Sức Khỏe Tổng Quát',
    description: 'Chương trình khám sức khỏe toàn diện với các gói khám phù hợp'
  },
  {
    image: '/images/service2.jpg',
    title: 'Tư Vấn Dinh Dưỡng',
    description: 'Tư vấn chế độ dinh dưỡng cá nhân hóa với chuyên gia'
  },
  {
    image: '/images/service3.jpg',
    title: 'Chăm Sóc Sức Khỏe Tại Nhà',
    description: 'Dịch vụ chăm sóc y tế tại nhà chuyên nghiệp'
  }
]);

const isNewsLoading = ref(true);
const latestNews = ref([]);
const loading = ref(true);

const isReviewsLoading = ref(true);
const topReviews = ref([]);

const currentAnnouncement = ref(0);
const announcements = ref([
  {
    title: "Lịch Nghỉ Lễ 2/9",
    content: "Bệnh viện sẽ duy trì dịch vụ cấp cứu 24/7 trong dịp lễ 2/9. Các dịch vụ khám thông thường sẽ tạm ngưng từ ngày 02/09 đến hết ngày 04/09.",
    icon: "fas fa-calendar-alt",
    link: "/holiday-schedule",
    linkText: "Xem lịch chi tiết"
  },
  {
    title: "Cập Nhật Quy Trình Đặt Lịch Khám",
    content: "Từ ngày 01/11/2024, bệnh viện áp dụng quy trình đặt lịch khám mới, giúp rút ngắn thời gian chờ đợi và tăng trải nghiệm khách hàng.",
    icon: "fas fa-procedures",
    link: "/booking-process",
    linkText: "Tìm hiểu thêm"
  },
  {
    title: "Chương Trình Tầm Soát Ung Thư",
    content: "Chương trình tầm soát ung thư miễn phí dành cho người cao tuổi sẽ được tổ chức vào các ngày cuối tuần trong tháng 10/2024.",
    icon: "fas fa-heartbeat",
    link: "/cancer-screening",
    linkText: "Đăng ký tham gia"
  }
]);

// Methods
const nextSlide = () => {
  currentSlide.value = (currentSlide.value + 1) % slides.value.length;
};

const prevSlide = () => {
  currentSlide.value = (currentSlide.value - 1 + slides.value.length) % slides.value.length;
};

const nextAnnouncement = () => {
  currentAnnouncement.value = (currentAnnouncement.value + 1) % announcements.value.length;
};

const prevAnnouncement = () => {
  currentAnnouncement.value = (currentAnnouncement.value - 1 + announcements.value.length) % announcements.value.length;
};

const goToAnnouncement = (index) => {
  currentAnnouncement.value = index;
};

// Format date from ISO string to readable format
const formatDate = (dateString) => {
  const date = new Date(dateString);
  return date.toLocaleDateString('vi-VN', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric'
  });
};

// Mounted hook
onMounted(() => {
  AOS.init({
    duration: 1000,
    once: true,
    offset: 50
  });

  // Start auto slide
  setInterval(() => {
    nextSlide();
  }, 5000);

  // Start auto announcement
  setInterval(() => {
    nextAnnouncement();
  }, 5000);

  // Fetch data
  fetchLatestNews();
  fetchTopReviews();
});

// Fetch latest news from API
const fetchLatestNews = async () => {
  try {
    console.log('Đang gọi API lấy tin tức...');
    const response = await axiosInstance.get('/api/news/latest');
    console.log('Kết quả API:', response.data);
    
    if (response.data.success) {
      latestNews.value = response.data.data;
    } else {
      console.error('API trả về không thành công:', response.data.message);
    }
  } catch (error) {
    console.error('Lỗi khi lấy tin tức:', error);
    if (error.response) {
      console.error('Chi tiết lỗi:', error.response.data);
    }
  } finally {
    loading.value = false;
  }
};

// Fetch top reviews
const fetchTopReviews = async () => {
  try {
    isReviewsLoading.value = true;
    const response = await axiosInstance.get('/api/feedback/top');
    topReviews.value = response.data.feedbacks;
  } catch (error) {
    console.error('Lỗi khi tải đánh giá:', error);
  } finally {
    isReviewsLoading.value = false;
  }
};
</script>

<style scoped>
.hero {
  position: relative;
  min-height: 100vh;
  background-image: url('@/assets/images/main-banner.jpg');
  background-size: cover;
  background-position: center;
  display: flex;
  align-items: center;
  color: white;
  overflow: hidden;
}


.container {
  position: relative;
  z-index: 1;
  padding: 0 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.hero-content {
  max-width: 800px;
  margin: 0 auto;
  text-align: center;
}

.hero-title {
  font-size: 3.5rem;
  font-weight: 700;
  margin-bottom: 1.5rem;
  line-height: 1.2;
  text-shadow: 2px 2px 4px rgba(0,0,0,0.2);
}

.hero-subtitle {
  font-size: 1.25rem;
  margin-bottom: 2rem;
  line-height: 1.6;
  opacity: 0.9;
}

.hero-buttons {
  display: flex;
  gap: 1rem;
  justify-content: center;
  margin-bottom: 4rem;
}

.btn {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 1rem 2rem;
  font-size: 1.1rem;
  font-weight: 600;
  border-radius: 50px;
  transition: all 0.3s ease;
}

.btn i {
  font-size: 1.2rem;
}

.btn-primary {
  background: #fff;
  color: #007bff;
  border: none;
}

.btn-primary:hover {
  background: #f8f9fa;
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(0,0,0,0.2);
}

.btn-outline {
  border: 2px solid #fff;
  color: #fff;
  background: transparent;
}

.btn-outline:hover {
  background: #fff;
  color: #007bff;
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(0,0,0,0.2);
}

.features-section {
  padding: 80px 0;
  background: #f8f9fa;
}

.hero-features {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 2rem;
  margin-top: 2rem;
}

.feature {
  position: relative;
  min-height: 300px;
  border-radius: 20px;
  overflow: hidden;
  background-size: cover;
  background-position: center;
  transition: all 0.3s ease;
}

.feature-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(to bottom, rgba(0,0,0,0.3), rgba(0,0,0,0.7));
  transition: all 0.3s ease;
}

.feature:hover .feature-overlay {
  background: linear-gradient(to bottom, rgba(0,0,0,0.5), rgba(0,0,0,0.9));
}

.feature-content {
  position: relative;
  z-index: 1;
  padding: 2rem;
  color: white;
  text-align: center;
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.feature i {
  font-size: 3rem;
  margin-bottom: 1.5rem;
  color: #fff;
  background: rgba(255, 255, 255, 0.1);
  width: 80px;
  height: 80px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
}

.feature:hover i {
  transform: scale(1.1);
  background: rgba(255, 255, 255, 0.2);
}

.feature h3 {
  font-size: 1.5rem;
  margin-bottom: 1rem;
  font-weight: 600;
  color: #fff;
}

.feature p {
  font-size: 1rem;
  opacity: 0.9;
  margin: 0;
  color: #fff;
}

.feature:hover {
  transform: translateY(-10px);
  box-shadow: 0 15px 30px rgba(0,0,0,0.2);
}

@media (max-width: 992px) {
  .hero-features {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .hero-features {
    grid-template-columns: 1fr;
  }

  .feature {
    min-height: 250px;
  }

  .feature i {
    font-size: 2.5rem;
    width: 60px;
    height: 60px;
  }

  .feature h3 {
    font-size: 1.3rem;
  }
}

/* Animation */
@keyframes float {
  0% {
    transform: translateY(0px);
  }
  50% {
    transform: translateY(-20px);
  }
  100% {
    transform: translateY(0px);
  }
}

.feature {
  animation: float 6s ease-in-out infinite;
}

.feature:nth-child(2) {
  animation-delay: 1s;
}

.feature:nth-child(3) {
  animation-delay: 2s;
}

/* Slider Section */
.slider-section {
  padding: 80px 0;
  background: #f8f9fa;
}

.section-title {
  text-align: center;
  margin-bottom: 40px;
}

.section-title h2 {
  font-size: 2.5rem;
  color: #064ba0;
  margin-bottom: 10px;
}

.section-title p {
  color: #6c757d;
  font-size: 1.1rem;
}

.slider {
  position: relative;
  overflow: hidden;
  border-radius: 20px;
  box-shadow: 0 10px 30px rgba(0,0,0,0.1);
}

.slider-container {
  display: flex;
  transition: transform 0.5s ease;
}

.slide {
  min-width: 100%;
  position: relative;
}

.slide img {
  width: 100%;
  height: 500px;
  object-fit: cover;
}

.slide-content {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 30px;
  background: linear-gradient(to top, rgba(0,0,0,0.8), transparent);
  color: white;
}

.slide-content h3 {
  font-size: 1.8rem;
  margin-bottom: 10px;
}

.slider-btn {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  background: white;
  border: none;
  width: 50px;
  height: 50px;
  border-radius: 50%;
  cursor: pointer;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  transition: all 0.3s ease;
}

.slider-btn:hover {
  background: #064ba0;
  color: white;
}

.slider-btn.prev {
  left: 20px;
}

.slider-btn.next {
  right: 20px;
}

/* News Section */
.news-section {
  padding: 80px 0;
  background: #f8f9fa;
}

.section-title {
  text-align: center;
  font-size: 2.5rem;
  color: #1a237e;
  margin-bottom: 3rem;
}

.news-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 2rem;
}

.news-card {
  background: white;
  border-radius: 15px;
  overflow: hidden;
  box-shadow: 0 5px 15px rgba(0,0,0,0.1);
  transition: transform 0.3s ease;
}

.news-card:hover {
  transform: translateY(-5px);
}

.news-image {
  height: 200px;
  overflow: hidden;
}

.news-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.news-card:hover .news-image img {
  transform: scale(1.05);
}

.news-content {
  padding: 1.5rem;
}

.news-category {
  display: inline-block;
  padding: 0.25rem 0.75rem;
  background: #e3f2fd;
  color: #1a237e;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  margin-bottom: 1rem;
}

.news-title {
  font-size: 1.25rem;
  color: #1a237e;
  margin-bottom: 0.75rem;
  line-height: 1.4;
}

.news-summary {
  color: #666;
  font-size: 0.9rem;
  line-height: 1.6;
  margin-bottom: 1rem;
}

.news-meta {
  display: flex;
  align-items: center;
  gap: 1rem;
  color: #888;
  font-size: 0.8rem;
}

.news-date i {
  margin-right: 0.5rem;
}

.loading-spinner {
  text-align: center;
  padding: 2rem;
  color: #1a237e;
  font-size: 2rem;
}

.no-news {
  text-align: center;
  padding: 2rem;
  color: #666;
  grid-column: 1 / -1;
}

@media (max-width: 768px) {
  .news-grid {
    grid-template-columns: 1fr;
  }
  
  .section-title {
    font-size: 2rem;
  }
}

/* Testimonials Section */
.testimonials-section {
  padding: 80px 0;
  background: #f0f7ff;
}

/* News actions */
.news-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 15px;
}

.testimonials-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 30px;
}

.testimonial-card {
  background: white;
  border-radius: 15px;
  padding: 30px;
  box-shadow: 0 5px 15px rgba(0,0,0,0.05);
  transition: all 0.3s ease;
}

.testimonial-card:hover {
  transform: translateY(-10px);
  box-shadow: 0 10px 30px rgba(0,0,0,0.1);
}

.testimonial-rating {
  margin-bottom: 20px;
  color: #ddd;
}

.testimonial-rating .fas.filled {
  color: #ffc107;
}

.testimonial-content {
  font-style: italic;
  margin-bottom: 20px;
  color: #555;
  line-height: 1.6;
}

.testimonial-author {
  display: flex;
  align-items: center;
}

.author-avatar {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  overflow: hidden;
  margin-right: 15px;
}

.author-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.author-info h4 {
  margin: 0;
  font-size: 1rem;
  color: #333;
}

.author-info p {
  margin: 5px 0 0;
  font-size: 0.9rem;
  color: #666;
}

@media (max-width: 768px) {
  .testimonials-grid {
    grid-template-columns: 1fr;
  }
}

/* Announcement Banner Carousel Styles */
.announcements-section {
  background-color: #f8f9fa;
  padding: 50px 0;
  margin-top: 50px;
}

.announcements-carousel {
  position: relative;
  max-width: 800px;
  margin: 0 auto;
  overflow: hidden;
  padding: 20px 0;
}

.announcement-item {
  display: none;
  background-color: white;
  border-radius: 10px;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
  padding: 30px;
  display: flex;
  align-items: flex-start;
  opacity: 0;
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  transition: opacity 0.5s ease;
}

.announcement-item.active {
  display: flex;
  opacity: 1;
  position: relative;
}

.announcement-icon {
  flex: 0 0 60px;
  height: 60px;
  background-color: #e3f2fd;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 20px;
  color: #1976d2;
  font-size: 24px;
}

.announcement-content {
  flex: 1;
}

.announcement-content h3 {
  margin: 0 0 10px 0;
  color: #333;
  font-size: 1.3rem;
}

.announcement-content p {
  margin: 0 0 15px 0;
  color: #666;
  line-height: 1.6;
}

.announcement-link {
  display: inline-block;
  color: #1976d2;
  text-decoration: none;
  font-weight: 600;
  transition: color 0.3s;
}

.announcement-link:hover {
  color: #0d47a1;
}

.carousel-controls {
  display: flex;
  justify-content: center;
  align-items: center;
  margin-top: 30px;
}

.control-btn {
  background-color: transparent;
  border: none;
  color: #1976d2;
  cursor: pointer;
  font-size: 1.2rem;
  padding: 5px 10px;
  transition: color 0.3s;
}

.control-btn:hover {
  color: #0d47a1;
}

.carousel-indicators {
  display: flex;
  gap: 10px;
  margin: 0 15px;
}

.carousel-indicators span {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background-color: #ccc;
  cursor: pointer;
  transition: background-color 0.3s;
}

.carousel-indicators span.active {
  background-color: #1976d2;
}

/* About Smart Healthcare Section */
.about-smart-healthcare {
  padding: 80px 0;
  background: #fff;
}

.about-wrapper {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 50px;
}

.about-image {
  flex: 0 0 45%;
  position: relative;
  overflow: hidden;
  border-radius: 20px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
}

.about-image img {
  width: 100%;
  height: 400px;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.about-image:hover img {
  transform: scale(1.05);
}

.about-text {
  flex: 0 0 45%;
}

.about-text h2 {
  font-size: 2.2rem;
  margin-bottom: 20px;
  color: #064ba0;
  transition: color 0.3s ease;
}

.about-text h2:hover {
  color: #ff7900;
}

.about-text p {
  font-size: 1.1rem;
  color: #555;
  margin-bottom: 30px;
  line-height: 1.8;
}

.btn-detail {
  display: inline-block;
  background-color: #ff7900;
  color: #fff;
  padding: 15px 30px;
  text-decoration: none;
  font-weight: 600;
  border-radius: 50px;
  transition: all 0.3s ease;
  box-shadow: 0 5px 15px rgba(255, 121, 0, 0.3);
}

.btn-detail:hover {
  background-color: #e06d00;
  transform: translateY(-3px);
  box-shadow: 0 8px 20px rgba(255, 121, 0, 0.4);
}

@media (max-width: 992px) {
  .about-wrapper {
    flex-direction: column;
    text-align: center;
  }

  .about-image, .about-text {
    flex: 0 0 100%;
  }

  .about-image img {
    height: 300px;
  }

  .about-text h2 {
    font-size: 2rem;
  }
}

@media (max-width: 576px) {
  .about-image img {
    height: 250px;
  }

  .about-text h2 {
    font-size: 1.8rem;
  }

  .about-text p {
    font-size: 1rem;
  }

  .btn-detail {
    padding: 12px 25px;
    font-size: 0.9rem;
  }
}
</style> 