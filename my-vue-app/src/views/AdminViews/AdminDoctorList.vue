<template>
  <div class="admin-doctor-container">
    <div class="container-fluid py-4">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h2>Quản lý bác sĩ</h2>
        <div class="d-flex align-items-center">
          <div class="input-group me-3" style="width: 300px;">
            <input 
              type="text" 
              class="form-control" 
              v-model="searchQuery"
              @input="handleSearch"
              placeholder="Tìm kiếm bác sĩ..."
            >
            <button class="btn btn-outline-secondary" @click="handleSearch">
              <i class="fas fa-search"></i>
            </button>
          </div>
          <button class="btn btn-primary" @click="showAddModal = true">
            <i class="fas fa-plus"></i> Thêm bác sĩ
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

      <!-- Danh sách bác sĩ -->
      <div v-if="!loading && !error" class="card">
        <div class="card-body">
          <div class="table-responsive">
            <table class="table table-hover">
              <thead>
                <tr>
                  <th>Ảnh đại diện</th>
                  <th>Họ tên</th>
                  <th>Chuyên khoa</th>
                  <th>Kinh nghiệm</th>
                  <th>Email</th>
                  <th>Số điện thoại</th>
                  <th>Trạng thái</th>
                  <th>Thao tác</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="filteredDoctors.length === 0">
                  <td colspan="8" class="text-center py-4">
                    <div v-if="searchQuery" class="text-muted">
                      Không tìm thấy bác sĩ nào phù hợp với từ khóa tìm kiếm
                    </div>
                    <div v-else class="text-muted">
                      Chưa có bác sĩ nào
                    </div>
                  </td>
                </tr>
                <tr v-for="doctor in filteredDoctors" :key="doctor._id">
                  <td>
                    <img 
                      :src="doctor.avatar || 'https://via.placeholder.com/50'" 
                      :alt="doctor.fullName"
                      class="doctor-avatar"
                    >
                  </td>
                  <td>{{ doctor.fullName }}</td>
                  <td>{{ doctor.specialty?.name || 'Chưa cập nhật' }}</td>
                  <td>{{ doctor.experience || 0 }} năm</td>
                  <td>{{ doctor.email }}</td>
                  <td>{{ doctor.phone || 'Chưa cập nhật' }}</td>
                  <td>
                    {{ doctor.status  }}
                  </td>
                  <td>
                    <button class="btn btn-sm btn-info me-2" @click="viewDoctor(doctor)">
                      <i class="fas fa-eye"></i>
                    </button>
                    <button class="btn btn-sm btn-primary me-2" @click="editDoctor(doctor)">
                      <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn btn-sm btn-danger" @click="confirmDelete(doctor)">
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

    <!-- Modal thêm bác sĩ -->
    <div class="modal fade" :class="{ show: showAddModal }" v-if="showAddModal" tabindex="-1">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Thêm bác sĩ mới</h5>
            <button type="button" class="btn-close" @click="closeAddModal"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="handleAddSubmit">
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label">Họ tên</label>
                  <input
                    type="text"
                    class="form-control"
                    v-model="addFormData.fullName"
                    required
                    placeholder="Nhập họ tên bác sĩ"
                  />
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Email</label>
                  <input
                    type="email"
                    class="form-control"
                    v-model="addFormData.email"
                    required
                    placeholder="Nhập email bác sĩ"
                  />
                </div>
              </div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label">Số điện thoại</label>
                  <input
                    type="tel"
                    class="form-control"
                    v-model="addFormData.phone"
                    placeholder="Nhập số điện thoại"
                  />
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Kinh nghiệm (năm)</label>
                  <input
                    type="number"
                    class="form-control"
                    v-model="addFormData.experience"
                    min="0"
                    placeholder="Nhập số năm kinh nghiệm"
                  />
                </div>
              </div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label">Ảnh đại diện</label>
                  <input
                    type="file"
                    class="form-control"
                    @change="handleAddAvatarChange"
                    accept="image/*"
                  />
                </div>
              </div>
              <div class="mb-3">
                <div class="form-check">
                  <input
                    type="checkbox"
                    class="form-check-input"
                    v-model="addFormData.isActive"
                  />
                  <label class="form-check-label">Hoạt động</label>
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="closeAddModal">
              Hủy
            </button>
            <button type="button" class="btn btn-primary" @click="handleAddSubmit" :disabled="isSubmitting">
              <span v-if="isSubmitting" class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span>
              {{ isSubmitting ? 'Đang lưu...' : 'Thêm mới' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal sửa bác sĩ -->
    <div class="modal fade" :class="{ show: showEditModal }" v-if="showEditModal" tabindex="-1">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Sửa thông tin bác sĩ</h5>
            <button type="button" class="btn-close" @click="closeEditModal"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="handleEditSubmit">
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label">Họ tên</label>
                  <input
                    type="text"
                    class="form-control"
                    v-model="editFormData.fullName"
                    required
                    placeholder="Nhập họ tên bác sĩ"
                  />
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Email</label>
                  <input
                    type="email"
                    class="form-control"
                    v-model="editFormData.email"
                    required
                    placeholder="Nhập email bác sĩ"
                  />
                </div>
              </div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label">Số điện thoại</label>
                  <input
                    type="tel"
                    class="form-control"
                    v-model="editFormData.phone"
                    placeholder="Nhập số điện thoại"
                  />
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Kinh nghiệm (năm)</label>
                  <input
                    type="number"
                    class="form-control"
                    v-model="editFormData.experience"
                    min="0"
                    placeholder="Nhập số năm kinh nghiệm"
                  />
                </div>
              </div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label">Chuyên khoa</label>
                  <select class="form-select" v-model="editFormData.specialty">
                    <option value="">Chọn chuyên khoa</option>
                    <option v-for="specialty in specialties" :key="specialty._id" :value="specialty._id">
                      {{ specialty.name }}
                    </option>
                  </select>
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Ảnh đại diện</label>
                  <input
                    type="file"
                    class="form-control"
                    @change="handleEditAvatarChange"
                    accept="image/*"
                  />
                </div>
              </div>
              <div class="mb-3">
                <div class="form-check">
                  <input
                    type="checkbox"
                    class="form-check-input"
                    v-model="editFormData.isActive"
                  />
                  <label class="form-check-label">Hoạt động</label>
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="closeEditModal">
              Hủy
            </button>
            <button type="button" class="btn btn-primary" @click="handleEditSubmit" :disabled="isSubmitting">
              <span v-if="isSubmitting" class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span>
              {{ isSubmitting ? 'Đang lưu...' : 'Cập nhật' }}
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
            <p>Bạn có chắc chắn muốn xóa bác sĩ "{{ deletingDoctor?.fullName }}" không?</p>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="showDeleteModal = false">
              Hủy
            </button>
            <button type="button" class="btn btn-danger" @click="deleteDoctor">
              Xóa
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal xem thông tin chi tiết bác sĩ -->
    <div class="modal fade" :class="{ show: showViewModal }" v-if="showViewModal" tabindex="-1">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Thông tin chi tiết bác sĩ</h5>
            <button type="button" class="btn-close" @click="closeViewModal"></button>
          </div>
          <div class="modal-body">
            <div v-if="viewingDoctor" class="row">
              <div class="col-md-4 text-center mb-4">
                <img 
                  :src="viewingDoctor.avatar || 'https://via.placeholder.com/200'" 
                  :alt="viewingDoctor.fullName"
                  class="doctor-detail-avatar mb-3"
                >
                <h4>{{ viewingDoctor.fullName }}</h4>
                <p class="text-muted">{{ viewingDoctor.specialty?.name || 'Chưa cập nhật' }}</p>
              </div>
              <div class="col-md-8">
                <div class="row mb-3">
                  <div class="col-md-6">
                    <h6>Email</h6>
                    <p>{{ viewingDoctor.email }}</p>
                  </div>
                  <div class="col-md-6">
                    <h6>Số điện thoại</h6>
                    <p>{{ viewingDoctor.phone || 'Chưa cập nhật' }}</p>
                  </div>
                </div>
                <div class="row mb-3">
                  <div class="col-md-6">
                    <h6>Kinh nghiệm</h6>
                    <p>{{ viewingDoctor.experience || 0 }} năm</p>
                  </div>
                  <div class="col-md-6">
                    <h6>Trạng thái</h6>
                    <p>
                      <span :class="viewingDoctor.isActive ? 'badge bg-success' : 'badge bg-danger'">
                        {{ viewingDoctor.isActive ? 'Hoạt động' : 'Không hoạt động' }}
                      </span>
                    </p>
                  </div>
                </div>
                <div class="row mb-3">
                  <div class="col-12">
                    <h6>Mô tả</h6>
                    <p>{{ viewingDoctor.description || 'Chưa có mô tả' }}</p>
                  </div>
                </div>
                <div class="row mb-3">
                  <div class="col-12">
                    <h6>Chuyên môn</h6>
                    <p>{{ viewingDoctor.expertise || 'Chưa cập nhật' }}</p>
                  </div>
                </div>
                <div class="row mb-3">
                  <div class="col-12">
                    <h6>Bằng cấp</h6>
                    <p>{{ viewingDoctor.qualification || 'Chưa cập nhật' }}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="closeViewModal">
              Đóng
            </button>
            <button type="button" class="btn btn-primary" @click="editDoctor(viewingDoctor)">
              Chỉnh sửa
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useToast } from 'vue-toastification'
import { doctorService } from '@/services/doctorService'
import { debounce } from 'lodash'

const toast = useToast()

// State
const loading = ref(false)
const error = ref(null)
const doctors = ref([])
const specialties = ref([])
const showAddModal = ref(false)
const showEditModal = ref(false)
const showDeleteModal = ref(false)
const editingDoctor = ref(null)
const deletingDoctor = ref(null)
const searchQuery = ref('')
const isSubmitting = ref(false)
const showViewModal = ref(false)
const viewingDoctor = ref(null)

const addFormData = ref({
  fullName: '',
  email: '',
  phone: '',
  experience: 0,
  avatar: null,
  isActive: true
})

const editFormData = ref({
  fullName: '',
  email: '',
  phone: '',
  experience: 0,
  specialty: '',
  avatar: '',
  isActive: true
})

// Computed
const filteredDoctors = computed(() => {
  if (!searchQuery.value.trim()) return doctors.value
  
  const query = searchQuery.value.toLowerCase()
  return doctors.value.filter(doctor => 
    doctor.fullName.toLowerCase().includes(query) ||
    doctor.email.toLowerCase().includes(query) ||
    (doctor.specialty?.name || '').toLowerCase().includes(query)
  )
})

// Methods
const debouncedSearch = debounce(() => {
  // Filter is handled by computed property
}, 300)

const handleSearch = () => {
  debouncedSearch()
}

const loadDoctors = async () => {
  try {
    loading.value = true
    error.value = null
    doctors.value = await doctorService.getDoctors()
  } catch (err) {
    error.value = 'Không thể tải danh sách bác sĩ. Vui lòng thử lại sau.'
    console.error('Error loading doctors:', err)
    showToast('error', 'Không thể tải danh sách bác sĩ')
  } finally {
    loading.value = false
  }
}

const loadSpecialties = async () => {
  try {
    specialties.value = await doctorService.getSpecialties()
  } catch (err) {
    console.error('Error loading specialties:', err)
    showToast('error', 'Không thể tải danh sách chuyên khoa')
  }
}

const resetAddForm = () => {
  addFormData.value = {
    fullName: '',
    email: '',
    phone: '',
    experience: 0,
    avatar: null,
    isActive: true
  }
}

const resetEditForm = () => {
  editFormData.value = {
    fullName: '',
    email: '',
    phone: '',
    experience: 0,
    specialty: '',
    avatar: '',
    isActive: true
  }
  editingDoctor.value = null
}

const closeAddModal = () => {
  showAddModal.value = false
  resetAddForm()
}

const closeEditModal = () => {
  showEditModal.value = false
  resetEditForm()
}

const editDoctor = (doctor) => {
  editingDoctor.value = doctor
  editFormData.value = { ...doctor }
  showEditModal.value = true
}

const confirmDelete = (doctor) => {
  deletingDoctor.value = doctor
  showDeleteModal.value = true
}

const handleAddAvatarChange = (event) => {
  const file = event.target.files[0]
  if (file) {
    addFormData.value.avatar = file
  }
}

const handleEditAvatarChange = (event) => {
  const file = event.target.files[0]
  if (file) {
    editFormData.value.avatar = file
  }
}

const handleAddSubmit = async () => {
  try {
    isSubmitting.value = true
    const formDataToSend = new FormData()
    Object.keys(addFormData.value).forEach(key => {
      if (key !== 'avatar') {
        formDataToSend.append(key, addFormData.value[key])
      }
    })

    if (addFormData.value.avatar instanceof File) {
      formDataToSend.append('avatar', addFormData.value.avatar)
    }

    await doctorService.createDoctor(formDataToSend)
    showToast('success', 'Thêm bác sĩ thành công')
    closeAddModal()
    await loadDoctors()
  } catch (err) {
    console.error('Error adding doctor:', err)
    showToast('error', err.response?.data?.message || 'Không thể thêm bác sĩ')
  } finally {
    isSubmitting.value = false
  }
}

const handleEditSubmit = async () => {
  try {
    isSubmitting.value = true
    const formDataToSend = new FormData()
    Object.keys(editFormData.value).forEach(key => {
      if (key !== 'avatar') {
        formDataToSend.append(key, editFormData.value[key])
      }
    })

    if (editFormData.value.avatar instanceof File) {
      formDataToSend.append('avatar', editFormData.value.avatar)
    }

    await doctorService.updateDoctor(editingDoctor.value._id, formDataToSend)
    showToast('success', 'Cập nhật thông tin bác sĩ thành công')
    closeEditModal()
    await loadDoctors()
  } catch (err) {
    console.error('Error updating doctor:', err)
    showToast('error', err.response?.data?.message || 'Không thể cập nhật thông tin bác sĩ')
  } finally {
    isSubmitting.value = false
  }
}

const deleteDoctor = async () => {
  try {
    await doctorService.deleteDoctor(deletingDoctor.value._id)
    showDeleteModal.value = false
    deletingDoctor.value = null
    await loadDoctors()
    showToast('success', 'Xóa bác sĩ thành công')
  } catch (err) {
    console.error('Error deleting doctor:', err)
    showToast('error', err.response?.data?.message || 'Không thể xóa bác sĩ')
  }
}

const viewDoctor = (doctor) => {
  viewingDoctor.value = doctor
  showViewModal.value = true
}

const closeViewModal = () => {
  showViewModal.value = false
  viewingDoctor.value = null
}

const showToast = (type, message) => {
  if (type === 'success') {
    toast.success(message)
  } else if (type === 'error') {
    toast.error(message)
  } else if (type === 'warning') {
    toast.warning(message)
  } else {
    toast.info(message)
  }
}

// Lifecycle hooks
onMounted(() => {
  loadDoctors()
  loadSpecialties()
})
</script>

<style scoped>
.admin-doctor-container {
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

.doctor-avatar {
  width: 50px;
  height: 50px;
  object-fit: cover;
  border-radius: 50%;
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

.doctor-detail-avatar {
  width: 200px;
  height: 200px;
  object-fit: cover;
  border-radius: 50%;
  border: 4px solid #fff;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.modal-body h6 {
  color: #6c757d;
  font-weight: 600;
  margin-bottom: 0.5rem;
}

.modal-body p {
  margin-bottom: 1rem;
}
</style> 