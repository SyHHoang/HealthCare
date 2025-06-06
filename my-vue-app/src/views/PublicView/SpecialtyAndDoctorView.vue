<template>
  <div class="specialty-doctor-container">
    <!-- Header Section -->
    <div class="header-section">
      <div class="container">
        <h1 class="header-title">Đội ngũ bác sĩ chuyên môn</h1>
        <p class="header-subtitle">Tìm kiếm và kết nối với bác sĩ phù hợp với nhu cầu của bạn</p>
      </div>
    </div>

    <div class="container">
      <!-- Search and Filter Section -->
      <div class="search-filter-section">
        <div class="row g-3">
          <div class="col-md-8">
            <div class="search-box">
              <i class="bi bi-search search-icon"></i>
              <input
                type="text"
                class="form-control search-input"
                v-model="searchQuery"
                placeholder="Tìm kiếm bác sĩ theo tên, chuyên khoa..."
                @keyup.enter="handleSearch"
              />
            </div>
          </div>
          <div class="col-md-4">
            <select 
              class="form-select filter-select" 
              v-model="currentFilter"
              @change="filterDoctors(currentFilter)"
            >
              <option value="all">Tất cả chuyên khoa</option>
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

        <!-- Smart Search Section -->
        <div class="smart-search-section mt-4">
          <div class="smart-search-box">
            <div class="smart-search-input-wrapper">
              <input
                type="text"
                class="form-control smart-search-input"
                v-model="smartSearchQuery"
                placeholder="Tìm kiếm Chuyên khoa bác sĩ dựa vào mô tả"
                @keyup.enter="handleSmartSearch"
              />
              <button 
                class="btn btn-primary smart-search-btn"
                @click="handleSmartSearch"
              >
                <i class="bi bi-magic"></i>
                Tìm kiếm thông minh
              </button>
            </div>
            
          </div>
        </div>
      </div>

      <!-- Loading Spinner -->
      <div v-if="loading" class="loading-container">
        <div class="spinner-border text-primary" role="status">
          <span class="visually-hidden">Loading...</span>
        </div>
      </div>

      <!-- Error Message -->
      <div v-if="error" class="alert alert-danger error-message" role="alert">
        <i class="bi bi-exclamation-circle me-2"></i>
        {{ error }}
      </div>

      <!-- Doctors List -->
      <div v-if="!loading && !error" class="doctors-section">
        <div class="section-header">
          <h2 class="section-title">Danh sách bác sĩ</h2>
          <p class="section-subtitle" v-if="currentSpecialty">
            Chuyên ngành: {{ currentSpecialty.name }}
          </p>
        </div>

        <div class="row g-4">
          <div
            v-for="doctor in filteredDoctors"
            :key="doctor._id"
            class="col-md-6 col-lg-4"
          >
            <div class="doctor-card">
              <div class="doctor-image-container">
                <img
                  :src="doctor.avatar || '/images/default-doctor.jpg'"
                  class="doctor-image"
                  :alt="doctor.fullName || doctor.name"
                />
                <div class="doctor-badge" v-if="doctor.academicTitle">
                  {{ doctor.academicTitle }}
                </div>
              </div>
              <div class="doctor-info">
                <h3 class="doctor-name">{{ doctor.fullName || doctor.name }}</h3>
                <p class="doctor-specialty">
                  <i class="bi bi-heart-pulse"></i>
                  {{ doctor.specialty?.name || doctor.specialty || 'Chưa cập nhật' }}
                </p>
                <div class="doctor-stats">
                  <div class="stat-item">
                    <i class="bi bi-briefcase"></i>
                    <span>{{ doctor.experience || 0 }} năm kinh nghiệm</span>
                  </div>
                  <div class="stat-item">
                    <i class="bi bi-star-fill"></i>
                    <span v-if="doctor.ratingStats">
                      {{ doctor.ratingStats.averageRating.toFixed(1) }}
                      <small>({{ doctor.ratingStats.totalReviews }})</small>
                    </span>
                    <span v-else>Chưa có đánh giá</span>
                  </div>
                </div>
                <div class="doctor-actions">
                  <button
                    class="btn btn-outline-primary"
                    @click="showDoctorDetail(doctor._id)"
                  >
                    <i class="bi bi-info-circle"></i>
                    Xem chi tiết
                  </button>
                  <button
                    class="btn btn-primary"
                    @click="handleVNPayPayment"
                  >
                    <i class="bi bi-calendar-check"></i>
                    Đăng ký tư vấn
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- No Results Message -->
        <div
          v-if="!loading && !error && filteredDoctors.length === 0"
          class="no-results"
        >
          <i class="bi bi-search no-results-icon"></i>
          <h3>Không tìm thấy kết quả</h3>
          <p>Vui lòng thử tìm kiếm với từ khóa khác</p>
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
const activeTab = ref('doctors');
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
const smartSearchQuery = ref('');

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

const handleSmartSearch = async () => {
  if (!smartSearchQuery.value.trim()) return;
  
  try {
    loading.value = true;
    error.value = null;
    
    // Gọi API tìm kiếm thông minh
    const response = await axios.post('/api/gemini/message', {
      message: `Tìm kiếm bác sĩ phù hợp với các triệu chứng sau: ${smartSearchQuery.value}`,
      chatHistory: []
    });
    
    // Xử lý kết quả tìm kiếm
    if (response.data.response) {
      // Cập nhật danh sách bác sĩ dựa trên kết quả
      // TODO: Implement logic to filter doctors based on AI response
      console.log('Smart search response:', response.data.response);
    }
  } catch (err) {
    error.value = 'Không thể thực hiện tìm kiếm thông minh. Vui lòng thử lại sau.';
    console.error('Smart search error:', err);
  } finally {
    loading.value = false;
  }
};

const useExample = (example) => {
  smartSearchQuery.value = example;
  handleSmartSearch();
};

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
}

/* Header Styles */
.header-section {
  background: linear-gradient(135deg, #0d6efd 0%, #0a58ca 100%);
  color: white;
  padding: 60px 0;
  margin-bottom: 40px;
  text-align: center;
}

.header-title {
  font-size: 2.5rem;
  font-weight: 700;
  margin-bottom: 1rem;
}

.header-subtitle {
  font-size: 1.1rem;
  opacity: 0.9;
}

/* Search and Filter Section */
.search-filter-section {
  background: white;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  margin-bottom: 30px;
}

.search-box {
  position: relative;
}

.search-icon {
  position: absolute;
  left: 15px;
  top: 50%;
  transform: translateY(-50%);
  color: #6c757d;
  font-size: 1.1rem;
}

.search-input {
  padding-left: 45px;
  height: 48px;
  border-radius: 8px;
  border: 1px solid #dee2e6;
  font-size: 1rem;
}

.search-input:focus {
  border-color: #0d6efd;
  box-shadow: 0 0 0 0.2rem rgba(13, 110, 253, 0.15);
}

.filter-select {
  height: 48px;
  border-radius: 8px;
  border: 1px solid #dee2e6;
  font-size: 1rem;
}

/* Smart Search Styles */
.smart-search-section {
  background: #f8f9fa;
  border-radius: 12px;
  padding: 20px;
  margin-top: 20px;
}

.smart-search-box {
  background: white;
  border-radius: 8px;
  padding: 15px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.smart-search-input-wrapper {
  display: flex;
  gap: 10px;
  margin-bottom: 15px;
}

.smart-search-input {
  flex: 1;
  height: 48px;
  border-radius: 8px;
  border: 1px solid #dee2e6;
  padding: 0 15px;
  font-size: 1rem;
  background: #f8f9fa;
}

.smart-search-input:focus {
  border-color: #0d6efd;
  box-shadow: 0 0 0 0.2rem rgba(13, 110, 253, 0.15);
  background: white;
}

.smart-search-btn {
  height: 48px;
  padding: 0 20px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 500;
  background: linear-gradient(135deg, #0d6efd 0%, #0a58ca 100%);
  border: none;
  transition: transform 0.2s ease;
}

.smart-search-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(13, 110, 253, 0.2);
}

.smart-search-btn i {
  font-size: 1.1rem;
}

.smart-search-examples {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.example-tag {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px;
  background: #e9ecef;
  border-radius: 20px;
  font-size: 0.9rem;
  color: #495057;
  cursor: pointer;
  transition: all 0.2s ease;
}

.example-tag:hover {
  background: #dee2e6;
  transform: translateY(-1px);
}

.example-tag i {
  color: #0d6efd;
}

@media (max-width: 768px) {
  .smart-search-input-wrapper {
    flex-direction: column;
  }
  
  .smart-search-btn {
    width: 100%;
    justify-content: center;
  }
  
  .smart-search-examples {
    justify-content: center;
  }
}

/* Doctor Card Styles */
.doctor-card {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.doctor-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
}

.doctor-image-container {
  position: relative;
  height: 250px;
  overflow: hidden;
}

.doctor-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.doctor-card:hover .doctor-image {
  transform: scale(1.05);
}

.doctor-badge {
  position: absolute;
  top: 15px;
  right: 15px;
  background: rgba(13, 110, 253, 0.9);
  color: white;
  padding: 5px 12px;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 500;
}

.doctor-info {
  padding: 20px;
}

.doctor-name {
  font-size: 1.25rem;
  font-weight: 600;
  margin-bottom: 8px;
  color: #2c3e50;
}

.doctor-specialty {
  color: #6c757d;
  font-size: 0.95rem;
  margin-bottom: 15px;
}

.doctor-specialty i {
  color: #0d6efd;
  margin-right: 8px;
}

.doctor-stats {
  display: flex;
  gap: 15px;
  margin-bottom: 20px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 6px;
  color: #495057;
  font-size: 0.9rem;
}

.stat-item i {
  color: #0d6efd;
}

.doctor-actions {
  display: flex;
  gap: 10px;
}

.doctor-actions .btn {
  flex: 1;
  padding: 8px 15px;
  font-size: 0.9rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
}

/* Section Styles */
.section-header {
  margin-bottom: 30px;
  text-align: center;
}

.section-title {
  font-size: 2rem;
  font-weight: 700;
  color: #2c3e50;
  margin-bottom: 10px;
}

.section-subtitle {
  color: #6c757d;
  font-size: 1.1rem;
}

/* Loading and Error States */
.loading-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 200px;
}

.error-message {
  margin: 20px 0;
  padding: 15px;
  border-radius: 8px;
  display: flex;
  align-items: center;
}

/* No Results State */
.no-results {
  text-align: center;
  padding: 60px 20px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

.no-results-icon {
  font-size: 3rem;
  color: #6c757d;
  margin-bottom: 20px;
}

.no-results h3 {
  color: #2c3e50;
  margin-bottom: 10px;
}

.no-results p {
  color: #6c757d;
}

/* Responsive Adjustments */
@media (max-width: 768px) {
  .header-section {
    padding: 40px 0;
  }

  .header-title {
    font-size: 2rem;
  }

  .doctor-image-container {
    height: 200px;
  }

  .doctor-actions {
    flex-direction: column;
  }

  .doctor-actions .btn {
    width: 100%;
  }
}
</style> 