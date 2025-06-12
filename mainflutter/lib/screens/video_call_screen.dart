import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:permission_handler/permission_handler.dart';
import '../services/socket_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class VideoCallScreen extends StatefulWidget {
  final String consultationId;
  final bool isDoctor;
  const VideoCallScreen({super.key, required this.consultationId, required this.isDoctor});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late IO.Socket socket;
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  bool cameraEnabled = true;
  bool micEnabled = true;

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _connectSocket();
    _initializeCall();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    socket.dispose();
    _localStream?.dispose();
    _peerConnection?.close();
    super.dispose();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void _connectSocket() {
    socket = IO.io('${dotenv.env['BASE_URL']}', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'consultationId': widget.consultationId, 'isDoctor': widget.isDoctor}
    });
    socket.connect();

    socket.on('connect', (_) => print('Socket connected'));
    socket.on('video_call_offer', _onOffer);
    socket.on('video_call_answer', _onAnswer);
    socket.on('video_call_ice_candidate', _onIceCandidate);
    socket.on('video_call_end', (_) => _endCall());
  }

  Future<void> _initializeCall() async {
    try {
      debugPrint('=== INITIALIZING VIDEO CALL ===');
      debugPrint('Consultation ID: ${widget.consultationId}');
      debugPrint('Is Doctor: ${widget.isDoctor}');

      // Cập nhật trạng thái cuộc gọi trong database
      SocketService.instance.emit('update_consultation_status', {
        'consultationId': widget.consultationId,
        'status': 'in_progress',
        'startTime': DateTime.now().toIso8601String(),
      });

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
          debugPrint('✅ ICE candidate sent');
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
        SocketService.instance.emit('join_video_call', {
          'consultationId': widget.consultationId,
        });
        
        // Lắng nghe response từ server
        SocketService.instance.on('join_video_call_response', (response) {
          if (response['success']) {
            debugPrint('✅ Joined room: ${response['roomId']}');
            debugPrint('Participants: ${response['participants']}');
            
            // Nếu là người đầu tiên tham gia, đợi người thứ hai
            if (response['participants'].length == 1) {
              debugPrint('Waiting for other participant...');
            } else {
              // Nếu là người thứ hai tham gia, tạo offer
              debugPrint('Other participant found, creating offer...');
              _createAndSendOffer();
            }
          } else {
            debugPrint('❌ Failed to join room: ${response['message']}');
            _endCall();
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

  Future<void> _createAndSendOffer() async {
    try {
      debugPrint('=== CREATING OFFER ===');
      final offer = await _peerConnection!.createOffer();
      debugPrint('✅ Offer created: ${offer.toMap()}');

      debugPrint('=== SETTING LOCAL DESCRIPTION ===');
      await _peerConnection!.setLocalDescription(offer);
      debugPrint('✅ Local description set');

      debugPrint('=== SENDING OFFER ===');
      SocketService.instance.emit('video_call_offer', {
        'consultationId': widget.consultationId,
        'offer': offer.toMap(),
      });
      debugPrint('✅ Offer sent');
    } catch (e) {
      debugPrint('❌ Error creating offer: $e');
      _endCall();
    }
  }

  void _setupSocketListeners() {
    // Lắng nghe sự kiện participant joined
    SocketService.instance.on('participant_joined', (data) {
      debugPrint('=== PARTICIPANT JOINED ===');
      debugPrint('Data: $data');
    });

    // Lắng nghe sự kiện participant left
    SocketService.instance.on('participant_left', (data) {
      debugPrint('=== PARTICIPANT LEFT ===');
      debugPrint('Data: $data');
      
      // Chỉ hiển thị thông báo khi người kia thoát
      if (data['remainingParticipants'] > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Người tham gia đã rời cuộc gọi'),
            duration: Duration(seconds: 3),
          ),
        );
      }
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

  void _onOffer(data) async {
    if (!widget.isDoctor) return;
    RTCSessionDescription offer = RTCSessionDescription(data['offer']['sdp'], data['offer']['type']);
    await _peerConnection!.setRemoteDescription(offer);
    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    socket.emit('video_call_answer', {
      'consultationId': widget.consultationId,
      'answer': answer.toMap(),
      'isDoctor': true
    });
  }

  void _onAnswer(data) async {
    if (widget.isDoctor) return;
    RTCSessionDescription answer = RTCSessionDescription(data['answer']['sdp'], data['answer']['type']);
    await _peerConnection!.setRemoteDescription(answer);
  }

  void _onIceCandidate(data) async {
    var candidate = RTCIceCandidate(
      data['candidate']['candidate'],
      data['candidate']['sdpMid'],
      data['candidate']['sdpMLineIndex'],
    );
    await _peerConnection?.addCandidate(candidate);
  }

  void _endCall() {
    // Chỉ đóng kết nối WebRTC và thoát màn hình
    if (_localStream != null) {
      _localStream!.getTracks().forEach((track) => track.stop());
    }
    if (_peerConnection != null) {
      _peerConnection!.close();
    }
    
    // Cập nhật trạng thái cuộc gọi trong database
    SocketService.instance.emit('update_consultation_status', {
      'consultationId': widget.consultationId,
      'status': 'completed',
      'endTime': DateTime.now().toIso8601String(),
    });
    
    // Thông báo cho server biết người dùng đã thoát cuộc gọi
    SocketService.instance.emit('leave_video_call', {
      'consultationId': widget.consultationId,
    });
    
    // Thoát màn hình video call
    Navigator.pop(context);
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };

    return await createPeerConnection(configuration);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Call')),
      body: Column(
        children: [
          Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
          Expanded(child: RTCVideoView(_remoteRenderer)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(cameraEnabled ? Icons.videocam : Icons.videocam_off),
                onPressed: () {
                  setState(() {
                    cameraEnabled = !cameraEnabled;
                    _localStream?.getVideoTracks()[0].enabled = cameraEnabled;
                  });
                },
              ),
              IconButton(
                icon: Icon(micEnabled ? Icons.mic : Icons.mic_off),
                onPressed: () {
                  setState(() {
                    micEnabled = !micEnabled;
                    _localStream?.getAudioTracks()[0].enabled = micEnabled;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.call_end, color: Colors.red),
                onPressed: _endCall,
              ),
            ],
          ),
        ],
      ),
    );
  }
} 