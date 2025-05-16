<template>
  <header class="user-header">
    <div class="header-left">
      <div class="logo">
        <h2>
          <span class="primary-text">Medi</span><span class="secondary-text">Connect</span>
        </h2>
      </div>
      <div class="search-container">
        <div class="search-box">
          <input type="text" placeholder="Tìm kiếm...">
          <button>
            <i class="bi bi-search"></i>
          </button>
        </div>
      </div>
    </div>
    
    <div class="header-right">
      <div class="header-actions">
        <nav class="quick-nav">
          <router-link to="/user/news" class="nav-link">
            <i class="bi bi-newspaper"></i>
            <span>Tin tức</span>
          </router-link>
          <router-link to="/user/drugs" class="nav-link">
            <i class="bi bi-capsule"></i>
            <span>Thuốc</span>
          </router-link>
          <router-link to="/user/feedback" class="nav-link">
            <i class="bi bi-star"></i>
            <span>Đánh giá</span>
          </router-link>
          <router-link to="/user/contact" class="nav-link">
            <i class="bi bi-envelope"></i>
            <span>Liên hệ</span>
          </router-link>
        </nav>
        
        <div class="notifications">
          <button class="notification-btn">
            <i class="bi bi-bell"></i>
            <span class="notification-badge">3</span>
          </button>
        </div>
        
        <div class="user-profile">
          <div class="user-info">
            <img src="https://via.placeholder.com/40" alt="User Avatar" class="avatar">
            <span class="user-name">{{ userName }}</span>
          </div>
          <div class="user-dropdown">
            <router-link to="/profile">
              <i class="bi bi-person"></i> Hồ sơ
            </router-link>
            <router-link to="/settings">
              <i class="bi bi-gear"></i> Cài đặt
            </router-link>
            <div class="dropdown-divider"></div>
            <button @click="logout" class="logout-btn">
              <i class="bi bi-box-arrow-right"></i> Đăng xuất
            </button>
          </div>
        </div>
      </div>
    </div>
  </header>
</template>

<script>
export default {
  name: 'UserHeader',
  data() {
    return {
      userName: 'Người dùng'
    }
  },
  created() {
    // Lấy thông tin người dùng từ localStorage
    const userInfo = JSON.parse(localStorage.getItem('userInfo') || '{}');
    this.userName = userInfo.name || 'Người dùng';
  },
  methods: {
    logout() {
      localStorage.removeItem('token');
      localStorage.removeItem('userInfo');
      this.$router.push('/auth/login');
    }
  }
}
</script>

<style scoped>
.user-header {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 80px;
  background: white;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 20px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  z-index: 1000;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 20px;
}

.logo h2 {
  margin: 0;
  font-size: 24px;
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
  width: 400px;
}

.search-box {
  display: flex;
  align-items: center;
  background: #f5f6fa;
  border-radius: 20px;
  padding: 8px 15px;
}

.search-box input {
  flex: 1;
  border: none;
  background: none;
  outline: none;
  font-size: 14px;
}

.search-box button {
  background: none;
  border: none;
  color: #95a5a6;
  cursor: pointer;
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

/* Quick Navigation */
.quick-nav {
  display: flex;
  gap: 15px;
}

.nav-link {
  display: flex;
  flex-direction: column;
  align-items: center;
  color: #555;
  text-decoration: none;
  font-size: 12px;
  transition: all 0.3s;
}

.nav-link i {
  font-size: 16px;
  margin-bottom: 3px;
}

.nav-link:hover {
  color: #3498db;
}

.notification-btn {
  background: none;
  border: none;
  font-size: 18px;
  color: #2c3e50;
  cursor: pointer;
  position: relative;
}

.notification-badge {
  position: absolute;
  top: -5px;
  right: -5px;
  background: #e74c3c;
  color: white;
  font-size: 12px;
  padding: 2px 6px;
  border-radius: 10px;
}

.user-profile {
  position: relative;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
}

.avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
}

.user-name {
  font-weight: 600;
  color: #2c3e50;
}

.user-dropdown {
  display: none;
  position: absolute;
  top: 100%;
  right: 0;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  min-width: 200px;
  margin-top: 10px;
}

.user-profile:hover .user-dropdown {
  display: block;
}

.user-dropdown a {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px 15px;
  color: #2c3e50;
  text-decoration: none;
  transition: all 0.3s;
}

.user-dropdown a:hover {
  background: #f5f6fa;
}

.dropdown-divider {
  height: 1px;
  background: #eee;
  margin: 5px 0;
}

.logout-btn {
  width: 100%;
  text-align: left;
  background: none;
  border: none;
  padding: 12px 15px;
  color: #e74c3c;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 10px;
  transition: all 0.3s;
}

.logout-btn:hover {
  background: #f5f6fa;
}

@media (max-width: 1024px) {
  .quick-nav {
    display: none;
  }
}

@media (max-width: 768px) {
  .search-container {
    display: none;
  }
  
  .user-name {
    display: none;
  }
  
  .user-dropdown {
    right: -50px;
  }
}
</style> 