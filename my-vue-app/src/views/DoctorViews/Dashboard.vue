<template>
  <div class="dashboard">
    <h1 class="dashboard-title">Tổng quan</h1>
    
    <!-- Thống kê tổng quan -->
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-icon">
          <i class="fas fa-calendar-check"></i>
        </div>
        <div class="stat-info">
          <h3>Lịch hẹn hôm nay</h3>
          <p class="stat-number">8</p>
          <span class="stat-change positive">+2 so với hôm qua</span>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon">
          <i class="fas fa-users"></i>
        </div>
        <div class="stat-info">
          <h3>Tổng số bệnh nhân</h3>
          <p class="stat-number">156</p>
          <span class="stat-change positive">+5 tuần này</span>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon">
          <i class="fas fa-prescription-bottle-alt"></i>
        </div>
        <div class="stat-info">
          <h3>Đơn thuốc đã kê</h3>
          <p class="stat-number">89</p>
          <span class="stat-change positive">+12 tháng này</span>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon">
          <i class="fas fa-clock"></i>
        </div>
        <div class="stat-info">
          <h3>Thời gian làm việc</h3>
          <p class="stat-number">6h 30m</p>
          <span class="stat-change">Còn 1h 30m</span>
        </div>
      </div>
    </div>

    <!-- Lịch hẹn hôm nay -->
    <div class="appointments-section">
      <h2>Lịch hẹn hôm nay</h2>
      <div class="appointments-list">
        <div class="appointment-item" v-for="appointment in appointments" :key="appointment.id">
          <div class="appointment-time">
            <i class="fas fa-clock"></i>
            <span>{{ appointment.time }}</span>
          </div>
          <div class="appointment-info">
            <h4>{{ appointment.patientName }}</h4>
            <p>{{ appointment.reason }}</p>
          </div>
          <div class="appointment-status" :class="appointment.status">
            {{ appointment.status }}
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'DoctorDashboard',
  data() {
    return {
      appointments: [
        {
          id: 1,
          time: '09:00',
          patientName: 'Nguyễn Văn A',
          reason: 'Khám tổng quát',
          status: 'completed'
        },
        {
          id: 2,
          time: '10:30',
          patientName: 'Trần Thị B',
          reason: 'Tái khám',
          status: 'pending'
        },
        {
          id: 3,
          time: '14:00',
          patientName: 'Lê Văn C',
          reason: 'Khám bệnh',
          status: 'upcoming'
        }
      ]
    }
  }
}
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

.stat-change {
  font-size: 12px;
}

.stat-change.positive {
  color: #2ecc71;
}

.appointments-section {
  background: white;
  padding: 20px;
  border-radius: 10px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.appointments-section h2 {
  margin-bottom: 20px;
  color: #2c3e50;
}

.appointments-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.appointment-item {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 8px;
}

.appointment-time {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #666;
}

.appointment-info {
  flex: 1;
}

.appointment-info h4 {
  margin: 0;
  color: #2c3e50;
}

.appointment-info p {
  margin: 5px 0 0;
  color: #666;
  font-size: 14px;
}

.appointment-status {
  padding: 5px 10px;
  border-radius: 15px;
  font-size: 12px;
}

.appointment-status.completed {
  background: #e8f5e9;
  color: #388e3c;
}

.appointment-status.pending {
  background: #fff3e0;
  color: #f57c00;
}

.appointment-status.upcoming {
  background: #e3f2fd;
  color: #1976d2;
}

@media (max-width: 768px) {
  .appointment-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }
}
</style> 