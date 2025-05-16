<template>
  <div class="order-types-container">
    <div class="header">
      <h2>Quản lý loại đơn hàng</h2>
      <button class="add-btn" @click="openAddModal">
        <i class="fas fa-plus"></i>
        Thêm loại đơn hàng
      </button>
    </div>

    <!-- Bảng danh sách loại đơn hàng -->
    <div class="table-container">
      <table class="order-types-table">
        <thead>
          <tr>
            <th>STT</th>
            <th>Tên loại đơn hàng</th>
            <th>Giá (VNĐ)</th>
            <th>Ngày tạo</th>
            <th>Thao tác</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(type, index) in orderTypes" :key="type._id">
            <td>{{ index + 1 }}</td>
            <td>{{ type.name }}</td>
            <td>{{ formatCurrency(type.price) }}</td>
            <td>{{ formatDate(type.createdAt) }}</td>
            <td class="actions">
              <button class="edit-btn" @click="openEditModal(type)">
                <i class="fas fa-edit"></i>
              </button>
              <button class="delete-btn" @click="confirmDelete(type)">
                <i class="fas fa-trash"></i>
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Modal thêm/sửa loại đơn hàng -->
    <div class="modal" v-if="showModal">
      <div class="modal-content">
        <div class="modal-header">
          <h3>{{ isEditing ? 'Sửa loại đơn hàng' : 'Thêm loại đơn hàng' }}</h3>
          <button class="close-btn" @click="closeModal">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label>Tên loại đơn hàng</label>
            <input 
              type="text" 
              v-model="formData.name" 
              placeholder="Nhập tên loại đơn hàng"
            >
          </div>
          <div class="form-group">
            <label>Giá (VNĐ)</label>
            <input 
              type="number" 
              v-model="formData.price" 
              placeholder="Nhập giá"
            >
          </div>
        </div>
        <div class="modal-footer">
          <button class="cancel-btn" @click="closeModal">Hủy</button>
          <button class="save-btn" @click="saveOrderType">
            {{ isEditing ? 'Cập nhật' : 'Thêm mới' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Modal xác nhận xóa -->
    <div class="modal" v-if="showDeleteModal">
      <div class="modal-content delete-modal">
        <div class="modal-header">
          <h3>Xác nhận xóa</h3>
          <button class="close-btn" @click="closeDeleteModal">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="modal-body">
          <p>Bạn có chắc chắn muốn xóa loại đơn hàng này?</p>
        </div>
        <div class="modal-footer">
          <button class="cancel-btn" @click="closeDeleteModal">Hủy</button>
          <button class="delete-btn" @click="deleteOrderType">Xóa</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axiosInstance from '@/services/axiosInstance';
import { format } from 'date-fns';
import { vi } from 'date-fns/locale';

// State
const orderTypes = ref([]);
const showModal = ref(false);
const showDeleteModal = ref(false);
const isEditing = ref(false);
const selectedOrderType = ref(null);
const formData = ref({
  name: '',
  price: ''
});

// Format currency
const formatCurrency = (amount) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND'
  }).format(amount);
};

// Format date
const formatDate = (date) => {
  return format(new Date(date), 'dd/MM/yyyy HH:mm', { locale: vi });
};

// Fetch order types
const fetchOrderTypes = async () => {
  try {
    const response = await axiosInstance.get('/api/order-types');
    orderTypes.value = response.data;
  } catch (error) {
    console.error('Lỗi khi lấy danh sách loại đơn hàng:', error);
  }
};

// Open add modal
const openAddModal = () => {
  isEditing.value = false;
  formData.value = {
    name: '',
    price: ''
  };
  showModal.value = true;
};

// Open edit modal
const openEditModal = (type) => {
  isEditing.value = true;
  selectedOrderType.value = type;
  formData.value = {
    name: type.name,
    price: type.price
  };
  showModal.value = true;
};

// Close modal
const closeModal = () => {
  showModal.value = false;
  formData.value = {
    name: '',
    price: ''
  };
  selectedOrderType.value = null;
};

// Save order type
const saveOrderType = async () => {
  try {
    if (isEditing.value) {
      await axiosInstance.put(`/api/order-types/${selectedOrderType.value._id}`, formData.value);
    } else {
      await axiosInstance.post('/api/order-types', formData.value);
    }
    await fetchOrderTypes();
    closeModal();
  } catch (error) {
    console.error('Lỗi khi lưu loại đơn hàng:', error);
  }
};

// Confirm delete
const confirmDelete = (type) => {
  selectedOrderType.value = type;
  showDeleteModal.value = true;
};

// Close delete modal
const closeDeleteModal = () => {
  showDeleteModal.value = false;
  selectedOrderType.value = null;
};

// Delete order type
const deleteOrderType = async () => {
  try {
    await axiosInstance.delete(`/api/order-types/${selectedOrderType.value._id}`);
    await fetchOrderTypes();
    closeDeleteModal();
  } catch (error) {
    console.error('Lỗi khi xóa loại đơn hàng:', error);
  }
};

onMounted(() => {
  fetchOrderTypes();
});
</script>

<style scoped>
.order-types-container {
  padding: 20px;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.header h2 {
  margin: 0;
  color: #2c3e50;
}

.add-btn {
  background-color: #4CAF50;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 5px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: background-color 0.3s;
}

.add-btn:hover {
  background-color: #45a049;
}

.table-container {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  overflow: hidden;
}

.order-types-table {
  width: 100%;
  border-collapse: collapse;
}

.order-types-table th,
.order-types-table td {
  padding: 12px 15px;
  text-align: left;
  border-bottom: 1px solid #eee;
}

.order-types-table th {
  background-color: #f8f9fa;
  font-weight: 600;
  color: #2c3e50;
}

.actions {
  display: flex;
  gap: 8px;
}

.edit-btn,
.delete-btn {
  background: none;
  border: none;
  padding: 6px;
  cursor: pointer;
  border-radius: 4px;
  transition: background-color 0.3s;
}

.edit-btn {
  color: #2196F3;
}

.delete-btn {
  color: #f44336;
}

.edit-btn:hover {
  background-color: #e3f2fd;
}

.delete-btn:hover {
  background-color: #ffebee;
}

/* Modal styles */
.modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: 8px;
  width: 500px;
  max-width: 90%;
}

.modal-header {
  padding: 15px 20px;
  border-bottom: 1px solid #eee;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-header h3 {
  margin: 0;
  color: #2c3e50;
}

.close-btn {
  background: none;
  border: none;
  font-size: 20px;
  cursor: pointer;
  color: #95a5a6;
}

.modal-body {
  padding: 20px;
}

.form-group {
  margin-bottom: 15px;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  color: #2c3e50;
}

.form-group input {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.modal-footer {
  padding: 15px 20px;
  border-top: 1px solid #eee;
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

.cancel-btn,
.save-btn {
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
  border: none;
}

.cancel-btn {
  background-color: #f5f6fa;
  color: #2c3e50;
}

.save-btn {
  background-color: #2196F3;
  color: white;
}

.delete-modal .modal-content {
  width: 400px;
}

.delete-modal .modal-body {
  text-align: center;
  padding: 30px 20px;
}

.delete-modal .delete-btn {
  background-color: #f44336;
  color: white;
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
  border: none;
}

@media (max-width: 768px) {
  .header {
    flex-direction: column;
    gap: 15px;
    align-items: flex-start;
  }

  .order-types-table {
    display: block;
    overflow-x: auto;
  }
}
</style> 