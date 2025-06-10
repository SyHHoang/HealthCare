<template>
  <div class="ai-evaluation">
    <div class="evaluation-header">
      <h2><i class="bi bi-robot"></i> Đánh giá sức khỏe bằng AI</h2>
      <button class="close-btn" @click="$emit('close')">
        <i class="bi bi-x-lg"></i>
      </button>
    </div>

    <div v-if="loading" class="loading">
      <div class="spinner"></div>
      <p>Đang phân tích dữ liệu sức khỏe...</p>
    </div>

    <div v-else class="evaluation-content">
      <!-- Phần đánh giá các mục sức khỏe -->
      <div class="evaluation-section">
        <h3><i class="bi bi-clipboard-check"></i> Đánh giá chi tiết</h3>
        <div class="health-metrics">
          <template v-if="evaluation && evaluation.detailedEvaluation && Object.keys(evaluation.detailedEvaluation).length">
            <div v-for="(value, key) in evaluation.detailedEvaluation" :key="key" class="metric-item">
              <div class="metric-header">
                <i :class="getIconForMetric(key)"></i>
                <span>{{ key }}</span>
              </div>
              <div class="metric-content">
                <template v-if="typeof value === 'object' && value !== null">
                  <div v-for="(subValue, subKey) in value" :key="subKey" class="metric-subitem">
                    <div class="metric-subheader">{{ subKey }}</div>
                    <p>{{ subValue }}</p>
                  </div>
                </template>
                <template v-else>
                  <p>{{ value }}</p>
                </template>
              </div>
            </div>
          </template>
          <template v-else>
            <p style="color: #f44336; text-align: center; font-weight: 600;">Không có dữ liệu đánh giá sức khỏe</p>
          </template>
        </div>
      </div>

      <!-- Phần kết luận tình trạng -->
      <div class="evaluation-section">
        <h3><i class="bi bi-stethoscope"></i> Kết luận tình trạng</h3>
        <div class="conclusion">
          <p>{{ evaluation.conclusion }}</p>
        </div>
      </div>

      <!-- Phần lời khuyên -->
      <div class="evaluation-section">
        <h3><i class="bi bi-lightbulb"></i> Lời khuyên</h3>
        <div class="recommendations">
          <div v-for="(recommendation, index) in evaluation.recommendations" :key="index" class="recommendation-item">
            <i class="bi bi-check-circle"></i>
            <p>{{ recommendation }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue';
import axiosInstance from '../services/axiosInstance.js';
import { useToast } from 'vue-toastification';

const toast = useToast();
const evaluation = ref({
  detailedEvaluation: {},
  conclusion: '',
  recommendations: []
});
const loading = ref(false);

watch(evaluation, (val) => {
  console.log('AI evaluation:', val);
}, { immediate: true });

const fetchHealthData = async () => {
  try {
    loading.value = true;
    
    // Lấy dữ liệu từ các API
    const [symptomsRes, allergiesRes, lifestyleRes, healthDataRes] = await Promise.all([
      axiosInstance.get('/api/medical-record/symptoms'),
      axiosInstance.get('/api/medical-record/allergies'),
      axiosInstance.get('/api/medical-record/lifestyles'),
      axiosInstance.get('/api/medical-record/health-data')
    ]);

    // Log dữ liệu đầu vào
    console.log('symptoms:', symptomsRes.data);
    console.log('allergies:', allergiesRes.data);
    console.log('lifestyle:', lifestyleRes.data);
    console.log('healthData:', healthDataRes.data);

    // Kiểm tra nếu tất cả đều rỗng thì báo lỗi
    const isAllEmpty = (
      (!symptomsRes.data || (Array.isArray(symptomsRes.data) && symptomsRes.data.length === 0)) &&
      (!allergiesRes.data || (Array.isArray(allergiesRes.data) && allergiesRes.data.length === 0)) &&
      (!lifestyleRes.data || (Array.isArray(lifestyleRes.data) && lifestyleRes.data.length === 0)) &&
      (!healthDataRes.data || (Array.isArray(healthDataRes.data) && healthDataRes.data.length === 0))
    );
    if (isAllEmpty) {
      toast.error('Bạn cần nhập ít nhất một dữ liệu sức khỏe để AI có thể đánh giá!');
      evaluation.value = {
        detailedEvaluation: {},
        conclusion: '',
        recommendations: []
      };
      loading.value = false;
      return;
    }

    // Gửi dữ liệu để đánh giá
    const response = await axiosInstance.post('/api/health-evaluation/evaluate', {
      symptoms: symptomsRes.data,
      allergies: allergiesRes.data,
      lifestyle: lifestyleRes.data,
      healthData: healthDataRes.data
    });

    evaluation.value = response.data;
    console.log('evaluation:', evaluation.value);
  } catch (error) {
    toast.error('Không thể tải đánh giá sức khỏe');
    console.error('Error fetching health evaluation:', error);
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  fetchHealthData();
});

defineEmits(['close']);
</script>

<style scoped>
.ai-evaluation {
  background: white;
  border-radius: 15px;
  width: 800px;
  height: 600px;
  max-width: 90vw;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.evaluation-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  border-bottom: 1px solid #eee;
  position: sticky;
  top: 0;
  background: white;
  z-index: 1;
}

.evaluation-header h2 {
  margin: 0;
  color: #2c3e50;
  display: flex;
  align-items: center;
  gap: 10px;
}

.close-btn {
  background: none;
  border: none;
  font-size: 20px;
  color: #666;
  cursor: pointer;
  padding: 5px;
  transition: all 0.3s;
}

.close-btn:hover {
  color: #e74c3c;
  transform: rotate(90deg);
}

.evaluation-content {
  padding: 20px;
}

.evaluation-section {
  margin-bottom: 30px;
}

.evaluation-section h3 {
  color: #2c3e50;
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 20px;
  font-weight: 600;
  padding-bottom: 10px;
  border-bottom: 2px solid #e9ecef;
}

.evaluation-section h3 i {
  color: #3498db;
  font-size: 24px;
}

.health-metrics {
  display: grid;
  gap: 20px;
}

.metric-item {
  background: #f8f9fa;
  border-radius: 10px;
  padding: 15px;
  border: 1px solid #eee;
  margin-bottom: 15px;
}

.metric-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 15px;
  padding-bottom: 10px;
  border-bottom: 2px solid #e9ecef;
}

.metric-header i {
  color: #3498db;
  font-size: 20px;
}

.metric-header span {
  font-size: 20px;
  font-weight: 700;
  color: #2c3e50;
  text-transform: uppercase;
  border-bottom: 2px solid #3498db;
  padding-bottom: 4px;
  display: inline-block;
}

.metric-content {
  margin-top: 8px;
}

.metric-subitem {
  margin-bottom: 10px;
}

.metric-subheader {
  font-size: 16px;
  font-weight: 600;
  color: #3498db;
  margin-top: 10px;
  margin-bottom: 4px;
  text-transform: capitalize;
}

.metric-item p {
  margin: 0 0 10px 0;
  line-height: 1.6;
  color: #495057;
  font-size: 15px;
  padding-left: 34px;
}

.status {
  margin-left: auto;
  padding: 5px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 500;
}

.status.good {
  background: #2ecc71;
  color: white;
}

.status.warning {
  background: #f1c40f;
  color: white;
}

.status.bad {
  background: #e74c3c;
  color: white;
}

.conclusion {
  background: #f8f9fa;
  border-radius: 10px;
  padding: 20px;
  border: 1px solid #eee;
  margin-bottom: 20px;
}

.conclusion p {
  margin: 0;
  line-height: 1.8;
  color: #495057;
  font-size: 16px;
}

.conclusion ul {
  margin: 0;
  padding-left: 20px;
}

.conclusion li {
  margin-bottom: 8px;
  color: #2c3e50;
}

.recommendations {
  display: grid;
  gap: 15px;
}

.recommendation-item {
  display: flex;
  align-items: flex-start;
  gap: 15px;
  background: #f8f9fa;
  border-radius: 10px;
  padding: 15px;
  border: 1px solid #eee;
}

.recommendation-item i {
  color: #2ecc71;
  font-size: 20px;
  margin-top: 2px;
}

.recommendation-item p {
  margin: 0;
  line-height: 1.6;
  color: #495057;
  font-size: 15px;
}

@media (max-width: 768px) {
  .ai-evaluation {
    width: 95vw;
  }

  .health-metrics {
    grid-template-columns: 1fr;
  }
}

.loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  padding: 40px;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #3498db;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>

<script>
// Thêm hàm helper để lấy icon cho từng loại metric
function getIconForMetric(metric) {
  const icons = {
    'Triệu chứng': 'bi bi-thermometer-half',
    'Dị ứng': 'bi bi-exclamation-triangle',
    'Lối sống': 'bi bi-person-walking',
    'Dữ liệu sức khỏe': 'bi bi-heart-pulse',
    'Thuốc men': 'bi bi-capsule',
    'Điều trị': 'bi bi-stethoscope',
    'Tiêm chủng': 'bi bi-syringe'
  };
  return icons[metric] || 'bi bi-info-circle';
}
</script> 