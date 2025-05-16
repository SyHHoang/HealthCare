<template>
  <div class="article-detail-page">
    <div class="container">
      <!-- Breadcrumb -->
      <div class="breadcrumb">
        <router-link to="/" class="breadcrumb-item">Trang chủ</router-link>
        <span class="separator"> / </span>
        <router-link to="/news-events" class="breadcrumb-item">Tin tức & Kiến thức</router-link>
        <span class="separator"> / </span>
        <span class="breadcrumb-item active">{{ article.title }}</span>
      </div>

      <!-- Loading -->
      <div v-if="isLoading" class="loading-container">
        <div class="spinner"></div>
        <p>Đang tải bài viết...</p>
      </div>

      <!-- Nội dung bài viết -->
      <div v-else-if="article._id" class="article-container">
        <!-- Thông tin bài viết -->
        <article class="article-content-wrapper">
          <header class="article-header">
            <div class="category-badge" :class="getCategoryClass(article.category)">
              {{ getCategoryName(article.category) }}
            </div>
            <h1 class="article-title">{{ article.title }}</h1>
            <div class="article-meta">
              <span class="meta-item date">
                <i class="far fa-calendar-alt"></i> {{ formatDate(article.date) }}
              </span>
              <span class="meta-item author" v-if="article.author">
                <i class="far fa-user"></i> {{ article.author }}
              </span>
              <span class="meta-item views">
                <i class="far fa-eye"></i> {{ article.viewCount || 0 }} lượt xem
              </span>
            </div>
          </header>

          <!-- Ảnh bài viết -->
          <div v-if="article.coverImage" class="article-featured-image">
            <img :src="article.coverImage" :alt="article.title" />
          </div>

          <!-- Nội dung tóm tắt -->
          <div v-if="article.summary" class="article-summary">
            <p>{{ article.summary }}</p>
          </div>

          <!-- Nội dung chính -->
          <div class="article-content" v-html="article.content"></div>

          <!-- Tags -->
          <div class="article-tags">
            <span class="tag-label">Tags:</span>
            <div class="tags">
              <a href="#" class="tag" @click.prevent="filterByCategory(article.category)">{{ getCategoryName(article.category) }}</a>
              <a href="#" class="tag">Sức khỏe</a>
              <a href="#" class="tag">Y tế</a>
            </div>
          </div>

          <!-- Social sharing -->
          <div class="social-sharing">
            <span class="share-label">Chia sẻ:</span>
            <div class="share-buttons">
              <a href="#" class="share-button facebook" @click.prevent="shareOnFacebook">
                <i class="fab fa-facebook-f"></i>
              </a>
              <a href="#" class="share-button twitter" @click.prevent="shareOnTwitter">
                <i class="fab fa-twitter"></i>
              </a>
              <a href="#" class="share-button linkedin" @click.prevent="shareOnLinkedIn">
                <i class="fab fa-linkedin-in"></i>
              </a>
              <a href="#" class="share-button email" @click.prevent="shareViaEmail">
                <i class="far fa-envelope"></i>
              </a>
            </div>
          </div>
        </article>

        <!-- Sidebar -->
        <aside class="article-sidebar">
          <!-- Bài viết liên quan -->
          <div class="related-articles">
            <h3 class="sidebar-title">Bài viết liên quan</h3>
            <div v-if="relatedArticles.length > 0" class="related-articles-list">
              <div v-for="related in relatedArticles" :key="related._id" class="related-article">
                <router-link :to="'/news/' + related._id" class="related-link">
                  <div class="related-image">
                    <img :src="related.coverImage || 'https://via.placeholder.com/150x100?text=HealthRight'" :alt="related.title" />
                  </div>
                  <div class="related-content">
                    <h4 class="related-title">{{ related.title }}</h4>
                    <span class="related-date">{{ formatDate(related.date) }}</span>
                  </div>
                </router-link>
              </div>
            </div>
            <div v-else class="no-related">
              <p>Không có bài viết liên quan</p>
            </div>
          </div>

          <!-- Newsletter -->
          <div class="newsletter-box">
            <h3 class="sidebar-title">Đăng ký nhận tin</h3>
            <p>Nhận thông tin mới nhất về sức khỏe và y học qua email</p>
            <form class="newsletter-form" @submit.prevent="subscribeNewsletter">
              <input type="email" v-model="newsletterEmail" placeholder="Email của bạn" required />
              <button type="submit" class="subscribe-btn">Đăng ký</button>
            </form>
          </div>
        </aside>
      </div>

      <!-- Không tìm thấy bài viết -->
      <div v-else-if="!isLoading" class="not-found">
        <i class="fas fa-newspaper"></i>
        <h2>Không tìm thấy bài viết</h2>
        <p>Bài viết bạn đang tìm kiếm không tồn tại hoặc đã bị xóa.</p>
        <router-link to="/news-events" class="btn-back">Quay lại trang tin tức</router-link>
      </div>
    </div>
  </div>
</template>
  
<script setup>
import { ref, watch, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import axios from 'axios'

const route = useRoute()
const router = useRouter()

const article = ref({})
const relatedArticles = ref([])
const isLoading = ref(true)
const newsletterEmail = ref('')

const categories = [
  { value: 'health', name: 'Sức khỏe', class: 'health' },
  { value: 'lifestyle', name: 'Lối sống', class: 'lifestyle' },
  { value: 'medical', name: 'Y tế', class: 'medical' },
  { value: 'research', name: 'Nghiên cứu', class: 'research' }
]

const fetchArticle = async () => {
  isLoading.value = true
  try {
    const id = route.params.id
    console.log('Đang lấy bài viết với ID:', id)
    const response = await axios.get(`http://localhost:5000/api/news/${id}`)
    console.log('Dữ liệu trả về:', response.data)
    
    if (!response.data || !response.data._id) {
      throw new Error('Bài viết không tồn tại')
    }
    
    article.value = response.data
    document.title = `${article.value.title} - HealthRight`

    await fetchRelatedArticles()
  } catch (error) {
    console.error('Lỗi lấy chi tiết bài viết:', error)
    if (error.response) {
      console.error('Status:', error.response.status)
      console.error('Data:', error.response.data)
    }
    article.value = {}
    router.push({ name: 'not-found' })
  } finally {
    isLoading.value = false
  }
}

const fetchRelatedArticles = async () => {
  try {
    console.log('Đang lấy bài viết liên quan...')
    const response = await axios.get('http://localhost:5000/api/news')
    console.log('Danh sách bài viết:', response.data)
    
    if (!response.data || !Array.isArray(response.data)) {
      throw new Error('Dữ liệu không hợp lệ')
    }

    const articles = response.data
    relatedArticles.value = articles
      .filter(a => a.category === article.value.category && a._id !== article.value._id)
      .slice(0, 3)

    if (relatedArticles.value.length < 3) {
      const moreArticles = articles
        .filter(a => a._id !== article.value._id && !relatedArticles.value.some(r => r._id === a._id))
        .slice(0, 3 - relatedArticles.value.length)

      relatedArticles.value = [...relatedArticles.value, ...moreArticles]
    }
    console.log('Bài viết liên quan:', relatedArticles.value)
  } catch (error) {
    console.error('Lỗi lấy bài viết liên quan:', error)
    if (error.response) {
      console.error('Status:', error.response.status)
      console.error('Data:', error.response.data)
    }
    relatedArticles.value = []
  }
}

const formatDate = (date) => {
  return new Date(date).toLocaleDateString('vi-VN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

const getCategoryName = (categoryValue) => {
  const category = categories.find(c => c.value === categoryValue)
  return category ? category.name : 'Chung'
}

const getCategoryClass = (categoryValue) => {
  const category = categories.find(c => c.value === categoryValue)
  return category ? category.class : ''
}

const filterByCategory = (category) => {
  router.push({ path: '/news-events', query: { category } })
}

const subscribeNewsletter = () => {
  alert(`Đã đăng ký nhận tin thành công với email: ${newsletterEmail.value}`)
  newsletterEmail.value = ''
}

const shareOnFacebook = () => {
  const url = `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(window.location.href)}`
  window.open(url, '_blank')
}

const shareOnTwitter = () => {
  const url = `https://twitter.com/intent/tweet?url=${encodeURIComponent(window.location.href)}&text=${encodeURIComponent(article.value.title)}`
  window.open(url, '_blank')
}

const shareOnLinkedIn = () => {
  const url = `https://www.linkedin.com/sharing/share-offsite/?url=${encodeURIComponent(window.location.href)}`
  window.open(url, '_blank')
}

const shareViaEmail = () => {
  const subject = encodeURIComponent(article.value.title)
  const body = encodeURIComponent(`Tôi muốn chia sẻ bài viết này với bạn: ${window.location.href}`)
  window.location.href = `mailto:?subject=${subject}&body=${body}`
}

// Gọi fetchArticle khi mounted và khi id thay đổi
watch(() => route.params.id, fetchArticle, { immediate: true })
</script>
  
<style scoped>
.article-detail-page {
  padding: 60px 0;
  background-color: #f8f9fa;
  min-height: 100vh;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

/* Breadcrumb */
.breadcrumb {
  display: flex;
  align-items: center;
  margin-bottom: 30px;
  font-size: 14px;
  color: #6c757d;
}

.breadcrumb-item {
  color: #6c757d;
  text-decoration: none;
}

.breadcrumb-item:hover {
  color: #007bff;
  text-decoration: underline;
}

.breadcrumb-item.active {
  color: #495057;
  font-weight: 500;
}

.separator {
  margin: 0 8px;
}

/* Loading */
.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 400px;
}

.spinner {
  border: 4px solid rgba(0, 0, 0, 0.1);
  border-radius: 50%;
  border-top: 4px solid #007bff;
  width: 40px;
  height: 40px;
  animation: spin 1s linear infinite;
  margin-bottom: 15px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Article container */
.article-container {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 40px;
}

.article-content-wrapper {
  background-color: white;
  border-radius: 12px;
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05);
  overflow: hidden;
}

/* Article header */
.article-header {
  padding: 30px 30px 20px;
  border-bottom: 1px solid #eee;
}

.category-badge {
  display: inline-block;
  padding: 6px 15px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 600;
  color: white;
  background-color: #6c757d;
  margin-bottom: 20px;
}

.category-badge.health {
  background-color: #28a745; /* Green */
}
.category-badge.lifestyle {
  background-color: #fd7e14; /* Orange */
}
.category-badge.medical {
  background-color: #007bff; /* Blue */
}
.category-badge.research {
  background-color: #6f42c1; /* Purple */
}

.article-title {
  font-size: 36px;
  font-weight: 700;
  color: #212529;
  margin-bottom: 20px;
  line-height: 1.3;
}

.article-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  font-size: 15px;
  color: #6c757d;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 6px;
}

/* Featured image */
.article-featured-image {
  width: 100%;
}

.article-featured-image img {
  width: 100%;
  max-height: 500px;
  object-fit: cover;
}

/* Article summary */
.article-summary {
  padding: 30px;
  background-color: #f8f9fa;
  border-left: 4px solid #007bff;
  margin: 20px 30px;
  font-size: 18px;
  font-weight: 500;
  color: #495057;
  line-height: 1.6;
  font-style: italic;
}

/* Article content */
.article-content {
  padding: 30px;
  font-size: 18px;
  line-height: 1.8;
  color: #343a40;
}

/* Override v-html styles */
:deep(.article-content h1),
:deep(.article-content h2),
:deep(.article-content h3),
:deep(.article-content h4),
:deep(.article-content h5),
:deep(.article-content h6) {
  margin-top: 40px;
  margin-bottom: 20px;
  font-weight: 700;
  color: #212529;
  line-height: 1.3;
}

:deep(.article-content h2) {
  font-size: 28px;
}

:deep(.article-content h3) {
  font-size: 24px;
}

:deep(.article-content p) {
  margin-bottom: 20px;
}

:deep(.article-content img) {
  max-width: 100%;
  height: auto;
  border-radius: 8px;
  margin: 30px 0;
  display: block;
}

:deep(.article-content ul),
:deep(.article-content ol) {
  margin: 20px 0;
  padding-left: 25px;
}

:deep(.article-content li) {
  margin-bottom: 10px;
}

:deep(.article-content a) {
  color: #007bff;
  text-decoration: none;
}

:deep(.article-content a:hover) {
  text-decoration: underline;
}

:deep(.article-content blockquote) {
  margin: 30px 0;
  padding: 20px;
  background-color: #f8f9fa;
  border-left: 4px solid #6c757d;
  font-style: italic;
}

/* Tags */
.article-tags {
  padding: 20px 30px;
  border-top: 1px solid #eee;
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
}

.tag-label {
  font-weight: 600;
  color: #495057;
}

.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.tag {
  display: inline-block;
  padding: 5px 12px;
  background-color: #f1f3f5;
  color: #495057;
  border-radius: 20px;
  font-size: 13px;
  text-decoration: none;
  transition: all 0.2s ease;
}

.tag:hover {
  background-color: #dee2e6;
  color: #212529;
}

/* Social sharing */
.social-sharing {
  padding: 20px 30px;
  border-top: 1px solid #eee;
  display: flex;
  align-items: center;
  gap: 15px;
}

.share-label {
  font-weight: 600;
  color: #495057;
}

.share-buttons {
  display: flex;
  gap: 10px;
}

.share-button {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  color: white;
  transition: all 0.3s ease;
}

.share-button:hover {
  transform: translateY(-3px);
}

.facebook {
  background-color: #3b5998;
}

.twitter {
  background-color: #1da1f2;
}

.linkedin {
  background-color: #0077b5;
}

.email {
  background-color: #ea4335;
}

/* Sidebar */
.article-sidebar {
  display: flex;
  flex-direction: column;
  gap: 30px;
}

.sidebar-title {
  font-size: 20px;
  font-weight: 700;
  color: #212529;
  margin-bottom: 20px;
  padding-bottom: 10px;
  border-bottom: 2px solid #dee2e6;
}

/* Related articles */
.related-articles {
  background-color: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05);
}

.related-articles-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.related-article {
  border-bottom: 1px solid #eee;
  padding-bottom: 15px;
}

.related-article:last-child {
  border-bottom: none;
  padding-bottom: 0;
}

.related-link {
  display: flex;
  gap: 15px;
  text-decoration: none;
  color: inherit;
}

.related-image {
  flex: 0 0 80px;
}

.related-image img {
  width: 80px;
  height: 60px;
  object-fit: cover;
  border-radius: 6px;
}

.related-content {
  flex: 1;
}

.related-title {
  font-size: 16px;
  font-weight: 600;
  color: #343a40;
  line-height: 1.4;
  margin: 0 0 8px;
  transition: color 0.2s ease;
}

.related-link:hover .related-title {
  color: #007bff;
}

.related-date {
  font-size: 13px;
  color: #6c757d;
}

.no-related {
  text-align: center;
  padding: 20px;
  color: #6c757d;
}

/* Newsletter */
.newsletter-box {
  background-color: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05);
}

.newsletter-box p {
  margin-bottom: 20px;
  color: #495057;
}

.newsletter-form {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.newsletter-form input {
  padding: 12px 15px;
  border: 1px solid #dee2e6;
  border-radius: 6px;
  font-size: 15px;
}

.newsletter-form input:focus {
  outline: none;
  border-color: #80bdff;
  box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
}

.subscribe-btn {
  padding: 12px;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.3s ease;
}

.subscribe-btn:hover {
  background-color: #0069d9;
}

/* Not found */
.not-found {
  text-align: center;
  padding: 60px 20px;
  background-color: white;
  border-radius: 12px;
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05);
}

.not-found i {
  font-size: 60px;
  color: #6c757d;
  margin-bottom: 20px;
}

.not-found h2 {
  font-size: 28px;
  margin-bottom: 15px;
  color: #212529;
}

.not-found p {
  font-size: 18px;
  color: #6c757d;
  margin-bottom: 30px;
}

.btn-back {
  display: inline-block;
  padding: 12px 25px;
  background-color: #007bff;
  color: white;
  border-radius: 6px;
  text-decoration: none;
  font-weight: 600;
  transition: background-color 0.3s ease;
}

.btn-back:hover {
  background-color: #0069d9;
}

/* Responsive styles */
@media (max-width: 991px) {
  .article-container {
    grid-template-columns: 1fr;
  }
  
  .article-title {
    font-size: 30px;
  }
}

@media (max-width: 767px) {
  .article-detail-page {
    padding: 30px 0;
  }
  
  .article-header {
    padding: 20px 20px 15px;
  }
  
  .article-content {
    padding: 20px;
  }
  
  .article-title {
    font-size: 26px;
  }
  
  .article-summary,
  .article-tags,
  .social-sharing {
    padding: 15px 20px;
    margin: 15px 20px;
  }
  
  .social-sharing {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .breadcrumb {
    font-size: 12px;
    margin-bottom: 20px;
    flex-wrap: wrap;
  }
}
</style>