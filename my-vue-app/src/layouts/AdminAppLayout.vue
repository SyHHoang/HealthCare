<template>
  <div id="admin-app">
    <div class="sidebar" :class="{ 'collapsed': isSidebarCollapsed }">
      <div class="sidebar-header">
        <h2><span class="primary-text">Health</span><span class="secondary-text">Right</span></h2>
        <span class="admin-badge">Admin</span>
      </div>
      

      
      <nav class="sidebar-nav">
        <ul>
          <li>
            <router-link to="/admin" class="nav-item" >
              <i class="bi bi-speedometer2"></i>
              <span>Tổng quan</span>
            </router-link>
          </li>
          <li>
            <router-link to="/admin/users" class="nav-item">
              <i class="bi bi-people"></i>
              <span>Quản lý người dùng</span>
            </router-link>
          </li>
          <li>
            <router-link to="/admin/doctors" class="nav-item">
              <i class="bi bi-person-badge"></i>
              <span>Quản lý bác sĩ</span>
            </router-link>
          </li>
          <li>
            <router-link to="/admin/specialties" class="nav-item">
              <i class="bi bi-heart-pulse"></i>
              <span>Quản lý chuyên khoa</span>
            </router-link>
          </li>
          <li>
            <router-link to="/admin/feedbacks" class="nav-item">
              <i class="bi bi-star"></i>
              <span>Quản lý đánh giá</span>
            </router-link>
          </li>
          <li>
            <router-link to="/admin/contacts" class="nav-item">
              <i class="bi bi-envelope"></i>
              <span>Quản lý liên hệ</span>
            </router-link>
          </li>
          <li>
            <router-link to="/admin/news" class="nav-item">
              <i class="bi bi-newspaper"></i>
              <span>Quản lý bài viết</span>
            </router-link>
          </li>
          <li>
            <router-link to="/admin/order-types" class="nav-item">
              <i class="bi bi-cart"></i>
              <span>Quản lý loại đơn hàng</span>
            </router-link>
          </li>
          <li>
            <router-link to="/admin/doctor-verifications" class="nav-item">
              <i class="bi bi-patch-check"></i>
              <span>Quản lý xác thực bác sĩ</span>
            </router-link>
          </li>
          <li>
            <router-link to="/admin/transaction" class="nav-item">
              <i class="bi bi-credit-card"></i>
              <span>Quản lý giao dịch</span>
            </router-link>
          </li>
          <li>
            <button @click="logout" class="nav-item logout-item">
              <i class="bi bi-box-arrow-right"></i>
              <span>Đăng xuất</span>
            </button>
          </li>
        </ul>
      </nav>
    </div>
    
    <div class="main-content" :class="{ 'expanded': isSidebarCollapsed }">
      <header class="admin-header">
        <div class="header-left">
          <button class="toggle-sidebar" @click="toggleSidebar">
            <i class="bi bi-list"></i>
          </button>
          
          <div class="page-title">
            <h3>{{ pageTitle }}</h3>
            <nav class="breadcrumb">
              <ul>
                <li><router-link to="/admin/dashboard">Admin</router-link></li>
                <li v-if="currentBreadcrumb">{{ currentBreadcrumb }}</li>
              </ul>
            </nav>
          </div>
        </div>
        
        <div class="header-right">
          
          
          <div class="user-profile">
            <div class="user-info" @click="toggleUserMenu">
              <img :src="adminAvatar || '/default-admin-avatar.png'" alt="Admin Avatar" class="user-avatar">
              <i class="bi bi-chevron-down"></i>
            </div>
            <div class="user-dropdown" v-if="showUserMenu">
              <router-link to="/admin/profile" class="dropdown-item">
                <i class="bi bi-person-circle"></i> Hồ sơ cá nhân
              </router-link>
              <router-link to="/admin/settings" class="dropdown-item">
                <i class="bi bi-gear"></i> Cài đặt
              </router-link>
              <div class="dropdown-divider"></div>
              <button @click="logout" class="dropdown-item logout-btn">
                <i class="bi bi-box-arrow-right"></i> Đăng xuất
              </button>
            </div>
          </div>
        </div>
      </header>
      
      <main class="admin-app-content">
        <router-view />
      </main>
    </div>
    
    <Toast />
  </div>
</template>

<script>
import { ref, computed, onMounted, onBeforeUnmount, watch } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import Toast from 'primevue/toast';
import { format, parseISO } from 'date-fns';
import { vi } from 'date-fns/locale';

export default {
  name: 'AdminAppLayout',
  components: {
    Toast
  },
  setup() {
    const router = useRouter();
    const route = useRoute();
    const adminName = ref('Admin');
    const adminAvatar = ref(null);
    const searchQuery = ref('');
    const isSidebarCollapsed = ref(false);
    
    // Notifications
    const showNotifications = ref(false);
    const unreadNotifications = ref(4);
    const notifications = ref([
      {
        type: 'user',
        message: 'Người dùng mới đã đăng ký: Nguyễn Văn A',
        time: new Date(Date.now() - 30 * 60 * 1000),
        read: false
      },
      {
        type: 'doctor',
        message: 'Bác sĩ Trần Văn B đã gửi yêu cầu phê duyệt tài khoản',
        time: new Date(Date.now() - 2 * 60 * 60 * 1000),
        read: false
      },
      {
        type: 'alert',
        message: 'Cảnh báo: Đã có 5 báo cáo về bác sĩ Lê Thị C',
        time: new Date(Date.now() - 5 * 60 * 60 * 1000),
        read: false
      },
      {
        type: 'system',
        message: 'Hệ thống đã được cập nhật lên phiên bản mới',
        time: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000),
        read: false
      },
      {
        type: 'payment',
        message: 'Đã nhận thanh toán từ bệnh nhân Phạm Văn D',
        time: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
        read: true
      }
    ]);
    
    // User menu
    const showUserMenu = ref(false);
    
    // Page info
    const pageTitle = computed(() => {
      const routeMap = {
        '/admin/dashboard': 'Tổng quan',
        '/admin/users': 'Quản lý người dùng',
        '/admin/doctors': 'Quản lý bác sĩ',
        '/admin/appointments': 'Quản lý lịch hẹn',
        '/admin/specialties': 'Quản lý chuyên khoa',
        '/admin/drugs': 'Quản lý thuốc',
        '/admin/reports': 'Báo cáo & Thống kê',
        '/admin/settings': 'Cài đặt hệ thống',
        '/admin/profile': 'Hồ sơ cá nhân',
        '/admin/order-types': 'Quản lý loại đơn hàng'
      };
      
      return routeMap[route.path] || 'Quản trị hệ thống';
    });
    
    const currentBreadcrumb = computed(() => {
      const path = route.path;
      if (path === '/admin/dashboard') return null;
      return pageTitle.value;
    });
    
    // Methods
    const toggleSidebar = () => {
      isSidebarCollapsed.value = !isSidebarCollapsed.value;
    };
    
    const toggleNotifications = () => {
      showNotifications.value = !showNotifications.value;
      showUserMenu.value = false; // Đóng user menu nếu đang mở
    };
    
    const toggleUserMenu = () => {
      showUserMenu.value = !showUserMenu.value;
      showNotifications.value = false; // Đóng notifications nếu đang mở
    };
    
    const markAllAsRead = () => {
      notifications.value.forEach(notification => {
        notification.read = true;
      });
      unreadNotifications.value = 0;
    };
    
    const getNotificationIcon = (type) => {
      const icons = {
        user: 'bi bi-person-plus',
        doctor: 'bi bi-person-badge',
        alert: 'bi bi-exclamation-triangle',
        system: 'bi bi-server',
        payment: 'bi bi-cash-coin',
        message: 'bi bi-envelope'
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
    
    const performSearch = () => {
      if (!searchQuery.value.trim()) return;
      
      console.log('Tìm kiếm:', searchQuery.value);
      // Thực hiện tìm kiếm - có thể chuyển hướng đến trang kết quả tìm kiếm với query params
      router.push({ 
        path: '/admin/search', 
        query: { q: searchQuery.value } 
      });
      searchQuery.value = ''; // Clear search after submitting
    };
    
    const logout = () => {
      localStorage.removeItem('token');
      localStorage.removeItem('adminInfo');
      router.push('/auth/login');
    };
    
    // Xử lý click bên ngoài dropdown
    const handleClickOutside = (event) => {
      // Kiểm tra nếu click bên ngoài notification dropdown
      if (showNotifications.value) {
        const notificationElement = document.querySelector('.notifications');
        if (notificationElement && !notificationElement.contains(event.target)) {
          showNotifications.value = false;
        }
      }
      
      // Kiểm tra nếu click bên ngoài user dropdown
      if (showUserMenu.value) {
        const userElement = document.querySelector('.user-profile');
        if (userElement && !userElement.contains(event.target)) {
          showUserMenu.value = false;
        }
      }
    };
    
    onMounted(() => {
      // Thêm Font Awesome
      const link = document.createElement('link');
      link.rel = 'stylesheet';
      link.href = 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css';
      document.head.appendChild(link);
      
      // Lấy thông tin admin từ localStorage
      try {
        const adminInfo = JSON.parse(localStorage.getItem('adminInfo') || '{}');
        adminName.value = adminInfo.fullName || adminInfo.name || 'Admin';
        adminAvatar.value = adminInfo.avatar;
      } catch (error) {
        console.error('Lỗi khi đọc thông tin admin:', error);
      }
      
      // Thêm event listener cho click outside
      document.addEventListener('click', handleClickOutside);
    });
    
    onBeforeUnmount(() => {
      // Xóa event listener khi component bị hủy
      document.removeEventListener('click', handleClickOutside);
    });
    
    return {
      adminName,
      adminAvatar,
      searchQuery,
      isSidebarCollapsed,
      showNotifications,
      unreadNotifications,
      notifications,
      showUserMenu,
      pageTitle,
      currentBreadcrumb,
      toggleSidebar,
      toggleNotifications,
      toggleUserMenu,
      markAllAsRead,
      getNotificationIcon,
      formatTime,
      performSearch,
      logout
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

#admin-app {
  display: flex;
  min-height: 100vh;
  background-color: #f8f9fa;
  font-family: 'Roboto', sans-serif;
}

/* Sidebar Styles */
.sidebar {
  width: 250px;
  background-color: #2c3e50;
  color: #ecf0f1;
  display: flex;
  flex-direction: column;
  transition: all 0.3s ease;
  position: fixed;
  top: 0;
  left: 0;
  height: 100vh;
  z-index: 1000;
}

.sidebar.collapsed {
  width: 70px;
  overflow: hidden;
}

.sidebar-header {
  padding: 20px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.sidebar-header h2 {
  font-size: 20px;
  white-space: nowrap;
}

.primary-text {
  color: #3498db;
  font-weight: 700;
}

.secondary-text {
  color: white;
  font-weight: 600;
}

.admin-badge {
  background-color: #e74c3c;
  color: white;
  font-size: 10px;
  padding: 3px 6px;
  border-radius: 3px;
  font-weight: bold;
}

.sidebar-user {
  padding: 15px 20px;
  display: flex;
  align-items: center;
  gap: 10px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.sidebar-user .user-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid rgba(255, 255, 255, 0.5);
}

.sidebar-user .user-info {
  white-space: nowrap;
}

.sidebar-user h4 {
  font-size: 14px;
  margin: 0;
  color: white;
}

.sidebar-user span {
  font-size: 12px;
  color: #bdc3c7;
}

.sidebar-nav {
  flex: 1;
  overflow-y: auto;
  padding: 10px 0;
}

.sidebar-nav ul {
  list-style: none;
}

.sidebar-nav .nav-item {
  display: flex;
  align-items: center;
  padding: 12px 20px;
  color: #bdc3c7;
  text-decoration: none;
  transition: all 0.3s;
  white-space: nowrap;
}

.sidebar.collapsed .nav-item span {
  display: none;
}

.sidebar-nav .nav-item i {
  margin-right: 10px;
  font-size: 16px;
  width: 20px;
  text-align: center;
}

.sidebar-nav .nav-item:hover {
  background-color: rgba(255, 255, 255, 0.05);
  color: white;
}

.sidebar-nav .router-link-active {
  background-color: #3498db;
  color: white;
}

.logout-item {
  width: 100%;
  text-align: left;
  background: none;
  border: none;
  color: #bdc3c7;
  font-family: inherit;
  font-size: inherit;
  cursor: pointer;
  margin-top: 20px;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
}

.logout-item:hover {
  color: #e74c3c;
}

/* Main Content Styles */
.main-content {
  flex: 1;
  margin-left: 250px;
  transition: all 0.3s ease;
  width: calc(100% - 250px);
}

.main-content.expanded {
  margin-left: 70px;
  width: calc(100% - 70px);
}

/* Admin Header Styles */
.admin-header {
  background-color: white;
  padding: 15px 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  position: sticky;
  top: 0;
  z-index: 900;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 15px;
}

.toggle-sidebar {
  background: none;
  border: none;
  font-size: 18px;
  cursor: pointer;
  color: #7f8c8d;
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
  color: #3498db;
}

.page-title h3 {
  margin: 0;
  font-size: 18px;
  color: #2c3e50;
}

.breadcrumb {
  margin-top: 5px;
}

.breadcrumb ul {
  display: flex;
  list-style: none;
  font-size: 12px;
}

.breadcrumb li {
  color: #7f8c8d;
}

.breadcrumb li:not(:last-child)::after {
  content: '/';
  margin: 0 5px;
}

.breadcrumb a {
  color: #3498db;
  text-decoration: none;
}

.breadcrumb a:hover {
  text-decoration: underline;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 15px;
}

.search-container {
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
.admin-app-content {
  padding: 20px;
}

/* Responsive Styles */
@media (max-width: 1024px) {
  .search-container {
    max-width: 200px;
  }
}

@media (max-width: 768px) {
  .sidebar {
    width: 70px;
  }
  
  .sidebar.collapsed {
    width: 0;
    overflow: hidden;
  }
  
  .sidebar-header h2, 
  .sidebar-user .user-info,
  .sidebar-nav .nav-item span {
    display: none;
  }
  
  .main-content {
    margin-left: 70px;
    width: calc(100% - 70px);
  }
  
  .main-content.expanded {
    margin-left: 0;
    width: 100%;
  }
  
  .search-container {
    display: none;
  }
  
  .notification-dropdown {
    width: 300px;
    right: -150px;
  }
}

@media (max-width: 576px) {
  .page-title h3 {
    font-size: 16px;
  }
  
  .breadcrumb {
    display: none;
  }
  
  .admin-app-content {
    padding: 15px;
  }
  
  .notification-dropdown {
    width: 280px;
    right: -120px;
  }
}
</style> 