import axiosInstance from './axiosInstance'

export const newsService = {
  // Lấy danh sách tin tức
  async getNews() {
    const response = await axiosInstance.get('/api/news')
    return response.data
  },

  // Tìm kiếm tin tức
  async searchNews(query) {
    const response = await axiosInstance.get(`/api/news?search=${query}`)
    return response.data
  },

  // Xóa tin tức
  async deleteNews(newsId) {
    const response = await axiosInstance.delete(`/api/news/${newsId}`)
    return response.data
  },

  // Lấy chi tiết tin tức
  async getNewsById(newsId) {
    const response = await axiosInstance.get(`/api/news/${newsId}`)
    return response.data
  },

  // Cập nhật tin tức
  async updateNews(newsId, formData) {
    const response = await axiosInstance.put(`/api/news/${newsId}`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    })
    return response.data
  },

  // Thêm tin tức mới
  async createNews(formData) {
    const response = await axiosInstance.post('/api/news', formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    })
    return response.data
  },

  // Upload ảnh lên ImageBB
  async uploadImage(file) {
    if (file.size > 2 * 1024 * 1024) {
      throw new Error('Kích thước ảnh không được vượt quá 2MB')
    }

    if (!file.type.match('image.*')) {
      throw new Error('Vui lòng chỉ chọn file ảnh')
    }

    const formData = new FormData()
    formData.append('image', file)

    const response = await axiosInstance.post(
      import.meta.env.VITE_BASE_URL_IMAGEBB + '/api/upload',
      formData,
      {
        timeout: 30000,
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      }
    )

    if (!response.data?.data?.url) {
      throw new Error('Không nhận được URL ảnh từ server')
    }

    return response.data.data.url
  },

  // Upload nhiều ảnh
  async uploadMultipleImages(files) {
    const imageMap = {}
    
    for (let file of files) {
      if (!file.type.startsWith('image/')) continue
      
      try {
        const imageUrl = await this.uploadImage(file)
        imageMap[file.name] = imageUrl
      } catch (error) {
        console.error(`Lỗi khi upload ảnh ${file.name}:`, error)
      }
    }
    
    return imageMap
  },

  // Xử lý nội dung HTML
  processHtmlContent(text, fileName) {
    let bodyContent
    
    if (fileName.endsWith('.docx.html')) {
      bodyContent = text.match(/<div class="WordSection1">([\s\S]*?)<\/div>/i)?.[1] 
        || text.match(/<body[^>]*>([\s\S]*)<\/body>/i)?.[1] 
        || text
    } else {
      bodyContent = text.match(/<body[^>]*>([\s\S]*)<\/body>/i)?.[1] || text
    }
    
    let cleanContent = bodyContent
      .replace(/<style[^>]*>[\s\S]*?<\/style>/gi, '')
      .replace(/<script[^>]*>[\s\S]*?<\/script>/gi, '')
      .replace(/class="[^"]*"/g, '')
      .replace(/id="[^"]*"/g, '')
      .replace(/style="[^"]*"/g, '')
      .replace(/<span[^>]*>([\s\S]*?)<\/span>/gi, '$1')
      .replace(/<o:p>\s*<\/o:p>/g, '')
      .replace(/<!--[\s\S]*?-->/g, '')
      .replace(/\n\s*\n/g, '\n')
      .trim()

    const tableStyles = `
      <style>
        table {
          border-collapse: collapse;
          width: 100%;
          margin: 15px 0;
        }
        th, td {
          border: 1px solid #ddd;
          padding: 8px;
          text-align: left;
        }
        th {
          background-color: #f5f5f5;
        }
        tr:nth-child(even) {
          background-color: #f9f9f9;
        }
        tr:hover {
          background-color: #f5f5f5;
        }
      </style>
    `

    return tableStyles + cleanContent
  },

  // Xử lý ảnh trong nội dung
  processContentImages(content, imageMap) {
    const parser = new DOMParser()
    const doc = parser.parseFromString(content, 'text/html')
    const images = doc.getElementsByTagName('img')
    
    for (let img of images) {
      const src = img.getAttribute('src')
      if (!src) continue

      const fileName = src.split('/').pop().split('?')[0]
      
      if (imageMap[fileName]) {
        img.setAttribute('src', imageMap[fileName])
        img.setAttribute('class', 'img-fluid')
        img.setAttribute('style', 'max-width: 100%; height: auto;')
      } else {
        img.setAttribute('src', 'https://placehold.co/800x600/png?text=Image+Not+Found')
        img.setAttribute('class', 'img-fluid')
        img.setAttribute('style', 'max-width: 100%; height: auto;')
      }
    }
    
    return doc.body.innerHTML
  }
} 