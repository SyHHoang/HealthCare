<template>
  <div class="chat-container">
    <div class="chat-header">Chatbot AI Tiếng Việt</div>
    <div class="chat-messages" ref="chatMessages">
      <div
        v-for="(message, index) in messages"
        :key="index"
        :class="['message', message.sender]"
      >
        {{ message.text }}
      </div>
    </div>
    <div class="chat-input">
      <input
        type="text"
        v-model="userInput"
        placeholder="Nhập tin nhắn..."
        @keyup.enter="sendMessage"
      />
      <button @click="sendMessage">Gửi</button>
    </div>
    <button class="close-btn" @click="$emit('close')">×</button>
  </div>
</template>

<script setup>
import { ref, nextTick } from 'vue';

// URL API của FastAPI
const apiUrl = 'http://localhost:8000/generate';

// State
const userInput = ref('');
const messages = ref([]);

// Gửi tin nhắn đến API FastAPI
const sendMessage = async () => {
  if (userInput.value.trim() === '') return;

  // Thêm tin nhắn của người dùng vào danh sách
  messages.value.push({ sender: 'user', text: userInput.value });

  try {
    // Gửi tin nhắn đến FastAPI với prompt trong query string
    const response = await fetch(`${apiUrl}?prompt=${encodeURIComponent(userInput.value)}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) {
      throw new Error(`HTTP error! Status: ${response.status}`);
    }

    const data = await response.json();

    // Thêm phản hồi từ chatbot vào danh sách
    messages.value.push({ sender: 'bot', text: data.generated_text });
  } catch (error) {
    console.error('Lỗi khi gửi tin nhắn:', error);
    messages.value.push({
      sender: 'bot',
      text: 'Xin lỗi, đã xảy ra lỗi khi kết nối với chatbot.',
    });
  }

  // Cuộn xuống cuối cùng
  await nextTick();
  const chatMessages = document.querySelector('.chat-messages');
  chatMessages.scrollTop = chatMessages.scrollHeight;

  // Xóa nội dung ô nhập
  userInput.value = '';
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
  position: relative; /* Để nút close-btn định vị đúng */
}

/* Header */
.chat-header {
  background: #3498db;
  color: #ffffff;
  padding: 12px;
  text-align: center;
  font-size: 1.1rem;
  font-weight: bold;
}

/* Nút đóng */
.close-btn {
  position: absolute;
  top: 8px;
  right: 12px;
  background: transparent;
  border: none;
  font-size: 24px;
  color: #ffffff; /* Đổi màu để nổi trên header xanh */
  cursor: pointer;
  z-index: 10;
}

/* Tin nhắn */
.chat-messages {
  flex: 1;
  padding: 12px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 8px;
  background-color: #f8f9fa;
}

.message {
  margin-bottom: 8px;
  padding: 8px 12px;
  border-radius: 15px;
  max-width: 80%;
  word-wrap: break-word;
}

.message.user {
  background: #3498db;
  color: #ffffff;
  align-self: flex-end;
  border-bottom-right-radius: 5px;
}

.message.bot {
  background: #ffffff;
  color: #333333;
  align-self: flex-start;
  border-bottom-left-radius: 5px;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
}

/* Input */
.chat-input {
  display: flex;
  border-top: 1px solid #eee;
  background: #ffffff;
}

.chat-input input {
  flex: 1;
  padding: 12px;
  border: none;
  outline: none;
  font-size: 0.95rem;
  background: transparent;
}

.chat-input button {
  background: #3498db;
  color: #ffffff;
  border: none;
  padding: 8px 15px;
  cursor: pointer;
  font-size: 0.95rem;
  transition: background-color 0.2s ease;
}

.chat-input button:hover {
  background: #2980b9;
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