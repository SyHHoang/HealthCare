import { GoogleGenerativeAI } from '@google/generative-ai';

// Khởi tạo Gemini API với API key
const genAI = new GoogleGenerativeAI(import.meta.env.VITE_GEMINI_API_KEY);

// Tạo model chat
const model = genAI.getGenerativeModel({ 
  model: "gemini-1.5-flash-001",
  generationConfig: {
    maxOutputTokens: 1000,
    temperature: 0.7,
  }
});

// Lưu trữ lịch sử chat
let chatHistory = [];

// Khởi tạo chat session
const chat = model.startChat({
  history: [],
});

class GeminiService {
  static async generateResponse(message) {
    try {
      // Thêm tin nhắn vào lịch sử
      chatHistory.push({ role: 'user', parts: message });
      
      // Gửi tin nhắn và nhận phản hồi
      const result = await chat.sendMessage(message);
      const response = await result.response;
      const text = response.text();
      
      // Thêm phản hồi vào lịch sử
      chatHistory.push({ role: 'model', parts: text });
      
      return text;
    } catch (error) {
      console.error('Lỗi khi gọi Gemini API:', error);
      throw error;
    }
  }

  static getChatHistory() {
    return chatHistory;
  }

  static clearChatHistory() {
    chatHistory = [];
    // Reset chat session
    chat.reset();
  }
}

export default GeminiService; 