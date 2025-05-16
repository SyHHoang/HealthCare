<template>
  <div class="admin-user-list">
    <div class="container">
      <div class="page-header">
        <h2>Quản lý người dùng</h2>
        <p class="text-muted">Danh sách tất cả người dùng trong hệ thống</p>
      </div>

      <div class="card">
        <div class="card-body">
          <!-- Thanh tìm kiếm và nút thêm mới -->
          <div class="d-flex justify-content-between align-items-center mb-4">
            <div class="search-bar">
              <div class="input-group">
                <input 
                  type="text" 
                  class="form-control" 
                  v-model="searchQuery"
                  @input="handleSearch"
                  placeholder="Tìm kiếm theo tên hoặc email..."
                >
                <button class="btn btn-outline-secondary" type="button" @click="handleSearch">
                  <i class="fas fa-search"></i>
                </button>
              </div>
            </div>
            <button class="btn btn-primary" @click="showCreateModal">
              <i class="fas fa-plus"></i> Thêm người dùng
            </button>
          </div>

          <!-- Loading state -->
          <div v-if="isLoading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Đang tải...</span>
            </div>
            <p class="mt-3">Đang tải danh sách người dùng...</p>
          </div>

          <!-- Error state -->
          <div v-else-if="error" class="alert alert-danger" role="alert">
            {{ error }}
          </div>

          <!-- Bảng danh sách người dùng -->
          <div v-else class="table-responsive">
            <table class="table table-hover">
              <thead>
                <tr>
                  <th>ID</th>
                  <th @click="handleSort('fullname')" style="cursor: pointer">
                    Họ tên
                    <i v-if="sortBy === 'fullname'" :class="sortIcon"></i>
                  </th>
                  <th @click="handleSort('email')" style="cursor: pointer">
                    Email
                    <i v-if="sortBy === 'email'" :class="sortIcon"></i>
                  </th>
                  <th @click="handleSort('role')" style="cursor: pointer">
                    Vai trò
                    <i v-if="sortBy === 'role'" :class="sortIcon"></i>
                  </th>
                  <th @click="handleSort('createdAt')" style="cursor: pointer">
                    Ngày tạo
                    <i v-if="sortBy === 'createdAt'" :class="sortIcon"></i>
                  </th>
                  <th @click="handleSort('isActive')" style="cursor: pointer">
                    Trạng thái
                    <i v-if="sortBy === 'isActive'" :class="sortIcon"></i>
                  </th>
                  <th>Thao tác</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="user in paginatedUsers" :key="user._id">
                  <td>{{ user._id }}</td>
                  <td>{{ user.fullname }}</td>
                  <td>{{ user.email }}</td>
                  <td>
                    <span :class="['badge', 
                      user.role === 'admin' ? 'bg-danger' : 
                      user.role === 'doctor' ? 'bg-warning' : 
                      'bg-primary'
                    ]">
                      {{ user.role === 'admin' ? 'Admin' : 
                         user.role === 'doctor' ? 'Bác sĩ' : 
                         'User' }}
                    </span>
                  </td>
                  <td>{{ formatDate(user.createdAt) }}</td>
                  <td>
                    <span :class="['badge', user.isActive ? 'bg-success' : 'bg-secondary']">
                      {{ user.isActive ? 'Đang hoạt động' : 'Đã khóa' }}
                    </span>
                  </td>
                  <td>
                    <div class="btn-group">
                      <button 
                        class="btn btn-sm btn-outline-primary" 
                        @click="viewUserDetails(user)"
                        title="Xem chi tiết"
                      >
                        <i class="fas fa-eye"></i>
                      </button>
                      <button 
                        class="btn btn-sm btn-outline-warning" 
                        @click="editUser(user)"
                        title="Chỉnh sửa"
                      >
                        <i class="fas fa-edit"></i>
                      </button>
                      <button 
                        class="btn btn-sm btn-outline-danger" 
                        @click="confirmDeleteUser(user)"
                        title="Xóa"
                      >
                        <i class="fas fa-trash-can"></i>
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Phân trang -->
          <nav v-if="totalPages > 1" class="mt-4">
            <ul class="pagination justify-content-center">
              <li class="page-item" :class="{ disabled: currentPage === 1 }">
                <a class="page-link" href="#" @click.prevent="changePage(currentPage - 1)">
                  <i class="fas fa-chevron-left"></i>
                </a>
              </li>
              <li 
                v-for="page in totalPages" 
                :key="page"
                class="page-item"
                :class="{ active: currentPage === page }"
              >
                <a class="page-link" href="#" @click.prevent="changePage(page)">{{ page }}</a>
              </li>
              <li class="page-item" :class="{ disabled: currentPage === totalPages }">
                <a class="page-link" href="#" @click.prevent="changePage(currentPage + 1)">
                  <i class="fas fa-chevron-right"></i>
                </a>
              </li>
            </ul>
          </nav>
        </div>
      </div>
    </div>

    <!-- Modal xem chi tiết người dùng -->
    <div class="modal fade" id="viewUserModal" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Thông tin người dùng</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body" v-if="selectedUser">
            <div class="user-info">
              <div class="user-avatar-container">
                <div class="avatar-wrapper">
                  <img 
                    :src="selectedUser.avatar || 'https://ui-avatars.com/api/?name=User&background=FFD700&color=fff&size=150'" 
                    :alt="selectedUser.fullname"
                    class="user-avatar"
                    @error="handleImageError"
                  >
                  <div class="avatar-status" :class="selectedUser.isActive ? 'active' : 'inactive'">
                    <i :class="selectedUser.isActive ? 'fas fa-check' : 'fas fa-times'"></i>
                  </div>
                </div>
                <div class="avatar-info">
                  <h5 class="user-name">{{ selectedUser.fullname }}</h5>
                  <span class="user-role" :class="[
                    selectedUser.role === 'admin' ? 'role-admin' : 
                    selectedUser.role === 'doctor' ? 'role-doctor' : 
                    'role-user'
                  ]">
                    {{ 
                      selectedUser.role === 'admin' ? 'Admin' : 
                      selectedUser.role === 'doctor' ? 'Bác sĩ' : 
                      'Người dùng' 
                    }}
                  </span>
                </div>
              </div>
              <div class="user-details">
                <div class="detail-item">
                  <i class="fas fa-envelope"></i>
                  <span>{{ selectedUser.email }}</span>
                </div>
                <div class="detail-item">
                  <i class="fas fa-birthday-cake"></i>
                  <span>{{ selectedUser.age || 'Chưa cập nhật' }} tuổi</span>
                </div>
                <div class="detail-item">
                  <i class="fas fa-venus-mars"></i>
                  <span>{{ formatGender(selectedUser.gender) }}</span>
                </div>
                <div class="detail-item">
                  <i class="fas fa-phone"></i>
                  <span>{{ selectedUser.phone || 'Chưa cập nhật' }}</span>
                </div>
                <div class="detail-item">
                  <i class="fas fa-calendar-plus"></i>
                  <span>Tham gia: {{ formatDate(selectedUser.createdAt) }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal chỉnh sửa người dùng -->
    <div class="modal fade" id="editUserModal" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Chỉnh sửa thông tin</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="updateUser" v-if="selectedUser">
              <!-- Phần upload ảnh -->
              <div class="mb-4 text-center">
                <div class="avatar-upload-container">
                  <img 
                    :src="editForm.avatar || 'https://ui-avatars.com/api/?name=User&background=FFD700&color=fff&size=150'" 
                    :alt="editForm.fullname"
                    class="avatar-preview"
                    @error="handleImageError"
                  >
                  <div class="avatar-upload-overlay">
                    <label for="avatar-upload" class="avatar-upload-label">
                      <i class="fas fa-camera"></i>
                      <span>Thay đổi ảnh</span>
                    </label>
                    <input 
                      type="file" 
                      id="avatar-upload" 
                      accept="image/*"
                      @change="handleAvatarChange"
                      class="d-none"
                    >
                  </div>
                </div>
                <small class="text-muted d-block mt-2">
                  Hỗ trợ: JPG, PNG, GIF. Tối đa 2MB
                </small>
              </div>

              <div class="mb-3">
                <label class="form-label">Họ tên</label>
                <input type="text" class="form-control" v-model="editForm.fullname" required>
              </div>
              <div class="mb-3">
                <label class="form-label">Email</label>
                <input type="email" class="form-control" v-model="editForm.email" disabled>
              </div>
              <div class="mb-3">
                <label class="form-label">Tuổi</label>
                <input type="number" class="form-control" v-model="editForm.age">
              </div>
              <div class="mb-3">
                <label class="form-label">Giới tính</label>
                <select class="form-select" v-model="editForm.gender">
                  <option value="">Chọn giới tính</option>
                  <option value="male">Nam</option>
                  <option value="female">Nữ</option>
                  <option value="other">Khác</option>
                </select>
              </div>
              <div class="mb-3">
                <label class="form-label">Số điện thoại</label>
                <input type="tel" class="form-control" v-model="editForm.phone">
              </div>
              <div class="mb-3">
                <label class="form-label">Trạng thái</label>
                <div class="form-check">
                  <input class="form-check-input" type="checkbox" v-model="editForm.isActive" id="isActiveCheck">
                  <label class="form-check-label" for="isActiveCheck">
                    Tài khoản đang hoạt động
                  </label>
                </div>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                <button type="submit" class="btn btn-primary" :disabled="isUpdating">
                  {{ isUpdating ? 'Đang cập nhật...' : 'Cập nhật' }}
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal xác nhận xóa -->
    <div class="modal fade" id="deleteModal" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Xác nhận xóa</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body">
            Bạn có chắc chắn muốn xóa người dùng này?
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
            <button type="button" class="btn btn-danger" @click="deleteUser">Xóa</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal tạo người dùng mới -->
    <div class="modal fade" id="createUserModal" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Thêm người dùng mới</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="createUser" v-if="!isCreating">
              <!-- Phần upload ảnh -->
              <div class="mb-4 text-center">
                <div class="avatar-upload-container">
                  <img 
                    :src="createForm.avatar || 'https://ui-avatars.com/api/?name=User&background=FFD700&color=fff&size=150'" 
                    :alt="createForm.fullname"
                    class="avatar-preview"
                    @error="handleImageError"
                  >
                  <div class="avatar-upload-overlay">
                    <label for="create-avatar-upload" class="avatar-upload-label">
                      <i class="fas fa-camera"></i>
                      <span>Thêm ảnh</span>
                    </label>
                    <input 
                      type="file" 
                      id="create-avatar-upload" 
                      accept="image/*"
                      @change="handleCreateAvatarChange"
                      class="d-none"
                    >
                  </div>
                </div>
                <small class="text-muted d-block mt-2">
                  Hỗ trợ: JPG, PNG, GIF. Tối đa 2MB
                </small>
              </div>

              <div class="mb-3">
                <label class="form-label">Họ tên</label>
                <input type="text" class="form-control" v-model="createForm.fullname" required>
              </div>
              <div class="mb-3">
                <label class="form-label">Email</label>
                <input type="email" class="form-control" v-model="createForm.email" required>
              </div>
              <div class="mb-3">
                <label class="form-label">Mật khẩu</label>
                <input type="password" class="form-control" v-model="createForm.password" required>
              </div>
              <div class="mb-3">
                <label class="form-label">Vai trò</label>
                <select class="form-select" v-model="createForm.role" required>
                  <option value="user">Người dùng</option>
                  <option value="admin">Admin</option>
                </select>
              </div>
              <div class="mb-3">
                <label class="form-label">Tuổi</label>
                <input type="number" class="form-control" v-model="createForm.age">
              </div>
              <div class="mb-3">
                <label class="form-label">Giới tính</label>
                <select class="form-select" v-model="createForm.gender">
                  <option value="">Chọn giới tính</option>
                  <option value="male">Nam</option>
                  <option value="female">Nữ</option>
                  <option value="other">Khác</option>
                </select>
              </div>
              <div class="mb-3">
                <label class="form-label">Số điện thoại</label>
                <input type="tel" class="form-control" v-model="createForm.phone">
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                <button type="submit" class="btn btn-primary" :disabled="isCreating">
                  {{ isCreating ? 'Đang tạo...' : 'Tạo người dùng' }}
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useToast } from 'vue-toastification'
import { userService } from '@/services/userService'
import { Modal } from 'bootstrap'

const router = useRouter()
const toast = useToast()

// State
const users = ref([])
const searchQuery = ref('')
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalPages = ref(1)
const totalItems = ref(0)
const selectedUser = ref(null)
const isLoading = ref(false)
const error = ref(null)
const sortBy = ref('fullname')
const sortOrder = ref('asc')

// Form states
const editForm = ref({
  fullname: '',
  email: '',
  age: '',
  gender: '',
  phone: '',
  isActive: true,
  avatar: ''
})

const createForm = ref({
  fullname: '',
  email: '',
  password: '',
  role: 'user',
  age: '',
  gender: '',
  phone: '',
  avatar: '',
  imageId: '',
  delete_token: ''
})

// Modal refs
const deleteModal = ref(null)
const viewModal = ref(null)
const editModal = ref(null)
const createModal = ref(null)

// File refs
const avatarFile = ref(null)
const createAvatarFile = ref(null)

// Loading states
const isUpdating = ref(false)
const isCreating = ref(false)

// Computed
const filteredUsers = computed(() => {
  if (!searchQuery.value) return users.value
  const query = searchQuery.value.toLowerCase()
  return users.value.filter(user => 
    user.fullname.toLowerCase().includes(query) || 
    user.email.toLowerCase().includes(query)
  )
})

const paginatedUsers = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return filteredUsers.value.slice(start, end)
})

const sortIcon = computed(() => {
  return sortOrder.value === 'asc' ? 'fas fa-sort-up' : 'fas fa-sort-down'
})

// Methods
const fetchUsers = async () => {
  try {
    isLoading.value = true
    error.value = null

    const params = {
      page: currentPage.value,
      limit: itemsPerPage.value,
      sort: sortBy.value,
      order: sortOrder.value,
      search: searchQuery.value
    }

    const data = await userService.getUsers(params)
    users.value = data.users
    totalItems.value = data.total
    totalPages.value = data.totalPages
    currentPage.value = data.currentPage
  } catch (err) {
    console.error('Lỗi khi lấy danh sách người dùng:', err)
    if (err.response?.status === 401) {
      error.value = 'Phiên đăng nhập đã hết hạn!'
      setTimeout(() => router.push('/auth/login'), 1500)
    } else if (err.response?.status === 403) {
      error.value = 'Bạn không có quyền truy cập trang này!'
      setTimeout(() => router.push('/'), 1500)
    } else {
      error.value = err.response?.data?.message || 'Có lỗi xảy ra khi lấy danh sách người dùng!'
    }
  } finally {
    isLoading.value = false
  }
}

const formatDate = (date) => {
  return new Date(date).toLocaleDateString('vi-VN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

const formatGender = (gender) => {
  switch (gender) {
    case 'male':
      return 'Nam'
    case 'female':
      return 'Nữ'
    case 'other':
      return 'Khác'
    default:
      return 'Chưa cập nhật'
  }
}

const viewUserDetails = (user) => {
  selectedUser.value = user
  viewModal.value.show()
}

const editUser = (user) => {
  selectedUser.value = user
  editForm.value = {
    fullname: user.fullname,
    email: user.email,
    age: user.age,
    gender: user.gender,
    phone: user.phone,
    isActive: user.isActive,
    avatar: user.avatar
  }
  avatarFile.value = null
  editModal.value.show()
}

const confirmDeleteUser = (user) => {
  selectedUser.value = user
  deleteModal.value.show()
}

const deleteUser = async () => {
  try {
    await userService.deleteUser(selectedUser.value._id)
    deleteModal.value.hide()
    toast.success('Xóa người dùng thành công!')
    fetchUsers()
  } catch (err) {
    console.error('Lỗi khi xóa người dùng:', err)
    if (err.response?.status === 401) {
      toast.error('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại!')
      router.push('/auth/login')
    } else if (err.response?.status === 403) {
      toast.error('Bạn không có quyền xóa người dùng này!')
    } else if (err.response?.status === 404) {
      toast.error('Không tìm thấy người dùng này!')
    } else {
      toast.error(err.response?.data?.message || 'Có lỗi xảy ra khi xóa người dùng!')
    }
  }
}

const handleAvatarChange = (event) => {
  const file = event.target.files[0]
  if (file) {
    if (file.size > 2 * 1024 * 1024) {
      toast.error('Kích thước file quá lớn. Vui lòng chọn file nhỏ hơn 2MB')
      return
    }

    const validTypes = ['image/jpeg', 'image/png', 'image/gif']
    if (!validTypes.includes(file.type)) {
      toast.error('Định dạng file không hợp lệ. Vui lòng chọn file JPG, PNG hoặc GIF')
      return
    }

    avatarFile.value = file
    const reader = new FileReader()
    reader.onload = (e) => {
      editForm.value.avatar = e.target.result
    }
    reader.readAsDataURL(file)
  }
}

const updateUser = async () => {
  try {
    isUpdating.value = true
    const updateData = {
      fullname: editForm.value.fullname,
      age: editForm.value.age,
      gender: editForm.value.gender,
      phone: editForm.value.phone,
      isActive: editForm.value.isActive
    }

    if (avatarFile.value) {
      const imageData = await userService.uploadImage(avatarFile.value)
      updateData.avatar = imageData.url
      updateData.imageId = imageData.id
      updateData.delete_token = imageData.delete_url.split('/').pop()
    }

    await userService.updateUser(selectedUser.value._id, updateData)
    editModal.value.hide()
    toast.success('Cập nhật thông tin người dùng thành công!')
    fetchUsers()
  } catch (err) {
    console.error('Lỗi khi cập nhật thông tin người dùng:', err)
    if (err.response?.status === 401) {
      toast.error('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại!')
      router.push('/auth/login')
    } else if (err.response?.status === 403) {
      toast.error('Bạn không có quyền cập nhật thông tin người dùng này!')
    } else if (err.response?.status === 404) {
      toast.error('Không tìm thấy người dùng này!')
    } else {
      toast.error(err.response?.data?.message || 'Có lỗi xảy ra khi cập nhật thông tin người dùng!')
    }
  } finally {
    isUpdating.value = false
  }
}

const handleSort = (field) => {
  if (sortBy.value === field) {
    sortOrder.value = sortOrder.value === 'asc' ? 'desc' : 'asc'
  } else {
    sortBy.value = field
    sortOrder.value = 'asc'
  }
  fetchUsers()
}

const handleSearch = () => {
  currentPage.value = 1
  fetchUsers()
}

const changePage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    fetchUsers()
  }
}

const handleImageError = (event) => {
  event.target.src = '/default-avatar.png'
}

const showCreateModal = () => {
  createForm.value = {
    fullname: '',
    email: '',
    password: '',
    role: 'user',
    age: '',
    gender: '',
    phone: '',
    avatar: '',
    imageId: '',
    delete_token: ''
  }
  createAvatarFile.value = null
  createModal.value.show()
}

const handleCreateAvatarChange = (event) => {
  const file = event.target.files[0]
  if (file) {
    if (file.size > 2 * 1024 * 1024) {
      toast.error('Kích thước file quá lớn. Vui lòng chọn file nhỏ hơn 2MB')
      return
    }

    const validTypes = ['image/jpeg', 'image/png', 'image/gif']
    if (!validTypes.includes(file.type)) {
      toast.error('Định dạng file không hợp lệ. Vui lòng chọn file JPG, PNG hoặc GIF')
      return
    }

    createAvatarFile.value = file
    const reader = new FileReader()
    reader.onload = (e) => {
      createForm.value.avatar = e.target.result
    }
    reader.readAsDataURL(file)
  }
}

const createUser = async () => {
  try {
    isCreating.value = true
    const userData = {
      fullname: createForm.value.fullname,
      email: createForm.value.email,
      password: createForm.value.password,
      role: createForm.value.role,
      age: createForm.value.age,
      gender: createForm.value.gender,
      phone: createForm.value.phone
    }

    if (createAvatarFile.value) {
      const imageData = await userService.uploadImage(createAvatarFile.value)
      userData.avatar = imageData.url
      userData.imageId = imageData.id
      userData.delete_token = imageData.delete_url.split('/').pop()
    }

    await userService.createUser(userData)
    createModal.value.hide()
    toast.success('Tạo người dùng thành công!')
    fetchUsers()
  } catch (err) {
    console.error('Lỗi khi tạo người dùng:', err)
    if (err.response?.status === 401) {
      toast.error('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại!')
      router.push('/auth/login')
    } else if (err.response?.status === 403) {
      toast.error('Bạn không có quyền tạo người dùng!')
    } else if (err.response?.status === 400) {
      toast.error(err.response.data.message || 'Email đã được sử dụng!')
    } else {
      toast.error(err.response?.data?.message || 'Có lỗi xảy ra khi tạo người dùng!')
    }
  } finally {
    isCreating.value = false
  }
}

// Lifecycle hooks
onMounted(() => {
  fetchUsers()
  deleteModal.value = new Modal(document.getElementById('deleteModal'))
  viewModal.value = new Modal(document.getElementById('viewUserModal'))
  editModal.value = new Modal(document.getElementById('editUserModal'))
  createModal.value = new Modal(document.getElementById('createUserModal'))
})
</script>

<style scoped>
.admin-user-list {
  padding: 20px;
  background-color: #f8f9fa;
  min-height: 100vh;
  width: 100%;
  overflow-x: hidden;
}

.container {
  width: 100%;
  max-width: 100%;
  margin: 0 auto;
  padding: 0;
}

.page-header {
  margin-bottom: 20px;
  text-align: center;
}

.page-header h2 {
  color: #2c3e50;
  margin-bottom: 10px;
  font-size: 1.5rem;
}

.search-bar {
  margin-bottom: 20px;
}

.search-bar .input-group {
  max-width: 100%;
}

.table-responsive {
  width: 100%;
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
  margin: 0;
  padding: 0;
}

.table {
  width: 100%;
  min-width: 800px;
  margin-bottom: 0;
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.table th {
  font-weight: 600;
  color: #495057;
  border-top: none;
  padding: 12px;
  white-space: nowrap;
}

.table td {
  vertical-align: middle;
  padding: 12px;
}

.badge {
  padding: 6px 12px;
  font-weight: 500;
  border-radius: 12px;
}

.btn-group {
  display: flex;
  gap: 5px;
  flex-wrap: nowrap;
}

.btn-sm {
  padding: 4px 8px;
  font-size: 0.875rem;
}

.pagination {
  margin: 20px 0;
  display: flex;
  justify-content: center;
  flex-wrap: wrap;
  gap: 5px;
}

.page-link {
  padding: 6px 12px;
  border-radius: 4px;
  color: #007bff;
  border: 1px solid #dee2e6;
}

.page-item.active .page-link {
  background-color: #007bff;
  border-color: #007bff;
  color: #fff;
}

/* Modal styles */
.modal-dialog {
  max-width: 95%;
  margin: 10px auto;
}

.modal-content {
  border-radius: 8px;
  border: none;
  box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.modal-header {
  border-bottom: 1px solid #dee2e6;
  padding: 15px;
}

.modal-body {
  padding: 15px;
}

.user-avatar-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 20px;
}

.avatar-wrapper {
  position: relative;
  width: 120px;
  height: 120px;
  margin-bottom: 15px;
}

.user-avatar {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  object-fit: cover;
  border: 4px solid #fff;
  box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.avatar-status {
  position: absolute;
  bottom: 5px;
  right: 5px;
  width: 25px;
  height: 25px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid #fff;
}

.avatar-info {
  text-align: center;
}

.user-name {
  font-size: 1.25rem;
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 10px;
}

.user-role {
  display: inline-block;
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 0.875rem;
  font-weight: 500;
}

.user-details {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 15px;
  background-color: #f8f9fa;
  border-radius: 8px;
  padding: 15px;
}

.detail-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px;
  background-color: #fff;
  border-radius: 4px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

.detail-item i {
  width: 20px;
  color: #6c757d;
  font-size: 1rem;
}

.detail-item span {
  color: #495057;
  font-size: 0.875rem;
}

/* Responsive styles */
@media (max-width: 1200px) {
  .table th, .table td {
    padding: 10px;
  }
}

@media (max-width: 992px) {
  .admin-user-list {
    padding: 15px;
  }
  
  .user-details {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .admin-user-list {
    padding: 10px;
  }
  
  .table th, .table td {
    padding: 8px;
  }
  
  .btn-group {
    flex-direction: column;
  }
  
  .user-details {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 576px) {
  .admin-user-list {
    padding: 5px;
  }
  
  .page-header h2 {
    font-size: 1.25rem;
  }
  
  .avatar-wrapper {
    width: 100px;
    height: 100px;
  }
  
  .detail-item {
    padding: 8px;
  }
}

.avatar-upload-container {
  position: relative;
  width: 150px;
  height: 150px;
  margin: 0 auto;
  border-radius: 50%;
  overflow: hidden;
  cursor: pointer;
}

.avatar-preview {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border: 4px solid #fff;
  box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.avatar-upload-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.avatar-upload-container:hover .avatar-upload-overlay {
  opacity: 1;
}

.avatar-upload-label {
  color: #fff;
  text-align: center;
  cursor: pointer;
}

.avatar-upload-label i {
  font-size: 24px;
  margin-bottom: 5px;
}

.avatar-upload-label span {
  display: block;
  font-size: 12px;
}
</style> 