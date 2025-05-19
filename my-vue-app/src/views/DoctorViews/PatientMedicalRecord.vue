<template>
  <div class="patient-medical-record">
    <!-- Sidebar -->
    <div class="sidebar">
      <div class="sidebar-header">
        <img 
          :src="patient.avatar" 
          :alt="patient.fullname" 
          class="patient-avatar"
          @error="handleImageError"
        >
        <h2>{{ patient.fullname }}</h2>
        <p class="patient-id">ID: {{ patient._id }}</p>
      </div>
      
      <div class="sidebar-menu">
        <button 
          v-for="menu in menus" 
          :key="menu.id"
          :class="['menu-item', { active: currentMenu === menu.id }]"
          @click="currentMenu = menu.id"
        >
          <i :class="menu.icon"></i>
          <span>{{ menu.name }}</span>
        </button>
      </div>

      <!-- Thêm nút đánh giá tổng quan -->
      <button class="ai-evaluation-btn" @click="showChatbot = true">
        <i class="fas fa-robot"></i>
        Đánh giá tổng quan sức khỏe bằng AI
      </button>
    </div>

    <!-- Main Content -->
    <div class="main-content">
      <!-- Loading State -->
      <div v-if="loading" class="loading-container">
        <div class="loading-spinner"></div>
        <p>Đang tải dữ liệu...</p>
      </div>

      <!-- Error State -->
      <div v-else-if="error" class="error-container">
        <i class="fas fa-exclamation-circle"></i>
        <p>{{ error }}</p>
        <button @click="retryFetch" class="retry-btn">
          <i class="fas fa-redo"></i> Thử lại
        </button>
      </div>

      <!-- Content -->
      <div v-else>
        

        <!-- Thông tin người dùng -->
        <div v-if="currentMenu === 'user-info'" class="form-section">
          <div class="section-header">
            <h2><i class="fas fa-user"></i> Thông tin người dùng</h2>
          </div>
          <div class="form-grid">
            <div class="form-group">
              <label>Họ tên</label>
              <input type="text" v-model="patient.fullname" disabled>
            </div>
            <div class="form-group">
              <label>Email</label>
              <input type="email" v-model="patient.email" disabled>
            </div>
            <div class="form-group">
              <label>Số điện thoại</label>
              <input type="tel" v-model="patient.phone" disabled>
            </div>
            <div class="form-group">
              <label>Giới tính</label>
              <input type="text" :value="patient.gender === 'male' ? 'Nam' : 'Nữ'" disabled>
            </div>
            <div class="form-group">
              <label>Tuổi</label>
              <input type="number" v-model="patient.age" disabled>
            </div>
            <div class="form-group">
              <label>Địa chỉ</label>
              <input type="text" v-model="patient.address" disabled>
            </div>
          </div>
        </div>

        <!-- Triệu chứng -->
        <div v-if="currentMenu === 'symptoms'" class="form-section">
          <div class="section-header">
            <h2><i class="fas fa-thermometer-half"></i> Triệu chứng</h2>
            <div class="section-actions">
              <span class="total-count">{{ symptomsList.length }} triệu chứng</span>
            </div>
          </div>
          <div class="list-container">
            <div v-if="symptomsList && symptomsList.length > 0" class="symptoms-list">
              <div v-for="(item, index) in symptomsList" :key="index" class="symptom-item">
                <div class="symptom-header">
                  <h3>{{ item.symptoms }}</h3>
                  <span class="severity" :class="getSeverityClass(item.severity)">{{ item.severity }}</span>
                </div>
                <div class="symptom-details">
                  <div class="detail-item">
                    <i class="fas fa-clock"></i>
                    <span>Thời gian: {{ item.duration }}</span>
                  </div>
                  <div class="detail-item">
                    <i class="fas fa-calendar"></i>
                    <span>Ngày: {{ formatDate(item.date) }}</span>
                  </div>
                  <div class="detail-item" v-if="item.notes">
                    <i class="fas fa-sticky-note"></i>
                    <span>Ghi chú: {{ item.notes }}</span>
                  </div>
                </div>
              </div>
            </div>
            <div v-else class="no-data">
              <i class="fas fa-info-circle"></i>
              <p>Chưa có dữ liệu triệu chứng</p>
            </div>
          </div>
        </div>

        <!-- Đơn thuốc -->
        <div v-if="currentMenu === 'prescriptions'" class="form-section">
          <div class="section-header">
            <h2><i class="fas fa-prescription"></i> Đơn thuốc</h2>
            <div class="section-actions">
              <span class="total-count">{{ prescriptionsList.length }} đơn thuốc</span>
            </div>
          </div>
          <div class="list-container">
            <div v-if="prescriptionsList && prescriptionsList.length > 0" class="prescriptions-list">
              <div v-for="(item, index) in prescriptionsList" :key="index" class="prescription-item">
                <div class="prescription-header">
                  <h3>Đơn thuốc #{{ index + 1 }}</h3>
                  <span class="date">{{ new Date(item.createdAt).toLocaleDateString() }}</span>
                </div>
                <div class="prescription-details">
                  <div class="detail-item">
                    <i class="fas fa-diagnoses"></i>
                    <span>Chẩn đoán: {{ item.diagnosis }}</span>
                  </div>
                  <div class="medicines" v-if="item.medicines && item.medicines.length > 0">
                    <h4><i class="fas fa-pills"></i> Thuốc:</h4>
                    <div v-for="(medicine, medIndex) in item.medicines" :key="medIndex" class="medicine">
                      <div class="medicine-header">
                        <h5>{{ medicine.name }}</h5>
                        <span class="dosage">{{ medicine.dosage }}</span>
                      </div>
                      <div class="medicine-details">
                        <span><i class="fas fa-sync"></i> {{ medicine.frequency }}</span>
                        <span><i class="fas fa-clock"></i> {{ medicine.duration }}</span>
                      </div>
                      <p v-if="medicine.notes" class="medicine-notes">
                        <i class="fas fa-sticky-note"></i> {{ medicine.notes }}
                      </p>
                    </div>
                  </div>
                  <div v-if="item.notes" class="detail-item">
                    <i class="fas fa-sticky-note"></i>
                    <span>Ghi chú: {{ item.notes }}</span>
                  </div>
                </div>
              </div>
            </div>
            <div v-else class="no-data">
              <i class="fas fa-info-circle"></i>
              <p>Chưa có đơn thuốc</p>
            </div>
          </div>
        </div>

        <!-- Dị ứng -->
        <div v-if="currentMenu === 'allergies'" class="form-section">
          <div class="section-header">
            <h2><i class="fas fa-allergies"></i> Dị ứng</h2>
            <div class="section-actions">
              <span class="total-count">{{ allergiesList.length }} dị ứng</span>
            </div>
          </div>
          <div class="list-container">
            <div v-if="allergiesList && allergiesList.length > 0" class="allergies-list">
              <div v-for="(item, index) in allergiesList" :key="index" class="allergy-item">
                <div class="allergy-header">
                  <h3>{{ item.allergen }}</h3>
                  <div class="tags">
                    <span class="type">{{ item.type }}</span>
                    <span class="severity" :class="item.severity?.toLowerCase()">{{ item.severity }}</span>
                  </div>
                </div>
                <div class="allergy-details">
                  <div class="symptoms" v-if="item.symptoms && item.symptoms.length > 0">
                    <h4><i class="fas fa-exclamation-triangle"></i> Triệu chứng:</h4>
                    <div class="symptom-tags">
                      <span v-for="(symptom, sIndex) in item.symptoms" :key="sIndex">{{ symptom }}</span>
                    </div>
                  </div>
                  <div class="timeline">
                    <div class="timeline-item">
                      <i class="fas fa-calendar-plus"></i>
                      <span>Lần đầu: {{ new Date(item.firstOccurrence).toLocaleDateString() }}</span>
                    </div>
                    <div class="timeline-item">
                      <i class="fas fa-calendar-check"></i>
                      <span>Lần gần nhất: {{ new Date(item.lastOccurrence).toLocaleDateString() }}</span>
                    </div>
                  </div>
                  <div class="treatment">
                    <h4><i class="fas fa-medkit"></i> Điều trị:</h4>
                    <p>{{ item.treatment }}</p>
                  </div>
                  <div v-if="item.notes" class="notes">
                    <i class="fas fa-sticky-note"></i>
                    <span>{{ item.notes }}</span>
                  </div>
                </div>
              </div>
            </div>
            <div v-else class="no-data">
              <i class="fas fa-info-circle"></i>
              <p>Chưa có thông tin dị ứng</p>
            </div>
          </div>
        </div>

        <!-- Tiêm chủng -->
        <div v-if="currentMenu === 'vaccinations'" class="form-section">
          <div class="section-header">
            <h2><i class="fas fa-syringe"></i> Tiêm chủng</h2>
            <div class="section-actions">
              <span class="total-count">{{ vaccinationsList.length }} mũi tiêm</span>
            </div>
          </div>
          <div class="list-container">
            <div v-if="vaccinationsList && vaccinationsList.length > 0" class="vaccinations-list">
              <div v-for="(item, index) in vaccinationsList" :key="index" class="vaccination-item">
                <div class="vaccination-header">
                  <h3>{{ item.vaccineName }}</h3>
                  <span class="type">{{ item.vaccineType }}</span>
                </div>
                <div class="vaccination-details">
                  <div class="timeline">
                    <div class="timeline-item">
                      <i class="fas fa-calendar-check"></i>
                      <span>Ngày tiêm: {{ new Date(item.dateAdministered).toLocaleDateString() }}</span>
                    </div>
                    <div class="timeline-item">
                      <i class="fas fa-calendar-alt"></i>
                      <span>Ngày tiêm tiếp: {{ new Date(item.nextDoseDate).toLocaleDateString() }}</span>
                    </div>
                  </div>
                  <div class="vaccine-info">
                    <div class="info-item">
                      <i class="fas fa-barcode"></i>
                      <span>Số lô: {{ item.batchNumber }}</span>
                    </div>
                    <div class="info-item">
                      <i class="fas fa-industry"></i>
                      <span>Nhà sản xuất: {{ item.manufacturer }}</span>
                    </div>
                  </div>
                  <div v-if="item.sideEffects && item.sideEffects.length > 0" class="side-effects">
                    <h4><i class="fas fa-exclamation-triangle"></i> Tác dụng phụ:</h4>
                    <div v-for="(effect, eIndex) in item.sideEffects" :key="eIndex" class="side-effect">
                      <div class="effect-header">
                        <h5>{{ effect.description }}</h5>
                        <span class="severity" :class="effect.severity?.toLowerCase()">{{ effect.severity }}</span>
                      </div>
                      <div class="effect-details">
                        <span><i class="fas fa-clock"></i> {{ effect.duration }}</span>
                      </div>
                    </div>
                  </div>
                  <div v-if="item.notes" class="notes">
                    <i class="fas fa-sticky-note"></i>
                    <span>{{ item.notes }}</span>
                  </div>
                </div>
              </div>
            </div>
            <div v-else class="no-data">
              <i class="fas fa-info-circle"></i>
              <p>Chưa có thông tin tiêm chủng</p>
            </div>
          </div>
        </div>

        <!-- Điều trị -->
        <div v-if="currentMenu === 'treatments'" class="form-section">
          <div class="section-header">
            <h2><i class="fas fa-stethoscope"></i> Điều trị</h2>
            <div class="section-actions">
              <span class="total-count">{{ treatmentsList.length }} đợt điều trị</span>
            </div>
          </div>
          <div class="list-container">
            <div v-if="treatmentsList && treatmentsList.length > 0" class="treatments-list">
              <div v-for="(item, index) in treatmentsList" :key="index" class="treatment-item">
                <div class="treatment-header">
                  <h3>Điều trị #{{ index + 1 }}</h3>
                  <span class="status" :class="item.status?.toLowerCase()">{{ item.status }}</span>
                </div>
                <div class="treatment-details">
                  <div class="diagnosis">
                    <h4><i class="fas fa-diagnoses"></i> Chẩn đoán:</h4>
                    <p>{{ item.diagnosis }}</p>
                  </div>
                  <div class="treatment-plan">
                    <h4><i class="fas fa-clipboard-list"></i> Kế hoạch điều trị:</h4>
                    <p>{{ item.treatmentPlan }}</p>
                  </div>
                  <div class="timeline">
                    <div class="timeline-item">
                      <i class="fas fa-calendar-plus"></i>
                      <span>Bắt đầu: {{ new Date(item.startDate).toLocaleDateString() }}</span>
                    </div>
                    <div class="timeline-item">
                      <i class="fas fa-calendar-check"></i>
                      <span>Kết thúc: {{ new Date(item.endDate).toLocaleDateString() }}</span>
                    </div>
                  </div>
                  <div v-if="item.medications && item.medications.length > 0" class="medications">
                    <h4><i class="fas fa-pills"></i> Thuốc:</h4>
                    <div v-for="(medication, mIndex) in item.medications" :key="mIndex" class="medication">
                      <div class="medication-header">
                        <h5>{{ medication.name }}</h5>
                        <span class="dosage">{{ medication.dosage }}</span>
                      </div>
                      <div class="medication-details">
                        <span><i class="fas fa-sync"></i> {{ medication.frequency }}</span>
                        <span><i class="fas fa-clock"></i> {{ medication.duration }}</span>
                      </div>
                    </div>
                  </div>
                  <div v-if="item.procedures && item.procedures.length > 0" class="procedures">
                    <h4><i class="fas fa-procedures"></i> Thủ thuật:</h4>
                    <div v-for="(procedure, pIndex) in item.procedures" :key="pIndex" class="procedure">
                      <div class="procedure-header">
                        <h5>{{ procedure.name }}</h5>
                        <span class="date">{{ new Date(procedure.date).toLocaleDateString() }}</span>
                      </div>
                      <p v-if="procedure.notes" class="procedure-notes">
                        <i class="fas fa-sticky-note"></i> {{ procedure.notes }}
                      </p>
                    </div>
                  </div>
                  <div class="follow-up">
                    <h4><i class="fas fa-calendar-alt"></i> Tái khám:</h4>
                    <div class="follow-up-details">
                      <span>Ngày: {{ new Date(item.followUp.date).toLocaleDateString() }}</span>
                      <p v-if="item.followUp.notes">{{ item.followUp.notes }}</p>
                    </div>
                  </div>
                  <div v-if="item.notes" class="notes">
                    <i class="fas fa-sticky-note"></i>
                    <span>{{ item.notes }}</span>
                  </div>
                </div>
              </div>
            </div>
            <div v-else class="no-data">
              <i class="fas fa-info-circle"></i>
              <p>Chưa có thông tin điều trị</p>
            </div>
          </div>
        </div>

        <!-- Lối sống -->
        <div v-if="currentMenu === 'lifestyle'" class="form-section">
          <div class="section-header">
            <h2><i class="fas fa-heartbeat"></i> Lối sống</h2>
            <div class="section-actions">
              <span class="total-count">{{ lifestyleList.length }} hoạt động</span>
            </div>
          </div>
          <div class="list-container">
            <div v-if="lifestyleList && lifestyleList.length > 0" class="lifestyle-list">
              <div v-for="(item, index) in lifestyleList" :key="index" class="lifestyle-item">
                <div class="lifestyle-header">
                  <h3>{{ item.activityType }}</h3>
                  <span class="frequency">{{ item.frequency }}</span>
                </div>
                <div class="lifestyle-details">
                  <div class="description">
                    <h4><i class="fas fa-info-circle"></i> Mô tả:</h4>
                    <p>{{ item.description }}</p>
                  </div>
                  <div class="timeline">
                    <div class="timeline-item">
                      <i class="fas fa-calendar-plus"></i>
                      <span>Bắt đầu: {{ new Date(item.startDate).toLocaleDateString() }}</span>
                    </div>
                    <div class="timeline-item">
                      <i class="fas fa-clock"></i>
                      <span>Thời gian: {{ item.duration }}</span>
                    </div>
                  </div>
                  <div v-if="item.notes" class="notes">
                    <i class="fas fa-sticky-note"></i>
                    <span>{{ item.notes }}</span>
                  </div>
                </div>
              </div>
            </div>
            <div v-else class="no-data">
              <i class="fas fa-info-circle"></i>
              <p>Chưa có thông tin lối sống</p>
            </div>
          </div>
        </div>

        <!-- Dữ liệu sức khỏe -->
        <div v-if="currentMenu === 'health-data'" class="form-section">
          <div class="section-header">
            <h2><i class="fas fa-chart-line"></i> Dữ liệu sức khỏe</h2>
            <div class="section-actions">
              <span class="total-count">{{ healthDataList.length }} chỉ số</span>
            </div>
          </div>
          <div class="list-container">
            <div v-if="healthDataList && healthDataList.length > 0" class="health-data-list">
              <div v-for="(item, index) in healthDataList" :key="index" class="health-data-item">
                <div class="health-data-header">
                  <h3>{{ item.dataType }}</h3>
                  <span class="value">{{ item.value }} {{ item.unit }}</span>
                </div>
                <div class="health-data-details">
                  <div class="timeline">
                    <div class="timeline-item">
                      <i class="fas fa-calendar-check"></i>
                      <span>Thời gian: {{ new Date(item.measurementTime).toLocaleString() }}</span>
                    </div>
                    <div class="timeline-item">
                      <i class="fas fa-map-marker-alt"></i>
                      <span>Nơi đo: {{ item.measurementLocation }}</span>
                    </div>
                  </div>
                  <div v-if="item.notes" class="notes">
                    <i class="fas fa-sticky-note"></i>
                    <span>{{ item.notes }}</span>
                  </div>
                </div>
              </div>
            </div>
            <div v-else class="no-data">
              <i class="fas fa-info-circle"></i>
              <p>Chưa có dữ liệu sức khỏe</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Chatbot Modal -->
    <div v-if="showChatbot" class="chatbot-modal">
      <div class="chatbot-modal-content">
        <AIEvaluationView @close="showChatbot = false" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import axiosInstance from '@/services/axiosInstance'
import AIEvaluationView from '@/components/AIEvaluationView.vue'

const route = useRoute()
const patient = ref({})
const loading = ref(true)
const error = ref(null)

// Data refs
const symptomsList = ref([])
const prescriptionsList = ref([])
const allergiesList = ref([])
const vaccinationsList = ref([])
const treatmentsList = ref([])
const lifestyleList = ref([])
const healthDataList = ref([])

// Menus
const menus = [
  { id: 'user-info', name: 'Thông tin người dùng', icon: 'fas fa-user' },
  { id: 'symptoms', name: 'Triệu chứng', icon: 'fas fa-thermometer-half' },
  { id: 'prescriptions', name: 'Đơn thuốc', icon: 'fas fa-prescription' },
  { id: 'allergies', name: 'Dị ứng', icon: 'fas fa-allergies' },
  { id: 'vaccinations', name: 'Tiêm chủng', icon: 'fas fa-syringe' },
  { id: 'treatments', name: 'Điều trị', icon: 'fas fa-stethoscope' },
  { id: 'lifestyle', name: 'Lối sống', icon: 'fas fa-heartbeat' },
  { id: 'health-data', name: 'Dữ liệu sức khỏe', icon: 'fas fa-chart-line' }
]
const currentMenu = ref('user-info')

// Thêm state cho chatbot
const showChatbot = ref(false)

// Hàm xử lý
const handleImageError = (event) => {
  event.target.src = '/default-avatar.png'
}

// Hàm lấy dữ liệu
const fetchPatientData = async () => {
  try {
    loading.value = true
    const response = await axiosInstance.get(`/api/users/doctor/user/${route.params.id}`)
    patient.value = response.data
  } catch (err) {
    error.value = 'Không thể tải thông tin bệnh nhân'
    console.error('Error fetching patient data:', err)
  } finally {
    loading.value = false
  }
}

const fetchSymptoms = async () => {
  try {
    loading.value = true
    console.log('Fetching symptoms for patient:', route.params.id)
    const response = await axiosInstance.get(`/api/medical-record/symptoms/doctor/${route.params.id}`)
    console.log('Symptoms response:', response.data)
    symptomsList.value = response.data || []
  } catch (err) {
    console.error('Error fetching symptoms:', err)
  } finally {
    loading.value = false
  }
}

const fetchPrescriptions = async () => {
  try {
    loading.value = true
    const response = await axiosInstance.get(`/api/medical-record/prescriptions/doctor/${route.params.id}`)
    console.log('Prescriptions response:', response.data)
    prescriptionsList.value = response.data || []
  } catch (err) {
    console.error('Error fetching prescriptions:', err)
  } finally {
    loading.value = false
  }
}

const fetchAllergies = async () => {
  try {
    loading.value = true
    const response = await axiosInstance.get(`/api/medical-record/allergies/doctor/${route.params.id}`)
    console.log('Allergies response:', response.data)
    allergiesList.value = response.data || []
  } catch (err) {
    console.error('Error fetching allergies:', err)
  } finally {
    loading.value = false
  }
}

const fetchVaccinations = async () => {
  try {
    loading.value = true
    const response = await axiosInstance.get(`/api/medical-record/vaccinations/doctor/${route.params.id}`)
    console.log('Vaccinations response:', response.data)
    vaccinationsList.value = response.data || []
  } catch (err) {
    console.error('Error fetching vaccinations:', err)
  } finally {
    loading.value = false
  }
}

const fetchTreatments = async () => {
  try {
    loading.value = true
    const response = await axiosInstance.get(`/api/medical-record/treatments/doctor/${route.params.id}`)
    console.log('Treatments response:', response.data)
    treatmentsList.value = response.data || []
  } catch (err) {
    console.error('Error fetching treatments:', err)
  } finally {
    loading.value = false
  }
}

const fetchLifestyle = async () => {
  try {
    loading.value = true
    const response = await axiosInstance.get(`/api/medical-record/lifestyles/doctor/${route.params.id}`)
    console.log('Lifestyle response:', response.data)
    lifestyleList.value = response.data || []
  } catch (err) {
    console.error('Error fetching lifestyle:', err)
  } finally {
    loading.value = false
  }
}

const fetchHealthData = async () => {
  try {
    loading.value = true
    const response = await axiosInstance.get(`/api/medical-record/health-data/doctor/${route.params.id}`)
    console.log('Health data response:', response.data)
    healthDataList.value = response.data || []
  } catch (err) {
    console.error('Error fetching health data:', err)
  } finally {
    loading.value = false
  }
}

// Thêm hàm retryFetch
const retryFetch = () => {
  error.value = null
  switch (currentMenu.value) {
    case 'symptoms':
      fetchSymptoms()
      break
    case 'prescriptions':
      fetchPrescriptions()
      break
    case 'allergies':
      fetchAllergies()
      break
    case 'vaccinations':
      fetchVaccinations()
      break
    case 'treatments':
      fetchTreatments()
      break
    case 'lifestyle':
      fetchLifestyle()
      break
    case 'health-data':
      fetchHealthData()
      break
  }
}

// Watcher cho currentMenu
watch(currentMenu, (newMenu) => {
  switch (newMenu) {
    case 'symptoms':
      if (symptomsList.value.length === 0) fetchSymptoms()
      break
    case 'prescriptions':
      if (prescriptionsList.value.length === 0) fetchPrescriptions()
      break
    case 'allergies':
      if (allergiesList.value.length === 0) fetchAllergies()
      break
    case 'vaccinations':
      if (vaccinationsList.value.length === 0) fetchVaccinations()
      break
    case 'treatments':
      if (treatmentsList.value.length === 0) fetchTreatments()
      break
    case 'lifestyle':
      if (lifestyleList.value.length === 0) fetchLifestyle()
      break
    case 'health-data':
      if (healthDataList.value.length === 0) fetchHealthData()
      break
  }
})

// Lấy dữ liệu khi component được mount
onMounted(async () => {
  await fetchPatientData()
})

// Thêm các hàm xử lý
const getSeverityClass = (severity) => {
  switch (severity) {
    case 'Nhẹ':
      return 'low'
    case 'Trung bình':
      return 'medium'
    case 'Nặng':
      return 'high'
    default:
      return 'medium'
  }
}

const formatDate = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('vi-VN', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}
</script>

<style scoped>
.patient-medical-record {
  display: flex;
  min-height: 100vh;
  background: #f5f6fa;
}

.sidebar {
  width: 280px;
  background: #2c3e50;
  color: white;
  padding: 20px;
  position: fixed;
  height: 100vh;
  overflow-y: auto;
}

.sidebar-header {
  text-align: center;
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.patient-avatar {
  width: 120px;
  height: 120px;
  border-radius: 50%;
  object-fit: cover;
  margin-bottom: 15px;
  border: 3px solid #3498db;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
}

.patient-id {
  font-size: 14px;
  color: #95a5a6;
  margin-top: 5px;
}

.sidebar-menu {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.menu-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 15px;
  border: none;
  background: none;
  color: white;
  cursor: pointer;
  border-radius: 8px;
  transition: all 0.3s ease;
  font-size: 15px;
}

.menu-item:hover {
  background: rgba(255, 255, 255, 0.1);
  transform: translateX(5px);
}

.menu-item.active {
  background: #3498db;
  box-shadow: 0 2px 8px rgba(52, 152, 219, 0.3);
}

.menu-item i {
  width: 20px;
  text-align: center;
}

.main-content {
  flex: 1;
  margin-left: 280px;
  padding: 30px;
}

.loading-container,
.error-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 400px;
  gap: 20px;
}

.loading-spinner {
  width: 50px;
  height: 50px;
  border: 5px solid #f3f3f3;
  border-top: 5px solid #3498db;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.error-container {
  color: #e74c3c;
}

.error-container i {
  font-size: 48px;
}

.retry-btn {
  padding: 10px 20px;
  background: #3498db;
  color: white;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
}

.retry-btn:hover {
  background: #2980b9;
}

.form-section {
  background: white;
  border-radius: 15px;
  padding: 25px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  margin-bottom: 30px;
  transition: all 0.3s ease;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
  padding-bottom: 15px;
  border-bottom: 1px solid #eee;
}

.section-header h2 {
  margin: 0;
  color: #2c3e50;
  display: flex;
  align-items: center;
  gap: 10px;
}

.section-header h2 i {
  color: #3498db;
}

.total-count {
  background: #f8f9fa;
  padding: 5px 12px;
  border-radius: 20px;
  font-size: 14px;
  color: #7f8c8d;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-group label {
  color: #666;
  font-weight: 500;
  font-size: 14px;
}

.form-group input {
  padding: 10px 15px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 14px;
  transition: all 0.3s;
}

.form-group input:disabled {
  background: #f8f9fa;
  color: #666;
}

.list-container {
  margin-top: 20px;
}

.symptoms-list,
.prescriptions-list,
.allergies-list,
.vaccinations-list,
.treatments-list,
.lifestyle-list,
.health-data-list {
  display: grid;
  gap: 20px;
}

.symptom-item,
.prescription-item,
.allergy-item,
.vaccination-item,
.treatment-item,
.lifestyle-item,
.health-data-item {
  background: #f8f9fa;
  border-radius: 12px;
  padding: 20px;
  transition: all 0.3s ease;
  border: 1px solid #eee;
}

.symptom-item:hover,
.prescription-item:hover,
.allergy-item:hover,
.vaccination-item:hover,
.treatment-item:hover,
.lifestyle-item:hover,
.health-data-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.symptom-header,
.prescription-header,
.allergy-header,
.vaccination-header,
.treatment-header,
.lifestyle-header,
.health-data-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.symptom-header h3,
.prescription-header h3,
.allergy-header h3,
.vaccination-header h3,
.treatment-header h3,
.lifestyle-header h3,
.health-data-header h3 {
  margin: 0;
  color: #2c3e50;
  font-size: 18px;
}

.severity,
.type,
.status,
.frequency,
.value {
  padding: 5px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 500;
}

.severity.low { background: #2ecc71; color: white; }
.severity.medium { background: #f1c40f; color: white; }
.severity.high { background: #e74c3c; color: white; }

.type { background: #3498db; color: white; }
.status.active { background: #2ecc71; color: white; }
.status.completed { background: #3498db; color: white; }
.status.cancelled { background: #e74c3c; color: white; }

.detail-item {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 10px;
  color: #666;
}

.detail-item i {
  color: #3498db;
  width: 20px;
}

.timeline {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin: 15px 0;
}

.timeline-item {
  display: flex;
  align-items: center;
  gap: 10px;
  color: #666;
}

.timeline-item i {
  color: #3498db;
  width: 20px;
}

.medicines,
.side-effects,
.medications,
.procedures {
  margin: 15px 0;
}

.medicine,
.side-effect,
.medication,
.procedure {
  background: white;
  border-radius: 8px;
  padding: 15px;
  margin-bottom: 10px;
  border: 1px solid #eee;
}

.medicine-header,
.side-effect-header,
.medication-header,
.procedure-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.medicine-header h5,
.side-effect-header h5,
.medication-header h5,
.procedure-header h5 {
  margin: 0;
  color: #2c3e50;
}

.dosage {
  background: #f1c40f;
  color: white;
  padding: 3px 8px;
  border-radius: 15px;
  font-size: 12px;
}

.medicine-details,
.medication-details {
  display: flex;
  gap: 15px;
  color: #666;
  font-size: 14px;
}

.medicine-notes,
.procedure-notes {
  margin-top: 10px;
  padding-top: 10px;
  border-top: 1px solid #eee;
  color: #666;
  font-size: 14px;
}

.symptom-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 10px;
}

.symptom-tags span {
  background: #e0f2f1;
  color: #009688;
  padding: 5px 10px;
  border-radius: 15px;
  font-size: 12px;
}

.no-data {
  text-align: center;
  padding: 40px;
  color: #95a5a6;
}

.no-data i {
  font-size: 48px;
  margin-bottom: 15px;
}

.no-data p {
  margin: 0;
  font-size: 16px;
}

.debug-info {
  background: #f8f9fa;
  padding: 10px;
  margin-bottom: 20px;
  border-radius: 5px;
  font-size: 14px;
  color: #666;
}

@media (max-width: 768px) {
  .patient-medical-record {
    flex-direction: column;
  }

  .sidebar {
    width: 100%;
    position: relative;
    height: auto;
  }

  .main-content {
    margin-left: 0;
    padding: 20px;
  }

  .form-grid {
    grid-template-columns: 1fr;
  }

  .symptoms-list,
  .prescriptions-list,
  .allergies-list,
  .vaccinations-list,
  .treatments-list,
  .lifestyle-list,
  .health-data-list {
    grid-template-columns: 1fr;
  }
}

/* Thêm styles cho nút AI và modal */
.ai-evaluation-btn {
  width: calc(100% - 40px);
  margin: 20px;
  padding: 12px;
  background: #4CAF50;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  transition: all 0.3s ease;
}

.ai-evaluation-btn:hover {
  background: #45a049;
  transform: translateY(-2px);
}

.ai-evaluation-btn i {
  font-size: 1.1rem;
}

.chatbot-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.chatbot-modal-content {
  position: relative;
  z-index: 1001;
}
</style>
