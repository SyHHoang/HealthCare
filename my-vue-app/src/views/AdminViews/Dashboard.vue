<template>
  <div class="dashboard">
    <div class="dashboard-header">
    <h1 class="dashboard-title">Tổng quan</h1>
      <div class="date-filter">
        <i class="fas fa-calendar-alt"></i>
        <span>{{ currentDate }}</span>
      </div>
    </div>
    
    <!-- Thống kê tổng quan -->
    <div class="stats-grid">
      <div class="stat-card users-card">
        <div class="stat-icon">
          <i class="fas fa-users"></i>
        </div>
        <div class="stat-info">
          <h3>Tổng số người dùng</h3>
          <p class="stat-number">{{ formatNumber(stats.totalUsers) }}</p>
          <span class="stat-change" :class="userChange >= 0 ? 'positive' : 'negative'">
            {{ userChange >= 0 ? '+' : '' }}{{ userChange }}% so với tháng trước
          </span>
        </div>
      </div>

      <div class="stat-card posts-card">
        <div class="stat-icon">
          <i class="fas fa-newspaper"></i>
        </div>
        <div class="stat-info">
          <h3>Tổng số bài viết</h3>
          <p class="stat-number">{{ formatNumber(stats.totalPosts) }}</p>
          <span class="stat-change" :class="postChange >= 0 ? 'positive' : 'negative'">
            {{ postChange >= 0 ? '+' : '' }}{{ postChange }}% so với tháng trước
          </span>
        </div>
      </div>

      <div class="stat-card revenue-card">
        <div class="stat-icon">
          <i class="fas fa-money-bill-wave"></i>
        </div>
        <div class="stat-info">
          <h3>Tổng doanh thu</h3>
          <p class="stat-number">{{ formatCurrency(stats.totalRevenue) }}</p>
          <span class="stat-change" :class="revenueChange >= 0 ? 'positive' : 'negative'">
            {{ revenueChange >= 0 ? '+' : '' }}{{ revenueChange }}% so với tháng trước
          </span>
        </div>
      </div>

      <div class="stat-card actual-revenue-card">
        <div class="stat-icon">
          <i class="fas fa-hand-holding-usd"></i>
        </div>
        <div class="stat-info">
          <h3>Doanh thu thực tế</h3>
          <p class="stat-number">{{ formatCurrency(stats.actualRevenue) }}</p>
          <span class="stat-change" :class="actualRevenueChange >= 0 ? 'positive' : 'negative'">
            {{ actualRevenueChange >= 0 ? '+' : '' }}{{ actualRevenueChange }}% so với tháng trước
          </span>
        </div>
      </div>

      <div class="stat-card active-doctors-card">
        <div class="stat-icon">
          <i class="fas fa-user-md"></i>
        </div>
        <div class="stat-info">
          <h3>Bác sĩ đang hoạt động</h3>
          <p class="stat-number">{{ formatNumber(stats.activeDoctors) }}</p>
          <span class="stat-change" :class="activeDoctorsChange >= 0 ? 'positive' : 'negative'">
            {{ activeDoctorsChange >= 0 ? '+' : '' }}{{ activeDoctorsChange }}% so với tháng trước
          </span>
        </div>
      </div>

      <div class="stat-card inactive-doctors-card">
        <div class="stat-icon">
          <i class="fas fa-user-md"></i>
        </div>
        <div class="stat-info">
          <h3>Bác sĩ chưa kích hoạt</h3>
          <p class="stat-number">{{ formatNumber(stats.inactiveDoctors) }}</p>
          <span class="stat-change" :class="inactiveDoctorsChange >= 0 ? 'positive' : 'negative'">
            {{ inactiveDoctorsChange >= 0 ? '+' : '' }}{{ inactiveDoctorsChange }}% so với tháng trước
          </span>
        </div>
      </div>

      <div class="stat-card feedbacks-card">
        <div class="stat-icon">
          <i class="fas fa-comments"></i>
        </div>
        <div class="stat-info">
          <h3>Tổng số phản hồi</h3>
          <p class="stat-number">{{ formatNumber(stats.totalFeedbacks) }}</p>
          <span class="stat-change" :class="feedbackChange >= 0 ? 'positive' : 'negative'">
            {{ feedbackChange >= 0 ? '+' : '' }}{{ feedbackChange }}% so với tháng trước
          </span>
        </div>
      </div>

      <div class="stat-card consultations-card">
        <div class="stat-icon">
          <i class="fas fa-headset"></i>
        </div>
        <div class="stat-info">
          <h3>Tổng lượt tư vấn</h3>
          <p class="stat-number">{{ formatNumber(stats.totalConsultations) }}</p>
          <span class="stat-change" :class="consultationChange >= 0 ? 'positive' : 'negative'">
            {{ consultationChange >= 0 ? '+' : '' }}{{ consultationChange }}% so với tháng trước
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { dashboardService } from '@/services/dashboardService'

// Định dạng số
const formatNumber = (number) => {
  return new Intl.NumberFormat('vi-VN').format(number)
}

// Định dạng tiền tệ
const formatCurrency = (amount) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND'
  }).format(amount)
}

// Ngày hiện tại
const currentDate = computed(() => {
  return new Date().toLocaleDateString('vi-VN', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
})

// Dữ liệu thống kê
const stats = ref({
  totalUsers: 0,
  totalPosts: 0,
  totalRevenue: 0,
  actualRevenue: 0,
  activeDoctors: 0,
  inactiveDoctors: 0,
  totalFeedbacks: 0,
  totalConsultations: 0
})

// Thay đổi so với tháng trước
const userChange = ref(5)
const postChange = ref(12)
const revenueChange = ref(8)
const actualRevenueChange = ref(6)
const activeDoctorsChange = ref(3)
const inactiveDoctorsChange = ref(-2)
const feedbackChange = ref(15)
const consultationChange = ref(10)

// Hàm lấy dữ liệu thống kê
const fetchStats = async () => {
  try {
    const data = await dashboardService.getStats()
    stats.value = data
  } catch (error) {
    console.error('Lỗi khi lấy dữ liệu thống kê:', error)
  }
}

onMounted(() => {
  fetchStats()
})
</script>

<style scoped>
.dashboard {
  padding: 24px;
  background-color: #f8f9fa;
  min-height: 100vh;
}

.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
}

.dashboard-title {
  margin: 0;
  color: #2c3e50;
  font-size: 28px;
  font-weight: 600;
}

.date-filter {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
  color: #666;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 24px;
  margin-bottom: 32px;
}

.stat-card {
  position: relative;
  overflow: hidden;
  color: white;
  padding: 24px;
  border-radius: 16px;
  box-shadow: 0 4px 6px rgba(0,0,0,0.05);
  display: flex;
  align-items: center;
  gap: 20px;
  transition: transform 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 15px rgba(0,0,0,0.1);
}

.stat-icon {
  width: 56px;
  height: 56px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  color: white;
}

.stat-info h3 {
  margin: 0;
  font-size: 14px;
  color: rgba(255, 255, 255, 0.9);
  font-weight: 500;
}

.stat-number {
  margin: 8px 0;
  font-size: 28px;
  font-weight: 600;
  color: white;
}

.stat-change {
  font-size: 13px;
  font-weight: 500;
}

.stat-change.positive {
  color: #2ecc71;
}

.stat-change.negative {
  color: #e74c3c;
}

/* Card Background Colors */
.users-card {
  background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
}

.posts-card {
  background: linear-gradient(135deg, #2196F3 0%, #1976D2 100%);
}

.revenue-card {
  background: linear-gradient(135deg, #9C27B0 0%, #7B1FA2 100%);
}

.actual-revenue-card {
  background: linear-gradient(135deg, #FF9800 0%, #F57C00 100%);
}

.active-doctors-card {
  background: linear-gradient(135deg, #00BCD4 0%, #0097A7 100%);
}

.inactive-doctors-card {
  background: linear-gradient(135deg, #FF5722 0%, #E64A19 100%);
}

.feedbacks-card {
  background: linear-gradient(135deg, #673AB7 0%, #512DA8 100%);
}

.consultations-card {
  background: linear-gradient(135deg, #3F51B5 0%, #303F9F 100%);
}

@media (max-width: 1200px) {
  .stats-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media (max-width: 992px) {
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .dashboard {
    padding: 16px;
  }

  .dashboard-header {
    flex-direction: column;
    gap: 16px;
    align-items: flex-start;
  }

  .stats-grid {
    grid-template-columns: 1fr;
  }
}
</style> 