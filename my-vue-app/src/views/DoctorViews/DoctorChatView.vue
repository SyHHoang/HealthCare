<template>
  <div class="chat-container">
    <div class="chat-sidebar">
      <h2>Danh sách chat</h2>
      <div v-for="chat in chats" :key="chat._id" 
           class="chat-item" 
           :class="{ active: selectedChat?._id === chat._id }"
           @click="selectChat(chat)">
        <img :src="chat.userId?.avatar" class="avatar" />
        <div class="chat-info">
          <h3>{{ chat.userId?.fullname || 'Bệnh nhân' }}</h3>
          <p class="last-message">{{ chat.lastMessage?.content || 'Chưa có tin nhắn' }}</p>
          <span class="online-status" :class="{ online: isUserOnline(chat.userId?._id) }">
            {{ isUserOnline(chat.userId?._id) ? 'Online' : 'Offline' }}
          </span>
        </div>
      </div>
    </div>
    
    <div class="chat-main">
      <div v-if="selectedChat" class="chat-messages" ref="chatMessages" @scroll="handleScroll">
        <div v-if="hasMoreMessages" class="load-more">
          <button @click="loadMoreMessages" class="load-more-btn" :disabled="isLoading">
            <i class="bi bi-arrow-up"></i> 
            {{ isLoading ? 'Đang tải...' : 'Tải tin nhắn cũ' }}
          </button>
        </div>
        <div v-for="message in selectedChat.messages" :key="message._id" 
             class="message" 
             :class="{ 'message-doctor': message.senderModel === 'Doctor' || message.sender.model === 'Doctor' }">
          <div v-if="message.content" class="message-content">
            <p>{{ message.content }}</p>
            <span v-if="message.senderModel === 'Doctor' || message.sender.model === 'Doctor'" class="read-status">
              <i v-if="message.isRead" class="bi bi-check2-all text-primary"></i>
              <i v-else class="bi bi-check2 text-muted"></i>
            </span>
          </div>
          <div v-if="message.image" class="message-image-wrapper">
            <img :src="message.image.url" alt="Hình ảnh" class="message-image" @click="openImagePreview(message.image.url)" />
            <span v-if="message.senderModel === 'Doctor' || message.sender.model === 'Doctor'" class="read-status">
              <i v-if="message.isRead" class="bi bi-check2-all text-primary"></i>
              <i v-else class="bi bi-check2 text-muted"></i>
            </span>
          </div>
          <div class="message-time">
            {{ new Date(message.createdAt).toLocaleTimeString() }}
          </div>
        </div>
      </div>
      
      <div v-else class="no-chat-selected">
        <p>Chọn một cuộc trò chuyện để bắt đầu</p>
      </div>
      
      <div v-if="selectedChat" class="chat-input">
        <input 
          v-model="newMessage" 
          @keyup.enter="sendMessage" 
          placeholder="Nhập tin nhắn..." 
        />
        <label for="image-upload" class="upload-btn">
          <i class="bi bi-image"></i>
          <input 
            type="file" 
            id="image-upload" 
            accept="image/*" 
            @change="handleImageUpload" 
            style="display: none"
          />
        </label>
        <button @click="sendMessage">Gửi</button>
      </div>
    </div>

    <!-- Modal xem ảnh -->
    <div v-if="showImagePreview" class="image-preview-modal" @click="closeImagePreview">
      <div class="image-preview-content" @click.stop>
        <img :src="previewImageUrl" alt="Preview" class="preview-image" />
        <button class="close-preview-btn" @click="closeImagePreview">
          <i class="bi bi-x-lg"></i>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, nextTick } from 'vue';
import { useRoute } from 'vue-router';
import socketService from '../../services/socketService';
import axiosInstance from '../../services/axiosInstance';
import { useToast } from 'primevue/usetoast';
import axios from 'axios';

const toast = useToast();
const route = useRoute();
const chats = ref([]);
const selectedChat = ref(null);
const newMessage = ref('');
const onlineUsers = ref(new Set());
const isOnline = ref(true);
const chatMessages = ref(null);
const hasMoreMessages = ref(false);
const currentPage = ref(1);
const isLoading = ref(false);
const selectedImage = ref(null);
const isUploading = ref(false);
const showImagePreview = ref(false);
const previewImageUrl = ref('');
const searchQuery = ref('');
const searchResults = ref([]);
const mediaMessages = ref([]);
const isLoadingImages = ref(false);

const isUserOnline = (userId) => {
  return onlineUsers.value.has(userId);
};

const handleUserOnline = (data) => {
  onlineUsers.value.add(data.userId);
};

const handleUserOffline = (data) => {
  onlineUsers.value.delete(data.userId);
};

const handleDoctorOnline = (data) => {
  console.log('Bác sĩ online:', data);
  // Cập nhật trạng thái online của bác sĩ
  isOnline.value = true;
};

const handleDoctorOffline = (data) => {
  console.log('Bác sĩ offline:', data);
  // Cập nhật trạng thái offline của bác sĩ
  isOnline.value = false;
};

const handleError = (error) => {
  console.error('Lỗi socket:', error);
};

const fetchChats = async () => {
  try {
    const response = await axiosInstance.get('/api/chat/doctor');
    if (response.data && Array.isArray(response.data)) {
      chats.value = response.data;
      console.log("Danh sách chat của bác sĩ:", response.data);
      
      // Nếu có chatId trong URL, chọn chat đó
      const chatId = route.params.chatId;
      if (chatId && !selectedChat.value) {
        const chat = chats.value.find(c => c._id === chatId);
        if (chat) {
          selectedChat.value = chat;
        }
      }
    } else {
      console.error('Dữ liệu trả về không hợp lệ:', response.data);
      chats.value = [];
    }
  } catch (error) {
    console.error('Lỗi khi lấy danh sách chat:', error);
    chats.value = [];
  }
};

const selectChat = async (chat) => {
  try {
    selectedChat.value = chat;
    currentPage.value = 1;
    hasMoreMessages.value = false;
    
    socketService.joinChat(chat._id);
    
    const response = await axiosInstance.get(
      `/api/chat/doctor/messages/${chat._id}?limit=10&page=1&sort=desc`
    );
    
    if (response.data && Array.isArray(response.data)) {
      const updatedChat = chats.value.find(c => c._id === chat._id);
      if (updatedChat) {
        // Đảo ngược mảng để hiển thị từ cũ đến mới
        updatedChat.messages = response.data.reverse();
        selectedChat.value = updatedChat;
        hasMoreMessages.value = response.data.length === 10;
        
        // Cuộn xuống tin nhắn mới nhất khi chọn chat
        nextTick(() => {
          scrollToBottom();
        });
      }
    }
  } catch (error) {
    console.error('Lỗi khi chọn chat:', error);
  }
};

const handleNewMessage = (data) => {
  console.log('Nhận tin nhắn mới:', data);
  
  if (selectedChat.value && data.chatId === selectedChat.value._id) {
    if (!selectedChat.value.messages) {
      selectedChat.value.messages = [];
    }
    
    const messageExists = selectedChat.value.messages.some(m => m._id === data._id);
    if (!messageExists) {
      const newMessage = {
        _id: data._id,
        content: data.content,
        senderModel: data.sender.model,
        sender: data.sender,
        receiver: data.receiver,
        createdAt: data.createdAt,
        isRead: data.isRead || false
      };
      
      // Thêm tin nhắn mới vào cuối mảng
      selectedChat.value.messages.push(newMessage);
      
      if (data.sender.model === 'User' && isLatestMessage(data)) {
        markMessageAsRead(data._id);
      }
      
      // Cuộn xuống tin nhắn mới
      nextTick(() => {
        scrollToBottom();
      });
    }
  }
  
  const chatIndex = chats.value.findIndex(c => c._id === data.chatId);
  if (chatIndex !== -1) {
    chats.value[chatIndex].lastMessage = {
      content: data.content,
      timestamp: data.createdAt
    };
  }
};

// Thêm hàm kiểm tra tin nhắn mới nhất
const isLatestMessage = (message) => {
  if (!selectedChat.value || !selectedChat.value.messages) return true;
  
  const messages = selectedChat.value.messages;
  const lastMessage = messages[messages.length - 1];
  
  return lastMessage && lastMessage._id === message._id;
};

// Thêm hàm đánh dấu tin nhắn đã đọc
const markMessageAsRead = async (messageId) => {
  try {
    await axiosInstance.put(`/api/messages/read/${messageId}`);
    // Cập nhật trạng thái tin nhắn trong UI
    if (selectedChat.value && selectedChat.value.messages) {
      const message = selectedChat.value.messages.find(m => m._id === messageId);
      if (message) {
        message.isRead = true;
      }
    }
  } catch (error) {
    console.error('Lỗi khi đánh dấu tin nhắn đã đọc:', error);
  }
};

const handleImageUpload = async (event) => {
  const file = event.target.files[0];
  if (!file) return;

  // Kiểm tra kích thước file (giới hạn 5MB)
  if (file.size > 5 * 1024 * 1024) {
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Kích thước ảnh không được vượt quá 5MB',
      life: 3000
    });
    return;
  }

  // Kiểm tra định dạng file
  if (!file.type.startsWith('image/')) {
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Vui lòng chọn file ảnh hợp lệ',
      life: 3000
    });
    return;
  }

  try {
    isUploading.value = true;
    const formData = new FormData();
    formData.append('image', file);
    
    // Upload trực tiếp lên ImageBB
    const response = await axios.post(
      `https://api.imgbb.com/1/upload?key=${import.meta.env.VITE_IMGBB_API_KEY}`,
      formData
    );

    if (response.data.success) {
      selectedImage.value = {
        url: response.data.data.url,
        deleteUrl: response.data.data.delete_url
      };
      // Tự động gửi tin nhắn với ảnh
      await sendMessage(true);
    }
  } catch (error) {
    console.error('Lỗi khi upload ảnh:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể upload ảnh. Vui lòng thử lại',
      life: 3000
    });
  } finally {
    isUploading.value = false;
    // Reset input file
    event.target.value = '';
  }
};

const sendMessage = async (isImage = false) => {
  if ((!newMessage.value.trim() && !selectedImage.value) || !selectedChat.value) return;
  
  try {
    const messageData = {
      chatId: selectedChat.value._id,
      content: newMessage.value.trim(),
      image: selectedImage.value
    };
    
    // Gửi tin nhắn qua socket
    socketService.sendMessage(messageData);
    
    // Reset form
    newMessage.value = '';
    selectedImage.value = null;
    
  } catch (error) {
    console.error('Lỗi khi gửi tin nhắn:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể gửi tin nhắn. Vui lòng thử lại',
      life: 3000
    });
  }
};

const loadMoreMessages = async () => {
  if (!selectedChat.value || isLoading.value) return;
  
  try {
    isLoading.value = true;
    currentPage.value++;
    
    const response = await axiosInstance.get(
      `/api/chat/doctor/messages/${selectedChat.value._id}?limit=10&page=${currentPage.value}&sort=desc`
    );
    
    if (response.data && Array.isArray(response.data)) {
      // Lưu vị trí cuộn hiện tại
      const chatMessagesElement = chatMessages.value;
      const oldScrollHeight = chatMessagesElement.scrollHeight;
      
      // Đảo ngược mảng và thêm vào đầu
      const reversedMessages = response.data.reverse();
      selectedChat.value.messages = [...reversedMessages, ...selectedChat.value.messages];
      
      // Kiểm tra còn tin nhắn cũ không
      hasMoreMessages.value = response.data.length === 10;
      
      // Đợi DOM cập nhật
      await nextTick();
      
      // Giữ nguyên vị trí cuộn để người dùng không bị nhảy
      chatMessagesElement.scrollTop = oldScrollHeight - chatMessagesElement.scrollHeight;
    }
  } catch (error) {
    console.error('Lỗi khi tải tin nhắn cũ:', error);
  } finally {
    isLoading.value = false;
  }
};

// Thêm hàm để cuộn xuống tin nhắn mới nhất
const scrollToBottom = () => {
  if (chatMessages.value) {
    chatMessages.value.scrollTop = chatMessages.value.scrollHeight;
  }
};

const handleScroll = () => {
  // Implementation of handleScroll
};

const openImagePreview = (imageUrl) => {
  previewImageUrl.value = imageUrl;
  showImagePreview.value = true;
  document.body.style.overflow = 'hidden';
};

const closeImagePreview = () => {
  showImagePreview.value = false;
  previewImageUrl.value = '';
  document.body.style.overflow = '';
};

const handleSearch = () => {
  // Implementation of handleSearch
};

const handleMediaScroll = () => {
  // Implementation of handleMediaScroll
};

onMounted(async () => {
  await fetchChats();
  
  // Reset số tin nhắn chưa đọc
  const doctorAppLayout = document.querySelector('#doctor-app');
  if (doctorAppLayout) {
    const event = new CustomEvent('reset-unread-messages');
    doctorAppLayout.dispatchEvent(event);
  }
  
  // Đăng ký các event socket
  socketService.on('new_message', handleNewMessage);
  socketService.on('user_online', handleUserOnline);
  socketService.on('user_offline', handleUserOffline);
  socketService.on('doctor_online', handleDoctorOnline);
  socketService.on('doctor_offline', handleDoctorOffline);
  socketService.on('error', handleError);
});

onBeforeUnmount(() => {
  // Hủy đăng ký các event socket
  socketService.off('new_message', handleNewMessage);
  socketService.off('user_online', handleUserOnline);
  socketService.off('user_offline', handleUserOffline);
  socketService.off('doctor_online', handleDoctorOnline);
  socketService.off('doctor_offline', handleDoctorOffline);
  socketService.off('error', handleError);

  // Reset các biến
  selectedChat.value = null;
  chats.value = [];
  newMessage.value = '';
  onlineUsers.value.clear();
  isOnline.value = true;
  hasMoreMessages.value = false;
  currentPage.value = 1;
  isLoading.value = false;
  showImagePreview.value = false;
  searchQuery.value = '';
  searchResults.value = [];
  mediaMessages.value = [];
  isLoadingImages.value = false;
});
</script>

<style scoped>
.chat-container {
  display: flex;
  height: calc(100vh - 100px);
  margin: 20px;
  border: 1px solid #ddd;
  border-radius: 8px;
}

.chat-sidebar {
  width: 300px;
  border-right: 1px solid #ddd;
  padding: 20px;
  overflow-y: auto;
}

.chat-item {
  display: flex;
  align-items: center;
  padding: 10px;
  cursor: pointer;
  border-radius: 8px;
  margin-bottom: 10px;
}

.chat-item:hover {
  background-color: #f5f5f5;
}

.chat-item.active {
  background-color: #e3f2fd;
}

.avatar {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  margin-right: 10px;
}

.chat-info {
  flex: 1;
}

.chat-info h3 {
  margin: 0;
  font-size: 16px;
}

.last-message {
  margin: 0;
  color: #666;
  font-size: 14px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.chat-main {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.chat-messages {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
  scroll-behavior: smooth;
}

.message {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  margin-bottom: 10px;
  max-width: 70%;
}

.message-doctor {
  align-items: flex-end;
  margin-left: auto;
}

.message-content {
  background-color: #f0f0f0;
  padding: 10px 15px;
  border-radius: 15px;
  margin-bottom: 5px;
  display: flex;
  align-items: center;
  gap: 5px;
}

.message-doctor .message-content {
  background-color: #28a745;
  color: white;
}

.message-time {
  font-size: 12px;
  color: #666;
}

.chat-input {
  padding: 20px;
  border-top: 1px solid #ddd;
  display: flex;
  gap: 10px;
}

.chat-input input {
  flex: 1;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.chat-input button {
  padding: 10px 20px;
  background-color: #28a745;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.chat-input button:hover {
  background-color: #218838;
}

.no-chat-selected {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #666;
}

.online-status {
  font-size: 12px;
  color: #666;
}

.online-status.online {
  color: #28a745;
}

.online-status::before {
  content: '';
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  margin-right: 4px;
  background-color: #666;
}

.online-status.online::before {
  background-color: #28a745;
}

.read-status {
  font-size: 14px;
  margin-left: 5px;
}

.read-status i {
  font-size: 14px;
}

.text-primary {
  color: #007bff;
}

.text-muted {
  color: #6c757d;
}

.load-more {
  display: flex;
  justify-content: center;
  margin-bottom: 15px;
}

.load-more-btn {
  background-color: #f8f9fa;
  border: 1px solid #dee2e6;
  border-radius: 20px;
  padding: 8px 16px;
  font-size: 14px;
  color: #6c757d;
  cursor: pointer;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  gap: 5px;
}

.load-more-btn:hover:not(:disabled) {
  background-color: #e9ecef;
  color: #495057;
}

.load-more-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.load-more-btn i {
  font-size: 12px;
}

.image-preview-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.9);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  cursor: pointer;
}

.image-preview-content {
  position: relative;
  max-width: 90%;
  max-height: 90vh;
  cursor: default;
}

.preview-image {
  max-width: 100%;
  max-height: 90vh;
  object-fit: contain;
  border-radius: 8px;
}

.close-preview-btn {
  position: absolute;
  top: -40px;
  right: 0;
  background: none;
  border: none;
  color: white;
  font-size: 24px;
  cursor: pointer;
  padding: 8px;
  transition: transform 0.2s;
}

.close-preview-btn:hover {
  transform: scale(1.1);
}

.upload-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: #f8f9fa;
  color: #6c757d;
  cursor: pointer;
  transition: all 0.3s ease;
}

.upload-btn:hover {
  background: #e9ecef;
  color: #495057;
}

.upload-btn i {
  font-size: 20px;
}

.message-image-wrapper {
  position: relative;
  max-width: 300px;
  margin: 4px 0;
}

.message-image {
  width: 100%;
  border-radius: 12px;
  cursor: pointer;
  transition: transform 0.2s;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.message-image:hover {
  transform: scale(1.02);
}

.message-doctor .message-image-wrapper {
  margin-left: auto;
}

.message-doctor .message-image {
  border-radius: 12px 12px 0 12px;
}
</style> 