import axiosInstance from './axiosInstance'

export const userService = {
  // Lấy danh sách người dùng
  async getUsers(params = {}) {
    const token = localStorage.getItem('token')
    if (!token) {
      throw new Error('No token found')
    }

    const queryParams = new URLSearchParams(params)
    const response = await axiosInstance.get(`/api/users?${queryParams}`, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      withCredentials: true
    })
    return response.data
  },

  // Xóa người dùng
  async deleteUser(userId) {
    const token = localStorage.getItem('token')
    if (!token) {
      throw new Error('No token found')
    }

    const response = await axiosInstance.delete(`/api/users/admin/${userId}`, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      withCredentials: true
    })
    return response.data
  },

  // Cập nhật thông tin người dùng
  async updateUser(userId, userData) {
    const token = localStorage.getItem('token')
    if (!token) {
      throw new Error('No token found')
    }

    const response = await axiosInstance.put(`/api/users/admin/${userId}`, userData, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      withCredentials: true
    })
    return response.data
  },

  // Tạo người dùng mới
  async createUser(userData) {
    const token = localStorage.getItem('token')
    if (!token) {
      throw new Error('No token found')
    }

    const response = await axiosInstance.post('/api/users/admin/create', userData, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      withCredentials: true
    })
    return response.data
  },

  // Upload ảnh lên ImageBB
  async uploadImage(file) {
    if (file.size > 2 * 1024 * 1024) {
      throw new Error('Kích thước file quá lớn. Vui lòng chọn file nhỏ hơn 2MB')
    }

    const validTypes = ['image/jpeg', 'image/png', 'image/gif']
    if (!validTypes.includes(file.type)) {
      throw new Error('Định dạng file không hợp lệ. Vui lòng chọn file JPG, PNG hoặc GIF')
    }

    const formData = new FormData()
    formData.append('image', file)

    const response = await axiosInstance.post(
      import.meta.env.VITE_BASE_URL_IMAGEBB + '/api/upload',
      formData
    )

    return response.data.data
  }
} 