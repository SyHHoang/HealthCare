<template>
  <div class="modal" @click.self="closeModal">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">
          <i class="fas fa-credit-card me-2"></i>Thanh toán
        </h5>
        <button type="button" class="btn-close" @click="closeModal"></button>
      </div>
      <div class="modal-body">
        <div class="payment-info mb-4">
          <h6>Thông tin thanh toán</h6>
          <div class="info-item">
            <span class="label">Bác sĩ:</span>
            <span class="value">{{ doctorName }}</span>
          </div>
          <div class="info-item">
            <span class="label">Dịch vụ:</span>
            <span class="value">{{ serviceDuration }} phút</span>
          </div>
          <div class="info-item">
            <span class="label">Thời gian:</span>
            <span class="value">{{ formatDate(bookingDate) }} - {{ startTime }} - {{ endTime }}</span>
          </div>
          <div class="info-item">
            <span class="label">Số tiền:</span>
            <span class="value price">{{ formatPrice(amount) }}</span>
          </div>
        </div>

        <div class="payment-method mb-4">
          <h6>Chọn phương thức thanh toán</h6>
          <div class="payment-options">
            <div class="payment-option" @click="selectPaymentMethod('vnpay')">
              <i class="fas fa-credit-card me-2"></i>
              <span>VNPAY</span>
            </div>
          </div>
        </div>

        <div v-if="selectedMethod === 'vnpay'" class="bank-list mb-4">
          <h6>Chọn ngân hàng</h6>
          <div class="bank-grid">
            <div v-for="bank in banks" :key="bank.code" 
                 class="bank-item" 
                 :class="{'selected': selectedBank === bank.code}"
                 @click="selectBank(bank.code)">
              <span class="bank-name">{{ bank.name }}</span>
            </div>
          </div>
        </div>

        <div class="payment-note">
          <small class="text-muted">
            <i class="fas fa-info-circle me-1"></i>
            Thanh toán an toàn và bảo mật với VNPAY
          </small>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" @click="closeModal">
          <i class="fas fa-times me-2"></i>Hủy
        </button>
        <button type="button" class="btn btn-primary" @click="proceedPayment" :disabled="!selectedBank">
          <i class="fas fa-check me-2"></i>Thanh toán
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useToast } from 'primevue/usetoast';
import axios from '@/services/axiosInstance.js';

const props = defineProps({
  doctorName: String,
  serviceDuration: Number,
  bookingDate: String,
  startTime: String,
  endTime: String,
  amount: Number,
  bookingId: String
});

const emit = defineEmits(['close', 'payment-success']);

const toast = useToast();
const showModal = ref(true);
const selectedMethod = ref('vnpay');
const selectedBank = ref(null);

const banks = [
  { code: 'NCB', name: 'NCB' },
  { code: 'AGRIBANK', name: 'Agribank' },
  { code: 'SCB', name: 'SCB' },
  { code: 'SACOMBANK', name: 'Sacombank' },
  { code: 'EXIMBANK', name: 'Eximbank' },
  { code: 'MSBANK', name: 'MSB' },
  { code: 'NAMABANK', name: 'NamABank' },
  { code: 'VNMART', name: 'VNMart' },
  { code: 'VIETINBANK', name: 'VietinBank' },
  { code: 'VIETCOMBANK', name: 'Vietcombank' },
  { code: 'HDBANK', name: 'HDBank' },
  { code: 'DONGABANK', name: 'DongABank' },
  { code: 'TPBANK', name: 'TPBank' },
  { code: 'OJB', name: 'OceanBank' },
  { code: 'BIDV', name: 'BIDV' },
  { code: 'TECHCOMBANK', name: 'Techcombank' },
  { code: 'VPBANK', name: 'VPBank' },
  { code: 'MBBANK', name: 'MBBank' },
  { code: 'ACB', name: 'ACB' },
  { code: 'OCB', name: 'OCB' },
  { code: 'IVB', name: 'Indovina' },
  { code: 'VISA', name: 'VISA' },
  { code: 'MASTERCARD', name: 'MasterCard' },
  { code: 'JCB', name: 'JCB' },
  { code: 'UPI', name: 'UPI' },
  { code: 'VIB', name: 'VIB' },
  { code: 'VRB', name: 'VRB' }
];

const selectPaymentMethod = (method) => {
  selectedMethod.value = method;
  selectedBank.value = null;
};

const selectBank = (bankCode) => {
  selectedBank.value = bankCode;
};

const formatPrice = (price) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND'
  }).format(price);
};

const formatDate = (dateString) => {
  const date = new Date(dateString);
  return date.toLocaleDateString('vi-VN', {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
    year: 'numeric'
  });
};

const closeModal = () => {
  emit('close');
};

const proceedPayment = async () => {
  try {
    const response = await axios.post('/api/payment/create', {
      bookingId: props.bookingId,
      amount: props.amount,
      bankCode: selectedBank.value
    });

    if (response.data.success) {
      // Chuyển hướng đến trang thanh toán VNPAY
      window.location.href = response.data.data.paymentUrl;
    }
  } catch (error) {
    console.error('Error creating payment:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: error.response?.data?.message || 'Không thể tạo giao dịch thanh toán',
      life: 3000
    });
  }
};
</script>

<style scoped>
.modal {
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

.modal-content {
  background: white;
  padding: 20px;
  border-radius: 10px;
  width: 90%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
}

.payment-info {
  background: #f8f9fa;
  padding: 15px;
  border-radius: 8px;
}

.info-item {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10px;
}

.info-item:last-child {
  margin-bottom: 0;
}

.label {
  color: #6c757d;
}

.value {
  font-weight: 500;
}

.price {
  color: #dc3545;
  font-weight: 600;
}

.payment-options {
  display: flex;
  gap: 15px;
  margin-top: 10px;
}

.payment-option {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px;
  border: 1px solid #dee2e6;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.payment-option:hover {
  border-color: #0d6efd;
  background-color: #f8f9fa;
}

.bank-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  gap: 10px;
  margin-top: 10px;
}

.bank-item {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 10px;
  border: 1px solid #dee2e6;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.bank-item:hover {
  border-color: #0d6efd;
  background-color: #f8f9fa;
}

.bank-item.selected {
  border-color: #0d6efd;
  background-color: #e7f1ff;
}

.bank-name {
  font-size: 0.9rem;
  text-align: center;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 100%;
}

.payment-note {
  margin-top: 20px;
  padding-top: 10px;
  border-top: 1px solid #dee2e6;
}

@media (max-width: 768px) {
  .bank-grid {
    grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
  }
}
</style> 