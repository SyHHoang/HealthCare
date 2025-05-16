<template>
  <div class="schedule-container">
    <div class="schedule-header">
      <h1>Lịch làm việc</h1>
      <button class="add-btn" @click="showAddModal = true">
        <i class="fas fa-plus"></i> Thêm thời gian làm việc
      </button>
    </div>

    <div class="schedule-table">
      <table>
        <thead>
          <tr>
            <th>Thứ</th>
            <th>Thời gian làm việc</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(day, index) in weekDays" :key="index">
            <td>{{ day.name }}</td>
            <td>
              <div v-if="getWorkingTime(day.name)" class="time-slots">
                <div v-for="(slot, slotIndex) in getWorkingTime(day.name)" :key="slotIndex" class="time-slot">
                  {{ slot.startTime }}
                  <button class="delete-btn" @click="deleteTimeSlot(day.name, slotIndex)">
                    <i class="fas fa-times"></i>
                  </button>
                </div>
              </div>
              <div v-else class="no-time">
                Chưa có thời gian làm việc
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Modal thêm thời gian làm việc -->
    <div v-if="showAddModal" class="modal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>Thêm thời gian làm việc</h2>
          <button class="close-btn" @click="closeModal">×</button>
        </div>
        <form @submit.prevent="addWorkingTime">
          <div class="form-group">
            <label>Thứ</label>
            <select v-model="newTime.day" required>
              <option v-for="day in weekDays" :key="day.name" :value="day.name">
                {{ day.name }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label>Thời gian bắt đầu</label>
            <input type="time" v-model="newTime.startTime" required>
          </div>
          <div class="modal-actions">
            <button type="button" class="btn-cancel" @click="closeModal">Hủy</button>
            <button type="submit" class="btn-submit">Thêm</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axiosInstance from '@/services/axiosInstance'
import { useToast } from 'vue-toastification'

const toast = useToast()
const showAddModal = ref(false)
const workingTimes = ref({})

const weekDays = [
  { name: 'Thứ 2' },
  { name: 'Thứ 3' },
  { name: 'Thứ 4' },
  { name: 'Thứ 5' },
  { name: 'Thứ 6' },
  { name: 'Thứ 7' },
  { name: 'Chủ nhật' }
]

const newTime = ref({
  day: '',
  startTime: ''
})

const getWorkingTime = (day) => {
  return workingTimes.value[day] || []
}

const addWorkingTime = async () => {
  try {
    if (!workingTimes.value[newTime.value.day]) {
      workingTimes.value[newTime.value.day] = [];
    }

    // Kiểm tra xung đột thời gian
    const hasConflict = workingTimes.value[newTime.value.day].some(slot => {
      const [existingHour, existingMinute] = slot.startTime.split(':').map(Number);
      const [newHour, newMinute] = newTime.value.startTime.split(':').map(Number);

      const existingTotalMinutes = existingHour * 60 + existingMinute;
      const newTotalMinutes = newHour * 60 + newMinute;

      // Kiểm tra khoảng cách giữa các thời gian
      return Math.abs(existingTotalMinutes - newTotalMinutes) < 35;
    });

    if (hasConflict) {
      toast.error('Thời gian này phải cách các thời gian khác ít nhất 35 phút');
      return;
    }

    workingTimes.value[newTime.value.day].push({
      startTime: newTime.value.startTime,
    });

    // Gọi API để lưu vào database
    await axiosInstance.post('/api/doctors/schedule', {
      day: newTime.value.day,
      startTime: newTime.value.startTime,
    });

    toast.success('Thêm thời gian làm việc thành công');
    closeModal();
  } catch (error) {
    console.error('Error adding working time:', error);
    toast.error('Có lỗi xảy ra khi thêm thời gian làm việc');
  }
};
const deleteTimeSlot = async (day, index) => {
  try {
    workingTimes.value[day].splice(index, 1)
    
    // Gọi API để xóa trong database
    await axiosInstance.delete(`/api/doctors/schedule/${day}/${index}`)
    
    toast.success('Xóa thời gian làm việc thành công')
  } catch (error) {
    console.error('Error deleting time slot:', error)
    toast.error('Có lỗi xảy ra khi xóa thời gian làm việc')
  }
}

const closeModal = () => {
  showAddModal.value = false
  newTime.value = {
    day: '',
    startTime: ''
  }
}

onMounted(async () => {
  try {
    // Lấy dữ liệu lịch làm việc từ API
    const response = await axiosInstance.get('/api/doctors/schedule')
    workingTimes.value = response.data.schedule
  } catch (error) {
    console.error('Error fetching data:', error)
    toast.error('Có lỗi xảy ra khi tải dữ liệu')
  }
})
</script>

<style scoped>
.schedule-container {
  padding: 20px;
  background: #f8f9fa;
  min-height: 100vh;
}

.schedule-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.schedule-header h1 {
  color: #2c3e50;
  margin: 0;
}

.add-btn {
  padding: 10px 20px;
  background: #3498db;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
}

.schedule-table {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  overflow: hidden;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th, td {
  padding: 15px;
  text-align: left;
  border-bottom: 1px solid #eee;
}

th {
  background: #f8f9fa;
  font-weight: 500;
  color: #2c3e50;
}

.time-slots {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.time-slot {
  background: #e3f2fd;
  padding: 6px 12px;
  border-radius: 4px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.delete-btn {
  background: none;
  border: none;
  color: #666;
  cursor: pointer;
  padding: 0;
}

.no-time {
  color: #666;
  font-style: italic;
}

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
  border-radius: 8px;
  width: 90%;
  max-width: 500px;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
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

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  color: #2c3e50;
}

.form-group input,
.form-group select {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 20px;
}

.btn-cancel {
  padding: 10px 20px;
  background: #f5f5f5;
  border: none;
  border-radius: 4px;
  color: #666;
  cursor: pointer;
}

.btn-submit {
  padding: 10px 20px;
  background: #3498db;
  border: none;
  border-radius: 4px;
  color: white;
  cursor: pointer;
}

@media (max-width: 768px) {
  .schedule-header {
    flex-direction: column;
    gap: 20px;
  }

  .add-btn {
    width: 100%;
    justify-content: center;
  }

  table {
    display: block;
    overflow-x: auto;
  }
}
</style>