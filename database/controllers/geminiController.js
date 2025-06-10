import { GoogleGenerativeAI } from '@google/generative-ai';

// Khởi tạo Gemini API với API key từ biến môi trường
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// Tạo model chat
const model = genAI.getGenerativeModel({ 
  model: "gemini-2.0-flash",
  generationConfig: {
    maxOutputTokens: 1000,
    temperature: 0.7,
  }
});

// Lưu session Gemini theo user (ở đây dùng IP, nếu có userId thì nên dùng userId)
const userSessions = new Map();

const geminiController = {
  // Khởi tạo chat session mới
  initializeChat: async (req, res) => {
    try {
      if (!process.env.GEMINI_API_KEY) {
        console.error('GEMINI_API_KEY is not set');
        return res.status(500).json({ error: 'Server configuration error' });
      }
      const chat = model.startChat();
      const userKey = req.ip;
      userSessions.set(userKey, chat);
      console.log('New chat session initialized for', userKey);
      res.json({ success: true, message: 'Chat session initialized' });
    } catch (error) {
      console.error('Error initializing chat:', error);
      res.status(500).json({ 
        error: 'Failed to initialize chat',
        details: error.message
      });
    }
  },

  // Xóa lịch sử chat
  clearChat: async (req, res) => {
    try {
      const userKey = req.ip;
      userSessions.delete(userKey);
      console.log('Chat session cleared for', userKey);
      res.json({ success: true, message: 'Chat history cleared' });
    } catch (error) {
      console.error('Error clearing chat:', error);
      res.status(500).json({ 
        error: 'Failed to clear chat history',
        details: error.message
      });
    }
  },

  // Gửi tin nhắn và nhận phản hồi
  sendMessage: async (req, res) => {
    try {
      const { message } = req.body;
      const userKey = req.ip;
      let chat = userSessions.get(userKey);

      if (!message) {
        return res.status(400).json({ error: 'Message is required' });
      }

      if (!process.env.GEMINI_API_KEY) {
        console.error('GEMINI_API_KEY is not set');
        return res.status(500).json({ error: 'Server configuration error' });
      }

      // Nếu chưa có session thì tạo mới
      if (!chat) {
        chat = model.startChat();
        userSessions.set(userKey, chat);
        console.log('Auto create new chat session for', userKey);
      }

      // Gửi tin nhắn và nhận phản hồi
      const result = await chat.sendMessage(message);
      const response = await result.response;
      const text = response.text();
      console.log('Gemini response for', userKey, ':', text);
      res.json({ response: text });
    } catch (error) {
      console.error('Detailed error in sendMessage:', {
        message: error.message,
        stack: error.stack,
        name: error.name
      });
      res.status(500).json({ 
        error: 'Failed to get response from Gemini',
        details: error.message
      });
    }
  }
};

export default geminiController; 