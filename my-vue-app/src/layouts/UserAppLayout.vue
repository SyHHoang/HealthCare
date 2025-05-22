<template>
  <div id="user-app">
    <header class="user-app-header">
      <div class="header-container">
        <div class="header-left">
          <div class="logo">
            <router-link to="/user/dashboard">
             <div class="logo">MediConnect</div>
            </router-link>
          </div>
        </div>
        
        <nav class="main-nav">
          <router-link to="/user/dashboard" class="nav-item">
            <i class="bi bi-house-door-fill"></i>
            <span>Trang chủ</span>
          </router-link>
          <router-link to="/user/consultation-history" class="nav-item">
            <i class="bi bi-calendar-check"></i>
            <span>Cuộc hẹn</span>
          </router-link>
          <router-link to="/user/consultationlist" class="nav-item">
            <i class="bi bi-list-check"></i>
            <span>Đặt lịch tư vấn</span>
          </router-link>
          <router-link to="/user/doctors" class="nav-item">
            <i class="bi bi-person-plus"></i>
            <span>Tìm bác sĩ</span>
          </router-link>
                   <router-link to="/user/chat" class="nav-item">
            <i class="bi bi-chat-dots-fill"></i>
            <span>Nhắn tin</span>
          </router-link>
          <router-link to="/user/news" class="nav-item">
            <i class="bi bi-newspaper"></i>
            <span>Tin tức</span>
          </router-link>
          <router-link to="/user/feedback" class="nav-item">
            <i class="bi bi-star"></i>
            <span>Đánh giá</span>
          </router-link>
          <router-link to="/user/contact" class="nav-item">
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
                <button @click="markAllAsRead">Đánh dấu đã đọc</button>
              </div>
              <div class="notification-list" v-if="notifications.length > 0">
                <div v-for="(notification, index) in notifications" :key="index" 
                     class="notification-item" 
                     :class="{ 'unread': !notification.read }">
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
                <router-link to="/user/notifications">Xem tất cả</router-link>
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
              <router-link to="/user/profile" class="dropdown-item">
                <i class="bi bi-person"></i> Hồ sơ cá nhân
              </router-link>
              <router-link to="/user/medical-record" class="dropdown-item">
                <i class="bi bi-file-earmark-medical"></i> Hồ sơ y tế
              </router-link>
              <router-link to="/user/settings" class="dropdown-item">
                <i class="bi bi-gear"></i> Cài đặt
              </router-link>
              <div class="dropdown-divider"></div>
              <button @click="logout" class="dropdown-item logout-btn">
                <i class="bi bi-box-arrow-right"></i> Đăng xuất
              </button>
            </div>
          </div>
        </div>
      </div>
    </header>
    
    <main class="user-app-content">
      <router-view />
    </main>
    
    <Toast />
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

<script>
import { ref, onMounted, onBeforeUnmount } from 'vue';
import { useRouter } from 'vue-router';
import Toast from 'primevue/toast';
import NotificationBell from '../components/NotificationBell.vue';
import ChatbotView from '../components/ChatbotView.vue';
import { format, parseISO } from 'date-fns';
import { vi } from 'date-fns/locale';
import socketService from '../services/socketService';
import axiosInstance from '../services/axiosInstance';
import { useToast } from 'primevue/usetoast';

export default {
  name: 'UserAppLayout',
  components: {
    Toast,
    NotificationBell,
    ChatbotView
  },
  setup() {
    const router = useRouter();
    const toast = useToast();
    const userName = ref('Người dùng');
    const userAvatar = ref(null);
    const searchQuery = ref('');
    
    // Notifications
    const showNotifications = ref(false);
    const unreadNotifications = ref(0);
    const notifications = ref([]);
    
    // User menu
    const showUserMenu = ref(false);
    const showChatbot = ref(false);

    // Socket handlers
    const handleNewNotification = (data) => {
      console.log('Nhận thông báo mới:', data);
      notifications.value.unshift({
        type: data.type,
        title: data.title,
        message: data.message,
        time: data.createdAt,
        read: false,
        data: data.data
      });
      unreadNotifications.value++;

      // Chỉ hiển thị toast nếu có title và message
      if (data.title && data.message) {
        toast.add({
          severity: 'info',
          summary: data.title,
          detail: data.message,
          life: 5000
        });
      }
    };

    const handlePaymentNotification = (data) => {
      console.log('Nhận thông báo thanh toán:', data);
      let message = '';
      let type = 'payment_success';

      switch(data.orderType) {
        case 'consultation':
          message = `Thanh toán tư vấn thành công với số tiền ${data.amount.toLocaleString('vi-VN')}đ`;
          break;
        case 'Extend':
          message = `Gia hạn tư vấn thành công với số tiền ${data.amount.toLocaleString('vi-VN')}đ`;
          break;
        case 'AddCallVideo':
          message = `Mua thêm ${data.quantity} cuộc gọi video thành công với số tiền ${data.amount.toLocaleString('vi-VN')}đ`;
          break;
        default:
          message = `Thanh toán thành công với số tiền ${data.amount.toLocaleString('vi-VN')}đ`;
      }

      notifications.value.unshift({
        type: type,
        title: 'Thanh toán thành công',
        message: message,
        time: new Date(),
        read: false,
        data: data
      });
      unreadNotifications.value++;

      // Chỉ hiển thị toast một lần
      toast.add({
        severity: 'success',
        summary: 'Thanh toán thành công',
        detail: message,
        life: 5000
      });
    };

    const handleMessageNotification = (data) => {
      console.log('Nhận thông báo tin nhắn mới:', data);
      notifications.value.unshift({
        type: 'message',
        title: 'Tin nhắn mới',
        message: `Bạn có tin nhắn mới từ ${data.senderName}`,
        time: new Date(),
        read: false,
        data: data
      });
      unreadNotifications.value++;

      // Chỉ hiển thị toast một lần
      toast.add({
        severity: 'info',
        summary: 'Tin nhắn mới',
        detail: `Bạn có tin nhắn mới từ ${data.senderName}`,
        life: 5000
      });
    };

    const handleAppointmentNotification = (data) => {
      console.log('Nhận thông báo lịch hẹn:', data);
      notifications.value.unshift({
        type: 'appointment',
        title: 'Cập nhật lịch hẹn',
        message: data.message,
        time: new Date(),
        read: false,
        data: data
      });
      unreadNotifications.value++;

      // Chỉ hiển thị toast một lần
      toast.add({
        severity: 'info',
        summary: 'Cập nhật lịch hẹn',
        detail: data.message,
        life: 5000
      });
    };

    const handleFeedbackNotification = (data) => {
      console.log('Nhận thông báo phản hồi:', data);
      notifications.value.unshift({
        type: 'feedback',
        title: 'Phản hồi mới',
        message: data.message,
        time: new Date(),
        read: false,
        data: data
      });
      unreadNotifications.value++;

      // Chỉ hiển thị toast một lần
      toast.add({
        severity: 'success',
        summary: 'Phản hồi thành công',
        detail: data.message,
        life: 5000
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
        await axiosInstance.patch('/api/notifications/read-all');
        notifications.value.forEach(notification => {
          notification.read = true;
        });
        unreadNotifications.value = 0;
      } catch (error) {
        console.error('Lỗi khi đánh dấu đã đọc:', error);
        toast.add({
          severity: 'error',
          summary: 'Lỗi',
          detail: 'Không thể đánh dấu tất cả thông báo đã đọc',
          life: 3000
        });
      }
    };
    
    const getNotificationIcon = (type) => {
      const icons = {
        appointment: 'bi bi-calendar-check',
        message: 'bi bi-chat-dots',
        system: 'bi bi-info-circle',
        capsule: 'bi bi-capsule',
        reminder: 'bi bi-bell',
        payment_success: 'bi bi-check-circle-fill',
        feedback: 'bi bi-star'
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
        path: '/user/search', 
        query: { q: searchQuery.value } 
      });
      searchQuery.value = '';
    };
    
    const logout = () => {
      socketService.notifyOffline();
      socketService.disconnect();
      localStorage.removeItem('token');
      localStorage.removeItem('userInfo');
      router.push('/');
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
        const response = await axiosInstance.get('/api/notifications');
        notifications.value = response.data;
        unreadNotifications.value = notifications.value.filter(n => !n.read).length;
      } catch (error) {
        console.error('Lỗi khi lấy thông báo:', error);
        toast.add({
          severity: 'error',
          summary: 'Lỗi',
          detail: 'Không thể tải danh sách thông báo',
          life: 3000
        });
      }
    };
    
    const toggleChatbot = () => {
      showChatbot.value = !showChatbot.value;
    };
    
    onMounted(async () => {
      try {
        const userInfo = JSON.parse(localStorage.getItem('userInfo') || '{}');
        userName.value = userInfo.fullName || userInfo.name || 'Người dùng';
        userAvatar.value = '/src/assets/images/default-avatar.png';

        // Kết nối socket và lấy thông báo
        socketService.connect();
        await fetchNotifications();

        // Đăng ký các event socket một lần duy nhất
        socketService.off('new_notification', handleNewNotification);
        socketService.off('notification', handlePaymentNotification);
        socketService.off('new_message', handleMessageNotification);
        socketService.off('appointment_update', handleAppointmentNotification);
        socketService.off('feedback_success', handleFeedbackNotification);

        socketService.on('new_notification', handleNewNotification);
        socketService.on('notification', handlePaymentNotification);
        socketService.on('new_message', handleMessageNotification);
        socketService.on('appointment_update', handleAppointmentNotification);
        socketService.on('feedback_success', handleFeedbackNotification);
      } catch (error) {
        console.error('Lỗi khi khởi tạo:', error);
      }
      
      document.addEventListener('click', handleClickOutside);
    });
    
    onBeforeUnmount(() => {
      // Hủy đăng ký các event socket
      socketService.off('new_notification', handleNewNotification);
      socketService.off('notification', handlePaymentNotification);
      socketService.off('new_message', handleMessageNotification);
      socketService.off('appointment_update', handleAppointmentNotification);
      socketService.off('feedback_success', handleFeedbackNotification);
      
      document.removeEventListener('click', handleClickOutside);
    });
    
    return {
      userName,
      userAvatar,
      searchQuery,
      showNotifications,
      unreadNotifications,
      notifications,
      showUserMenu,
      toggleNotifications,
      toggleUserMenu,
      markAllAsRead,
      getNotificationIcon,
      formatTime,
      performSearch,
      logout,
      showChatbot,
      toggleChatbot
    };
  }
};
</script>

<style scoped>
/* Reset CSS */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

#user-app {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  background-color: #f8f9fa;
  font-family: 'Roboto', sans-serif;
}

/* Header Styles */
.user-app-header {
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
}

.primary-text {
  color: #3498db;
  font-weight: 700;
}

.secondary-text {
  color: #2c3e50;
  font-weight: 600;
}

/* Main Navigation */
.main-nav {
  display: flex;
  align-items: center;
  gap: 15px;
}

.nav-item {
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
  color: #3498db;
  background-color: #f8f9fa;
}

.router-link-active.nav-item {
  color: #3498db;
  background-color: #ebf5fb;
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
  color: #3498db;
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
  color: #3498db;
  cursor: pointer;
  font-size: 14px;
  padding: 5px 10px;
  border-radius: 4px;
  transition: all 0.3s;
}

.notification-header button:hover {
  background-color: #ebf5fb;
}

.notification-list {
  max-height: 300px;
  overflow-y: auto;
}

.notification-item {
  display: flex;
  padding: 12px 15px;
  border-bottom: 1px solid #f5f6fa;
  transition: all 0.3s;
  cursor: pointer;
}

.notification-item:hover {
  background-color: #f8f9fa;
}

.notification-item.unread {
  background-color: #ebf5fb;
}

.notification-icon {
  margin-right: 12px;
  color: #3498db;
  font-size: 18px;
  display: flex;
  align-items: center;
}

.notification-content {
  flex: 1;
}

.notification-text {
  margin: 0 0 5px 0;
  font-size: 14px;
  color: #2c3e50;
  line-height: 1.4;
}

.notification-time {
  font-size: 12px;
  color: #95a5a6;
}

.empty-notifications {
  padding: 20px;
  text-align: center;
  color: #95a5a6;
}

.notification-footer {
  padding: 12px 15px;
  border-top: 1px solid #eee;
  text-align: center;
}

.notification-footer a {
  color: #3498db;
  text-decoration: none;
  font-size: 14px;
  transition: all 0.3s;
}

.notification-footer a:hover {
  color: #217dbb;
}

/* Scrollbar cho notification-list */
.notification-list::-webkit-scrollbar {
  width: 6px;
}

.notification-list::-webkit-scrollbar-track {
  background: #f1f1f1;
}

.notification-list::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

.notification-list::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
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

.user-app-content {
  margin-top: 70px; /* Chiều cao của header */
  min-height: calc(100vh - 70px);
  padding: 20px;
  background-color: #f8f9fa;
  position: relative;
  z-index: 1;
}

/* Thêm vào phần media queries */
@media (max-width: 768px) {
  .user-app-content {
    padding: 15px;
  }
}
.logo {
  font-size: 24px;
  font-weight: bold;
}

.logo span {
  color: gold;
}
.user-profile {
  position: relative;
  display: flex;
  align-items: center;
  cursor: pointer;
  margin-left: 10px;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 12px;
  border-radius: 20px;
  background: #f5f6fa;
  transition: background 0.2s;
}

.user-info:hover {
  background: #ebf5fb;
}

.user-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid #e1e1e1;
  background: #fff;
}

.user-name {
  font-size: 15px;
  color: #2c3e50;
  font-weight: 500;
  max-width: 120px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.user-profile .bi-chevron-down {
  font-size: 16px;
  color: #888;
  margin-left: 2px;
}

.user-dropdown {
  position: absolute;
  top: 48px;
  right: 0;
  min-width: 180px;
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 4px 16px rgba(0,0,0,0.13);
  z-index: 1200;
  padding: 8px 0;
  animation: fadeIn 0.18s;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px);}
  to { opacity: 1; transform: translateY(0);}
}

.user-dropdown .dropdown-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 18px;
  color: #2c3e50;
  font-size: 15px;
  background: none;
  border: none;
  width: 100%;
  text-align: left;
  cursor: pointer;
  transition: background 0.2s, color 0.2s;
  text-decoration: none;
}

.user-dropdown .dropdown-item:hover,
.user-dropdown .dropdown-item.logout-btn:hover {
  background: #f8f9fa;
  color: #3498db;
}

.user-dropdown .dropdown-divider {
  height: 1px;
  background: #eee;
  margin: 6px 0;
}

.user-dropdown .logout-btn {
  color: #e74c3c;
}

.user-dropdown .logout-btn:hover {
  background: #fdecea;
  color: #c0392b;
}

@media (max-width: 600px) {
  .user-profile {
    margin-left: 0;
  }
  .user-info {
    padding: 4px 8px;
  }
  .user-name {
    max-width: 70px;
    font-size: 13px;
  }
  .user-dropdown {
    min-width: 140px;
    right: -20px;
  }
}
</style>