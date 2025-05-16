<template>
  <div class="admin-news">
    <div class="header">
      <h1>Quản lý tin tức</h1>
      <div class="d-flex align-items-center">
        <div class="input-group me-3" style="width: 300px;">
          <input 
            type="text" 
            class="form-control" 
            v-model="searchQuery"
            placeholder="Tìm kiếm tin tức..."
            @keyup.enter="handleSearch"
          >
          <button class="btn btn-outline-secondary" @click="handleSearch">
            <i class="fas fa-search"></i>
          </button>
        </div>
        <router-link to="/admin/news/addnews" class="btn btn-primary">
          <i class="fas fa-plus"></i> Thêm tin tức mới
        </router-link>
      </div>
    </div>

    <!-- Bảng danh sách tin tức -->
    <div class="table-responsive">
      <table class="table">
        <thead>
          <tr>
            <th>Ảnh bìa</th>
            <th>Tiêu đề</th>
            <th>Danh mục</th>
            <th>Tác giả</th>
            <th>Lượt xem</th>
            <th>Ngày tạo</th>
            <th>Thao tác</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="news in newsList" :key="news._id">
            <td>
              <img 
                :src="news.coverImage || 'https://via.placeholder.com/100'" 
                :alt="news.title"
                class="news-cover"
              >
            </td>
            <td>{{ news.title }}</td>
            <td>{{ formatCategory(news.category) }}</td>
            <td>{{ news.author?.fullname }}</td>
            <td>{{ news.viewCount }}</td>
            <td>{{ formatDate(news.createdAt) }}</td>
            <td>
              <router-link :to="'/news/' + news._id" class="btn btn-sm btn-success me-2" target="_blank">
                <i class="fas fa-eye"></i>
              </router-link>
              <router-link :to="'/admin/news/edit/' + news._id" class="btn btn-sm btn-info me-2">
                <i class="fas fa-edit"></i>
              </router-link>
              <button class="btn btn-sm btn-danger" @click="confirmDelete(news)">
                <i class="fas fa-trash-can"></i>
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useToast } from 'vue-toastification'
import { newsService } from '@/services/newsService'

const toast = useToast()

// State
const newsList = ref([])
const searchQuery = ref('')
const loading = ref(false)
const error = ref(null)

// Methods
const fetchNews = async () => {
  try {
    loading.value = true
    error.value = null
    newsList.value = await newsService.getNews()
  } catch (err) {
    console.error('Lỗi khi lấy danh sách tin tức:', err)
    error.value = 'Không thể lấy danh sách tin tức'
    showToast('error', 'Không thể lấy danh sách tin tức')
  } finally {
    loading.value = false
  }
};

const confirmDelete = async (news) => {
  if (!confirm('Bạn có chắc chắn muốn xóa tin tức này?')) return

  try {
    await newsService.deleteNews(news._id)
    showToast('success', 'Xóa tin tức thành công')
    await fetchNews()
  } catch (err) {
    console.error('Lỗi khi xóa tin tức:', err)
    showToast('error', 'Không thể xóa tin tức')
  }
};

const formatCategory = (category) => {
  const categories = {
    health: 'Sức khỏe',
    lifestyle: 'Lối sống',
    medical: 'Y tế',
    research: 'Nghiên cứu'
  }
  return categories[category] || category
};

const formatDate = (date) => {
  return new Date(date).toLocaleDateString('vi-VN')
};

const handleSearch = async () => {
  try {
    loading.value = true
    error.value = null
    newsList.value = await newsService.searchNews(searchQuery.value)
  } catch (err) {
    console.error('Lỗi khi tìm kiếm tin tức:', err)
    error.value = 'Không thể tìm kiếm tin tức'
    showToast('error', 'Không thể tìm kiếm tin tức')
  } finally {
    loading.value = false
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
  fetchNews()
})
</script>

<style scoped>
.admin-news {
  padding: 20px;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.news-cover {
  width: 100px;
  height: 60px;
  object-fit: cover;
  border-radius: 4px;
}

.table img {
  max-width: 100px;
  height: auto;
}
</style> 