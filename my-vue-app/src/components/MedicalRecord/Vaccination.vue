<template>
  <div class="vaccination-container">
    <!-- Danh sách tiêm chủng -->
    <div class="list-section">
      <div class="header-actions">
        <h2>Thông tin tiêm chủng</h2>
        <button @click="showAddForm = true" class="btn-add">
          <i class="fas fa-plus"></i> Thêm mới
        </button>
      </div>

      <div class="table-responsive">
        <table class="table">
          <thead>
            <tr>
              <th>Tên vắc xin</th>
              <th>Loại</th>
              <th>Ngày tiêm</th>
              <th>Trạng thái</th>
              <th>Thao tác</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="vaccination in vaccinations" :key="vaccination._id">
              <td>{{ vaccination.vaccineName }}</td>
              <td>{{ vaccination.vaccineType }}</td>
              <td>{{ formatDate(vaccination.dateAdministered) }}</td>
              <td>
                <span :class="['status-badge', vaccination.status.toLowerCase().replace(' ', '-')]">
                  {{ vaccination.status }}
                </span>
              </td>
              <td>
                <div class="action-buttons">
                  <button @click="viewDetails(vaccination)" class="btn-view">
                    <i class="fas fa-eye"></i>
                  </button>
                  <button @click="deleteVaccination(vaccination._id)" class="btn-delete">
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
    <div v-if="selectedVaccination" class="modal-overlay" @click.self="selectedVaccination = null">
      <div class="modal-content">
        <div class="modal-header">
          <h3>Chi tiết tiêm chủng</h3>
          <button @click="selectedVaccination = null" class="btn-close">×</button>
        </div>
        <div class="modal-body">
          <div class="detail-item">
            <strong>Tên vắc xin:</strong> {{ selectedVaccination.vaccineName }}
          </div>
          <div class="detail-item">
            <strong>Loại:</strong> {{ selectedVaccination.vaccineType }}
          </div>
          <div class="detail-item">
            <strong>Ngày tiêm:</strong> {{ formatDate(selectedVaccination.dateAdministered) }}
          </div>
          <div class="detail-item">
            <strong>Ngày tiêm tiếp theo:</strong> {{ selectedVaccination.nextDoseDate ? formatDate(selectedVaccination.nextDoseDate) : 'Không có' }}
          </div>
          <div class="detail-item">
            <strong>Số lô:</strong> {{ selectedVaccination.batchNumber || 'Không có' }}
          </div>
          <div class="detail-item">
            <strong>Nhà sản xuất:</strong> {{ selectedVaccination.manufacturer || 'Không có' }}
          </div>
          <div class="detail-item" v-if="selectedVaccination.sideEffects?.length">
            <strong>Tác dụng phụ:</strong>
            <ul>
              <li v-for="(effect, index) in selectedVaccination.sideEffects" :key="index">
                {{ effect.description }} ({{ effect.severity }}) - {{ effect.duration }}
              </li>
            </ul>
          </div>
          <div class="detail-item">
            <strong>Ghi chú:</strong> {{ selectedVaccination.notes || 'Không có' }}
          </div>
          <div class="detail-item">
            <strong>Trạng thái:</strong> {{ selectedVaccination.status }}
          </div>
        </div>
        <div class="modal-footer">
          <button @click="editVaccination(selectedVaccination)" class="btn-edit">
            <i class="fas fa-edit"></i> Sửa
          </button>
          <button @click="selectedVaccination = null" class="btn-close">
            Đóng
          </button>
        </div>
      </div>
    </div>

    <!-- Form thêm/sửa -->
    <div v-if="showAddForm" class="modal-overlay" @click.self="closeForm">
      <div class="modal-content">
        <div class="modal-header">
          <h3>{{ formData._id ? 'Cập nhật thông tin' : 'Thêm thông tin mới' }}</h3>
          <button @click="closeForm" class="btn-close">×</button>
        </div>
        <div class="modal-body">
          <form @submit.prevent="handleSubmit">
            <div class="form-group">
              <label>Tên vắc xin</label>
              <input type="text" class="form-control" v-model="formData.vaccineName" required>
            </div>

            <div class="form-group">
              <label>Loại vắc xin</label>
              <select class="form-select" v-model="formData.vaccineType" required>
                <option value="Bắt buộc">Bắt buộc</option>
                <option value="Khuyến nghị">Khuyến nghị</option>
                <option value="Khác">Khác</option>
              </select>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label>Ngày tiêm</label>
                <input type="date" class="form-control" v-model="formData.dateAdministered" required>
              </div>

              <div class="form-group">
                <label>Ngày tiêm mũi tiếp theo</label>
                <input type="date" class="form-control" v-model="formData.nextDoseDate">
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label>Số lô</label>
                <input type="text" class="form-control" v-model="formData.batchNumber">
              </div>

              <div class="form-group">
                <label>Nhà sản xuất</label>
                <input type="text" class="form-control" v-model="formData.manufacturer">
              </div>
            </div>

            <div class="form-group">
              <label>Tác dụng phụ</label>
              <div v-for="(effect, index) in formData.sideEffects" :key="index" class="side-effect-item">
                <div class="form-row">
                  <div class="form-group">
                    <input type="text" class="form-control" v-model="effect.description" placeholder="Mô tả">
                  </div>
                  <div class="form-group">
                    <select class="form-select" v-model="effect.severity">
                      <option value="Nhẹ">Nhẹ</option>
                      <option value="Trung bình">Trung bình</option>
                      <option value="Nặng">Nặng</option>
                    </select>
                  </div>
                  <div class="form-group">
                    <input type="text" class="form-control" v-model="effect.duration" placeholder="Thời gian">
                  </div>
                  <button type="button" @click="removeSideEffect(index)" class="btn-remove">×</button>
                </div>
              </div>
              <button type="button" @click="addSideEffect" class="btn-add-small">
                <i class="fas fa-plus"></i> Thêm tác dụng phụ
              </button>
            </div>

            <div class="form-group">
              <label>Ghi chú</label>
              <textarea class="form-control" v-model="formData.notes"></textarea>
            </div>

            <div class="form-group">
              <label>Trạng thái</label>
              <select class="form-select" v-model="formData.status" required>
                <option value="Đã tiêm">Đã tiêm</option>
                <option value="Đã hoãn">Đã hoãn</option>
                <option value="Đã hủy">Đã hủy</option>
              </select>
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
const vaccinations = ref([])
const selectedVaccination = ref(null)
const showAddForm = ref(false)

const formData = ref({
  vaccineName: '',
  vaccineType: 'Bắt buộc',
  dateAdministered: '',
  nextDoseDate: '',
  batchNumber: '',
  manufacturer: '',
  sideEffects: [],
  notes: '',
  status: 'Đã tiêm'
})

const fetchVaccinations = async () => {
  try {
    const response = await axiosInstance.get('/api/medical-record/vaccinations')
    vaccinations.value = response.data
  } catch (error) {
    toast.error('Lỗi khi tải dữ liệu tiêm chủng')
  }
}

const handleSubmit = async () => {
  try {
    const url = formData.value._id
      ? `/api/medical-record/vaccinations/${formData.value._id}`
      : '/api/medical-record/vaccinations'

    const response = await axiosInstance({
      method: formData.value._id ? 'put' : 'post',
      url,
      data: formData.value
    })

    toast.success(formData.value._id ? 'Cập nhật thành công' : 'Thêm mới thành công')
    closeForm()
    fetchVaccinations()
  } catch (error) {
    toast.error('Lỗi khi lưu thông tin tiêm chủng')
  }
}

const viewDetails = (vaccination) => {
  selectedVaccination.value = vaccination
}

const editVaccination = (vaccination) => {
  formData.value = JSON.parse(JSON.stringify(vaccination))
  selectedVaccination.value = null
  showAddForm.value = true
}

const deleteVaccination = async (id) => {
  if (!confirm('Bạn có chắc chắn muốn xóa thông tin tiêm chủng này?')) return

  try {
    await axiosInstance.delete(`/api/medical-record/vaccinations/${id}`)
    toast.success('Xóa thành công')
    fetchVaccinations()
  } catch (error) {
    toast.error('Lỗi khi xóa thông tin tiêm chủng')
  }
}

const closeForm = () => {
  showAddForm.value = false
  resetForm()
}

const resetForm = () => {
  formData.value = {
    vaccineName: '',
    vaccineType: 'Bắt buộc',
    dateAdministered: '',
    nextDoseDate: '',
    batchNumber: '',
    manufacturer: '',
    sideEffects: [],
    notes: '',
    status: 'Đã tiêm'
  }
}

const addSideEffect = () => {
  formData.value.sideEffects.push({
    description: '',
    severity: 'Nhẹ',
    duration: ''
  })
}

const removeSideEffect = (index) => {
  formData.value.sideEffects.splice(index, 1)
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

onMounted(() => {
  fetchVaccinations()
})
</script>

<style scoped>
.vaccination-container {
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

.status-badge.đã-tiêm {
  background: #4CAF50;
  color: white;
}

.status-badge.đã-hoãn {
  background: #FFC107;
  color: black;
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

.side-effect-item {
  margin-bottom: 12px;
  padding: 12px;
  border: 1px solid #eee;
  border-radius: 4px;
  position: relative;
  background: #f8f9fa;
}

.btn-add-small {
  background: #4CAF50;
  color: white;
  border: none;
  padding: 6px 12px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 12px;
  margin-top: 8px;
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
</style> 