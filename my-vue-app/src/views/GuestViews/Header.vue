<template>
  <header>
    <div class="logo">MediConnect</div>
    <nav>
      <ul>
        <router-link to="/">Trang chủ</router-link> 
        <router-link to="/about">Giới thiệu</router-link>
        <router-link to="/news-events">Tin tức</router-link>
        <router-link to="/feedback">Đánh giá</router-link>
        <router-link to="/doctors&specialties">Chuyên khoa & Bác sĩ</router-link>
        <router-link to="/drugs">Tra cứu thuốc</router-link>
        <li class="nav-item">
          <router-link class="nav-link" to="/contact">Liên hệ</router-link>
        </li>
        <div class="auth-links">
          <template v-if="isLoggedIn">
            <div class="profile-dropdown">
              <router-link to="/profile" class="profile-link">
                <i class="fas fa-user"></i>
              </router-link>
              <div class="dropdown-menu">
                <router-link v-if="isUser||isAdmin"  to="/profile" class="dropdown-item">
                  <i class="fas fa-user-circle"></i> Thông tin cá nhân
                </router-link>
                <router-link v-if="isUser||isAdmin"  to="/consultationlist" class="dropdown-item">
                  <i class="fas fa-user-circle"></i> Danh sách bác sỹ tư vấn
                </router-link>
                <router-link v-if="isUser||isAdmin" to="/medical-record" class="dropdown-item">
                  <i class="fas fa-file-medical"></i> Hồ sơ bệnh án
                </router-link>
                <router-link v-if="isUser||isAdmin" to="/ChangePassword" class="dropdown-item">
                  <i class="fas fa-user-changepass"></i> Đổi mật khẩu
                </router-link>
                <router-link v-if="isUser||isAdmin" to="/consultation-history" class="dropdown-item">
                  <i class="fas fa-user-changepass"></i> Cuộc hẹn tư vấn
                </router-link>
                <router-link v-if="isUser||isAdmin" to="/chat" class="dropdown-item">
                  <i class="fas fa-comments"></i> Chat
                </router-link>
                <router-link v-if="isAdmin" to="/admin" class="dropdown-item">
                  <i class="fas fa-cog"></i> Quản trị
                </router-link>
                <router-link v-if="isDoctor" to="/doctor/dashboard" class="dropdown-item">
                  <i class="fas fa-cog"></i> Quản trị
                </router-link>
                <router-link v-if="isDoctor" to="/doctor/change-password" class="dropdown-item">
                  <i class="fas fa-cog"></i> Đổi mật khẩu
                </router-link>
                <router-link v-if="isDoctor" to="/doctor/profile" class="dropdown-item">
                  <i class="fas fa-cog"></i> Thông tin cá nhân
                </router-link>
                <div class="dropdown-divider"></div>
                <button @click="logout" class="dropdown-item text-danger">
                  <i class="fas fa-sign-out-alt"></i> Đăng xuất
                </button>
              </div>
            </div>
          </template>
          <template v-else>
            <router-link to="/auth/login" class="auth-btn login-btn">
              <i class="fas fa-sign-in-alt"></i>
              Đăng nhập
            </router-link>
            <router-link to="/auth/register" class="auth-btn register-btn">
              <i class="fas fa-user-plus"></i>
              Đăng ký
            </router-link>
          </template>
        </div>
      </ul>
    </nav>
  </header>
</template>

<script>
export default {
  name: 'AppHeader',
  data() {
    return {
      isLoggedIn: false,
      isAdmin: false,
      isDoctor: false,
      isUser: false
    }
  },
  mounted() {
    // Thêm Font Awesome
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css';
    document.head.appendChild(link);
    
    // Kiểm tra trạng thái đăng nhập
    this.checkLoginStatus();
  },
  methods: {
    checkLoginStatus() {
      const token = localStorage.getItem('token');
      const role = localStorage.getItem('role');
      this.isLoggedIn = !!token;
      this.isAdmin = role === 'admin';
      this.isDoctor = role === 'doctor';
      this.isUser = role === 'user';
    },
    async logout() {
      // Xóa token và role
      localStorage.removeItem('token');
      localStorage.removeItem('role');
      this.isLoggedIn = false;
      this.isAdmin = false;
      this.isDoctor = false;
      this.isUser = false;
      // Nếu đang không ở trang chủ thì chuyển về trang chủ
      if (this.$route.path !== '/') {
        await this.$router.push('/');
      }
    }
  },
  created() {
    // Lắng nghe sự kiện đăng nhập từ LoginView
    window.addEventListener('login-success', () => {
      this.checkLoginStatus();
    });
  }
};
</script>

<style scoped>
header {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 80px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 20px;
  background: white;
  border-bottom: 2px solid #f4f4f4;
  z-index: 1000;
}

.logo {
  font-size: 24px;
  font-weight: bold;
}

.logo span {
  color: gold;
}

nav ul {
  list-style: none;
  display: flex;
  gap: 20px;
  align-items: center;
  margin: 0;
  padding: 0;
}

nav ul a {
  text-decoration: none;
  color: black;
  font-weight: bold;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 5px;
}

nav ul a:hover {
  color: gold;
}

.auth-links {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-left: 15px;
  padding-left: 15px;
  border-left: 2px solid #f4f4f4;
}

.profile-link {
  font-size: 20px;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: #f4f4f4;
  transition: all 0.3s ease;
}

.profile-link:hover {
  background: gold;
  color: white;
}

.auth-btn {
  padding: 8px 15px;
  border-radius: 20px;
  font-size: 14px;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 5px;
  text-decoration: none;
}

.login-btn {
  background: transparent;
  border: 2px solid gold;
  color: #333;
}

.login-btn:hover {
  background: gold;
  color: white;
}

.register-btn {
  background: gold;
  border: 2px solid gold;
  color: white;
}

.register-btn:hover {
  background: transparent;
  color: #333;
}

.auth-btn i {
  color: inherit;
}

.logout-btn {
  padding: 8px 15px;
  border-radius: 20px;
  font-size: 14px;
  transition: all 0.3s ease;
  background: transparent;
  border: 2px solid #ff4444;
  color: #ff4444;
  display: flex;
  align-items: center;
  gap: 5px;
  cursor: pointer;
}

.logout-btn:hover {
  background: #ff4444;
  color: white;
}

.logout-btn i {
  color: inherit;
}

@media (max-width: 768px) {
  nav ul {
    gap: 10px;
  }
  
  .auth-links {
    margin-left: 10px;
    padding-left: 10px;
  }
  
  .login-btn, .logout-btn {
    padding: 6px 10px;
    font-size: 12px;
  }
}

.profile-dropdown {
  position: relative;
  display: inline-block;
}

.dropdown-menu {
  display: none;
  position: absolute;
  right: 0;
  top: 100%;
  background-color: white;
  min-width: 200px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  border-radius: 8px;
  padding: 8px 0;
  z-index: 1000;
}

.profile-dropdown:hover .dropdown-menu {
  display: block;
}

.dropdown-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 15px;
  color: #333;
  text-decoration: none;
  transition: all 0.3s ease;
}

.dropdown-item:hover {
  background-color: #f8f9fa;
}

.dropdown-item i {
  width: 20px;
  text-align: center;
}

.dropdown-divider {
  height: 1px;
  background-color: #eee;
  margin: 8px 0;
}

.text-danger {
  color: #ff4444;
  border: none;
  background: none;
  width: 100%;
  text-align: left;
  cursor: pointer;
}

.text-danger:hover {
  background-color: #ff4444;
  color: white;
}
</style>