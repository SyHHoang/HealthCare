<template>
  <div class="chat-container">
    <div class="chat-sidebar">
      <h2>Danh sách chat</h2>
      <div v-for="chat in chats" :key="chat._id" 
           class="chat-item" 
           :class="{ active: selectedChat?._id === chat._id }"
           @click="selectChat(chat)">
        <img :src="chat.doctorId?.avatar || '/images/default-doctor.jpg'" class="avatar" />
        <div class="chat-info">
          <h3>{{ chat.doctorId?.fullName || 'Bác sĩ' }}</h3>
  
          <span class="online-status" :class="{ online: isDoctorOnline(chat.doctorId?._id) }">
            {{ isDoctorOnline(chat.doctorId?._id) ? 'Online' : 'Offline' }}
          </span>
        </div>
      </div>
    </div>
    
    <div class="chat-main">
      <div v-if="selectedChat" class="chat-messages" ref="chatMessages" @scroll="handleScroll">
        <div v-if="hasMoreMessages" class="load-more">
          <button @click="loadMoreMessages" class="load-more-btn">
            <i class="bi bi-arrow-up"></i> Tải tin nhắn cũ
          </button>
        </div>
        <div v-for="message in selectedChat.messages" :key="message._id" 
             class="message" 
             :class="{ 'message-user': message.senderModel === 'User' }">
          <div v-if="message.content" class="message-content">
            <p>{{ message.content }}</p>
          </div>
          <div v-if="message.image" class="message-image-wrapper">
            <img :src="message.image.url" alt="Hình ảnh" class="message-image" @click="openImagePreview(message.image.url)" />
          </div>
          <div class="message-time">
            {{ new Date(message.createdAt).toLocaleTimeString() }}
            <span v-if="message.senderModel === 'User' && isLatestMessage(message)" class="read-status">
              <i v-if="message.isRead" class="bi bi-check2-all text-primary"></i>
              <i v-else class="bi bi-check2 text-muted"></i>
            </span>
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

    <!-- Thêm modal xem ảnh -->
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
const onlineDoctors = ref(new Set());
const isOnline = ref(false);
const chatMessages = ref(null);
const hasMoreMessages = ref(false);
const currentPage = ref(1);
const isLoading = ref(false);
const selectedImage = ref(null);
const isUploading = ref(false);
const showImagePreview = ref(false);
const previewImageUrl = ref('');

const isDoctorOnline = (doctorId) => {
  return onlineDoctors.value.has(doctorId);
};

const handleDoctorOnline = (data) => {
  console.log('Bác sĩ online:', data);
  onlineDoctors.value.add(data.doctorId);
};

const handleDoctorOffline = (data) => {
  console.log('Bác sĩ offline:', data);
  onlineDoctors.value.delete(data.doctorId);
};

// Thêm hàm xử lý trạng thái online của user
const handleUserOnline = (data) => {
  console.log('User online:', data);
  isOnline.value = true;
};

const handleUserOffline = (data) => {
  console.log('User offline:', data);
  isOnline.value = false;
};

const handleError = (error) => {
  console.error('Lỗi socket:', error);
  // Hiển thị thông báo lỗi cho người dùng
  alert(error.message || 'Có lỗi xảy ra khi gửi tin nhắn');
};

const fetchChats = async () => {
  try {
    const response = await axiosInstance.get('/api/chat/user');
    if (response.data && Array.isArray(response.data)) {
      chats.value = response.data;
      console.log("Danh sách chat của user:", response.data);
      
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

const handleScroll = (event) => {
  const { scrollTop } = event.target;
  if (scrollTop === 0 && hasMoreMessages.value && !isLoading.value) {
    loadMoreMessages();
  }
};

const loadMoreMessages = async () => {
  if (!selectedChat.value || isLoading.value) return;
  
  try {
    isLoading.value = true;
    currentPage.value++;
    
    const response = await axiosInstance.get(
      `/api/chat/messages/${selectedChat.value._id}?limit=10&page=${currentPage.value}&sort=desc`
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

const selectChat = async (chat) => {
  try {
    selectedChat.value = chat;
    currentPage.value = 1;
    hasMoreMessages.value = false;
    
    socketService.joinChat(chat._id);
    
    const response = await axiosInstance.get(
      `/api/chat/messages/${chat._id}?limit=10&page=1&sort=desc`
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
      
      if (data.sender.model === 'Doctor' && isLatestMessage(data)) {
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
    console.log(import.meta.env.VITE_IMGBB_API_KEY);
    // Upload trực tiếp lên ImageBB
    const response = await axios.post(
      `https://api.imgbb.com/1/upload?key=${import.meta.env.VITE_IMGBB_API_KEY}`,
      formData
    );
    console.log(response);
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

// Thêm hàm scrollToBottom
const scrollToBottom = () => {
  if (chatMessages.value) {
    chatMessages.value.scrollTop = chatMessages.value.scrollHeight;
  }
};

// Thêm các hàm xử lý xem ảnh
const openImagePreview = (imageUrl) => {
  previewImageUrl.value = imageUrl;
  showImagePreview.value = true;
  document.body.style.overflow = 'hidden'; // Ngăn scroll khi đang xem ảnh
};

const closeImagePreview = () => {
  showImagePreview.value = false;
  previewImageUrl.value = '';
  document.body.style.overflow = ''; // Cho phép scroll lại
};

onMounted(async () => {
  await fetchChats();
  
  // Đăng ký các event socket
  socketService.on('new_message', handleNewMessage);
  socketService.on('doctor_online', handleDoctorOnline);
  socketService.on('doctor_offline', handleDoctorOffline);
  socketService.on('user_online', handleUserOnline);
  socketService.on('user_offline', handleUserOffline);
  socketService.on('error', handleError);
});

onBeforeUnmount(() => {
  // Hủy đăng ký các event socket
  socketService.off('new_message', handleNewMessage);
  socketService.off('doctor_online', handleDoctorOnline);
  socketService.off('doctor_offline', handleDoctorOffline);
  socketService.off('user_online', handleUserOnline);
  socketService.off('user_offline', handleUserOffline);
  socketService.off('error', handleError);
});
</script>

<style scoped>
.chat-container {
  display: flex;
  height: calc(100vh - 110px);
  margin: 10px auto;
  background: #fff;
  border-radius: 16px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
  overflow: hidden;
  max-width: 1200px;
}

.chat-sidebar {
  width: 280px;
  background: #f8f9fa;
  border-right: 1px solid #e9ecef;
  display: flex;
  flex-direction: column;
}

.chat-sidebar h2 {
  padding: 16px;
  margin: 0;
  font-size: 1.25rem;
  color: #2c3e50;
  border-bottom: 1px solid #e9ecef;
}

.chat-list {
  flex: 1;
  overflow-y: auto;
  padding: 8px;
}

.chat-item {
  display: flex;
  align-items: center;
  padding: 10px;
  cursor: pointer;
  border-radius: 12px;
  margin-bottom: 6px;
  transition: all 0.3s ease;
  background: #fff;
  border: 1px solid #e9ecef;
}

.chat-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}

.chat-item.active {
  background: #e3f2fd;
  border-color: #90caf9;
}

.avatar {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  margin-right: 10px;
  object-fit: cover;
  border: 2px solid #fff;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.chat-info {
  flex: 1;
  min-width: 0;
}

.chat-info h3 {
  margin: 0 0 2px;
  font-size: 14px;
  font-weight: 600;
  color: #2c3e50;
}

.last-message {
  margin: 0;
  color: #6c757d;
  font-size: 12px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.chat-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: #fff;
  max-width: 100%;
}

.chat-header {
  padding: 12px 16px;
  border-bottom: 1px solid #e9ecef;
  display: flex;
  align-items: center;
  background: #fff;
}

.chat-messages {
  flex: 1;
  padding: 32px 0 16px 24px;
  overflow-y: auto;
  background: #f8f9fa;
  scroll-behavior: smooth;
}

.message {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  margin-bottom: 8px;
  max-width: 60%;
  word-break: break-word;
}

.message-user {
  align-self: flex-end;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  margin-bottom: 8px;
  max-width: 95%;
  word-break: break-word;
  margin-right: 0;
}

.message-content {
  padding: 10px 15px;
  border-radius: 12px;
  font-size: 14px;
  line-height: 1.4;
  position: relative;
  background: #e9ecef;
  color: #2c3e50;
  word-break: break-word;
}

.message-user .message-content {
  background: #007bff;
  color: #fff;
}

.message-time {
  font-size: 10px;
  color: #6c757d;
  margin-top: 2px;
  padding: 0 4px;
}

.chat-input {
  padding: 12px 16px;
  background: #fff;
  border-top: 1px solid #e9ecef;
  display: flex;
  gap: 8px;
  align-items: center;
}

.chat-input input {
  flex: 1;
  padding: 8px 12px;
  border: 1px solid #e9ecef;
  border-radius: 20px;
  font-size: 13px;
  transition: all 0.3s ease;
}

.chat-input input:focus {
  outline: none;
  border-color: #90caf9;
  box-shadow: 0 0 0 3px rgba(144, 202, 249, 0.2);
}

.chat-input button {
  padding: 8px 16px;
  background: #007bff;
  color: #fff;
  border: none;
  border-radius: 20px;
  font-weight: 500;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 6px;
}

.chat-input button:hover {
  background: #0056b3;
  transform: translateY(-1px);
}

.chat-input button:active {
  transform: translateY(0);
}

.online-status {
  font-size: 12px;
  display: flex;
  align-items: center;
  gap: 4px;
  margin-top: 4px;
}

.online-status::before {
  content: '';
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #6c757d;
}

.online-status.online::before {
  background: #28a745;
}

.read-status {
  margin-left: 4px;
  font-size: 12px;
}

.load-more {
  text-align: center;
  margin-bottom: 12px;
}

.load-more-btn {
  background: #fff;
  border: 1px solid #e9ecef;
  border-radius: 16px;
  padding: 6px 12px;
  font-size: 12px;
  color: #6c757d;
  cursor: pointer;
  transition: all 0.3s ease;
  display: inline-flex;
  align-items: center;
  gap: 4px;
}

.no-chat-selected {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #6c757d;
  background: #f8f9fa;
  gap: 16px;
}

.no-chat-selected i {
  font-size: 48px;
  color: #dee2e6;
}

@media (max-width: 768px) {
  .chat-container {
    margin: 0;
    height: calc(100vh - 70px);
    border-radius: 0;
    max-width: 100%;
  }

  .chat-sidebar {
    width: 100%;
    position: absolute;
    left: 0;
    top: 0;
    bottom: 0;
    z-index: 10;
    transform: translateX(-100%);
    transition: transform 0.3s ease;
  }

  .chat-sidebar.active {
    transform: translateX(0);
  }

  .chat-main {
    max-width: 100%;
  }
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

.message-user .message-image-wrapper {
  margin-left: auto;
}

.message-user .message-image {
  border-radius: 12px 12px 0 12px;
}

/* Thêm styles cho modal xem ảnh */
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

/* Thêm hiệu ứng hover cho ảnh trong tin nhắn */
.message-image {
  cursor: zoom-in;
}
</style> 