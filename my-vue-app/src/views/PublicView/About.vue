<template>
  <div class="about-page">
    <div class="hero-section">
      <div class="container">
        <h1 class="text-center">Về Chúng Tôi</h1>
        <p class="lead text-center">Hệ thống tư vấn y tế thông minh - Chăm sóc sức khỏe toàn diện</p>
      </div>
    </div>

    <div class="container py-5">
      <div class="row mb-5">
        <div class="col-md-6">
          <h2 class="section-title">Tầm Nhìn</h2>
          <p>Trở thành hệ thống tư vấn y tế thông minh hàng đầu, mang đến giải pháp chăm sóc sức khỏe toàn diện và tiện lợi cho mọi người dân Việt Nam.</p>
          
          <h2 class="section-title mt-4">Sứ Mệnh</h2>
          <p>Ứng dụng công nghệ hiện đại vào lĩnh vực y tế, giúp người dân dễ dàng tiếp cận với dịch vụ chăm sóc sức khỏe chất lượng cao, đồng thời hỗ trợ đội ngũ y bác sĩ trong công tác khám chữa bệnh.</p>
        </div>
        <div class="col-md-6">
          <div class="about-image">
            <img  alt="Đội ngũ y tế" class="img-fluid rounded shadow">
          </div>
        </div>
      </div>

      <div class="row mb-5">
        <div class="col-12">
          <h2 class="section-title text-center mb-4">Giá Trị Cốt Lõi</h2>
          <div class="row g-4">
            <div class="col-md-4">
              <div class="value-card">
                <div class="icon">
                  <i class="fas fa-heart"></i>
                </div>
                <h3>Tận Tâm</h3>
                <p>Luôn đặt sức khỏe và sự an toàn của người bệnh lên hàng đầu</p>
              </div>
            </div>
            <div class="col-md-4">
              <div class="value-card">
                <div class="icon">
                  <i class="fas fa-shield-alt"></i>
                </div>
                <h3>Chuyên Nghiệp</h3>
                <p>Đội ngũ y bác sĩ giàu kinh nghiệm, được đào tạo bài bản</p>
              </div>
            </div>
            <div class="col-md-4">
              <div class="value-card">
                <div class="icon">
                  <i class="fas fa-sync-alt"></i>
                </div>
                <h3>Đổi Mới</h3>
                <p>Không ngừng cập nhật công nghệ và phương pháp điều trị tiên tiến</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="row mb-5">
        <div class="col-12">
          <h2 class="section-title text-center mb-4">Dịch Vụ Của Chúng Tôi</h2>
          <div class="row g-4">
            <div class="col-md-6 col-lg-3">
              <div class="service-card">
                <div class="icon">
                  <i class="fas fa-robot"></i>
                </div>
                <h4>Tư Vấn AI</h4>
                <p>Hệ thống trí tuệ nhân tạo hỗ trợ chẩn đoán sơ bộ 24/7</p>
              </div>
            </div>
            
            <div class="col-md-6 col-lg-3">
              <div class="service-card">
                <div class="icon">
                  <i class="fas fa-user-md"></i>
                </div>
                <h4>Tư Vấn Trực Tuyến</h4>
                <p>Kết nối trực tiếp với bác sĩ chuyên khoa qua video call</p>
              </div>
            </div>
            <div class="col-md-6 col-lg-3">
              <div class="service-card">
                <div class="icon">
                  <i class="fas fa-file-medical"></i>
                </div>
                <h4>Hồ Sơ Điện Tử</h4>
                <p>Quản lý hồ sơ bệnh án và đơn thuốc trực tuyến</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="row">
        <div class="col-12">
          <h2 class="section-title text-center mb-4">Đội Ngũ Chuyên Gia</h2>
          <div class="row g-4">
            <div v-if="loading" class="col-12 text-center">
              <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">Loading...</span>
              </div>
            </div>
            <div v-else-if="error" class="col-12 text-center">
              <div class="alert alert-danger">{{ error }}</div>
            </div>
            <div v-else class="col-md-4" v-for="doctor in doctors" :key="doctor._id">
              <div class="expert-card">
                <div class="expert-image-container">
                  <img :src="doctor.avatar" :alt="doctor.fullname" class="expert-image">
                  <div class="expert-overlay">
                    <div class="expert-social">
                      <a href="#" class="social-icon"><i class="fab fa-facebook"></i></a>
                      <a href="#" class="social-icon"><i class="fab fa-twitter"></i></a>
                      <a href="#" class="social-icon"><i class="fab fa-linkedin"></i></a>
                    </div>
                  </div>
                </div>
                <div class="expert-info">
                  <h3>{{ doctor.fullname }}</h3>
                  <p class="position">{{ doctor.position }}</p>
                  <p class="specialty">{{ doctor.specialty }}</p>
                  <p class="experience">Kinh nghiệm: {{ doctor.experience }} năm</p>
                  <p class="workplace">{{ doctor.workplace }}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <Footer />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axiosInstance from '@/services/axiosInstance.js';
import Footer from '@/views/GuestViews/Footer.vue';

const doctors = ref([]);
const loading = ref(true);
const error = ref(null);

const fetchDoctors = async () => {
  try {
    loading.value = true;
    error.value = null;
    const response = await axiosInstance.get('/api/doctors/public?limit=3');
    console.log('Doctors response:', response.data);
    
    if (response.data && response.data.success && response.data.doctors) {
      doctors.value = response.data.doctors;
    } else {
      throw new Error('Không có dữ liệu bác sĩ');
    }
  } catch (err) {
    console.error('Error fetching doctors:', err);
    error.value = err.response?.data?.message || 'Không thể tải thông tin bác sĩ. Vui lòng thử lại sau.';
    // Hiển thị bác sĩ mẫu nếu API lỗi
    doctors.value = [
      {
        _id: '1',
        fullname: 'TS.BS Nguyễn Văn A',
        position: 'Tiến sĩ Y khoa',
        specialty: 'Chuyên khoa Nội tổng quát',
        experience: 15,
        workplace: 'Bệnh viện Đại học Y Hà Nội',
        avatar: '/images/default-doctor.jpg'
      },
      {
        _id: '2',
        fullname: 'PGS.TS Trần Thị B',
        position: 'Phó Giáo sư, Tiến sĩ',
        specialty: 'Chuyên khoa Tim mạch',
        experience: 20,
        workplace: 'Bệnh viện Bạch Mai',
        avatar: '/images/default-doctor.jpg'
      },
      {
        _id: '3',
        fullname: 'BS.CKI Lê Văn C',
        position: 'Bác sĩ Chuyên khoa I',
        specialty: 'Chuyên khoa Nhi',
        experience: 10,
        workplace: 'Bệnh viện Nhi Trung ương',
        avatar: '/images/default-doctor.jpg'
      }
    ];
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  fetchDoctors();
});
</script>

<style scoped>
.about-page {
  margin-top: 80px;
  background-color: #f8f9fa;
}

.hero-section {
  background: linear-gradient(rgba(52, 152, 219, 0.9), rgba(52, 152, 219, 0.9)), url('/images/medical-bg.jpg');
  background-size: cover;
  background-position: center;
  color: white;
  padding: 100px 0;
  margin-bottom: 50px;
  position: relative;
  overflow: hidden;
}

.hero-section::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: url('/images/pattern.png');
  opacity: 0.1;
}

.hero-section h1 {
  font-size: 2.8rem;
  font-weight: 700;
  margin-bottom: 20px;
  text-shadow: 2px 2px 4px rgba(0,0,0,0.2);
}

.hero-section .lead {
  font-size: 1.3rem;
  font-weight: 300;
  text-shadow: 1px 1px 2px rgba(0,0,0,0.2);
}

.section-title {
  color: #2c3e50;
  font-weight: 600;
  margin-bottom: 1.5rem;
  position: relative;
  display: inline-block;
  font-size: 1.8rem;
}

.section-title::after {
  content: '';
  position: absolute;
  bottom: -10px;
  left: 50%;
  transform: translateX(-50%);
  width: 50px;
  height: 3px;
  background: #3498db;
}

.value-card, .service-card {
  background: white;
  padding: 2rem;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0,0,0,0.1);
  text-align: center;
  height: 100%;
  transition: all 0.3s ease;
  border: 1px solid rgba(0,0,0,0.1);
}

.value-card:hover, .service-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 15px rgba(0,0,0,0.1);
}

.value-card .icon, .service-card .icon {
  font-size: 2.5rem;
  color: #3498db;
  margin-bottom: 1rem;
  transition: transform 0.3s ease;
}

.value-card:hover .icon, .service-card:hover .icon {
  transform: scale(1.1);
}

.expert-card {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 6px rgba(0,0,0,0.1);
  transition: all 0.3s ease;
  border: 1px solid rgba(0,0,0,0.1);
}

.expert-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 15px rgba(0,0,0,0.1);
}

.expert-image-container {
  position: relative;
  overflow: hidden;
}

.expert-image {
  width: 100%;
  height: 300px;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.expert-card:hover .expert-image {
  transform: scale(1.05);
}

.expert-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0,0,0,0.5);
  opacity: 0;
  transition: opacity 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.expert-card:hover .expert-overlay {
  opacity: 1;
}

.expert-social {
  display: flex;
  gap: 15px;
}

.social-icon {
  color: white;
  font-size: 1.5rem;
  transition: transform 0.3s ease;
}

.social-icon:hover {
  transform: scale(1.2);
  color: #3498db;
}

.expert-info {
  padding: 1.5rem;
  text-align: center;
}

.expert-info h3 {
  color: #2c3e50;
  font-size: 1.2rem;
  margin-bottom: 0.5rem;
  font-weight: 600;
}

.expert-info .position {
  color: #3498db;
  font-weight: 600;
  margin-bottom: 0.5rem;
}

.expert-info .specialty {
  color: #666;
  font-size: 0.9rem;
  margin-bottom: 0.5rem;
}

.expert-info .experience {
  color: #666;
  font-size: 0.9rem;
  margin-bottom: 0.5rem;
}

.expert-info .workplace {
  color: #666;
  font-size: 0.9rem;
  margin-bottom: 0;
}

@media (max-width: 768px) {
  .hero-section {
    padding: 60px 0;
  }

  .hero-section h1 {
    font-size: 2.2rem;
  }

  .hero-section .lead {
    font-size: 1.1rem;
  }

  .section-title {
    font-size: 1.5rem;
  }

  .value-card h3, .service-card h3 {
    font-size: 1.2rem;
  }

  .expert-image {
    height: 250px;
  }
}
</style> 