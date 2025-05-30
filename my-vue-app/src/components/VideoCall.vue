<template>
  <div class="video-call-container">
    <div class="video-grid">
      <div class="video-box">
        <video ref="localVideo" autoplay muted playsinline></video>
        <span class="video-label">Bạn</span>
      </div>
      <div class="video-box">
        <video ref="remoteVideo" autoplay playsinline></video>
        <span class="video-label">{{ isDoctor ? 'Bệnh nhân' : 'Bác sĩ' }}</span>
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
</template>

<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue';
import { useToast } from 'primevue/usetoast';
import { useRouter, useRoute } from 'vue-router';
import socketService from '@/services/socketService.js';

const props = defineProps({
  consultationId: {
    type: String,
    required: true
  }
});

const route = useRoute();
const isDoctor = computed(() => route.query.isDoctor === 'true');

const toast = useToast();
const router = useRouter();
const localVideo = ref(null);
const remoteVideo = ref(null);
const cameraEnabled = ref(true);
const micEnabled = ref(true);
const remainingTime = ref(30 * 60); // 30 phút tính bằng giây
let localStream = null;
let peerConnection = null;
let timerInterval = null;

const formatTime = (seconds) => {
  const minutes = Math.floor(seconds / 60);
  const remainingSeconds = seconds % 60;
  return `${minutes.toString().padStart(2, '0')}:${remainingSeconds.toString().padStart(2, '0')}`;
};

const startTimer = () => {
  timerInterval = setInterval(() => {
    remainingTime.value--;
    if (remainingTime.value <= 0) {
      clearInterval(timerInterval);
      endCall();
    }
  }, 1000);
};

const initializeCall = async () => {
  try {
    console.log('=== INITIALIZING VIDEO CALL ===');
    console.log('Consultation ID:', props.consultationId);
    console.log('Is Doctor:', isDoctor.value);

    // Cập nhật trạng thái cuộc gọi trong database
    await socketService.emit('update_consultation_status', {
      consultationId: props.consultationId,
      status: 'in_progress',
      startTime: new Date().toISOString()
    });

    // Lấy stream từ camera và mic
    localStream = await navigator.mediaDevices.getUserMedia({ 
      video: true, 
      audio: true 
    });
    localVideo.value.srcObject = localStream;
    console.log('✅ Got local media stream');

    // Tạo peer connection
    peerConnection = new RTCPeerConnection({
      iceServers: [
        { urls: 'stun:stun.l.google.com:19302' }
      ]
    });
    console.log('✅ Peer connection created');

    // Thêm stream local vào peer connection
    localStream.getTracks().forEach(track => {
      peerConnection.addTrack(track, localStream);
    });
    console.log('✅ Local tracks added');

    // Xử lý remote stream
    peerConnection.ontrack = event => {
      console.log('=== RECEIVED REMOTE TRACK ===');
      console.log('Track kind:', event.track.kind);
      console.log('Streams:', event.streams);
      remoteVideo.value.srcObject = event.streams[0];
      console.log('✅ Remote stream set');
    };

    // Xử lý ICE candidate
    peerConnection.onicecandidate = event => {
      if (event.candidate) {
        console.log('=== SENDING ICE CANDIDATE ===');
        console.log('Candidate:', event.candidate);
        socketService.emit('video_call_ice_candidate', {
          consultationId: props.consultationId,
          candidate: event.candidate
        });
        console.log('✅ ICE candidate sent');
      }
    };

    // Log ICE connection state
    peerConnection.oniceconnectionstatechange = () => {
      console.log('ICE Connection State:', peerConnection.iceConnectionState);
    };

    // Log connection state
    peerConnection.onconnectionstatechange = () => {
      console.log('Connection State:', peerConnection.connectionState);
    };

    // Tham gia vào room video call
    console.log('=== JOINING VIDEO CALL ROOM ===');
    socketService.emit('join_video_call', { 
      consultationId: props.consultationId 
    }, (response) => {
      if (response.success) {
        console.log('✅ Joined room:', response.roomId);
        console.log('Participants:', response.participants);
        
        // Nếu là người đầu tiên tham gia, đợi người thứ hai
        if (response.participants.length === 1) {
          console.log('Waiting for other participant...');
        } else {
          // Nếu là người thứ hai tham gia, tạo offer
          console.log('Other participant found, creating offer...');
          createAndSendOffer();
        }
      } else {
        console.error('Failed to join room:', response.message);
        toast.add({
          severity: 'error',
          summary: 'Lỗi',
          detail: response.message,
          life: 3000
        });
      }
    });

    // Lắng nghe các sự kiện từ socket
    socketService.on('participant_joined', handleParticipantJoined);
    socketService.on('participant_left', handleParticipantLeft);
    socketService.on('video_call_offer', handleOffer);
    socketService.on('video_call_answer', handleAnswer);
    socketService.on('video_call_ice_candidate', handleIceCandidate);
    socketService.on('video_call_ended', handleCallEnd);

    startTimer();
  } catch (error) {
    console.error('Error initializing call:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể khởi tạo cuộc gọi video: ' + error.message,
      life: 3000
    });
    endCall();
  }
};

const createAndSendOffer = async () => {
  try {
    console.log('=== CREATING OFFER ===');
    const offer = await peerConnection.createOffer();
    console.log('✅ Offer created:', offer);

    console.log('=== SETTING LOCAL DESCRIPTION ===');
    await peerConnection.setLocalDescription(offer);
    console.log('✅ Local description set');

    console.log('=== SENDING OFFER ===');
    socketService.emit('video_call_offer', {
      consultationId: props.consultationId,
      offer: offer
    });
    console.log('✅ Offer sent');
  } catch (error) {
    console.error('Error creating offer:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể tạo offer: ' + error.message,
      life: 3000
    });
  }
};

const handleParticipantJoined = (data) => {
  console.log('=== PARTICIPANT JOINED ===');
  console.log('Data:', data);
  toast.add({
    severity: 'success',
    summary: 'Thông báo',
    detail: 'Người tham gia đã vào cuộc gọi',
    life: 3000
  });
};

const handleParticipantLeft = (data) => {
  console.log('=== PARTICIPANT LEFT ===');
  console.log('Data:', data);
  
  // Chỉ hiển thị thông báo khi người kia thoát
  if (data.remainingParticipants > 0) {
    toast.add({
      severity: 'warn',
      summary: 'Thông báo',
      detail: 'Người tham gia đã rời cuộc gọi',
      life: 3000
    });
  }
};

const handleOffer = async (data) => {
  try {
    await peerConnection.setRemoteDescription(new RTCSessionDescription(data.offer));
    const answer = await peerConnection.createAnswer();
    await peerConnection.setLocalDescription(answer);
    socketService.emit('video_call_answer', {
      consultationId: props.consultationId,
      answer: answer
    });
  } catch (error) {
    console.error('Lỗi xử lý offer:', error);
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
    await peerConnection.addIceCandidate(new RTCIceCandidate(data.candidate));
  } catch (error) {
    console.error('Lỗi xử lý ICE candidate:', error);
  }
};

const handleCallEnd = () => {
  endCall();
};

const endCall = () => {
  // Dừng các track media
  if (localStream) {
    localStream.getTracks().forEach(track => track.stop());
  }
  
  // Đóng kết nối WebRTC
  if (peerConnection) {
    peerConnection.close();
  }
  
  // Dừng timer
  if (timerInterval) {
    clearInterval(timerInterval);
  }
  
  // Cập nhật trạng thái cuộc gọi trong database
  socketService.emit('update_consultation_status', {
    consultationId: props.consultationId,
    status: 'completed',
    endTime: new Date().toISOString()
  });
  
  // Thông báo cho server biết người dùng đã thoát cuộc gọi
  socketService.emit('leave_video_call', {
    consultationId: props.consultationId
  });
  
  // Thoát màn hình video call
  router.back();
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

onMounted(() => {
  initializeCall();
});

onUnmounted(() => {
  if (localStream) {
    localStream.getTracks().forEach(track => track.stop());
  }
  if (peerConnection) {
    peerConnection.close();
  }
  if (timerInterval) {
    clearInterval(timerInterval);
  }
  socketService.emit('leave_video_call', {
    consultationId: props.consultationId
  });
});
</script>

<style scoped>
.video-call-container {
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
}

.video-box {
  position: relative;
  background-color: #1a1a1a;
  border-radius: 10px;
  overflow: hidden;
  height: 100%;
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

@media (max-width: 768px) {
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