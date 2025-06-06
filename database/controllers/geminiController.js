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

const geminiController = {
  // Gửi tin nhắn và nhận phản hồi
  sendMessage: async (req, res) => {
    try {
      const { message, chatHistory } = req.body;
      console.log('Received message:', message);
      console.log('Chat history:', JSON.stringify(chatHistory, null, 2));

      if (!message) {
        return res.status(400).json({ error: 'Message is required' });
      }

      if (!process.env.GEMINI_API_KEY) {
        console.error('GEMINI_API_KEY is not set');
        return res.status(500).json({ error: 'Server configuration error' });
      }

      try {
        // Tạo chat session với lịch sử chat
        const chat = model.startChat({
          history: chatHistory.map(msg => ({
            role: msg.sender === 'user' ? 'user' : 'model',
            parts: [{ text: msg.text }]
          }))
        });

        // Gửi tin nhắn và nhận phản hồi
        const result = await chat.sendMessage(message);
        console.log('Gemini response:', result);
        
        const response = await result.response;
        const text = response.text();
        console.log('Response text:', text);

        res.json({ response: text });
      } catch (geminiError) {
        console.error('Gemini API error:', {
          message: geminiError.message,
          stack: geminiError.stack,
          name: geminiError.name
        });
        
        // Thử lại với generateContent nếu startChat thất bại
        console.log('Trying with generateContent...');
        const result = await model.generateContent(message);
        const response = await result.response;
        const text = response.text();
        
        res.json({ response: text });
      }
    } catch (error) {
      console.error('Detailed error in sendMessage:', {
        message: error.message,
        stack: error.stack,
        name: error.name
      });
      
      // Trả về lỗi cụ thể hơn cho client
      res.status(500).json({ 
        error: 'Failed to get response from Gemini',
        details: error.message
      });
    }
  }
};

export default geminiController; 