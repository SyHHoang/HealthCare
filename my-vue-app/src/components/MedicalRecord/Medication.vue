<template>
  <div class="medication-container">
    <div class="form-section">
      <h2>Thuốc men</h2>
      <form @submit.prevent="submitMedication">
        <div class="form-group">
          <label for="name">Tên thuốc:</label>
          <input
            id="name"
            v-model="formData.name"
            required
            placeholder="Nhập tên thuốc..."
          >
        </div>

        <div class="form-group">
          <label for="dosage">Liều lượng:</label>
          <input
            id="dosage"
            v-model="formData.dosage"
            required
            placeholder="Ví dụ: 1 viên, 500mg..."
          >
        </div>

        <div class="form-group">
          <label for="frequency">Tần suất:</label>
          <input
            id="frequency"
            v-model="formData.frequency"
            required
            placeholder="Ví dụ: 2 lần/ngày..."
          >
        </div>

        <div class="form-row">
          <div class="form-group">
            <label for="startDate">Ngày bắt đầu:</label>
            <input
              id="startDate"
              type="date"
              v-model="formData.startDate"
              required
            >
          </div>

          <div class="form-group">
            <label for="endDate">Ngày kết thúc:</label>
            <input
              id="endDate"
              type="date"
              v-model="formData.endDate"
            >
          </div>
        </div>

        <div class="form-group">
          <label for="purpose">Mục đích sử dụng:</label>
          <input
            id="purpose"
            v-model="formData.purpose"
            required
            placeholder="Nhập mục đích sử dụng..."
          >
        </div>

        <div class="form-group">
          <label>Tác dụng phụ:</label>
          <div class="side-effects">
            <div v-for="(effect, index) in formData.sideEffects" :key="index" class="side-effect-item">
              <input
                v-model="formData.sideEffects[index]"
                placeholder="Nhập tác dụng phụ..."
              >
              <button type="button" @click="removeSideEffect(index)" class="btn-remove">Xóa</button>
            </div>
            <button type="button" @click="addSideEffect" class="btn-add">Thêm tác dụng phụ</button>
          </div>
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
            Đang sử dụng
          </label>
        </div>

        <button type="submit" class="btn-submit">Lưu</button>
      </form>
    </div>

    <div class="history-section">
      <h3>Lịch sử thuốc</h3>
      <div class="medications-list">
        <div v-for="medication in medicationsHistory" :key="medication._id" class="medication-item">
          <div class="medication-header">
            <span class="date">{{ formatDate(medication.startDate) }}</span>
            <span class="status" :class="{ active: medication.isActive }">
              {{ medication.isActive ? 'Đang sử dụng' : 'Đã ngừng' }}
            </span>
            <div class="actions">
              <button @click="editMedication(medication)" class="btn-edit">Sửa</button>
              <button @click="deleteMedication(medication._id)" class="btn-delete">Xóa</button>
            </div>
          </div>
          <div class="medication-content">
            <p><strong>Tên thuốc:</strong> {{ medication.name }}</p>
            <p><strong>Liều lượng:</strong> {{ medication.dosage }}</p>
            <p><strong>Tần suất:</strong> {{ medication.frequency }}</p>
            <p><strong>Mục đích:</strong> {{ medication.purpose }}</p>
            <p v-if="medication.endDate">
              <strong>Ngày kết thúc:</strong> {{ formatDate(medication.endDate) }}
            </p>
            <div v-if="medication.sideEffects && medication.sideEffects.length">
              <strong>Tác dụng phụ:</strong>
              <ul>
                <li v-for="(effect, index) in medication.sideEffects" :key="index">
                  {{ effect }}
                </li>
              </ul>
            </div>
            <p v-if="medication.notes"><strong>Ghi chú:</strong> {{ medication.notes }}</p>
          </div>
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
const medicationsHistory = ref([]);
const editingId = ref(null);

const formData = ref({
  name: '',
  dosage: '',
  frequency: '',
  startDate: '',
  endDate: '',
  purpose: '',
  sideEffects: [''],
  notes: '',
  isActive: true
});

const addSideEffect = () => {
  formData.value.sideEffects.push('');
};

const removeSideEffect = (index) => {
  formData.value.sideEffects.splice(index, 1);
};

const submitMedication = async () => {
  try {
    const url = editingId.value 
      ? `/api/medical-record/medications/${editingId.value}`
      : '/api/medical-record/medications';
    
    const response = await axiosInstance({
      method: editingId.value ? 'put' : 'post',
      url,
      data: formData.value
    });

    toast.success(response.data.message);
    resetForm();
    fetchMedications();
  } catch (error) {
    toast.error(error.response?.data?.message || 'Có lỗi xảy ra');
    console.log(error);
  }
};

const fetchMedications = async () => {
  try {
    const response = await axiosInstance.get('/api/medical-record/medications');
    console.log(response.data);
    medicationsHistory.value = response.data;
  } catch (error) {
    toast.error('Không thể tải lịch sử thuốc');
    console.log(error);
  }
};

const editMedication = (medication) => {
  editingId.value = medication._id;
  formData.value = { ...medication };
};

const deleteMedication = async (id) => {
  if (!confirm('Bạn có chắc chắn muốn xóa thuốc này?')) return;
  
  try {
    await axiosInstance.delete(`/api/medical-record/medications/${id}`);
    toast.success('Xóa thành công');
    fetchMedications();
  } catch (error) {
    toast.error('Xóa thất bại');
  }
};

const resetForm = () => {
  formData.value = {
    name: '',
    dosage: '',
    frequency: '',
    startDate: '',
    endDate: '',
    purpose: '',
    sideEffects: [''],
    notes: '',
    isActive: true
  };
  editingId.value = null;
};

const formatDate = (date) => {
  return format(new Date(date), 'dd/MM/yyyy', { locale: vi });
};

onMounted(() => {
  fetchMedications();
});
</script>

<style scoped>
.medication-container {
  padding: 20px;
  max-width: 800px;
  margin: 0 auto;
}

.form-section {
  background: #fff;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  margin-bottom: 30px;
}

.form-group {
  margin-bottom: 15px;
}

.form-row {
  display: flex;
  gap: 15px;
}

.form-row .form-group {
  flex: 1;
}

label {
  display: block;
  margin-bottom: 5px;
  font-weight: 500;
}

input, textarea {
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

.side-effects {
  margin-top: 10px;
}

.side-effect-item {
  display: flex;
  gap: 10px;
  margin-bottom: 10px;
}

.side-effect-item input {
  flex: 1;
}

.btn-remove {
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

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
}

.btn-submit {
  background: #4CAF50;
  color: white;
  padding: 10px 20px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 16px;
}

.history-section {
  background: #fff;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.medication-item {
  border-bottom: 1px solid #eee;
  padding: 15px 0;
}

.medication-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.date {
  color: #666;
  font-size: 14px;
}

.status {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
}

.status.active {
  background: #4CAF50;
  color: white;
}

.actions button {
  margin-left: 10px;
  padding: 5px 10px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.btn-edit {
  background: #2196F3;
  color: white;
}

.btn-delete {
  background: #f44336;
  color: white;
}

.medication-content p {
  margin: 5px 0;
  line-height: 1.5;
}

.medication-content ul {
  margin: 5px 0;
  padding-left: 20px;
}

.medication-content li {
  margin: 3px 0;
}
</style> 