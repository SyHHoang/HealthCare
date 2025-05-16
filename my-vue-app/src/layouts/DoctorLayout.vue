<template>
  <div class="doctor-layout">
    <!-- Sidebar -->
    <div class="sidebar">
      <div class="sidebar-header">
        <h3>HealthRight Doctor</h3>
      </div>
      <nav class="sidebar-nav">
        <ul>
          <li>
            <router-link to="/doctor/dashboard" class="nav-item">
              <i class="fas fa-tachometer-alt"></i>
              <span>Tổng quan</span>
            </router-link>
          </li>
          <li>
            <router-link to="/doctor/consultation-history" class="nav-item">
              <i class="fas fa-calendar-check"></i>
              <span>Quản lý lịch hẹn</span>
            </router-link>
          </li>
          <li>
            <router-link to="/doctor/patients" class="nav-item">
              <i class="fas fa-users"></i>
              <span>Quản lý bệnh nhân</span>
            </router-link>
          </li>
          <li>
            <router-link to="/doctor/prescriptions" class="nav-item">
              <i class="fas fa-prescription-bottle-alt"></i>
              <span>Quản lý đơn thuốc</span>
            </router-link>
          </li>
          <li>
            <router-link to="/doctor/schedule" class="nav-item">
              <i class="fas fa-calendar-alt"></i>
              <span>Lịch làm việc</span>
            </router-link>
          </li>
          <li>
            <router-link to="/doctor/chat" class="nav-item">
              <i class="fas fa-comments"></i>
              <span>Chat</span>
            </router-link>
          </li>
        </ul>
      </nav>
    </div>

    <!-- Main Content -->
    <div class="main-content">
      
      <main class="content">
        <router-view></router-view>
      </main>
    </div>
  </div>
</template>

<script>
export default {
  name: 'DoctorLayout',
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
.doctor-layout {
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

.doctor-profile {
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