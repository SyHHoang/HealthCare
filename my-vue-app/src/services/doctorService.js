import axios from 'axios';
import router from '@/router';
import axiosInstance from './axiosInstance';

// Cập nhật ảnh đại diện
const updateAvatar = async (data) => {
  try {
    const response = await axiosInstance.put('/doctors/profile', data);
    return response.data;
  } catch (error) {
    throw error;
  }
};

// Cập nhật thông tin bác sĩ
const updateProfile = async (data) => {
  try {
    const response = await axiosInstance.put('/doctors/profile', data);
    if (response.data.success) {
      return response.data;
    } else {
      throw new Error(response.data.message || 'Cập nhật thông tin thất bại');
    }
  } catch (error) {
    console.error('Lỗi khi cập nhật thông tin:', error);
    throw error;
  }
};
const getDoctorProfile = async () => {
  try {
    const response = await axiosInstance.get('/api/doctors/profile');
    return response.data;
  } catch (error) {
    throw error;
  }
};
export const doctorService = {
  // Lấy danh sách bác sĩ
  async getDoctors() {
    const token = localStorage.getItem('token')
    if (!token) {
      throw new Error('No token found')
    }

    const response = await axiosInstance.get('/api/doctors', {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    })

    return response.data?.data || response.data
  },

  // Lấy danh sách chuyên khoa
  async getSpecialties() {
    const token = localStorage.getItem('token')
    if (!token) {
      throw new Error('No token found')
    }

    const response = await axiosInstance.get('/api/specialties', {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    })

    return response.data
  },

  // Thêm bác sĩ mới
  async createDoctor(formData) {
    const token = localStorage.getItem('token')
    if (!token) {
      throw new Error('No token found')
    }

    return await axiosInstance.post('/api/doctors', formData, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'multipart/form-data'
      }
    })
  },

  // Cập nhật thông tin bác sĩ
  async updateDoctor(doctorId, formData) {
    const token = localStorage.getItem('token')
    if (!token) {
      throw new Error('No token found')
    }

    return await axiosInstance.put(`/api/doctors/${doctorId}`, formData, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'multipart/form-data'
      }
    })
  },

  // Xóa bác sĩ
  async deleteDoctor(doctorId) {
    const token = localStorage.getItem('token')
    if (!token) {
      throw new Error('No token found')
    }

    return await axiosInstance.delete(`/api/doctors/${doctorId}`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    })
  },

  // Lấy danh sách tất cả bác sĩ
  getAllDoctors: async () => {
    const response = await axiosInstance.get('/api/doctors/active/isActive');
    return response.data.data.doctors;
  },
  updateProfile,
  getDoctorProfile,
  // Lấy thông tin chi tiết bác sĩ
  getDoctorById: async (id) => {
    try {
      const response = await axiosInstance.get(`/api/doctors/${id}`);
      console.log("------------------------------------------response",response);
      return response.data;
    } catch (error) {
      console.error('Lỗi khi lấy thông tin bác sĩ:', error);
      throw error;
    }
  },

  // Tìm kiếm bác sĩ
  searchDoctors: async (query) => {
    const response = await axiosInstance.get('/doctors/active/isActive', {
      params: { search: query }
    });
    return response.data.data.doctors;
  },

  // Lấy danh sách bác sĩ theo chuyên môn
  getDoctorsBySpecialty: async (specialtyId) => {
    const response = await axiosInstance.get(`/specialties/${specialtyId}/doctors`);
    return response.data;
  },

  // Upload avatar cho bác sĩ
  uploadAvatar: async (doctorId, file) => {
    const formData = new FormData();
    formData.append('avatar', file);

    const response = await axiosInstance.post(
      `/doctors/${doctorId}/avatar`,
      formData,
      {
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      }
    );
    return response.data;
  },

  updateAvatar,

  // Lấy thông tin profile để chỉnh sửa
  getProfileForEdit: async () => {
    try {
      const response = await axiosInstance.get('/api/doctors/profile/edit');
      console.log("------------------------------------------response",response);
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  // Gửi yêu cầu xác thực
  requestVerification: async (doctorData) => {
    try {
      const response = await axiosInstance.post('/api/verification/request', doctorData);
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  // Lấy trạng thái yêu cầu xác thực
  getVerificationStatus: async () => {
    try {
      const response = await axiosInstance.get('/api/verification/doctor/verification-details');
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  // Lấy toàn bộ thông tin bác sĩ
  getFullDoctorInfo: async (doctorId) => {
    try {
      const response = await axiosInstance.get(`/api/doctors/full-info/${doctorId}`);
      return response.data;
    } catch (error) {
      throw error.response?.data || error;
    }
  },

  // Lấy thông tin đơn xác thực
  getVerificationRequest: async () => {
    try {
      const response = await axiosInstance.get('/api/verification/doctor/verification-details');
      console.log('Response from server:', response.data);
      return response.data;
    } catch (error) {
      console.error('Lỗi khi lấy thông tin đơn xác thực:', error);
      return {
        success: false,
        message: error.response?.data?.message || 'Không thể lấy thông tin đơn xác thực'
      };
    }
  },
};

export const searchDoctors = async (query) => {
  try {
    const response = await axiosInstance.get(`/doctors/search?query=${encodeURIComponent(query)}`);
    return response.data;
  } catch (error) {
    console.error('Error searching doctors:', error);
    throw error;
  }
}; 