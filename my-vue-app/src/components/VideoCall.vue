<template>
  <div class="video-call-container">
    <div class="video-grid">
      <div class="video-box">
        <video ref="localVideo" autoplay muted></video>
        <span class="video-label">Bạn</span>
      </div>
      <div class="video-box">
        <video ref="remoteVideo" autoplay></video>
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
    
    // Hiển thị cảnh báo khi còn 5 phút
    if (remainingTime.value === 300) {
      toast.add({
        severity: 'warn',
        summary: 'Cảnh báo',
        detail: 'Bạn còn 5 phút nữa trong cuộc gọi',
        life: 5000
      });
    }
    
    // Kết thúc cuộc gọi khi hết thời gian
    if (remainingTime.value <= 0) {
      clearInterval(timerInterval);
      toast.add({
        severity: 'error',
        summary: 'Hết thời gian',
        detail: 'Cuộc gọi của bạn đã kết thúc do hết thời gian',
        life: 5000
      });
      endCall();
    }
  }, 1000);
};

const initializeCall = async () => {
  try {
    // Lấy stream từ camera và mic
    localStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
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
          consultationId: props.consultationId,
          candidate: event.candidate,
          isDoctor: isDoctor.value
        });
      }
    };

    // Kết nối với socket
    socketService.connect();
    
    // Lắng nghe các sự kiện từ socket
    socketService.on('video_call_offer', handleOffer);
    socketService.on('video_call_answer', handleAnswer);
    socketService.on('video_call_ice_candidate', handleIceCandidate);
    socketService.on('video_call_end', handleCallEnd);

    // Nếu là bác sĩ, tạo offer
    if (isDoctor.value) {
      const offer = await peerConnection.createOffer();
      await peerConnection.setLocalDescription(offer);
      
      socketService.emit('video_call_offer', {
        consultationId: props.consultationId,
        offer: offer,
        isDoctor: true
      });
    }

    // Bắt đầu đếm thời gian
    startTimer();
  } catch (error) {
    console.error('Lỗi khởi tạo cuộc gọi:', error);
    toast.add({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Không thể khởi tạo cuộc gọi video',
      life: 3000
    });
  }
};

const handleOffer = async (data) => {
  if (data.consultationId !== props.consultationId || !isDoctor.value) return;
  
  try {
    await peerConnection.setRemoteDescription(new RTCSessionDescription(data.offer));
    const answer = await peerConnection.createAnswer();
    await peerConnection.setLocalDescription(answer);
    
    socketService.emit('video_call_answer', {
      consultationId: props.consultationId,
      answer: answer,
      isDoctor: true
    });
  } catch (error) {
    console.error('Lỗi xử lý offer:', error);
  }
};

const handleAnswer = async (data) => {
  if (data.consultationId !== props.consultationId || isDoctor.value) return;
  
  try {
    await peerConnection.setRemoteDescription(new RTCSessionDescription(data.answer));
  } catch (error) {
    console.error('Lỗi xử lý answer:', error);
  }
};

const handleIceCandidate = async (data) => {
  if (data.consultationId !== props.consultationId) return;
  
  try {
    await peerConnection.addIceCandidate(new RTCIceCandidate(data.candidate));
  } catch (error) {
    console.error('Lỗi xử lý ICE candidate:', error);
  }
};

const handleCallEnd = (data) => {
  if (data.consultationId !== props.consultationId) return;
  endCall();
};

const endCall = async () => {
  try {
    if (localStream) {
      localStream.getTracks().forEach(track => track.stop());
    }
    if (peerConnection) {
      peerConnection.close();
    }
    if (timerInterval) {
      clearInterval(timerInterval);
    }
    
    socketService.emit('video_call_end', {
      consultationId: props.consultationId,
      isDoctor: isDoctor.value
    });
    
    router.back();
  } catch (error) {
    console.error('Lỗi kết thúc cuộc gọi:', error);
  }
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
  socketService.disconnect();
});
</script>

<style scoped>
.video-call-container {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  background-color: #1a1a1a;
  color: white;
}

.video-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  padding: 20px;
  flex-grow: 1;
}

.video-box {
  position: relative;
  background-color: #2a2a2a;
  border-radius: 10px;
  overflow: hidden;
  aspect-ratio: 16/9;
}

.video-box video {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.video-label {
  position: absolute;
  bottom: 10px;
  left: 10px;
  background-color: rgba(0, 0, 0, 0.5);
  padding: 5px 10px;
  border-radius: 5px;
}

.controls {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 20px;
  padding: 20px;
  background-color: #2a2a2a;
}

.controls button {
  padding: 10px 20px;
  border-radius: 20px;
  font-size: 1rem;
}

.controls button i {
  margin-right: 5px;
}

.timer {
  font-size: 1.2rem;
  font-weight: bold;
  padding: 10px 20px;
  border-radius: 20px;
  background-color: #28a745;
  color: white;
}

.timer.warning {
  background-color: #ffc107;
  color: black;
  animation: pulse 1s infinite;
}

@keyframes pulse {
  0% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
  100% {
    opacity: 1;
  }
}

.btn-danger {
  background-color: #dc3545;
  border-color: #dc3545;
}

.btn-secondary {
  background-color: #6c757d;
  border-color: #6c757d;
}
</style> 