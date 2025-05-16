<template>
  <div class="tooltip-container">
    <!-- Button để mở/đóng chatbot -->
    <button 
      class="tooltip-button" 
      :class="{ 'active': isOpen }"
      @click="toggleChat"
    >
      <i class="fas" :class="isOpen ? 'fa-times' : 'fa-comments'"></i>
    </button>

    <!-- Container cho chatbot -->
    <div class="chatbot-container" :class="{ 'open': isOpen }">
      <ChatbotView v-if="isOpen" />
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import ChatbotView from './ChatbotView.vue';

const isOpen = ref(false);

const toggleChat = () => {
  isOpen.value = !isOpen.value;
};
</script>

<style scoped>
.tooltip-container {
  position: fixed;
  bottom: 20px;
  right: 20px;
  z-index: 1000;
}

.tooltip-button {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background-color: #3498db;
  border: none;
  color: white;
  font-size: 24px;
  cursor: pointer;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1001;
}

.tooltip-button:hover {
  transform: scale(1.1);
  background-color: #2980b9;
}

.tooltip-button.active {
  background-color: #e74c3c;
}

.chatbot-container {
  position: fixed;
  bottom: 90px;
  right: 20px;
  visibility: hidden;
  opacity: 0;
  transform: translateY(20px);
  transition: all 0.3s ease;
}

.chatbot-container.open {
  visibility: visible;
  opacity: 1;
  transform: translateY(0);
}
</style> 