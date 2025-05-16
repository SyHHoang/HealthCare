<template>
  <div class="prescription-container">
    <!-- Danh sách đơn thuốc -->
    <div class="list-section">
      <div class="header-actions">
        <h2>Danh sách đơn thuốc</h2>
        <button @click="showAddForm = true" class="btn-add">
          <i class="fas fa-plus"></i> Thêm mới
        </button>
      </div>

      <div class="table-responsive">
        <table class="table">
          <thead>
            <tr>
              <th>Chẩn đoán</th>
              <th>Số thuốc</th>
              <th>Ngày kê đơn</th>
              <th>Bác sĩ</th>
              <th>Thao tác</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="prescription in prescriptionsHistory" :key="prescription._id">
              <td>{{ prescription.diagnosis }}</td>
              <td>{{ prescription.medicines.length }}</td>
              <td>{{ formatDate(prescription.date) }}</td>
              <td>{{ prescription.doctorId?.name || 'Không xác định' }}</td>
              <td>
                <div class="action-buttons">
                  <button @click="viewDetails(prescription)" class="btn-view">
                    <i class="fas fa-eye"></i>
                  </button>
                  <button @click="deletePrescription(prescription._id)" class="btn-delete">
                    <i class="fas fa-trash"></i>
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modal xem chi tiết -->
    <div v-if="selectedPrescription" class="modal-overlay" @click.self="selectedPrescription = null">
      <div class="modal-content">
        <div class="modal-header">
          <h3>Chi tiết đơn thuốc</h3>
          <button @click="selectedPrescription = null" class="btn-close">×</button>
        </div>
        <div class="modal-body">
          <div class="detail-item">
            <strong>Chẩn đoán:</strong> {{ selectedPrescription.diagnosis }}
          </div>
          <div class="detail-section">
            <h4>Danh sách thuốc</h4>
            <div v-for="(medicine, index) in selectedPrescription.medicines" :key="index" class="detail-card">
              <p><strong>Tên thuốc:</strong> {{ medicine.name }}</p>
              <p><strong>Liều lượng:</strong> {{ medicine.dosage }}</p>
              <p><strong>Tần suất:</strong> {{ medicine.frequency }}</p>
              <p><strong>Thời gian:</strong> {{ medicine.duration }}</p>
              <p v-if="medicine.notes"><strong>Ghi chú:</strong> {{ medicine.notes }}</p>
            </div>
          </div>
          <div class="detail-item">
            <strong>Ghi chú chung:</strong> {{ selectedPrescription.notes || 'Không có' }}
          </div>
        </div>
        <div class="modal-footer">
          <button @click="editPrescription(selectedPrescription)" class="btn-edit">
            <i class="fas fa-edit"></i> Sửa
          </button>
          <button @click="selectedPrescription = null" class="btn-close">
            Đóng
          </button>
        </div>
      </div>
    </div>

    <!-- Form thêm/sửa -->
    <div v-if="showAddForm" class="modal-overlay" @click.self="closeForm">
      <div class="modal-content">
        <div class="modal-header">
          <h3>{{ formData._id ? 'Cập nhật đơn thuốc' : 'Thêm đơn thuốc mới' }}</h3>
          <button @click="closeForm" class="btn-close">×</button>
        </div>
        <div class="modal-body">
          <form @submit.prevent="submitPrescription">
            <div class="form-group">
              <label>Chẩn đoán</label>
              <textarea class="form-control" v-model="formData.diagnosis" required></textarea>
            </div>

            <div class="form-section">
              <div class="section-header">
                <h4>Danh sách thuốc</h4>
                <button type="button" @click="addMedicine" class="btn-add-small">
                  <i class="fas fa-plus"></i> Thêm thuốc
                </button>
              </div>
              <div v-for="(medicine, index) in formData.medicines" :key="index" class="form-card">
                <button type="button" @click="removeMedicine(index)" class="btn-remove">×</button>
                <div class="form-row">
                  <div class="form-group">
                    <label>Tên thuốc</label>
                    <input type="text" class="form-control" v-model="medicine.name" required>
                  </div>
                  <div class="form-group">
                    <label>Liều lượng</label>
                    <input type="text" class="form-control" v-model="medicine.dosage" required>
                  </div>
                </div>
                <div class="form-row">
                  <div class="form-group">
                    <label>Tần suất</label>
                    <input type="text" class="form-control" v-model="medicine.frequency" required>
                  </div>
                  <div class="form-group">
                    <label>Thời gian</label>
                    <input type="text" class="form-control" v-model="medicine.duration" required>
                  </div>
                </div>
                <div class="form-group">
                  <label>Ghi chú</label>
                  <input type="text" class="form-control" v-model="medicine.notes">
                </div>
              </div>
            </div>

            <div class="form-group">
              <label>Ghi chú chung</label>
              <textarea class="form-control" v-model="formData.notes"></textarea>
            </div>

            <div class="form-actions">
              <button type="submit" class="btn-submit">
                {{ formData._id ? 'Cập nhật' : 'Thêm mới' }}
              </button>
              <button type="button" @click="closeForm" class="btn-cancel">
                Hủy
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { format } from 'date-fns'
import { vi } from 'date-fns/locale'
import axiosInstance from '../../services/axiosInstance.js'
import { useToast } from 'vue-toastification'

const toast = useToast()
const prescriptionsHistory = ref([])
const selectedPrescription = ref(null)
const showAddForm = ref(false)

const formData = ref({
  diagnosis: '',
  medicines: [{
    name: '',
    dosage: '',
    frequency: '',
    duration: '',
    notes: ''
  }],
  notes: ''
})

const fetchPrescriptions = async () => {
  try {
    const response = await axiosInstance.get('/api/medical-record/prescriptions')
    prescriptionsHistory.value = response.data
  } catch (error) {
    toast.error('Không thể tải danh sách đơn thuốc')
  }
}

const submitPrescription = async () => {
  try {
    const url = formData.value._id 
      ? `/api/medical-record/prescriptions/${formData.value._id}`
      : '/api/medical-record/prescriptions'
    
    const response = await axiosInstance({
      method: formData.value._id ? 'put' : 'post',
      url,
      data: formData.value
    })

    toast.success(response.data.message)
    closeForm()
    fetchPrescriptions()
  } catch (error) {
    toast.error(error.response?.data?.message || 'Có lỗi xảy ra khi lưu đơn thuốc')
  }
}

const viewDetails = (prescription) => {
  selectedPrescription.value = prescription
}

const editPrescription = (prescription) => {
  formData.value = JSON.parse(JSON.stringify(prescription))
  selectedPrescription.value = null
  showAddForm.value = true
}

const deletePrescription = async (id) => {
  if (!confirm('Bạn có chắc chắn muốn xóa đơn thuốc này?')) return
  
  try {
    await axiosInstance.delete(`/api/medical-record/prescriptions/${id}`)
    toast.success('Xóa thành công')
    fetchPrescriptions()
  } catch (error) {
    toast.error('Xóa thất bại')
  }
}

const addMedicine = () => {
  formData.value.medicines.push({
    name: '',
    dosage: '',
    frequency: '',
    duration: '',
    notes: ''
  })
}

const removeMedicine = (index) => {
  formData.value.medicines.splice(index, 1)
}

const closeForm = () => {
  showAddForm.value = false
  resetForm()
}

const resetForm = () => {
  formData.value = {
    diagnosis: '',
    medicines: [{
      name: '',
      dosage: '',
      frequency: '',
      duration: '',
      notes: ''
    }],
    notes: ''
  }
}

const formatDate = (date) => {
  if (!date) return ''
  try {
    return format(new Date(date), 'dd/MM/yyyy HH:mm', { locale: vi })
  } catch (error) {
    console.error('Lỗi định dạng ngày tháng:', error)
    return date
  }
}

onMounted(() => {
  fetchPrescriptions()
})
</script>

<style scoped>
.prescription-container {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.header-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.table {
  width: 100%;
  border-collapse: collapse;
  background: white;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.table th,
.table td {
  padding: 12px;
  text-align: left;
  border-bottom: 1px solid #eee;
}

.table th {
  background: #f8f9fa;
  font-weight: 600;
}

.action-buttons {
  display: flex;
  gap: 8px;
}

.btn-view,
.btn-delete {
  padding: 6px 12px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.btn-view {
  background: #2196F3;
  color: white;
}

.btn-delete {
  background: #f44336;
  color: white;
}

.btn-add {
  background: #4CAF50;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0,0,0,0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: 8px;
  width: 90%;
  max-width: 800px;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  padding: 16px;
  border-bottom: 1px solid #eee;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-body {
  padding: 16px;
}

.modal-footer {
  padding: 16px;
  border-top: 1px solid #eee;
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}

.detail-item {
  margin-bottom: 12px;
}

.detail-item strong {
  display: inline-block;
  width: 140px;
}

.detail-section {
  margin-top: 20px;
}

.detail-section h4 {
  margin-bottom: 12px;
  color: #2196F3;
}

.detail-card {
  background: #f8f9fa;
  padding: 12px;
  border-radius: 4px;
  margin-bottom: 8px;
}

.detail-card p {
  margin: 4px 0;
}

.form-group {
  margin-bottom: 16px;
}

.form-row {
  display: flex;
  gap: 16px;
}

.form-row .form-group {
  flex: 1;
}

.form-section {
  margin: 24px 0;
  padding: 16px;
  border: 1px solid #eee;
  border-radius: 4px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.section-header h4 {
  margin: 0;
  color: #2196F3;
}

.form-card {
  background: #f8f9fa;
  padding: 16px;
  border-radius: 4px;
  margin-bottom: 12px;
  position: relative;
}

.form-control {
  width: 100%;
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

textarea.form-control {
  min-height: 100px;
  resize: vertical;
}

.btn-add-small {
  background: #4CAF50;
  color: white;
  border: none;
  padding: 6px 12px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 12px;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 20px;
}

.btn-submit,
.btn-cancel {
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.btn-submit {
  background: #4CAF50;
  color: white;
}

.btn-cancel {
  background: #9E9E9E;
  color: white;
}

.btn-edit {
  background: #2196F3;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
}

.btn-close {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  padding: 0;
  color: #666;
}

.btn-remove {
  position: absolute;
  top: 8px;
  right: 8px;
  background: none;
  border: none;
  font-size: 20px;
  color: #f44336;
  cursor: pointer;
  padding: 0;
}
</style> 