import axiosInstance from './axiosInstance'

export const dashboardService = {
  // Lấy thống kê tổng quan
  async getStats() {
    const token = localStorage.getItem('token')
    if (!token) {
      throw new Error('No token found')
    }

    const response = await axiosInstance.get('/api/admin/dashboard/stats', {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    })
    return response.data
  },

  // Lấy thống kê lượt xem
  async getViewStats() {
    const token = localStorage.getItem('token')
    if (!token) {
      throw new Error('No token found')
    }

    return await axiosInstance.get('/api/news/stats/views', {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    })
  },

  // Lấy thống kê lượt xem của một bài viết cụ thể
  async getArticleViewStats(articleId) {
    const token = localStorage.getItem('token')
    if (!token) {
      throw new Error('No token found')
    }

    return await axiosInstance.get(`/api/news/stats/views/${articleId}`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    })
  },

  // Lấy số lượng người dùng
  async getUserCount() {
    const token = localStorage.getItem('token')
    if (!token) {
      throw new Error('No token found')
    }

    return await axiosInstance.get('/api/users/count', {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    })
  },

  // Lấy số lượng phản hồi
  async getFeedbackCount() {
    const token = localStorage.getItem('token')
    if (!token) {
      throw new Error('No token found')
    }

    return await axiosInstance.get('/api/feedback/count', {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    })
  }
} 