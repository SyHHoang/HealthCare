<template>
  <div class="prescriptions">
    <h1 class="page-title">Quản lý đơn thuốc</h1>

    <!-- Thanh tìm kiếm và lọc -->
    <div class="filters">
      <div class="search-input">
        <i class="fas fa-search"></i>
        <input 
          type="text" 
          v-model="searchQuery" 
          placeholder="Tìm kiếm đơn thuốc theo tên bệnh nhân hoặc ID..."
        >
      </div>
      <div class="filter-group">
        <label>Trạng thái:</label>
        <select v-model="filters.status">
          <option value="">Tất cả</option>
          <option value="active">Đang sử dụng</option>
          <option value="completed">Đã hoàn thành</option>
          <option value="cancelled">Đã hủy</option>
        </select>
      </div>
      <button class="new-prescription-btn" @click="showNewPrescriptionModal = true">
        <i class="fas fa-plus"></i> Tạo đơn thuốc mới
      </button>
    </div>

    <!-- Danh sách đơn thuốc -->
    <div class="prescriptions-list">
      <div class="prescription-card" v-for="prescription in prescriptions" :key="prescription.id">
        <div class="prescription-header">
          <div class="prescription-info">
            <h3>Đơn thuốc #{{ prescription.id }}</h3>
            <p>Bệnh nhân: {{ prescription.patientName }}</p>
          </div>
          <div class="prescription-status" :class="prescription.status">
            {{ getStatusText(prescription.status) }}
          </div>
        </div>

        <div class="prescription-details">
          <div class="detail-row">
            <div class="detail-item">
              <i class="fas fa-calendar"></i>
              <span>Ngày kê: {{ prescription.date }}</span>
            </div>
            <div class="detail-item">
              <i class="fas fa-clock"></i>
              <span>Thời gian: {{ prescription.time }}</span>
            </div>
          </div>
          <div class="detail-row">
            <div class="detail-item">
              <i class="fas fa-stethoscope"></i>
              <span>Chẩn đoán: {{ prescription.diagnosis }}</span>
            </div>
          </div>
        </div>

        <div class="medications-list">
          <h4>Danh sách thuốc</h4>
          <div class="medication-item" v-for="med in prescription.medications" :key="med.id">
            <div class="medication-info">
              <span class="med-name">{{ med.name }}</span>
              <span class="med-dosage">{{ med.dosage }}</span>
            </div>
            <span class="med-duration">{{ med.duration }}</span>
          </div>
        </div>

        <div class="prescription-actions">
          <button class="action-btn view" @click="viewPrescription(prescription)">
            <i class="fas fa-eye"></i> Xem chi tiết
          </button>
          <button class="action-btn edit" v-if="prescription.status === 'active'" @click="editPrescription(prescription)">
            <i class="fas fa-edit"></i> Chỉnh sửa
          </button>
          <button class="action-btn cancel" v-if="prescription.status === 'active'" @click="cancelPrescription(prescription)">
            <i class="fas fa-times"></i> Hủy
          </button>
        </div>
      </div>
    </div>

    <!-- Modal tạo đơn thuốc mới -->
    <div class="modal" v-if="showNewPrescriptionModal">
      <div class="modal-content">
        <h2>Tạo đơn thuốc mới</h2>
        <form @submit.prevent="createPrescription">
          <div class="form-group">
            <label>Chọn bệnh nhân</label>
            <select v-model="newPrescription.patientId" required>
              <option value="">Chọn bệnh nhân</option>
              <option v-for="patient in patients" :key="patient.id" :value="patient.id">
                {{ patient.name }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label>Chẩn đoán</label>
            <textarea v-model="newPrescription.diagnosis" required></textarea>
          </div>
          <div class="form-group">
            <label>Ghi chú</label>
            <textarea v-model="newPrescription.notes"></textarea>
          </div>
          <div class="medications-section">
            <h3>Danh sách thuốc</h3>
            <div class="medication-form" v-for="(med, index) in newPrescription.medications" :key="index">
              <div class="medication-inputs">
                <div class="form-group">
                  <label>Tên thuốc</label>
                  <input type="text" v-model="med.name" required>
                </div>
                <div class="form-group">
                  <label>Liều lượng</label>
                  <input type="text" v-model="med.dosage" required>
                </div>
                <div class="form-group">
                  <label>Thời gian sử dụng</label>
                  <input type="text" v-model="med.duration" required>
                </div>
              </div>
              <button type="button" class="remove-med-btn" @click="removeMedication(index)">
                <i class="fas fa-trash"></i>
              </button>
            </div>
            <button type="button" class="add-med-btn" @click="addMedication">
              <i class="fas fa-plus"></i> Thêm thuốc
            </button>
          </div>
          <div class="modal-actions">
            <button type="button" class="cancel-btn" @click="showNewPrescriptionModal = false">
              Hủy
            </button>
            <button type="submit" class="submit-btn">
              Tạo đơn thuốc
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'DoctorPrescriptions',
  data() {
    return {
      searchQuery: '',
      filters: {
        status: ''
      },
      showNewPrescriptionModal: false,
      newPrescription: {
        patientId: '',
        diagnosis: '',
        notes: '',
        medications: []
      },
      patients: [
        { id: 'BN001', name: 'Nguyễn Văn A' },
        { id: 'BN002', name: 'Trần Thị B' },
        { id: 'BN003', name: 'Lê Văn C' }
      ],
      prescriptions: [
        {
          id: 'DT001',
          patientName: 'Nguyễn Văn A',
          date: '2024-03-20',
          time: '09:00',
          diagnosis: 'Cảm cúm',
          status: 'active',
          medications: [
            {
              id: 1,
              name: 'Paracetamol',
              dosage: '500mg',
              duration: '3 lần/ngày, 7 ngày'
            },
            {
              id: 2,
              name: 'Vitamin C',
              dosage: '1000mg',
              duration: '1 lần/ngày, 7 ngày'
            }
          ]
        },
        {
          id: 'DT002',
          patientName: 'Trần Thị B',
          date: '2024-03-19',
          time: '14:30',
          diagnosis: 'Đau dạ dày',
          status: 'completed',
          medications: [
            {
              id: 3,
              name: 'Omeprazole',
              dosage: '20mg',
              duration: '1 lần/ngày, 14 ngày'
            }
          ]
        }
      ]
    }
  },
  methods: {
    getStatusText(status) {
      const statusMap = {
        active: 'Đang sử dụng',
        completed: 'Đã hoàn thành',
        cancelled: 'Đã hủy'
      }
      return statusMap[status] || status
    },
    viewPrescription(prescription) {
      console.log('Viewing prescription:', prescription)
    },
    editPrescription(prescription) {
      console.log('Editing prescription:', prescription)
    },
    cancelPrescription(prescription) {
      console.log('Cancelling prescription:', prescription)
    },
    addMedication() {
      this.newPrescription.medications.push({
        name: '',
        dosage: '',
        duration: ''
      })
    },
    removeMedication(index) {
      this.newPrescription.medications.splice(index, 1)
    },
    createPrescription() {
      // Implement create prescription logic
      console.log('Creating new prescription:', this.newPrescription)
      this.showNewPrescriptionModal = false
      this.newPrescription = {
        patientId: '',
        diagnosis: '',
        notes: '',
        medications: []
      }
    }
  }
}
</script>

<style scoped>
.prescriptions {
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

.filter-group {
  display: flex;
  align-items: center;
  gap: 10px;
}

.filter-group label {
  color: #666;
}

.filter-group select {
  padding: 12px;
  border: 1px solid #ddd;
  border-radius: 8px;
  min-width: 150px;
}

.new-prescription-btn {
  padding: 12px 24px;
  background: #2ecc71;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
}

.new-prescription-btn:hover {
  background: #27ae60;
}

.prescriptions-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 20px;
}

.prescription-card {
  background: white;
  border-radius: 10px;
  padding: 20px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.prescription-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.prescription-info h3 {
  margin: 0;
  color: #2c3e50;
}

.prescription-info p {
  margin: 5px 0 0;
  color: #666;
  font-size: 14px;
}

.prescription-status {
  padding: 5px 10px;
  border-radius: 15px;
  font-size: 12px;
}

.prescription-status.active {
  background: #e8f5e9;
  color: #388e3c;
}

.prescription-status.completed {
  background: #f5f5f5;
  color: #666;
}

.prescription-status.cancelled {
  background: #ffebee;
  color: #d32f2f;
}

.prescription-details {
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

.medications-list {
  background: #f8f9fa;
  padding: 15px;
  border-radius: 8px;
  margin-bottom: 20px;
}

.medications-list h4 {
  margin: 0 0 15px;
  color: #2c3e50;
}

.medication-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px;
  background: white;
  border-radius: 4px;
  margin-bottom: 8px;
}

.medication-info {
  display: flex;
  flex-direction: column;
}

.med-name {
  font-weight: 500;
  color: #2c3e50;
}

.med-dosage {
  font-size: 12px;
  color: #666;
}

.med-duration {
  font-size: 12px;
  color: #666;
}

.prescription-actions {
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

.action-btn.cancel {
  background: #ffebee;
  color: #d32f2f;
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
  padding: 30px;
  border-radius: 10px;
  width: 90%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-content h2 {
  margin-bottom: 20px;
  color: #2c3e50;
}

.form-group {
  margin-bottom: 15px;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  color: #666;
}

.form-group input,
.form-group select,
.form-group textarea {
  width: 100%;
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.form-group textarea {
  height: 100px;
  resize: vertical;
}

.medications-section {
  margin-top: 20px;
}

.medications-section h3 {
  margin-bottom: 15px;
  color: #2c3e50;
}

.medication-form {
  display: flex;
  gap: 10px;
  margin-bottom: 15px;
}

.medication-inputs {
  flex: 1;
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
}

.remove-med-btn {
  padding: 8px;
  background: #ffebee;
  color: #d32f2f;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  align-self: flex-end;
}

.add-med-btn {
  padding: 8px 16px;
  background: #e3f2fd;
  color: #1976d2;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 20px;
}

.cancel-btn {
  padding: 8px 16px;
  background: #f5f5f5;
  color: #666;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.submit-btn {
  padding: 8px 16px;
  background: #2ecc71;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

@media (max-width: 768px) {
  .filters {
    flex-direction: column;
  }
  
  .search-input {
    width: 100%;
  }
  
  .filter-group {
    width: 100%;
  }
  
  .filter-group select {
    width: 100%;
  }
  
  .new-prescription-btn {
    width: 100%;
    justify-content: center;
  }
  
  .medication-inputs {
    grid-template-columns: 1fr;
  }
  
  .prescription-actions {
    flex-direction: column;
  }
  
  .action-btn {
    width: 100%;
    justify-content: center;
  }
}
</style> 