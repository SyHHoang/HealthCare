<template>
  <div class="medical-record-container">
    <div class="row">
      <!-- Sidebar - Fixed ở bên trái -->
      <div class="col-md-3 sidebar-col">
        <div class="sidebar">
          <div class="card">
            <div class="card-header">
              <h5 class="card-title mb-0">Hồ sơ sức khỏe</h5>
            </div>
            <div class="card-body p-0">
              <ul class="list-group list-group-flush">
                <li v-for="item in menuItems" 
                    :key="item.id"
                    class="list-group-item"
                    :class="{ active: activeMenu === item.id }"
                    @click="activeMenu = item.id">
                  <i :class="item.icon" class="me-2"></i>
                  {{ item.title }}
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>

      <!-- Main Content -->
      <div class="col-md-9 offset-md-3 content-col">
        <div class="content-area">
          <!-- Symptoms Component -->
          <Symptoms v-if="activeMenu === 'symptoms'" />

          <!-- Prescriptions Component -->
          <Prescription v-if="activeMenu === 'prescriptions'" />
          
          <!-- Allergy Component -->
          <Allergy v-if="activeMenu === 'allergy'" />

          <!-- Vaccination Component -->
          <Vaccination v-if="activeMenu === 'vaccination'" />

          <!-- Treatments Component -->
          <Treatment v-if="activeMenu === 'treatments'" />

          <!-- Lifestyle Component -->
          <Lifestyle v-if="activeMenu === 'lifestyle'" />

          <!-- Health Data Component -->
          <HealthData v-if="activeMenu === 'healthData'" />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import Symptoms from './MedicalRecord/Symptoms.vue';
import Prescription from './MedicalRecord/Prescription.vue';
import Allergy from './MedicalRecord/Allergy.vue';
import Vaccination from './MedicalRecord/Vaccination.vue';
import Treatment from './MedicalRecord/Treatment.vue';
import Lifestyle from './MedicalRecord/Lifestyle.vue';
import HealthData from './MedicalRecord/HealthData.vue';
import { ref } from 'vue';
export default {
  name: 'MedicalRecord',
  components: {
    Symptoms,
    Prescription,
    Allergy,
    Vaccination,
    Treatment,
    Lifestyle,
    HealthData
  },
  setup() {
    const activeMenu = ref('symptoms');
    const menuItems = [
      { id: 'symptoms', title: 'Triệu chứng', icon: 'bi bi-thermometer-half' },
      { id: 'prescriptions', title: 'Đơn thuốc', icon: 'bi bi-prescription' },
      { id: 'allergy', title: 'Dị ứng', icon: 'bi bi-exclamation-triangle' },
      { id: 'vaccination', title: 'Tiêm chủng', icon: 'bi bi-arrow-through-heart' },
      { id: 'treatments', title: 'Điều trị', icon: 'bi bi-hospital' },
      { id: 'lifestyle', title: 'Lối sống', icon: 'bi bi-heart' },
      { id: 'healthData', title: 'Dữ liệu sức khỏe', icon: 'bi bi-graph-up' }
    ];

    return {
      activeMenu,
      menuItems
    };
  }
};
</script>

<style scoped>
.medical-record-container {
  position: relative;
  min-height: calc(100vh - 80px);
}

.sidebar-col {
  position: fixed;
  width: 25%;
  max-width: 300px;
  height: 100%;
  z-index: 100;
  padding-top: 20px;
}

.sidebar {
  position: sticky;
  top: 20px;
}

.content-col {
  margin-left: 25%;
  padding: 20px;
}

.content-area {
  background-color: #fff;
  border-radius: 10px;
  box-shadow: 0 0 15px rgba(0, 0, 0, 0.05);
  padding: 20px;
  min-height: 80vh;
}

.card {
  border: none;
  box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
  border-radius: 10px;
}

.card-header {
  background-color: #f8f9fa;
  border-bottom: 1px solid rgba(0, 0, 0, 0.1);
  border-radius: 10px 10px 0 0 !important;
  padding: 15px;
}

.list-group-item {
  cursor: pointer;
  transition: all 0.3s ease;
  padding: 12px 15px;
  display: flex;
  align-items: center;
}

.list-group-item:hover {
  background-color: #f8f9fa;
}

.list-group-item.active {
  background-color: #0d6efd;
  color: white;
  border-color: #0d6efd;
}

.list-group-item i {
  min-width: 24px;
  text-align: center;
  font-size: 1.1rem;
  margin-right: 10px;
}

@media (max-width: 768px) {
  .sidebar-col {
    position: relative;
    width: 100%;
    max-width: 100%;
    height: auto;
  }
  
  .content-col {
    margin-left: 0;
    width: 100%;
  }
}
</style>
