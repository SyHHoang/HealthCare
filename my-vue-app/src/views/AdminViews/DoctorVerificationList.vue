<template>
  <div class="verification-list">
    <div class="container">
      <div class="header">
        <h1>Danh sách yêu cầu xác thực bác sĩ</h1>
        <div class="filter-section">
          <select v-model="selectedStatus" @change="fetchRequests">
            <option value="">Tất cả</option>
            <option value="pending">Chờ xử lý</option>
            <option value="approved">Đã duyệt</option>
            <option value="rejected">Đã từ chối</option>
          </select>
        </div>
      </div>

      <div class="requests-grid">
        <div v-for="request in requests" :key="request._id" class="request-card">
          <div class="request-header">
            <div class="doctor-info">
              <div class="avatar-section">
                <img :src="request.avatar || '/default-avatar.png'" alt="Avatar" class="doctor-avatar" />
              </div>
              <div class="info">
                <h3>{{ request.fullName }}</h3>
                <p class="specialty">{{ request.specialty }}</p>
              </div>
            </div>
            <span class="status-badge" :class="request.status">
              {{ 
                request.status === 'pending' ? 'Chờ xử lý' :
                request.status === 'approved' ? 'Đã duyệt' :
                'Đã từ chối'
              }}
            </span>
          </div>

          <div class="request-content">
            <div class="info-section">
              <div class="info-item">
                <i class="fas fa-envelope"></i>
                <span>{{ request.email }}</span>
              </div>
              <div class="info-item">
                <i class="fas fa-phone"></i>
                <span>{{ request.phone }}</span>
              </div>
              <div class="info-item">
                <i class="fas fa-clock"></i>
                <span>Gửi lúc: {{ formatDate(request.submittedAt) }}</span>
              </div>
            </div>

            <div class="request-footer">
              <div v-if="request.status === 'pending'" class="action-buttons">
                <button @click="openDetailModal(request)" class="view-btn">
                  <i class="fas fa-eye"></i>
                  Xem chi tiết
                </button>
                <button @click="handleRequest(request._id, 'approved')" class="approve-btn">
                  <i class="fas fa-check"></i>
                  Duyệt
                </button>
                <button @click="showRejectionModal(request._id)" class="reject-btn">
                  <i class="fas fa-times"></i>
                  Từ chối
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div v-if="requests.length === 0" class="text-center text-muted py-5">
        Không có yêu cầu xác thực nào.
      </div>
    </div>

    <!-- Modal chi tiết yêu cầu -->
    <div v-if="showDetailModal" class="modal">
      <div class="modal-content">
        <div class="modal-header">
          <h3>Chi tiết yêu cầu xác thực</h3>
          <div class="header-actions">
            <button @click="toggleDoctorInfo" class="view-old-info-btn" v-if="!showDoctorInfo">
              <i class="fas fa-user-md"></i>
              Xem thông tin cũ
            </button>
            <button @click="closeDetailModal" class="close-btn">
              <i class="fas fa-times"></i>
            </button>
          </div>
        </div>
        
        <div class="modal-body">
          <div class="forms-container">
            <!-- Form thông tin yêu cầu xác thực -->
            <div class="verification-form">
              <div class="doctor-profile">
                <img :src="selectedRequest.avatar || '/default-avatar.png'" alt="Avatar" class="detail-avatar" />
                <div class="profile-info">
                  <h2>{{ selectedRequest.fullName }}</h2>
                  <p class="specialty">{{ selectedRequest.specialty }}</p>
                  <p class="other-specialties" v-if="selectedRequest.otherSpecialties">
                    Chuyên khoa khác: {{ selectedRequest.otherSpecialties }}
                  </p>
                </div>
              </div>

              <div class="info-groups">
                <div class="info-group">
                  <h4>Thông tin liên hệ</h4>
                  <div class="info-item">
                    <i class="fas fa-envelope"></i>
                    <span>{{ selectedRequest.email }}</span>
                  </div>
                  <div class="info-item">
                    <i class="fas fa-phone"></i>
                    <span>{{ selectedRequest.phone }}</span>
                  </div>
                </div>

                <div class="info-group">
                  <h4>Tài liệu xác thực</h4>
                  <div class="verification-images">
                    <div class="image-item">
                      <h5>Giấy phép hành nghề</h5>
                      <img 
                        :src="selectedRequest.licenseImageUrl" 
                        alt="Giấy phép hành nghề"
                        @click="openImageModal(selectedRequest.licenseImageUrl)"
                        class="verification-image"
                      />
                    </div>
                    <div class="image-item">
                      <h5>CMND/CCCD mặt trước</h5>
                      <img 
                        :src="selectedRequest.idCardFrontUrl" 
                        alt="CMND/CCCD mặt trước"
                        @click="openImageModal(selectedRequest.idCardFrontUrl)"
                        class="verification-image"
                      />
                    </div>
                    <div class="image-item">
                      <h5>CMND/CCCD mặt sau</h5>
                      <img 
                        :src="selectedRequest.idCardBackUrl" 
                        alt="CMND/CCCD mặt sau"
                        @click="openImageModal(selectedRequest.idCardBackUrl)"
                        class="verification-image"
                      />
                    </div>
                  </div>
                </div>

                <div class="info-group">
                  <h4>Thông tin chuyên môn</h4>
                  <div class="info-item">
                    <i class="fas fa-briefcase"></i>
                    <span>Kinh nghiệm: {{ selectedRequest.experience }} năm</span>
                  </div>
                  <div class="info-item">
                    <i class="fas fa-hospital"></i>
                    <span>Nơi làm việc: {{ selectedRequest.currentWorkplace }}</span>
                  </div>
                </div>

                <div class="info-group">
                  <h4>Thông tin học vấn</h4>
                  <div class="info-item">
                    <i class="fas fa-graduation-cap"></i>
                    <span>Trường: {{ selectedRequest.education }}</span>
                  </div>
                  <div class="info-item">
                    <i class="fas fa-calendar"></i>
                    <span>Năm tốt nghiệp: {{ selectedRequest.graduationYear }}</span>
                  </div>
                  <div class="info-item">
                    <i class="fas fa-id-card"></i>
                    <span>Số giấy phép: {{ selectedRequest.licenseNumber }}</span>
                  </div>
                </div>
              </div>

              <div class="request-timeline">
                <div class="timeline-item">
                  <i class="fas fa-paper-plane"></i>
                  <div class="timeline-content">
                    <h4>Gửi yêu cầu</h4>
                    <p>{{ formatDate(selectedRequest.submittedAt) }}</p>
                  </div>
                </div>
                <div class="timeline-item" v-if="selectedRequest.reviewedAt">
                  <i class="fas fa-check-circle"></i>
                  <div class="timeline-content">
                    <h4>Xử lý yêu cầu</h4>
                    <p>{{ formatDate(selectedRequest.reviewedAt) }}</p>
                  </div>
                </div>
              </div>
            </div>

            <!-- Form thông tin bác sĩ -->
            <div v-if="showDoctorInfo && currentDoctor" class="doctor-form">
              <h3>Thông tin hiện tại của bác sĩ</h3>
              <div class="info-groups">
                <div class="info-group">
                  <h4>Thông tin cơ bản</h4>
                  <div class="info-item">
                    <i class="fas fa-user"></i>
                    <span>{{ currentDoctor.basicInfo.fullName }}</span>
                  </div>
                  <div class="info-item">
                    <i class="fas fa-envelope"></i>
                    <span>{{ currentDoctor.basicInfo.email }}</span>
                  </div>
                  <div class="info-item">
                    <i class="fas fa-phone"></i>
                    <span>{{ currentDoctor.basicInfo.phone }}</span>
                  </div>
                  <div class="info-item">
                    <i class="fas fa-clock"></i>
                    <span>Ngày tạo: {{ formatDate(currentDoctor.basicInfo.createdAt) }}</span>
                  </div>
                </div>

                <div class="info-group">
                  <h4>Thông tin chuyên môn</h4>
                  <div class="info-item">
                    <i class="fas fa-stethoscope"></i>
                    <span>Chuyên khoa: {{ currentDoctor.professionalInfo.specialty }}</span>
                  </div>
                  <div class="info-item" v-if="currentDoctor.professionalInfo.otherSpecialties">
                    <i class="fas fa-certificate"></i>
                    <span>Chuyên khoa khác: {{ currentDoctor.professionalInfo.otherSpecialties }}</span>
                  </div>
                  <div class="info-item">
                    <i class="fas fa-briefcase"></i>
                    <span>Kinh nghiệm: {{ currentDoctor.professionalInfo.experience }} năm</span>
                  </div>
                  <div class="info-item">
                    <i class="fas fa-hospital"></i>
                    <span>Nơi làm việc: {{ currentDoctor.professionalInfo.currentWorkplace }}</span>
                  </div>
                  <div class="info-item" v-if="currentDoctor.professionalInfo.academicTitle">
                    <i class="fas fa-award"></i>
                    <span>Học hàm: {{ currentDoctor.professionalInfo.academicTitle }}</span>
                  </div>
                </div>

                <div class="info-group">
                  <h4>Thông tin học vấn</h4>
                  <div class="info-item">
                    <i class="fas fa-graduation-cap"></i>
                    <span>Trường: {{ currentDoctor.educationInfo.education }}</span>
                  </div>
                  <div class="info-item">
                    <i class="fas fa-calendar"></i>
                    <span>Năm tốt nghiệp: {{ currentDoctor.educationInfo.graduationYear }}</span>
                  </div>
                  <div class="info-item">
                    <i class="fas fa-id-card"></i>
                    <span>Số giấy phép: {{ currentDoctor.educationInfo.licenseNumber }}</span>
                  </div>
                </div>

                <div class="info-group" v-if="currentDoctor.verificationInfo">
                  <h4>Thông tin xác thực</h4>
                  <div class="info-item">
                    <i class="fas fa-check-circle"></i>
                    <span>Trạng thái: {{ 
                      currentDoctor.verificationInfo.status === 'pending' ? 'Chờ xử lý' :
                      currentDoctor.verificationInfo.status === 'approved' ? 'Đã duyệt' :
                      'Đã từ chối'
                    }}</span>
                  </div>
                  <div class="info-item">
                    <i class="fas fa-paper-plane"></i>
                    <span>Gửi lúc: {{ formatDate(currentDoctor.verificationInfo.submittedAt) }}</span>
                  </div>
                  <div class="info-item" v-if="currentDoctor.verificationInfo.reviewedAt">
                    <i class="fas fa-clock"></i>
                    <span>Xử lý lúc: {{ formatDate(currentDoctor.verificationInfo.reviewedAt) }}</span>
                  </div>
                  <div class="info-item" v-if="currentDoctor.verificationInfo.rejectionReason">
                    <i class="fas fa-times-circle"></i>
                    <span>Lý do từ chối: {{ currentDoctor.verificationInfo.rejectionReason }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal nhập lý do từ chối -->
    <div v-if="showModal" class="modal">
      <div class="modal-content rejection-modal">
        <div class="modal-header">
          <h3>Nhập lý do từ chối</h3>
          <button @click="closeModal" class="close-btn">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label for="rejectionReason">Lý do từ chối:</label>
            <textarea 
              id="rejectionReason"
              v-model="rejectionReason" 
              placeholder="Nhập lý do từ chối..."
              rows="4"
              class="form-control"
            ></textarea>
          </div>
        </div>
        <div class="modal-footer">
          <button @click="closeModal" class="cancel-btn">
            <i class="fas fa-times"></i>
            Hủy
          </button>
          <button @click="handleRequest(selectedRequestId, 'rejected')" class="confirm-btn">
            <i class="fas fa-check"></i>
            Xác nhận
          </button>
        </div>
      </div>
    </div>

    <!-- Thêm modal xem ảnh -->
    <div v-if="showImageModal" class="modal image-modal" @click="closeImageModal">
      <div class="modal-content image-modal-content" @click.stop>
        <div class="modal-header">
          <h3>Xem ảnh</h3>
          <button @click="closeImageModal" class="close-btn">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="modal-body">
          <img :src="selectedImage" alt="Ảnh xác thực" class="full-size-image" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useToast } from 'primevue/usetoast';
import verificationService from '@/services/verificationService';
import { doctorService } from '@/services/doctorService';

const toast = useToast();
const requests = ref([]);
const selectedStatus = ref('');
const showModal = ref(false);
const selectedRequestId = ref('');
const rejectionReason = ref('');
const showDetailModal = ref(false);
const selectedRequest = ref(null);
const currentDoctor = ref(null);
const showDoctorInfo = ref(false);
const showImageModal = ref(false);
const selectedImage = ref('');

// Lấy danh sách yêu cầu
const fetchRequests = async () => {
  try {
    const response = await verificationService.getVerificationRequests();
    requests.value = response;
    console.log('requests', requests.value);
  } catch (error) {
    console.error('Lỗi khi lấy danh sách yêu cầu:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể lấy danh sách yêu cầu. Vui lòng thử lại sau.',
      life: 3000
    });
  }
};

onMounted(fetchRequests);

// Mở modal chi tiết
const openDetailModal = async (request) => {
  selectedRequest.value = request;
  showDetailModal.value = true;
  showDoctorInfo.value = false; // Reset trạng thái hiển thị thông tin bác sĩ
};

// Đóng modal chi tiết
const closeDetailModal = () => {
  showDetailModal.value = false;
  selectedRequest.value = null;
  currentDoctor.value = null;
  showDoctorInfo.value = false;
};

// Toggle hiển thị thông tin bác sĩ
const toggleDoctorInfo = async () => {
  if (!showDoctorInfo.value) {
    try {
      console.log('Selected request:', selectedRequest.value); // Debug log
      const doctorId = selectedRequest.value.doctor;
      console.log('Doctor ID:', doctorId); // Debug log
      
      if (!doctorId) {
        throw new Error('Không tìm thấy ID bác sĩ');
      }

      const response = await doctorService.getFullDoctorInfo(doctorId);
      if (response.success) {
        currentDoctor.value = response.data;
        showDoctorInfo.value = true;
      }
    } catch (error) {
      console.error('Lỗi khi lấy thông tin bác sĩ:', error);
      toast.add({
        severity: 'error',
        summary: 'Lỗi',
        detail: error.message || 'Không thể lấy thông tin bác sĩ',
        life: 3000
      });
    }
  } else {
    showDoctorInfo.value = false;
  }
};

// Hiển thị modal từ chối
const showRejectionModal = (requestId) => {
  selectedRequestId.value = requestId;
  rejectionReason.value = ''; // Reset lý do từ chối
  showModal.value = true;
};

// Đóng modal từ chối
const closeModal = () => {
  showModal.value = false;
  selectedRequestId.value = '';
  rejectionReason.value = '';
};

// Xử lý yêu cầu
const handleRequest = async (requestId, status) => {
  try {
    if (status === 'rejected' && !rejectionReason.value.trim()) {
      toast.add({
        severity: 'error',
        summary: 'Lỗi',
        detail: 'Vui lòng nhập lý do từ chối',
        life: 3000
      });
      return;
    }

    const response = await verificationService.handleVerificationRequest(
      requestId,
      status,
      status === 'rejected' ? rejectionReason.value : ''
    );

    if (
      response.message === 'Yêu cầu xác thực đã được từ chối' ||
      response.message === 'Yêu cầu xác thực đã được duyệt'
    ) {
      toast.add({
        severity: 'success',
        summary: 'Thành công',
        detail: response.message,
        life: 3000
      });
      // Cập nhật lại danh sách
      await fetchRequests();
      // Đóng modal và reset form nếu từ chối
      if (status === 'rejected') {
        closeModal();
        rejectionReason.value = '';
      }
      // Nếu đang xem chi tiết, cập nhật lại thông tin
      if (selectedRequest.value && selectedRequest.value._id === requestId) {
        const updatedRequest = requests.value.find(r => r._id === requestId);
        if (updatedRequest) {
          selectedRequest.value = updatedRequest;
        }
      }
    } else {
      toast.add({
        severity: 'error',
        summary: 'Lỗi',
        detail: response.message || 'Xử lý yêu cầu thất bại',
        life: 3000
      });
    }
  } catch (error) {
    console.error('Lỗi khi xử lý yêu cầu:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể xử lý yêu cầu. Vui lòng thử lại sau.',
      life: 3000
    });
  }
};

// Định dạng ngày tháng
const formatDate = (dateString) => {
  if (!dateString) return '';
  const date = new Date(dateString);
  return date.toLocaleString('vi-VN', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  });
};

const openImageModal = (imageUrl) => {
  selectedImage.value = imageUrl;
  showImageModal.value = true;
};

const closeImageModal = () => {
  showImageModal.value = false;
  selectedImage.value = '';
};
</script>

<style scoped>
.verification-list {
  padding: 20px;
  min-height: 100vh;
  background: #f8f9fa;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.header h1 {
  color: #333;
  font-size: 1.8rem;
}

.filter-section select {
  padding: 8px 15px;
  border-radius: 5px;
  border: 1px solid #ddd;
  background: white;
  font-size: 1rem;
}

.requests-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 20px;
}

.request-card {
  background: white;
  border-radius: 10px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.request-header {
  padding: 15px;
  background: #f8f9fa;
  border-bottom: 1px solid #eee;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.doctor-info h3 {
  margin: 0;
  color: #333;
  font-size: 1.2rem;
}

.specialty {
  color: #666;
  font-size: 0.9rem;
  margin: 5px 0 0;
}

.status-badge {
  padding: 5px 10px;
  border-radius: 15px;
  font-size: 0.8rem;
  font-weight: 500;
}

.status-badge.pending {
  background: #fff3cd;
  color: #856404;
}

.status-badge.approved {
  background: #d4edda;
  color: #155724;
}

.status-badge.rejected {
  background: #f8d7da;
  color: #721c24;
}

.request-content {
  padding: 15px;
}

.info-section {
  display: grid;
  grid-template-columns: 1fr;
  gap: 10px;
}

.info-group {
  margin-bottom: 15px;
  padding: 10px;
  background: #f8f9fa;
  border-radius: 5px;
}

.info-group h4 {
  margin: 0 0 10px;
  color: #333;
  font-size: 1rem;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 5px;
  color: #555;
}

.info-item i {
  width: 20px;
  color: #4a90e2;
}

.other-specialties {
  color: #666;
  font-size: 0.9rem;
  margin: 5px 0 0;
}

.rejection-reason {
  margin-top: 15px;
  padding: 10px;
  background: #f8f9fa;
  border-radius: 5px;
}

.rejection-reason h4 {
  margin: 0 0 5px;
  color: #dc3545;
}

.rejection-reason p {
  margin: 0;
  color: #666;
}

.request-footer {
  margin-top: 15px;
  padding-top: 15px;
  border-top: 1px solid #eee;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.timestamp {
  color: #666;
  font-size: 0.8rem;
}

.timestamp p {
  margin: 0;
}

.action-buttons {
  display: flex;
  gap: 10px;
}

.action-buttons button {
  padding: 8px 15px;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 0.9rem;
  transition: all 0.3s ease;
}

.view-btn {
  background: #4a90e2;
  color: white;
}

.view-btn:hover {
  background: #357abd;
}

.approve-btn {
  background: #28a745;
  color: white;
}

.approve-btn:hover {
  background: #218838;
}

.reject-btn {
  background: #dc3545;
  color: white;
}

.reject-btn:hover {
  background: #c82333;
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
  border-radius: 10px;
  width: 80%;
  max-width: 1000px;
  max-height: 80vh;
  overflow-y: auto;
}

.forms-container {
  display: flex;
  gap: 20px;
  padding: 15px;
}

.verification-form {
  flex: 1;
  background: white;
  border-radius: 8px;
  padding: 15px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  border: 1px solid #e0e0e0;
  min-width: 0; /* Prevent flex item from overflowing */
}

.doctor-form {
  flex: 1;
  background: #f8f9fa;
  border-radius: 8px;
  padding: 15px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  border: 1px solid #e0e0e0;
  min-width: 0; /* Prevent flex item from overflowing */
}

.doctor-profile {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 10px;
}

.detail-avatar {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  object-fit: cover;
}

.profile-info h2 {
  font-size: 1rem;
  margin: 0 0 3px;
}

.profile-info p {
  margin: 0;
  font-size: 0.8rem;
}

.info-groups {
  display: grid;
  gap: 8px;
}

.info-group {
  background: #f8f9fa;
  padding: 8px;
  border-radius: 6px;
}

.info-group h4 {
  font-size: 0.9rem;
  margin: 0 0 6px;
  padding-bottom: 4px;
  border-bottom: 1px solid #dee2e6;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-bottom: 4px;
  font-size: 0.8rem;
}

.info-item i {
  color: #4a90e2;
  width: 14px;
}

.info-item span {
  color: #666;
}

.request-timeline {
  margin-top: 10px;
  padding-top: 10px;
  border-top: 1px solid #eee;
}

.timeline-item {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-bottom: 4px;
}

.timeline-item i {
  color: #4a90e2;
  width: 14px;
}

.timeline-content h4 {
  font-size: 0.8rem;
  margin: 0 0 2px;
}

.timeline-content p {
  font-size: 0.7rem;
  margin: 0;
  color: #666;
}

.doctor-form h3 {
  font-size: 0.9rem;
  margin-bottom: 10px;
  padding-bottom: 4px;
  border-bottom: 1px solid #eee;
  color: #333;
}

.modal-header {
  padding: 8px 10px;
  border-bottom: 1px solid #dee2e6;
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: sticky;
  top: 0;
  background: white;
  z-index: 1;
}

.modal-header h3 {
  font-size: 1rem;
  margin: 0;
}

.header-actions {
  display: flex;
  gap: 6px;
  align-items: center;
}

.view-old-info-btn {
  padding: 4px 8px;
  font-size: 0.8rem;
  background: #4a90e2;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.view-old-info-btn:hover {
  background: #357abd;
}

.close-btn {
  padding: 4px;
  font-size: 0.9rem;
  background: none;
  border: none;
  color: #666;
  cursor: pointer;
}

.close-btn:hover {
  color: #333;
}

@media (max-width: 768px) {
  .modal-content {
    width: 95%;
    margin: 10px;
  }
  
  .forms-container {
    flex-direction: column;
    gap: 15px;
  }

  .verification-form,
  .doctor-form {
    padding: 10px;
  }

  .doctor-profile {
    flex-direction: column;
    text-align: center;
  }

  .detail-avatar {
    width: 40px;
    height: 40px;
  }
}

.rejection-modal {
  width: 40%;
  max-width: 500px;
  max-height: auto;
}

.modal-header {
  padding: 15px 20px;
  border-bottom: 1px solid #dee2e6;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-header h3 {
  margin: 0;
  font-size: 1.2rem;
  color: #333;
}

.modal-body {
  padding: 20px;
}

.form-group {
  margin-bottom: 0;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  color: #333;
}

.form-control {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 0.9rem;
  resize: vertical;
}

.form-control:focus {
  outline: none;
  border-color: #4a90e2;
  box-shadow: 0 0 0 2px rgba(74, 144, 226, 0.2);
}

.modal-footer {
  padding: 15px 20px;
  border-top: 1px solid #dee2e6;
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

.cancel-btn {
  padding: 8px 15px;
  border: 1px solid #dc3545;
  border-radius: 4px;
  background: white;
  color: #dc3545;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 0.9rem;
  transition: all 0.3s ease;
}

.cancel-btn:hover {
  background: #dc3545;
  color: white;
}

.confirm-btn {
  padding: 8px 15px;
  border: none;
  border-radius: 4px;
  background: #28a745;
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 0.9rem;
  transition: all 0.3s ease;
}

.confirm-btn:hover {
  background: #218838;
}

@media (max-width: 768px) {
  .rejection-modal {
    width: 90%;
    margin: 10px;
  }
  
  .modal-header {
    padding: 10px 15px;
  }
  
  .modal-body {
    padding: 15px;
  }
  
  .modal-footer {
    padding: 10px 15px;
  }
}

.verification-images {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 15px;
  margin-top: 10px;
}

.image-item {
  text-align: center;
}

.image-item h5 {
  font-size: 0.8rem;
  margin-bottom: 8px;
  color: #666;
}

.verification-image {
  width: 100%;
  height: 150px;
  object-fit: cover;
  border-radius: 8px;
  cursor: pointer;
  transition: transform 0.2s;
  border: 1px solid #ddd;
}

.verification-image:hover {
  transform: scale(1.05);
}

.image-modal {
  background: rgba(0, 0, 0, 0.9);
}

.image-modal-content {
  width: 90%;
  max-width: 1200px;
  background: transparent;
  box-shadow: none;
}

.image-modal .modal-header {
  background: transparent;
  border-bottom: none;
}

.image-modal .modal-header h3 {
  color: white;
}

.image-modal .close-btn {
  color: white;
}

.image-modal .modal-body {
  padding: 0;
  display: flex;
  justify-content: center;
  align-items: center;
}

.full-size-image {
  max-width: 100%;
  max-height: 80vh;
  object-fit: contain;
}

@media (max-width: 768px) {
  .verification-images {
    grid-template-columns: 1fr;
  }
  
  .verification-image {
    height: 200px;
  }
}
</style> 