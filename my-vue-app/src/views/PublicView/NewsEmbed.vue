<template>
  <div class="news-embed-view">
    <div v-if="isLoading" class="loading-container">
      <div class="spinner"></div>
      <p>Đang tải bài viết...</p>
    </div>
    <div v-else-if="errorMessage" class="error-container">
      <i class="fas fa-exclamation-circle"></i>
      <p>{{ errorMessage }}</p>
    </div>
    <div v-else class="news-embed-container">
      <div class="news-embed-header">
        <h1>{{ news.title }}</h1>
        <div class="news-meta">
          <span class="news-category">{{ news.category }}</span>
          <span class="news-date">{{ formatDate(news.createdAt) }}</span>
        </div>
      </div>
      
      <div class="news-embed-image" v-if="news.coverImage">
        <img :src="news.coverImage" :alt="news.title">
      </div>
      
      <div class="news-embed-summary">
        {{ news.summary }}
      </div>
      
      <div class="news-embed-footer">
        <a :href="`${baseUrl}/news/${news.id}`" target="_blank" class="read-more-link">
          Đọc bài viết đầy đủ <i class="fas fa-external-link-alt"></i>
        </a>
        <div class="news-source">
          <span>Nguồn: Y tế Chăm Sóc Sức Khỏe Thông Minh</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import axiosInstance from '@/services/axiosInstance.js';

const route = useRoute();
const isLoading = ref(true);
const errorMessage = ref('');
const news = ref({});
const baseUrl = window.location.origin;

const formatDate = (dateString) => {
  const date = new Date(dateString);
  return date.toLocaleDateString('vi-VN', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric'
  });
};

const fetchNewsArticle = async () => {
  const newsId = route.params.id;
  
  try {
    isLoading.value = true;
    const response = await axiosInstance.get(`/api/news/${newsId}`);
    news.value = response.data;
  } catch (error) {
    console.error('Lỗi khi tải bài viết:', error);
    errorMessage.value = 'Không thể tải bài viết. Bài viết không tồn tại hoặc đã bị xóa.';
  } finally {
    isLoading.value = false;
  }
};

onMounted(() => {
  fetchNewsArticle();
  
  // Thông báo cho trang chủ rằng iframe đã được tải
  window.parent.postMessage({ type: 'EMBED_LOADED', newsId: route.params.id }, '*');
});
</script>

<style scoped>
.news-embed-view {
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  color: #333;
  max-width: 100%;
  margin: 0;
  padding: 16px;
  box-sizing: border-box;
  background-color: #fff;
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 300px;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid rgba(0, 123, 255, 0.1);
  border-radius: 50%;
  border-top-color: #007bff;
  animation: spin 1s ease-in-out infinite;
  margin-bottom: 15px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.error-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 200px;
  color: #dc3545;
  text-align: center;
}

.error-container i {
  font-size: 36px;
  margin-bottom: 10px;
}

.news-embed-container {
  display: flex;
  flex-direction: column;
}

.news-embed-header {
  margin-bottom: 16px;
}

.news-embed-header h1 {
  font-size: 1.8rem;
  margin: 0 0 10px 0;
  color: #064ba0;
  line-height: 1.3;
}

.news-meta {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 12px;
}

.news-category {
  background-color: #064ba0;
  color: white;
  font-size: 0.8rem;
  padding: 3px 10px;
  border-radius: 20px;
}

.news-date {
  color: #6c757d;
  font-size: 0.9rem;
}

.news-embed-image {
  margin-bottom: 16px;
  border-radius: 8px;
  overflow: hidden;
}

.news-embed-image img {
  width: 100%;
  display: block;
  height: auto;
  max-height: 300px;
  object-fit: cover;
}

.news-embed-summary {
  margin-bottom: 20px;
  line-height: 1.6;
  color: #555;
}

.news-embed-footer {
  margin-top: 20px;
  padding-top: 16px;
  border-top: 1px solid #eee;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
}

.read-more-link {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  color: #064ba0;
  text-decoration: none;
  font-weight: 600;
  padding: 6px 0;
}

.read-more-link:hover {
  color: #053a7e;
}

.news-source {
  color: #6c757d;
  font-size: 0.8rem;
}

@media (max-width: 480px) {
  .news-embed-header h1 {
    font-size: 1.5rem;
  }
  
  .news-embed-footer {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }
}
</style> 