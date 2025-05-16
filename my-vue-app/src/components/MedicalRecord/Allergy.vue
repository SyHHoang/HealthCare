<template>
  <div class="allergy-container">
    <!-- Danh sách dị ứng -->
    <div class="list-section">
      <div class="header-actions">
        <h2>Danh sách dị ứng</h2>
        <button @click="showAddForm = true" class="btn-add">
          <i class="fas fa-plus"></i> Thêm mới
        </button>
      </div>

      <div class="table-responsive">
        <table class="table">
          <thead>
            <tr>
              <th>Tác nhân</th>
              <th>Loại</th>
              <th>Mức độ</th>
              <th>Trạng thái</th>
              <th>Thao tác</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="allergy in allergiesHistory" :key="allergy._id">
              <td>{{ allergy.allergen }}</td>
              <td>{{ allergy.type }}</td>
              <td>
                <span :class="['severity-badge', allergy.severity.toLowerCase()]">
                  {{ allergy.severity }}
                </span>
              </td>
              <td>
                <span :class="['status-badge', allergy.isActive ? 'active' : 'inactive']">
                  {{ allergy.isActive ? 'Vẫn còn dị ứng' : 'Đã hết dị ứng' }}
                </span>
              </td>
              <td>
                <div class="action-buttons">
                  <button @click="viewDetails(allergy)" class="btn-view">
                    <i class="fas fa-eye"></i>
                  </button>
                  <button @click="deleteAllergy(allergy._id)" class="btn-delete">
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
    <div v-if="selectedAllergy" class="modal-overlay" @click.self="selectedAllergy = null">
      <div class="modal-content">
        <div class="modal-header">
          <h3>Chi tiết dị ứng</h3>
          <button @click="selectedAllergy = null" class="btn-close">×</button>
        </div>
        <div class="modal-body">
          <div class="detail-item">
            <strong>Tác nhân:</strong> {{ selectedAllergy.allergen }}
          </div>
          <div class="detail-item">
            <strong>Loại:</strong> {{ selectedAllergy.type }}
          </div>
          <div class="detail-item">
            <strong>Mức độ:</strong> {{ selectedAllergy.severity }}
          </div>
          <div class="detail-item">
            <strong>Triệu chứng:</strong>
            <ul>
              <li v-for="(symptom, index) in selectedAllergy.symptoms" :key="index">
                {{ symptom }}
              </li>
            </ul>
          </div>
          <div class="detail-item">
            <strong>Lần đầu xuất hiện:</strong> {{ formatDate(selectedAllergy.firstOccurrence) }}
          </div>
          <div class="detail-item">
            <strong>Lần gần nhất:</strong> {{ formatDate(selectedAllergy.lastOccurrence) }}
          </div>
          <div class="detail-item">
            <strong>Điều trị:</strong> {{ selectedAllergy.treatment }}
          </div>
          <div class="detail-item">
            <strong>Ghi chú:</strong> {{ selectedAllergy.notes }}
          </div>
          <div class="detail-item">
            <strong>Trạng thái:</strong>
            {{ selectedAllergy.isActive ? 'Vẫn còn dị ứng' : 'Đã hết dị ứng' }}
          </div>
        </div>
        <div class="modal-footer">
          <button @click="editAllergy(selectedAllergy)" class="btn-edit">
            <i class="fas fa-edit"></i> Sửa
          </button>
          <button @click="selectedAllergy = null" class="btn-close">
            Đóng
          </button>
        </div>
      </div>
    </div>

    <!-- Form thêm/sửa -->
    <div v-if="showAddForm" class="modal-overlay" @click.self="closeForm">
      <div class="modal-content">
        <div class="modal-header">
          <h3>{{ editingId ? 'Cập nhật dị ứng' : 'Thêm dị ứng mới' }}</h3>
          <button @click="closeForm" class="btn-close">×</button>
        </div>
        <div class="modal-body">
          <form @submit.prevent="submitAllergy">
            <div class="form-group">
              <label for="allergen">Tác nhân gây dị ứng:</label>
              <input
                id="allergen"
                v-model="formData.allergen"
                required
                placeholder="Ví dụ: Đậu phộng, Penicillin..."
              >
            </div>

            <div class="form-group">
              <label for="type">Loại dị ứng:</label>
              <select id="type" v-model="formData.type" required>
                <option value="Thực phẩm">Thực phẩm</option>
                <option value="Thuốc">Thuốc</option>
                <option value="Môi trường">Môi trường</option>
                <option value="Khác">Khác</option>
              </select>
            </div>

            <div class="form-group">
              <label for="severity">Mức độ nghiêm trọng:</label>
              <select id="severity" v-model="formData.severity" required>
                <option value="Nhẹ">Nhẹ</option>
                <option value="Trung bình">Trung bình</option>
                <option value="Nặng">Nặng</option>
                <option value="Nguy hiểm đến tính mạng">Nguy hiểm đến tính mạng</option>
              </select>
            </div>

            <div class="form-group">
              <label>Triệu chứng:</label>
              <div class="symptoms">
                <div v-for="(symptom, index) in formData.symptoms" :key="index" class="symptom-item">
                  <input
                    v-model="formData.symptoms[index]"
                    placeholder="Nhập triệu chứng..."
                  >
                  <button type="button" @click="removeSymptom(index)" class="btn-remove">×</button>
                </div>
                <button type="button" @click="addSymptom" class="btn-add-small">
                  <i class="fas fa-plus"></i> Thêm triệu chứng
                </button>
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label for="firstOccurrence">Lần đầu xuất hiện:</label>
                <input
                  id="firstOccurrence"
                  type="date"
                  v-model="formData.firstOccurrence"
                >
              </div>

              <div class="form-group">
                <label for="lastOccurrence">Lần gần nhất:</label>
                <input
                  id="lastOccurrence"
                  type="date"
                  v-model="formData.lastOccurrence"
                >
              </div>
            </div>

            <div class="form-group">
              <label for="treatment">Điều trị:</label>
              <textarea
                id="treatment"
                v-model="formData.treatment"
                placeholder="Mô tả phương pháp điều trị..."
              ></textarea>
            </div>

            <div class="form-group">
              <label for="notes">Ghi chú:</label>
              <textarea
                id="notes"
                v-model="formData.notes"
                placeholder="Thêm ghi chú nếu có..."
              ></textarea>
            </div>

            <div class="form-group">
              <label class="checkbox-label">
                <input
                  type="checkbox"
                  v-model="formData.isActive"
                >
                Vẫn còn dị ứng
              </label>
            </div>

            <div class="form-actions">
              <button type="submit" class="btn-submit">
                {{ editingId ? 'Cập nhật' : 'Thêm mới' }}
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
import { ref, onMounted } from 'vue';
import axiosInstance from '../../services/axiosInstance.js';
import { useToast } from 'vue-toastification';

const toast = useToast();
const allergiesHistory = ref([]);
const editingId = ref(null);
const selectedAllergy = ref(null);
const showAddForm = ref(false);

const formData = ref({
  allergen: '',
  type: 'Thực phẩm',
  severity: 'Nhẹ',
  symptoms: [''],
  firstOccurrence: '',
  lastOccurrence: '',
  treatment: '',
  notes: '',
  isActive: true
});

const addSymptom = () => {
  formData.value.symptoms.push('');
};

const removeSymptom = (index) => {
  formData.value.symptoms.splice(index, 1);
};

const submitAllergy = async () => {
  try {
    const url = editingId.value 
      ? `/api/medical-record/allergies/${editingId.value}`
      : '/api/medical-record/allergies';
    
    const response = await axiosInstance({
      method: editingId.value ? 'put' : 'post',
      url,
      data: formData.value
    });

    toast.success(response.data.message);
    closeForm();
    fetchAllergies();
  } catch (error) {
    toast.error(error.response?.data?.message || 'Có lỗi xảy ra');
  }
};

const fetchAllergies = async () => {
  try {
    const response = await axiosInstance.get('/api/medical-record/allergies');
    allergiesHistory.value = response.data;
  } catch (error) {
    toast.error('Không thể tải lịch sử dị ứng');
  }
};

const viewDetails = (allergy) => {
  selectedAllergy.value = allergy;
};

const editAllergy = (allergy) => {
  editingId.value = allergy._id;
  formData.value = { ...allergy };
  selectedAllergy.value = null;
  showAddForm.value = true;
};

const deleteAllergy = async (id) => {
  if (!confirm('Bạn có chắc chắn muốn xóa dị ứng này?')) return;
  
  try {
    await axiosInstance.delete(`/api/medical-record/allergies/${id}`);
    toast.success('Xóa thành công');
    fetchAllergies();
  } catch (error) {
    toast.error('Xóa thất bại');
  }
};

const closeForm = () => {
  showAddForm.value = false;
  resetForm();
};

const resetForm = () => {
  formData.value = {
    allergen: '',
    type: 'Thực phẩm',
    severity: 'Nhẹ',
    symptoms: [''],
    firstOccurrence: '',
    lastOccurrence: '',
    treatment: '',
    notes: '',
    isActive: true
  };
  editingId.value = null;
};

const formatDate = (date) => {
  if (!date) return '';
  return new Date(date).toLocaleDateString('vi-VN');
};

onMounted(() => {
  fetchAllergies();
});
</script>

<style scoped>
.allergy-container {
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

.severity-badge {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
}

.severity-badge.nhẹ {
  background: #4CAF50;
  color: white;
}

.severity-badge.trung-bình {
  background: #FFC107;
  color: black;
}

.severity-badge.nặng {
  background: #f44336;
  color: white;
}

.severity-badge.nguy-hiểm-đến-tính-mạng {
  background: #D32F2F;
  color: white;
}

.status-badge {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
}

.status-badge.active {
  background: #4CAF50;
  color: white;
}

.status-badge.inactive {
  background: #9E9E9E;
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
  max-width: 600px;
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

label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
}

input,
select,
textarea {
  width: 100%;
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

textarea {
  min-height: 100px;
  resize: vertical;
}

.symptoms {
  margin-top: 8px;
}

.symptom-item {
  display: flex;
  gap: 8px;
  margin-bottom: 8px;
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

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

.checkbox-label input {
  width: auto;
}
</style> 