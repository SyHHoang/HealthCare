<template>
  <div class="transaction-management">
    <div class="d-flex justify-content-between align-items-center mb-4">
      <h2>Quản lý giao dịch</h2>
      <button class="btn btn-success" @click="exportToExcel">
        <i class="fas fa-file-excel me-2"></i>Xuất Excel
      </button>
    </div>

    <!-- Thống kê tổng quan -->
    <div class="statistics-cards mb-4">
      <div class="row g-3">
        <div class="col-md-4">
          <div class="card">
            <div class="card-body">
              <h6 class="card-subtitle mb-2 text-muted">Doanh thu hôm nay</h6>
              <h4 class="card-title">{{ formatCurrency(stats.daily.totalAmount) }}</h4>
              <p class="card-text">{{ stats.daily.count }} giao dịch</p>
            </div>
          </div>
        </div>
        <div class="col-lg-2 col-md-4 col-6">
          <div class="card bg-success bg-opacity-10">
            <div class="card-body">
              <h6 class="card-subtitle mb-2 text-muted">Thành công</h6>
              <h4 class="card-title text-dark">{{ stats.byStatus.success }}</h4>
              <p class="card-text">giao dịch</p>
            </div>
          </div>
        </div>
        <div class="col-lg-2 col-md-4 col-6">
          <div class="card bg-info bg-opacity-10">
            <div class="card-body">
              <h6 class="card-subtitle mb-2 text-muted">Đã gửi cho BS</h6>
              <h4 class="card-title text-dark">{{ stats.byStatus.paid_to_doctor }}</h4>
              <p class="card-text">giao dịch</p>
            </div>
          </div>
        </div>
        <div class="col-lg-2 col-md-4 col-6">
          <div class="card bg-danger bg-opacity-10">
            <div class="card-body">
              <h6 class="card-subtitle mb-2 text-muted">Thất bại</h6>
              <h4 class="card-title text-dark">{{ stats.byStatus.failed }}</h4>
              <p class="card-text">giao dịch</p>
            </div>
          </div>
        </div>
        <div class="col-lg-2 col-md-4 col-6">
          <div class="card bg-warning bg-opacity-10">
            <div class="card-body">
              <h6 class="card-subtitle mb-2 text-muted">Đang xử lý</h6>
              <h4 class="card-title text-dark">{{ stats.byStatus.pending }}</h4>
              <p class="card-text">giao dịch</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Biểu đồ thống kê -->
    <!-- <div class="row mb-4">
      <div class="col-md-8">
        <div class="card">
          <div class="card-body">
            <h5 class="card-title">Biểu đồ doanh thu</h5>
            <canvas ref="revenueChart"></canvas>
          </div>
        </div>
      </div>
      <div class="col-md-4">
        <div class="card">
          <div class="card-body">
            <h5 class="card-title">Tỷ lệ trạng thái</h5>
            <canvas ref="statusChart"></canvas>
          </div>
        </div>
      </div>
    </div> -->

    <!-- Bộ lọc nâng cao -->
    <div class="card mb-4">
      <div class="card-body">
        <div class="row g-3">
          <div class="col-md-3">
            <label class="form-label">Từ ngày</label>
            <input
              type="date"
              class="form-control"
              v-model="filters.startDate"
              @change="loadTransactions"
            />
          </div>
          <div class="col-md-3">
            <label class="form-label">Đến ngày</label>
            <input
              type="date"
              class="form-control"
              v-model="filters.endDate"
              @change="loadTransactions"
            />
          </div>
          <div class="col-md-2">
            <label class="form-label">Trạng thái</label>
            <select class="form-select" v-model="filters.status" @change="loadTransactions">
              <option value="">Tất cả</option>
              <option value="success">Thành công</option>
              <option value="failed">Thất bại</option>
              <option value="pending">Đang xử lý</option>
              <option value="paid_to_doctor">Đã gửi tiền cho bác sĩ</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="form-label">Sắp xếp theo</label>
            <select class="form-select" v-model="filters.sortBy" @change="loadTransactions">
              <option value="date_desc">Mới nhất</option>
              <option value="date_asc">Cũ nhất</option>
              <option value="amount_desc">Giá trị cao nhất</option>
              <option value="amount_asc">Giá trị thấp nhất</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="form-label">Tìm kiếm</label>
            <div class="input-group">
              <input
                type="text"
                class="form-control"
                v-model="filters.search"
                placeholder="Mã giao dịch..."
                @keyup.enter="loadTransactions"
              />
              <button class="btn btn-primary" @click="loadTransactions">
                <i class="fas fa-search"></i>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Bảng giao dịch -->
    <div class="card">
      <div class="card-body">
        <div class="table-responsive">
          <table class="table table-hover">
            <thead>
              <tr>
                <th>Mã giao dịch</th>
                <th>Người dùng</th>
                <th>Bác sĩ</th>
                <th>Số tiền</th>
                <th>Trạng thái</th>
                <th>Thời gian</th>
                <th>Thao tác</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="transaction in transactions" :key="transaction._id">
                <td>{{ transaction.txnRef }}</td>
                <td>
                  {{ transaction.userId?.fullname }}
                  <br />
                  <small class="text-muted">{{ transaction.userId?.email }}</small>
                </td>
                <td>
                  {{ transaction.doctorId?.fullName }}
                  <br />
                  <small class="text-muted">{{ transaction.doctorId?.specialty }}</small>
                </td>
                <td>{{ formatCurrency(transaction.amount) }}</td>
                <td>
                  <span
                    class="badge"
                    :class="{
                      'bg-success': transaction.status === 'success',
                      'bg-danger': transaction.status === 'failed',
                      'bg-warning': transaction.status === 'pending',
                      'bg-info': transaction.status === 'paid_to_doctor'
                    }"
                  >
                    {{ getStatusText(transaction.status) }}
                  </span>
                </td>
                <td>{{ formatDate(transaction.transactionDate) }}</td>
                <td>
                  <button
                    class="btn btn-sm btn-info me-2"
                    @click="showTransactionDetail(transaction)"
                    title="Xem chi tiết"
                  >
                    <i class="fas fa-eye"></i>
                  </button>
                  <button 
                    v-if="transaction.status === 'pending'"
                    class="btn btn-sm btn-success me-2"
                    @click="updateStatus(transaction._id, 'success')"
                    title="Đánh dấu thành công"
                  >
                    <i class="fas fa-check"></i>
                  </button>
                  <button 
                    v-if="transaction.status === 'success'"
                    class="btn btn-sm btn-primary"
                    @click="updateStatus(transaction._id, 'paid_to_doctor')"
                    title="Gửi tiền cho bác sĩ"
                  >
                    <i class="bi bi-cash-coin"></i> Gửi tiền cho bác sĩ
                  </button>
                </td>
              </tr>
              <tr v-if="transactions.length === 0">
                <td colspan="7" class="text-center py-4">
                  <div class="text-muted">Không có giao dịch nào</div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Phân trang -->
        <nav v-if="totalPages > 1" class="mt-4">
          <ul class="pagination justify-content-center">
            <li class="page-item" :class="{ disabled: currentPage === 1 }">
              <a class="page-link" href="#" @click.prevent="changePage(currentPage - 1)">
                <i class="fas fa-chevron-left"></i>
              </a>
            </li>
            <li
              v-for="page in totalPages"
              :key="page"
              class="page-item"
              :class="{ active: page === currentPage }"
            >
              <a class="page-link" href="#" @click.prevent="changePage(page)">{{ page }}</a>
            </li>
            <li class="page-item" :class="{ disabled: currentPage === totalPages }">
              <a class="page-link" href="#" @click.prevent="changePage(currentPage + 1)">
                <i class="fas fa-chevron-right"></i>
              </a>
            </li>
          </ul>
        </nav>
      </div>
    </div>

    <!-- Modal chi tiết giao dịch -->
    <div class="modal fade" id="transactionDetailModal" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Chi tiết giao dịch</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body" v-if="selectedTransaction">
            <div class="mb-4">
              <h6 class="border-bottom pb-2">Thông tin giao dịch</h6>
              <div class="row">
                <div class="col-md-6">
                  <p><strong>Mã giao dịch:</strong></p>
                  <p class="text-muted">{{ selectedTransaction.txnRef }}</p>
                </div>
                <div class="col-md-6">
                  <p><strong>Số tiền:</strong></p>
                  <p class="text-muted">{{ formatCurrency(selectedTransaction.amount) }}</p>
                </div>
                <div class="col-md-6">
                  <p><strong>Trạng thái:</strong></p>
                  <p>
                    <span
                      class="badge"
                      :class="{
                        'bg-success': selectedTransaction.status === 'success',
                        'bg-danger': selectedTransaction.status === 'failed',
                        'bg-warning': selectedTransaction.status === 'pending',
                        'bg-info': selectedTransaction.status === 'paid_to_doctor'
                      }"
                    >
                      {{ getStatusText(selectedTransaction.status) }}
                    </span>
                  </p>
                </div>
                <div class="col-md-6">
                  <p><strong>Thời gian:</strong></p>
                  <p class="text-muted">{{ formatDate(selectedTransaction.transactionDate) }}</p>
                </div>
                <div class="col-md-6">
                  <p><strong>Phương thức:</strong></p>
                  <p class="text-muted">{{ selectedTransaction.paymentMethod }}</p>
                </div>
                <div class="col-md-6">
                  <p><strong>Mã ngân hàng:</strong></p>
                  <p class="text-muted">{{ selectedTransaction.bankCode || 'N/A' }}</p>
                </div>
              </div>
            </div>
            <div class="mb-4">
              <h6 class="border-bottom pb-2">Thông tin người dùng</h6>
              <div class="row">
                <div class="col-md-6">
                  <p><strong>Họ tên:</strong></p>
                  <p class="text-muted">{{ selectedTransaction.userId?.fullname }}</p>
                </div>
                <div class="col-md-6">
                  <p><strong>Email:</strong></p>
                  <p class="text-muted">{{ selectedTransaction.userId?.email }}</p>
                </div>
                <div class="col-md-12">
                  <p><strong>Số điện thoại:</strong></p>
                  <p class="text-muted">{{ selectedTransaction.userId?.phone }}</p>
                </div>
              </div>
            </div>
            <div class="mb-4">
              <h6 class="border-bottom pb-2">Thông tin bác sĩ</h6>
              <div class="row">
                <div class="col-md-6">
                  <p><strong>Họ tên:</strong></p>
                  <p class="text-muted">{{ selectedTransaction.doctorId?.fullName }}</p>
                </div>
                <div class="col-md-6">
                  <p><strong>Chuyên khoa:</strong></p>
                  <p class="text-muted">{{ selectedTransaction.doctorId?.specialty }}</p>
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
            <button
              v-if="selectedTransaction?.status === 'pending'"
              type="button"
              class="btn btn-success"
              @click="updateStatus(selectedTransaction._id, 'success')"
            >
              Đánh dấu thành công
            </button>
            <button
              v-if="selectedTransaction?.status === 'success'"
              type="button"
              class="btn btn-primary"
              @click="updateStatus(selectedTransaction._id, 'paid_to_doctor')"
            >
              <i class="bi bi-cash-coin me-1"></i> Gửi tiền cho bác sĩ
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { transactionService } from '@/services/transactionService'
import { useToast } from 'vue-toastification'
import { Modal } from 'bootstrap'
import * as XLSX from 'xlsx'

const toast = useToast()

// State
const transactions = ref([])
const loading = ref(false)
const error = ref(null)
const currentPage = ref(1)
const totalPages = ref(1)
const searchQuery = ref('')
const statusFilter = ref('all')
const stats = ref({
  totalRevenue: 0,
  actualRevenue: 0,
  pendingAmount: 0,
  totalTransactions: 0
})
const filters = ref({
  startDate: '',
  endDate: '',
  status: '',
  search: '',
  sortBy: 'date_desc'
})
const selectedTransaction = ref(null)
const transactionDetailModal = ref(null)
const revenueChart = ref(null)
const statusChart = ref(null)
let revenueChartInstance = null
let statusChartInstance = null

// Computed
const filteredTransactions = computed(() => {
  return transactions.value
})

// Methods
const fetchTransactions = async () => {
  loading.value = true
  error.value = null
  try {
    const params = {
      page: currentPage.value,
      search: searchQuery.value,
      status: statusFilter.value !== 'all' ? statusFilter.value : undefined
    }
    const response = await transactionService.getTransactions(params)
    transactions.value = response.data
    totalPages.value = response.last_page
  } catch (err) {
    error.value = 'Không thể tải danh sách giao dịch'
    console.error('Error fetching transactions:', err)
  } finally {
    loading.value = false
  }
}

const fetchStats = async () => {
  try {
    const data = await transactionService.getStats()
    stats.value = data
  } catch (err) {
    console.error('Error fetching stats:', err)
  }
}

const handleStatusChange = async (transactionId, newStatus) => {
  try {
    await transactionService.updateStatus(transactionId, newStatus)
    toast.success('Cập nhật trạng thái thành công')
    await fetchTransactions()
    await fetchStats()
  } catch (err) {
    toast.error('Không thể cập nhật trạng thái')
    console.error('Error updating status:', err)
  }
}

const handleSearch = () => {
  currentPage.value = 1
  fetchTransactions()
}

const handlePageChange = (page) => {
  currentPage.value = page
  fetchTransactions()
}

const formatDate = (dateString) => {
  return new Date(dateString).toLocaleDateString('vi-VN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const formatCurrency = (amount) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND'
  }).format(amount)
}

const getStatusBadgeClass = (status) => {
  const classes = {
    pending: 'bg-warning',
    completed: 'bg-success',
    cancelled: 'bg-danger',
    refunded: 'bg-info'
  }
  return classes[status] || 'bg-secondary'
}

const getStatusText = (status) => {
  const texts = {
    pending: 'Chờ xử lý',
    completed: 'Hoàn thành',
    cancelled: 'Đã hủy',
    refunded: 'Đã hoàn tiền'
  }
  return texts[status] || status
}

const exportToExcel = () => {
  const wb = XLSX.utils.book_new()
  
  // Chuyển đổi dữ liệu
  const data = transactions.value.map(t => ({
    'Mã giao dịch': t.txnRef,
    'Người dùng': t.userId?.fullname,
    'Email': t.userId?.email,
    'Bác sĩ': t.doctorId?.fullName,
    'Chuyên khoa': t.doctorId?.specialty,
    'Số tiền': t.amount,
    'Trạng thái': getStatusText(t.status),
    'Thời gian': formatDate(t.transactionDate)
  }))

  const ws = XLSX.utils.json_to_sheet(data)
  XLSX.utils.book_append_sheet(wb, ws, 'Giao dịch')
  
  // Tải file
  XLSX.writeFile(wb, `giao-dich-${new Date().toISOString().split('T')[0]}.xlsx`)
}

const showTransactionDetail = (transaction) => {
  selectedTransaction.value = transaction
  transactionDetailModal.value.show()
}

const updateStatus = async (id, status) => {
  try {
    await transactionService.updateStatus(id, status)
    toast.success('Đã cập nhật trạng thái giao dịch')
    await fetchTransactions()
    await fetchStats()
    if (transactionDetailModal.value) {
      transactionDetailModal.value.hide()
    }
  } catch (error) {
    console.error('Error updating status:', error)
    toast.error('Không thể cập nhật trạng thái giao dịch')
  }
}

// Lifecycle hooks
onMounted(() => {
  fetchTransactions()
  fetchStats()
  transactionDetailModal.value = new Modal(document.getElementById('transactionDetailModal'))
})

// Theo dõi thay đổi của filters
watch(filters, () => {
  currentPage.value = 1
  fetchTransactions()
}, { deep: true })
</script>

<style scoped>
.transaction-management {
  padding: 20px;
}

.statistics-cards .card {
  border: none;
  box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s;
  height: 100%;
}

.statistics-cards .card-title {
  font-size: 1.6rem;
  margin-bottom: 0.5rem;
}

.statistics-cards .card-subtitle {
  font-size: 0.85rem;
  opacity: 0.8;
}

.statistics-cards .card-text {
  font-size: 0.9rem;
  margin-bottom: 0;
}

.statistics-cards .card:hover {
  transform: translateY(-5px);
}

.card {
  border: none;
  box-shadow: 0 0 15px rgba(0, 0, 0, 0.05);
  border-radius: 10px;
  margin-bottom: 20px;
}

.table th {
  background-color: #f8f9fa;
  font-weight: 600;
}

.badge {
  padding: 8px 12px;
  border-radius: 6px;
}

.modal-body h6 {
  color: #495057;
  font-weight: 600;
  margin-bottom: 15px;
}

.pagination .page-link {
  color: #0d6efd;
  padding: 8px 16px;
}

.pagination .page-item.active .page-link {
  background-color: #0d6efd;
  border-color: #0d6efd;
}

.btn-success {
  background-color: #198754;
  border: none;
}

.btn-success:hover {
  background-color: #157347;
}

.btn-primary {
  display: inline-flex;
  align-items: center;
  gap: 5px;
}

canvas {
  min-height: 300px;
}

@media (max-width: 768px) {
  .statistics-cards .card {
    margin-bottom: 15px;
  }
}
</style> 