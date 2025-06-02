<template>
  <div class="chat-container">
    <div class="chat-header">
      <span>Trợ lý Y tế AI</span>
      <button class="close-btn" @click="$emit('close')">×</button>
    </div>
    <div class="chat-messages" ref="chatMessages">
      <div
        v-for="(message, index) in messages"
        :key="index"
        :class="['message', message.sender]"
      >
        <div class="message-content">
          {{ message.text }}
        </div>
        <div class="message-time">
          {{ new Date().toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' }) }}
        </div>
      </div>
      <div v-if="isLoading" class="message bot">
        <div class="typing-indicator">
          <span></span>
          <span></span>
          <span></span>
        </div>
      </div>
    </div>
    <div class="chat-input">
      <input
        type="text"
        v-model="userInput"
        placeholder="Nhập câu hỏi của bạn..."
        @keyup.enter="sendMessage"
        :disabled="isLoading"
      />
      <button @click="sendMessage" :disabled="isLoading">
        <i class="fas fa-paper-plane"></i>
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, nextTick, onMounted, onUnmounted } from 'vue';
import GeminiService from '@/services/geminiService';

// State
const userInput = ref('');
const messages = ref([]);
const isLoading = ref(false);
const chatMessages = ref(null);

// Khi mở chatbot, hiển thị tin nhắn chào
onMounted(() => {
  messages.value = [
    { 
      sender: 'bot', 
      text: 'Xin chào! Tôi là trợ lý y tế AI. Tôi có thể giúp bạn tìm hiểu thông tin về sức khỏe, bệnh tật và các vấn đề y tế khác. Bạn cần tôi giúp gì không?' 
    }
  ];
});

// Xóa lịch sử chat khi đóng chatbot
onUnmounted(() => {
  GeminiService.clearChatHistory();
});

// Gửi tin nhắn đến Gemini API
const sendMessage = async () => {
  if (userInput.value.trim() === '' || isLoading.value) return;

  const userMessage = userInput.value;
  userInput.value = ''; // Xóa input ngay lập tức
  isLoading.value = true;

  // Thêm tin nhắn của người dùng vào danh sách
  messages.value.push({ 
    sender: 'user', 
    text: userMessage,
    time: new Date().toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' })
  });

  try {
    // Gọi Gemini API
    const response = await GeminiService.generateResponse(userMessage);
    
    // Thêm phản hồi từ chatbot vào danh sách
    messages.value.push({ 
      sender: 'bot', 
      text: response,
      time: new Date().toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' })
    });
  } catch (error) {
    console.error('Lỗi khi gửi tin nhắn:', error);
    messages.value.push({
      sender: 'bot',
      text: 'Xin lỗi, đã xảy ra lỗi khi kết nối với trợ lý AI. Vui lòng thử lại sau.',
      time: new Date().toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' })
    });
  } finally {
    isLoading.value = false;
  }

  // Cuộn xuống cuối cùng
  await nextTick();
  if (chatMessages.value) {
    chatMessages.value.scrollTop = chatMessages.value.scrollHeight;
  }
};
</script>

<style scoped>
/* Container chính */
.chat-container {
  width: 350px;
  height: 500px;
  background: #ffffff;
  border-radius: 10px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  position: relative;
}

/* Header */
.chat-header {
  background: #4CAF50;
  color: #ffffff;
  padding: 12px 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 1.1rem;
  font-weight: bold;
}

/* Nút đóng */
.close-btn {
  background: transparent;
  border: none;
  font-size: 24px;
  color: #ffffff;
  cursor: pointer;
  padding: 0;
  line-height: 1;
}

/* Tin nhắn */
.chat-messages {
  flex: 1;
  padding: 16px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 12px;
  background-color: #f8f9fa;
}

.message {
  display: flex;
  flex-direction: column;
  max-width: 85%;
}

.message.user {
  align-self: flex-end;
}

.message.bot {
  align-self: flex-start;
}

.message-content {
  padding: 10px 14px;
  border-radius: 15px;
  word-wrap: break-word;
}

.message.user .message-content {
  background: #4CAF50;
  color: #ffffff;
  border-bottom-right-radius: 5px;
}

.message.bot .message-content {
  background: #ffffff;
  color: #333333;
  border-bottom-left-radius: 5px;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
}

.message-time {
  font-size: 0.75rem;
  color: #666;
  margin-top: 4px;
  align-self: flex-end;
}

/* Input */
.chat-input {
  display: flex;
  border-top: 1px solid #eee;
  background: #ffffff;
  padding: 8px;
}

.chat-input input {
  flex: 1;
  padding: 10px 12px;
  border: 1px solid #ddd;
  border-radius: 20px;
  outline: none;
  font-size: 0.95rem;
  transition: border-color 0.2s;
}

.chat-input input:focus {
  border-color: #4CAF50;
}

.chat-input input:disabled {
  background: #f5f5f5;
  cursor: not-allowed;
}

.chat-input button {
  background: #4CAF50;
  color: #ffffff;
  border: none;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  margin-left: 8px;
  cursor: pointer;
  transition: background-color 0.2s;
}

.chat-input button:hover:not(:disabled) {
  background: #45a049;
}

.chat-input button:disabled {
  background: #cccccc;
  cursor: not-allowed;
}

/* Typing indicator */
.typing-indicator {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 10px 14px;
  background: #ffffff;
  border-radius: 15px;
  border-bottom-left-radius: 5px;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
}

.typing-indicator span {
  width: 8px;
  height: 8px;
  background: #4CAF50;
  border-radius: 50%;
  animation: typing 1s infinite ease-in-out;
}

.typing-indicator span:nth-child(2) {
  animation-delay: 0.2s;
}

.typing-indicator span:nth-child(3) {
  animation-delay: 0.4s;
}

@keyframes typing {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-5px);
  }
}

/* Scrollbar styling */
.chat-messages::-webkit-scrollbar {
  width: 6px;
}

.chat-messages::-webkit-scrollbar-track {
  background: #f1f1f1;
}

.chat-messages::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

.chat-messages::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}
</style>