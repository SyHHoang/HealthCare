<template>
  <div class="admin-specialty-container">
    <div class="container-fluid py-4">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h2>Quản lý chuyên môn</h2>
        <div class="d-flex align-items-center">
          <div class="input-group me-3" style="width: 300px;">
            <input 
              type="text" 
              class="form-control" 
              v-model="searchQuery"
              @input="handleSearch"
              placeholder="Tìm kiếm chuyên môn..."
            >
            <button class="btn btn-outline-secondary" @click="handleSearch">
              <i class="fas fa-search"></i>
            </button>
          </div>
          <button class="btn btn-primary" @click="showAddModal = true">
            <i class="fas fa-plus"></i> Thêm chuyên môn
          </button>
        </div>
      </div>

      <!-- Loading spinner -->
      <div v-if="loading" class="text-center">
        <div class="spinner-border text-primary" role="status">
          <span class="visually-hidden">Loading...</span>
        </div>
      </div>

      <!-- Error message -->
      <div v-if="error" class="alert alert-danger" role="alert">
        {{ error }}
      </div>

      <!-- Danh sách chuyên môn -->
      <div v-if="!loading && !error" class="card">
        <div class="card-body">
          <div class="table-responsive">
            <table class="table table-hover">
              <thead>
                <tr>
                  <th>Tên chuyên môn</th>
                  <th>Mô tả</th>
                  <th>Số bác sĩ</th>
                  <th>Thao tác</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="filteredSpecialties.length === 0">
                  <td colspan="4" class="text-center py-4">
                    <div v-if="searchQuery" class="text-muted">
                      Không tìm thấy chuyên môn nào phù hợp với từ khóa tìm kiếm
                    </div>
                    <div v-else class="text-muted">
                      Chưa có chuyên môn nào
                    </div>
                  </td>
                </tr>
                <tr v-for="specialty in filteredSpecialties" :key="specialty._id">
                  <td>{{ specialty.name }}</td>
                  <td>{{ specialty.description }}</td>
                  <td>{{ specialty.count || 0 }}</td>
                  <td>
                    <button class="btn btn-sm btn-primary me-2" @click="editSpecialty(specialty)">
                      <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn btn-sm btn-danger" @click="confirmDelete(specialty)">
                      <i class="fas fa-trash"></i>
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal thêm/sửa chuyên môn -->
    <div class="modal fade" :class="{ show: showAddModal }" v-if="showAddModal" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ editingSpecialty ? 'Sửa chuyên môn' : 'Thêm chuyên môn' }}</h5>
            <button type="button" class="btn-close" @click="closeModal"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="handleSubmit">
              <div class="mb-3">
                <label class="form-label">Tên chuyên môn</label>
                <input
                  type="text"
                  class="form-control"
                  v-model="formData.name"
                  required
                />
              </div>
              <div class="mb-3">
                <label class="form-label">Mô tả</label>
                <textarea
                  class="form-control"
                  v-model="formData.description"
                  rows="3"
                  required
                ></textarea>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="closeModal">
              Hủy
            </button>
            <button type="button" class="btn btn-primary" @click="handleSubmit">
              {{ editingSpecialty ? 'Cập nhật' : 'Thêm mới' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal xác nhận xóa -->
    <div class="modal fade" :class="{ show: showDeleteModal }" v-if="showDeleteModal" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Xác nhận xóa</h5>
            <button type="button" class="btn-close" @click="showDeleteModal = false"></button>
          </div>
          <div class="modal-body">
            <p>Bạn có chắc chắn muốn xóa chuyên môn "{{ deletingSpecialty?.name }}" không?</p>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="showDeleteModal = false">
              Hủy
            </button>
            <button type="button" class="btn btn-danger" @click="deleteSpecialty">
              Xóa
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, inject, computed } from 'vue';
import { specialtyService } from '@/services/specialtyService';
import { debounce } from 'lodash';

const toast = inject('$toast', null);
const loading = ref(false);
const error = ref(null);
const specialties = ref([]);
const showAddModal = ref(false);
const showDeleteModal = ref(false);
const editingSpecialty = ref(null);
const deletingSpecialty = ref(null);
const searchQuery = ref('');

const formData = ref({
  name: '',
  description: ''
});

// Hàm tính khoảng cách Levenshtein
const levenshteinDistance = (str1, str2) => {
  const m = str1.length;
  const n = str2.length;
  const dp = Array(m + 1).fill().map(() => Array(n + 1).fill(0));

  for (let i = 0; i <= m; i++) dp[i][0] = i;
  for (let j = 0; j <= n; j++) dp[0][j] = j;

  for (let i = 1; i <= m; i++) {
    for (let j = 1; j <= n; j++) {
      if (str1[i - 1] === str2[j - 1]) {
        dp[i][j] = dp[i - 1][j - 1];
      } else {
        dp[i][j] = Math.min(
          dp[i - 1][j - 1] + 1, // Thay thế
          dp[i - 1][j] + 1,     // Xóa
          dp[i][j - 1] + 1      // Thêm
        );
      }
    }
  }
  return dp[m][n];
};

// Hàm kiểm tra chuỗi có chứa từ khóa tìm kiếm gần đúng không
const fuzzyMatch = (text, searchQuery) => {
  if (!searchQuery) return true;
  
  const searchWords = searchQuery.toLowerCase().split(' ');
  const textLower = text.toLowerCase();
  
  // Kiểm tra từng từ trong từ khóa tìm kiếm
  return searchWords.every(word => {
    // Nếu từ khóa quá ngắn, tìm kiếm chính xác
    if (word.length <= 2) {
      return textLower.includes(word);
    }
    
    // Tìm kiếm gần đúng cho từ khóa dài hơn
    const maxDistance = Math.floor(word.length / 3); // Cho phép sai số 1/3 độ dài từ
    const words = textLower.split(' ');
    
    return words.some(textWord => {
      const distance = levenshteinDistance(word, textWord);
      return distance <= maxDistance;
    });
  });
};

// Computed property for filtered specialties
const filteredSpecialties = computed(() => {
  if (!searchQuery.value.trim()) return specialties.value;
  
  const query = searchQuery.value.trim();
  return specialties.value.filter(specialty => 
    fuzzyMatch(specialty.name, query) ||
    fuzzyMatch(specialty.description, query)
  );
});

// Debounced search function
const debouncedSearch = debounce(() => {
  // Filter is handled by computed property
}, 300);

const handleSearch = () => {
  debouncedSearch();
};

const loadSpecialties = async () => {
  try {
    loading.value = true;
    error.value = null;
    specialties.value = await specialtyService.getAllSpecialties();
  } catch (err) {
    error.value = 'Không thể tải danh sách chuyên môn. Vui lòng thử lại sau.';
    console.error('Error loading specialties:', err);
    showToast('error', 'Không thể tải danh sách chuyên môn');
  } finally {
    loading.value = false;
  }
};

const resetForm = () => {
  formData.value = {
    name: '',
    description: ''
  };
  editingSpecialty.value = null;
};

const closeModal = () => {
  showAddModal.value = false;
  resetForm();
};

const editSpecialty = (specialty) => {
  editingSpecialty.value = specialty;
  formData.value = { ...specialty };
  showAddModal.value = true;
};

const confirmDelete = (specialty) => {
  deletingSpecialty.value = specialty;
  showDeleteModal.value = true;
};

const handleSubmit = async () => {
  try {
    if (editingSpecialty.value) {
      await specialtyService.updateSpecialty(editingSpecialty.value._id, formData.value);
      showToast('success', 'Cập nhật chuyên môn thành công');
    } else {
      await specialtyService.createSpecialty(formData.value);
      showToast('success', 'Thêm chuyên môn thành công');
    }
    closeModal();
    loadSpecialties();
  } catch (err) {
    error.value = 'Không thể lưu chuyên môn. Vui lòng thử lại sau.';
    console.error('Error saving specialty:', err);
    showToast('error', 'Không thể lưu chuyên môn');
  }
};

const deleteSpecialty = async () => {
  try {
    await specialtyService.deleteSpecialty(deletingSpecialty.value._id);
    showDeleteModal.value = false;
    deletingSpecialty.value = null;
    loadSpecialties();
    showToast('success', 'Xóa chuyên môn thành công');
  } catch (err) {
    error.value = 'Không thể xóa chuyên môn. Vui lòng thử lại sau.';
    console.error('Error deleting specialty:', err);
    showToast('error', 'Không thể xóa chuyên môn');
  }
};

// Hiển thị toast
const showToast = (severity, message) => {
  if (toast) {
    toast.add({
      severity,
      summary: severity === 'success' ? 'Thành công' : 'Lỗi',
      detail: message,
      life: 3000
    });
  } else {
    alert(message);
  }
};

onMounted(() => {
  loadSpecialties();
});
</script>

<style scoped>
.admin-specialty-container {
  padding: 20px;
}

.modal {
  background-color: rgba(0, 0, 0, 0.5);
}

.modal.show {
  display: block;
}

.table th {
  background-color: #f8f9fa;
}

.btn-sm {
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
}

.input-group {
  max-width: 300px;
}

.input-group input {
  border-right: none;
}

.input-group .btn {
  border-left: none;
  background-color: transparent;
}

.input-group .btn:hover {
  background-color: #f8f9fa;
}
</style> 