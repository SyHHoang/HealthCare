<template>
  <div class="ai-evaluation">
    <div class="evaluation-header">
      <h2><i class="bi bi-robot"></i> Đánh giá sức khỏe bằng AI</h2>
      <button class="close-btn" @click="$emit('close')">
        <i class="bi bi-x-lg"></i>
      </button>
    </div>

    <div class="evaluation-content">
      <!-- Phần đánh giá các mục sức khỏe -->
      <div class="evaluation-section">
        <h3><i class="bi bi-clipboard-check"></i> Đánh giá chi tiết</h3>
        <div class="health-metrics">
          <!-- Dị ứng -->
          <div class="metric-item">
            <div class="metric-header">
              <i class="bi bi-exclamation-triangle"></i>
              <span>Dị ứng</span>
              <span class="status warning">Cần lưu ý</span>
            </div>
            <p>Có 2 dị ứng đang hoạt động: Penicillin (Nặng) và Đậu phộng (Trung bình). Cần thận trọng khi sử dụng thuốc và thực phẩm.</p>
          </div>

          <!-- Dữ liệu sức khỏe -->
          <div class="metric-item">
            <div class="metric-header">
              <i class="bi bi-heart-pulse"></i>
              <span>Chỉ số sức khỏe</span>
              <span class="status good">Tốt</span>
            </div>
            <p>Huyết áp: 120/80 mmHg, Nhịp tim: 75 bpm, Đường huyết: 5.5 mmol/L. Các chỉ số đều trong giới hạn bình thường.</p>
          </div>

          <!-- Lối sống -->
          <div class="metric-item">
            <div class="metric-header">
              <i class="bi bi-person-walking"></i>
              <span>Lối sống</span>
              <span class="status good">Tốt</span>
            </div>
            <p>Tập thể dục đều đặn 30 phút/ngày, chế độ ăn cân bằng. Cần cải thiện thời gian ngủ.</p>
          </div>

          <!-- Thuốc men -->
          <div class="metric-item">
            <div class="metric-header">
              <i class="bi bi-capsule"></i>
              <span>Thuốc men</span>
              <span class="status warning">Cần lưu ý</span>
            </div>
            <p>Đang sử dụng 3 loại thuốc thường xuyên. Cần tuân thủ đúng liều lượng và thời gian.</p>
          </div>

          <!-- Triệu chứng -->
          <div class="metric-item">
            <div class="metric-header">
              <i class="bi bi-thermometer-half"></i>
              <span>Triệu chứng</span>
              <span class="status warning">Cần lưu ý</span>
            </div>
            <p>Có triệu chứng đau đầu và mệt mỏi kéo dài. Cần theo dõi và tái khám nếu không cải thiện.</p>
          </div>

          <!-- Phác đồ điều trị -->
          <div class="metric-item">
            <div class="metric-header">
              <i class="bi bi-stethoscope"></i>
              <span>Điều trị</span>
              <span class="status good">Tốt</span>
            </div>
            <p>Đang trong quá trình điều trị viêm xoang. Tuân thủ tốt phác đồ điều trị.</p>
          </div>

          <!-- Tiêm chủng -->
          <div class="metric-item">
            <div class="metric-header">
              <i class="bi bi-syringe"></i>
              <span>Tiêm chủng</span>
              <span class="status good">Đầy đủ</span>
            </div>
            <p>Đã tiêm đầy đủ các mũi vắc xin cơ bản. Cần tiêm nhắc lại vắc xin cúm.</p>
          </div>
        </div>
      </div>

      <!-- Phần kết luận tình trạng -->
      <div class="evaluation-section">
        <h3><i class="bi bi-stethoscope"></i> Kết luận tình trạng</h3>
        <div class="conclusion">
          <p>Tình trạng sức khỏe chung đang ở mức tốt. Các chỉ số cơ bản đều trong giới hạn cho phép. Tuy nhiên, cần lưu ý:</p>
          <ul>
            <li>Quản lý tốt các dị ứng đang hoạt động</li>
            <li>Theo dõi các triệu chứng đau đầu và mệt mỏi</li>
            <li>Tuân thủ đúng phác đồ điều trị và lịch uống thuốc</li>
            <li>Cải thiện thời gian ngủ và chất lượng giấc ngủ</li>
          </ul>
        </div>
      </div>

      <!-- Phần lời khuyên -->
      <div class="evaluation-section">
        <h3><i class="bi bi-lightbulb"></i> Lời khuyên</h3>
        <div class="recommendations">
          <div class="recommendation-item">
            <i class="bi bi-check-circle"></i>
            <p>Duy trì chế độ ăn uống lành mạnh, tránh các thực phẩm gây dị ứng</p>
          </div>
          <div class="recommendation-item">
            <i class="bi bi-check-circle"></i>
            <p>Tiếp tục tập thể dục đều đặn 30 phút mỗi ngày</p>
          </div>
          <div class="recommendation-item">
            <i class="bi bi-check-circle"></i>
            <p>Đặt lịch tái khám định kỳ sau 2 tuần</p>
          </div>
          <div class="recommendation-item">
            <i class="bi bi-check-circle"></i>
            <p>Ghi chú lại các triệu chứng bất thường để báo cáo với bác sĩ</p>
          </div>
          <div class="recommendation-item">
            <i class="bi bi-check-circle"></i>
            <p>Đặt lịch tiêm vắc xin cúm trong tháng tới</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
defineEmits(['close'])
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
}

.metric-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 10px;
}

.metric-header i {
  color: #3498db;
  font-size: 18px;
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
}

.conclusion p {
  margin: 0 0 15px 0;
  line-height: 1.6;
  color: #2c3e50;
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
  font-size: 18px;
  margin-top: 2px;
}

.recommendation-item p {
  margin: 0;
  line-height: 1.6;
  color: #2c3e50;
}

@media (max-width: 768px) {
  .ai-evaluation {
    width: 95vw;
  }

  .health-metrics {
    grid-template-columns: 1fr;
  }
}
</style> 