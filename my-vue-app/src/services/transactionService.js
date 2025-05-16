import axiosInstance from './axiosInstance'

export const transactionService = {
  // Lấy danh sách giao dịch
  async getTransactions(params = {}) {
    const response = await axiosInstance.get('/api/transactions', { params })
    return response.data
  },

  // Lấy thống kê giao dịch
  async getStats() {
    const response = await axiosInstance.get('/api/transactions/stats/summary')
    return response.data
  },

  // Cập nhật trạng thái giao dịch
  async updateStatus(transactionId, status) {
    const response = await axiosInstance.patch(`/api/transactions/${transactionId}/status`, { status })
    return response.data
  }
} 