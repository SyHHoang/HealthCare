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

      <!-- Chat Panel -->
      <div class="chat-panel" :class="{ 'expanded': showChat }">
        <div class="chat-header">
          <h5>Chat</h5>
          <button class="close-btn" @click="toggleChat">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="chat-messages" ref="chatMessages">
          <div v-for="(message, index) in callMessages" :key="index" 
               :class="['message', message.sender === 'me' ? 'sent' : 'received']">
            <div class="message-content">
              {{ message.text }}
            </div>
            <div class="message-time">
              {{ formatMessageTime(message.timestamp) }}
            </div>
          </div>
        </div>
        <div class="chat-input">
          <input type="text" v-model="newMessage" @keyup.enter="sendCallMessage" 
                 placeholder="Nhập tin nhắn...">
          <button @click="sendCallMessage">
            <i class="fas fa-paper-plane"></i>
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
        <button class="btn btn-secondary" @click="toggleScreenShare">
          <i :class="isScreenSharing ? 'fas fa-stop-circle' : 'fas fa-desktop'"></i>
          {{ isScreenSharing ? 'Dừng chia sẻ' : 'Chia sẻ màn hình' }}
        </button>
        <button class="btn btn-secondary" @click="toggleRecording">
          <i :class="isRecording ? 'fas fa-stop-circle' : 'fas fa-record-vinyl'"></i>
          {{ isRecording ? 'Dừng ghi âm' : 'Ghi âm' }}
        </button>
        <button class="btn btn-secondary" @click="toggleChat">
          <i class="fas fa-comments"></i>
          Chat
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
import { ref, onMounted, onUnmounted, nextTick } from 'vue';
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
const isFirstParticipant = ref(false);

// New refs for additional features
const isScreenSharing = ref(false);
const isRecording = ref(false);
const showChat = ref(false);
const callMessages = ref([]);
const newMessage = ref('');
const chatMessages = ref(null);
let mediaRecorder = null;
let screenStream = null;

// Video quality constraints
const videoConstraints = {
  video: {
    width: { ideal: 1280 },
    height: { ideal: 720 },
    frameRate: { ideal: 30 }
  },
  audio: {
    echoCancellation: true,
    noiseSuppression: true
  }
};

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
  return Math.abs(timeDiff) <= 30 * 60 * 1000;
};

const initializeCall = async (consultationId) => {
  try {
    console.log('=== INITIALIZING VIDEO CALL ===');
    console.log('Consultation ID:', consultationId);

    // Get media with improved quality
    localStream = await navigator.mediaDevices.getUserMedia(videoConstraints);
    localVideo.value.srcObject = localStream;

    // Create peer connection with better configuration
    peerConnection = new RTCPeerConnection({
      iceServers: [
        { urls: 'stun:stun.l.google.com:19302' },
        { urls: 'stun:stun1.l.google.com:19302' },
        { urls: 'stun:stun2.l.google.com:19302' }
      ],
      iceCandidatePoolSize: 10
    });

    // Add connection state change handler
    peerConnection.onconnectionstatechange = () => {
      if (peerConnection.connectionState === 'disconnected') {
        handleDisconnection();
      }
    };

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
          console.log('Is first participant:', response.isFirstParticipant);
          
          isFirstParticipant.value = response.isFirstParticipant;
          
          // Không gửi offer ngay lập tức, đợi người thứ 2 tham gia
          toast.add({
            severity: 'success',
            summary: 'Thành công',
            detail: 'Đã tham gia phòng video call',
            life: 3000
          });
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
    console.log('=== SETTING UP SOCKET LISTENERS ===');
    socketService.on('participant_joined', handleParticipantJoined);
    socketService.on('participant_left', handleParticipantLeft);
    socketService.on('video_call_offer', handleOffer);
    socketService.on('video_call_answer', handleAnswer);
    socketService.on('video_call_ice_candidate', handleIceCandidate);
    socketService.on('video_call_ended', handleCallEnd);
    console.log('✅ Socket listeners set up');
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
  console.log('=== PARTICIPANT JOINED ===');
  console.log('Data:', data);
  
  // Nếu là người đầu tiên và có người thứ 2 tham gia, tạo và gửi offer
  if (isFirstParticipant.value) {
    console.log('First participant detected, creating and sending offer...');
    // Đợi một chút để đảm bảo peer connection đã sẵn sàng
    setTimeout(() => {
      createAndSendOffer(currentConsultationId);
    }, 1000);
  }
  
  toast.add({
    severity: 'success',
    summary: 'Thông báo',
    detail: 'Bệnh nhân đã tham gia cuộc gọi',
    life: 3000
  });
};

const createAndSendOffer = async (consultationId) => {
  try {
    console.log('=== CREATING AND SENDING OFFER ===');
    console.log('Consultation ID:', consultationId);

    // Kiểm tra và tạo mới peer connection nếu cần
    if (!peerConnection || peerConnection.connectionState === 'closed') {
      console.log('Creating new peer connection...');
      peerConnection = new RTCPeerConnection({
        iceServers: [
          { urls: 'stun:stun.l.google.com:19302' },
          { urls: 'stun:stun1.l.google.com:19302' },
          { urls: 'stun:stun2.l.google.com:19302' }
        ],
        iceCandidatePoolSize: 10
      });

      // Thêm các event handlers
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

      peerConnection.ontrack = event => {
        console.log('=== RECEIVED REMOTE TRACK ===');
        remoteVideo.value.srcObject = event.streams[0];
        console.log('✅ Remote stream set');
      };

      // Thêm local stream vào peer connection
      if (localStream) {
        localStream.getTracks().forEach(track => {
          peerConnection.addTrack(track, localStream);
        });
        console.log('✅ Local tracks added to new peer connection');
      }
    }

    // Tạo offer
    const offer = await peerConnection.createOffer();
    console.log('✅ Offer created');

    // Set local description
    await peerConnection.setLocalDescription(offer);
    console.log('✅ Local description set');

    // Gửi offer
    socketService.emit('video_call_offer', {
      consultationId: consultationId,
      offer: offer
    });
    console.log('✅ Offer sent');

    toast.add({
      severity: 'info',
      summary: 'Đang chờ bệnh nhân',
      detail: 'Vui lòng đợi bệnh nhân chấp nhận cuộc gọi',
      life: 3000
    });
  } catch (error) {
    console.error('❌ Error creating and sending offer:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể tạo cuộc gọi: ' + error.message,
      life: 3000
    });
    endCall();
  }
};

const handleParticipantLeft = (data) => {
  console.log('=== PARTICIPANT LEFT ===');
  console.log('Data:', data);
  
  // Tự động thoát khi người kia rời đi
  endCall();
  
  toast.add({
    severity: 'warn',
    summary: 'Thông báo',
    detail: 'Bệnh nhân đã rời cuộc gọi',
    life: 3000
  });
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
  console.log('=== ENDING CALL ===');
  console.log('Consultation ID:', currentConsultationId);
  
  // Stop recording if active
  if (isRecording.value) {
    stopRecording();
  }
  
  // Stop screen sharing if active
  if (isScreenSharing.value) {
    stopScreenShare();
  }
  
  // Stop local stream
  if (localStream) {
    localStream.getTracks().forEach(track => track.stop());
    localStream = null;
  }
  
  // Close peer connection
  if (peerConnection) {
    // Đóng tất cả các kết nối
    peerConnection.close();
    // Reset peer connection
    peerConnection = null;
  }
  
  // Emit leave events
  if (currentConsultationId) {
    socketService.emit('leave_video_call', {
      consultationId: currentConsultationId
    });
    
    socketService.emit('video_call_end', {
      consultationId: currentConsultationId
    });
    
    // Xóa tất cả listeners liên quan đến video call
    socketService.off('participant_joined');
    socketService.off('participant_left');
    socketService.off('video_call_offer');
    socketService.off('video_call_answer');
    socketService.off('video_call_ice_candidate');
    socketService.off('video_call_ended');
    socketService.off('call_message');
  }
  
  // Reset state
  showVideoCall.value = false;
  currentConsultationId = null;
  isScreenSharing.value = false;
  isRecording.value = false;
  showChat.value = false;
  callMessages.value = [];
  newMessage.value = '';
  expandedVideo.value = null;
  isFirstParticipant.value = false;
  
  console.log('=== CALL ENDED ===');
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

    // Đảm bảo peer connection đã được reset
    if (peerConnection) {
      peerConnection.close();
      peerConnection = null;
    }

    // Reset các trạng thái
    if (localStream) {
      localStream.getTracks().forEach(track => track.stop());
      localStream = null;
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
    // Đảm bảo reset state nếu có lỗi
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

// Screen sharing
const toggleScreenShare = async () => {
  try {
    if (!isScreenSharing.value) {
      screenStream = await navigator.mediaDevices.getDisplayMedia({
        video: true
      });
      const screenTrack = screenStream.getVideoTracks()[0];
      
      // Replace video track
      const sender = peerConnection.getSenders().find(s => s.track.kind === 'video');
      if (sender) {
        sender.replaceTrack(screenTrack);
      } else {
        peerConnection.addTrack(screenTrack, screenStream);
      }
      
      isScreenSharing.value = true;
      
      // Handle when user stops sharing
      screenTrack.onended = () => {
        stopScreenShare();
      };
    } else {
      stopScreenShare();
    }
  } catch (error) {
    console.error('Error toggling screen share:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể chia sẻ màn hình: ' + error.message,
      life: 3000
    });
  }
};

const stopScreenShare = () => {
  if (screenStream) {
    screenStream.getTracks().forEach(track => track.stop());
    screenStream = null;
  }
  isScreenSharing.value = false;
  
  // Restore camera video
  if (localStream) {
    const videoTrack = localStream.getVideoTracks()[0];
    const sender = peerConnection.getSenders().find(s => s.track.kind === 'video');
    if (sender) {
      sender.replaceTrack(videoTrack);
    }
  }
};

// Recording
const toggleRecording = () => {
  if (!isRecording.value) {
    startRecording();
  } else {
    stopRecording();
  }
};

const startRecording = () => {
  try {
    const stream = remoteVideo.value.srcObject;
    mediaRecorder = new MediaRecorder(stream, {
      mimeType: 'video/webm;codecs=vp8,opus'
    });
    
    const chunks = [];
    mediaRecorder.ondataavailable = (e) => {
      if (e.data.size > 0) {
        chunks.push(e.data);
      }
    };
    
    mediaRecorder.onstop = async () => {
      const blob = new Blob(chunks, { type: 'video/webm' });
      const url = URL.createObjectURL(blob);
      
      // Save recording
      const a = document.createElement('a');
      a.href = url;
      a.download = `call-recording-${new Date().toISOString()}.webm`;
      a.click();
      
      // Log recording
      await logCallRecording(currentConsultationId, blob);
    };
    
    mediaRecorder.start();
    isRecording.value = true;
    
    toast.add({
      severity: 'info',
      summary: 'Thông báo',
      detail: 'Đang ghi âm cuộc gọi',
      life: 3000
    });
  } catch (error) {
    console.error('Error starting recording:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể bắt đầu ghi âm: ' + error.message,
      life: 3000
    });
  }
};

const stopRecording = () => {
  if (mediaRecorder && mediaRecorder.state !== 'inactive') {
    mediaRecorder.stop();
    isRecording.value = false;
    
    toast.add({
      severity: 'success',
      summary: 'Thông báo',
      detail: 'Đã dừng ghi âm',
      life: 3000
    });
  }
};

// Chat functionality
const toggleChat = () => {
  showChat.value = !showChat.value;
};

const sendCallMessage = () => {
  if (!newMessage.value.trim()) return;
  
  const message = {
    text: newMessage.value,
    sender: 'me',
    timestamp: new Date()
  };
  
  callMessages.value.push(message);
  socketService.emit('call_message', {
    consultationId: currentConsultationId,
    message: newMessage.value,
    timestamp: message.timestamp
  });
  
  newMessage.value = '';
  scrollToBottom();
};

const scrollToBottom = async () => {
  await nextTick();
  if (chatMessages.value) {
    chatMessages.value.scrollTop = chatMessages.value.scrollHeight;
  }
};

const formatMessageTime = (timestamp) => {
  return new Date(timestamp).toLocaleTimeString('vi-VN', {
    hour: '2-digit',
    minute: '2-digit'
  });
};

// Handle disconnection
const handleDisconnection = async () => {
  toast.add({
    severity: 'warn',
    summary: 'Cảnh báo',
    detail: 'Mất kết nối. Đang thử kết nối lại...',
    life: 3000
  });
  
  try {
    // Try to reconnect
    await reconnectCall();
  } catch (error) {
    console.error('Reconnection failed:', error);
    endCall();
  }
};

const reconnectCall = async () => {
  if (!peerConnection || peerConnection.connectionState === 'connected') return;
  
  try {
    // Create new offer
    const offer = await peerConnection.createOffer();
    await peerConnection.setLocalDescription(offer);
    
    // Send offer through signaling
    socketService.emit('video_call_offer', {
      consultationId: currentConsultationId,
      offer: offer
    });
  } catch (error) {
    console.error('Error during reconnection:', error);
    throw error;
  }
};

// Log call recording
const logCallRecording = async (consultationId, recordingBlob) => {
  try {
    const formData = new FormData();
    formData.append('recording', recordingBlob);
    formData.append('consultationId', consultationId);
    
    await axios.post('/api/video-call/log-recording', formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    });
  } catch (error) {
    console.error('Error logging recording:', error);
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

  // New socket listeners
  socketService.on('call_message', (data) => {
    callMessages.value.push({
      text: data.message,
      sender: 'other',
      timestamp: data.timestamp
    });
    scrollToBottom();
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
  if (screenStream) {
    screenStream.getTracks().forEach(track => track.stop());
  }
  if (mediaRecorder && mediaRecorder.state !== 'inactive') {
    mediaRecorder.stop();
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

/* New styles for additional features */
.chat-panel {
  position: fixed;
  right: -300px;
  top: 0;
  width: 300px;
  height: 100vh;
  background-color: white;
  box-shadow: -2px 0 5px rgba(0, 0, 0, 0.1);
  transition: right 0.3s ease;
  z-index: 1000;
}

.chat-panel.expanded {
  right: 0;
}

.chat-header {
  padding: 15px;
  background-color: #f8f9fa;
  border-bottom: 1px solid #dee2e6;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.chat-messages {
  height: calc(100vh - 130px);
  overflow-y: auto;
  padding: 15px;
}

.message {
  margin-bottom: 15px;
  max-width: 80%;
}

.message.sent {
  margin-left: auto;
}

.message.received {
  margin-right: auto;
}

.message-content {
  padding: 10px;
  border-radius: 10px;
  background-color: #e9ecef;
}

.message.sent .message-content {
  background-color: #0d6efd;
  color: white;
}

.message-time {
  font-size: 0.8rem;
  color: #6c757d;
  margin-top: 5px;
}

.chat-input {
  padding: 15px;
  border-top: 1px solid #dee2e6;
  display: flex;
  gap: 10px;
}

.chat-input input {
  flex: 1;
  padding: 8px;
  border: 1px solid #dee2e6;
  border-radius: 4px;
}

.chat-input button {
  padding: 8px 15px;
  background-color: #0d6efd;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.chat-input button:hover {
  background-color: #0b5ed7;
}

.close-btn {
  background: none;
  border: none;
  color: #6c757d;
  cursor: pointer;
}

.close-btn:hover {
  color: #0d6efd;
}

/* Responsive styles */
@media (max-width: 768px) {
  .chat-panel {
    width: 100%;
    right: -100%;
  }
  
  .controls {
    flex-wrap: wrap;
  }
  
  .controls button {
    flex: 1 1 calc(50% - 10px);
  }
}
</style> 