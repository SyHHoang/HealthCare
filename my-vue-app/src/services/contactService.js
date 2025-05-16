import axiosInstance from './axiosInstance'

export const contactService = {
  // Lấy danh sách liên hệ
  async getContacts(params) {
    return await axiosInstance.get('/api/contact/admin', {
      params,
      headers: {
        Authorization: `Bearer ${localStorage.getItem('token')}`
      }
    })
  },

  // Cập nhật trạng thái liên hệ
  async updateStatus(contactId, status) {
    return await axiosInstance.patch(`/api/contact/admin/${contactId}/status`, 
      { status },
      { 
        headers: {
          Authorization: `Bearer ${localStorage.getItem('token')}`
        }
      }
    )
  },

  // Xóa liên hệ
  async deleteContact(contactId) {
    return await axiosInstance.delete(`/api/contact/admin/${contactId}`, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem('token')}`
      }
    })
  },

  // Gửi phản hồi
  async sendReply(contactId, message) {
    return await axiosInstance.post(`/api/contact/admin/${contactId}/reply`, 
      { message },
      { 
        headers: {
          Authorization: `Bearer ${localStorage.getItem('token')}`
        }
      }
    )
  }
} 