<template>
  <div class="health-data-container">
    <!-- Danh sách dữ liệu sức khỏe -->
    <div class="list-section">
      <div class="header-actions">
        <h2>Dữ liệu sức khỏe</h2>
        <button @click="showAddForm = true" class="btn-add">
          <i class="fas fa-plus"></i> Thêm mới
        </button>
      </div>

      <div class="table-responsive">
        <table class="table">
          <thead>
            <tr>
              <th>Loại dữ liệu</th>
              <th>Giá trị</th>
              <th>Đơn vị</th>
              <th>Thời gian đo</th>
              <th>Thao tác</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="data in healthData" :key="data._id">
              <td>{{ data.dataType }}</td>
              <td>{{ data.value }}</td>
              <td>{{ data.unit }}</td>
              <td>{{ formatDateTime(data.measurementTime) }}</td>
              <td>
                <div class="action-buttons">
                  <button @click="viewDetails(data)" class="btn-view">
                    <i class="fas fa-eye"></i>
                  </button>
                  <button @click="deleteHealthData(data._id)" class="btn-delete">
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
    <div v-if="selectedData" class="modal-overlay" @click.self="selectedData = null">
      <div class="modal-content">
        <div class="modal-header">
          <h3>Chi tiết dữ liệu sức khỏe</h3>
          <button @click="selectedData = null" class="btn-close">×</button>
        </div>
        <div class="modal-body">
          <div class="detail-item">
            <strong>Loại dữ liệu:</strong> {{ selectedData.dataType }}
          </div>
          <div class="detail-item">
            <strong>Giá trị:</strong> {{ selectedData.value }} {{ selectedData.unit }}
          </div>
          <div class="detail-item">
            <strong>Thời gian đo:</strong> {{ formatDateTime(selectedData.measurementTime) }}
          </div>
          <div class="detail-item">
            <strong>Vị trí đo:</strong> {{ selectedData.measurementLocation || 'Không có' }}
          </div>
          <div class="detail-item">
            <strong>Ghi chú:</strong> {{ selectedData.notes || 'Không có' }}
          </div>
        </div>
        <div class="modal-footer">
          <button @click="editHealthData(selectedData)" class="btn-edit">
            <i class="fas fa-edit"></i> Sửa
          </button>
          <button @click="selectedData = null" class="btn-close">
            Đóng
          </button>
        </div>
      </div>
    </div>

    <!-- Form thêm/sửa -->
    <div v-if="showAddForm" class="modal-overlay" @click.self="closeForm">
      <div class="modal-content">
        <div class="modal-header">
          <h3>{{ formData._id ? 'Cập nhật dữ liệu' : 'Thêm dữ liệu mới' }}</h3>
          <button @click="closeForm" class="btn-close">×</button>
        </div>
        <div class="modal-body">
          <form @submit.prevent="handleSubmit">
            <div class="form-group">
              <label class="form-label">Loại dữ liệu</label>
              <select class="form-select" v-model="formData.dataType" required>
                <option value="Huyết áp">Huyết áp</option>
                <option value="Đường huyết">Đường huyết</option>
                <option value="Nhịp tim">Nhịp tim</option>
                <option value="Cân nặng">Cân nặng</option>
                <option value="Chiều cao">Chiều cao</option>
                <option value="Nhiệt độ">Nhiệt độ</option>
                <option value="Khác">Khác</option>
              </select>
            </div>

            <div class="form-group">
              <label class="form-label">Giá trị</label>
              <input type="number" class="form-control" v-model="formData.value" required step="0.01">
            </div>

            <div class="form-group">
              <label class="form-label">Đơn vị</label>
              <input type="text" class="form-control" v-model="formData.unit" required>
            </div>

            <div class="form-group">
              <label class="form-label">Thời gian đo</label>
              <input type="datetime-local" class="form-control" v-model="formData.measurementTime" required>
            </div>

            <div class="form-group">
              <label class="form-label">Vị trí đo</label>
              <input type="text" class="form-control" v-model="formData.measurementLocation">
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
const healthData = ref([]);
const selectedData = ref(null);
const showAddForm = ref(false);

const formData = ref({
  dataType: 'Huyết áp',
  value: '',
  unit: '',
  measurementTime: '',
  measurementLocation: '',
  notes: ''
});

const fetchHealthData = async () => {
  try {
    const response = await axiosInstance.get('/api/medical-record/health-data');
    healthData.value = response.data;
  } catch (error) {
    toast.error('Lỗi khi tải dữ liệu sức khỏe');
  }
};

const handleSubmit = async () => {
  try {
    if (formData.value._id) {
      await axiosInstance.put(`/api/medical-record/health-data/${formData.value._id}`, formData.value);
      toast.success('Cập nhật dữ liệu sức khỏe thành công');
    } else {
      await axiosInstance.post('/api/medical-record/health-data', formData.value);
      toast.success('Thêm dữ liệu sức khỏe thành công');
    }
    closeForm();
    fetchHealthData();
  } catch (error) {
    toast.error('Lỗi khi lưu dữ liệu sức khỏe');
  }
};

const viewDetails = (data) => {
  selectedData.value = data;
};

const editHealthData = (data) => {
  formData.value = { ...data };
  selectedData.value = null;
  showAddForm.value = true;
};

const deleteHealthData = async (id) => {
  if (confirm('Bạn có chắc chắn muốn xóa dữ liệu sức khỏe này?')) {
    try {
      await axiosInstance.delete(`/api/medical-record/health-data/${id}`);
      toast.success('Xóa dữ liệu sức khỏe thành công');
      fetchHealthData();
    } catch (error) {
      toast.error('Lỗi khi xóa dữ liệu sức khỏe');
    }
  }
};

const closeForm = () => {
  showAddForm.value = false;
  resetForm();
};

const resetForm = () => {
  formData.value = {
    dataType: 'Huyết áp',
    value: '',
    unit: '',
    measurementTime: '',
    measurementLocation: '',
    notes: ''
  };
};

const formatDateTime = (dateTime) => {
  if (!dateTime) return '';
  try {
    return new Date(dateTime).toLocaleString('vi-VN');
  } catch (error) {
    console.error('Lỗi định dạng ngày tháng:', error);
    return dateTime;
  }
};

onMounted(() => {
  fetchHealthData();
});
</script>

<style scoped>
.health-data-container {
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