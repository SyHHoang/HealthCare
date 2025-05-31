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
    super.dispose();
  }

  void _cleanup() {
    _localStream?.getTracks().forEach((track) => track.stop());
    _peerConnection?.close();
    _localStream = null;
    _peerConnection = null;
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
            
            // Không gửi offer ngay lập tức, đợi người thứ 2 tham gia
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
        debugPrint('First participant detected, creating and sending offer...');
        await _createAndSendOffer();
      }
    });

    // Lắng nghe sự kiện participant left
    SocketService.instance.on('participant_left', (data) {
      debugPrint('=== PARTICIPANT LEFT ===');
      debugPrint('Data: $data');
      _endCall();
    });

    // Lắng nghe sự kiện video call offer
    SocketService.instance.on('video_call_offer', (data) async {
      debugPrint('=== RECEIVED VIDEO CALL OFFER ===');
      debugPrint('Data: $data');
      try {
        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(
            data['offer']['sdp'],
            data['offer']['type'],
          ),
        );
        final answer = await _peerConnection!.createAnswer();
        await _peerConnection!.setLocalDescription(answer);
        SocketService.instance.emit('video_call_answer', {
          'consultationId': widget.consultationId,
          'answer': answer.toMap(),
        });
        debugPrint('✅ Đã gửi answer');
      } catch (e) {
        debugPrint('❌ Error handling offer: $e');
      }
    });

    // Lắng nghe sự kiện video call answer
    SocketService.instance.on('video_call_answer', (data) async {
      debugPrint('=== RECEIVED VIDEO CALL ANSWER ===');
      debugPrint('Data: $data');
      try {
        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(
            data['answer']['sdp'],
            data['answer']['type'],
          ),
        );
        debugPrint('✅ Đã set remote description từ answer');
      } catch (e) {
        debugPrint('❌ Error handling answer: $e');
      }
    });

    // Lắng nghe sự kiện ICE candidate
    SocketService.instance.on('video_call_ice_candidate', (data) async {
      debugPrint('=== RECEIVED ICE CANDIDATE ===');
      debugPrint('Data: $data');
      try {
        if (data['candidate'] != null) {
          await _peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate']['candidate'],
              data['candidate']['sdpMid'],
              data['candidate']['sdpMLineIndex'],
            ),
          );
          debugPrint('✅ Đã thêm ICE candidate');
        }
      } catch (e) {
        debugPrint('❌ Error handling ICE candidate: $e');
      }
    });

    // Lắng nghe sự kiện video call ended
    SocketService.instance.on('video_call_ended', (data) {
      debugPrint('=== CALL ENDED ===');
      debugPrint('Data: $data');
      _endCall();
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
    _cleanup();
    SocketService.instance.emit('leave_video_call', {
      'consultationId': widget.consultationId,
    });
    SocketService.instance.emit('video_call_end', {
      'consultationId': widget.consultationId,
    });
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
    return GridView.count(
      crossAxisCount: 2,
      children: [
        _buildVideoBox(
          _localRenderer,
          widget.isDoctor ? 'Bác sĩ' : 'Bạn',
          'local',
        ),
        _buildVideoBox(
          _remoteRenderer,
          widget.isDoctor ? 'Bệnh nhân' : 'Bác sĩ',
          'remote',
        ),
      ],
    );
  }

  Widget _buildExpandedVideo() {
    return _buildVideoBox(
      _expandedVideo == 'local' ? _localRenderer : _remoteRenderer,
      _expandedVideo == 'local'
          ? (widget.isDoctor ? 'Bác sĩ' : 'Bạn')
          : (widget.isDoctor ? 'Bệnh nhân' : 'Bác sĩ'),
      _expandedVideo!,
    );
  }

  Widget _buildVideoBox(RTCVideoRenderer renderer, String label, String type) {
    return GestureDetector(
      onTap: () => _toggleExpand(type),
      child: Stack(
        children: [
          RTCVideoView(
            renderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: Icon(
                _expandedVideo == type ? Icons.fullscreen_exit : Icons.fullscreen,
                color: Colors.white,
              ),
              onPressed: () => _toggleExpand(type),
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

  Future<void> _checkConnection() async {
    if (_peerConnection == null) return;

    final iceState = _peerConnection!.iceConnectionState;
    final connState = _peerConnection!.connectionState;

    debugPrint('=== CHECKING CONNECTION ===');
    debugPrint('ICE State: $iceState');
    debugPrint('Connection State: $connState');

    if (iceState == RTCIceConnectionState.RTCIceConnectionStateFailed ||
        connState == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
      debugPrint('❌ Connection failed, attempting to reconnect...');
      await _reconnect();
    }
  }

  Future<void> _reconnect() async {
    try {
      debugPrint('=== RECONNECTING ===');
      // Đóng kết nối cũ
      await _peerConnection?.close();
      _peerConnection = null;

      // Khởi tạo lại kết nối
      await _initializeCall();
    } catch (e) {
      debugPrint('❌ Reconnection failed: $e');
      _endCall();
    }
  }
} 