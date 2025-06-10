<template>
  <div class="dashboard-container">
    <!-- Top Navigation -->
    

    <!-- Main Content -->
    <div class="main-content">
      <div class="dashboard-content">
        <div class="dashboard-header">
          <h1 class="dashboard-title">Tổng quan</h1>
        </div>

        <!-- Thống kê tổng quan -->
        <div class="stats-grid">
          <div class="stat-card appointments-card">
            <div class="stat-icon">
              <i class="bi bi-calendar-check"></i>
            </div>
            <div class="stat-info">
              <h3>Lịch hẹn hôm nay</h3>
              <p class="stat-number">0</p>

            </div>
          </div>

          <div class="stat-card patients-card">
            <div class="stat-icon">
              <i class="bi bi-people"></i>
            </div>
            <div class="stat-info">
              <h3>Tổng số bệnh nhân</h3>
              <p class="stat-number">10</p>

            </div>
          </div>

          <div class="stat-card rating-card">
            <div class="stat-icon">
              <i class="bi bi-star"></i>
            </div>
            <div class="stat-info">
              <h3>Đánh giá trung bình</h3>
              <p class="stat-number">
                {{ ratingCard.averageRating.toFixed(1) }} 
                <i class="bi bi-star-fill rating-star"></i>
              </p>
              <p class="stat-detail">
                Tổng số đánh giá: {{ ratingCard.totalReviews }}
              </p>
            </div>
          </div>

          <div class="stat-card revenue-card">
            <div class="stat-icon">
              <i class="bi bi-currency-dollar"></i>
            </div>
            <div class="stat-info">
              <h3>Tổng doanh thu</h3>
              <p class="stat-number">2.500.000 VNĐ</p>
        
            </div>
          </div>
        </div>

        <!-- Quick Guide Section (Hướng dẫn nhanh) dạng accordion, full width -->
        <div class="quick-guide-section">
          <h2>Hướng dẫn nhanh</h2>
          <div class="accordion">
            <div v-for="(guide, index) in guides" :key="index" class="accordion-item">
              <div 
                class="accordion-header"
                :class="{ active: activeGuideIndex === index }"
                @click="toggleGuideAccordion(index)"
              >
                <h3>{{ guide.title }}</h3>
                <i class="fas" :class="activeGuideIndex === index ? 'fa-chevron-up' : 'fa-chevron-down'"></i>
              </div>
              <div class="accordion-content" v-show="activeGuideIndex === index">
                <div v-html="guide.content"></div>
              </div>
            </div>
          </div>
        </div>

        <!-- Guide Articles Section (Bài viết hướng dẫn) -->
        <div class="guide-articles">
          <h2>Bài viết hướng dẫn</h2>
          <div v-if="loadingGuides" class="loading">
            <i class="fas fa-spinner fa-spin"></i> Đang tải...
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
                  <span class="article-date">{{ formatDate(article.createdAt) }}</span>
                  <router-link :to="'/news/' + article._id" class="read-more">
                    Đọc thêm <i class="fas fa-arrow-right"></i>
                  </router-link>
                </div>
              </div>
            </div>
          </div>
          <div v-else class="no-articles">
            <p>Chưa có bài viết hướng dẫn nào</p>
          </div>
        </div>

        <!-- Tin tức nổi bật -->
        <div class="featured-news">
          <div class="section-header">
            <h2>Tin tức nổi bật</h2>
            <router-link to="/news" class="view-all">Xem tất cả <i class="bi bi-arrow-right"></i></router-link>
          </div>
          <div v-if="featuredNews.length === 0" class="no-articles">
            <p>Chưa có tin tức nổi bật nào</p>
          </div>
          <div v-else class="news-grid">
            <div v-for="news in featuredNews" :key="news._id" class="news-card">
              <div class="news-image">
                <img :src="news.coverImage" :alt="news.title">
                <div class="news-category">{{ news.category }}</div>
              </div>
              <div class="news-content">
                <h3>{{ news.title }}</h3>
                <p>{{ news.summary }}</p>
                <div class="news-meta">
                  <span class="views"><i class="bi bi-eye"></i> {{ news.viewCount }} lượt xem</span>
                  <span class="date"><i class="bi bi-calendar3"></i> {{ formatDate(news.createdAt) }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Main Dashboard Grid -->
        <div class="dashboard-grid">
          <!-- Reviews Section -->
          <div class="dashboard-card reviews-section">
            <div class="card-header">
              <h2>Đánh giá gần đây</h2>
              <div class="review-filters">
                <button 
                  v-for="rating in 5" 
                  :key="rating"
                  :class="['filter-btn', { active: currentRatingFilter === rating }]"
                  @click="currentRatingFilter = rating"
                >
                  {{ rating }} <i class="bi bi-star-fill"></i>
                </button>
                <button 
                  :class="['filter-btn', { active: currentRatingFilter === 'all' }]"
                  @click="currentRatingFilter = 'all'"
                >
                  Tất cả
                </button>
              </div>
            </div>
            <div class="reviews-list">
              <div v-if="filteredReviews.length === 0" class="no-reviews">
                <i class="bi bi-chat-square-text"></i>
                <p>Chưa có đánh giá nào</p>
              </div>
              <div 
                v-else
                v-for="review in filteredReviews" 
                :key="review._id" 
                class="review-item"
              >
                <div class="review-header">
                  <div class="reviewer-info">
                    <img :src="review.user.avatar || '/images/default-avatar.png'" :alt="review.user.fullname" class="reviewer-avatar">
                    <div>
                      <h4>{{ review.user.fullname }}</h4>
                      <div class="review-rating">
                        <span v-for="star in 5" :key="star">
                          <i :class="star <= review.rating ? 'bi bi-star-fill' : 'bi bi-star'" class="text-warning"></i>
                        </span>
                      </div>
                    </div>
                  </div>
                  <div class="review-date">{{ formatDate(review.createdAt) }}</div>
                </div>
                <div class="review-content">
                  {{ review.content }}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import axiosInstance from '@/services/axiosInstance';
import axios from 'axios';
const router = useRouter();

// Data
const todayAppointments = ref(8);
const appointmentChange = ref(2);
const totalPatients = ref(156);
const patientChange = ref(5);
const totalRevenue = ref(15000000);
const revenueChange = ref(15);
const currentFilter = ref('all');
const currentRatingFilter = ref('all');

const appointmentStatuses = [
  { label: 'Tất cả', value: 'all' },
  { label: 'Đã hoàn thành', value: 'completed' },
  { label: 'Đang chờ', value: 'pending' },
  { label: 'Sắp tới', value: 'upcoming' }
];

const appointments = ref([
        {
          id: 1,
          time: '09:00',
          patientName: 'Nguyễn Văn A',
    patientAvatar: '/images/avatar1.jpg',
          reason: 'Khám tổng quát',
          status: 'completed'
        },
        {
          id: 2,
          time: '10:30',
          patientName: 'Trần Thị B',
    patientAvatar: '/images/avatar2.jpg',
          reason: 'Tái khám',
          status: 'pending'
        },
        {
          id: 3,
          time: '14:00',
          patientName: 'Lê Văn C',
    patientAvatar: '/images/avatar3.jpg',
          reason: 'Khám bệnh',
          status: 'upcoming'
        }
]);

// Computed
const currentDate = computed(() => {
  return new Date().toLocaleDateString('vi-VN', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });
});

const filteredAppointments = computed(() => {
  if (currentFilter.value === 'all') return appointments.value;
  return appointments.value.filter(app => app.status === currentFilter.value);
});

const filteredReviews = computed(() => {
  if (currentRatingFilter.value === 'all') return reviews.value;
  return reviews.value.filter(review => review.rating === currentRatingFilter.value);
});

// Guide data
const guides = [
  {
    title: 'Quản lý lịch hẹn',
    icon: 'fas fa-calendar-check',
    content: `
      <h5>Hướng dẫn quản lý lịch hẹn:</h5>
      <ul>
        <li>Xem danh sách lịch hẹn trong ngày</li>
        <li>Lọc lịch hẹn theo trạng thái</li>
        <li>Bắt đầu cuộc gọi video khi đến giờ hẹn</li>
        <li>Chat với bệnh nhân trước khi tư vấn</li>
      </ul>
    `
  },
  {
    title: 'Tư vấn trực tuyến',
    icon: 'fas fa-video',
    content: `
      <h5>Hướng dẫn tư vấn trực tuyến:</h5>
      <ul>
        <li>Kiểm tra kết nối internet trước khi bắt đầu</li>
        <li>Chuẩn bị tài liệu cần thiết</li>
        <li>Ghi chú thông tin bệnh nhân</li>
        <li>Kết thúc cuộc tư vấn đúng giờ</li>
      </ul>
    `
  },
  {
    title: 'Quản lý hồ sơ',
    icon: 'fas fa-file-medical',
    content: `
      <h5>Hướng dẫn quản lý hồ sơ:</h5>
      <ul>
        <li>Cập nhật thông tin bệnh nhân</li>
        <li>Lưu trữ lịch sử tư vấn</li>
        <li>Xem đánh giá từ bệnh nhân</li>
        <li>Xuất báo cáo định kỳ</li>
      </ul>
    `
  }
];

const activeGuideIndex = ref(null);
const toggleGuideAccordion = (index) => {
  activeGuideIndex.value = activeGuideIndex.value === index ? null : index;
};

// Methods
const formatCurrency = (amount) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND'
  }).format(amount);
};

const startVideoCall = (appointmentId) => {
  router.push({
    name: 'video-call',
    params: { appointmentId },
    query: { isDoctor: 'true' }
  });
};

const startChat = (appointmentId) => {
  router.push({
    name: 'chat',
    params: { appointmentId }
  });
};

// Thêm dữ liệu cho tin tức nổi bật
const featuredNews = ref([]);

// Hàm format ngày tháng
const formatDate = (date) => {
  try {
    const d = new Date(date);
    return d.toLocaleDateString('vi-VN');
  } catch (error) {
    return 'Không rõ ngày';
  }
};

// Lấy tin tức nổi bật
const fetchFeaturedNews = async () => {
  try {
    const response = await fetch('http://localhost:5000/api/news/stats/views');
    const data = await response.json();
    if (data.topArticles) {
      featuredNews.value = data.topArticles.slice(0, 3); // Chỉ lấy 3 bài viết
    }
  } catch (error) {
    console.error('Lỗi khi lấy tin tức nổi bật:', error);
  }
};

// Gọi API khi component được mount
onMounted(() => {
  fetchFeaturedNews();
});

const loadingGuides = ref(true);
const guideArticles = ref([]);

const fetchGuideArticles = async () => {
  loadingGuides.value = true;
  try {
    const response = await fetch('http://localhost:5000/api/news?category=guide');
    const data = await response.json();
    // DashboardView.vue trả về mảng hoặc object có data
    guideArticles.value = Array.isArray(data) ? data : (data.data || []);
  } catch (error) {
    console.error('Lỗi khi tải bài viết hướng dẫn:', error);
    guideArticles.value = [];
  } finally {
    loadingGuides.value = false;
  }
};

onMounted(() => {
  fetchGuideArticles();
});

const ratingCard = ref({
  averageRating: 0,
  totalReviews: 0,
  ratingDistribution: {
    5: 0,
    4: 0,
    3: 0,
    2: 0,
    1: 0
  }
});

// Hàm lấy thông tin đánh giá
const fetchRatingStats = async () => {
  try {
    const response = await axiosInstance.get(`/api/reviews/doctor-stats`);
    if (response.data.success) {
      ratingCard.value = response.data.data;
    }
  } catch (error) {
    console.error('Lỗi khi lấy thông tin đánh giá:', error);
  }
};

const reviews = ref([]);

// Hàm lấy danh sách đánh giá
const fetchReviews = async () => {
  try {
    const response = await axios.get('/api/reviews/doctor-reviews');
    if (response.data.success) {
      reviews.value = response.data.data;
    }
  } catch (error) {
    console.error('Lỗi khi lấy danh sách đánh giá:', error);
  }
};

onMounted(() => {
  fetchRatingStats();
  fetchReviews();
});
</script>

<style scoped>
.dashboard-container {
  min-height: 100vh;
  background-color: #f8f9fa;
}

/* Top Navigation */
.top-nav {
  background: white;
  padding: 1rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
  position: sticky;
  top: 0;
  z-index: 1000;
}

.nav-left {
  display: flex;
  align-items: center;
  gap: 2rem;
}

.logo {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 1.5rem;
  font-weight: 600;
  color: #2c3e50;
}

.logo i {
  font-size: 2rem;
  color: #0d6efd;
}

.date-display {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: #6c757d;
}

.nav-right {
  display: flex;
  align-items: center;
  gap: 2rem;
}

.search-box {
  position: relative;
  width: 300px;
}

.search-box input {
  width: 100%;
  padding: 0.5rem 1rem 0.5rem 2.5rem;
  border: 1px solid #dee2e6;
  border-radius: 8px;
  font-size: 0.9rem;
}

.search-box i {
  position: absolute;
  left: 1rem;
  top: 50%;
  transform: translateY(-50%);
  color: #6c757d;
}

.nav-actions {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.action-btn {
  position: relative;
  background: none;
  border: none;
  font-size: 1.2rem;
  color: #6c757d;
  cursor: pointer;
  padding: 0.5rem;
}

.badge {
  position: absolute;
  top: 0;
  right: 0;
  background: #dc3545;
  color: white;
  font-size: 0.7rem;
  padding: 0.2rem 0.4rem;
  border-radius: 10px;
}

.user-profile {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 0.5rem;
  border-radius: 8px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.user-profile:hover {
  background-color: #f8f9fa;
}

.avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
}

.user-info {
  display: flex;
  flex-direction: column;
}

.user-name {
  font-weight: 600;
  color: #2c3e50;
}

.user-role {
  font-size: 0.8rem;
  color: #6c757d;
}

/* Main Content */
.main-content {
  padding: 2rem;
}

/* Stats Grid */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.stat-card {
  background: white;
  border-radius: 16px;
  padding: 1.5rem;
  display: flex;
  align-items: center;
  gap: 1.5rem;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
  transition: transform 0.3s, box-shadow 0.3s;
}

.stat-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.8rem;
  color: white;
}

.appointments-card .stat-icon {
  background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
}

.patients-card .stat-icon {
  background: linear-gradient(135deg, #2196F3 0%, #1976D2 100%);
}

.rating-card .stat-icon {
  background: linear-gradient(135deg, #FF9800 0%, #F57C00 100%);
}

.revenue-card .stat-icon {
  background: linear-gradient(135deg, #9C27B0 0%, #7B1FA2 100%);
}

.stat-info h3 {
  margin: 0;
  font-size: 0.9rem;
  color: #6c757d;
  font-weight: 500;
}

.stat-number {
  display: flex;
  align-items: center;
  gap: 0.3rem;
  font-size: 1.8rem;
  font-weight: 600;
  color: #2c3e50;
  margin: 0.5rem 0;
}

.stat-change {
  display: flex;
  align-items: center;
  gap: 0.3rem;
  font-size: 0.8rem;
  font-weight: 500;
}

.stat-change.positive {
  color: #28a745;
}

.stat-change.negative {
  color: #dc3545;
}

.rating-star {
  color: #ffc107;
  font-size: 1.2rem;
  margin-left: 0.3rem;
}

.stat-detail {
  font-size: 0.9rem;
  color: #6c757d;
  margin-top: 0.5rem;
}

/* Dashboard Grid */
.dashboard-grid {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 1.5rem;
}

.dashboard-card {
  background: white;
  border-radius: 16px;
  padding: 1.5rem;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.card-header h2 {
  margin: 0;
  font-size: 1.2rem;
  color: #2c3e50;
  font-weight: 600;
}

/* Appointments Section */
.appointment-filters {
  display: flex;
  gap: 0.5rem;
}

.filter-btn {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 8px;
  background: #f8f9fa;
  color: #6c757d;
  font-size: 0.9rem;
  cursor: pointer;
  transition: all 0.3s;
}

.filter-btn:hover {
  background: #e9ecef;
}

.filter-btn.active {
  background: #0d6efd;
  color: white;
}

.appointments-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.appointment-item {
  display: flex;
  align-items: center;
  gap: 1.5rem;
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 12px;
  transition: background-color 0.3s;
}

.appointment-item:hover {
  background: #e9ecef;
}

.appointment-time {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: #6c757d;
  font-weight: 500;
  min-width: 100px;
}

.patient-info {
  display: flex;
  align-items: center;
  gap: 1rem;
  flex: 1;
}

.patient-avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  object-fit: cover;
}

.patient-info h4 {
  margin: 0;
  color: #2c3e50;
  font-size: 1rem;
  font-weight: 600;
}

.patient-info p {
  margin: 0.2rem 0 0;
  color: #6c757d;
  font-size: 0.9rem;
}

.appointment-actions {
  display: flex;
  gap: 0.5rem;
}

.action-btn {
  width: 40px;
  height: 40px;
  border: none;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s;
}

.action-btn.video-call {
  background: #e3f2fd;
  color: #1976d2;
}

.action-btn.chat {
  background: #f3e5f5;
  color: #7b1fa2;
}

.action-btn:hover {
  transform: translateY(-2px);
}

/* Guide Section */
.guide-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.guide-item {
  display: flex;
  gap: 1rem;
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 12px;
  transition: background-color 0.3s;
}

.guide-item:hover {
  background: #e9ecef;
}

.guide-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  background: #0d6efd;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
}

.guide-content h3 {
  margin: 0 0 0.5rem;
  font-size: 1rem;
  color: #2c3e50;
  font-weight: 600;
}

.guide-content ul {
  margin: 0;
  padding-left: 1.2rem;
  color: #6c757d;
  font-size: 0.9rem;
}

.guide-content li {
  margin-bottom: 0.3rem;
}

/* Responsive Design */
@media (max-width: 1200px) {
  .dashboard-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 992px) {
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .search-box {
    width: 200px;
  }
}

@media (max-width: 768px) {
  .top-nav {
    padding: 1rem;
  }
  
  .nav-left {
    gap: 1rem;
  }
  
  .logo span {
    display: none;
  }
  
  .search-box {
    display: none;
  }
  
  .user-info {
    display: none;
  }
  
  .main-content {
    padding: 1rem;
  }
  
  .appointment-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
  }
  
  .appointment-actions {
    width: 100%;
    justify-content: flex-end;
  }
}

.dashboard-title {
  margin: 0;
  color: #2c3e50;
  font-size: 1.5rem;
  font-weight: 600;
}

/* Featured News Styles */
.featured-news {
  background: white;
  border-radius: 16px;
  padding: 1.5rem;
  margin-bottom: 2rem;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.section-header h2 {
  margin: 0;
  font-size: 1.2rem;
  color: #2c3e50;
  font-weight: 600;
}

.view-all {
  color: #0d6efd;
  text-decoration: none;
  font-size: 0.9rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  transition: color 0.3s;
}

.view-all:hover {
  color: #0a58ca;
}

.news-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.5rem;
}

.news-card {
  background: #f8f9fa;
  border-radius: 12px;
  overflow: hidden;
  transition: transform 0.3s, box-shadow 0.3s;
}

.news-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.news-image {
  position: relative;
  height: 200px;
  overflow: hidden;
}

.news-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.news-category {
  position: absolute;
  top: 1rem;
  right: 1rem;
  background: rgba(13, 110, 253, 0.9);
  color: white;
  padding: 0.3rem 0.8rem;
  border-radius: 20px;
  font-size: 0.8rem;
  text-transform: capitalize;
}

.news-content {
  padding: 1rem;
}

.news-content h3 {
  margin: 0 0 0.5rem;
  font-size: 1rem;
  color: #2c3e50;
  font-weight: 600;
  line-height: 1.4;
}

.news-content p {
  margin: 0 0 1rem;
  color: #6c757d;
  font-size: 0.9rem;
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.news-meta {
  display: flex;
  justify-content: space-between;
  color: #6c757d;
  font-size: 0.8rem;
}

.news-meta span {
  display: flex;
  align-items: center;
  gap: 0.3rem;
}

@media (max-width: 1200px) {
  .news-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .news-grid {
    grid-template-columns: 1fr;
  }
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

/* Font Awesome Spinner */
.fa-spinner {
  animation: fa-spin 1s infinite linear;
}

@keyframes fa-spin {
  100% { transform: rotate(360deg); }
}

.quick-guide-section {
  margin-top: 40px;
  margin-bottom: 40px;
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.05);
  padding: 20px;
}

.quick-guide-section h2 {
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
  background: #f8f9fa;
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

.accordion-header:hover,
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

.reviews-section {
  background: white;
  border-radius: 16px;
  padding: 1.5rem;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

.review-filters {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.reviews-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  margin-top: 1rem;
}

.review-item {
  background: #f8f9fa;
  border-radius: 12px;
  padding: 1rem;
  transition: background-color 0.3s;
}

.review-item:hover {
  background: #e9ecef;
}

.review-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 0.5rem;
}

.reviewer-info {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.reviewer-avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  object-fit: cover;
}

.reviewer-info h4 {
  margin: 0;
  color: #2c3e50;
  font-size: 1rem;
  font-weight: 600;
}

.review-rating {
  display: flex;
  gap: 0.2rem;
  margin-top: 0.3rem;
}

.review-date {
  color: #6c757d;
  font-size: 0.9rem;
}

.review-content {
  color: #2c3e50;
  font-size: 0.95rem;
  line-height: 1.5;
  margin-top: 0.5rem;
}

.no-reviews {
  text-align: center;
  padding: 2rem;
  color: #6c757d;
}

.no-reviews i {
  font-size: 2rem;
  margin-bottom: 1rem;
}

.no-reviews p {
  margin: 0;
  font-size: 1rem;
}
</style> 