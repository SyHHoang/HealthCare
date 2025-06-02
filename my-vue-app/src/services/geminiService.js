import axios from 'axios';

const GEMINI_API_KEY = 'AIzaSyCwhyhpQgyXlvXGXWGAc4lXuU_XO8ferCQ';
const GEMINI_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

class GeminiService {
  static chatHistory = [];

  static async generateResponse(prompt) {
    try {
      // Thêm tin nhắn người dùng vào lịch sử
      this.chatHistory.push({
        role: "user",
        parts: [{ text: prompt }]
      });

      // Tạo nội dung gửi đi bao gồm hệ thống và lịch sử chat
      const contents = [
        {
          role: "system",
          parts: [
            {
              text:
                "Bạn là một trợ lý y tế AI thông minh. Chỉ trả lời câu hỏi y tế. Hãy trả lời bằng tiếng Việt một cách ngắn gọn và chính xác."
            }
          ]
        },
        ...this.chatHistory
      ];

      const response = await axios.post(
        `${GEMINI_API_URL}?key=${GEMINI_API_KEY}`,
        {
          contents,
          generationConfig: {
            temperature: 0.7,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 1024,
          },
          safetySettings: [
            {
              category: "HARM_CATEGORY_HARASSMENT",
              threshold: "BLOCK_MEDIUM_AND_ABOVE"
            },
            {
              category: "HARM_CATEGORY_HATE_SPEECH",
              threshold: "BLOCK_MEDIUM_AND_ABOVE"
            },
            {
              category: "HARM_CATEGORY_SEXUALLY_EXPLICIT",
              threshold: "BLOCK_MEDIUM_AND_ABOVE"
            },
            {
              category: "HARM_CATEGORY_DANGEROUS_CONTENT",
              threshold: "BLOCK_MEDIUM_AND_ABOVE"
            }
          ]
        },
        {
          headers: {
            'Content-Type': 'application/json',
          }
        }
      );

      if (
        response.data &&
        response.data.candidates &&
        response.data.candidates[0]?.content?.parts?.[0]?.text
      ) {
        const botResponse = response.data.candidates[0].content.parts[0].text;

        // Thêm phản hồi của bot vào lịch sử
        this.chatHistory.push({
          role: "model",
          parts: [{ text: botResponse }]
        });

        // Giới hạn độ dài lịch sử
        if (this.chatHistory.length > 10) {
          this.chatHistory = this.chatHistory.slice(-10);
        }

        return botResponse;
      }

      throw new Error('Không nhận được phản hồi hợp lệ từ Gemini');
    } catch (error) {
      console.error('Lỗi khi gọi Gemini API:', error);
      if (error.response) {
        console.error('Response data:', error.response.data);
        console.error('Response status:', error.response.status);
      }
      throw error;
    }
  }

  // Xóa lịch sử chat
  static clearChatHistory() {
    this.chatHistory = [];
  }
}

export default GeminiService;
