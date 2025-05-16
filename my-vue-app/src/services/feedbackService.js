import axiosInstance from './axiosInstance'

export const feedbackService = {
  // Lấy danh sách feedback
  async getFeedbacks(params = {}) {
    const token = localStorage.getItem('token')
    if (!token) {
      throw new Error('No token found')
    }

    const queryParams = new URLSearchParams(params)
    const response = await axiosInstance.get(`/api/feedback?${queryParams}`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    })
    return response.data
  },

  // Xóa feedback
  async deleteFeedback(feedbackId) {
    const token = localStorage.getItem('token')
    if (!token) {
      throw new Error('No token found')
    }

    const response = await axiosInstance.delete(`/api/feedback/${feedbackId}`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    })
    return response.data
  },

  // Tìm kiếm feedback
  async searchFeedbacks(query) {
    const token = localStorage.getItem('token')
    if (!token) {
      throw new Error('No token found')
    }

    const response = await axiosInstance.get(`/api/feedback?search=${query}`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    })
    return response.data
  }
} 