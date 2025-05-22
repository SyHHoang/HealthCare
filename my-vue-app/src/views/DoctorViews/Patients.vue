<template>
  <div class="patients">
    <h2 class="page-title">Quản lý bệnh nhân</h2>

    <!-- Thanh tìm kiếm -->
    <div class="search-bar">
      <div class="search-input">
        <i class="fas fa-search"></i>
        <input 
          type="text" 
          v-model="searchQuery" 
          placeholder="Tìm kiếm bệnh nhân theo tên hoặc số điện thoại..."
        >
      </div>
    </div>

    <!-- Danh sách bệnh nhân -->
    <div class="patients-list">
      <div class="patient-card" v-for="patient in patients" :key="patient.id">
        <div class="patient-header">
          <div class="patient-info">
            <img 
              :src="patient.avatar" 
              :alt="patient.fullname" 
              class="patient-avatar"
              @error="handleImageError"
            >
            <div>
              <p>{{ patient.fullname }}</p>
            </div>
          </div>
        </div>

        <div class="patient-details">
          <div class="detail-row">
            <div class="detail-item">
              <i class="bi bi-telephone"></i>
              <span>{{ patient.phone }}</span>
            </div>
          </div>
          <div class="detail-row">
            <div class="detail-item">
              <i class="bi bi-gender-ambiguous"></i>
              <span>{{ patient.gender === 'male' ? 'Nam' : 'Nữ' }}</span>
            </div>
            <div class="detail-item">
              <i class="bi bi-calendar"></i>
              <span>{{ patient.age }} tuổi</span>
            </div>
          </div>
        </div>

        <div class="patient-actions">
          <button class="action-btn view" @click="viewPatient(patient)">
            <i class="fas fa-eye"></i> Xem hồ sơ
          </button>
        </div>
      </div>
    </div>

    <!-- Modal Prescription -->
    <div v-if="showPrescription" class="modal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>Thêm đơn thuốc cho {{ selectedPatient?.fullname }}</h2>
          <button class="close-btn" @click="closePrescriptionModal">×</button>
        </div>
        
        <div class="prescription-form">
          <form @submit.prevent="submitPrescription">
            <div class="form-group">
              <label for="diagnosis">Chẩn đoán:</label>
              <textarea
                id="diagnosis"
                v-model="prescriptionForm.diagnosis"
                required
                placeholder="Nhập chẩn đoán..."
              ></textarea>
            </div>

            <div class="medicines-section">
              <h3>Danh sách thuốc</h3>
              <div v-for="(medicine, index) in prescriptionForm.medicines" :key="index" class="medicine-item">
                <div class="form-group">
                  <label :for="'medicineName' + index">Tên thuốc:</label>
                  <input
                    :id="'medicineName' + index"
                    v-model="medicine.name"
                    required
                    placeholder="Tên thuốc"
                  >
                </div>
                <div class="form-group">
                  <label :for="'dosage' + index">Liều lượng:</label>
                  <input
                    :id="'dosage' + index"
                    v-model="medicine.dosage"
                    required
                    placeholder="Ví dụ: 1 viên"
                  >
                </div>
                <div class="form-group">
                  <label :for="'frequency' + index">Tần suất:</label>
                  <input
                    :id="'frequency' + index"
                    v-model="medicine.frequency"
                    required
                    placeholder="Ví dụ: 2 lần/ngày"
                  >
                </div>
                <div class="form-group">
                  <label :for="'duration' + index">Thời gian:</label>
                  <input
                    :id="'duration' + index"
                    v-model="medicine.duration"
                    required
                    placeholder="Ví dụ: 7 ngày"
                  >
                </div>
                <div class="form-group">
                  <label :for="'notes' + index">Ghi chú:</label>
                  <input
                    :id="'notes' + index"
                    v-model="medicine.notes"
                    placeholder="Ghi chú thêm"
                  >
                </div>
                <button type="button" @click="removeMedicine(index)" class="btn-remove">Xóa</button>
              </div>
              <button type="button" @click="addMedicine" class="btn-add">Thêm thuốc</button>
            </div>

            <div class="form-group">
              <label for="notes">Ghi chú chung:</label>
              <textarea
                id="notes"
                v-model="prescriptionForm.notes"
                placeholder="Thêm ghi chú nếu có..."
              ></textarea>
            </div>

            <div class="form-actions">
              <button type="button" @click="closePrescriptionModal" class="btn-cancel">Hủy</button>
              <button type="submit" class="btn-submit">Lưu</button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axiosInstance from '@/services/axiosInstance';
import { useRouter } from 'vue-router';
import { useToast } from 'vue-toastification';

const router = useRouter();
const toast = useToast();
const searchQuery = ref('')
const loading = ref(false);
const error = ref(null);
const showPrescription = ref(false);
const selectedPatient = ref(null);
const patients = ref([]);

const prescriptionForm = ref({
  diagnosis: '',
  medicines: [{
    name: '',
    dosage: '',
    frequency: '',
    duration: '',
    notes: ''
  }],
  notes: ''
});

const addMedicine = () => {
  prescriptionForm.value.medicines.push({
    name: '',
    dosage: '',
    frequency: '',
    duration: '',
    notes: ''
  });
};

const removeMedicine = (index) => {
  prescriptionForm.value.medicines.splice(index, 1);
};

const submitPrescription = async () => {
  try {
    const submitData = {
      patientId: selectedPatient.value.userId,
      diagnosis: prescriptionForm.value.diagnosis,
      medicines: prescriptionForm.value.medicines.map(medicine => ({
        name: medicine.name,
        dosage: medicine.dosage,
        frequency: medicine.frequency,
        duration: medicine.duration,
        notes: medicine.notes || ''
      })),
      instructions: prescriptionForm.value.notes
    };

    const response = await axiosInstance.post(`/api/medical-record/prescriptions/doctor`, submitData);

    toast.success('Thêm đơn thuốc thành công');
    closePrescriptionModal();
  } catch (error) {
    console.error('Error submitting prescription:', error);
    toast.error(error.response?.data?.message || 'Có lỗi xảy ra khi lưu đơn thuốc');
  }
};

const loadConsultationList = async () => {
  try {
    loading.value = true;
    error.value = null;
    const token = localStorage.getItem('token');
    console.log('Token:', token);

    const response = await axiosInstance.get('/api/consultationList/list/user');
    console.log('Consultation list response:', response.data); // Debug log
    
    if (response.data && Array.isArray(response.data)) {
      // Chuyển đổi dữ liệu từ API thành định dạng phù hợp với giao diện
      patients.value = response.data.map(consultation => ({
        id: consultation._id,
        fullname: consultation.userId.fullname,
        age: consultation.userId.age,
        gender: consultation.userId.gender,
        phone: consultation.userId.phone,
        avatar: consultation.userId.avatar || 'https://ibb.co/WWjN48Gf',
        createdAt: new Date(consultation.createdAt).toLocaleDateString(),
        userId: consultation.userId._id
      }));
    } else {
      console.log('No data found');
      patients.value = [];
    }
  } catch (err) {
    console.error('Error loading consultation list:', err);
    if (err.response?.status === 401) {
      error.value = 'Vui lòng đăng nhập để xem danh sách tư vấn';
      router.push('/doctor/login');
    } else {
      error.value = 'Không thể tải thông tin bệnh nhân. Vui lòng thử lại sau.';
    }
  } finally {
    loading.value = false;
  }
};

const handleImageError = (event) => {
  event.target.src = 'https://ibb.co/WWjN48Gf';
};

const viewPatient = (patient) => {
window.open(`/doctor/patient/${patient.userId}`, '_blank');
console.log('Viewing patient:', patient.userId);

}

const editPatient = (patient) => {
  console.log('Editing patient:', patient)
}

const showPrescriptionModal = (patient) => {
  selectedPatient.value = patient;
  showPrescription.value = true;
};

const closePrescriptionModal = () => {
  showPrescription.value = false;
  selectedPatient.value = null;
  prescriptionForm.value = {
    diagnosis: '',
    medicines: [{
      name: '',
      dosage: '',
      frequency: '',
      duration: '',
      notes: ''
    }],
    notes: ''
  };
};

onMounted(() => {
  loadConsultationList();
});
</script>

<style scoped>
/* Styles remain the same as in your original code */
.patients {
  padding: 20px;
}

.page-title {
  margin-bottom: 30px;
  color: #2c3e50;
}

.search-bar {
  display: flex;
  gap: 20px;
  margin-bottom: 30px;
  flex-wrap: wrap;
}

.search-input {
  flex: 1;
  min-width: 300px;
  position: relative;
}

.search-input i {
  position: absolute;
  left: 12px;
  top: 50%;
  transform: translateY(-50%);
  color: #666;
}

.search-input input {
  width: 100%;
  padding: 12px 12px 12px 40px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 14px;
}

.patients-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.patient-card {
  background: white;
  border-radius: 10px;
  padding: 20px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.patient-header {
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
  width: 50px;
  height: 50px;
  border-radius: 50%;
  object-fit: cover;
  background-color: #f0f0f0;
}

.patient-info h3 {
  margin: 0;
  color: #2c3e50;
}

.patient-details {
  margin-bottom: 20px;
}

.detail-row {
  display: flex;
  gap: 20px;
  margin-bottom: 10px;
}

.detail-item {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #666;
  font-size: 14px;
}

.detail-item i {
  color: #3498db;
  width: 16px;
}

.patient-actions {
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

.action-btn.edit {
  background: #e3f2fd;
  color: #1976d2;
}

.action-btn:hover {
  opacity: 0.9;
}

/* Modal styles */
.modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0,0,0,0.5);
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
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 10px;
  border-bottom: 1px solid #eee;
}

.modal-header h2 {
  margin: 0;
  color: #2c3e50;
}

.close-btn {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: #666;
}

.close-btn:hover {
  color: #333;
}

@media (max-width: 768px) {
  .search-bar {
    flex-direction: column;
  }
  
  .search-input {
    width: 100%;
  }
  
  .detail-row {
    flex-direction: column;
  }
  
  .patient-actions {
    flex-direction: column;
  }
  
  .action-btn {
    width: 100%;
    justify-content: center;
  }
}

/* Prescription Form Styles */
.prescription-form {
  padding: 20px 0;
}

.form-group {
  margin-bottom: 15px;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  font-weight: 500;
  color: #333;
}

.form-group input,
.form-group textarea {
  width: 100%;
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.form-group textarea {
  min-height: 100px;
  resize: vertical;
}

.medicines-section {
  margin: 20px 0;
  padding: 15px;
  border: 1px solid #eee;
  border-radius: 4px;
}

.medicine-item {
  position: relative;
  padding: 15px;
  margin-bottom: 15px;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.btn-remove {
  position: absolute;
  top: 15px;
  right: 15px;
  background: #f44336;
  color: white;
  border: none;
  padding: 5px 10px;
  border-radius: 4px;
  cursor: pointer;
}

.btn-add {
  background: #4CAF50;
  color: white;
  border: none;
  padding: 8px 15px;
  border-radius: 4px;
  cursor: pointer;
  margin-top: 10px;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 20px;
}

.btn-cancel {
  padding: 8px 16px;
  background: #f5f5f5;
  color: #666;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.btn-submit {
  padding: 8px 16px;
  background: #4CAF50;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.btn-cancel:hover,
.btn-submit:hover {
  opacity: 0.9;
}
</style>
