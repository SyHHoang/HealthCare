<template>
  <div class="news-events">
    <div class="container">
      <div class="news-header">
        <h1 class="page-title">Tin tức & Kiến thức</h1>
        <p class="subtitle">Cập nhật thông tin mới nhất về sức khỏe và y học</p>
      </div>
    </div>
      <!-- Layout mới với sidebar -->
      <div class="news-content">
        <!-- Sidebar -->
        <aside class="news-sidebar">
          <div class="sidebar-title">
            <h2>Danh mục</h2>
          </div>
          <div class="category-filter">
            <button 
              class="category-button" 
              :class="{ active: selectedCategory === 'all' }" 
              @click="filterByCategory('all')">
              Tất cả
            </button>
            <button 
              v-for="category in categories" 
              :key="category.value" 
              class="category-button" 
              :class="{ active: selectedCategory === category.value }" 
              @click="filterByCategory(category.value)">
              {{ category.name }}
            </button>
          </div>
        </aside>
      </div>
        <!-- Main content -->
        <main class="main-content">
          <div class="articles-container">
            <div v-for="(article) in filteredArticles" :key="article._id" class="article-card">
              <div class="article-image-container">
                <img
                  :src="article.coverImage || 'https://via.placeholder.com/600x400?text=HealthRight'"
                  :alt="article.title"
                  class="article-image"
                  loading="lazy"
                />
                <div class="category-badge" :class="getCategoryClass(article.category)">
                  {{ getCategoryName(article.category) }}
                </div>
              </div>
              <div class="article-content">
                <div class="article-meta">
                  <span class="article-date"><i class="far fa-calendar-alt"></i> {{ formatDate(article.date) }}</span>
                </div>
                <h2 class="article-title">{{ article.title }}</h2>
                <p class="article-summary">{{ article.summary || truncateContent(article.content) }}</p>
                <router-link :to="'/news/' + article._id" class="read-more">
                  Xem thêm <i class="fas fa-arrow-right"></i>
                </router-link>
              </div>
            </div>
          </div>

          <!-- Loading và trạng thái trống -->
          <div v-if="isLoading" class="loading">
            <div class="spinner"></div>
            <p>Đang tải bài viết...</p>
          </div>
          
          <div v-if="!isLoading && filteredArticles.length === 0" class="no-articles">
            <i class="fas fa-newspaper"></i>
            <p>Không có bài viết nào</p>
          </div>
        </main>
      
    
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import axios from 'axios'
import { useRouter } from 'vue-router'

const articles = ref([])
const filteredArticles = ref([])
const isLoading = ref(true)
const selectedCategory = ref('all')
const searchTerm = ref('')

const categories = [
  { value: 'health', name: 'Sức khỏe', class: 'health' },
  { value: 'lifestyle', name: 'Lối sống', class: 'lifestyle' },
  { value: 'medical', name: 'Y tế', class: 'medical' },
  { value: 'research', name: 'Nghiên cứu', class: 'research' }
]

const fetchArticles = async () => {
  isLoading.value = true
  try {
    const response = await axios.get('http://localhost:5000/api/news')
    articles.value = response.data
    console.log('Danh sách bài viết:', articles.value)
    console.log('Tiêu đề bài viết đầu tiên:', articles.value[0]?.title)
    filteredArticles.value = [...articles.value]
    console.log('Danh sách bài viết đã lọc:', filteredArticles.value)
  } catch (error) {
    console.error('Lỗi lấy danh sách bài viết:', error)
  } finally {
    isLoading.value = false
  }
}

const formatDate = (date) => {
  return new Date(date).toLocaleDateString('vi-VN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })
}

const truncateContent = (content) => {
  if (!content) return ''
  const plainText = content.replace(/<[^>]*>?/gm, '')
  return plainText.length > 150 ? plainText.substring(0, 150) + '...' : plainText
}

const filterByCategory = (category) => {
  selectedCategory.value = category
  filterArticles()
}

const filterArticles = () => {
  if (selectedCategory.value === 'all' && !searchTerm.value) {
    filteredArticles.value = [...articles.value]
    console.log('Lọc tất cả bài viết:', filteredArticles.value)
    return
  }

  filteredArticles.value = articles.value.filter(article => {
    const matchCategory = selectedCategory.value === 'all' || article.category === selectedCategory.value
    const matchSearch = !searchTerm.value ||
      article.title.toLowerCase().includes(searchTerm.value.toLowerCase()) ||
      (article.summary && article.summary.toLowerCase().includes(searchTerm.value.toLowerCase()))
    return matchCategory && matchSearch
  })
  console.log('Kết quả lọc:', filteredArticles.value)
}

const clearSearch = () => {
  searchTerm.value = ''
  filterArticles()
}

const getCategoryName = (categoryValue) => {
  const category = categories.find(c => c.value === categoryValue)
  return category ? category.name : 'Chung'
}

const getCategoryClass = (categoryValue) => {
  const category = categories.find(c => c.value === categoryValue)
  return category ? category.class : ''
}

onMounted(() => {
  fetchArticles()
})
</script>


<style scoped>
.news-events {
  padding: 20px;
  background-color: #f8f9fa;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 15px;
}

.news-header {
  text-align: center;
  padding: 40px 20px;
  background: white;
  border-bottom: 1px solid #eee;
}

.page-title {
  font-size: 42px;
  font-weight: bold;
  color: #1a1a1a;
  margin-bottom: 10px;
}

.subtitle {
  font-size: 18px;
  color: #666;
  max-width: 600px;
  margin: 0 auto;
}

/* Layout chính */
.news-content {
  display: grid;
  grid-template-columns: 250px 1fr;
  gap: 30px;
  position: relative;
}

/* Sidebar */
.news-sidebar {
  position: fixed;
  top: 0;
  left: 0;
  width: 250px;
  height: 100vh;
  background: #fff;
  border-right: 1px solid #eee;
  padding: 20px 0;
  overflow-y: auto;
  z-index: 1000;
}

.sidebar-title {
  padding: 0 20px 15px;
  margin-bottom: 15px;
  border-bottom: 2px solid #f0f0f0;
}

.sidebar-title h2 {
  font-size: 20px;
  font-weight: 600;
  color: #333;
  margin: 0;
}

.category-filter {
  padding: 0 10px;
}

.category-button {
  display: block;
  width: 100%;
  padding: 12px 20px;
  margin-bottom: 8px;
  text-align: left;
  background: none;
  border: none;
  border-radius: 8px;
  color: #666;
  font-size: 15px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.category-button:hover {
  background: #f8f9fa;
  color: #007bff;
}

.category-button.active {
  background: #007bff;
  color: white;
}

/* Main content */
.main-content {
  margin-left: 250px;
  padding: 20px;
  min-height: 100vh;
  background: #f8f9fa;
}

/* Container cho danh sách tin tức */
.articles-container {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
}

/* Card tin tức */
.article-card {
  flex: 1 1 300px;
  min-width: 300px;
  max-width: calc(33.333% - 14px);
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  display: flex;
  flex-direction: column;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.article-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.12);
}

.article-image-container {
  height: 200px;
  overflow: hidden;
}

.article-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.article-content {
  padding: 15px;
  flex: 1;
  display: flex;
  flex-direction: column;
}

.article-title {
  font-size: 18px;
  font-weight: bold;
  margin-bottom: 10px;
  color: #333;
}

.article-meta {
  margin-top: auto;
  display: flex;
  gap: 15px;
  color: #666;
  font-size: 14px;
}

.category-badge {
  display: inline-block;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  color: white;
  background-color: #007bff;
}

/* Responsive */
@media (max-width: 992px) {
  .news-content {
    grid-template-columns: 1fr;
  }

  .news-sidebar {
    position: static;
    width: 100%;
    height: auto;
    border-right: none;
    border-bottom: 1px solid #eee;
    padding: 20px;
    margin-bottom: 20px;
  }

  .category-filter {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    padding: 0;
  }

  .category-button {
    width: auto;
    margin: 0;
    padding: 8px 16px;
  }

  .main-content {
    margin-left: 0;
  }

  .article-card {
    max-width: calc(50% - 10px);
  }
}

@media (max-width: 576px) {
  .article-card {
    max-width: 100%;
  }

  .category-button {
    width: 100%;
  }
}
</style>