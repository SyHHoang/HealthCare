import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:async';
import '../services/socket_service.dart';

class VideoCallWidget extends StatefulWidget {
  final String consultationId;
  final bool isDoctor;
  final VoidCallback onCallEnd;

  const VideoCallWidget({
    Key? key,
    required this.consultationId,
    required this.isDoctor,
    required this.onCallEnd,
  }) : super(key: key);

  @override
  State<VideoCallWidget> createState() => _VideoCallWidgetState();
}

class _VideoCallWidgetState extends State<VideoCallWidget> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  bool _isCameraEnabled = true;
  bool _isMicEnabled = true;
  final bool _isExpanded = false;
  String? _expandedVideo;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  bool _isFirstParticipant = false;
  Timer? _heartbeatTimer;

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _cleanup();
    _heartbeatTimer?.cancel();
    super.dispose();
  }

  void _cleanup() {
    _localStream?.getTracks().forEach((track) => track.stop());
    _peerConnection?.close();
    _localStream = null;
    _peerConnection = null;
  }

  void _startHeartbeat() {
    debugPrint('=== STARTING HEARTBEAT ===');
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      debugPrint('Sending heartbeat...');
      SocketService.instance.emit('heartbeat', {
        'consultationId': widget.consultationId,
      });
    });
  }

  Future<void> _initializeCall() async {
    try {
      debugPrint('=== INITIALIZING VIDEO CALL ===');
      debugPrint('Consultation ID: ${widget.consultationId}');
      debugPrint('Is Doctor: ${widget.isDoctor}');

      await _localRenderer.initialize();
      await _remoteRenderer.initialize();

      // Kiểm tra và yêu cầu quyền
      final cameraStatus = await Permission.camera.request();
      final micStatus = await Permission.microphone.request();

      if (cameraStatus.isGranted && micStatus.isGranted) {
        debugPrint('✅ Quyền camera và microphone đã được cấp');

        final constraints = <String, dynamic>{
          'audio': true,
          'video': {
            'mandatory': {
              'minWidth': '640',
              'minHeight': '480',
              'minFrameRate': '30',
            },
            'facingMode': 'user',
            'optional': [],
          }
        };

        _localStream = await navigator.mediaDevices.getUserMedia(constraints);
        _localRenderer.srcObject = _localStream;
        debugPrint('✅ Đã lấy được local stream');

        // Tạo peer connection
        _peerConnection = await _createPeerConnection();
        debugPrint('✅ Đã tạo peer connection');

        // Thêm stream local vào peer connection
        _localStream!.getTracks().forEach((track) {
          _peerConnection!.addTrack(track, _localStream!);
        });
        debugPrint('✅ Đã thêm local tracks vào peer connection');

        // Xử lý remote stream
        _peerConnection!.onTrack = (RTCTrackEvent event) {
          debugPrint('=== RECEIVED REMOTE TRACK ===');
          debugPrint('Track kind: ${event.track.kind}');
          debugPrint('Stream ID: ${event.streams[0].id}');
          
          if (event.streams.isNotEmpty) {
            _remoteRenderer.srcObject = event.streams[0];
            debugPrint('✅ Đã set remote stream vào renderer');
          }
        };

        // Xử lý ICE candidate
        _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
          debugPrint('=== SENDING ICE CANDIDATE ===');
          debugPrint('Consultation ID: ${widget.consultationId}');
          debugPrint('Candidate: ${candidate.toMap()}');
          SocketService.instance.emit('video_call_ice_candidate', {
            'consultationId': widget.consultationId,
            'candidate': candidate.toMap(),
          });
        };

        // Xử lý ICE connection state
        _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
          debugPrint('=== ICE CONNECTION STATE CHANGED ===');
          debugPrint('New state: $state');
          if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
            debugPrint('✅ ICE connection established');
          } else if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
            debugPrint('❌ ICE connection failed');
            _endCall();
          }
        };

        // Xử lý connection state
        _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
          debugPrint('=== CONNECTION STATE CHANGED ===');
          debugPrint('New state: $state');
          if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
            debugPrint('✅ Peer connection established');
          } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
            debugPrint('❌ Peer connection failed');
            _endCall();
          }
        };

        // Join video call room
        debugPrint('=== JOINING VIDEO CALL ROOM ===');
        debugPrint('Consultation ID: ${widget.consultationId}');
        SocketService.instance.emitWithCallback('join_video_call', {
          'consultationId': widget.consultationId,
        }, (response) {
          if (response != null && response['success'] == true) {
            _isFirstParticipant = response['isFirstParticipant'] ?? false;
            debugPrint('✅ Joined video call room. Is first participant: $_isFirstParticipant');
            
            // Bắt đầu gửi heartbeat sau khi join thành công
            _startHeartbeat();
          }
        });

        // Lắng nghe các sự kiện từ socket
        _setupSocketListeners();
      }
    } catch (e) {
      debugPrint('❌ Error initializing call: $e');
      _endCall();
    }
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    final configuration = <String, dynamic>{
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
      'iceCandidatePoolSize': 1, // Giới hạn số lượng ICE candidates
      'bundlePolicy': 'max-bundle',
      'rtcpMuxPolicy': 'require',
    };

    final constraints = <String, dynamic>{
      'mandatory': {},
      'optional': [
        {'DtlsSrtpKeyAgreement': true},
      ],
    };

    return await createPeerConnection(configuration, constraints);
  }

  Future<void> _createAndSendOffer() async {
    try {
      debugPrint('=== CREATING AND SENDING OFFER ===');
      debugPrint('Consultation ID: ${widget.consultationId}');

      // Tạo offer
      final offer = await _peerConnection!.createOffer();
      debugPrint('✅ Offer created');

      // Set local description
      await _peerConnection!.setLocalDescription(offer);
      debugPrint('✅ Local description set');

      // Gửi offer
      SocketService.instance.emit('video_call_offer', {
        'consultationId': widget.consultationId,
        'offer': offer.toMap(),
      });
      debugPrint('✅ Offer sent');
    } catch (e) {
      debugPrint('❌ Error creating and sending offer: $e');
      _endCall();
    }
  }

  void _setupSocketListeners() {
    // Lắng nghe sự kiện participant joined
    SocketService.instance.on('participant_joined', (data) async {
      debugPrint('=== PARTICIPANT JOINED ===');
      debugPrint('Data: $data');
      
      // Nếu là người đầu tiên và có người thứ 2 tham gia, tạo và gửi offer
      if (_isFirstParticipant) {
        debugPrint('First participant detected, waiting for 1 second before sending offer...');
        // Đợi 1 giây để đảm bảo người nhận đã sẵn sàng
        await Future.delayed(const Duration(seconds: 1));
        await _createAndSendOffer();
      }
    });

    // Lắng nghe sự kiện participant left
    SocketService.instance.on('participant_left', (data) {
      debugPrint('=== PARTICIPANT LEFT ===');
      debugPrint('Data: $data');
      
      // Chỉ kết thúc cuộc gọi nếu người kia rời đi và không phải là socket của chính mình
      if (data['socketId'] != SocketService.instance.socket?.id) {
        debugPrint('Other participant left, ending call...');
        _endCall();
      } else {
        debugPrint('Self left event, ignoring...');
      }
    });

    // Lắng nghe sự kiện video call offer
    SocketService.instance.on('video_call_offer', (data) async {
      debugPrint('=== RECEIVED VIDEO CALL OFFER ===');
      debugPrint('Data: $data');
      try {
        if (_peerConnection == null) {
          debugPrint('❌ No peer connection available');
          return;
        }

        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(
            data['offer']['sdp'],
            data['offer']['type'],
          ),
        );
        debugPrint('✅ Remote description set');

        final answer = await _peerConnection!.createAnswer();
        await _peerConnection!.setLocalDescription(answer);
        debugPrint('✅ Local description set');

        SocketService.instance.emit('video_call_answer', {
          'consultationId': widget.consultationId,
          'answer': answer.toMap(),
        });
        debugPrint('✅ Answer sent');
      } catch (e) {
        debugPrint('❌ Error handling offer: $e');
        _endCall();
      }
    });

    // Lắng nghe sự kiện video call answer
    SocketService.instance.on('video_call_answer', (data) async {
      debugPrint('=== RECEIVED VIDEO CALL ANSWER ===');
      debugPrint('Data: $data');
      try {
        if (_peerConnection == null) {
          debugPrint('❌ No peer connection available');
          return;
        }

        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(
            data['answer']['sdp'],
            data['answer']['type'],
          ),
        );
        debugPrint('✅ Remote description set from answer');
      } catch (e) {
        debugPrint('❌ Error handling answer: $e');
        _endCall();
      }
    });

    // Lắng nghe sự kiện ICE candidate
    SocketService.instance.on('video_call_ice_candidate', (data) async {
      debugPrint('=== RECEIVED ICE CANDIDATE ===');
      debugPrint('Data: $data');
      try {
        if (_peerConnection == null) {
          debugPrint('❌ No peer connection available');
          return;
        }

        if (data['candidate'] != null) {
          await _peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate']['candidate'],
              data['candidate']['sdpMid'],
              data['candidate']['sdpMLineIndex'],
            ),
          );
          debugPrint('✅ ICE candidate added');
        }
      } catch (e) {
        debugPrint('❌ Error handling ICE candidate: $e');
      }
    });

    // Lắng nghe sự kiện video call ended
    SocketService.instance.on('video_call_ended', (data) {
      debugPrint('=== CALL ENDED ===');
      debugPrint('Data: $data');
      
      // Chỉ kết thúc cuộc gọi nếu người kia kết thúc cuộc gọi
      if (data['by'] != widget.consultationId) {
        debugPrint('Call ended by other participant');
        _endCall();
      } else {
        debugPrint('Call ended by self, ignoring...');
      }
    });

    // Lắng nghe sự kiện participant disconnected
    SocketService.instance.on('participant_disconnected', (data) {
      debugPrint('=== PARTICIPANT DISCONNECTED ===');
      debugPrint('Data: $data');
      
      // Chỉ kết thúc cuộc gọi nếu người kia bị ngắt kết nối
      if (data['socketId'] != SocketService.instance.socket?.id) {
        debugPrint('Other participant disconnected, ending call...');
        _endCall();
      } else {
        debugPrint('Self disconnected event, ignoring...');
      }
    });
  }

  void _toggleCamera() {
    setState(() {
      _isCameraEnabled = !_isCameraEnabled;
      _localStream?.getVideoTracks().forEach((track) {
        track.enabled = _isCameraEnabled;
      });
    });
  }

  void _toggleMic() {
    setState(() {
      _isMicEnabled = !_isMicEnabled;
      _localStream?.getAudioTracks().forEach((track) {
        track.enabled = _isMicEnabled;
      });
    });
  }

  void _toggleExpand(String video) {
    setState(() {
      if (_expandedVideo == video) {
        _expandedVideo = null;
      } else {
        _expandedVideo = video;
      }
    });
  }

  void _endCall() {
    debugPrint('=== ENDING CALL ===');
    debugPrint('Consultation ID: ${widget.consultationId}');
    debugPrint('Socket ID: ${SocketService.instance.socket?.id}');
    
    // Hủy heartbeat timer
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    
    // Xóa tất cả listeners trước khi emit events
    SocketService.instance.off('participant_joined');
    SocketService.instance.off('participant_left');
    SocketService.instance.off('video_call_offer');
    SocketService.instance.off('video_call_answer');
    SocketService.instance.off('video_call_ice_candidate');
    SocketService.instance.off('video_call_ended');
    SocketService.instance.off('participant_disconnected');

    // Emit events
    SocketService.instance.emit('leave_video_call', {
      'consultationId': widget.consultationId,
    });
    
    SocketService.instance.emit('video_call_end', {
      'consultationId': widget.consultationId,
    });

    // Cleanup resources
    _cleanup();
    
    // Call parent callback
    widget.onCallEnd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _expandedVideo != null
                  ? _buildExpandedVideo()
                  : _buildGridVideo(),
            ),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildGridVideo() {
    // Xác định video nào là của bệnh nhân và bác sĩ
    final patientRenderer = widget.isDoctor ? _remoteRenderer : _localRenderer;
    final doctorRenderer = widget.isDoctor ? _localRenderer : _remoteRenderer;
    final patientLabel = widget.isDoctor ? 'Bệnh nhân' : 'Bạn';
    final doctorLabel = widget.isDoctor ? 'Bác sĩ' : 'Bác sĩ';

    return Stack(
      children: [
        // Màn hình bệnh nhân toàn màn hình
        Positioned.fill(
          child: _buildFullScreenVideo(
            patientRenderer,
            patientLabel,
            widget.isDoctor ? 'remote' : 'local',
          ),
        ),
        // Màn hình bác sĩ nhỏ ở góc phải
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            width: 120,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildSmallVideo(
                doctorRenderer,
                doctorLabel,
                widget.isDoctor ? 'local' : 'remote',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedVideo() {
    // Khi expand, hiển thị video được chọn toàn màn hình
    final renderer = _expandedVideo == 'local' ? _localRenderer : _remoteRenderer;
    final label = _expandedVideo == 'local'
        ? (widget.isDoctor ? 'Bác sĩ' : 'Bạn')
        : (widget.isDoctor ? 'Bệnh nhân' : 'Bác sĩ');

    return _buildFullScreenVideo(renderer, label, _expandedVideo!);
  }

  Widget _buildFullScreenVideo(RTCVideoRenderer renderer, String label, String type) {
    return GestureDetector(
      onTap: () => _toggleExpand(type),
      child: Stack(
        children: [
          RTCVideoView(
            renderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          ),
          Positioned(
            bottom: 80, // Đặt cao hơn để không bị che bởi controls
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallVideo(RTCVideoRenderer renderer, String label, String type) {
    return GestureDetector(
      onTap: () => _toggleExpand(type),
      child: Stack(
        children: [
          RTCVideoView(
            renderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          ),
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.fullscreen,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black87,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(
              _isCameraEnabled ? Icons.videocam : Icons.videocam_off,
              color: Colors.white,
            ),
            onPressed: _toggleCamera,
          ),
          IconButton(
            icon: Icon(
              _isMicEnabled ? Icons.mic : Icons.mic_off,
              color: Colors.white,
            ),
            onPressed: _toggleMic,
          ),
          FloatingActionButton(
            backgroundColor: Colors.red,
            onPressed: _endCall,
            child: const Icon(Icons.call_end),
          ),
        ],
      ),
    );
  }


} 