<template>
  <div class="lifestyle-container">
    <!-- Danh sách lối sống -->
    <div class="list-section">
      <div class="header-actions">
        <h2>Thông tin lối sống</h2>
        <button @click="showAddForm = true" class="btn-add">
          <i class="fas fa-plus"></i> Thêm mới
        </button>
      </div>

      <div class="table-responsive">
        <table class="table">
          <thead>
            <tr>
              <th>Loại hoạt động</th>
              <th>Tần suất</th>
              <th>Thời lượng</th>
              <th>Ngày bắt đầu</th>
              <th>Thao tác</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="lifestyle in lifestyles" :key="lifestyle._id">
              <td>{{ lifestyle.activityType }}</td>
              <td>{{ lifestyle.frequency }}</td>
              <td>{{ lifestyle.duration }}</td>
              <td>{{ formatDate(lifestyle.startDate) }}</td>
              <td>
                <div class="action-buttons">
                  <button @click="viewDetails(lifestyle)" class="btn-view">
                    <i class="fas fa-eye"></i>
                  </button>
                  <button @click="deleteLifestyle(lifestyle._id)" class="btn-delete">
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
    <div v-if="selectedLifestyle" class="modal-overlay" @click.self="selectedLifestyle = null">
      <div class="modal-content">
        <div class="modal-header">
          <h3>Chi tiết lối sống</h3>
          <button @click="selectedLifestyle = null" class="btn-close">×</button>
        </div>
        <div class="modal-body">
          <div class="detail-item">
            <strong>Loại hoạt động:</strong> {{ selectedLifestyle.activityType }}
          </div>
          <div class="detail-item">
            <strong>Mô tả:</strong> {{ selectedLifestyle.description }}
          </div>
          <div class="detail-item">
            <strong>Tần suất:</strong> {{ selectedLifestyle.frequency }}
          </div>
          <div class="detail-item">
            <strong>Thời lượng:</strong> {{ selectedLifestyle.duration }}
          </div>
          <div class="detail-item">
            <strong>Ngày bắt đầu:</strong> {{ formatDate(selectedLifestyle.startDate) }}
          </div>
          <div class="detail-item">
            <strong>Ghi chú:</strong> {{ selectedLifestyle.notes || 'Không có' }}
          </div>
        </div>
        <div class="modal-footer">
          <button @click="editLifestyle(selectedLifestyle)" class="btn-edit">
            <i class="fas fa-edit"></i> Sửa
          </button>
          <button @click="selectedLifestyle = null" class="btn-close">
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
              <label class="form-label">Loại hoạt động</label>
              <select class="form-select" v-model="formData.activityType" required>
                <option value="Tập thể dục">Tập thể dục</option>
                <option value="Ăn uống">Ăn uống</option>
                <option value="Giấc ngủ">Giấc ngủ</option>
                <option value="Hút thuốc">Hút thuốc</option>
                <option value="Uống rượu">Uống rượu</option>
                <option value="Khác">Khác</option>
              </select>
            </div>

            <div class="form-group">
              <label class="form-label">Mô tả</label>
              <textarea class="form-control" v-model="formData.description" required></textarea>
            </div>

            <div class="form-group">
              <label class="form-label">Tần suất</label>
              <select class="form-select" v-model="formData.frequency" required>
                <option value="Hàng ngày">Hàng ngày</option>
                <option value="Hàng tuần">Hàng tuần</option>
                <option value="Hàng tháng">Hàng tháng</option>
                <option value="Thỉnh thoảng">Thỉnh thoảng</option>
              </select>
            </div>

            <div class="form-group">
              <label class="form-label">Thời lượng</label>
              <input type="text" class="form-control" v-model="formData.duration" placeholder="Ví dụ: 30 phút, 2 lần/ngày">
            </div>

            <div class="form-group">
              <label class="form-label">Ngày bắt đầu</label>
              <input type="date" class="form-control" v-model="formData.startDate">
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
const lifestyles = ref([]);
const selectedLifestyle = ref(null);
const showAddForm = ref(false);

const formData = ref({
  activityType: 'Tập thể dục',
  description: '',
  frequency: 'Hàng ngày',
  duration: '',
  startDate: '',
  notes: ''
});

const fetchLifestyles = async () => {
  try {
    const response = await axiosInstance.get('/api/medical-record/lifestyles');
    lifestyles.value = response.data;
  } catch (error) {
    toast.error('Lỗi khi tải dữ liệu lối sống');
  }
};

const handleSubmit = async () => {
  try {
    if (formData.value._id) {
      await axiosInstance.put(`/api/medical-record/lifestyles/${formData.value._id}`, formData.value);
      toast.success('Cập nhật thông tin lối sống thành công');
    } else {
      await axiosInstance.post('/api/medical-record/lifestyles', formData.value);
      toast.success('Thêm thông tin lối sống thành công');
    }
    closeForm();
    fetchLifestyles();
  } catch (error) {
    toast.error('Lỗi khi lưu thông tin lối sống');
  }
};

const viewDetails = (lifestyle) => {
  selectedLifestyle.value = lifestyle;
};

const editLifestyle = (lifestyle) => {
  formData.value = { ...lifestyle };
  selectedLifestyle.value = null;
  showAddForm.value = true;
};

const deleteLifestyle = async (id) => {
  if (confirm('Bạn có chắc chắn muốn xóa thông tin lối sống này?')) {
    try {
      await axiosInstance.delete(`/api/medical-record/lifestyles/${id}`);
      toast.success('Xóa thông tin lối sống thành công');
      fetchLifestyles();
    } catch (error) {
      toast.error('Lỗi khi xóa thông tin lối sống');
    }
  }
};

const closeForm = () => {
  showAddForm.value = false;
  resetForm();
};

const resetForm = () => {
  formData.value = {
    activityType: 'Tập thể dục',
    description: '',
    frequency: 'Hàng ngày',
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
  fetchLifestyles();
});
</script>

<style scoped>
.lifestyle-container {
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