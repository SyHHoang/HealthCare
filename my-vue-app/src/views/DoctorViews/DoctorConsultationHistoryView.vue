<template>
  <div class="consultation-history-container">
    <!-- Video Call Modal -->
    <div v-if="showVideoCall" class="video-call-modal">
      <div class="video-grid" :class="{ 'expanded': expandedVideo }">
        <div class="video-box" :class="{ 'expanded': expandedVideo === 'local' }" @click="toggleExpand('local')">
          <video ref="localVideo" autoplay muted playsinline></video>
          <span class="video-label">Bạn</span>
          <button class="expand-btn" @click.stop="toggleExpand('local')">
            <i :class="expandedVideo === 'local' ? 'fas fa-compress' : 'fas fa-expand'"></i>
          </button>
        </div>
        <div class="video-box" :class="{ 'expanded': expandedVideo === 'remote' }" @click="toggleExpand('remote')">
          <video ref="remoteVideo" autoplay playsinline></video>
          <span class="video-label">Bệnh nhân</span>
          <button class="expand-btn" @click.stop="toggleExpand('remote')">
            <i :class="expandedVideo === 'remote' ? 'fas fa-compress' : 'fas fa-expand'"></i>
          </button>
        </div>
      </div>
      <div class="controls">
        <button class="btn btn-danger" @click="endCall">
          <i class="fas fa-phone-slash"></i> Kết thúc
        </button>
        <button class="btn btn-secondary" @click="toggleCamera">
          <i :class="cameraEnabled ? 'fas fa-video' : 'fas fa-video-slash'"></i>
          {{ cameraEnabled ? 'Tắt camera' : 'Bật camera' }}
        </button>
        <button class="btn btn-secondary" @click="toggleMic">
          <i :class="micEnabled ? 'fas fa-microphone' : 'fas fa-microphone-slash'"></i>
          {{ micEnabled ? 'Tắt mic' : 'Bật mic' }}
        </button>
      </div>
    </div>

    <div class="container-fluid">
      <div class="row">
        <!-- Sidebar -->
        <div class="col-md-3 col-lg-2 sidebar">
          <div class="d-flex flex-column p-3">
            <h4 class="sidebar-title mb-4">Quản lý tư vấn</h4>
            <div class="nav flex-column nav-pills">
              <button 
                class="nav-link mb-2" 
                :class="{ active: activeTab === 'upcoming' }"
                @click="activeTab = 'upcoming'"
              >
                <i class="fas fa-calendar-check me-2"></i>
                Cuộc hẹn sắp tới
              </button>
              <button 
                class="nav-link mb-2" 
                :class="{ active: activeTab === 'history' }"
                @click="activeTab = 'history'"
              >
                <i class="fas fa-history me-2"></i>
                Lịch sử tư vấn
              </button>
            </div>
          </div>
      </div>

        <!-- Main Content -->
        <div class="col-md-9 col-lg-10 main-content">
          <div class="container py-4">
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

            <!-- Upcoming Tab Content -->
            <div v-if="!loading && !error && activeTab === 'upcoming'">
      <!-- Next Consultation -->
              <div v-if="nextConsultation" class="next-consultation mb-5">
        <h3 class="mb-4">Cuộc tư vấn sắp tới</h3>
        <div class="card">
          <div class="card-body">
            <div class="row align-items-center">
              <div class="col-md-2">
                <img 
                  :src="nextConsultation.userId.avatar || '/images/default-avatar.jpg'" 
                  class="patient-avatar rounded-circle"
                  :alt="nextConsultation.userId.fullname"
                >
              </div>
              <div class="col-md-8">
                <h5 class="card-title">{{ nextConsultation.userId.fullname }}</h5>
                <p class="card-text text-muted">
                  <i class="fas fa-user me-2"></i>
                  {{ nextConsultation.userId.gender === 'male' ? 'Nam' : 'Nữ' }}, 
                  {{ nextConsultation.userId.age }} tuổi
                </p>
                <p class="card-text">
                  <i class="fas fa-phone me-2"></i>
                  {{ nextConsultation.userId.phone }}
                </p>
                <p class="card-text">
                  <i class="fas fa-calendar-alt me-2"></i>
                  {{ formatDate(nextConsultation.consultationDate) }}
                </p>
              </div>
              <div class="col-md-2 text-end">
                <button 
                  class="btn btn-primary" 
                  @click="startVideoCall(nextConsultation._id)"
                  :disabled="!isConsultationTime(nextConsultation.consultationDate)"
                >
                  <i class="fas fa-video"></i> Gọi video
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

              <!-- Upcoming Consultations List -->
              <div v-if="upcomingConsultations.length > 0" class="upcoming-list">
                <h3 class="mb-4">Danh sách tư vấn sắp tới</h3>
        <div class="row g-4">
          <div v-for="consultation in upcomingConsultations" :key="consultation._id" class="col-md-6">
            <div class="card h-100">
              <div class="card-body">
                <div class="row align-items-center">
                  <div class="col-md-3">
                    <img 
                      :src="consultation.userId.avatar || '/images/default-avatar.jpg'" 
                      class="patient-avatar rounded-circle"
                      :alt="consultation.userId.fullname"
                    >
                  </div>
                  <div class="col-md-9">
                    <h5 class="card-title">{{ consultation.userId.fullname }}</h5>
                    <p class="card-text text-muted">
                      <i class="fas fa-user me-2"></i>
                      {{ consultation.userId.gender === 'male' ? 'Nam' : 'Nữ' }}, 
                      {{ consultation.userId.age }} tuổi
                    </p>
                    <p class="card-text">
                      <i class="fas fa-phone me-2"></i>
                      {{ consultation.userId.phone }}
                    </p>
                    <p class="card-text">
                      <i class="fas fa-calendar-alt me-2"></i>
                      {{ formatDate(consultation.consultationDate) }}
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
              <div v-if="!nextConsultation && upcomingConsultations.length === 0" 
           class="text-center py-5">
                <h3>Bạn chưa có cuộc tư vấn nào sắp tới</h3>
        <p class="text-muted">Chưa có bệnh nhân nào đặt lịch tư vấn với bạn</p>
      </div>
    </div>

            <!-- History Tab Content -->
            <div v-if="!loading && !error && activeTab === 'history'">
              <h3 class="mb-4">Lịch sử tư vấn</h3>
              <div v-if="pastConsultations.length === 0" class="text-center py-5">
              <p class="text-muted">Chưa có cuộc tư vấn nào đã hoàn thành</p>
            </div>
            <div v-else class="row g-4">
              <div v-for="consultation in pastConsultations" :key="consultation._id" class="col-md-6">
                <div class="card h-100">
                  <div class="card-body">
                    <div class="row align-items-center">
                      <div class="col-md-3">
                        <img 
                          :src="consultation.userId.avatar || '/images/default-avatar.jpg'" 
                          class="patient-avatar rounded-circle"
                          :alt="consultation.userId.fullname"
                        >
                      </div>
                      <div class="col-md-9">
                        <h5 class="card-title">{{ consultation.userId.fullname }}</h5>
                        <p class="card-text text-muted">
                          <i class="fas fa-user me-2"></i>
                          {{ consultation.userId.gender === 'male' ? 'Nam' : 'Nữ' }}, 
                          {{ consultation.userId.age }} tuổi
                        </p>
                        <p class="card-text">
                          <i class="fas fa-phone me-2"></i>
                          {{ consultation.userId.phone }}
                        </p>
                        <p class="card-text">
                          <i class="fas fa-calendar-alt me-2"></i>
                          {{ formatDate(consultation.consultationDate) }}
                        </p>
                          <p class="card-text">
                            <i class="fas fa-clock me-2"></i>
                            Ngày tạo: {{ formatDate(consultation.createdAt) }}
                          </p>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue';
import { useToast } from 'primevue/usetoast';
import axios from '@/services/axiosInstance.js';
import { useRouter } from 'vue-router';
import socketService from '@/services/socketService';

const toast = useToast();
const router = useRouter();
const loading = ref(false);
const error = ref(null);
const nextConsultation = ref(null);
const upcomingConsultations = ref([]);
const pastConsultations = ref([]);
const activeTab = ref('upcoming');

// Video Call State
const showVideoCall = ref(false);
const localVideo = ref(null);
const remoteVideo = ref(null);
const cameraEnabled = ref(true);
const micEnabled = ref(true);
let localStream = null;
let peerConnection = null;
let currentConsultationId = null;
const expandedVideo = ref(null);

const loadConsultationHistory = async () => {
  try {
    loading.value = true;
    error.value = null;
    
    const response = await axios.get('/api/consultationList/doctor/history');
    
    if (response.data && response.data.success) {
      nextConsultation.value = response.data.data.nextConsultation;
      upcomingConsultations.value = response.data.data.upcomingConsultations;
      pastConsultations.value = response.data.data.pastConsultations;
    }
  } catch (err) {
    console.error('Error loading consultation history:', err);
    if (err.response?.status === 401) {
      error.value = 'Vui lòng đăng nhập để xem lịch sử tư vấn';
    } else {
      error.value = 'Không thể tải lịch sử tư vấn. Vui lòng thử lại sau.';
    }
  } finally {
    loading.value = false;
  }
};

const formatDate = (dateString) => {
  if (!dateString) return '';
  const date = new Date(dateString);
  return date.toLocaleString('vi-VN', {
    hour: '2-digit',
    minute: '2-digit',
    day: '2-digit',
    month: '2-digit',
    year: 'numeric'
  });
};

const isConsultationTime = (consultationDate) => {
  const now = new Date();
  const consultationTime = new Date(consultationDate);
  const timeDiff = consultationTime - now;
  return Math.abs(timeDiff) <= 15 * 60 * 1000;
};

const initializeCall = async (consultationId) => {
  try {
    console.log('=== INITIALIZING VIDEO CALL ===');
    console.log('Consultation ID:', consultationId);

    // Lấy stream từ camera và mic
    console.log('=== GETTING USER MEDIA ===');
    localStream = await navigator.mediaDevices.getUserMedia({ 
      video: true, 
      audio: true 
    });
    localVideo.value.srcObject = localStream;
    console.log('✅ Got local media stream');

    // Tạo peer connection
    console.log('=== CREATING PEER CONNECTION ===');
    peerConnection = new RTCPeerConnection({
      iceServers: [
        { urls: 'stun:stun.l.google.com:19302' }
      ]
    });
    console.log('✅ Peer connection created');

    // Thêm stream local vào peer connection
    console.log('=== ADDING LOCAL TRACKS ===');
    localStream.getTracks().forEach(track => {
      peerConnection.addTrack(track, localStream);
    });
    console.log('✅ Local tracks added');

    // Xử lý remote stream
    peerConnection.ontrack = event => {
      console.log('=== RECEIVED REMOTE TRACK ===');
      remoteVideo.value.srcObject = event.streams[0];
      console.log('✅ Remote stream set');
    };

    // Xử lý ICE candidate
    peerConnection.onicecandidate = event => {
      if (event.candidate) {
        console.log('=== VIDEO CALL ICE CANDIDATE ===');
        console.log('Consultation ID:', consultationId);
        console.log('Candidate:', event.candidate);
        socketService.emit('video_call_ice_candidate', {
          consultationId: consultationId,
          candidate: event.candidate
        });
        console.log('✅ ICE candidate sent');
      }
    };

    // Tham gia vào room video call
    console.log('=== JOINING VIDEO CALL ROOM ===');
    console.log('Consultation ID:', consultationId);
    socketService.emit('join_video_call', { 
      consultationId: consultationId 
    });
    console.log('✅ Joined video call room');

    // Lắng nghe các sự kiện từ socket
    console.log('=== SETTING UP SOCKET LISTENERS ===');
    socketService.on('participant_joined', handleParticipantJoined);
    socketService.on('participant_left', handleParticipantLeft);
    socketService.on('video_call_offer', handleOffer);
    socketService.on('video_call_answer', handleAnswer);
    socketService.on('video_call_ice_candidate', handleIceCandidate);
    socketService.on('video_call_ended', handleCallEnd);
    console.log('✅ Socket listeners set up');

    // Đợi offer từ user
    console.log('=== WAITING FOR PATIENT OFFER ===');
    toast.add({
      severity: 'info',
      summary: 'Đang chờ bệnh nhân',
      detail: 'Vui lòng đợi bệnh nhân tham gia cuộc gọi',
      life: 3000
    });
  } catch (error) {
    console.error('❌ Error initializing call:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể khởi tạo cuộc gọi video: ' + error.message,
      life: 3000
    });
    endCall();
  }
};

const handleParticipantJoined = (data) => {
  toast.add({
    severity: 'success',
    summary: 'Thông báo',
    detail: 'Bệnh nhân đã tham gia cuộc gọi',
    life: 3000
  });
};

const handleParticipantLeft = (data) => {
  toast.add({
    severity: 'warn',
    summary: 'Thông báo',
    detail: 'Bệnh nhân đã rời cuộc gọi',
    life: 3000
  });
  endCall();
};

const handleOffer = async (data) => {
  try {
    console.log('=== RECEIVED OFFER ===');
    console.log('Data:', data);
    
    console.log('=== SETTING REMOTE DESCRIPTION ===');
    await peerConnection.setRemoteDescription(new RTCSessionDescription(data.offer));
    console.log('✅ Remote description set');

    console.log('=== CREATING ANSWER ===');
    const answer = await peerConnection.createAnswer();
    console.log('✅ Answer created:', answer);

    console.log('=== SETTING LOCAL DESCRIPTION ===');
    await peerConnection.setLocalDescription(answer);
    console.log('✅ Local description set');

    console.log('=== SENDING ANSWER ===');
    socketService.emit('video_call_answer', {
      consultationId: currentConsultationId,
      answer: answer
    });
    console.log('✅ Answer sent');
  } catch (error) {
    console.error('❌ Error handling offer:', error);
  }
};

const handleAnswer = async (data) => {
  try {
    await peerConnection.setRemoteDescription(new RTCSessionDescription(data.answer));
  } catch (error) {
    console.error('Lỗi xử lý answer:', error);
  }
};

const handleIceCandidate = async (data) => {
  try {
    console.log('=== RECEIVED ICE CANDIDATE ===');
    console.log('Data:', data);
    await peerConnection.addIceCandidate(new RTCIceCandidate(data.candidate));
    console.log('✅ Đã thêm ICE candidate');
  } catch (error) {
    console.error('❌ Error handling ICE candidate:', error);
  }
};

const handleCallEnd = () => {
  endCall();
};

const endCall = () => {
  if (localStream) {
    localStream.getTracks().forEach(track => track.stop());
  }
  if (peerConnection) {
    peerConnection.close();
  }
  
  socketService.emit('leave_video_call', {
    consultationId: currentConsultationId
  });
  
  socketService.emit('video_call_end', {
    consultationId: currentConsultationId
  });
  
  showVideoCall.value = false;
  currentConsultationId = null;
};

const toggleCamera = () => {
  if (localStream) {
    const videoTrack = localStream.getVideoTracks()[0];
    videoTrack.enabled = !videoTrack.enabled;
    cameraEnabled.value = videoTrack.enabled;
  }
};

const toggleMic = () => {
  if (localStream) {
    const audioTrack = localStream.getAudioTracks()[0];
    audioTrack.enabled = !audioTrack.enabled;
    micEnabled.value = audioTrack.enabled;
  }
};

const startVideoCall = async (consultationId) => {
  try {
    console.log('=== DOCTOR STARTING VIDEO CALL ===');
    console.log('Consultation ID:', consultationId);
    
    if (!consultationId) {
      console.error('Consultation ID is undefined');
      toast.add({
        severity: 'error',
        summary: 'Lỗi',
        detail: 'Không tìm thấy ID cuộc hẹn',
        life: 3000
      });
      return;
    }
    
    // Kiểm tra thời gian cuộc hẹn
    const consultation = nextConsultation.value || upcomingConsultations.value.find(c => c._id === consultationId);
    if (!consultation) {
      console.error('Không tìm thấy thông tin cuộc hẹn');
      toast.add({
        severity: 'error',
        summary: 'Lỗi',
        detail: 'Không tìm thấy thông tin cuộc hẹn',
        life: 3000
      });
      return;
    }

    if (!isConsultationTime(consultation.consultationDate)) {
      console.error('Không đúng thời gian tư vấn');
      toast.add({
        severity: 'error',
        summary: 'Lỗi',
        detail: 'Chưa đến thời gian tư vấn hoặc đã quá thời gian cho phép',
        life: 3000
      });
      return;
    }

    currentConsultationId = consultationId;
    showVideoCall.value = true;
    await initializeCall(consultationId);
  } catch (error) {
    console.error('Lỗi khi bắt đầu cuộc gọi:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể bắt đầu cuộc gọi video',
      life: 3000
    });
  }
};

const toggleExpand = (video) => {
  if (expandedVideo.value === video) {
    expandedVideo.value = null;
  } else {
    expandedVideo.value = video;
  }
};

onMounted(() => {
  loadConsultationHistory();

  // Lắng nghe sự kiện participant_joined
  socketService.on('participant_joined', (data) => {
    console.log('=== PARTICIPANT JOINED ===');
    console.log('Data:', data);
  });

  // Lắng nghe sự kiện participant_left
  socketService.on('participant_left', (data) => {
    console.log('=== PARTICIPANT LEFT ===');
    console.log('Data:', data);
  });

  // Lắng nghe sự kiện video_call_offer
  socketService.on('video_call_offer', (data) => {
    console.log('=== RECEIVED VIDEO CALL OFFER ===');
    console.log('Data:', data);
  });

  // Lắng nghe sự kiện video_call_answer
  socketService.on('video_call_answer', (data) => {
    console.log('=== RECEIVED VIDEO CALL ANSWER ===');
    console.log('Data:', data);
  });

  // Lắng nghe sự kiện video_call_ice_candidate
  socketService.on('video_call_ice_candidate', (data) => {
    console.log('=== RECEIVED ICE CANDIDATE ===');
    console.log('Data:', data);
  });
});

onUnmounted(() => {
  if (localStream) {
    localStream.getTracks().forEach(track => track.stop());
  }
  if (peerConnection) {
    peerConnection.close();
  }
  if (currentConsultationId) {
    socketService.emit('leave_video_call', {
      consultationId: currentConsultationId
    });
  }
});
</script>

<style scoped>
.consultation-history-container {
  padding-top: 80px;
  background-color: #f8f9fa;
  min-height: 100vh;
}

.sidebar {
  background-color: white;
  border-right: 1px solid #dee2e6;
  min-height: calc(100vh - 80px);
  position: fixed;
  top: 80px;
  left: 0;
  width: 16.666667%;
  padding: 20px;
  z-index: 100;
}

.sidebar-title {
  color: #0d6efd;
  font-weight: 600;
}

.nav-link {
  color: #495057;
  border-radius: 8px;
  padding: 12px 16px;
  transition: all 0.3s ease;
}

.nav-link:hover {
  background-color: #e9ecef;
}

.nav-link.active {
  background-color: #0d6efd;
  color: white;
}

.main-content {
  margin-left: 16.666667%;
  padding: 20px;
  position: relative;
  z-index: 1;
  width: 83.333333%;
}

.patient-avatar {
  width: 100px;
  height: 100px;
  object-fit: cover;
}

.card {
  border: none;
  border-radius: 10px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  background-color: white;
  margin-bottom: 20px;
}

.card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
}

.next-consultation .card {
  background-color: #e3f2fd;
}

.video-call-modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: #000;
  color: white;
  z-index: 9999;
}

.video-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  padding: 20px;
  flex-grow: 1;
  height: calc(100vh - 100px);
  transition: all 0.3s ease;
}

.video-grid.expanded {
  grid-template-columns: 1fr;
}

.video-box {
  position: relative;
  background-color: #1a1a1a;
  border-radius: 10px;
  overflow: hidden;
  height: 100%;
  cursor: pointer;
  transition: all 0.3s ease;
}

.video-box.expanded {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  z-index: 10000;
  border-radius: 0;
}

.video-box video {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.video-label {
  position: absolute;
  bottom: 20px;
  left: 20px;
  background-color: rgba(0, 0, 0, 0.7);
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 500;
}

.controls {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 20px;
  padding: 20px;
  background-color: rgba(0, 0, 0, 0.8);
}

.controls button {
  padding: 12px 24px;
  border-radius: 50px;
  font-size: 1rem;
  border: none;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 8px;
}

.controls button:hover {
  transform: translateY(-2px);
}

.btn-danger {
  background-color: #dc3545;
  color: white;
}

.btn-secondary {
  background-color: rgba(255, 255, 255, 0.2);
  color: white;
}

.expand-btn {
  position: absolute;
  top: 20px;
  right: 20px;
  background: rgba(0, 0, 0, 0.5);
  border: none;
  color: white;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
}

.expand-btn:hover {
  background: rgba(0, 0, 0, 0.7);
  transform: scale(1.1);
}

.video-box.expanded .expand-btn {
  top: 30px;
  right: 30px;
  width: 50px;
  height: 50px;
  font-size: 1.2rem;
}

@media (max-width: 768px) {
  .sidebar {
    position: static;
    width: 100%;
    min-height: auto;
    border-right: none;
    border-bottom: 1px solid #dee2e6;
    padding: 15px;
  }

  .main-content {
    margin-left: 0;
    padding: 15px;
    width: 100%;
  }

  .patient-avatar {
    width: 80px;
    height: 80px;
  }

  .video-grid {
    grid-template-columns: 1fr;
    padding: 10px;
  }

  .controls {
    padding: 15px;
    gap: 10px;
  }

  .controls button {
    padding: 10px 20px;
    font-size: 0.9rem;
  }
}
</style> 