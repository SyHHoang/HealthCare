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
          <span class="video-label">Bác sĩ</span>
          <button class="expand-btn" @click.stop="toggleExpand('remote')">
            <i :class="expandedVideo === 'remote' ? 'fas fa-compress' : 'fas fa-expand'"></i>
          </button>
        </div>
      </div>
      <div class="controls">
        <div class="timer" :class="{ 'warning': remainingTime <= 300 }">
          Thời gian còn lại: {{ formatTime(remainingTime) }}
        </div>
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
                <i class="bi bi-calendar-check me-2"></i>
                Cuộc hẹn sắp tới
              </button>
              <button 
                class="nav-link mb-2" 
                :class="{ active: activeTab === 'history' }"
                @click="activeTab = 'history'"
              >
                <i class="bi bi-clock-history me-2"></i>
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
              <div v-if="validUpcomingConsultations.length > 0" class="upcoming-list">
                <h3 class="mb-4">Danh sách cuộc hẹn còn hiệu lực</h3>
                <div class="row g-4">
                  <div v-for="consultation in validUpcomingConsultations" :key="consultation._id" class="col-md-6">
                    <div class="card h-100">
                      <div class="card-body">
                        <div class="row align-items-center">
                          <div class="col-md-3">
                            <img 
                              :src="consultation.doctorId.avatar || '/images/default-doctor.jpg'" 
                              class="doctor-avatar rounded-circle"
                              :alt="consultation.doctorId.fullName"
                            >
                          </div>
                          <div class="col-md-9">
                            <h5 class="card-title">{{ consultation.doctorId.fullName }}</h5>
                            <p class="card-text text-muted">
                              <i class="bi bi-stethoscope me-2"></i>
                              {{ consultation.doctorId.specialty }}
                            </p>
                            <p class="card-text">
                              <i class="bi bi-calendar-event me-2"></i>
                              {{ formatDate(consultation.consultationDate) }}
                            </p>
                            <div class="d-flex justify-content-end">
                              <button 
                                class="btn btn-primary" 
                                @click="startVideoCall(consultation._id)"
                                :disabled="!isConsultationTime(consultation.consultationDate)"
                              >
                                <i class="bi bi-camera-video"></i> Gọi video
                              </button>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div v-else class="text-center py-5">
                <h3>Không có cuộc hẹn nào còn hiệu lực</h3>
                <p class="text-muted">Bạn chưa có cuộc hẹn nào đang còn hiệu lực</p>
                <router-link to="/doctors" class="btn btn-primary mt-3">
                  Tìm kiếm bác sĩ
                </router-link>
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
                            :src="consultation.doctorId?.avatar || '/images/default-doctor.jpg'" 
                            class="doctor-avatar rounded-circle"
                            :alt="consultation.doctorId?.fullName || 'Bác sĩ'"
                          >
                        </div>
                        <div class="col-md-9">
                          <h5 class="card-title">{{ consultation.doctorId?.fullName || 'Bác sĩ' }}</h5>
                          <p class="card-text text-muted">
                            <i class="bi bi-stethoscope me-2"></i>
                            {{ consultation.doctorId?.specialty || 'Chuyên khoa' }}
                          </p>
                          <p class="card-text">
                            <i class="bi bi-calendar-event me-2"></i>
                            {{ formatDate(consultation.consultationDate) }}
                          </p>
                          <p class="card-text">
                            <i class="bi bi-clock me-2"></i>
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
import { ref, onMounted, onUnmounted, computed } from 'vue';
import { useToast } from 'primevue/usetoast';
import axiosInstance from '@/services/axiosInstance.js';
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
const isFirstParticipant = ref(false);
const remainingTime = ref(1800); // 30 minutes in seconds

const validUpcomingConsultations = computed(() => {
  const now = new Date();
  return upcomingConsultations.value.filter(consultation => {
    const consultationDate = new Date(consultation.consultationDate);
    const endTime = new Date(consultationDate.getTime() + 30 * 60 * 1000); // Thêm 30 phút
    return now < endTime;
  });
});

const loadConsultationHistory = async () => {
  try {
    loading.value = true;
    error.value = null;
    
    const response = await axiosInstance.get('/api/consultationList/history');
    console.log("API Response:", response.data);
    
    if (response.data && response.data.success) {
      nextConsultation.value = response.data.data.nextConsultation || null;
      upcomingConsultations.value = response.data.data.upcomingConsultations || [];
      pastConsultations.value = response.data.data.pastConsultations || [];
    } else {
      error.value = 'Không thể lấy dữ liệu lịch sử tư vấn';
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

const formatCountdown = (dateString) => {
  const now = new Date();
  const target = new Date(dateString);
  const diff = target - now;

  if (diff <= 0) return 'Đã đến giờ';

  const days = Math.floor(diff / (1000 * 60 * 60 * 24));
  const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
  const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));

  let result = '';
  if (days > 0) result += `${days} ngày `;
  if (hours > 0) result += `${hours} giờ `;
  if (minutes > 0) result += `${minutes} phút`;

  return result.trim();
};

const isConsultationTime = (consultationDate) => {
  const now = new Date();
  const consultationTime = new Date(consultationDate);
  const timeDiff = consultationTime - now;
  console.log('=== CHECKING CONSULTATION TIME ===');
  console.log('Current time:', now.toLocaleString());
  console.log('Consultation time:', consultationTime.toLocaleString());
  console.log('Time difference (minutes):', timeDiff / (1000 * 60));
  console.log('Is within 15 minutes:', Math.abs(timeDiff) <= 15 * 60 * 1000);
  return Math.abs(timeDiff) <= 5 * 60 * 1000; // Cho phép vào trước 15 phút
};

const formatTime = (seconds) => {
  const minutes = Math.floor(seconds / 60);
  const remainingSeconds = seconds % 60;
  return `${minutes.toString().padStart(2, '0')}:${remainingSeconds.toString().padStart(2, '0')}`;
};

const handleParticipantJoined = (data) => {
  console.log('=== PARTICIPANT JOINED ===');
  console.log('Data:', data);
  
  // Nếu là người gọi đầu tiên, đợi người nhận tham gia rồi mới gửi offer
  if (isFirstParticipant.value) {
    console.log('First participant, waiting for receiver to join...');
    // Đợi 1 giây để đảm bảo người nhận đã sẵn sàng
    setTimeout(() => {
      createAndSendOffer(currentConsultationId);
    }, 1000);
  }
  
  toast.add({
    severity: 'success',
    summary: 'Thông báo',
    detail: 'Bác sĩ đã tham gia cuộc gọi',
    life: 3000
  });
};

const handleParticipantLeft = (data) => {
  console.log('=== PARTICIPANT LEFT ===');
  console.log('Data:', data);
  toast.add({
    severity: 'warn',
    summary: 'Thông báo',
    detail: 'Bác sĩ đã rời cuộc gọi',
    life: 3000
  });
  endCall();
};

const handleCallEnd = () => {
  console.log('=== CALL ENDED ===');
  endCall();
};

const endCall = () => {
  console.log('=== ENDING CALL ===');
  
  // Stop local stream
  if (localStream) {
    console.log('Stopping local stream...');
    localStream.getTracks().forEach(track => track.stop());
    localStream = null;
  }

  // Close peer connection
  if (peerConnection) {
    console.log('Closing peer connection...');
    peerConnection.close();
    peerConnection = null;
  }

  // Remove socket listeners
  console.log('Removing socket listeners...');
  socketService.socket.off('participant_joined', handleParticipantJoined);
  socketService.socket.off('participant_left', handleParticipantLeft);
  socketService.socket.off('video_call_offer', handleOffer);
  socketService.socket.off('video_call_answer', handleAnswer);
  socketService.socket.off('video_call_ice_candidate', handleIceCandidate);
  socketService.socket.off('video_call_ended', handleCallEnd);

  // Emit leave events
  if (currentConsultationId) {
    console.log('Emitting leave events...');
    socketService.socket.emit('leave_video_call', {
      consultationId: currentConsultationId
    });
    
    socketService.socket.emit('video_call_end', {
      consultationId: currentConsultationId
    });
  }

  // Reset state
  console.log('Resetting state...');
  showVideoCall.value = false;
  currentConsultationId = null;
  isFirstParticipant.value = false;
  expandedVideo.value = null;
  cameraEnabled.value = true;
  micEnabled.value = true;
  remainingTime.value = 1800;

  console.log('=== CALL ENDED SUCCESSFULLY ===');
};

const toggleCamera = () => {
  if (localStream) {
    const videoTrack = localStream.getVideoTracks()[0];
    videoTrack.enabled = !videoTrack.enabled;
    cameraEnabled.value = videoTrack.enabled;
    console.log('Camera ' + (cameraEnabled.value ? 'enabled' : 'disabled'));
  }
};

const toggleMic = () => {
  if (localStream) {
    const audioTrack = localStream.getAudioTracks()[0];
    audioTrack.enabled = !audioTrack.enabled;
    micEnabled.value = audioTrack.enabled;
    console.log('Microphone ' + (micEnabled.value ? 'enabled' : 'disabled'));
  }
};

const startVideoCall = async (consultationId) => {
  try {
    console.log('=== USER STARTING VIDEO CALL ===');
    console.log('Consultation ID:', consultationId);
    console.log('Next Consultation:', JSON.stringify(nextConsultation.value, null, 2));
    console.log('Upcoming Consultations:', JSON.stringify(upcomingConsultations.value, null, 2));
    
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
    const consultation = upcomingConsultations.value.find(c => c._id === consultationId);
    console.log('Found Consultation:', JSON.stringify(consultation, null, 2));
    
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

    console.log('Consultation Date:', consultation.consultationDate);
    console.log('Is Consultation Time:', isConsultationTime(consultation.consultationDate));
    console.log('Current Time:', new Date().toLocaleString());
    console.log('Consultation Time:', new Date(consultation.consultationDate).toLocaleString());
    console.log('Time Difference (minutes):', Math.abs(new Date(consultation.consultationDate) - new Date()) / (1000 * 60));

    // Kiểm tra thời gian
    const now = new Date();
    const consultationTime = new Date(consultation.consultationDate);
    const timeDiff = consultationTime - now;
    const minutesDiff = Math.abs(timeDiff) / (1000 * 60);

    if (minutesDiff > 15) {
      console.error('Không đúng thời gian tư vấn');
      toast.add({
        severity: 'error',
        summary: 'Lỗi',
        detail: `Chưa đến thời gian tư vấn hoặc đã quá thời gian cho phép. Thời gian chênh lệch: ${Math.round(minutesDiff)} phút`,
        life: 3000
      });
      return;
    }

    // Đảm bảo cleanup trước khi bắt đầu cuộc gọi mới
    endCall();

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
    endCall();
  }
};

const toggleExpand = (video) => {
  if (expandedVideo.value === video) {
    expandedVideo.value = null;
  } else {
    expandedVideo.value = video;
  }
};

const handleOffer = async (data) => {
  try {
    console.log('=== HANDLING OFFER ===');
    console.log('From:', data.from);
    console.log('Role:', data.role);
    
    if (!peerConnection) {
      console.error('❌ No peer connection available');
      return;
    }

    // Set remote description
    await peerConnection.setRemoteDescription(new RTCSessionDescription(data.offer));
    console.log('✅ Remote description set');

    // Create and send answer
    const answer = await peerConnection.createAnswer();
    await peerConnection.setLocalDescription(answer);
    console.log('✅ Local description set');

    // Send answer
    socketService.socket.emit('video_call_answer', {
      consultationId: currentConsultationId,
      answer: answer
    });
    console.log('✅ Answer sent');
  } catch (error) {
    console.error('❌ Error handling offer:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể xử lý yêu cầu kết nối: ' + error.message,
      life: 3000
    });
  }
};

const handleAnswer = async (data) => {
  try {
    console.log('=== HANDLING ANSWER ===');
    console.log('From:', data.from);
    console.log('Role:', data.role);
    
    if (!peerConnection) {
      console.error('❌ No peer connection available');
      return;
    }

    // Set remote description
    await peerConnection.setRemoteDescription(new RTCSessionDescription(data.answer));
    console.log('✅ Remote description set');
  } catch (error) {
    console.error('❌ Error handling answer:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể xử lý phản hồi kết nối: ' + error.message,
      life: 3000
    });
  }
};

const handleIceCandidate = async (data) => {
  try {
    console.log('=== HANDLING ICE CANDIDATE ===');
    console.log('From:', data.from);
    console.log('Role:', data.role);
    
    if (!peerConnection) {
      console.error('❌ No peer connection available');
      return;
    }

    // Add ICE candidate
    await peerConnection.addIceCandidate(new RTCIceCandidate(data.candidate));
    console.log('✅ ICE candidate added');
  } catch (error) {
    console.error('❌ Error handling ICE candidate:', error);
  }
};

const createAndSendOffer = async (consultationId) => {
  try {
    console.log('=== CREATING AND SENDING OFFER ===');
    console.log('Consultation ID:', consultationId);
    
    if (!peerConnection) {
      console.error('❌ No peer connection available');
      return;
    }

    // Create offer
    const offer = await peerConnection.createOffer();
    await peerConnection.setLocalDescription(offer);
    console.log('✅ Local description set');

    // Send offer
    socketService.socket.emit('video_call_offer', {
      consultationId: consultationId,
      offer: offer
    });
    console.log('✅ Offer sent');
  } catch (error) {
    console.error('❌ Error creating and sending offer:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể tạo yêu cầu kết nối: ' + error.message,
      life: 3000
    });
  }
};

const startHeartbeat = () => {
  console.log('=== STARTING HEARTBEAT ===');
  const heartbeatInterval = setInterval(() => {
    console.log('Sending heartbeat...');
    socketService.socket.emit('heartbeat', {
      consultationId: currentConsultationId.value
    });
  }, 3000); // Gửi mỗi 3 giây

  // Lưu interval để cleanup
  onUnmounted(() => {
    console.log('=== CLEANING UP HEARTBEAT ===');
    clearInterval(heartbeatInterval);
  });
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
        socketService.socket.emit('video_call_ice_candidate', {
          consultationId: consultationId,
          candidate: event.candidate
        });
        console.log('✅ ICE candidate sent');
      }
    };

    // Tham gia vào room video call
    console.log('=== JOINING VIDEO CALL ROOM ===');
    console.log('Consultation ID:', consultationId);
    console.log('Socket connected:', socketService.socket.connected);

    try {
      // Thêm timeout để kiểm tra callback
      const timeout = setTimeout(() => {
        console.log('❌ Callback timeout - not called within 5 seconds');
        toast.add({
          severity: 'error',
          summary: 'Lỗi',
          detail: 'Không nhận được phản hồi từ server',
          life: 3000
        });
        endCall();
      }, 5000);

      // Gửi sự kiện join_video_call với callback
      console.log('Emitting join_video_call event...');
      socketService.socket.emit('join_video_call', { 
        consultationId: consultationId 
      }, (response) => {
        clearTimeout(timeout);
        console.log('=== CALLBACK EXECUTED ===');
        console.log('Response:', response);
        
        if (!response) {
          console.error('❌ No response received from server');
          toast.add({
            severity: 'error',
            summary: 'Lỗi',
            detail: 'Không nhận được phản hồi từ server',
            life: 3000
          });
          endCall();
          return;
        }

        if (response.success) {
          console.log('✅ Joined video call room successfully');
          console.log('Room ID:', response.roomId);
          console.log('Participants:', response.participants);
          console.log("Response Data:", response.data);
          
          isFirstParticipant.value = response.isFirstParticipant;
          console.log('Is first participant:', isFirstParticipant.value);
          
          // Bắt đầu gửi heartbeat sau khi join thành công
          startHeartbeat();
        } else {
          console.error('❌ Failed to join video call room');
          console.error('Error:', response.message);
          
          toast.add({
            severity: 'error', 
            summary: 'Lỗi',
            detail: response.message || 'Không thể tham gia phòng video call',
            life: 3000
          });
          
          endCall();
        }
      });

      // Thêm listener cho sự kiện error
      socketService.socket.on('error', (error) => {
        console.error('Socket error:', error);
        clearTimeout(timeout);
        toast.add({
          severity: 'error',
          summary: 'Lỗi',
          detail: error.message || 'Lỗi kết nối',
          life: 3000
        });
        endCall();
      });

    } catch (error) {
      console.error('❌ Error joining video call:', error);
      toast.add({
        severity: 'error',
        summary: 'Lỗi',
        detail: 'Không thể tham gia phòng video call: ' + error.message,
        life: 3000
      });
      endCall();
    }

    // Lắng nghe các sự kiện từ socket
    socketService.socket.on('participant_joined', handleParticipantJoined);
    socketService.socket.on('participant_left', handleParticipantLeft);
    socketService.socket.on('video_call_offer', handleOffer);
    socketService.socket.on('video_call_answer', handleAnswer);
    socketService.socket.on('video_call_ice_candidate', handleIceCandidate);
    socketService.socket.on('video_call_ended', handleCallEnd);
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

onMounted(() => {
  loadConsultationHistory();
  // Không cần lắng nghe các sự kiện socket ở đây vì chúng sẽ được xử lý trong VideoCall component
});

onUnmounted(() => {
  if (localStream) {
    localStream.getTracks().forEach(track => track.stop());
  }
  if (peerConnection) {
    peerConnection.close();
  }
  if (currentConsultationId) {
    socketService.socket.emit('leave_video_call', {
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

.doctor-avatar {
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

.countdown {
  margin-top: 10px;
}

.countdown .badge {
  font-size: 1rem;
  padding: 8px 16px;
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

.timer {
  font-size: 1.2rem;
  font-weight: bold;
  padding: 12px 24px;
  border-radius: 50px;
  background-color: rgba(40, 167, 69, 0.9);
  color: white;
}

.timer.warning {
  background-color: rgba(255, 193, 7, 0.9);
  color: black;
  animation: pulse 1s infinite;
}

@keyframes pulse {
  0% { opacity: 1; }
  50% { opacity: 0.5; }
  100% { opacity: 1; }
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

  .doctor-avatar {
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

  .timer {
    font-size: 1rem;
    padding: 10px 20px;
  }
}
</style> 