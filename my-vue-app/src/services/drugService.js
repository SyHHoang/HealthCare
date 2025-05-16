import axiosInstance from './axiosInstance'

export const drugService = {
  // Lấy danh sách thuốc
  async getDrugs(params) {
    return await axiosInstance.get('/api/drugs/search', { params })
  },

  // Thêm thuốc mới
  async createDrug(drugData) {
    const token = localStorage.getItem('token')
    if (!token) {
      throw new Error('No token found')
    }

    return await axiosInstance.post('/api/drugs', drugData, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    })
  },

  // Cập nhật thuốc
  async updateDrug(drugId, drugData) {
    const token = localStorage.getItem('token')
    if (!token) {
      throw new Error('No token found')
    }

    return await axiosInstance.put(`/api/drugs/${drugId}`, drugData, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    })
  },

  // Xóa thuốc
  async deleteDrug(drugId) {
    const token = localStorage.getItem('token')
    if (!token) {
      throw new Error('No token found')
    }

    return await axiosInstance.delete(`/api/drugs/${drugId}`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    })
  }
} 