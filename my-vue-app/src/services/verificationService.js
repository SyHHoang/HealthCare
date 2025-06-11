import axiosInstance from './axiosInstance';

const verificationService = {
  // Gửi yêu cầu xác thực
  async requestVerification(data) {
    try {
      const response = await axiosInstance.post('/api/verification/request', data);
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  // Lấy thông tin yêu cầu xác thực của bác sĩ
  async getDoctorVerificationRequest() {
    try {
      const response = await axiosInstance.get('/api/verification/doctor/request');
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  // Lấy danh sách yêu cầu xác thực (cho admin)
  async getVerificationRequests() {
    const response = await axiosInstance.get('/api/verification/requests');
    return response.data;
  },

  // Xử lý yêu cầu xác thực (cho admin)
  async handleVerificationRequest(requestId, action, reason) {
    try {
      const response = await axiosInstance.put(`/api/verification/handle-requests/${requestId}`, {
        action,
        reason
      });
      console.log('Response:', response.data);
      return response.data;
    } catch (error) {
      console.error('Error handling verification request:', error);
      throw error;
    }
  }
};

export default verificationService; 