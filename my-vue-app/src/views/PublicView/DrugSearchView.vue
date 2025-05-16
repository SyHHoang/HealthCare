<template>
  <div class="drug-search-container">
    <div class="container py-4">
      <!-- Header -->
      <div class="text-center mb-5">
        <h1 class="display-4">Tra cứu thuốc</h1>
        <p class="lead">Tìm kiếm thông tin về các loại thuốc</p>
      </div>

      <!-- Search Section -->
      <div class="search-section mb-4">
        <div class="row">
          <div class="col-md-8 mx-auto">
            <div class="input-group">
              <input
                type="text"
                class="form-control"
                v-model="searchQuery"
                placeholder="Nhập tên thuốc, hoạt chất hoặc công dụng..."
                @keyup.enter="handleSearch"
              />
              <button class="btn btn-primary" @click="handleSearch">
                <i class="fas fa-search"></i> Tìm kiếm
              </button>
            </div>
          </div>
        </div>

        <!-- Filter Section -->
        <div class="row mt-3">
          <div class="col-md-8 mx-auto">
            <div class="d-flex flex-wrap gap-2">
              <select class="form-select" v-model="categoryFilter">
                <option value="">Tất cả danh mục</option>
                <option v-for="category in categories" :key="category" :value="category">
                  {{ category }}
                </option>
              </select>
              <select class="form-select" v-model="typeFilter">
                <option value="">Tất cả dạng bào chế</option>
                <option v-for="type in types" :key="type" :value="type">
                  {{ type }}
                </option>
              </select>
            </div>
          </div>
        </div>
      </div>

      <!-- Loading Spinner -->
      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border text-primary" role="status">
          <span class="visually-hidden">Loading...</span>
        </div>
      </div>

      <!-- Error Message -->
      <div v-if="error" class="alert alert-danger" role="alert">
        {{ error }}
      </div>

      <!-- No Results Message -->
      <div v-if="!loading && !error && drugs.length === 0" class="text-center py-5">
        <h3>Không tìm thấy kết quả</h3>
        <p class="text-muted">Vui lòng thử tìm kiếm với từ khóa khác</p>
      </div>

      <!-- Drug List -->
      <div v-if="!loading && !error && drugs.length > 0" class="row g-4">
        <div v-for="drug in filteredDrugs" :key="drug._id" class="col-md-6 col-lg-4">
          <div class="card h-100 drug-card">
            <div class="card-body">
              <h5 class="card-title">{{ drug.name }}</h5>
              <p class="card-text text-muted">
                <i class="fas fa-tag me-2"></i>{{ drug.category }}
              </p>
              <p class="card-text">
                <i class="fas fa-pills me-2"></i>{{ drug.type }}
              </p>
              <p class="card-text">
                <i class="fas fa-flask me-2"></i>Hoạt chất: {{ drug.activeIngredient }}
              </p>
              <p class="card-text">
                <i class="fas fa-info-circle me-2"></i>Công dụng: {{ drug.uses }}
              </p>
              <p class="card-text">
                <i class="fas fa-exclamation-triangle me-2"></i>Chống chỉ định: {{ drug.contraindications }}
              </p>
              <button class="btn btn-outline-primary mt-3" @click="showDrugDetail(drug)">
                Xem chi tiết
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Drug Detail Modal -->
    <div class="modal fade" id="drugDetailModal" tabindex="-1" aria-labelledby="drugDetailModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="drugDetailModalLabel">Chi tiết thuốc</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body" v-if="selectedDrug">
            <div class="row">
              <div class="col-md-6">
                <h5>{{ selectedDrug.name }}</h5>
                <p><strong>Danh mục:</strong> {{ selectedDrug.category }}</p>
                <p><strong>Dạng bào chế:</strong> {{ selectedDrug.type }}</p>
                <p><strong>Hoạt chất:</strong> {{ selectedDrug.activeIngredient }}</p>
                <p><strong>Nhà sản xuất:</strong> {{ selectedDrug.manufacturer }}</p>
              </div>
              <div class="col-md-6">
                <h6>Công dụng:</h6>
                <p>{{ selectedDrug.uses }}</p>
                <h6>Liều dùng:</h6>
                <p>{{ selectedDrug.dosage }}</p>
                <h6>Chống chỉ định:</h6>
                <p>{{ selectedDrug.contraindications }}</p>
                <h6>Tác dụng phụ:</h6>
                <p>{{ selectedDrug.sideEffects }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { Modal } from 'bootstrap';
import axios from '@/services/axiosInstance.js';

const searchQuery = ref('');
const categoryFilter = ref('');
const typeFilter = ref('');
const loading = ref(false);
const error = ref(null);
const drugs = ref([]);
const selectedDrug = ref(null);
const drugDetailModal = ref(null);

// Danh sách danh mục và dạng bào chế mẫu
const categories = ref([
  'Kháng sinh',
  'Giảm đau',
  'Hạ sốt',
  'Kháng viêm',
  'Vitamin',
  'Dinh dưỡng',
  'Tim mạch',
  'Tiêu hóa',
  'Hô hấp',
  'Da liễu'
]);

const types = ref([
  'Viên nén',
  'Viên nang',
  'Viên sủi',
  'Dung dịch',
  'Hỗn dịch',
  'Sirô',
  'Thuốc mỡ',
  'Thuốc bột',
  'Thuốc tiêm'
]);

const handleSearch = async () => {
  try {
    loading.value = true;
    error.value = null;
    
    console.log('Searching with params:', {
      query: searchQuery.value,
      category: categoryFilter.value,
      type: typeFilter.value
    });
    
    const response = await axios.get('/api/drugs/search', {
      params: {
        query: searchQuery.value,
        category: categoryFilter.value,
        type: typeFilter.value
      }
    });
    
    console.log('Search response:', response.data);
    drugs.value = response.data || [];
  } catch (err) {
    console.error('Error searching drugs:', err);
    error.value = err.response?.data?.message || 'Không thể tìm kiếm thuốc. Vui lòng thử lại sau.';
    drugs.value = [];
  } finally {
    loading.value = false;
  }
};

const showDrugDetail = (drug) => {
  selectedDrug.value = drug;
  if (drugDetailModal.value) {
    drugDetailModal.value.show();
  }
};

const filteredDrugs = computed(() => {
  return drugs.value;
});

onMounted(() => {
  drugDetailModal.value = new Modal(document.getElementById('drugDetailModal'));
  handleSearch(); // Tải danh sách thuốc ban đầu
});
</script>

<style scoped>
.drug-search-container {
  padding-top: 80px;
  background-color: #f8f9fa;
}

.search-section {
  background-color: white;
  padding: 20px;
  border-radius: 10px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.drug-card {
  transition: transform 0.3s ease;
  border: none;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.drug-card:hover {
  transform: translateY(-5px);
}

.form-select {
  max-width: 200px;
}

@media (max-width: 768px) {
  .form-select {
    max-width: 100%;
  }
}
</style> 