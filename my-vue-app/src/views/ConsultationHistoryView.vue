const showVideoCall = ref(false);
const localVideo = ref(null);
const remoteVideo = ref(null);
const cameraEnabled = ref(true);
const micEnabled = ref(true);
let localStream = null;
let peerConnection = null;
let currentConsultationId = null;
const expandedVideo = ref(null);

const startTimer = () => {
  // Xóa hàm này
};

const initializeCall = async (consultationId) => {
  try {
    console.log('=== INITIALIZING VIDEO CALL ===');
    console.log('Consultation ID:', consultationId);

    // Lấy stream từ camera và mic
    localStream = await navigator.mediaDevices.getUserMedia({ 
      video: true, 
      audio: true 
    });
    localVideo.value.srcObject = localStream;

    // Tạo peer connection
    peerConnection = new RTCPeerConnection({
      iceServers: [
        { urls: 'stun:stun.l.google.com:19302' }
      ]
    });

    // Thêm stream local vào peer connection
    localStream.getTracks().forEach(track => {
      peerConnection.addTrack(track, localStream);
    });

    // Xử lý remote stream
    peerConnection.ontrack = event => {
      remoteVideo.value.srcObject = event.streams[0];
    };

    // Xử lý ICE candidate
    peerConnection.onicecandidate = event => {
      if (event.candidate) {
        socketService.emit('video_call_ice_candidate', {
          consultationId: consultationId,
          candidate: event.candidate
        });
      }
    };

    // Tham gia vào room video call
    socketService.emit('join_video_call', { 
      consultationId: consultationId 
    });

    // Lắng nghe các sự kiện từ socket
    socketService.on('participant_joined', handleParticipantJoined);
    socketService.on('participant_left', handleParticipantLeft);
    socketService.on('video_call_offer', handleOffer);
    socketService.on('video_call_answer', handleAnswer);
    socketService.on('video_call_ice_candidate', handleIceCandidate);
    socketService.on('video_call_ended', handleCallEnd);

    // Đợi offer từ user
    toast.add({
      severity: 'info',
      summary: 'Đang chờ bác sĩ',
      detail: 'Vui lòng đợi bác sĩ tham gia cuộc gọi',
      life: 3000
    });
  } catch (error) {
    console.error('Lỗi khởi tạo cuộc gọi:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể khởi tạo cuộc gọi video: ' + error.message,
      life: 3000
    });
    endCall();
  }
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
    <!-- ... rest of the template ... -->
  </div>
</template>

<style scoped>
/* ... existing styles ... */
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
/* ... rest of the styles ... */
</style> 