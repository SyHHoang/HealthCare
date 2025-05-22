<template>
  <div class="consultation-list-container">
    <div class="container py-4">
      <!-- Header -->
      <div class="text-center mb-5">
        <h1 class="display-4">Danh sách Bác sĩ Tư vấn</h1>
        <p class="lead">Danh sách các bác sĩ bạn đã đăng ký tư vấn</p>
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

      <!-- Empty List Message -->
      <div v-if="!loading && !error && doctors.length === 0" class="text-center py-5">
        <h3>Bạn chưa đăng ký tư vấn với bác sĩ nào</h3>
        <p class="text-muted">Hãy tìm kiếm và đăng ký tư vấn với bác sĩ phù hợp</p>
        <router-link to="/doctors" class="btn btn-primary mt-3">
          Tìm kiếm bác sĩ
        </router-link>
      </div>

      <!-- Doctor List -->
      <div v-if="!loading && !error && doctors.length > 0" class="row g-4">
        <div v-for="doctor in doctors" :key="doctor._id" class="col-md-4">
          <div class="card h-100 doctor-card">
                  <button class="btn delete-button" @click="removeDoctor(doctor._id)">
                    <i class="bi bi-trash"></i> Xóa
                  </button>
            <img
              :src="doctor.avatar || '/images/default-doctor.jpg'"
              class="card-img-top doctor-image"
              :alt="doctor.fullName"
            />
            <div class="card-body">
              <h5 class="card-title">{{ doctor.fullName }}</h5>
              <p class="card-text text-muted">
                <i class="bi bi-briefcase me-2"></i>{{ doctor.specialty }}
              </p>
              <p class="card-text">
  <i class="bi bi-briefcase me-2"></i> Ngày bắt đầu tư vấn {{ formatDate(doctor.StartDate)}}
</p>
<p class="card-text">
  <i class="bi bi-briefcase me-2"></i> Ngày kết thúc tư vấn {{ formatDate(doctor.EndDate) }} 
</p>
<p class="card-text">
  <i class="bi bi-briefcase me-2"></i>{{ doctor.experience }} năm kinh nghiệm
</p>
<p class="card-text text-muted">
  <small>
    <i class="bi bi-calendar-plus me-2"></i>
    Đã thêm vào: {{ formatDate(doctor.addedAt) }}
  </small>
</p>
              <div class="d-flex justify-content-between align-items-center">
<div class="d-flex gap-2 justify-content-between align-items-center flex-wrap">
  <button class="btn btn-outline-primary flex-fill" @click="showDoctorDetail(doctor._id)">
    <i class="bi bi-info-circle me-1"></i> Xem chi tiết
  </button>
  <button class="btn btn-primary flex-fill" @click="showBookingModal(doctor)">
    <i class="bi bi-calendar-check me-1"></i> Đặt lịch
  </button>
  <button class="btn btn-warning flex-fill" @click="showRenewModal(doctor)">
    <i class="bi bi-arrow-repeat me-1"></i> Gia hạn
  </button>
</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
 
    
    <!-- Doctor Detail Modal -->
    <DoctorDetailModal
      ref="doctorDetailModal"
      :doctor-id="selectedDoctorId"
      :show-book-button="false"
    />

    <!-- Booking Modal -->
    <div v-if="showBooking" class="modal" @click.self="closeBookingModal">
  <div class="modal-content">
    <div class="modal-header">
      <h5 class="modal-title">
        <i class="fas fa-calendar-check me-2"></i>Đặt lịch hẹn với bác sĩ {{ selectedDoctor?.fullName }}
      </h5>
      <button type="button" class="btn-close" @click="closeBookingModal"></button>
    </div>
    <div class="modal-body">
      <!-- Hiển thị số lần tư vấn còn lại -->
      <div class="mb-4">
        <h6>Số lần tư vấn còn lại:</h6>
        <p class="text-muted">
          <i class="fas fa-phone me-2"></i>{{ selectedDoctor?.call || 0 }} lần
        </p>
        <!-- Thông báo nếu số lần tư vấn bằng 0 -->
        <p v-if="selectedDoctor?.call === 0" class="text-danger">
          <i class="fas fa-exclamation-circle me-2"></i>Bạn cần gia hạn số lần tư vấn
        </p>
      </div>

      <div class="mb-4">
        <h6>Chọn ngày tư vấn:</h6>
        <div class="date-picker-container">
          <input 
            type="date" 
            v-model="selectedDate"
            :min="formatDateForInput(selectedDoctor?.StartDate)"
            :max="formatDateForInput(selectedDoctor?.EndDate)"
            class="form-control"
            @change="loadAvailableTimeSlots"
          />
        </div>
      </div>

      <div v-if="selectedDate" class="mb-4">
        <h6>Chọn thời gian:</h6>
        <div class="time-slots">
          <template v-if="availableTimeSlots.length > 0">
            <div v-for="slot in availableTimeSlots" :key="slot.startTime" class="time-slot-item">
              <button 
                class="btn btn-outline-secondary btn-sm w-100 mb-2"
                :class="{'btn-primary': selectedTimeSlot?.startTime === slot.startTime}"
                @click="selectTimeSlot(slot)"
              >
                {{ slot.startTime }}
              </button>
            </div>
          </template>
          <div v-else class="text-muted">
            Không có lịch trống trong ngày này
          </div>
        </div>
      </div>
    </div>
    <div class="modal-footer">
      <button type="button" class="btn btn-secondary" @click="closeBookingModal">
        <i class="fas fa-times me-2"></i>Đóng
      </button>
      <button 
        v-if="selectedTimeSlot && selectedDoctor?.call > 0" 
        type="button" 
        class="btn btn-primary" 
        @click="handleBooking">
        <i class="fas fa-check me-2"></i>Xác nhận đặt lịch
      </button>
    </div>
  </div>
</div>
    <!-- Payment Modal -->
    <PaymentModal
      v-if="showPaymentModal && selectedBooking"
      :doctor-name="selectedBooking.doctorName"
      :service-duration="selectedBooking.serviceDuration"
      :booking-date="selectedBooking.date"
      :start-time="selectedBooking.startTime"
      :end-time="selectedBooking.endTime"
      :amount="selectedBooking.amount"
      :booking-id="selectedBooking._id"
      @close="showPaymentModal = false"
      @payment-success="handlePaymentSuccess"
    />
   <!-- Modal Gia hạn -->
<div v-if="showRenew && selectedDoctor" class="modal" @click.self="closeRenewModal">
  <div class="modal-content">
    <div class="modal-header">
      <h5 class="modal-title">
        <i class="fas fa-redo me-2"></i>Gia hạn tư vấn với bác sĩ {{ selectedDoctor.fullName }}
      </h5>
      <button type="button" class="btn-close" @click="closeRenewModal"></button>
    </div>
    <div class="modal-body">
      <p>Chọn phương thức gia hạn:</p>
      <div class="d-flex justify-content-around">
        <button class="btn btn-primary" @click="showAddSessionsInput = true">
          <i class="fas fa-plus-circle me-2"></i>Thêm số lượt tư vấn
        </button>
        <button class="btn btn-success" @click="addConsultationDays(selectedDoctor._id)">
          <i class="fas fa-calendar-plus me-2"></i>Thêm ngày tư vấn
        </button>
      </div>
            <!-- Hiển thị trường nhập số lượt tư vấn -->
            <div v-if="showAddSessionsInput" class="mt-4">
        <label for="sessionCount" class="form-label">Nhập số lượt tư vấn:</label>
        <input
          id="sessionCount"
          type="number"
          class="form-control"
          v-model.number="sessionCount"
          min="1"
          placeholder="Nhập số lượt tư vấn"
        />
        <button
          class="btn btn-primary mt-3 w-100"
          :disabled="sessionCount < 1"
          @click="addConsultationSessions(selectedDoctor._id, sessionCount)"
        >
          Xác nhận
        </button>
      </div>
    </div>
 
  </div>
</div> 
  </div>
  
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import { useToast } from 'primevue/usetoast';
import axios from '@/services/axiosInstance.js';
import DoctorDetailModal from '../../components/DoctorDetailModal.vue';
import PaymentModal from '../../components/PaymentModal.vue';

const router = useRouter();
const toast = useToast();
const loading = ref(false);
const error = ref(null);
const doctors = ref([]);
const selectedDoctorId = ref(null);
const selectedDoctor = ref(null);
const doctorDetailModal = ref(null);
const showBooking = ref(false);
const selectedService = ref(null);
const selectedTimeSlot = ref(null);
const selectedDate = ref(null);
const showPaymentModal = ref(false);
const selectedBooking = ref(null);
const availableTimeSlots = ref([]);
const showAddSessionsInput = ref(false); // Trạng thái hiển thị trường nhập số lượt tư vấn
const sessionCount = ref(1); // Số lượt tư vấn được chọn
const showRenew = ref(false); // Trạng thái hiển thị modal gia hạn
const showRenewModal = (doctor) => {
  selectedDoctor.value = doctor; // Lưu thông tin bác sĩ được chọn
  showRenew.value = true; // Hiển thị modal
};

const closeRenewModal = () => {
  showRenew.value = false; // Đóng modal
  selectedDoctor.value = null; // Xóa thông tin bác sĩ được chọn
};

const addConsultationSessions = async (doctorId, count) => {
  try {
    closeRenewModal();
    await handleVNPayPayment(doctorId, "AddCallVideo", count); // Gửi số lượt tư vấn
     // Đóng modal ngay sau khi xác nhận
  } catch (error) {
    console.error('Error adding consultation sessions:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể thêm số lượt tư vấn. Vui lòng thử lại sau.',
      life: 3000,
    });
  }
};

const addConsultationDays = async (doctorId) => {
  closeRenewModal();
    handleVNPayPayment(doctorId,"Extend",1);
};
const loadConsultationList = async () => {
  try {
    loading.value = true;
    error.value = null;
    
    const response = await axios.get('/api/consultationList/list');
    console.log('Consultation list response:', response); // Debug log
    
    if (response.data && response.data.success && response.data.data) {
      doctors.value = response.data.data.map(doctor => ({
        ...doctor,
        addedAt: doctor.addedAt || new Date().toISOString(),
        avatar: doctor.avatar || '/images/default-doctor.jpg',
        academicTitle: doctor.academicTitle || 'Bác sĩ',
        specialty: doctor.specialty || doctor.otherSpecialties || '',
        experience: doctor.experience || 0,
        services: doctor.services || [],
        schedule: doctor.schedule || new Map(),
        StartDate: doctor.StartDate ,
        EndDate: doctor.EndDate ,
        call: doctor.call || 0,
      }));
    } else {
      doctors.value = [];
    }


  } catch (err) {
    console.error('Error loading consultation list:', err);
    if (err.response?.status === 401) {
      error.value = 'Vui lòng đăng nhập để xem danh sách tư vấn';
      router.push('/login');
    } else {
      error.value = 'Không thể tải danh sách bác sĩ tư vấn. Vui lòng thử lại sau.';
    }
  } finally {
    loading.value = false;
  }
};

const showDoctorDetail = (doctorId) => {
  selectedDoctorId.value = doctorId;
  doctorDetailModal.value.show();
};

const removeDoctor = async (doctorId) => {
  try {
    // Hiển thị xác nhận trước khi xóa
    if (!confirm('Bạn có chắc chắn muốn xóa bác sĩ này khỏi danh sách tư vấn?')) {
      return;
    }
    
    loading.value = true;
    const response = await axios.delete(`/api/consultationList/remove/${doctorId}`);
    
    if (response.data && response.data.success) {
      toast.add({
        severity: 'success',
        summary: 'Thành công',
        detail: 'Đã xóa bác sĩ khỏi danh sách tư vấn',
        life: 3000
      });
      
      // Cập nhật lại danh sách
      await loadConsultationList();
    } else {
      throw new Error(response.data?.message || 'Không thể xóa bác sĩ');
    }
  } catch (err) {
    console.error('Error removing doctor:', err);
    if (err.response?.status === 401) {
      toast.add({
        severity: 'error',
        summary: 'Lỗi',
        detail: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại',
        life: 3000
      });
      router.push('/login');
    } else {
      toast.add({
        severity: 'error',
        summary: 'Lỗi',
        detail: err.response?.data?.message || 'Không thể xóa bác sĩ khỏi danh sách tư vấn',
        life: 3000
      });
    }
  } finally {
    loading.value = false;
  }
};
const formatDate = (dateString) => {
  const date = new Date(dateString);
  const time = date.toLocaleTimeString('vi-VN', {
    hour: '2-digit',
    minute: '2-digit'
  });
  const day = date.toLocaleDateString('vi-VN', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric'
  });
  return `${time} - ${day}`;
};

const formatDateForInput = (dateString) => {
  if (!dateString) return '';
  
  try {
    // Kiểm tra xem dateString có phải là ngày hợp lệ không
    const date = new Date(dateString);
    if (isNaN(date.getTime())) {
      console.error('Invalid date:', dateString);
      return '';
    }
    
    // Chuyển đổi thành định dạng YYYY-MM-DD
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    
    return `${year}-${month}-${day}`;
  } catch (error) {
    console.error('Error formatting date:', error);
    return '';
  }
};

const checkBookedTimes = async (doctorId, date) => {
  try {
    const response = await axios.post('/api/consultationList/check-duplicate', {
      doctorId,
      consultationDate: date
    });

    if (response.data.success) {
      return response.data.data; // Danh sách thời gian đã được đặt
    }
    return [];
  } catch (error) {
    console.error('Lỗi kiểm tra lịch đã đặt:', error);
    return [];
  }
};

const loadAvailableTimeSlots = async () => {
  if (!selectedDate.value || !selectedDoctor.value) return;
  
  try {
    // Lấy thứ trong tuần của ngày được chọn
    const date = new Date(selectedDate.value);
    if (isNaN(date.getTime())) {
      toast.add({
        severity: 'error',
        summary: 'Lỗi',
        detail: 'Ngày không hợp lệ',
        life: 3000
      });
      return;
    }
    
    // Chuyển đổi thứ từ số sang tên tiếng Việt
    const dayOfWeek = date.getDay();
    const dayNames = ['Chủ nhật', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];
    const dayName = dayNames[dayOfWeek];
    
    // Kiểm tra xem ngày được chọn có nằm trong khoảng thời gian tư vấn không
    const selectedDateObj = new Date(selectedDate.value);
    const startDate = new Date(selectedDoctor.value.StartDate);
    const endDate = new Date(selectedDoctor.value.EndDate);
    
    if (isNaN(startDate.getTime()) || isNaN(endDate.getTime())) {
      toast.add({
        severity: 'error',
        summary: 'Lỗi',
        detail: 'Thời gian tư vấn của bác sĩ không hợp lệ',
        life: 3000
      });
      return;
    }
    
    if (selectedDateObj < startDate || selectedDateObj > endDate) {
      toast.add({
        severity: 'error',
        summary: 'Lỗi',
        detail: 'Ngày được chọn không nằm trong thời gian tư vấn của bác sĩ',
        life: 3000
      });
      selectedDate.value = null;
      availableTimeSlots.value = [];
      return;
    }
    
    // Lấy danh sách thời gian làm việc của ngày đó
    const daySchedule = selectedDoctor.value.schedule[dayName] || [];
    
    // Lấy danh sách thời gian đã được đặt
    const bookedTimes = await checkBookedTimes(selectedDoctor.value._id, selectedDate.value);
    
    // Lọc ra các thời gian còn trống
    availableTimeSlots.value = daySchedule
      .filter(slot => !bookedTimes.includes(slot.startTime))
      .map(slot => ({
        startTime: slot.startTime,
        day: selectedDate.value
      }));

    // Nếu không có lịch trong ngày đó
    if (availableTimeSlots.value.length === 0) {
      toast.add({
        severity: 'info',
        summary: 'Thông báo',
        detail: `Bác sĩ không có lịch tư vấn vào ${dayName} hoặc tất cả lịch đã được đặt`,
        life: 3000
      });
    }
  } catch (error) {
    console.error('Error loading time slots:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể tải danh sách thời gian trống',
      life: 3000
    });
  }
};

const selectTimeSlot = (slot) => {
  selectedTimeSlot.value = slot;
};

const closeBookingModal = () => {
  showBooking.value = false;
  selectedDoctor.value = null;
  selectedService.value = null;
  selectedTimeSlot.value = null;
  selectedDate.value = null;
  availableTimeSlots.value = [];
};

const showBookingModal = (doctor) => {
  selectedDoctor.value = doctor;
  selectedService.value = null;
  selectedTimeSlot.value = null;
  selectedDate.value = null;
  availableTimeSlots.value = [];
  showBooking.value = true;
};

const startChat = async (doctorId) => {
  try {
    // Tạo chat mới hoặc lấy chat hiện có
    const response = await axios.post('/api/chat/create', { doctorId });
    
    // Chuyển đến trang chat với chatId
    router.push({
      path: `/chat/${response.data._id}`
    });
  } catch (err) {
    console.error('Error starting chat:', err);
    if (err.response?.status === 401) {
      toast.add({
        severity: 'error',
        summary: 'Lỗi',
        detail: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại',
        life: 3000
      });
      router.push('/login');
    } else {
      toast.add({
        severity: 'error',
        summary: 'Lỗi',
        detail: err.response?.data?.message || 'Không thể bắt đầu chat với bác sĩ',
        life: 3000
      });
    }
  }
};
const handleVNPayPayment = async (doctorid,Type,Quantity) => {
  try {
    // Gửi yêu cầu đến API backend để tạo URL thanh toán
    const response = await axios.post('/api/vnpay/create_payment_url', { // Số tiền thanh toán (ví dụ: 500,000 VNĐ)
        bankCode: 'NCB',  // Mã ngân hàng nếu có
        language: 'vn',  // Ngôn ngữ
        orderType: Type,
        quantity: Quantity,
        doctorId: doctorid,
      });
      if (response.data.vnpUrl) {
        // Mở URL thanh toán trong tab mới
        window.open(response.data.vnpUrl, '_blank');
        
        // Đóng modal đăng ký tư vấn
   
        
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
    } 
  };

const handleBooking = async () => {
  try {
    if (!selectedTimeSlot.value) {
      toast.add({
        severity: 'error',
        summary: 'Lỗi',
        detail: 'Vui lòng chọn thời gian tư vấn',
        life: 3000
      });
      return;
    }

    // Tạo ngày tư vấn từ selectedDate và selectedTimeSlot
    const [hours, minutes] = selectedTimeSlot.value.startTime.split(':');
    const consultationDate = new Date(selectedDate.value);
    consultationDate.setHours(parseInt(hours), parseInt(minutes), 0, 0);

    const response = await axios.post('/api/consultationList/book', {
      doctorId: selectedDoctor.value._id,
      consultationDate: consultationDate.toISOString()
    });

    if (response.data.success) {
      toast.add({
        severity: 'success',
        summary: 'Thành công',
        detail: 'Đã đặt lịch tư vấn thành công',
        life: 3000
      });
      closeBookingModal();
      // Cập nhật lại danh sách bác sĩ
      await loadConsultationList();
    } else {
      throw new Error(response.data.message);
    }
  } catch (err) {
    console.error('Lỗi đặt lịch:', err);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: err.response?.data?.message || 'Không thể đặt lịch tư vấn',
      life: 3000
    });
  }
};

onMounted(() => {
  loadConsultationList();
});
</script>

<style scoped>
/* Container chính */
.consultation-list-container {
  padding-top: 80px;
  background-color: #f8f9fa;
  min-height: 100vh;
}

/* Thẻ bác sĩ */
.doctor-card {
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  border: none;
  position: relative;
  border-radius: 10px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  overflow: hidden;
  background-color: #ffffff;
}

.doctor-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
}

.doctor-image {
  height: 250px;
  object-fit: cover;
  border-bottom: 2px solid #f1f1f1;
}

.card-body {
  padding: 20px;
}

.card-title {
  font-size: 1.25rem;
  font-weight: bold;
  color: #2c3e50;
}

.card-text {
  font-size: 0.95rem;
  color: #7f8c8d;
}

.btn {
  border-radius: 20px;
  font-size: 0.9rem;
  padding: 8px 16px;
}

.btn-outline-primary {
  color: #3498db;
  border-color: #3498db;
}

.btn-outline-primary:hover {
  background-color: #3498db;
  color: #ffffff;
}

.btn-primary {
  background-color: #3498db;
  border-color: #3498db;
}

.btn-primary:hover {
  background-color: #2980b9;
  border-color: #2980b9;
}

.btn-danger {
  background-color: #e74c3c;
  border-color: #e74c3c;
}

.btn-danger:hover {
  background-color: #c0392b;
  border-color: #c0392b;
}

/* Modal */
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
  background: white;
  padding: 20px;
  border-radius: 10px;
  width: 90%;
  max-width: 800px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
}

.modal-header {
  border-bottom: 1px solid #f1f1f1;
  padding-bottom: 10px;
}

.modal-title {
  font-size: 1.5rem;
  font-weight: bold;
  color: #2c3e50;
}

.modal-footer {
  border-top: 1px solid #f1f1f1;
  padding-top: 10px;
}

.btn-close {
  background-color: transparent;
  border: none;
  font-size: 1.25rem;
  color: #7f8c8d;
}

.btn-close:hover {
  color: #2c3e50;
}

/* Lịch */
.schedule-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
  margin-top: 1rem;
}

.day-slot {
  background: #f8f9fa;
  padding: 1rem;
  border-radius: 0.5rem;
  border: 1px solid #dee2e6;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.day-slot:hover {
  transform: translateY(-5px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.day-title {
  color: #2c3e50;
  font-size: 1rem;
  margin-bottom: 0.5rem;
  border-bottom: 1px solid #dee2e6;
  padding-bottom: 0.5rem;
}

.time-slots {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 0.5rem;
  margin-top: 1rem;
}

.time-slot-item {
  width: 100%;
}

.time-slot-item .btn {
  text-align: center;
  padding: 0.5rem;
  font-size: 0.9rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  border-radius: 10px;
  transition: background-color 0.3s ease, color 0.3s ease;
}

.time-slot-item .btn:hover {
  background-color: #e9ecef;
}

.time-slot-item .btn-primary {
  background-color: #3498db;
  color: #ffffff;
}

.time-slot-item .btn-primary:hover {
  background-color: #2980b9;
}

/* Loading Spinner */
.spinner-border {
  width: 3rem;
  height: 3rem;
  border-width: 0.3rem;
}

/* Thông báo */
.alert {
  border-radius: 10px;
  padding: 15px;
  font-size: 1rem;
}

.alert-danger {
  background-color: #f8d7da;
  color: #721c24;
  border-color: #f5c6cb;
}

.alert-success {
  background-color: #d4edda;
  color: #155724;
  border-color: #c3e6cb;
}

/* Responsive */
@media (max-width: 768px) {
  .doctor-image {
    height: 200px;
  }

  .time-slots {
    grid-template-columns: 1fr;
  }
}

.date-picker-container {
  margin-top: 10px;
}

.date-picker-container input {
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  width: 100%;
}
/*xóa*/
.delete-button {
  position: absolute;
  top: 10px;
  right: 10px; /* Đặt nút ở góc phải trên cùng */
  z-index: 10;
  border-radius: 20px; /* Bo góc giống các nút khác */
  padding: 8px 16px; /* Kích thước padding giống các nút khác */
  font-size: 0.9rem; /* Kích thước chữ giống các nút khác */
  background-color: #e74c3c;
  color: #fff;
  border: none;
  transition: background-color 0.3s ease, transform 0.3s ease;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); /* Thêm hiệu ứng đổ bóng */
}

.delete-button i {
  margin-right: 5px; /* Tạo khoảng cách giữa biểu tượng và chữ */
}

.delete-button:hover {
  background-color: #c0392b;
  transform: scale(1.05); /* Phóng to nhẹ khi hover */
}

.btn-warning {
  background-color: #f39c12;
  border-color: #f39c12;
  color: #fff;
}

.btn-warning:hover {
  background-color: #e67e22;
  border-color: #e67e22;
}
.d-flex.justify-content-around {
  gap: 10px; /* Khoảng cách giữa các nút */
}

.btn {
  flex: 1; /* Đảm bảo các nút có kích thước đồng đều */
  text-align: center;
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
  background: white;
  padding: 20px;
  border-radius: 10px;
  width: 90%;
  max-width: 500px;
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
}

.modal-header {
  border-bottom: 1px solid #f1f1f1;
  padding-bottom: 10px;
}

.modal-footer {
  border-top: 1px solid #f1f1f1;
  padding-top: 10px;
}

.d-flex.justify-content-around {
  gap: 10px;
}
</style> 