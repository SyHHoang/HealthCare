<template>
  <div class="admin-edit-news">
    <div class="container">
      <div class="page-header">
        <h2>Chỉnh sửa bài viết</h2>
        <p class="text-muted">Chỉnh sửa thông tin bài viết</p>
      </div>
      
      <form @submit.prevent="handleSubmit" class="news-form">
        <div class="form-section">
          <h3 class="section-title">Thông tin cơ bản</h3>
          <div class="row">
            <div class="col-md-8">
              <div class="mb-3">
                <label for="title" class="form-label">Tiêu đề bài viết <span class="text-danger">*</span></label>
                <input 
                  type="text" 
                  class="form-control form-control-lg" 
                  id="title" 
                  v-model="news.title"
                  placeholder="Nhập tiêu đề bài viết"
                  required
                >
              </div>
            </div>
            <div class="col-md-4">
              <div class="mb-3">
                <label for="category" class="form-label">Danh mục <span class="text-danger">*</span></label>
                <select 
                  class="form-select form-select-lg" 
                  id="category" 
                  v-model="news.category"
                  required
                >
                  <option value="">Chọn danh mục</option>
                  <option value="health">Sức khỏe</option>
                  <option value="lifestyle">Lối sống</option>
                  <option value="medical">Y tế</option>
                  <option value="research">Nghiên cứu</option>
                  <option value="guide">Hướng dẫn</option>
                </select>
              </div>
            </div>
          </div>

          <div class="mb-3">
            <label for="summary" class="form-label">Tóm tắt bài viết</label>
            <textarea 
              class="form-control" 
              id="summary" 
              v-model="news.summary"
              rows="3"
              placeholder="Nhập tóm tắt ngắn gọn về bài viết"
            ></textarea>
          </div>
          
          <!-- Phần tải lên hình ảnh đại diện -->
          <div class="mb-4">
            <label class="form-label">Hình ảnh đại diện bài viết <span class="text-danger">*</span></label>
            <div class="image-upload-container">
              <div class="row">
                <div class="col-md-8">
                  <div class="image-input-container">
                    <input
                      type="file"
                      class="form-control"
                      id="coverImage"
                      @change="onAvatarChange"
                      accept="image/*"
                      :disabled="isUploading"
                    />
                    <small class="text-muted d-block mt-1">
                      Định dạng hỗ trợ: JPG, PNG, GIF. Kích thước tối đa: 5MB
                    </small>
                  </div>
                </div>
                <div class="col-md-4">
                  <div class="d-flex justify-content-end">
                    <button 
                      type="button" 
                      class="btn btn-danger btn-sm"
                      @click="clearImage"
                      v-if="news.coverImage"
                    >
                      <i class="fas fa-trash"></i> Xóa ảnh
                    </button>
                  </div>
                </div>
              </div>
              
              <div class="image-preview-container mt-3" v-if="news.coverImage || isUploading">
                <div v-if="isUploading" class="text-center p-3">
                  <div class="spinner-border text-primary" role="status">
                    <span class="visually-hidden">Đang tải...</span>
                  </div>
                  <p class="mt-2 mb-0">Đang tải ảnh lên...</p>
                </div>
                <div v-else-if="news.coverImage" class="image-preview">
                  <img :src="news.coverImage" alt="Ảnh đại diện bài viết" class="img-fluid rounded" />
                </div>
              </div>
              
              <div v-if="imageError" class="text-danger mt-2">
                {{ imageError }}
              </div>
            </div>
          </div>

          <div class="mb-3">
            <label for="imageFolder" class="form-label">Chọn folder ảnh</label>
            <input 
              type="file" 
              class="form-control" 
              id="imageFolder" 
              @change="handleImageFolderSelect"
              webkitdirectory
              directory
              multiple
              accept="image/*"
            >
            <small class="form-text text-muted">
              Chọn folder chứa ảnh để thay thế trong nội dung
            </small>
          </div>
        </div>

        <div class="form-section">
          <h3 class="section-title">Nội dung bài viết <span class="text-danger">*</span></h3>
          <div class="mb-3">
            <div class="docs-container">
              <div class="row">
                <div class="col-md-8">
                  <div class="mb-3">
                    <label for="docUrl" class="form-label">URL Google Docs (tuỳ chọn)</label>
                    <div class="input-group">
                      <input 
                        type="text" 
                        class="form-control" 
                        id="docUrl" 
                        v-model="docsUrl"
                        placeholder="https://docs.google.com/document/d/..."
                      >
                      <button class="btn btn-primary" type="button" @click="embedGoogleDoc">
                        <i class="fas fa-link"></i> Nhúng
                      </button>
                    </div>
                    <small class="form-text text-muted">
                      Nhập URL Google Docs và nhấn "Nhúng" để soạn thảo trực tiếp
                    </small>
                  </div>
                </div>
                <div class="col-md-4">
                  <div class="mb-3">
                    <label for="importFormat" class="form-label">Nhập từ file</label>
                    <input 
                      type="file" 
                      class="form-control" 
                      id="htmlFile" 
                      @change="handleHtmlUpload"
                      accept=".html,.docx.html,.docx,.txt"
                    >
                  </div>
                </div>
              </div>
              
              <div v-if="showDocEditor" class="google-docs-editor mb-3">
                <iframe 
                  :src="embedUrl" 
                  frameborder="0" 
                  class="docs-iframe"
                ></iframe>
                <div class="mt-2 d-flex justify-content-between">
                  <button type="button" class="btn btn-sm btn-info" @click="openInNewTab">
                    <i class="fas fa-external-link-alt"></i> Mở trong tab mới
                  </button>
                  <button type="button" class="btn btn-sm btn-success" @click="fetchDocContent">
                    <i class="fas fa-download"></i> Lấy nội dung
                  </button>
                </div>
              </div>
              
              <div class="content-preview-container">
                <div class="mb-2 d-flex justify-content-between align-items-center">
                  <label class="form-label mb-0">Xem trước nội dung</label>
                  <div>
                    <button type="button" class="btn btn-sm btn-outline-secondary me-2" @click="togglePreview">
                      <i :class="showPreview ? 'fas fa-code' : 'fas fa-eye'"></i>
                      {{ showPreview ? 'Xem HTML' : 'Xem trước' }}
                    </button>
                    <button type="button" class="btn btn-sm btn-outline-danger" @click="clearContent" v-if="news.content">
                      <i class="fas fa-trash"></i> Xóa nội dung
                    </button>
                  </div>
                </div>
                
                <div v-if="showPreview" class="content-preview border p-3 rounded" v-html="news.content"></div>
                <textarea 
                  v-else
                  class="form-control" 
                  rows="10" 
                  v-model="news.content"
                  placeholder="Nội dung HTML của bài viết sẽ hiển thị ở đây. Bạn có thể chỉnh sửa trực tiếp nếu cần."
                ></textarea>
              </div>
              
              <div v-if="contentError" class="text-danger mt-2">
                {{ contentError }}
              </div>
            </div>
          </div>
        </div>

        <div class="form-actions">
          <button type="button" class="btn btn-light me-2" @click="$router.push('/admin/news')">
            <i class="fas fa-arrow-left"></i> Quay lại
          </button>
          <button type="submit" class="btn btn-primary" :disabled="isSubmitting">
            <i class="fas fa-save"></i> 
            {{ isSubmitting ? 'Đang lưu...' : 'Lưu thay đổi' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { newsService } from '@/services/newsService'

const router = useRouter()
const route = useRoute()
const newsId = route.params.id

// Reactive state
const news = ref({
  title: '',
  summary: '',
  content: '',
  category: '',
  coverImage: '',
  GoogleDocsId: ''
})
const docsUrl = ref('')
const embedUrl = ref('')
const showDocEditor = ref(false)
const showPreview = ref(true)
const isSubmitting = ref(false)
const contentError = ref('')
const isUploading = ref(false)
const imageError = ref('')
const imageMap = ref({})

// Load dữ liệu tin tức
const loadNews = async () => {
  try {
    const response = await newsService.getNews(newsId)
    news.value = response.data
  } catch (error) {
    console.error('Lỗi khi tải tin tức:', error)
    if (error.message === 'No token found') {
      router.push('/auth/login')
    } else {
      alert('Không thể tải tin tức. Vui lòng thử lại sau.')
      router.push('/admin/news')
    }
  }
}

const embedGoogleDoc = () => {
  if (!docsUrl.value) {
    alert('Vui lòng nhập URL Google Docs')
    return
  }
  
  try {
    let url = new URL(docsUrl.value)
    
    if (!url.hostname.includes('docs.google.com')) {
      alert('URL không hợp lệ. Vui lòng nhập URL Google Docs.')
      return
    }
    
    let docId = ''
    if (url.pathname.includes('/d/')) {
      docId = url.pathname.split('/d/')[1].split('/')[0]
    }
    
    if (!docId) {
      alert('Không thể xác định ID của tài liệu. Vui lòng kiểm tra lại URL.')
      return
    }
    
    embedUrl.value = `https://docs.google.com/document/d/${docId}/edit?embedded=true`
    showDocEditor.value = true
  } catch (error) {
    console.error('Lỗi khi xử lý URL:', error)
    alert('URL không hợp lệ. Vui lòng kiểm tra lại.')
  }
}

const openInNewTab = () => {
  if (embedUrl.value) {
    window.open(embedUrl.value.replace('?embedded=true', ''), '_blank')
  }
}

const fetchDocContent = () => {
  alert('Để lấy nội dung từ Google Docs:\n\n1. Trong Google Docs, chọn "File" > "Download" > "Web Page (.html, zipped)"\n2. Giải nén file ZIP tải về\n3. Tải lên file HTML vừa giải nén bằng nút "Nhập từ file"')
}

const togglePreview = () => {
  showPreview.value = !showPreview.value
}

const clearContent = () => {
  if (confirm('Bạn có chắc chắn muốn xóa nội dung bài viết?')) {
    news.value.content = ''
  }
}

const handleHtmlUpload = async (event) => {
  const file = event.target.files[0]
  if (file) {
    try {
      const text = await file.text()
      const cleanContent = newsService.processHtmlContent(text, file.name)
      news.value.content = await newsService.processContentImages(cleanContent, imageMap.value)
      validateContent()
      event.target.value = ''
    } catch (error) {
      console.error('Lỗi khi đọc file:', error)
      alert('Có lỗi xảy ra khi đọc file. Vui lòng thử lại!')
    }
  }
}

const validateContent = () => {
  const content = news.value.content
  if (!content || content.trim() === '' || content === '<p><br></p>' || content === '<p></p>') {
    contentError.value = 'Vui lòng nhập nội dung bài viết'
    return false
  }
  contentError.value = ''
  return true
}

const handleSubmit = async () => {
  if (!validateContent()) return
  
  if (!news.value.coverImage) {
    imageError.value = 'Vui lòng tải lên hình ảnh đại diện cho bài viết'
    document.getElementById('coverImage').scrollIntoView({ behavior: 'smooth' })
    return
  }

  isSubmitting.value = true

  try {
    const newsData = {
      title: news.value.title,
      summary: news.value.summary || '',
      content: news.value.content,
      category: news.value.category,
      coverImage: news.value.coverImage,
      GoogleDocsId: news.value.GoogleDocsId
    }

    await newsService.updateNews(newsId, newsData)
    alert('Cập nhật bài viết thành công!')
    router.push('/admin/news')
  } catch (error) {
    console.error('Lỗi khi cập nhật bài viết:', error)
    if (error.message === 'No token found') {
      router.push('/auth/login')
    } else {
      alert(error.response?.data?.message || 'Có lỗi xảy ra khi cập nhật bài viết')
    }
  } finally {
    isSubmitting.value = false
  }
}

const onAvatarChange = async (event) => {
  const file = event.target.files[0]
  if (!file) return

  isUploading.value = true
  imageError.value = ''
  
  try {
    const imageUrl = await newsService.uploadImage(file)
    news.value.coverImage = imageUrl
  } catch (error) {
    console.error('Lỗi khi tải ảnh lên:', error)
    imageError.value = error.message
    alert(error.message)
  } finally {
    isUploading.value = false
    event.target.value = ''
  }
}

const clearImage = () => {
  if (confirm('Bạn có chắc chắn muốn xóa hình ảnh đại diện bài viết?')) {
    news.value.coverImage = ''
  }
}

const handleImageFolderSelect = async (event) => {
  const files = event.target.files
  if (!files || files.length === 0) return

  isUploading.value = true
  try {
    imageMap.value = await newsService.uploadMultipleImages(files)
    
    if (news.value.content) {
      news.value.content = newsService.processContentImages(news.value.content, imageMap.value)
    }

    alert('Đã upload thành công ' + Object.keys(imageMap.value).length + ' ảnh')
  } catch (error) {
    console.error('Lỗi khi upload ảnh:', error)
    alert('Có lỗi xảy ra khi upload ảnh. Vui lòng thử lại!')
  } finally {
    isUploading.value = false
    event.target.value = ''
  }
}

onMounted(() => {
  loadNews()
})
</script>

<style scoped>
.admin-edit-news {
  padding: 40px 0;
  background-color: #f8f9fa;
  min-height: 100vh;
}

.page-header {
  margin-bottom: 40px;
  text-align: center;
}

.page-header h2 {
  color: #2c3e50;
  margin-bottom: 10px;
}

.news-form {
  max-width: 1000px;
  margin: 0 auto;
  background: white;
  padding: 30px;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.1);
}

.form-section {
  margin-bottom: 40px;
  padding-bottom: 30px;
  border-bottom: 1px solid #eee;
}

.form-section:last-child {
  border-bottom: none;
  margin-bottom: 0;
  padding-bottom: 0;
}

.section-title {
  color: #2c3e50;
  font-size: 1.2rem;
  margin-bottom: 20px;
  font-weight: 600;
}

.form-label {
  font-weight: 500;
  color: #495057;
  margin-bottom: 8px;
}

.form-control, .form-select {
  border: 1px solid #ced4da;
  padding: 10px 15px;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.form-control:focus, .form-select:focus {
  border-color: #80bdff;
  box-shadow: 0 0 0 0.2rem rgba(0,123,255,.25);
}

.form-actions {
  margin-top: 30px;
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

.btn {
  padding: 10px 20px;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 8px;
}

.btn i {
  font-size: 16px;
}

.btn-primary {
  background: #007bff;
  border: none;
}

.btn-primary:hover {
  background: #0056b3;
}

.btn-light {
  background: #f8f9fa;
  border: 1px solid #dee2e6;
}

.btn-light:hover {
  background: #e2e6ea;
}

@media (max-width: 768px) {
  .admin-edit-news {
    padding: 20px;
  }

  .news-form {
    padding: 20px;
  }

  .form-section {
    margin-bottom: 30px;
    padding-bottom: 20px;
  }
}

.google-docs-editor {
  width: 100%;
  border: 1px solid #ddd;
  border-radius: 8px;
  overflow: hidden;
}

.docs-iframe {
  width: 100%;
  height: 600px;
  border: none;
}

.content-preview-container {
  margin-top: 20px;
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 15px;
  background-color: #fff;
}

.content-preview {
  min-height: 300px;
  max-height: 500px;
  overflow-y: auto;
  background-color: #fff;
}

.btn-outline-secondary {
  color: #6c757d;
  border-color: #6c757d;
}

.btn-outline-secondary:hover {
  color: #fff;
  background-color: #6c757d;
}

.btn-outline-danger {
  color: #dc3545;
  border-color: #dc3545;
}

.btn-outline-danger:hover {
  color: #fff;
  background-color: #dc3545;
}

.image-upload-container {
  margin-bottom: 20px;
}

.image-input-container {
  margin-bottom: 10px;
}

.image-preview-container {
  margin-top: 10px;
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 15px;
  background-color: #fff;
}

.image-preview {
  max-height: 300px;
  overflow: hidden;
  border-radius: 8px;
  margin-bottom: 10px;
}

.btn-secondary {
  background-color: #6c757d;
  border: none;
}

.btn-secondary:hover {
  background-color: #5a6268;
}
</style> 