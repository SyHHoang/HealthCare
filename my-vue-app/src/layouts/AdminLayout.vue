<template>
    <div class="admin-layout">
      <!-- Sidebar -->
      <div class="sidebar">
        <div class="sidebar-header">
          <h3>HealthRight Admin</h3>
        </div>
        <nav class="sidebar-nav">
          <ul>
            <li>
              <router-link to="/admin/dashboard" class="nav-item">
                <i class="fas fa-tachometer-alt"></i>
                <span>Tổng quan</span>
              </router-link>
            </li>
            <li>
              <router-link to="/admin/transaction" class="nav-item">
                <i class="fas fa-file-alt"></i>
                <span>Quản lý giao dịch</span>
              </router-link>
            </li>
            <li>
              <router-link to="/admin/users" class="nav-item">
                <i class="bi-person-fill"></i>
                <span>Quản lý người dùng</span>
              </router-link>
            </li>
            <li>
              <router-link to="/admin/doctors" class="nav-item">
                <i class="fas fa-user-md"></i>
                <span>Quản lý bác sĩ</span>
              </router-link>
            </li>
            <li>
              <router-link to="/admin/drugs" class="nav-item">
                <i class="fas fa-pills"></i>
                <span>Quản lý thuốc</span>
              </router-link>
            </li>
            <li>
              <router-link to="/admin/news" class="nav-item">
                <i class="fas fa-newspaper"></i>
                <span>Quản lý bài viết</span>
              </router-link>
            </li>
            <li>
              <router-link to="/admin/feedbacks" class="nav-item">
                <i class="fas fa-comments"></i>
                <span>Quản lý phản hồi</span>
              </router-link>
            </li>
            <li>
              <router-link to="/admin/contacts" class="nav-item">
                <i class="fas fa-envelope"></i>
                <span>Quản lý liên hệ</span>
              </router-link>
              <router-link to="/admin/specialties" class="nav-item">
                <i class="fas fa-user-md"></i>
                <span>Quản lý chuyên khoa</span>
              </router-link>
              <router-link to="/admin/doctor-verifications" class="nav-item">
                <i class="fas fa-user-check"></i>
                <span>Quản lý xác thực bác sĩ</span>
              </router-link>
            </li>
          </ul>
        </nav>
      </div>
  
      <!-- Main Content -->
      <div class="main-content">
        <header class="top-header">
          <div class="header-left">
            <button class="toggle-sidebar" @click="toggleSidebar">
              <i class="fas fa-bars"></i>
            </button>
          </div>
          <div class="header-right">
            <div class="admin-profile">
              <img src="https://via.placeholder.com/40" alt="Admin" class="avatar">
              <span class="admin-name">Admin</span>
              <button class="logout-btn" @click="handleLogout">
                <i class="fas fa-sign-out-alt"></i>
              </button>
            </div>
          </div>
        </header>
        
        <main class="content">
          <router-view></router-view>
        </main>
      </div>
    </div>
  </template>
  
  <script>
  export default {
    name: 'AdminLayout',
    methods: {
      toggleSidebar() {
        document.querySelector('.sidebar').classList.toggle('collapsed');
      },
      handleLogout() {
        localStorage.removeItem('token');
        this.$router.push('/auth/login');
      }
    }
  }
  </script>
  
  <style scoped>
  .admin-layout {
    display: flex;
    min-height: 100vh;
  }
  
  .sidebar {
    width: 250px;
    background-color: #2c3e50;
    color: white;
    transition: all 0.3s ease;
  }
  
  .sidebar.collapsed {
    width: 70px;
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
  }
  
  .nav-item:hover {
    background-color: rgba(255, 255, 255, 0.1);
  }
  
  .nav-item i {
    margin-right: 10px;
    width: 20px;
    text-align: center;
  }
  
  .main-content {
    flex: 1;
    background-color: #f5f6fa;
  }
  
  .top-header {
    background-color: white;
    padding: 15px 20px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  }
  
  .toggle-sidebar {
    background: none;
    border: none;
    font-size: 1.2rem;
    cursor: pointer;
    color: #2c3e50;
  }
  
  .admin-profile {
    display: flex;
    align-items: center;
    gap: 10px;
  }
  
  .avatar {
    width: 35px;
    height: 35px;
    border-radius: 50%;
    object-fit: cover;
  }
  
  .logout-btn {
    background: none;
    border: none;
    color: #2c3e50;
    cursor: pointer;
  }
  
  .content {
    padding: 20px;
  }
  
  /* Responsive */
  @media (max-width: 768px) {
    .sidebar {
      position: fixed;
      left: -250px;
      height: 100vh;
      z-index: 1000;
    }
  
    .sidebar.collapsed {
      left: 0;
      width: 250px;
    }
  }
  </style>