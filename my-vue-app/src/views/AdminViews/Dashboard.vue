<template>
  <div class="dashboard">
    <div class="dashboard-header">
      <h1 class="dashboard-title">Tổng quan</h1>
      <div class="date-filter">
        <i class="bi bi-calendar-event"></i>
        <span>{{ currentDate }}</span>
      </div>
    </div>
    
    <!-- Thống kê tổng quan -->
    <div class="stats-grid">
      <div class="stat-card users-card">
        <div class="stat-icon">
          <i class="bi bi-people-fill"></i>
        </div>
        <div class="stat-info">
          <h3>Tổng số bệnh nhân</h3>
          <p class="stat-number">{{ formatNumber(stats.totalUsers || 0) }}</p>
        </div>
      </div>

      <div class="stat-card posts-card">
        <div class="stat-icon">
          <i class="bi bi-newspaper"></i>
        </div>
        <div class="stat-info">
          <h3>Tổng số bài viết</h3>
          <p class="stat-number">{{ formatNumber(stats.totalPosts || 0) }}</p>
        </div>
      </div>

      <div class="stat-card revenue-card">
        <div class="stat-icon">
          <i class="bi bi-cash-stack"></i>
        </div>
        <div class="stat-info">
          <h3>Tổng doanh thu</h3>
          <p class="stat-number">{{ formatCurrency(stats.totalRevenue || 0) }}</p>
        </div>
      </div>

      <div class="stat-card actual-revenue-card">
        <div class="stat-icon">
          <i class="bi bi-wallet2"></i>
        </div>
        <div class="stat-info">
          <h3>Doanh thu thực tế</h3>
          <p class="stat-number">{{ formatCurrency(stats.actualRevenue || 0) }}</p>
        </div>
      </div>

      <div class="stat-card active-doctors-card">
        <div class="stat-icon">
          <i class="bi bi-person-badge"></i>
        </div>
        <div class="stat-info">
          <h3>Bác sĩ đã xác thực</h3>
          <p class="stat-number">{{ formatNumber(stats.verifiedDoctors || 0) }}</p>
          <p class="stat-subtitle">
            {{ calculatePercentage(stats.verifiedDoctors, stats.totalDoctors) }}% tổng số
          </p>
        </div>
      </div>

      <div class="stat-card inactive-doctors-card">
        <div class="stat-icon">
          <i class="bi bi-person-badge"></i>
        </div>
        <div class="stat-info">
          <h3>Bác sĩ chưa xác thực</h3>
          <p class="stat-number">{{ formatNumber(stats.unverifiedDoctors || 0) }}</p>
          <p class="stat-subtitle">
            {{ calculatePercentage(stats.unverifiedDoctors, stats.totalDoctors) }}% tổng số
          </p>
        </div>
      </div>

      <div class="stat-card feedbacks-card">
        <div class="stat-icon">
          <i class="bi bi-chat-dots"></i>
        </div>
        <div class="stat-info">
          <h3>Tổng số phản hồi</h3>
          <p class="stat-number">{{ formatNumber(stats.totalFeedbacks || 0) }}</p>
        </div>
      </div>

      <div class="stat-card consultations-card">
        <div class="stat-icon">
          <i class="bi bi-headset"></i>
        </div>
        <div class="stat-info">
          <h3>Tổng lượt tư vấn</h3>
          <p class="stat-number">{{ formatNumber(stats.totalConsultations || 0) }}</p>
        </div>
      </div>
    </div>

    <!-- Biểu đồ doanh thu 30 ngày gần nhất -->
    <div class="card" style="margin-bottom: 30px;">
      <div class="card-header">
        <h5>Doanh thu 30 ngày gần nhất</h5>
      </div>
      <div class="card-body" style="height: 320px;">
        <canvas id="revenueChart" ref="revenueChart"></canvas>
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref, onMounted, computed } from 'vue'
import Chart from 'chart.js/auto'
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
  totalFeedbacks: 0,
  totalRevenue: 0,
  actualRevenue: 0,
  verifiedDoctors: 0,
  unverifiedDoctors: 0,
  totalDoctors: 0,
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

const revenueChart = ref(null)
const revenueStats = ref([])

const fetchStats = async () => {
  try {
    const [data, totalPosts, totalFeedbacks, totalRevenue, totalConsultations] = await Promise.all([
      dashboardService.getStats(),
      dashboardService.getTotalPosts(),
      dashboardService.getTotalFeedbacks(),
      dashboardService.getTotalRevenue(),
      dashboardService.getTotalConsultations()
    ])
    if (data) {
      stats.value = {
        totalUsers: data.totalUsers || 0,
        totalPosts: totalPosts || 0,
        totalFeedbacks: totalFeedbacks || 0,
        totalRevenue: totalRevenue || 0,
        actualRevenue: Math.round((totalRevenue || 0) * 0.25),
        totalConsultations: totalConsultations || 0,
        verifiedDoctors: data.verifiedDoctors || 0,
        unverifiedDoctors: data.unverifiedDoctors || 0,
        totalDoctors: data.totalDoctors || 0
      }
    }
  } catch (error) {
    console.error('Lỗi khi lấy dữ liệu thống kê:', error)
  }
}

const fetchRevenueStats = async () => {
  try {
    const response = await dashboardService.getRevenueStats()
    if (Array.isArray(response)) {
      revenueStats.value = response
      renderRevenueChart()
    } else {
      console.error('Dữ liệu không đúng định dạng:', response)
    }
  } catch (error) {
    console.error('Lỗi khi lấy thống kê doanh thu:', error)
    revenueStats.value = []
  }
}

const renderRevenueChart = () => {
  const ctx = document.getElementById('revenueChart')
  if (!ctx) return

  // Destroy chart cũ nếu tồn tại
  if (revenueChart.value instanceof Chart) {
    revenueChart.value.destroy()
  }

  // Kiểm tra dữ liệu trước khi render
  if (!Array.isArray(revenueStats.value) || revenueStats.value.length === 0) {
    console.log('Không có dữ liệu để hiển thị biểu đồ')
    return
  }

  const labels = revenueStats.value.map(item =>
    new Date(item.date).toLocaleDateString('vi-VN', { day: 'numeric', month: 'numeric' })
  )
  const data = revenueStats.value.map(item => item.revenue)

  revenueChart.value = new Chart(ctx, {
    type: 'line',
    data: {
      labels,
      datasets: [{
        label: 'Doanh thu (VNĐ)',
        data,
        fill: true,
        backgroundColor: 'rgba(255, 193, 7, 0.2)',
        borderColor: '#FFC107',
        tension: 0.4
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        y: {
          beginAtZero: true,
          ticks: {
            callback: value => value.toLocaleString('vi-VN')
          }
        }
      },
      plugins: {
        legend: { display: false }
      }
    }
  })
}

// Hàm tính phần trăm
const calculatePercentage = (value, total) => {
  if (!total) return 0;
  return Math.round((value / total) * 100);
};

onMounted(() => {
  fetchStats()
  fetchRevenueStats()
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

.stat-subtitle {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.8);
  margin: 4px 0 0 0;
  font-weight: 500;
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