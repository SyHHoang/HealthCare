<template>
  <div class="symptoms-container">
    <!-- Danh sách triệu chứng -->
    <div class="list-section">
      <div class="header-actions">
        <h2>Triệu chứng</h2>
        <button @click="showAddForm = true" class="btn-add">
          <i class="fas fa-plus"></i> Thêm mới
        </button>
      </div>

      <div class="table-responsive">
        <table class="table">
          <thead>
            <tr>
              <th>Triệu chứng</th>
              <th>Mức độ</th>
              <th>Thời gian</th>
              <th>Ngày bắt đầu</th>
              <th>Thao tác</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="symptom in symptomsHistory" :key="symptom._id">
              <td>{{ symptom.symptoms }}</td>
              <td>
                <span :class="['severity-badge', symptom.severity]">
                  {{ symptom.severity }}
                </span>
              </td>
              <td>{{ symptom.duration }}</td>
              <td>{{ formatDate(symptom.startDate) }}</td>
              <td>
                <div class="action-buttons">
                  <button @click="viewDetails(symptom)" class="btn-view">
                    <i class="fas fa-eye"></i>
                  </button>
                  <button @click="deleteSymptom(symptom._id)" class="btn-delete">
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
    <div v-if="selectedSymptom" class="modal-overlay" @click.self="selectedSymptom = null">
      <div class="modal-content">
        <div class="modal-header">
          <h3>Chi tiết triệu chứng</h3>
          <button @click="selectedSymptom = null" class="btn-close">×</button>
        </div>
        <div class="modal-body">
          <div class="detail-item">
            <strong>Triệu chứng:</strong> {{ selectedSymptom.symptoms }}
          </div>
          <div class="detail-item">
            <strong>Mức độ:</strong> {{ selectedSymptom.severity }}
          </div>
          <div class="detail-item">
            <strong>Thời gian:</strong> {{ selectedSymptom.duration }}
          </div>
          <div class="detail-item">
            <strong>Ngày bắt đầu:</strong> {{ formatDate(selectedSymptom.startDate) }}
          </div>
          <div class="detail-item">
            <strong>Ghi chú:</strong> {{ selectedSymptom.notes || 'Không có' }}
          </div>
        </div>
        <div class="modal-footer">
          <button @click="editSymptom(selectedSymptom)" class="btn-edit">
            <i class="fas fa-edit"></i> Sửa
          </button>
          <button @click="selectedSymptom = null" class="btn-close">
            Đóng
          </button>
        </div>
      </div>
    </div>

    <!-- Form thêm/sửa -->
    <div v-if="showAddForm" class="modal-overlay" @click.self="closeForm">
      <div class="modal-content">
        <div class="modal-header">
          <h3>{{ formData._id ? 'Cập nhật triệu chứng' : 'Thêm triệu chứng mới' }}</h3>
          <button @click="closeForm" class="btn-close">×</button>
        </div>
        <div class="modal-body">
          <form @submit.prevent="submitSymptoms">
            <div class="form-group">
              <label class="form-label">Triệu chứng</label>
              <textarea class="form-control" v-model="formData.symptoms" required></textarea>
            </div>

            <div class="form-group">
              <label class="form-label">Mức độ nghiêm trọng</label>
              <select class="form-select" v-model="formData.severity" required>
                <option value="Nhẹ">Nhẹ</option>
                <option value="Trung bình">Trung bình</option>
                <option value="Nặng">Nặng</option>
              </select>
            </div>

            <div class="form-group">
              <label class="form-label">Thời gian</label>
              <input type="text" class="form-control" v-model="formData.duration" required>
            </div>

            <div class="form-group">
              <label class="form-label">Ngày bắt đầu</label>
              <input type="date" class="form-control" v-model="formData.startDate" required>
            </div>

            <div class="form-group">
              <label class="form-label">Ghi chú</label>
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
import { ref, onMounted } from 'vue';
import axiosInstance from '../../services/axiosInstance.js';
import { useToast } from 'vue-toastification';

const toast = useToast();
const symptomsHistory = ref([]);
const selectedSymptom = ref(null);
const showAddForm = ref(false);

const formData = ref({
  symptoms: '',
  severity: 'Nhẹ',
  duration: '',
  startDate: '',
  notes: ''
});

const fetchSymptoms = async () => {
  try {
    const response = await axiosInstance.get('/api/medical-record/symptoms');
    symptomsHistory.value = response.data.data;
    console.log("symptomsHistory",symptomsHistory.value);
  } catch (error) {
    toast.error('Lỗi khi tải dữ liệu triệu chứng');
  }
};

const submitSymptoms = async () => {
  try {
    if (formData.value._id) {
      await axiosInstance.put(`/api/medical-record/symptoms/${formData.value._id}`, formData.value);
      toast.success('Cập nhật triệu chứng thành công');
    } else {
      console.log("formData",formData.value);
      await axiosInstance.post('/api/medical-record/symptoms', formData.value);
      
      toast.success('Thêm triệu chứng thành công');
    }
    closeForm();
    fetchSymptoms();
  } catch (error) {
    toast.error('Lỗi khi lưu triệu chứng');
  }
};

const viewDetails = (symptom) => {
  selectedSymptom.value = symptom;
};

const editSymptom = (symptom) => {
  formData.value = { ...symptom };
  selectedSymptom.value = null;
  showAddForm.value = true;
};

const deleteSymptom = async (id) => {
  if (confirm('Bạn có chắc chắn muốn xóa triệu chứng này?')) {
    try {
      await axiosInstance.delete(`/api/medical-record/symptoms/${id}`);
      toast.success('Xóa triệu chứng thành công');
      fetchSymptoms();
    } catch (error) {
      toast.error('Lỗi khi xóa triệu chứng');
    }
  }
};

const closeForm = () => {
  showAddForm.value = false;
  resetForm();
};

const resetForm = () => {
  formData.value = {
    symptoms: '',
    severity: 'Nhẹ',
    duration: '',
    startDate: '',
    notes: ''
  };
};

const formatDate = (date) => {
  if (!date) return '';
  try {
    return new Date(date).toLocaleDateString('vi-VN');
  } catch (error) {
    console.error('Lỗi định dạng ngày tháng:', error);
    return date;
  }
};

onMounted(() => {
  fetchSymptoms();
});
</script>

<style scoped>
.symptoms-container {
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
</style> 