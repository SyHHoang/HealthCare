<template>
  <div class="user-layout">
    <!-- Sidebar -->
    <div class="sidebar" :class="{ 'collapsed': isSidebarCollapsed }">
      <div class="sidebar-header">
        <h3>HealthRight</h3>
      </div>
      <nav class="sidebar-nav">
        <ul>
          <li>
            <router-link to="/user/dashboard" class="nav-item">
              <i class="bi bi-house-fill"></i>
              <span>Trang chủ</span>
            </router-link>
          </li>
          <li>
            <router-link to="/user/consultation-history" class="nav-item">
              <i class="bi bi-calendar-check"></i>
              <span>Lịch sử tư vấn</span>
            </router-link>
          </li>
          <li>
            <router-link to="/user/consultationlist" class="nav-item">
              <i class="bi bi-list-check"></i>
              <span>Danh sách tư vấn</span>
            </router-link>
          </li>
          <li>
            <router-link to="/user/profile" class="nav-item">
              <i class="bi bi-person-fill"></i>
              <span>Hồ sơ cá nhân</span>
            </router-link>
          </li>
          <li>
            <router-link to="/user/medical-record" class="nav-item">
              <i class="bi bi-file-medical"></i>
              <span>Hồ sơ y tế</span>
            </router-link>
          </li>
          <li>
            <router-link to="/user/doctors" class="nav-item">
              <i class="bi bi-heart-pulse-fill"></i>
              <span>Bác sĩ & Chuyên khoa</span>
            </router-link>
          </li>
          <li>
            <router-link to="/user/drugs" class="nav-item">
              <i class="bi bi-capsule"></i>
              <span>Tìm kiếm thuốc</span>
            </router-link>
          </li>
          <li>
            <router-link to="/user/news" class="nav-item">
              <i class="bi bi-newspaper"></i>
              <span>Tin tức y tế</span>
            </router-link>
          </li>
          <li>
            <router-link to="/user/feedback" class="nav-item">
              <i class="bi bi-star"></i>
              <span>Đánh giá</span>
            </router-link>
          </li>
          <li>
            <router-link to="/user/contact" class="nav-item">
              <i class="bi bi-envelope"></i>
              <span>Liên hệ</span>
            </router-link>
          </li>
          <li>
            <router-link to="/user/chat" class="nav-item">
              <i class="bi bi-chat-dots-fill"></i>
              <span>Trò chuyện</span>
            </router-link>
          </li>
        </ul>
      </nav>
    </div>

    <!-- Main Content -->
    <div class="main-content">
      <!-- Top Header -->
      <header class="top-header">
        <div class="header-left">
          <button class="toggle-sidebar" @click="toggleSidebar">
            <i class="bi bi-list"></i>
          </button>
          <div class="logo">
            <h2><span class="primary-text">Health</span><span class="secondary-text">Right</span></h2>
          </div>
          <div class="search-container">
            <div class="search-box">
              <input type="text" placeholder="Tìm kiếm..." v-model="searchQuery" @keyup.enter="performSearch">
              <button @click="performSearch">
                <i class="bi bi-search"></i>
              </button>
            </div>
          </div>
        </div>
        <div class="header-right">
          <div class="header-actions">
            <div class="notifications" ref="notificationRef">
              <button class="notification-button" @click="toggleNotifications">
                <i class="bi bi-bell-fill"></i>
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
            <div class="quick-actions">
              <button class="quick-action-button">
                <i class="bi bi-calendar-plus"></i>
              </button>
            </div>
          </div>
          <div class="user-profile">
            <span class="user-name">{{ userName }}</span>
            <div class="avatar-wrapper">
              <img :src="userAvatar || '/default-avatar.png'" alt="Avatar" class="avatar">
              <div class="user-dropdown">
                <ul>
                  <li><router-link to="/user/profile"><i class="bi bi-person"></i> Hồ sơ</router-link></li>
                  <li><router-link to="/user/medical-record"><i class="bi bi-file-medical"></i> Hồ sơ y tế</router-link></li>
                  <li><router-link to="/user/settings"><i class="bi bi-gear"></i> Cài đặt</router-link></li>
                  <li><a @click="handleLogout"><i class="bi bi-box-arrow-right"></i> Đăng xuất</a></li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </header>

      <!-- Navigation Header -->
      <nav class="navigation-header">
        <ul>
          <li>
            <router-link to="/user/dashboard">
              <i class="bi bi-house-door"></i>
              <span>Trang chủ</span>
            </router-link>
          </li>
          <li>
            <router-link to="/user/consultation-history">
              <i class="bi bi-calendar-check"></i>
              <span>Lịch sử tư vấn</span>
            </router-link>
          </li>
          <li>
            <router-link to="/user/consultationlist">
              <i class="bi bi-list-check"></i>
              <span>Danh sách tư vấn</span>
            </router-link>
          </li>
          <li>
            <router-link to="/user/doctors">
              <i class="bi bi-heart-pulse"></i>
              <span>Bác sĩ</span>
            </router-link>
          </li>
          <li>
            <router-link to="/user/drugs">
              <i class="bi bi-capsule"></i>
              <span>Thuốc</span>
            </router-link>
          </li>
          <li>
            <router-link to="/user/news">
              <i class="bi bi-newspaper"></i>
              <span>Tin tức</span>
            </router-link>
          </li>
          <li>
            <router-link to="/user/feedback">
              <i class="bi bi-star"></i>
              <span>Đánh giá</span>
            </router-link>
          </li>
          <li>
            <router-link to="/user/contact">
              <i class="bi bi-envelope"></i>
              <span>Liên hệ</span>
            </router-link>
          </li>
          <li>
            <router-link to="/user/chat">
              <i class="bi bi-chat-dots"></i>
              <span>Chat</span>
            </router-link>
          </li>
        </ul>
      </nav>
      
      <main class="content">
        <router-view></router-view>
      </main>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue';
import { useRouter } from 'vue-router';
import axiosInstance from '@/services/axiosInstance.js';
import { format, parseISO } from 'date-fns';
import { vi } from 'date-fns/locale';

const router = useRouter();
const userName = ref('Người dùng');
const userAvatar = ref('');
const isSidebarCollapsed = ref(false);
const searchQuery = ref('');
const showNotifications = ref(false);
const unreadNotifications = ref(2);
const notificationRef = ref(null);
const notifications = ref([
  {
    type: 'appointment',
    message: 'Lịch hẹn khám với Bác sĩ Nguyễn Văn A vào ngày mai',
    time: new Date(Date.now() - 30 * 60 * 1000),
    read: false
  },
  {
    type: 'message',
    message: 'Bạn có tin nhắn mới từ Bác sĩ Trần Thị B',
    time: new Date(Date.now() - 3 * 60 * 60 * 1000),
    read: false
  },
  {
    type: 'system',
    message: 'Hệ thống đã cập nhật thông tin hồ sơ y tế của bạn',
    time: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
    read: true
  }
]);

const toggleSidebar = () => {
  isSidebarCollapsed.value = !isSidebarCollapsed.value;
};

const handleLogout = () => {
  localStorage.removeItem('token');
  localStorage.removeItem('role');
  router.push('/auth/login');
};

const performSearch = () => {
  if (!searchQuery.value.trim()) return;
  
  console.log('Tìm kiếm:', searchQuery.value);
  // Thực hiện tìm kiếm - có thể chuyển hướng đến trang kết quả tìm kiếm với query params
  // router.push({ path: '/user/search', query: { q: searchQuery.value } });
};

const toggleNotifications = () => {
  showNotifications.value = !showNotifications.value;
};

const markAllAsRead = () => {
  notifications.value.forEach(notification => {
    notification.read = true;
  });
  unreadNotifications.value = 0;
};

const getNotificationIcon = (type) => {
  const icons = {
    appointment: 'bi bi-calendar-check',
    message: 'bi bi-chat-dots',
    system: 'bi bi-info-circle',
    prescription: 'bi bi-clipboard2-pulse',
    reminder: 'bi bi-bell'
  };
  
  return icons[type] || 'bi bi-bell';
};

const formatTime = (time) => {
  try {
    const date = time instanceof Date ? time : parseISO(time);
    // Nếu là hôm nay, chỉ hiển thị giờ
    const now = new Date();
    if (date.toDateString() === now.toDateString()) {
      return format(date, 'HH:mm', { locale: vi });
    }
    return format(date, 'dd/MM/yyyy - HH:mm', { locale: vi });
  } catch (error) {
    return 'Không rõ thời gian';
  }
};

// Xử lý click bên ngoài dropdown thông báo
const handleClickOutside = (event) => {
  if (notificationRef.value && !notificationRef.value.contains(event.target)) {
    showNotifications.value = false;
  }
};

onMounted(async () => {
  try {
    const token = localStorage.getItem('token');
    if (token) {
      const response = await axiosInstance.get('/api/users/profile');
      if (response.data) {
        userName.value = response.data.fullName || response.data.email;
        userAvatar.value = response.data.avatar;
      }
    }
    
    // Thêm event listener cho click outside
    document.addEventListener('click', handleClickOutside);
    
  } catch (error) {
    console.error('Không thể tải thông tin người dùng:', error);
  }
});

onBeforeUnmount(() => {
  // Xóa event listener khi component bị hủy
  document.removeEventListener('click', handleClickOutside);
});
</script>

<style scoped>
.user-layout {
  display: flex;
  min-height: 100vh;
}

/* Sidebar styles */
.sidebar {
  width: 250px;
  background-color: #2c3e50;
  color: white;
  transition: all 0.3s ease;
  z-index: 1000;
}

.sidebar.collapsed {
  width: 0;
  overflow: hidden;
}

.sidebar-header {
  padding: 20px;
  text-align: center;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.sidebar-nav ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.nav-item {
  display: flex;
  align-items: center;
  padding: 15px 20px;
  color: white;
  text-decoration: none;
  transition: all 0.3s ease;
  white-space: nowrap;
  gap: 10px;
}

.nav-item:hover {
  background-color: rgba(255, 255, 255, 0.1);
}

.nav-item i {
  margin-right: 10px;
  width: 20px;
  text-align: center;
  font-size: 1.1rem;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.sidebar-nav .nav-item {
  display: flex;
  align-items: center;
  padding: 12px 20px;
  color: #bdc3c7;
  text-decoration: none;
  transition: all 0.3s;
  white-space: nowrap;
  gap: 10px;
}

/* Main content styles */
.main-content {
  flex: 1;
  background-color: #f5f6fa;
  display: flex;
  flex-direction: column;
}

/* Top header styles */
.top-header {
  background-color: white;
  padding: 15px 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  z-index: 900;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 15px;
  flex: 1;
}

.logo {
  display: flex;
  align-items: center;
}

.logo h2 {
  margin: 0;
  font-size: 22px;
  color: #2c3e50;
  display: flex;
}

.primary-text {
  color: #3498db;
  font-weight: 700;
}

.secondary-text {
  color: #2c3e50;
  font-weight: 600;
}

.search-container {
  flex: 1;
  max-width: 400px;
  margin-left: 20px;
}

.search-box {
  display: flex;
  align-items: center;
  background-color: #f5f6fa;
  border-radius: 20px;
  padding: 0 10px;
  height: 38px;
  box-shadow: inset 0 0 3px rgba(0,0,0,0.05);
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
  padding: 5px;
}

.search-box button:hover {
  color: #3498db;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 20px;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 15px;
}

.notifications {
  position: relative;
}

.notification-button {
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
  transition: all 0.3s;
}

.notification-button:hover {
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
  right: -50px;
  width: 320px;
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
  background-color: #ebf5fb;
}

.notification-icon {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background-color: #e8f4fc;
  color: #3498db;
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
  color: #3498db;
  text-decoration: none;
  font-size: 14px;
}

.quick-actions {
  display: flex;
  gap: 5px;
}

.quick-action-button {
  background: none;
  border: none;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: #7f8c8d;
  transition: all 0.3s;
}

.quick-action-button:hover {
  background-color: #f5f6fa;
  color: #3498db;
}

.toggle-sidebar {
  background: none;
  border: none;
  font-size: 1.2rem;
  cursor: pointer;
  color: #2c3e50;
  padding: 5px;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
}

.toggle-sidebar:hover {
  background-color: #f5f6fa;
}

/* User profile styles */
.user-profile {
  display: flex;
  align-items: center;
  gap: 10px;
  position: relative;
}

.user-name {
  font-weight: 500;
}

.avatar-wrapper {
  position: relative;
  cursor: pointer;
}

.avatar {
  width: 35px;
  height: 35px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid #fff;
  box-shadow: 0 2px 5px rgba(0,0,0,0.1);
}

.user-dropdown {
  position: absolute;
  top: 45px;
  right: 0;
  background: white;
  box-shadow: 0 2px 15px rgba(0,0,0,0.1);
  border-radius: 8px;
  width: 200px;
  z-index: 1000;
  display: none;
}

.avatar-wrapper:hover .user-dropdown {
  display: block;
}

.user-dropdown ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.user-dropdown li {
  padding: 0;
}

.user-dropdown a {
  padding: 12px 15px;
  display: flex;
  align-items: center;
  color: #333;
  text-decoration: none;
  transition: background 0.3s;
}

.user-dropdown a:hover {
  background: #f5f5f5;
}

.user-dropdown i {
  margin-right: 10px;
  width: 20px;
  text-align: center;
}

/* Navigation header styles */
.navigation-header {
  background-color: #fff;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
  padding: 0 20px;
  position: sticky;
  top: 0;
  z-index: 800;
  overflow-x: auto;
  white-space: nowrap;
}

.navigation-header ul {
  display: flex;
  list-style: none;
  padding: 0;
  margin: 0;
  min-width: max-content;
}

.navigation-header li {
  flex-shrink: 0;
}

.navigation-header a {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 15px 15px;
  color: #555;
  text-decoration: none;
  font-size: 13px;
  position: relative;
  transition: all 0.3s;
}

.navigation-header a i {
  font-size: 18px;
  margin-bottom: 5px;
}

.navigation-header a.router-link-active {
  color: #3498db;
}

.navigation-header a.router-link-active::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 50%;
  height: 3px;
  background-color: #3498db;
  border-radius: 3px 3px 0 0;
}

/* Content area styles */
.content {
  padding: 20px;
  flex: 1;
  overflow-y: auto;
}

/* Responsive styles */
@media (max-width: 1024px) {
  .sidebar {
    position: fixed;
    left: 0;
    top: 0;
    height: 100vh;
    transform: translateX(-100%);
    box-shadow: 2px 0 5px rgba(0,0,0,0.1);
  }
  
  .sidebar.collapsed {
    transform: translateX(0);
    width: 250px;
  }
  
  .logo {
    display: none;
  }
  
  .search-container {
    max-width: 100%;
  }
  
  .notification-dropdown {
    width: 300px;
    right: -100px;
  }
}

@media (max-width: 768px) {
  .top-header {
    padding: 10px 15px;
  }
  
  .navigation-header a span {
    font-size: 12px;
  }
  
  .navigation-header a {
    padding: 10px 15px;
  }
  
  .user-name {
    display: none;
  }
  
  .content {
    padding: 15px;
  }
  
  .search-container {
    display: none;
  }
  
  .notification-dropdown {
    width: 280px;
    right: -120px;
  }
}

@media (min-width: 1025px) {
  .navigation-header {
    display: none;
  }
}
</style> 