<template>
  <div class="dashboard-container">
    <!-- Sidebar -->
    <div class="sidebar">
      <div class="sidebar-header">
        <img src="/images/logo.png" alt="Logo" class="logo">
        <h2>Doctor Portal</h2>
      </div>
      <nav class="sidebar-nav">
        <router-link to="/doctor/dashboard" class="nav-item active">
          <i class="fas fa-home"></i>
          <span>Tổng quan</span>
        </router-link>
        <router-link to="/doctor/appointments" class="nav-item">
          <i class="fas fa-calendar-check"></i>
          <span>Lịch hẹn</span>
        </router-link>
        <router-link to="/doctor/patients" class="nav-item">
          <i class="fas fa-users"></i>
          <span>Bệnh nhân</span>
        </router-link>
        <router-link to="/doctor/consultations" class="nav-item">
          <i class="fas fa-video"></i>
          <span>Tư vấn</span>
        </router-link>
        <router-link to="/doctor/profile" class="nav-item">
          <i class="fas fa-user-md"></i>
          <span>Hồ sơ</span>
        </router-link>
      </nav>
    </div>

    <!-- Main Content -->
    <div class="main-content">
      <!-- Header -->
      <header class="main-header">
        <div class="header-left">
          <button class="menu-toggle">
            <i class="fas fa-bars"></i>
          </button>
          <div class="date-filter">
            <i class="fas fa-calendar-alt"></i>
            <span>{{ currentDate }}</span>
          </div>
        </div>
        <div class="header-right">
          <div class="notifications">
            <i class="fas fa-bell"></i>
            <span class="badge">3</span>
          </div>
          <div class="user-menu">
            <img src="/images/doctor-avatar.jpg" alt="Doctor" class="avatar">
            <span class="user-name">Dr. Nguyễn Văn A</span>
          </div>
        </div>
      </header>

      <!-- Dashboard Content -->
      <div class="dashboard-content">
        <div class="dashboard-header">
          <h1 class="dashboard-title">Tổng quan</h1>
        </div>
        
        <!-- Thống kê tổng quan -->
        <div class="stats-grid">
          <div class="stat-card appointments-card">
            <div class="stat-overlay"></div>
            <div class="stat-icon">
              <i class="fas fa-calendar-check"></i>
            </div>
            <div class="stat-info">
              <h3>Lịch hẹn hôm nay</h3>
              <p class="stat-number">{{ todayAppointments }}</p>
              <span class="stat-change" :class="appointmentChange >= 0 ? 'positive' : 'negative'">
                {{ appointmentChange >= 0 ? '+' : '' }}{{ appointmentChange }} so với hôm qua
              </span>
            </div>
          </div>

          <div class="stat-card patients-card">
            <div class="stat-overlay"></div>
            <div class="stat-icon">
              <i class="fas fa-users"></i>
            </div>
            <div class="stat-info">
              <h3>Tổng số bệnh nhân</h3>
              <p class="stat-number">{{ totalPatients }}</p>
              <span class="stat-change" :class="patientChange >= 0 ? 'positive' : 'negative'">
                {{ patientChange >= 0 ? '+' : '' }}{{ patientChange }} tuần này
              </span>
            </div>
          </div>

          <div class="stat-card rating-card">
            <div class="stat-overlay"></div>
            <div class="stat-icon">
              <i class="fas fa-star"></i>
            </div>
            <div class="stat-info">
              <h3>Đánh giá trung bình</h3>
              <p class="stat-number">{{ averageRating }} <i class="fas fa-star rating-star"></i></p>
              <span class="stat-change" :class="ratingChange >= 0 ? 'positive' : 'negative'">
                {{ ratingChange >= 0 ? '+' : '' }}{{ ratingChange }} so với tháng trước
              </span>
            </div>
          </div>

          <div class="stat-card revenue-card">
            <div class="stat-overlay"></div>
            <div class="stat-icon">
              <i class="fas fa-money-bill-wave"></i>
            </div>
            <div class="stat-info">
              <h3>Tổng doanh thu</h3>
              <p class="stat-number">{{ formatCurrency(totalRevenue) }}</p>
              <span class="stat-change" :class="revenueChange >= 0 ? 'positive' : 'negative'">
                {{ revenueChange >= 0 ? '+' : '' }}{{ revenueChange }}% so với tháng trước
              </span>
            </div>
          </div>
        </div>

        <!-- Hướng dẫn sử dụng -->
        <div class="guide-section">
          <div class="section-header">
            <h2>Hướng dẫn sử dụng</h2>
          </div>
          <div class="accordion" id="guideAccordion">
            <div class="accordion-item" v-for="(guide, index) in guides" :key="index">
              <h2 class="accordion-header">
                <button 
                  class="accordion-button" 
                  :class="{ collapsed: activeGuide !== index }"
                  @click="toggleGuide(index)"
                >
                  <i :class="guide.icon" class="me-2"></i>
                  {{ guide.title }}
                </button>
              </h2>
              <div 
                class="accordion-collapse collapse" 
                :class="{ show: activeGuide === index }"
              >
                <div class="accordion-body">
                  <div v-html="guide.content"></div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Lịch hẹn hôm nay -->
        <div class="appointments-section">
          <div class="section-header">
            <h2>Lịch hẹn hôm nay</h2>
            <div class="appointment-filters">
              <button 
                v-for="status in appointmentStatuses" 
                :key="status.value"
                :class="['filter-btn', { active: currentFilter === status.value }]"
                @click="currentFilter = status.value"
              >
                {{ status.label }}
              </button>
            </div>
          </div>
          <div class="appointments-list">
            <div v-if="filteredAppointments.length === 0" class="no-appointments">
              <i class="fas fa-calendar-times"></i>
              <p>Không có lịch hẹn nào</p>
            </div>
            <div 
              v-else
              v-for="appointment in filteredAppointments" 
              :key="appointment.id" 
              class="appointment-item"
            >
              <div class="appointment-time">
                <i class="fas fa-clock"></i>
                <span>{{ appointment.time }}</span>
              </div>
              <div class="appointment-info">
                <div class="patient-info">
                  <img :src="appointment.patientAvatar || '/images/default-avatar.jpg'" :alt="appointment.patientName" class="patient-avatar">
                  <div>
                    <h4>{{ appointment.patientName }}</h4>
                    <p>{{ appointment.reason }}</p>
                  </div>
                </div>
              </div>
              <div class="appointment-actions">
                <button class="action-btn video-call" @click="startVideoCall(appointment.id)">
                  <i class="fas fa-video"></i>
                </button>
                <button class="action-btn chat" @click="startChat(appointment.id)">
                  <i class="fas fa-comments"></i>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();

// Data
const todayAppointments = ref(8);
const appointmentChange = ref(2);
const totalPatients = ref(156);
const patientChange = ref(5);
const averageRating = ref(4.8);
const ratingChange = ref(0.2);
const totalRevenue = ref(15000000);
const revenueChange = ref(15);
const currentFilter = ref('all');

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

const activeGuide = ref(0);

const toggleGuide = (index) => {
  activeGuide.value = activeGuide.value === index ? -1 : index;
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
</script>

<style scoped>
.dashboard-container {
  display: flex;
  min-height: 100vh;
  background-color: #f8f9fa;
}

/* Sidebar Styles */
.sidebar {
  width: 280px;
  background: white;
  box-shadow: 2px 0 5px rgba(0,0,0,0.05);
  padding: 24px;
  position: fixed;
  height: 100vh;
  z-index: 1000;
}

.sidebar-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 32px;
}

.logo {
  width: 40px;
  height: 40px;
}

.sidebar-header h2 {
  margin: 0;
  font-size: 20px;
  color: #2c3e50;
}

.sidebar-nav {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  color: #666;
  text-decoration: none;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.nav-item:hover {
  background: #f0f4f8;
  color: #0d6efd;
}

.nav-item.active {
  background: #0d6efd;
  color: white;
}

.nav-item i {
  width: 20px;
  text-align: center;
}

/* Main Content Styles */
.main-content {
  flex: 1;
  margin-left: 280px;
  padding: 24px;
}

/* Header Styles */
.main-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
  background: white;
  padding: 16px 24px;
  border-radius: 12px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.menu-toggle {
  display: none;
  background: none;
  border: none;
  font-size: 20px;
  color: #666;
  cursor: pointer;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 24px;
}

.notifications {
  position: relative;
  cursor: pointer;
}

.notifications i {
  font-size: 20px;
  color: #666;
}

.badge {
  position: absolute;
  top: -5px;
  right: -5px;
  background: #e74c3c;
  color: white;
  font-size: 12px;
  padding: 2px 6px;
  border-radius: 10px;
}

.user-menu {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
}

.avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
}

.user-name {
  font-weight: 500;
  color: #2c3e50;
}

/* Existing styles */
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
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 24px;
  margin-bottom: 32px;
}

.stat-card {
  position: relative;
  overflow: hidden;
  color: white;
  z-index: 1;
  padding: 24px;
  border-radius: 16px;
  box-shadow: 0 4px 6px rgba(0,0,0,0.05);
  display: flex;
  align-items: center;
  gap: 20px;
  transition: transform 0.3s ease;
}

.stat-overlay {
  display: none;
}

.appointments-card {
  background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
}

.patients-card {
  background: linear-gradient(135deg, #2196F3 0%, #1976D2 100%);
}

.rating-card {
  background: linear-gradient(135deg, #FF9800 0%, #F57C00 100%);
}

.revenue-card {
  background: linear-gradient(135deg, #9C27B0 0%, #7B1FA2 100%);
}

.stat-card .stat-info h3,
.stat-card .stat-number,
.stat-card .stat-change {
  color: white;
}

.stat-card .stat-icon {
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

.stat-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 15px rgba(0,0,0,0.1);
}

.stat-info h3 {
  margin: 0;
  font-size: 14px;
  color: #666;
  font-weight: 500;
}

.stat-number {
  margin: 8px 0;
  font-size: 28px;
  font-weight: 600;
  color: #2c3e50;
}

.rating-star {
  color: #ffc107;
  font-size: 20px;
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

.appointments-section {
  background: white;
  padding: 24px;
  border-radius: 16px;
  box-shadow: 0 4px 6px rgba(0,0,0,0.05);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.section-header h2 {
  margin: 0;
  color: #2c3e50;
  font-size: 20px;
  font-weight: 600;
}

.appointment-filters {
  display: flex;
  gap: 12px;
}

.filter-btn {
  padding: 8px 16px;
  border: none;
  border-radius: 8px;
  background: #f8f9fa;
  color: #666;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
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
  gap: 16px;
}

.no-appointments {
  text-align: center;
  padding: 48px 0;
  color: #666;
}

.no-appointments i {
  font-size: 48px;
  margin-bottom: 16px;
  color: #dee2e6;
}

.appointment-item {
  display: flex;
  align-items: center;
  gap: 24px;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 12px;
  transition: all 0.3s ease;
}

.appointment-item:hover {
  background: #f0f4f8;
}

.appointment-time {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #666;
  font-weight: 500;
  min-width: 100px;
}

.patient-info {
  display: flex;
  align-items: center;
  gap: 16px;
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
  font-size: 16px;
  font-weight: 600;
}

.patient-info p {
  margin: 4px 0 0;
  color: #666;
  font-size: 14px;
}

.appointment-actions {
  display: flex;
  gap: 12px;
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
  transition: all 0.3s ease;
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

.guide-section {
  background: white;
  padding: 24px;
  border-radius: 16px;
  box-shadow: 0 4px 6px rgba(0,0,0,0.05);
  margin-bottom: 32px;
}

.accordion-item {
  border: none;
  margin-bottom: 12px;
  border-radius: 8px !important;
  overflow: hidden;
}

.accordion-button {
  background: #f8f9fa;
  color: #2c3e50;
  font-weight: 500;
  padding: 16px 20px;
}

.accordion-button:not(.collapsed) {
  background: #0d6efd;
  color: white;
}

.accordion-button:focus {
  box-shadow: none;
  border-color: transparent;
}

.accordion-body {
  padding: 20px;
  background: #f8f9fa;
}

.accordion-body h5 {
  color: #2c3e50;
  margin-bottom: 16px;
}

.accordion-body ul {
  margin: 0;
  padding-left: 20px;
}

.accordion-body li {
  margin-bottom: 8px;
  color: #666;
}

/* Responsive Styles */
@media (max-width: 1024px) {
  .sidebar {
    width: 80px;
    padding: 24px 12px;
  }

  .sidebar-header h2,
  .nav-item span {
    display: none;
  }

  .main-content {
    margin-left: 80px;
  }

  .nav-item {
    justify-content: center;
    padding: 12px;
  }

  .nav-item i {
    margin: 0;
  }
}

@media (max-width: 768px) {
  .sidebar {
    transform: translateX(-100%);
    transition: transform 0.3s ease;
  }

  .sidebar.show {
    transform: translateX(0);
  }

  .menu-toggle {
    display: block;
  }

  .main-content {
    margin-left: 0;
  }

  .stats-grid {
    grid-template-columns: 1fr;
  }

  .appointment-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }

  .appointment-actions {
    width: 100%;
    justify-content: flex-end;
  }

  .section-header {
    flex-direction: column;
    gap: 16px;
    align-items: flex-start;
  }

  .appointment-filters {
    width: 100%;
    overflow-x: auto;
    padding-bottom: 8px;
  }
}
</style> 