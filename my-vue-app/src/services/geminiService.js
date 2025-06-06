import axiosInstance from '@/services/axiosInstance.js';

class GeminiService {
  static async generateResponse(message, chatHistory) {
    try {
      const response = await axiosInstance.post('/api/gemini/message', { 
        message,
        chatHistory
      });
      return response.data.response;
    } catch (error) {
      console.error('Lỗi khi gọi Gemini API:', error);
      throw error;
    }
  }

  static async initializeChat() {
    try {
      await axiosInstance.post('/api/gemini/initialize');
    } catch (error) {
      console.error('Lỗi khi khởi tạo chat:', error);
      throw error;
    }
  }

  static async clearChatHistory() {
    try {
      await axiosInstance.delete('/api/gemini/clear');
    } catch (error) {
      console.error('Lỗi khi xóa lịch sử chat:', error);
      throw error;
    }
  }
}

export default GeminiService; 