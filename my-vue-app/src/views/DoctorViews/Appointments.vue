<template>
  <div class="appointments">
    <h1 class="page-title">Quản lý lịch hẹn</h1>

    <!-- Bộ lọc -->
    <div class="filters">
      <div class="filter-group">
        <label>Từ ngày:</label>
        <input type="date" v-model="filters.startDate">
      </div>
      <div class="filter-group">
        <label>Đến ngày:</label>
        <input type="date" v-model="filters.endDate">
      </div>
      <div class="filter-group">
        <label>Trạng thái:</label>
        <select v-model="filters.status">
          <option value="">Tất cả</option>
          <option value="pending">Chờ khám</option>
          <option value="completed">Đã khám</option>
          <option value="cancelled">Đã hủy</option>
        </select>
      </div>
      <button class="search-btn" @click="searchAppointments">
        <i class="fas fa-search"></i> Tìm kiếm
      </button>
    </div>

    <!-- Danh sách lịch hẹn -->
    <div class="appointments-list">
      <div class="appointment-item" v-for="appointment in appointments" :key="appointment.id">
        <div class="appointment-header">
          <div class="patient-info">
            <img :src="appointment.patientAvatar" alt="Patient" class="patient-avatar">
            <div>
              <h3>{{ appointment.patientName }}</h3>
              <p>ID: {{ appointment.patientId }}</p>
            </div>
          </div>
          <div class="appointment-status" :class="appointment.status">
            {{ getStatusText(appointment.status) }}
          </div>
        </div>
        
        <div class="appointment-details">
          <div class="detail-item">
            <i class="fas fa-calendar"></i>
            <span>{{ appointment.date }}</span>
          </div>
          <div class="detail-item">
            <i class="fas fa-clock"></i>
            <span>{{ appointment.time }}</span>
          </div>
          <div class="detail-item">
            <i class="fas fa-stethoscope"></i>
            <span>{{ appointment.reason }}</span>
          </div>
        </div>

        <div class="appointment-actions">
          <button class="action-btn view" @click="viewAppointment(appointment)">
            <i class="fas fa-eye"></i> Xem chi tiết
          </button>
          <button class="action-btn complete" v-if="appointment.status === 'pending'" @click="completeAppointment(appointment)">
            <i class="fas fa-check"></i> Hoàn thành
          </button>
          <button class="action-btn cancel" v-if="appointment.status === 'pending'" @click="cancelAppointment(appointment)">
            <i class="fas fa-times"></i> Hủy
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'DoctorAppointments',
  data() {
    return {
      filters: {
        startDate: '',
        endDate: '',
        status: ''
      },
      appointments: [
        {
          id: 1,
          patientId: 'BN001',
          patientName: 'Nguyễn Văn A',
          patientAvatar: 'https://via.placeholder.com/40',
          date: '2024-03-20',
          time: '09:00',
          reason: 'Khám tổng quát',
          status: 'pending'
        },
        {
          id: 2,
          patientId: 'BN002',
          patientName: 'Trần Thị B',
          patientAvatar: 'https://via.placeholder.com/40',
          date: '2024-03-20',
          time: '10:30',
          reason: 'Tái khám',
          status: 'completed'
        },
        {
          id: 3,
          patientId: 'BN003',
          patientName: 'Lê Văn C',
          patientAvatar: 'https://via.placeholder.com/40',
          date: '2024-03-20',
          time: '14:00',
          reason: 'Khám bệnh',
          status: 'cancelled'
        }
      ]
    }
  },
  methods: {
    getStatusText(status) {
      const statusMap = {
        pending: 'Chờ khám',
        completed: 'Đã khám',
        cancelled: 'Đã hủy'
      }
      return statusMap[status] || status
    },
    searchAppointments() {
      // Implement search logic here
      console.log('Searching with filters:', this.filters)
    },
    viewAppointment(appointment) {
      // Implement view details logic
      console.log('Viewing appointment:', appointment)
    },
    completeAppointment(appointment) {
      // Implement complete logic
      console.log('Completing appointment:', appointment)
    },
    cancelAppointment(appointment) {
      // Implement cancel logic
      console.log('Cancelling appointment:', appointment)
    }
  }
}
</script>

<style scoped>
.appointments {
  padding: 20px;
}

.page-title {
  margin-bottom: 30px;
  color: #2c3e50;
}

.filters {
  display: flex;
  gap: 20px;
  margin-bottom: 30px;
  flex-wrap: wrap;
}

.filter-group {
  display: flex;
  align-items: center;
  gap: 10px;
}

.filter-group label {
  color: #666;
}

.filter-group input,
.filter-group select {
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.search-btn {
  padding: 8px 16px;
  background: #3498db;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
}

.search-btn:hover {
  background: #2980b9;
}

.appointments-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.appointment-item {
  background: white;
  border-radius: 10px;
  padding: 20px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.appointment-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.patient-info {
  display: flex;
  align-items: center;
  gap: 15px;
}

.patient-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
}

.patient-info h3 {
  margin: 0;
  color: #2c3e50;
}

.patient-info p {
  margin: 5px 0 0;
  color: #666;
  font-size: 14px;
}

.appointment-status {
  padding: 5px 10px;
  border-radius: 15px;
  font-size: 12px;
}

.appointment-status.pending {
  background: #fff3e0;
  color: #f57c00;
}

.appointment-status.completed {
  background: #e8f5e9;
  color: #388e3c;
}

.appointment-status.cancelled {
  background: #ffebee;
  color: #d32f2f;
}

.appointment-details {
  display: flex;
  gap: 20px;
  margin-bottom: 15px;
  flex-wrap: wrap;
}

.detail-item {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #666;
}

.detail-item i {
  color: #3498db;
}

.appointment-actions {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.action-btn {
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
}

.action-btn.view {
  background: #f0f4f8;
  color: #2c3e50;
}

.action-btn.complete {
  background: #e8f5e9;
  color: #388e3c;
}

.action-btn.cancel {
  background: #ffebee;
  color: #d32f2f;
}

.action-btn:hover {
  opacity: 0.9;
}

@media (max-width: 768px) {
  .filters {
    flex-direction: column;
  }
  
  .filter-group {
    width: 100%;
  }
  
  .appointment-details {
    flex-direction: column;
  }
  
  .appointment-actions {
    flex-direction: column;
  }
  
  .action-btn {
    width: 100%;
    justify-content: center;
  }
}
</style> 