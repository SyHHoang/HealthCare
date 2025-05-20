import axiosInstance from './axiosInstance'

export const transactionService = {
  // Lấy danh sách giao dịch
  async getTransactions(params = {}) {
    try {
      const response = await axiosInstance.get('/api/transactions', { params })
      return response.data
    } catch (error) {
      console.error('Error in getTransactions:', error)
      throw error
    }
  },

  // Lấy thống kê giao dịch
  async getStats() {
    try {
      const response = await axiosInstance.get('/api/transactions/stats/summary')
      return response.data
    } catch (error) {
      console.error('Error in getStats:', error)
      throw error
    }
  },

  // Cập nhật trạng thái giao dịch
  async updateStatus(transactionId, status) {
    try {
      const response = await axiosInstance.patch(`/api/transactions/${transactionId}/status`, { status })
      return response.data
    } catch (error) {
      console.error('Error in updateStatus:', error)
      throw error
    }
  }
} 