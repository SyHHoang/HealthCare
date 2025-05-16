<template>
  <div class="treatment-container">
    <!-- Danh sách phác đồ điều trị -->
    <div class="list-section">
      <div class="header-actions">
        <h2>Phác đồ điều trị</h2>
        <button @click="showAddForm = true" class="btn-add">
          <i class="fas fa-plus"></i> Thêm mới
        </button>
      </div>

      <div class="table-responsive">
        <table class="table">
          <thead>
            <tr>
              <th>Chẩn đoán</th>
              <th>Ngày bắt đầu</th>
              <th>Ngày kết thúc</th>
              <th>Trạng thái</th>
              <th>Thao tác</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="treatment in treatmentsHistory" :key="treatment._id">
              <td>{{ treatment.diagnosis }}</td>
              <td>{{ formatDate(treatment.startDate) }}</td>
              <td>{{ treatment.endDate ? formatDate(treatment.endDate) : 'Chưa kết thúc' }}</td>
              <td>
                <span :class="['status-badge', treatment.status.toLowerCase().replace(' ', '-')]">
                  {{ treatment.status }}
                </span>
              </td>
              <td>
                <div class="action-buttons">
                  <button @click="viewDetails(treatment)" class="btn-view">
                    <i class="fas fa-eye"></i>
                  </button>
                  <button @click="deleteTreatment(treatment._id)" class="btn-delete">
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
    <div v-if="selectedTreatment" class="modal-overlay" @click.self="selectedTreatment = null">
      <div class="modal-content">
        <div class="modal-header">
          <h3>Chi tiết phác đồ điều trị</h3>
          <button @click="selectedTreatment = null" class="btn-close">×</button>
        </div>
        <div class="modal-body">
          <div class="detail-item">
            <strong>Chẩn đoán:</strong> {{ selectedTreatment.diagnosis }}
          </div>
          <div class="detail-item">
            <strong>Kế hoạch điều trị:</strong> {{ selectedTreatment.treatmentPlan }}
          </div>
          <div class="detail-item">
            <strong>Ngày bắt đầu:</strong> {{ formatDate(selectedTreatment.startDate) }}
          </div>
          <div class="detail-item">
            <strong>Ngày kết thúc:</strong> {{ selectedTreatment.endDate ? formatDate(selectedTreatment.endDate) : 'Chưa kết thúc' }}
          </div>
          <div class="detail-item">
            <strong>Trạng thái:</strong> {{ selectedTreatment.status }}
          </div>

          <div v-if="selectedTreatment.medications?.length" class="detail-section">
            <h4>Danh sách thuốc</h4>
            <div v-for="(medicine, index) in selectedTreatment.medications" :key="index" class="detail-card">
              <p><strong>Tên thuốc:</strong> {{ medicine.name }}</p>
              <p><strong>Liều lượng:</strong> {{ medicine.dosage }}</p>
              <p><strong>Tần suất:</strong> {{ medicine.frequency }}</p>
              <p><strong>Thời gian:</strong> {{ medicine.duration }}</p>
            </div>
          </div>

          <div v-if="selectedTreatment.procedures?.length" class="detail-section">
            <h4>Thủ thuật/Phẫu thuật</h4>
            <div v-for="(procedure, index) in selectedTreatment.procedures" :key="index" class="detail-card">
              <p><strong>Tên:</strong> {{ procedure.name }}</p>
              <p v-if="procedure.date"><strong>Ngày thực hiện:</strong> {{ formatDate(procedure.date) }}</p>
              <p v-if="procedure.notes"><strong>Ghi chú:</strong> {{ procedure.notes }}</p>
            </div>
          </div>

          <div v-if="selectedTreatment.followUp" class="detail-section">
            <h4>Hẹn tái khám</h4>
            <div class="detail-card">
              <p v-if="selectedTreatment.followUp.date">
                <strong>Ngày hẹn:</strong> {{ formatDate(selectedTreatment.followUp.date) }}
              </p>
              <p v-if="selectedTreatment.followUp.notes">
                <strong>Ghi chú:</strong> {{ selectedTreatment.followUp.notes }}
              </p>
            </div>
          </div>

          <div v-if="selectedTreatment.notes" class="detail-item">
            <strong>Ghi chú chung:</strong> {{ selectedTreatment.notes }}
          </div>
        </div>
        <div class="modal-footer">
          <button @click="editTreatment(selectedTreatment)" class="btn-edit">
            <i class="fas fa-edit"></i> Sửa
          </button>
          <button @click="selectedTreatment = null" class="btn-close">
            Đóng
          </button>
        </div>
      </div>
    </div>

    <!-- Form thêm/sửa -->
    <div v-if="showAddForm" class="modal-overlay" @click.self="closeForm">
      <div class="modal-content">
        <div class="modal-header">
          <h3>{{ formData._id ? 'Cập nhật phác đồ' : 'Thêm phác đồ mới' }}</h3>
          <button @click="closeForm" class="btn-close">×</button>
        </div>
        <div class="modal-body">
          <form @submit.prevent="submitTreatment">
            <div class="form-group">
              <label>Chẩn đoán</label>
              <textarea class="form-control" v-model="formData.diagnosis" required></textarea>
            </div>

            <div class="form-group">
              <label>Kế hoạch điều trị</label>
              <textarea class="form-control" v-model="formData.treatmentPlan" required></textarea>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label>Ngày bắt đầu</label>
                <input type="date" class="form-control" v-model="formData.startDate" required>
              </div>

              <div class="form-group">
                <label>Ngày kết thúc</label>
                <input type="date" class="form-control" v-model="formData.endDate">
              </div>

              <div class="form-group">
                <label>Trạng thái</label>
                <select class="form-select" v-model="formData.status" required>
                  <option value="Đang điều trị">Đang điều trị</option>
                  <option value="Đã hoàn thành">Đã hoàn thành</option>
                  <option value="Đã hủy">Đã hủy</option>
                </select>
              </div>
            </div>

            <div class="form-section">
              <div class="section-header">
                <h4>Danh sách thuốc</h4>
                <button type="button" @click="addMedicine" class="btn-add-small">
                  <i class="fas fa-plus"></i> Thêm thuốc
                </button>
              </div>
              <div v-for="(medicine, index) in formData.medications" :key="index" class="form-card">
                <button type="button" @click="removeMedicine(index)" class="btn-remove">×</button>
                <div class="form-row">
                  <div class="form-group">
                    <label>Tên thuốc</label>
                    <input type="text" class="form-control" v-model="medicine.name" placeholder="Tên thuốc">
                  </div>
                  <div class="form-group">
                    <label>Liều lượng</label>
                    <input type="text" class="form-control" v-model="medicine.dosage" placeholder="Ví dụ: 1 viên">
                  </div>
                </div>
                <div class="form-row">
                  <div class="form-group">
                    <label>Tần suất</label>
                    <input type="text" class="form-control" v-model="medicine.frequency" placeholder="Ví dụ: 2 lần/ngày">
                  </div>
                  <div class="form-group">
                    <label>Thời gian</label>
                    <input type="text" class="form-control" v-model="medicine.duration" placeholder="Ví dụ: 7 ngày">
                  </div>
                </div>
              </div>
            </div>

            <div class="form-section">
              <div class="section-header">
                <h4>Thủ thuật/Phẫu thuật</h4>
                <button type="button" @click="addProcedure" class="btn-add-small">
                  <i class="fas fa-plus"></i> Thêm thủ thuật
                </button>
              </div>
              <div v-for="(procedure, index) in formData.procedures" :key="index" class="form-card">
                <button type="button" @click="removeProcedure(index)" class="btn-remove">×</button>
                <div class="form-row">
                  <div class="form-group">
                    <label>Tên thủ thuật</label>
                    <input type="text" class="form-control" v-model="procedure.name" placeholder="Tên thủ thuật">
                  </div>
                  <div class="form-group">
                    <label>Ngày thực hiện</label>
                    <input type="date" class="form-control" v-model="procedure.date">
                  </div>
                </div>
                <div class="form-group">
                  <label>Ghi chú</label>
                  <input type="text" class="form-control" v-model="procedure.notes" placeholder="Ghi chú thêm">
                </div>
              </div>
            </div>

            <div class="form-section">
              <h4>Hẹn tái khám</h4>
              <div class="form-row">
                <div class="form-group">
                  <label>Ngày hẹn</label>
                  <input type="date" class="form-control" v-model="formData.followUp.date">
                </div>
                <div class="form-group">
                  <label>Ghi chú</label>
                  <input type="text" class="form-control" v-model="formData.followUp.notes" placeholder="Ghi chú cho lần tái khám">
                </div>
              </div>
            </div>

            <div class="form-group">
              <label>Ghi chú chung</label>
              <textarea class="form-control" v-model="formData.notes" placeholder="Thêm ghi chú nếu có..."></textarea>
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
import axiosInstance from '@/services/axiosInstance'
import { useToast } from 'vue-toastification'

const toast = useToast()
const treatmentsHistory = ref([])
const selectedTreatment = ref(null)
const showAddForm = ref(false)

const formData = ref({
  diagnosis: '',
  treatmentPlan: '',
  startDate: '',
  endDate: '',
  status: 'Đang điều trị',
  medications: [{
    name: '',
    dosage: '',
    frequency: '',
    duration: ''
  }],
  procedures: [{
    name: '',
    date: '',
    notes: ''
  }],
  followUp: {
    date: '',
    notes: ''
  },
  notes: ''
})

const addMedicine = () => {
  formData.value.medications.push({
    name: '',
    dosage: '',
    frequency: '',
    duration: ''
  })
}

const removeMedicine = (index) => {
  formData.value.medications.splice(index, 1)
}

const addProcedure = () => {
  formData.value.procedures.push({
    name: '',
    date: '',
    notes: ''
  })
}

const removeProcedure = (index) => {
  formData.value.procedures.splice(index, 1)
}

const fetchTreatments = async () => {
  try {
    const res = await axiosInstance.get('/api/medical-record/treatments')
    treatmentsHistory.value = res.data
  } catch (err) {
    toast.error('Không thể tải lịch sử điều trị')
  }
}

const submitTreatment = async () => {
  try {
    const url = formData.value._id
      ? `/api/medical-record/treatments/${formData.value._id}`
      : '/api/medical-record/treatments'

    const res = await axiosInstance({
      method: formData.value._id ? 'put' : 'post',
      url,
      data: formData.value
    })

    toast.success(res.data.message)
    closeForm()
    fetchTreatments()
  } catch (err) {
    toast.error(err.response?.data?.message || 'Có lỗi xảy ra')
  }
}

const viewDetails = (treatment) => {
  selectedTreatment.value = treatment
}

const editTreatment = (treatment) => {
  formData.value = JSON.parse(JSON.stringify(treatment))
  selectedTreatment.value = null
  showAddForm.value = true
}

const deleteTreatment = async (id) => {
  if (!confirm('Bạn có chắc chắn muốn xóa phác đồ điều trị này?')) return

  try {
    await axiosInstance.delete(`/api/medical-record/treatments/${id}`)
    toast.success('Xóa thành công')
    fetchTreatments()
  } catch (err) {
    toast.error('Xóa thất bại')
  }
}

const closeForm = () => {
  showAddForm.value = false
  resetForm()
}

const resetForm = () => {
  formData.value = {
    diagnosis: '',
    treatmentPlan: '',
    startDate: '',
    endDate: '',
    status: 'Đang điều trị',
    medications: [{
      name: '',
      dosage: '',
      frequency: '',
      duration: ''
    }],
    procedures: [{
      name: '',
      date: '',
      notes: ''
    }],
    followUp: {
      date: '',
      notes: ''
    },
    notes: ''
  }
}

const formatDate = (date) => {
  if (!date) return ''
  try {
    return format(new Date(date), 'dd/MM/yyyy', { locale: vi })
  } catch (error) {
    console.error('Lỗi định dạng ngày tháng:', error)
    return date
  }
}

onMounted(fetchTreatments)
</script>

<style scoped>
.treatment-container {
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

.status-badge {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
}

.status-badge.đang-điều-trị {
  background: #2196F3;
  color: white;
}

.status-badge.đã-hoàn-thành {
  background: #4CAF50;
  color: white;
}

.status-badge.đã-hủy {
  background: #f44336;
  color: white;
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