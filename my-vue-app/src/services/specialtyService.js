import axiosInstance from '@/services/axiosInstance.js';

export const specialtyService = {
  // Lấy tất cả chuyên môn
  async getAllSpecialties() {
    try {
      const response = await axiosInstance.get('/api/specialties');
      return response.data;
    } catch (error) {
      console.error('Error fetching specialties:', error);
      throw error;
    }
  },

  // Lấy danh sách bác sĩ theo chuyên môn
  getDoctorsBySpecialty: async (specialtyId) => {
    try {
      const response = await axiosInstance.get(`/api/specialties/${specialtyId}/doctors`);
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  // Tìm kiếm chuyên môn và bác sĩ
  searchSpecialtiesAndDoctors: async (query) => {
    try {
      const response = await axiosInstance.get('/api/specialties/search', {
        params: { query }
      });
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  // Tạo chuyên môn mới
  async createSpecialty(specialtyData) {
    try {
      const response = await axiosInstance.post('/api/specialties', specialtyData);
      return response.data;
    } catch (error) {
      console.error('Error creating specialty:', error);
      throw error;
    }
  },

  // Cập nhật chuyên môn
  async updateSpecialty(id, specialtyData) {
    try {
      const response = await axiosInstance.put(`/api/specialties/${id}`, specialtyData);
      return response.data;
    } catch (error) {
      console.error('Error updating specialty:', error);
      throw error;
    }
  },

  // Xóa chuyên môn
  async deleteSpecialty(id) {
    try {
      const response = await axiosInstance.delete(`/api/specialties/${id}`);
      return response.data;
    } catch (error) {
      console.error('Error deleting specialty:', error);
      throw error;
    }
  }
}; 