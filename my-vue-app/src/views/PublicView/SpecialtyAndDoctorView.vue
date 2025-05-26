<template>
  <div class="specialty-doctor-container">
    <div class="container-fluid">
      <div class="row">
        <!-- Sidebar -->
        <div class="col-md-3 sidebar">
          <div class="sidebar-content">
            <div class="nav flex-column nav-pills" role="tablist">
              <button
                class="nav-link"
                :class="{ active: activeTab === 'specialties' }"
                @click="activeTab = 'specialties'"
              >
                <i class="bi bi-heart-pulse me-2"></i>
                Danh sách chuyên khoa
              </button>
              <button
                class="nav-link"
                :class="{ active: activeTab === 'doctors' }"
                @click="activeTab = 'doctors'"
              >
                <i class="bi bi-person-badge me-2"></i>
                Danh sách bác sĩ
              </button>
            </div>
          </div>
        </div>

        <!-- Main Content -->
        <div class="col-md-9 main-content">
          <!-- Search Section -->
          <div class="search-section mb-4">
            <div class="input-group">
              <input
                type="text"
                class="form-control"
                v-model="searchQuery"
                :placeholder="activeTab === 'specialties' ? 'Tìm kiếm chuyên khoa...' : 'Tìm kiếm bác sĩ...'"
                @keyup.enter="handleSearch"
              />
              <button class="btn btn-primary" @click="handleSearch">
                <i class="bi bi-search"></i>
              </button>
            </div>
            <!-- Filter Section for Doctors -->
            <div v-if="activeTab === 'doctors'" class="filter-section mt-3">
              <div class="d-flex align-items-center gap-3">
                <select 
                  class="form-select" 
                  v-model="currentFilter"
                  @change="filterDoctors(currentFilter)"
                >
                  <option value="all">Tất cả bác sĩ</option>
                  <option 
                    v-for="specialty in specialties" 
                    :key="specialty._id"
                    :value="specialty._id"
                  >
                    {{ specialty.name }}
                  </option>
                </select>
              </div>
            </div>
          </div>

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

          <!-- Specialties Tab Content -->
          <div v-if="!loading && !error && activeTab === 'specialties'" class="tab-content">
            <h2 class="mb-4">Chuyên khoa y tế</h2>
            <div class="row g-4">
              <div
                v-for="specialty in filteredSpecialties"
                :key="specialty._id"
                class="col-md-6 col-lg-4"
              >
                <div class="card h-100 specialty-card">
                  <div class="card-body">
                    <h5 class="card-title">{{ specialty.name }}</h5>
                    <p class="card-text">{{ specialty.description }}</p>
                    <div class="d-flex justify-content-between align-items-center">
                      <span class="badge bg-primary">
                        {{ specialty.count || 0 }} bác sĩ
                      </span>
                      <button
                        class="btn btn-outline-primary btn-sm"
                        @click="viewDoctorsBySpecialty(specialty._id)"
                      >
                        <i class="bi bi-person-badge me-1"></i>
                        Xem bác sĩ
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Doctors Tab Content -->
          <div v-if="!loading && !error && activeTab === 'doctors'" class="tab-content">
            <h2 class="mb-4">Danh sách bác sĩ</h2>
            <h5 class="mb-3 specialty-title">Chuyên ngành: {{ currentSpecialty?.name || 'Tất cả' }}</h5>
            <div class="row g-4">
              <div
                v-for="doctor in filteredDoctors"
                :key="doctor._id"
                class="col-md-6 col-lg-4"
              >
                <div class="card h-100 doctor-card">
                  <img
                    :src="doctor.avatar || '/images/default-doctor.jpg'"
                    class="card-img-top doctor-image"
                    :alt="doctor.fullName || doctor.name"
                  />
                  <div class="card-body">
                    <h5 class="card-title">{{ doctor.fullName || doctor.name }}</h5>
                    <p class="card-text text-muted">
                      <i class="bi bi-person-badge me-2"></i>{{ doctor.academicTitle || 'Chưa cập nhật' }}
                    </p>
                    <p class="card-text text-muted">
                      <i class="bi bi-heart-pulse me-2"></i>{{ doctor.specialty?.name || doctor.specialty || 'Chưa cập nhật' }}
                    </p>
                    <p class="card-text">
  <i class="bi bi-briefcase me-2"></i>{{ doctor.experience || 0 }} năm kinh nghiệm
</p>
<p class="card-text">
  <i class="bi bi-star-half me-2"></i>
  Đánh giá: 
  <span v-if="doctor.ratingStats">
    {{ doctor.ratingStats.averageRating.toFixed(1) }} / 5
    <small class="text-muted">({{ doctor.ratingStats.totalReviews }} đánh giá)</small>
  </span>
  <span v-else>
    Chưa có đánh giá
  </span>
</p>

                    <div class="d-flex justify-content-between align-items-center">
                      <button
                        class="btn btn-outline-primary btn-sm"
                        @click="showDoctorDetail(doctor._id)"
                      >
                        <i class="bi bi-info-circle me-1"></i>
                        Xem chi tiết
                      </button>
                      <button
                        class="btn btn-primary btn-sm"
                        @click="handleVNPayPayment"
                      >
                        <i class="bi bi-currency-exchange me-1"></i>
                        Đăng ký tư vấn
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- No Results Message -->
          <div
            v-if="!loading && !error && 
              ((activeTab === 'specialties' && filteredSpecialties.length === 0) || 
               (activeTab === 'doctors' && filteredDoctors.length === 0))"
            class="text-center py-5"
          >
            <h3>Không tìm thấy kết quả</h3>
            <p class="text-muted">Vui lòng thử tìm kiếm với từ khóa khác</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Doctor Detail Modal -->
    <div v-if="showDoctorModal" class="modal">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">
            <i class="fas fa-user-md me-2"></i>Thông tin chi tiết bác sĩ
          </h5>
          <button type="button" class="btn-close" @click="closeDoctorModal"></button>
        </div>
        <div class="modal-body">
          <!-- Loading Spinner -->
          <div v-if="loadingDoctor" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Loading...</span>
            </div>
          </div>

          <!-- Error Message -->
          <div v-if="doctorError" class="alert alert-danger" role="alert">
            <i class="fas fa-exclamation-circle me-2"></i>{{ doctorError }}
          </div>

          <!-- Doctor Detail -->
          <div v-if="!loadingDoctor && !doctorError && selectedDoctor" class="doctor-detail">
            <!-- Doctor Image and Basic Info -->
            <div class="doctor-profile mb-4">
              <div class="doctor-avatar">
                <img
                  :src="selectedDoctor.avatar || '/images/default-doctor.jpg'"
                  :alt="selectedDoctor.fullName"
                  class="img-fluid rounded-circle"
                />
                <div class="doctor-badge">
                  <i class="fas fa-certificate"></i>
                </div>
              </div>
              <div class="doctor-info ms-4">
                <h3 class="doctor-name mb-1">{{ selectedDoctor.fullName }}</h3>
                <p class="doctor-title mb-0">{{ selectedDoctor.academicTitle || 'Bác sĩ' }}</p>
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
                      <span class="value">{{ selectedDoctor.specialty?.name || selectedDoctor.specialty || 'Chưa cập nhật' }}</span>
                    </div>
                  </div>
                  <div class="detail-item">
                    <i class="fas fa-certificate me-2 text-primary"></i>
                    <div>
                      <span class="label">Kinh nghiệm</span>
                      <span class="value">{{ selectedDoctor.experience || 0 }} năm</span>
                    </div>
                  </div>
                  <div class="detail-item">
                    <i class="fas fa-star me-2 text-warning"></i>
                    <div>
                      <span class="label">Đánh giá</span>
                      <span class="value">
                        {{ selectedDoctor.ratingStats?.averageRating?.toFixed(1) || '0.0' }} / 5
                        <small class="text-muted">({{ selectedDoctor.ratingStats?.totalReviews || 0 }} đánh giá)</small>
                      </span>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Rating Distribution -->
              <div class="details-section mb-4" v-if="selectedDoctor.ratingStats?.ratingDistribution">
                <h4 class="section-title mb-3">
                  <i class="fas fa-chart-bar me-2"></i>Phân bố đánh giá
                </h4>
                <div class="rating-distribution">
                  <div v-for="rating in 5" :key="rating" class="rating-bar">
                    <div class="rating-label">
                      {{ rating }} <i class="fas fa-star text-warning"></i>
                    </div>
                    <div class="progress">
                      <div 
                        class="progress-bar bg-warning" 
                        :style="{ width: calculateRatingPercentage(rating) + '%' }"
                      ></div>
                    </div>
                    <div class="rating-count">
                      {{ selectedDoctor.ratingStats.ratingDistribution[rating] || 0 }}
                    </div>
                  </div>
                </div>
              </div>

              <!-- Latest Reviews -->
              <div class="details-section" v-if="selectedDoctor.ratingStats?.latestReviews?.length">
                <h4 class="section-title mb-3">
                  <i class="fas fa-comments me-2"></i>Đánh giá gần đây
                </h4>
                <div class="reviews-list">
                  <div v-for="review in displayedReviews" :key="review._id" class="review-item">
                    <div class="review-header">
                      <div class="reviewer-info">
                        <img 
                          :src="review.user.avatar || '/images/default-avatar.jpg'" 
                          :alt="review.user.fullname"
                          class="reviewer-avatar"
                        />
                        <div class="reviewer-details">
                          <div class="reviewer-name">{{ review.user.fullname }}</div>
                          <div class="review-date">{{ formatDate(review.createdAt) }}</div>
                        </div>
                      </div>
                      <div class="review-rating">
                        <span v-for="star in 5" :key="star">
                          <i :class="star <= review.rating ? 'fas fa-star text-warning' : 'far fa-star text-warning'"></i>
                        </span>
                      </div>
                    </div>
                    <div class="review-content">
                      {{ review.content }}
                    </div>
                  </div>
                </div>
                <div class="text-center mt-3" v-if="selectedDoctor.ratingStats.latestReviews.length > 3">
                  <button 
                    class="btn btn-outline-primary" 
                    @click="toggleShowAllReviews"
                  >
                    {{ showAllReviews ? 'Ẩn bớt' : 'Xem thêm' }}
                  </button>
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
                      <tr v-for="(timeSlots, day) in selectedDoctor.schedule" :key="day">
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
          <button type="button" class="btn btn-secondary" @click="closeDoctorModal">
            <i class="fas fa-times me-2"></i>Đóng
          </button>
          <button type="button" class="btn btn-primary" @click="handleVNPayPayment">
            <i class="fas fa-calendar-check me-2"></i>Đăng ký tư vấn
          </button>
        </div>
      </div>
    </div>
    <div v-if="showDoctorModal" class="modal-backdrop"></div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useToast } from 'primevue/usetoast';
import { specialtyService } from '@/services/specialtyService';
import { doctorService } from '@/services/doctorService';
import axios from '@/services/axiosInstance.js';
import { Modal } from 'bootstrap';

const toast = useToast();
const loading = ref(false);
const error = ref(null);
const searchQuery = ref('');
const activeTab = ref('specialties');
const specialties = ref([]);
const doctors = ref([]);
const selectedDoctorId = ref('');
const doctorDetailModal = ref(null);
const currentFilter = ref('all');
const currentSpecialty = ref(null);
const consultationModal = ref(null);
const symptoms = ref('');
const consultationError = ref('');
const consultationLoading = ref(false);
const orderType=ref('');
const showDoctorModal = ref(false);
const loadingDoctor = ref(false);
const doctorError = ref(null);
const selectedDoctor = ref(null);
const showAllReviews = ref(false);

const displayedReviews = computed(() => {
  if (!selectedDoctor.value?.ratingStats?.latestReviews) return [];
  return showAllReviews.value 
    ? selectedDoctor.value.ratingStats.latestReviews 
    : selectedDoctor.value.ratingStats.latestReviews.slice(0, 3);
});

const toggleShowAllReviews = () => {
  showAllReviews.value = !showAllReviews.value;
};

const calculateRatingPercentage = (rating) => {
  if (!selectedDoctor.value?.ratingStats?.ratingDistribution || !selectedDoctor.value?.ratingStats?.totalReviews) return 0;
  const count = selectedDoctor.value.ratingStats.ratingDistribution[rating] || 0;
  return (count / selectedDoctor.value.ratingStats.totalReviews) * 100;
};

const formatDate = (dateString) => {
  const date = new Date(dateString);
  return date.toLocaleDateString('vi-VN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });
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

const loadSpecialties = async () => {
  try {
    loading.value = true;
    error.value = null;
    const response = await specialtyService.getAllSpecialties();
    specialties.value = response || [];
  } catch (err) {
    error.value = 'Không thể tải danh sách chuyên khoa. Vui lòng thử lại sau.';
    console.error('Error loading specialties:', err);
    specialties.value = [];
  } finally {
    loading.value = false;
  }
};

const loadDoctors = async () => {
  try {
    loading.value = true;
    error.value = null;
    const response = await doctorService.getAllDoctors();
    doctors.value = response?.data || response || [];
    
    // Lấy thông tin đánh giá cho từng bác sĩ
    for (let doctor of doctors.value) {
      try {
        const ratingResponse = await axios.get(`/api/reviews/doctor-statspublicpublic/${doctor._id}`);
        if (ratingResponse.data.success) {
          doctor.ratingStats = ratingResponse.data.data;
        }
      } catch (err) {
        console.error('Lỗi khi lấy thông tin đánh giá:', err);
      }
    }
    
    console.log('All doctors:', doctors.value);
  } catch (err) {
    error.value = 'Không thể tải danh sách bác sĩ. Vui lòng thử lại sau.';
    console.error('Error loading doctors:', err);
    doctors.value = [];
  } finally {
    loading.value = false;
  }
};

const GetOrrderTypeConsolutionID = async () =>{
  try{
   const resuilt=await axiosInstance.get('/api/order-types/getConsolution')
   orderType.value= resuilt?.data || ''
  }catch (err) {
    console.error('Lỗi lấy thông tin đơn hàng:', err);
    consultationError.value = 'Không thể thực hiện thanh toán. Vui lòng thử lại sau.';}
};

const handleVNPayPayment = async () => {
  try {
   const result=await axios.get('/api/consultationList/check',{
    params:{
      doctorId:selectedDoctorId.value
    }
   });
   console.log("result",result);
   if(result.data.consultation){
    consultationError.value = 'Lỗi: Bạn đã đăng ký tư vấn bác sỹ rồi';
    return;
   }
    consultationLoading.value = true;
    consultationError.value = '';
    // Kiểm tra thông tin người dùng
    const isUserInfoComplete = await checkUserInfo();
    if (!isUserInfoComplete) {
      consultationLoading.value = false;
      return;
    }
    // Tìm thông tin bác sĩ được chọn
    const selectedDoctor = doctors.value.find(doctor => doctor._id === selectedDoctorId.value);
    if (!selectedDoctor || !selectedDoctor.email) {
      toast.add({
        severity: 'error',
        summary: 'Lỗi',
        detail: 'Không tìm thấy thông tin email bác sĩ',
        life: 3000,
        Kind: "Consultation" 
      });
      return;
    }
    // Gửi yêu cầu đến API backend để tạo URL thanh toán
    const response = await axios.post('/api/vnpay/create_payment_url', {
      // Số tiền thanh toán (ví dụ: 500,000 VNĐ)
      bankCode: 'NCB',  // Mã ngân hàng nếu có
      language: 'vn',  // Ngôn ngữ
      orderType: 'consultation',
      doctorId: selectedDoctor._id,
      quantity:1
    });
    if (response.data.vnpUrl) {
      // Mở URL thanh toán trong tab mới
      window.open(response.data.vnpUrl, '_blank');
      
      // Đóng modal đăng ký tư vấn
      hideConsultationModal();
      
      toast.add({
        severity: 'info',
        summary: 'Thông báo',
        detail: 'Đã mở trang thanh toán trong tab mới',
        life: 3000,
      });
    } else {
      toast.add({
        severity: 'error',
        summary: 'Lỗi',
        detail: 'Không thể tạo URL thanh toán. Vui lòng thử lại sau.',
        life: 3000,
      });
    }
  } catch (err) {
    console.error('Lỗi thanh toán VNPay:', err);
    consultationError.value = 'Không thể thực hiện thanh toán. Vui lòng thử lại sau.';
  } finally {
    consultationLoading.value = false;
  }
};

const handleSearch = async () => {
  if (!searchQuery.value.trim()) {
    if (activeTab.value === 'specialties') {
      await loadSpecialties();
    } else {
      await loadDoctors();
    }
    return;
  }

  try {
    loading.value = true;
    error.value = null;
    
    if (activeTab.value === 'specialties') {
      // Tìm kiếm chuyên khoa
      const response = await specialtyService.searchSpecialtiesAndDoctors(searchQuery.value);
      specialties.value = response?.specialties || [];
      
      if (specialties.value.length === 0) {
        toast.add({
          severity: 'info',
          summary: 'Thông báo',
          detail: 'Không tìm thấy chuyên khoa nào phù hợp',
          life: 3000
        });
      }
    } else {
      // Tìm kiếm bác sĩ
      let response;
      
      // Nếu đang lọc theo chuyên khoa cụ thể
      if (currentFilter.value !== 'all') {
        // Lấy danh sách bác sĩ của chuyên khoa hiện tại
        const specialtyDoctors = await specialtyService.getDoctorsBySpecialty(currentFilter.value);
        
        // Lọc bác sĩ theo từ khóa tìm kiếm
        doctors.value = specialtyDoctors.filter(doctor => 
          doctor.fullName?.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
          doctor.academicTitle?.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
          doctor.specialty?.name?.toLowerCase().includes(searchQuery.value.toLowerCase())
        );
      } else {
        // Tìm kiếm tất cả bác sĩ
        response = await doctorService.searchDoctors(searchQuery.value);
        doctors.value = response?.data || response || [];
      }
      
      if (doctors.value.length === 0) {
        toast.add({
          severity: 'info',
          summary: 'Thông báo',
          detail: 'Không tìm thấy bác sĩ nào phù hợp',
          life: 3000
        });
      }
    }
  } catch (err) {
    error.value = 'Không thể tìm kiếm. Vui lòng thử lại sau.';
    console.error('Error searching:', err);
    
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể tìm kiếm. Vui lòng thử lại sau.',
      life: 3000
    });
    
    if (activeTab.value === 'specialties') {
      specialties.value = [];
    } else {
      doctors.value = [];
    }
  } finally {
    loading.value = false;
  }
};

const viewDoctorsBySpecialty = async (specialtyId) => {
  activeTab.value = 'doctors';
  try {
    loading.value = true;
    error.value = null;
    console.log('Fetching doctors for specialty ID:', specialtyId);
    
    currentSpecialty.value = specialties.value.find(s => s._id === specialtyId) || null;
    
    const response = await specialtyService.getDoctorsBySpecialty(specialtyId);
    console.log('API Response for doctors by specialty:', response);
    
    if (Array.isArray(response)) {
      doctors.value = response;
      
      // Lấy thông tin đánh giá cho từng bác sĩ
      for (let doctor of doctors.value) {
        try {
          const ratingResponse = await axios.get(`/api/reviews/doctor-stats/${doctor._id}`);
          if (ratingResponse.data.success) {
            doctor.ratingStats = ratingResponse.data.data;
          }
        } catch (err) {
          console.error('Lỗi khi lấy thông tin đánh giá:', err);
        }
      }
    } else {
      doctors.value = [];
      console.warn('Unexpected response structure:', response);
    }
    
    console.log('Processed doctors:', doctors.value);
    
    if (doctors.value.length === 0) {
      toast.add({
        severity: 'info',
        summary: 'Thông báo',
        detail: 'Không có bác sĩ nào thuộc chuyên khoa này',
        life: 3000
      });
    }
  } catch (err) {
    error.value = 'Không thể tải danh sách bác sĩ. Vui lòng thử lại sau.';
    console.error('Error loading doctors by specialty:', err);
    doctors.value = [];
    
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể tải danh sách bác sĩ. Vui lòng thử lại sau.',
      life: 3000
    });
  } finally {
    loading.value = false;
  }
};

const showDoctorDetail = async (doctorId) => {
  selectedDoctorId.value = doctorId;
  showDoctorModal.value = true;
  loadingDoctor.value = true;
  doctorError.value = null;
  showAllReviews.value = false;

  try {
    const response = await axios.get(`/api/doctors/getPublicDoctorProfile/${doctorId}`);
    if (response.data) {
      selectedDoctor.value = response.data.data;
      
      // Lấy thông tin đánh giá
      try {
        const ratingResponse = await axios.get(`/api/reviews/doctor-statspublicpublic/${doctorId}`);
        if (ratingResponse.data.success) {
          selectedDoctor.value.ratingStats = ratingResponse.data.data;
        }
      } catch (err) {
        console.error('Lỗi khi lấy thông tin đánh giá:', err);
      }
    } else {
      throw new Error('Dữ liệu bác sĩ không hợp lệ');
    }
  } catch (err) {
    console.error('Error loading doctor detail:', err);
    doctorError.value = 'Không thể tải thông tin bác sĩ. Vui lòng thử lại sau.';
  } finally {
    loadingDoctor.value = false;
  }
};

const closeDoctorModal = () => {
  showDoctorModal.value = false;
  selectedDoctor.value = null;
  doctorError.value = null;
  showAllReviews.value = false;
};

const checkUserInfo = async () => {
  try {
    const response = await axios.get('/api/users/profile');
    const user = response.data;
    
    if (!user.fullname || !user.phone || !user.email || !user.age || !user.gender) {
      consultationError.value = 'Vui lòng cập nhật đầy đủ thông tin cá nhân (Họ tên, Số điện thoại, Email, Tuổi, Giới tính) trước khi đăng ký tư vấn.';
      return false;
    }
    return true;
  } catch {
    consultationError.value = 'Không thể kiểm tra thông tin người dùng. Vui lòng thử lại sau.';
    return false;
  }
};

const submitConsultation = async () => {
  try {
    consultationLoading.value = true;
    consultationError.value = '';

    // Kiểm tra thông tin người dùng
    const isUserInfoComplete = await checkUserInfo();
    if (!isUserInfoComplete) {
      consultationLoading.value = false;
      return;
    }
  } catch (err) {
    console.error('Lỗi đăng ký tư vấn:', err);
    if (err.response?.status === 401) {
      consultationError.value = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    } else {
      consultationError.value = err.response?.data?.message || 'Đã xảy ra lỗi khi đăng ký tư vấn. Vui lòng thử lại sau.';
    }
  } finally {
    consultationLoading.value = false;
  }
};

const showConsultationModal = (doctorId) => {
  selectedDoctorId.value = doctorId;
  symptoms.value = '';
  consultationError.value = '';
  if (consultationModal.value) {
    consultationModal.value.show();
  }
};

const hideConsultationModal = () => {
  if (consultationModal.value) {
    consultationModal.value.hide();
  }
};

const bookAppointment = async (doctorId) => {
  showConsultationModal(doctorId);
};

const filterDoctors = async (filterId) => {
  currentFilter.value = filterId;
  if (filterId === 'all') {
    currentSpecialty.value = null;
    await loadDoctors();
  } else {
    await viewDoctorsBySpecialty(filterId);
  }
};

const filteredSpecialties = computed(() => {
  return specialties.value;
});

const filteredDoctors = computed(() => {
  return doctors.value;
});

onMounted(() => {
  loadSpecialties();
  loadDoctors();
  //consultationModal.value = new Modal(document.getElementById('consultationModal'));
});
</script>

<style scoped>
.specialty-doctor-container {
  min-height: 100vh;
  background-color: #f8f9fa;
  padding-top: 80px;
}

.sidebar {
  background-color: white;
  min-height: calc(100vh - 80px);
  border-right: 1px solid #dee2e6;
  padding: 20px;
}

.sidebar-content {
  position: sticky;
  top: 100px;
}

.nav-pills .nav-link {
  color: #495057;
  padding: 12px 20px;
  margin-bottom: 8px;
  border-radius: 8px;
  display: flex;
  align-items: center;
}

.nav-pills .nav-link:hover {
  background-color: #f8f9fa;
}

.nav-pills .nav-link.active {
  background-color: #0d6efd;
  color: white;
}

.main-content {
  padding: 20px;
}

.specialty-card, .doctor-card {
  transition: transform 0.3s ease;
  border: none;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.specialty-card:hover, .doctor-card:hover {
  transform: translateY(-5px);
}

.doctor-image {
  height: 200px;
  object-fit: cover;
}

.search-section {
  margin-bottom: 20px;
}

.search-section .input-group {
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.search-section .form-control {
  border-right: none;
  border-top-right-radius: 0;
  border-bottom-right-radius: 0;
}

.search-section .btn {
  border-left: none;
  border-top-left-radius: 0;
  border-bottom-left-radius: 0;
}

.filter-section {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.filter-section .form-select {
  max-width: 300px;
  border-radius: 8px;
  border: 1px solid #dee2e6;
  padding: 8px 12px;
  background-color: white;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.filter-section .form-select:focus {
  border-color: #0d6efd;
  box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25);
}

@media (max-width: 768px) {
  .sidebar {
    min-height: auto;
    border-right: none;
    border-bottom: 1px solid #dee2e6;
  }
  
  .doctor-image {
    height: 150px;
  }

  .filter-section .form-select {
    max-width: 100%;
  }
}

.specialty-title {
  font-size: 0.9rem;
  color: #6c757d;
  font-weight: 500;
}

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

.rating-distribution {
  background: #f8f9fa;
  padding: 1rem;
  border-radius: 0.5rem;
}

.rating-bar {
  display: flex;
  align-items: center;
  margin-bottom: 0.5rem;
}

.rating-label {
  width: 80px;
  font-weight: 500;
}

.progress {
  flex: 1;
  height: 8px;
  margin: 0 1rem;
  background-color: #e9ecef;
  border-radius: 4px;
  overflow: hidden;
}

.rating-count {
  width: 40px;
  text-align: right;
  color: #6c757d;
  font-size: 0.875rem;
}

.reviews-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.review-item {
  background: #f8f9fa;
  padding: 1rem;
  border-radius: 0.5rem;
}

.review-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.reviewer-info {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.reviewer-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
}

.reviewer-details {
  display: flex;
  flex-direction: column;
}

.reviewer-name {
  font-weight: 500;
  color: #2c3e50;
}

.review-date {
  font-size: 0.875rem;
  color: #6c757d;
}

.review-rating {
  display: flex;
  gap: 0.25rem;
}

.review-content {
  color: #2c3e50;
  line-height: 1.5;
  margin-top: 0.5rem;
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

.btn-outline-primary {
  border-color: #3498db;
  color: #3498db;
  transition: all 0.3s ease;
}

.btn-outline-primary:hover {
  background-color: #3498db;
  color: white;
}

.modal-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  z-index: 999;
}

@media (max-width: 768px) {
  .modal-content {
    width: 95%;
    margin: 10px auto;
    max-height: calc(100vh - 20px);
  }
  
  .doctor-profile {
    flex-direction: column;
    text-align: center;
  }
  
  .doctor-info {
    margin-left: 0;
    margin-top: 1rem;
  }
  
  .details-grid {
    grid-template-columns: 1fr;
  }
}
</style> 