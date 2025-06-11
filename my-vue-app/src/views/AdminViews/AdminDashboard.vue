<template>
  <div class="admin-dashboard">
    <div class="container">
      <div class="dashboard-header">
        <h1>Quản Trị Hệ Thống</h1>
        <p class="text-muted">Thống kê và quản lý website</p>
      </div>

      <div class="dashboard-cards">
        <div class="card dash-card" data-aos="fade-up">
          <div class="card-body">
            <div class="stat-icon">
              <i class="bi bi-newspaper"></i>
            </div>
            <div class="stat-content">
              <h3 class="stat-title">{{ stats.totalArticles || 0 }}</h3>
              <p class="stat-desc">Bài viết</p>
            </div>
          </div>
        </div>

        <div class="card dash-card" data-aos="fade-up" data-aos-delay="100">
          <div class="card-body">
            <div class="stat-icon">
              <i class="bi bi-eye"></i>
            </div>
            <div class="stat-content">
              <h3 class="stat-title">{{ stats.totalViews || 0 }}</h3>
              <p class="stat-desc">Lượt xem</p>
            </div>
          </div>
        </div>

        <div class="card dash-card" data-aos="fade-up" data-aos-delay="200">
          <div class="card-body">
            <div class="stat-icon">
              <i class="bi bi-people"></i>
            </div>
            <div class="stat-content">
              <h3 class="stat-title">{{ userCount }}</h3>
              <p class="stat-desc">Người dùng</p>
            </div>
          </div>
        </div>

        <div class="card dash-card" data-aos="fade-up" data-aos-delay="300">
          <div class="card-body">
            <div class="stat-icon">
              <i class="bi bi-chat-dots"></i>
            </div>
            <div class="stat-content">
              <h3 class="stat-title">{{ feedbackCount }}</h3>
              <p class="stat-desc">Phản hồi</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Biểu đồ doanh thu 30 ngày gần nhất -->
      <div class="card" data-aos="fade-up" style="margin-bottom: 30px;">
        <div class="card-header">
          <h5>Doanh thu 30 ngày gần nhất</h5>
        </div>
        <div class="card-body chart-container">
          <canvas id="revenueChart" ref="revenueChart"></canvas>
        </div>
      </div>

      <div class="row dashboard-analytics">
        <!-- Biểu đồ thống kê lượt xem theo thời gian -->
        <div class="col-lg-8" data-aos="fade-up">
          <div class="card">
            <div class="card-header">
              <h5>Lượt xem theo thời gian</h5>
              <div class="chart-controls">
                <select v-model="selectedArticle" class="form-select" @change="fetchArticleStats">
                  <option value="">Tất cả bài viết</option>
                  <option v-for="article in topArticles" :key="article._id" :value="article._id">
                    {{ article.title }}
                  </option>
                </select>
              </div>
            </div>
            <div class="card-body chart-container">
              <div v-if="isLoading" class="loading-indicator">
                <div class="spinner-border text-primary" role="status">
                  <span class="visually-hidden">Đang tải...</span>
                </div>
              </div>
              <canvas id="viewsChart" ref="viewsChart"></canvas>
            </div>
          </div>
        </div>

        <!-- Thống kê lượt xem theo danh mục -->
        <div class="col-lg-4" data-aos="fade-up" data-aos-delay="100">
          <div class="card">
            <div class="card-header">
              <h5>Lượt xem theo danh mục</h5>
            </div>
            <div class="card-body chart-container">
              <div v-if="isLoading" class="loading-indicator">
                <div class="spinner-border text-primary" role="status">
                  <span class="visually-hidden">Đang tải...</span>
                </div>
              </div>
              <canvas id="categoryChart" ref="categoryChart"></canvas>
            </div>
          </div>
        </div>
      </div>

      <!-- Bài viết được xem nhiều nhất -->
      <div class="top-articles" data-aos="fade-up">
        <div class="card">
          <div class="card-header">
            <h5>Bài viết xem nhiều nhất</h5>
          </div>
          <div class="card-body">
            <div v-if="isLoading" class="loading-indicator">
              <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">Đang tải...</span>
              </div>
            </div>
            <div class="table-responsive">
              <table class="table table-hover">
                <thead>
                  <tr>
                    <th>#</th>
                    <th>Bài viết</th>
                    <th>Danh mục</th>
                    <th>Ngày đăng</th>
                    <th>Lượt xem</th>
                    <th>Thao tác</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(article, index) in topArticles" :key="article._id">
                    <td>{{ index + 1 }}</td>
                    <td>{{ article.title }}</td>
                    <td>{{ getCategoryName(article.category) }}</td>
                    <td>{{ formatDate(article.createdAt) }}</td>
                    <td>{{ article.viewCount }}</td>
                    <td>
                      <button class="btn btn-sm btn-info me-2" @click="viewArticleStats(article._id)">
                        <i class="bi bi-graph-up"></i>
                      </button>
                      <router-link :to="`/news/${article._id}`" class="btn btn-sm btn-primary" target="_blank">
                        <i class="bi bi-eye"></i>
                      </router-link>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import Chart from 'chart.js/auto'
import { dashboardService } from '@/services/dashboardService'

const router = useRouter()

// Reactive state
const isLoading = ref(true)
const stats = ref({
  totalArticles: 0,
  totalViews: 0,
  categoryStats: {}
})
const userCount = ref(0)
const feedbackCount = ref(0)
const topArticles = ref([])
const selectedArticle = ref('')
const viewsChart = ref(null)
const categoryChart = ref(null)
const revenueChart = ref(null)
const revenueStats = ref([])

const categories = [
  { value: 'health', name: 'Sức khỏe', color: '#4CAF50' },
  { value: 'lifestyle', name: 'Lối sống', color: '#2196F3' },
  { value: 'medical', name: 'Y tế', color: '#FF9800' },
  { value: 'research', name: 'Nghiên cứu', color: '#9C27B0' }
]

// Methods
const fetchStats = async () => {
  isLoading.value = true
  try {
    const response = await dashboardService.getViewStats()
    stats.value = response.data
    topArticles.value = response.data.topArticles
    
    // Vẽ biểu đồ danh mục
    renderCategoryChart()
    
    // Mặc định vẽ biểu đồ tổng quan (tất cả bài viết)
    renderViewsChart()
  } catch (error) {
    console.error('Lỗi khi lấy thống kê:', error)
    if (error.message === 'No token found') {
      router.push('/auth/login')
    }
  } finally {
    isLoading.value = false
  }
}

const fetchArticleStats = async () => {
  if (!selectedArticle.value) {
    // Nếu không chọn bài viết cụ thể, hiển thị tổng quan
    renderViewsChart()
    return
  }
  
  try {
    const response = await dashboardService.getArticleViewStats(selectedArticle.value)
    const articleStats = response.data
    renderArticleViewsChart(articleStats)
  } catch (error) {
    console.error('Lỗi khi lấy thống kê bài viết:', error)
  }
}

const fetchUserCount = async () => {
  try {
    const response = await dashboardService.getUserCount()
    userCount.value = response.data.count
  } catch (error) {
    console.error('Lỗi khi lấy số lượng người dùng:', error)
    userCount.value = 0
  }
}

const fetchFeedbackCount = async () => {
  try {
    const response = await dashboardService.getFeedbackCount()
    feedbackCount.value = response.data.count
  } catch (error) {
    console.error('Lỗi khi lấy số lượng phản hồi:', error)
    feedbackCount.value = 0
  }
}

const fetchRevenueStats = async () => {
  try {
    const response = await dashboardService.getRevenueStats()
    revenueStats.value = response.data
    renderRevenueChart()
  } catch (error) {
    console.error('Lỗi khi lấy thống kê doanh thu:', error)
  }
}

const renderCategoryChart = () => {
  // Xóa biểu đồ cũ nếu có
  if (categoryChart.value) {
    categoryChart.value.destroy()
  }
  
  const categoryData = stats.value.categoryStats
  const categories = Object.keys(categoryData)
  
  // Chuẩn bị dữ liệu
  const data = {
    labels: categories.map(category => getCategoryName(category)),
    datasets: [{
      data: categories.map(category => categoryData[category].views),
      backgroundColor: categories.map(category => getCategoryColor(category)),
      hoverOffset: 4
    }]
  }
  
  // Vẽ biểu đồ tròn
  const ctx = document.getElementById('categoryChart').getContext('2d')
  categoryChart.value = new Chart(ctx, {
    type: 'pie',
    data: data,
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          position: 'right',
          labels: {
            boxWidth: 20
          }
        },
        tooltip: {
          callbacks: {
            label: function(context) {
              const label = context.label || ''
              const value = context.parsed || 0
              const total = context.dataset.data.reduce((a, b) => a + b, 0)
              const percentage = Math.round((value / total) * 100)
              return `${label}: ${value} lượt xem (${percentage}%)`
            }
          }
        }
      }
    }
  })
}

const renderViewsChart = () => {
  // Xóa biểu đồ cũ nếu có
  if (viewsChart.value) {
    viewsChart.value.destroy()
  }
  
  // Chuẩn bị dữ liệu giả mẫu - trong thực tế cần lấy dữ liệu thực từ API
  const last7Days = Array.from({length: 7}, (_, i) => {
    const d = new Date()
    d.setDate(d.getDate() - i)
    return d.toLocaleDateString('vi-VN', {weekday: 'short', day: 'numeric', month: 'numeric'})
  }).reverse()
  
  // Tạo dữ liệu giả 
  const viewsData = Array.from({length: 7}, () => Math.floor(Math.random() * 50) + 10)
  
  const data = {
    labels: last7Days,
    datasets: [{
      label: 'Lượt xem',
      data: viewsData,
      fill: true,
      backgroundColor: 'rgba(75, 192, 192, 0.2)',
      borderColor: 'rgba(75, 192, 192, 1)',
      tension: 0.4
    }]
  }
  
  // Vẽ biểu đồ đường
  const ctx = document.getElementById('viewsChart').getContext('2d')
  viewsChart.value = new Chart(ctx, {
    type: 'line',
    data: data,
    options: {
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        y: {
          beginAtZero: true,
          ticks: {
            precision: 0
          }
        }
      },
      plugins: {
        legend: {
          display: false
        },
        tooltip: {
          mode: 'index',
          intersect: false
        }
      }
    }
  })
}

const renderArticleViewsChart = (articleStats) => {
  // Xóa biểu đồ cũ nếu có
  if (viewsChart.value) {
    viewsChart.value.destroy()
  }
  
  // Chuẩn bị dữ liệu từ viewHistory
  const historyData = articleStats.viewHistory || []
  
  // Sắp xếp theo ngày tăng dần
  historyData.sort((a, b) => new Date(a.date) - new Date(b.date))
  
  // Tối đa hiển thị 30 ngày gần nhất
  const recentData = historyData.slice(-30)
  
  const labels = recentData.map(item => 
    new Date(item.date).toLocaleDateString('vi-VN', {day: 'numeric', month: 'numeric'})
  )
  
  const counts = recentData.map(item => item.count)
  
  const data = {
    labels: labels,
    datasets: [{
      label: articleStats.title,
      data: counts,
      fill: true,
      backgroundColor: 'rgba(54, 162, 235, 0.2)',
      borderColor: 'rgba(54, 162, 235, 1)',
      tension: 0.4
    }]
  }
  
  // Vẽ biểu đồ đường
  const ctx = document.getElementById('viewsChart').getContext('2d')
  viewsChart.value = new Chart(ctx, {
    type: 'line',
    data: data,
    options: {
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        y: {
          beginAtZero: true,
          ticks: {
            precision: 0
          }
        }
      },
      plugins: {
        title: {
          display: true,
          text: `Thống kê lượt xem: ${articleStats.title}`,
          font: {
            size: 16
          }
        },
        tooltip: {
          mode: 'index',
          intersect: false
        }
      }
    }
  })
}

const renderRevenueChart = () => {
  if (revenueChart.value) {
    revenueChart.value.destroy()
  }
  const ctx = document.getElementById('revenueChart').getContext('2d')
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

const viewArticleStats = (articleId) => {
  selectedArticle.value = articleId
  fetchArticleStats()
}

const getCategoryName = (categoryValue) => {
  const category = categories.find(c => c.value === categoryValue)
  return category ? category.name : 'Không xác định'
}

const getCategoryColor = (categoryValue) => {
  const category = categories.find(c => c.value === categoryValue)
  return category ? category.color : '#999'
}

const formatDate = (dateString) => {
  return new Date(dateString).toLocaleDateString('vi-VN', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

// Lifecycle hooks
onMounted(() => {
  fetchStats()
  fetchUserCount()
  fetchFeedbackCount()
  fetchRevenueStats()
})
</script>

<style scoped>
.admin-dashboard {
  padding: 40px 0;
  background-color: #f8f9fa;
  min-height: 100vh;
}

.dashboard-header {
  text-align: center;
  margin-bottom: 40px;
}

.dashboard-header h1 {
  color: #333;
  font-weight: bold;
  margin-bottom: 10px;
}

.dashboard-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.dash-card {
  border-radius: 10px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  overflow: hidden;
  border: none;
}

.dash-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.15);
}

.dash-card .card-body {
  display: flex;
  align-items: center;
  padding: 25px;
}

.stat-icon {
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  margin-right: 20px;
  font-size: 24px;
  color: white;
}

.dash-card:nth-child(1) .stat-icon {
  background-color: #4CAF50;
}

.dash-card:nth-child(2) .stat-icon {
  background-color: #2196F3;
}

.dash-card:nth-child(3) .stat-icon {
  background-color: #FF9800;
}

.dash-card:nth-child(4) .stat-icon {
  background-color: #9C27B0;
}

.stat-content {
  flex: 1;
}

.stat-title {
  font-size: 30px;
  font-weight: 700;
  margin: 0;
  color: #333;
  line-height: 1.2;
}

.stat-desc {
  font-size: 14px;
  color: #757575;
  margin: 0;
}

.dashboard-analytics {
  margin-bottom: 30px;
}

.dashboard-analytics .card,
.top-articles .card {
  border-radius: 10px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
  border: none;
  margin-bottom: 30px;
}

.card-header {
  background-color: white;
  border-bottom: 1px solid #eee;
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header h5 {
  margin: 0;
  font-weight: 600;
  color: #333;
}

.chart-controls {
  width: 250px;
}

.chart-container {
  position: relative;
  height: 300px;
  padding: 20px;
}

.loading-indicator {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  justify-content: center;
  align-items: center;
  background-color: rgba(255, 255, 255, 0.8);
  z-index: 10;
}

.table {
  margin-bottom: 0;
}

.table th {
  font-weight: 600;
  background-color: #f8f9fa;
}

.table td, .table th {
  vertical-align: middle;
}

.btn-sm {
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
}

@media (max-width: 992px) {
  .dashboard-cards {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .dashboard-cards {
    grid-template-columns: 1fr;
  }
  
  .chart-controls {
    width: 100%;
    margin-top: 10px;
  }
  
  .card-header {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .card-header h5 {
    margin-bottom: 10px;
  }
}
</style> 