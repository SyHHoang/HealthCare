<template>
  <div class="admin-drugs">
    <div class="container py-4">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="page-title">Quản lý thuốc</h1>
        <button class="btn btn-primary" @click="openAddModal">
          <i class="fas fa-plus"></i> Thêm thuốc mới
        </button>
      </div>

      <!-- Search and Filter -->
      <div class="search-section mb-4">
        <div class="row">
          <div class="col-md-8">
            <div class="input-group">
              <input
                type="text"
                class="form-control"
                v-model="searchQuery"
                placeholder="Tìm kiếm thuốc..."
                @keyup.enter="handleSearch"
              />
              <button class="btn btn-outline-secondary" @click="handleSearch">
                <i class="fas fa-search"></i>
              </button>
            </div>
          </div>
          <div class="col-md-4">
            <select class="form-select" v-model="categoryFilter">
              <option value="">Tất cả danh mục</option>
              <option v-for="category in categories" :key="category" :value="category">
                {{ category }}
              </option>
            </select>
          </div>
        </div>
      </div>

      <!-- Loading Spinner -->
      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border text-primary" role="status">
          <span class="visually-hidden">Loading...</span>
        </div>
      </div>

      <!-- Error Message -->
      <div v-if="error" class="alert alert-danger" role="alert">
        {{ error }}
      </div>

      <!-- Drugs Table -->
      <div v-if="!loading && !error" class="table-responsive">
        <table class="table table-striped table-hover">
          <thead>
            <tr>
              <th>Tên thuốc</th>
              <th>Danh mục</th>
              <th>Dạng bào chế</th>
              <th>Hoạt chất</th>
              <th>Nhà sản xuất</th>
              <th>Thao tác</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="drug in drugs" :key="drug._id">
              <td>{{ drug.name }}</td>
              <td>{{ drug.category }}</td>
              <td>{{ drug.type }}</td>
              <td>{{ drug.activeIngredient }}</td>
              <td>{{ drug.manufacturer }}</td>
              <td>
                <button class="btn btn-sm btn-info me-2" @click="editDrug(drug)">
                  <i class="fas fa-edit"></i>
                </button>
                <button class="btn btn-sm btn-danger" @click="deleteDrug(drug._id)">
                  <i class="fas fa-trash"></i>
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Add/Edit Drug Modal -->
      <div class="modal fade" id="drugModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
          <div class="modal-content">
            <div class="modal-header">
              <h5 class="modal-title">{{ isEditing ? 'Chỉnh sửa thuốc' : 'Thêm thuốc mới' }}</h5>
              <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
              <form @submit.prevent="handleSubmit">
                <div class="row">
                  <div class="col-md-6 mb-3">
                    <label class="form-label">Tên thuốc</label>
                    <input type="text" class="form-control" v-model="drugForm.name" required>
                  </div>
                  <div class="col-md-6 mb-3">
                    <label class="form-label">Danh mục</label>
                    <select class="form-select" v-model="drugForm.category" required>
                      <option value="">Chọn danh mục</option>
                      <option v-for="category in categories" :key="category" :value="category">
                        {{ category }}
                      </option>
                    </select>
                  </div>
                </div>
                <div class="row">
                  <div class="col-md-6 mb-3">
                    <label class="form-label">Dạng bào chế</label>
                    <select class="form-select" v-model="drugForm.type" required>
                      <option value="">Chọn dạng bào chế</option>
                      <option v-for="type in types" :key="type" :value="type">
                        {{ type }}
                      </option>
                    </select>
                  </div>
                  <div class="col-md-6 mb-3">
                    <label class="form-label">Hoạt chất</label>
                    <input type="text" class="form-control" v-model="drugForm.activeIngredient" required>
                  </div>
                </div>
                <div class="row">
                  <div class="col-md-6 mb-3">
                    <label class="form-label">Nhà sản xuất</label>
                    <input type="text" class="form-control" v-model="drugForm.manufacturer" required>
                  </div>
                  <div class="col-md-6 mb-3">
                    <label class="form-label">Liều dùng</label>
                    <input type="text" class="form-control" v-model="drugForm.dosage" required>
                  </div>
                </div>
                <div class="mb-3">
                  <label class="form-label">Công dụng</label>
                  <textarea class="form-control" v-model="drugForm.uses" required></textarea>
                </div>
                <div class="mb-3">
                  <label class="form-label">Chống chỉ định</label>
                  <textarea class="form-control" v-model="drugForm.contraindications" required></textarea>
                </div>
                <div class="mb-3">
                  <label class="form-label">Tác dụng phụ</label>
                  <textarea class="form-control" v-model="drugForm.sideEffects" required></textarea>
                </div>
                <div class="modal-footer">
                  <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                  <button type="submit" class="btn btn-primary" :disabled="loading">
                    <span v-if="loading" class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span>
                    {{ isEditing ? 'Cập nhật' : 'Thêm mới' }}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { drugService } from '@/services/drugService'
import { useToast } from 'vue-toastification'

const router = useRouter()
const toast = useToast()

// State
const drugs = ref([])
const loading = ref(false)
const searchQuery = ref('')
const currentPage = ref(1)
const totalPages = ref(1)
const itemsPerPage = ref(10)
const showAddModal = ref(false)
const showEditModal = ref(false)
const showDeleteModal = ref(false)
const selectedDrug = ref(null)
const newDrug = ref({
  name: '',
  description: '',
  usage: '',
  sideEffects: '',
  price: '',
  category: '',
  manufacturer: '',
  image: null
})

// Computed
const filteredDrugs = computed(() => {
  return drugs.value
})

// Methods
const fetchDrugs = async () => {
  try {
    loading.value = true
    const params = {
      page: currentPage.value,
      limit: itemsPerPage.value,
      search: searchQuery.value
    }
    const response = await drugService.getDrugs(params)
    drugs.value = response.data.drugs
    totalPages.value = response.data.totalPages
  } catch (error) {
    console.error('Error fetching drugs:', error)
    toast.error('Có lỗi xảy ra khi tải danh sách thuốc')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  currentPage.value = 1
  fetchDrugs()
}

const handlePageChange = (page) => {
  currentPage.value = page
  fetchDrugs()
}

const openAddModal = () => {
  newDrug.value = {
    name: '',
    description: '',
    usage: '',
    sideEffects: '',
    price: '',
    category: '',
    manufacturer: '',
    image: null
  }
  showAddModal.value = true
}

const openEditModal = (drug) => {
  selectedDrug.value = { ...drug }
  showEditModal.value = true
}

const openDeleteModal = (drug) => {
  selectedDrug.value = drug
  showDeleteModal.value = true
}

const handleAddDrug = async () => {
  try {
    await drugService.createDrug(newDrug.value)
    toast.success('Thêm thuốc thành công')
    showAddModal.value = false
    fetchDrugs()
  } catch (error) {
    console.error('Error adding drug:', error)
    toast.error('Có lỗi xảy ra khi thêm thuốc')
  }
}

const handleEditDrug = async () => {
  try {
    await drugService.updateDrug(selectedDrug.value._id, selectedDrug.value)
    toast.success('Cập nhật thuốc thành công')
    showEditModal.value = false
    fetchDrugs()
  } catch (error) {
    console.error('Error updating drug:', error)
    toast.error('Có lỗi xảy ra khi cập nhật thuốc')
  }
}

const handleDeleteDrug = async () => {
  try {
    await drugService.deleteDrug(selectedDrug.value._id)
    toast.success('Xóa thuốc thành công')
    showDeleteModal.value = false
    fetchDrugs()
  } catch (error) {
    console.error('Error deleting drug:', error)
    toast.error('Có lỗi xảy ra khi xóa thuốc')
  }
}

const handleImageUpload = (event) => {
  const file = event.target.files[0]
  if (file) {
    newDrug.value.image = file
  }
}

// Lifecycle hooks
onMounted(() => {
  fetchDrugs()
})
</script>

<style scoped>
.admin-drugs {
  padding-top: 80px;
}

.page-title {
  color: #2c3e50;
}

.search-section {
  background-color: white;
  padding: 20px;
  border-radius: 10px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.table {
  background-color: white;
  border-radius: 10px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.btn-sm {
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
}
</style> 