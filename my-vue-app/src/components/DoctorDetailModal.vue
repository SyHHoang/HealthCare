<template>
  <div v-if="isVisible" class="modal">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">
          <i class="fas fa-user-md me-2"></i>Thông tin chi tiết bác sĩ
        </h5>
        <button type="button" class="btn-close" @click="hide"></button>
      </div>
      <div class="modal-body">
        <!-- Loading Spinner -->
        <div v-if="loading" class="text-center py-5">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Loading...</span>
          </div>
        </div>

        <!-- Error Message -->
        <div v-if="error" class="alert alert-danger" role="alert">
          <i class="fas fa-exclamation-circle me-2"></i>{{ error }}
        </div>

        <!-- Doctor Detail -->
        <div v-if="!loading && !error && doctor" class="doctor-detail">
          <!-- Doctor Image and Basic Info -->
          <div class="doctor-profile mb-4">
            <div class="doctor-avatar">
              <img
                :src="doctor.avatar || '/images/default-doctor.jpg'"
                :alt="doctor.fullName"
                class="img-fluid rounded-circle"
              />
              <div class="doctor-badge">
                <i class="fas fa-certificate"></i>
              </div>
            </div>
            <div class="doctor-info ms-4">
              <h3 class="doctor-name mb-1">{{ doctor.fullName }}</h3>
              <p class="doctor-title mb-0">{{ doctor.academicTitle || 'Bác sĩ' }}</p>
            </div>
          </div>

          <!-- Doctor Details -->
          <div class="doctor-details">
            <div class="details-section mb-4">
              <h4 class="section-title mb-3">
                <i class="fas fa-graduation-cap me-2"></i>Chuyên môn
              </h4>
              <div class="details-grid">
                <div class="detail-item">
                  <i class="fas fa-medal me-2 text-primary"></i>
                  <div>
                    <span class="label">Chuyên khoa</span>
                    <span class="value">{{ doctor.specialty || doctor.otherSpecialties }}</span>
                  </div>
                </div>
                <div class="detail-item">
                  <i class="fas fa-certificate me-2 text-primary"></i>
                  <div>
                    <span class="label">Kinh nghiệm</span>
                    <span class="value">{{ doctor.experience }} năm</span>
                  </div>
                </div>
              </div>
            </div>
            <div class="details-section">
              <h4 class="section-title mb-3">
                <i class="fas fa-calendar-alt me-2"></i>Lịch làm việc
              </h4>
              <div class="schedule-table">
                <table class="table table-bordered">
                  <thead class="table-light">
                    <tr>
                      <th>Thứ</th>
                      <th>Thời gian làm việc</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="(timeSlots, day) in doctor.schedule" :key="day">
                      <td class="fw-bold">{{ getDayName(day) }}</td>
                      <td>
                        <div v-if="timeSlots && timeSlots.length > 0">
                          <div v-for="(slot, index) in timeSlots" :key="index" class="time-slot">
                            {{ slot.startTime }} - {{ slot.endTime }}
                          </div>
                        </div>
                        <div v-else class="text-muted">
                          Nghỉ
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" @click="hide">
          <i class="fas fa-times me-2"></i>Đóng
        </button>
        <button v-if="showBookButton" type="button" class="btn btn-primary" @click="bookConsultation">
          <i class="fas fa-calendar-check me-2"></i>Đăng ký tư vấn
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue';
import { useRouter } from 'vue-router';
import axiosInstance from '../services/axiosInstance.js';  

const props = defineProps({
  doctorId: {
    type: String,
    required: true
  },
  showBookButton: {
    type: Boolean,
    default: true
  },
});
const emit = defineEmits(['bookConsultation']);
const router = useRouter();
const loading = ref(false);
const error = ref(null);
const doctor = ref(null);
const isVisible = ref(false);

const loadDoctorDetail = async () => {
  try {
    if (!props.doctorId) {
      console.error('Doctor ID is missing');
      error.value = 'Không tìm thấy thông tin bác sĩ';
      return;
    }

    loading.value = true;
    error.value = null;
    const response = await axiosInstance.get(`/api/doctors/getPublicDoctorProfile/${props.doctorId}`);
    console.log('response.data',response.data);
    console.log('response.data.data',response.data.data);
    console.log('response.data.success',response.data.success);
    if (response.data ) {
      doctor.value = response.data.data
    } 
     else {
      throw new Error('Dữ liệu bác sĩ không hợp lệ');
    }
  } catch (err) {
    console.error('Error loading doctor detail:', err);
    if (err.response?.status === 401) {
      error.value = 'Vui lòng đăng nhập để xem thông tin chi tiết';
      router.push('/login');
    } else {
      error.value = 'Không thể tải thông tin bác sĩ. Vui lòng thử lại sau.';
    }
  } finally {
    loading.value = false;
  }
};

const show = async () => {
  if (!props.doctorId) return;
  isVisible.value = true;
  await loadDoctorDetail();
};

const hide = () => {
  isVisible.value = false;
  error.value = null;
  doctor.value = null;
};

const bookConsultation = () => {
  hide();
  emit('bookConsultation', props.doctorId);
};

const getDayName = (day) => {
  const days = {
    monday: 'Thứ 2',
    tuesday: 'Thứ 3',
    wednesday: 'Thứ 4',
    thursday: 'Thứ 5',
    friday: 'Thứ 6',
    saturday: 'Thứ 7',
    sunday: 'Chủ nhật'
  };
  return days[day] || day;
};

defineExpose({
  show,
  hide
});
</script>

<style scoped>
.modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  position: relative;
  background: white;
  padding: 20px;
  border-radius: 10px;
  width: 90%;
  max-width: 800px;
  max-height: 90vh;
  overflow-y: auto;
  margin: auto;
  animation: modalFadeIn 0.3s ease;
}

@keyframes modalFadeIn {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 1px solid #dee2e6;
}

.modal-title {
  margin: 0;
  font-size: 1.25rem;
  color: #333;
}

.modal-body {
  margin-bottom: 20px;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  padding-top: 15px;
  border-top: 1px solid #dee2e6;
}

.doctor-profile {
  display: flex;
  align-items: center;
}

.doctor-avatar {
  position: relative;
  width: 120px;
  height: 120px;
  flex-shrink: 0;
}

.doctor-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border: 3px solid #fff;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.doctor-badge {
  position: absolute;
  bottom: 0;
  right: 0;
  background: #28a745;
  color: white;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid #fff;
}

.doctor-name {
  font-size: 1.5rem;
  color: #2c3e50;
  margin: 0;
}

.doctor-title {
  font-size: 1rem;
  color: #6c757d;
  font-style: italic;
}

.doctor-specialty,
.doctor-experience {
  color: #6c757d;
  display: flex;
  align-items: center;
}

.section-title {
  color: #2c3e50;
  font-size: 1.2rem;
  border-bottom: 2px solid #e9ecef;
  padding-bottom: 0.5rem;
}

.details-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
}

.detail-item {
  display: flex;
  align-items: flex-start;
  padding: 0.5rem;
  background: #f8f9fa;
  border-radius: 0.5rem;
}

.detail-item i {
  margin-top: 3px;
}

.detail-item div {
  display: flex;
  flex-direction: column;
}

.label {
  font-size: 0.875rem;
  color: #6c757d;
  margin-bottom: 0.25rem;
}

.value {
  color: #2c3e50;
  font-weight: 500;
}

.bio-content {
  background: #f8f9fa;
  padding: 1rem;
  border-radius: 0.5rem;
  color: #2c3e50;
}

.schedule-table {
  background: #fff;
  border-radius: 0.5rem;
  overflow: hidden;
}

.table {
  margin-bottom: 0;
}

.table th {
  background: #f8f9fa;
  font-weight: 600;
}

.table td {
  vertical-align: middle;
}

.text-muted {
  color: #6c757d;
  font-style: italic;
}

.time-slot {
  background: #e3f2fd;
  padding: 6px 12px;
  border-radius: 4px;
  margin-bottom: 4px;
  font-size: 0.9rem;
}

.time-slot:last-child {
  margin-bottom: 0;
}

@media (max-width: 768px) {
  .modal-content {
    width: 95%;
    margin: 10px auto;
    max-height: calc(100vh - 20px);
  }
}
</style> 