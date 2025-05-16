<template>
  <div class="dashboard">
    <h1 class="dashboard-title">Tổng quan</h1>
    
    <!-- Thống kê tổng quan -->
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-icon">
          <i class="fas fa-users"></i>
        </div>
        <div class="stat-info">
          <h3>Tổng số người dùng</h3>
          <p class="stat-number">{{ formatNumber(stats.totalUsers) }}</p>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon">
          <i class="fas fa-newspaper"></i>
        </div>
        <div class="stat-info">
          <h3>Tổng số bài viết</h3>
          <p class="stat-number">{{ formatNumber(stats.totalPosts) }}</p>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon">
          <i class="fas fa-money-bill-wave"></i>
        </div>
        <div class="stat-info">
          <h3>Tổng doanh thu</h3>
          <p class="stat-number">{{ formatCurrency(stats.totalRevenue) }}</p>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon">
          <i class="fas fa-hand-holding-usd"></i>
        </div>
        <div class="stat-info">
          <h3>Doanh thu thực tế</h3>
          <p class="stat-number">{{ formatCurrency(stats.actualRevenue) }}</p>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon">
          <i class="fas fa-user-md"></i>
        </div>
        <div class="stat-info">
          <h3>Bác sĩ đang hoạt động</h3>
          <p class="stat-number">{{ formatNumber(stats.activeDoctors) }}</p>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon">
          <i class="fas fa-user-md text-warning"></i>
        </div>
        <div class="stat-info">
          <h3>Bác sĩ chưa kích hoạt</h3>
          <p class="stat-number">{{ formatNumber(stats.inactiveDoctors) }}</p>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon">
          <i class="fas fa-comments"></i>
        </div>
        <div class="stat-info">
          <h3>Tổng số phản hồi</h3>
          <p class="stat-number">{{ formatNumber(stats.totalFeedbacks) }}</p>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon">
          <i class="fas fa-headset"></i>
        </div>
        <div class="stat-info">
          <h3>Tổng lượt tư vấn</h3>
          <p class="stat-number">{{ formatNumber(stats.totalConsultations) }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
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
  padding: 20px;
}

.dashboard-title {
  margin-bottom: 30px;
  color: #2c3e50;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  background: white;
  padding: 20px;
  border-radius: 10px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  display: flex;
  align-items: center;
  gap: 15px;
}

.stat-icon {
  width: 50px;
  height: 50px;
  background: #f0f4f8;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  color: #2c3e50;
}

.stat-info h3 {
  margin: 0;
  font-size: 14px;
  color: #666;
}

.stat-number {
  margin: 5px 0;
  font-size: 24px;
  font-weight: bold;
  color: #2c3e50;
}

@media (max-width: 768px) {
  .stats-grid {
    grid-template-columns: 1fr;
  }
}
</style> 