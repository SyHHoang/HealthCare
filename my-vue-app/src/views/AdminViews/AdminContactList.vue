<template>
  <div class="admin-contacts">
    <div class="container-fluid py-4">
      <div class="card">
        <div class="card-header bg-primary text-white">
          <h3 class="mb-0">
            <i class="fas fa-envelope me-2"></i> Quản lý liên hệ
          </h3>
        </div>
        <div class="card-body">
          <!-- Bộ lọc và tìm kiếm -->
          <div class="row mb-4">
            <div class="col-md-6">
              <div class="input-group">
                <input 
                  type="text" 
                  class="form-control" 
                  placeholder="Tìm kiếm theo tên, email..." 
                  v-model="searchQuery"
                >
                <button class="btn btn-outline-primary" type="button" @click="applySearch">
                  <i class="fas fa-search"></i>
                </button>
              </div>
            </div>
            <div class="col-md-3">
              <select class="form-select" v-model="statusFilter">
                <option value="all">Tất cả trạng thái</option>
                <option value="new">Mới</option>
                <option value="in-progress">Đang xử lý</option>
                <option value="completed">Đã xử lý</option>
              </select>
            </div>
            <div class="col-md-3">
              <select class="form-select" v-model="sortOption">
                <option value="newest">Mới nhất trước</option>
                <option value="oldest">Cũ nhất trước</option>
                <option value="name-asc">Tên (A-Z)</option>
                <option value="name-desc">Tên (Z-A)</option>
              </select>
            </div>
          </div>

          <!-- Bảng danh sách liên hệ -->
          <div class="table-responsive">
            <table class="table table-hover table-striped">
              <thead class="table-light">
                <tr>
                  <th>ID</th>
                  <th>Họ và tên</th>
                  <th>Email</th>
                  <th>Số điện thoại</th>
                  <th>Chủ đề</th>
                  <th>Ngày gửi</th>
                  <th>Trạng thái</th>
                  <th>Thao tác</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="loading">
                  <td colspan="8" class="text-center py-4">
                    <div class="spinner-border text-primary" role="status">
                      <span class="visually-hidden">Đang tải...</span>
                    </div>
                  </td>
                </tr>
                <tr v-else-if="contacts.length === 0">
                  <td colspan="8" class="text-center py-4">
                    Không có dữ liệu liên hệ nào
                  </td>
                </tr>
                <tr v-for="contact in contacts" :key="contact._id">
                  <td>{{ contact._id.substring(0, 6) }}...</td>
                  <td>{{ contact.name }}</td>
                  <td>
                    <a :href="`mailto:${contact.email}`">{{ contact.email }}</a>
                  </td>
                  <td>{{ contact.phone || 'N/A' }}</td>
                  <td>{{ contact.subject || 'Không có chủ đề' }}</td>
                  <td>{{ formatDate(contact.createdAt) }}</td>
                  <td>
                    <span class="badge" :class="getStatusBadgeClass(contact.status)">
                      {{ getStatusText(contact.status) }}
                    </span>
                  </td>
                  <td>
                    <div class="btn-group">
                      <button class="btn btn-sm btn-info" @click="viewContact(contact)">
                        <i class="fas fa-eye"></i>
                      </button>
                      <button class="btn btn-sm btn-success" @click="updateStatus(contact, 'completed')" v-if="contact.status !== 'completed'">
                        <i class="fas fa-check"></i>
                      </button>
                      <button class="btn btn-sm btn-warning" @click="updateStatus(contact, 'in-progress')" v-if="contact.status === 'new'">
                        <i class="fas fa-clock"></i>
                      </button>
                      <button class="btn btn-sm btn-danger" @click="deleteContact(contact)">
                        <i class="fas fa-trash"></i>
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Phân trang -->
          <div class="d-flex justify-content-between align-items-center mt-4">
            <div>
              Hiển thị {{ contacts.length }} / {{ totalContacts }} liên hệ
            </div>
            <nav aria-label="Page navigation">
              <ul class="pagination">
                <li class="page-item" :class="{ disabled: currentPage === 1 }">
                  <a class="page-link" href="#" @click.prevent="goToPage(currentPage - 1)">
                    <i class="fas fa-chevron-left"></i>
                  </a>
                </li>
                <li v-for="page in totalPages" :key="page" class="page-item" :class="{ active: currentPage === page }">
                  <a class="page-link" href="#" @click.prevent="goToPage(page)">{{ page }}</a>
                </li>
                <li class="page-item" :class="{ disabled: currentPage === totalPages }">
                  <a class="page-link" href="#" @click.prevent="goToPage(currentPage + 1)">
                    <i class="fas fa-chevron-right"></i>
                  </a>
                </li>
              </ul>
            </nav>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal xem chi tiết liên hệ -->
    <div class="modal fade" id="contactDetailModal" tabindex="-1" aria-hidden="true" ref="contactModal">
      <div class="modal-dialog modal-lg">
        <div class="modal-content" v-if="selectedContact">
          <div class="modal-header">
            <h5 class="modal-title">
              <i class="fas fa-envelope-open-text me-2"></i>
              Chi tiết liên hệ
            </h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <div class="contact-info mb-4">
              <div class="row mb-3">
                <div class="col-md-6">
                  <h6 class="fw-bold mb-1">Họ và tên:</h6>
                  <p>{{ selectedContact.name }}</p>
                </div>
                <div class="col-md-6">
                  <h6 class="fw-bold mb-1">Email:</h6>
                  <p>
                    <a :href="`mailto:${selectedContact.email}`">{{ selectedContact.email }}</a>
                  </p>
                </div>
              </div>
              <div class="row mb-3">
                <div class="col-md-6">
                  <h6 class="fw-bold mb-1">Số điện thoại:</h6>
                  <p>{{ selectedContact.phone || 'Không có' }}</p>
                </div>
                <div class="col-md-6">
                  <h6 class="fw-bold mb-1">Chủ đề:</h6>
                  <p>{{ selectedContact.subject || 'Không có chủ đề' }}</p>
                </div>
              </div>
              <div class="row mb-3">
                <div class="col-md-6">
                  <h6 class="fw-bold mb-1">Ngày gửi:</h6>
                  <p>{{ formatDate(selectedContact.createdAt) }}</p>
                </div>
                <div class="col-md-6">
                  <h6 class="fw-bold mb-1">Trạng thái:</h6>
                  <select class="form-select" v-model="selectedContact.status" @change="updateSelectedContactStatus">
                    <option value="new">Mới</option>
                    <option value="in-progress">Đang xử lý</option>
                    <option value="completed">Đã xử lý</option>
                  </select>
                </div>
              </div>
              <div class="mb-4">
                <h6 class="fw-bold mb-2">Nội dung:</h6>
                <div class="message-content p-3 border rounded bg-light">
                  {{ selectedContact.message }}
                </div>
              </div>
              
              <!-- Phần phản hồi -->
              <h6 class="fw-bold mb-2">Phản hồi:</h6>
              <div class="mb-3">
                <textarea 
                  class="form-control" 
                  rows="4" 
                  placeholder="Nhập nội dung phản hồi..."
                  v-model="replyMessage"
                ></textarea>
              </div>
              <button class="btn btn-primary" @click="sendReply">
                <i class="fas fa-paper-plane me-2"></i> Gửi phản hồi
              </button>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Modal } from 'bootstrap'
import { contactService } from '@/services/contactService'

const router = useRouter()

// Reactive state
const contacts = ref([])
const totalContacts = ref(0)
const loading = ref(true)
const currentPage = ref(1)
const perPage = ref(10)
const searchQuery = ref('')
const statusFilter = ref('all')
const sortOption = ref('newest')
const selectedContact = ref(null)
const contactModal = ref(null)
const replyMessage = ref('')

// Computed
const totalPages = computed(() => {
  return Math.ceil(totalContacts.value / perPage.value)
})

// Methods
const fetchContacts = async () => {
  try {
    loading.value = true
    
    const params = {
      page: currentPage.value,
      limit: perPage.value,
      sort: sortOption.value,
      search: searchQuery.value,
    }
    
    if (statusFilter.value !== 'all') {
      params.status = statusFilter.value
    }
    
    const response = await contactService.getContacts(params)
    contacts.value = response.data.contacts
    totalContacts.value = response.data.total
  } catch (error) {
    console.error('Lỗi khi tải danh sách liên hệ:', error)
    if (error.response && error.response.status === 401) {
      alert('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại!')
      router.push('/auth/login')
    } else {
      alert('Có lỗi xảy ra khi tải danh sách liên hệ. Vui lòng thử lại!')
    }
  } finally {
    loading.value = false
  }
}

const applySearch = () => {
  currentPage.value = 1
  fetchContacts()
}

const goToPage = (page) => {
  if (page < 1 || page > totalPages.value) return
  currentPage.value = page
  fetchContacts()
}

const viewContact = (contact) => {
  selectedContact.value = { ...contact }
  replyMessage.value = ''
  
  if (!contactModal.value) {
    contactModal.value = new Modal(document.getElementById('contactDetailModal'))
  }
  
  contactModal.value.show()
}

const updateStatus = async (contact, status) => {
  if (!confirm(`Bạn có chắc muốn cập nhật trạng thái liên hệ từ "${getStatusText(contact.status)}" thành "${getStatusText(status)}"?`)) {
    return
  }
  
  try {
    await contactService.updateStatus(contact._id, status)
    
    const index = contacts.value.findIndex(c => c._id === contact._id)
    if (index !== -1) {
      contacts.value[index].status = status
    }
    
    alert('Cập nhật trạng thái thành công!')
  } catch (error) {
    console.error('Lỗi khi cập nhật trạng thái:', error)
    alert('Có lỗi xảy ra khi cập nhật trạng thái. Vui lòng thử lại!')
  }
}

const updateSelectedContactStatus = async () => {
  try {
    await contactService.updateStatus(selectedContact.value._id, selectedContact.value.status)
    
    const index = contacts.value.findIndex(c => c._id === selectedContact.value._id)
    if (index !== -1) {
      contacts.value[index].status = selectedContact.value.status
    }
  } catch (error) {
    console.error('Lỗi khi cập nhật trạng thái:', error)
    alert('Có lỗi xảy ra khi cập nhật trạng thái. Vui lòng thử lại!')
  }
}

const deleteContact = async (contact) => {
  if (!confirm('Bạn có chắc chắn muốn xóa liên hệ này?')) {
    return
  }
  
  try {
    await contactService.deleteContact(contact._id)
    
    contacts.value = contacts.value.filter(c => c._id !== contact._id)
    totalContacts.value--
    
    alert('Xóa liên hệ thành công!')
  } catch (error) {
    console.error('Lỗi khi xóa liên hệ:', error)
    alert('Có lỗi xảy ra khi xóa liên hệ. Vui lòng thử lại!')
  }
}

const sendReply = async () => {
  if (!replyMessage.value.trim()) {
    alert('Vui lòng nhập nội dung phản hồi!')
    return
  }
  
  try {
    await contactService.sendReply(selectedContact.value._id, replyMessage.value)
    
    alert('Gửi phản hồi thành công!')
    
    selectedContact.value.status = 'completed'
    await updateSelectedContactStatus()
    
    replyMessage.value = ''
  } catch (error) {
    console.error('Lỗi khi gửi phản hồi:', error)
    alert('Có lỗi xảy ra khi gửi phản hồi. Vui lòng thử lại!')
  }
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  
  const date = new Date(dateString)
  return new Intl.DateTimeFormat('vi-VN', { 
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  }).format(date)
}

const getStatusText = (status) => {
  const statusMap = {
    'new': 'Mới',
    'in-progress': 'Đang xử lý',
    'completed': 'Đã xử lý'
  }
  
  return statusMap[status] || 'Không xác định'
}

const getStatusBadgeClass = (status) => {
  const classMap = {
    'new': 'bg-danger',
    'in-progress': 'bg-warning text-dark',
    'completed': 'bg-success'
  }
  
  return classMap[status] || 'bg-secondary'
}

// Lifecycle hooks
onMounted(() => {
  fetchContacts()
})
</script>

<style scoped>
.admin-contacts {
  margin-top: 80px; /* Điều chỉnh theo header */
  padding-bottom: 2rem;
  min-height: calc(100vh - 80px);
}

.message-content {
  white-space: pre-line;
  max-height: 200px;
  overflow-y: auto;
}

.table th, .table td {
  vertical-align: middle;
}

.btn-group .btn {
  margin-right: 0.2rem;
}
</style> 