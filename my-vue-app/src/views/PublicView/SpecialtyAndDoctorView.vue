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
                <i class="fas fa-stethoscope me-2"></i>
                Danh sách chuyên khoa
              </button>
              <button
                class="nav-link"
                :class="{ active: activeTab === 'doctors' }"
                @click="activeTab = 'doctors'"
              >
                <i class="fas fa-user-md me-2"></i>
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
                <i class="fas fa-search"></i>
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
                      <i class="fas fa-user-md me-2"></i>{{ doctor.academicTitle || 'Chưa cập nhật' }}
                    </p>
                    <p class="card-text text-muted">
                      <i class="fas fa-stethoscope me-2"></i>{{ doctor.specialty?.name || doctor.specialty || 'Chưa cập nhật' }}
                    </p>
                    <p class="card-text">
                      <i class="fas fa-briefcase me-2"></i>{{ doctor.experience || 0 }} năm kinh nghiệm
                    </p>
                    <div class="d-flex justify-content-between align-items-center">
                      <button
                        class="btn btn-outline-primary btn-sm"
                        @click="showDoctorDetail(doctor._id)"
                      >
                        Xem chi tiết
                      </button>
                      <button
                        class="btn btn-primary btn-sm"
                        @click="handleVNPayPayment"
                      >
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
    <DoctorDetailModal
      ref="doctorDetailModal"
      :doctor-id="selectedDoctorId"
      @bookConsultation="bookAppointment"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useToast } from 'primevue/usetoast';
import { specialtyService } from '@/services/specialtyService';
import { doctorService } from '@/services/doctorService';
import axios from '@/services/axiosInstance.js';
import DoctorDetailModal from '../../components/DoctorDetailModal.vue';
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
    
    // Tìm chuyên khoa hiện tại
    currentSpecialty.value = specialties.value.find(s => s._id === specialtyId) || null;
    
    const response = await specialtyService.getDoctorsBySpecialty(specialtyId);
    console.log('API Response for doctors by specialty:', response);
    
    if (Array.isArray(response)) {
      doctors.value = response;
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

const showDoctorDetail = (doctorId) => {
  selectedDoctorId.value = doctorId;
  if (doctorDetailModal.value) {
    doctorDetailModal.value.show();
  } else {
    console.error('Doctor detail modal not initialized');
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể hiển thị thông tin bác sĩ. Vui lòng thử lại sau.',
      life: 3000
    });
  }
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
//=================================================================
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

.modal-content {
  border-radius: 10px;
}

.modal-header {
  background-color: #f8f9fa;
  border-bottom: 1px solid #dee2e6;
}

.modal-title {
  color: #0d6efd;
  font-weight: 600;
}

.form-control:focus {
  border-color: #0d6efd;
  box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25);
}

.btn-primary {
  background-color: #0d6efd;
  border: none;
  padding: 10px 20px;
  font-weight: 500;
}

.btn-primary:hover {
  background-color: #0b5ed7;
}

.btn-primary:disabled {
  background-color: #6c757d;
}
</style> 