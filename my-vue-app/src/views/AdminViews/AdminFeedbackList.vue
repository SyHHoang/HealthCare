<template>
  <div class="admin-feedback-list">
    <div class="container py-5">
      <h2 class="section-title mb-4">Quản Lý Đánh Giá</h2>
      
      <!-- Bộ lọc -->
      <div class="filters mb-4">
        <div class="row g-3">
          <div class="col-md-3">
            <select class="form-select" v-model="filters.rating">
              <option value="">Tất cả đánh giá</option>
              <option v-for="i in 5" :key="i" :value="i">{{ i }} sao</option>
            </select>
          </div>
          <div class="col-md-3">
            <select class="form-select" v-model="filters.service">
              <option value="">Tất cả dịch vụ</option>
              <option v-for="(label, value) in serviceOptions" :key="value" :value="value">
                {{ label }}
              </option>
            </select>
          </div>
          <div class="col-md-6">
            <div class="input-group">
              <input 
                type="text" 
                class="form-control" 
                v-model="searchQuery"
                @keyup.enter="handleSearch"
                placeholder="Tìm kiếm theo tiêu đề hoặc nội dung..."
              >
              <button class="btn btn-primary" @click="handleSearch">
                <i class="fas fa-search"></i>
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Loading & Error states -->
      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border text-primary"></div>
      </div>

      <div v-else-if="error" class="alert alert-danger">{{ error }}</div>

      <!-- Danh sách feedback -->
      <div v-else class="feedback-list">
        <div v-if="feedbacks.length === 0" class="text-center py-5">
          <p class="text-muted">Chưa có đánh giá nào</p>
        </div>

        <div v-else class="row">
          <div v-for="feedback in feedbacks" :key="feedback.id" class="col-12 mb-4">
            <div class="card">
              <div class="card-body">
                <!-- Header -->
                <div class="d-flex justify-content-between align-items-start mb-3">
                  <h5 class="card-title">{{ feedback.title }}</h5>
                  <div class="rating">
                    <i v-for="star in 5" 
                       :key="star"
                       class="fas fa-star"
                       :class="{ 'text-warning': star <= feedback.rating }"
                    ></i>
                  </div>
                </div>

                <!-- Service badge -->
                <div class="mb-3">
                  <span :class="getServiceBadgeClass(feedback.service)">
                    {{ serviceOptions[feedback.service] }}
                  </span>
                </div>

                <!-- Content -->
                <p class="card-text">{{ feedback.content }}</p>

                <!-- Details -->
                <div class="feedback-details small text-muted">
                  <div v-if="feedback.pros" class="mb-2">
                    <strong>Ưu điểm:</strong> {{ feedback.pros }}
                  </div>
                  <div v-if="feedback.cons" class="mb-2">
                    <strong>Điểm cần cải thiện:</strong> {{ feedback.cons }}
                  </div>
                  <div v-if="feedback.suggestions" class="mb-2">
                    <strong>Đề xuất:</strong> {{ feedback.suggestions }}
                  </div>
                </div>

                <!-- Images -->
                <div v-if="feedback.images?.length" class="feedback-images mt-3">
                  <div class="row g-2">
                    <div v-for="(image, index) in feedback.images" 
                         :key="index" 
                         class="col-auto">
                      <img :src="image" 
                           class="img-thumbnail cursor-pointer" 
                           style="height: 100px;"
                           @click="showImage(image)"
                           :alt="'Ảnh ' + (index + 1)">
                    </div>
                  </div>
                </div>

                <!-- Contact info -->
                <div class="mt-3 small text-muted">
                  <div v-if="feedback.email">
                    <i class="fas fa-envelope me-2"></i>{{ feedback.email }}
                  </div>
                  <div v-if="feedback.phone">
                    <i class="fas fa-phone me-2"></i>{{ feedback.phone }}
                  </div>
                  <div>
                    <i class="fas fa-clock me-2"></i>
                    {{ formatDate(feedback.createdAt) }}
                  </div>
                </div>

                <!-- Actions -->
                <div class="mt-3 text-end">
                  <button class="btn btn-danger btn-sm" @click="confirmDelete(feedback)">
                    <i class="fas fa-trash-alt me-1"></i>Xóa
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Pagination -->
        <div v-if="totalPages > 1" class="d-flex justify-content-center mt-4">
          <nav>
            <ul class="pagination">
              <li class="page-item" :class="{ disabled: currentPage === 1 }">
                <button class="page-link" @click="changePage(currentPage - 1)">
                  <i class="fas fa-chevron-left"></i>
                </button>
              </li>
              <li v-for="page in totalPages" 
                  :key="page" 
                  class="page-item"
                  :class="{ active: page === currentPage }">
                <button class="page-link" @click="changePage(page)">{{ page }}</button>
              </li>
              <li class="page-item" :class="{ disabled: currentPage === totalPages }">
                <button class="page-link" @click="changePage(currentPage + 1)">
                  <i class="fas fa-chevron-right"></i>
                </button>
              </li>
            </ul>
          </nav>
        </div>
      </div>
    </div>

    <!-- Image Modal -->
    <div class="modal fade" id="imageModal" tabindex="-1">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-body p-0">
            <button class="btn-close position-absolute top-0 end-0 m-2" data-bs-dismiss="modal"></button>
            <img :src="selectedImage" class="img-fluid w-100" alt="Preview">
          </div>
        </div>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div class="modal fade" id="deleteModal" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Xác nhận xóa</h5>
            <button class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body">
            Bạn có chắc chắn muốn xóa đánh giá này?
          </div>
          <div class="modal-footer">
            <button class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
            <button class="btn btn-danger" @click="deleteFeedback">Xóa</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useToast } from 'vue-toastification'
import { feedbackService } from '@/services/feedbackService'
import { Modal } from 'bootstrap'
import { debounce } from 'lodash'

const router = useRouter()
const toast = useToast()

// State
const feedbacks = ref([])
const loading = ref(true)
const error = ref(null)
const currentPage = ref(1)
const totalPages = ref(1)
const selectedImage = ref('')
const selectedFeedback = ref(null)
const searchQuery = ref('')

const filters = ref({
  rating: '',
  service: '',
  search: ''
})

const modals = ref({
  image: null,
  delete: null
})

const serviceOptions = {
  ai: 'Tư vấn AI',
  online: 'Tư vấn trực tuyến',
  appointment: 'Đặt lịch khám',
  other: 'Khác'
}

// Methods
const fetchFeedbacks = async () => {
  try {
    loading.value = true
    error.value = null
    
    const params = {
      page: currentPage.value,
      ...filters.value
    }

    const data = await feedbackService.getFeedbacks(params)
    feedbacks.value = data.feedbacks
    totalPages.value = data.totalPages
  } catch (err) {
    console.error('Lỗi khi tải feedback:', err)
    if (err.response?.status === 401) {
      router.push('/auth/login')
    } else {
      error.value = 'Có lỗi xảy ra khi tải danh sách đánh giá'
    }
  } finally {
    loading.value = false
  }
}

const getServiceBadgeClass = (service) => {
  const classes = {
    ai: 'bg-primary',
    online: 'bg-success',
    appointment: 'bg-info',
    other: 'bg-secondary'
  }
  return `badge ${classes[service] || 'bg-secondary'}`
}

const formatDate = (date) => {
  return new Date(date).toLocaleDateString('vi-VN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const showImage = (image) => {
  selectedImage.value = image
  modals.value.image.show()
}

const confirmDelete = (feedback) => {
  selectedFeedback.value = feedback
  modals.value.delete.show()
}

const deleteFeedback = async () => {
  try {
    await feedbackService.deleteFeedback(selectedFeedback.value.id)
    modals.value.delete.hide()
    await fetchFeedbacks()
    toast.success('Xóa đánh giá thành công')
  } catch (err) {
    console.error('Lỗi khi xóa feedback:', err)
    toast.error('Có lỗi xảy ra khi xóa đánh giá')
  }
}

const handleSearch = async () => {
  try {
    const data = await feedbackService.searchFeedbacks(searchQuery.value)
    feedbacks.value = data
  } catch (err) {
    console.error('Lỗi khi tìm kiếm phản hồi:', err)
    toast.error('Không thể tìm kiếm phản hồi')
  }
}

const changePage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    fetchFeedbacks()
  }
}

// Lifecycle hooks
onMounted(() => {
  fetchFeedbacks()
  modals.value.image = new Modal(document.getElementById('imageModal'))
  modals.value.delete = new Modal(document.getElementById('deleteModal'))
})
</script>

<style scoped>
.admin-feedback-list {
  background-color: #f8f9fa;
  min-height: 100vh;
}

.section-title {
  color: #2c3e50;
  font-weight: 600;
}

.card {
  border: none;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  transition: transform 0.2s;
}

.card:hover {
  transform: translateY(-2px);
}

.rating i:not(.text-warning) {
  color: #ddd;
}

.feedback-images img {
  cursor: pointer;
  transition: transform 0.2s;
}

.feedback-images img:hover {
  transform: scale(1.05);
}

.pagination {
  margin-bottom: 0;
}

.page-link {
  color: #3498db;
  border-color: #3498db;
}

.page-item.active .page-link {
  background-color: #3498db;
  border-color: #3498db;
}

@media (max-width: 768px) {
  .filters .row {
    row-gap: 1rem;
  }
}
</style> 