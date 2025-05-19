<template>
  <div class="consultation-history-container">
    <div class="container-fluid">
      <div class="row">
        <!-- Sidebar -->
        <div class="col-md-3 col-lg-2 sidebar">
          <div class="d-flex flex-column p-3">
            <h4 class="sidebar-title mb-4">Quản lý tư vấn</h4>
            <div class="nav flex-column nav-pills">
              <button 
                class="nav-link mb-2" 
                :class="{ active: activeTab === 'upcoming' }"
                @click="activeTab = 'upcoming'"
              >
                <i class="fas fa-calendar-check me-2"></i>
                Cuộc hẹn sắp tới
              </button>
              <button 
                class="nav-link mb-2" 
                :class="{ active: activeTab === 'history' }"
                @click="activeTab = 'history'"
              >
                <i class="fas fa-history me-2"></i>
                Lịch sử tư vấn
              </button>
            </div>
          </div>
      </div>

        <!-- Main Content -->
        <div class="col-md-9 col-lg-10 main-content">
          <div class="container py-4">
      <!-- Loading Spinner -->
      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border text-primary" role="status">
          <span class="visually-hidden">Loading...</span>
        </div>
      </div>

      <!-- Error Message -->
      <div v-if="error" class="alert alert-danger" role="alert">
        {{ error }}
      </div>

            <!-- Upcoming Tab Content -->
            <div v-if="!loading && !error && activeTab === 'upcoming'">
      <!-- Next Consultation -->
              <div v-if="nextConsultation" class="next-consultation mb-5">
        <h3 class="mb-4">Cuộc tư vấn sắp tới</h3>
        <div class="card">
          <div class="card-body">
            <div class="row align-items-center">
              <div class="col-md-2">
                <img 
                  :src="nextConsultation.userId.avatar || '/images/default-avatar.jpg'" 
                  class="patient-avatar rounded-circle"
                  :alt="nextConsultation.userId.fullname"
                >
              </div>
              <div class="col-md-8">
                <h5 class="card-title">{{ nextConsultation.userId.fullname }}</h5>
                <p class="card-text text-muted">
                  <i class="fas fa-user me-2"></i>
                  {{ nextConsultation.userId.gender === 'male' ? 'Nam' : 'Nữ' }}, 
                  {{ nextConsultation.userId.age }} tuổi
                </p>
                <p class="card-text">
                  <i class="fas fa-phone me-2"></i>
                  {{ nextConsultation.userId.phone }}
                </p>
                <p class="card-text">
                  <i class="fas fa-calendar-alt me-2"></i>
                  {{ formatDate(nextConsultation.consultationDate) }}
                </p>
                        <div class="countdown">
                  <span class="badge bg-primary">
                    Còn {{ formatCountdown(nextConsultation.consultationDate) }}
                  </span>
                </div>
              </div>
              <div class="col-md-2 text-end">
                <button 
                  class="btn btn-primary" 
                  @click="startVideoCall(nextConsultation._id)"
                  :disabled="!isConsultationTime(nextConsultation.consultationDate)"
                >
                  <i class="fas fa-video"></i> Gọi video
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

              <!-- Upcoming Consultations List -->
              <div v-if="upcomingConsultations.length > 0" class="upcoming-list">
                <h3 class="mb-4">Danh sách tư vấn sắp tới</h3>
        <div class="row g-4">
          <div v-for="consultation in upcomingConsultations" :key="consultation._id" class="col-md-6">
            <div class="card h-100">
              <div class="card-body">
                <div class="row align-items-center">
                  <div class="col-md-3">
                    <img 
                      :src="consultation.userId.avatar || '/images/default-avatar.jpg'" 
                      class="patient-avatar rounded-circle"
                      :alt="consultation.userId.fullname"
                    >
                  </div>
                  <div class="col-md-9">
                    <h5 class="card-title">{{ consultation.userId.fullname }}</h5>
                    <p class="card-text text-muted">
                      <i class="fas fa-user me-2"></i>
                      {{ consultation.userId.gender === 'male' ? 'Nam' : 'Nữ' }}, 
                      {{ consultation.userId.age }} tuổi
                    </p>
                    <p class="card-text">
                      <i class="fas fa-phone me-2"></i>
                      {{ consultation.userId.phone }}
                    </p>
                    <p class="card-text">
                      <i class="fas fa-calendar-alt me-2"></i>
                      {{ formatDate(consultation.consultationDate) }}
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
              <div v-if="!nextConsultation && upcomingConsultations.length === 0" 
           class="text-center py-5">
                <h3>Bạn chưa có cuộc tư vấn nào sắp tới</h3>
        <p class="text-muted">Chưa có bệnh nhân nào đặt lịch tư vấn với bạn</p>
      </div>
    </div>

            <!-- History Tab Content -->
            <div v-if="!loading && !error && activeTab === 'history'">
              <h3 class="mb-4">Lịch sử tư vấn</h3>
              <div v-if="pastConsultations.length === 0" class="text-center py-5">
              <p class="text-muted">Chưa có cuộc tư vấn nào đã hoàn thành</p>
            </div>
            <div v-else class="row g-4">
              <div v-for="consultation in pastConsultations" :key="consultation._id" class="col-md-6">
                <div class="card h-100">
                  <div class="card-body">
                    <div class="row align-items-center">
                      <div class="col-md-3">
                        <img 
                          :src="consultation.userId.avatar || '/images/default-avatar.jpg'" 
                          class="patient-avatar rounded-circle"
                          :alt="consultation.userId.fullname"
                        >
                      </div>
                      <div class="col-md-9">
                        <h5 class="card-title">{{ consultation.userId.fullname }}</h5>
                        <p class="card-text text-muted">
                          <i class="fas fa-user me-2"></i>
                          {{ consultation.userId.gender === 'male' ? 'Nam' : 'Nữ' }}, 
                          {{ consultation.userId.age }} tuổi
                        </p>
                        <p class="card-text">
                          <i class="fas fa-phone me-2"></i>
                          {{ consultation.userId.phone }}
                        </p>
                        <p class="card-text">
                          <i class="fas fa-calendar-alt me-2"></i>
                          {{ formatDate(consultation.consultationDate) }}
                        </p>
                          <p class="card-text">
                            <i class="fas fa-clock me-2"></i>
                            Ngày tạo: {{ formatDate(consultation.createdAt) }}
                          </p>
                        </div>
                      </div>
                    </div>
                  </div>
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
import { ref, onMounted } from 'vue';
import { useToast } from 'primevue/usetoast';
import axios from '@/services/axiosInstance.js';
import { useRouter } from 'vue-router';

const toast = useToast();
const router = useRouter();
const loading = ref(false);
const error = ref(null);
const nextConsultation = ref(null);
const upcomingConsultations = ref([]);
const pastConsultations = ref([]);
const activeTab = ref('upcoming');

const loadConsultationHistory = async () => {
  try {
    loading.value = true;
    error.value = null;
    
    const response = await axios.get('/api/consultationList/doctor/history');
    
    if (response.data && response.data.success) {
      nextConsultation.value = response.data.data.nextConsultation;
      upcomingConsultations.value = response.data.data.upcomingConsultations;
      pastConsultations.value = response.data.data.pastConsultations;
    }
  } catch (err) {
    console.error('Error loading consultation history:', err);
    if (err.response?.status === 401) {
      error.value = 'Vui lòng đăng nhập để xem lịch sử tư vấn';
    } else {
      error.value = 'Không thể tải lịch sử tư vấn. Vui lòng thử lại sau.';
    }
  } finally {
    loading.value = false;
  }
};

const formatDate = (dateString) => {
  if (!dateString) return '';
  const date = new Date(dateString);
  return date.toLocaleString('vi-VN', {
    hour: '2-digit',
    minute: '2-digit',
    day: '2-digit',
    month: '2-digit',
    year: 'numeric'
  });
};

const formatCountdown = (dateString) => {
  const now = new Date();
  const target = new Date(dateString);
  const diff = target - now;

  if (diff <= 0) return 'Đã đến giờ';

  const days = Math.floor(diff / (1000 * 60 * 60 * 24));
  const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
  const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));

  let result = '';
  if (days > 0) result += `${days} ngày `;
  if (hours > 0) result += `${hours} giờ `;
  if (minutes > 0) result += `${minutes} phút`;

  return result.trim();
};

const isConsultationTime = (consultationDate) => {
  const now = new Date();
  const consultationTime = new Date(consultationDate);
  const timeDiff = consultationTime - now;
  return Math.abs(timeDiff) <= 15 * 60 * 1000;
};

const startVideoCall = (consultationId) => {
  router.push({
    name: 'video-call',
    params: { consultationId },
    query: { isDoctor: 'true' }
  });
};

onMounted(() => {
  loadConsultationHistory();
});
</script>

<style scoped>
.consultation-history-container {
  padding-top: 80px;
  background-color: #f8f9fa;
  min-height: 100vh;
}

.sidebar {
  background-color: white;
  border-right: 1px solid #dee2e6;
  min-height: calc(100vh - 80px);
  position: fixed;
  top: 80px;
  left: 0;
  width: 16.666667%;
  padding: 20px;
  z-index: 100;
}

.sidebar-title {
  color: #0d6efd;
  font-weight: 600;
}

.nav-link {
  color: #495057;
  border-radius: 8px;
  padding: 12px 16px;
  transition: all 0.3s ease;
}

.nav-link:hover {
  background-color: #e9ecef;
}

.nav-link.active {
  background-color: #0d6efd;
  color: white;
}

.main-content {
  margin-left: 16.666667%;
  padding: 20px;
  position: relative;
  z-index: 1;
  width: 83.333333%;
}

.patient-avatar {
  width: 100px;
  height: 100px;
  object-fit: cover;
}

.card {
  border: none;
  border-radius: 10px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  background-color: white;
  margin-bottom: 20px;
}

.card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
}

.next-consultation .card {
  background-color: #e3f2fd;
}

.countdown {
  margin-top: 10px;
}

.countdown .badge {
  font-size: 1rem;
  padding: 8px 16px;
}

@media (max-width: 768px) {
  .sidebar {
    position: static;
    width: 100%;
    min-height: auto;
    border-right: none;
    border-bottom: 1px solid #dee2e6;
    padding: 15px;
  }

  .main-content {
    margin-left: 0;
    padding: 15px;
    width: 100%;
  }

  .patient-avatar {
    width: 80px;
    height: 80px;
  }
}
</style> 