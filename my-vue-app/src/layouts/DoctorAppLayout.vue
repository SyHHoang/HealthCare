<template>
  <div id="doctor-app">
    <NotificationHandler />
    <header class="doctor-app-header">
      <div class="header-container">
        <div class="header-left">
          <div class="logo">
            <router-link to="/doctor/dashboard">
              <div class="logo">MediConnect</div>
            </router-link>
          </div>
        </div>
        
        <nav class="main-nav">
          <router-link to="/doctor/dashboard" class="nav-item">
            <i class="bi bi-house-door"></i>
            <span>Trang chủ</span>
          </router-link>
          <router-link to="/doctor/patients" class="nav-item">
            <i class="bi bi-people"></i>
            <span>Quản lý bệnh nhân</span>
          </router-link>
          <router-link to="/doctor/schedule" class="nav-item">
            <i class="bi bi-calendar-event"></i>
            <span>Quản lý Lịch làm việc</span>
          </router-link>
          <router-link to="/doctor/consultation-history" class="nav-item">
            <i class="bi bi-clock-history"></i>
            <span>Cuộc hẹn</span>
          </router-link>
          <router-link to="/doctor/chat" class="nav-item">
            <i class="bi bi-chat-dots"></i>
            <span>Nhắn tin</span>
            <span v-if="unreadMessages > 0" class="message-badge">{{ unreadMessages }}</span>
          </router-link>
                    <router-link to="/doctor/feedback" class="nav-item">
            <i class="bi bi-star"></i>
            <span>Đánh giá</span>
          </router-link>
          <router-link to="/doctor/contact" class="nav-item">
            <i class="bi bi-envelope"></i>
            <span>Liên hệ</span>
          </router-link>
        </nav>
        
        <div class="header-right">
          <div class="notifications">
            <button class="notification-btn" @click="toggleNotifications">
              <i class="bi bi-bell"></i>
              <span v-if="unreadNotifications > 0" class="notification-badge">{{ unreadNotifications }}</span>
            </button>
            <div class="notification-dropdown" v-if="showNotifications">
              <div class="notification-header">
                <h3>Thông báo</h3>
                <button 
                  @click="markAllAsRead" 
                  :disabled="!notifications.some(n => !n.read)"
                  class="mark-all-read-btn"
                >
                  Đánh dấu đã đọc
                </button>
              </div>
              <div class="notification-list" v-if="notifications.length > 0">
                <div v-for="(notification, index) in notifications" 
                     :key="index" 
                     class="notification-item" 
                     :class="{ 'unread': !notification.read }"
                     @click="handleNotificationClick(notification)">
                  <div class="notification-icon">
                    <i :class="getNotificationIcon(notification.type)"></i>
                  </div>
                  <div class="notification-content">
                    <p class="notification-text">{{ notification.message }}</p>
                    <span class="notification-time">{{ formatTime(notification.time) }}</span>
                  </div>
                </div>
              </div>
              <div class="empty-notifications" v-else>
                <p>Không có thông báo</p>
              </div>
              <div class="notification-footer">
                <router-link to="/doctor/notifications">Xem tất cả</router-link>
              </div>
            </div>
          </div>
          
          <div class="user-profile">
     <div class="user-info" @click="toggleUserMenu">
              <img :src="userAvatar || '@/assets/images/default-avatar.png'" alt="User Avatar" class="user-avatar">
              <span class="user-name">{{ userName }}</span>
              <i class="bi bi-chevron-down"></i>
            </div>
            <div class="user-dropdown" v-if="showUserMenu">
              <router-link to="/doctor/profile" class="dropdown-item">
                <i class="fas fa-user-md"></i> Hồ sơ bác sĩ
              </router-link>
              <router-link to="/doctor/settings" class="dropdown-item">
                <i class="fas fa-cog"></i> Cài đặt
              </router-link>
              <div class="dropdown-divider"></div>
              <button @click="logout" class="dropdown-item logout-btn">
                <i class="fas fa-sign-out-alt"></i> Đăng xuất
              </button>
            </div>
          </div>
        </div>
      </div>
    </header>
    
    <main class="doctor-app-content">
      <router-view />
    </main>
    
    <Toast ref="toast" />
    <!-- Chatbot Tooltip & Popup -->
    <Teleport to="body">
  <div class="chatbot-tooltip" @click="toggleChatbot" v-tooltip="'Chat với AI'">
    <i class="bi bi-robot"></i>
  </div>
  <div v-if="showChatbot">
    <!-- <div class="chatbot-overlay" @click="showChatbot = false"></div> -->
    <div class="chatbot-popup">
      <ChatbotView @close="showChatbot = false" />
    </div>
  </div>
</Teleport>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue';
import { useRouter } from 'vue-router';
import Toast from 'primevue/toast';
import { useToast } from 'primevue/usetoast';
import { format, parseISO } from 'date-fns';
import { vi } from 'date-fns/locale';
import socketService from '../services/socketService';
import axiosInstance from '../services/axiosInstance';
import ChatbotView from '../components/ChatbotView.vue';
import NotificationHandler from '../components/NotificationHandler.vue';
import { getFCMToken } from '../firebase-config';

const router = useRouter();
const toast = useToast();
const doctorName = ref('Nguyễn Văn A');
const doctorAvatar = ref(null);
const searchQuery = ref('');

// Notifications
const showNotifications = ref(false);
const unreadNotifications = ref(0);
const notifications = ref([]);

// User menu
const showUserMenu = ref(false);
const unreadMessages = ref(0);

// Chatbot
const showChatbot = ref(false);

const requestNotificationPermission = async () => {
  try {
    console.log('Requesting notification permission', Notification.permission);
    const permission = await Notification.requestPermission();
    if (permission === 'granted') {
      const token = await getFCMToken();
      if (token) {
        await axiosInstance.post('/api/doctors/update-fcm-token', { fcmToken: token });
        console.log('FCM token saved successfully for doctor');
        toast.add({
          severity: 'success',
          summary: 'Thành công',
          detail: 'Bạn đã cho phép nhận thông báo',
          life: 3000
        });
      }
    } else {
      toast.add({
        severity: 'warn',
        summary: 'Cảnh báo',
        detail: 'Bạn cần cho phép thông báo để nhận thông tin về giao dịch',
        life: 5000
      });
    }
  } catch (error) {
    console.error('Error requesting notification permission:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể yêu cầu quyền thông báo',
      life: 3000
    });
  }
};

// Socket handlers
const handleNewNotification = (data) => {
  console.log('Nhận thông báo mới:', data);
  const newNotification = {
    type: data.type || 'system',
    message: data.message,
    time: new Date(),
    read: false,
    data: data.data || {}
  };
  
  notifications.value.unshift(newNotification);
  
  // Chỉ tăng số thông báo chưa đọc nếu không phải là thông báo tin nhắn
  if (data.type !== 'message') {
    unreadNotifications.value++;
  }
  
  // Hiển thị toast thông báo
  toast.add({
    severity: 'info',
    summary: 'Thông báo mới',
    detail: data.message,
    life: 3000
  });
};

const handleNewMessage = (data) => {
  console.log('Nhận tin nhắn mới:', data);
  if (!window.location.pathname.includes('/doctor/chat')) {
    unreadMessages.value++;
  }
  
  const newNotification = {
    type: 'message',
    message: data.message || 'Bạn có tin nhắn mới',
    time: new Date(),
    read: false,
    data: {
      chatId: data.chatId,
      senderId: data.senderId
    }
  };
  
  notifications.value.unshift(newNotification);
};

const handleAppointmentNotification = (data) => {
  console.log('Nhận thông báo lịch hẹn:', data);
  const newNotification = {
    type: 'appointment',
    message: data.message,
    time: new Date(),
    read: false,
    data: {
      appointmentId: data.appointmentId,
      status: data.status
    }
  };
  
  notifications.value.unshift(newNotification);
  unreadNotifications.value++;
  
  toast.add({
    severity: 'info',
    summary: 'Lịch hẹn mới',
    detail: data.message,
    life: 3000
  });
};

const handleFeedbackNotification = (data) => {
  console.log('Nhận thông báo phản hồi:', data);
  const newNotification = {
    type: 'feedback',
    message: data.message,
    time: new Date(),
    read: false,
    data: {
      feedbackId: data.feedbackId,
      rating: data.rating
    }
  };
  
  notifications.value.unshift(newNotification);
  unreadNotifications.value++;
  
  toast.add({
    severity: 'info',
    summary: 'Phản hồi mới',
    detail: data.message,
    life: 3000
  });
};

const toggleNotifications = () => {
  showNotifications.value = !showNotifications.value;
  showUserMenu.value = false;
};

const toggleUserMenu = () => {
  showUserMenu.value = !showUserMenu.value;
  showNotifications.value = false;
};

const markAllAsRead = async () => {
  try {
    await axiosInstance.patch('/api/notifications/doctor/read-all');
    notifications.value.forEach(notification => {
      notification.read = true;
    });
    unreadNotifications.value = 0;
    toast.add({
      severity: 'success',
      summary: 'Thành công',
      detail: 'Đã đánh dấu tất cả thông báo đã đọc',
      life: 2000
    });
  } catch (error) {
    console.error('Lỗi khi đánh dấu tất cả đã đọc:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể đánh dấu tất cả thông báo đã đọc',
      life: 3000
    });
  }
};

const handleNotificationClick = async (notification) => {
  if (!notification.read) {
    try {
      await axiosInstance.patch(`/api/notifications/doctor/${notification._id}/read`);
      notification.read = true;
      
      // Giảm số lượng thông báo chưa đọc tương ứng
      if (notification.type === 'message') {
        unreadMessages.value = Math.max(0, unreadMessages.value - 1);
      } else {
        unreadNotifications.value = Math.max(0, unreadNotifications.value - 1);
      }
    } catch (error) {
      console.error('Lỗi khi đánh dấu đã đọc:', error);
    }
  }

  // Xử lý điều hướng dựa vào loại thông báo
  if (notification.data) {
    switch (notification.type) {
      case 'appointment':
        router.push(`/doctor/appointments/${notification.data.appointmentId}`);
        break;
      case 'message':
        router.push(`/doctor/chat/${notification.data.chatId}`);
        break;
      case 'prescription':
        router.push(`/doctor/prescriptions/${notification.data.prescriptionId}`);
        break;
      case 'feedback':
        router.push('/doctor/feedback');
        break;
      case 'payment_success':
        router.push('/doctor/transactions');
        break;
    }
  }
  showNotifications.value = false;
};

const getNotificationIcon = (type) => {
  const icons = {
    appointment: 'bi bi-calendar-check',
    message: 'bi bi-chat-dots',
    system: 'bi bi-info-circle',
    prescription: 'bi bi-file-earmark-medical',
    cancel: 'bi bi-calendar-x',
    reminder: 'bi bi-bell',
    feedback: 'bi bi-chat-left-text'
  };
  return icons[type] || 'bi bi-bell';
};

const formatTime = (time) => {
  try {
    const date = time instanceof Date ? time : parseISO(time);
    const now = new Date();
    if (date.toDateString() === now.toDateString()) {
      return format(date, 'HH:mm', { locale: vi });
    }
    return format(date, 'dd/MM/yyyy - HH:mm', { locale: vi });
  } catch (error) {
    return 'Không rõ thời gian';
  }
};

const performSearch = () => {
  if (!searchQuery.value.trim()) return;
  router.push({ 
    path: '/doctor/patients/search', 
    query: { q: searchQuery.value } 
  });
  searchQuery.value = '';
};

const logout = () => {
  socketService.notifyOffline();
  socketService.disconnect();
  localStorage.removeItem('token');
  localStorage.removeItem('doctorInfo');
  router.push('/auth/doctor/login');
};

const handleClickOutside = (event) => {
  if (showNotifications.value) {
    const notificationElement = document.querySelector('.notifications');
    if (notificationElement && !notificationElement.contains(event.target)) {
      showNotifications.value = false;
    }
  }
  
  if (showUserMenu.value) {
    const userElement = document.querySelector('.user-profile');
    if (userElement && !userElement.contains(event.target)) {
      showUserMenu.value = false;
    }
  }
};

const fetchNotifications = async () => {
  try {
    const response = await axiosInstance.get('/api/notifications/doctor');
    notifications.value = response.data;
    unreadNotifications.value = notifications.value.filter(n => !n.read).length;
  } catch (error) {
    console.error('Lỗi khi lấy thông báo:', error);
  }
};

const toggleChatbot = () => {
  showChatbot.value = !showChatbot.value;
};

onMounted(async () => {
  // Thêm Font Awesome
  const link = document.createElement('link');
  link.rel = 'stylesheet';
  link.href = 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css';
  document.head.appendChild(link);
  
  try {
    const doctorInfo = JSON.parse(localStorage.getItem('doctorInfo') || '{}');
    doctorName.value = doctorInfo.fullName || doctorInfo.name || 'Bác sĩ';
    doctorAvatar.value = doctorInfo.avatar;

    // Xin quyền thông báo khi component được mount
    await requestNotificationPermission();

    // Kết nối socket và lấy thông báo
    socketService.connect();
    await fetchNotifications();

    // Đăng ký các event socket
    socketService.on('new_notification', handleNewNotification);
    socketService.on('new_message', handleNewMessage);
    socketService.on('appointment_update', handleAppointmentNotification);
    socketService.on('feedback_notification', handleFeedbackNotification);

    // Thêm event listener để reset số tin nhắn chưa đọc
    const doctorApp = document.querySelector('#doctor-app');
    if (doctorApp) {
      doctorApp.addEventListener('reset-unread-messages', () => {
        unreadMessages.value = 0;
      });
    }
  } catch (error) {
    console.error('Lỗi khi khởi tạo:', error);
  }
  
  document.addEventListener('click', handleClickOutside);
});

onBeforeUnmount(() => {
  // Hủy đăng ký các event socket
  socketService.off('new_notification', handleNewNotification);
  socketService.off('new_message', handleNewMessage);
  socketService.off('appointment_update', handleAppointmentNotification);
  socketService.off('feedback_notification', handleFeedbackNotification);
  
  // Xóa event listener
  const doctorApp = document.querySelector('#doctor-app');
  if (doctorApp) {
    doctorApp.removeEventListener('reset-unread-messages', () => {
      unreadMessages.value = 0;
    });
  }
  
  document.removeEventListener('click', handleClickOutside);
});
</script>

<style scoped>
/* Reset CSS */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

#doctor-app {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  background-color: #f8f9fa;
  font-family: 'Roboto', sans-serif;
}

/* Header Styles */
.doctor-app-header {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  background-color: #ffffff;
  box-shadow: 0 2px 10px rgba(0,0,0,0.08);
  z-index: 1000;
}

.header-container {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
  max-width: 1400px;
  margin: 0 auto;
  height: 70px;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 20px;
  flex: 1;
}

.logo a {
  text-decoration: none;
}

.logo h2 {
  margin: 0;
  font-size: 24px;
  line-height: 1;
  position: relative;
}

.primary-text {
  color: #3498db;
  font-weight: 700;
}

.secondary-text {
  color: #2c3e50;
  font-weight: 600;
}

.doctor-badge {
  font-size: 10px;
  background-color: #27ae60;
  color: white;
  padding: 2px 5px;
  border-radius: 3px;
  margin-left: 5px;
  font-weight: 600;
  position: absolute;
  top: -2px;
}

.search-container {
  flex: 1;
  max-width: 300px;
}

.search-box {
  display: flex;
  align-items: center;
  background-color: #f5f6fa;
  border-radius: 24px;
  padding: 0 15px;
  height: 40px;
  transition: all 0.3s;
}

.search-box:focus-within {
  box-shadow: 0 0 0 2px rgba(52, 152, 219, 0.3);
}

.search-box input {
  flex: 1;
  border: none;
  outline: none;
  background: transparent;
  padding: 0 10px;
  font-size: 14px;
}

.search-box button {
  background: none;
  border: none;
  color: #95a5a6;
  cursor: pointer;
  transition: color 0.3s;
}

.search-box button:hover {
  color: #3498db;
}

/* Main Navigation */
.main-nav {
  display: flex;
  align-items: center;
  gap: 15px;
}

.nav-item {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-decoration: none;
  color: #7f8c8d;
  font-size: 13px;
  padding: 5px 12px;
  border-radius: 8px;
  transition: all 0.3s;
}

.nav-item i {
  font-size: 18px;
  margin-bottom: 5px;
}

.nav-item:hover {
  color: #27ae60;
  background-color: #f8f9fa;
}

.router-link-active.nav-item {
  color: #27ae60;
  background-color: #eafaf1;
}

/* Header Right */
.header-right {
  display: flex;
  align-items: center;
  gap: 20px;
}

/* Notifications */
.notifications {
  position: relative;
}

.notification-btn {
  background: none;
  border: none;
  position: relative;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: #7f8c8d;
  font-size: 18px;
  transition: all 0.3s;
}

.notification-btn:hover {
  background-color: #f5f6fa;
  color: #27ae60;
}

.notification-badge {
  position: absolute;
  top: 0;
  right: 0;
  background-color: #e74c3c;
  color: white;
  border-radius: 10px;
  padding: 1px 6px;
  font-size: 10px;
  min-width: 15px;
  text-align: center;
}

.notification-dropdown {
  position: absolute;
  top: 45px;
  right: -100px;
  width: 350px;
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 5px 15px rgba(0,0,0,0.15);
  z-index: 1000;
  overflow: hidden;
}

.notification-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px;
  border-bottom: 1px solid #eee;
}

.notification-header h3 {
  margin: 0;
  font-size: 16px;
  color: #2c3e50;
}

.notification-header button {
  background: none;
  border: none;
  color: #27ae60;
  cursor: pointer;
  font-size: 12px;
}

.notification-list {
  max-height: 300px;
  overflow-y: auto;
}

.notification-item {
  display: flex;
  padding: 12px 15px;
  border-bottom: 1px solid #eee;
  transition: background 0.3s;
  cursor: pointer;
}

.notification-item:hover {
  background-color: #f9f9f9;
}

.notification-item.unread {
  background-color: #eafaf1;
}

.notification-icon {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background-color: #eafaf1;
  color: #27ae60;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 12px;
  flex-shrink: 0;
}

.notification-content {
  flex: 1;
}

.notification-text {
  margin: 0 0 5px;
  font-size: 14px;
  color: #2c3e50;
}

.notification-time {
  font-size: 11px;
  color: #95a5a6;
}

.empty-notifications {
  padding: 30px;
  text-align: center;
  color: #95a5a6;
}

.notification-footer {
  padding: 10px;
  text-align: center;
  border-top: 1px solid #eee;
}

.notification-footer a {
  color: #27ae60;
  text-decoration: none;
  font-size: 14px;
}

/* User Profile */
.user-profile {
  position: relative;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  padding: 6px 10px;
  border-radius: 20px;
  transition: all 0.3s;
}

.user-info:hover {
  background-color: #f5f6fa;
}

.user-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid #fff;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.user-name {
  font-weight: 600;
  color: #2c3e50;
  font-size: 14px;
}

.user-info i {
  font-size: 12px;
  color: #95a5a6;
}

.user-dropdown {
  position: absolute;
  top: 50px;
  right: 0;
  width: 220px;
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 5px 15px rgba(0,0,0,0.15);
  z-index: 1000;
  overflow: hidden;
}

.dropdown-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px 15px;
  text-decoration: none;
  color: #2c3e50;
  transition: all 0.3s;
  font-size: 14px;
}

.dropdown-item:hover {
  background-color: #f5f6fa;
}

.dropdown-divider {
  height: 1px;
  background-color: #eee;
  margin: 5px 0;
}

.logout-btn {
  width: 100%;
  text-align: left;
  background: none;
  border: none;
  color: #e74c3c;
  cursor: pointer;
  font-size: 14px;
}

/* Main Content */
.doctor-app-content {
  margin-top: 70px;
  padding: 20px;
  max-width: 1400px;
  width: 100%;
  margin-left: auto;
  margin-right: auto;
  flex: 1;
}

/* Responsive Styles */
@media (max-width: 1024px) {
  .header-container {
    padding: 0 15px;
  }
  
  .main-nav {
    gap: 10px;
  }
  
  .nav-item {
    padding: 5px 8px;
  }
}

@media (max-width: 768px) {
  .search-container {
    display: none;
  }
  
  .user-name {
    display: none;
  }
  
  .user-info {
    padding: 4px 8px;
  }
  
  .notification-dropdown {
    right: -150px;
    width: 300px;
  }
  
  .user-dropdown {
    right: -30px;
  }
}

@media (max-width: 576px) {
  .header-container {
    height: 60px;
  }
  
  .logo h2 {
    font-size: 20px;
  }
  
  .doctor-badge {
    top: -3px;
    font-size: 8px;
  }
  
  .main-nav {
    position: fixed;
    bottom: 0;
    left: 0;
    width: 100%;
    display: flex;
    justify-content: space-around;
    background-color: white;
    box-shadow: 0 -2px 10px rgba(0,0,0,0.1);
    padding: 8px 0;
    gap: 0;
  }
  
  .nav-item {
    flex: 1;
    padding: 8px 0;
    border-radius: 0;
  }
  
  .header-right {
    gap: 10px;
  }
  
  .doctor-app-content {
    margin-top: 60px;
    margin-bottom: 60px; /* Để tránh nội dung bị che bởi bottom nav */
    padding: 15px;
  }
  
  .notification-dropdown {
    width: 280px;
    right: -120px;
  }
}

.message-badge {
  position: absolute;
  top: -5px;
  right: -5px;
  background-color: #e74c3c;
  color: white;
  border-radius: 50%;
  width: 18px;
  height: 18px;
  font-size: 11px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
}

.chatbot-tooltip {
  position: fixed;
  bottom: 32px;
  right: 32px;
  z-index: 2000;
  background: #3498db;
  color: #fff;
  border-radius: 50%;
  width: 56px;
  height: 56px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 16px rgba(0,0,0,0.18);
  cursor: pointer;
  font-size: 28px;
  transition: background 0.2s;
}
.chatbot-tooltip:hover {
  background: #217dbb;
}
.chatbot-overlay {
  position: fixed;
  inset: 0;
  background: rgba(44, 62, 80, 0.35);
  z-index: 3000;
}

.chatbot-popup {
  position: fixed;
  bottom: 90px;
  right: 40px;
  z-index: 3100;
  max-width: 350px;
  width: 100vw;
  max-height: 80vh;
  background: #fff;
  border-radius: 18px;
  box-shadow: 0 8px 32px rgba(0,0,0,0.18);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  animation: chatbot-fade-in 0.2s;
}

@media (max-width: 600px) {
  .chatbot-popup {
    right: 0;
    left: 0;
    bottom: 0;
    max-width: 100vw;
    width: 100vw;
    border-radius: 0;
    height: 100vh;
    max-height: 100vh;
  }
}

@keyframes chatbot-fade-in {
  from { opacity: 0; transform: translateY(40px);}
  to { opacity: 1; transform: translateY(0);}
}
.logo {
  font-size: 24px;
  font-weight: bold;
}

.logo span {
  color: gold;
}

.mark-all-read-btn {
  background: none;
  border: none;
  color: #27ae60;
  cursor: pointer;
  font-size: 12px;
  padding: 4px 8px;
  border-radius: 4px;
  transition: all 0.3s;
}

.mark-all-read-btn:hover:not(:disabled) {
  background-color: #eafaf1;
}

.mark-all-read-btn:disabled {
  color: #95a5a6;
  cursor: not-allowed;
}
</style> 